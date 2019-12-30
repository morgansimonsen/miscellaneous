Function Start-xRunLimitedWithCompatLayer
{
    [CmdletBinding()]
    Param(
    # FilePath
    [Parameter(
    Mandatory=$true
    )]
    [System.IO.FileInfo]$FilePath
    )

    If ($SilentConnection -eq $true)
    {
        Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--command silent_connection 1"
    }
    elseif ($SilentConnection -eq $false) {
        Start-Process "$env:ProgramFiles\OpenVPN\bin\openvpn-gui.exe" -ArgumentList "--command silent_connection 0"
    }
}

Function Start-xRunLmitedWithPSExec
{
    [CmdletBinding()]
    Param(
    # FilePath
    [Parameter(
    Mandatory=$true
    )]
    [System.IO.FileInfo]$FilePath,

    # PSExecPath
    [Parameter(
    Mandatory=$false
    )]
    [System.IO.FileInfo]$PSExecPath = "$env:OneDrive\PortableApps\Sysinternals\PSTools\PsExec.exe",

    # ExtraArgs
    [Parameter(
        Mandatory=$false
        )]
        [string]$ExtraArgs
    )

    If ( -not ( Test-Path -Path $PSExecPath ) )
    {
        Write-Error -Message "PSExec not found at $PSExecPath"
        Break
    }

    If ( -not ( Test-Path -Path $FilePath ) )
    {
        Write-Error -Message "Executable not found!"
        Break
    }

    $PSExecArgs = @(
        "-d"
        "-l"
        """$($FilePath.FullName) $ExtraArgs"""
    )

    Write-Verbose -Message $FilePath.FullName
    Write-Verbose -Message "PSExec args:"
    Write-Verbose -Message ( $PSExecArgs | Out-String )

    Start-Process -FilePath $PSExecPath `
                -ArgumentList $PSExecArgs `
                -WindowStyle Hidden
}