## Discovery

#Nmap 

```bash
sudo nmap -oN discoveryScan -sn 192.168.1.0/24
```

###   Findings:

IP Address: 192.168.1.20

## Recon

#Nmap 

```bash
sudo nmap -T4 -sV -sC -p- -oA targetScan 192.168.1.20
```

###   Findings:

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 80    | http   | Apache httpd 2.4.29 |
| 110    | pop3   | Dovecot pop3d |
| 2222  | ssh    | OpenSSH 8.2p1 |
| 8000  | nagios-nsca  | Nagios NSCA  |
| 9000  | cslistener? | NONE  |

Linux OS

SSH is running on a non default port... Security through obscurity?
A pop3 server is running
Need to research what a nagios nsca is and what a cslistener is

I navigated to port 80 to see what the website is hosting and got the following:

![[nullyCTFHomePage.png]]

ROE:
    I need to stay away from attacking port 80 on this machine as well as port 8000 and 9000
    There are three servers in total
        Mail
        Web
        Database 
    The first server seems to be the mail server since port 110 is hosting a pop3 service
    I have credentials for the pop3 server,
        `pentester:qKnGByeaeQJWTjj2efHxst7Hu0xHADGO`

## Enumeration

#Telnet 

```bash
telnet 192.168.1.20 110
```

###    Findings:

I was able to log into the pop3 server on port 110 using the provided credentials.
I was then able to read my email and had one from a "Bob Smith" who said that he was the mail server admin.

He let me know that he forgot his password but remembered that it was simple. May need to try and crack into his account.

![[email.png]]

I tried to SSH into the mail server with my username and password and it told me that the account is currently not available

![[sshError.png]]

I tried again with a different and password and got an incorrect password message, so I know that the username and password is valid

After doing some research on pop3, it seems that the only way to know if a username is valid is to correctly log in with it. This means that I will need to know the password as well and will probably need to brute force the system to get the correct login

#username-anarchy

```bash
username-anarchy -i name > usernames
```

I created a username list with username anarchy out of the name "bob smith" and I am trying to crack the user's password with the hint that was given on the vulnhub page of greping "bobby" from rockyou and making a wordlist from that

#Hydra 

```bash
hydra -L usernames -P bobby.list -f 192.168.1.20 pop3 -V
```

I am using hydra to brute force the pop3 server with these lists

![[hydraPop3.png]]

I was able to get the correct username and password pair for the pop3 server
    user: bob
    pass: bobby1985

I was able to telnet into the server as bob, but there are no messages in his inbox or information to get from it

![[telnetPop3Bob.png]]

However, now that I know I have a successful login I can see if these credentials work with SSH

Using the same username and password that I found for the mail server, I was able to log in as Bob to the ssh port, 2222

![[sshLoginBob.png]]

#MetaSploit 

Using the ssh-exec exploit in metasploit, I was able to login and get a meterpreter shell on the system using Bob's credentials

![[sshMeterpreter.png]]

Looking inside of Bob's home directory, I found a file called 'todo'
    Inside of the file I was able to find a list of things that Bob was wanting to get done, one of them included creating a 2nd user in order to do backups so that it wasn't his account doing it
    I was able to find this 2nd user and it is called "my2user" 

![[bobsHomeDir.png]]

I was able to run "sudo -l" as Bob since I have his password and was able to see that he can run a script as the "my2user" account 

![[sudoLBob.png]]

Inside of this script is a lot of different checks to see if the server is running correctly. I think I should be able to use this script to get into that account and see if it has better permissions

![[sudoLMy2User.png]]

Looking at the script, I was able to append things to the end of it in order to check what kind of permissions my2user had
    I added "sudo -l" to the end and found that the user was able to run a command as root
        The /usr/bin/zip command

![[gtfoBinsZip.png]]

Looking into this command, I found on GTFOBins that you can use it to keep elevated permissions
    I was able to append the commands to the file that it said to and then ran the script as my2user again, this allowed me to keep the root permissions and get a shell as root and read the flag in the root directory

![[mailServerRootFlag.png]]

## Recon

Now that I have gotten root on the mail server, I need to search for a way to reach the web server and pivot to it in order to get root there as well 
###   Findings:

#meterpreter

Using my meterpreter session with the mail server, I was able to see the network interfaces that the mail server has
    One of them is interesting as it has a connection to a 172 subnet
        172.17.0.2 is the address that it has which tells me that there is an internal subnet that I can access with this machine

![[mailServerInterfaces.png]]

I was able to use meterpreter to setup a route to this new subnet so that I can start searching it

![[mailServerRoutes.png]]

While searching for ways that I could search the subnet for any hosts, I was able to find that the mailserver had nmap on it, whether through the meterpreter or because it was already on the system I am not sure.
    I used the nmap on the pwned mail server to do a subnet scan and find more hosts in the internal subnet

```shell
nmap -sn 172.17.0.0/16
```

![[nmapSubnetScan.png]]

The hosts that I found are:
    172.17.0.1
    172.17.0.2
    172.17.0.3
    172.17.0.4
    172.17.0.5

It seems that 172.17.0.1 and 172.17.0.2 are both the mail server because they have the same ports open and the same thing on those ports and it is just duplicated

```shell
nmap -T4 172.17.0.3-5
```

![[subnetPortScan.png]]

As for the other hosts
    172.17.0.3 seems to be the database server because it has FTP and SSH open
    172.17.0.4 seems to be the container host and should not be attacked per the ROE
    172.17.0.5 seems to be the web server because it has HTTP and SSH open

#### Web Server

I scanned the web server IP address to get the service information on it to see what versions are running on the open ports

```shell
nmap -T4 -sV -oX webServer.xml -p- 172.17.0.5
```

![[webServerPortScan.png]]

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | SSH   | OpenSSH 8.2p1 |
| 80    | HTTP   | Apache httpd 2.4.41 |

I was able to set up a port forward using the meterpreter session to port 80 so that I could see the http service from my attack machine

```msfconsole
portfwd add -l 1234 -p 80 -r 172.17.0.5
```

![[portfwdCreated.png]]

I was able to access the http port from my local machine and was greeted with a page that says that it is under construction and gives me a name that I can maybe use to brute force "Oliver" 

![[webServerHomePage.png]]

Seems that this page doesn't have anything else on it, but I will search for some exploits and also try and brute force ssh with the username oliver to see if that gets a login

I was able to find another person, Oscar

I looked at the website's robots file and found an entry for /ping. When I went to that path it pulled up a directory listing with two files and one was titled "For Oscar"

![[websiteListingForPing.png]]

Inside of the text file it says that the application ping is used to check other servers.

![[forOscar.png]]

If I open up the ping.php file I get a small line of php that I need to look into to see what it actually is doing/trying to do

![[webServerPingPHP.png]]

Using the host parameter in the url and the gateway of this server's network, I was able to get a response in this page

![[pingAppGatewayResponse.png]]

After looking at the input/output and thinking on how the small script would be running, I realized that it is most likely take the host parameter and IP address and just sending it to the "ping" command
    Thinking on how to break this, I tried to add a "&" and a "&&" and then a different command after that, but it did not return anything. I then tried a ";" to break out of the first "ping" command and then ran a command and I got a response back from the system

![[brokenPHPScriptPasswd.png]]

I was able to upload a static binary of "nc" to the mail server and then from there do a "wget" on the web server to get it onto that system. I then set up a remote listener on the mail server and ran a reverse shell from the web server to the mail server and I now have a shell on the system

![[reverseShellWebServer.png]]

Now that I am on the server, I can start looking for files and programs that belong to people other than the system and services
    There are two other users on this system
        Oscar: 1000
        Oliver: 1001

Searching through the files that Oscar owns did not bring up anything that I was able to use other than python, but I have to have a password

Searching through the files that Oliver owns brings up something interesting though. There is a file named ".secret" that Oliver owns in the "/var/backups" folder
    When I read the file it has his password in it

![[oliverSecretPassword.png]]

Creating a local port forward from the mail server to the ssh port on the web server, I was able to ssh into the web server from my machine

![[sshAsOliver.png]]

Now that I am on the system as a user and in a better shell environment, I can do some more enumeration to see if I can escalate my privileges.

I looked around for the sticky bit set on any binaries and found that python3 is able to be run as Oscar, so I ran it to get a shell and was able to land as Oscar instead of Oliver

![[pythonToOscar.png]]

I then looked around in Oscar's home directory and found a text file named "my_password" and inside is his password for the machine

![[oscarPassword.png]]

Inside of Oscar's home folder there was a folder called "scripts" and inside of here there was a binary called "current_date" that when ran gives you back the current date and time

However, this binary was ran by root and when I ran strings against it I was able to find that it was using the setuid command and running the date binary to get the date
    Since the date binary it was running was the one in the path and it was not calling it directly, I was able to write my own script called date and add it to the path before the normal date binary

![[currentDateBinary.png]]

I named my script "date" and put only the "su" command in it and then added it to the path and ran the current_date script. I was then greeted with a root terminal prompt and was able to read the root flag

![[dateRootScript.png]]

![[runningCurrentDateGettingRoot.png]]

![[webServerRootFlag.png]]

#### File Server

The file server seems to be at IP address 172.17.0.3
    This IP address is running ftp and ssh

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 21    | ftp   | vsftpd 3.0.3 |
| 22    | ssh   | OpenSSH 8.2p1 |

Looking into the FTP server from the source of the web server, I was able to login as anonymous to list out the directories. 

![[anonymousFTPListing.png]]

I found that the server had a folder in it called pub/test, but that at the end it was just one empty file in it.

![[pubDirectoryListing.png]]

I decided to pull all of the files down in order to see if there was anything else here just in case there were hidden files that I could not see.

#Wget 
```bash
wget -r -l 0 ftp://anonymous@172.17.0.3/*
```

![[wgetFTPFiles.png]]

Once I downloaded the files and listed them looking for hidden files, I found a folder called .folder in the pub folder. Inside of this folder was a zip file called .backup.zip but when I tried to unzip it I found that it was password protected.

![[hiddenFTPFiles.png]]

![[protectedZIPArchive.png]]

I was able to use john2zip in order to get the hash of the zip file and then I used hashcat to crack the password on the archive and unzip the folder. Inside, I found a text file titled "creds.txt" and inside was a username and password for a user named "donald"

#John 
```bash
zip2john .backup.zip > backup.hash
```

![[zip2JohnBackup.png]]

#Hashcat 
```bash
hashcat -m 17210 -a 0 backup.hash /usr/share/wordlists/rockyou.txt
```

![[crackedArchive.png]]

![[donaldCredentials.png]]

Using these credentials, I was able to setup a port forward to this machine and SSH into it from my attack box and get user access.

```bash
ssh -L 4546:172.17.0.3:22 root@192.168.1.16 -p 2222 -i mailServerRootKey
```

![[loginAsDonald.png]]

Running a search to see if any binaries have the sticky bit set that are vulnerable returned one that is not normal to find. 

![[fileServerStickyBit.png]]

A binary called "screen," after looking this up in GTFObins I was able to find a way to use this in order to get root access
    Unfortunately, this would require sudo access and I cannot run sudo

However, since this has the sticky bit set and is version 4.5.0, there is an exploit for this in exploitDB that can give us root access instead.

The exploit takes advantage of the fact that you can run the process as root as well as being able to create our own C files for the screen binary to use. It then runs screen on our file instead of the normal config and gives us a session as root

![[gettingRootOnFileServer.png]]

Now that I have a root shell, I am able to get the flag on the file server and have finished the box

![[rootFlagFileServer.png]]