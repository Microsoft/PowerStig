# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

using module ..\helper.psm1
using module ..\..\PowerStig.psm1

<#
    .SYNOPSIS
        A composite DSC resource to manage the McAfee VirusScan STIG settings.
    .PARAMETER TechnologyRole
        The technology version of McAfee the STIG applies to
    .PARAMETER Version
        The version of McAfee technology the STIG applies to
    .PARAMETER StigVersion
        The version of the McAfee VirusScan STIG to apply and/or monitor
    .PARAMETER Exception
        A hashtable of StigId=Value key pairs that are injected into the STIG data and applied to
        the target node. The title of STIG settings are tagged with the text ‘Exception’ to identify
        the exceptions to policy across the data center when you centralize DSC log collection.
    .PARAMETER OrgSettings
        The path to the xml file that contains the local organizations preferred settings for STIG
        items that have allowable ranges.  The OrgSettings parameter also accepts a hashtable for
        values that need to be modified.  When a hashtable is used, the specified values take
        presidence over the values defined in the org.default.xml file.
    .PARAMETER SkipRule
        The SkipRule Node is injected into the STIG data and applied to the taget node. The title
        of STIG settings are tagged with the text 'Skip' to identify the skips to policy across the
        data center when you centralize DSC log collection.
    .PARAMETER SkipRuleType
        All STIG rule IDs of the specified type are collected in an array and passed to the Skip-Rule
        function. Each rule follows the same process as the SkipRule parameter.
#>
configuration McAfee
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $TechnologyRole,

        [Parameter(Mandatory = $true)]
        [string]
        $Version,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [version]
        $StigVersion,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [hashtable]
        $Exception,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [object]
        $OrgSettings,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('CAT_I', 'CAT_II', 'CAT_III')]
        [string[]]
        $SkipRuleCategory
    )

    ##### BEGIN DO NOT MODIFY #####
    $stig = [STIG]::New('McAfee', $Version, $TechnologyRole, $StigVersion)
    $stig.LoadRules($OrgSettings, $Exception, $SkipRule, $SkipRuleType, $SkipRuleCategory)
    ##### END DO NOT MODIFY #####

    Import-DscResource -ModuleName PSDSCresources -ModuleVersion 2.12.0.0
    . "$resourcePath\windows.Registry.ps1"
    . "$resourcePath\windows.Script.skip.ps1"
}
