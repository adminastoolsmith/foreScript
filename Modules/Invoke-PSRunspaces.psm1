# -----------------------------------------------------------------------------------------
# Script: Invoke-PSRunspaces.psm1
# Author: Nigel Thomas
# Date: April 24, 2015
# Version: 1.0
# Purpose: This module contains the functions that are used to execute the Poershell scripts
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

$HelperFunctions = {

    function Format-FSTypes {
        [CmdletBinding()]
        Param(
            [Parameter(Position=0,Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            $InputObject,

            [Parameter(Position=1,Mandatory=$True)]
            [ValidateNotNullOrEmpty()]
            $Type,
            $Header)


        #try {
        
            # Set the working directory to the startup path of the script
            #$StartupLocation = Split-Path $script:MyInvocation.MyCommand.Path
            #$StartupLocation
            Set-Location $StartupLocation
            [System.IO.Directory]::SetCurrentDirectory($StartupLocation)

            Import-Module -Name ".\Types\$Type-Type.psm1"

            # Load the type mappings
            $typemap = (Get-Content  '.\Config\fstypes.json' -Raw).ToString().Trim() | ConvertFrom-Json
            #$typemap
            $output = $null

            foreach ($map in $typemap.Types) { 
                if ($map.Name -match $Type) {
                     #$map
                    $output = &$map.format -InputObject $InputObject -StartupLocation $StartupLocation
                }
            }
   
            Remove-Module -Name ".\Types\$Type-Type.psm1" | Out-Null
            return $output
        <#}
        catch {
            if ($_.Exception.InnerException) {                $ExceptionMessage = $_.Exception.InnerException            }            else {                $ExceptionMessage = $_.Exception.Message            }

            $ExceptionMessage
        }#>
 
    
    }


}

$DoImpersonation = {

        $Login_Impersonation = @'
namespace LOGIN_IMPERSONATION
{
    #region Using directives.
    // ----------------------------------------------------------------------

    using System;
    using System.Security.Principal;
    using System.Runtime.InteropServices;
    using System.ComponentModel;

    // ----------------------------------------------------------------------
    #endregion

    /////////////////////////////////////////////////////////////////////////

    /// <summary>
    /// Impersonation of a user. Allows to execute code under another
    /// user context.
    /// Please note that the account that instantiates the Impersonator class
    /// needs to have the 'Act as part of operating system' privilege set.
    /// </summary>
    /// <remarks>   
    /// This class is based on the information in the Microsoft knowledge base
    /// article http://support.microsoft.com/default.aspx?scid=kb;en-us;Q306158
    /// 
    /// Encapsulate an instance into a using-directive like e.g.:
    /// 
    ///     ...
    ///     using ( new Impersonator( "myUsername", "myDomainname", "myPassword" ) )
    ///     {
    ///         ...
    ///         [code that executes under the new context]
    ///         ...
    ///     }
    ///     ...
    /// 
    /// Please contact the author Uwe Keim (mailto:uwe.keim@zeta-software.de)
    /// for questions regarding this class.
    /// </remarks>
    public class Impersonator :
        IDisposable
    {
        #region Public methods.
        // ------------------------------------------------------------------

        /// <summary>
        /// Constructor. Starts the impersonation with the given credentials.
        /// Please note that the account that instantiates the Impersonator class
        /// needs to have the 'Act as part of operating system' privilege set.
        /// </summary>
        /// <param name="userName">The name of the user to act as.</param>
        /// <param name="domainName">The domain name of the user to act as.</param>
        /// <param name="password">The password of the user to act as.</param>
        public Impersonator(
            string userName,
            string domainName,
            string password)
        {
            ImpersonateValidUser(userName, domainName, password);
        }

        // ------------------------------------------------------------------
        #endregion

        #region IDisposable member.
        // ------------------------------------------------------------------

        public void Dispose()
        {
            UndoImpersonation();
        }

        // ------------------------------------------------------------------
        #endregion

        #region P/Invoke.
        // ------------------------------------------------------------------

        [DllImport("advapi32.dll", SetLastError = true)]
        private static extern int LogonUser(
            string lpszUserName,
            string lpszDomain,
            string lpszPassword,
            int dwLogonType,
            int dwLogonProvider,
            ref IntPtr phToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern int DuplicateToken(
            IntPtr hToken,
            int impersonationLevel,
            ref IntPtr hNewToken);

        [DllImport("advapi32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        private static extern bool RevertToSelf();

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        private static extern bool CloseHandle(
            IntPtr handle);

        private const int LOGON32_LOGON_INTERACTIVE = 2;
        private const int LOGON32_LOGON_NEW_CREDENTIALS = 9;
        private const int LOGON32_PROVIDER_DEFAULT = 0;

        // ------------------------------------------------------------------
        #endregion

        #region Private member.
        // ------------------------------------------------------------------

        /// <summary>
        /// Does the actual impersonation.
        /// </summary>
        /// <param name="userName">The name of the user to act as.</param>
        /// <param name="domainName">The domain name of the user to act as.</param>
        /// <param name="password">The password of the user to act as.</param>
        private void ImpersonateValidUser(
            string userName,
            string domain,
            string password)
        {
            WindowsIdentity tempWindowsIdentity = null;
            IntPtr token = IntPtr.Zero;
            IntPtr tokenDuplicate = IntPtr.Zero;

            try
            {
                if (RevertToSelf())
                {
                    if (LogonUser(
                        userName,
                        domain,
                        password,
                        LOGON32_LOGON_NEW_CREDENTIALS,
                        LOGON32_PROVIDER_DEFAULT,
                        ref token) != 0)
                    {
                        if (DuplicateToken(token, 2, ref tokenDuplicate) != 0)
                        {
                            tempWindowsIdentity = new WindowsIdentity(tokenDuplicate);
                            impersonationContext = tempWindowsIdentity.Impersonate();
                        }
                        else
                        {
                            throw new Win32Exception(Marshal.GetLastWin32Error());
                        }
                    }
                    else
                    {
                        throw new Win32Exception(Marshal.GetLastWin32Error());
                    }
                }
                else
                {
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                }
            }
            finally
            {
                if (token != IntPtr.Zero)
                {
                    CloseHandle(token);
                }
                if (tokenDuplicate != IntPtr.Zero)
                {
                    CloseHandle(tokenDuplicate);
                }
            }
        }

        /// <summary>
        /// Reverts the impersonation.
        /// </summary>
        private void UndoImpersonation()
        {
            if (impersonationContext != null)
            {
                impersonationContext.Undo();
            }
        }

        private WindowsImpersonationContext impersonationContext = null;

        // ------------------------------------------------------------------
        #endregion
    }

    /////////////////////////////////////////////////////////////////////////
}


'@

    try {

        if ($Impersonator) {
            $Impersonator.Dispose()
        }
        

        if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {

            Add-Type -TypeDefinition $Login_Impersonation
            
            $impersonatepassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $impersonatecred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $impersonatepassword
            $networkCred = $impersonatecred.GetNetworkCredential()
            $Impersonator = New-Object LOGIN_IMPERSONATION.Impersonator($networkCred.UserName.ToString(), $networkCred.Domain.ToString(), $networkCred.Password)

        }
    }
    catch {
          $ExceptionMessage = $_ | format-list -force | Out-String          "Exception generated for $ComputerName in DoImpersonation"          $ExceptionMessage 
    }

}

$DoCredential = {

     try {


        if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {
            
            $secpassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $cred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $secpassword

        }

        if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {
            
            $secpassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $FS_Credential = New-Object -typename System.Management.Automation.PSCredential -argumentlist $UserName, $secpassword

        }

    }
    catch {
        $ExceptionMessage = $_ | format-list -force | Out-String        "Exception generated for $ComputerName in DoCredentail"        $ExceptionMessage 
    }
}


function Execute-AsyncRunspaces {

    [CmdletBinding()]
    Param (

        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$True)]
        [ValidateNotNullOrEmpty()]
        [Alias('IPAddress', 'Server', 'Computer', 'ComputerName')]
        [PSObject[]]$InputObject,

        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [String]$InputScriptBlock,


        [Parameter(Mandatory=$false)]
        [int]$MaxRunspaces=20,

        [Parameter(Mandatory=$false)]
        $UserName,

        [Parameter(Mandatory=$false)]
        $Password,

        [Parameter(Mandatory=$false)]
        $AuthenticationType,

        [Parameter(Mandatory=$false)]
        $StartupLocation,

        [Parameter(Mandatory=$false)]
        $CallBackParams,

        [switch]$DoCallBack
    )

    BEGIN {

        try {

        
            $RunspaceThreads = @()

            $TempScriptBlock  = [System.Management.Automation.Language.Parser]::ParseInput($InputScriptBlock, [ref]$null, [ref]$null)

            # If no parameter block is defined in the script then provdide it
            if ($TempScriptBlock.ParamBlock -eq $null) {

                $DefaultParamBlock = "Param(`$ComputerName, `$CallBackParams, [Switch]`$DoCallBack )"
                $CredentialParamBlock = "Param(`$ComputerName, `$UserName, `$Password, `$CallBackParams, [Switch]`$DoCallBack )" 

            }

            # Extract the parameter block and add additional parametrs
            if ($TempScriptBlock.ParamBlock -ne $null) {
          
                $TempParamBlock = $TempScriptBlock.ParamBlock.Extent.Text.Substring(0, $TempScriptBlock.ParamBlock.Extent.Text.Length -1).TrimEnd()

                if ($TempScriptBlock.ParamBlock.Attributes -ne $null) {
                    $TempParamBlockAttributes = $TempScriptBlock.ParamBlock.Attributes.Extent.Text.Substring(0, $TempScriptBlock.ParamBlock.Attributes.Extent.Text.Length).TrimEnd()
                }

                #if ($TempScriptBlock.ParamBlock.Extent.Text.Contains("ComputerName")) {
                if ("`$ComputerName" -in $TempScriptBlock.ParamBlock.Parameters.Name.Extent.Text) {

                    $DefaultParamBlock = $TempParamBlockAttributes + "`r`n" + $TempParamBlock + ", `r`n `$CallBackParams, [Switch]`$DoCallBack )"
                    $CredentialParamBlock = $TempParamBlockAttributes + "`r`n" + $TempParamBlock + ", `r`n `$UserName, `$Password, `$CallBackParams, [Switch]`$DoCallBack )" 

                }
                else {

                    $DefaultParamBlock = $TempParamBlockAttributes + "`r`n" + $TempParamBlock + ", `r`n `$ComputerName, `$CallBackParams, [Switch]`$DoCallBack )"
                    $CredentialParamBlock = $TempParamBlockAttributes + "`r`n" + $TempParamBlock + ", `r`n `$ComputerName, `$UserName, `$Password, `$CallBackParams, [Switch]`$DoCallBack )"

                }
                
                if ($TempParamBlockAttributes -ne $null) {

                    $InputScriptBlock = $InputScriptBlock.Replace($TempScriptBlock.ParamBlock.Attributes.Extent.Text, "")
         
                }

                $InputScriptBlock = $InputScriptBlock.Replace($TempScriptBlock.ParamBlock.Extent.Text, "")
                
                #$InputScriptBlock
                
            }

            #$DefaultParamBlock
            #$CredentialParamBlock

            $ScriptBlock = [ScriptBlock]::Create($InputScriptBlock)            if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {                                if ($AuthenticationType -eq 'credential') {                    $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($CredentialParamBlock + "`r`n" + $DoCredential.ToString() + "`r`n" + $HelperFunctions.ToString() + "`r`n" + $ScriptBlock.ToString())                }                if ($AuthenticationType -eq 'impersonation'){                    $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($CredentialParamBlock + "`r`n" + $DoImpersonation.ToString() + "`r`n" + $HelperFunctions.ToString() + "`r`n" + $ScriptBlock.ToString())                }                if ($AuthenticationType -eq 'combined'){                    $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($CredentialParamBlock + "`r`n" + $DoImpersonation.ToString() + "`r`n" + $DoCredential.ToString() + "`r`n" + $HelperFunctions.ToString() + "`r`n" + $ScriptBlock.ToString())                }            }            else {                $ScriptBlock = $ExecutionContext.InvokeCommand.NewScriptBlock($DefaultParamBlock + "`r`n" + $HelperFunctions.ToString() + "`r`n" + $ScriptBlock.ToString())
            }

            #$ScriptBlock
            #$PSBoundParameters

            $InitialSessionState = [System.Management.Automation.Runspaces.Initialsessionstate]::CreateDefault()
            $RunspacePool = [Runspacefactory]::CreateRunspacePool(1, $MaxRunspaces, $InitialSessionState, $Host)
            $RunspacePool.ApartmentState = 'STA'
            #$RunspacePool.ThreadOptions = 'UseCurrentThread'
            $SS_StartupLOcation = New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry("StartupLocation", $StartupLocation, "")
		    $RunspacePool.InitialSessionState.Variables.Add($SS_StartupLOcation)
            $RunspacePool.Open()


        }
        catch {

            $ExceptionMessage = $_ | format-list -force            "Exception from Execute-AsyncRunspaces Begin block ..."            $ExceptionMessage 
        }
    }

    PROCESS {

        try {

            foreach ($ComputerName in $InputObject) {

                if ($ComputerName -eq $null) {
                    continue
                }

                if ([String]::IsNullOrEmpty($ComputerName)) {
                    continue
                }

                if ([String]::IsNullOrWhiteSpace($ComputerName)) {
                    continue
                }

                if (($PSBoundParameters.ContainsKey('UserName')) -and ($PSBoundParameters.ContainsKey('Password'))) {

                    $powershell = [Powershell]::Create().AddScript($ScriptBlock).AddParameter('ComputerName', $ComputerName).AddParameter('UserName', $UserName).AddParameter('Password', $Password).AddParameter('CallBackParams', $CallBackParams).AddParameter('DoCallBack', $DoCallBack)
                }
                else {

                    $powershell = [Powershell]::Create().AddScript($ScriptBlock).AddParameter('ComputerName', $ComputerName).AddParameter('CallBackParams', $CallBackParams).AddParameter('DoCallBack', $DoCallBack)
                }

                foreach ($key in $rsDataTransfer.scriptparameters.Keys) {
                    [void]$powershell.AddParameter($key, $rsDataTransfer.scriptparameters.$key)
                }

                $powershell.RunspacePool = $RunspacePool

                [Collections.Arraylist]$RunspaceThreads += New-Object PSObject -Property @{                    Computer = $Computer;                    PSInstance = $powershell;                    PSHandle = $powershell.BeginInvoke();
                }

            }
        }
        catch {
            $ExceptionMessage = $_ | format-list -force            "Exception from Execute-AsyncRunspaces Process block ..."            $ExceptionMessage 
        }
    }

    END {

        try {            while ($RunspaceThreads) {                  foreach ($RunspaceThread in $RunspaceThreads.ToArray()) {                                        if ($RunspaceThread.PSHandle.IsCompleted) {                        $rsDataTransfer.RunspaceOutPut += $RunspaceThread.PSInstance.EndInvoke($RunspaceThread.PSHandle)                        $RunspaceThread.PSInstance.Dispose()                        $RunspaceThreads.Remove($RunspaceThread)                    }                    <#if($rsDataTransfer.CancelScript) {                        break                    }                    [System.Windows.Forms.Application]::DoEvents()#>                }                #[System.Windows.Forms.Application]::DoEvents()                <#if($rsDataTransfer.CancelScript) {                    foreach ($RunspaceThread in $RunspaceThreads.ToArray()) {                        $RunspaceThread.PSInstance.Dispose()                        $RunspaceThreads.Remove($RunspaceThread)                    }                    $CancelMessage = "Script Cancelled by User Request `r`n"                    $CancelMessage                }#>            }

            $RunspacePool.Close()
        }
        catch {
            $ExceptionMessage = $_ | format-list -force            "Exception from Execute-AsyncRunspaces  End Block ..."            $ExceptionMessage 
        }
        <#finally {

            try {

                foreach ($RunspaceThread in $RunspaceThreads) {                    $rsDataTransfer += $RunspaceThread.PSInstance.EndInvoke($RunspaceThread.PSHandle)                    $RunspaceThread.PSInstance.Dispose()                }
            }
            catch {

                if ($_.Exception.InnerException) {                    $ExceptionMessage = $_.Exception.InnerException                }                else {                    $ExceptionMessage = $_.Exception.Message                }

                $ExceptionMessage

            }
        }#>
    }
}