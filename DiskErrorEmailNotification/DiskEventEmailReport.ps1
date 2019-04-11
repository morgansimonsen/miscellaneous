# DiskEventEmailReport.ps1
# Morgan Simonsen
#
# Get-EventLog -LogName System -Source "Disk" -InstanceId 7
# Write-EventLog -LogName System -Source "Disk" -EntryType Error -EventID 7 -Message "This is a test message."
# http://www.eventid.net/display.asp?eventid=7&source=disk

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$computerName,
	
    [Parameter(Mandatory=$True,Position=2)]
    [int]$EventID,

    [Parameter(Mandatory=$True,Position=3)]
    [int]$EventCategory,

    [Parameter(Mandatory=$True,Position=5)]
    [string]$Disk,

    [Parameter(Mandatory=$True,Position=6)]
    [string]$EventDateTime,
	
    [Parameter(Mandatory=$True,Position=7)]
    [string]$AlertRecipientSMTPAddress
)

$SMTPServerUsername = "<username>"
$SMTPServerPassword = "<plain text password here>"
$SMTPServerSecurePassword = ConvertTo-SecureString $SMTPServerPassword -AsPlainText -Force
$SMTPServerCredential = New-Object System.Management.Automation.PSCredential ($SMTPServerUsername, $SMTPServerSecurePassword)

$EventLevel = @{
    2 = 'Error'
    3 = 'Warning'
    4 = 'Information'
}

switch ( $EventID )
{
     7 { $EventDescription = "The device, $Disk, has a bad block." }
    15 { $EventDescription = "The device, $Disk, is not ready for access yet." }
    51 { $EventDescription = "An error was detected on device $Disk during a paging operation." }
   157 { $EventDescription = "$Disk has been surprise removed." }
   default { $EventDescription = "Unknown event" }

}
<#
$EventDescription = @{
     7 = "The device, $Disk, has a bad block."
    15 = "The device, $Disk, is not ready for access yet."
    51 = "An error was detected on device $Disk during a paging operation."
   157 = "$Disk has been surprise removed."
}
#>

$EmailBody = @"
<html>
    <head>
        <title>Disk $($EventLevel[$EventCategory])</title>
    </head>
    <body>
    Disk $($EventLevel[$EventCategory]) for disk <b>$Disk</b> on <b>$computerName</b><br>
    Level: <b>$($EventLevel[$EventCategory])</b><br>
    Time: <b>$EventDateTime</b><br>
    Id: <b>$EventID</b><br>
    Description: $EventDescription<br>
    <a href="http://www.eventid.net/display.asp?eventid=$EventID&source=disk">More information on EventID.net</a>
    </body>
</html>
"@

$EmailFrom = "$computerName <noreply@simonsen.bz>"
#$EmailSubject = ("Disk "+$EventLevel[$EventCategory]+" on $computerName")
$EmailSubject = "Disk $($EventLevel[$EventCategory]) on $computerName"
$SMTPServer = "smtp.gmail.com"
$SMTPServerPort = "587"

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