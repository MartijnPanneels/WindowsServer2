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

Add-ADGroupMember -Identity "Domain Admins" -Members "vagrant"

New-ADUser -Name "admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=Admin_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
Add-ADGroupMember -Identity "Domain Admins" -Members "admin2"
# Domain Users
New-ADUser -Name "user1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "user2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true


# --- DNS Configuration ---
Add-DnsServerResourceRecordA -Name "server1" -ZoneName $DomainName -IPv4Address "192.168.25.10" -CreatePtr -ErrorAction SilentlyContinue

Write-Host "DNS record1 "

Add-DnsServerResourceRecordA -Name "server2" -ZoneName $DomainName -IPv4Address "192.168.25.20" -CreatePtr -ErrorAction SilentlyContinue

Write-Host "DNS record2 "

# Set-DnsServerPrimaryZone -Name $DomainName -ZoneFile "$DomainName.dns" -SecondaryServers @("192.168.25.20") -SecureSecondaries TransferAnyServer
Write-Host "DNS "

# --- DHCP Configuration ---
Start-Service DHCPServer
Set-Service DHCPServer -StartupType Automatic

$DomainName = "WS2-25-martijn.hogent"
$scopeNetwork = "192.168.25.0"

Get-DhcpServerv4Scope -ErrorAction SilentlyContinue | Remove-DhcpServerv4Scope -Confirm:$false

Add-DhcpServerv4Scope -Name "WS2-25 Scope" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active


Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -DnsServer @("192.168.25.10", "192.168.25.20")
Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -DnsDomain $DomainName
Set-DhcpServerv4OptionValue -ScopeId $scopeNetwork -Router "192.168.25.1"

Add-DhcpServerv4ExclusionRange -ScopeId $scopeNetwork -StartRange 192.168.25.101 -EndRange 192.168.25.150

Set-DhcpServerv4Binding -BindingState $true -InterfaceAlias "Ethernet 2"

$passwordadmin = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
$credadmin = New-Object System.Management.Automation.PSCredential("WS2-25-martijn\admin1", $passwordadmin)

Invoke-Command -ComputerName "server1.WS2-25-martijn.hogent" -Credential $credadmin -ScriptBlock {
    Add-DhcpServerInDC -DnsName "server1.WS2-25-martijn.hogent" -IPAddress 192.168.25.10
}

Write-Host "DHCP Server configured successfully!"
