# -----------------------------------------------------------------------------------------
# Script: Set-LocalAdmininistrator.ps1
# Author: Nigel Thomas
# Date: July 21, 2015
# Version: 1.0
# Purpose: This script is used change the local administrator name, password on desktop computers.
#          It will also enable the local administrator account as well.
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3


if ($Computer -eq $null) {
    $Computer = $env:COMPUTERNAME
}

$PasswdFormatFile = 'c:\psscripts\passwordformat.txt'
$RenameAdministratorFile = 'c:\psscripts\renameadministrator.txt'

if ((Test-Path $PasswdFormatFile) -and (Test-Path $RenameAdministratorFile) ) {
    $Passwordformat = Get-Content -Path $PasswdFormatFile  -Raw
    $RenameAdministrator = Get-Content -Path $RenameAdministratorFile  -Raw
}

else {
    $message = "Could not find the Password formating file at $PasswdFormatFile. `r`n"
    $message += "Could not find the Administrator Renaming file at $RenameAdministratorFile."
    $message
    return
}

# Get the event id 4724 and 4728 created within the last hour. These evenets are created when a users password is reset.

$query4724 = '
     <QueryList>
    <Query Id="0" Path="Security">
    <Select Path="Security">*[System[(EventID=4724) and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
   </Query>
   </QueryList>
'
$query4738 = '
     <QueryList>
     <Query Id="0" Path="Security">
     <Select Path="Security">*[System[(EventID=4738) and TimeCreated[timediff(@SystemTime) &lt;= 3600000]]]</Select>
     </Query>
    </QueryList>
'

if (Test-Connection -Computer $Computer -Count 1 -BufferSize 16 -Quiet ) {


    try {

        # Get the CSName for client computers.
        # ProductType = 1 designate a desktop computer
        $os_params = @{
            'ComputerName' = $Computer;
            'Class' = 'win32_operatingsystem ';
            #'Filter' = 'ProductType = "1"';
            'ErrorAction' = 'Stop'
        }

        # If we are going to use alternate credentials to access the computer then supply it

        if($FS_Credential) {
            $os_params.Credential = $FS_Credential
        }

        # Get the name of the computer
        $CSName = (Get-WmiObject @os_params).CSName

        # If we did not get anything, ie not client computer bail out, or just could not get the name then bail out
        if (!$CSName) {
            $message = "$Computer is running a Server Operating System.`r`n"
            $message += "This script can only be used to reset the Administrator password on Desktop computers.`r`n"
            $message
            return
        }
        # Find the local administrator account. We will use the well know SID for the local administrator        $findadminparams = @{            'ComputerName' = $Computer;
            'Class' = 'Win32_UserAccount ';
            'Filter' = 'LocalAccount = TRUE and SID like "S-1-5-21-%-500"';
            'ErrorAction' = 'Stop'        }        if($FS_Credential) {
            $findadminparams.Credential = $FS_Credential
        }        # Get the local administrator account        $findadmin = (Get-WmiObject @findadminparams).Name        [adsi]$admin = [adsi]("WinNT://$Computer/$findadmin,User")        $setpasswordresults = [ordered]@{            'Date' = (Get-Date -format F).ToString()            'Computer Name' = $Computer        }        if ($admin) {

            $setpasswordresults.'Local Administrator Account' = $admin.Name.ToString()

            # Create new password based on the template and we will enable the administrator user account as well
            $NewPassword = Invoke-Expression $Passwordformat 
            #$NewPassword
            $setpasswordresults.'New Password' = $NewPassword

            $admin.SetPassword($NewPassword)
            $admin.UserFlags = 512
            $admin.SetInfo()

            # Rename the administrator account
            if ($RenameAdministrator.Length -gt 0) {
                $admin.psbase.Rename($RenameAdministrator)
                $admin.SetInfo()
                $setpasswordresults.'Renamed Account' = $admin.Name.ToString()
            }

            else {
                $setpasswordresults.'Renamed Account' = $findadmin
            }

            $admin.SetInfo()
            
            # Halt the script. Need to do this so that event log gets updated on remote computer
            Sleep 5

            # Query event log for password change messages
            $passwdchangeparams = @{
                'ComputerName' = $Computer
                'FilterXml' = $query4724
                'MaxEvents' = 1
                'ErrorAction' = 'Stop'
            }

            if($FS_Credential) {
                $passwdchangeparams.Credential = $FS_Credential
            }

            $setpasswordresults.'Security Event ID 4724' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message

            $passwdchangeparams = @{
                'ComputerName' = $Computer
                'FilterXml' = $query4738
                'MaxEvents' = 1
                'ErrorAction' = 'Stop'
            }

            if($FS_Credential) {
                $passwdchangeparams.Credential = $FS_Credential
            }

            $setpasswordresults.'Security Event ID 4738' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message

            # Test that the password was changed by mapping the ADMIN$ share on the computer as the 
            # local administrator with the new password
            $remotehost = "\\$Computer\admin`$"
            $remoteuser = $Computer + "\" + $admin.Name
            $map = New-Object -ComObject WScript.Network            $map.MapNetworkDrive('Z:',$remotehost,$false,$remoteuser,$NewPassword)            if ($map.EnumNetworkDrives() -contains $remotehost) {               $setpasswordresults.'Login Result' = "Network login to $Computer was successful."            }            else {                $setpasswordresults.'Login Result' = "Network login to $Computer was not successful or an error occured."            }            $map.RemoveNetworkDrive('Z:')        }        else {            $setpasswordresults.'Local Administrator Account' = $admin.Name.ToString()            $setpasswordresults.'New Password' = ""            # Halt the script. Need to do this so that event log gets updated on remote computer
            Sleep 5            # Query event log for password change messages
            $passwdchangeparams = @{
                'ComputerName' = $Computer
                'FilterXml' = $query4724
                'MaxEvents' = 1
            }

            if($FS_Credential) {
                $passwdchangeparams.Credential = $FS_Credential
            }

            $setpasswordresults.'Security Event ID 4724' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message

            $passwdchangeparams = @{
                'ComputerName' = $Computer
                'FilterXml' = $query4738
                'MaxEvents' = 1
            }

            if($FS_Credential) {
                $passwdchangeparams.Credential = $FS_Credential
            }

            $setpasswordresults.'Security Event ID 4738' = (Get-WinEvent @passwdchangeparams | Select -First 1).Message            $setpasswordresults.'Login Result' = "Network login to $Computer was not successful or an error occured."        }        #$setpasswordresults        $obj = New-Object -TypeName PSObject -Property $setpasswordresults        $obj        

     }
     catch {
         $ExceptionMessage = $_ | format-list -force | Out-String       "Exception generated for $Computer"       $ExceptionMessage 
     }
     

}
else {
  
  "Could not connect to computer $Computer...`r`n" 


}