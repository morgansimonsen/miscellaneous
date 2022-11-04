<#
.SYNOPSIS
    Update IIS FTP Server with public IP address
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    - https://jfrmilner.wordpress.com/2012/12/22/powershell-quick-tip-03-whats-my-external-ip-address-windows-command-line/
    - http://stackoverflow.com/questions/23522557/set-permissions-and-settings-on-iis-ftp-site-using-powershell
    - http://unix.stackexchange.com/questions/22615/how-can-i-get-my-external-ip-address-in-a-shell-script
.EXAMPLE
    Test-MyTestFunction -Verbose
    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
#>
#Requires -Version 5.0
[CmdletBinding()]
param ()

# Configure as scheduled task:
# $ftptask_settings = New-ScheduledTaskSettingsSet -Compatibility Win8
# $ftptask_action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-file c:\Scripts\UpdateFTPServerPublicIPAddress.ps1"
# $ftptask_trigger =  New-ScheduledTaskTrigger -Daily -At "05:00"
# $ftptask_principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
# Register-ScheduledTask -TaskName "FTP Site public IP" -Principal $ftptask_principal  -Action $ftptask_action -Trigger $ftptask_trigger -Description "Update FTP Site with current public IP" -Settings $ftptask_settings

$LogFilePath = Join-Path -Path "C:\Scripts" -ChildPath "UpdateFTPServerPublicIPAddress-$($env:COMPUTERNAME).log"

function Write-Log
{
    param (
        [Parameter(Mandatory)]
        [string]$Message,
        
        [Parameter()]
        [ValidateSet('1','2','3')]
        [int]$Severity = 1 ## Default to a low severity. Otherwise, override
    )
    
    $line = [pscustomobject]@{
        'DateTime' = (Get-Date)
        'Message' = $Message
        'Severity' = $Severity
    }
    
    ## Ensure that $LogFilePath is set to a global variable at the top of script
    $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation
}

$FTPSiteName = "Default FTP Site"
$FullyQualifiedFTPSiteName = "IIS:\Sites\"+$FTPSiteName

Import-Module WebAdministration

# Get our public IP
Write-Log -Message "Getting public IP"
try {
    [ipaddress]$publicIP = (Invoke-WebRequest "http://whatismyip.akamai.com/" -UseBasicParsing).Content.replace("`n","")
}
catch {
    Write-Log -Message "Unable to get public IP"
    Write-Log -Message $_.Exception
}

if ($publicIP) {
    Write-Log -Message "New public IP: $($publicIP.IPAddressToString)"
    if ($publicIP.IPAddressToString -ne (get-Itemproperty $FullyQualifiedFTPSiteName -Name ftpServer.firewallSupport.externalIp4Address).Value) {
        Write-Log -Message "New public IP different from existing public IP; setting new public IP in IIS config"
        Set-Itemproperty $FullyQualifiedFTPSiteName -Name ftpServer.firewallSupport.externalIp4Address -Value $publicIP.IPAddressToString
    
        Write-Log -Message "Restarting site"
        Restart-WebItem $FullyQualifiedFTPSiteName
    } else {
        Write-Log -Message "Public IP is already updated"
    }
}
