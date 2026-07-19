Write-Host "Verander het toetsenbord naar azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE
Write-Host "Verander het toetsenbord naar azerty voltooid"

Write-Host "Configureer netwerkadapter" 
$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}

New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.20" -PrefixLength 24 -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"
Write-Host "Configureer netwerkadapter voltooid" 

Write-Host "Kopieer gedeelde map naar lokale pad"
$LOCALPATH = "C:\Users\Public\shared_folder"

New-Item -Path $LOCALPATH -ItemType Directory -Force
Copy-Item -Path "C:\vagrant\*" -Destination $LOCALPATH -Recurse -Force
Write-Host "Kopieer gedeelde map naar lokale pad voltooid"

Write-Host "Instaleer Windows features"
Install-WindowsFeature -Name DNS -IncludeManagementTools
Write-Host "Instaleer Windows features voltooid"

# Configure firewall
Write-Host "Configureer firewall"
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True
New-NetFirewallRule -DisplayName "Allow SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
New-NetFirewallRule -DisplayName "Allow SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
New-NetFirewallRule -DisplayName "Allow SQL Browser" -Direction Inbound -Protocol UDP -LocalPort 1434 -Action Allow
Write-Host "Configureer firewall voltooid"

Write-Host "Join domain WS2-25-martijn.hogent"
$Domain = "WS2-25-martijn.hogent"
$AdminUser = "WS2-25-martijn\admin1"
$Password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($AdminUser, $Password)

Add-Computer -DomainName $Domain -Credential $Credential -Restart -Force
