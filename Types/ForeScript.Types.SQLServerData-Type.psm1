# -----------------------------------------------------------------------------------------
# Script: ForeScript.Types.SQLServerCheckList-Type.psm1.ps1
# Author: Nigel Thomas
# Date: June 24, 2015
# Version: 1.0
# Purpose: This module provides the functionality to convert The output from the SQL Server checklist
#          into a custom type named ForeScript.Types.SQLServerCheckList and to display it in ForeScript
#          usinga custom HTML Template.
#          
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

#Requires -version 3

function ConvertTo-SQLServerCheckList {

    [CmdletBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        #[System.Data.DataTable]$InputObject,
        $InputObject,
        $StartupLocation )

     
    # Set the working directory to the startup path of the script
    Set-Location $StartupLocation
    [System.IO.Directory]::SetCurrentDirectory($StartupLocation)

    Add-Type -Path ( '.\Types\Modules\ForeScript.Types.dll')

    #$InputObject

    $SQLServerChecklist = New-Object ForeScript.Types.SQLServerData
    $SQLServerChecklist.Description = $Header


    foreach ($dt in $InputObject) {
        
        if ($dt -ne $null) {
            if ($dt.Rows.Count -gt 0) {
                $SQLServerChecklist.QueryResult.Add($dt)
            }
        }
 
        #$SQLServerChecklist.QueryResult.Add($dt)
    }

    $SQLServerChecklist

}

function Out-SQLServerChecklist {

    Param (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [ForeScript.Types.SQLServerData]$InputObject,

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
    }

    $i = 1
    foreach ($query in $InputObject.QueryResult) {

        $tplparameter."TEMPL_QUERY$i" = $InputObject.ConvertToJson($query)
        $i++
    }

    foreach ($key in $tplparameter.Keys) {
             $outputtemplate = $outputtemplate.Replace($key, $tplparameter[$key])
    }

    $outputtemplate
}


# Set functions to read only
Set-Item -Path function:ConvertTo-SQLServerCheckList -Options ReadOnly
Set-Item -Path function:Out-SQLServerChecklist -Options ReadOnly


# Export the functions that will be accessed outside the module
Export-ModuleMember -Function ConvertTo-SQLServerCheckList, Out-SQLServerChecklist