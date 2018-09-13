#region Header
using module .\..\..\..\Module\Common\Common.psm1
using module .\..\..\..\Module\Stig.TechnologyRole\Stig.TechnologyRole.psm1
using module .\..\..\..\Module\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $technologyRole1 = 'DNS'
        $technologyRole2 = 'ADDomain'
        $technologyRole3 = 'Instance'

        $Technology1 = [Technology]::Windows
        $Technology2 = [Technology]::SqlServer

        $technologyVersion1 = [TechnologyVersion]::new('2012R2', $Technology1)
        $technologyVersion2 = [TechnologyVersion]::new('All', $Technology1)
        $technologyVersion3 = [TechnologyVersion]::new('2012', $Technology2)

        $TestValidateSet = @"
2012R2 = DNS, DC, MS, IISSite, IISServer
All = ADDomain, ADForest, FW, IE11, DotNet4, Outlook2013, Excel2013
2012 = Instance, Database
"@

        $TestValidSetData = ConvertFrom-StringData -StringData $TestValidateSet

        $InvalidName = 'Cheeseburger'
        #endregion
        #region Class Tests
        Describe "technologyRole Class" {

            Context "Constructor" {
                It "Should create an technologyRole class instance using technologyRole1 and technologyVersion1 data" {
                    $technologyRole = [technologyRole]::new($technologyRole1, $technologyVersion1)
                    $technologyRole.Name | Should Be $technologyRole1
                    $technologyRole.TechnologyVersion | Should Be $technologyVersion1
                }

                It "Should create an technologyRole class instance using technologyRole2 and technologyVersion2 data" {
                    $technologyRole = [technologyRole]::new($technologyRole2, $technologyVersion2)
                    $technologyRole.Name | Should Be $technologyRole2
                    $technologyRole.TechnologyVersion | Should Be $technologyVersion2
                }

                It "Should create an technologyRole class instance using technologyRole3 and technologyVersion3 data" {
                    $technologyRole = [technologyRole]::new($technologyRole3, $technologyVersion3)
                    $technologyRole.Name | Should Be $technologyRole3
                    $technologyRole.TechnologyVersion | Should Be $technologyVersion3
                }

                It "Should throw an exception for technologyRole not being available for TechnologyVersion: 2012R2 -> ADDomain" {
                    { [technologyRole]::new($technologyRole1, $technologyVersion2) } | Should Throw
                }

                It "Should throw an exception for technologyRole not being available for TechnologyVersion: All -> DNS" {
                    { [technologyRole]::new($technologyRole2, $technologyVersion1) } | Should Throw
                }

                It "Should throw an exception for technologyRole not being available for TechnologyVersion: 2012R2 -> DNS" {
                    { [technologyRole]::new($technologyRole2, $technologyVersion3) } | Should Throw
                }
            }

            Context "Static Properties" {
                It "ValidateSet: Should match TestValidateSet to static ValidateSet property" {
                    [technologyRole]::ValidateSet | Should Be $TestValidateSet
                }
            }

            Context "Instance Methods" {
                It "Validate: Should be able to validate a technologyRole. Valid property config." {
                    $technologyRole = [technologyRole]::new()
                    $technologyRole.Name = $technologyRole1
                    $technologyRole.TechnologyVersion = $technologyVersion1
                    $technologyRole.Validate() | Should Be $true
                }

                It "Validate: Should be able to validate a technologyRole. Invalid property config." {
                    $technologyRole = [technologyRole]::new()
                    $technologyRole.Name = $technologyRole1
                    $technologyRole.TechnologyVersion = $technologyVersion2
                    $technologyRole.Validate() | Should Be $false
                }
            }

            Context "Static Methods" {
                It "Available: Should be able to return available roles. Valid TechnologyVersion parameter." {
                    $ValidVersion = $technologyVersion1.Name
                    [technologyRole]::Available($ValidVersion) | Should Be $TestValidSetData.$ValidVersion.Split(',').Trim()
                }

                It "Available: Should throw an exception that no roles are available for an unsupported version." {
                    { [technologyRole]::Available($InvalidName) } | Should Throw
                }
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
