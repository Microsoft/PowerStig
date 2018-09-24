$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests$
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Integration Tests
    foreach ($stig in $stigList)
    {
        Describe "Office $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

        It 'Should compile the MOF without throwing' {
            {
                & "$($script:DSCCompositeResourceName)_config" `
                -OfficeApp $stig.TechnologyRole `
                -StigVersion $stig.stigVersion `
                -OutputPath $TestDrive
            } | Should Not throw
        }

        [xml] $dscXml = Get-Content -Path $stig.Path

        $configurationDocumentPath = "$TestDrive\localhost.mof"

        $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

        Context 'Registry' {
            $hasAllSettings = $true
            $dscXml = @($dscXml.DISASTIG.RegistryRule.Rule)
            $dscMof = $instances |
                Where-Object {$PSItem.ResourceID -match "\[xRegistry\]" -or $PSItem.ResourceID -match "\[cAdministrativeTemplateSetting\]"}

            foreach ($setting in $dscXml)
            {
                if (-not ($dscMof.ResourceID -match $setting.Id) )
                {
                    Write-Warning -Message "Missing registry Setting $($setting.Id)"
                    $hasAllSettings = $false
                }
            }

            It "Should have $($dscXml.Count) Registry settings" {
                $hasAllSettings | Should Be $true
            }
        }
    }
}
#endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
