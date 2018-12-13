Configuration IisSite_config
{
    param
    (
        [Parameter()]
        [string[]]
        $WebAppPool,

        [Parameter(Mandatory = $true)]
        [string[]]
        $WebSiteName,

        [Parameter(Mandatory = $true)]
        [string]
        $OsVersion,

        [Parameter(Mandatory = $true)]
        [string]
        $StigVersion,

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
            IisSite SiteConfiguration
            {
                $(if ($null -ne $WebAppPool)
                {
                   "WebAppPool = @($( ($WebAppPool | % {"'$_'"}) -join ',' ))`n"
                })
                $( "WebSiteName = @($( ($WebSiteName | % {"'$_'"}) -join ',' ))`n" )
                OsVersion = '$OsVersion'
                StigVersion = '$StigVersion'
<<<<<<< HEAD
                $(if ($null -ne $Exception)
                {
                    "Exception    = @{'$Exception'= @{'Value'='1234567'}}"
                })
=======
>>>>>>> origin/2.4.0.0
                $(if ($null -ne $SkipRule)
                {
                    "SkipRule = @($( ($SkipRule | % {"'$_'"}) -join ',' ))`n"
                }
                if ($null -ne $SkipRuleType)
                {
                    "SkipRuleType = @($( ($SkipRuleType | % {"'$_'"}) -join ',' ))`n"
                })
            }")
        )
    }
}
