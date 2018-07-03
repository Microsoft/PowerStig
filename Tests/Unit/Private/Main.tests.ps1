#region HEADER
$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)))
$script:moduleName = $MyInvocation.MyCommand.Name -replace '\.tests\.ps1', '.psm1'
$script:modulePath = "$($script:moduleRoot)$(($PSScriptRoot -split 'Unit')[1])\$script:moduleName"
if ( (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))) -or `
     (-not (Test-Path -Path (Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests\TestHelper.psm1'))) )
{
    & git @('clone','https://github.com/Microsoft/PowerStig.Tests',(Join-Path -Path $script:moduleRoot -ChildPath 'PowerStig.Tests'))
}
Import-Module -Name (Join-Path -Path $script:moduleRoot -ChildPath (Join-Path -Path 'PowerStig.Tests' -ChildPath 'TestHelper.psm1')) -Force
Import-Module $modulePath -Force
#endregion
#region Test Setup
$StigGroups = '<?xml version="1.0" encoding="utf-8"?>
<Group id="V-1000">
<title>Rule Title</title>
    <Rule id="SV-1000r2_rule" severity="high" weight="10.0">
    <check>
    <check-content>{0}</check-content>
    </check>
    </Rule>
</Group>'
#endregion
#region Tests
Describe "Get-StigRules" {

    <#
        Set all of the test function to false to be inherited into each context and then set
        the required test function to true in each context.
    #>
    It "Verifies the function 'Get-StigRules' exists" {
        Get-Command -Name Get-StigRules | Should Not BeNullOrEmpty
    }
}
#endregion

