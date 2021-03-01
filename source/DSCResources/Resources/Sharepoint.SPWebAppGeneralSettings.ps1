# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = Select-Rule -Type SPWebAppGeneralSettingsRule -RuleList $stig.RuleList

ForEach ($WebApp in $WebAppUrl)
{
    $configStringBuilder = New-Object -TypeName System.Text.StringBuilder

    $resourceTitle = "[$($rules.id -join ' ')_$($WebApp)]"

    [void] $configStringBuilder.AppendLine("SPWebAppGeneralSettings '$resourceTitle'")
    [void] $configStringBuilder.AppendLine("{")
    [void] $configStringBuilder.AppendLine("WebAppUrl = '$WebApp'")
    foreach ($rule in $rules)
    {
        if ($rule.PropertyValue -eq 'true' -or $rule.PropertyValue -eq 'false')
        {
            $correctedString = "`$$($rule.PropertyValue)"
            [void] $configStringBuilder.AppendLine("$($rule.PropertyName) = $correctedString")
        }
        else
        {
            [void] $configStringBuilder.AppendLine("$($rule.PropertyName) = '$($rule.PropertyValue)'")
        }
    }

    [void] $configStringBuilder.AppendLine("PsDscRunAsCredential = `$SetupAccount")
    [void] $configStringBuilder.AppendLine("}")
    [scriptblock]::Create($configStringBuilder.ToString()).Invoke()
}