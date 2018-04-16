<#
	GinikoBBCWorld.ps1

	Script to use VLC to play the BBC World Service stream using  VLC
#>

$GinikoURL = "http://www.giniko.com/watch.php?id=216"
$VLCPath = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\vlc.exe"
$userAgent = ":http-user-agent=Mozilla/5.0"

# Get the web page with the auth key
$HTML = Invoke-WebRequest -Uri $GinikoURL

# Extract the URL and authN key
$video = $HTML.ParsedHtml.getElementsByTagName("source")
$video2 = $video.ie8_item().outerhtml -split " "
#$video2 = $video2[1] -split "\?" -replace '\"'
$url = $video2[1] -replace "src=",""

# Start the stream
Start-Process -FilePath $VLCPath.'(default)' -ArgumentList ($url+" "+$userAgent)