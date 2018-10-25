#region Header
using module .\..\..\..\Module\Stig.OrganizationalSetting\Stig.OrganizationalSetting.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        [xml] $OrgSettingXml = @"
<OrganizationalSettings version="2.9">
<OrganizationalSetting id="V-1114" value="xGuest" />
<OrganizationalSetting id="V-1115" value="xAdministrator" />
<OrganizationalSetting id="V-3472.a" value="NT5DS" />
<OrganizationalSetting id="V-4108" value="90" />
<OrganizationalSetting id="V-4113" value="300000" />
<OrganizationalSetting id="V-8322.b" value="NT5DS" />
<OrganizationalSetting id="V-26482" value="Administrators" />
<OrganizationalSetting id="V-26579" value="32768" />
<OrganizationalSetting id="V-26580" value="196608" />
<OrganizationalSetting id="V-26581" value="32768" />
</OrganizationalSettings>
"@

        [hashtable] $OrgSettingHashtable = @{
            "V-1114"   = "xGuest";
            "V-1115"   = "xAdministrator";
            "V-3472.a" = "NT5DS";
            "V-4108"   = "90";
            "V-4113"   = "300000";
            "V-8322.b" = "NT5DS";
            "V-26482"  = "Administrators";
            "V-26579"  = "32768";
            "V-26580"  = "196608";
            "V-26581"  = "32768"
        }
        #endregion
        #region Class Tests
        Describe 'OrganizationalSetting Class' {

            Context 'Constructor' {

                It 'Should create an OrganizationalSetting class instance using OrgSettingHashtable data' {
                    foreach ($hash in $OrgSettingHashtable.GetEnumerator())
                    {
                        $newOrgSetting = [OrganizationalSetting]::new($hash.Key, $hash.Value)
                        $newOrgSetting.StigRuleId | Should Be $hash.Key
                        $newOrgSetting.Value | Should Be $hash.Value
                    }
                }
            }

            Context 'Static Methods' {
                It 'ConvertFrom: Should be able to convert an Xml document to a OrganizationalSetting array' {
                    $orgSettingArray = [OrganizationalSetting]::ConvertFrom($OrgSettingXml)

                    foreach ($node in $OrgSettingXml.OrganizationalSettings.ChildNodes)
                    {
                        $orgSetting = $orgSettingArray.Where( {$_.StigRuleId -eq $node.id})
                        $orgSetting.StigRuleId | Should Be $node.id
                        $orgSetting.Value | Should Be $node.value
                    }
                }

                It 'ConvertFrom: Should be able to convert a Hashtable to a OrganizationalSetting array' {
                    $orgSettingArray = [OrganizationalSetting]::ConvertFrom($OrgSettingHashtable)

                    foreach ($hash in $OrgSettingHashtable.GetEnumerator())
                    {
                        $orgSetting = $orgSettingArray.Where( {$_.StigRuleId -eq $hash.Key})
                        $orgSetting.StigRuleId | Should Be $hash.Key
                        $orgSetting.Value | Should Be $hash.Value
                    }
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-PropertyMap' {

            It 'Should return the local $PropertyMap variable hashtable' {
                (Get-PropertyMap).GetType() | Should Be 'hashtable'
            }
        }
        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
