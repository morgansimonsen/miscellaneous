<#
Check if any disks have lost communication and then send email
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false,Position=0)]
    [string]$AlertRecipientSMTPAddress="morgan@simonsen.bz"
)

$suspectDisks = Get-PhysicalDisk | Where-Object { ($_.OperationalStatus -ne "OK") -or ( $_.HealthStatus -ne "Healthy") }

If ( $suspectDisks -ne $null)
{
$EmailBody = @"
<html>
    <head>
        <title>Abnormal disk situation $env:COMPUTERNAME</title>
    </head>
    <body>
    One or more disks with suspect status:<br>
    <hr>
    $(
        ForEach ( $disk in $suspectDisks)
        {
            "Disk: $($disk.FriendlyName)<br>"
            "Serial Number: $($disk.SerialNumber)<br>"
            "Health Status: $($disk.HealthStatus)<br>"
            "Operational Status: $($disk.OperationalStatus)<br>"
            "<hr>"
        }
    )
    </body>
</html>
"@

    $EmailFrom = "$env:COMPUTERNAME <noreply@simonsen.bz>"
    #$EmailSubject = ("Disk "+$EventLevel[$EventCategory]+" on $computerName")
    $EmailSubject = "Abnormal disk situation $env:COMPUTERNAME"
    $SMTPServer = "smtp.gmail.com"
    $SMTPServerPort = "587"
    $SMTPServerUsername = "morgan.simonsen@gmail.com"
    $SMTPServerPassword = "that was really stupid"
    $SMTPServerSecurePassword = ConvertTo-SecureString $SMTPServerPassword -AsPlainText -Force
    $SMTPServerCredential = New-Object System.Management.Automation.PSCredential ($SMTPServerUsername, $SMTPServerSecurePassword)
    
    Send-MailMessage -From $EmailFrom `
                        -To $AlertRecipientSMTPAddress `
                        -Subject $EmailSubject `
                        -BodyAsHtml `
                        -body $EmailBody `
                        -SmtpServer $SMTPServer `
                        -Port $SMTPServerPort `
                        -UseSsl `
                        -Credential $SMTPServerCredential `
                        -Priority High
}