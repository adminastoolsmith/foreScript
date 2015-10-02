# -----------------------------------------------------------------------------------------
# Script: foreScriptCore.psm1
# Author: Nigel Thomas
# Date: April 24, 2015
# Version: 1.0
# Purpose: This module contains the functions that are used to update the  foreScript UI
#
# Project: foreScript
#
# -----------------------------------------------------------------------------------------
#
# (C) Nigel Thomas, 2015
#
#------------------------------------------------------------------------------------------


#region functions


function ConvertTo-WPRHTML {
    Param (
        $Template,
        $TemplateHeading,
        $Data
    )

    $TEMPL_JQUERY_VERSION = (Get-Content ".\Templates\scripts\jquery-1.9.1.min.js" -ReadCount 0 | Out-String )
    $TEMPL_JQUERYDATATABLE_VERSION = (Get-Content ".\Templates\scripts\json.htmTable.js" -ReadCount 0 | Out-String )
    $outputtemplate = (Get-Content ".\Templates\html\$Template" -ReadCount 0 | Out-String )
   
    $tplparameter = @{ "TEMPL_JQUERY_VERSION" = "$TEMPL_JQUERY_VERSION";
                          "TEMPL_JQUERYDATATABLE_VERSION" = "$TEMPL_JQUERYDATATABLE_VERSION";
                          "TEMPL_HEADING" = "$TemplateHeading";
                          "TEMPL_DATA" = "$Data"

    }

    foreach ($key in $tplparameter.Keys) {
             $outputtemplate = $outputtemplate.Replace($key, $tplparameter[$key])
    }

    $outputtemplate
}

function ConvertTo-FSHTML {
    Param (
        $Template,
        $TemplateHeading,
        $Data
    )

    $TEMPL_JQUERY_VERSION = (Get-Content ".\Templates\scripts\jquery-1.9.1.min.js" -ReadCount 0 | Out-String )
    $TEMPL_JQUERYDATATABLE_VERSION = (Get-Content ".\Templates\scripts\json.htmTable.js" -ReadCount 0 | Out-String )
    $outputtemplate = (Get-Content ".\Templates\html\$Template" -ReadCount 0 | Out-String )
   
    $tplparameter = @{ "TEMPL_JQUERY_VERSION" = "$TEMPL_JQUERY_VERSION";
                          "TEMPL_JQUERYDATATABLE_VERSION" = "$TEMPL_JQUERYDATATABLE_VERSION";
                          "TEMPL_HEADING" = "$TemplateHeading";
                          "TEMPL_DATA" = "$Data"

    }

    foreach ($key in $tplparameter.Keys) {
             $outputtemplate = $outputtemplate.Replace($key, $tplparameter[$key])
    }

    $outputtemplate
}



function Write-Console {
    Param (
        $Message
    )

    $xamlGUI.Control_ConsoleOutputRichTextBox.Dispatcher.Invoke(        "Normal",        [action]({
    
    try {

        $Text = $Message  | Out-String -Width 10240
    
        $msgcolor = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::GhostWhite)
        $tr = New-Object System.Windows.Documents.TextRange($xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd, $xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd);
        $tr.Text = $Text #+ "`r`n"
        $tr.ApplyPropertyValue([System.Windows.Documents.TextElement]::ForegroundProperty, $msgcolor)
        $xamlGUI.Control_ConsoleOutputRichTextBox.ScrollToEnd()
    
        
    }
    catch {
        if ($_.Exception.InnerException) {
            $ExceptionMessage = $_.Exception.InnerException
        }
        else {
            $ExceptionMessage = $_.Exception.Message
        }

        $msgcolor = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Red)
        $tr = New-Object System.Windows.Documents.TextRange($xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd, $xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd);
        $tr.Text = $ExceptionMessage #+ "`r`n"
        $tr.ApplyPropertyValue([System.Windows.Documents.TextElement]::ForegroundProperty, $msgcolor)
        $xamlGUI.Control_ConsoleOutputRichTextBox.ScrollToEnd()
        
    }
    }))
}

function Write-TabbedUI {    Param (        $HTMLData,        $Tab,        $TabHeader    )    try {        if ([String]::IsNullOrEmpty($HTMLData )) {            return        }                # Input - The enumeration value is 5. Operations are processed at the same priority as input.        # Normal - The enumeration value is 9. Operations are processed at normal priority. This is the typical application priority.            $xamlGUI.Control_DisplayResults.Dispatcher.Invoke(        "Normal",        [action]({                try {                                        # Create Web Browser control                    $webbrowser = New-Object Windows.Controls.WebBrowser                    $webbrowser.NavigateToString($HTMLData)                        # Create Tabitem                    $tabitem = New-Object Windows.Controls.TabItem                    $tabitem.Header =  $TabHeader                    $tabitem.Content = $webbrowser                    if ($Tab -eq 'Dhcp') {                                                # Check if we have displayed this tabitem before by reading the tabitem header                        foreach ($item in $xamlGUI.Control_DisplayDHCPLeases.Items) {                            if ($item.Header -contains $tabitem.Header) {                                return                            }                        }                        $tabitem.ContextMenu = $xamlGUI.Window.FindResource('DHCPContextMenu')                        #$tabitem.Style = $xamlGUI.Window.FindResource('MetroTabItem')                                            $xamlGUI.Control_DisplayDHCPLeases.Items.Add($tabitem)                        #$xamlGUI.Control_MainDisplay.SelectedIndex = 2                        #$xamlGUI.Control_DisplayDHCPLeases.SelectedIndex = ($xamlGUI.Control_DisplayDHCPLeases.Items.Count - 1)                                            }                    if ($Tab -eq 'Results') {                        $tabitem.ContextMenu = $xamlGUI.Window.FindResource('TabitemContextMenu')                        #$tabitem.Style = $xamlGUI.Window.FindResource('MetroTabItem')                                            $xamlGUI.Control_DisplayResults.Items.Add($tabitem)                        #$xamlGUI.Control_MainDisplay.SelectedIndex = 3                        #$xamlGUI.Control_DisplayResults.SelectedIndex = ($xamlGUI.Control_DisplayResults.Items.Count - 1)                    }                                     }                catch  {                   if ($_.Exception.InnerException) {                        $ExceptionMessage = $_.Exception.InnerException                    }                    else {                       $ExceptionMessage = $_.Exception.Message                    }                            $xamlGUI.Control_ConsoleOutputRichTextBox.AppendText($ExceptionMessage)                }                             }))    }    catch  {       if ($_.Exception.InnerException) {            $ExceptionMessage = $_.Exception.InnerException        }        else {           $ExceptionMessage = $_.Exception.Message        }                $xamlGUI.Control_ConsoleOutputRichTextBox.AppendText($ExceptionMessage)    }}

function Write-MessageBox {
    Param (
        [String]$Message
    )

    [System.Windows.MessageBox]::Show($Message)
}

function Write-Exception {
    Param (
        $Message
    )
    $xamlGUI.Control_ConsoleOutputRichTextBox.Dispatcher.Invoke(        "Normal",        [action]({
    
    try {

        $Text = $Message  | Out-String -Width 10240
    
        $msgcolor = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Coral)
        $tr = New-Object System.Windows.Documents.TextRange($xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd, $xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd);
        $tr.Text = $Text #+ "`r`n"
        $tr.ApplyPropertyValue([System.Windows.Documents.TextElement]::ForegroundProperty, $msgcolor)
        $xamlGUI.Control_ConsoleOutputRichTextBox.ScrollToEnd()
    
        
    }
    catch {
        if ($_.Exception.InnerException) {
            $ExceptionMessage = $_.Exception.InnerException
        }
        else {
            $ExceptionMessage = $_.Exception.Message
        }

        $msgcolor = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Colors]::Red)
        $tr = New-Object System.Windows.Documents.TextRange($xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd, $xamlGUI.Control_ConsoleOutputRichTextBox.Document.ContentEnd);
        $tr.Text = $ExceptionMessage #+ "`r`n"
        $tr.ApplyPropertyValue([System.Windows.Documents.TextElement]::ForegroundProperty, $msgcolor)
        $xamlGUI.Control_ConsoleOutputRichTextBox.ScrollToEnd()

        
    }
    }))
}


#endregion functions


# Set functions to read only
Set-Item -Path function:ConvertTo-WPRHTML -Options ReadOnly
Set-Item -Path function:ConvertTo-FSHTML -Options ReadOnly
Set-Item -Path function:Write-Console -Options ReadOnly
Set-Item -Path function:Write-TabbedUI -Options ReadOnly
Set-Item -Path function:Write-MessageBox -Options ReadOnly
Set-Item -Path function:Write-Exception -Options ReadOnly


# Export the functions that will be accessed outside the module
Export-ModuleMember -Function ConvertTo-WPRHTML, ConvertTo-FSHTML, Write-Console, Write-TabbedUI, Write-MessageBox, Write-Exception