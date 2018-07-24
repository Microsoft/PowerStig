#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Stig.TechnologyVersion\Stig.TechnologyVersion.psm1
#endregion
#region Class
<#
    .SYNOPSIS
        This class describes a TechnologyRole

    .DESCRIPTION
        The TechnologyRole class describes a TechnologyRole, the definition of the specific application or portion of an application that
        the Stig applies to. The TechnologyRole is one of a few Technology focused classes that work together to form a complete
        description of the Stig required by the user or application creating the StigData instance.

    .EXAMPLE
        $technologyRole = [TechnologyRole]::new([string] $Name, [TechnologyVersion] $TechnologyVersion)

    .NOTES
        This class requires PowerShell v5 or above.
#>
Class TechnologyRole 
{
    #region Properties
    <#
        .DESCRIPTION
            The name of a role of technology of the Stig to select
    #>
    [string] $Name

    <#
        .DESCRIPTION
            The TechnologyVersion instance for the selected role
    #>
    [TechnologyVersion] $TechnologyVersion

    <#
        .DESCRIPTION
            The available roles for each version of technology currently in PowerStig
    #>
    static $ValidateSet = @"
10 = Client
2012R2 = DNS, DC, MS, IISSite, IISServer
2016 = DC, MS
All = ADDomain, ADForest, FW, IE11
Server2012 = Instance, Database
"@
    #endregion
    #region Constructors
    <#
        .SYNOPSIS
            Parameterless constructor

        .DESCRIPTION
            A parameterless constructor for TechnologyRole. To be used only for
            build/unit testing purposes as Pester currently requires it in order to test
            static methods on powershell classes
    #>
    TechnologyRole() 
    {
        Write-Warning "This constructor is for build testing only."
    }

    <#
        .SYNOPSIS
            Constructor

        .DESCRIPTION
            A constructor for TechnologyRole. Returns a ready to use instance
            of TechnologyRole.

        .PARAMETER Name
            The name of a role of technology of the Stig to select

        .PARAMETER TechnologyVersion
            The TechnologyVersion instance for the selected role
    #>
    TechnologyRole ([string] $Name, [TechnologyVersion] $TechnologyVersion) 
    {
        $this.Name = $Name
        $TechnologyVersion.Validate()
        $this.TechnologyVersion = $TechnologyVersion
        if (!($this.Validate())) 
        {
            throw("The specified Role name is not valid. Please check for available Roles.")
        }
    }
    #endregion
    #region Methods
    <#
        .SYNOPSIS
            Validates the provided name

        .DESCRIPTION
            This method validates that the provided name for the TechnologyRole is
            available for a given TechnologyVersion in PowerStig
    #>
    [bool] Validate () 
    {
        $roles = [TechnologyRole]::Available($this.TechnologyVersion.Name)

        if ($roles -contains $this.Name) 
        {
            return $true
        }
        else 
        {
            Write-Warning -Message "The Roles currently available within PowerStig for $($this.TechnologyVersion.Name) include:`n$($roles -join "`n")"
            return $false
        }
    }
    #endregion
    #region Static Methods
    <#
        .SYNOPSIS
            Returns available TechnologyRoles

        .DESCRIPTION
            This method returns TechnologyRoles for a given TechnologyVersion name currently available in PowerStig

        .PARAMETER TechnologyVersion
            The TechnologyVersion name
    #>
    static [string[]] Available ([string] $TechnologyVersion) 
    {
        $roles = ConvertFrom-StringData -StringData $([TechnologyRole]::ValidateSet)

        if ($roles.$TechnologyVersion) 
        {
            return $roles.$TechnologyVersion.Split(',').Trim()
        }
        else 
        {
            throw("No Roles are available for the Version you have specified. Please check available Versions and run again.")
        }
    }
    #endregion
}
#endregion
#region Footer
Foreach ($supportFile in (Get-ChildItem -Path $PSScriptRoot -Exclude $MyInvocation.MyCommand.Name))
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
Export-ModuleMember -Function '*' -Variable '*'
#endregion
