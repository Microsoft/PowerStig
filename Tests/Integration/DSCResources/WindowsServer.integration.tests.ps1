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

        Describe "Windows $($stig.TechnologyVersion) $($stig.TechnologyRole) $($stig.StigVersion) mof output" {

            It 'Should compile the MOF without throwing' {
                {
                    & "$($script:DSCCompositeResourceName)_config" `
                        -OsVersion $stig.TechnologyVersion  `
                        -OsRole $stig.TechnologyRole `
                        -StigVersion $stig.StigVersion `
                        -ForestName 'integration.test' `
                        -DomainName 'integration.test' `
                        -OutputPath $TestDrive
                } | Should -Not -Throw
            }

            $configurationDocumentPath = "$TestDrive\localhost.mof"

            $instances = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($configurationDocumentPath, 4)

            Context 'AuditPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AuditPolicyRule.Rule
                $dscMof = $instances |
                Where-Object {$PSItem.ResourceID -match "\[AuditPolicySubcategory\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing Audit Policy Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Audit Policy settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Permissions' {
                $hasAllSettings = $true
                <#
                    https://github.com/Microsoft/PowerStigDsc/issues/1
                    Once the Composite is updated to configure ActiveDirectoryAuditRuleEntry,
                    remove '-and $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"' from the
                    following where cmdlet
                #>
                $dscXmlPermissionPolicy = $dscXml.DISASTIG.PermissionRule.Rule |
                    Where-Object { $PSItem.conversionstatus -eq 'pass' -and
                                   $PSItem.dscResource -ne "ActiveDirectoryAuditRuleEntry"}
                $dscMofPermissionPolicy = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[NTFSAccessEntry\]|\[RegistryAccessEntry\]"}

                foreach ($setting in $dscXmlPermissionPolicy)
                {
                    If (-not ($dscMofPermissionPolicy.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing permission setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXmlPermissionPolicy.count) permission settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Registry' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.RegistryRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xRegistry\]" -or $PSItem.ResourceID -match "\[cAdministrativeTemplateSetting\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing registry Setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) Registry settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'WMI' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WmiRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[script\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing wmi setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) wmi settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Services' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.ServiceRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[xService\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing service setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) service settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'AccountPolicy' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.AccountPolicyRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[AccountPolicy\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) security settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'UserRightsAssignment' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.UserRightRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[UserRightsAssignment\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing user right $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) user rights settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'SecurityOption' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.SecurityOptionRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[SecurityOption\]"}

                foreach ( $setting in $dscXml )
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing security setting $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) security settings" {
                    $hasAllSettings | Should -Be $true
                }
            }

            Context 'Windows Feature' {
                $hasAllSettings = $true
                $dscXml = $dscXml.DISASTIG.WindowsFeatureRule.Rule
                $dscMof = $instances |
                    Where-Object {$PSItem.ResourceID -match "\[WindowsFeature\]"}

                foreach ($setting in $dscXml)
                {
                    If (-not ($dscMof.ResourceID -match $setting.id) )
                    {
                        Write-Warning -Message "Missing windows feature $($setting.id)"
                        $hasAllSettings = $false
                    }
                }

                It "Should have $($dscXml.count) windows feature settings" {
                    $hasAllSettings | Should -Be $true
                }
            }
        }
        #### Begin DO NOT REMOVE Core Tests
        $technologyConfig = "$($script:DSCCompositeResourceName)_config"

        $skipRule = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
        $skipRuleType = "AuditPolicyRule"
        $expectedSkipRuleTypeCount = $dscXml.DISASTIG.AuditPolicyRule.ChildNodes.Count

        $skipRuleMultiple = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2
        $skipRuleTypeMultiple = @('AuditPolicyRule','AccountPolicyRule')
        $expectedSkipRuleTypeMultipleCount = $dscXml.DISASTIG.AuditPolicyRule.ChildNodes.Count + $dscXml.DISASTIG.AccountPolicyRule.ChildNodes.Count

        $exception = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id
        $exceptionMultiple = Get-Random -InputObject $dscXml.DISASTIG.RegistryRule.Rule.id -Count 2

        $userSettingsPath = "$PSScriptRoot\stigdata.usersettings.ps1"
        . $userSettingsPath
        ### End DO NOT REMOVE Core Tests
    }
    #endregion Tests
}
finally
{
    Restore-TestEnvironment -TestEnvironment $TestEnvironment
}
