## Recon

**IP Address: 10.129.237.101**

#Nmap 

```bash
sudo nmap -T4 -sV -O -sC -p- -oA targetScan 10.129.237.101
```

###   Findings:

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 80    | http   | Apache httpd 2.4.56 |

Nmap was able to find the this is a Windows server 2019 
The server is running only port 80 open and it is an Apache server

![[visualHomePage.png]]

Navigating to the IP in my browser brought me to the homepage for the site.

This server says that it is going to compile your programs for you if you send them your git repo url and then it will give you the executables and DLLs that you need.

Interesting things on the homepage
    Text box to enter git repo url

#wappalyzer

![[wappalyzerOutput.png]]

Using wappalyzer, I was able to find that the box is running the following software
    Bootstrap
    Apache
    PHP
    OpenSSL

Now that I know that the server is running PHP I might be able to get a webshell or reverse shell using PHP

## Enumeration

###    Findings:

I tried entering the word "test" into the text box and was told that it had to be a url
    For it to take my input I had to do "http://test.com" 

I tried to enter a url in the text box and got the following when I submitted it

![[enteringURL.png]]

