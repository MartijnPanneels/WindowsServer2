# Domain variabelen
$Domain = "DC=WS2-25-martijn,DC=hogent"
$DomainName = "WS2-25-martijn.hogent"

Write-Host "Configureer DHCP server"
$ScopeID = "192.168.25.0"
$StartIP = "192.168.25.50"
$EndIP = "192.168.25.150"
$SubnetMask = "255.255.255.0"
$ScopeName = "HostOnly-Scope"

Add-DhcpServerv4Scope -Name $ScopeName -StartRange $StartIP -EndRange $EndIP -SubnetMask $SubnetMask -State Active -ErrorAction SilentlyContinue
Add-DhcpServerv4ExclusionRange -ScopeId $ScopeID -StartRange "192.168.25.101" -EndRange "192.168.25.150" -ErrorAction SilentlyContinue
Set-DhcpServerv4OptionValue -ScopeId $ScopeID -DnsServer "192.168.25.10" -Router "192.168.25.1" -DnsDomain $DomainName
Add-DhcpServerInDC -DnsName "server1.$DomainName" -IPAddress "192.168.25.10" -ErrorAction SilentlyContinue
Write-Host "Configureer DHCP server voltooid"


Write-Host "Maak OU Structure & Users"
New-ADOrganizationalUnit -Name "IT" -Path $Domain -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "HR" -Path $Domain -ErrorAction SilentlyContinue
New-ADOrganizationalUnit -Name "Management" -Path $Domain -ErrorAction SilentlyContinue

$SecurePass = ConvertTo-SecureString "Password123!" -AsPlainText -Force
New-ADUser -Name "Admin1" -GivenName "Admin" -Surname "One" -SamAccountName "admin1" -UserPrincipalName "admin1@$DomainName" -Path "OU=IT,$Domain" -AccountPassword $SecurePass -Enabled $true -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "Domain Admins" -Members "admin1" -ErrorAction SilentlyContinue

New-ADUser -Name "Admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=IT,$Domain" -AccountPassword $SecurePass -Enabled $true -ErrorAction SilentlyContinue
Add-ADGroupMember -Identity "Domain Admins" -Members "admin2" -ErrorAction SilentlyContinue

New-ADUser -Name "User1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=HR,$Domain" -AccountPassword $SecurePass -Enabled $true -ErrorAction SilentlyContinue

New-ADUser -Name "User2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=HR,$Domain" -AccountPassword $SecurePass -Enabled $true -ErrorAction SilentlyContinue

Write-Host "Maak OU Structure & Users voltooid"


Write-Host "Configureer DNS Reverse Lookup Zone"
$NetworkId = "192.168.25.0/24"
$ZoneName = "25.168.192.in-addr.arpa"

Add-DnsServerPrimaryZone -NetworkId $NetworkId -ReplicationScope "Domain" -ErrorAction SilentlyContinue
Add-DnsServerResourceRecordPtr -ZoneName $ZoneName -Name "10" -PtrDomainName "server1.$DomainName" -AllowUpdateAny -ErrorAction SilentlyContinue
Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries TransferToSecureServers -SecondaryServers "192.168.25.20" -ErrorAction SilentlyContinue
Set-DnsServerPrimaryZone -Name $ZoneName -SecureSecondaries TransferToSecureServers -SecondaryServers "192.168.25.20" -ErrorAction SilentlyContinue
Write-Host "Configureer DNS Reverse Lookup Zone voltooid"


Write-Host "Installeer CA & Web Enrollment"
Install-WindowsFeature AD-Certificate, ADCS-Web-Enrollment -IncludeManagementTools
Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CACommonName "WS2-25-martijn-CA" -KeyLength 2048 -HashAlgorithmName SHA256 -CryptoProviderName "RSA#Microsoft Software Key Storage Provider" -Force
Install-AdcsWebEnrollment -Force
Restart-Service certsvc

Write-Host "Configureer IIS om HTTP toe te staan voor Web Enrollment"
Import-Module WebAdministration
Set-WebConfigurationProperty -Filter 'system.webServer/security/access' -Location 'Default Web Site/CertSrv' -Name sslFlags -Value None
iisreset
Write-Host "Installeer CA & Web Enrollment voltooid"
