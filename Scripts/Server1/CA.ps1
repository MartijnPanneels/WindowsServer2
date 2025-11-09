Write-Host "setup CA" 
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools

Install-AdcsCertificationAuthority -CAType EnterpriseRootCA