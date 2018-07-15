# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#region Header

#endregion
#region Main Function
<#
    .SYNOPSIS
        This function generates a new xml file based on the convert objects from ConvertFrom-StigXccdf.

    .PARAMETER Path
        The full path to the xccdf to convert.

    .PARAMETER Destination
        The full path to save the converted xml to.

    .PARAMETER CreateOrgSettingsFile
        Creates the orginazational settings files associated with the version of the STIG.

    .PARAMETER IncludeRawString
        Adds the check-content elemet content to the converted object.
#>
function ConvertTo-PowerStigXml
{
    [CmdletBinding()]
    [OutputType([xml])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter()]
        [string]
        $Destination,

        [parameter()]
        [switch]
        $CreateOrgSettingsFile,

        [parameter()]
        [switch]
        $IncludeRawString
    )
    Begin
    {
        $CurrentVerbosePreference = $global:VerbosePreference

        if ($PSBoundParameters.ContainsKey('Verbose'))
        {
            $global:VerbosePreference = 'Continue'
        }
    }
    Process
    {
        $convertedStigObjects = ConvertFrom-StigXccdf -Path $Path -IncludeRawString:$IncludeRawString

        # Get the raw xccdf xml to pull additional details from the root node.
        [xml] $xccdfXml = Get-Content -Path $Path -Encoding UTF8
        [version] $stigVersionNumber = Get-StigVersionNumber -stigDetails $xccdfXml

        $ruleTypeList = Get-RuleTypeList -StigSettings $convertedStigObjects

        # Start the XML doc and add the root element
        $xmlDocument = [System.XML.XMLDocument]::New()
        [System.XML.XMLElement] $xmlRoot = $xmlDocument.CreateElement( $xmlElement.stigConvertRoot )

        # Append as child to an existing node. This method will 'leak' an object out of the function
        # so DO NOT remove the [void]
        [void] $xmlDocument.appendChild( $xmlRoot )
        $xmlRoot.SetAttribute( $xmlAttribute.stigId , $xccdfXml.Benchmark.ID )

        # Set the version and creation attributes in the output file.
        $xmlRoot.SetAttribute( $xmlAttribute.stigVersion, $stigVersionNumber )
        $xmlRoot.SetAttribute( $xmlAttribute.stigConvertCreated, $(Get-Date).ToShortDateString() )

        # Add the STIG types as child elements
        foreach ( $ruleType in $ruleTypeList )
        {
            # Create the rule type node
            [System.XML.XMLElement] $xmlRuleType = $xmlDocument.CreateElement( $ruleType )

            # Append as child to an existing node. DO NOT remove the [void]
            [void] $xmlRoot.appendChild( $xmlRuleType )
            $XmlRuleType.SetAttribute( $xmlattribute.ruleDscResourceModule, $DscResourceModule.$ruleType )

            # Get the rules for the current STIG type.
            $rules = $convertedStigObjects | Where-Object { $PSItem.GetType().ToString() -eq $ruleType }

            # Get the list of properties of the current object type to use as child elements
            [System.Collections.ArrayList] $properties = $rules |
                Get-Member |
                Where-Object MemberType -eq Property |
                Select-Object Name -ExpandProperty Name

            <#
                The $properties array is used to set the child elements of the rule. Remove the base
                class properties from the array list that we do not want added as child elements.
            #>
            $propertiesToRemove = @($xmlattribute.ruleId, $xmlattribute.ruleSeverity,
                $xmlattribute.ruleConversionStatus, $xmlattribute.ruleTitle,
                $xmlattribute.ruleDscResource)

            # Remove the raw string from the output if it was not requested.
            if ( -not $IncludeRawString )
            {
                $propertiesToRemove += 'RawString'
            }

            # These properties are removed becasue they are attributes of the object, not elements
            foreach ($propertyToRemove in $propertiesToRemove)
            {
                [void] $properties.Remove( $propertyToRemove )
            }

            # Add the STIG details to the xml document.
            foreach ( $rule in $rules )
            {
                [System.XML.XMLElement] $xmlRuleTypeProperty = $xmlDocument.CreateElement( 'Rule' )
                # Append as child to an existing node. DO NOT remove the [void]
                [void] $xmlRuleType.appendChild( $xmlRuleTypeProperty )
                # Set the base class properties
                $xmlRuleTypeProperty.SetAttribute( $xmlattribute.ruleId, $rule.ID )
                $xmlRuleTypeProperty.SetAttribute( $xmlattribute.ruleSeverity, $rule.severity )
                $xmlRuleTypeProperty.SetAttribute( $xmlattribute.ruleConversionStatus, $rule.conversionstatus )
                $xmlRuleTypeProperty.SetAttribute( $xmlattribute.ruleTitle, $rule.title )
                $xmlRuleTypeProperty.SetAttribute( $xmlattribute.ruleDscResource, $rule.dscresource )

                foreach ( $property in $properties )
                {
                    [System.XML.XMLElement] $xmlRuleTypePropertyUnique = $xmlDocument.CreateElement( $property )
                    # Append as child to an existing node. DO NOT remove the [void]
                    [void] $xmlRuleTypeProperty.appendChild( $xmlRuleTypePropertyUnique )

                    # Skip any blank vaules
                    if ($null -eq $rule.$property)
                    {
                        continue
                    }
                    <#
                    The Permission rule returns an ACE list that needs to be serialized on a second
                    level. This will pick that up and expand the object in the xml.
                #>
                if ($property -eq 'AccessControlEntry')
                {
                    foreach ($ace in $rule.$property)
                    {
                        [System.XML.XMLElement] $aceEntry = $xmlDocument.CreateElement( 'Entry' )
                        [void] $xmlRuleTypePropertyUnique.appendChild( $aceEntry )

                        # Add the ace entry Type
                        [System.XML.XMLElement] $aceEntryType = $xmlDocument.CreateElement( 'Type' )
                        [void] $aceEntry.appendChild( $aceEntryType )
                        $aceEntryType.InnerText = $ace.Type

                        # Add the ace entry Principal
                        [System.XML.XMLElement] $aceEntryPrincipal = $xmlDocument.CreateElement( 'Principal' )
                        [void] $aceEntry.appendChild( $aceEntryPrincipal )
                        $aceEntryPrincipal.InnerText = $ace.Principal

                        # Add the ace entry Principal
                        [System.XML.XMLElement] $aceEntryForcePrincipal = $xmlDocument.CreateElement( 'ForcePrincipal' )
                        [void] $aceEntry.appendChild( $aceEntryForcePrincipal )
                        $aceEntryForcePrincipal.InnerText = $ace.ForcePrincipal

                        # Add the ace entry Inheritance flag
                        [System.XML.XMLElement] $aceEntryInheritance = $xmlDocument.CreateElement( 'Inheritance' )
                        [void] $aceEntry.appendChild( $aceEntryInheritance )
                        $aceEntryInheritance.InnerText = $ace.Inheritance

                        # Add the ace entery FileSystemRights
                        [System.XML.XMLElement] $aceEntryRights = $xmlDocument.CreateElement( 'Rights' )
                        [void] $aceEntry.appendChild( $aceEntryRights )
                        $aceEntryRights.InnerText = $ace.Rights
                    }
                }
                elseif ($property -eq 'LogCustomFieldEntry')
                {
                    foreach ($entry in $rule.$property)
                    {
                        [System.XML.XMLElement] $logCustomFieldEntry = $xmlDocument.CreateElement( 'Entry' )
                        [void] $xmlRuleTypePropertyUnique.appendChild( $logCustomFieldEntry )

                        [System.XML.XMLElement] $entrySourceType = $xmlDocument.CreateElement( 'SourceType' )
                        [void] $logCustomFieldEntry.appendChild( $entrySourceType )
                        $entrySourceType.InnerText = $entry.SourceType

                        [System.XML.XMLElement] $entrySourceName = $xmlDocument.CreateElement( 'SourceName' )
                        [void] $logCustomFieldEntry.appendChild( $entrySourceName )
                        $entrySourceName.InnerText = $entry.SourceName
                    }
                }
                else
                    {
                        $xmlRuleTypePropertyUnique.InnerText = $rule.$property
                    }
                }
            }
        }

        $OutPath = Get-OutputFileRoot -Path $Path -Destination $Destination
        $convertStigPath = "$OutPath.xml"
        $OrgSettingsPath = "$OutPath.org.xml"

        try
        {
            $xmlDocument.save( $convertStigPath )
        }
        catch [System.Exception]
        {
            Write-Error -Message $error[0]
        }

        Write-Output "Converted Output: $convertStigPath"

        if ($CreateOrgSettingsFile)
        {
            $OrganizationalSettingsXmlFileParameters = @{
                'convertedStigObjects' = $convertedStigObjects
                'StigVersionNumber'    = $stigVersionNumber
                'Destination'          = $OrgSettingsPath
            }
            New-OrganizationalSettingsXmlFile @OrganizationalSettingsXmlFileParameters

            Write-Output "Org Settings Output: $OrgSettingsPath"
        }
    }
    End
    {
        $global:VerbosePreference = $CurrentVerbosePreference
    }
}

<#
    .SYNOPSIS
        Compares the converted xml files from ConvertFrom-StigXccdf.

    .PARAMETER OldStigPath
        The full path to the previous PowerStigXml file to convert.

    .PARAMETER NewStigPath
        The full path to the current PowerStigXml file to convert.
#>
function Compare-PowerStigXml
{
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $OldStigPath,

        [parameter(Mandatory = $true)]
        [string]
        $NewStigPath,

        [parameter()]
        [switch]
        $ignoreRawString
    )
    Begin
    {
        $CurrentVerbosePreference = $global:VerbosePreference

        if ($PSBoundParameters.ContainsKey('Verbose'))
        {
            $global:VerbosePreference = 'Continue'
        }
    }
    Process
    {

        [xml] $OldStigContent = Get-Content -Path $OldStigPath -Encoding UTF8
        [xml] $NewStigContent = Get-Content -Path $NewStigPath -Encoding UTF8

        $rules = $OldStigContent.DISASTIG.ChildNodes.ToString() -split "\s"

        $returnCompareList = @{}
        $compareObjects = @()
        $propsToIgnore = @()
        if ($ignoreRawString)
        {
            $propsToIgnore += "rawString"
        }
        foreach ( $rule in $rules )
        {
            $OldStigXml = Select-Xml -Xml $OldStigContent -XPath "//$rule/*"
            $NewStigXml = Select-Xml -Xml $NewStigContent -XPath "//$rule/*"

            if ($OldStigXml.Count -lt 2)
            {
                $prop = (Get-Member -MemberType Properties -InputObject $OldStigXml.Node).Name
            }
            else
            {
                $prop = (Get-Member -MemberType Properties -InputObject $OldStigXml.Node[0]).Name
            }
            $OldStigXml = $OldStigXml.Node | Select-Object $prop -ExcludeProperty $propsToIgnore

            if ($NewStigXml.Count -lt 2)
            {
                $prop = (Get-Member -MemberType Properties -InputObject $NewStigXml.Node).Name
            }
            else
            {
                $prop = (Get-Member -MemberType Properties -InputObject $NewStigXml.Node[0]).Name
            }
            $NewStigXml = $NewStigXml.Node | Select-Object $prop -ExcludeProperty $propsToIgnore

            $compareObjects += Compare-Object -ReferenceObject $OldStigXml -DifferenceObject $NewStigXml -Property $prop
        }

        $compareIdList = $compareObjects.Id

        foreach ($stig in $compareObjects)
        {
            $compareIdListFilter = $compareIdList |
                Where-Object {$PSitem -eq $stig.Id}

            if ($compareIdListFilter.Count -gt "1")
            {
                $delta = "changed"
            }
            else
            {
                if ($stig.SideIndicator -eq "=>")
                {
                    $delta = "added"
                }
                elseif ($stig.SideIndicator -eq "<=")
                {
                    $delta = "deleted"
                }
            }

            if ( -not $returnCompareList.ContainsKey($stig.Id))
            {
                [void] $returnCompareList.Add($stig.Id, $delta)
            }
        }
        $returnCompareList.GetEnumerator() | Sort-Object Name
    }
    End
    {
        $global:VerbosePreference = $CurrentVerbosePreference
    }
}
#endregion

#region Private Functions
$organizationalSettingRootComment = @'

    The organizational settings file is used to define the local organizations
    preferred setting within an allowed range of the STIG.

    Each setting in this file is linked by STIG ID and the valid range is in an
    associated comment.

'@

<#
    .SYNOPSIS
        Creates the Organizational settings file that accompanies the converted STIG data.

    .PARAMETER convertedStigObjects
        The Converted Stig Objects to sort through

    .PARAMETER StigVersionNumber
        The version number of the xccdf that is being processed.

    .PARAMETER Destination
        The path to store the output file.
#>
function New-OrganizationalSettingsXmlFile
{
    [CmdletBinding()]
    [OutputType()]
    param
    (
        [parameter(Mandatory = $true)]
        [psobject]
        $ConvertedStigObjects,

        [parameter(Mandatory = $true)]
        [version]
        $StigVersionNumber,

        [parameter(Mandatory = $true)]
        [string]
        $Destination
    )

    $orgSettings = Get-StigObjectsWithOrgSettings -ConvertedStigObjects $ConvertedStigObjects

    $xmlDocument = [System.XML.XMLDocument]::New()

    ##############################   Root object   ###################################
    [System.XML.XMLElement] $xmlRootElement = $xmlDocument.CreateElement(
        $xmlElement.organizationalSettingRoot )

    [void] $xmlDocument.appendChild( $xmlRootElement )
    [void] $xmlRootElement.SetAttribute( $xmlAttribute.stigVersion, $StigVersionNumber )

    $rootComment = $xmlDocument.CreateComment( $organizationalSettingRootComment )
    [void] $xmlDocument.InsertBefore( $rootComment, $xmlRootElement )

    #########################################   Root object   ##########################################
    #########################################    ID object    ##########################################

    foreach ( $orgSetting in $orgSettings)
    {
        [System.XML.XMLElement] $xmlSettingChildElement = $xmlDocument.CreateElement(
            $xmlElement.organizationalSettingChild )

        [void] $xmlRootElement.appendChild( $xmlSettingChildElement )

        $xmlSettingChildElement.SetAttribute( $xmlAttribute.ruleId , $orgSetting.id )

        $xmlSettingChildElement.SetAttribute( $xmlAttribute.organizationalSettingValue , "LOCAL_STIG_SETTING_HERE")

        $settingComment = " Ensure $(($orgSetting.OrganizationValueTestString) -f "'$($orgSetting.Id)'")"

        $rangeNameComment = $xmlDocument.CreateComment($settingComment)
        [void] $xmlRootElement.InsertBefore($rangeNameComment, $xmlSettingChildElement)
    }
    #########################################    ID object    ##########################################

    $xmlDocument.Save( $Destination )
}

<#
    .SYNOPSIS
        Creates a version number from the xccdf benchmark element details.

    .PARAMETER stigDetails
        A reference to the in memory xml document.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-StigVersionNumber
{
    [CmdletBinding()]
    [OutputType([version])]
    param
    (
        [parameter(Mandatory = $true)]
        [xml]
        $stigDetails
    )

    # Extract the revision number from the xccdf
    $revision = ( $stigDetails.Benchmark.'plain-text'.'#text' `
            -split "(Release:)(.*?)(Benchmark)" )[2].trim()

    "$($stigDetails.Benchmark.version).$revision"
}

<#
    .SYNOPSIS
        Filters the lsit of STIG objects and returns anything that requires an organizational desicion.

    .PARAMETER convertedStigObjects
        A reference to the object that contains the converted stig data.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-StigObjectsWithOrgSettings
{
    [CmdletBinding()]
    [OutputType([psobject])]
    param
    (
        [parameter(Mandatory = $true)]
        [psobject]
        $ConvertedStigObjects
    )

    $ConvertedStigObjects |
        Where-Object { $PSitem.OrganizationValueRequired -eq $true}
}

<#
    .SYNOPSIS
        Gets the target folder name in the composite based on the xccdf title.

    .PARAMETER Path
        A reference to the xccdf that was converted.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-CompositeTargetFolder
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path
    )

    [xml] $xccdf = Get-Content -Path $path -Encoding UTF8

    Switch ($xccdf.Benchmark.title)
    {
        {$PSItem -match '(?=.*Windows)(?=.*Domain(\s*)Controller)'}
        {return 'WindowsServerDC'}
        {$PSItem -match '(?=.*Windows)(?=.*Member(\s*)Server)'}
        {return 'WindowsServerMS'}
    }

}

<#
    .SYNOPSIS
        Filters the lsit of STIG objects and returns anything that requires an organizational desicion.

    .PARAMETER Path
        A reference to the object that contains the converted stig data.

    .PARAMETER Destination
        A reference to the object that contains the converted stig data.

    .NOTES
        This function should only be called from the public ConvertTo-DscStigXml function.
#>
function Get-OutputFileRoot
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [parameter(Mandatory = $true)]
        [string]
        $Path,

        [parameter()]
        [string]
        $Destination
    )

    $outFileNameRoot = ( Split-Path $Path -Leaf ) -replace '_Manual-xccdf.xml', ''

    $CompositeStigDscIsFound = Get-Module -ListAvailable CompositeStigDsc -Verbose:$false

    if ($CompositeStigDscIsFound -and -not $Destination)
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to Composite Resource"
        $CompositeTargetFolder = Get-CompositeTargetFolder -Path $Path
        $OutPath = "$($CompositeStigDscIsFound.ModuleBase)\DscResources\$CompositeTargetFolder\stigData"
    }
    elseif ($Destination)
    {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to $Destination"
        $OutPath = $Destination
    }
    else
    {
        $sourceFilePath = ( Split-Path $Path -Parent )
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Adding file to local directory $sourceFilePath"
        $OutPath = "$sourceFilePath"
    }

    if (Test-Path $OutPath)
    {
        "$OutPath\$outFileNameRoot"
    }
    else
    {
        throw "$OutPath was not found"
    }
}
#endregion
