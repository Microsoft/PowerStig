#region Header
using module .\..\..\..\Module\Convert.Main\Convert.Main.psm1
. $PSScriptRoot\.tests.header.ps1
#endregion
try
{
    InModuleScope -ModuleName $script:moduleName {
        #region Test Setup
        $script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
        #endregion
        #region Class Tests

        #endregion
        #region Method Tests

        #endregion
        #region Function Tests
        Describe 'Split-StigXccdf' {

            $sampleXccdfFileName = 'U_Windows_Server_2016{0}_STIG_V1R1_Manual-xccdf.xml'
            $sampleXccdfId = 'Windows_Server_2016{0}_STIG'
            $sampleXccdfPath = "$TestDrive\$sampleXccdfFileName" -f ''
            (Get-TestStigRule -XccdfId ($sampleXccdfId -f '')).Save($sampleXccdfPath)
            Split-StigXccdf -Path $sampleXccdfPath

            Context 'Member Server' {
                $sampleXccdfSplitPath = "$TestDrive\$sampleXccdfFileName" -f '_MS_SPLIT'
                It 'Should create an MS STIG file' {
                    Test-Path -Path $sampleXccdfSplitPath | Should Be $true
                }

                It 'Should have MS in the benchmark ID' {
                    [xml] $sampleXccdfSplitContent = Get-Content $sampleXccdfSplitPath -Encoding UTF8 -Raw
                    $sampleXccdfSplitContent.Benchmark.id | Should Be ($sampleXccdfId -f '_MS')
                }
            }

            Context 'Domain Controller' {
                $sampleXccdfSplitPath = "$TestDrive\$sampleXccdfFileName" -f '_DC_SPLIT'
                It 'Should create an DC STIG file' {
                    Test-Path -Path $sampleXccdfSplitPath | Should Be $true
                }
                It 'Should have DC in the benchmark ID' {
                    [xml] $sampleXccdfSplitContent = Get-Content $sampleXccdfSplitPath -Encoding UTF8 -Raw
                    $sampleXccdfSplitContent.Benchmark.id | Should Be ($sampleXccdfId -f '_DC')
                }
            }
        }
        Describe "Get-StigVersionNumber" {
            $majorVersionNumber = '1'
            $minorVersionNumber = '5'
            $sampleXccdf = Get-TestStigRule -XccdfVersion $majorVersionNumber `
                -XccdfRelease "Release: $minorVersionNumber Benchmark Date: 01 Jan 1901"

            It "Should extract the version number from the xccdf" {
                Get-StigVersionNumber -StigDetails $sampleXccdf |
                    Should Be "$majorVersionNumber.$minorVersionNumber"
            }
        }

        Describe "Get-PowerStigFileList" {
            $majorVersionNumber = '1'
            $minorVersionNumber = '5'
            $sampleXccdf = Get-TestStigRule -XccdfVersion $majorVersionNumber `
                -XccdfRelease "Release: $minorVersionNumber Benchmark Date: 01 Jan 1901" `
                -XccdfId "Windows_2012_DC_STIG"
            $expectedName = "Windows-2012-DC-$majorVersionNumber.$minorVersionNumber.xml"
            Context 'No Destination supplied' {

                $powerStigFileList = Get-PowerStigFileList -StigDetails $sampleXccdf

                It "Should return a fileInfo Object" {
                    $powerStigFileList.Settings.GetType().ToString() | Should Be 'System.IO.FileInfo'
                }
                It " Should return the file name" {
                    $powerStigFileList.Settings.Name | Should Be $expectedName
                }
                It " Should return the full path" {
                    $powerStigFileList.Settings.FullName | Should Be "$script:moduleRoot\StigData\Processed\$expectedName"
                }
            }


            Context 'Destination supplied' {
                Mock -CommandName Resolve-Path -MockWith {return "C:\Test\Path"}
                $powerStigFileList = Get-PowerStigFileList -StigDetails $sampleXccdf -Destination ".\Path"

                It "Should return the full path of the supplied destination" {
                    $powerStigFileList.Settings.FullName | Should Be "C:\Test\Path\$expectedName"
                }
            }
        }

        Describe "Split-BenchmarkId" {

            $sampleStrings = [ordered]@{
                'SQLServer' = @(
                    @{
                        'id' = 'Microsoft_SQL_Server_2012_Database__Security_Technical_Implementation_Guide_NewBenchmark'
                        'Technology' = 'SQLServer'
                        'TechnologyVersion' = '2012'
                        'TechnologyRole' = 'Database'
                    },
                    @{
                        'id' = 'Microsoft_SQL_Server_2012_Database_Instance_Security_Technical_Implementation_Guide'
                        'Technology' = 'SQLServer'
                        'TechnologyVersion' = '2012'
                        'TechnologyRole' = 'Instance'
                    }
                )
                'Firewall' = @(
                    @{
                        'id' = 'Windows_Firewall'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole' = 'FW'
                    }
                )
                'DNS' = @(
                    @{
                        'id' = 'Microsoft_Windows_2012_Server_Domain_Name_System_STIG'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = '2012'
                        'TechnologyRole' = 'DNS'
                    }
                )
                'Windows' = @(
                    @{
                        'id'                = 'Windows_2012_DC_STIG'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = '2012'
                        'TechnologyRole'    = 'DC'
                    },
                    @{
                        'id'                = 'Windows_2012_MS_STIG'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = '2012'
                        'TechnologyRole'    = 'MS'
                    },
                    @{
                        'id'                = 'Windows_Server_2016_DC_STIG'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = '2016'
                        'TechnologyRole'    = 'DC'
                    },
                    @{
                        'id'                = 'Windows_Server_2016_MS_STIG'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = '2016'
                        'TechnologyRole'    = 'MS'
                    },
                    @{
                        'id'                = 'Windows_10'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = '10'
                        'TechnologyRole'    = 'Client'
                    }
                )
                'Active_Directory' = @(
                    @{
                        'id' = 'Active_Directory_Domain'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole' = 'Domain'
                    },
                    @{
                        'id' = 'Active_Directory_Forest'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole' = 'Forest'
                    }
                )
                'IE' = @(
                    @{
                        'id' = 'IE_11_STIG'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole' = 'IE11'
                    }
                )
                'Outlook2013'      = @(
                    @{
                        'id'                = 'Windows_All_Outlook2013'
                        'Technology'        = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole'    = 'Outlook2013'
                    }
                )
                'Word2013' = @(
                    @{
                        'id' = 'Windows_All_Word2013'
                        'Technology' = 'Windows'
                        'TechnologyVersion' = 'All'
                        'TechnologyRole' = 'Word2013'
                    }
                )                
            }
            foreach ($sampleString in $sampleStrings.GetEnumerator())
            {
                Context "$($sampleString.Key)" {

                    foreach ($sample in $sampleString.value)
                    {
                        Context "$($sample.Id)" {
                            $benchmarkId = Split-BenchmarkId -Id $sample.Id
                            It "Should return $($sample.Technology) as the Technology property" {
                                $benchmarkId.Technology | Should Be $sample.Technology
                            }
                            It "Should return $($sample.TechnologyVersion) as the TechnologyVersion property" {
                                $benchmarkId.TechnologyVersion | Should Be $sample.TechnologyVersion
                            }
                            It "Should return $($sample.TechnologyRole) as the TechnologyRole property" {
                                $benchmarkId.TechnologyRole | Should Be $sample.TechnologyRole
                            }
                        }
                    }

                }
            }
        }
        #endregion
        #region Data Tests

        #endregion
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}

