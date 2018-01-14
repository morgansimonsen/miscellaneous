# DiskErrorEmailReport.ps1
# Morgan Simonsen
#
# Get-EventLog -LogName System -Source "Disk" -InstanceId 7
# Write-EventLog –LogName System –Source "Disk" –EntryType Error –EventID 7 –Message "This is a test message."
#
# https://social.technet.microsoft.com/Forums/ie/en-US/382b9023-01a9-4131-b2f2-8560b593bc3f/scheduled-task-trigerred-by-event-getting-data-into-the-scripts-as-parameters-question?forum=winserverpowershell
# https://vijredblog.wordpress.com/2014/03/21/task-scheduler-event-log-trigger-include-event-data-in-mail/

[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$computerName,
	
   [Parameter(Mandatory=$True,Position=2)]
   [string]$Disk,

   [Parameter(Mandatory=$True,Position=3)]
   [string]$EventDateTime,
	
   [Parameter(Mandatory=$True,Position=4)]
   [string]$AlertRecipientSMTPAddress
)

$SMTPServerUsername = "<username>"
$SMTPServerPassword = "<plain text password here>"
$SMTPServerSecurePassword = ConvertTo-SecureString $SMTPServerPassword -AsPlainText -Force
$SMTPServerCredential = New-Object System.Management.Automation.PSCredential ($SMTPServerUsername, $SMTPServerSecurePassword)

$EmailBody =  "<html>"
$EmailBody += "<head>"
$EmailBody += "<title>Disk Error</title>"
$EmailBody += "</head>"
$EmailBody += "<body>"
$EmailBody += "Disk error detected on disk <b>$Disk</b> on <b>$computerName</b> at <b>$EventDateTime</b>"
$EmailBody += "</body>"
$EmailBody += "</html>"

$EmailFrom = "$computerName <noreply@simonsen.bz>"
$EmailSubject = "Disk error on $computerName"
$SMTPServer = "smtp.gmail.com"
$SMTPServerPort = "587"

Send-MailMessage -From $EmailFrom `                    -To $AlertRecipientSMTPAddress `                    -Subject $EmailSubject `                    -BodyAsHtml `                    -body $EmailBody `                    -SmtpServer $SMTPServer `                    -Port $SMTPServerPort `                    -UseSsl `                    -Credential $SMTPServerCredential `                    -Priority High