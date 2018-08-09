# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header
$rules = Get-RuleClassData -StigData $StigData -Name WindowsFeatureRule

$ensureMapping = @{
    Present = 'Enable'
    Absent  = 'Disable'
}
#endregion Header

foreach ( $rule in $rules )
{
    <#
        This is here to address the issue that WindowsOptionalFeature is writen to not run
        a DC, and WindowsFeature does not run on client OS. In the future if WindowsOptionalFeature
        is updated to allow it to run a on DC lines 17-31 can be removed.
    #>
    if ( $StigData.DISASTIG.id -match 'MS|DC' )
    {
        if ( $rule.FeatureName -eq 'SMB1Protocol' )
        {
            $rule.FeatureName = 'FS-SMB1'
        }

        WindowsFeature (Get-ResourceTitle -Rule $rule)
        {
            Name   = $rule.FeatureName
            Ensure = $rule.InstallState
        }
    }
    else
    {
        WindowsOptionalFeature (Get-ResourceTitle -Rule $rule)
        {
            Name   = $rule.FeatureName
            Ensure = $ensureMapping.($rule.InstallState)
        }
    }
}

