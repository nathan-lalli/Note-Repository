---
tags:
  - tool
category: recon
---

# Enum4Linux

## Description

Enumerates information from Windows and Samba systems over SMB (ports 139/445) - users, groups, shares, password policy, OS version - similar in spirit to the old Windows `enum` tools, wrapped around `smbclient`/`rpcclient`/`net`.

## Installation

```bash
sudo apt install enum4linux
# or the actively-maintained rewrite:
pip3 install enum4linux-ng --break-system-packages
```

## Common Usage

*Enumerate the system information on a system over port 139 and 445*
```bash
enum4linux <target>
```

*Run everything (users, groups, shares, password policy, OS info) in one pass*
```bash
enum4linux -a <target>
```

## Flags Reference

| Flag | Description |
|---|---|
| `-a` | Do all simple enumeration (users, shares, groups, policy, OS info) |
| `-U` | Get userlist |
| `-S` | Get sharelist |
| `-P` | Get password policy information |
| `-G` | Get group and member list |
| `-o` | Get OS information |

## Example Output

```
$ enum4linux -a 10.10.10.10
 ==================================
|    Target Information           |
 ==================================
Target ........... 10.10.10.10
RID Range ........ 500-550,1000-1050
...
 ==================================
|    Users on 10.10.10.10         |
 ==================================
index: 0x1 RID: 0x1f4 acb: 0x00000010 Account: Administrator
```

## Notes / Gotchas

- Null-session enumeration (no credentials) often works against older/misconfigured Windows and Samba boxes but is increasingly locked down by default on modern Windows - if it comes back empty, don't assume the box has nothing to enumerate, try with a low-priv credential instead.
- `enum4linux-ng` (Python rewrite) has better output formatting and JSON export, worth using over the original Perl script when it's available.

## Related

- [SMBClient](SMBClient.md)
- [SMBMap](SMBMap.md)
- [Footprinting](../HTB/Cheatsheets/Footprinting.md)
