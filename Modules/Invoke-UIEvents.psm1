# -----------------------------------------------------------------------------------------
# Script: Invoke-UIEvents.psm1
# Author: Nigel Thomas
# Date: April 24, 2015
# Version: 1.0
# Purpose: This module provides the functions that are linked to the control events
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------

# Import required modules
Import-Module -Name '.\Modules\foreScriptCore.psm1'
#Import-Module -Name '.\Modules\Invoke-WinAPI.psm1'


# Add the UI events that will be hooked up to the xamlGUI here
function Initialize-UIEvents {

    # Populate the scripts tab
    if (Test-Path '.\Config\psscripts.json') {
        
        try {
        # Read the psscripts.josn file and convert the josn data to pscustomobjects
        # Load the pscustomobjects into a collection
        $psscriptobjs =  (Get-Content '.\Config\psscripts.json' -Raw | ConvertFrom-Json)
        $allscripts = New-Object -TypeName System.Collections.ObjectModel.ObservableCollection[Object] -ArgumentList @(, $psscriptobjs.Scripts)

  
        # Create a collectionview and set the grouping to the folder column        # Bind the datagrid to the collectionview        [System.Windows.Data.ListCollectionView]$collectionview = [System.Windows.Data.CollectionViewSource]::GetDefaultView($allscripts)        $collectionview.GroupDescriptions.Add((New-Object System.Windows.Data.PropertyGroupDescription('Folder')))

        # Define the column headers and bindings that we want to display
        $colheader = @('name', 'author', 'description', 'folder', 'file', 'authtype', 'template', 'callback', 'warn')

        foreach ($col in $colheader) {

            $column = New-Object System.Windows.Controls.DataGridTextColumn
            $binding = New-Object System.Windows.Data.Binding($col)
            $column.Header = $col
            $column.Binding = $binding
            $xamlGUI.Control_DisplayPSScripts.Columns.Add($column)
        }
        
        $xamlGUI.Control_DisplayPSScripts.ItemsSource = $collectionview
        }
        catch {                    $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 
            Write-Exception -Message $ExceptionMessage
        }


        
    }
    

    # Event for the Clear Console Menu
    $xamlGUI.Control_ClearConsoleMenu.Add_Click({
        
        $xamlGUI.Control_ConsoleOutputRichTextBox.Document.Blocks.Clear()
    })

    # Event for the DHCP Close Tab Menu
    $xamlGUI.Control_DHCPCloseTabMenu.Add_Click({
        
        $selectedtabitem = $xamlGUI.Control_DisplayDHCPLeases.SelectedItem        $xamlGUI.Content = ""        $xamlGUI.Control_DisplayDHCPLeases.Items.Remove($selectedtabitem)
    })

    # Event for the DHCP Close All Tab Menu
    $xamlGUI.Control_DHCPCloseAllTabsMenu.Add_Click({
        
        $xamlGUI.Control_DisplayDHCPLeases.Items.Clear()
    })

    # Event for the Results Close Tab Menu
    $xamlGUI.Control_CloseTabMenu.Add_Click({
        
        $selectedtabitem = $xamlGUI.Control_DisplayResults.SelectedItem        $xamlGUI.Content = ""        $xamlGUI.Control_DisplayResults.Items.Remove($selectedtabitem)
    })

    # Event for the Results Close All Tab Menu
    $xamlGUI.Control_CloseAllTabsMenu.Add_Click({
        
        $xamlGUI.Control_DisplayResults.Items.Clear()
    })

    # Event for the Save Tab Contents Tab Menu
    $xamlGUI.Control_SaveTabContentsMenu.Add_Click({

        try {
            
            $SaveFileWithThisName = File-Save -TempFileName $xamlGUI.Control_DisplayResults.SelectedItem.Header            if ($SaveFileWithThisName -eq $null) {                return        
            }

            $selectedtabitem = $xamlGUI.Control_DisplayResults.SelectedItem

            # The tabitem content is set to the web browser control. Get the Header and Body of the HTML document.
            # Use a regex to remove the script tags from the HTML document.
            # The table is built in the web browser control
            $ScriptTgaRegex = '<script[^>]*>[\s\S]*?</script>'
            $htmldoc = $selectedtabitem.Content.Document.Body.Document.All.Item(2).innerHTML
            #$htmldoc = $htmldoc.Replace('id="DynamicTable"', "")
            $htmldoc = $htmldoc -replace $ScriptTgaRegex, ""
            $htmldoc = "<HTML>" + "`r`n" + $htmldoc + "`r`n"  + "</HTML>"
            
            #Write-Console -Message $htmldoc
            
            [System.IO.File]::WriteAllText($SaveFileWithThisName, $htmldoc, [System.Text.Encoding]::GetEncoding($selectedtabitem.Content.Document.Encoding))
        }
        catch {
            
            $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 
            Write-Exception -Message $ExceptionMessage
        }
        
        
    })

    # Event for the Save All Tab Contents Tab Menu
    $xamlGUI.Control_SaveAllTabContentsMenu.Add_Click({
        

        Write-Console -Message ("`r`nStarted saving reports at {0}" -f (Get-Date))
        $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait


        try {
            
            # Cycle through the tabitems and display them
            # Need to do that before we save them
            foreach ($tabitem in $xamlGUI.Control_DisplayResults.Items) {
        
                $tabitem.Focus()
                
                while (!$tabitem.IsInitialized) {
                    [System.Windows.Forms.Application]::DoEvents()
                }

                $tabitem.UpdateLayOut()
                
            }

            #Sleep 10

             # Switch to the Console Output
            $xamlGUI.Control_MainDisplay.SelectedIndex = 0

            foreach ($tabitem in $xamlGUI.Control_DisplayResults.Items) {
               
                Write-Console -Message $tabitem.Header

                $tabitem.Focus()
                $selectedtabitem = $tabitem
                $TempFileName = $tabitem.Header
                $SaveAsFileName = ($TempFileName.Replace(".txt", "").Trim() + "-" + (Get-Date -Format s).Replace(":", ""))

                $ScriptTgaRegex = '<script[^>]*>[\s\S]*?</script>'
                $htmldoc = $selectedtabitem.Content.Document.Body.Document.All.Item(2).innerHTML
                $htmldoc = $htmldoc -replace $ScriptTgaRegex, ""
                $htmldoc = "<HTML>" + "`r`n" + $htmldoc + "`r`n"  + "</HTML>"
            
                #Write-Console -Message $htmldoc

                $SaveFileWithThisName = ("./Reports/" + $SaveAsFileName + ".html")
                Write-Console -Message ("Saving report {0}" -f $SaveFileWithThisName)
            
                [System.IO.File]::WriteAllText($SaveFileWithThisName, $htmldoc, [System.Text.Encoding]::GetEncoding($selectedtabitem.Content.Document.Encoding))
            }

            
        }
        catch {

            $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 
            Write-Exception -Message $ExceptionMessage
        }
        finally {
            $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            Write-Console -Message ("`r`nCompleted saving reports at {0}" -f (Get-Date))
        }

    })

    # Event for the Select File button
    $xamlGUI.Control_SelectFileButton.Add_Click({
        
        try {

            $SelectedFile = File-Import            if ($SelectedFile -eq $null) {                return        
            }

            $xamlGUI.Control_SelectFileTextBox.Text = $SelectedFile
        }
        catch {

            $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 

            Write-Exception -Message $ExceptionMessage
        }
    })

    # Event for the Wake On LAN button
    $xamlGUI.Control_DoWOLButton.Add_Click({

        if ($xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked -eq $false) {

            Write-MessageBox -Message "Please enter the name or ip address of a DHCP Server, and a DHCP scope"
            $xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked = $true
            $xamlGUI.Control_DHCPServerTextBox.Focus()
            return
        }

        if (([String]::IsNullOrEmpty($xamlGUI.Control_DHCPServerTextBox.Text))) {
            
            Write-MessageBox -Message "Please enter the name or ip address of the DHCP Server."
            $xamlGUI.Control_DHCPServerTextBox.Focus()
		    return 
        }

        if (([String]::IsNullOrEmpty($xamlGUI.Control_DHCPSubnetScopeTextBox.Text))) {
		
            Write-MessageBox -Message "Please enter the ip address subnet scope."
		    $xamlGUI.Control_DHCPSubnetScopeTextBox.Focus()
		    return 
	    }
        
        # Check if we are using different login credentials
        # Check that the text boxes are not null or empty

        if ($xamlGUI.Control_ProvideCredentialCheckBox.IsChecked -eq $true) {
            
            if (([String]::IsNullOrEmpty($xamlGUI.Control_UserNameTextBox.Text))) {
		
                Write-MessageBox -Message "Please enter a user name in the domain\username format."
		        $xamlGUI.Control_UserNameTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return
	        }

            if (([String]::IsNullOrEmpty($xamlGUI.Control_PasswordTextBox.Password))) {
		
                Write-MessageBox -Message "Please enter a password."
		        $xamlGUI.Control_PasswordTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return
	       }
        }

        # If the key NameOrIPFromDHCP is present then delete it.
        if ($rsDataTransfer.ContainsKey('NameOrIPFromDHCP')) {
            $rsDataTransfer.Remove('NameOrIPFromDHCP')
        }

        try {

            $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait

            [System.Windows.Forms.Application]::DoEvents()

            
            if (!([String]::IsNullOrEmpty($xamlGUI.Control_DHCPServerTextBox.Text)) -and !([String]::IsNullOrEmpty($xamlGUI.Control_DHCPSubnetScopeTextBox.Text))) {
            
                    $parameters = @{
                        'DHCPServerNameOrIP' = $xamlGUI.Control_DHCPServerTextBox.Text;
                        'Subnet' = $xamlGUI.Control_DHCPSubnetScopeTextBox.Text;
                        'UserName' = $xamlGUI.Control_UserNameTextBox.Text;
                        'Password' =  $xamlGUI.Control_PasswordTextBox.Password
                    }
                    
                    # Get the DHCP client leases
                    Execute-GetDHCPSubnetClients @parameters

                    if ($rsDataTransfer.NameOrIPFromDHCP.Data) {
            
                        $HTMLHeading = "DHCP Client lease for server: " + $xamlGUI.Control_DHCPServerTextBox.Text
                        $HTMLData = $rsDataTransfer.NameOrIPFromDHCP.Data | ConvertTo-Json  -Compress
                        $HTMLClientLeases = ConvertTo-WPRHTML -Template 'FSDHCPLease.tpl' -TemplateHeading $HTMLHeading -Data $HTMLData
                        Write-TabbedUI -HTMLData $HTMLClientLeases -Tab 'Dhcp' -TabHeader ("DHCP Server: " + $xamlGUI.Control_DHCPServerTextBox.Text)

                    }

                    [System.Windows.Forms.Application]::DoEvents()


                    if ($rsDataTransfer.NameOrIPFromDHCP.Error) {
                        Write-Exception -Message $rsDataTransfer.NameOrIPFromDHCP.Error
                        return
                    }


                    # If the key WOLOutPut is present then delete it.
                    # It means that we have output from a previous WOL run
                    if ($rsDataTransfer.ContainsKey('WOLOutPut')) {
                        $rsDataTransfer.Remove('WOLOutPut')
                    }

                    # Do Wake On LAN
                    $wolparameters = @{
                        'InputObject' = $rsDataTransfer.NameOrIPFromDHCP.Data;
                        'Computer' = $xamlGUI.Control_DHCPServerTextBox.Text;
                        'UserName' = $xamlGUI.Control_UserNameTextBox.Text;
                        'Password' =  $xamlGUI.Control_PasswordTextBox.Password
                    }
                    
                    # Get the DHCP client leases
                    Execute-WOLJOb @wolparameters

                    if ($rsDataTransfer.WOLOutPut.Data) {
                        #Write-Console -Message $rsDataTransfer.WOLOutPut.Data
                        $WOLHeading = "WOL Results for subnet : " + $xamlGUI.Control_DHCPSubnetScopeTextBox.Text
                        $WOLData = $rsDataTransfer.WOLOutPut.Data | ConvertTo-Json -Compress
                        $WOLResults = ConvertTo-WPRHTML -Template 'FSWOL.tpl' -TemplateHeading $WOLHeading -Data $WOLData
                        Write-TabbedUI -HTMLData $WOLResults -Tab 'Results' -TabHeader ("WOL for subnet: " + $xamlGUI.Control_DHCPSubnetScopeTextBox.Text)
                    }

                    if ($rsDataTransfer.WOLOutPut.Error) {
                        Write-Exception -Message $rsDataTransfer.WOLOutPut.Error
                        #return
                    }

                    [System.Windows.Forms.Application]::DoEvents()

            }
        }
        catch {

            $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 
            
            Write-Exception -Message $ExceptionMessage
        }
        finally {
            
            $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow

            if (($xamlGUI.Control_DisplayResults.Items.Count -ne 0) -or ($rsDataTransfer.WOLOutPut.Data.Count -ne 0 )) {
                
                Write-Console -Message "`r`nWOL completed. Please check results tab for the output ..."
            }
            else {
                Write-Exception -Message "`r`nThe WOL process failed ..."
            }

            
            
        }
    })

    # Event for the Get Help button
    $xamlGUI.Control_GetHelpButton.Add_Click({

        # Check that we have selected a script
        if ($xamlGUI.Control_DisplayPSScripts.SelectedItem -eq $null) {
            
            Write-MessageBox -Message "Please select a script."
            $xamlGUI.Control_MainDisplay.SelectedIndex = 1
            $xamlGUI.Control_DisplayPSScripts.Focus()
            #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            return
        }
        
        # Get the path to the script
        $Path = "PSSCripts\" + $xamlGUI.Control_DisplayPSScripts.SelectedItem.folder +"\" + $xamlGUI.Control_DisplayPSScripts.SelectedItem.file

        if (!(Test-Path -Path $Path)) {
             Write-MessageBox -Message ("Could not find the script {0}\{1}" -f $StartupLocation,$Path)
             #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
             return
         }

         # Switch to the Console Output
         $xamlGUI.Control_MainDisplay.SelectedIndex = 0

         $ScriptHelp = Get-Help -Detailed $Path
         Write-Console -Message $ScriptHelp
    })

    # Event for the Cancel Script button
    $xamlGUI.Control_CancelScriptButton.Add_Click({

       <# if ($rsDataTransfer.ContainsKey('CancelScript')) {
                $rsDataTransfer.Remove('CancelScript')
        }#>

        $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
        $rsDataTransfer.CancelScript = $true

    })

    # Event for the Batch Script button
    $xamlGUI.Control_BatchScriptButton.Add_Click({

        # Get the batch script file
        $SelectedBatchFile = Get-BatchFile

        if ($SelectedBatchFile -eq $null) {
            return
        }
        $batchfile = $null
        $batchfile = Import-CSV $SelectedBatchFile

        #Write-Console -Message $batchfile
        Write-Console -Message ("`r`nStarted procssing of the batch file $SelectedBatchFile at {0}" -f (Get-Date))

        # Get the Run Script Button and automate click method

        # Go through the batch file and process each line
        foreach ($batch in $batchfile) {
            
            #Write-Console -Message $batch.DHCPServer

            if ($rsDataTransfer.CancelScript -eq $true) {
   
                  Write-Exception -Message "Batch Process cancelled by user request"
                  return
            }

            if ($batch.BatchType -eq $null) {
                
                Write-Exception -Message "Please provide a BatchType in the file $SelectedBatchFile"
                return
            }

            if ($batch.BatchType -eq 'FILE') {

                # Enable the Import from FILE Radio button
                $xamlGUI.Control_ImportFromFileRadioButton.IsChecked = $true
                $xamlGUI.Control_SelectFileTextBox.Text = $batch.Path
                [System.Windows.Forms.Application]::DoEvents()
            }

            if ($batch.BatchType -eq 'DHCP') {

                # Enable the Import from DHCP Radio button
                $xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked = $true
                $xamlGUI.Control_DHCPServerTextBox.Text = $batch.DHCPServer
                $xamlGUI.Control_DHCPSubnetScopeTextBox.Text = $batch.Subnet
                [System.Windows.Forms.Application]::DoEvents()
            }
            

            # Clear the current selected items and select the script to run
            $xamlGUI.Control_DisplayPSScripts.SelectedItems.Clear()
            $foundscript = $false
            foreach ($item in $xamlGUI.Control_DisplayPSScripts.Items ) {
  
                if ($item.name -contains $batch.ScriptName) {
                    $xamlGUI.Control_DisplayPSScripts.SelectedItem = $item
                    $foundscript = $true
                }

            }

            if (!$foundscript){
                 Write-MessageBox -Message ("Could not find the script '{0}' among the list of scripts at {1}\PSScripts" -f $batch.ScriptName, $StartupLocation)
                 #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
                 return
            }

            # Execute the script
            [System.Windows.Forms.Application]::DoEvents() 
            $btnclick = New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent, $xamlGUI.Control_RunScriptButton)
            $xamlGUI.Control_RunScriptButton.RaiseEvent($btnclick)
            [System.Windows.Forms.Application]::DoEvents() 
 
        }

        Write-Console -Message ("`r`nCompleted procssing of the batch file $SelectedBatchFile at {0}" -f (Get-Date))


    })


    # Event for the Run Script button
    $xamlGUI.Control_RunScriptButton.Add_Click({

        #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait
        
        # Check that we have provided computers to run the script against.
        # Check that the text boxes are not null or empty

        if ($xamlGUI.Control_ImportFromFileRadioButton.IsChecked -eq $true) {
            if ([String]::IsNullOrEmpty($xamlGUI.Control_SelectFileTextBox.Text)) {
                
                Write-MessageBox -Message "Please select a file that has the name or ip addresses of the computers."
		        $xamlGUI.Control_SelectFileTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return 
            }
        }

        if ($xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked -eq $true) {

            if (([String]::IsNullOrEmpty($xamlGUI.Control_DHCPServerTextBox.Text))) {
		
                Write-MessageBox -Message "Please enter the name or ip address of the DHCP Server."
		        $xamlGUI.Control_DHCPServerTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return 
            }

            if (([String]::IsNullOrEmpty($xamlGUI.Control_DHCPSubnetScopeTextBox.Text))) {
		
                Write-MessageBox -Message "Please enter the ip address subnet scope."
		        $xamlGUI.Control_DHCPSubnetScopeTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return 
	        }
        }

        # Check if we are using different login credentials
        # Check that the text boxes are not null or empty

        if ($xamlGUI.Control_ProvideCredentialCheckBox.IsChecked -eq $true) {
            
            if (([String]::IsNullOrEmpty($xamlGUI.Control_UserNameTextBox.Text))) {
		
                Write-MessageBox -Message "Please enter a user name in the domain\username format."
		        $xamlGUI.Control_UserNameTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return
	        }

            if (([String]::IsNullOrEmpty($xamlGUI.Control_PasswordTextBox.Password))) {
		
                Write-MessageBox -Message "Please enter a password."
		        $xamlGUI.Control_PasswordTextBox.Focus()
                #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
		        return
	       }
        }

        # Check that we have selected a script
        if ($xamlGUI.Control_DisplayPSScripts.SelectedItem -eq $null) {
            
            Write-MessageBox -Message "Please select a script to run."
            $xamlGUI.Control_MainDisplay.SelectedIndex = 1
            $xamlGUI.Control_DisplayPSScripts.Focus()
            #$xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            return
        }

        # Basic validation passed

        # If the key NameOrIPFromFile is present then delete it.
        if ($rsDataTransfer.ContainsKey('NameOrIPFromFile')) {
            $rsDataTransfer.Remove('NameOrIPFromFile')
        }

        # If the key NameOrIPFromDHCP is present then delete it.
        if ($rsDataTransfer.ContainsKey('NameOrIPFromDHCP')) {
            $rsDataTransfer.Remove('NameOrIPFromDHCP')
        }
        

        try {

            # Show a warning if we are going to run a script that could be potentially harmful.
            # This is not ideal for batch scripts
            if($xamlGUI.Control_DisplayPSScripts.SelectedItem.warn -eq $true) {
                $message = ("You are about to run the script {0}. ") -f $xamlGUI.Control_DisplayPSScripts.SelectedItem.name
                $message += ("{0} `r`n") -f $xamlGUI.Control_DisplayPSScripts.SelectedItem.Description
                $message += "Continue with the execution of this script?"

                $dlgresult = [System.Windows.MessageBox]::Show($message, "Warning", [System.Windows.MessageBoxButton]::YesNo, [System.Windows.MessageBoxImage]::Warning)

                if ($dlgresult -eq [System.Windows.MessageBoxResult]::No) {
                    return
                }
            }

            $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait

            # Switch to the Console Output
            $xamlGUI.Control_MainDisplay.SelectedIndex = 0

            #$rsDataTransfer.RunScript = $true

            # Get the computer names or ip address from the file or the textox itself
            if ($xamlGUI.Control_ImportFromFileRadioButton.IsChecked -eq $true) {
            
                if (!([String]::IsNullOrEmpty($xamlGUI.Control_SelectFileTextBox.Text))) {

                    if (Test-Path $xamlGUI.Control_SelectFileTextBox.Text) {
                        $rsDataTransfer.NameOrIPFromFile = Get-Content $xamlGUI.Control_SelectFileTextBox.Text
                    }
                    else {

                        # http://stackoverflow.com/questions/106179/regular-expression-to-match-dns-hostname-or-ip-address
                        # http://www.powershelladmin.com/wiki/PowerShell_regex_to_accurately_match_IPv4_address_%280-255_only%29

                        $IPV4Regex = '^(?:(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)\.){3}(?:0?0?\d|0?[1-9]\d|1\d\d|2[0-5][0-5]|2[0-4]\d)$'
                        $HostnameRegex = '^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$'

                        $ComputerNameOrIPInput = $xamlGUI.Control_SelectFileTextBox.Text.ToString().Trim().Split(',')
                        
                        $NameOrIPFromTextBox = @()

                        foreach ($ComputerNameOrIP in $ComputerNameOrIPInput) {

                            $ComputerNameOrIP = $ComputerNameOrIP.Trim()

                            if (($ComputerNameOrIP -match $IPV4Regex) -or ($ComputerNameOrIP -match $HostnameRegex)) {
                                $NameOrIPFromTextBox += $ComputerNameOrIP
                            }
                            else {
                                Write-MessageBox -Message "Invalid IP Address or Hostname."
                                Write-Console -Message $ComputerNameOrIPInput
                                $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
                                $xamlGUI.Control_SelectFileTextBox.SelectAll()
                                $xamlGUI.Control_SelectFileTextBox.Focus()
                                return
                            }
                        }

                        $rsDataTransfer.NameOrIPFromFile = $NameOrIPFromTextBox

                        

                        #$rsDataTransfer.NameOrIPFromFile = $xamlGUI.Control_SelectFileTextBox.Text
                    }
                    
 
                }
            }

            # Get the computer names or ip addresses from DHCP
            if ($xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked -eq $true) {

                if (!([String]::IsNullOrEmpty($xamlGUI.Control_DHCPServerTextBox.Text)) -and !([String]::IsNullOrEmpty($xamlGUI.Control_DHCPSubnetScopeTextBox.Text))) {

                    $dhcpparameters = $null
                    $dhcpparameters = @{
                        'DHCPServerNameOrIP' = $xamlGUI.Control_DHCPServerTextBox.Text;
                        'Subnet' = $xamlGUI.Control_DHCPSubnetScopeTextBox.Text;
                        'UserName' = $xamlGUI.Control_UserNameTextBox.Text;
                        'Password' =  $xamlGUI.Control_PasswordTextBox.Password
                    }

                    $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait

                    Execute-GetDHCPSubnetClients @dhcpparameters

                    if ($rsDataTransfer.NameOrIPFromDHCP.Error) {
                        Write-Exception -Message $rsDataTransfer.NameOrIPFromDHCP.Error
                    }

                }
            }


            # Excute the selected script against the list of computer names or ip addressses
            if ($rsDataTransfer.NameOrIPFromFile -or $rsDataTransfer.NameOrIPFromDHCP.Data) {
                
                # Switch to the Console Output
                #$xamlGUI.Control_MainDisplay.SelectedIndex = 0

                #Write-Console -Message $xamlGUI.Control_DisplayPSScripts.SelectedItem.name
                $Path = "PSSCripts\" + $xamlGUI.Control_DisplayPSScripts.SelectedItem.folder +"\" + $xamlGUI.Control_DisplayPSScripts.SelectedItem.file

                if (!(Test-Path -Path $Path)) {
                        Write-MessageBox -Message ("Could not find the script at {0}\{1}" -f $StartupLocation,$Path)
                        $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
                        return
                }

                #Execute-PowershellJobs -InputObject $rsDataTransfer.NameOrIPFromFile -Path $Path

                # If the key scriptparameters is present then delete it.
                # It means that we have output from a previous script
                if ($rsDataTransfer.ContainsKey('scriptparameters')) {
                    $rsDataTransfer.Remove('scriptparameters')
                }

                # Parameters entered in the format param1=value1 param2=value2 separated by a space
                # Replace \ with \\ in directory paths to deal with regex errors
                if (!([String]::IsNullOrEmpty($xamlGUI.Control_ScriptParametersTextBox.Text))) {
                    $stringtohash = $xamlGUI.Control_ScriptParametersTextBox.Text.ToString().Replace(",", "`n").Replace("\", "\\")
                    $rsDataTransfer.scriptparameters = ConvertFrom-StringData -StringData $stringtohash

                    #Write-Console -Message $rsDataTransfer.scriptparameters
                    #foreach ($key in $rsDataTransfer.scriptparameters.Keys) {
                    #    Write-Console -Message ($key + "=" + $rsDataTransfer.scriptparameters.$key)
                    #}
                    
                    #return
                }

                # If the key rsparameters is present then delete it.
                # It means that we have output from a previous script
                if ($rsDataTransfer.ContainsKey('rsparameters')) {
                    $rsDataTransfer.Remove('rsparameters')
                }

                $rsparameters = $null
                $rsparameters = @{
                        #'InputObject' = $rsDataTransfer.NameOrIPFromFile;
                        'Path' = $Path;
                        'UserName' = $xamlGUI.Control_UserNameTextBox.Text;
                        'Password' =  $xamlGUI.Control_PasswordTextBox.Password;
                        'AuthenticationType' = $xamlGUI.Control_DisplayPSScripts.SelectedItem.authtype
                }

                if ($rsDataTransfer.NameOrIPFromFile) {
                    $rsparameters.InputObject = $rsDataTransfer.NameOrIPFromFile
                }
                else {
                    $rsparameters.InputObject = $rsDataTransfer.NameOrIPFromDHCP.Data.ClientIP
                }

                # If the key RunspaceOutPut and CancelScript is present then delete it.
                # It means that we have output from a previous script
                if ($rsDataTransfer.ContainsKey('RunspaceOutPut')) {
                    $rsDataTransfer.Remove('RunspaceOutPut')
                }


                [System.Windows.Forms.Application]::DoEvents()

                $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait

                [System.Windows.Forms.Application]::DoEvents()

                Execute-PowershellJobs @rsparameters

                #Write-Console -Message $rsDataTransfer.RunspaceOutPut


                $AllOutput = @()
                
                if ($rsDataTransfer.RunspaceOutPut) {

                    #Write-Console -Message $rsDataTransfer.RunspaceOutPut
                    if ($xamlGUI.Control_ImportFromFileRadioButton.IsChecked) {

                        if (Test-Path $xamlGUI.Control_SelectFileTextBox.Text) {

                            $Resultfor = (" - {0}") -f (Split-Path $xamlGUI.Control_SelectFileTextBox.Text -Leaf)
                        }
                        <#else {
                            
                            $Resultfor = $xamlGUI.Control_SelectFileTextBox.Text
                        }#>
                    }

                    if ($xamlGUI.Control_ImportFromDHCPRadioButton.IsChecked) {
                        
                        $Resultfor = (" - {0}") -f $xamlGUI.Control_DHCPSubnetScopeTextBox.Text
                    }

                    foreach ($RunspaceOutPut in $rsDataTransfer.RunspaceOutPut) {

                        # Bail out if we have null output
                        # Some methods in scripts can output null results
                        if (($RunspaceOutPut -eq $null) -or ([System.String]::IsNullOrEmpty($RunspaceOutPut)) -or ([System.String]::IsNullOrWhiteSpace($RunspaceOutPut))) {
                            continue
                        }

                        #Write-Console -Message ($RunspaceOutPut.GetType().FullName)

                        $ResultType = $RunspaceOutPut.GetType().FullName

                        switch ($ResultType) {

                            "System.String" {Write-Console -Message $RunspaceOutPut; break}
                            "System.ComponentModel.Win32Exception" {Write-Exception -Message $RunspaceOutPut; break}
                            "System.Management.Automation.Host.HostException" {Write-Exception -Message $RunspaceOutPut; break}
                            "System.Management.ManagementException" {Write-Exception -Message $RunspaceOutPut; break}
                            "Microsoft.PowerShell.Commands.Internal.Format.FormatStartData" {Write-Exception -Message $RunspaceOutPut; break}
                            "Microsoft.PowerShell.Commands.Internal.Format.GroupStartData" {Write-Exception -Message $RunspaceOutPut; break}
                            "Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData" {Write-Exception -Message $RunspaceOutPut; break}
                            "Microsoft.PowerShell.Commands.Internal.Format.GroupEndData" {Write-Exception -Message $RunspaceOutPut; break}
                            "Microsoft.PowerShell.Commands.Internal.Format.FormatEndData" {Write-Exception -Message $RunspaceOutPut; break}
                            #"System.Management.Automation.PSCustomObject" {Write-Console -Message $RunspaceOutPut; break}
                            #"System.Data.DataSet" {Write-Console -Message $RunspaceOutPut; break}
                            #"ForeScript.Types.ServerChecklist" {Write-Console -Message $RunspaceOutPut; break}

                            default {$typemap = (Get-Content  '.\Config\fstypes.json' -Raw).ToString().Trim() | ConvertFrom-Json;
                                     $fstypes = $false
                                     foreach ($map in $typemap.Types) { 
                                        if ($map.Name -match $ResultType) {
    
                                            Import-Module -Name ".\Types\$ResultType-Type.psm1"
                                            #Write-Console -Message $RunspaceOutPut
                                            $HTMLBody = &$map.display -InputObject $RunspaceOutPut -Template $xamlGUI.Control_DisplayPSScripts.SelectedItem.template
                                            #Write-Console -Message $HTMLBody
                                            Write-TabbedUI -HTMLData $HTMLBody -Tab 'Results' -TabHeader ($xamlGUI.Control_DisplayPSScripts.SelectedItem.name + $Resultfor)
                                            Remove-Module -Name "$ResultType-Type"

                                            [System.Windows.Forms.Application]::DoEvents()
                                            $fstypes = $true
                                            break
                                            
                                        }
                                     };

                                     if (-not $fstypes) {
                                        $AllOutput += $RunspaceOutPut
                                     }
            
                                     #$AllOutput += $RunspaceOutPut;
                                     }
                        }

                    }

                    if ($rsDataTransfer.NameOrIPFromDHCP.Data) {
                        
                        $HTMLHeading = "DHCP Client lease for server: " + $xamlGUI.Control_DHCPServerTextBox.Text
                        $HTMLData = $rsDataTransfer.NameOrIPFromDHCP.Data | ConvertTo-Json -Compress
                        $HTMLClientLeases = ConvertTo-WPRHTML -Template 'FSDHCPLease.tpl' -TemplateHeading $HTMLHeading -Data $HTMLData
                        Write-TabbedUI -HTMLData $HTMLClientLeases -Tab 'Dhcp' -TabHeader ("DHCP Server: " + $xamlGUI.Control_DHCPServerTextBox.Text)

                    }

                    [System.Windows.Forms.Application]::DoEvents()

                    # This shows what was received from the runspaces
                    #Write-Console -Message $AllOutput
                    if ($AllOutput.Count -ne 0 ) {
                        
                        if (![String]::IsNullOrEmpty($xamlGUI.Control_DisplayPSScripts.SelectedItem.template)) {
                            
                            $HTMLHeading = $xamlGUI.Control_DisplayPSScripts.SelectedItem.name
                            $HTMLData = $AllOutput | ConvertTo-Json -Depth 10 -Compress

                            if($AllOutput.Count -eq 1) {
                                $HTMLData = "[" + $HTMLData + "]"
                            }
                            $HTMLBody = ConvertTo-WPRHTML -Template $xamlGUI.Control_DisplayPSScripts.SelectedItem.template -TemplateHeading $HTMLHeading -Data $HTMLData
                            Write-TabbedUI -HTMLData $HTMLBody -Tab 'Results' -TabHeader ($xamlGUI.Control_DisplayPSScripts.SelectedItem.name + $Resultfor)
                        }
                        else {
                            # No template supplied so write the output to the console
                            foreach ($Output in $AllOutput ) {

                                Write-Console -Message $Output
                            }
                            #Write-Console -Message $AllOutput
                        }
  
                        
                    }
                    

                    [System.Windows.Forms.Application]::DoEvents()

                }

            }

        }
        catch {

            $ExceptionMessage = $_ | format-list -force            #$ExceptionMessage 
            
            Write-Exception -Message $ExceptionMessage
        }
        finally {

            $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            #$rsDataTransfer.RunScript = $false

            if ($rsDataTransfer.ContainsKey('CancelScript')) {
   
                  $rsDataTransfer.CancelScript = $false
            }

            if (($xamlGUI.Control_DisplayResults.Items.Count -ne 0) -or ($AllOutput.Count -ne 0 )) {
                
                Write-Console -Message ("Execution of script " + $xamlGUI.Control_DisplayPSScripts.SelectedItem.name + " is completed. Please check results tab for the output ...")

                # Setup the call back
                if (![System.String]::IsNullOrEmpty($xamlGUI.Control_DisplayPSScripts.SelectedItem.callback)) {
                    $xamlGUI.Control_InvokeJSCallBackButton.IsEnabled = $true
                    $xamlGUI.Control_InvokeJSCallBackButton.Content = $xamlGUI.Control_DisplayPSScripts.SelectedItem.callback
                    $rsDataTransfer.rsparameters = $rsparameters
                }

            
            }
            else {
                Write-Exception -Message ("`r`nNo results returned for the script '" + $xamlGUI.Control_DisplayPSScripts.SelectedItem.name + "'")

                if ($xamlGUI.Control_InvokeJSCallBackButton.IsEnabled) {
                    $xamlGUI.Control_InvokeJSCallBackButton.IsEnabled = $false
                    $xamlGUI.Control_InvokeJSCallBackButton.Content = ''
                }
            }
        }
        

       
    })

        # Event for the Save Tab Contents Tab Menu
    $xamlGUI.Control_InvokeJSCallBackButton.Add_Click({

        # Switch to the Results Display
        $xamlGUI.Control_MainDisplay.SelectedIndex = 3
        $xamlGUI.Control_DisplayResults.Focus()

        [System.Windows.Forms.Application]::DoEvents()
        
        # The tabitem content is set to the web browser control.
        # Call the InvokeJSCallBack that returns the data for the callback
        $webbroser = $xamlGUI.Control_DisplayResults.SelectedItem
        $jsresult = $webbroser.Content.InvokeScript('InvokeJSCallBack')
        $jscallback = $jsresult | ConvertFrom-Json
        #Write-Console -Message $jscallback
        #Write-Console -Message $rsDataTransfer.rsparameters

        # If the key RunspaceOutPut is present then delete it.
        # It means that we have output from a previous script
        if ($rsDataTransfer.ContainsKey('RunspaceOutPut')) {
            $rsDataTransfer.Remove('RunspaceOutPut')
        }

        [System.Windows.Forms.Application]::DoEvents()

        $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Wait
        $rsparameters = @{}
        $rsparameters = $rsDataTransfer.rsparameters
        $rsparameters.CallBackParams = $jscallback
        $rsparameters.DoCallBack = $true

        #Write-Console -Message $rsparameters

        Execute-PowershellJobs @rsparameters

        if ($rsDataTransfer.RunspaceOutPut) {
            Write-Console -Message $rsDataTransfer.RunspaceOutPut
        }

        [System.Windows.Forms.Application]::DoEvents()

        $xamlGUI.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
    })


    # Event for the Cancel button
    $xamlGUI.Control_CancelButton.Add_Click({
        $xamlGUI.Window.Close()
    })

}


#region Execute-GetDHCPSubnetClients
function Execute-GetDHCPSubnetClients () {
    [CmdletBinding()]
    Param (
        $DHCPServerNameOrIP,
        $Subnet,
        $UserName,
        $Password
    )
    
    # The Get-DHCPClientlease script runs as a 32-bit process.
    # So we have to pass the user name and password to the script
    # and do impersonation in the 32-bit process
    $ExecuteAsyncRunspace = [Runspacefactory]::CreateRunspace() 
    $ExecuteAsyncRunspace.ApartmentState = 'STA'
    $ExecuteAsyncRunspace.ThreadOptions = 'UseCurrentThread'         
    $ExecuteAsyncRunspace.Open()
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('StartupLocation',$StartupLocation) 
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('rsDataTransfer',$rsDataTransfer)
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('parameters',$psboundparameters)

    $ExecuteAsyncPowershell = [PowerShell]::Create().AddScript({                     try {                                Set-Location $StartupLocation                [System.IO.Directory]::SetCurrentDirectory($StartupLocation)                                       $DHCPClientLeases = &"./Modules/Get-DHCPClientLeases.ps1" @parameters                                        $rsDataTransfer.NameOrIPFromDHCP = $DHCPClientLeases   -join "`r`n"  | ConvertFrom-Json             }        catch {                        $ExceptionMessage = $_ | format-list -force            $ExceptionMessage         }    })    $ExecuteAsyncPowershell.Runspace = $ExecuteAsyncRunspace
    #$FinalResult = $ExecuteAsyncPowershell.Invoke()
    $ExecuteAsyncPowershellHandle = $ExecuteAsyncPowershell.BeginInvoke()
    $FinalResult = $ExecuteAsyncPowershell.EndInvoke($ExecuteAsyncPowershellHandle)

    $ExecuteAsyncPowershell.Dispose()
    $ExecuteAsyncRunspace.Close() 

    if ($FinalResult) {
        Write-Exception -Message $FinalResult
    }
}

#endregion Execute-GetDHCPSubnetClients

#region Execute-WOLJob

function Execute-WOLJob {

[CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [PSObject[]]$InputObject,

        [Parameter(Mandatory=$false)]
        $Computer,

        [Parameter(Mandatory=$false)]
        $UserName,

        [Parameter(Mandatory=$false)]
        $Password

    )

    $ExecuteAsyncRunspace = [Runspacefactory]::CreateRunspace()  
    $ExecuteAsyncRunspace.ApartmentState = 'STA'
    $ExecuteAsyncRunspace.ThreadOptions = 'UseCurrentThread'       
    $ExecuteAsyncRunspace.Open()
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('StartupLocation',$StartupLocation) 
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('rsDataTransfer',$rsDataTransfer)
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('parameters',$psboundparameters)

    $ExecuteAsyncPowershell = [PowerShell]::Create().AddScript({                     try {                                Set-Location $StartupLocation                [System.IO.Directory]::SetCurrentDirectory($StartupLocation)                $WOLResult = &"./Modules/Invoke-RemoteWOL.ps1" @parameters                                        $rsDataTransfer.WOLOutPut = $WOLResult   -join "`r`n"  | ConvertFrom-Json                               }        catch {                         $ExceptionMessage = $_ | format-list -force             $ExceptionMessage         }    })    $ExecuteAsyncPowershell.Runspace = $ExecuteAsyncRunspace
    #$FinalResult = $ExecuteAsyncPowershell.Invoke()
    $ExecuteAsyncPowershellHandle = $ExecuteAsyncPowershell.BeginInvoke()
    $FinalResult = $ExecuteAsyncPowershell.EndInvoke($ExecuteAsyncPowershellHandle)

    $ExecuteAsyncPowershell.Dispose()
    $ExecuteAsyncRunspace.Close() 

    if ($FinalResult) {
        Write-Exception -Message $FinalResult
    }

}

#endregion Execute-WOLJob

#region Execute-PowershellJobs 

function Execute-PowershellJobs {
    
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True)]
        [ValidateNotNullOrEmpty()]
        [PSObject[]]$InputObject,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory=$false)]
        $UserName,

        [Parameter(Mandatory=$false)]
        $Password,

        [Parameter(Mandatory=$false)]
        $AuthenticationType,

        [Parameter(Mandatory=$false)]
        $CallBackParams,

        [switch]$DoCallBack
    )

    $ExecuteAsyncRunspace = [Runspacefactory]::CreateRunspace()  
    $ExecuteAsyncRunspace.ApartmentState = 'STA'
    $ExecuteAsyncRunspace.ThreadOptions = 'UseCurrentThread'       
    $ExecuteAsyncRunspace.Open()
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('StartupLocation',$StartupLocation) 
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('rsDataTransfer',$rsDataTransfer)
    $ExecuteAsyncRunspace.SessionStateProxy.SetVariable('parameters',$psboundparameters)

    #Write-Console -Message $psboundparameters

    $ExecuteAsyncPowershell = [PowerShell]::Create().AddScript({                     try {                                Set-Location $StartupLocation                [System.IO.Directory]::SetCurrentDirectory($StartupLocation)                Import-Module -Name '.\Modules\Invoke-PSRunspaces.psm1'                                $InputScriptBlock = (Get-Content $parameters.Path -ReadCount 0 -ErrorAction Stop | Out-String )                $asynrsparams = @{                    'InputScriptBlock' = $InputScriptBlock;                    'MaxRunspaces' = 20;                    'StartupLocation' = $StartupLocation;                    'CallBackParams' = $parameters.CallBackParams                }                if ($parameters.UserName -and $parameters.Password -and $parameters.AuthenticationType) {                    $asynrsparams.UserName = $parameters.UserName                    $asynrsparams.Password = $parameters.Password                    $asynrsparams.AuthenticationType = $parameters.AuthenticationType                }                if ($parameters.DoCallBack) {                    $asynrsparams.Add('DoCallBack', $true)                }                                $parameters.InputObject | Execute-AsyncRunspaces @asynrsparams                               }        catch {

            $ExceptionMessage = $_ | format-list -force            $ExceptionMessage 
        }    })    $ExecuteAsyncPowershell.Runspace = $ExecuteAsyncRunspace
    #$FinalResult = $ExecuteAsyncPowershell.Invoke()
    $ExecuteAsyncPowershellHandle = $ExecuteAsyncPowershell.BeginInvoke()
    $FinalResult = $ExecuteAsyncPowershell.EndInvoke($ExecuteAsyncPowershellHandle)

    $ExecuteAsyncPowershell.Dispose()
    $ExecuteAsyncRunspace.Close() 

    if ($FinalResult) {
        Write-Exception -Message $FinalResult
    }


}

#endregion Execute-PowershellJobs 

#region support functions

function File-Import {    $FileImportDlg = New-Object Microsoft.Win32.OpenFileDialog        #Set filter for file extension and default file extension    $FileImportDlg.Title = "Import Computers"    #$FileImportDlg.InitialDirectory = "c:\"    $FileImportDlg.DefaultExt = ".txt"    $FileImportDlg.Filter = "Text documents (.txt)|*.txt"    $FileImportDlg.ReadOnlyChecked = $true    $FileImportDlg.ShowReadOnly = $true    # Display the openfile dialog and get the selected file    $Dlgresult = $FileImportDlg.ShowDialog()    if ($Dlgresult -eq $true) {        $SelectedFile = $FileImportDlg.FileName    }    return $SelectedFile}

function File-Save {    Param (        $TempFileName    )    $FileSaveDlg = New-Object Microsoft.Win32.SaveFileDialog        #Set filter for file extension and default file extension    $FileSaveDlg.Title = "Save Report As ..."    #$FileImportDlg.InitialDirectory = "c:\"    $FileSaveDlg.FileName = ($TempFileName.Replace(".txt", "") + "-" + (Get-Date -Format s).Replace(":", ""))    $FileSaveDlg.DefaultExt = ".html"    $FileSaveDlg.Filter = "Html documents (.html)|*.html"    # Display the openfile dialog and get the selected file    $Dlgresult = $FileSaveDlg.ShowDialog()    if ($Dlgresult -eq $true) {        $SaveFileWithThisName = $FileSaveDlg.FileName    }    return $SaveFileWithThisName}

function Get-BatchFile {    $FileImportDlg = New-Object Microsoft.Win32.OpenFileDialog        #Set filter for file extension and default file extension    $FileImportDlg.Title = "Import Batch File"    #$FileImportDlg.InitialDirectory = "c:\"    $FileImportDlg.DefaultExt = ".csv"    $FileImportDlg.Filter = "foreScript Batch File (.csv)|*.csv"    $FileImportDlg.ReadOnlyChecked = $true    $FileImportDlg.ShowReadOnly = $true    # Display the openfile dialog and get the selected file    $Dlgresult = $FileImportDlg.ShowDialog()    if ($Dlgresult -eq $true) {        $SelectedFile = $FileImportDlg.FileName    }    return $SelectedFile}

#endregion support functions

# Set functions to read only
Set-Item -Path function:Initialize-UIEvents -Options ReadOnly


# Export the functions that will be accessed outside the module
Export-ModuleMember -Function Initialize-UIEvents