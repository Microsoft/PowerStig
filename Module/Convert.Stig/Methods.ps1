#region Method Functions
<#
    .SYNOPSIS
        Looks at the check-content data and returns the rule type that is should be converted to.

    .PARAMETER CheckContent
        The check-content xml element from the stig rule
#>
function Get-RuleTypeMatchList
{
    [CmdletBinding()]
    [OutputType([RuleType[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CheckContent
    )

    [System.Collections.ArrayList] $ruleTypeList = @()
    $parsed = $false
    switch ( $CheckContent )
    {
        {
            $PSItem -Match 'gpedit\.msc' -and $PSItem -match 'Account Policies'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::AccountPolicyRule )
            $parsed = $true
        }
        {
            $PSItem -Match "\bAuditpol\b" -and $PSItem -NotMatch "resourceSACL"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::AuditPolicyRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'dnsmgmt\.msc' -and
            $PSItem -NotMatch 'Forward Lookup Zones' -and
            $PSItem -Notmatch 'Logs\\Microsoft' -and
            $PSItem -NotMatch 'Verify the \"root hints\"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DnsServerSettingRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'dnsmgmt\.msc' -and
            $PSItem -Match 'Verify the \"root hints\"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DnsServerRootHintRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Logging' -and
            $PSItem -Match 'IIS 8\.5' -and
            $PSItem -NotMatch 'review source IP' -and
            $PSItem -NotMatch 'verify only authorized groups' -and
            $PSItem -NotMatch 'consult with the System Administrator to review' -and
            $PSItem -Notmatch 'If an account associated with roles other than auditors'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::IisLoggingRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'MIME Types' -and
            $PSItem -Match 'IIS 8\.5'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::MimeTypeRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'permission(s|)' -and
            $PSItem -NotMatch 'Forward\sLookup\sZones|Devices\sand\sPrinters|Shared\sFolders' -and
            $PSItem -NotMatch 'Verify(ing)? the ((permissions .* ((G|g)roup (P|p)olicy|OU|ou))|auditing .* ((G|g)roup (P|p)olicy))' -and
            $PSItem -NotMatch 'Windows Registry Editor' -and
            $PSItem -NotMatch '(ID|id)s? .* (A|a)uditors?,? (SA|sa)s?,? .* (W|w)eb (A|a)dministrators? .* access to log files?' -and
            $PSItem -NotMatch '\n*\.NET Trust Level' -and
            $PSItem -NotMatch 'IIS 8\.5 web' -and
            $PSItem -cNotmatch 'SELECT' -and
            $PSItem -NotMatch 'SQL Server' -and
            $PSItem -NotMatch 'user\srights\sand\spermissions' -and
            $PSItem -NotMatch 'Query the SA' -and
            $PSItem -NotMatch "caspol\.exe" -and
            $PSItem -NotMatch "Select the Group Policy object in the left pane" -and
            $PSItem -NotMatch "Deny log on through Remote Desktop Services" -and
            $PSItem -NotMatch "Interview the IAM" -and
            $PSItem -NotMatch "InetMgr\.exe" -and
            $PSItem -NotMatch "Register the required DLL module by typing the following at a command line ""regsvr32 schmmgmt.dll""."
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::PermissionRule )
            $parsed = $true
        }
        {
            (
                $PSItem -Match "HKEY_LOCAL_MACHINE|HKEY_CURRENT_USER" -and
                $PSItem -NotMatch "Permission(s|)" -and
                $PSItem -NotMatch "SupportedEncryptionTypes" -and
                $PSItem -NotMatch "Sql Server"
            ) -or
            (
                $PSItem -Match "Windows Registry Editor" -and
                $PSItem -Match "HKLM|HKCU"
            ) -or
            (
                $PSItem -match "HKLM|HKCU" -and
                $PSItem -match "REG_DWORD"
            )
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::RegistryRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'gpedit\.msc' -and
            $PSItem -match 'Security Options'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::SecurityOptionRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'services\.msc' -and
            $PSItem -NotMatch 'Required Services' -and
            $PSItem -NotMatch 'presence of applications' -and
            $PSItem -NotMatch 'is not installed by default' -and
            $PSItem -NotMatch 'Sql Server'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::ServiceRule )
            $parsed = $true
        }
        {
            $PSItem -Match "SELECT" -and
            $PSItem -Match 'existence.*publicly available.*(").*(")\s*(D|d)atabase' -or
            $PSItem -Match "(DISTINCT|(D|d)istinct)\s+traceid" -or
            $PSItem -Match "direct access.*server-level" -and
            $PSItem -NotMatch "SHUTDOWN_ON_ERROR" -and
            $PSItem -NotMatch "'Alter any availability group' permission"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::SqlScriptQueryRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'gpedit\.msc' -and
            $PSItem -Match 'User Rights Assignment' -and
            $PSItem -NotMatch 'unresolved SIDs' -and
            $PSItem -NotMatch 'SQL Server'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::UserRightRule )
            $parsed = $true
        }
        {
            $PSItem -cMatch 'IIS' -and
            $PSItem -Match 'Application Pools' -and
            $PSItem -NotMatch 'recycl' -and
            $PSItem -NotMatch 'review the "Applications"'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WebAppPoolRule )
            $parsed = $true
        }
        {
            $PSItem -Match '\.NET Trust Level' -or
            (
                $PSItem -Match 'IIS 8\.5 web' -and
                $PSItem -NotMatch 'document'
            ) -and
            (
                $PSItem -NotMatch 'alternateHostName' -and
                $PSItem -NotMatch 'Application Pools' -and
                $PSItem -NotMatch 'bindings' -and
                $PSItem -NotMatch 'DoD PKI Root CA' -and
                $PSItem -NotMatch 'IUSR account' -and
                $PSItem -NotMatch 'Logging' -and
                $PSItem -NotMatch 'MIME Types' -and
                $PSItem -NotMatch 'Physical Path' -and
                $PSItem -NotMatch 'script extensions' -and
                $PSItem -NotMatch 'recycl' -and
                $PSItem -NotMatch 'WebDAV' -and
                $PSItem -NotMatch 'Review the local users' -and
                $PSItem -NotMatch 'System Administrator' -and
                $PSItem -NotMatch 'are not restrictive enough to prevent connections from nonsecure zones' -and
                $PSItem -NotMatch 'verify the certificate path is to a DoD root CA' -and
                $PSItem -NotMatch 'HKLM' -and
                $PSItem -NotMatch 'Authorization Rules' -and
                $PSItem -NotMatch 'regedit <enter>' -and
                $PSItem -NotMatch 'Enable proxy'
            )
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WebConfigurationPropertyRule )
            $parsed = $true
        }
        {
            $PSItem -Match '(Get-Windows(Optional)?Feature|is not installed by default)' -or
            $PSItem -Match 'WebDAV Authoring Rules' -and
            $PSItem -NotMatch 'HKEY_LOCAL_MACHINE'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WindowsFeatureRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Logs\\Microsoft' -and
            $PSItem -Match 'eventvwr\.msc'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WinEventLogRule )
            $parsed = $true
        }
        {
            $PSItem -Match "Disk Management" -or
            $PSItem -Match "Service Pack"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::WmiRule )
            $parsed = $true
        }
        {
            $PSItem -Match "Get-ProcessMitigation"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::ProcessMitigationRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'Navigate to System Tools >> Local Users and Groups >> Groups\.' -and
            $PSItem -NotMatch 'Backup Operators|Hyper-V Administrators'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::GroupRule )
            $parsed = $true
        }
        {
            $PSItem -Match 'about:config' -and
            $PSItem -NotMatch 'Mozilla.cfg'
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::FileContentRule )
            $parsed = $true
        }
        <#
            Break out of switch statement once a rule has been parsed before it tries to convert to a
            document or manual rule.
        #>
        {
            $parsed -eq $true
        }
        {
            break
        }
        <#
            Some rules have a documentation requirement only for exceptions, so the DocumentRule
            needs to be at the end of the swtich as a catch all for documentation rules.
        #>
        {
            $PSItem -Match "Document(ation)?" -and
            $PSItem -NotMatch "resourceSACL|Disk Management" -and
            $PSItem -NotMatch "Caspol\.exe" -and
            $PSItem -NotMatch "Examine the \.NET CLR configuration files" -and
            $PSItem -NotMatch "\*\.exe\.config"
        }
        {
            [void] $ruleTypeList.Add( [RuleType]::DocumentRule )
        }
        default
        {
            [void] $ruleTypeList.Add( [RuleType]::ManualRule )
        }
    }
    return $ruleTypeList
}

<#
    .SYNOPSIS
        Used to determine the DSC Resource to handle this specific rule

    .PARAMETER StigRule
        The converted rule class based object
#>
function Get-StigRuleResource
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [RuleType]
        $RuleType
    )

    switch ( $RuleType )
    {
        'PermissionRule'
        {
            $Path = $this.Path
            if ( $Path )
            {
                return Get-PermissionRuleDscResource -Path $Path
            }
        }
        'IISLoggingRule'
        {
            return Get-IISLoggingRuleDscResource -StigTitle $global:stigTitle
        }
        'WindowsFeature'
        {
            return 'WindowsOptionalFeature'
        }
        'FileContentRule'
        {
            return Get-FileContentRuleDscResource -Key $this.Key
        }
        'RegistryRule'
        {
            return Get-RegistryRuleDscResource -Key $this.Key
        }
        default
        {
            return $DscResource.($RuleType.ToString())
        }
    }
}

<#
    .SYNOPSIS
        Returns the name of the DSC resource used to handle the specific rule

    .PARAMETER Key
        The Registry Key of the STIG Rule
#>
function Get-RegistryRuleDscResource
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Key
    )
    
    if ($Key -match "(^hklm|^HKEY_LOCAL_MACHINE)")
    {
        return "xRegistry"
    }
    else
    {
        return "cAdministrativeTemplate"
    }
}

<#
    .SYNOPSIS
        Returns the name of the DSC resource used to handle the specific rule

    .PARAMETER Path
        Stig Title for the DSC Resource

    .EXAMPLE
        Get-IISLoggingRuleDscResource -StigTitle "IIS 8.5 Server Security Technical Implementation Guide"
#>
function Get-IISLoggingRuleDscResource
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [String]
        $StigTitle
    )

    if ($StigTitle -match "Server")
    {
        return "xIISLogging"
    }

    return "XWebsite"
}

<#
    .SYNOPSIS
        Returns the name of the DSC resource used to handle the specific rule

    .PARAMETER Path
        Path value for the permission rule

    .EXAMPLE
        Get-PermissionRuleDscResource -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurePipeServers\winreg\"
#>
function Get-PermissionRuleDscResource
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $Path
    )

    switch ($Path)
    {
        {$PSItem -match '{domain}'}
        {
            return "ActiveDirectoryAuditRuleEntry"
        }
        {$PSItem -match 'HKLM:\\'}
        {
            return 'RegistryAccessEntry'
        }
        {$PSItem -match '(%windir%)|(ProgramFiles)|(%SystemDrive%)|(%ALLUSERSPROFILE%)'}
        {
            return 'NTFSAccessEntry'
        }
    }
}

<#
    .SYNOPSIS
        Returns the name fo the DSC resource needed to manage a FileContentRule
    .PARAMETER Key
        The Key of the STIG rule
    .EXAMPLE
        Get-FileContentRuleDscResource -StigId 'V-19741'
#>
function Get-FileContentRuleDscResource
{
    [CmdletBinding()]
    [OutputType([String])]
    param
    (
        [parameter(Mandatory = $true)]
        [String]
        $Key
    )

    if ($Key -match 'app.update.enabled|datareporting.policy.dataSubmissionEnabled')
    {
        return 'cJsonFile'
    }
    return 'ReplaceText'
}
<#
    .SYNOPSIS
        Checks for Html encoded char

    .PARAMETER CheckString
        The string to convert.
#>
function Test-HtmlEncoding
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CheckString
    )

    if ( $CheckString -match '&\w+;' )
    {
        return $true
    }
    else
    {
        return $false
    }
}

<#
    .SYNOPSIS
        Converts Html encoded strings back in the ascii char

    .PARAMETER CheckString
        The string to convert.
#>
function ConvertFrom-HtmlEncoding
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $CheckString
    )

    return [System.Web.HttpUtility]::HtmlDecode( $CheckString )
}

<#
    .SYNOPSIS
        Tests the results of ConvertTo-*Rule functions for duplicates.  The DNS STIG has multiple duplicates but we only
        need to account for them once.  If a duplicate is detected we will convert that rule to a document rule.

    .PARAMETER ReffernceObject
        The list of Stigs objects to compare to.

    .PARAMETER DifferenceObject
        The newly created object to verify is not a duplicate.

    .NOTES
        General notes
#>
function Test-DuplicateRule
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter( Mandatory = $true )]
        [AllowNull()]
        [object]
        $ReferenceObject,

        [Parameter( Mandatory = $true )]
        [object]
        $DifferenceObject
    )

    $ruleType = $DifferenceObject.GetType().Name
    $baseStig = [Stig]::New()

    $referenceProperties = ( $baseStig | Get-Member -MemberType Property ).Name
    $differenceProperties = ( $DifferenceObject | Get-Member -MemberType Property ).Name

    $propertyList = (Compare-Object -ReferenceObject $referenceProperties -DifferenceObject $differenceProperties).InputObject
    $referenceRules = $ReferenceObject | Where-Object { $( $PsItem.GetType().Name ) -eq $ruletype }

    foreach ( $rule in $referenceRules )
    {
        $results = @()

        foreach ($propertyName in $PropertyList)
        {
            $results += $rule.$propertyName -eq $DifferenceObject.$propertyName
        }

        if ( $results -notcontains $false )
        {
            Write-Verbose "$($rule.id) is a duplicate"
            return $true
        }
    }
    # if the code made it this far a duplicate does not exist and we return $false
    return $false
}

<#
    .SYNOPSIS
        Looks in $global:stigSettings for existing rules

    .NOTES
        Some rules in the STIG enforce multiple settings. This function will test for
        this scenario to so we can act upon it later.
#>
function Test-ExistingRule
{
    [CmdletBinding()]
    [OutputType([Boolean])]
    param
    (
        [Parameter()]
        [object]
        $RuleCollection,

        [Parameter()]
        [object]
        $NewRule
    )

    $IdExist = $RuleCollection | Where-Object {$PSItem.Id -eq $NewRule.Id}

    return $IdExist.id -eq $NewRule.id
}
#endregion
