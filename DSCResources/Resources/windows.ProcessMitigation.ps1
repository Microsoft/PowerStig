# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Get-RuleClassData -StigData $StigData -Name ProcessMitigationRule
$mitigationTargets = $rules.MitigationTarget | Select-Object -Unique

foreach ($target in $mitigationTargets)
{
    $targetrules = $rules | where {$_.MitigationTarget -eq "$target"}
    $enableValue = @()
    $disableValue = @()
    $idValue = @()

    foreach ($rule in $targetrules)
    {   
        if ($rule.enable)
        {
            $enableValue  += $rule.enable
        }
        if ($rule.disable)
        {
            $disableValue += $rule.disable    
        }

        $idValue += $rule.id
    }

    $enableValue = $enableValue.split(',')

    ProcessMitigation "$Target-$idValue"
    {
        MitigationTarget = $target
        Enable           = $enableValue
        Disable          = $disableValue  
    }
}
