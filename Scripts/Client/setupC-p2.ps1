# ==============================================================================
# Script: setupC-p2.ps1
# Beschrijving: RSAT-tools en SSMS installeren op de Client
# ==============================================================================
# azerty keyboard layout
Write-Host "azerty"
$LangList = New-WinUserLanguageList fr-BE
Set-WinUserLanguageList $LangList -Force
Set-WinSystemLocale fr-BE
Set-WinUILanguageOverride fr-BE

# 1. Definieer het lokale pad naar SSMS
$SSMSInstallerPath = "C:\Users\Public\shared_folder\SQL\SSMS-Setup-ENU.exe"

# 2. Installatie van RSAT tools
Write-Host "Starting RSAT management tools installation..."
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
    # Gebruik de native PowerShell methode voor Features on Demand
    Add-WindowsCapability -Online -Name "$Feature~~~~0.0.1.0" -ErrorAction SilentlyContinue
    Write-Host "$Feature processing complete."
}

Write-Output "All RSAT tools have been processed."

# 3. Installatie van SSMS
Write-Host "Installing SQL Server Management Studio (SSMS)..."
Write-Host "Dit is een zware installatie en kan gerust 10 minuten duren. Geduld a.u.b."

if (Test-Path $SSMSInstallerPath) {
    # Start de installatie op de achtergrond zonder herstart
    Start-Process -FilePath $SSMSInstallerPath -ArgumentList "/install /quiet /norestart" -Wait -NoNewWindow
    Write-Host "SQL Server Management Studio installed successfully."
}
else {
    Write-Warning "Fout: Kon SSMS niet vinden op pad: $SSMSInstallerPath."
    Write-Warning "Controleer of het bestand op je hostmachine in de juiste map staat."
}

# 4. Verificatie van de installaties
Write-Output "Verifying RSAT installations..."
foreach ($Feature in $RSATFeatures) {
    # Gebruik Get-WindowsCapability om de status uit te lezen
    $CapabilityName = "$Feature~~~~0.0.1.0"
    $State = (Get-WindowsCapability -Online -Name $CapabilityName).State
    Write-Host "Feature: $Feature, Status: $State"
}

Write-Host "Script execution completed successfully."