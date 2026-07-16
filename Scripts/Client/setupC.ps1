# Setup Client

Write-Host "Configuring Internal Network Interface..."
# We zoeken de tweede netwerkkaart (niet de NAT adapter)
$InternalAdapter = Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne "Ethernet" }

# IP en DNS instellen
$IPAddress = "192.168.25.30"
$PrefixLength = 24
$Gateway = "192.168.25.1" # Optioneel, afhankelijk van je routing vereisten
$DNSServer = "192.168.25.10"

New-NetIPAddress -InterfaceAlias $InternalAdapter.InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $InternalAdapter.InterfaceAlias -ServerAddresses $DNSServer

Write-Host "Network configuration complete. IP: $IPAddress, DNS: $DNSServer"

# Copy shared folder locally
$LOCALPATH = "C:\Users\Public\shared_folder"

Write-Output "Copying shared folder to the local path."
if (!(Test-Path $LOCALPATH)) {
    New-Item -Path $LOCALPATH -ItemType Directory -Force
    Write-Output "Local path created at $LOCALPATH."
}
Copy-Item -Path "C:\vagrant\*" -Destination $LOCALPATH -Recurse -Force
Write-Host "Shared folder successfully copied to $LOCALPATH."

Write-Host "Joining domain WS2-25-martijn.hogent..."

$Domain = "WS2-25-martijn.hogent"
$AdminUser = "WS2-25-martijn\admin1"
# Gebruik het wachtwoord dat je voor admin1 hebt ingesteld
$Password = ConvertTo-SecureString "Student2025!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($AdminUser, $Password)

# Voeg de client toe aan het domein (herstart automatisch als het succesvol is)
Add-Computer -DomainName $DOMAIN -Credential $CREDENTIAL -Restart -Force