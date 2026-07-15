# Setup Server2
# Voor gebruiksgemak zet ik het toetsenbord op azerty
Write-Host "azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE


$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}

# statisch ip instellen
if ($adapter) {
Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.20" -PrefixLength 24 -DefaultGateway "192.168.25.1"
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"}

Start-Sleep -Seconds 20

# toevoegen aan het domein
$DomainName = "WS2-25-martijn.hogent"
$pw = ConvertTo-SecureString "vagrant" -AsPlainText -Force
Add-Computer -DomainName $DomainName -Credential (New-Object System.Management.Automation.PSCredential("WS2-25-martijn.hogent\Administrator",$pw))

Install-WindowsFeature -Name DNS -IncludeManagementTools

Import-Module DnsServer

Restart-Computer -Force