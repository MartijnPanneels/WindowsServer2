Write-Host "Valideer Client"

Write-Host "IP-configuratie:"
Get-NetAdapter | Where-Object Status -eq "Up" | Get-NetIPConfiguration | Where-Object { $_.IPv4Address.IPAddress -like "192.168.25.*" } | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway

Write-Host "Computer en Domein status:"
Get-CimInstance Win32_ComputerSystem | Select-Object Name, Domain

Write-Host "Geïnstalleerde RSAT Tools:"
Get-WindowsCapability -Online -Name "Rsat*" | Where-Object State -eq "Installed" | Format-Table Name

Write-Host "SSMS (SQL Server Management Studio) Installatie:"
Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object DisplayName -match "SQL Server Management Studio" | Format-Table DisplayName, DisplayVersion

Write-Host "Certificaat (Root CA van het domein aanwezig):"
Get-ChildItem -Path Cert:\LocalMachine\Root | Where-Object { $_.Subject -match "martijn" } | Format-Table Subject, Thumbprint

Write-Host "Valideer Client voltooid"