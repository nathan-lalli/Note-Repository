## Target

**IP Address:** 10.129.138.246
## Recon

### Port Scan

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan 10.129.138.246
```

![[nmapDownload.png]]
#### Findings

| Port  | Service  | Version       |
| ----- | -------- | ------------- |
| 22    | SSH      | OpenSSH 8.2p1 |
| 80    | HTTP     | nginx 1.18.0  |

OS: Linux

SSH
    I believe this version of SSH might be vulnerable to the new exploit, but I do not think this is the intended path

HTTP
    This takes you to a page that is for uploading and downloading files
    There is a place that you can login and register an account as well

![[defaultWebPage.png]]

