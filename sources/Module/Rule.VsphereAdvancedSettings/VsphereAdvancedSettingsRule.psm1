# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Rule\Rule.psm1
#header

<#
    .SYNOPSIS
        An Vsphere Advanced Settings Rule object
    .DESCRIPTION
        The Vsphere Advanced Settings class is used to maange the Vmware Vsphere Settings.
    .PARAMETER AdvancedSettings
        A string with value name and value data. (i.e. 'ValueName' = 'ValueData')


#>
Class VsphereAdvancedSettingsRule : Rule
{
    [string] $AdvancedSettings


    <#
        .SYNOPSIS
            Default constructor to support the AsRule cast method
    #>
    VsphereAdvancedSettingsRule ()
    {
    }

    <#
        .SYNOPSIS
            Used to load PowerSTIG data from the processed data directory
        .PARAMETER Rule
            The STIG rule to load
    #>
    VsphereAdvancedSettingsRule ([xml.xmlelement] $Rule) : Base ($Rule)
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
    VsphereAdvancedSettingsRule ([xml.xmlelement] $Rule, [switch] $Convert) : Base ($Rule, $Convert)
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
