# Deployment Guide

**Verdiepende/technische uitleg staat genoteerd in de scripts**

1. Om de opstelling op te zetten moet men beginnen met `vagrant up server1` uit te voeren in de directory waar de vagrantfile staat. De virtuele machine, server1, wordt hierdoor aangemaakt en opgestart. Alle bestanden die nodig zijn om het vervolg van de setup te voltooien wordt gekopieerd in C:/scripts. De basisopstelling wordt reeds gestart bij het uitvoeren van `vagrant up server1`. Dit komt omdat `setup.ps1`automatisch wordt uitgevoert.
2. Nadat de virtuele machine is opgestart kunnen we het volgende script uitvoeren. Ga naar C:/scripts en voer `DC.ps1` uit. Dit script promoveert server1 tot de domein controller.
3. De volgende stap voert men `ADConfig.ps1` uit. Dit stelt gebruikers in, zowel administratoren als gebruikers. Hierin wordt ook DNS en DHCP geconfigureerd.
4. Vervolgens kunnen we de 2de server aanmaken. Hiervoor gebruikt men `vagrant up server2`. `Setup.ps1` wordt hierdoor ook automatisch uitgevoerd.
5. Om server2 verder te configureren gebruiken we opnieuw de scripts die werden gekopieerd bij de opstart. In C:/scripts kunnen we DNS.ps1 uitvoeren.
6. De Client kunnen we opstarten met dezelfde werkwijze als de vorige servers, hiervoor gebruiken we `vagrant up client` in de map waarin de vagrant file staat. Het `setup.ps1` bestand wordt hier ook automatisch uitgevoerd.