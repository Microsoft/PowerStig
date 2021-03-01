# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\SPWebAppGeneralSettingsRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a SharePoint WebAppGeneralSetting object
    .DESCRIPTION
        The SPWebAppGeneralSettingsRule class is used to extract the WebApp General settings from the
        check-content of the xccdf. Once a STIG rule is identified a WebApp General Settings rule,
        it is passed to the SPWebAppGeneralSettingsRule class for parsing and validation.
#>
class SPWebAppGeneralSettingsRuleConvert : SPWebAppGeneralSettingsRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    SPWebAppGeneralSettingsRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a SharePoint Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>
    SPWebAppGeneralSettingsRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetPropertyName($this.SplitCheckContent)
        $this.SetPropertyValue($this.SplitCheckContent)
        $this.SetDuplicateRule()
        $this.SetDscResource()
    }

    <#
        .SYNOPSIS
            Extracts the Property Name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the  Property Name from the xccdf content and sets the
            value.
    #>
    [void] SetPropertyName ($CheckContent)
    {
        $thisPropertyName = Get-PropertyName -CheckContent $CheckContent

        if (-not $this.SetStatus($thisPropertyName))
        {
            $this.set_PropertyName($thisPropertyName)
        }
    }

    <#
        .SYNOPSIS
            Extracts the Property Value from the check-content and sets
            the value
        .DESCRIPTION
            Gets the Property Value from the xccdf content and sets the
            value.
    #>
    [void] SetPropertyValue ($CheckContent)
    {
        $thisPropertyValue = Get-PropertyValue -CheckContent $CheckContent

        if (-not $this.SetStatus($thisPropertyValue))
        {
            $this.set_PropertyValue($thisPropertyValue)
        }
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'SPWebAppGeneralSettings'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "SharePoint server configuration" -and
            $CheckContent -Match "prohibited mobile code" -or
            $CheckContent -Match "ensure a session lock" -or
            $CheckContent -Match "ensure user sessions are terminated upon user logoff" -or
            $CheckContent -Match "ensure access to the online web part gallery is configured"
        )
        {
            return $true
        }

        return $false
    }
}
