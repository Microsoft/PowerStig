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
        [xml] $dscXml = Get-Content -Path $stig.Path
        
        Describe " $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $stig.stigVersion `
                        -OutputPath $TestDrive
                } | Should not throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'FileContentRule' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.FileContentRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[ReplaceText\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.Id) )
                    {
                        Write-Warning -Message "Missing FileContent Setting $($setting.Id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.Count) FileContent settings" {
                    $hasAllSettings | Should Be $true
                }
            }
        }

        Describe " $($stig.TechnologyRole) $($stig.StigVersion) Single SkipRule mof output" {

            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $stig.StigVersion `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                        -OutputPath $TestDrive
                } | Should not throw
            }       
 
            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion

            Context 'Skip check' {

                #region counts how many Skips there are and how many there should be.
                $dscXml = $($SkipRule.Count)
                [array] $dscMof = $instances | Where-Object {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion

                It "Should have $dscXml Skipped settings" {
                    $dscMof.count | Should Be $dscXml
                }
            }
        }

        Describe " $($stig.TechnologyRole) $($stig.StigVersion) Multiple SkipRule mof output" {
            
            $SkipRule = Get-Random -InputObject $dscXml.DISASTIG.FileContentRule.Rule.id -Count 2
            
            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -StigVersion $stig.StigVersion `
                        -SkipRule $SkipRule `
                        -SkipRuleType $SkipRuleType `
                        -OutputPath $TestDrive
                } | Should not throw
            }
            
            #region Gets the mof content
            $configurationDocumentPath = "$TestDrive\localhost.mof"
            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)
            #endregion
           
            Context 'Skip check' {
                
                #region counts how many Skips there are and how many there should be.
                $expectedSkipRuleCount = ($($SkipRule.Count))
                $dscMof = $instances | Where-Object -FilterScript {$PSItem.ResourceID -match "\[Skip\]"}
                #endregion
                
                It "Should have $expectedSkipRuleCount Skipped settings" {
                    $dscMof.count | Should Be $expectedSkipRuleCount
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
