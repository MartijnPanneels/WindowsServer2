Write-Host "Valideer Server1"

Write-Host "IP-configuratie:"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -like "192.168.25.*" | Format-Table InterfaceAlias, IPAddress, PrefixLength

Write-Host "Domein status:"
Get-ADDomain | Select-Object Name, DomainMode, ForestMode

Write-Host "Domain Controller registratie:"
Get-ADDomainController -Filter * | Format-Table Name, Domain, IPv4Address

Write-Host "Zelfgemaakte OU's:"
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

Write-Host "Ingeschakelde gebruikers:"
Get-ADUser -Filter {Enabled -eq $true} | Select-Object Name, SamAccountName, UserPrincipalName

Write-Host "Domain Admin rechten:"
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, ObjectClass

Write-Host "Actieve IPv4 DHCP scope:"
Get-DhcpServerv4Scope | Format-Table ScopeId, Name, StartRange, EndRange, State

Write-Host "DHCP scope uitsluitingen:"
Get-DhcpServerv4ExclusionRange -ScopeId "192.168.25.0" | Format-Table StartRange, EndRange

Write-Host "A-record (server1):"
Get-DnsServerResourceRecord -ZoneName "WS2-25-martijn.hogent" -Name "server1" | Format-Table HostName, RecordType, RecordData

Write-Host "Reverse Lookup test (192.168.25.10):"
Resolve-DnsName -Name 192.168.25.10 | Format-Table Name, Type, NameHost

Write-Host "Forward Lookup Zone:"
Get-DnsServerZone -Name "WS2-25-martijn.hogent" | Format-List ZoneName, SecureSecondaries, SecondaryServers

Write-Host "Reverse Lookup Zone:"
Get-DnsServerZone -Name "25.168.192.in-addr.arpa" | Format-List ZoneName, SecureSecondaries, SecondaryServers

Write-Host "Status certificaatservice:"
Get-Service certsvc | Format-Table Status, Name, DisplayName

Write-Host "Valideer Server1 voltooid"