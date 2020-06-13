<#

.PARAMETER WinISOFile
The ISO file that contains the Windows OS you want to inject drivers into.

.PARAMETER WinISOMountPath
The path to mount the source ISO file

.PARAMETER WindowsEditon
The name of the edition in the ISO file that you want to use in the new ISO file

.PARAMETER BootDriverPaths
An array of paths to search for drivers to inject into the boot image
These should only be for storage, and perhaps network

.PARAMETER MountPath
The path to mount WIM images to

.PARAMETER NewWinISOFile
Path and name of new ISO to file to create

.PARAMETER OSDriverPaths
An array of paths to search for drivers to inject into the boot image

.PARAMETER NewWinISOFileVolumeLabel
Volume label to set for the new ISO

.PARAMETER KeepFiles
Don't delete the source files for the new ISO
This means that the contents of the WinISOMountPath will be kept
#>

[CmdletBinding()]
param (
    # WinISOFile
    [parameter(
        Position=0,
        Mandatory=$true
    )]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Leaf) ){
            throw "The WinISOFile argument must be a file. Folder paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$WinISOFile,

    # WinISOMountPath
    [parameter(
        Position=1,
        Mandatory=$true
    )]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "Folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Container) ){
            throw "The WinISOMountPath argument must be a folder. File paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$WinISOMountPath,
    
    # WindowsEdition
    [parameter(
        Position=2,
        Mandatory=$false
    )]
    [ValidateSet(
        "Windows 10 Home", 
        "Windows 10 Home N",
        "Windows 10 Home Single Language",
        "Windows 10 Education",
        "Windows 10 Education N",
        "Windows 10 Pro",
        "Windows 10 Pro N"
    )]
    [string]$WindowsEdition="Windows 10 Pro",

    # BootDriverPaths
    [parameter(
        Position=3,
        Mandatory=$true
    )]
    [array]$BootDriverPaths,

    # MountPath
    [parameter(
        Position=4,
        Mandatory=$true
    )]
    [ValidateScript({
        if(-Not ($_ | Test-Path) ){
            throw "Folder does not exist" 
        }
        if(-Not ($_ | Test-Path -PathType Container) ){
            throw "The MountPath argument must be a folder. File paths are not allowed."
        }
        return $true
    })]
    [System.IO.FileInfo]$MountPath,

    # NewWinISOFile
    [parameter(
        Position=5,
        Mandatory=$true
    )]
    [ValidateScript({
        if(-Not ($_.DirectoryName | Test-Path) ){
            throw "Folder does not exist" 
        }
        if( ($_ | Test-Path -PathType Leaf) ){
            throw "File already exists"
        }
        return $true
    })]
    [System.IO.FileInfo]$NewWinISOFile,

    # Architecture
    [parameter(
        Position=6,
        Mandatory=$false
    )]
    [ValidateSet(
        "x86",
        "x64"
    )]
    [string]$Architecture="x64",

    # OSDriverPaths
    [parameter(
        Position=7,
        Mandatory=$true
    )]
    [array]$OSDriverPaths,

    # NewWinISOFileVolumeLabel
    [parameter(
        Position=8,
        Mandatory=$false
    )]
    [string]$NewWinISOFileVolumeLabel="win10",

    # KeepFiles
    [parameter(
        Position=9,
        Mandatory=$false
    )]
    [switch]$KeepFiles
)

Function CleanUp
{
    #Dismount image
    Dismount-WindowsImage -Path $MountPath -Discard

    #Empty ISO Folder
    Remove-Item -Path $WinISOMountPath -Recurse -Force
}

$virtioWin10amd64 = @(
    "I:\Balloon\w10\amd64",
    "I:\NetKVM\w10\amd64",
    "I:\pvpanic\w10\amd64",
    "I:\qemufwcfg\w10\amd64",
    "I:\qemupciserial\w10\amd64",
    "I:\qxldod\w10\amd64",
    "I:\vioinput\w10\amd64",
    "I:\viorng\w10\amd64",
    "I:\vioscsi\w10\amd64",
    "I:\vioserial\w10\amd64",
    "I:\viostor\w10\amd64"
)

$rhelvirtioWin10amd64 = @(
    "O:\Balloon\w10\amd64",
"O:\NetKVM\w10\amd64",
"O:\pvpanic\w10\amd64",
"O:\qemufwcfg\w10\amd64",
"O:\qemupciserial\w10\amd64",
"O:\vioinput\w10\amd64",
"O:\viorng\w10\amd64",
"O:\vioscsi\w10\amd64",
"O:\vioserial\w10\amd64",
"O:\viostor\w10\amd64",
"I:\qxldod\w10\amd64"
)

switch ($Architecture)
{
    "x86" { [uint]$arch=0 }
    "x64" { [uint]$arch=9 }
}
# Echo start time
$start = get-date -Format "dd-MM-yyyy HH:mm"
Write-Information -MessageData "Process start: $start" -InformationAction Continue

# ADK Path 
$DeploymentToolsPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools"
$OSCDPath = "amd64\Oscdimg\oscdimg.exe"

# Get drivers
#Write-Information -MessageData "Getting boot driver data from $BootDriversPath..." -InformationAction Continue
#$BootCriticalDrivers = @()
#$BootDrivers = Get-ChildItem -Path $BootDriversPath -Recurse -Include "*.inf" -File | Select-Object -Property FullName

#ForEach ($Driver in $Drivers)
#{
#    $BootCriticalDrivers += Get-WindowsDriver -Online -Driver $Driver.FullName | where { ( $_.BootCritical -eq $true ) -and ($_.Architecture -eq $arch ) -and ( $_.ClassDescription -eq "Storage controllers") }
#}
#$BootCriticalDrivers
#exit

# Mount ISO
Write-Information -MessageData "Mounting Windows ISO image..." -InformationAction Continue
$ISOmount = Mount-DiskImage -ImagePath $WinISOFile -StorageType ISO
$volume = $ISOmount | Get-volume
$Drive = Get-PSDrive -Name $volume.DriveLetter

# Copy Windows install files to folder
Write-Information -MessageData "Copying Windows ISO image contents to '$WinISOMountPath'..." -InformationAction Continue
Copy-Item -Path ($Drive.Root+"*") -Destination $WinISOMountPath -Recurse

# Inject drivers in boot image
Write-Information -MessageData "Injecting boot critical drivers into boot image..." -InformationAction Continue
$BootImagePath = Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "boot.wim"

# Remove read-only attribute
Set-ItemProperty -Path $BootImagePath -Name IsReadOnly -Value $false

$BootImages = Get-WindowsImage -ImagePath $BootImagePath

ForEach ( $BootImage in $BootImages )
{
    # Mount boot image
    Write-Information -MessageData "Mounting '$($BootImage.ImageName)'..." -InformationAction Continue
    Mount-WindowsImage -Path $MountPath -ImagePath $BootImagePath -Index $BootImage.ImageIndex

    # Add drivers
    ForEach ( $BootDriverPath in $BootDriverPaths )
    {
        Write-Information -MessageData "Adding drivers from '$BootDriverPath'..." -InformationAction Continue
        Add-WindowsDriver -Path $MountPath -Driver $BootDriverPath -Recurse
    }

    # Dismount image
    Try
    {
        Dismount-WindowsImage -Path $MountPath -Save
    }
    Catch
    {
        Write-Warning -Message "error unmonting image..."
        $_.exception
        $continue = Read-Host -Prompt "Unmount manually and press 'c' to continue, or 'q' or CTRL+C to quit"
        switch ( $continue )
        {
            "q" { exit }
            "c" {}
        }
    }
}

# Get OS image
Write-Information -MessageData "Getting OS image information for '$WindowsEdition'..." -InformationAction Continue
If ( Test-Path -Path (Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.esd") )
{
    Write-Information -MessageData "ESD image type detected..." -InformationAction Continue
    $OSimagePath = Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.esd"
}
else
{
    Write-Information -MessageData "WIM image type detected..." -InformationAction Continue
    $OSimagePath = Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.wim"
}

$OSimage = Get-WindowsImage -ImagePath $OSimagePath | where { $_.ImageName -eq $WindowsEdition }

# Check if ESD or WIM image
If ( $OSimagePath -like "*.esd" )
{
    Write-Information -MessageData "Image is in ESD format; converting to WIM format..." -InformationAction Continue
    $DISMESDToWIMArgs = @(
        "/export-image"
        "/SourceImageFile:$($OSimagePath)"
        "/SourceIndex:$($OSimage.ImageIndex)"
        "/DestinationImageFile:$(Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.wim")"
        "/Compress:max"
        "/CheckIntegrity"
    )

    Start-Process -FilePath "dism.exe" -ArgumentList $DISMESDToWIMArgs -NoNewWindow -Wait
    #Rename-Item -Path $OSimagePath -NewName ($OSimagePath -replace ".esd",".esd.bak")
    Remove-Item -Path $OSimagePath -Force #get rid of old ESD
    $OSimagePath = Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.wim"
}

# Mount image
Write-Information -MessageData "Mounting install image to '$MountPath'..." -InformationAction Continue
Mount-WindowsImage -Path $MountPath -ImagePath $OSimagePath -Index "1"

# Add drivers
Write-Information -MessageData "Adding drivers from '$OSDriverPaths'..." -InformationAction Continue
ForEach ( $OSDriverPath in $OSDriverPaths )
{
    Write-Information -MessageData "Adding drivers from '$OSDriverPath'..." -InformationAction Continue
    Add-WindowsDriver -Path $MountPath -Driver $OSDriverPath -Recurse
}

# Dismount image
Try
{
    Dismount-WindowsImage -Path $MountPath -Save
}
Catch
{
    Write-Warning -Message "error unmonting image..."
    $_.exception
    $continue = Read-Host -Prompt "Unmount manually and press 'c' to continue, or 'q' or CTRL+C to quit"
    switch ( $continue )
    {
        "q" { exit }
        "c" {}
    }
}

# Convert to ESD
Write-Information -MessageData "Exporting '$OSimagePath' to ESD format..." -InformationAction Continue
$DISMWIMToESDArgs = @(
    "/Export-Image"
    "/SourceImageFile:$OSimagePath"
    "/SourceIndex:1"
    "/DestinationImageFile:$(Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.esd")"
    "/Compress:recovery"
    )
Start-Process -FilePath "dism.exe" -ArgumentList $DISMWIMToESDArgs -NoNewWindow -Wait

# Remove WIM file
Write-Information -MessageData "Removing '$OSimagePath'..." -InformationAction Continue
Remove-Item -Path $OSimagePath -Force
$OSimagePath = Join-Path -Path $WinISOMountPath -ChildPath "sources" -AdditionalChildPath "install.esd"

# Write new ISO
Write-Information -MessageData "Writing new ISO file to $NewWinISOFile..." -InformationAction Continue
$NewWinISOFileArgs = @(
    #"-o"
    "-m"
    "-l$NewWinISOFileVolumeLabel"
    "-u2"
    "-udfver102"
    "-bootdata:2#p0,e,b"+$(Join-Path -Path $WinISOMountPath -ChildPath "boot\etfsboot.com")+"#pEF,e,b"+$(Join-Path -Path $WinISOMountPath -ChildPath "efi\microsoft\boot\efisys.bin")
    $WinISOMountPath
    $NewWinISOFile
)

Try
{
    Start-Process -FilePath (Join-Path -Path $DeploymentToolsPath -ChildPath $OSCDPath) -ArgumentList $NewWinISOFileArgs -NoNewWindow -Wait
}
Catch
{
    Write-Warning -Message "error creating new ISO file..."
    $_.exception
    $continue = Read-Host -Prompt "Press 'c' to continue, or 'q' or CTRL+C to quit"
    switch ( $continue )
    {
        "q" { exit }
        "c" {}
    }
}

# Generate checksum
$hashAlgo = "MD5"
Write-Information -MessageData "Generating $hashAlgo hash for $NewWinISOFile..." -InformationAction Continue
$NewWinISOHash = Get-FileHash -Path $NewWinISOFile -Algorithm $hashAlgo
$NewWinISOHashFilename = Join-Path -Path $NewWinISOFile.DirectoryName -ChildPath ($NewWinISOFile.BaseName+".md5")
$NewWinISOHash.Hash + "`n" | Set-Content -Path $NewWinISOHashFilename -NoNewline #create a file compatible with UNIX

# Clean up ISO folder
If ( -Not $KeepFiles)
{
    Write-Information -MessageData "Cleaning up ISO folder..." -InformationAction Continue
    Remove-Item -Path "$WinISOMountPath\*" -Recurse -Force
}

# Dismount ISO
Write-Information -MessageData "Dismounting Windows ISO image..." -InformationAction Continue
Dismount-DiskImage -ImagePath $ISOmount.ImagePath

# Echo end time
$end = get-date -Format "dd-MM-yyyy HH:mm"
Write-Information -MessageData "Process finished: $end" -InformationAction Continue
New-TimeSpan -Start $start -End $end