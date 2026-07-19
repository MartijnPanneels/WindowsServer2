# Readme - Panneels Martijn 3B2

## Deployment Guide

### Credentials

| Naam           | Gebruikersnaam  | Wachtwoord     | Groep                   | OU     |
| :------------- | :-------------- | :------------- | :---------------------- | :----- |
| **DSRM Admin** | `Administrator` | `vagrant`      | Safe Mode Administrator | N.v.t. |
| **Admin1**     | `admin1`        | `Password123!` | Domain Admins           | IT     |
| **Admin2**     | `admin2`        | `Password123!` | Domain Admins           | IT     |
| **User1**      | `user1`         | `Password123!` | Domain Users            | HR     |
| **User2**      | `user2`         | `Password123!` | Domain Users            | HR     |

### Server 1

1. Start Server1: `vagrant up server1`.
2. Voer op de VM `C:\vagrant\Server1\setupS1.ps1` uit.
3. Na dit script is er een reboot vereist. Log na het uitvoeren van het eerste script in met de administrator: `ssh administrator@192.168.25.10` het wachtwoord is `vagrant`
4. Ga in de powershell env: `powershell`
5. Navigeer naar `C:\vagrant\Server1\setupS1-p2.ps1` en voer dit script uit.
6. Om te valideren of server1 alle functionaliteiten heeft kan je het `C:\vagrant\Server1\valideerS1.ps1` uit voeren en de output bekijken.

### Server 2

1. Start Server2: `vagrant up server2`.
2. Voer op de VM `C:\vagrant\Server2\setupS2.ps1` uit.
3. Na dit script is er een reboot vereist. Log na het uitvoeren van het eerste script in met de administrator: `ssh admin1@192.168.25.20` het wachtwoord is `Password123!`
4. Ga in de powershell env: `powershell`
5. Voer op de VM `C:\vagrant\Server2\setupS2-p2.ps1` uit.
6. Om te valideren of server2 alle functionaliteiten heeft kan je het `C:\vagrant\Server2\valideerS2.ps1` uit voeren en de output bekijken.

### Client

1. Start client: `vagrant up client`.
2. Log in: wachtwoord `vagrant`
3. Voer op de VM `C:\vagrant\client\setupC.ps1` uit.
4. Log in met: `WS2-25-martijn\admin1` en wachtwoord `Password123!`
5. Ga in Powershell naar `C:\Users\Public\shared_folder\Client` en voer `setupC-p2.ps1` uit.
6. Om te valideren of de client alle functionaliteiten heeft kan je het `C:\vagrant\Client\valideerC.ps1` uit voeren en de output bekijken.
7. Open SQL Server Management Studio
8. Vul de volgende gegevens in: Server type: Database Engine, Server name: server2.WS2-25-martijn.hogent, Authentication: Windows Authentication en klik Trust server certificate aan.
9. Connectie is gemaakt
10. Surf naar: http://server1.ws2-25-martijn.hogent/certsrv, vul de credentials in.

### Wat heb je geleerd uit dit deel van het project?

### Wat zou je in de toekomst anders doen?

### Aan welke zaken heb je (te) veel tijd verloren?
