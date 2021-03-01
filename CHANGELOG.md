# Versions

## [Unreleased]

* Functions.Checklist.ps1 updated to incorporate localhost data into STIG CKLS [#828](https://github.com/microsoft/PowerStig/issues/828)

## [4.8.0] - 2021-03-01

* Update PowerSTIG to remove old rule Ids in Hard Coded Framework: [#790](https://github.com/microsoft/PowerStig/issues/790)
* Update PowerSTIG to Parse/Apply MS Office 365 ProPlus Ver 2, Rel 1: [#811](https://github.com/microsoft/PowerStig/issues/811)
* Update PowerSTIG to parse and apply RHEL 7.x V3R1: [#608](https://github.com/microsoft/PowerStig/issues/608)
* Update PowerSTIG to parse and apply Ubuntu 18.04 LTS STIG - Ver 2, Rel 2: [#821](https://github.com/microsoft/PowerStig/issues/821)
* Update PowerSTIG to Add Checklist Accountability: [#808](https://github.com/microsoft/PowerStig/issues/808)
* Update PowerSTIG to move O365 Pro Plus log entries into Exclusion Rule list: [#815](https://github.com/microsoft/PowerStig/issues/815)
* Update PowerSTIG to parse and apply Mozilla Firefox V5R1 STIG: [#834](https://github.com/microsoft/PowerStig/issues/834)
* Update PowerSTIG to parse and apply Microsoft DotNet V2R1 STIG: [#831](https://github.com/microsoft/PowerStig/issues/831)
* Update PowerSTIG to Parse/Apply Oracle JRE 8 Ver 2, Rel 1: [#833](https://github.com/microsoft/PowerStig/issues/833)
* Update PowerSTIG to use WindowsDefenderDSC 2.1.0: [#822](https://github.com/microsoft/PowerStig/issues/822)
* Update PowerSTIG to Parse/Apply Google Chrome Ver 2, Rel 2: [#841](https://github.com/microsoft/PowerStig/issues/841)
* Update PowerSTIG SkipRule to Accept Parent Rule for Split Rules: [#846](https://github.com/microsoft/PowerStig/issues/846)
* Fixed: ConvertTo-ManualCheckListHashTable function call is missing mandatory argument: [#823](https://github.com/microsoft/PowerStig/issues/823)
* Fixed: RHEL RuleId V-204406 should be removed: [#847](https://github.com/microsoft/PowerStig/issues/847)
* Update PowerSTIG to successfully parse/apply Microsoft SQL Server 2016 Instance Version 2; Release 2: [#838](https://github.com/microsoft/PowerStig/issues/838)
* Update PowerSTIG to successfully parse/apply MS Edge V1R1: [#860](https://github.com/microsoft/PowerStig/issues/860)
* Update PowerSTIG to successfully parse/apply VMware 6.5 ESXI V2R1 STIG: [#851](https://github.com/microsoft/PowerStig/issues/851)
* Fixed: RHEL RuleId V-204406 should be removed: [#847](https://github.com/microsoft/PowerStig/issues/847)

## [4.7.1] - 2021-01-22

* Fixed: ConvertTo-ManualCheckListHashTable function call is missing mandatory argument: [#823](https://github.com/microsoft/PowerStig/issues/823)

## [4.7.0] - 2020-12-17

* Update PowerSTIG to successfully parse/apply Microsoft Windows 2012 and 2012 R2 DC STIG - Ver 3, Rel 1: [#784](https://github.com/microsoft/PowerStig/issues/784)
* Update PowerSTIG to successfully parse/apply Microsoft Windows 2012 and 2012 R2 MS STIG - Ver 3, Rel 1: [#785](https://github.com/microsoft/PowerStig/issues/785)
* Update PowerSTIG to successfully parse/apply Microsoft Windows 10 STIG - Ver 2, Rel 1: [#783](https://github.com/microsoft/PowerStig/issues/783)
* Update PowerSTIG to successfully parse/apply Microsoft Windows Defender Antivirus STIG - Ver 2, Rel 1: [#786](https://github.com/microsoft/PowerStig/issues/786)
* Update PowerSTIG to successfully parse/apply Microsoft Windows Server 2016 STIG - Ver 2, Rel 1: [#782](https://github.com/microsoft/PowerStig/issues/782)
* Update PowerSTIG to successfully parse/apply Microsoft Windows Server 2019 STIG - Ver 2, Rel 1  [#787](https://github.com/microsoft/PowerStig/issues/787)
* Update PowerSTIG to successfully parse/apply Google Chrome V2R1: [#709](https://github.com/microsoft/PowerStig/issues/709)
* Update PowerSTIG to include LegacyId to assist in determining Legacy Vuln Ids with the new DISA standard: [#788](https://github.com/microsoft/PowerStig/issues/788)
* Update PowerSTIG to include LegacyId query via Get-StigRule function: [#800](https://github.com/microsoft/PowerStig/issues/800)
* Fixed: Update PowerSTIG to fix LegacyId logic: [#791](https://github.com/microsoft/PowerStig/issues/791)
* Fixed: Update PowerSTIG to correctly parse Windows Server 2019 DC - LDAP SecurityOptionRule: [#804](https://github.com/microsoft/PowerStig/issues/804)

## [4.6.0] - 2020-12-01

* Provide Method to install DoD Root Certs for Server OS and Client OS: [#755](https://github.com/microsoft/PowerStig/issues/755)
* Update Windows 10 Client STIGs based on ACAS results: [#778](https://github.com/microsoft/PowerStig/issues/778)
* Update PowerSTIG to Provide Rule Data from Processed xml: [#747](https://github.com/microsoft/PowerStig/issues/747)
* Update PowerSTIG to send a warning to the user when using a composite that leverages the new DISA Ids: [#772](https://github.com/microsoft/PowerStig/issues/772)
* Update PowerSTIG to successfully parse/apply Microsoft Office System 2013 STIG - Ver 2, Rel 1: [#769](https://github.com/microsoft/PowerStig/issues/769)
* Update PowerSTIG to successfully parse/apply Microsoft Windows 2012 Server DNS STIG - Ver 2, Rel 1: [#760](https://github.com/microsoft/PowerStig/issues/760)
* Update PowerSTIG to successfully parse/apply Microsoft SQL Server 2016 Instance Version 2; Release 1: [#761](https://github.com/microsoft/PowerStig/issues/761)
* Update PowerSTIG to successfully parse/apply Microsoft Outlook 2016 Version 2; Release 1: [#767](https://github.com/microsoft/PowerStig/issues/767)
* Update spacing in DoD logon script: [#757](https://github.com/microsoft/PowerStig/issues/757)
* Update PowerSTIG to Increase Code Coverage of Unit Tests: [#737](https://github.com/microsoft/PowerStig/issues/737)
* Update PowerSTIG with new SkipRuleSeverity Parameter to skip entire STIG Category/Severity Level(s): [#711](https://github.com/microsoft/PowerStig/issues/711)
* Update PowerSTIG to successfully parse/apply Microsoft IIS 10 SITE/SERVER STIG - Ver 2, Rel 1: [#759](https://github.com/microsoft/PowerStig/issues/759)
* Update PowerSTIG to successfully parse/apply IIS 8.5 Site/Server V2R1 STIGs: [#762](https://github.com/microsoft/PowerStig/issues/762)

## [4.5.1] - 2020-10-12

* Fixed [#746](https://github.com/microsoft/PowerStig/issues/746): Functions.Checklist Manual Checks need to leverage psd1 files - Backward Compat Issue

## [4.5.0] - 2020-09-01

* Update PowerSTIG to successfully parse/apply Windows 2012 R2 DC Version 2, Rev 21: [#677](https://github.com/microsoft/PowerStig/issues/677)
* Update PowerSTIG to successfully parse/apply IIS Site/Server V1R11 STIGs: [#702](https://github.com/microsoft/PowerStig/issues/702)
* Update PowerSTIG to successfully parse/apply Microsoft Internet Explorer 11 STIG - Ver 1, Rel 19: [#707](https://github.com/microsoft/PowerStig/issues/707)
* Update PowerSTIG to successfully parse/apply Microsoft Windows 2012 Server DNS - V1R15: [#696](https://github.com/microsoft/PowerStig/issues/696)
* Update PowerSTIG to successfully parse/apply SQL Server 2016 Instance V1R10: [#704](https://github.com/microsoft/PowerStig/issues/704)
* Update PowerSTIG to successfully parse/apply IIS 10.0 Site/Server V1R2 STIGs: [#699](https://github.com/microsoft/PowerStig/issues/699)
* Update PowerSTIG to successfully parse Microsoft Windows 10 STIG - Ver 1, Rel 23: [#678](https://github.com/microsoft/PowerStig/issues/678)
* Update PowerSTIG to successfully parse/apply Windows Server 2019 Instance Ver. 1 Rel. 5: [#683](https://github.com/microsoft/PowerStig/issues/683)
* Update PowerSTIG to successfully parse/apply Windows 2016 DC/MS Version 1, Rev 12: [#681](https://github.com/microsoft/PowerStig/issues/681)
* Update PowerSTIG to successfully parse/apply Windows 2012 R2 MS Version 2, Rev 19: [#676](https://github.com/microsoft/PowerStig/issues/676)
* Update PowerSTIG To Use WindowsDefenderDsc version 2.0.0 : [#657](https://github.com/microsoft/PowerStig/issues/657)
* Update PowerSTIG To Use PSDSCResources version 2.12.0.0: [#723](https://github.com/microsoft/PowerStig/issues/723)
* Update PowerSTIG To Use AuditPolicyDsc version 1.4.0.0 : [#715](https://github.com/microsoft/PowerStig/issues/715)
* Update PowerSTIG To Use xWebAdministration version 3.2.0 : [#713](https://github.com/microsoft/PowerStig/issues/713)
* Update PowerSTIG To Use xDnsServer version 1.16.0.0: [#695](https://github.com/microsoft/PowerStig/issues/695)
* Update PowerSTIG To Use SecurityPolicyDsc version 2.10.0.0: [#690](https://github.com/microsoft/PowerStig/issues/690)
* Update PowerSTIG To Use FileContentDsc version 1.3.0.151: [#722](https://github.com/microsoft/PowerStig/issues/722)
* Update PowerSTIG To Use ComputerManagementDsc version 8.4.0: [#720](https://github.com/microsoft/PowerStig/issues/720)
* Update PowerSTIG to support multiple STIGs per checklist [#567](https://github.com/microsoft/PowerStig/issues/567)
* Release Process Update: Ensure the nuget package uses explicit DSC Resource Module Versions: [#667](https://github.com/microsoft/PowerStig/issues/667)
* Fixed [#668](https://github.com/microsoft/PowerStig/issues/668): Incorrect key for SSL 3.0 rules in SqlServer-2016-Instance.*.xml
* Fixed [#669](https://github.com/microsoft/PowerStig/issues/669): Missing TLS 1.2 configuration for rule V-97521
* Fixed [#663](https://github.com/microsoft/PowerStig/issues/663): Missing OrgSettings for V-88203 - Win10 Client 1.19 and 1.21
* Fixed [#673](https://github.com/microsoft/PowerStig/issues/673): IIS Sever 10.0 STIG hardening rule V-100163 fails with error in Windows Server 2019 while using PowerSTIG 4.4.2
* Fixed: Removed Windows Server 2016 DC/MS R1V9 from processed STIGs folder
* Fixed [#718](https://github.com/microsoft/PowerStig/issues/718): Allow application of applicable user rights assignments for non-domain and disconnected systems
* Fixed [#731](https://github.com/microsoft/PowerStig/issues/731): Update Windows 10 Client Org Default Setting For Rule V-63405 to "15"
* Fixed [#735](https://github.com/microsoft/PowerStig/issues/735): Rule V-63353 won't reach desired state if system partition is Fat32

## [4.4.2] - 2020-07-06

* Removed required dependency of Vmware.VsphereDSC due to cyclic redundancy error when importing PowerSTIG
* Update PowerSTIG to successfully parse/apply MS SQL Server 2012 Instance Ver. 1 Rel. 20: [#639](https://github.com/microsoft/PowerStig/issues/639)
* Update PowerSTIG to successfully parse/apply MS SQL Server 2016 Instance Ver. 1 Rel. 9: [#636](https://github.com/microsoft/PowerStig/issues/636)
* Update PowerSTIG to successfully parse/apply Windows Server 2012 DNS STIG - Ver 1, Rel 14:  [#633](https://github.com/microsoft/PowerStig/issues/633)
* Update PowerSTIG to successfully parse Microsoft IIS Server/Site 10.0 STIG STIG V1R1: [#632](https://github.com/microsoft/PowerStig/issues/632)
* Update PowerSTIG to successfully parse Microsoft Visio 2013 STIG V1R4: [#629](https://github.com/microsoft/PowerStig/issues/629)
* Update PowerSTIG to successfully parse/apply Windows Defender Antivirus STIG - V1R8: [#625](https://github.com/microsoft/PowerStig/issues/625)
* Update PowerSTIG to successfully parse Microsoft SQL Server 2012 Database STIG V1R20: [#618](https://github.com/microsoft/PowerStig/issues/618)
* Update PowerSTIG to successfully parse/apply Microsoft IIS Server/Site 8.5 STIG - Ver 1, Rel10: [#622](https://github.com/microsoft/PowerStig/issues/622)
* Update PowerSTIG to use Azure Pipelines and DSC Community based build logic: [#600](https://github.com/microsoft/PowerStig/issues/600)
* Update PowerSTIG to parse/convert the Vmware Vsphere 6.5 STIG V1R3: [#604](https://github.com/microsoft/PowerStig/issues/604)
* Update PowerSTIG to parse/convert the Vmware Vsphere 6.5 STIG V1R4: [#634](https://github.com/microsoft/PowerStig/issues/634)
* Fixed [#647](https://github.com/microsoft/PowerStig/issues/647): Conflict when configuring multiple databases
* Fixed [#616](https://github.com/microsoft/PowerStig/issues/616): Unable to Import PowerSTIG 4.4.0 Due to cyclic dependency Error
* Fixed [#632](https://github.com/microsoft/PowerStig/issues/632): Update PowerSTIG to allow for workgroup level scansr
* Fixed [#652](https://github.com/microsoft/PowerStig/issues/652): Invalid ValueName for InternetExplorer11 rules V-75169 and V-75171

## [4.3.0] - 2020-03-27

* Update PowerSTIG to Expand .NET STIG Automation: [#591](https://github.com/microsoft/PowerStig/issues/591)
* Update PowerSTIG to parse and apply McAfee VirusScan 8.8 Local Client STIG V5R16: [#588](https://github.com/microsoft/PowerStig/issues/588)
* Update PowerSTIG to successfully parse Microsoft SQL Server 2016 Instance STIG - Ver 1, Rel 8: [#586](https://github.com/microsoft/PowerStig/issues/586)
* Update PowerSTIG to parse and apply Windows Server 2019 V1R3 STIG: [#584](https://github.com/microsoft/PowerStig/issues/584)
* Update PowerSTIG to parse/convert the Windows Server 2016 V2R10: [#582](https://github.com/microsoft/PowerStig/issues/582)
* Update PowerSTIG to parse/convert the Windows Server 2012 DNS STIG V1R13: [#580](https://github.com/microsoft/PowerStig/issues/580)
* Update PowerSTIG to parse/convert the Windows Server 2012 R2 DC V2R19: [#578](https://github.com/microsoft/PowerStig/issues/578)
* Update PowerSTIG to parse/convert the Windows Defender STIG V1R7: [#576](https://github.com/microsoft/PowerStig/issues/576)
* Update PowerSTIG to successfully parse Mozilla Firefox STIG - Ver 4, Rel 28: [#573](https://github.com/microsoft/PowerStig/issues/573)
* Update PowerSTIG to parse and apply Adobe Acrobat Reader Version 1, Release 6: [#562](https://github.com/microsoft/PowerStig/issues/562)
* Update PowerSTIG release process to include STIG Coverage markdown wiki automation: [#560](https://github.com/microsoft/PowerStig/issues/560)
* Update PowerSTIG to show duplicate rule status matching in a checklist: [#257](https://github.com/microsoft/PowerStig/issues/257)
* Fixed [#589](https://github.com/microsoft/PowerStig/issues/589): Update module manifest to leverage GPRegistryPolicyDsc v1.2.0
* Fixed [#569](https://github.com/microsoft/PowerStig/issues/569): Update SqlServerDsc module version references
* Fixed [#259](https://github.com/microsoft/PowerStig/issues/259): Checklist .ckl file fails XML validation in Stig Viewer 2.8.
* Fixed [#527](https://github.com/microsoft/PowerStig/issues/527): Checklist is not using manualcheckfile when using DscResult.
* Fixed [#548](https://github.com/microsoft/PowerStig/issues/548): Target/host data is blank when creating a new checklist.
* Fixed [#546](https://github.com/microsoft/PowerStig/issues/546): Typecast causing an issue when trying to generate checklist using New-StigChecklist function.
* Fixed [#401](https://github.com/microsoft/PowerStig/issues/401): Checklists generated by New-StigChecklist do not provide finding details.
* Fixed [#593](https://github.com/microsoft/PowerStig/issues/593): Update PowerSTIG Convert naming conventions of output STIGs

## [4.2.0] - 2019-12-20

* Update PowerSTIG parsing for IIS 8.5 STIG - Ver 1, Rel 9: [#530](https://github.com/microsoft/PowerStig/issues/530)
* Update PowerSTIG to successfully parse Microsoft .Net Framework STIG 4.0 STIG - Ver 1, Rel 9: [535](https://github.com/microsoft/PowerStig/issues/535)
* Update PowerSTIG to successfully parse MS Internet Explorer 11 STIG - Ver 1, Rel 18: [#538](https://github.com/microsoft/PowerStig/issues/538)
* Update PowerSTIG to successfully parse Mozilla Firefox STIG - Ver 4, Rel 27: [#540](https://github.com/microsoft/PowerStig/issues/540)
* Update PowerSTIG to successfully parse Microsoft Windows 10 STIG - Ver 1, Rel 19: [533](https://github.com/microsoft/PowerStig/issues/533)
* Update PowerSTIG to parse/convert the Windows Server 2012 R2 MS/DC V2R17/V2R18 Respectively: [531](https://github.com/microsoft/PowerStig/issues/531)
* Update PowerSTIG to successfully parse Microsoft SQL Server 2016 Instance STIG - Ver 1, Rel 7: [#542](https://github.com/microsoft/PowerStig/issues/542)
* Update PowerSTIG to parse and apply OfficeSystem 2013 STIG V1R9 / 2016 V1R1: [#551](https://github.com/microsoft/PowerStig/issues/551)
* Update PowerSTIG to parse and apply Windows Server 2019 V1R2 STIG: [#554](https://github.com/microsoft/PowerStig/issues/554)
* Fixed [#428](https://github.com/microsoft/PowerStig/issues/428): Updated JRE rule V-66941.a to be a Organizational setting
* Fixed [#427](https://github.com/microsoft/PowerStig/issues/427): Windows 10 Rule V-63373 fails to apply settings to system drive
* Fixed [#514](https://github.com/microsoft/PowerStig/issues/514): Feature request: additional support for servicerule properties
* Fixed [#521](https://github.com/microsoft/PowerStig/issues/521): Organizational setting warning should include Stig name
* Fixed [#443](https://github.com/microsoft/PowerStig/issues/443): Missing cmdlet Get-StigXccdfBenchmark function
* Fixed [#528](https://github.com/microsoft/PowerStig/issues/528): New-StigChecklist should not require a ManualCheckFile
* Fixed [#545](https://github.com/microsoft/PowerStig/issues/545): Need a test to verify the conversionstatus="fail" does not exist in processed STIGs
* Fixed [#517](https://github.com/microsoft/PowerStig/issues/520): Need a test to verify the module version in the module manifest matches the DscResources.

## [4.1.1] - 2019-10-31

* Fixed [#517](https://github.com/microsoft/PowerStig/issues/517): 4.1.0 GPRegistryPolicyDsc Module Version Issue

## [4.1.0] - 2019-10-31

* Update PowerSTIG to enable Exception Parameter Backward Compatibility Feature Request: [506](https://github.com/microsoft/PowerStig/issues/506)
* Update Enable Stig Checklist automation to include Status and Comments for manual checks: [#485](https://github.com/microsoft/PowerStig/issues/485)

## [4.0.0] - 2019-09-23

* Update PowerSTIG parsing for Windows Sever 2016 STIG - Ver 1, Rel 9 [#498](https://github.com/microsoft/PowerStig/issues/498)
* Fixed [#507](https://github.com/microsoft/PowerStig/issues/507): Get-HardCodedRuleLogFileEntry Errors on RegistryRule
* Update PowerSTIG to leverage the GPRegistryPolicyDsc resource for Local Group Policy automation: [#497](https://github.com/microsoft/PowerStig/issues/497)
* Update PowerSTIG to enable the logfile framework to consume a hashtable for HardCodedRule: [#494](https://github.com/microsoft/PowerStig/issues/494)
* Update PowerSTIG to pass OrgSettings in via configuration hashtable: [#372](https://github.com/microsoft/PowerStig/issues/372)
* Update support for SQL Server 2012 Database STIG, Version 1, Release 19 [#482](https://github.com/microsoft/PowerStig/issues/482)
* Fixed [#478](https://github.com/microsoft/PowerStig/issues/478): SQL STIG Instance V-40936 Fails to apply
* Update PowerSTIG to automate applying the IIS 8.5 STIG, Version 1 Release 8. [#469](https://github.com/microsoft/PowerStig/issues/469)
* Fixed [#476](https://github.com/microsoft/PowerStig/issues/476): AuditSetting Rule for Windows STIGs has an incorrect operator when evaluating Service Pack information
* Added support for Dot Net Framework 4.0 STIG, Version 1, Release 8 [#447](https://github.com/microsoft/PowerStig/issues/447)
* Added support for Windows 10 STIG, Version 1, Release 17 & 18: [#466](https://github.com/microsoft/PowerStig/issues/466)
* Added support for Windows 2012 Server DNS STIG, Version 1, Release 12 [#464](https://github.com/microsoft/PowerStig/issues/464)
* Update PowerSTIG to automate applying the Windows Server 2012R2 DC & MS STIG, Version 2, Release 17 & 16 respectively. [#456](https://github.com/microsoft/PowerStig/issues/456)
* Fixed [#444](https://github.com/microsoft/PowerStig/issues/444): Duplicate principals in Permission Rule (Registry)
* Updated logfile in 2012R2 DC STIG leveraging HardCodedRule to automate additional STIG rules. [#446](https://github.com/microsoft/PowerStig/issues/446)
* Updated logfile in 2012R2 MS STIG leveraging HardCodedRule to automate additional STIG rules. [#448](https://github.com/microsoft/PowerStig/issues/448)
* Declarative definition of a rule in the StigData log file to provide a standard way to populate unautomated rules [#435](https://github.com/microsoft/PowerStig/issues/435)
* Updated PowerSTIG to leverage AuditSetting instead of the Script resource. Additionally renamed WmiRule to AuditSettingRule [#431](https://github.com/Microsoft/PowerStig/issues/431)
* Fixed [#419](https://github.com/Microsoft/PowerStig/issues/419): PowerStig is creating resource xSSLSettings with the wrong value for Name.
* Added support for Windows Defender, Version 1, Release 5 [#393](https://github.com/microsoft/PowerStig/issues/393)
* Added support for Internet Explorer 11 Version 1, Release 17 [#422](https://github.com/Microsoft/PowerStig/issues/422)
* Added support for Server 2016 STIG, Version 1, Release 8 [#418](https://github.com/Microsoft/PowerStig/issues/418)
* Update PowerSTIG to enforce additional rules in the SQL Server 2012 STIG [#438](https://github.com/microsoft/PowerStig/issues/438)
* Added support for Windows Defender Antivirus STIG, Version 1, Release 6 [#462](https://github.com/Microsoft/PowerStig/issues/462)
* Added support for Firefox STIG v4r26 [#458](https://github.com/Microsoft/PowerStig/issues/458)
* Updated logfile in DotNet Framework STIG leveraging HardCodedRule to automate additional STIG rules. [#454](https://github.com/microsoft/PowerStig/issues/454)
* Fixed [#493](https://github.com/microsoft/PowerStig/issues/493): IIS 8/5 Server STIG rule V-76745 is referencing the incorrect IIS default path
* Fixed [#505](https://github.com/microsoft/PowerStig/issues/505): Missing reg key setting on V-76759 IIS Server 8.5 v1R7
