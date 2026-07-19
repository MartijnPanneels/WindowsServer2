Write-Host "Verander het toetsenbord naar azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE
Write-Host "Verander het toetsenbord naar azerty voltooid"

Write-Host "Instalatie van RSAT tools"
$RSATFeatures = @(
    "Rsat.ActiveDirectory.DS-LDS.Tools",
    "Rsat.Dns.Tools",
    "Rsat.FileServices.Tools",
    "Rsat.GroupPolicy.Management.Tools",
    "Rsat.ServerManager.Tools",
    "Rsat.DHCP.Tools"
)

foreach ($Feature in $RSATFeatures) {
    Write-Output "Installing capability: $Feature..."
    Add-WindowsCapability -Online -Name "$Feature~~~~0.0.1.0" -ErrorAction SilentlyContinue
    Write-Host "$Feature processing complete."
}

Write-Host "Instalatie van RSAT tools voltooid"

Write-Host "Installatie van SSMS"

$SSMSInstallerPath = "C:\Users\Public\shared_folder\SQL\SSMS-Setup-ENU.exe"

Start-Process -FilePath $SSMSInstallerPath -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow

Write-Host "Installatie van SSMS voltooid"

Write-Host "Script C-p2 voltooid"