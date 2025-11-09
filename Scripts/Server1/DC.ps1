
# --- Domain Controller Promotion ---

Write-Host "Installing AD-Domain-Services feature"
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-WindowsFeature -Name DHCP -IncludeManagementTools

$DomainName = "WS2-25-martijn.hogent"

Write-Host "Promoting to Domain Controller..."
Import-Module ADDSDeployment

$securePassword = ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force

Install-ADDSForest -DomainName $DomainName -SafeModeAdministratorPassword $securePassword -InstallDns -Force:$true

Restart-Computer -Force

Write-Host "Domain Controller done"


