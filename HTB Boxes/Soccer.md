
IP Address: 10.10.11.194

## Target Scanning



###   Tools Used:

#Nmap 

###   Commands Ran:

```
sudo nmap -T4 -O -sV -sC -oN targetScan $ipAddress
```

```
sudo sniper -t soccer.htb
```

```
sudo dirb http://soccer.htb /usr/share/wordlists/dirb/big.txt
```

```
nc -nvlp 4444
```

```
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

###   Findings:

|Port|Service|Version|
|---|---|---|
|22|SSH|OpenSSH 8.2p1|
|80|HTTP|nginx 1.18.0|
|9091|xmltec-xmlmail?|Version not found|

What is port 9091 used for?
    Outbound TCP/9091 and 9092 (or whatever ports are configured for HTTP and HTTPS the client transfer application). These are **the ports through which a client on the internal network establishes communication with the proxy server**.

What is xmltec-xmlmail?
    

    | vulners: 
    |   cpe:/a:openbsd:openssh:8.2p1: 
    |     	CVE-2020-15778	6.8	https://vulners.com/cve/CVE-2020-15778
    |     	C94132FD-1FA5-5342-B6EE-0DAF45EEFFE3	6.8 https://vulners.com/githubexploit/C94132FD-1FA5-5342-B6EE-0DAF45EEFFE3	*EXPLOIT*
    |     	10213DBE-F683-58BB-B6D3-353173626207	6.8	https://vulners.com/githubexploit/10213DBE-F683-58BB-B6D3-353173626207	*EXPLOIT*
    |     	CVE-2020-12062	5.0	https://vulners.com/cve/CVE-2020-12062
    |     	CVE-2021-28041	4.6	https://vulners.com/cve/CVE-2021-28041
    |     	CVE-2021-41617	4.4	https://vulners.com/cve/CVE-2021-41617
    |     	CVE-2020-14145	4.3	https://vulners.com/cve/CVE-2020-14145
    |     	CVE-2016-20012	4.3	https://vulners.com/cve/CVE-2016-20012
    |_    	CVE-2021-36368	2.6	https://vulners.com/cve/CVE-2021-36368

Dirb found a hidden directory 
    soccer.htb/tiny
    This is a web portal for the software "Tiny file manager"

What is Tiny File Manager?
    Tiny File Manager is a web based file management system written in php. It is open source and made to be fast and small

Vulnerability found in Tiny File Manager:
    Authenticated RCE exploit

I looked up the default creds to Tiny File Manager
    user/password - admin:admin@123

I logged in with the default credentials and could see the file structure of the site and was also about to see a folder called uploads
    The tiny file manager exploit needs a place to upload to and therefore this is the perfect spot to try it out

I got a PHP reverse shell from pentestmonkey and put it into a file to upload
    I set up a listener on my machine and then uploaded the file and opened it in the browser to make it run

I got a connection on my listener and was not logged in as www-data but as not a tty shell. I ran the above python command and got a tty

I checked the /etc/passwd file and saw that there was a user on the machine other than root named "player"

Going into their home directory I found a file called "user.txt" but could not read it because I did not have permissions

I was able to now upload linpeas onto the machine through the upload folder and move it to /tmp 

After running linpeas I found a new hostname that had a page running on it "soc-player.soccer.htb"
    I added that name to my hosts file instead of the soccer.htb and was able to connect

I ran dirb on this page to see what was there and found a hidden directory called /check

On this page was a text box that was using a web socket to connect back to the server and check something but it was not doing it securely

I was able to get a python script that allowed me to blind sqli the text box

##  Enumeration

###    Tools Used:

#Python #Sqlmap 

###    Commands Ran:

```
python3 sqliInjection.py
```

```
sqlmap -u "http://localhost:8081/?id=1" -p "id" --dbs
```
```
sqlmap -u "http://localhost:8081/?id=1" -D soccer_db --dump
```


###    Findings:

After running a blind sqli injection the site I found the database that were present and one was called "soccer_db"
    I dumped that database so that I could see what was in it

One of the tables was called "Accounts" and had the "player" account in it and contained the password in clear text
    PlayerOftheMatch2022

I used the username player and the password to ssh into the machine now so that I had a more stable shell

I tried to view my sudo permissions but did not have sudo rights at all 

After looking up different ways to check my permissions I came across "doas" on the machine which gave me permission to run commands as root in a single folder "/usr/bin/dstat"

I found an exploit with this folder that allows you to create a listener and send a shell back to it as root when it runs the python script

##  Root Access Obtained

I created a new listener on my machine and ran the script in that folder and I was now root