Write-Host "Valideer Server2"

Write-Host "IP-configuratie:"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -like "192.168.25.*" | Format-Table InterfaceAlias, IPAddress, PrefixLength

Write-Host "Computer en Domein status:"
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain

Write-Host "Secundaire DNS Forward Zone:"
Get-DnsServerZone -Name "WS2-25-martijn.hogent" -ErrorAction SilentlyContinue | Format-Table ZoneName, ZoneType

Write-Host "Secundaire DNS Reverse Zone:"
Get-DnsServerZone -Name "25.168.192.in-addr.arpa" -ErrorAction SilentlyContinue | Format-Table ZoneName, ZoneType

Write-Host "Status SQL Server Service:"
Get-Service -Name "MSSQLSERVER" -ErrorAction SilentlyContinue | Format-Table Status, Name, DisplayName

Write-Host "SQL Server Firewall Regels:"
Get-NetFirewallRule | Where-Object { $_.DisplayName -match "SQL" -or $_.DisplayName -match "1433" } | Format-Table DisplayName, Enabled, Action, Direction

Write-Host "Valideer Server2 voltooid"