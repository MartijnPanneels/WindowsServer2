# Setup Client

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE


# Instaleren RSAT tools

 Add-WindowsCapability -Online -Name     "RSAT:ActiveDirectory"
 Add-WindowsCapability -Online -Name     "RSAT:DNS-Server"
 Add-WindowsCapability -Online -Name     "RSAT:DHCP"
 Add-WindowsCapability -Online -Name     "RSAT:CertificateServicesTools"



$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}


if ($adapter) {
    # Remove any existing IP configuration first
    Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue

    # Set to obtain IP automatically via DHCP
    Set-NetIPInterface -InterfaceAlias $adapter.Name -Dhcp Enabled
    
    # Set DNS to obtain automatically (or set to server1 if needed)
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
    
    Write-Host "Client configured for DHCP"
}


$pw = ConvertTo-SecureString "vagrant" -AsPlainText -Force
Add-Computer -DomainName "WS2-25-martijn.hogent" -Credential (New-Object System.Management.Automation.PSCredential("WS2-25-martijn\Administrator",$pw))
Restart-Computer -Force