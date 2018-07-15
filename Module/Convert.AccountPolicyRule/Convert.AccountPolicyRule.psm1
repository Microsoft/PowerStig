#region Header
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
using module .\..\Common\Common.psm1
using module .\..\Convert.Stig\Convert.Stig.psm1

$exclude = @($MyInvocation.MyCommand.Name,'Template.*.txt')
$supportFileList = Get-ChildItem -Path $PSScriptRoot -Exclude $exclude
Foreach ($supportFile in $supportFileList)
{
    Write-Verbose "Loading $($supportFile.FullName)"
    . $supportFile.FullName
}
#endregion
#region Class
Class AccountPolicyRule : STIG
{
    # Properties
    [string] $PolicyName
    [string] $PolicyValue

    # Constructor
    AccountPolicyRule ( [xml.xmlelement] $StigRule )
    {
        $this.InvokeClass( $StigRule )
    }

    # Methods
    [void] SetPolicyName ()
    {
        $thisPolicyName = Get-AccountPolicyName -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyName ) )
        {
            $this.set_PolicyName( $thisPolicyName )
        }
    }

    [bool] TestPolicyValueForRange ()
    {
        if (Test-SecurityPolicyContainsRange -CheckContent $this.SplitCheckContent)
        {
            return $true
        }
        else
        {
            return $false
        }
    }

    [void] SetPolicyValue ()
    {
        $thisPolicyValue = Get-AccountPolicyValue -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValue ) )
        {
            $this.set_PolicyValue( $thisPolicyValue )
        }
    }

    [void] SetPolicyValueRange ()
    {
        $this.set_OrganizationValueRequired($true)

        $thisPolicyValueTestString = Get-SecurityPolicyOrganizationValueTestString -CheckContent $this.SplitCheckContent

        if ( -not $this.SetStatus( $thisPolicyValueTestString ) )
        {
            $this.set_OrganizationValueTestString( $thisPolicyValueTestString )
        }
    }
}
#endregion
