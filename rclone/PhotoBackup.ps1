## Backup Photos to OneDrive
##
## Morgan Simonsen
##
## Test with adding element to path 'rclonebackuptest'

#.\rclone.exe copy E:\Shares\Pictures\ remote-onedrive-personal:Backup/Photos_HOME-NAS/current --backup-dir "remote-onedrive-personal:Backup/Photos_HOME-NAS/$(Get-Date -Format "yyyyMMdd-HHmmss")" --progress

[CmdletBinding()]
Param(
    # computername
    [Parameter(Mandatory=$False,Position=1)]
    [string]$computerName=$env:COMPUTERNAME,
    
    # AlertRecipientSMTPAddress
    [Parameter(Mandatory=$False,Position=2)]
    [string]$AlertRecipientSMTPAddress=$env:SMTP_NotificationRecipient,

	# dryrun
    [Parameter(Mandatory=$False,Position=3)]
    [switch]$dryrun,
    
    # rcloneSource
    [Parameter(Mandatory=$False,Position=4)]
    [string]$rcloneSource="E:\Shares\Pictures\",

	# rcloneDestination
    [Parameter(Mandatory=$False,Position=5)]
    [string]$rcloneDestination="remote-onedrive-personal:Backup/Photos_HOME-NAS/current",
	
	# KeepLogFile
	[Parameter(Mandatory=$False,Position=5)]
    [switch]$KeepLogFile,

    # rcloneConfigFile
	[Parameter(Mandatory=$False,Position=6)]
    [string]$rcloneConfigFile="C:\Users\Administrator\.config\rclone\rclone.conf",

    # Transcribe
	[Parameter(Mandatory=$False,Position=7)]
    [switch]$Transcribe
)
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
If ( $Transcribe )
{
    Start-Transcript -Path (Join-Path -Path $env:temp -ChildPath "rclone-transcript-$computername-$timestamp.log")
}

$SMTPServerUsername = $env:SMTP_Username
$SMTPServerPassword = $env:SMTP_Password
$SMTPServerSecurePassword = ConvertTo-SecureString $SMTPServerPassword -AsPlainText -Force
$SMTPServerCredential = New-Object System.Management.Automation.PSCredential ($SMTPServerUsername, $SMTPServerSecurePassword)
$rclonepath = "$env:ProgramFiles\rclone\rclone.exe"


$LogFilePath = Join-Path -Path $env:temp -ChildPath "rclone-stats-$computername-$timestamp.log"

$rcloneArguments = @(
    "copy"
    $rcloneSource
    $rcloneDestination
    "--backup-dir"
    "remote-onedrive-personal:Backup/Photos_HOME-NAS/$timestamp"
    "--config"
    "$rcloneConfigFile"
    "--log-file"
    $LogFilePath
    "--stats-log-level NOTICE"
	"--log-level NOTICE"
	#"--stats-one-line"
    "--exclude Thumbs.db"
)

If ( $dryrun )
{
    $rcloneArguments += "--dry-run"
	$rcloneArguments += "--progress"
}
Else {
	#$rcloneArguments += "--stats=0"
}

## Run backup job
Start-Process -FilePath $rclonepath -ArgumentList $rcloneArguments -Wait -NoNewWindow

## Parse results and create HTML
#$stats = @()
#$stats = Get-Content -Path $LogFilePath #cannot use with converting to hash table because returns array
$stats = [System.IO.File]::ReadLines($LogFilePath)
$statshtml = @()
ForEach ( $stat in $stats )
{
	$statshtml += "$stat<br>"
}

## Give up on parsing the output for now
#$statshtml += "<table>"
#$statshtml += ("<tr><th colspan=""2"">"+$($stats[0])+"</th></tr>")
#ForEach ( $stat in $stats[1..($stats.length-2)] )
#{
#    $statshtml += "<tr><td>"+$($stat -replace ":\s*","</td><td>")+"</td></tr>"
#}
#$statshtml += "</table>"

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
        <title>rclone backup summary $timestamp</title>
    </head>
    <body>
        <h2>rclone backup summary $timestamp on $computerName</h2>
        <p>Job started at: $timestamp</p>
        $($statshtml)
		<p>Arguments: $rcloneArguments</p>
    </body>
</html>
"@

$EmailFrom = "$computerName <noreply@simonsen.bz>"
$EmailSubject = "rclone backup summary $timestamp on $computerName"
$SMTPServer = "smtp.gmail.com"
$SMTPServerPort = "587"

#$EmailBody | out-file "$home\Downloads\rclone.html"

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

# Clean up logfile
If ($KeepLogFile)
{
	Write-Information -InformationAction Continue -Message "Logfile kept at: $LogFilePath"
}
Else
{
	Remove-Item -Path $LogFilePath -Force 
}

If ( $Transcribe )
{
    Stop-Transcript
}