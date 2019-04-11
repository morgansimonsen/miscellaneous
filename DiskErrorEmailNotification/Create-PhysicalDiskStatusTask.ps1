<#
Register the task to check disks
#>

$A = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass C:\Scripts\Get-PhysicalDiskStatus.ps1"
$T = New-ScheduledTaskTrigger -Daily -At "10:00"
$P = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -Compatibility Win8
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask -TaskName "CheckPhysicalDiskStatus" -InputObject $D
