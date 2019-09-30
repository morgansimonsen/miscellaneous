<#
Register the task to check for pending reboots
#>

$A = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass C:\Scripts\RebootIfPending.ps1"
$T = New-ScheduledTaskTrigger -Daily -At "05:00"
$P = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -Compatibility Win8
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask -TaskName "Reboot-If-Pending" -InputObject $D
