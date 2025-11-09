# Setup Client

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

Write-Host "Installing RSAT tools..."
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.Dns.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.DHCP.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.CertificateServices.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue

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
    
    Set-DnsClient -InterfaceAlias $adapter.Name -RegisterThisConnectionsAddress $false
     
    Write-Host "Client configured for DHCP"
}


$pw = ConvertTo-SecureString "vagrant" -AsPlainText -Force

Write-Host "Joining the domain"
Add-Computer -DomainName "WS2-25-martijn.hogent" -Credential (New-Object System.Management.Automation.PSCredential("WS2-25-martijn\Administrator",$pw))
Write-Host "restarting"
Restart-Computer -Force