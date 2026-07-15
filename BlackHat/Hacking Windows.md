
## Enumeration

**Useful Services**

| Port/Protocol                  | Description                                                                                                                                                                                                                                                                                        |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 88 TCP and UDP                 | Network authentication                                                                                                                                                                                                                                                                             |
| 135/TCP and 135/UDP (RPC EPM ) | MS RPC endpoint mapper. (DCE locator service) Similar to Sun RPC port mapper. Services such as Outlook, Exchange, messenger service use this                                                                                                                                                       |
| 137/UDP and 138/UDP            | NetBIOS browser, naming and lookup functions. 137/UDP- Browsing requests of NetBIOS over TCP/IP for eg. name lookup requests such as file sharing, printer, SQL named pipes, WINS proxy, etc. 138/UDP - Browsing datagram responses of NetBIOS over TCP/IP e.g NetLogon service (see services.msc) |
| 139 and 445                    | File sharing (CIFS)                                                                                                                                                                                                                                                                                |
**NetBT Name Resolution

* NetBT || NetBIOS over TCP/IP || NBT
* NetBIOS over TCP/IP is the network component that performs computer name to IP address mapping, name resolution (netbt.sys or vnbt.sys)
* A legacy protocol used for backward compatibility
* Can be queried using the built in Windows utility nbtstat (nmblookup on linux)
	* Linux: nmblookup -A 192.168.3.215
	* Windows nbstat -a 192.168.3.215
* A response of 1C denotes that the host is a Domain Controller (a list of NetBIOS suffixes @ https://technet.microsoft.com/en-us/library/cc961921.aspx )

**SIDs and RIDs**

* Unique and assigned sequentially by the local system or, if a domain user, a domain controller
* Before you can enumerate users, you need to have knowledge of the domain or local computer identifier
	* S-1-5-21-2000478354-1708537768-1957994488-500
	* S: Identifies the value as a SID
	* 1: The revision level/version of the specification
	* 5: The top-level authority that issued the SID
	* 21: SECURITY_NT_NON_UNIQUE, indicates a domain id will follow
	* 2000478354-1708537768-1957994488: The domain or local computer identifier that issued the SID
	* 500: The RID

**User Enumeration: Today**

* What if we have:
	* No Null session
	* No password
	* Now what?
* User Enumeration via Kerberos:
	* Non-existent account: KDC_ERR_C_PRINCIPAL_UNKNOWN
	* A locked or disabled account: KDC_ERR_CLIENT_REVOKED
	* A valid account: KDC_ERR_PREAUTH_REQUIRED
* The prerequisite: We need to have a list of possible usernames
* Sensepost - May 2018
* Additional methods to perform unauthenticated user enumeration
* Methods (all require a pre-populated list of usernames):
	* DsrGetDcNameEx2
	* CLDAP (Connectionless LDAP) Ping
		* UDP packet (fast)
		* Response codes indicate existence of account - 23 (true) or 25 (false)
	* NetBIOS MailSlot Ping
		* Response codes indicate existence of account - 23 (true) or 25 (false)

**Level Up!**

* We have a list of valid accounts, now what?
* Password guessing:
	* Most domain accounts will be influenced by a defined password policy
	* Account lockout is usually configured
	* Unless you can view password policy details, we wouldn’t recommend testing more than 3 passwords per unique account
	* Tie in with OSINT activities - any hints, personal information or naming conventions?

### IPv6 MiTM Attack

**Neighbor Discovery Portocol (NDP)**

NDP is a protocol responsible for discovering and maintaining the neighbor device addresses. A point of flaw that leads to the occurrence of an IPv6 MiTM attack.

* Router Solicitation (RS) – A message hosts can send for immediate Router Advertisement to obtain the routing information.
* Router Advertisement (RA) – Routers periodically or as a response to the Router Solicitation message announcing its presence.
* Neighbor Solicitation (NS) – A message hosts send for the link-layer address of a neighbor device.
* Neighbor Advertisement (NA) – Response of the host to the Neighbor Solicitation message.

* Stateless Address Auto-Configuration (SLAAC): A method for hosts to auto-configure their IP addresses without the need for a central server.
* Neighbor Cache: Information on neighbors maintained by hosts and routers.
* Redirect: A message used by routers to inform hosts about a better next-hop address

* Duplicate Address Detection (DAD): Hosts use the DAD mechanism to ensure the uniqueness of the chosen IPv6 address.
* Secure Neighbor Discovery (SEND): A security mechanism to protect against attacks such as Spoofing of Neighbor Advertisements (NA).
* RA Guard: A security mechanism to protect against rogue Router Advertisement (RA) messages.

**Different Types of MiTM - IPv6**

* Neighbor Advertisement (NA) spoofing
![Pasted image 20240803181401](../Images/Blackhat/Pasted%20image%2020240803181401.png)

* Router Advertisement (RA) spoofing
![Pasted image 20240803181410](../Images/Blackhat/Pasted%20image%2020240803181410.png)

* Rouge DHCPv6 Server
![Pasted image 20240803181430](../Images/Blackhat/Pasted%20image%2020240803181430.png)

**Possible Tools**

>MiTM6
>ntlmrelayx

**Web Proxy Auto Discovery (WPAD)**

* A protocol used by web browsers to auto-discover proxy configuration on the network which allows locating the proxy server
* A client requests the 'wpad.dat' or 'proxy.pac' file which contains instructions on connecting to a proxy server including web traffic routing rules
* Once this process is completed, all web traffic will route through the attacker proxy server
* Post impersonation of DNS server
![Pasted image 20240803181812](../Images/Blackhat/Pasted%20image%2020240803181812.png)

**Mitigations**

* Disable IPv6 in the network if not required
* Disable Proxy Auto Detection to mitigate WPAD abuse
* Instead of relying on WPAD, explicitly configure the PAC URL
* Enable SMB and LDAP signing to mitigate NTLM relay

### AMSI Bypass Techniques & Post Exploitation

**Simplified AMSI Architecture**

![Pasted image 20240804094209](../Images/Blackhat/Pasted%20image%2020240804094209.png)

**AMSI_RESULT Values**

![Pasted image 20240804094237](../Images/Blackhat/Pasted%20image%2020240804094237.png)

**Limitations of AMSI Provider Checks**

* Signature-based detection, easily bypassed by:
	* String manipulation
	* Obfuscation
	* Encoding
* Hit or mis, depending on the AV vendor's signature
* Invoke-Obfuscation.ps1
* https://amsi.fail

**Signature Evasion - AmsiTrigger**

* PowerShell find code signature with AmsiTrigger
* Manually adjust the code to bypass signature-based threat detection mechanisms

![Pasted image 20240804094446](../Images/Blackhat/Pasted%20image%2020240804094446.png)

**Opportunities to Disable AMSI**

* AMSI is loaded into the address space of the attacker-created process
* Each component can be tampered with to break the chain

![Pasted image 20240804094550](../Images/Blackhat/Pasted%20image%2020240804094550.png)

**Tampering with Consumers: PowerShell**

> Tampering differs based on consumer application

* amsiInitFailed
* amsiContext

![Pasted image 20240804094644](../Images/Blackhat/Pasted%20image%2020240804094644.png)

* Force set amsiInitFailed to True

![Pasted image 20240804094710](../Images/Blackhat/Pasted%20image%2020240804094710.png)

**Tampering with amsi.dll**

* Code Path Functions
	* AmsiOpenSession()
	* AmsiScanBuffer()
* Alternate ways to locate functions: Function Offsets & Egg Hunter
* Drawback: Detected by scanners looking for amsi.dll code patches at runtime

![Pasted image 20240804094829](../Images/Blackhat/Pasted%20image%2020240804094829.png)

**Patching AmsiOpenSession**

* Craft your own patch

![Pasted image 20240804094859](../Images/Blackhat/Pasted%20image%2020240804094859.png)

**Patching AmsiOpenSession**

* Find the offset of address to be patched -> convert from hex to decimal

![Pasted image 20240804094945](../Images/Blackhat/Pasted%20image%2020240804094945.png)

![Pasted image 20240804094958](../Images/Blackhat/Pasted%20image%2020240804094958.png)

### Windows Authentication/Pass the Hash

![Pasted image 20240804105530](../Images/Blackhat/Pasted%20image%2020240804105530.png)

>Windows systems allow authentication using hashes - we don’t need the plaintext password!

* PowerShell:
	* Invoke-TheHash
* MimiKatz:
	* sekurlsa::pth /user:kevin /domain:plum.local /ntlm:80de0b25034cbe9a63df9d8dfcdaadf3 /run:powershell.exe
* Rubeus:
	* Rubeus.exe asktgt /domain:plum.local /rc4:80de0b25034cbe9a63df9d8dfcdaadf3 /ptt

* However, if we have administrative access to the host we can make a registry change and then it’s business as usual: 
* “HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVe rsion\Policies\System” 
	* Type: DWORD (32-bit) 
	* Name: LocalAccountTokenFilterPolicy Data: 1

**Extra Protection**

* Restricted Admin Mode: https://blogs.technet.microsoft.com/kfalde/2013/08/14/restricted-admin-mode-for-rdp-inwindows-8-1-2012-r2/
* Utilize the Protected Users group: https://technet.microsoft.com/enus/library/dn466518(v=ws.11).aspx
	* Members can’t authenticate using NTLM, Digest Auth or CredSSP
	* Passwords are not cached
	* Kerberos AES support only (DES and RC4 excluded)
	* Account cannot be delegated
	* Reduced TGT lifetime (4 hours)
* Credential Guard has been introduced in Windows 10 Enterprise & Server 2016 https://technet.microsoft.com/en-us/itpro/windows/keep-secure/credential-guard

**Credential Guard**

* On by default on Windows 11 version 22H2 Enterprise/Education
* Lsaiso.exe runs in Hyper-V virtual machines
* Advanced local procedure calls (ALPCs)
* Lsaiso.exe remains offline
* Lsass.exe handles the Send/receive
* While cryptographic operations are handled by Lsaiso

**Local Administrator Password Solution (LAPS)**

* Periodic rotation of local admin passwords as per policy and storage in AD
* Password stored in mc-Mcs-AdmPwd with expiry as ms-MCS-AdmPwdExpirationTime
* Controlled by C:\\Program Files\\LAPS\\CSE\\AdmPwd.dll
* PowerShell commands are available: Get-Command \*AdmPwd\*
* Who can read the passwords
	* Find-AdmPwdExtendedRights
* Extract Password
	* Get-ADObject 'CN=ms-mcsadmpwd,CN=schema,CN=configuration,DC=aih,dc=local'

**LAPS Exploitation**

* Extract Password via PowerView in case ADMPwd.ps not available
	* Get-DomainObject -Identity \<computer\> -Properties ms-mcs-admpwd
* Set Manual Password
	* Set-DomainObject -Identity \<computer\> -Set @{'ms-mcs-admpwd'=NewPassword'}
* Set large expiry date on ms0Mcs-AdmPwdExpirationTime
* No integrity check on admpwd.ps.dll (ergo replaceable by admin)
	* C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\Modules\\AdmPwd.PS\\Admpwd.ps.dll

### Active Directory

**What data is useful?**

* Domain password and account lockout policies
* Details on our account and the permissions these have locally and within the domain
* Details on obvious customized admin enabled user accounts
* Customized groups including nesting and inheritance
* Active Directory ACLs and delegated objects
* Password management tools/utilities
* Encrypted passwords in policies
* Service accounts with SPNs
* Sensitive data in scripts or config files
* Domain trusts and types

**Active Directory Recon**

>ADRecon - https://github.com/adrecon/ADRecon

* Uses Microsoft Remote Server Administration Tools (RSAT) else falls back to LDAP
* Enumerates users, groups, computers, OUs, various permission assignments and generates useful statistics
	* From a non-domain joined host
		* ADRecon.ps1 -DomainController 192.168.3.215 -Credential plum\\bob

**Active Directory Delegation**

>“…Active Directory delegation is critical part of many organizations' IT infrastructure. By delegating administration, you can grant users or groups only the permissions they need without adding users to privileged groups (e.g., Domain Admins, Account Operators)…”*

* What can be delegated?
	* Read user information
	* Create/manage users
	* Create/manage groups
	* Modify group memberships
	* Reset passwords
	* and much more through custom assignments
* Custom tasks/permission assignments
	* Extremely fine grained, allowing for specific delegation requirements

**Active Directory Delegation: Why?**

>Why should we take an interest in how an environment has been delegated?

* Clued up organizations are minimizing the memberships of powerful groups such as domain admins/enterprise admins. Instead (as designed) they are assigning various delegation permissions such as ‘reset password’ to custom groups. If we compromise a user from one of these groups, we inherit these potentially powerful permissions.
* We’re looking for mistakes, logical errors or even abuse ‘by design’ implementations.
* Redundant, legacy and weak configurations may be in place and all but forgotten.

**Active Directory Delegation: Audit**

>Tools

* Windows Remote Administration Toolkit https://www.microsoft.com/en-gb/download/details.aspx?id=45520
* ADACL Scanner https://github.com/canix1/ADACLScanner
* PowerView https://github.com/PowerShellMafia/PowerSploit/tree/dev/Recon
* Windows attacking host with Admin Privileges (PowerShell)
* NotSoSecure’s own custom powershell script https://github.com/NotSoSecure/AD_delegation_hunting

* Import-Module ActiveDirectory: With a non-domain account / standalone system the AD drive connection will fail (errors will slightly differ depending on situation)

![Pasted image 20240804111443](../Images/Blackhat/Pasted%20image%2020240804111443.png)

* Disable loading of the AD drive: $Env:ADPS_LoadDefaultDrive = 0
* Run a query using a domain account
	* Get-ADDomain -Server 192.168.3.215 -Credential "plum\\bob"

![Pasted image 20240804111544](../Images/Blackhat/Pasted%20image%2020240804111544.png)

**AdminSDHolder and SDProp**

* AdminsSDHolder is a container that exists in each AD domain
* A Protected group is a group that is identified as privileged. This group and all its members should be protected from unintentional modifications.
* When a group is marked as protected; AD will ensure that the owner, the ACLs, and the inheritance applied on this group are the same as those applied on AdminSDHolder container

**AdminSDHolder: Who/What?**

* Get-ADGroup -LDAPFilter "(admincount=1)" -Server 192.168.3.215 - Credential "plum\bob" | Select SamAccountName

![Pasted image 20240804115430](../Images/Blackhat/Pasted%20image%2020240804115430.png)

* Get-ADUser -LDAPFilter "(admincount=1)" -Server 192.168.3.215 - Credential "plum\bob" | Select SamAccountName

![Pasted image 20240804115442](../Images/Blackhat/Pasted%20image%2020240804115442.png)

