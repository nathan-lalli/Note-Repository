---
tags:
  - box
platform: HTB
os: Linux
difficulty:
date_completed:
mitre_attack:
status: in-progress
---

## Target

**IP Address:** 10.129.203.128

## Recon

#Nmap

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan 10.129.203.128
```

#### Findings

| Port | Service | Version |
|---|---|---|
| 22 | ssh | OpenSSH 8.2p1 |
| 50051 | unknown | unknown |

## Enumeration

<!-- Not reached yet in these notes - port 50051 is the default gRPC port, worth checking for a .proto definition or reflection API before anything else -->

## Exploitation

<!-- Not reached yet in these notes -->

## Privilege Escalation

<!-- Not reached yet in these notes -->

## Flags

**User/Root:** not yet captured in these notes

## Lessons Learned

<!-- Fill in once further along -->
