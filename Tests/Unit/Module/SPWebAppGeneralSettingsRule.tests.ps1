#region Header
. $PSScriptRoot\.tests.header.ps1
#endregion

try
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        #region Test Setup
        $testRuleList = @(
            @{
                OrganizationValueRequired = $false
                PropertyName = 'SecurityValidationTimeOutMinutes'
                PropertyValue = '15'
                CheckContent = 'Review the SharePoint server configuration to ensure a session lock occurs after 15 minutes of inactivity.

                In SharePoint Central Administration, click Application Management. 
                
                On the Application Management page, in the Web Applications section, click Manage web applications. 
                
                Verify that each web application meets this requirement.
                - Select the web application.
                - Select General Settings &gt;&gt; General Settings.
                - Navigate to the Web Page Security Validation section.
                - Verify that the Security Validation is "On" and set to expire after 15 minutes or less. 
                
                If Security Validation is "Off" or if the default time-out period is not set to 15 minutes or less for any of the web applications, this is a finding.'
                FixText = 'Configure the SharePoint server to lock the session lock after 15 minutes of inactivity.

                In SharePoint Central Administration, click Application Management. 
                
                On the Application Management page, in the Web Applications section, click Manage web applications. 
                
                Perform the following steps for each web application.
                - Select web application.
                - Select General Settings >> General Settings.
                - Navigate to Web Page Security Validation.
                - Set the "Security validation is:" property to On.
                - Set the "Security validation expires:" property to After.
                - Set the default time-out period to 15 minutes or less.
                - Select OK to save settings.'
            },
            @{
                OrganizationValueRequired = $false
                PropertyName = 'SecurityValidation'
                PropertyValue = 'True'
                CheckContent = 'Review the SharePoint server configuration to ensure user sessions are terminated upon user logoff, and when idle time limit is exceeded.

                Navigate to Central Administration website.
                
                Click "Application Management".
                
                Click "Manage Web Applications".
                
                Repeat the following steps for each web application:
                -Select the web application.
                -Click "General Settings" in the "Web Application" ribbon.
                -In the "Web Page Security Validation" section, verify that "Security Validation is:" is set to "On" and that the "Security Validation Expires:" setting is set to 15 minutes.
                
                Otherwise, this is a finding.'
                FixText = 'Configure the SharePoint server to terminate user sessions upon user logoff, and when idle time limit is exceeded.

                Navigate to Central Administration website.
                
                Click "Application Management".
                
                Click "Manage Web Applications".
                
                Repeat the following steps for each web application:
                -Select the web application.
                -Click "General Settings" in the "Web Application" ribbon.
                -In the "Web Page Security Validation" section, set "Security Validation:" to "On" and that the "Security Validation Expires:" setting is set to 15 minutes.'
            },
            @{
                OrganizationValueRequired = $false
                PropertyName = 'BrowserFileHandling'
                PropertyValue = 'Strict'
                CheckContent = 'Review the SharePoint server configuration to ensure the execution of prohibited mobile code is prevented.

                Navigate to Central Administration.
                
                Click Manage Web Applications.
                
                For each Web Application in the Farm:
                -Click on the Web Application to configure.
                -Click on the drop-down box below General Settings.
                -Click on General Settings in the drop down box.
                -Under Browser File Handling, verify that "Strict" is selected.
                
                If "Strict" is not selected, this is a finding.'
                FixText = 'Configure SharePoint to prevent the execution of prohibited mobile code.

                Navigate to Central Administration.
                
                Click Manage Web Applications.
                
                For each Web Application in the Farm:
                -Click on the Web Application to configure.
                -Click on the drop-down box below General Settings.
                -Click on General Settings in the drop down box.
                -Under Browser File Handling, verify that "Strict" is selected.
                
                If "Strict" is not selected, this is a finding.
                
                Mobile code can be further restricted to meet the policy of the organization:
                
                Log on to a farm server hosting Central Administration.
                
                Click Start and type SharePoint 2013 Management Shell followed by Enter.
                
                Type $webApp = Get-SPWebApplication -Identity {URL} where {URL is the {URL} of the web application to configure.
                
                Press Enter.
                
                Type $webApp.AllowedInlineDownloadedMimeTypes. Remove ({mime type}) where {mime type} represents the mime type to remove (e.g., application\x-shockwave-flash).
                
                Press Enter.'
            },
            @{
                OrganizationValueRequired = $false
                PropertyName = 'AllowOnlineWebPartCatalog'
                PropertyValue = 'False'
                CheckContent = 'Review the SharePoint server configuration to ensure access to the online web part gallery is configured for limited access.

                Log on to Central Administration.
                
                Navigate to the Security page.
                
                Click on "Manage web part security".
                
                For each web application in the web application section, perform the following: 
                -Select the correct web application in the web application section.
                -Verify "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is selected.
                
                If the "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section is not checked, this is a finding.'
                FixText = 'Configure the SharePoint server for limited access to the Online Web Part Gallery.

                Enable the "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option for each web application. 
                
                Log on to Central Administration.
                
                Navigate to the Security page.
                
                Click on "Manage web part security".
                
                For each web application in the web application section, perform the following: 
                -Select the correct web application in the web application section.
                -Select the "Prevents users from accessing the Online Web Part Gallery, and helps to improve security and performance" option in the Online Web Part Gallery section.
                
                Select "OK".'
            }
        )
        #endregion

        foreach ($testRule in $testRuleList)
        {
            . $PSScriptRoot\Convert.CommonTests.ps1
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
