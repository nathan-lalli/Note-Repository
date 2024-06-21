## Target Discovery

###   Tools Used:

#Nmap 
   
###   Commands Ran:

```bash
sudo nmap -oN hostDiscovery -sn 192.168.1.0/24
```

###   Findings:

![[hostDiscovery.png]]

Target IP Address:
    192.168.1.26

## Target Recon

##### #Nmap 

```bash
sudo nmap -T4 -O -sV -sC --reason -p- -oA targetScan 192.168.1.26
```

###   Findings:

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | SSH   | OpenSSH 5.9p1 |
| 3128    | HTTP-Proxy   | Squid Http Proxy 3.1.19 |
| 8080 | HTTP-Proxy | Showing as closed |

Port 22 and 3128 are showing as open, but port 8080 is showing but says closed.
    Could this be due to the http proxy?

![[Images/SickOS/NmapScan.png]]

##### #SearchSploit 

```bash
searchsplot --nmap targetscan.xml
```

### Findings:

I should be able to do user enumeration through SSH
Squid has some exploits, but I will need to search more to see if they will be useful.

Did a lookup on squid web proxy and found some CVEs associated with version 3.1.19

There is a hacktricks page on squid
     Since squid is a web proxy, in order to curl it you have to provide the --proxy flag


##### #Browser 

### Findings:

I went to the IP address and proxy port in firefox and got an error page

![[initialWebAccessError.png]]

The most interesting thing here is that the cache administrator is said to be webmaster. This could be a username on the machine and we can verify with SSH
    Webmaster is not a valid username

##### #Curl 

```bash
curl --proxy http://192.168.1.26:3128 http://192.168.1.26
```

### Findings:

![[defaultCurlProxy.png]]

I got real output from the page, but it is a single level 1 header saying "BLEH!!!"
    Not sure what this means

##### #ProxyChains

```bash
sudo vim /etc/proxychains4.conf
```
*Add line: "http 192.168.1.26 3128" to the end of the file*

```bash
sudo proxychains nmap -T4 -O -sV -sC -p- -oA proxiedTargetScan 192.168.1.26
```

### Findings:

Using proxychains did not work for this. It just got stuck in a loop no matter what I tried

##### #Spose

```bash
git clone https://github.com/aancw/spose
cd spose
```

```bash
sudo python spose.py --proxy http://192.168.1.26:3128 --target 192.168.1.26
```

### Findings:

Spose finds that there are two ports open
    22 and 80

![[initialSposeScan.png]]

##  Enumeration

I used the following as an example for how to use proxied services:
    https://infosecwriteups.com/proving-grounds-practice-squid-walkthrough-f761d2da973f

##### #FoxyProxy

I set up a proxy in foxy proxy that will direct the traffic the right way and then went to the web address and got the page that just says "BLEHHH!!!"
    There is nothing in the comments or source and no other network resources

![[proxiedBrowserAccess.png]]

Going to robots.txt on that page gives one bit of info
    the page /wolfcms is disallowed

![[robots.txt.png]]

Going to /wolfcms through the proxy connections returns a small blog that does not seem to be fully set up.
    wolfcms stands for Wold Content Management Simplified, Need to see if this is a real thing or if this is what the blog is called

![[WolfCMSHomepage.png]]

## Target Recon

Turns out this is a sample blog that is using wolfcms just as an example
Wolfcms is a real software that people can use, need to see if it is vulnerable

There are vulnerabilities in Wolf CMS but I am not sure what version this site is running and need to find out

##### #Dirb 

```bash
dirb http://192.168.1.26:80/wolfcms/ -p 192.168.1.26:3128
```

Using dirb with a proxy gave me some results with a docs folder that has some install instructions and references a ? in the url

![[defaultDirb.png]]

```bash
dirb http://192.168.1.26:80/wolfcms/?/ -p 192.168.1.26:3128
```

Using proxied dirb with the ? in the URL returned a hidden admin login screen

![[extendedDirb.png]]

##### #Browser 

Going to 192.168.1.26/wolfcms/?/admin gives an admin log in screen

![[adminLogin.png]]

Trying default credentials was able to get me into the admin page
    username:admin
    password:admin

After logging in it takes you to the default admin page

![[adminPage.png]]

On the admin page home screen it shows that it is using version Wolf CMS 0.8.2

## Enumeration

Looking up vulnerabilities on Wolf CMS 0.8.2 I found a file upload and RCE vulnerability with PHP

After going to the files tab seen on the admin page you can upload a file there with no restrictions that then gets put in the /wolfcms/public folder for anyone to access

#Reverse_Shell #PHP

![[phpReverseShell.php]]

I uploaded the above reverse shell and created a listener on my machine with
```bash
nc -lvnp 4444
```

I then went to http://192.168.1.26\wolfcms\public and then clicked on the uploaded file and got a response back in my listener with a reverse shell

I got a shell with no TTY so I ran a TTY shell to get a better and more stable shell

```python
python -c 'import pty; pty.spawn("/bin/bash")'
```

![[shellAchieved.png]]

I tried to run sudo -l but I do not have a password to use it with

##### #Linpeas 

Running linpeas showed a list of exploits because the kernel is a very low and vulnerable version
    May be able to exploit these but I want to look and see if there is anything else

##### #Sticky_Bit 

```bash
find / -perm -4000 -type f -exec ls -al {} \; 2>/dev/null
```

Found the command /usr/bin/at that has the sticky bit set, I am not sure if this is exploitable yet, but I have never seen it before so I think it is interesting 

There is an exploit for the "at" command on ExploitDB 
    https://www.exploit-db.com/exploits/281

##### #www-data

Inside of the www-data folder I found a config.php file that has mysql credentials in it
    /var/www/wolfcms/config.php
    root:john@123

![[mysqlCreds.png]]

There was nothing interesting in the databases because it was hashed passwords that were passwords I already have


##  Root Access Obtained

After not finding anything I tried to switch users to sickos using the passwords that I had obtained so far.
    admin
    blank
    sickos
    BLEHHH!!!
    john@123

john@123 worked and let me in as sickos

![[sickosLoggedIn.png]]

Once logged in I checked my sudo permissions with "sudo -l" and saw that I had a full sudo user on the machine and did a "sudo su" to change to root

![[changedToRoot.png]]

Once on as root I was able to read the flag in the root directory

![[Images/SickOS/rootFlag.png]]