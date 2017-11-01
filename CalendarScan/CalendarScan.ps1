# CalendarScanDaily.ps1
# Batch scan script

$Scanner = "HP ENVY 5540 series TWAIN"
$DPI = "300"
$CLScanExecutablePath = "C:\Users\Morgan\Downloads\clscan\CLScan.exe"
$ScanDestinationPath = [Environment]::GetFolderPath("MyPictures")
$ScanBaseFileName = "2016-RutetidKalender"
$ScanExtension = ".jpg"
$ScanLogFile = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+".log")
[int]$counter = 1

Do 
{
    Write-Host -NoNewline "Press space to scan next image, press C to abort..."
    $PressedKey = [Console]::ReadKey($true)
    If ( $PressedKey.Key -eq "Spacebar" )
    {
        Write-Host "Scanning image..."
        $ScanDesinationFullPath = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+"-"+("{0:D3}" -f $counter)+$ScanExtension)
        Write-Host "Destination File: $ScanDesinationFullPath"
        $CLScanArguments = "/SetScanner `"$Scanner`" /SetFileName $ScanDesinationFullPath /SetResolution $DPI /SetCrop /SetDeskew /LogToFile $ScanLogFile"
        #Write-Host $CLScanArguments
        Start-Process -FilePath $CLScanExecutablePath -ArgumentList $CLScanArguments
        $counter++
    }
}
Until ($PressedKey.KeyChar -eq "C")