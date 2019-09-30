Function Enable-xWiresharkTLSDecryption
{
    [alias("Enable-xBrowserTLSDecryption")]
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$false)]
    [System.IO.FileInfo]$SSLKeyLogFile="$env:USERPROFILE\sslkey.log"
    )

    [Environment]::SetEnvironmentVariable("SSLKEYLOGFILE", $SSLKeyLogFile, "Machine")
}

Function Disable-xWiresharkTLSDecryption
{
    [alias("Disable-xBrowserTLSDecryption")]
    [CmdletBinding()]
    Param()
    
    [Environment]::SetEnvironmentVariable("SSLKEYLOGFILE", $null, "Machine")
}