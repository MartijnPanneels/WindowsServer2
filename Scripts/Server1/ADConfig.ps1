Write-Host "Waiting for AD services to be fully ready..."
$DomainName = "WS2-25-martijn.hogent"
$DomainDN = "DC=WS2-25-martijn,DC=hogent"  

# ----- AD Configuration -----

Write-Host "Importing AD Module..."
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

Write-Host "Creating OU Structure"

# Create OU Structure
New-ADOrganizationalUnit -Name "Admin_Accounts" -Path $DomainDN -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name "User_Accounts" -Path $DomainDN -ProtectedFromAccidentalDeletion $false
# Create Users - Domain Admins
New-ADUser -Name "admin1" -GivenName "Admin" -Surname "One" -SamAccountName "admin1" -UserPrincipalName "admin1@$DomainName" -Path "OU=Admin_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "admin1"

New-ADUser -Name "admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=Admin_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "admin2"
# Domain Users
New-ADUser -Name "user1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "user2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true


# --- DNS Configuration ---
Add-DnsServerResourceRecordA -Name "server1" -ZoneName $DomainName -IPv4Address "192.168.25.10" -CreatePtr -ErrorAction SilentlyContinue

Write-Host "DNS "

Add-DnsServerResourceRecordA -Name "server2" -ZoneName $DomainName -IPv4Address "192.168.25.20" -CreatePtr -ErrorAction SilentlyContinue

Write-Host "DNS "

Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries "TransferToSecureServers" -SecondaryServers "192.168.25.20"
Write-Host "DNS "



