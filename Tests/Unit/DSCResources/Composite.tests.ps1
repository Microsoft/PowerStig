$script:DSCModuleName = 'PowerStig'
# Header

$script:moduleRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
Import-Module (Join-Path -Path $moduleRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1') -Force

Describe 'Common Tests - Configuration Module Requirements' {

    $manifestPath = "$script:moduleRoot\$script:DSCModuleName.psd1"
    $Manifest = Import-PowerShellDataFile -Path $manifestPath

    Context "$script:DSCModuleName module manifest properties" {

        It 'Should contain a module manifest that aligns to the folder and module names' {
            Test-Path -Path $manifestPath | Should Be True
        }
        It 'Should be a valid Manifest' {
            {Microsoft.PowerShell.Core\Test-ModuleManifest -Path $manifestPath } |
            Should Not Throw
        }
        It "Manifest $script:DSCModuleName.psd1 should import as a data file" {
            $Manifest | Should BeOfType 'Hashtable'
        }
        It 'Should have a GUID in the manifest' {
            $Manifest.GUID | Should Match '[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}'
        }
        It 'Should list a module version in the manifest' {
            $Manifest.ModuleVersion | Should BeGreaterThan 0.0.0.0
        }
        It 'Should list an author in the manifest' {
            $Manifest.Author | Should Not BeNullOrEmpty
        }
        It 'Should provide a description in the manifest' {
            $Manifest.Description | Should Not BeNullOrEmpty
        }
        It 'Should require PowerShell version 5.0 or later in the manifest' {
            $Manifest.PowerShellVersion | Should BeGreaterThan 5.0
        }
        It 'Should require CLR version 4 or later in the manifest' {
            $Manifest.CLRVersion | Should BeGreaterThan 4.0
        }
        It 'Should export DscResources in the manifest' {
            $Manifest.DscResourcesToExport | Should Not BeNullOrEmpty
        }
        It 'Should include tags in the manifest' {
            $Manifest.PrivateData.PSData.Tags | Should Not BeNullOrEmpty
        }
        It 'Should include a project URI in the manifest' {
            $Manifest.PrivateData.PSData.ProjectURI | Should Not BeNullOrEmpty
        }
    }

    if ($Manifest.RequiredModules)
    {
        Context "$script:DSCModuleName required modules" {

            It "Should find <ModuleName> : <ModuleVersion> in the PowerShell public gallery" -TestCases $Manifest.RequiredModules {
                param ($ModuleName, $ModuleVersion)

                $discoveredModule = Find-Module -Name $ModuleName -RequiredVersion $ModuleVersion -Repository 'PsGallery'

                $discoveredModule.Name    | Should Be $ModuleName
                $discoveredModule.Version | Should Be $ModuleVersion
            }
        }
    }


    Describe 'Composite Resources' {

        $manifestDscResourceList = $Manifest.DscResourcesToExport

        $moduleDscResourceList = Get-ChildItem -Path "$($script:moduleRoot)\DscResources" -Directory -Exclude 'Resources' |
                            Select-Object -Property BaseName -ExpandProperty BaseName

        It 'Should have all module resources listed in the manifest' {
            $manifestDscResourceList | Should Be $moduleDscResourceList
        }

        $TechnologyRoleFilter = @{
            Browser          = 'IE'
            DotNetFramework  = 'DotNet'
            SqlServer        = 'Database|Instance'
            WindowsDnsServer = 'DNS'
            WindowsFirewall  = 'FW'
            WindowsServer    = 'DC|MS'
            Outlook2013      = 'Outlook2013'
            Word2013         = 'Word2013'
        }
        Foreach ($resource in $moduleDscResourceList)
        {
            Context "$resource Composite Resource" {
                $compositeManifestPath = "$($script:moduleRoot)\DscResources\$resource\$resource.psd1"
                $compositeSchemaPath   = "$($script:moduleRoot)\DscResources\$resource\$resource.schema.psm1"

                It "Should have a $resource Composite Resource" {
                    $manifestDscResourceList.Where( {$PSItem -eq $resource}) | Should Not BeNullOrEmpty
                }

                It 'Should be a valid manifest' {
                    {Test-ModuleManifest -Path $compositeManifestPath} | Should Not Throw
                }

                It 'Should contain a schema module' {
                    Test-Path -Path $compositeSchemaPath | Should Be $true
                }

                It 'Should contain a correctly named configuration' {
                    $configurationName = Get-ConfigurationName -FilePath $compositeSchemaPath
                    $configurationName | Should Be $resource
                }

                It "Should match ValidateSet from PowerStig" {
                    $validateSet = Get-StigVersionParameterValidateSet -FilePath $compositeSchemaPath
                    $availableStigVersions = Get-ValidStigVersionNumbers -TechnologyRoleFilter $TechnologyRoleFilter[$resource]
                    $validateSet | Should BeIn $availableStigVersions
                }
            }
        }
    }
}
#endregion Tests

