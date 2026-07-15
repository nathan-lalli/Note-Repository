---
tags:
  - tool
category: recon
---

# SMBClient

## Description

An FTP-like command-line client for browsing and pulling files from SMB/CIFS shares - the go-to tool once you know a share exists (from Nmap/SMBMap/enum4linux) and want to actually look inside it.

## Installation

```bash
sudo apt install smbclient
```

## Common Usage

*Connect to a machine over SMB*
```bash
smbclient -U <username>%<password> //<target>/<sharename>
```

*List available shares on a target*
```bash
smbclient -L //<target> -U <username>%<password>
```

*Get entire share (run inside an active smbclient session)*
```bash
mask ""
recurse on
prompt off
mget *
```

## Flags Reference

| Flag | Description |
|---|---|
| `-U <user>%<pass>` | Username/password (use `%` with no password for a null session, or `guest%` for guest) |
| `-L //<target>` | List shares instead of connecting to one |
| `-N` | No password prompt (anonymous/null session) |
| `mget *` (interactive) | Download all files in current remote directory |
| `mask ""` (interactive) | Clear the file mask so `mget *` grabs every file regardless of extension |
| `recurse on` (interactive) | Descend into subdirectories automatically |

## Example Output

```
$ smbclient -L //10.10.10.10 -N
        Sharename       Type      Comment
        ---------       ----      -------
        ADMIN$          Disk      Remote Admin
        C$              Disk      Default share
        Users           Disk
```

## Notes / Gotchas

- Try a null session (`-N` or `-U ""%""`) before assuming credentials are required - plenty of boxes leave anonymous SMB access enabled.
- `recurse on` + `mget *` without `mask ""` first will silently skip files that don't match the current mask (default is often `*.*`, which misses extensionless files).

## Related

- [SMBMap](SMBMap.md) - faster for a first look at what shares/permissions exist before diving in with smbclient
- [Enum4Linux](Enum4Linux.md)
