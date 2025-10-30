# Setup Server1 - Script 1 (NetworkDHCP.ps1)

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# --- Network Configuration ---
Write-Host "Configuring network."


# Remove existing IP configuration
Remove-NetIPAddress -InterfaceAlias "Ethernet 2" -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias "Ethernet 2" -Confirm:$false -ErrorAction SilentlyContinue
    
# Set static IP
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress "192.168.25.10" -PrefixLength 24 -DefaultGateway "192.168.25.1"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses "192.168.25.10"
Write-Host "Network configured: Static IP 192.168.25.10"


# --- Domain Controller Promotion ---

Write-Host "Installing AD-Domain-Services feature"
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$domainName = "WS2-25-martijn.hogent"

Write-Host "Promoting to Domain Controller..."
Import-Module ADDSDeployment

$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force


Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $securePassword -InstallDns -Force:$true

