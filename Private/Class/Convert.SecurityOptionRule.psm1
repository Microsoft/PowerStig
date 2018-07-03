#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Public\Class\Common.Enum.psm1
using module .\..\..\Public\Data\Convert.Data.psm1
# Class module
using module .\..\..\Public\Class\Convert.SecurityOptionRule.psm1
#endregion
#region Main Functions
<#
    .SYNOPSIS
        ConvertTo-SecurityOptionRule
#>
function ConvertTo-SecurityOptionRule
{
    [CmdletBinding()]
    [OutputType([SecurityOptionRule])]
    Param
    (
        [parameter(Mandatory = $true)]
        [xml.xmlelement]
        $StigRule
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    $securityOptionRule = [SecurityOptionRule]::New( $StigRule )
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
#endregion
#region Support Function
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
    [OutputType( [bool] )]
    Param
    (
        [parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    if ( $CheckContent -match 'value other than' )
    {
        return $true
    }

    return $false
}
#endregion
