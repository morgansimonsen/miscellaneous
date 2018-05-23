# Upgrade Unifi Controller
# Morgan Simonsen

# Setting up
add-type -AssemblyName microsoft.VisualBasic
add-type -AssemblyName System.Windows.Forms

# Download UniFI SW from URI
Write-Output "Downloading new UniFi Controller..."
$UniFiDownloadURI = [System.Uri]$args[0]
$UniFiInstaller = (($UniFiDownloadURI.Segments[-1] -replace ".exe","")+"-"+($UniFiDownloadURI.Segments[-2] -replace "/",".exe"))
If (!(Test-Path $UniFiInstaller))
{
    Start-BitsTransfer -Source $UniFiDownloadURI.AbsoluteUri -Destination $UniFiInstaller
}

# Stop current Unifi process
Write-Output "Checking for running controller..."
$UniFiParentProcess = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*javaw*UniFi*ace.jar*" }
If ( $UniFiParentProcess -ne $null)
{
    Write-Output " Stopping running UniFi Controller..."
    $UniFiParentProcess2 = get-process -Id  $UniFiParentProcess.ProcessId | Select-Object *
    $MainWindowTitle = $UniFiParentProcess2.MainWindowTitle
    ( Get-Process -Id $UniFiParentProcess2.Id ).CloseMainWindow()
    # Press enter to exit
    [Microsoft.VisualBasic.Interaction]::AppActivate($MainWindowTitle)
    [System.Windows.Forms.SendKeys]::SendWait("~")

    # Wait until the controller has closed
    Do 
    {
        Start-Sleep -Seconds 5
        $UniFiParentProcess2 = get-process -Id  $UniFiParentProcess.ProcessId
    }
    Until ($UniFiParentProcess2.HasExited -eq $true)
    Write-Output " Finished stopping running UniFi Controller..."
}
else {
    Write-Output " Running controller process not found, continuing with install of new controller..."
}

# Install new Unifi Controller
Write-Output "Installing new UniFi controller..."
$InstallProcess = Start-Process -FilePath $UniFiInstaller -ArgumentList "/S" -PassThru

# Answer the first prompt: Do you want to upgrade?
Do {
    Start-Sleep -Seconds 1
    $InstallerMainWindowTitle = (get-process -Id  $InstallProcess.Id | Select-Object *).MainWindowTitle    
}
Until ( $InstallerMainWindowTitle -ne "" )

[Microsoft.VisualBasic.Interaction]::AppActivate($InstallerMainWindowTitle)
[System.Windows.Forms.SendKeys]::SendWait("~")

# Answer the second prompt: Do you have a backup?
Do {
    Start-Sleep -Seconds 1
    $InstallerMainWindowTitle = (get-process -Id  $InstallProcess.Id | Select-Object *).MainWindowTitle    
}
Until ( $InstallerMainWindowTitle -ne "" )

[Microsoft.VisualBasic.Interaction]::AppActivate($InstallerMainWindowTitle)
[System.Windows.Forms.SendKeys]::SendWait("~")

# Wait while the installer runs
Do {
    Write-Output " Waiting while UniFi Controller is installed..."
    Start-Sleep -Seconds 5
}
Until ($InstallProcess.HasExited -eq $true)

# Start controller
Write-Output "Starting UniFi Controller..."
Start-Process -FilePath (Join-Path -Path $env:APPDATA -ChildPath "Microsoft\Windows\Start Menu\Programs\Ubiquiti UniFi\UniFi.lnk")