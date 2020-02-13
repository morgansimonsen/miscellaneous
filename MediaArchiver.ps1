<#
    .SYNOPSIS
    Archive media to removable drive to save space on NAS disks

    .DESCRIPTION
    Scan root folder for subfolders with a signal file (archive.me)
    Copy folders to specified removable drive
    Delete contents of folders, including signal file
    Generate video file in folder showing that the item has been archived and to which disk
    Output log

    .PARAMETER DestinationDrive
    The drive letter of the drive to archive to

    .PARAMETER SourcePath
    The path to start search for signal file from
#>

[CmdletBinding()]
Param
(
    # DestinationDrive
    [parameter(
        Position=0,
        Mandatory=$true
    )]
    [ValidateScript({
        if( -Not ($_ | Test-Path -PathType Container) )
        {
            throw "Destination drive not found"
        }
        return $true
    })]
    [System.IO.FileInfo]$DestinationDrive,

    # SourcePath
    [parameter(
        Position=1,
        Mandatory=$true
    )]
    [ValidateScript({
        if( -Not ($_ | Test-Path -PathType Container) )
        {
            throw "SourcePath not found"
        }
        return $true
    })]
    [System.IO.FileInfo]$SourcePath
)

$ffmpegPath = "C:\Users\morga\Downloads\ffmpeg-20200209-5ad1c1a-win64-static\bin\ffmpeg.exe"
$signalFilename = "archive.me"
$StartTime = Get-Date -Format yyyyMMdd-HHmmss
$script:LogFile = Join-Path -Path $DestinationDrive -ChildPath "MediaArchiver-$StartTime.log"

function Write-Log {
    Param(
        $Message,
        $Path = $LogFile
    )

    function TimeStamp {
        Get-Date -Format 'yyyyMMdd-HH:mm:ss'
    }

    "[$(TimeStamp)]$Message" | Tee-Object -FilePath $Path -Append | Write-Host
}

Write-Log -Message "Starting media archiving job..."
# Get the unique identifier of the specified destination drive
$volumeUniqueId = ( Get-Volume -FilePath $DestinationDrive ).UniqueId | `
                    Select-String -Pattern "Volume(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}" | `
                    foreach { $_.Matches.Value }
$archiveMessage = @"
This item has been archived to drive
$volumeUniqueId
"@

Write-Log -Message "Will look for items to archive in: $sourcePath"
Write-Log -Message "Will archive to: $DestinationDrive ($volumeUniqueId)"

# Get all folders selected for archiving
$archiveItems = Get-ChildItem $SourcePath -Recurse -File $signalFilename
Write-Log -Message "Items to archive:"
$archiveItems.DirectoryName | foreach { Write-Log -Message $_ }

# Copy archive items to archive drive
ForEach ( $item in $archiveItems )
{
    Write-Log -Message "Archiving: $($item.DirectoryName)"
    # Copy item to archive drive
    Try {
        Copy-Item -Path $item.DirectoryName `
                -Destination ( Join-Path -Path $DestinationDrive -ChildPath $SourcePath.directory.name ) `
                -Recurse `
                -Exclude $signalFilename
    }
    Catch {
        throw "File copy failed"
        $_.Exception
        continue
    }

    # Remove contents of archived folder
    Write-Log -Message "Removing contents from $($item.DirectoryName)"
    Remove-Item -Path ( Join-Path -Path $item.DirectoryName -ChildPath "\*" ) -Recurse

    # Generate video explaining that item has been archived
    Write-Log -Message "Creating archive message video..."
    $ffmpegfile = Join-Path -Path $($item.DirectoryName) -ChildPath "archived.mp4"
    $ffmpegArgs = @(
        "-n"
        "-nostats"
        "-loglevel 0"
        "-f lavfi"
        "-i color=c=black:s=1280x720:d=30"
        "-vf ""drawtext=fontfile=/WINDOWS/fonts/arial.ttf:fontsize=50:fontcolor=white:x=(w-text_w)/2:y=(h-text_h)/2:text='$($archiveMessage)'"""
        """$ffmpegfile"""
    )

    Start-Process -FilePath $ffmpegPath `
                -ArgumentList $ffmpegArgs `
                -NoNewWindow `
                -Wait
}

Write-Log -Message "Media archive operation completed!"
Copy-Item -Path $LogFile -Destination $DestinationDrive