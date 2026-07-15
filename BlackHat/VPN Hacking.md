
## VPN Types

#### PPTP

* Easy to configure, fast and weakest regarding security
* MSCHAPv1 is broken since 15+ years ago
* Unencapsulated MS-CHAPv2 authentication
* What else? MS says use L2TP with IPSec or SSTP

#### L2TP/IPSec

* L2TP can be run over non-IP networks (frame relay, ATM, etc)
* L2TP encapsulates data
* The IPSec connection is used to transport the data

#### Others

* Secure Socket Tunnelling Protocol (SSTP), OpenVPN

#### VPN: Services

General Ports/Protocols
* PPTP - 1723/TCP
* L2TP - 1701/UDP
* IPSec
	* 500/UDP (IKE)/ 500/TCP (IKE over TCP sometimes)
	* IP protocol 50 (Encapsulating Security Payload - ESP) and 51
	* 4500/UDP (Nat Traversal)
* SSTP/OpenVPN/SSL VPNs
	* 443/TCP

#### VPN: IPSec Hierarchy

![Pasted image 20240806085227](../Images/Blackhat/Pasted%20image%2020240806085227.png)

#### VPN: IKE Connection Mode

* IKE Phase 1 occurs in two modes:
	* Main Mode (6 packet exchange)
	* Aggressive Mode (3 packet exchange)
* Authentication and kye exchange is a two-phase process:
	* Phase 1 - authenticates and establishes a secure channel known as IKE SA
	* Phase 2 - negotiates IPSec mode, sets up secure channel of AH/ESP traffic known as IPSec SA

#### VPN: Main Mode vs Aggressive Mode

![Pasted image 20240806085449](../Images/Blackhat/Pasted%20image%2020240806085449.png)

#### VPN: Attribute Selection

* The first mutually acceptable attribute is selected for use

![Pasted image 20240806085527](../Images/Blackhat/Pasted%20image%2020240806085527.png)

#### VPN: What to Use and What Not to Use

**What to use**
* Symmetric key > 128 bits
* Diffie-Hellman group 5 with 1536-bit primes
* Diffie-Hellman group 14 with 2048-bit primes

**What not to use**
* DES Algorithm
* 56-bit symmetric key
* Diffie-Hellman Group 1 with 768-bit primes

#### VPN: IKE-Scan

* An SA payload contains a single proposal, containing eight transforms
* Enc (2) * Hash (2) * Auth (1) * Group (2) * Lifetime (1) =2x2x1x2x1=8 transforms (basically combinations)
* Transform attributes - The 8 transforms represent the following attribute combinations (IKE default proposal):
	* Enc: DES or Triple DES
	* Hash: MD5 or SHA1
	* Auth: Pre-Shared Key
	* Group: 1(modp768) or 2 (modp1024)
	* SA Lifetime: 28800 seconds
* Enumeration - Fingerprinting, Vendor information (VID), id/group names etc.
* Be aware - the PSK may not be enough on its own!
* Authentication mechanisms (relevant to this example):
	* PSK
	* XAUTH - provides an additional level of authentication by requesting extended authentication from users, thus forcing remote users to respond with their credentials before being allowed access to the VPN (http://www.ciscopress.com)
* Useful switches:
	* --sport=\<p>
		* can be used to set UDP source port to \<p>,default=500
	* --trans=\<t>
		* use custom transform \<t> instead of the default set
	* --id=\<id>
		* is the identification value. This option is only applicable to Aggressive Mode
	* --auth=\<n>
		* set the auth method to \<n>, default=1 (PSK), XAUTH uses 65001 to 65010
	* -P \<location>
		* This option outputs the aggressive mode PSK parameters for offline cracking

#### VPN: Attack Methodology

* Identify a VPN server
	* nmap and udp-proto-scanner
* Identify valid proposals / identify handshake mode (main/aggressive)
	* ike-scan
* Identify authentication (PSK/XAUTH etc.) and ID (dependant on server config)
* Capture and crack psk if aggressive mode is identified
	* psk-crack
* Using the identified PSK, id and other credentials login to the VPN
	* Strongswan, Openswan or another VPN client
* Attack the internal network

#### VPN: Preparation

* Ensure we have a VPN client to hand (Strongswan)
* Configuration Sample
* Copy the sample config files to /etc/ipsec.conf and /etc/ipsec.secrets on your attacking host
* Crack the PSK
	* psk-crack -d \<dictionary> capture_file
* Amend the file /etc/ipsec.secrets to reflect your findings
* Connect to the VPN (ipsec up vpn)
