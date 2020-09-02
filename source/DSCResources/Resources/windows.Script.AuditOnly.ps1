$rules = $stig.RuleList | Select-Rule -Type AuditOnlyRule

foreach ( $rule in $rules ) {

    $resourceTitle = Get-ResourceTitle -Rule $rule
    $AuditOnlyQuery = Get-AuditOnlyQuery -Rule $rule
    $AuditOnlyExpectedValue = Get-AuditOnlyExpectedValue -Rule $rule

    Script $resourceTitle
    {
        GetScript = { @{ Result = (Invoke-Expression $using:AuditOnlyQuery) } }

        TestScript = {
            if ((Invoke-Expression $using:AuditOnlyQuery) -ne ($using:AuditOnlyExpectedValue))
            {
                return $false
            }
            else
            {
                return $true
            }
        }

        SetScript = { }
    }
}