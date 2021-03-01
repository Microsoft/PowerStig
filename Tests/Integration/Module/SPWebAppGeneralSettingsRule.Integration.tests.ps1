#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    $testCases = @(
        @{
            PropertyName    = 'SecurityValidation'
            PropertyValue   = 'True'
            DscResource     = 'SPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure user sessions are terminated upon user logoff, and when idle time limit is exceeded.

            Navigate to Central Administration website.
            
            Click "Application Management".
            
            Click "Manage Web Applications".
            
            Repeat the following steps for each web application:
            -Select the web application.
            -Click "General Settings" in the "Web Application" ribbon.
            -In the "Web Page Security Validation" section, verify that "Security Validation is:" is set to "On" and that the "Security Validation Expires:" setting is set to 15 minutes.
            
            Otherwise, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'SecurityValidationTimeOutMinutes'
            PropertyValue   = '15'
            DscResource     = 'SPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure a session lock occurs after 15 minutes of inactivity.

            In SharePoint Central Administration, click Application Management. 
            
            On the Application Management page, in the Web Applications section, click Manage web applications. 
            
            Verify that each web application meets this requirement.
            - Select the web application.
            - Select General Settings &gt;&gt; General Settings.
            - Navigate to the Web Page Security Validation section.
            - Verify that the Security Validation is "On" and set to expire after 15 minutes or less. 
            
            If Security Validation is "Off" or if the default time-out period is not set to 15 minutes or less for any of the web applications, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'BrowserFileHandling'
            PropertyValue   = 'Strict'
            DscResource     = 'SPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure the execution of prohibited mobile code is prevented.

            Navigate to Central Administration.
            
            Click Manage Web Applications.
            
            For each Web Application in the Farm:
            -Click on the Web Application to configure.
            -Click on the drop-down box below General Settings.
            -Click on General Settings in the drop down box.
            -Under Browser File Handling, verify that "Strict" is selected.
            
            If "Strict" is not selected, this is a finding.'
            ConversionStatus = 'pass'
        },
        @{
            PropertyName    = 'AllowOnlineWebPartCatalog'
            PropertyValue   = 'False'
            DscResource     = 'SPWebAppGeneralSettings'
            CheckContent    = 'Review the SharePoint server configuration to ensure access to the online web part gallery is configured for limited access.

            Log on to Central Administration.
            
            Navigate to the Security page.
            
            Click on "Manage web part security".
            
            For each web application in the web application section, perform the following: 
            -Select the correct web application in the web application section.
            -Verify "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is selected.
            
            If the "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is not checked, this is a finding.'
            ConversionStatus = 'pass'
        }
    )

    Describe 'SPWebAppGeneralSettings Rule Conversion' {
        Context "When SPWebAppGeneralSettings is converted" {
            It 'Should return a correctly converted "<PropertyName>" Rule' -TestCases $testCases {
                param ($PropertyName, $PropertyValue, $DscResource, $CheckContent)

                [xml] $stigRule = Get-TestStigRule -CheckContent $CheckContent -XccdfTitle 'SharePoint'
                $TestFile = Join-Path -Path $TestDrive -ChildPath 'TextData.xml'
                $stigRule.Save($TestFile)
                $rule = ConvertFrom-StigXccdf -Path $TestFile

                $rule.GetType()        | Should -Be 'SPWebAppGeneralSettingsRule'
                $rule.PropertyName     | Should -Be $PropertyName
                $rule.PropertyValue    | Should -Be $PropertyValue
                $rule.DscResource      | Should -Be 'SPWebAppGeneralSettings'
                $rule.conversionstatus | Should -Be 'pass'
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
