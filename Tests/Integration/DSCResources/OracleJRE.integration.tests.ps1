using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    $additionalTestParameterList = @{
        configPath = 'C:\Windows\Sun\Java\Deployment\deployment.config'
        propertiesPath = 'C:\Windows\Java\Deployment\deployment.properties'
    }

    foreach ($stig in $stigList)
    {
        $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone

        $skipRule = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id
        $skipRuleType = $null
        $expectedSkipRuleTypeCount = 0

        $skipRuleMultiple = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id -Count 2
        $skipRuleTypeMultiple = $null
        $expectedSkipRuleTypeMultipleCount = 0

        $exception = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $powerstigXml.FileContentRule.Rule.id -Count 2

        . "$PSScriptRoot\Common.integration.ps1"
    }
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
