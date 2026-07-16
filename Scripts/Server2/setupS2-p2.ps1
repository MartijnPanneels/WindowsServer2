# ==============================================================================
# Script: setupS2-p2.ps1
# Beschrijving: DNS configureren en MS SQL Server 2022 installeren
# ==============================================================================

# 1. DNS Configuratie
Write-Host "Installing DNS Server Role..."
Install-WindowsFeature DNS -IncludeManagementTools

Write-Host "Configuring Secondary DNS Zones..."
Add-DnsServerSecondaryZone -Name "WS2-25-martijn.hogent" -ZoneFile "WS2-25-martijn.hogent.dns" -MasterServers "192.168.25.10" -ErrorAction SilentlyContinue
Add-DnsServerSecondaryZone -Name "25.168.192.in-addr.arpa" -ZoneFile "25.168.192.in-addr.arpa.dns" -MasterServers "192.168.25.10" -ErrorAction SilentlyContinue

# VARIABELEN
Write-Host "Setting variables..."
$sqlSetupPath = "D:\setup.exe"
$sqlConfigFile = "C:\vagrant\sql\sql_config.ini"
$odbcPath = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\"

# SQL SERVER INSTALLATIE  
Write-Host "Starting SQL Server installation..."
if ((Test-Path $sqlSetupPath) -and (Test-Path $sqlConfigFile)) {
    Write-Host "setup.exe and configuration file found, starting installation..."
    Start-Process -FilePath $sqlSetupPath -ArgumentList "/ConfigurationFile=$sqlConfigFile /IACCEPTSQLSERVERLICENSETERMS" -Wait
    Write-Host "SQL Server installation completed."
} else {
    Write-Error "SQL setup.exe or config file not found. Check paths and try again."
    exit 1
}

# PAD TOEVOEGEN 
Write-Host "Updating system PATH variable..."
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notlike "*$odbcPath*") {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$odbcPath", "Machine")
    Write-Host "PATH updated. Restart required to take effect."
} else {
    Write-Host "PATH already contains ODBC tools."
}

$instanceName = "SERVER2"

try {
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
} catch {
    Write-Warning "Could not configure TCP/IP: $_"
}

if (-not (Get-NetFirewallRule -DisplayName "SQL Server TCP 1433" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName "SQL Server TCP 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
    netsh advfirewall firewall add rule name="SQL Browser UDP 1434" dir=in action=allow protocol=UDP localport=1434

    Write-Host "Firewall rule added to allow  1433"
} else {
    Write-Host "Firewall rule already exists."
}
