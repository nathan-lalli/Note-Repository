
**Target: 10.129.130.226**
## Recon

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan 10.129.130.226
```

###   Findings:

![[zippingNmap.png]]

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | SSH   | OpenSSH 9.0p1 |
| 80    | HTTP   | Apache httpd 2.4.54 |

Going to the page on port 80 returns a page saying it a watch store

![[zippingHomepage.png]]

#Ffuf 

```bash
sudo ffuf -v -w /usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-5000.txt -u http://zipping.htb -H "Host: FUZZ.zipping.htb" -fs 16738
```

This returned no other domains

The page has to working links on it
    zipping.htb/shop
    zipping.htb/upload.php

The shop page does not seem to have anything interesting on it but the upload page had a way to upload files 
    The file has to be a zip file and also has to have a pdf in it

![[uploadPage.png]]

If you upload something that is not a pdf in the zip or not a real zip you get an error

![[errorUpload.png]]

Once you get a file uploaded it returns a link for you to view the pdf that you have uploaded

![[successfulUpload.png]]





