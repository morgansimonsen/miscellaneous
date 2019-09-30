Function Stop-OpenVPN
{
    stop-process -Name openvpn -ErrorAction SilentlyContinue
    stop-process -Name openvpn-gui -ErrorAction SilentlyContinue
}
Function Set-OpenVPNGuiSettings
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [bool]$SilentConnection=$false
    )

    If ($SilentConnection -eq $true)
    {
        Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--command silent_connection 1"
    }
    elseif ($SilentConnection -eq $false) {
        Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--command silent_connection 0"
    }
}

Function Connect-OpenVPN
{
    <#
    .SYNOPSIS
    Connect with OpenVPN client
    
    .DESCRIPTION
    Long description
    
    .EXAMPLE
    An example
    
    .NOTES
    openvpn.exe requires the config file parameter to be FIRST
    then the other parameters that override what is in the config file

    #>
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The ConfigFile argument must be a file. Folder paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$ConfigFile="$env:USERPROFILE\OpenVPN\config\TigerVPN\NO - Oslo @tigervpn.com.ovpn",

    [Parameter(Mandatory=$false)]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The CAFile argument must be a file. Folder paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$CAFile="$env:USERPROFILE\OpenVPN\config\TigerVPN\ca.crt"
    )

    $credentials_file = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials.txt"
    If (!(Test-Path $credentials_file))
    {
        Write-Warning "Credentials file not found; run Add-OpenVPNCredentials first"
        Break
    }
    $creddata = Import-Csv -Path $credentials_file -Delimiter ";" -Header "username","encryptedpassword"
    $username_cleartext = $creddata.username
    $password_cleartext = (New-Object PSCredential $creddata.username,( ConvertTo-SecureString $creddata.encryptedpassword)).GetNetworkCredential().Password
    [System.IO.FileInfo]$credentials_file_cleartext = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials2.txt"
    Out-File -FilePath $credentials_file_cleartext -Encoding ascii -Force
    Add-Content $credentials_file_cleartext -Value $username_cleartext -Encoding Ascii
    Add-Content $credentials_file_cleartext -Value $password_cleartext -Encoding Ascii
    $myarg = @(
        "--config ""$ConfigFile"""
        "--ca ""$CAFile"""
        "--capath ""$($CAFile.DirectoryName)"""
        "--auth-user-pass ""$($credentials_file_cleartext.FullName)"""
    )
    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn.exe" -ArgumentList $myarg -WindowStyle Minimized
    Start-Sleep -Seconds 5
    credentials_file_cleartext -Force
}

Function Connect-OpenVPNGui
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [String]$ConfigName="NO - Oslo @tigervpn.com.ovpn",

    [Parameter(Mandatory=$false)]
    [switch]$SilentConnection
    )
    $myarg = @(
        "--command connect ""$ConfigName"""
    )

    If ($SilentConnection)
    {
        Set-OpenVPNGuiSettings -SilentConnection $true
    }

    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList $myarg
}

Function Disconnect-OpenVPNGui
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [String]$ConfigName="NO - Oslo @tigervpn.com.ovpn"
    )

    $myarg = @(
        "--command disconnect ""$ConfigName"""
    )

    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList $myarg
}

Function Reconnect-OpenVPNGui
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [String]$ConfigName="NO - Oslo @tigervpn.com.ovpn"
    )
    $myarg = @(
        "--command reconnect ""$ConfigName"""
    )
    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList $myarg
}

Function Disconnect-OpenVPNGuiAll
{
    $myarg = @(
        "--command disconnect_all"
    )
    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList $myarg
}

Function Get-OpenVPNGuiStatus
{
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [String]$ConfigName="NO - Oslo @tigervpn.com.ovpn"
    )
    $myarg = @(
        "--command status ""$ConfigName"""
    )
    Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList $myarg
}

Function Add-OpenVPNCredentials
{
    $username = Read-Host "Enter VPN username"
    $password = Read-Host "Enter VPN password" -AsSecureString
    $credentials_file = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials.txt"
    ($username+";"+(ConvertFrom-SecureString ($password))) | Out-File -FilePath $credentials_file -Force
}