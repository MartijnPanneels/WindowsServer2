# Setup Server1

# Server1 - Static IP 192.168.25.10 + DHCP Server
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq 'Up' -and $_.Name -like '*Ethernet*'} | Select-Object -Index 1

if ($adapter) {
    # Remove existing default gateway
    Remove-NetRoute -InterfaceAlias $adapter.Name -DestinationPrefix "0.0.0.0/0" -Confirm:$false -ErrorAction SilentlyContinue
    
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
    
    # Set DHCP options (Router = 192.168.25.1, DNS = 192.168.25.10)
    Set-DhcpServerv4OptionValue -DnsServer 192.168.25.10 -Router 192.168.25.1
    
    # Exclude IP range 101-150
    Add-DhcpServerv4ExclusionRange -ScopeId 192.168.25.0 -StartRange 192.168.25.101 -EndRange 192.168.25.150
    
    Restart-Service dhcpserver
    Write-Host "Server1 configured: Static IP 192.168.25.10 + DHCP Server"
}