# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
 .SYNOPSIS
    Parses Check-Content element to retrieve the Security Options Policy name
#>
function Get-SecurityOptionName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    # Use a regular expression to pull the user string from between the quotes
    $Option = ( $checkContent |
            Select-String -Pattern ([RegularExpression]::TextBetweenQuotes) -AllMatches )

    If ($checkContent -match "Verify the effective setting in Local Group Policy Editor")
    {
        $Option = $Option.Matches.Groups[3].Value
        $Option = $Option.Replace('"','')
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $Option "
        return $option
    }
    # Used for converting SQL Server 2016 Instance Stig Rules
    If ($checkContent -match "System cryptography: Use FIPS-compliant algorithms" -or "In the right-side pane" -or "Use FIPS compliant algorithms" )
    {
        $Option = "System_cryptography_Use_FIPS_compliant_algorithms_for_encryption_hashing_and_signing"
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $Option "
        return $option
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : Not Found"
        return
    }
}

<#
 .SYNOPSIS
    Parses Check-Content element to retrieve the Security Policy value
#>
function Get-SecurityOptionValue
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string[]]
        $CheckContent
    )

    Write-Verbose "[$($MyInvocation.MyCommand.Name)]"

    # Use a regular expression to pull the user string from between the quotes
    $option = ( $checkContent |
            Select-String -Pattern ([RegularExpression]::TextBetweenQuotes) -AllMatches )

    If ($checkContent -match "Verify the effective setting in Local Group Policy Editor")
    {
        $Option = $Option.Matches.Groups[5].Value
        $Option = $Option.Replace('"','')
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $Option "
        return $option
    }
    # Used for converting SQL Server 2016 Instance Stig Rules
    If ($checkContent -match "System cryptography: Use FIPS-compliant algorithms" -or "In the right-side pane" -or "Use FIPS compliant algorithms")
    {
        $Option = 'Enabled'
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : $Option "
        return $option
    }
    else
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Security Option : Not Found"
        return
    }
}
#endregion
