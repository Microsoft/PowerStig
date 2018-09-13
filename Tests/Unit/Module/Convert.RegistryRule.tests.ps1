#region Header
using module .\..\..\..\Module\Convert.RegistryRule\Convert.RegistryRule.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $rulesToTest = @(
            @{
                Hive                        = 'HKEY_LOCAL_MACHINE'
                Path                        = '\Software\Policies\Microsoft\WindowsMediaPlayer'
                OrganizationValueRequired   = 'False'
                OrganizationValueTestString = ''
                ValueData                   = '1'
                ValueName                   = 'GroupPrivacyAcceptance'
                ValueType                   = 'DWORD'
                CheckContent                = 'Windows Media Player is not installed by default.  If it is not installed, this is NA.

                        If the following registry value does not exist or is not configured as specified, this is a finding:

                        Registry Hive: HKEY_LOCAL_MACHINE
                        Registry Path: \Software\Policies\Microsoft\WindowsMediaPlayer\

                        Value Name: GroupPrivacyAcceptance

                        Type: REG_DWORD
                        Value: 1'
            },
            @{
                Hive                        = 'HKEY_LOCAL_MACHINE'
                Path                        = '\System\CurrentControlSet\Services\W32Time\Config'
                OrganizationValueRequired   = 'True'
                OrganizationValueTestString = "{0} -match '2|3'"
                ValueData                   = ''
                ValueName                   = 'EventLogFlags'
                ValueType                   = 'DWORD'
                CheckContent                = 'Verify logging is configured to capture time source switches.

                        If the Windows Time Service is used, verify the following registry value.  If it is not configured as specified, this is a finding.

                        Registry Hive: HKEY_LOCAL_MACHINE
                        Registry Path: \System\CurrentControlSet\Services\W32Time\Config\

                        Value Name: EventLogFlags

                        Type: REG_DWORD
                        Value: 2 or 3

                        If another time synchronization tool is used, review the available configuration options and logs.  If the tool has time source logging capability and it is not enabled, this is a finding.'
            },
            @{
                Hive                        = 'HKEY_LOCAL_MACHINE'
                Path                        = '\System\CurrentControlSet\Control\Session Manager\Subsystems'
                OrganizationValueRequired   = 'False'
                OrganizationValueTestString = ''
                ValueData                   = ''
                ValueName                   = 'Optional'
                ValueType                   = 'MultiString'
                CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                        Registry Hive: HKEY_LOCAL_MACHINE
                        Registry Path: \System\CurrentControlSet\Control\Session Manager\Subsystems\

                        Value Name: Optional

                        Value Type: REG_MULTI_SZ
                        Value: (Blank)'
            },
            @{
                Hive                        = 'HKEY_LOCAL_MACHINE'
                Path                        = '\Software\Microsoft\Windows NT\CurrentVersion\Winlogon'
                OrganizationValueRequired   = 'True'
                OrganizationValueTestString = "{0} -le '5'"
                ValueData                   = ''
                ValueName                   = 'ScreenSaverGracePeriod'
                ValueType                   = 'String'
                CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                        Registry Hive: HKEY_LOCAL_MACHINE
                        Registry Path: \Software\Microsoft\Windows NT\CurrentVersion\Winlogon\

                        Value Name: ScreenSaverGracePeriod

                        Value Type: REG_SZ
                        Value: 5 (or less)'
            },
            @{
                Hive                        = 'HKEY_LOCAL_MACHINE'
                Path                        = '\System\CurrentControlSet\Control\Lsa\MSV1_0'
                OrganizationValueRequired   = 'False'
                OrganizationValueTestString = ''
                ValueData                   = '537395200'
                ValueName                   = 'NTLMMinServerSec'
                ValueType                   = 'DWORD'
                CheckContent                = 'If the following registry value does not exist or is not configured as specified, this is a finding:

                        Registry Hive: HKEY_LOCAL_MACHINE
                        Registry Path: \System\CurrentControlSet\Control\Lsa\MSV1_0\

                        Value Name: NTLMMinServerSec

                        Value Type: REG_DWORD
                        Value: 0x20080000 (537395200)'
            },
            @{
                Hive                      = 'HKEY_LOCAL_MACHINE'
                Path                      = '\SYSTEM\CurrentControlSet\Control\Lsa'
                OrganizationValueRequired = 'False'
                ValueName                 = 'RestrictRemoteSAM'
                ValueData                 = 'O:BAG:BAD:(A;;RC;;;BA)'
                ValueType                 = 'String'
                CheckContent              = 'This is NA prior to v1607 of Windows 10.

                                            If the following registry value does not exist or is not configured as specified, this is a finding:

                                            Registry Hive: HKEY_LOCAL_MACHINE
                                            Registry Path: \SYSTEM\CurrentControlSet\Control\Lsa\

                                            Value Name: RestrictRemoteSAM

                                            Value Type: REG_SZ
                                            Value: O:BAG:BAD:(A;;RC;;;BA)'
            },
            @{
                Hive                      = 'HKEY_LOCAL_MACHINE'
                Path                      = '\SOFTWARE\Classes\batfile\shell\runasuser', '\SOFTWARE\Classes\cmdfile\shell\runasuser', '\SOFTWARE\Classes\exefile\shell\runasuser', '\SOFTWARE\Classes\mscfile\shell\runasuser'
                OrganizationValueRequired = 'False'
                ValueName                 = 'SuppressionPolicy'
                ValueData                 = '4096'
                ValueType                 = 'Dword'
                CheckContent              = 'If the following registry values do not exist or are not configured as specified, this
                                            is a finding.
                                            The policy configures the same Value Name, Type and Value under four different registry
                                            paths.

                                            Registry Hive:  HKEY_LOCAL_MACHINE
                                            Registry Paths:
                                            \SOFTWARE\Classes\batfile\shell\runasuser\
                                            \SOFTWARE\Classes\cmdfile\shell\runasuser\
                                            \SOFTWARE\Classes\exefile\shell\runasuser\
                                            \SOFTWARE\Classes\mscfile\shell\runasuser\

                                            Value Name:  SuppressionPolicy

                                            Type:  REG_DWORD
                                            Value:  0x00001000 (4096)'
            },
            @{
                Hive                      = 'HKEY_CURRENT_USER'
                Path                      = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments'
                OrganizationValueRequired = 'False'
                ValueName                 = 'SaveZoneInformation'
                ValueData                 = '2'
                ValueType                 = 'Dword'
                CheckContent              = 'The default behavior is for Windows to mark file attachments with their zone information.

                If the registry Value Name below does not exist, this is not a finding.

                If it exists and is configured with a value of "2", this is not a finding.

                If it exists and is configured with a value of "1", this is a finding.

                Registry Hive: HKEY_CURRENT_USER
                Registry Path: \SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Attachments\

                Value Name: SaveZoneInformation

                Value Type: REG_DWORD
                Value: 0x00000002 (2) (or if the Value Name does not exist)'
            }
        )
        $rule = [RegistryRule]::new( (Get-TestStigRule -ReturnGroupOnly) )
        #endregion
        #region Class Tests
        Describe "$($rule.GetType().Name) Child Class" {

            Context 'Base Class' {
                It "Shoud have a BaseType of STIG" {
                    $rule.GetType().BaseType.ToString() | Should Be 'STIG'
                }
            }

            Context 'Class Properties' {

                $classProperties = @('Key', 'ValueName', 'ValueData', 'ValueType', 'Ensure')

                foreach ( $property in $classProperties )
                {
                    It "Should have a property named '$property'" {
                        ( $rule | Get-Member -Name $property ).Name | Should Be $property
                    }
                }
            }

            Context 'Class Methods' {

                $classMethods = @('FormatMultiStringRegistryData',
                    'GetIntegerFromHex', 'GetNumberFromString', 'GetMultiValueRegistryStringData',
                    'GetValidEnabledOrDisabled', 'IsDataBlank', 'IsDataEnabledOrDisabled', 'IsDataHexCode',
                    'IsDataInteger', 'SetEnsureFlag', 'SetKey', 'GetValueData', 'SetValueName',
                    'SetValueType', 'TestValueDataStringForRange')

                foreach ( $method in $classMethods )
                {
                    It "Should have a method named '$method'" {
                        ( $rule | Get-Member -Name $method ).Name | Should Be $method
                    }
                }

                # If new methods are added this will catch them so test coverage can be added
                It "Should not have more methods than are tested" {
                    $memberPlanned = Get-StigBaseMethods -ChildClassMethodNames $classMethods
                    $memberActual = ( $rule | Get-Member -MemberType Method ).Name
                    $compare = Compare-Object -ReferenceObject $memberActual -DifferenceObject $memberPlanned
                    $compare.Count | Should Be 0
                }
            }
        }
        #endregion
        #region Method Tests
        Describe 'Get-RegistryKey' {

            foreach ( $rule in $rulesToTest )
            {
                $expectedPaths = $rule.Path | Sort-Object -Descending
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryKey = Get-RegistryKey -CheckContent $checkContent

                foreach ($expectedPath in $expectedPaths)
                {
                    It "Should return '$($rule.Hive + $expectedPath)'" {
                        $result = $registryKey | Where-Object -FilterScript { $PSItem -like "*$expectedPath" }
                        $result | Should Be ($rule.Hive + $expectedPath)
                    }
                }

            }
        }

        Describe 'Get-RegistryValueType' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.ValueType)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $registryKey = Get-RegistryValueType -CheckContent $checkContent
                    $registryKey | Should Be ($rule.ValueType)
                }
            }
        }

        Describe 'Get-RegistryValueName' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.ValueName)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $registryKey = Get-RegistryValueName -CheckContent $checkContent
                    $registryKey | Should Be ($rule.ValueName)
                }
            }
        }

        Describe 'Get-RegistryValueData' {

            foreach ( $rule in $rulesToTest )
            {
                if ($rule.OrganizationValueRequired -eq 'False')
                {
                    It "Should return '$($rule.ValueData)'" {
                        $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                        $registryKey = Get-RegistryValueData -CheckContent $checkContent
                        $result = $registryKey -match "$($rule.ValueData)|Blank" -or $registryKey -eq $rule.ValueData
                        $result | Should Be $true
                    }
                }
            }
        }

        Describe 'Get-RegistryHiveFromWindowsStig' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.Hive)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $registryKey = Get-RegistryHiveFromWindowsStig -CheckContent $checkContent
                    $registryKey | Should Be ($rule.Hive)
                }
            }
        }

        Describe 'Get-RegistryPathFromWindowsStig' {

            foreach ( $rule in $rulesToTest )
            {
                It "Should return '$($rule.Path)'" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $registryKey = Get-RegistryPathFromWindowsStig -CheckContent $checkContent
                    foreach ( $key in $registryKey )
                    {
                        $key -in $rule.Path | Should Be $true
                    }
                }
            }
        }

        Describe 'Test-RegistryValueDataContainsRange' {

            Context 'Matches' {
                $rangeStrings = @(
                    'Value: 1 or 2 = a Finding',
                    'Value:  3 (or less)',
                    'Value: 300000 (or less)',
                    'Value: 30 (or less, but not 0)',
                    'Value: 0x000dbba0 (900000) or less but not 0',
                    'Value: 0x0000001e (30) (or less, but not 0)',
                    'Value: 0x0000001e (30) (or less, excluding 0)',
                    'Value: Possible values are NoSync,NTP,NT5DS, AllSync'
                )

                foreach ($string in $rangeStrings)
                {
                    It "Should return true when given '$string'" {
                        $containsRange = Test-RegistryValueDataContainsRange -ValueDataString $string
                        $containsRange | Should Be $true
                    }
                }
            }

            Context 'Non Matches' {
                $rangeStrings = @(
                    'Value: (Blank)',
                    'Value: Enabled',
                    'Value: Disabled',
                    'Value: 0x0000000a (10)',
                    'Value: 10',
                    'Value: 0x00000002 (2) (or if the Value Name does not exist)'
                )

                foreach ($string in $rangeStrings)
                {
                    It "Should return false when given '$string'" {
                        $containsRange = Test-RegistryValueDataContainsRange -ValueDataString $string
                        $containsRange | Should Be $false
                    }
                }
            }

            foreach ( $rule in $rulesToTest )
            {
                It "Should return the correct Org Setting required flag" {
                    $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                    $registryData = Get-RegistryValueData -CheckContent $checkContent
                    $registryKey = Test-RegistryValueDataContainsRange -ValueDataString ($registryData)
                    $registryKey | Should Be ($rule.OrganizationValueRequired)
                }
            }
        }

        Describe 'Test-RegistryValueDataIsBlank' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                if ($registryData -eq '(Blank)')
                {
                    $result = $true
                }
                else
                {
                    $result = $false
                }

                It "Should return '$($result)'" {
                    $registryKey = Test-RegistryValueDataIsBlank -ValueDataString ($registryData)
                    $registryKey | Should Be ($result)
                }
            }
        }

        Describe 'Test-IsValidDword' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                try
                {
                    [void] [System.Convert]::ToInt32( $registryData )
                    $result = $true
                }
                catch
                {
                    $result = $false
                }

                It "Should return '$($result)'" {
                    $registryKey = Test-IsValidDword -ValueData ($registryData)
                    $registryKey | Should Be ($result)
                }
            }
        }

        Describe 'Test-RegistryValueDataIsInteger' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                if ( $registryData -Match '\b([0-9]{1,})\b' )
                {
                    $result = $true
                }
                else
                {
                    $result = $false
                }

                It "Should return '$($result)'" {
                    $registryKey = Test-RegistryValueDataIsInteger -ValueDataString ($registryData)
                    $registryKey | Should Be ($result)
                }
            }
        }

        Describe 'Get-NumberFromString' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                if ( Test-RegistryValueDataIsInteger -ValueDataString ($registryData) )
                {
                    if ($rule.OrganizationValueRequired -eq 'False')
                    {
                        It "Should return '$($rule.ValueData)'" {
                            $registryKey = Get-NumberFromString -ValueDataString ($registryData)
                            $registryKey | Should Be ($rule.ValueData)
                        }
                    }
                }
                else
                {
                    It "Should throw if a number is not found" {
                        {Get-NumberFromString -ValueDataString ($registryData)} | Should Throw
                    }
                }
            }
        }

        Describe 'Test-RegistryValueDataIsHexCode' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                if ( $registryData -Match '\b(0x[A-Fa-f0-9]{8}){1}\b' )
                {
                    $result = $true
                }
                else
                {
                    $result = $false
                }

                It "Should return '$($result)'" {
                    $registryKey = Test-RegistryValueDataIsHexCode -ValueDataString ($registryData)
                    $registryKey | Should Be ($result)
                }
            }
        }

        Describe 'Get-IntegerFromHex' {

            foreach ( $rule in $rulesToTest )
            {
                $checkContent = Split-TestStrings -CheckContent $rule.CheckContent
                $registryData = Get-RegistryValueData -CheckContent $checkContent
                if ( Test-RegistryValueDataIsHexCode -ValueDataString ($registryData) )
                {
                    $result = $true
                }
                else
                {
                    $result = $false
                }

                if ($result)
                {
                    It "Should return '$($rule.ValueData)'" {
                        $registryKey = Get-IntegerFromHex -ValueDataString ($registryData)
                        $registryKey | Should Be ($rule.ValueData)
                    }
                }
                else
                {
                    It "Should return an error" {
                        {Get-IntegerFromHex -ValueDataString ($registryData)} | Should throw
                    }
                }
            }
        }
        #endregion
        #region Function Tests
        Describe 'ConvertTo-RegistryRule' {

            $stigRule = Get-TestStigRule -CheckContent $rulesToTest[0].checkContent -ReturnGroupOnly
            $rule = ConvertTo-RegistryRule -StigRule $stigRule

            It "Should return an RegistryRule object" {
                $rule.GetType() | Should Be 'RegistryRule'
            }
        }

        Describe "Get-RegistryKey" {

            Context 'Windows STIG' {

                $hive = "HKEY_LOCAL_MACHINE"
                $path = "\Path\To\Value"
                $checkContent = "Registry Hive: $hive`n" +
                "Registry Path:  $path"

                Mock Test-SingleLineRegistryRule {return $false} -Verifiable
                Mock Get-RegistryHiveFromWindowsStig {return $hive}
                Mock Get-RegistryPathFromWindowsStig {return $path}

                It 'Should return the correct path' {
                    $checkContent = Split-TestStrings -CheckContent $checkContent
                    $correctPath = Get-RegistryKey -CheckContent $checkContent
                    $correctPath | Should Be "$hive$path"
                    Assert-VerifiableMock
                }
            }

            Context 'Office STIG' {

                Mock Test-SingleLineRegistryRule {return $true} -Verifiable

                It 'Should return the correct HKCU path' {
                    $fullPath = "HKEY_CURRENT_USER\Path\To\Value"
                    $checkContent = ("",
                        "$fullPath",
                        "",
                        "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding.")
                    Mock Get-SingleLineRegistryPath {return $fullPath}
                    Get-RegistryKey -CheckContent $checkContent | Should Be $fullPath
                }
                It 'Should return the correct HKLM path' {
                    $fullPath = "HKEY_LOCAL_MACHINE\Path\To\Value"
                    $checkContent = ("",
                        "$fullPath",
                        "",
                        "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding.")
                    Mock Get-SingleLineRegistryPath {return $fullPath}
                    Get-RegistryKey -CheckContent $checkContent | Should Be $fullPath
                }
            }
        }

        Describe "Get-RegistryHiveFromWindowsStig" {

            $goodStrings = @(
                "Registry Hive:{0}", "Registry Hive: {0}",
                ' Registry Hive: {0}', ' Registry Hive:  {0}',
                'Hive:{0}', 'Hive: {0}', 'Hive:  {0}',
                ' Hive:{0}', ' Hive:{0}', ' Hive:  {0}'
            )

            foreach ($string in $goodStrings)
            {
                $hive = 'HKEY_LOCAL_MACHINE'
                $checkContent = $string -f $hive

                It " Should return '$hive' from '$checkContent'" {
                    Get-RegistryHiveFromWindowsStig -CheckContent $checkContent | Should Be $hive
                }
            }

            It " Should throw an error when a hive is not found" {
                $checkContent = "Registry Hive: HKEYLM \nRegistry Path: \Path" -split "\\n"
                {Get-RegistryHiveFromWindowsStig -CheckContent $checkContent} | Should Throw
            }
        }

        Describe "Get-RegistryPathFromWindowsStig" {

            # a list of invalid registry key formats to validate the regex
            $pathToExtract = 'SYSTEM\CurrentControlSet'
            $goodStrings = @(
                "Registry Path: \$pathToExtract\" , " Registry Path: $pathToExtract\",
                "Registry Path:  \$pathToExtract\", " Registry Path:  $pathToExtract\",
                "Path: \$pathToExtract\", " Path: $pathToExtract\", " Path:  $pathToExtract\",
                "Path: \$pathToExtract" , " Path: $pathToExtract" , " Path:  $pathToExtract",
                "Subkey: \$pathToExtract", " Subkey: $pathToExtract", " Subkey:  $pathToExtract")

            foreach ( $path in $goodStrings )
            {
                It "Should return '\$pathToExtract' from '$path'" {
                    Get-RegistryPathFromWindowsStig -CheckContent $path | Should Be "\$pathToExtract"
                }
            }
            # test for an edge case where the intern at DISA added a space between 'SOFTWARE\ Polices'

            It "Should return path with typo and formated correctly" {
                $typoString = 'Registry Path: \SOFTWARE\ Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
                $expected = '\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
                $result = Get-RegistryPathFromWindowsStig -CheckContent $typoString

                $result | Should Be $expected
            }
            #  Fuzz testing the regex
            $badStrings = @(
                'Registry Path: SYSTEM', 'Registry Path: \SYSTEM', 'Registry Path: \SYSTEM\',
                "Path: SYSTEM", " Path: SYSTEM", "Path: \SYSTEM", "Path:  \SYSTEM", "Path: \SYSTEM\",
                "Subkey: SYSTEM", "Subkey:  SYSTEM", "Subkey: \SYSTEM", "Subkey: \SYSTEM\")

            foreach ( $path in $badStrings )
            {
                It "Should throw an error when given '$path'" {
                    #Get-RegistryPathFromWindowsStig -CheckContent $path
                    {Get-RegistryPathFromWindowsStig -CheckContent $path} | Should Throw
                }
            }
        }
        #region #########################################   Registry Type   ########################################
        Describe "Get-RegistryValueType" {
            # A list of the registry types in the STIG(key) to DSC(value) format
            # this is a seperate list to detect changes in the script
            $registryTypes = [ordered] @{
                'REG_SZ'        = 'String'
                'REG_BINARY'    = 'Binary'
                'REG_DWORD'     = 'Dword'
                'REG_QWORD'     = 'Qword'
                'REG_MULTI_SZ'  = 'MultiString'
                'REG_EXPAND_SZ' = 'ExpandableString'
                'Disabled'      = 'Dword'
                'Enabled'       = 'Dword'
            }

            Context 'Windows STIG' {
                Mock Test-SingleLineStigFormat {return $false}
                Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_SZ'} -Verifiable

                It "Should call Get-RegistryValueTypeFromWindowsStig when a Windows STIG is given" {
                    Get-RegistryValueType -CheckContent "Type: REG_SZ" | Out-Null
                    Assert-VerifiableMock
                }

                foreach ( $item in $registryTypes.GetEnumerator() )
                {
                    [string] $registryTypeFromSTIG = $item.Key
                    [string] $registryTypeForDSC = $item.Value

                    It "Should accept '$registryTypeFromSTIG' and return '$registryTypeForDSC'" {
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_SZ'}  -ParameterFilter {$CheckContent -eq 'Type: REG_SZ'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_BINARY'}  -ParameterFilter {$CheckContent -match 'REG_BINARY'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_DWORD'}  -ParameterFilter {$CheckContent -match 'REG_DWORD'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_QWORD'}  -ParameterFilter {$CheckContent -match 'REG_QWORD'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_MULTI_SZ'}  -ParameterFilter {$CheckContent -match 'REG_MULTI_SZ'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'REG_EXPAND_SZ'}  -ParameterFilter {$CheckContent -match 'REG_EXPAND_SZ'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'Disabled'}  -ParameterFilter {$CheckContent -match 'Disabled'}
                        Mock Get-RegistryValueTypeFromWindowsStig {return 'Enabled'}  -ParameterFilter {$CheckContent -match 'Enabled'}

                        $RegistryValueType = Get-RegistryValueType -CheckContent "Type: $($item.Key)"
                        $RegistryValueType | Should Be $registryTypeForDSC
                    }
                }

                It "Should return 'null' with invalid registry type" {
                    Mock Get-RegistryValueTypeFromWindowsStig {return 'Invalid'}
                    Get-RegistryValueType -CheckContent 'Mocked data' | Should Be $null
                }
            }

            Context 'Office STIG' {
                Mock Test-SingleLineStigFormat {return $true}
                Mock Get-RegistryValueTypeFromSingleLineStig {return 'REG_SZ'} -Verifiable

                It "Should call Get-RegistryValueTypeFromSingleLineStig when an Office STIG is given" {
                    Get-RegistryValueType -CheckContent "Type: REG_SZ" | Out-Null
                    Assert-VerifiableMock
                }
            }
        }

        Describe 'Test-RegistryValueType' {
            $registryTypes = [ordered] @{
                'REG_SZ'        = 'String'
                'REG_BINARY'    = 'Binary'
                'REG_DWORD'     = 'Dword'
                'REG_QWORD'     = 'Qword'
                'REG_MULTI_SZ'  = 'MultiString'
                'REG_EXPAND_SZ' = 'ExpandableString'
                'Disabled'      = 'Dword'
                'Enabled'       = 'Dword'
            }

            foreach ( $item in $registryTypes.GetEnumerator() )
            {
                [string] $registryTypeFromSTIG = $item.Key
                It "Should return '$registryTypeFromSTIG'" {
                    $RegistryValueType = Test-RegistryValueType -TestValueType "Type: $($item.Key)"
                    $RegistryValueType | Should Be $registryTypeFromSTIG
                }
            }
        }
        
        Describe "Get-RegistryValueTypeFromWindowsStig" {

            $checkContent = "Type: REG_SZ"
            $RegistryValueType = Get-RegistryValueTypeFromWindowsStig -CheckContent $checkContent

            It "Should return 'REG_Type' from '$checkContent'" {
                $RegistryValueType | Should Be 'REG_SZ'
            }
        }
        #endregion
        #region #########################################   Registry Name   ########################################
        Describe "Get-RegistryValueName" {

            $valueName = 'ValueName'

            Context 'Windows STIG' {

                Mock Test-SingleLineStigFormat {return $false}

                It "Should return ValueName" {
                    Mock Get-RegistryValueNameFromWindowsStig {return 'ValueName'}
                    $RegistryValueName = Get-RegistryValueName -CheckContent "Name: $valueName"
                    $RegistryValueName | Should Be 'ValueName'
                }
            }

            Context 'Office STIG' {
                Mock Test-SingleLineStigFormat {return $true}

                $checkContent = "Criteria: If the value $valueName is REG_Type = 2, this is not a finding."

                It "Should return ValueName" {
                    Mock Get-RegistryValueNameFromSingleLineStig {return 'ValueName' }
                    $RegistryValueName = Get-RegistryValueName -CheckContent $checkContent
                    $RegistryValueName | Should Be $valueName
                }
            }
        }

        Describe "Get-RegistryValueNameFromWindowsStig" {
            # Test different number of trailing and leading spaces to verify the match
            $stringsToTest = @(
                'Value Name:',
                ' Value Name:',
                ' Value Name: ',
                'Value Name:  '
            )

            foreach ($string in $stringsToTest)
            {
                $valueName = 'ValueName'
                $checkContent = "$string $valueName"
                It "Should return '$valueName' from '$checkContent'" {
                    Get-RegistryValueNameFromWindowsStig -CheckContent $checkContent | Should Be $valueName
                }
            }
        }
        #endregion
        #region #########################################   Registry Data   ########################################
        Describe "Get-RegistryValueData" {

            Context 'Windows STIG' {

                Mock Test-SingleLineStigFormat {return $false}
                Mock Get-RegistryValueDataFromWindowsStig {return ""} -Verifiable
                It 'Should call the Windows code path when not an office registry format' {
                    Get-RegistryValueData -CheckContent "Value: 1"
                    Assert-VerifiableMock
                }
            }

            Context 'Office STIG' {
                Mock Test-SingleLineStigFormat {return $true}
                Mock Get-RegistryValueDataFromSingleStig -Verifiable
                It 'Should call the Office code path with an office registry format' {
                    Get-RegistryValueData -CheckContent "Criteria: 1"
                    Assert-VerifiableMock
                }
            }
        }

        Describe "Get-RegistryValueDataFromWindowsStig" {
            <#
            There are a lot of different string formats that have been found in the registry data
            so replicas of each pattern seen to data is represented below with the expected
            output. If new patterns are disovered, add them here to expand the test coverage.
        #>
            $testValues = @{

                # Integers with different leading and trailing spaces
                'Value: 1 (Enabled)'                           = '1 (Enabled)'
                'Value: 1'                                     = '1'
                'Value: 1 '                                    = '1'
                'Value:1'                                      = '1'
                'Value:1 '                                     = '1'
                'Value: 10'                                    = '10'
                'Value: 10 '                                   = '10'
                'Value:10'                                     = '10'
                'Value:10 '                                    = '10'
                'Value: 196608'                                = '196608'
                'Value: 32768'                                 = '32768'
                'Value: 4 (Prompt for consent)'                = '4 (Prompt for consent)'

                # Hex values
                'Value: 0x0000000a (10)'                       = '0x0000000a (10)'
                'Value: 0x20080000 (537395200)'                = '0x20080000 (537395200)'

                'Value: 1 or 2 = a Finding'                    = '1 or 2 = a Finding'

                # Integers with a range
                'Value:  3 (or less)'                          = '3 (or less)'
                'Value: 5 (or less)'                           = '5 (or less)'
                'Value: 300000 (or less)'                      = '300000 (or less)'
                'Value: 30 (or less, but not 0)'               = '30 (or less, but not 0)'
                'Value: 14 (or greater)'                       = '14 (or greater)'

                # Hex values with a range
                'Value: 0x00000384 (900) (or less)'            = '0x00000384 (900) (or less)'
                'Value: 0x000004b0 (1200) or less'             = '0x000004b0 (1200) or less'
                'Value: 0x000dbba0 (900000) or less but not 0' = '0x000dbba0 (900000) or less but not 0'
                'Value: 0x00000032 (50) (or greater)'          = '0x00000032 (50) (or greater)'
            }

            foreach ($testValue in $testValues.GetEnumerator())
            {
                It "Should return '$($testValue.value)' from '$($testValue.key)'" {
                    $RegistryValueDataFromWindowsStig = Get-RegistryValueDataFromWindowsStig -CheckContent $testValue.key
                    $RegistryValueDataFromWindowsStig | Should Be $testValue.value
                }
            }
        }

        #endregion
        Describe 'Test-RegistryValueDataIsBlank' {

            It "Should return True when given '(Blank)'" {
                Test-RegistryValueDataIsBlank -ValueDataString "(Blank)" | Should BeExactly $true
            }

            It "Should return False when not given '(Blank)'" {
                Test-RegistryValueDataIsBlank -ValueDataString "Anything else" | Should BeExactly $false
            }
        }

        Describe 'Test-RegistryValueDataIsEnabledOrDisabled' {

            $passTests = 'Enabled', 'Enable', 'Disabled', 'Disable'
            foreach ($test in $passTests)
            {
                It "Should return True when given '$test'" {
                    Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString $test | Should BeExactly $true
                }
            }
            It "Should return False when not given enabled ro disabled" {
                Test-RegistryValueDataIsEnabledOrDisabled -ValueDataString "Anything else" | Should BeExactly $false
            }
        }

        Describe 'Get-ValidEnabledOrDisabled' {

            Context 'Valid Dword' {

                Mock Test-IsValidDword {return $false}
                Mock ConvertTo-ValidDword {return '1'}  -ParameterFilter {$valueData -match 'Enable'}
                Mock ConvertTo-ValidDword {return '0'}  -ParameterFilter {$valueData -match 'Disable'}

                It "Should Convert Enable into 1 with Type Dword" {
                    Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Enabled" | Should Be "1"
                }

                It "Should Convert Disabled into 1 with Type Dword" {
                    Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Disable" | Should Be "0"
                }
            }

            Context 'Invalid Dword' {

                Mock Test-IsValidDword {return $true}

                It "Should return Enable when not a Dword" {
                    Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Enabled" | Should Be "Enabled"
                }

                It "Should return Disable when not a Dword" {
                    Get-ValidEnabledOrDisabled -ValueType 'Dword' -ValueData "Disable" | Should Be "Disable"
                }
            }
        }

        Describe 'Hex Code Tasks' {
            $testValues = @{
                'Value: 0x00000384 (900) (or less)'            = '900'
                'Value: 0x000004b0 (1200) or less'             = '1200'
                'Value: 0x000dbba0 (900000) or less but not 0' = '900000'
                'Value: 0x00000032 (50) (or greater)'          = '50'
            }

            Context 'Test-RegistryValueDataIsHexCode' {
                foreach ($testValue in $testValues.GetEnumerator())
                {
                    It "Should return True when given '$($testValue.key)'" {
                        Test-RegistryValueDataIsHexCode -ValueDataString $testValue.key | Should Be $true
                    }
                }

                It "Should return False when not given a hex code" {
                    Test-RegistryValueDataIsHexCode -ValueDataString "Anything else" | Should Be $false
                }
            }

            Context 'Get-IntegerFromHex' {

                It "Should thow an error if a hex code is not found" {
                    {Get-IntegerFromHex -ValueDataString 'No Hex code here'} | Should Throw
                }

                Foreach ($testValue in $testValues.GetEnumerator())
                {
                    It "Should return '$($testValue.value)' from '$($testValue.key)'" {
                        Get-IntegerFromHex -ValueDataString $testValue.Key | Should Be $testValue.Value
                    }
                }
            }
        }

        Describe 'Integer Tasks' {

            $testValues = [ordered] @{

                # Integers with different leading and trailing spaces
                'Value: 1 (Enabled)'            = '1'
                'Value: 1'                      = '1'
                'Value: 1 '                     = '1'
                'Value:1'                       = '1'
                'Value:1 '                      = '1'
                'Value: 10'                     = '10'
                'Value: 10 '                    = '10'
                'Value:10'                      = '10'
                'Value:10 '                     = '10'
                'Value: 196608'                 = '196608'
                'Value: 32768'                  = '32768'
                'Value: 4 (Prompt for consent)' = '4'
            }

            Context 'Test-RegistryValueDataIsInteger' {

                foreach ($test in $testValues.GetEnumerator())
                {
                    It "Should return True when given '$($test.Key)'" {
                        Test-RegistryValueDataIsInteger -ValueDataString $test.key | Should BeExactly $true
                    }
                }

                It "Should return False when not given a hex code" {
                    Test-RegistryValueDataIsInteger -ValueDataString "Anything else" | Should BeExactly $false
                }
            }

            Context 'Get-NumberFromString' {

                It "Should thow an error if a integer is not found" {
                    {Get-NumberFromString -ValueDataString 'No Integers here'} | Should Throw
                }

                Foreach ($string in $testValues.GetEnumerator())
                {
                    It "Should return '$($string.value)' from '$($string.key)'" {
                        Get-NumberFromString -ValueDataString $string.Key | Should Be $String.Value
                    }
                }
            }
        }

        Describe 'Format-MultiStringRegistryData' {

            It "Should return a multi line string from 'One Two Three'" {
                $MultiStringRegistryData = Format-MultiStringRegistryData -ValueDataString "One Two Three"
                ($MultiStringRegistryData -split ";")[0] | Should Be "One"
                ($MultiStringRegistryData -split ";")[1] | Should Be "Two"
                ($MultiStringRegistryData -split ";")[2] | Should Be "Three"
            }

            It "Should return a multi line string from 'Four, Five, Six'" {
                $MultiStringRegistryData = Format-MultiStringRegistryData -ValueDataString "Four, Five, Six"
                ($MultiStringRegistryData -split ";")[0] | Should Be "Four"
                ($MultiStringRegistryData -split ";")[1] | Should Be "Five"
                ($MultiStringRegistryData -split ";")[2] | Should Be "Six"
            }
        }

        Describe 'Get-MultiValueRegistryStringData' {

            $checkStrings = "Value: see below`n`n" +
            "System\Path\One`n" +
            "System\Path\Two`n" +
            "Software\Path\Three`n`n" +
            "Legitimate applications may add entries to this registry value."

            $MultiValueRegistryStringData = Get-MultiValueRegistryStringData -CheckStrings $checkStrings

            It "Should return a string of semicolon delimited values." {
                ($MultiValueRegistryStringData -split ";")[0] | Should Be "System\Path\One"
                ($MultiValueRegistryStringData -split ";")[1] | Should Be "System\Path\Two"
                ($MultiValueRegistryStringData -split ";")[2] | Should Be "Software\Path\Three"
            }
        }

        Describe "Test-IsValidDword" {

            It "Should return $true when given an integer '3'" {
                Test-IsValidDword -ValueData "3" | Should Be $true
            }

            It "Should return $false when given a string 'Three'" {
                Test-IsValidDword -ValueData "Three" | Should Be $false
            }
        }

        Describe "ConvertTo-ValidDword" {

            $testValues = [ordered] @{

                # Integers with different leading and trailing spaces
                '1 (Enabled)'  = '1'
                'Enabled'      = '1'
                '0 (Disabled)' = '0'
                'Disabled'     = '0'
            }

            Foreach ($testValue in $testValues.GetEnumerator())
            {
                It "Should return '$($testValue.value)' when given '$($testValue.key)'" {
                    ConvertTo-ValidDword -ValueData $testValue.key | Should Be $testValue.value
                }
            }

            It "Should throw an error when given anything but Enabled|Disable" {
                {ConvertTo-ValidDword -ValueData 'anything'} | Should Throw
            }
        }

        Describe 'Range value detection and return data' {

            <#
            See message * below

            Value: see below

                    System\CurrentControlSet\Control\ProductOptions
                    System\CurrentControlSet\Control\Server Applications
                    Software\Microsoft\Windows NT\CurrentVersion

            Value: see below

                    Software\Microsoft\OLAP Server
                    Software\Microsoft\Windows NT\CurrentVersion\Perflib
                    Software\Microsoft\Windows NT\CurrentVersion\Print
                    Software\Microsoft\Windows NT\CurrentVersion\Windows
                    System\CurrentControlSet\Control\ContentIndex
                    System\CurrentControlSet\Control\Print\Printers
                    System\CurrentControlSet\Control\Terminal Server
                    System\CurrentControlSet\Control\Terminal Server\UserConfig
                    System\CurrentControlSet\Control\Terminal Server\DefaultUserConfiguration
                    System\CurrentControlSet\Services\Eventlog
                    System\CurrentControlSet\Services\Sysmonlog
            #>

            Context 'Multi String Value' {

            }

            Context 'Multiple registry entries per SITG Id' {

            }
        }

        $multipleRegistryHiveString = "This applies to a server

    If the following registry values are not configured as specified, this is a finding:

    Registry Hive: HKEY_LOCAL_MACHINE
    Registry Path: \Path\ToTheFirstValue\To\Set\

    Value Name: SettingOneName

    Type: REG_SZ
    Value: ValueOne

    Registry Hive: HKEY_LOCAL_MACHINE
    Registry Path: \Path\ToTheSecondValue\To\Set\

    Value Name: SettingTwoName

    Type: REG_DWORD
    Value: ValueTwo"

        $multipleRegistryPathString = "Determine if the setting is correct.

    If they are not configured as specified, this is a finding.

    Registry Hive: HKEY_LOCAL_MACHINE

    Registry Path: \Path\ToTheFirstValue\To\Set\
    Value Name: SettingOneName
    Type: REG_SZ
    Value: ValueOne

    Registry Path: \Path\ToTheSecondValue\To\Set\
    Value Name: SettingTwoName
    Type: REG_DWORD
    Value: ValueTwo

    If it is not enabled and no alternate tool is enabled, this is a finding."

        $multipleRegistryValueString = 'Review the following registry values:

    Registry Hive: HKEY_LOCAL_MACHINE
    Registry Path: \Path\ToTheFirstValue\To\Set\

    Value Name: SettingOneName
    Type: REG_SZ
    Value: ValueOne

    and

    Value Name: SettingTwoName
    Type: REG_DWORD
    Value: ValueTwo'

        $singleRegistryString = "If the following registry value does not exist or is not configured as specified, this is a finding:

    Registry Hive: HKEY_LOCAL_MACHINE
    Registry Path: \Path\ToTheFirstValue\To\Set\

    Value Name: SettingOneName

    Value Type: REG_SZ
    Value: ValueOne"
        Describe 'Test-MultipleRegistryEntries' {

            foreach ($checkContent in @($multipleRegistryHiveString, $multipleRegistryPathString, $multipleRegistryValueString))
            {
                It "Should return $true when multiple registry settings are found" {
                    $checkContent = Split-TestStrings -CheckContent $checkContent
                    $hasMultipleEntries = Test-MultipleRegistryEntries -CheckContent $checkContent
                    $hasMultipleEntries | Should Be $true
                }
            }

            It "Should return $false when multiple registry settings are not found" {
                $checkContent = Split-TestStrings -CheckContent $singleRegistryString
                $hasMultipleEntries = Test-MultipleRegistryEntries -CheckContent $checkContent
                $hasMultipleEntries | Should Be $false
            }
        }

        Describe 'Split-MultipleRegistryEntries' {

            Context 'Multiple Hives' {
                $checkContent = Split-TestStrings -CheckContent $multipleRegistryHiveString
                $registryEntries = Split-MultipleRegistryEntries -CheckContent $checkContent

                It "Should not return the second registry entry in the first object" {
                    $registryEntries[0] -notmatch '\\Path\\ToTheSecondValue\\To\\Set\\' | Should Be $true
                    $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
                    $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
                    $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
                }

                It "Should not return the first registry entry in the second object" {
                    $registryEntries[1] -notmatch '\\Path\\ToTheFirstalue\\To\\Set\\' | Should Be $true
                    $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
                    $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
                    $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
                }
            }

            Context 'Multiple Paths' {
                $checkContent = Split-TestStrings -CheckContent $multipleRegistryPathString
                $registryEntries = Split-MultipleRegistryEntries -CheckContent $checkContent

                It "Should not return the second registry entry in the first object, but have the same Hive" {
                    $registryEntries[0] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
                    $registryEntries[0] -notmatch '\\Path\\ToTheSecondValue\\To\\Set\\' | Should Be $true
                    $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
                    $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
                    $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
                }

                It "Should not return the first registry entry in the second object, but have the same Hive" {
                    $registryEntries[1] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
                    $registryEntries[1] -notmatch '\\Path\\ToTheFirstalue\\To\\Set\\' | Should Be $true
                    $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
                    $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
                    $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
                }
            }

            Context 'Multiple Values' {
                $checkContent = Split-TestStrings -CheckContent $multipleRegistryValueString
                $registryEntries = Split-MultipleRegistryEntries -CheckContent $checkContent

                It "Should not return the second registry entry in the first object, but have the same hive and path" {
                    $registryEntries[0] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
                    $registryEntries[0] -match '\\Path\\ToTheFirstValue\\To\\Set\\' | Should Be $true
                    $registryEntries[0] -notmatch 'SettingTwoName' | Should Be $true
                    $registryEntries[0] -notmatch 'REG_DWORD' | Should Be $true
                    $registryEntries[0] -notmatch 'ValueTwo' | Should Be $true
                }

                It "Should not return the first registry entry in the second object, but have the same hive and path" {
                    $registryEntries[1] -match 'HKEY_LOCAL_MACHINE' | Should Be $true
                    $registryEntries[1] -match '\\Path\\ToTheFirstValue\\To\\Set\\' | Should Be $true
                    $registryEntries[1] -notmatch 'SettingOneName' | Should Be $true
                    $registryEntries[1] -notmatch 'REG_SZ' | Should Be $true
                    $registryEntries[1] -notmatch 'ValueOne' | Should Be $true
                }
            }
        }
        #endregion
        #region Function Tests - Single Line
        Describe 'Test-SingleLineRegistryRule' {

            It 'Should exist' {
                Get-Command Test-SingleLineRegistryRule | Should Not BeNullOrEmpty
            }

            It "Should return $true when 'HKCU\' is found" {
                Test-SingleLineRegistryRule -CheckContent "HKCU\" | Should Be $true
            }

            It "Should return $true when 'HKLM\' is found" {
                Test-SingleLineRegistryRule -CheckContent "HKLM\" | Should Be $true
            }

            It "Should return $false when 'Permission' is found" {
                Test-SingleLineRegistryRule -CheckContent "Permission" | Should Be $false
            }
        }

        Describe 'Get-SingleLineRegistryPath ' {

            It "Should return the full Current User registry path" {
                $checkContent = 'HKCU\Path\To\Value'
                $returnContent = 'HKEY_CURRENT_USER\Path\To\Value'
                Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
            }

            It "Should return the full Local Machine registry path" {
                $checkContent = 'HKLM\Path\To\Value'
                $returnContent = 'HKEY_LOCAL_MACHINE\Path\To\Value'
                Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
            }

            It "Should return the full Current User registry path without a trailing period" {
                $checkContent = 'HKCU\Path\To\Value.'
                $returnContent = 'HKEY_CURRENT_USER\Path\To\Value'
                Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
            }

            It "Should return the full Local Machine registry path without a trailing period" {
                $checkContent = 'HKLM\Path\To\Value.'
                $returnContent = 'HKEY_LOCAL_MACHINE\Path\To\Value'
                Get-SingleLineRegistryPath  -CheckContent $checkContent | Should Be $returnContent
            }
        }

        #########################################   Registry Type   ########################################
        Describe "Get-RegistryValueTypeFromSingleLineStig" {
            # A list of the registry types in the STIG(key) to DSC(value) format
            # this is a seperate list to detect changes in the script
            $registryTypes = @(
                'REG_SZ', 'REG_BINARY', 'REG_DWORD', 'REG_QWORD', 'REG_MULTI_SZ', 'REG_EXPAND_SZ'
            )

            foreach ( $registryType in $registryTypes )
            {
                $checkContent = "Criteria: If the value ""1001"" is $registryType = 3"
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_SZ = 3'}  -ParameterFilter {$CheckContent -match 'REG_SZ'}
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_BINARY = 3'}  -ParameterFilter {$CheckContent -match 'REG_BINARY'}
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_QWORD = 3'}  -ParameterFilter {$CheckContent -match 'REG_QWORD'}
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_MULTI_SZ = 3'}  -ParameterFilter {$CheckContent -match 'REG_MULTI_SZ'}
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is DWORD = 3'}  -ParameterFilter {$CheckContent -match 'REG_DWORD'}
                Mock Get-RegistryValueStringFromSingleLineStig {return 'Criteria: If the value ""1001"" is REG_EXPAND_SZ = 3'}  -ParameterFilter {$CheckContent -match 'REG_EXPAND_SZ'}

                It "Should return '$registryType' from '$checkContent'" {

                    $RegistryValueType = Get-RegistryValueTypeFromSingleLineStig -CheckContent $checkContent
                    $RegistryValueType | Should Be $registryType
                }
            }

            It "Should return 'null' with invalid registry type" {

                Get-RegistryValueTypeFromSingleLineStig -CheckContent 'Mocked data' | Should Be $null
            }
        }

        #########################################   Registry Type   ########################################
        #########################################   Registry Name   ########################################
        Describe "Get-RegistryValueNameFromSingleLineStig" {

            $valueName = 'ValueName'
            $checkContent = "Criteria: If the value ""$valueName"" is REG_Type = 2, this is not a finding."
            It "Should return '$valueName' from '$checkContent'" {
                Get-RegistryValueNameFromSingleLineStig -CheckContent $checkContent | Should Be $valueName
            }
        }
        #########################################   Registry Name   ########################################
        #########################################   Registry Data   ########################################
        Describe "Get-RegistryValueDataFromSingleStig" {

            $valueData = '2'
            $checkContent = "Criteria: If the value ""ValueName"" is REG_Type = $valueData, this is not a finding."

            It "Should return '$valueData' from '$checkContent'" {
                $result = Get-RegistryValueDataFromSingleStig -CheckContent $checkContent 
                $result | Should Be $valueData
            }
        }
        #########################################   Registry Data   ########################################
        ######################################   Ancillary functions   #####################################
        Describe 'Get-RegistryValueStringFromSingleLineStig' {

            $registryValueName = 'XL4Workbooks'
            $registryValueType = 'REG_DWORD'
            $registryValueData = '2'
            $registryValueInnerString = """$registryValueName"" is $registryValueType = $registryValueData"
            $registryValueString = "Criteria: If the value $registryValueInnerString, this is not a finding."
            $checkContent = "
    HKCU\Path\to\value

    $registryValueString"

            It "Should return the correct full string" {
                $checkContent = Split-TestStrings -CheckContent $checkContent
                $fullString = Get-RegistryValueStringFromSingleLineStig -CheckContent $checkContent
                $fullString | Should Be $registryValueString
            }

            <#
                "Criteria: If the value HtmlandXmlssFiles is REG_DWORD = 2, this is not a finding.",
                "Criteria: If the value DifandSylkFiles is REG_DWORD = 2, this is not a finding.",
                "Criteria: If the value XL9597WorkbooksandTemplates is REG_DWORD = 5, this is not a finding.",
                "Criteria: If the value of excel.exe is REG_DWORD = 1, this is not a finding.",
                "Criteria: If the value openinprotectedview does not exist, this is not a finding. If the value is REG_DWORD = 1, this is not a finding.",
                "Criteria: If the value ExcelBypassEncryptedMacroScan does not exist, this is not a finding. If the value is REG_DWORD = 0, this is not a finding.",
                "Criteria: If the value DefaultFormat is REG_DWORD =  0x00000033(hex) or 51 (Decimal), this is not a finding."
            #>

            $stringFormats = @(
                "Criteria: If the value of $registryValueInnerString, this is not a finding.",
                "Criteria: If the value $registryValueInnerString, this is not a finding."
            )
            foreach ($stringFormat in $stringFormats)
            {
                It "Should return the correct trimmed string" {
                    $trimmedString = Get-RegistryValueStringFromSingleLineStig -CheckContent $stringFormat -Trim
                    $trimmedString | Should Be $registryValueInnerString
                }
            }


            It "Should remove extra spaces from the string" {
                $checkContent = "Criteria: If   the value  XL4Workbooks  is REG_DWORD = 2, this is not a finding."

                $trimmedString = Get-RegistryValueStringFromSingleLineStig -CheckContent $checkContent
                $trimmedString | Should Be "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding."
            }

        }

        Describe "Test-SingleLineStigFormat" {
            $checkContent = "",
            "HKLM\to\value",
            "",
            "Criteria: If the value XL4Workbooks is REG_DWORD = 2, this is not a finding."

            It "Should return $true when match Office format" {
                Test-SingleLineStigFormat -CheckContent $checkContent | Should Be $true
            }

            $checkContent = "Registry Hive: HKEY_LOCAL_MACHINE" +
            "Registry Path:  \Path\To\Value"
            It "Should return $false when not match Office foramt" {
                Test-SingleLineStigFormat -CheckContent $checkContent | Should Be $false
            }
        }
        #endregion
        #region Data Tests
        Describe "DscRegistryValueType Data Section" {

            # Validate the static data section to convert the registry value types
            $registryTypes = @{
                'REG_SZ'         = 'String'
                'REG_BINARY'     = 'Binary'
                'REG_DWORD'      = 'Dword'
                'REG_QWORD'      = 'Qword'
                'REG_MULTI_SZ'   = 'MultiString'
                'REG_EXPAND_SZ'  = 'ExpandableString'
                'Does Not Exist' = 'Does Not Exist'
            }

            foreach ($registryType in $registryTypes.GetEnumerator())
            {
                It "'$($registryType.Key)' should exist and return '$($registryType.Value)'" {
                    $dscRegistryValueType.($registryType.Key) | Should Be $registryType.Value
                }
            }
        }

        Describe "RegistryRegularExpression Data Section" {

            Context "Hive Match" {

                $hiveStrings = @(
                    'Hive: HKEY_LOCAL_MACHINE',
                    'Hive: HKEY_LOCAL_MACHINE',
                    'Registry Hive: HKEY_LOCAL_MACHINE',
                    'Registry Hive: HKEY_LOCAL_MACHINE'
                )

                foreach ($string in $hiveStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryHive
                    }
                }
            }

            Context "Path Match" {

                $pathStrings = @(
                    'SubKey : \Path\To\RegistryValue',
                    'Registry Path :\Path\To\RegistryValue'
                )

                foreach ($string in $pathStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryPath
                    }
                }
            }

            Context "Type Match" {

                $typeStrings = @(
                    'Type: REG_SZ',
                    'Type: REG_BINARY',
                    'Type: REG_DWORD',
                    'Type: REG_QWORD',
                    'Type: REG_MULTI_SZ ',
                    'Type: REG_EXPAND_SZ'
                )

                foreach ($string in $typeStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryEntryType
                    }
                }
            }

            Context "ValueName Match" {
                $valueNameStrings = @(
                    'Value Name : SettingName'
                )

                foreach ($string in $valueNameStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryValueName
                    }
                }
            }

            Context "ValueData Match" {
                $valueNameStrings = @(
                    'Value : 1'
                )

                foreach ($string in $valueNameStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryValueData
                    }
                }

                $valueNameStringsToNotMatch = @(
                    'The policy referenced configures the following registry value:'
                )

                foreach ($string in $valueNameStringsToNotMatch)
                {
                    It "Should not match '$string'" {
                        $string | Should Not Match $RegistryRegularExpression.registryValueData
                    }
                }
            }

            Context "Value Data Range Match" {

                $rangeStrings = @(
                    'Possible values are'
                )

                foreach ($string in $rangeStrings)
                {
                    It "Should match '$string'" {
                        $string | Should Match $RegistryRegularExpression.registryValueRange
                    }
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
