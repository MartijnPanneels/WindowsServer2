Write-Host "setup CA" 


$passwordadmin = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force
$credadmin = New-Object System.Management.Automation.PSCredential("WS2-25-martijn\admin1", $passwordadmin)

Invoke-Command -ComputerName "server1.WS2-25-martijn.hogent" -Credential $credadmin -ScriptBlock {
    Install-WindowsFeature -Name ADCS-Cert-Authority, ad   -IncludeManagementTools

    Install-AdcsCertificationAuthority -CAType EnterpriseRootCA -CACommonName "WS2-CA" -Force

    Install-AdcsWebEnrollment -CAConfig "server1\WS2-CA" -Force
}