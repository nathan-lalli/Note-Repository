---
tags:
  - box
platform: HTB
os: Linux
difficulty:
date_completed:
mitre_attack: T1190, T1078, T1505.003, T1552.001, T1548.003
status: rooted
---

## Target

**IP Address:** 10.10.11.194

## Recon

#Nmap

```bash
sudo nmap -T4 -O -sV -sC -oN targetScan $ipAddress
sudo sniper -t soccer.htb
sudo dirb http://soccer.htb /usr/share/wordlists/dirb/big.txt
```

#### Findings

| Port | Service | Version |
|---|---|---|
| 22 | SSH | OpenSSH 8.2p1 |
| 80 | HTTP | nginx 1.18.0 |
| 9091 | xmltec-xmlmail? | Version not found |

Port 9091 is used for outbound TCP/9091 and 9092 (or whatever ports are configured for HTTP and HTTPS on the client transfer application) - the ports through which a client on the internal network establishes communication with the proxy server.

Nmap vulners output for OpenSSH 8.2p1 flagged several CVEs (CVE-2020-15778, CVE-2020-12062, CVE-2021-28041, CVE-2021-41617, CVE-2020-14145, CVE-2016-20012, CVE-2021-36368) - noted but not the path taken on this box.

Dirb found a hidden directory: `soccer.htb/tiny` - a web portal for the software "Tiny File Manager" (a web-based file management system written in PHP, open source, built to be fast and small).

## Enumeration

Vulnerability found in Tiny File Manager: authenticated RCE exploit. Looked up the default creds: `admin:admin@123`.

## Exploitation

Logged in with the default credentials and could see the file structure of the site, including a folder called `uploads` - the Tiny File Manager exploit needs a place to upload to, and this is the perfect spot to try it.

Got a PHP reverse shell from pentestmonkey, uploaded it, set up a listener, and opened it in the browser to trigger it.

```bash
nc -nvlp 4444
```

Got a connection on the listener, logged in as `www-data` but without a tty. Upgraded to a proper shell:

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

Checked `/etc/passwd` and saw a non-root user on the machine named `player`. Went into their home directory and found `user.txt`, but couldn't read it due to permissions.

Uploaded LinPEAS through the upload folder and moved it to `/tmp`. Running it revealed a new hostname with a page running on it: `soc-player.soccer.htb`. Added that name to the hosts file (instead of soccer.htb) and connected. Ran dirb on this page and found a hidden directory `/check`.

On this page was a text box using a WebSocket to connect back to the server and check something, but not securely. Got a Python script that allowed blind SQL injection against the text box.

#Python #Sqlmap

```bash
python3 sqliInjection.py
sqlmap -u "http://localhost:8081/?id=1" -p "id" --dbs
sqlmap -u "http://localhost:8081/?id=1" -D soccer_db --dump
```

After running the blind SQLi against the site, found the databases present, including one called `soccer_db`. Dumped it and found a table called "Accounts" containing the `player` account with the password in cleartext: `PlayerOftheMatch2022`.

Used the username and password to SSH into the machine for a more stable shell.

## Privilege Escalation

Tried to view sudo permissions but had no sudo rights at all. After looking up different ways to check permissions, came across `doas` on the machine, which gave permission to run commands as root in a single folder: `/usr/bin/dstat`.

Found an exploit using this folder that allows creating a listener and getting a shell back as root when `dstat` runs (malicious dstat plugin).

## Flags

**Root/System:** captured - created a new listener, ran the script in that folder, and got a shell as root.

## Lessons Learned

Default credentials on niche self-hosted admin tools (Tiny File Manager here) are always worth trying before looking for a CVE - `admin:admin@123` was enough for authenticated RCE via file upload. Also a good reminder to fully enumerate `doas`/`sudo -l` equivalents - `doas` is easy to miss if you're only checking `sudo -l` out of habit, and dstat's plugin-loading behavior is a well-documented privesc vector once you can run it as root in any capacity.
