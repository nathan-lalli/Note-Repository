**IP Address: 192.168.1.29**

## Recon

#Nmap 

```bash
sudo nmap -sV -sC -O -oA scans/targetScan -p- 192.168.1.29
```

###   Findings:

![[nmapScanofFall.png]]

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | ssh   | OpenSSH 7.8 |
| 80    | http   | Apache httpd 2.4.39 |
| 139   | netbios-ssn | Samba smbd       |
| 443   | ssl/http    | Apache httpd 2.4.39 |
| 445   | netbios-ssn | Samba smbd 4.8.10 | 
| 3306  | mysql       | MySQL (unauthorized) |
| 9090  | http        | Cockpit web service |


## Enumeration

###    Findings:

Using the browser I navigated to the web page that is being host on port 80

![[fallHomepage.png]]

From this homepage I am able to see that the site is built using a software called "CMS Made Simple"

Also on the left side of the page I see that there are links to blog posts and one of them is called "backdoor" and another talking about PHP pages and in these pages I found a possible username for someone named "qiu" 

![[fallBackdoorBlogPost.png]]

After looking through the page and not finding anything from clicking the links I ran a directory scan to see if there are any hidden pages or directories, as well as checking the robots.txt page to see if it is one the system and what it may have

![[fallRobots.png]]

From the robots page we can see that the page is blocking all bots except the Google Bot, but this is not helpful in this situation

```bash
ffuf -w /usr/share/wordlists/dirb/big.txt -u http://192.168.1.29/FUZZ
```

```bash
dirb http://192.168.1.29
```

![[fallInitialDirbScan.png]]

![[Images/Fall/dirbScan.png]]

From the first scan of the site I was able to find a few different directories that are available

```bash
ffuf -w /usr/share/wordlists/dirb/big.txt -u http://192.168.1.29/uploads/FUZZ
```

```bash
dirb http://192.168.1.29 -X .txt,.py,.php
```

![[uploadsDirectory.png]]

![[dirbScanWithExtensions.png]]

After running a scan on these directories I found a file titled "secret.txt" but inside it there was nothing important but seemed to be a clue that I was on the right track

![[secretSection.png]]

After not being able to find any results from these scans but having the hint to being on the right track, I looked at adding some file extensions to the word lists to see if anything else is being hidden

```bash
ffuf -w /usr/share/wordlists/dirb/big.txt -u http://192.168.1.29/FUZZ -e .txt,.py,.php -fc 301,403
```

![[extensionDirbScan.png]]

After running this scan I was able to find that the root directory of the site has a file in it called "test.php" that is not a normal file to find in this directory

![[missingGet.png]]

When navigating to this page I was met with an error message telling me that I am "Missing a GET parameter!" 
    In the context of a php script, this means that the site is expecting a variable to get sent to it with the page request but that it is not getting anything
    To test this I will FUZZ the site to see what parameter it is looking for

```bash
ffuf -w /usr/share/wordlists/dirb/big.txt -u http://192.168.1.29/test.php?FUZZ=test -fs 80
```

![[fuzzingTestParameter.png]]

After running this fuzz, I was able to file that the parameter that it is looking for is the word "file"
    Assuming that the word "file" is meaning a file on the system, I tried putting in "/etc/passwd" and got the passwd file back from the system

![[etcPasswdLFI.png]]

Looking through the file and with references on the site, I was able to determine there is a user with the username qiu on the site

With this info and with ssh open, I can try to brute force the ssh port to see if I can login as qiu

```bash
hydra -l qiu -P /usr/share/wordlists/fasttrack.txt ssh://192.168.1.29
```

![[hydraErrorMessage.png]]

After running hydra to attempt to brute force it, I found that the server does not support password authentication which means that I will need qiu's private ssh key if I want to login as him through ssh

Since I have an LFI, I can try to grab his ssh key from the machine with this

![[qiuSSHKey.png]]

This returned the full ssh key for the user qiu and I can now create the key for myself and use it to login

```bash
curl http://192.168.1.29/test.php?file=/home/qiu/.ssh/id_rsa > qiuKey
```
```bash
chmod 600 qiuKey
```
```bash
ssh -i qiuKey qiu@192.168.1.29
```

![[loginAsQiu.png]]

I was able to pull the key down to my machine and login as Qiu onto the victim machine

Now that I am on the machine as Qiu, I am able to see everything that he is able to do and look at what he has done

I ran su with no password but was not granted access

I ran sudo -l but I do not have Qiu's password since I logged in with his ssh key

I then ran history to see if he had done anything on the system with his account since we know that he is the admin for this machine
    I was then able to see that he had done a lot on the machine, which at one point included accidentally entering his password in clear text

```bash
history
```

![[qiuHistory.png]]

You can see at the top that qiu's password is "remarkablyawesomE" as well as the fact that he tried to remove his bash history but did not do it correctly

```bash
sudo -l
```

![[sudoLasQiu.png]]

Now that I have his password I was able to run sudo -l and see that he is allowed to run all commands as sudo

```bash
su
```

![[suToRoot.png]]

With this in mind I was able to run su with qiu's password and login in root instead of qiu

![[Images/rootFlag.png]]

Now that I have root I am able to get to and read the flag that was left in the root directory to show that I have completed the box