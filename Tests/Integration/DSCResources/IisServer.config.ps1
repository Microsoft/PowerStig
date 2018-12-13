Configuration IisServer_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $LogPath,

        [Parameter()]
        [psobject]
        $SkipRule,

        [Parameter()]
        [psobject]
<<<<<<< HEAD
        $SkipRuleType,

        [Parameter()]
        [psobject]
        $Exception
=======
        $SkipRuleType
>>>>>>> origin/2.4.0.0
    )

    Import-DscResource -ModuleName PowerStig
    Node localhost
    {
        & ([scriptblock]::Create("
<<<<<<< HEAD
        IisServer ServerConfiguration
        {
            OsVersion   = '$OsVersion'
            StigVersion = '$StigVersion'
            LogPath     = '$LogPath'
            $(if ($null -ne $Exception)
            {
                "Exception    = @{'$Exception'= @{'Value'='1234567'}}"
            })
            $(if ($null -ne $SkipRule)
            {
                "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
            }
            if ($null -ne $SkipRuleType)
            {
                " SkipRuleType = @($( ($SkipRuleType | % {"'$_'"}) -join ',' ))`n"
            })
        }")
=======
            IisServer ServerConfiguration
            {
                OsVersion   = '$OsVersion'
                StigVersion = '$StigVersion'
                LogPath     = '$LogPath'
                $(if ($null -ne $SkipRule)
                {
                    "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
                }
                if ($null -ne $SkipRuleType)
                {
                    "SkipRuleType = @($( ($SkipRuleType | % {"'$_'"}) -join ',' ))`n"
                })
            }")
>>>>>>> origin/2.4.0.0
        )
    }
}
