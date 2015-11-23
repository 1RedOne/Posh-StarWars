<#
This will return the rectangle position of a process window. 

Values of the Rectangle in relation to pixel location on window:

Left;        // x position of upper-left corner
Top;         // y position of upper-left corner
Right;       // x position of lower-right corner
Bottom;      // y position of lower-right corner

#>

Function Get-WindowPosition {
    [cmdletbinding()]
    Param ($ProcessID
        #[parameter(ValueFromPipelineByPropertyName=$True)]
        #$ProcessName
    )

       DynamicParam {
            # Set the dynamic parameters' name
            $ParameterName = 'ProcessName'
            
            # Create the dictionary 
            $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

            # Create the collection of attributes
            $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            
            # Create and set the parameters' attributes
            $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
            $ParameterAttribute.Position = 1

            # Add the attributes to the attributes collection
            $AttributeCollection.Add($ParameterAttribute)

            # Generate and set the ValidateSet 
            $arrSet = Get-process | Select-Object -ExpandProperty Name
            $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

            # Add the ValidateSet to the attributes collection
            $AttributeCollection.Add($ValidateSetAttribute)

            # Create and return the dynamic parameter
            $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
            $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
            return $RuntimeParameterDictionary
    }

    Begin {

        $ProcessName = $PsBoundParameters[$ParameterName]
        Add-Type @"
          using System;
          using System.Runtime.InteropServices;
          public class Window {
            [DllImport("user32.dll")]
            [return: MarshalAs(UnmanagedType.Bool)]
            public static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);
          }
          public struct RECT
          {
            public int Left;        // x position of upper-left corner
            public int Top;         // y position of upper-left corner
            public int Right;       // x position of lower-right corner
            public int Bottom;      // y position of lower-right corner
          }
"@
    }
    Process {
        $rcWindow = New-Object RECT
        $h = if($ProcessID){(Get-Process -id $ProcessID).MainWindowHandle}else{(Get-Process -Name $ProcessName).MainWindowHandle}
        $Return = [Window]::GetWindowRect($h,[ref]$rcWindow)
        If ($Return) {
            $Height = $rcWindow.Bottom - $rcWindow.Top
            $Width = $rcWindow.Right - $rcWindow.Left
            $Size = New-Object System.Management.Automation.Host.Size -ArgumentList $Width, $Height
            $TopLeft = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $rcWindow.Left, $rcWindow.Top
            $BottomRight = New-Object System.Management.Automation.Host.Coordinates -ArgumentList $rcWindow.Right, $rcWindow.Bottom
            [pscustomobject]@{
                Size = $Size
                TopLeft = $TopLeft
                BottomRight = $BottomRight
            }
        }
    }
}
