<#
For systems that do not detect that they are not in use;
force starting maintenance
#>

$A = New-ScheduledTaskAction -Execute "mschedexe.exe" -Argument "start"
$T = New-ScheduledTaskTrigger -Daily -At "03:00"
$P = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -Compatibility Win8
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S
Register-ScheduledTask -TaskName "ForceMaintenance" -InputObject $D
