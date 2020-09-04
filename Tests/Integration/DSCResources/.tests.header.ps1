$script:DSCModuleName = 'PowerStig'

# Using global variable so that Get-DscResource will only run when needed
if ($null -eq $global:getDscResource)
{
    $global:getDscResource = Get-DscResource -Module $script:DSCModuleName
}

$script:projectRoot = Split-Path -Path (Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent) -Parent
$script:buildOutput = Join-Path -Path $projectRoot -ChildPath 'output'
$script:modulePath = (Get-ChildItem -Path $buildOutput -Filter 'PowerStig.psd1' -Recurse).FullName
$script:moduleRoot = Split-Path -Path $script:modulePath -Parent
$helperModulePath = Join-Path -Path $script:projectRoot -ChildPath 'Tools\TestHelper\TestHelper.psm1'

Import-Module -Name $helperModulePath -Force
