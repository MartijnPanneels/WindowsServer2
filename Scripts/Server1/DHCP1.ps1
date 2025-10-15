# Setup Server1

# --- Keyboard layout (Belgian AZERTY) ---
Write-Host "Setting keyboard layout to Belgian (AZERTY)..."
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# Server1 - Static IP 192.168.25.10 + DHCP Server
$adapter = Get-NetAdapter -Name "Ethernet 2"

if ($adapter) {
    # Remove any existing IP configuration first
    Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    
    # Set static IP
    New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.10" -PrefixLength 24 -DefaultGateway "192.168.25.1"
    
    # Set DNS to itself
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"
    
    # Install DHCP role
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    
    # Configure DHCP server
    Start-Service dhcpserver
    Set-Service dhcpserver -StartupType Automatic
    
    # Create DHCP scope
    Add-DhcpServerv4Scope -Name "HostOnlyNetwork" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active
    
    # Set DHCP options (Router = 192.168.25.1)
    Set-DhcpServerv4OptionValue -Router 192.168.25.1
    
    # Exclude IP range 101-150
    Add-DhcpServerv4ExclusionRange -ScopeId 192.168.25.0 -StartRange 192.168.25.101 -EndRange 192.168.25.150
    
    Restart-Service dhcpserver
    Write-Host "Server1 configured: Static IP 192.168.25.10 + DHCP Server"
}