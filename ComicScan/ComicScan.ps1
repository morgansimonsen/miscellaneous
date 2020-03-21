<#
    ComicScan.ps1
    Batch scan comics
    http://www.gssezisoft.com/main/cmdtwain/
    http://sergey.marechek.com/blog/2009/10/31/97/
    http://www.commandlinescanning.com/
#>

[CmdletBinding()]
Param(
    # OutputFolder
    [parameter(
        Mandatory=$true,
        Position=0)]
        [ValidateScript({
            if( -Not ($_ | Test-Path) )
            {
                Write-Verbose -Message "File or folder does not exist"
                New-Item -Path $_ -Force -ItemType Directory
            }
            return $true
        })]
        [System.IO.FileInfo]$OutputFolder,

    # PageNumber
    [parameter(
        Mandatory=$false,
        Position=1)]
        [int]$PageNumber=1
    )

$PageNumber = '{0:d2}' -f [int]$PageNumber

$CmdTwainExecutablePath = "$env:LOCALAPPDATA\Programs\GssEziSoft\CmdTwain\CmdTwain.exe"

$DPI = "300"
$ScanExtension = "jpg"
$WidthInCm = "17.0"
$HeightInCm = "15.0"

$KeepScanning = $true

Do {
    Write-Host -NoNewline "Press space to scan image, or press 'q' to quit..."
    $PressedKey = [Console]::ReadKey($true)

    If ($PressedKey.Key -eq "Spacebar")
    {
        Write-Host "Scanning image..."
        $ScanDesinationFullPath = Join-Path -Path $OutputFolder.FullName -ChildPath ("$PageNumber+"."+$ScanExtension")
        Write-Host "Destination File: $ScanDesinationFullPath"

        $CmdTwainArguments = @(
            "-c `"CM WH $WidthInCm $HeightInCm DPI $DPI RBG AUTOBR 1`" 75 $ScanDesinationFullPath"
        )
        Write-Verbose -Message "Command line arguments:  $CmdTwainArguments"
        Start-Process -FilePath $CmdTwainExecutablePath -ArgumentList $CmdTwainArguments -Wait
        $PageNumber+=1
        }
    elseif ($PressedKey.Key -eq "q")
    {
        $KeepScanning = $false
    }
}
While ( $KeepScanning -eq $true )
