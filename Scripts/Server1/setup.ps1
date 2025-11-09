# Setup Server1 - Script 1 (NetworkDHCP.ps1)

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# --- Network Configuration ---
Write-Host "Configuring network."

$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}

# Remove existing IP configuration
Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
Write-Host "Deleted ip"
    
# Set static IP
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.10" -PrefixLength 24 -DefaultGateway "192.168.25.1"
Write-Host "IP done"
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses @("192.168.25.10", "192.168.25.20")
Write-Host "Dns done"
Write-Host "Network configured: Static IP 192.168.25.10"

Restart-Computer -Force