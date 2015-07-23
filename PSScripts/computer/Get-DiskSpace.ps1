# Create an array to hold the information about the processes running on the computer
$allhdusage = New-Object System.Collections.ArrayList

if (Test-Connection -Computer $Computer -Count 1 -BufferSize 16 -Quiet ) {


    try {
    
    # Get the hard disk information
    $params = @{
        'ComputerName' = $Computer;
        'Class' = 'Win32_LogicalDisk';
        'Filter' = 'DriveType = 3';
        'ErrorAction' = 'Stop'
    }

    # If we are going to use alternate credentials to access the computer then supply it

    if($cred) {
        $params.Credential = $cred
    }


     $disks = Get-WmiObject  @params | Select-Object DeviceID, FreeSpace, Size, VolumeName

     if ($disks) {
        foreach ($disk in $disks) {
           $objdisk = New-Object System.Management.Automation.PSObject
           $objdisk | add-member NoteProperty "Computer" -value $Computer | Out-Null
           $objdisk | add-member NoteProperty "Device ID" -value $disk.DeviceID | Out-Null
           $objdisk | add-member NoteProperty "Volumn Name" -value $disk.VolumeName | Out-Null
           $objdisk | add-member NoteProperty "Size (GB)" -value ([Math]::Round($disk.Size/1GB,0)) | Out-Null
           $objdisk | add-Member NoteProperty "Used Space (GB)" ([Math]::Round($disk.Size/1GB - $disk.FreeSpace/1GB,0) ) | Out-Null
           $objdisk | add-member NoteProperty "Free Space (GB)" -value ([Math]::Round($disk.FreeSpace/1GB,0)) | Out-Null
           $objdisk | add-member NoteProperty "Percent Free (%)" -value ([Math]::Round((($disk.FreeSpace/1GB) / ($disk.Size/1GB) * 100),0)) | Out-Null

           $allhdusage.Add($objdisk) | Out-Null
        }

        #Clear-Variable disks
        
        # Output the disk inforamtion
        $allhdusage

        #$allhdusage.Clear()

     }

     }
     catch {
  
       if ($_.Exception.InnerException) {            $ExceptionMessage = $_.Exception.InnerException       }       else {             $ExceptionMessage = $_.Exception.Message       }       $ExceptionMessage 
       
     }
     

}
else {
  
  "Could not connect to computer $Computer...`r`n" 


}