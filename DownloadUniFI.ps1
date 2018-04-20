# Upgrade Unifi Controller
# Morgan Simonsen

# Download UniFI SW from URI
$UniFiDownloadURI = [System.Uri]$args[0]
$UniFiInstaller = (($UniFiDownloadURI.Segments[-1] -replace ".exe","")+"-"+($UniFiDownloadURI.Segments[-2] -replace "/",".exe"))
Start-BitsTransfer -Source $UniFiDownloadURI.AbsoluteUri -Destination $UniFiInstaller

# Stop current Unifi process
$UniFiParentProcess = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*javaw*UniFi*ace.jar*" }
add-type -AssemblyName microsoft.VisualBasic
add-type -AssemblyName System.Windows.Forms
$MainWindowTitle = (get-process -Id  $UniFiParentProcess.ProcessId | Select-Object *).MainWindowTitle
( Get-Process -Id $UniFiParentProcess.ProcessId ).CloseMainWindow()
[Microsoft.VisualBasic.Interaction]::AppActivate($MainWindowTitle)
[System.Windows.Forms.SendKeys]::SendWait("~")
#taskkill.exe /T /PID $UniFiParentProcess.ProcessId /F

# Install new Unifi
Start-Process -FilePath $UniFiInstaller -ArgumentList "/S" -Wait
# add keystrokes here too to confirm the prompts...