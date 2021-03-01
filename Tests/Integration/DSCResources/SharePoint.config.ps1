configuration SharePoint_config
{
    [CmdletBinding()]
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
        [hashtable]
        $Exception,

        [Parameter()]
        [hashtable]
        $BackwardCompatibilityException,

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
        [object]
        $OrgSettings,

        [Parameter()]
        [string[]]
        $ResourceParameters,

        [Parameter()]
        [string]
        $WebAppUrl,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $SetupAccount
    )

    Import-DscResource -ModuleName PowerStig

    Node localhost
    {
        $psboundParams = $PSBoundParameters
        $psboundParams.SharePointVersion = $psboundParams['TechnologyVersion']
        $psboundParams.Remove('TechnologyRole')
        $psboundParams.Remove('ConfigurationData')
        $psboundParams.Remove('TechnologyVersion')

        $resourceParamString = New-ResourceParameterString -ResourceParameters $ResourceParameters -PSBoundParams $psboundParams
        $resourceScriptBlockString = New-ResourceString -ResourceParameterString $resourceParamString -ResourceName SharePoint
        & ([scriptblock]::Create($resourceScriptBlockString))
    }
}
