# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a WebConfigurationPropertyRule object.

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function ConvertTo-WebConfigurationPropertyRule
{
    [CmdletBinding()]
    [OutputType([WebConfigurationPropertyRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webConfigurationPropertyRules = @()
    $checkStrings = $stigRule.rule.Check.('check-content')

    if ( [WebConfigurationPropertyRule]::HasMultipleRules( $checkStrings ) )
    {
        $splitWebConfigurationPropertyRules = [WebConfigurationPropertyRule]::SplitMultipleRules( $checkStrings )

        [int]$byte = 97
        $id = $stigRule.id
        foreach ($webConfigurationPropertyRule in $splitWebConfigurationPropertyRules)
        {
            $stigRule.id = "$id.$([CHAR][BYTE]$byte)"
            $stigRule.rule.Check.('check-content') = $webConfigurationPropertyRule
            $rule = New-WebConfigurationPropertyRule -StigRule $stigRule
            $webConfigurationPropertyRules += $rule
            $byte ++
        }
    }
    else
    {
        $webConfigurationPropertyRules += ( New-WebConfigurationPropertyRule -StigRule $stigRule )
    }
    return $webConfigurationPropertyRules
}
#endregion
#region Support Functions
<#
    .SYNOPSIS
        Creates a new WebConfigurationPropertyRule

    .PARAMETER StigRule
        The xml Stig rule from the XCCDF.
#>
function New-WebConfigurationPropertyRule
{
    [CmdletBinding()]
    [OutputType([WebConfigurationPropertyRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $webConfigurationProperty = [WebConfigurationPropertyRule]::New( $stigRule )

    $webConfigurationProperty.SetConfigSection()

    $webConfigurationProperty.SetKeyValuePair()

    if ($webConfigurationProperty.IsOrganizationalSetting())
    {
        $webConfigurationProperty.SetOrganizationValueTestString()
    }

    if ($webConfigurationProperty.conversionstatus -eq 'pass')
    {
        if ( $webConfigurationProperty.IsDuplicateRule( $global:stigSettings ))
        {
            $webConfigurationProperty.SetDuplicateTitle()
        }
    }

    $webConfigurationProperty.SetStigRuleResource()

    return $webConfigurationProperty
}
#endregion
