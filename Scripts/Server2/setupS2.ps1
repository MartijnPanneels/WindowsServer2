# Setup Server2
Write-Host "azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# Statisch ip instellen
$adapter = Get-NetAdapter | Where-Object {
    $addresses = Get-NetIPAddress -InterfaceIndex $_.InterfaceIndex -ErrorAction SilentlyContinue
    ($_.Status -eq "Up" -and -not ($addresses.IPAddress -like "10.0.*"))
} | Select-Object -First 1

Write-Host "Configuring static IPv4"
New-NetIPAddress -InterfaceAlias $adapter.Name -IPAddress "192.168.25.20" -PrefixLength 24 -ErrorAction SilentlyContinue

# Verwijs naar Server1 om het domein te vinden
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.25.10"

Write-Output "Static IP set to 192.168.25.20 on interface $($adapter.Name)"


# Copy shared folder locally
Write-Output "Copying shared folder to the local path."
$LOCALPATH = "C:\Users\Public\shared_folder"

if (!(Test-Path $LOCALPATH)) {
    New-Item -Path $LOCALPATH -ItemType Directory -Force
    Write-Output "Local path created at $LOCALPATH."
}
Copy-Item -Path C:\vagrant\* -Destination $LOCALPATH -Recurse -Force
Write-Host "Shared folder successfully copied to $LOCALPATH."

# Install required packages
Write-Host "Installing required Windows features."
Install-WindowsFeature -Name DNS -IncludeManagementTools
Write-Output "All required packages installed successfully."

# Configure firewall
Write-Host "Configuring Firewall..."
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True
New-NetFirewallRule -DisplayName "Allow SSH" -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow
New-NetFirewallRule -DisplayName "Allow SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
New-NetFirewallRule -DisplayName "Allow SQL Browser" -Direction Inbound -Protocol UDP -LocalPort 1434 -Action Allow

# Domein Join
Write-Host "Joining domain WS2-25-martijn.hogent..."
$Domain = "WS2-25-martijn.hogent"
$Password = ConvertTo-SecureString "Student2025!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential("Administrator", $Password)

Add-Computer -DomainName $Domain -Credential $Credential -Options JoinWithNewName,AccountCreate -Restart:$false -Force

Write-Host "Server2 basic setup and domain join complete. Please run Restart-Computer -Force"