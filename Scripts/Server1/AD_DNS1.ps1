Param([switch]$Post)

$ErrorActionPreference = 'Stop'

# Configuration
$DomainName = "WS2-25-martijn.hogent"
$DomainNetbios = "WS225MARTIJN"
$SafeModePasswordPlain = "P@ssw0rd123!"
$SafeModePassword = ConvertTo-SecureString $SafeModePasswordPlain -AsPlainText -Force
$RunOnceName = "WS2_PostADConfig"
$DestFolder = "C:\vagrant\Server1"
$CopiedScript = Join-Path $DestFolder "AD_DNS1.ps1"

function Join-DNFromDomain {
    param($domain)
    ($domain -split '\.') | ForEach-Object { "DC=$_" } -join ','
}

if ($Post) {
    # Post-reboot actions (RunOnce will call this)
    Start-Sleep -Seconds 120

    Try { Import-Module ActiveDirectory -ErrorAction SilentlyContinue } Catch {}
    # wait for AD services to be ready
    $tries = 0
    while ($tries -lt 12) {
        if (Get-Service -Name ntds -ErrorAction SilentlyContinue) { break }
        Start-Sleep -Seconds 10
        $tries++
    }

    $dcPath = Join-DNFromDomain -domain $DomainName

    # Create OU structure (idempotent)
    Try { if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Admin_Accounts'" -ErrorAction SilentlyContinue)) { New-ADOrganizationalUnit -Name "Admin_Accounts" -Path $dcPath -ProtectedFromAccidentalDeletion $false } } Catch {}
    Try { if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'User_Accounts'" -ErrorAction SilentlyContinue))  { New-ADOrganizationalUnit -Name "User_Accounts"  -Path $dcPath -ProtectedFromAccidentalDeletion $false } } Catch {}
    Try { if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'Servers'" -ErrorAction SilentlyContinue))        { New-ADOrganizationalUnit -Name "Servers"        -Path $dcPath -ProtectedFromAccidentalDeletion $false } } Catch {}

    # Create users (if not exist) and add to Domain Admins
    $pw = ConvertTo-SecureString $SafeModePasswordPlain -AsPlainText -Force
    Try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq 'admin1'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name "admin1" -GivenName "Admin" -Surname "One" -SamAccountName "admin1" -UserPrincipalName "admin1@$DomainName" -Path "OU=Admin_Accounts,$dcPath" -AccountPassword $pw -Enabled $true
        }
        Add-ADGroupMember -Identity "Domain Admins" -Members "admin1" -ErrorAction SilentlyContinue
    } Catch {}

    Try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq 'admin2'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name "admin2" -GivenName "Admin" -Surname "Two" -SamAccountName "admin2" -UserPrincipalName "admin2@$DomainName" -Path "OU=Admin_Accounts,$dcPath" -AccountPassword $pw -Enabled $true
        }
        Add-ADGroupMember -Identity "Domain Admins" -Members "admin2" -ErrorAction SilentlyContinue
    } Catch {}

    Try {
        if (-not (Get-ADUser -Filter "SamAccountName -eq 'user1'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name "user1" -GivenName "User" -Surname "One" -SamAccountName "user1" -UserPrincipalName "user1@$DomainName" -Path "OU=User_Accounts,$dcPath" -AccountPassword $pw -Enabled $true
        }
        if (-not (Get-ADUser -Filter "SamAccountName -eq 'user2'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name "user2" -GivenName "User" -Surname "Two" -SamAccountName "user2" -UserPrincipalName "user2@$DomainName" -Path "OU=User_Accounts,$dcPath" -AccountPassword $pw -Enabled $true
        }
    } Catch {}

    # DNS configuration (idempotent attempts)
    Try {
        if (-not (Get-DnsServerZone -Name $DomainName -ErrorAction SilentlyContinue)) {
            Add-DnsServerPrimaryZone -Name $DomainName -ReplicationScope "Domain"
        }
    } Catch {}

    Try {
        $revZoneName = "25.168.192.in-addr.arpa"
        if (-not (Get-DnsServerZone -Name $revZoneName -ErrorAction SilentlyContinue)) {
            Add-DnsServerPrimaryZone -NetworkID "192.168.25.0/24" -ReplicationScope "Domain"
        }
    } Catch {}

    # Add A records (update if exists)
    Try { Add-DnsServerResourceRecordA -Name "server1" -ZoneName $DomainName -IPv4Address "192.168.25.10" -CreatePtr -ErrorAction SilentlyContinue } Catch {}
    Try { Add-DnsServerResourceRecordA -Name "server2" -ZoneName $DomainName -IPv4Address "192.168.25.20" -CreatePtr -ErrorAction SilentlyContinue } Catch {}

    # Configure Zone Transfers (ignore errors if already configured)
    Try { Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20" -ErrorAction SilentlyContinue } Catch {}
    Try { Set-DnsServerPrimaryZone -Name $revZoneName -SecureSecondaries "TransferToServer" -SecondaryServers "192.168.25.20" -ErrorAction SilentlyContinue } Catch {}

    # Update DHCP server options (if DHCP service present)
    Try { Set-DhcpServerv4OptionValue -DnsServer "192.168.25.10" -Router "192.168.25.1" -ErrorAction SilentlyContinue } Catch {}

    Write-Host "AD Domain and DNS configuration completed."

    # Optionally remove copied script
    Try { Remove-Item -Path $CopiedScript -Force -ErrorAction SilentlyContinue } Catch {}

    Exit 0
}

# ---------- Pre-promotion ----------
# If already domain controller, exit
if (Get-Service -Name ntds -ErrorAction SilentlyContinue) {
    Write-Host "Already a domain controller. Exiting."
    Exit 0
}

# Ensure destination folder exists (C:\vagrant is mounted by Vagrant)
if (-not (Test-Path $DestFolder)) { New-Item -Path $DestFolder -ItemType Directory -Force | Out-Null }

# Copy this script to the synced folder so it is available after reboot
$MyScript = $MyInvocation.MyCommand.Definition
Try { Copy-Item -Path $MyScript -Destination $CopiedScript -Force -ErrorAction Stop } Catch { Write-Host "Warning: could not copy script to $CopiedScript. $_" }

# Create RunOnce entry to run the same script with -Post after reboot
Try {
    $cmd = "powershell -NoProfile -ExecutionPolicy Bypass -File `"$CopiedScript`" -Post"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name $RunOnceName -Value $cmd
} Catch {
    Write-Host "Warning: could not set RunOnce. $_"
}

# Install AD Domain Services and DNS
Try {
    Install-WindowsFeature -Name AD-Domain-Services, DNS -IncludeManagementTools -ErrorAction Stop
} Catch {
    Write-Error "Failed to install AD/DNS features: $_"
    Exit 1
}

# Promote to Domain Controller (this will trigger reboot)
Try {
    Install-ADDSForest `
        -DomainName $DomainName `
        -DomainNetbiosName $DomainNetbios `
        -ForestMode "Win2025" `
        -DomainMode "Win2025" `
        -SafeModeAdministratorPassword $SafeModePassword `
        -Force
} Catch {
    Write-Error "AD promotion failed: $_"
    Exit 1
}

Write-Host "AD promotion initiated; post-configure will run after reboot via RunOnce."