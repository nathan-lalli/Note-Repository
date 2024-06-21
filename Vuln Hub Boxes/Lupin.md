We do not need to do host discovery on this box as the IP Address is provided 

**IP Address: 192.168.56.3**

## Recon

###   Tools Used:

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -A -p- -oA targetScan 192.168.56.3
```

###   Findings:

Found that port 22 and 80 are both pen on the machine

| Port  | Service   | Version             |
| ----- | --------- | ------------------- |
| 22    | SSH       | OpenSSH 8.4p1       |
| 80    | HTTP      | Apache httpd 2.4.48 |

![[Images/Lupin/nmapScan.png]]

The nmap scan also showed that there is an entry in the robots.txt file called /~myfiles

There are some CVEs for this version of SSH that I may look in to
    CVE-2021-28041	4.6   https://vulners.com/cve/CVE-2021-28041
    CVE-2021-41617	4.4   https://vulners.com/cve/CVE-2021-41617
    CVE-2020-14145	4.3   https://vulners.com/cve/CVE-2020-14145
    CVE-2016-20012	4.3   https://vulners.com/cve/CVE-2016-20012
    CVE-2021-36368	2.6   https://vulners.com/cve/CVE-2021-36368

There are a lot of CVEs for this version of Apache httpd, not sure if they will work since the pages are so limited

![[apacheVulns.png]]


##### #Curl 

```bash
curl http://192.168.56.3
```

There is a single image on the page and a comment that says it is an easy box

![[curl.png]]

##### #Browser 

When I went to the page http://192.168.56.3 I was able to see the image and download it to my machine for later

![[mainPage.png]]

I also went to http://192.168.56.3/~myfiles and got a error 404 page, but there is a comment on that page that says "Your can do it, keep trying"

![[fake404.png]]

## Enumeration

##### #Ffuf 

After seeing that the URL is http://192.168.56.3/~myfiles and doing a directory scan on the site comes back with nothing I decided to try a directory scan putting the "~" symbol in front

```bash
sudo ffuf -w /usr/share/wordlists/dirb/big.txt -u http://192.168.56.3/~FUZZ 
```

This came back with two results
    myfiles
    secret

##### #Browser 

Going to the URL http://192.168.56.3/~secret returned a web page saying that there is an ssh key here somewhere and gives a possible username. It also hints at using fast-track

![[secretPage.png]]

##### #Ffuf 

```bash
sudo ffuf -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -u http://192.168.56.3/~secret/.FUZZ -e .pem,.txt -fs 277 
```

This gave me the hidden file called ".mysecret.txt"

![[mySecret.png]]

This is supposed to be an ssh key but the format is off. It looks like it has been encoded somehow

##### #Dcode

Putting the text into dcode to identify the cipher came back with the cipher being "Base 58"

After decoding the text using a dcode base 58 I got back the real ssh key
    This may not work yet because there might be a passphrase on the key

##### #John

With the ssh key in hand I was able to convert it into a format that john the ripper can use to get the passphrase and then run john the ripper on it to crack the passphrase

```bash
ssh2john ssh_key.pem > ssh_key.hash
```
```bash
john --wordlist=/usr/share/wordlists/fasttrack.txt ssh_key.hash
```

![[passphraseCracked.png]]

I was able to get on to the system using this key and passphrase and got the user flag for the system

![[logInUserFlag.png]]

### Privilege Escalation

I was able to run sudo -l on the machine and found that I can run python and a python script called "heist.py" as the user "arsene" on the machine

![[sudo-l.png]]

Seeing that I can run heist.py as arsene I need to see what is in the heist.py file

![[heistpy.png]]

It seems that the script it trying to open a web browser but it does not actually work. I also do not have permission to edit the file, just read and execute it

Looking into the web browser python import I can actually edit the python file that they are importing and might be able to change the function of the open function that they are using

![[openFunction.png]]

I was able to re-write the open function so that it opens the hidden secret file and prints the output to the screen

![[arsenePassword.png]]

I was able to get arsene's password from the file

    rQ8EE"UK,eV)weg~*nd-`5:{*"j7*Q

Using this password and username, I was able to log in to the system as arsene and list his permissions on the system

![[arsenePerm.png]]

It seems that arsene can run Pip as root
    Not sure yet what I can do with this

Looking into priv esc with PIP, I found a small script that I can run to give myself root access

```bash
TF=$(mktemp -d)
```
```bash
echo "import os; os.execl('/bin/sh', 'sh', '-c', 'sh <$(tty) >$(tty) 2>$(tty)')" > $TF/setup.py
```
```bash
sudo -u root /usr/bin/pip install $TF
```

After running these commands, I was met with a blank shell and ran ID to see that I was now root and could read the root flag

## PWNED

![[rootAchieved.png]]

![[Images/Lupin/rootFlag.png]]