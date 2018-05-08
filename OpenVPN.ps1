# openvpn.exe requires the config file parameter to be FIRST
# then the other parameters that override what is in the config file


Function Stop-OpenVpn
{
    stop-process -Name openvpn -ErrorAction SilentlyContinue
    stop-process -Name openvpn-gui -ErrorAction SilentlyContinue
}

Function Connect-OpenVpn
{
    $credentials_file = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials.txt"
    If (!(Test-Path $credentials_file))
    {
        Write-Warning "Credentials file not found; run Add-OpenVpnCredentials first"
        Break
    }
    $creddata = Import-Csv -Path $credentials_file -Delimiter ";" -Header "username","encryptedpassword"
    $username_cleartext = $creddata.username
    $password_cleartext = (New-Object PSCredential $creddata.username,( ConvertTo-SecureString $creddata.encryptedpassword)).GetNetworkCredential().Password
    $credentials_file_cleartext = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials2.txt"
    Out-File -FilePath $credentials_file_cleartext -Encoding ascii -Force
    Add-Content $credentials_file_cleartext -Value $username_cleartext -Encoding Ascii
    Add-Content $credentials_file_cleartext -Value $password_cleartext -Encoding Ascii
    $myarg = "--config ""C:\Program Files\OpenVPN\config\NO - Oslo @tigervpn.com.ovpn"" --ca ""C:\Program Files\OpenVPN\config\ca.crt"" --capath ""C:\Program Files\OpenVPN\config"" --auth-user-pass ""C:\Users\MorganSimonsen\openvpncredentials2.txt"""
    Start-Process 'c:\Program Files\OpenVPN\bin\openvpn.exe' -ArgumentList $myarg -WindowStyle Minimized
    Start-Sleep -Seconds 5
    Remove-Item -Path $credentials_file_cleartext -Force
}

Function Add-OpenVpnCredentials
{
    $username = Read-Host "Enter VPN username"
    $password = Read-Host "Enter VPN password" -AsSecureString
    $credentials_file = Join-Path -Path $env:USERPROFILE -ChildPath "openvpncredentials.txt"
    ($username+";"+(ConvertFrom-SecureString ($password))) | Out-File -FilePath $credentials_file -Force
}