# CalendarScanDaily.ps1
# Batch scan script
# http://www.gssezisoft.com/main/cmdtwain/
# http://sergey.marechek.com/blog/2009/10/31/97/
# http://www.commandlinescanning.com/
 Param(
        [parameter(Mandatory=$false, Position=0)]
        [string]
        $CalendarDate
        )

$Scanner = "HP ENVY 5540 series TWAIN"
$DPI = "300"
$CmdTwainExecutablePath = "C:\Users\Morgan\Downloads\CmdTwain\CmdTwain.exe"
$CLScanExecutablePath = "C:\Users\Morgan\Downloads\clscan\CLScan.exe"
$ScanDestinationPath = [Environment]::GetFolderPath("MyPictures")
$ScanBaseFileName = "2017-PondusKalender"
$ScanExtension = ".jpg"
$ScanLogFile = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+".log")
[int]$Width = 1000
[int]$Height = 750
$WidthInCm = "17.0"
$HeightInCm = "13.0"

If ( $CalendarDate -eq "")
{
    $date = get-date -f yyyy-MM-dd
    $cmdLineDate = $false
    Write-Host -NoNewline "Press space to scan today's image..."
    $PressedKey = [Console]::ReadKey($true)
}
Else
{
    $date = $CalendarDate
    $cmdLineDate = $true
}


If ( ($PressedKey.Key -eq "Spacebar") -or ($cmdLineDate -eq $true) )
{
    Write-Host "Scanning image..."
    $ScanDesinationFullPath = Join-Path -Path $ScanDestinationPath -ChildPath ($ScanBaseFileName+"-"+$date+$ScanExtension)
    Write-Host "Destination File: $ScanDesinationFullPath"
    $CLScanArguments = "/SetScanner `"$Scanner`" /SetFileName $ScanDesinationFullPath /SetResolution $DPI /SetCrop /SetDeskew /LogToFile $ScanLogFile /SetWidth $Width /SetHeight $Height"
    $CmdTwainArguments = "-c  `"CM WH $WidthInCm $HeightInCm DPI $DPI RBG AUTOBR 1`" 75 $ScanDesinationFullPath"
    #Write-Host "Command line arguments:  $CmdTwainArguments"
    Start-Process -FilePath $CmdTwainExecutablePath -ArgumentList $CmdTwainArguments -Wait
}
