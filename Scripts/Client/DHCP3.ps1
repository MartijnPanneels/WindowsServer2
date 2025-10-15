# Setup Client

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# Setup Client - Configure as DHCP client
$adapter = Get-NetAdapter -Name "Ethernet 2"

if ($adapter) {
    # Set to obtain IP automatically via DHCP
    Set-NetIPInterface -InterfaceAlias $adapter.Name -Dhcp Enabled
    
    # Set DNS to obtain automatically (or set to server1 if needed)
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
    
    Write-Host "Client configured for DHCP"
}


