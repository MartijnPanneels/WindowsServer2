# Setup Client

# azeerty keyboard layout
Write-Host "azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# installeren rsat-tools
Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.Dns.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.DHCP.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue
Add-WindowsCapability -Online -Name "Rsat.CertificateServices.Tools~~~~0.0.1.0" -ErrorAction SilentlyContinue

$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}

# netwerk instellen op DHCP
if ($adapter) {
    Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
    Set-NetIPInterface -InterfaceAlias $adapter.Name -Dhcp Enabled
    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
    Set-DnsClient -InterfaceAlias $adapter.Name -RegisterThisConnectionsAddress $false
}
# # instaleren ssms
# $ssms= "https://aka.ms/ssmsfullsetup"
# $destination = "$env:USERPROFILE\Downloads\SSMS-Setup.exe"

# Invoke-WebRequest -Uri $ssms -OutFile $destination
# Start-Process -FilePath $destination -ArgumentList "/install /quiet /norestart" -Wait

# toevoegen aan het domain
$pw = ConvertTo-SecureString "vagrant" -AsPlainText -Force
Add-Computer -DomainName "WS2-25-martijn.hogent" -Credential (New-Object System.Management.Automation.PSCredential("WS2-25-martijn\Administrator",$pw))
Restart-Computer -Force