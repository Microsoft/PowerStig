# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\..\Common\Common.psm1
using module .\..\..\Rule\Rule.psm1
using module .\..\PowerShellScriptQueryRule.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}

# Header

<#
    .SYNOPSIS
        Convert the contents of an xccdf check-content element into a PowerShellScriptQueryRule.
    .DESCRIPTION
        The PowerShellScriptQueryRule class is used to execute PowerShell code to meet 
        the requirement for vulnerability ID's that can't be met through other DSC modules.
#>

class PowerShellScriptQueryRuleConvert : PowerShellScriptQueryRule
{
    <#
        .SYNOPSIS
            Empty constructor for SplitFactory
    #>
    PowerShellScriptQueryRuleConvert ()
    {
    }

    <#
        .SYNOPSIS
            Converts a xccdf stig rule element into a PowerShellScriptQuery Rule
        .PARAMETER XccdfRule
            The STIG rule to convert
    #>

    PowerShellScriptQueryRuleConvert ([xml.xmlelement] $XccdfRule) : base ($XccdfRule, $true)
    {
        $this.SetGetScript()
        $this.SetTestScript()
        $this.SetSetScript()
        $this.SetDscResource()
    }

    #region Methods

    <#
        .SYNOPSIS
            Extracts the mitigation target name from the check-content and sets
            the value
        .DESCRIPTION
            Gets the mitigation target name from the xccdf content and sets the
            value. If the mitigation target name that is returned is not valid,
            the parser status is set to fail
    #>

    [void] SetGetScript ()
    {
        $thisGetScript = Get-GetScript -CheckContent $this.RawString

        if (-not $this.SetStatus($thisGetScript))
        {
            $this.set_GetScript($thisGetScript)
        }
    }

    [void] SetTestScript ()
    {
        $thisTestScript = Get-TestScript -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisTestScript))
        {
            $this.set_TestScript($thisTestScript)
        }
    }

    [void] SetSetScript ()
    {
        $thisSetSetScript = Get-SetScript -CheckContent $this.rawstring

        if (-not $this.SetStatus($thisSetSetScript))
        {
            $this.set_SetScript($thisSetSetScript)
        }
    }

    static [bool] Match ([string] $CheckContent)
    {
        if
        (
            $CheckContent -Match "setspn -L" -or
            $CheckContent -Match "If IsClustered returns 1" -or
            $CheckContent -Match "Named Pipes" -or
            $CheckContent -Match "sys.database_mirroring_endpoints" -or
            $CheckContent -Match "sys.service_broker_endpoints" -or
            $CheckContent -Match "Windows Start Menu and/or Control Panel,"
        )
        {
            return $true
        }
        
        return $false
    }

    hidden [void] SetDscResource ()
    {
        if ($null -eq $this.DuplicateOf)
        {
            $this.DscResource = 'Script'
        }
        else
        {
            $this.DscResource = 'None'
        }
    }
}
