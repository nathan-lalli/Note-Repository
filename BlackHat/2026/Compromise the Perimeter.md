---
tags:
  - trainings
  - blackhat
category: exploitation
---
# External Exposure & Initial Access

*The perimeter - The first line of defense in any infrastructure*

**Perimeter Infrastructure:**
	Understand modern infrastructure

**Perimeter Infrastructure Weakness:**
	Risk based attack planning

**Traditional Perimeter:**
	VPNs
	Firewall
	Public web applications

**Today's Threat Landscape**

* On-premises, Cloud, and SaaS applications
	* Office 365, VDI
	* Directory synchronization
* Remote access requirements
	* Third-party vendors & suppliers
	* Remote workers


# IPSec VPNs

## VPN Types

* PPTP
* L2TP/IPSec
* Secure Socket Tunnelling Protocol (SSTP)
* OpenVPN

## IPSec Hierarchy

### Overview

IKE (Phase 1) authenticates peers and establishes a secure channel
IPSec (Phase 2) uses that channel to protect data using AH or ESP

![[Pasted image 20260801163101.png]]

### IKE Connection Mode

**IKE Phase 1 occurs in two modes:**
	Main mode (6 packet exchange)
	Aggressive Mode (3 packet exchange)

**Authentication and key exchange is a two-phase process:**
* Phase 1: Authenticates and establishes a secure channel known as IKE SA
* Phase 2: Negotiates IPSec mode, sets up secure channel of AH/ESP traffic known as IPSec SA

![[Pasted image 20260801163250.png]]

### Ciphers

**Recommended:**
* Symmetric key > 128 bits
* Diffie-Hellman group 5 with 1536 bit primes
* Diffie-Hellman group 14 with 2048 bit primes

**Not Recommended:**
* DES Algorithm
* 56 bit symmetric key
* Diffie-Hellman Group 1 with 768 bit primes

### Attribute Selection

**Each SA payload contains a single proposal with eight transforms**
	Enc(2) * Hash(2) * Auth(1) * Group(2) * Lifetime(1) = 2x2x1x2x1=8

**Representing the following attribute combination (IKE default proposal)**
* Enc: DES or Triple DES
* Hash: MD5 or SHA1
* Auth: Pre-Shared Key
* Group: 1(modp768) or 2 (modp1024)
* SA Lifetime: 28800 seconds

### Tools and Methodology

**Identification**
* NMAP
* udp-proto-scanner

**Identify Valid Proposals**
	IKE-SCAN

**Vender Information**
	IKE-SCAN

**Crack the PSK**
	psk-crack

**Connect to the Network**
	Strongswan
	Openswan

