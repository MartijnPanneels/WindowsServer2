Install-WindowsFeature AD-Domain-Services 
# Domein aanmaken 
write-host "AD configureren en herstarten"
Import-Module ADDSDeployment

$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "Win2025" `
-DomainName "WS2-25-martijn.hogent" `
-DomainNetbiosName "WS225MARTIJN" `
-ForestMode "Win2025" `
-InstallDns:$true `
-SafeModeAdministratorPassword $SafeModePassword `
-Force

Restart-Computer -Force