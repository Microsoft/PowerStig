using module .\helper.psm1

$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1

$configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
. $configFile

$stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName
$resourceInformation = $global:getDscResource | Where-Object -FilterScript {$PSItem.Name -eq $script:DSCCompositeResourceName}
$resourceParameters = $resourceInformation.Properties.Name

$password = ConvertTo-SecureString -AsPlainText -Force -String 'ThisIsAPlaintextPassword'
$setupAccount = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList 'Admin', $password

$webAppUrl = 'https://sharePoint.contoso.com','http://partner.contoso.com'

$additionalTestParameterList = @{
    ConfigurationData = @{
        AllNodes = @(
            @{
                NodeName = 'localhost'
                PSDscAllowDomainUser = $true
                PSDscAllowPlainTextPassword = $true
            }
        )
    }
    WebAppUrl = $webAppUrl
    SetupAccount = $setupAccount
}

foreach ($stig in $stigList)
{
    $orgSettingsPath = $stig.Path.Replace('.xml', '.org.default.xml')
    $blankSkipRuleId = Get-BlankOrgSettingRuleId -OrgSettingPath $orgSettingsPath
    $powerstigXml = [xml](Get-Content -Path $stig.Path) | Remove-DscResourceEqualsNone | Remove-SkipRuleBlankOrgSetting -OrgSettingPath $orgSettingsPath

    $skipRule = Get-Random -InputObject $powerstigXml.SPWebAppGeneralSettingsRule.Rule.id
    $skipRuleType = "SPWebAppGeneralSettingsRule"
    $expectedSkipRuleTypeCount = $powerstigXml.SPWebAppGeneralSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $skipRuleMultiple = Get-Random -InputObject $powerstigXml.SPWebAppGeneralSettingsRule.Rule.id -Count 2
    $skipRuleTypeMultiple = @('SPWebAppGeneralSettingsRule')
    $expectedSkipRuleTypeMultipleCount = $powerstigXml.SPWebAppGeneralSettingsRule.Rule.Count + $blankSkipRuleId.Count

    $singleSkipRuleSeverity = 'CAT_I'
    $multipleSkipRuleSeverity = 'CAT_I', 'CAT_II'
    $expectedSingleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $singleSkipRuleSeverity
    $expectedSingleSkipRuleSeverityCount = ($expectedSingleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count
    $expectedMultipleSkipRuleSeverity = Get-CategoryRule -PowerStigXml $powerstigXml -RuleCategory $multipleSkipRuleSeverity
    $expectedMultipleSkipRuleSeverityCount = ($expectedMultipleSkipRuleSeverity | Measure-Object).Count + $blankSkipRuleId.Count

    $getRandomExceptionRuleParams = @{
        RuleType        = 'SPWebAppGeneralSettingsRule'
        PowerStigXml    = $powerstigXml
        ParameterValue  = "Strict"
    }
    . "$PSScriptRoot\Common.integration.ps1"
}
