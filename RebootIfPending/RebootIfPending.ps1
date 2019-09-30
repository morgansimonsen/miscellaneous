<#
RebootIfPending.ps1

If Windows determines that a computer is always in use, it will never run
automatic maintenance. Automatic maintenance can be forced with the
ForceMaintenance scheduled task, but the compute will not reboot.
This script will check if a reboot is pending and reboot if it is.
#> 

#Requires -Modules PendingReboot

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$computerName=$env:COMPUTERNAME
$SMTPServerUsername = $env:SMTP_Username
$SMTPServerPassword = $env:SMTP_Password
$AlertRecipientSMTPAddress=$env:SMTP_NotificationRecipient
$SMTPServerSecurePassword = ConvertTo-SecureString $SMTPServerPassword -AsPlainText -Force
$SMTPServerCredential = New-Object System.Management.Automation.PSCredential ($SMTPServerUsername, $SMTPServerSecurePassword)
If ((Test-PendingReboot -SkipConfigurationManagerClientCheck).IsRebootPending)
{
    $EmailFrom = "$computerName <noreply@simonsen.bz>"
    $EmailSubject = "Reboot required at $timestamp on $computerName"
    $SMTPServer = "smtp.gmail.com"
    $SMTPServerPort = "587"

$EmailBody = @"
<html>
    <head>
        <style>
        table, th, td {
        border: 1px solid black;
        border-collapse: collapse;
        }
        th, td {
        padding: 5px;
        text-align: left;
        }
        </style>
        <title>Reboot required at $timestamp on $computerName</title>
    </head>
    <body>
        <h2>Reboot required at $timestamp on $computerName</h2>
        <p>Reboot initiated!</p>
    </body>
</html>
"@

    Send-MailMessage -From $EmailFrom `
                        -To $AlertRecipientSMTPAddress `
                        -Subject $EmailSubject `
                        -BodyAsHtml `
                        -body $EmailBody `
                        -SmtpServer $SMTPServer `
                        -Port $SMTPServerPort `
                        -UseSsl `
                        -Credential $SMTPServerCredential `
                        -Priority Normal

    Restart-Computer -Force
}