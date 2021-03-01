# PowerSTIG

**PowerStig** is a PowerShell module that contains several components to automate different DISA Security Technical Implementation Guides (STIGs) where possible.

| Name | Description | Published to PS Gallery|
| ---- | ---- | --- |
|[PowerStig.Convert](#powerstigconvert) | Extract configuration objects from the xccdf | No
|[PowerStig.Data](#powerstigdata) | A PowerShell class to access the PowerSTIG "database" | Yes
|[PowerStig.DSC](#powerstigdsc) | Compsite DSC resources to apply and/or audit STIG settings | Yes
|[PowerStig.Document](#powerstigdocument) | An experimental module to create prefilled out checklists | Yes

This project has adopted the [Microsoft Open Source Code of Conduct](
  https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](
  https://opensource.microsoft.com/codeofconduct/faq/)
or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions
or comments.

| Branch | Status | Description |
| ---- | ---- | --- |
| master | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/master?svg=true) | Contains the latest release - no contributions are made directly to this branch. |
| dev | [![Build status](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true)](https://ci.appveyor.com/api/projects/status/9iuhve75mrjdxokb/branch/dev?svg=true) | Where contributions should be proposed by contributors as pull requests. This branch is merged into the master branch, and be released to PowerShell Gallery. |

## Released Module

To see the released PowerStig module, go to the [PowerShell Gallery](https://www.powershellgallery.com/items?q=powerstig&x=19&y=15). We recommend that you use PowerShellGet to install PowerStig:

For example:

```powershell
Install-Module -Name PowerStig -Scope CurrentUser
```

Once PowerStig is installed, you can view the list of STIGs that are currently available.
The Get-Stig function queries the StigData and returns a full list.
This will give you an idea of what you can target in your environment.

```powershell
Import-Module PowerStig
Get-Stig -ListAvailable
```

To update a previously installed module use this command:

```powershell
Update-Module -Name PowerStig
```

## PowerStig.Convert

A utility module that we use to generate PowerStig XML to store in [PowerStig.Data](#powerstigdata).
The module uses PowerShell classes to extract settings from check-content elements of the xccdf.
This nested module is NOT published to the PS Gallery.
The extracted settings are converted into a new PowerStig XML schema.
The XML file is saved into a processed StigData folder and released to the PS Gallery on a regular cadence.

For detailed information, please see the [Convert Wiki](https://github.com/Microsoft/PowerStig/wiki/Convert)

## PowerStig.Data

A module with PowerShell classes and a directory of PowerStig XML to provide a way of retrieving StigData and documenting deviations.
The PowerStig.Data classes provide methods to:

1. Override a setting defined in a STIG and automatically document the exception to policy
1. Apply settings that have a valid range of values (Organizational Settings)
1. Exclude a rule if it is already defined in another STIG (de-duplication) and automatically document the exception to policy
1. Exclude an entire class of rules (intended for testing and integration) and automatically document the exception to policy

For detailed information, please see the [StigData Wiki](https://github.com/Microsoft/PowerStig/wiki/Stig). For STIG xml file hashes please refer to [File Hashes](https://github.com/Microsoft/PowerStig/blob/dev/FILEHASH.md).

## PowerStig.DSC

PowerStig.DSC is not really a specific module, but rather a collection of PowerShell Desired State Configuration (DSC) composite resources to manage the configurable items in each STIG.
Each composite uses [PowerStig.Data](#powerstigdata) classes to retrieve PowerStig XML.
This allows the PowerStig.Data classes to manage exceptions, Org settings, and skipped rules uniformly across all composite resources. The standard DSC ResourceID's can them be used by additional automation to automatically generate compliance reports or trigger other automation solutions.

### Composite Resources

The list of STIGs that we are currently covering.

|Name|Description|
| ---- | --- |
|[Browser](https://github.com/Microsoft/PowerStig/wiki/Browser) | Provides a mechanism to manage Browser STIG settings. |
|[DotNetFramework](https://github.com/Microsoft/PowerStig/wiki/DotNetFramework) | Provides a mechanism to manage .Net Framework STIG settings. |
|[Office](https://github.com/Microsoft/PowerStig/wiki/Office) | Provides a mechanism to manage Microsoft Office STIG settings. |
|[SqlServer](https://github.com/Microsoft/PowerStig/wiki/SqlServer) | Provides a mechanism to manage SqlServer STIG settings. |
|[WindowsDnsServer](https://github.com/Microsoft/PowerStig/wiki/WindowsDnsServer) | Provides a mechanism to manage Windows DNS Server STIG settings. |
|[WindowsFirewall](https://github.com/Microsoft/PowerStig/wiki/WindowsFirewall) | Provides a mechanism to manage the Windows Firewall STIG settings. |
|[WindowsServer](https://github.com/Microsoft/PowerStig/wiki/WindowsServer) | Provides a mechanism to manage the Windows Server STIG settings. |

For detailed information, please see the [Composite Resources Wiki](https://github.com/Microsoft/PowerStig/wiki/CompositeResources)

## PowerStig.Document

An **Experimental** module to create checklists and other types of documentation based on the results of the DSC compliance report.
This module generates a checklist, but we are not 100% sure on the workflow, so we wanted to publish the idea and build on it.

For detailed information, please see the [Document Wiki](https://github.com/Microsoft/PowerStig/wiki/Document)

## Contributing

We welcome all contributions to the development of PowerStig.
There are several different ways you can help.
You can create new convert modules, add test automation, improve documentation, fix existing issues, or open new ones.
See our [contributing guide](README.CONTRIBUTING.md) for more info on how to become a contributor.
If you would like to contribute to a Composite Resource, please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResources/blob/master/CONTRIBUTING.md).

Thank you to everyone that has reviewed the project and provided feedback through issues.
We are especially thankful for those who have contributed pull requests to the code and documentation.

### Contributors

* [@ALichtenberg](https://github.com/ALichtenberg) (Adam Lichtenberg)
* [@athaynes](https://github.com/athaynes) (Adam Haynes)
* [@bcwilhite](https://github.com/bcwilhite) (Brian Wilhite)
* [@bgouldman](https://github.com/bgouldman) (Brian Gouldman)
* [@camusicjunkie](https://github.com/camusicjunkie) (John Steele)
* [@chasewilson](https://github.com/chasewilson) (Chase Wilson)
* [@clcaldwell](https://github.com/clcaldwell) (Coby Caldwell)
* [@davbowman](https://github.com/davbowman) (David Bowman)
* [@erjenkin](https://github.com/erjenkin) (Eric Jenkins)
* [@JakeDean3631](https://github.com/JakeDean3631) (Jake Dean)
* [@japatton](https://github.com/japatton) (Jason Patton)
* [@jcwalker](https://github.com/jcwalker) (Jason Walker)
* [@jesal858](https://github.com/jesal858) (Jeff Salas)
* [@ldillonel](https://github.com/ldillonel) (LaNika Dillon)
* [@LLansey](https://github.com/LLansey) (La'Neice Lansey)
* [@mcollera](https://github.com/mcollera) (Matthew Collera)
* [@nehrua](https://github.com/nehrua) (Nehru Ali)
* [@regedit32](https://github.com/regedit32) (Reggie Gibson)
* [@stevehose](https://github.com/stevehose) (Steve Hose)
* [@winthrop28](https://github.com/winthrop28) (Drew Taylor)
* [@mikedzikowski](https://github.com/mikedzikowski) (Mike Dzikowski)
* [@togriffith](https://github.com/mikedzikowski) (Tony Griffith)
* [@hinderjd](https://github.com/hinderjd) (James Hinders)
