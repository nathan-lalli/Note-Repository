
## IPv4 Discovery & Scanning

### ARP Basics

* Address Resolution Protocol
* A layer 2 protocol
* ARP is a protocol used to map IPv4 addressess to hardware MAC addressess

### Port Scanning

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

## IPv6

### Basics

* 128-bit (x4 the size of IPv4)
* 8 x 16-bit segments delimited by colons : when in hex format
* Reduction
	* Leading 0's can be removed from the start of a segment
	* All zeros segment can be compressed all together (::) - only once!
* Unicast - a single IP assigned to a single network interface
* Multicast (FF00::/8) - multiple network interfaces (hosts)
	* All nodes: FF02::1
	* All routers: FF02::2
* Anycast (taken from Global Unicast pool and therefore impossible to distinguish based on format alone) - multiple network interfaces (hosts) but only a single network interface (host) needs to respond

### Useful to Know

* Localhost ::1/128
* Link-Local Unicast Addresse FE80::/10
* Unique Local Unicast Addresses (ULA) FC00:/7
* Global Unicast Addresses 2000::/3
* 6to4: Mapping ipv4 over ipv6
	* 2002:V4ADDR::V4ADDR (Windows)
	* 2002:V4ADDR::1 (Linux)

### IPv6 Neighbor Discovery Protocol (NDP)

#### Router Discovery

* Used to locate routers on the same link using ICMPv6
	* Router Solicitation (type 133) is sent from node to all router's multicast group
	* Router Advertisement (type 134) is sent from routers to all node's multicast group
* Prefix information (type 3) can be included within the Router Advertisement, which lists IPv6 prefixes (subnets) that are reachable

#### Address Resolution

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

### SNMP: Simple Network Management Protocol

* Listens on UDP port 161 by default
* Versions 1, 2c, 3 exist
* Used to manage and collect information from network devices
* SNMP queries objects for information
* These objects are identified via Object Identifiers (OIDs)