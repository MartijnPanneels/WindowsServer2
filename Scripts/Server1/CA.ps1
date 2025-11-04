Write-Host "setup CA" 

Write-Host "Installing" 
Install-WindowsFeature -Name ADCS-Cert-Authority -IncludeManagementTools
Install-AdcsWebEnrollment -Force
Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -Force
Import-Module ADCSAdministration


$GpoName = "Enable Auto Certificate Enrollment"
New-GPO -Name $GpoName
$Gpo = Get-GPO -Name $GpoName
Set-GPRegistryValue -Name $Gpo.DisplayName -Key "HKLM\Software\Policies\Microsoft\Cryptography\AutoEnrollment" -ValueName "AEPolicy" -Type DWord -Value 7
$DomainDN = (Get-ADDomain).DistinguishedName
New-GPLink -Name $GpoName -Target $DomainDN


Write-Host "Web Enrollment" 

Restart-Service w3svc




