# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
# Header

<#
    .SYNOPSIS
        Automatically creates a STIG Viewer checklist from DSC results (DscResults) or a compiled MOF (ReferenceConfiguration) parameter for a single endpoint.
        The function will test based upon the passed in STIG file or files (XccdfPath) parameter.
        Manual entries in the checklist can be injected from a ManualChecklistEntriesFile file.

    .PARAMETER ReferenceConfiguration
        A MOF that was compiled with a PowerStig composite.
        This parameter supports an alias of 'MofFile'

    .PARAMETER DscResults
        The results of Test-DscConfiguration or DSC report server output for a node. This can also be data retrieved from a DSC pull server with
        some modifications. See the PowerSTIG wiki for more information.

    .PARAMETER XccdfPath
        The path to a DISA STIG .xccdf file. PowerSTIG includes the supported files in the /PowerShell/StigData/Archive folder.

    .PARAMETER OutputPath
        The location where the checklist .ckl file will be created. Must include the filename with .ckl on the end.

    .PARAMETER ManualChecklistEntriesFile
        Location of a .xml file containing the input for Vulnerabilities unmanaged via DSC/PowerSTIG.

        This file can be created manually or by exporting an Excel worksheet as XML. The file format should look like the following:

        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <stigManualChecklistData>
        <stigRuleData>
            <STIG>U_Windows_Firewall_STIG_V1R7_Manual-xccdf.xml</STIG>
            <ID>V-36440</ID>
            <Status>NotAFinding</Status>
            <Comments>Not Applicable</Comments>
            <Details>This machine is not part of a domain, so this rule does not apply.</Details>
        </stigRuleData>

        See a sample at /PowerShell/StigData/Samples/ManualChecklistEntriesFileSample.xml.

    .EXAMPLE
        Generate a checklist for single STIG using a .MOF file:

        $ReferenceConfiguration = 'C:\contoso.local.mof'
        $xccdfPath = 'C:\SQL Server\U_MS_SQL_Server_2016_Instance_STIG_V1R7_Manual-xccdf.xml'
        $outputPath = 'C:\SqlServerInstance_2016_V1R7_STIG_config_mof.ckl'
        $ManualChecklistEntriesFile = 'C:\ManualChecklistEntriesFileExcelExport.xml'
        New-StigCheckList -ReferenceConfiguration $ReferenceConfiguration -XccdfPath $XccdfPath -OutputPath $outputPath -ManualChecklistEntriesFile $ManualChecklistEntriesFile

    .EXAMPLE
        Generate a checklist for a single STIG using DSC results obtained from Test-DscConfiguration:

        $audit = Test-DscConfiguration -ComputerName localhost -ReferenceConfiguration 'C:\Dev\Utilities\SqlServerInstance_config\localhost.mof'
        $xccdfPath = 'C:\U_MS_SQL_Server_2016_Instance_STIG_V1R7_Manual-xccdf.xml'
        $outputPath = 'C:\SqlServerInstance_2016_V1R7_STIG_config_dscresults.ckl'
        $ManualChecklistEntriesFile = 'C:\ManualChecklistEntriesFileSQL2016Instance.xml'
        New-StigCheckList -DscResult $audit -XccdfPath $xccdfPath -OutputPath $outputPath -ManualChecklistEntriesFile $ManualChecklistEntriesFile

    .EXAMPLE
        Generate a checklist for multiple STIGs for an endpoint using a .MOF file and a file containing STIGs to check:

        $XccdfPath = Get-Content 'C:\ChecklistSTIGFiles.txt'
        $outputPath = 'C:\SqlServer01_mof.ckl'
        $ManualChecklistEntriesFile = 'C:\ManualChecklistEntriesFileSqlServer01ExcelExport.xml'
        New-StigCheckList -DscResults $auditRehydrated -XccdfPath $XccdfPath -OutputPath $outputPath -ManualChecklistEntriesFile $ManualChecklistEntriesFile

    .EXAMPLE
        Generate a checklist for multiple STIGs for an endpoint using DSC results obtained from Test-DscConfiguration, dehydrated/rehydrated using CLIXML:

        $audit = Test-DscConfiguration -ComputerName localhost -MofFile 'C:\localhost.mof'
        $audit | Export-Clixml 'C:\TestDSC.xml'

        $auditRehydrated = import-clixml C:\TestDSC.xml
        $XccdfPath = 'C:\STIGS\SQL Server\U_MS_SQL_Server_2016_Instance_STIG_V1R7_Manual-xccdf.xml','C:\STIGS\Windows.Server.2012R2\U_MS_Windows_2012_and_2012_R2_DC_STIG_V2R19_Manual-xccdf.xml'
        $outputPath = 'C:\SqlServer01_dsc.ckl'
        $ManualChecklistEntriesFile = 'C:\ManualChecklistEntriesFileSqlServer01ExcelExport.xml'

        New-StigCheckList -DscResults $auditRehydrated -XccdfPath $XccdfPath -OutputPath $outputPath -ManualChecklistEntriesFile $ManualChecklistEntriesFile
#>
function New-StigCheckList
{
    [CmdletBinding()]
    [OutputType([XML])]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'mof')]
        [Alias('MofFile')]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                if (Test-Path -Path $_ -PathType Leaf)
                {
                    return $true
                }
                else
                {
                    throw "$($_) is not a valid path to a reference configuration (.mof) file. Provide a full valid path and filename."
                }
            }
        )]
        [String]
        $ReferenceConfiguration,

        [Parameter(Mandatory = $true, ParameterSetName = 'dsc')]
        [PSObject]
        $DscResults,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                foreach ($filename in $_)
                {
                    if (Test-Path -Path $filename -PathType Leaf)
                    {
                        return $true
                    }
                    else
                    {
                        throw "$($filename) is not a valid path to a DISA STIG .xccdf file. Provide a full valid path and filename."
                    }
                }
            }
        )]
        [String[]]
        $XccdfPath,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                if (Test-Path -Path $_ -PathType Leaf)
                {
                    return $true
                }
                else
                {
                    throw "$($_) is not a valid path to a Manual Checklist Entries File file. Provide a full valid path and filename."
                }
            }
        )]
        [String]
        $ManualChecklistEntriesFile,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript(
            {
                if (Test-Path -Path $_.DirectoryName -PathType Container)
                {
                    return $true
                }
                else
                {
                    throw "$($_) is not a valid directory. Please provide a valid directory."
                }
                if ($_.Extension -ne '.ckl')
                {
                    throw "$($_.FullName) is not a valid checklist extension. Please provide a full valid path ending in .ckl"
                }
                else
                {
                    return $true
                }
            }
        )]
        [System.IO.FileInfo]
        $OutputPath,

        [Parameter()]
        [String]
        $Verifier,

        [Parameter()]
        [Switch]
        $IncludeLocalHostData
    )

    if ($PSBoundParameters.ContainsKey('ManualChecklistEntriesFile'))
    {
        $manualCheckData = ConvertTo-ManualCheckListHashTable -Path $ManualChecklistEntriesFile -XccdfPath $XccdfPath
    }

    # Values for some of these fields can be read from the .mof file or the DSC results file
    if ($PSCmdlet.ParameterSetName -eq 'mof')
    {
        $mofString = Get-Content -Path $ReferenceConfiguration -Raw
        $targetNode = Get-TargetNodeFromMof -MofString $mofString
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'dsc')
    {
        # Check the returned object
        if ($null -eq $DscResults)
        {
            throw 'Passed in $DscResults parameter is null. Please provide a valid result using Test-DscConfiguration.'
        }

        $targetNode = $DscResults.PSComputerName
    }

    $statusMap = @{
        NotReviewed   = 'Not_Reviewed'
        Open          = 'Open'
        NotAFinding   = 'NotAFinding'
        NotApplicable = 'Not_Applicable'
    }

    $targetNodeType = Get-TargetNodeType -TargetNode $targetNode

    switch ($targetNodeType)
    {
        "MACAddress"
        {
            $HostnameMACAddress = $targetNode
            break
        }
        "IPv4Address"
        {
            $HostnameIPAddress = $targetNode
            break
        }
        "IPv6Address"
        {
            $HostnameIPAddress = $targetNode
            break
        }
        "FQDN"
        {
            $HostnameFQDN = $targetNode
            break
        }
        default
        {
            $Hostname = $targetNode
        }
    }

    $xmlWriterSettings = [System.Xml.XmlWriterSettings]::new()
    $xmlWriterSettings.Indent = $true
    $xmlWriterSettings.IndentChars = "`t"
    $xmlWriterSettings.NewLineChars = "`n"
    $writer = [System.Xml.XmlWriter]::Create($OutputPath.FullName, $xmlWriterSettings)
    $writer.WriteStartElement('CHECKLIST')
    $writer.WriteStartElement("ASSET")

    if ($IncludeLocalHostData)
    {
        try
        {
            $localHostData      = Invoke-Command -Computername $hostName -ErrorAction 'Stop' -Scriptblock {
                return @{
                    MacAddress  = ((Get-NetAdapter -Physical | Where-Object -Property 'Status' -eq 'Up')[0]).MacAddress
                    IpAddress   = ((Get-NetIPAddress -AddressFamily IPV4 | Where-Object -Property IpAddress -notlike "127.*")[0]).IPAddress
                    Fqdn        = [System.Net.DNS]::GetHostByName($env:ComputerName).HostName
                }
            }
        }
        catch
        {
            Write-Warning "Unable to Obtain local IP/MAC Addresses."
        }
    }

    $assetElements = [ordered] @{
        'ROLE'            = 'None'
        'ASSET_TYPE'      = 'Computing'
        'HOST_NAME'       = "$Hostname"
        'HOST_IP'         = "$($localHostData.IpAddress)"
        'HOST_MAC'        = "$($localHostData.MacAddress)"
        'HOST_FQDN'       = "$($localHostData.Fqdn)"
        'TECH_AREA'       = ''
        'TARGET_KEY'      = '2350'
        'WEB_OR_DATABASE' = 'false'
        'WEB_DB_SITE'     = ''
        'WEB_DB_INSTANCE' = ''
    }

    foreach ($assetElement in $assetElements.GetEnumerator())
    {
        $writer.WriteStartElement($assetElement.name)
        $writer.WriteString($assetElement.value)
        $writer.WriteEndElement()
    }

    $writer.WriteEndElement(<#ASSET#>)

    #region STIGS
    $writer.WriteStartElement("STIGS")

    #region STIG_iteration
    foreach ($xccdfPathItem in $XccdfPath)
    {

        $writer.WriteStartElement("iSTIG")

        #region iSTIG/STIG_INFO

        $writer.WriteStartElement("STIG_INFO")

        $xccdfBenchmarkContent = Get-StigXccdfBenchmarkContent -Path $XccdfPathItem

        $stigInfoElements = [ordered] @{
            'version'        = $xccdfBenchmarkContent.version
            'classification' = 'UNCLASSIFIED'
            'customname'     = ''
            'stigid'         = $xccdfBenchmarkContent.id
            'description'    = $xccdfBenchmarkContent.description
            'filename'       = Split-Path -Path $xccdfPathItem -Leaf
            'releaseinfo'    = $xccdfBenchmarkContent.'plain-text'.InnerText
            'title'          = $xccdfBenchmarkContent.title
            'uuid'           = (New-Guid).Guid
            'notice'         = $xccdfBenchmarkContent.notice.InnerText
            'source'         = $xccdfBenchmarkContent.reference.source
        }

        foreach ($stigInfoElement in $stigInfoElements.GetEnumerator())
        {
            $writer.WriteStartElement("SI_DATA")
            $writer.WriteStartElement('SID_NAME')
            $writer.WriteString($stigInfoElement.name)
            $writer.WriteEndElement(<#SID_NAME#>)
            $writer.WriteStartElement('SID_DATA')
            $writer.WriteString($stigInfoElement.value)
            $writer.WriteEndElement(<#SID_DATA#>)
            $writer.WriteEndElement(<#SI_DATA#>)
        }

        $writer.WriteEndElement(<#STIG_INFO#>)

        #endregion STIGS/iSTIG/STIG_INFO

        #region STIGS/iSTIG/VULN[]

        # Parse out the STIG file name for lookups
        $stigPathFileName = $XccdfPathItem.Split('\\')
        $stigFileName = $stigPathFileName[$stigPathFileName.Length-1]

        # Pull in the processed XML file to check for duplicate rules for each vulnerability
        [XML] $xccdfBenchmark = Get-Content -Path $xccdfPathItem -Encoding UTF8
        $fileList = Get-PowerStigFileList -StigDetails $xccdfBenchmark -Path $XccdfPathItem
        $processedFileName = $fileList.Settings.FullName
        [XML] $processed = Get-Content -Path $processedFileName

        $vulnerabilities = Get-VulnerabilityList -XccdfBenchmark $xccdfBenchmarkContent

        foreach ($vulnerability in $vulnerabilities)
        {
            $writer.WriteStartElement("VULN")

            foreach ($attribute in $vulnerability.GetEnumerator())
            {
                $status = $null
                $findingDetails = $null
                $comments = $null
                $manualCheck = $null

                if ($attribute.Name -eq 'Vuln_Num')
                {
                    $vid = $attribute.Value
                }

                $writer.WriteStartElement("STIG_DATA")

                $writer.WriteStartElement("VULN_ATTRIBUTE")
                $writer.WriteString($attribute.Name)
                $writer.WriteEndElement(<#VULN_ATTRIBUTE#>)

                $writer.WriteStartElement("ATTRIBUTE_DATA")
                $writer.WriteString($attribute.Value)
                $writer.WriteEndElement(<#ATTRIBUTE_DATA#>)

                $writer.WriteEndElement(<#STIG_DATA#>)
            }

            if ($PSCmdlet.ParameterSetName -eq 'mof')
            {
                $setting = Get-SettingsFromMof -ReferenceConfiguration $ReferenceConfiguration -Id $vid
                $manualCheck = $manualCheckData | Where-Object -FilterScript {$_.STIG -eq $stigFileName -and $_.ID -eq $vid}
                if ($setting)
                {
                    $status = $statusMap['Open']
                    $comments = "To be addressed by PowerStig MOF via $setting"
                    $findingDetails = Get-FindingDetails -Setting $setting

                }
                elseif ($manualCheck)
                {
                    $status = $statusMap["$($manualCheck.Status)"]
                    $findingDetails = $manualCheck.Details
                    $comments = $manualCheck.Comments
                }
                else
                {
                    $status = $statusMap['NotReviewed']
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'dsc')
            {
                $manualCheck = $manualCheckData | Where-Object -FilterScript {$_.STIG -eq $stigFileName -and $_.ID -eq $vid}
                if ($manualCheck)
                {
                    $status = $statusMap["$($manualCheck.Status)"]
                    $findingDetails = $manualCheck.Details
                    $comments = $manualCheck.Comments
                }
                else
                {
                    $setting = Get-SettingsFromResult -DscResults $DscResults -Id $vid
                    if ($setting)
                    {
                        if ($setting.InDesiredState -eq $true)
                        {
                            $status = $statusMap['NotAFinding']
                            if ($PSBoundParameters.ContainsKey('Verifier'))
                            {
                                $comments = "Addressed by PowerStig MOF via {0} and verified by {1}" -f $setting, $Verifier
                            }
                            else
                            {
                                $comments = "Addressed by PowerStig MOF via $setting"
                            }

                            $findingDetails = Get-FindingDetails -Setting $setting
                        }
                        elseif ($setting.InDesiredState -eq $false)
                        {
                            $status = $statusMap['Open']
                            $comments = "Configuration attempted by PowerStig MOF via $setting, but not currently set."
                            $findingDetails = Get-FindingDetails -Setting $setting
                        }
                        else
                        {
                            $status = $statusMap['Open']
                        }
                    }
                    else
                    {
                        $status = $statusMap['NotReviewed']
                    }
                }
            }

            # Test to see if this rule is managed as a duplicate
            $convertedRule = $processed.SelectSingleNode("//Rule[@id='$vid']")

            if ($convertedRule.DuplicateOf)
            {
                # How is the duplicate rule handled? If it is handled, then this duplicate should have the same status
                if ($PSCmdlet.ParameterSetName -eq 'mof')
                {
                    $originalSetting = Get-SettingsFromMof -ReferenceConfiguration $ReferenceConfiguration -Id $convertedRule.DuplicateOf

                    if ($originalSetting)
                    {
                        $status = $statusMap['Open']
                        $findingDetails = 'See {0} for Finding Details.' -f $convertedRule.DuplicateOf
                        $comments = 'Managed via PowerStigDsc - this rule is a duplicate of {0}' -f $convertedRule.DuplicateOf
                    }
                }
                elseif ($PSCmdlet.ParameterSetName -eq 'dsc')
                {
                    $originalSetting = Get-SettingsFromResult -DscResults $DscResults -Id $convertedRule.DuplicateOf

                    if ($originalSetting.InDesiredState -eq 'True')
                    {
                        $status = $statusMap['NotAFinding']
                        $findingDetails = 'See {0} for Finding Details.' -f $convertedRule.DuplicateOf
                        $comments = 'Managed via PowerStigDsc - this rule is a duplicate of {0}' -f $convertedRule.DuplicateOf
                    }
                    else
                    {
                        $status = $statusMap['Open']
                        $findingDetails = 'See {0} for Finding Details.' -f $convertedRule.DuplicateOf
                        $comments = 'Managed via PowerStigDsc - this rule is a duplicate of {0}' -f $convertedRule.DuplicateOf
                    }
                }
            }

            $writer.WriteStartElement("STATUS")
            $writer.WriteString($status)
            $writer.WriteEndElement(<#STATUS#>)

            $writer.WriteStartElement("FINDING_DETAILS")
            $findingDetails = ConvertTo-SafeXml -UnescapedXmlString $findingDetails
            $writer.WriteString($findingDetails)
            $writer.WriteEndElement(<#FINDING_DETAILS#>)

            $writer.WriteStartElement("COMMENTS")
            $comments = ConvertTo-SafeXml -UnescapedXmlString $comments
            $writer.WriteString($comments)
            $writer.WriteEndElement(<#COMMENTS#>)

            $writer.WriteStartElement("SEVERITY_OVERRIDE")
            $writer.WriteString('')
            $writer.WriteEndElement(<#SEVERITY_OVERRIDE#>)

            $writer.WriteStartElement("SEVERITY_JUSTIFICATION")
            $writer.WriteString('')
            $writer.WriteEndElement(<#SEVERITY_JUSTIFICATION#>)

            $writer.WriteEndElement(<#VULN#>)
        }

        #endregion STIGS/iSTIG/VULN[]

        $writer.WriteEndElement(<#iSTIG#>)
    }

    #endregion STIG_iteration

    $writer.WriteEndElement(<#STIGS#>)

    #endregion STIGS

    $writer.WriteEndElement(<#CHECKLIST#>)
    $writer.Flush()
    $writer.Close()

}

<#
    .SYNOPSIS
        Gets the vulnerability details from the rule description
#>
function Get-VulnerabilityList
{
    [CmdletBinding()]
    [OutputType([XML])]
    param
    (
        [Parameter()]
        [PSObject]
        $XccdfBenchmark
    )

    [System.Collections.ArrayList] $vulnerabilityList = @()

    foreach ($vulnerability in $XccdfBenchmark.Group)
    {
        $vulnerabilityDiscussion = ConvertTo-SafeXml -UnescapedXmlString $($vulnerability.Rule.description)
        [XML] $vulnerabiltyDiscussionElement = "<discussionroot>$vulnerabilityDiscussion</discussionroot>"

        [void]  $vulnerabilityList.Add(
            @(
                [PSCustomObject] @{Name = 'Vuln_Num'; Value = $vulnerability.id},
                [PSCustomObject] @{Name = 'Severity'; Value = $vulnerability.Rule.severity},
                [PSCustomObject] @{Name = 'Group_Title'; Value = $vulnerability.title},
                [PSCustomObject] @{Name = 'Rule_ID'; Value = $vulnerability.Rule.id},
                [PSCustomObject] @{Name = 'Rule_Ver'; Value = $vulnerability.Rule.version},
                [PSCustomObject] @{Name = 'Rule_Title'; Value = $vulnerability.Rule.title},
                [PSCustomObject] @{Name = 'Vuln_Discuss'; Value = $vulnerabiltyDiscussionElement.discussionroot.VulnDiscussion},
                [PSCustomObject] @{Name = 'IA_Controls'; Value = $vulnerabiltyDiscussionElement.discussionroot.IAControls},
                [PSCustomObject] @{Name = 'Check_Content'; Value = $vulnerability.Rule.check.'check-content'},
                [PSCustomObject] @{Name = 'Fix_Text'; Value = $vulnerability.Rule.fixtext.InnerText},
                [PSCustomObject] @{Name = 'False_Positives'; Value = $vulnerabiltyDiscussionElement.discussionroot.FalsePositives},
                [PSCustomObject] @{Name = 'False_Negatives'; Value = $vulnerabiltyDiscussionElement.discussionroot.FalseNegatives},
                [PSCustomObject] @{Name = 'Documentable'; Value = $vulnerabiltyDiscussionElement.discussionroot.Documentable},
                [PSCustomObject] @{Name = 'Mitigations'; Value = $vulnerabiltyDiscussionElement.discussionroot.Mitigations},
                [PSCustomObject] @{Name = 'Potential_Impact'; Value = $vulnerabiltyDiscussionElement.discussionroot.PotentialImpacts},
                [PSCustomObject] @{Name = 'Third_Party_Tools'; Value = $vulnerabiltyDiscussionElement.discussionroot.ThirdPartyTools},
                [PSCustomObject] @{Name = 'Mitigation_Control'; Value = $vulnerabiltyDiscussionElement.discussionroot.MitigationControl},
                [PSCustomObject] @{Name = 'Responsibility'; Value = $vulnerabiltyDiscussionElement.discussionroot.Responsibility},
                [PSCustomObject] @{Name = 'Security_Override_Guidance'; Value = $vulnerabiltyDiscussionElement.discussionroot.SeverityOverrideGuidance},
                [PSCustomObject] @{Name = 'Check_Content_Ref'; Value = $vulnerability.Rule.check.'check-content-ref'.href},
                [PSCustomObject] @{Name = 'Weight'; Value = $vulnerability.Rule.Weight},
                [PSCustomObject] @{Name = 'Class'; Value = 'Unclass'},
                [PSCustomObject] @{Name = 'STIGRef'; Value = "$($XccdfBenchmark.title) :: $($XccdfBenchmark.'plain-text'.InnerText)"},
                [PSCustomObject] @{Name = 'TargetKey'; Value = $vulnerability.Rule.reference.identifier}

                # Some Stigs have multiple Control Correlation Identifiers (CCI)
                $(
                    # Extract only the cci entries
                    $CCIREFList = $vulnerability.Rule.ident |
                    Where-Object -FilterScript {$PSItem.system -eq 'http://iase.disa.mil/cci'} |
                    Select-Object 'InnerText' -ExpandProperty 'InnerText'

                    foreach ($CCIREF in $CCIREFList)
                    {
                        [PSCustomObject] @{Name = 'CCI_REF'; Value = $CCIREF}
                    }
                )
            )
        )
    }

    return $vulnerabilityList
}

<#
    .SYNOPSIS
        Converts the mof into an array of objects
#>
function Get-MofContent
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ReferenceConfiguration
    )

    if (-not $script:mofContent)
    {
        $script:mofContent = [Microsoft.PowerShell.DesiredStateConfiguration.Internal.DscClassCache]::ImportInstances($ReferenceConfiguration, 4)
    }

    return $script:mofContent
}

<#
    .SYNOPSIS
        Gets the stig details from the mof
#>
function Get-SettingsFromMof
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $ReferenceConfiguration,

        [Parameter(Mandatory = $true)]
        [String]
        $Id
    )

    $mofContent = Get-MofContent -ReferenceConfiguration $ReferenceConfiguration

    $mofContentFound = $mofContent.Where({$PSItem.ResourceID -match $Id})

    return $mofContentFound
}

<#
    .SYNOPSIS
        Gets the stig details from the Test\Get-DscConfiguration output
#>
function Get-SettingsFromResult
{
    [CmdletBinding()]
    [OutputType([PSObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [PSObject]
        $DscResults,

        [Parameter(Mandatory = $true)]
        [String]
        $Id
    )

    if (-not $script:allResources)
    {
        $script:allResources = $DscResults.ResourcesNotInDesiredState + $DscResults.ResourcesInDesiredState
    }

    return $script:allResources.Where({$PSItem.ResourceID -match $id})
}

<#
    .SYNOPSIS
        Gets the value from a STIG setting
#>
function Get-FindingDetails
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSObject]
        $Setting
    )

    switch ($setting.ResourceID)
    {
        # Only add custom entries if specific output is more valuable than dumping all properties
        {$PSItem -match "^\[None\]"}
        {
            return "No DSC resource was leveraged for this rule (Resource=None)"
        }
        {$PSItem -match "^\[UserRightsAssignment\]"}
        {
            return "UserRightsAssignment Identity = $($setting.Identity)"
        }
        default
        {
            return Get-FindingDetailsString -Setting $setting
        }
    }
}

<#
    .SYNOPSIS
        Formats properties and values with standard string format.

#>
function Get-FindingDetailsString
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [PSObject]
        $Setting
    )

    foreach ($property in $setting.PSobject.properties)
    {
        if ($property.TypeNameOfValue -Match 'String')
        {
            $returnString += $($property.Name) + ' = '
            $returnString += $($setting.PSobject.properties[$property.Name].Value) + "`n"
        }
    }

    return $returnString
}

<#
    .SYNOPSIS
        Extracts the node targeted by the MOF file

#>
function Get-TargetNodeFromMof
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $MofString
    )

    $pattern = "((?<=@TargetNode=')(.*)(?='))"
    $targetNodeSearch = $MofString | Select-String -Pattern $pattern
    $targetNode = $targetNodeSearch.matches.value
    return $targetNode
}

<#
    .SYNOPSIS
        Determines the type of node address

#>
function Get-TargetNodeType
{
    [OutputType([String])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        $TargetNode
    )

    switch ($TargetNode)
    {
        # Do we have a MAC address?
        {
            $_ -match '(([0-9a-f]{2}:){5}[0-9a-f]{2})'
        }
        {
            return 'MACAddress'
        }

        # Do we have an IPv6 address?
        {
            $_ -match '(([0-9a-f]{0,4}:){7}[0-9a-f]{0,4})'
        }
        {
            return 'IPv4Address'
        }

        # Do we have an IPv4 address?
        {
            $_ -match '(([0-9]{1,3}\.){3}[0-9]{1,3})'
        }
        {
            return 'IPv6Address'
        }

        # Do we have a Fully-qualified Domain Name?
        {
            $_ -match '([a-zA-Z0-9-.\+]{2,256}\.[a-z]{2,256}\b)'
        }
        {
            return 'FQDN'
        }
    }

    return ''
}

<#
    .SYNOPSIS
        Escapes invalid characters in the input to create safe XML output.
        Note: Intended for contents of attributes, elements, etc.
#>
function ConvertTo-SafeXml
{
    [OutputType([xml])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [String]
        [AllowEmptyString()]
        $UnescapedXmlString
    )

    $escapedXml = [System.Security.SecurityElement]::Escape($UnescapedXmlString)
    return $escapedXml
}

<#
    .SYNOPSIS
        Converts the xml or psd1 in to a consistent data structure (hashtable) for use with the New-StigCheckList function.

    .DESCRIPTION
        Converts the xml or psd1 in to a consistent data structure (hashtable) for use with the New-StigCheckList function.

    .PARAMETER Path
        Location of a .xml or .psd1 file containing the input for Vulnerabilities unmanaged via DSC/PowerSTIG i.e.: Document/Manual Rules.

    .PARAMETER XccdfPath
        The path to a DISA STIG .xccdf file. PowerSTIG includes the supported files in the /PowerShell/StigData/Archive folder.

    .EXAMPLE
        PS> ConvertTo-ManualCheckListHashTable -Path C:\dev\ManualEntryData.psd1 -XccdfPath $xccdfPath

        Returns a hashtable that constains checklist data that will be used to inject into the ckl in the New-StigCheckList function.

    .NOTES
        Internal use only function, not for Export-ModuleMember
#>
function ConvertTo-ManualCheckListHashTable
{
    [OutputType([hashtable[]])]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter(Mandatory = $true)]
        [string[]]
        $XccdfPath
    )

    $fileDetail = Get-Item -Path $Path

    switch ($fileDetail.Extension)
    {
        '.xml'
        {
            # Import ManualCheckList xml contents to convert to hashtable to match psd1 back compat
            [xml] $xmlToConvert = Get-Content -Path $Path

            foreach ($stigRuleData in $xmlToConvert.stigManualChecklistData.stigRuleData)
            {
                $stigRuleManualCheck = @{}
                $stigRuleDataPropertyNames = (Get-Member -InputObject $stigRuleData -MemberType 'Property').Name
                foreach ($stigRuleDataPropertyName in $stigRuleDataPropertyNames)
                {
                    $stigRuleManualCheck.Add($stigRuleDataPropertyName, $stigRuleData.$stigRuleDataPropertyName)
                }
                $stigRuleManualCheck
            }
        }
        '.psd1'
        {
            $formattedPsd1ToConvert = (Get-Content -Path $Path -Raw) -replace '"|@{' -split '}'
            $convertedPsd1HashTable = $formattedPsd1ToConvert | ConvertFrom-StringData
            foreach ($stigRuleManualCheck in $convertedPsd1HashTable)
            {
                if ($stigRuleManualCheck.Count -ne 0)
                {
                    $stigFileName = Get-StigXccdfFileName -VulnId $stigRuleManualCheck.VulID -XccdfPath $XccdfPath
                    $stigRuleManualCheck.Add('STIG', $stigFileName)
                    $stigRuleManualCheck.Add('Details', $stigRuleManualCheck.Comments)
                    $stigRuleManualCheck.Add('ID', $stigRuleManualCheck['VulId'])
                    $stigRuleManualCheck.Remove('VulId')
                    $stigRuleManualCheck
                }
            }
        }
    }
}

<#
    .SYNOPSIS
        Used to detect the correct STIG property when a psd1 is specified.

    .DESCRIPTION
        Used to detect the correct STIG property when a psd1 is specified.

    .PARAMETER VulnId
        The VulnId or RuleId for a given STIG Rule

    .PARAMETER XccdfPath
        The path to a DISA STIG .xccdf file. PowerSTIG includes the supported files in the /PowerShell/StigData/Archive folder.

    .EXAMPLE
        PS> Get-StigXccdfFileName -VulnId 'V-1114' -XccdfPath C:\PowerStig\StigData\Archive\Windows.Server.2012R2\U_MS_Windows_2012_and_2012_R2_DC_STIG_V2R19_Manual-xccdf.xml

        Returns U_MS_Windows_2012_and_2012_R2_DC_STIG_V2R19_Manual-xccdf.xml as the correct xccdf file specified by the user.

    .NOTES
        Internal use only function, not for Export-ModuleMember
#>
function Get-StigXccdfFileName
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $VulnId,

        [Parameter(Mandatory = $true)]
        [string[]]
        $XccdfPath
    )

    $processedXmlPath = Join-Path -Path $PSScriptRoot -ChildPath '..\..\StigData\Processed\*.xml'
    $processedXml = Select-String -Path $processedXmlPath -Pattern $VulnId -Exclude '*.org.default.xml' | Sort-Object -Property Pattern

    $stigVersionData = @()
    foreach ($xmlPath in $processedXml.Path)
    {
        [xml] $xml = Get-Content -Path $xmlPath
        $stigVersionData += [PSCustomObject] @{
            Version  = [version] $xml.DISASTIG.fullversion
            FileName = $xml.DISASTIG.filename
        }
    }

    # populate the STIG value based on Xccdf Path passed by user
    $compareObjectParams = @{
        ReferenceObject  = $(Split-Path -Path $XccdfPath -Leaf)
        DifferenceObject = $stigVersionData.FileName
        IncludeEqual     = $true
        ExcludeDifferent = $true
    }

    $xccdfFileDetection = (Compare-Object @compareObjectParams).InputObject

    if ($xccdfFileDetection.Count -eq 1)
    {
        return $xccdfFileDetection
    }
    elseif ($xccdfFileDetection.Count -gt 1)
    {
        throw 'Unable to determine correct Xccdf file for psd1 usage, ensure that the correct Xccdf file(s) are used.'
    }
    else
    {
        return ($stigVersionData | Sort-Object -Property Version -Descending | Select-Object -First 1).FileName
    }
}
