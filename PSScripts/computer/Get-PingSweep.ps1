    $objWOLInfo = [ordered]@{}
    $objWOLInfo.ClientIP = $Computer
    #$objWOLInfo.ClientName = $InputObject.ClientName
    #$objWOLInfo.MacAddress = $InputObject.MacAddress
        
    if (Test-Connection -ComputerName $Computer -BufferSize 16 -Count 1 -Quiet -ErrorAction SilentlyContinue) {

        $objWOLInfo.Online = $true
    }
    else {
        $objWOLInfo.Online = $false
    }

    $objWOLInfo