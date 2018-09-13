# Versions

## Unreleased

* Added the following STIGs
  * Microsoft Outlook 2013 STIG V1R12
  * Microsoft Excel 2013 STIG V1R7

## 2.1.0.0

* Migrated Composite resources to the xRegistry resource
* Fixed 2012R2 V-15713 default org setting value
* Updated IE STIGs (V-46477) with the decimal value
* Updated New-StigCheckList to output StigViewer 2.7.1 ckl files
* Added SkipRule functionality to all composite resources
* Added StigData for FireFox STIG V4R21
* Added Sql2012 1.17 to Archive and processed
* Updated Sql2012 1.16 to fix broken rules
* Removed Sql2012 1.14 from archives to comply with n-2 version policy
* Updated data for 2012R2 Stigs to fix broken rules

## 2.0.0.0

* Added a Document module to automatically create a Stig Checklist (EXPERIMENTAL)
* Merged PowerStigDsc into PowerStig so there is only one module to maintain
  * Replaced PowerStig Technology Class with Enumeration
  * Added script module back to manifest
  * Added DotNetFramework composite resource

* Added the following STIGs
  * Windows Server 2012R2 MS STIG V2R13
  * Windows Server 2012R2 DC STIG V2R13
  * Windows 2012 DNS V1R10
  * Windows Domain V2R10
  * Windows Forest V2R8
  * IE11-V1R16

* Corrected parsing of rule V-46477 in the IE STIGs
  * Updated StigData
  * Bug fixes
  * Removed Windows Server 2012R2 MS and DC StigData v2.9

## 1.1.1.0

Update IIS Server STIG V-76723.a with correct value

## 1.1.0.0

Replaced Technology class with enumeration. This breaks PowerStigDsc < 1.1.0.0

Added the following STIGs:

* IIS 8.5 Server STIG V1R3

Updates

* Updated SQL STIG code to account for SQL STIGS being added in PowerStigDsc
* Update to PowerStig.psm1 to fix issue were StigData class was not accessible to PowerStigDsc

## 1.0.0.0

Added the following STIGs:

* Windows Server 2012R2 MS STIG V2R12
* Windows Server 2012R2 DC STIG V2R12
* Windows Server DNS V1R9
* Windows AD Domain V2R9
* IE11 V1R15
