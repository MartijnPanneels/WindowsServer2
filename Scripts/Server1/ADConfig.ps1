Write-Host "Waiting for AD services to be fully ready..."

$maxAttempts = 30
$attempt = 0
$DomainName = "WS2-25-martijn.hogent"
$DomainDN = "DC=WS2-25-martijn,DC=hogent"  # Correct DN format

do {
    $attempt++
    Write-Host "Checking AD readiness... Attempt $attempt/$maxAttempts"
    
    try {
        # Test of AD volledig operationeel is
        $domain = Get-ADDomain -ErrorAction Stop
        $dns = Get-DnsServerZone -Name $DomainName -ErrorAction SilentlyContinue
        
        if ($domain -and $dns) {
            Write-Host "AD and DNS are fully operational!"
            break
        }
    }
    catch {
        Write-Host "Services not ready yet, waiting 10 seconds..."
        Start-Sleep 10
    }
} while ($attempt -lt $maxAttempts)

if ($attempt -eq $maxAttempts) {
    Write-Host "Continuing configuration anyway..."
}

# ----- AD Configuration -----

try {
    Write-Host "Creating OU Structure..."
    
    # Create OU Structure
    New-ADOrganizationalUnit -Name "Admin_Accounts" -Path $DomainDN -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name "User_Accounts" -Path $DomainDN -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name "Servers" -Path $DomainDN -ProtectedFromAccidentalDeletion $false

    Write-Host "Creating Users..."
    
    # Create Users - Domain Admins
    New-ADUser -Name "admin1" -GivenName "Admin" -Surname "One" -SamAccountName "admin1" -UserPrincipalName "admin1@$DomainName" -Path "OU=Admin_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
    Add-ADGroupMember -Identity "Domain Admins" -Members "admin1"
    
    New-ADUser -Name "admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=Admin_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
    Add-ADGroupMember -Identity "Domain Admins" -Members "admin2"

    # Domain Users
    New-ADUser -Name "user1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true
    New-ADUser -Name "user2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=User_Accounts,$DomainDN" -AccountPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) -Enabled $true

    Write-Host "Configuring DNS..."
    
    # DNS Configuration - Zones bestaan waarschijnlijk al door AD installatie
    # Alleen records toevoegen als ze nog niet bestaan
    
    # Create A and PTR records for Server1 (als ze nog niet bestaan)
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
    Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20"
    Set-DnsServerPrimaryZone -Name "25.168.192.in-addr.arpa" -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20"

    # Update DHCP DNS settings
    Set-DhcpServerv4OptionValue -DnsServer "192.168.25.10", "192.168.25.20" -DnsDomain $DomainName

    Write-Host "AD Domain and DNS configuration completed successfully!"

} catch {
    Write-Host "Error during AD configuration: $_" -ForegroundColor Red
    exit 1
}