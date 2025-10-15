# Setup Server2

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# Server2 - Static IP 192.168.25.20
$adapter = Get-NetAdapter -Name "Ethernet 2"

if ($adapter) {
    # Remove any existing IP configuration
    Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    
    # Set static IP with default gateway
    New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.20" -PrefixLength 24 -DefaultGateway "192.168.25.1"
    
    # Set DNS to server1 (future DNS server)
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"
    
    Write-Host "Server2 configured: Static IP 192.168.25.20"
}