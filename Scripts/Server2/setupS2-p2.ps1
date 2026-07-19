Write-Host "Configureer Secondary DNS Zones"
Add-DnsServerSecondaryZone -Name "WS2-25-martijn.hogent" -ZoneFile "WS2-25-martijn.hogent.dns" -MasterServers "192.168.25.10" -ErrorAction SilentlyContinue
Add-DnsServerSecondaryZone -Name "25.168.192.in-addr.arpa" -ZoneFile "25.168.192.in-addr.arpa.dns" -MasterServers "192.168.25.10" -ErrorAction SilentlyContinue

$sqlSetupPath = "D:\setup.exe"
$sqlConfigFile = "C:\Users\Public\shared_folder\sql\sql_config.ini"
$odbcPath = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\"

Write-Host "Installeer SQL server"
Start-Process -FilePath $sqlSetupPath -ArgumentList "/ConfigurationFile=$sqlConfigFile /IACCEPTSQLSERVERLICENSETERMS" -Wait

$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
[Environment]::SetEnvironmentVariable("Path", "$currentPath;$odbcPath", "Machine")

$instanceName = "SERVER2"

$wmi = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement16" -Class "ServerNetworkProtocol" |
       Where-Object { $_.InstanceName -eq $instanceName -and $_.ProtocolName -eq "Tcp" }
if ($null -eq $wmi) {
    $wmi = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement16" -Class "ServerNetworkProtocol" |
           Where-Object { $_.InstanceName -eq "MSSQLSERVER" -and $_.ProtocolName -eq "Tcp" }
    if ($null -ne $wmi) { $instanceName = "MSSQLSERVER" }
}
if ($null -ne $wmi) {
    if ($wmi.Enabled -ne $true) {
        $wmi.SetEnable($true)
        Write-Host "TCP/IP protocol enabled for instance $instanceName"
    } else {
        Write-Host "TCP/IP protocol already enabled."
    }
    $tcpProps = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement16" -Class "ServerNetworkProtocolProperty" |
                Where-Object { $_.InstanceName -eq $instanceName -and $_.PropertyName -eq "TcpPort" }
    foreach ($prop in $tcpProps) { $prop.SetStringValue("1433") }
    Write-Host "TCP port set to 1433 for instance $instanceName"
} else {
    Write-Warning "Geen SQL Server instance gevonden in WMI! Is SQL Server correct geinstalleerd?"
}

Write-Host "Configureer firewall"
New-NetFirewallRule -DisplayName "SQL Server TCP 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
netsh advfirewall firewall add rule name="SQL Browser UDP 1434" dir=in action=allow protocol=UDP localport=1434
Write-Host "Configureer firewall voltooid"

Write-Host "Installeer SQL server voltooid"

Restart-Service -Name "MSSQLSERVER" -Force
