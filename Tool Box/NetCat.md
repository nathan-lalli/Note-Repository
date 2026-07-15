---
tags:
  - tool
category: general
---

# NetCat

## Description

The "TCP/IP Swiss Army knife" - reads and writes raw data over network connections. Used for banner grabbing, catching reverse shells, simple file transfers, and ad-hoc port checks when a more specialized tool isn't warranted.

NetCat can be used to connect to a host or target system and get information back from that system. This can be used to get data and any other metadata that may be stored in the header/banner of that port/service.

## Installation

```bash
sudo apt install netcat-traditional   # or ncat, part of the nmap suite
```

## Common Usage

*Connect to an IP address on the given port and be verbose*
```bash
nc -nvv <target> <port>
```

*Connect to an IP address on the given port from a specific port and be verbose*
```bash
nc -nvv -p <source-port> <target> <port>
```

*Listen for an incoming connection (e.g. catching a reverse shell)*
```bash
nc -lvnp <port>
```

*Transfer a file (receiver listens, sender connects)*
```bash
# receiver
nc -lvnp <port> > received_file
# sender
nc <receiver_ip> <port> < file_to_send
```

## Flags Reference

| Flag | Description |
|---|---|
| `-l` | Listen mode |
| `-v` / `-vv` | Verbose / more verbose |
| `-n` | Don't resolve DNS |
| `-p <port>` | Source port |
| `-e <program>` | Execute a program on connection (not present on all builds, security-restricted) |

## Example Output

```
$ nc -nvv 10.10.10.10 80
(UNKNOWN) [10.10.10.10] 80 (http) open
HEAD / HTTP/1.0

HTTP/1.1 200 OK
Server: Apache/2.4.41 (Ubuntu)
```

## Notes / Gotchas

- Many modern netcat builds ship without `-e` for security reasons - if you need "netcat with -e" for a one-liner reverse shell, use `ncat` (nmap's netcat) or a `mkfifo`-based bash reverse shell instead.
- Always have a listener (`nc -lvnp <port>`) running before triggering the reverse shell on the target, not after.

## Related

- [Socat](Socat.md) - more flexible relay/tunneling alternative
- [Stabilize Shell](../Knowledge%20Base/Misc/Stabilize%20Shell.md)
- [File Transfers](../Knowledge%20Base/Misc/File%20Transfers.md)
