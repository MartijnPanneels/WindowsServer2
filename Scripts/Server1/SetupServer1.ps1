# Setup Server1

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE


# Set static IP for server1 (remove existing default gateway first)
Remove-NetRoute -InterfaceAlias "Ethernet 2" -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias "Ethernet 2" -IPAddress "192.168.25.10" -PrefixLength 24 -DefaultGateway "192.168.25.1" -ErrorAction SilentlyContinue

# Set DNS to itself
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses "192.168.25.10"

# Install DHCP role
Install-WindowsFeature -Name DHCP -IncludeManagementTools

# Add DHCP authorization
Add-DhcpServerInDC

# Create DHCP scope
Add-DhcpServerv4Scope -Name "HostOnlyNetwork" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active

# Set scope options
Set-DhcpServerv4OptionValue -ScopeId 192.168.25.0 -DnsServer 192.168.25.10 -Router 192.168.25.1

# Exclude upper IP range (101-150)
Add-DhcpServerv4ExclusionRange -ScopeId 192.168.25.0 -StartRange 192.168.25.101 -EndRange 192.168.25.150