# Setup Server2

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# Server2 - Static IP 192.168.25.20
$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}


if ($adapter) {
Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.20" -PrefixLength 24 -DefaultGateway "192.168.25.1"
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"

    
    Write-Host "Server2 configured: Static IP 192.168.25.20"
}

Start-Sleep -Seconds 20

$DomainName = "WS2-25-martijn.hogent"
$pw = ConvertTo-SecureString "vagrant" -AsPlainText -Force
Add-Computer -DomainName $DomainName -Credential (New-Object System.Management.Automation.PSCredential("WS2-25-martijn.hogent\Administrator",$pw))
Restart-Computer -Force