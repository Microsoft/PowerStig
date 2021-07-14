# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$rules = $stig.RuleList | Select-Rule -Type PowerShellScriptQueryRule

# Creates variable with SQL Server Instance Name.
foreach ($instance in $serverInstance)
{
    try
    {
        # Default Instance.
        if ($instance -notmatch '\\')
        {
            $sqlInstanceName = 'MSSQLSERVER'
            $hostName = $instance
            $sqlConnectionName = $hostName
        }
        else
        {
            # Named Instance.
            $sqlInstanceName = $instance
            $hostName = $sqlInstanceName.Split("{\}")[0]
            $sqlConnectionName = $sqlInstanceName
        }
    }
    Catch
    {
        $errorMessage = $_.Exception.Message
        Write-Verbose $errorMessage
    }

    foreach ($rule in $rules)
    {
        Try
        {
            # XML file has placeholder key words. This replaces the placeholder keywords with actual values for configuration for the SQL 2016 STIG.
            $setScript = $rule.SetScript
            $setScript = ($setScript) | ForEach-Object{$_.replace('SQLInstanceName',$sqlInstanceName).replace('HostName',$hostName).replace('SQLConnectionName',$sqlConnectionName)}

            $testScript = $rule.TestScript
            $testScript = ($testScript) | ForEach-Object{$_.replace('SQLInstanceName',$sqlInstanceName).replace('HostName',$hostName).replace('SQLConnectionName',$sqlConnectionName)}

            $getScript = $rule.GetScript
            $getScript = ($getScript) | ForEach-Object{$_.replace('SQLInstanceName',$sqlInstanceName).replace('HostName',$hostName).replace('SQLConnectionName',$sqlConnectionName)}

            Script (Get-ResourceTitle -Rule $rule)
            {
                GetScript       = $getScript
                TestScript      = $testScript
                SetScript       = $setScript
            }
        }
        Catch
        {
            $errorMessage = $_.Exception.Message
            Write-Verbose $errorMessage
        }
    }
}
