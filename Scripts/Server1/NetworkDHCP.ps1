# Setup Server1 - Verbeterde Versie

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# --- Network Configuration ---
Write-Host "Configuring network..."
$adapters = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Sort-Object InterfaceIndex
$hostOnlyAdapter = $adapters[1]  # Tweede adapter is meestal host-only

if ($hostOnlyAdapter) {
    # Remove existing IP configuration
    Remove-NetIPAddress -InterfaceAlias $hostOnlyAdapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $hostOnlyAdapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    
    # Set static IP
    New-NetIPAddress -InterfaceAlias $hostOnlyAdapter.Name -IPAddress "192.168.25.10" -PrefixLength 24
    Set-DnsClientServerAddress -InterfaceAlias $hostOnlyAdapter.Name -ServerAddresses "192.168.25.10"
    
    Write-Host "Network configured: Static IP 192.168.25.10"
}

# --- DHCP Configuration ---
Write-Host "Configuring DHCP..."
$scopeId = "192.168.25.0"

# Install DHCP role
if (-not (Get-WindowsFeature -Name DHCP).Installed) {
    Write-Host "Installing DHCP feature..."
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
}

# Start DHCP service
Start-Service dhcpserver -ErrorAction SilentlyContinue
Set-Service dhcpserver -StartupType Automatic

# Create DHCP scope if it doesn't exist
if (-not (Get-DhcpServerv4Scope -ScopeId $scopeId -ErrorAction SilentlyContinue)) {
    Write-Host "Creating DHCP scope..."
    Add-DhcpServerv4Scope -Name "HostOnlyNetwork" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active
    
    # Authorize DHCP server in AD 
    Add-DhcpServerInDC -DnsName "server1.WS2-25-martijn.hogent"
    
    # Set DHCP options
    Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsServer "192.168.25.10","192.168.25.20"
    Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsDomain "WS2-25-martijn.hogent"
    Set-DhcpServerv4OptionValue -ScopeId $scopeId -Router "192.168.25.1"
    
    # Exclude IP range
    Add-DhcpServerv4ExclusionRange -ScopeId $scopeId -StartRange 192.168.25.101 -EndRange 192.168.25.150
    
    Write-Host "DHCP scope configured successfully"
}

Restart-Service dhcpserver
Write-Host "DHCP Server configured"

# --- Domain Controller Promotion ---
Write-Host "Checking Domain Controller status..."
$domainName = "WS2-25-martijn.hogent"

if (-not (Get-ADDomain -Identity $domainName -ErrorAction SilentlyContinue)) {
    Write-Host "Promoting to Domain Controller..."
    
    # Install AD Domain Services
    if (-not (Get-WindowsFeature -Name AD-Domain-Services).Installed) {
        Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    }
    
    # Promote to Domain Controller
    $SafeModePassword = ConvertTo-SecureString "letmein" -AsPlainText -Force
    
    Install-ADDSForest `
        -CreateDnsDelegation:$false `
        -DatabasePath "C:\Windows\NTDS" `
        -DomainMode "Win2025" `
        -DomainName $domainName `
        -DomainNetbiosName "WS225MARTIJN" `
        -ForestMode "Win2025" `
        -InstallDns:$true `
        -SafeModeAdministratorPassword $SafeModePassword `
        -Force
    # Script reboot hier
} else {
    Write-Host "Server is already a Domain Controller for $domainName"
}