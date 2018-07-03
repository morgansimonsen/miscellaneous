<#
    .SYNOPSIS
    PowerShell script to add segment to IIS Request Filtering Hidden Segments
    .DESCRIPTION
    Specify the config element, website and the segment to add to the list of Hidden Segments
    .PARAMETER ConfigFile
    The IIS config element to apply the hidden segment to
    ApplicationHost: system32\inetsrv\config\applicationhost.config global section
    ApplicationHost: system32\inetsrv\config\applicationhost.config using the 'location' tag to target the website
    WebConfig: the web.config file in the root of the website directory
    Application: the web.config file in the root of the application in the website
    .PARAMETER WebSite
    The website to add the hidden segment to
    .PARAMETER segment
    The segment to add
    .EXAMPLE
    Add-IISHiddenSegment.ps1 -Site "MySite" -segment "connectionString.txt"
    .LINK
    https://docs.microsoft.com/en-us/iis/configuration/system.webserver/security/requestfiltering/hiddensegments/add
    https://docs.microsoft.com/en-us/iis/get-started/planning-your-iis-architecture/deep-dive-into-iis-configuration-with-iis-7-and-iis-8
    https://docs.microsoft.com/en-us/powershell/module/iisadministration/get-iisconfigsection?view=win10-ps
#>

[CmdletBinding()]
Param
(
    [parameter(
        Position=0,
        Mandatory=$true
    )]
    [String]
    [ValidateSet("ApplicationHostGlobal", "ApplicationHostLocation","Site","Application")]
    $ConfigElement,

    [parameter(
        Position=1,
        Mandatory=$false
    )]
    [String]
    $WebSite = "Default Web Site",

    [parameter(
        Position=2,
        Mandatory=$false,
        ParameterSetName="Application"
    )]
    [String]
    $Application,

    [parameter(
        Position=3,
        Mandatory=$true)]
    [String]
    $segment
)

switch ( $ConfigElement )
{ 
    "ApplicationHostGlobal" {
        $configSection = Get-IISConfigSection -SectionPath "system.webServer/security/requestFiltering"
    }
    "ApplicationHostLocation" {
        $configSection = Get-IISConfigSection -SectionPath "system.webServer/security/requestFiltering" -Location $WebSite
    }
    "Site" {
        $configSection = Get-IISConfigSection -SectionPath "system.webServer/security/requestFiltering" -CommitPath $WebSite
    }
    "Application" {
        $configSection = Get-IISConfigSection -SectionPath "system.webServer/security/requestFiltering" -CommitPath ($WebSite+"/"+$Application)
    }
}

$hiddenSegments = Get-IISConfigCollection -ConfigElement $configSection -CollectionName "hiddenSegments"

New-IISConfigCollectionElement -ConfigCollection $hiddenSegments -ConfigAttribute  @{"segment"=$segment}

Write-Output "Request Filtering Hidden segments:"
Get-IISConfigCollectionElement -ConfigCollection $hiddenSegments | Get-IISConfigAttributeValue -AttributeName "segment"