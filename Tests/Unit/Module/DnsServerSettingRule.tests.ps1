#region Header
using module .\..\..\..\Module\Rule.DnsServerSetting\Convert\DnsServerSettingRule.Convert.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName "$($script:moduleName).Convert" {
        #region Test Setup
        $rulesToTest = @(
            @{
                PropertyName = 'EventLogLevel'
                PropertyValue = '4'
                CheckContent = 'Log on to the DNS server using the Domain Admin or Enterprise Admin account.

        Press Windows Key + R, execute dnsmgmt.msc.

        Right-click the DNS server, select “Properties”.

        Click on the “Event Logging” tab. By default, all events are logged.

        Verify "Errors and warnings" or "All events" is selected.

        If any option other than "Errors and warnings" or "All events" is selected, this is a finding.'
            }
        )

        $stigRule = Get-TestStigRule -ReturnGroupOnly
        $rule = [DnsServerSettingRuleConvert]::new( $stigRule )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {

                It 'Shoud have a BaseType of STIG' {
                    $rule.GetType().BaseType.ToString() | Should Be 'DnsServerSettingRule'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('PropertyName', 'PropertyValue')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-DnsServerSettingProperty' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.PropertyName)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-DnsServerSettingProperty -CheckContent $checkContent | Should Be $rule.PropertyName
                }
            }
        }

        Describe 'Get-DnsServerSettingPropertyValue' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.PropertyValue)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    Get-DnsServerSettingPropertyValue -CheckContent $checkContent | Should Be $rule.PropertyValue
                }
            }
        }
        #endregion

        <#{TODO}#> <#Rem structural tests. This is testing a specific variable name
        and can be moved to the $rulesToTest above#>
        <#region Function Tests
        Describe 'Private DnsServerSetting Rule tests' {

            # Regular expression tests
            Context 'Dns Stig Rules regex tests' {

                [string] $text = 'the          forwarders     tab.'
                $result = ($text |
                        Select-String $regularExpression.textBetweenTheTab -AllMatches |
                        Select-Object Matches).Matches.Groups[1]
                It 'Should match text inside of the words "the" and "tab"' {
                    $result.Success | Should be $true
                }
                It 'Should return text between the words "the" and "tab"' {
                    $result.Value.trim() | Should Be 'forwarders'
                }

                [string] $text = ' âForwardersâ'
                It 'Should match any non letter characters' {
                    $result = $text -match $regularExpression.nonLetters
                    $result | Should Be $true
                }
                It 'Should remove the non word characters' {
                    $result = $text -replace $regularExpression.nonLetters
                    $result.Trim() | Should Be 'Forwarders'
                }
            }
        }

        #endregion

        #region Data Tests

        #endregion #>
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
