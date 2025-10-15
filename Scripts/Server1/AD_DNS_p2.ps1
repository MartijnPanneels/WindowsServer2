
# Create OU Structure
New-ADOrganizationalUnit -Name "Admin_Accounts" -Path "DC=WS2-25-martijn,DC=hogent" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "User_Accounts" -Path "DC=WS2-25-martijn,DC=hogent" -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "Servers" -Path "DC=WS2-25-martijn,DC=hogent" -ProtectedFromAccidentalDeletion $false

# Create Users
# Domain Admins
New-ADUser -Name "admin1" -GivenName "Admin" -Surname "One" -SamAccountName "admin1" -UserPrincipalName "admin1@$DomainName" -Path "OU=Admin_Accounts,DC=WS2-25-martijn,DC=hogent" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "admin1"

New-ADUser -Name "admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=Admin_Accounts,DC=WS2-25-martijn,DC=hogent" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "admin2"

# Domain Users
New-ADUser -Name "user1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=User_Accounts,DC=WS2-25-martijn,DC=hogent" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "user2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=User_Accounts,DC=WS2-25-martijn,DC=hogent" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true

# DNS Configuration
# Forward Lookup Zone
Add-DnsServerPrimaryZone -Name "$DomainName" -ReplicationScope "Domain"

# Reverse Lookup Zone
Add-DnsServerPrimaryZone -NetworkID "192.168.25.0/24" -ReplicationScope "Domain"

# Create A and PTR records for Server1
Add-DnsServerResourceRecordA -Name "server1" -ZoneName "$DomainName" -IPv4Address "192.168.25.10" -CreatePtr
Add-DnsServerResourceRecordA -Name "server2" -ZoneName "$DomainName" -IPv4Address "192.168.25.20" -CreatePtr

# Configure Zone Transfers
Set-DnsServerPrimaryZone -Name "$DomainName" -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20"
Set-DnsServerPrimaryZone -Name "25.168.192.in-addr.arpa" -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20"

# Update DHCP to point to correct DNS
Set-DhcpServerv4OptionValue -DnsServer "192.168.25.10" -Router "192.168.25.1"

Write-Host "AD Domain and DNS configuration completed"