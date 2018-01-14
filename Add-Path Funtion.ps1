Function Global:Add-Path {
    <#.SYNOPSIS
    PowerShell function to modify Env:Path in the registry
    .DESCRIPTION
    Includes a parameter to append the Env:Path
    .EXAMPLE 
    Add-Path -NewPath "D:\Downloads"
    #> 
    Param (
    [String]$NewPath ="D:\Powershell"
             )
    Begin {
    Clear-Host
            } # End of small begin section
    Process {
        Clear-Host
        $Reg = "Registry::HKLM\System\CurrentControlSet\Control\Session Manager\Environment"
        $OldPath = (Get-ItemProperty -Path "$Reg" -Name PATH).Path
        $NewPath = $OldPath + ';' + $NewPath
        Set-ItemProperty -Path $Reg -Name PATH -Value $NewPath -Confirm
        } #End of Process
}
# This is what you type to call the function.
Add-Path