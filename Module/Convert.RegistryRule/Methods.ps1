# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Method Functions
<#
    .SYNOPSIS
        Determines what function to use to extract the registry key from a string. This is used to
        account for all of the different variations on registry setting in different STIGs.

    .Parameter stigString
        This is an array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryKey
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $result = @()
    if (Test-SingleLineRegistryRule -CheckContent $CheckContent)
    {
        $result = Get-SingleLineRegistryPath -CheckContent $CheckContent
        if ($result -match "!")
        {
            $result = $result.Substring(0, $result.IndexOf('!'))
        }
    }
    else
    {
        # Get the registry hive from the content string
        $registryHive = Get-RegistryHiveFromWindowsStig -CheckContent $CheckContent

        # Get the registry path from the content string
        $registryPath = Get-RegistryPathFromWindowsStig -CheckContent $CheckContent

        foreach ($path in $registryPath)
        {
            $result += ($registryHive + $path)
        }
    }

    $result
}

<#
    .SYNOPSIS
        Extract the registry key root from a string.

    .Parameter CheckContent
        An array of the raw string data taken from the STIG setting.
#>
function Get-RegistryHiveFromWindowsStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    # Get the second index of the list, which should be the hive and remove spaces.
    $hive = ( ( $CheckContent | Select-String -Pattern $script:registryRegularExpression.RegistryHive ) -split ":" )[1]

    if ( -not [string]::IsNullOrEmpty( $hive ) )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $true"

        $hive = $hive.trim()

        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Trimmed : $hive"
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $false"
        throw "Registry hive was not found in check content."
    }

    $hive
}

<#
    .SYNOPSIS
        Extract the registry path from a string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting. the raw sting data taken from the STIG setting.
#>
function Get-RegistryPathFromWindowsStig
{
    [CmdletBinding()]
    [OutputType([string[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $result = @()
    $paths = ( $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryPath )

    if ( [string]::IsNullOrEmpty($paths) )
    {
        throw "Registry path was not found in check content."
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $false"
    }
    else
    {
        foreach ( $path in $paths.Line )
        {
            if ( $path -match ':' )
            {
                # Get the second index of the list, which should be the path and remove spaces.
                $path = (($path -split ":")[1])
            }

            $path = $path.trim().TrimEnd("\")

            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Trimmed : $path"

            # There are several cases where the leading backslash is missing, so add it back.
            if ( $path -notmatch "^\\" )
            {
                $path = "\$path"
                Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Fixed Leading Backslash : $path"
            }

            # There is an edge case where the STIG has a typo and the path is writen with a space after \SOFTWARE\  (V-68819)
            if  ($path -match '\sP' )
            {
                $path = $path -replace '\s'
            }
            $result += $path
        }
    }
    $result
}

<#
    .SYNOPSIS
        Extract the registry value type from a string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    # The Office format is different to check which way to send the strings.
    if ( Test-SingleLineStigFormat -CheckContent $CheckContent )
    {
        [string] $type = Get-RegistryValueTypeFromSingleLineStig -CheckContent $CheckContent
    }
    else
    {
        # Get the second index of the list, which should be the data type and remove spaces.
        [string] $type = Get-RegistryValueTypeFromWindowsStig -CheckContent $CheckContent
    }

    [string] $DscRegistryValueType = $dscRegistryValueType.$type
    # Verify the registry type against the dscRegistryValueType data section.
    if ( -not [string]::IsNullOrEmpty( $DscRegistryValueType ) )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]  Convert Type : $DscRegistryValueType "
        # Set the dsc format of the registry type
        [string] $return = $DscRegistryValueType
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] DSC Format Not Found For Type : $type"
        return
    }

    $return
}

<#
    .SYNOPSIS
        Tests that the ValueType is able to be used in a STIG

    .PARAMETER TestValueType
        The string to test against known good ValueTypes
#>
function Test-RegistryValueType
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $TestValueType
    )

    foreach ($valueType in $dscRegistryValueType.Keys)
    {
        if ($TestValueType -match $valueType)
        {
            $return = $valueType

            break
        }
    }
    
    if ($null -eq $return)
    {
        $return = $TestValueType
    }

    return $return
}
<#
    .SYNOPSIS
        Extract the registry value type from a Windows STIG string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueTypeFromWindowsStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    $type = ( $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryEntryType ).Matches.Value

    if ( -not [string]::IsNullOrEmpty( $type ) )
    {
        # Get the second index of the list, which should be the data type and remove spaces.
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]    Found : $type"

        $type = ( ($type -split ":")[1] ).trim()

        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]  Trimmed : $type"
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $false"
        # If we get here, there is nothing to verify so return.
        return
    }

    $type
}

<#
    .SYNOPSIS
        Extract the registry value type from a string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    # The Office format is different to check which way to send the strings.
    if ( Test-SingleLineStigFormat -CheckContent $CheckContent )
    {
        Get-RegistryValueNameFromSingleLineStig -CheckContent $CheckContent
    }
    else
    {
        Get-RegistryValueNameFromWindowsStig -CheckContent $CheckContent
    }
}

<#
    .SYNOPSIS
        Extract the registry value name from a string.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueNameFromWindowsStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    # Get the second index of the list, which should be the data type and remove spaces
    [string] $name = ( ( $CheckContent |
                Select-String -Pattern $script:registryRegularExpression.registryValueName ) -split ":" )[1]

    if ( -not [string]::IsNullOrEmpty( $name ) )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $true"

        $return = $name.trim()

        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Trimmed : $name"
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $false"
        return
    }

    return $return
}

<#
    .SYNOPSIS
        Looks for multiple patterns in the value string to extract out the value to return or determine
        if additional processing is required. For example if an allowable range detected, additional
        functions need to be called to convert the text into powershell operators.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueData
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    # The Office format is different to check which way to send the strings.
    switch ( $true )
    {
        { Test-SingleLineStigFormat -CheckContent $CheckContent }
        {
            return Get-RegistryValueDataFromSingleStig -CheckContent $CheckContent
        }
        default
        {
            $valueString = ( $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryValueData )
            return Get-RegistryValueDataFromWindowsStig -CheckContent $valueString
        }
    }
}

<#
    .SYNOPSIS
        Looks for multiple patterns in the value string to extract out the value to return or determine
        if additional processing is required. For example if an allowable range detected, additional
        functions need to be called to convert the text into powershell operators.

    .Parameter CheckContent
        An array of the raw sting data taken from the STIG setting.
#>
function Get-RegistryValueDataFromWindowsStig
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    <#
        Get the second index of the list, which should be the data and remove spaces# Get the second
        index of the list, which should be the data and remove spaces.
    #>
    [string] $initialData = ( $CheckContent -replace $script:registryRegularExpression.registryValueData )

    if ( -not [string]::IsNullOrEmpty( $initialData ) )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $true"

        $return = $initialData.trim()

        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Trimmed : $return"
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)]   Found : $false"
        # If the no data was found return, becasue there is nothing to further process.
        return
    }

    $return
}

<#
    .SYNOPSIS
        Checks if a string contains the literal word Blank

    .PARAMETER ValueDataString
        String from the STIG to check

    .NOTES
        This is an edge case function.
#>
function Test-RegistryValueDataIsBlank
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueDataString
    )
    <#
        There is an edge case that returns the string (Blank) with the expected return to be an
        empty string. No further processing is necessary, so simply return the empty string.
    #>
    if ( $ValueDataString -Match $script:regularExpression.blankString )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $true"
        return $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $false"
        return $false
    }
}

<#
    .SYNOPSIS
        Checks if a string contains the literal word Enabled or Disabled

    .PARAMETER ValueDataString
        String from the STIG to check

    .NOTES
        This is an edge case function.
#>
function Test-RegistryValueDataIsEnabledOrDisabled
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueDataString
    )
    <#
        Here is an edge case that returns the string (Blank) with the expected return to be an
        empty string. No further processing is necessary, so simply return the empty string.
    #>
    if ( $ValueDataString -Match $script:regularExpression.enabledOrDisabled )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $true"
        return $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $false"
        return $false
    }
}

<#
    .SYNOPSIS
        Checks if a string contains the literal word Enabled or Disabled

    .PARAMETER ValueDataString
        String from the STIG to check

    .NOTES
        This is an edge case function.
#>
function Get-ValidEnabledOrDisabled
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ValueType,

        [Parameter(Mandatory = $true)]
        [string]
        $ValueData
    )
    <#
        There is an edge case where Enabled|Disabled is used in place of the Dword int
        Get the integer value for the string, otherwise leave the data valuse as is.
    #>
    if ( $ValueType -eq 'Dword' -and -not (Test-IsValidDword -ValueData $ValueData) )
    {
        ConvertTo-ValidDword -ValueData $ValueData
    }
    else
    {
        $ValueData
    }
}

<#
    .SYNOPSIS
        Checks if a string contains a hexadecimal number

    .PARAMETER ValueDataString
        String from the STIG to check

    .NOTES
        This is an edge case function.
#>
function Test-RegistryValueDataIsHexCode
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueDataString
    )
    <#
        There is an edge case that returns the string (Blank) with the expected return to be an
        empty string. No further processing is necessary, so simply return the empty string.
    #>
    if ( $ValueDataString -Match $script:regularExpression.hexCode )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $true"
        return $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $false"
        return $false
    }
}

<#
    .SYNOPSIS
        Returns the integer of a hexadecimal number

    .PARAMETER ValueDataString
        String from the STIG to Convert

    .NOTES
        Extract the hex code if it exists, convert to int32 and set the output value. This ignores the
        int that usually accompanies the hex value in parentheses.
#>
function Get-IntegerFromHex
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ValueDataString
    )

    $ValueDataString -Match $script:regularExpression.hexCode | Out-Null

    try
    {
        [convert]::ToInt32($matches[0], 16)
    }
    catch
    {
        throw "Could not convert $($matches[0]) into an integer"
    }
}

<#
    .SYNOPSIS
        Checks if a string contains a hexadecimal number

    .PARAMETER ValueDataString
        String from the STIG to check

    .NOTES
        This will match any lines that start with an integer (of any length) as the value to be set
#>
function Test-RegistryValueDataIsInteger
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueDataString
    )

    if ( $ValueDataString -Match $script:regularExpression.leadingIntegerUnbound -and
            $ValueDataString -NotMatch $script:registryRegularExpression.hardenUncPathValues )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $true"
        return $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $false"
        return $false
    }
}

<#
    .SYNOPSIS
        Returns the number from a string

    .PARAMETER ValueDataString
        String from the STIG to Convert
#>
function Get-NumberFromString
{
    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ValueDataString
    )

    $string = Select-String -InputObject $ValueDataString `
                            -Pattern $script:regularExpression.leadingIntegerUnbound
    if($null -eq $string)
    {
        throw
    }
    else
    {
        return $string.Matches[0].Value
    }
}

<#
    .SYNOPSIS
        Determines if a STIG check has a range of valid options.

    .DESCRIPTION
        There are serveral instances where a STIG check allows for a range of compliant values. This
        function reads the value string of a registry entry and if it discovers a sentence structure
        that provides for more than one value and $true flag is returned. If a fixed value is found
        a $false bool is returned.

    .PARAMETER ValueDataString
        The string to be tested.

    .EXAMPLE
        This example turns $true
        Test-RegistryValueDataContainsRange -ValueDataString "Value: 0x00008000 (32768) (or greater)"

    .EXAMPLE
        This example turns $false
        Test-RegistryValueDataContainsRange -ValueDataString "Value: 1"

    .NOTES
        General notes
#>
function Test-RegistryValueDataContainsRange
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueDataString
    )

    # Is in a word boundary since it is a common pattern
    if ( $ValueDataString -match $script:registryRegularExpression.registryValueRange -and
         $ValueDataString -notmatch 'does not exist' )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $true"
        return $true
    }
    else
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] $false"
        return $false
    }
}

<#
    .SYNOPSIS
        Formats a string value into a multiline string by spliting it on a space or comma space format.

    .PARAMETER ValueDataString
        The registry value data string to split.

    .NOTES
        General notes
#>
function Format-MultiStringRegistryData
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ValueDataString
    )

    $regEx = "\s|,\s"

    Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Formatting Multi String Data"

    return ( $ValueDataString -split $regEx ) -join ";"
}

<#
    .SYNOPSIS
        Formats a string value into a multiline string by spliting it on a space or comma space foramt.

    .PARAMETER CheckStrings
        The registry value data string to split.

    .NOTES
        General notes
#>
function Get-MultiValueRegistryStringData
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckStrings
    )

    $multiStringEntries = [String]$CheckStrings |
        Select-String -Pattern $script:registryRegularExpression.MultiStringNamedPipe -AllMatches

    $multiStringList = @()
    foreach ( $entry in $multiStringEntries.Matches )
    {
        $multiStringList += $entry.Value.ToString().Trim()
    }

    return $multiStringList -join ";"
}

<#
    .SYNOPSIS
        Verifies that the discovered dword is an integer.

    .DESCRIPTION
        Dword registry data can only contain integers. This function provides a quick validation of
        the data that was extracted from the stig string to further increase the confidence of the
        conversion process.

    .PARAMETER ValueData
        The string to be tested.

    .EXAMPLE
        This example turns $true
        Test-IsValidDword -ValueData "3"

    .EXAMPLE
        This example turns $false
        Test-IsValidDword -ValueData "Three"

    .NOTES
        General notes
#>
function Test-IsValidDword
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]
        $ValueData
    )
    <#
        Since this is a simple validation function we only need to know if it is a valide integer.
        If .Net can't figure it out, neither can we.
    #>
    try
    {
        [void] [System.Convert]::ToInt32( $ValueData )
    }
    catch [System.Exception]
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Valid Dword : $false"
        return $false
    }

    Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Valid Dword : $true"
    return $true
}

<#
    .SYNOPSIS
        Convert a string field into the correct dword value.

    .DESCRIPTION
        Several STIG settings provide the dword value in text or enumation format
        This function converts the english text value back into a a bit flag the dword accepts.

    .PARAMETER ValueData
        The text string to convert.

    .EXAMPLE
        In this example the string value "Enabled" is converted into the integer 1 and returned

        ConvertTo-ValidDword -ValueData "Enabled"

    .NOTES
        General notes
#>
function ConvertTo-ValidDword
{
    [CmdletBinding()]
    [OutputType([int])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $ValueData
    )

    $conversionTable = @{
        Enabled  = 1
        Disabled = 0
    }

    <#
        There is an edge case the puts the data in the '1 (Enabled)' format
        pull out the string and convert it to the integer.
    #>
    $ValueData -Match $script:regularExpression.enabledOrDisabled | Out-Null

    $ValueData = $matches[0]
    if ( $null -ne $conversionTable.$ValueData )
    {
        Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Valid Dword : $conversionTable.$ValueData"
        $conversionTable.$ValueData
    }
    else
    {
        throw "'$ValueData' is not a valid dword enumeration."
    }
}

<#
    .SYNOPSIS
        There are several rules that publish multiple registry settings in a single rule.
        This function will check for multiple entries. Some of the entries have a single
        Hive or path and multiple values.

    .PARAMETER CheckContent
        The standard check content string to look for duplicate entries.

    .NOTES
        General notes
#>
function Test-MultipleRegistryEntries
{
    [CmdletBinding()]
    [OutputType([bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    if (Test-SingleLineStigFormat -CheckContent $CheckContent)
    {
        $matches = $CheckContent | Select-String -Pattern "(HKLM|HKCU)\\" -AllMatches

        if ($matches.Matches.Count -gt 1 -and $matches -match 'outlook\\security')
        {
            return $false
        }

        if ( $matches.Matches.Count -gt 1 )
        {
            return $true
        }

        return $false
    }
    else
    {
        [int] $hiveCount = ($CheckContent |
                Select-String -Pattern $script:registryRegularExpression.registryHive ).Count

        [int] $pathCount = ($CheckContent |
                Select-String -Pattern $script:registryRegularExpression.registryPath ).Count

        [int] $valueCount = ($CheckContent |
                Select-String -Pattern $script:registryRegularExpression.registryValueData ).Count

        [int] $valueNameCount = ($CheckContent |
                Select-String -Pattern $script:registryRegularExpression.registryValueName ).Count

        if ( ( $hiveCount + $pathCount + $valueCount + $valueNameCount ) -gt 4 )
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Multiple Entries : $true"
            return $true
        }
        else
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Multiple Entries : $false"
            return $false
        }
    }
}

<#
    .SYNOPSIS
        Splits multiple registry entries from a single check into individual check strings.

    .PARAMETER CheckContent
        The standard check content string to split.

    .NOTES
        General notes
#>
function Split-MultipleRegistryEntries
{
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        [Parameter(Mandatory = $true)]
        [psobject]
        $CheckContent
    )

    [int] $registryEntryCounter = 0
    [System.Collections.ArrayList] $registryEntries = @()

    if ( Test-SingleLineStigFormat -CheckContent $CheckContent )
    {
        $paths = $CheckContent | Select-String "(HKLM|HKCU)\\" -AllMatches

        if ( $paths.Matches.Count -gt 1 )
        {
            if ( $paths -match 'Procedure:' )
            {
                $paths = $($CheckContent -join " ") -Split "AND(\s*)Procedure:"
            }
            if ( $CheckContent -match 'Navigate to:' )
            {
                $keys = @()
                $paths = @()
                foreach ($line in $CheckContent)
                {
                    if ( $line -match '^(HKLM|HKCU)' )
                    {
                        $keys += $line
                    }
                    if ( $line -match 'REG_DWORD value' )
                    {
                        foreach ($key in $keys)
                        {
                            $add = $key, $line -join " "
                            $paths += $add
                        }
                        $keys = @()
                    }
                }
            }
        }

        if ($paths.Count -lt 2)
        {
            $paths = $paths -split " and "
        }
        foreach ($path in $paths)
        {
            if (![string]::IsNullOrWhiteSpace($path))
            {
                [void] $registryEntries.Add( $path )
                $registryEntryCounter ++
            }
        }
    }
    else
    {
        $hives  = $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryHive
        $paths  = $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryPath
        $types  = $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryEntryType
        $names  = $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryValueName
        $values = $CheckContent | Select-String -Pattern $script:registryRegularExpression.registryValueData

        # If a check contains a multiple registry hives, then reference each one that is discovered.
        if ( $hives.Count -gt 1 )
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Hives : $($hives.Count)"

            foreach ( $registryRule in $hives )
            {
                $newSplitRegistryEntry = @(
                    $hives[$registryEntryCounter],
                    $paths[$registryEntryCounter],
                    $types[$registryEntryCounter],
                    $names[$registryEntryCounter],
                    $values[$registryEntryCounter]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
        <#
            If a check contains only the registry hive, but have multiple/unique paths,type,names,and values, then reference the single
            hive for each path that is discovered.
        #>
        elseIf ( $paths.count -gt 1 -and $types.count -eq 1 -and $names.count -eq 1 -and $values.count -eq 1 )
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Paths : $($paths.count)"

            foreach ($registryRule in $paths)
            {
                $newSplitRegistryEntry = @(
                    $hives[0],
                    $paths[$registryEntryCounter],
                    $types[0],
                    $names[0],
                    $values[0]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
        <#
            If a check contains a single registry hive, path, type, and value, but multiple value names, then reference
            the single hive hive, path, type, and value for each value name that is discovered.
        #>
        elseIf ( $names.count -gt 1 -and $types.count -eq 1 -and $values.count -eq 1 )
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Values : $($names.count)"

            foreach ($registryRule in $names)
            {
                $newSplitRegistryEntry = @(
                    $hives[0],
                    $paths[0],
                    $types[0],
                    $names[$registryEntryCounter],
                    $values[0]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
        <#
            If a check contains a single registry hive and path, but multiple values, then reference
            the single hive and path for each value name that is discovered.
        #>
        elseIf ( $names.count -gt 1 -and $types.count -gt 1 )
        {
            Write-Verbose -Message "[$($MyInvocation.MyCommand.Name)] Values : $($names.count)"

            foreach ($registryRule in $names)
            {
                $newSplitRegistryEntry = @(
                    $hives[0],
                    $paths[0],
                    $types[$registryEntryCounter],
                    $names[$registryEntryCounter],
                    $values[$registryEntryCounter]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
        elseIf ( $hives.count -eq 1 -and $paths.count -gt 1 -and $types.count -eq 1 -and $names.count -eq 1 -and $values.count -eq 1 )
        {
            foreach ( $registryRule in $names )
            {
                $newSplitRegistryEntry = @(
                    $hives[0],
                    $paths[$registryEntryCounter],
                    $types[0],
                    $names[0],
                    $values[0]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
        elseIf ( $hives.count -eq 1 -and $paths.count -eq 1 -and $types.count -eq 1 -and $names.count -gt 1 -and $values.count -gt 1 )
        {
            foreach ( $registryRule in $values )
            {
                $newSplitRegistryEntry = @(
                    $hives[0],
                    $paths[0],
                    $types[0],
                    $names[$registryEntryCounter],
                    $values[$registryEntryCounter]) -join "`r`n"

                [void] $registryEntries.Add( $newSplitRegistryEntry )
                $registryEntryCounter ++
            }
        }
    }

    return $registryEntries
}
#endregion
