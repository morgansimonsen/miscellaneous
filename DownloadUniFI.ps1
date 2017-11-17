# Download UniFI SW from URI

$UniFiDownloadURI = [System.Uri]$args[0]
Start-BitsTransfer -Source $UniFiDownloadURI.AbsoluteUri -Destination (($UniFiDownloadURI.Segments[-1] -replace ".exe","")+"-"+($UniFiDownloadURI.Segments[-2] -replace "/",".exe"))
