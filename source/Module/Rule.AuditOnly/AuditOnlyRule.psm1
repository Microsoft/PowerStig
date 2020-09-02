# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into an AuditOnlyRule
    .DESCRIPTION
        The AuditOnlyRule class is used to extract the auditing settings
        from the check-content of the xccdf. Once a STIG rule is identified an
        audit rule, it is passed to the AuditOnlyRuleclass for parsing
        and validation.
    .PARAMETER Query
        The query to be evaluated
    .PARAMETER ExpectedValue
        The expected query result
#>
class AuditOnlyRule : Rule {
    [string] $Query
    [string] $ExpectedValue <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    AuditOnlyRule() {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    AuditOnlyRule ([xml.xmlelement] $Rule) : base ($Rule) {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content
    #>
    [PSObject] GetExceptionHelp() {
        return @{
            Value = "1"
            Notes = $null
        }
    }
}