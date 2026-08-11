---
tags:
  - trainings
  - blackhat
category: recon
---
# Intelligence Gathering

*Attackers don't seek vulnerabilities. They seek opportunities.*

### Level 1: Initial Intel Collection

* Identify target profile
* Basic attack surface map
* Establish situation awareness

### Level 2: Enhanced Reconnaissance

* Develop operational understanding of the target
* Physical locations (HQ, branches, key sites)
* Identify alliances/business relationships
* Map command structure/organizational chart

*You will always find someone unhappy at any company, this is your best target*
### Level 3: Full Spectrum Reconnaissance

* Full-Scope intelligence operation
* Integrate Level 1 + Level 2
* Deep organizational analysis
* Map network of entities (org & personnel)
* Key personnel profiling and social presence
* Analyze links and dependencies between nodes

## Structuring intelligence data

`https://osintframework.com`
`http://www.pentest-standard.org`

![[Pasted image 20260801122727.png]]

![[Pasted image 20260801124556.png]]

### Corporate Information

![[Pasted image 20260801123007.png]]

#### Physical

* Provide an understanding of the physical attack surface
* Potential physical security measures

#### Logical

* Understand the organization’s business
	* The clients, their products
	* Business relationships
#### Electronic

* Documentation and marketing

![[Pasted image 20260801123127.png]]

### Individual/Employee Information

![[Pasted image 20260801123319.png]]

## Organization fingerprinting
* Collection methods & sources.

## Reconnaissance

![[Pasted image 20260801124651.png]]

### Passive Reconnaissance

![[Pasted image 20260801124726.png]]

* Fully passive intel gathering
	* Collected indirectly through third party records

* Semi-passive intel gathering
	* All of the traffic should appear like normal network traffic

#### Search Engines

* Google Hacking

```google-dorks
inurl:github.com intitle:config intext:"/msg nickserv identify"
ext:xls intext:NAME intext:TEL intext:EMAIL intext:PASSWORD
```

* Shodan

```shodan
country:US port:23 asn:ASN123456 cisco
```

* Domain Whois Information

```whois
whois domainname.tld
```


#### LLM Assisted

```prompt
Review public code repositories related to [TARGET_DOMAIN] and identify
any exposed sensitive information such as credentials, API keys, private
keys, tokens, or configuration secrets.
```

```prompt
Generate advanced Google dorks to identify potential sensitive
information related to the target domain [Target_Domain], including
exposed credentials, API keys, private keys, cloud storage buckets,
configuration files, .env files, database dumps, CI/CD files, logs,
backups, and sensitive data on code repositories or cloud platforms.
```

#### Miscellaneous Tools

[Source Code Search Engine](https://publicwww.com)
[Markdown Web Search/Scrape](https://www.firecrawl.dev/)
[Organization Search Tool](https://theorg.com)

### Active Reconnaissance.

![[Pasted image 20260801130135.png]]

* Active intel gathering 
	* Activities that engage directly with the target, like service scans

## Network Service Discovery

### ARP - Address Resolution Protocol

* Layer 2 protocol
* Used to map IPv4 addresses to hardware (MAC) addresses

A full scan of TCP/UDP (0 - 65535) is very likely to be noticed
#### Passive

Passively listen to ARP requests in the environment

#### Active

Sending ARP requests yourself to see the interactions

#### Optimizations

* Prioritize common services
* Introduce random delays between probes
* Rely on third part information (Shodan)
* Split the scan into smaller ranges

### IPv6

**Reduction:**
	Leading 0's can be removed from the start of a segment
	All zero segments can be compressed all together (::) - only once

Localhost ::1/128 (~ 127.0.0.1)
Link-Local Unicast Addresses FE80::/10 (generated via MAC address)
Unique Local Unicast Addresses (ULA) FC00::/7
Global Unicast Addresses 2000::/3
6to4 Mapping

**Unicast** - A single IP assigned to a single network interface
**Multicast** (FF00::/8) - Multiple network interfaces (hosts)
	All nodes: FF02::1
	All routers: FF02::2
**Anycast** - Multiple network interfaces, but only a single network interface needs to respond

#### Neighbor Discovery Protocol (NDP)

**Stateless Address Auto-Configuration (SLAAC)**
	A method for hosts to auto-configure their IP addresses without the need for a central server
**Neighbor Cache**
	Information on neighbors maintained by hosts and routers
**Redirect**
	A message used by routers to inform hosts about a better next-hop address

**Router Discovery:**
	Used to locate routers on the same link using ICMPv6
	**Router Solicitation**
		A message hosts can send for immediate Router Advertisement to obtain the routing information
	**Router Advertisement**
		Routers periodically or as a response to the Router Solicitation message announcing its presence

**Neighbor Discovery:**
	**Neighbor Solicitation**
		A message hosts send for the link-layer address of a neighbor device
	**Neighbor Advertisement**
		Response of the host to the Neighbor Solicitation message

**Duplicate Address Detection (DAD):**
	Hosts use the DAD mechanism to ensure the uniqueness of the chosen IPv6 address

**Secure Neighbor Discovery (SEND):**
	A security mechanism to protect against attacks such as Spoofing of Neighbor Advertisements (NA)

**RA Guard:**
	A security mechanism to protect against rogue Router Advertisement (RA) messages

#### Man in the Middle

**Tools:**
`https://github.com/fortra/impacket/blob/master/examples/ntlmrelayx.py`
`https://github.com/dirkjanm/mitm6`

![[Pasted image 20260801154457.png]]

**ICMPv6 Redirect**

![[Pasted image 20260801154519.png]]

#### Web Proxy Auto Discovery (WPAD)

A protocol used by web browsers to auto-discover proxy configuration on the network, which allows locating the proxy server

A client requests the ‘wpad.dat’ or ‘proxy.pac’ file, which contains instructions on connecting to a proxy server, including web traffic routing rules

Once this process is completed, all web traffic will route through the attacker’s proxy server

Any browsing or application using the Windows API will have its traffic routed through the threat controlled server

![[Pasted image 20260801131811.png]]

## Operational Security

**The purpose of a red team is to EMULATE - not copy**

The red team should always utilize proper OPSEC that is commensurate with the operation and goals of the client.

> [!INFO] Defined by NIST
 Systematic and proven process by which potential adversaries can be denied information
about capabilities and intentions by identifying, controlling, and protecting generally
unclassified evidence of the planning and execution of sensitive activities.

**All tools leave a forensic trace**
	Nmap user agent `Nmap Scripting Engine`
	Impacket's secretsdump creates a file with an 8-character name on the machine

This leaves clues that may place the blue team on alert

