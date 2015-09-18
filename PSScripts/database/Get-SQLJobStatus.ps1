﻿# -----------------------------------------------------------------------------------------
# Script: Get-SQLJobStatus.ps1
# Author: Nigel Thomas
# Date: September 19, 2015
# Version: 1.0
# Purpose: This script is used to retrive the SQL Server agent job status.
#
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

<#
    .SYNOPSIS
    
        of free space or have X gigabytes of free space.

    .PARAMETER FreeSpace
        Returns the hard disk with X gigabytes of free space.

    .PARAMETER PercentFree
        Returns the hard disk with X percentage of free space.

    .Link 
        https://toolsmith.brycoretechnologies.com
    
    .Notes
        SQL SCRIPT SOURCES: 
        https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/
        http://sqlrepository.co.uk/code-snippets/sql-dba-code-snippets/script-to-finds-failed-sql-server-agent-jobs/
#>
[Cmdletbinding()]
Param (
    $ComputerName = $env:COMPUTERNAME
)


function Get-QueryResults {

    Param (
        $SQLConnection,
        $Query
    )

    #try {
    $ds = New-object "System.Data.DataSet" "SQLServerChecklistData"
    #$ds = New-object "System.Data.DataTable" "SQLServerChecklistData"
    $da = New-Object "System.Data.SqlClient.SqlDataAdapter" ($Query, $SQLConnection)
    $da.Fill($ds) | Out-Null
    #return @(,$ds)

    if ($ds.Tables[0].Rows.Count  -gt 0) {
        return $ds
    }


    # Return an empty dataset
    $newRow = $ds.Tables[0].NewRow()
    #$newRow[0] = $Query
    $ds.Tables[0].Rows.Add($newRow)  

    return $ds

    <#}
    catch {
        # Return a dataset with the error
        $ds = New-object "System.Data.DataSet" "SQLServerChecklistData"
        $dt = New-object "System.Data.DataTable" "SQLServerChecklistData"
        $dt.Columns.Add('Query')
        $dt.Columns.Add('Error')
        $ds.Tables.Add($dt)
        $newRow = $ds.Tables[0].NewRow()
        $newRow[0] = $Query
        $newRow[1] = $_
        $ds.Tables[0].Rows.Add($newRow)  

        $ds
    }#>


    
}
                      SET @Date = DATEADD(dd, -1, GETDATE()) -- Last 1 day


                     SELECT j.[name] [Agnet_Job_Name], js.step_name [Step_name], js.step_id [Step ID], js.command [Command_executed], js.database_name [Databse_Name],
                     msdb.dbo.agent_datetime(h.run_date, h.run_time) as [Run_DateTime] , h.sql_severity [Severity], h.message [Error_Message], h.server [Server_Name],
                     h.retries_attempted [Number_of_retry_attempts],
                     CASE h.run_status 
                      WHEN 0 THEN 'Failed'
                      WHEN 1 THEN 'Succeeded'
                      WHEN 2 THEN 'Retry'
                      WHEN 3 THEN 'Canceled'
                    END as [Job_Status],
                    CASE js.last_run_outcome
                      WHEN 0 THEN 'Failed'
                      WHEN 1 THEN 'Succeeded'
                      WHEN 2 THEN 'Retry'
                      WHEN 3 THEN 'Canceled'
                      WHEN 5 THEN 'Unknown'
                   END as [Outcome_of_the_previous_execution]
                   FROM msdb.dbo.sysjobhistory h INNER JOIN msdb.dbo.sysjobs j ON h.job_id = j.job_id 
                   INNER JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id AND h.step_id = js.step_id
                   WHERE h.run_status = 0 AND msdb.dbo.agent_datetime(h.run_date, h.run_time)> @Date 

    $sqlagentjobsparams.Credential = $FS_Credential
}
            }

            #$ConnectionString 
            $cn = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)

  
     }#>
else {
  
  "Could not connect to computer $ComputerName ...`r`n" 


}