---
tags:
  - tool
category: recon
---

# Nmap

## Description

The standard network scanner for host discovery, port scanning, service/version detection, and OS fingerprinting. Almost always the first tool run against a new target.

## Installation

```bash
sudo apt install nmap
```

## Common Usage

*My default scan: This will save output in all formats so make sure you know where you are running it from*
```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan <target>
```

*Scan a network for targets and save the output to a normal file*
```bash
sudo nmap -oN <filename> -sn <subnet>
```

*Scan a target system with safe scripts and save the output to a normal file and XML*
```bash
sudo nmap -T4 -O -sV -sC -oN <filename> -oX <filename>.xml <target>
```

*Enumerate SMB share on a target system*
```bash
sudo nmap --script smb-enum-shares.nse -p139,445 <target>
```

*Tells you the reason a port is open|filtered|closed*
```bash
sudo nmap --reason <target>
```

*Add verbosity*
```bash
sudo nmap -v <target>
```
*Can also press 'v' during scan to add it as well*

## Flags Reference

| Flag | Description |
|---|---|
| `-sS` | TCP SYN scan (default, needs root) |
| `-sV` | Service/version detection |
| `-sC` | Run default NSE script set |
| `-O` | OS fingerprinting |
| `-p-` | Scan all 65535 ports |
| `-T4` | Timing template (0=slowest/stealthiest, 5=fastest) |
| `-oA <file>` | Output in all formats (normal, XML, grepable) |
| `-sn` | Ping scan only, no port scan (host discovery) |
| `--script <name>` | Run a specific NSE script |
| `-v` / `-vv` | Verbosity |
| `--reason` | Show why a port was marked open/filtered/closed |

## Example Output

```
PORT     STATE SERVICE     VERSION
22/tcp   open  ssh         OpenSSH 8.2p1 Ubuntu
80/tcp   open  http        Apache httpd 2.4.41
445/tcp  open  netbios-ssn Samba smbd 4.6.2
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

## Notes / Gotchas

- `-p-` with `-sC -sV -O` against all 65535 ports is slow - for a first pass, a quick `-p-` port-only scan followed by a targeted `-sC -sV` against just the open ports found is often faster than doing it all in one pass.
- `-O` (OS detection) needs at least one open and one closed port to give a confident guess - it'll be unreliable against heavily filtered hosts.
- Root/sudo is required for SYN scans (`-sS`, the default) and `-O` - without it, Nmap falls back to a slower TCP connect scan.

## Related

- [Network Enumeration with Nmap](../HTB/Cheatsheets/Network%20Enumeration%20with%20Nmap.md)
- [Footprinting](../HTB/Cheatsheets/Footprinting.md)
- [FPing](FPing.md) - faster host-discovery sweep before a full Nmap scan
