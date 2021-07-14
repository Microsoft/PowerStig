#region Header
. $PSScriptRoot\.tests.header.ps1
# endregion

try 
{
    InModuleScope -ModuleName "$($global:moduleName).Convert" {
        # region Test Setup
        $testRuleList = @(
            @{
                # V-213961 (SQL 2016)
                GetScript     = '# Fetches Named Pipes Protocol status
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                if (''SQLConnectionName'' -notmatch ''\\'')
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                }
                else
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                }

                return @{Result = $smoSqlNamedPipes.IsEnabled}'
                TestScript    = '# Fetches Named Pipes Protocol status
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                if (''SQLConnectionName'' -notmatch ''\\'')
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                }
                else
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                }

                if ($smoSqlNamedPipes.IsEnabled -eq $True)
                {
                    return $False
                }
                else
                {
                    return $True
                }'
                SetScript     = '# Sets the Named Pipes Protocol to disabled.
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                if (''SQLConnectionName'' -notmatch ''\\'')
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                    $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                    $np.IsEnabled = $False
                    $np.Alter()
                }
                else
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                    $smoSqlNamedPipes = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''np'' }
                    $np = $smoSqlConfigServices.GetSmoObject($smoSqlNamedPipes.Urn.Value)
                    $np.IsEnabled = $False
                    $np.Alter()
                }'
                CheckContent              = 'To determine the protocol(s) enabled for SQL Server, open SQL Server Configuration Manager. In the left-hand pane, expand SQL Server Network Configuration. Click on the entry for the SQL Server instance under review: "Protocols for ". The right-hand pane displays the protocols enabled for the instance. 

                                                    If Named Pipes is enabled and not specifically required and authorized, this is a finding. 

                                                    If any listed protocol is enabled but not authorized, this is a finding.'
                OrganizationValueRequired = $false
            },
            @{
                # V-213931 (SQL 2016)
                GetScript                 = '# Fetches the SPN for the SQL Server Engine service account.
                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $sqlServiceEngineAccount = $smoSqlConnection.ServiceAccount

                $accountSPN = setspn -l $sqlServiceEngineAccount

                $sqlSpnList = @{}

                foreach ($spn in $accountSpn)
                {
                    if ($spn -match "MSSQLSvc/$env:ComputerName*")
                    {
                        $guid = New-Guid
                        $sqlSpnList.Add($guid,$spn)
                    }
                }

                return @{Result = $sqlSpnList.Values}'
                TestScript                = '# Fetches SQL Server port in use.
                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')
 
                if (''SQLConnectionName'' -notmatch ''\\'')
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                }
                else
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1]}
                }

                $smoSqlTcpIp = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''tcp'' }
                $smoSqlIpConfigs = $smoSqlTcpIp.IPAddresses | Where-Object { $_.Name -eq ''IPALL'' }
                $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpPort''} | Select-Object -Property Value

                if (!$smoSqlPort.Value)
                {
                    $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpDynamicPorts'' } | Select-Object -Property Value
                }

                [string]$smoSqlPort = $smoSqlPort

                # Fetches SQL Server service account in use.
                $SqlServiceEngineAccount = $smoSqlConnection.ServiceAccount

                # Fetches SPN currently created.
                $fetchSqlSpn = SetSPN -l $sqlServiceEngineAccount

                # Fetches FQDN.
                $fetchDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

                # Removes whitespace from setspn command.
                $formatFetchSqlSpn = @()
                foreach ($badFormat in $fetchSqlSpn)
                {
                    $formatFetchSqlSpn += [string]$badFormat.TrimStart()
                }

                $matchedSpn = @()
                $listenerMatchedSpn = @()

                # Determine if Always-On High Availability is enabled
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
                $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery, $rootSqlConnection)
                $haTable = New-Object System.Data.DataTable ''HA_Table''
                $listenerTable = New-Object System.Data.DataTable ''Listener_Table''

                $rootSqlConnection.Open()
                $haAdapter.Fill($haTable) | Out-Null
                $rootSqlConnection.Close()

                # Compares SPN''s that exist to SPN''s that should exist for the Availability Group Listener
                if ($HATable.IsHadrEnabled -eq "1")
                {
                    $listenerQuery = ''SELECT dns_name, port from sys.availability_group_listeners''
                    $listenerAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($listenerQuery, $rootSqlConnection)

                    $rootSqlConnection.Open()
                    $listenerAdapter.Fill($listenerTable) | Out-Null
                    $rootSqlConnection.Close()

                    # Verify a listener exists then compare
                    if ($listenerTable.Rows.Count -gt 0)
                    {
                        $listenerSpn = @(''MSSQLSvc/'' + $listenerTable.dns_name + ''.'' + $FetchDomain + '':'' + $listenerTable.port), (''MSSQLSvc/'' + $listenerTable.dns_name + '':'' + $listenerTable.port)
                        foreach ($existingSpn in $formatFetchSqlSpn)
                        {
                            foreach ($requiredSpn in $listenerSpn)
                            {
                                if ($requiredSpn -eq $existingSpn)
                                {
                                    $listenerMatchedSpn += $requiredSpn
                                }
                             }
                         }
                     }
                 }

                 # Compares SPN''s that exist to SPN''s that should exist for SQL Server.
                 if ($smoSqlConnection.ServiceName -eq ''MSSQLSERVER'')
                 {
                     $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain)

                     foreach ($existingSpn in $formatFetchSqlSpn)
                     {
                         foreach ($requiredSpn in $sqlSpn)
                         {
                             if ($requiredSpn -eq $existingSpn)
                             {
                                 $matchedSpn += $requiredSpn
                             }
                         }
                     }
                 }
                 else
                 {
                     $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $FetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlConnection.ServiceName)

                     foreach ($existingSpn in $formatFetchSqlSpn)
                     {
                         foreach ($requiredSpn in $sqlSpn)
                         {
                             if ($requiredSpn -eq $existingSpn)
                             {
                                 $matchedSpn += $requiredSpn
                             }
                         }
                     }
                 }

                 if ($matchedSpn.Count -lt 2 -or ($listenerTable.Rows.Count -gt 0 -and $listenerMatchedSpn.Count -lt 2))
                 {
                     return $False
                 }
                 else
                 {
                 return $True
                 }'
                SetScript                 = '# Fetches SQL Server port in use.
                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $smoSqlConfigServices = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer(''HostName'')

                if (''SQLConnectionName'' -notmatch ''\\'')
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName'' }
                }
                else
                {
                    $smoSqlAgent = $smoSqlConfigServices.ServerInstances | Where-Object { $_.Name -eq ''SQLInstanceName''.Split("{\}")[1] }
                }

                $smoSqlTcpIp = $smoSqlAgent.ServerProtocols | Where-Object { $_.Name -eq ''tcp'' }
                $smoSqlIPConfigs = $smoSqlTcpIp.IPAddresses | Where-Object { $_.Name -eq ''IPALL'' }
                $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpPort'' } | Select-Object -Property Value

                if (!$smoSqlPort.Value)
                {
                    $smoSqlPort = $smoSqlIPConfigs.IPAddressProperties | Where-Object { $_.Name -eq ''TcpDynamicPorts'' } | Select-Object -Property Value
                }

                [string]$smoSqlPort = $smoSqlPort

                # Fetches SQL Server service account in use.
                $sqlServiceEngineAccount = $smoSqlConnection.ServiceAccount

                # Fetches FQDN.
                $fetchDomain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

                # Determine if Always-On High Availability is enabled
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
                $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery, $rootSqlConnection)
                $haTable = New-Object System.Data.DataTable ''HA_Table''
                $listenerTable = New-Object System.Data.DataTable ''Listener_Table''

                $rootSqlConnection.Open()
                $haAdapter.Fill($haTable) | Out-Null
                $rootSqlConnection.Close()

                # Determine if a listener exists
                if ($haTable.IsHadrEnabled -eq ''1'')
                {
                    $listenerQuery = ''SELECT dns_name, port FROM sys.availability_group_listeners''
                    $listenerAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($listenerQuery, $rootSqlConnection)

                    $rootSqlConnection.Open()
                    $listenerAdapter.Fill($listenerTable) | Out-Null
                    $rootSqlConnection.Close()

                    if ($listenerTable.Rows.Count -gt 0)
                    {
                        $listenerSpn = @(''MSSQLSvc/'' + $listenerTable.dns_name + ''.'' + $fetchDomain + '':'' + $listenerTable.port), (''MSSQLSvc/'' + $listenerTable.dns_name + '':'' + $listenerTable.port)
                        foreach ($spn in $listenerSpn)
                        {
                            setspn -s $spn $sqlServiceEngineAccount | Out-Null
                        }
                    }
                }

                # Creates missing SQL Server Engine SPN''s.
                if ($smoSqlConnection.ServiceName -eq ''MSSQLSERVER'')
                {
                    $SqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain)
                    foreach ($spn in $sqlSpn)
                    {
                        setspn -s $spn $sqlServiceEngineAccount | Out-Null
                    }
                }
                else
                {
                    $sqlSpn = @("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlPort.Split("{=}")[2]), ("MSSQLSvc/$env:ComputerName" + ''.'' + $fetchDomain + '':'' + $smoSqlConnection.ServiceName)
                    foreach ($spn in $sqlSpn)
                    {
                        setspn -s $spn $sqlServiceEngineAccount | Out-Null
                    }
                }'
                CheckContent              = 'If the SQL Server is not part of an Active Directory domain, this finding is Not Applicable. 

                Obtain the fully qualified domain name of the SQL Server instance: 
                
                Launch Windows Explorer. 
                
                Right-click on "Computer" or "This PC" (Varies by OS level), click "Properties". 
                
                Note the value shown for "Full computer name". 
                
                *** Note: For a cluster, this value must be obtained from the Failover Cluster Manager. *** 
                
                Obtain the TCP port that is supporting the SQL Server instance: 
                
                Click Start >> Type "SQL Server 2016 Configuration Manager" >> From the search results, click "SQL Server 2016 Configuration Manager". 
                
                From the tree on the left, expand "SQL Server Network Configuration". 
                
                Click "Protocols for <Instance Name>" where <Instance Name> is the name of the instance (MSSQLSERVER is the default name). 
                
                In the right pane, right-click on "TCP/IP" and choose "Properties". 
                
                In the window that opens, click the "IP Addresses" tab. 
                
                Note the TCP port configured for the instance. 
                
                Obtain the service account that is running the SQL Server service: 
                
                Click "Start". 
                Type "SQL Server 2016 Configuration Manager". 
                From the search results, click "SQL Server 2016 Configuration Manager". 
                
                From the tree on the left, select "SQL Server Services". 
                
                Note the account listed in the "Log On As" column for the SQL Server instance being reviewed. 
                
                Launch a command-line or PowerShell window. 
                
                Enter the following command where <Service Account> is the identity of the service account. 
                
                setspn -L <Service Account> 
                
                Example: setspn -L CONTOSO\sql2016svc 
                
                Review the Registered Service Principal Names returned. 
                
                If the listing does not contain the following supported service principal names (SPN) formats, this is a finding. 
                
                Named instance
                 MSSQLSvc/<FQDN>:[<port> | <instancename>], where:
                 MSSQLSvc is the service that is being registered.
                 <FQDN> is the fully qualified domain name of the server.
                 <port> is the TCP port number.
                 <instancename> is the name of the SQL Server instance.
                
                Default instance
                 MSSQLSvc/<FQDN>:<port> | MSSQLSvc/<FQDN>, where:
                 MSSQLSvc is the service that is being registered.
                 <FQDN> is the fully qualified domain name of the server.
                 <port> is the TCP port number.
                
                If the MSSQLSvc service is registered for any fully qualified domain names that do not match the current server, this may indicate the service account is shared across SQL Server instances. Review server documentation, if the sharing of service accounts across instances is not documented and authorized, this is a finding.
                '
                OrganizationValueRequired = $false
            },
            @{
                # V-213934 (SQL 2016)
                GetScript                 = '# Fetches NT AUTHORITY/SYSTEM permissions.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $PermissionQuery = ''SELECT a.permission_name, b.name
                                     FROM sys.server_permissions a
                                     JOIN sys.server_principals b
                                     ON a.grantee_principal_id = b.principal_id
                                     WHERE b.name = N''''NT AUTHORITY\SYSTEM''''''

                $permissionAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($permissionQuery,$rootSqlConnection)
                $permissionTable = New-Object System.Data.DataTable ''Permission_Table''

                $rootSqlConnection.Open()
                $permissionAdapter.Fill($permissionTable) | Out-Null
                $rootSqlConnection.Close()

                $permissionsList = @{}

                foreach ($permission in $permissionTable)
                {
                    $guid = New-Guid
                    $permissionsList.Add($guid,$permission.Permission_Name)
                }

                return @{Result = $permissionsList.Values}'
                TestScript                = '# Fetches NT AUTHORITY/SYSTEM permissions.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $permissionQuery = ''SELECT a.permission_name, b.name
                                     FROM sys.server_permissions a
                                     JOIN sys.server_principals b
                                     ON a.grantee_principal_id = b.principal_id
                                     WHERE b.name = N''''NT AUTHORITY\SYSTEM''''''
 
                $permissionAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($permissionQuery,$rootSqlConnection)
                $permissionTable = New-Object System.Data.DataTable ''Permission_Table''

                $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
                $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery,$rootSqlConnection)
                $haTable = New-Object System.Data.DataTable ''HA_Table''

                $rootSqlConnection.Open()
                $permissionAdapter.Fill($permissionTable) | Out-Null
                $haAdapter.Fill($haTable) | Out-Null
                $rootSqlConnection.Close()

                # Checks Permissions Based on if there is HA.
                if ($haTable.IsHadrEnabled -eq ''1'')
                {
                    $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE'',''ALTER ANY AVAILABILITY GROUP'',''CREATE AVAILABILITY GROUP'',''VIEW SERVER STATE''
                    $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name

                    $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>'' } | Select-Object -Property InputObject

                    if ($permissionsRemove)
                    {
                        return $false
                    }
                    else
                    {
                        return $true
                    }
                 }
                 elseif ($haTable.IsClustered -eq ''1'')
                 {
                     $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE'',''VIEW SERVER STATE''
                     $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name

                     $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>'' } | Select-Object -Property InputObject

                     if ($permissionsRemove)
                     {
                         return $false
                     }
                     else
                     {
                         return $true
                     }
                 }
                 else
                 {
                     $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE''
                     $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name

                     $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>'' } | Select-Object -Property InputObject

                     if ($permissionsRemove)
                     {
                         return $false
                     }
                     else
                     {
                         return $true
                     }
                 }'
                SetScript                 = '# Fetches NT AUTHORITY/SYSTEM permissions.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI; Pooling=False;'')
                $permissionQuery = ''EXECUTE AS LOGIN = ''''NT AUTHORITY\SYSTEM''''
                                     SELECT * FROM fn_my_permissions(NULL,NULL)''

                $permissionAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($permissionQuery,$rootSqlConnection)
                $permissionTable = New-Object System.Data.DataTable ''Permission_Table''

                # Fetches high availability configuration information.
                $haQuery = ''SELECT SERVERPROPERTY(''''IsClustered'''') as IsClustered, SERVERPROPERTY(''''IsHadrEnabled'''') as IsHadrEnabled''
                $haAdapter = New-Object System.Data.SqlClient.SqlDataAdapter($haQuery,$rootSqlConnection)
                $haTable = New-Object System.Data.DataTable ''HA_Table''

                $rootSqlConnection.Open()
                $permissionAdapter.Fill($permissionTable) | Out-Null
                $haAdapter.Fill($haTable) | Out-Null
                $rootSqlConnection.Close()

                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $smoSqlConnection.ConnectionContext.SqlExecutionModes = [Microsoft.SqlServer.Management.Common.SqlExecutionModes]::ExecuteSql

                # Checks permissions based on if there is HA.
                if ($haTable.IsHadrEnabled -eq ''1'')
                {
                    $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE'',''ALTER ANY AVAILABILITY GROUP'',''CREATE AVAILABILITY GROUP'',''VIEW SERVER STATE''
                    $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name

                    $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>'' } | Select-Object -Property InputObject

                    if ($permissionsRemove)
                    {
                        foreach($rPermission in $permissionsRemove)
                        {
                            # Removes Permissions
                            $revokePerm = $rPermission.InputObject
                            $removePermissionsQuery = "REVOKE $revokePerm FROM [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($removePermissionsQuery)
                        }

                        foreach($sPermission in $stigPermissions)
                        {
                            # Add Permissions
                            $addPermissionsQuery = "GRANT $sPermission TO [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($addPermissionsQuery)
                        }
                    }
                }
                elseif ($haTable.IsClustered -eq ''1'')
                {
                    $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE'',''VIEW SERVER STATE''
                    $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name

                    $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>'' } | Select-Object -Property InputObject

                    if ($permissionsRemove)
                    {
                        foreach ($rPermission in $permissionsRemove)
                        {
                            # Removes Permissions
                            $revokePerm = $rPermission.InputObject
                            $removePermissionsQuery = "REVOKE $revokePerm FROM [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($removePermissionsQuery)
                        }

                        foreach ($sPermission in $stigPermissions)
                        {
                            # Add Permissions
                            $addPermissionsQuery = "GRANT $sPermission TO [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($addPermissionsQuery)
                        }
                    }
                }
                else
                {
                    $stigPermissions = ''CONNECT SQL'',''VIEW ANY DATABASE''
                    $permissionsCompare = Compare-Object -ReferenceObject $stigPermissions -DifferenceObject $permissionTable.Permission_Name
                    $permissionsRemove = $permissionsCompare | Where-Object { $_.SideIndicator -eq ''=>''} | Select-Object -Property InputObject

                    if ($permissionsRemove)
                    {
                        foreach ($rPermission in $permissionsRemove)
                        {
                            # Removes Permissions
                            $revokePerm = $rPermission.InputObject
                            $removePermissionsQuery = "REVOKE $RevokePerm FROM [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($removePermissionsQuery)
                        }

                        foreach ($sPermission in $stigPermissions)
                        {
                            # Add Permissions
                            $addPermissionsQuery = "GRANT $SPermission TO [NT AUTHORITY\SYSTEM]"
                            $smoSqlConnection.ConnectionContext.ExecuteNonQuery($addPermissionsQuery)
                        }
                    }
                }'
                CheckContent              = 'Execute the following queries. The first query checks for Clustering and Availability Groups being provisioned in the Database Engine. The second query lists permissions granted to the Local System account.

                SELECT
                 SERVERPROPERTY(''IsClustered'') AS [IsClustered],
                 SERVERPROPERTY(''IsHadrEnabled'') AS [IsHadrEnabled]
                
                EXECUTE AS LOGIN = ''NT AUTHORITY\SYSTEM''
                
                SELECT * FROM fn_my_permissions(NULL, ''server'')
                
                REVERT
                
                GO
                
                
                If IsClustered returns 1, IsHadrEnabled returns 0, and any permissions have been granted to the Local System account beyond "CONNECT SQL", "VIEW SERVER STATE", and "VIEW ANY DATABASE", this is a finding.
                
                If IsHadrEnabled returns 1 and any permissions have been granted to the Local System account beyond "CONNECT SQL", "CREATE AVAILABILITY GROUP", "ALTER ANY AVAILABILITY GROUP", "VIEW SERVER STATE", and "VIEW ANY DATABASE", this is a finding.
                
                If both IsClustered and IsHadrEnabled return 0 and any permissions have been granted to the Local System account beyond "CONNECT SQL" and "VIEW ANY DATABASE", this is a finding.'
                OrganizationValueRequired = $false
            },
            @{
                # V-214031 (SQL 2016)
                GetScript                 = '# Fetches database mirroring endpoint encryption type.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, type_desc, encryption_algorithm_desc,encryption_algorithm
                                   FROM sys.database_mirroring_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSqlConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSQLConnection.Close()

                if ($endPointTable.Rows.Count -ge 1)
                {
                    return @{Result = $endPointTable.Encryption_Algorithm}
                }
                else
                {
                    return @{Result = ""}
                }'
                TestScript                = '# Fetches database mirroring endpoint encryption type.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, type_desc, encryption_algorithm_desc,encryption_algorithm
                                   FROM sys.database_mirroring_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSqlConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSQLConnection.Close()

                if ([string]::IsNullOrEmpty($endPointTable) -or $endPointTable.Encryption_Algorithm -eq 2)
                {
                    return $true
                }
                else
                {
                    return $false
                }'
                SetScript                 = '# Fetches database mirroring endpoint encryption type.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, type_desc, encryption_algorithm_desc,encryption_algorithm
                                   FROM sys.database_mirroring_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSqlConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSqlConnection.Close()

                $endPointName = $endPointTable.Name

                # Sets database mirroring endpoint encryption type to STIG standard.
                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $smoSqlConnection.ConnectionContext.SqlExecutionModes = [Microsoft.SqlServer.Management.Common.SqlExecutionModes]::ExecuteSql
                $endPointEncQuery = "ALTER ENDPOINT [$endPointName] FOR database_mirroring (ENCRYPTION = REQUIRED ALGORITHM AES)"

                $smoSqlConnection.ConnectionContext.ExecuteNonQuery($endPointEncQuery)'
                CheckContent              = 'If the data owner does not have a strict requirement for ensuring data integrity and confidentiality is maintained at every step of the data transfer and handling process, and the requirement is documented and authorized, this is not a finding.

                If Database Mirroring is in use, run the following to check for encrypted transmissions:  
                
                SELECT name, type_desc, encryption_algorithm_desc
                FROM sys.database_mirroring_endpoints
                WHERE encryption_algorithm != 2
                
                If any records are returned, this is a finding.'
                OrganizationValueRequired = $false
            },
            @{
                # V-214032 (SQL 2016)
                GetScript                 = '# Fetches service broker endpoint encryption type.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, encryption_algorithm
                                   FROM sys.service_broker_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSqlConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSQLConnection.Close()

                if ($endPointTable.Rows.Count -ge 1)
                {
                    return @{Result = $endPointTable.Encryption_Algorithm}
                }
                else
                {
                    return @{Result = ""}
                }'
                TestScript                = '# Fetches service broker endpoint encryption type.
                $rootSqlConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, encryption_algorithm
                                   FROM sys.service_broker_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSqlConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSqlConnection.Close()

                if ([string]::IsNullOrEmpty($endPointTable) -or $endPointTable.Encryption_Algorithm -eq 2)
                {
                    return $true
                }
                else
                {
                    return $false
                }'
                SetScript                 = '# Fetches service broker endpoint encryption type.
                $rootSQLConnection = New-Object System.Data.SqlClient.SqlConnection(''Data Source = SQLConnectionName ;Initial Catalog=Master;Integrated Security=SSPI;'')
                $endPointQuery = ''SELECT name, encryption_algorithm
                                   FROM sys.service_broker_endpoints''

                $endPointAdapater = New-Object System.Data.SqlClient.SqlDataAdapter($endPointQuery,$rootSqlConnection)
                $endPointTable = New-Object System.Data.DataTable ''EndPoint_Table''

                $rootSQLConnection.Open()
                $endPointAdapater.Fill($endPointTable) | Out-Null
                $rootSqlConnection.Close()

                $endPointName = $endPointTable.Name

                # Sets service broker endpoint encryption type to STIG standard.
                $smoSqlConnection = New-Object Microsoft.SqlServer.Management.Smo.Server(''SQLConnectionName'')
                $smoSqlConnection.ConnectionContext.SqlExecutionModes = [Microsoft.SqlServer.Management.Common.SqlExecutionModes]::ExecuteSql
                $endPointEncQuery = "ALTER ENDPOINT [$endPointName] FOR service_broker (ENCRYPTION = REQUIRED ALGORITHM AES)"

                $smoSqlConnection.ConnectionContext.ExecuteNonQuery($endPointEncQuery)'
                CheckContent              = 'If the data owner does not have a strict requirement for ensuring data integrity and confidentiality is maintained at every step of the data transfer and handling process, and the requirement is documented and authorized, this is not a finding.

                If SQL Service Broker is in use, run the following to check for encrypted transmissions:  
                
                SELECT name, type_desc, encryption_algorithm_desc
                FROM sys.service_broker_endpoints
                WHERE encryption_algorithm != 2
                
                If any records are returned, this is a finding.'
                OrganizationValueRequired = $false
            },
            @{
                # V-214042 (SQL 2016)
                GetScript                 = '# Fetches SQL Server Browser status.
                $sqlBrowser = Get-Service -Name SQLBrowser | Select-Object -Property Status, StartType
                $sqlBrowserList = @{}
                $sqlBrowserList.Add(''Status'',$SQLBrowser.Status)
                $sqlBrowserList.Add(''StartType'', $SQLBrowser.StartType)
                return @{Result = $sqlBrowserList.Values}'
                TestScript                = '# Fetches SQL Server Browser status.
                if (''SQLInstanceName'' -eq ''MSSQLSERVER'')
                {
                    $sqlBrowser = Get-Service -Name SQLBrowser | Select-Object -Property Status, StartType

                    if ($sqlBrowser.StartType -eq ''Disabled'')
                    {
                        return $true
                    }
                    else
                    {
                        return $false
                    }
                 }
                 else
                 {
                     return $true
                 }'
                SetScript                 = '# Disabled the SQL Server Browser service.
                Set-Service -Name SQLBrowser -StartupType Disabled
                $sqlBrowser = Get-Service -Name SQLBrowser | Select-Object -Property Status, StartType

                if ($sqlBrowser.Status -eq ''Running'')
                {
                    Stop-Service -Name SQLBrowser
                }'
                CheckContent              = 'If the need for the SQL Server Browser service is documented and authorized, this is not a finding. 

                Open the Services tool. 
                
                Either navigate, via the Windows Start Menu and/or Control Panel, to "Administrative Tools", and select "Services"; or at a command prompt, type "services.msc" and press the "Enter" key. 
                
                Scroll to "SQL Server Browser". 
                
                If its Startup Type is not shown as "Disabled", this is a finding.
                '
                OrganizationValueRequired = $false
            }
        )
        # endregion

        # region Add Custom Tests Here

        Describe 'Method Function Tests'{
            foreach ($testRule in $testRuleList)
            {
                # Whitespace is removed from the script blocks to create a valid test.
                $getScript  = Get-GetScript -CheckContent $testRule.CheckContent
                $getScript  = ($getScript -replace "\s{2,}", " ")

                $testScript = Get-TestScript -CheckContent $testRule.CheckContent
                $testScript = ($testScript -replace "\s{2,}", " ")

                $setScript  = Get-SetScript -CheckContent $testRule.CheckContent
                $setScript  = ($setScript -replace "\s{2,}", " ")

                Context 'PowerShellScriptQuery Get-GetScript'{
                    It 'Should return the get script block'{
                        $getScript | Should Be ($testRule.GetScript -replace "\s{2,}" , " ")
                    }
                }

                Context 'PowerShellScriptQuery Get-TestScript'{
                    It 'Should return the test script block'{
                        $testScript | Should Be ($testRule.TestScript -replace "\s{2,}" , " ")
                    }
                }

                Context 'PowerShellScriptQuery Get-SetScript'{
                    It 'Should return the set script block'{
                        $setScript | Should Be ($testRule.SetScript -replace "\s{2,}" , " ")
                    }
                }

                $scriptblockCount = ($testRule.Keys | Where-Object {$_ -like "*Script*"}).Count
                
                Context 'PowerShellScriptQuery scriptblock count'{
                    It 'Should return the count of scriptblocks'{
                        $scriptblockCount | Should Be '3'
                    }
                }
            }
        }
    }
}
finally
{
    . $PSScriptRoot\.tests.footer.ps1
}
