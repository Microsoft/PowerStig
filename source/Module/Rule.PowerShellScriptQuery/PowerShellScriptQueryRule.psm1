﻿# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Account Policy Rule object
    .DESCRIPTION
        The PowerShellScriptQueryRule class is used to execute PowerShell code.
    .PARAMETER GetScript
        The Get script content
    .PARAMETER TestScript
        The test script content
    .PARAMETER SetScript
        The set script content
#>
Class PowerShellScriptQueryRule : Rule
{
    [string] $GetScript
    [string] $TestScript
    [string] $SetScript <#(ExceptionValue)#>

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    PowerShellScriptQueryRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    PowerShellScriptQueryRule ([xml.xmlelement] $Rule) : Base ($Rule)
    {
    }

    <#
        .SYNOPSIS
            The Convert child class constructor
        .PARAMETER Rule
            The STIG rule to convert
        .PARAMETER Convert
            A simple bool flag to create a unique constructor signature
    #>
    PowerShellScriptQueryRule ([xml.xmlelement] $Rule, [switch] $Convert) : Base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specifc help content
    #>
    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
