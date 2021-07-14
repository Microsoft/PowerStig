# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.
#region Method Functions
<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule GetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-GetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkcontent)
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $getScript = '# Fetches Named Pipes Protocol status
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
        }
        {$PSItem -Match 'setspn -L'}
        {
            $getScript = '# Fetches the SPN for the SQL Server Engine service account.
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
        }
        {$PSItem -Match 'If IsClustered returns 1'}
        {
            $getScript = '# Fetches NT AUTHORITY/SYSTEM permissions.
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
        }
        {$PSItem -Match 'sys.database_mirroring_endpoints'}
        {
            $getScript = '# Fetches database mirroring endpoint encryption type.
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
        }
        {$PSItem -Match 'sys.service_broker_endpoints'}
        {
            $getScript = '# Fetches service broker endpoint encryption type.
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
        }
        {$PSItem -Match 'Windows Start Menu and/or Control Panel,'}
        {
            $getScript = '# Fetches SQL Server Browser status.
                          $sqlBrowser = Get-Service -Name SQLBrowser | Select-Object -Property Status, StartType
                          $sqlBrowserList = @{}
                          $sqlBrowserList.Add(''Status'',$SQLBrowser.Status)
                          $sqlBrowserList.Add(''StartType'', $SQLBrowser.StartType)
                          return @{Result = $sqlBrowserList.Values}'
        }
    }

    return $getScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule TestScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-TestScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $testScript = '# Fetches Named Pipes Protocol status
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
        }
        {$PSItem -Match 'setspn -L'}
        {
            $testScript = '# Fetches SQL Server port in use.
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
        }
        {$PSItem -Match 'If IsClustered returns 1'}
        {
            $testScript = '# Fetches NT AUTHORITY/SYSTEM permissions.
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
        }
        {$PSItem -Match 'sys.database_mirroring_endpoints'}
        {
            $testScript = '# Fetches database mirroring endpoint encryption type.
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
        }
        {$PSItem -Match 'sys.service_broker_endpoints'}
        {
            $testScript = '# Fetches service broker endpoint encryption type.
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
        }
        {$PSItem -Match 'Windows Start Menu and/or Control Panel,'}
        {
            $testScript = '# Fetches SQL Server Browser status.
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
        }
    }

    return $testScript
}

<#
    .SYNOPSIS
        Sets the PowerShellScriptQueryRule SetScript from the check-content element in the xccdf.

    .PARAMETER CheckContent
        Specifies the check-content element in the xccdf
#>
function Get-SetScript
{
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckContent
    )

    switch ($checkContent)
    {
        {$PSItem -Match 'Named Pipes'}
        {
            $setScript = '# Sets the Named Pipes Protocol to disabled.
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
        }
        {$PSItem -Match 'setspn -L'}
        {
            $setScript = '# Fetches SQL Server port in use.
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
        }
        {$PSItem -Match 'If IsClustered returns 1'}
        {
            $setScript = '# Fetches NT AUTHORITY/SYSTEM permissions.
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
        }
        {$PSItem -Match 'sys.database_mirroring_endpoints'}
        {
            $setScript =  '# Fetches database mirroring endpoint encryption type.
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
        }
        {$PSItem -Match 'sys.service_broker_endpoints'}
        {
            $setScript = '# Fetches service broker endpoint encryption type.
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
        }
        {$PSItem -Match 'Windows Start Menu and/or Control Panel,'}
        {
            $setScript = '# Disabled the SQL Server Browser service.
                          Set-Service -Name SQLBrowser -StartupType Disabled
                          $sqlBrowser = Get-Service -Name SQLBrowser | Select-Object -Property Status, StartType

                          if ($sqlBrowser.Status -eq ''Running'')
                          {
                              Stop-Service -Name SQLBrowser
                          }'
        }
    }

    return $setScript
}
