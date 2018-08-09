# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Variables
[string] $resourcePath = (Resolve-Path -Path $PSScriptRoot\common).Path
#endregion

#region Functions
<#
    .SYNOPSIS
        Applies a standard format of STIG data to resource titles.

    .PARAMETER Rule
        The Stig rule that is being created.
#>
function Get-ResourceTitle
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Xml.XmlElement]
        $Rule
    )

    return "[$($rule.Id)][$($rule.severity)][$($rule.title)]"
}

<#
    .SYNOPSIS
        Filters the STIG items to a specifc type

    .PARAMETER Name
        The name of the rule type to return

    .PARAMETER StigData
        The main stig data object to filter.
#>
function Get-RuleClassData
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [xml]
        $StigData
    )

    return $StigData.DISASTIG.$Name.Rule | Where-Object { $_.conversionstatus -eq 'pass' }
}
#endregion

Export-ModuleMember -Function 'Get-ResourceTitle','Get-RuleClassData' `
                    -Variable 'resourcePath'
