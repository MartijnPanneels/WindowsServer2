# Readme - Panneels Martijn 3B2

## Deployment Guide

### Server 1

1. Start Server1: `vagrant up server1`.
2. Voer op de VM `C:\vagrant\Server1\setupS1.ps1` uit.
3. Na dit script is er een reboot vereist. Log na het uitvoeren van het eerste script in met de administrator: `ssh administrator@192.168.25.10` het wachtwoord is `vagrant`
<!-- 4. Nakijken of dit ook lukt met admin1 -> Student2025! (nog aan te passen) -->
4. Ga in de powershell env: `powershell`
5. Navigeer naar `C:\vagrant\Server1\setupS1-p2.ps1` en voer dit script uit.

Om te controleren of de server goed is ingesteld kunnen volgende commandos worden gebruikt:

- IP-configuratie validatie: `Get-NetIPAddress -AddressFamily IPv4 | Where-Object IPAddress -like "192.168.25.*" | Format-Table InterfaceAlias, IPAddress, PrefixLength`
- Domein status: `Get-ADDomain | Select-Object Name, DomainMode, ForestMode`
- Controleer of server1 geregistreerd staat als Domain Controller: `Get-ADDomainController -Filter * | Format-Table Name, Domain, IPv4Address`
- Toon de zelfgemaakte OU's: `Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName`
- Toon alle ingeschakelde gebruikers: `Get-ADUser -Filter {Enabled -eq $true} | Select-Object Name, SamAccountName, UserPrincipalName`
- Bevestig welke gebruikers Domain Admin rechten hebben: `Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, ObjectClass`
- Controleer de actieve IPv4 scope: `Get-DhcpServerv4Scope | Format-Table ScopeId, Name, StartRange, EndRange, State`
- Controleer de uitsluitingen voor deze scope: `Get-DhcpServerv4ExclusionRange -ScopeId "192.168.25.0" | Format-Table StartRange, EndRange`
- Controleer het A-record in de forward lookup zone: `Get-DnsServerResourceRecord -ZoneName "WS2-25-martijn.hogent" -Name "server1" | Format-Table HostName, RecordType, RecordData`
- Test de Reverse Lookup: `Resolve-DnsName -Name 192.168.25.10 | Format-Table Name, Type, NameHost`
- Controleer de Forward Lookup Zone: `Get-DnsServerZone -Name "WS2-25-martijn.hogent" | Format-List ZoneName, SecureSecondaries, SecondaryServers`
- Controleer de Reverse Lookup Zone: `Get-DnsServerZone -Name "25.168.192.in-addr.arpa" | Format-List ZoneName, SecureSecondaries, SecondaryServers`
- Status van de certificaatservice: `Get-Service certsvc | Format-Table Status, Name, DisplayName`

### Server 2

1. Start Server1: `vagrant up server2`.
2. Voer op de VM `C:\vagrant\Server2\setupS2.ps1` uit.
3. Na dit script is er een reboot vereist. Log na het uitvoeren van het eerste script in met de administrator: `ssh admin1@192.168.25.20` het wachtwoord is `Student2025!`
4. Ga in de powershell env: `powershell`
5. Voer op de VM `C:\vagrant\Server2\setupS2-p2.ps1` uit.
6. Controlleer of SQLServer runt: `Get-Service -Name "MSSQLSERVER"`

### Client

WS2-25-martijn\admin1
