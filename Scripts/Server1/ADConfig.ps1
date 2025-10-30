Write-Host "Waiting for AD services to be fully ready..."
$DomainName = "WS2-25-martijn.hogent"
$DomainDN = "DC=WS2-25-martijn,DC=hogent"  

# ----- AD Configuration -----

Write-Host "Importing AD Module..."
Import-Module ActiveDirectory -ErrorAction SilentlyContinue

try {
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


    # DNS Configuration - Zones bestaan waarschijnlijk al door AD installatie
    # Alleen records toevoegen als ze nog niet bestaan
    try {
        Add-DnsServerResourceRecordA -Name "server1" -ZoneName $DomainName -IPv4Address "192.168.25.10" -CreatePtr -ErrorAction SilentlyContinue
    } catch {
        Write-Host "server1 A record already exists"
    }
    
    try {
        Add-DnsServerResourceRecordA -Name "server2" -ZoneName $DomainName -IPv4Address "192.168.25.20" -CreatePtr -ErrorAction SilentlyContinue
    } catch {
        Write-Host "server2 A record already exists"
    }

    # Configure Zone Transfers naar server2
    Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries "TransferToSecureServers" -SecondaryServers "192.168.25.20"

} catch {
    Write-Host "Error during AD configuration: $_" -ForegroundColor Red
    exit 1
}

# --- DHCP Configuration ---
Write-Host "Configuring DHCP"
$scopeId = "192.168.25.0"

# Install DHCP role
Write-Host "Installing DHCP feature"
Install-WindowsFeature -Name DHCP -IncludeManagementTools


# Start DHCP service
Start-Service DHCPServer 
Set-Service DHCPServer -StartupType Automatic


Write-Host "Creating DHCP scope"
Add-DhcpServerv4Scope -Name "Hostonlynetwork" -StartRange 192.168.25.50 -EndRange 192.168.25.150 -SubnetMask 255.255.255.0 -State Active


# Authorize DHCP server in AD
$password = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("$domainName\Administrator", $password)
Write-Host "Authorizing DHCP server in AD..."
Add-DhcpServerInDC -DnsName "server1.$domainName" -Credential $credential


# Set DHCP options
Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsServer "192.168.25.10","192.168.25.20"
Set-DhcpServerv4OptionValue -ScopeId $scopeId -DnsDomain "WS2-25-martijn.hogent"
Set-DhcpServerv4OptionValue -ScopeId $scopeId -Router "192.168.25.1"

# Exclude IP range
Add-DhcpServerv4ExclusionRange -ScopeId $scopeId -StartRange 192.168.25.101 -EndRange 192.168.25.150

Write-Host "DHCP scope configured successfully"
# Update DHCP DNS settings
Set-DhcpServerv4OptionValue -DnsServer "192.168.25.10", "192.168.25.20" -DnsDomain $DomainName


Restart-Service dhcpserver
Write-Host "DHCP Server configured"
