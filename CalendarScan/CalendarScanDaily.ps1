# CalendarScanDaily.ps1
# Batch scan script

$Scanner = "HP ENVY 5540 series TWAIN"
$DPI = "300"
$CLScanExecutablePath = "C:\Users\Morgan\Downloads\clscan\CLScan.exe"
$ScanDestinationPath = [Environment]::GetFolderPath("MyPictures")
$ScanBaseFileName = "2017-PondusKalender"
$ScanExtension = ".jpg"
$ScanLogFile = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+".log")
[int]$Width = 1000
[int]$Height = 750
[int]$counter = 1

If ( $args[0] -eq "")
{
    $date = get-date -f yyyy-MM-dd
    $cmdLineDate = $false
    Write-Host -NoNewline "Press space to scan today's image..."
    $PressedKey = [Console]::ReadKey($true)
}
Else
{
    $date = $args[0]
    $cmdLineDate = $true
}


If ( ($PressedKey.Key -eq "Spacebar") -or ($cmdLineDate -eq $true) )
{
    Write-Host "Scanning image..."
    $ScanDesinationFullPath = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+"-"+$date+$ScanExtension)
    Write-Host "Destination File: $ScanDesinationFullPath"
    $CLScanArguments = "/SetScanner `"$Scanner`" /SetFileName $ScanDesinationFullPath /SetResolution $DPI /SetCrop /SetDeskew /LogToFile $ScanLogFile /SetWidth $Width /SetHeight $Height"
    #Write-Host $CLScanArguments
    Start-Process -FilePath $CLScanExecutablePath -ArgumentList $CLScanArguments -Wait
    $counter++
}
