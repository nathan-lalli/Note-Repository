---
tags:
  - tool
category: recon
---

# SMBMap

## Description

SMBMap is used to map out a target SMB share. It will connect to the system as either a guest user or a credentialed user, if credentials are provided, then return the shares that it finds as well as permissions to those shares.

## Installation

```bash
sudo apt install smbmap
# or
pip3 install smbmap --break-system-packages
```

## Common Usage

*Non-Credentialed Scan*
```bash
smbmap -H <target>
```

*Credentialed Scan*
```bash
smbmap -u <username> -p <password> -H <target>
```

*Credentialed Scan with user and password lists*
```bash
smbmap -U <list.txt> -P <list.txt> -H <target>
```

*Specify a domain (default is WORKGROUP)*
```bash
smbmap -H <target> -d <domain>
```

*Specify port (default is 445)*
```bash
smbmap -H <target> -P <port>
```

## Flags Reference

| Flag | Description |
|---|---|
| `-H <target>` | Target host |
| `-u <user>` / `-p <pass>` | Single credential pair |
| `-U <file>` / `-P <file>` | Username/password lists (note: `-P` also doubles as the port flag depending on context - check `smbmap -h` on the version installed) |
| `-d <domain>` | Domain (default `WORKGROUP`) |
| `-r` | Recursively list directories |
| `-R <share>` | Recurse into a specific share only |
| `--download <path>` | Download a specific file |

## Example Output

```
$ smbmap -H 10.10.10.10
[+] IP: 10.10.10.10:445        Name: 10.10.10.10
    Disk                      Permissions     Comment
    ----                      -----------     -------
    ADMIN$                    NO ACCESS       Remote Admin
    C$                        NO ACCESS       Default share
    Users                     READ ONLY
```

## Notes / Gotchas

- Run this before `smbclient` - SMBMap's permission column (READ ONLY / READ, WRITE / NO ACCESS) tells you immediately which shares are worth digging into instead of connecting to each one blind.
- A WRITE permission on any share is worth checking for upload-based attacks (e.g. dropping a webshell if the share backs a website, or a malicious `.lnk`/`.scf` file to capture NTLM hashes).

## Related

- [SMBClient](SMBClient.md)
- [Enum4Linux](Enum4Linux.md)
