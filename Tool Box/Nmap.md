## #Nmap

*My default scan: This will save output in all formats so make sure you know where you are running it from*
```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan <target>
```

*Scan a network for targets and save the output to a normal file*
```bash
sudo nmap -oN <filename> -sn <subnet>
```

*Scan a target system with safe scripts and save the output to a normal file and XML*
```bash
sudo nmap -T4 -O -sV -sC -oN <filename> -oX <filename>.xml <target>
```

*Enumerate SMB share on a target system*
```bash
sudo nmap --script smb-enum-shares.nse -p139,445 <target>
```

*Tells you the reason a port is open|filtered|closed*
```bash
sudo nmap --reason <target>
```

*Add verbosity*
```bash
sudo nmap -v <target>
```
*Can also press 'v' during scan to add it as well*
