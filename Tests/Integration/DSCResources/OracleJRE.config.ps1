configuration OracleJRE_config
{
    param
    (
        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyVersion,

        [Parameter()]
        [AllowNull()]
        [string]
        $TechnologyRole,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter()]
        [string[]]
        $SkipRule,

        [Parameter()]
        [string[]]
        $SkipRuleType,

        [Parameter()]
        [string[]]
        $SkipRuleSeverity,

        [Parameter()]
        [hashtable]
        $Exception,

        [Parameter()]
        [string[]]
        $ResourceParameters,

        [Parameter()]
        [object]
        $OrgSettings,

        [Parameter()]
        [AllowNull()]
        [string]
        $ConfigPath,

        [Parameter()]
        [AllowNull()]
        [string]
        $PropertiesPath
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $psboundParams = $PSBoundParameters
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName OracleJRE
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
