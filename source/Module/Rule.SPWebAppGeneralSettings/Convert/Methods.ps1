# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Property Name.
#>
function Get-PropertyName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    switch -Regex ($CheckContent)
    {
        "SharePoint server configuration.*prohibited mobile code"
        {
            return 'BrowserFileHandling'
        }
        "SharePoint server configuration.*session lock"
        {
            return 'SecurityValidationTimeOutMinutes'
        }
        "SharePoint server configuration.*user sessions.*time limit is exceeded"
        {
            return 'SecurityValidation'
        }
        "SharePoint server configuration.*online web part gallery"
        {
            return 'AllowOnlineWebPartCatalog'
        }
    }
}

<#
    .SYNOPSIS
        Parses Check-Content element to retrieve the Property Value.
#>
function Get-PropertyValue
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    switch -Regex ($CheckContent)
    {
        "Verify that the Security Validation.*set to expire after \d+ minutes or less."
        {
            $CheckContentPattern = [regex]::new('(\d+)(?=\sminutes or less for any of the web applications, this is a finding)')
            $MinutesMatches = $CheckContentPattern.Matches($CheckContent)
            return $MinutesMatches.Value
        }
        ".*Web Page Security Validation.*Security Validation.*On.*"
        {
            return "$true"
        }
        ".*accessing the Online Web Part Gallery.*improve security and performance.*is selected.*"
        {
            return "$false"
        }
        'Under Browser File Handling, verify that "(?i)[A-Z]+" is selected.'
        {
            $CheckContentPattern = [regex]::new('(?i)("[A-Z]+")(?=\sis selected)')
            $MinutesMatches = $CheckContentPattern.Matches($CheckContent)
            return $MinutesMatches.Value.Trim('"')
        }
    }
}
