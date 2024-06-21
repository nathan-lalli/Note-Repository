IP Address: 10.10.11.218

## Target Scanning

###   Tools Used:

#Nmap #Dirb #Sniper #Browser

###   Findings:

##### #Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oN targetScan $ipAddress
```

![[sandwormScan.png]]

Nmap scan shows us the following:
    Port 22 - Open - OpenSSH 8.9p1
    Port 80 - Open - http nginx 1.18.0
    Port 443 - Open - ssl/http nginx 1.18.0

##### #Dirb 

```bash
dirb http://10.10.11.218
```

##### #HTTP 

I went to the website and saw that the website is powered by "Flask"
    Flask is a micro web framework for creating web APIs in Python

##### #Sniper

```bash
sudo sniper -t ssa.htb
```


##  Enumeration

###    Tools Used:


###    Commands Ran:

```

```

###    Findings:


##  Root Access Obtained
