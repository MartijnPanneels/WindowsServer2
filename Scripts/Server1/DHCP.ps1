# Configure DHCP after reboot
Start-Service DHCPServer
Set-Service DHCPServer -StartupType Automatic

$DomainName = "WS2-25-martijn.hogent"
$scopeNetwork = "192.168.25.0"

Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Remove-DhcpServerv4Scope -Confirm:$false

Add-DhcpServerv4Scope -Name "WS2-25 Scope" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active


Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -DnsServer "192.168.25.10"
Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -DnsDomain $DomainName
Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -Router "192.168.25.1"

Add-DhcpServerv4ExclusionRange -ScopeId $scopeNetwork -StartRange 192.168.25.101 -EndRange 192.168.25.150

Set-DhcpServerv4Binding -BindingState $true -InterfaceAlias "Ethernet 2"

Write-Host "DHCP Server configured successfully!" -ForegroundColor Green