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
        $TechnologyVersion1 = 'All'
        $TechnologyVersion2 = '2016'
        $TechnologyVersion3 = '2012R2'
        $TechnologyVersion4 = '10'
        $TechnologyVersion5 = 'Server2012'

        $Technology1 = [Technology]::Windows
        $Technology2 = [Technology]::SQL

        $TestValidateSet = @"
Windows = All, 2016, 2012R2, 10
SQL = Server2012
"@

        $TestValidSetData = ConvertFrom-StringData -StringData $TestValidateSet

        $InvalidName = 'groundChuck'
        #endregion
        #region Class Tests
        Describe "TechnologyVersion Class" {

            Context "Constructor" {

                It "Should create a TechnologyVersion class instance using Technology1 and TechnologyVersion1 data" {
                    $TechnologyVersion = [TechnologyVersion]::new($TechnologyVersion1, $Technology1)
                    $TechnologyVersion.Name | Should Be $TechnologyVersion1
                    $TechnologyVersion.Technology | Should Be $Technology1
                }

                It "Should create a TechnologyVersion class instance using Technology1 and TechnologyVersion2 data" {
                    $TechnologyVersion = [TechnologyVersion]::new($TechnologyVersion2, $Technology1)
                    $TechnologyVersion.Name | Should Be $TechnologyVersion2
                    $TechnologyVersion.Technology | Should Be $Technology1
                }

                It "Should create a TechnologyVersion class instance using Technology1 and TechnologyVersion3 data" {
                    $TechnologyVersion = [TechnologyVersion]::new($TechnologyVersion3, $Technology1)
                    $TechnologyVersion.Name | Should Be $TechnologyVersion3
                    $TechnologyVersion.Technology | Should Be $Technology1
                }

                It "Should create a TechnologyVersion class instance using Technology1 and TechnologyVersion4 data" {
                    $TechnologyVersion = [TechnologyVersion]::new($TechnologyVersion4, $Technology1)
                    $TechnologyVersion.Name | Should Be $TechnologyVersion4
                    $TechnologyVersion.Technology | Should Be $Technology1
                }

                It "Should create a TechnologyVersion class instance using Technology2 and TechnologyVersion5 data" {
                    $TechnologyVersion = [TechnologyVersion]::new($TechnologyVersion5, $Technology2)
                    $TechnologyVersion.Name | Should Be $TechnologyVersion5
                    $TechnologyVersion.Technology | Should Be $Technology2
                }

                It "Should throw an exception for TechnologyRole not being available for TechnologyVersion: Windows -> Cheeseburger" {
                    { [TechnologyVersion]::new($InvalidName, $Technology1) } | Should Throw
                }
            }

            Context "Static Properties" {
                It "ValidateSet: Should match TestValidateSet to static ValidateSet property" {
                    [TechnologyVersion]::ValidateSet | Should Be $TestValidateSet
                }
            }

            Context "Instance Methods" {
                It "Validate: Should be able to validate a TechnologyVersion. Valid property config." {
                    $TechnologyVersion = [TechnologyVersion]::new()
                    $TechnologyVersion.Name = $TechnologyVersion1
                    $TechnologyVersion.Technology = $Technology1
                    $TechnologyVersion.Validate() | Should Be $true
                }

                It "Validate: Should be able to validate a TechnologyVersion. Invalid property config." {
                    $TechnologyVersion = [TechnologyVersion]::new()
                    $TechnologyVersion.Name = $InvalidName
                    $TechnologyVersion.Technology = $Technology1
                    $TechnologyVersion.Validate() | Should Be $false
                }
            }

            Context "Static Methods" {
                It "Available: Should be able to return available roles. Valid TechnologyVersion parameter." {
                    $ValidVersion = $Technology1.ToString()
                    [TechnologyVersion]::Available($ValidVersion) | Should Be $TestValidSetData.$ValidVersion.Split(',').Trim()
                }

                It "Available: Should throw an exception that no roles are available for an unsupported version." {
                    $InvalidTechnology = $InvalidName
                    { [TechnologyVersion]::Available($InvalidTechnology) } | Should Throw
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
