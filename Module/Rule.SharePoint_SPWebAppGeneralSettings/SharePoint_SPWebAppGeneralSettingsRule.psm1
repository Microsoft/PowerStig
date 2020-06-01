# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        A SharePoint WebAppGeneralSettings Rule object
    .DESCRIPTION
        The SharePointRule class is used to manage SharePoint STIG rule settings.
    .PARAMETER GetScript
        The Get script content
    .PARAMETER TestScript
        The test script content
    .PARAMETER SetScript
        The set script content
#>
Class SharePoint_SPWebAppGeneralSettingsRule : Rule
{
    [string] $GetScript
    [string] $TestScript
    [string] $SetScript <#(ExceptionValue)#>
    [string[]] $Variable
    [String[]] $VariableValue

    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    SharePoint_SPWebAppGeneralSettingsRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    SharePoint_SPWebAppGeneralSettingsRule ([xml.xmlelement] $Rule) : Base ($Rule)
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
    SharePoint_SPWebAppGeneralSettingsRule ([xml.xmlelement] $Rule, [switch] $Convert) : Base ($Rule, $Convert)
    {
    }

    <#
        .SYNOPSIS
            Creates class specific help content
    #>
    [PSObject] GetExceptionHelp()
    {
        return @{
            Value = "15"
            Notes = $null
        }
    }
}
