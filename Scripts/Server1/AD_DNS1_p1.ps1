# Active Directory and DNS Configuration for Server1
$DomainName = "WS2-25-martijn.hogent"  
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

# Install AD Domain Services and DNS
Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools

# Promote to Domain Controller
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName "WS225MARTIJN" ` 
    -ForestMode "Windows2025Forest" `
    -DomainMode "Windows2025Domain" `
    -SafeModeAdministratorPassword $SafeModePassword `
    -Force

# After reboot, continue with OU and DNS configuration
