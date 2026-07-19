Write-Host "Configureer netwerkadapter voor DHCP en DNS"
$InternalAdapter = Get-NetAdapter | Where-Object { $_.InterfaceAlias -ne "Ethernet" }
Set-NetIPInterface -InterfaceAlias $InternalAdapter.InterfaceAlias -Dhcp Enabled
Set-DnsClientServerAddress -InterfaceAlias $InternalAdapter.InterfaceAlias -ResetServerAddresses

Write-Host "Configuratie voltooid"

Write-Host "Kopieer gedeelde map naar lokale pad"
$LOCALPATH = "C:\Users\Public\shared_folder"

New-Item -Path $LOCALPATH -ItemType Directory -Force
Copy-Item -Path "C:\vagrant\*" -Destination $LOCALPATH -Recurse -Force
Write-Host "Kopieer gedeelde map naar lokale pad voltooid"

Write-Host "Join domain WS2-25-martijn.hogent"
$Domain = "WS2-25-martijn.hogent"
$AdminUser = "WS2-25-martijn\admin1"
$Password = ConvertTo-SecureString "Password123!" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($AdminUser, $Password)

Add-Computer -DomainName $Domain -Credential $Credential -Restart -Force