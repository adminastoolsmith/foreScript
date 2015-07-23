# -----------------------------------------------------------------------------------------
# Script: ForeScript.Types.ServerChecklist-Type.psm1.ps1
# Author: Nigel Thomas
# Date: June 24, 2015
# Version: 1.0
# Purpose: This module provides a sample for processing custom data types in ForeScript. 
#          The module must be named My_CUSTOM_DATA_Type-Type.psm1. It must expose functions
#          that will format a PSObject into the custom data type and to convert the custom
#          data type into an HTML output for display purposes.
#          The mappings for the custom types is found in the fstypes.json file in the 
#          config folder.
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3

function ConvertTo-ServerCheckList {

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        $StartupLocation )

     
    # Set the working directory to the startup path of the script
    Set-Location $StartupLocation
    [System.IO.Directory]::SetCurrentDirectory($StartupLocation)

    Add-Type -Path ( '.\Types\Modules\ForeScript.Types.dll')

    #$InputObject

    $ServerChecklist = New-Object ForeScript.Types.ServerChecklist
    $ServerChecklist.Description = $Header

    $SystemParams = @{
        ComputerName = $InputObject.System.Computername
        OS = $InputObject.System.OS
        ServicePack = $InputObject.System.ServicePack
        FreePhysicalMemory = $InputObject.System.FreePhysicalMemory
        FreeVirtualMemory = $InputObject.System.FreeVirtualMemory
        TotalVirtualMemorySize = $InputObject.System.TotalVirtualMemorySize
        TotalVisibleMemorySize = $InputObject.System.TotalVisibleMemorySize
        NumberOfProcesses = $InputObject.System.NumberOfProcesses
        LastBoot = $InputObject.System.LastBoot
        Uptime = $InputObject.System.Uptime
    }

    $ServerChecklist.System = New-Object ForeScript.Types.ServerChecklist+SystemInfo
    $ServerChecklist.System = $SystemParams
    #$ServerChecklist.System
    #$ServerChecklist.ConvertToJson($ServerChecklist.System) | Out-String

    $CPUParams = @{
        Manufacturer = $InputObject.Processor.Manufacturer
        Model = $InputObject.Processor.Model
        Architecture = $InputObject.Processor.Architecture
        Processors = $InputObject.Processor.Processors
    }

    $ServerCheckList.Processor = New-Object ForeScript.Types.ServerChecklist+ProcessorInfo
    $ServerCheckList.Processor = $CPUParams


    foreach ($Harddisk in $InputObject.HardDisk) {
  
        $ServerChecklist.AddHardDisk($Harddisk.DeviceID, $Harddisk.SizeGB, $Harddisk.FreeGB, $Harddisk.PercentFree)
    }

    foreach ($Service in $InputObject.Service) {
 
        $ServerChecklist.AddService($Service.Name, $Service.DisplayName, $Service.StartMode)
    }

    foreach ($ApplicationLog in $InputObject.ApplicationLog) {
 
        $ServerChecklist.AddApplicationLog($ApplicationLog.TimeGenerated, $ApplicationLog.EventCode, $ApplicationLog.SourceName, $ApplicationLog.Type, $ApplicationLog.Message)
    }

    foreach ($SystemLog in $InputObject.SystemLog) {
 
        $ServerChecklist.AddSystemLog($SystemLog.TimeGenerated, $SystemLog.EventCode, $SystemLog.SourceName, $SystemLog.Type, $SystemLog.Message)
    }

    $ServerChecklist

}

function Out-ServerChecklist {

    Param (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ForeScript.Types.ServerChecklist]$InputObject,

        [Parameter(Position=1,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        $Template
 
    )

    $TEMPL_JQUERY_VERSION = (Get-Content ".\Templates\scripts\jquery-1.9.1.min.js" -ReadCount 0 | Out-String )
    $TEMPL_JQUERYDATATABLE_VERSION = (Get-Content ".\Templates\scripts\json.htmTable.js" -ReadCount 0 | Out-String )
    $outputtemplate = (Get-Content ".\Templates\html\$Template" -ReadCount 0 | Out-String )
   
    $tplparameter = @{ "TEMPL_JQUERY_VERSION" = "$TEMPL_JQUERY_VERSION";
                          "TEMPL_JQUERYDATATABLE_VERSION" = "$TEMPL_JQUERYDATATABLE_VERSION";
                          "TEMPL_HEADING" = $InputObject.Description;
                          "TEMPL_COMPUTERSYSTEM" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.System);
                          "TEMPL_COMPUTERPROCESSOR" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.Processor);
                          "TEMPL_COMPUTERDISKS" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.HardDisk);
                          "TEMPL_COMPUTERSERVICE" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.Service);
                          "TEMPL_COMPUTERSYSLOG" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.SystemLog);
                          "TEMPL_COMPUTERAPPLOG" = [ForeScript.Types.Utility]::ConvertToJson($InputObject.ApplicationLog)

    }

    foreach ($key in $tplparameter.Keys) {
             $outputtemplate = $outputtemplate.Replace($key, $tplparameter[$key])
    }

    $outputtemplate
}


# Set functions to read only
Set-Item -Path function:ConvertTo-ServerCheckList -Options ReadOnly
Set-Item -Path function:Out-ServerChecklist -Options ReadOnly


# Export the functions that will be accessed outside the module
Export-ModuleMember -Function ConvertTo-ServerCheckList, Out-ServerChecklist