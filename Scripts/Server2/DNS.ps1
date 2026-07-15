# De zonefiles instellen

Add-DnsServerSecondaryZone -Name "25.168.192.in-addr.arpa" -MasterServers "192.168.25.10" -ZoneFile "25.168.192.in-addr.arpa.dns"

Add-DnsServerSecondaryZone -Name "WS2-25-martijn.hogent" -MasterServers "192.168.25.10" -ZoneFile "WS2-25-martijn.hogent.dns" 

Start-Service DNS

