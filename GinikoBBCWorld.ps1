<#
	GinikoBBCWorld.ps1

	Script to use VLC to play the BBC World Service stream using  VLC

	References:
	- https://wiki.videolan.org/VLC_command-line_help/
	- http://nimlive1.giniko.com/bbcworldnews/bbcworld/playlist.m3u8?wmsAuthSign=c2VydmVyX3RpbWU9NS8zMS8yMDE4IDE6MTc6MzcgUE0maGFzaF92YWx1ZT1kM1dWaTNmMVhpa1V3WDlKK1A4Zm5nPT0mdmFsaWRtaW51dGVzPTE0NDA=
#>

$GinikoURL = "http://www.giniko.com/watch.php?id=216"
$VLCPath = Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\App Paths\vlc.exe"
$userAgent = ":http-user-agent=Mozilla/5.0"

# Get the web page with the auth key
$HTML = Invoke-WebRequest -Uri $GinikoURL -UseBasicParsing

# Extract the URL and authN key
$urldata = $html.Content -split "[`r`n]" | select-string -pattern "wmsAuthSign"
$url = ($urldata -split '"')[5]
#$video = $HTML.ParsedHtml.getElementsByTagName("source")
#$video2 = $video.ie8_item().outerhtml -split " "
#$video2 = $video2[1] -split "\?" -replace '\"'
#$url = $video2[1] -replace "src=",""

# Start the stream
Start-Process -FilePath $VLCPath.'(default)' -ArgumentList ($url+" "+$userAgent+" --video-on-top --qt-minimal-view --qt-opacity=1.0")