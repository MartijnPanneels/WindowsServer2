$DomainName = "WS2-25-martijn.hogent"

Write-Host "Configuring Server2 as secondary DNS server..."

Install-WindowsFeature -Name DNS -IncludeManagementTools

Import-Module DnsServer
Add-DnsServerSecondaryZone -Name $DomainName -MasterServers "192.168.25.10" -ZoneFile "$DomainName.dns"

Start-Service DNS

Write-Host "Server2 is now secondary DNS server for $DomainName"