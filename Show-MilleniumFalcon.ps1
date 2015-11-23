<#
    .SYSNOPSIS
        Displays a clock on the screen with date.

    .DESCRIPTION
        Displays a clock on the screen with date.

    .PARAMETER TimeColor
        Specify the color of the time display.

    .PARAMETER DateColor
        Specify the color of the date display.

        Default is White

    .NOTES
        Author: Boe Prox
        Created: 27 March 2014
        Version History:
            Version 1.0 -- 27 March 2014
                -Initial build

    .EXAMPLE
        .\ClockWidget.ps1

        Description
        -----------
        Clock is displayed on screen

    .EXAMPLE
        .\ClockWidget.ps1 -TimeColor DarkRed -DateColor Gold

        Description
        -----------
        Clock is displayed on screen with alternate colors

    .EXAMPLE
        .\ClockWidget.ps1 –TimeColor "#669999" –DateColor "#334C4C"

        Description
        -----------
        Clock is displayed on screen with alternate colors as hex values
            
#>
Param (
    [parameter()]
    [string]$TimeColor = "White",
    [parameter()]
    [string]$DateColor = "White"
)
$Clockhash = [hashtable]::Synchronized(@{})
$Runspacehash = [hashtable]::Synchronized(@{})
$Runspacehash.host = $Host
$Clockhash.TimeColor = $TimeColor
$Clockhash.DateColor = $DateColor
$Runspacehash.runspace = [RunspaceFactory]::CreateRunspace()
$Runspacehash.runspace.ApartmentState = “STA”
$Runspacehash.runspace.ThreadOptions = “ReuseThread”
$Runspacehash.runspace.Open() 
$Runspacehash.psCmd = {Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase}.GetPowerShell() 
$Runspacehash.runspace.SessionStateProxy.SetVariable("Clockhash",$Clockhash)
$Runspacehash.runspace.SessionStateProxy.SetVariable("Runspacehash",$Runspacehash)
$Runspacehash.runspace.SessionStateProxy.SetVariable("TimeColor",$TimeColor)
$Runspacehash.runspace.SessionStateProxy.SetVariable("DateColor",$DateColor)
$Runspacehash.psCmd.Runspace = $Runspacehash.runspace 
$Runspacehash.Handle = $Runspacehash.psCmd.AddScript({ 

$window = Get-WindowPosition -ProcessID $PID
$left = $window.BottomRight.X - 231
$top = $window.BottomRight.Y - 126

$position= @"
 Left="$left" Top="90"
"@

$imgFolder = "$(get-module Posh-StarWars | select Path | Split-Path)\img"

$inputXML = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        WindowStyle = "None"  SizeToContent = "WidthAndHeight" ShowInTaskbar = "False"
        ResizeMode = "NoResize" Title = "Weather" AllowsTransparency = "True" Background = "Transparent" Opacity = "1" Topmost = "True" $position>
    <Grid x:Name = "Grid" Background = "Transparent" Height="126" Width="231">

        <Image x:Name="image" HorizontalAlignment="Left" Height="126" Margin="0,-10,0,0" VerticalAlignment="Top" Width="221" Source="C:\git\Posh-StarWars\img\Millennium-Falcon.jpeg"/>
		<Label x:Name="label" Content="Millenium Falcon" HorizontalAlignment="Left" Height="36" Margin="24,80,0,0" VerticalAlignment="Top" Width="181" Foreground="#FFE1DB00" FontSize="24"/>
    </Grid>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $xaml) 
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch [System.Management.Automation.MethodInvocationException] {
    Write-Warning "We ran into a problem with the XAML code.  Check the syntax for this control..."
    write-host $error[0].Exception.Message -ForegroundColor Red
    if ($error[0].Exception.Message -like "*button*"){
        write-warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"}
}
catch{#if it broke some other way <span title=":D" class="wp-smiley wp-emoji wp-emoji-bigsmile">:D</span>
    Write-Host "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."
        }
 
#===========================================================================
# Store Form Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-host "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}
 
Get-FormVariables
 
#===========================================================================
    # Use this space to add code to the various form elements in your GUI
    #===========================================================================
                                                                    
     
    #Reference 
 
    #Adding items to a dropdown/combo box
      #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
     
    #Setting the text of a text box to the current PC name    
      #$WPFtextBox.Text = $env:COMPUTERNAME
     
    #Adding code to a button, so that when clicked, it pings a system
    # $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
    # })
    #===========================================================================
    # Shows the form
    #===========================================================================
 $form.Add_MouseRightButtonUp({
    $form.close()
})
$form.Add_MouseLeftButtonDown({
    $form.DragMove()
})

$Form.Left = $([System.Windows.SystemParameters]::WorkArea.Width-$form.Width)
$Form.Top = $([System.Windows.SystemParameters]::WorkArea.Height-$form.Height)

$Form.ShowDialog() | out-null
}).BeginInvoke()