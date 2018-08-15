# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name WinEventLogRule

Foreach( $rule in $rules )
{
    xWinEventLog (Get-ResourceTitle -Rule $rule)
    {
        LogName     = $rule.LogName
        IsEnabled   = [boolean]$($rule.IsEnabled)
    }
}
