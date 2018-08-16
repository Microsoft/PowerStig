# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name ServiceRule

Foreach( $rule in $rules )
{
    xService (Get-ResourceTitle -Rule $rule)
    {
        Name        = $rule.ServiceName
        State       = $rule.ServiceState
        StartupType = $rule.StartupType
    }
}
