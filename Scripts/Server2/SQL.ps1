# In dit script wordt SQL Server geïnstalleerd, geconfigureerd om TCP-poort 1433 te gebruiken
# en worden de benodigde firewallregels toegevoegd.

$SetupPath = "D:\\setup.exe"
$odbcPath = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\"

Write-Host "Install SQL Server "
Start-Process -FilePath $SetupPath -ArgumentList "/IACCEPTSQLSERVERLICENSETERMS" -Wait

[Environment]::GetEnvironmentVariable("Path", "Machine")
[Environment]::SetEnvironmentVariable("Path", "$currentPath;$odbcPath", "Machine")

Import-Module SqlServer



$wmi = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement15" -Class "ServerNetworkProtocol" |
       Where-Object { $_.InstanceName -eq "server2" -and $_.ProtocolName -eq "Tcp" }
$wmi.SetEnable($true)

$tcpProps = Get-WmiObject -Namespace "root\Microsoft\SqlServer\ComputerManagement15" -Class "ServerNetworkProtocolProperty" |
            Where-Object { $_.InstanceName -eq "server2" -and $_.PropertyName -eq "TcpPort" }
foreach ($prop in $tcpProps) { $prop.SetStringValue("1433") }
Write-Host "TCP port set to 1433 for instance server2"

New-NetFirewallRule -DisplayName "SQL Server TCP 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
netsh advfirewall firewall add rule name="SQL Browser UDP 1434" dir=in action=allow protocol=UDP localport=1434

Restart-Computer -Force