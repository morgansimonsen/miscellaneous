
Function Disable-GoogleChromeSwReporter
{
    <#
    .SYNOPSIS
    Disable Google Chrome Software Reporter by removing all file permissions

    .DESCRIPTION

    .PARAMETER SwReporterPath
    Root path where SwReporter version subdirectories are stored

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> 

    .LINK
    https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/
    https://www.itechtics.com/disable-software-reporter-tool/
    #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$false)]
        [String]$SwReporterPath = "$Env:LOCALAPPDATA\google\chrome\User Data\SwReporter\"
    )

    # Find all exe files under swreporter path
    $SwReporterExes = Get-ChildItem -Path $SwReporterPath -Filter "*.exe" -Recurse

    ForEach ( $SwReporterExe in $SwReporterExes)
    {
        Write-Information -MessageData "Processing exe file: $SwReporterExe.FullName" -InformationAction Continue
        $SwReporterACL = Get-Acl -Path $SwReporterExe.FullName
        # Disable inheritance and delete all inherited permissions
        $SwReporterACL.SetAccessRuleProtection($true,$false)
        $SwReporterACL | Set-Acl -Path $SwReporterExe.FullName
    }
}


Function Enable-GoogleChromeSwReporter
{
    <#
    .SYNOPSIS
    Enable Google Chrome Software Reporter by removing all file permissions

    .DESCRIPTION

    .PARAMETER SwReporterPath
    Root path where SwReporter version subdirectories are stored

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> 

    .LINK
    https://blog.netwrix.com/2018/04/18/how-to-manage-file-system-acls-with-powershell-scripts/
    https://www.itechtics.com/disable-software-reporter-tool/
    #>

    [CmdletBinding()]
    Param (
        [Parameter(
            Mandatory=$false)]
        [String]$SwReporterPath = "$Env:LOCALAPPDATA\google\chrome\User Data\SwReporter\"
    )

    # Find all exe files under swreporter path
    $SwReporterExes = Get-ChildItem -Path $SwReporterPath -Filter "*.exe" -Recurse

    ForEach ( $SwReporterExe in $SwReporterExes)
    {
        Write-Information -MessageData "Processing exe file: $SwReporterExe.FullName" -InformationAction Continue
        $SwReporterACL = Get-Acl -Path $SwReporterExe.FullName
        # Enable inheritance and copy all inherited permissions
        $SwReporterACL.SetAccessRuleProtection($false,$true)
        $SwReporterACL | Set-Acl -Path $SwReporterExe.FullName
    }
}

Function Remove-GoogleChrome
{
    <#
    .SYNOPSIS
    Remove Google Chrome

    .DESCRIPTION
    Removes Google Chrome by:
    - Deleting C:\Program Files\Google\Chrome
    - Deleting \AppData\Local\Google from user profile
    - Taking ownership of and deleting HKEY_LOCAL_MACHINE\SOFTWARE\Google
    - Deleting HKEY_CURRENT_USER\SOFTWARE\Google

    .INPUTS
    None.

    .OUTPUTS
    None.

    .EXAMPLE
    PS> 

    .LINK
    #>

    [CmdletBinding()]
    Param()

    Remove-Item "C:\Program Files\Google\Chrome" -recurse -force
    Remove-Item $env:USERPROFILE\AppData\Local\Google -recurse -force

    $regpath = "HKLM:\SOFTWARE\Google\"
    $ACL = Get-ACL -Path $regpath
    $Group = New-Object System.Security.Principal.NTAccount("Builtin", "Administrators")
    $ACL.SetOwner($Group)
    $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($group.Value,"FullControl","Allow")
    $acl.SetAccessRule($AccessRule)
    Set-Acl -Path $regpath -AclObject $ACL

    #& 'C:\Users\morga\OneDrive\PortableApps\SetACL\64 bit\SetACL.exe' -on "HKEY_LOCAL_MACHINE\SOFTWARE\Google" -ot reg -actn setowner -ownr "n:Administrators" -rec cont_obj
    #& 'C:\Users\morga\OneDrive\PortableApps\SetACL\64 bit\SetACL.exe' -on "HKEY_LOCAL_MACHINE\SOFTWARE\Google" -ot reg -actn ace -ace "n:Administrators;p:full" -rec cont_obj

    Remove-Item "HKCU:\Software\Google\" -Recurse -Force
    Remove-Item "HKLM:\Software\Google\" -Recurse -Force

}

Export-ModuleMember -Function * -Cmdlet * -Variable * -Alias *
