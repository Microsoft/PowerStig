# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Functions
<#
    .SYNOPSIS
        Accepts the raw stig string data and converts it to a SecurityOptionRule object.
#>
function ConvertTo-SecurityOptionRule
{
    [CmdletBinding()]
    [OutputType([SecurityOptionRule])]
    param
    (
        [Parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $securityOptionRule = [SecurityOptionRule]::New( $stigRule )
    $securityOptionRule.SetStigRuleResource()
    $securityOptionRule.SetOptionName()

    if ( $securityOptionRule.TestOptionValueForRange() )
    {
        $securityOptionRule.SetOptionValueRange()
    }
    else
    {
        $securityOptionRule.SetOptionValue()
    }

    return $securityOptionRule
}

<#
    .SYNOPSIS
        There are multiple rules that require a value other than default.  If found we will
        set the OrganizationValueRequired flag to true.
    .NOTES
        General notes
#>
function Test-ValueOtherThan
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    if ( $checkContent -match 'value other than' )
    {
        return $true
    }

    return $false
}
#endregion
