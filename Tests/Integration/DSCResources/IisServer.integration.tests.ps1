$script:DSCCompositeResourceName = ($MyInvocation.MyCommand.Name -split '\.')[0]
. $PSScriptRoot\.tests.header.ps1
# Header

# Using try/finally to always cleanup even if something awful happens.
try
{
    #region Integration Tests
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:DSCCompositeResourceName).config.ps1"
    . $configFile

    $stigList = Get-StigVersionTable -CompositeResourceName $script:DSCCompositeResourceName

    #region Integration Tests
    foreach ($stig in $stigList)
    {
        Describe "IIS Server $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion `
                        -StigVersion $stig.StigVersion `
                        -LogPath $TestDrive `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            [xml] $dscXml = Get-Content -Path $stig.Path

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'IisLoggingRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.IisLoggingRule.Rule
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[xIisLogging\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing IisLoggingRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) IisLoggingRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }

            Context 'WebConfigurationPropertyRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WebConfigurationPropertyRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xWebConfigProperty\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing WebConfigurationPropertyRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }


                It "Should have $($dscXml.Count) WebConfigurationPropertyRule settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'MimeTypeRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.MimeTypeRule.Rule
                $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[xIisMimeTypeMapping\]"}

                foreach ($setting in $dscXml)
                {
                    if (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "WebServer missing MimeTypeRule Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) MimeTypeRule settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }
    }
}
#endregion Tests
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
