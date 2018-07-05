using module .\..\..\..\..\Public\Class\Stig.StigProperty.psm1
#region Header
. $PSScriptRoot\.Stig.Test.Header.ps1
#endregion

$StigPropertyTest = @{
    'ValueData' = '2';
    'Identity' = 'Administrators,Local Service'
}

Describe "StigProperty Class" {

    Context "Constructor" {

        It "Should create an StigProperty class instance using StigProperty1 data" {
            foreach ($property in $StigPropertyTest.GetEnumerator())
            {
                $stigProperty = [StigProperty]::new($property.Key, $property.Value)
                $stigProperty.Name | Should Be $property.Key
                $stigProperty.Value | Should Be $property.Value
            }
        }
    }
}
