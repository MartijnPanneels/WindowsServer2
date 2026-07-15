# Setup Server1
# Voor gebruiksgemak zet ik het toetsenbord op azerty
Write-Host "azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# statisch ip instellen
$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
}

Write-Host "Configuring static IPv4"
# Remove-NetIPAddress -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
# Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
# Remove-NetRoute -InterfaceAlias $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue

New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.10" -PrefixLength 24 
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"

Write-Output "Static IP set to 192.168.25.10 on interface $adapter.Name"

# Copy shared folder locally
Write-Output "Copying shared folder to the local path."

$LOCALPATH = "C:\Users\Public\shared_folder"

if (!(Test-Path $LOCALPATH)) {
    New-Item -Path $LOCALPATH -ItemType Directory -Force
    Write-Output "Local path created at $LOCALPATH."
}
Copy-Item -Path C:\vagrant\* -Destination $LOCALPATH -Recurse -Force
Write-Host "Shared folder successfully copied to $LOCALPATH."

Write-Host "Installing required Windows features."
Install-WindowsFeature -Name DHCP, AD-Domain-Services, DNS -IncludeManagementTools
Write-Output "All required packages installed successfully."


Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True
New-NetFirewallRule -DisplayName "Allow SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
New-NetFirewallRule -DisplayName "Allow AD DS core" -Direction Inbound -Protocol TCP -LocalPort 53,88,135,389,445,3268,3269 -Action Allow
New-NetFirewallRule -DisplayName "Allow AD DS core UDP" -Direction Inbound -Protocol UDP -LocalPort 53,88,389 -Action Allow

$NAME = "WS2-25-martijn.hogent"
$PASS = "Password123!"

# Promote to dcx
Write-Output "Promoting server1 to domain controller"
Install-ADDSForest -DomainName $NAME `
    -ForestMode Win2025 `
    -DomainMode Win2025 `
    -InstallDns `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $PASS -AsPlainText -Force) `
    -Force
Write-Host "SERVER1 successfully promoted to domain controller."
