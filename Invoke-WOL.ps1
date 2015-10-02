

    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $MacAddress,
        [Parameter(Mandatory=$true)]
        $BroadCastAddress
    )

    # Based on http://viniciuscanto.blogspot.com/2010/01/wake-on-lan-powershell-waking-up.html
    function Execute-WOL {
        
        [Cmdletbinding()]
        Param(
            [Parameter(Mandatory=$true)]
            $MacAddress,
            [Parameter(Mandatory=$true)]
            $BroadCastAddress
        )


        # The number of times to send out the WOL packet for each MAC Address
        # This has to be sent out multiple times to work
        [int]$NumberPackets = 4

        # Create the UDP datagram ssocket
        $socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.AddressFamily]::InterNetwork, [System.Net.Sockets.SocketType]::Dgram, [System.Net.Sockets.ProtocolType]::Udp)

        # Setup the connection information
	    $destination = [System.Net.IPAddress]::Parse($broadcastAddress)
	    $endpoint = New-Object System.Net.IPEndpoint($destination,0) 

        # Send the packet
        
        # Create the packet
	    [byte[]]$buffer = @(255,255,255,255,255,255) 
	    $buffer += (($MacAddress.split(':-') | foreach {[byte]('0x' + $_)}) * 16)
    
        # Send the packet. Need to send it a few times for it to work
        for ($i = 0; $i -le $NumberPackets; $i ++) {
             $sent = $socket.Sendto($buffer, $buffer.length, 0, $endpoint) 
             Start-Sleep 5
        }
	
        #"$sent bytes sent. The computer $macAddress may be initializing."


    }

    # Start of the Invoke-RemoteWOL Script

    # We get the broacast address of the remote ip subnet and invoke WOL
    # for each MAC Address in the array of MAC Addresses
    try {
    
         foreach ($Mac in $MacAddress) {
            
            if ($Mac -eq $null) {
                continue
            }

            Execute-WOL  -MacAddress $Mac -BroadCastAddress $BroadCastAddress
         }
    }
    catch {

        if ($_.Exception.InnerException) {           $ExceptionMessage = $_.Exception.InnerException        }        else {         $ExceptionMessage = $_.Exception.Message        }
        
        $ExceptionMessage 

    }

    

