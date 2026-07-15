---
tags:
  - tool
category: pivoting
---

# Chisel

## Description

A fast TCP/UDP tunnel over HTTP, written in Go. Used to pivot into networks a target machine can reach but you can't - run a server on your attack box, a client on the compromised host, and route traffic (including SOCKS proxies) through the tunnel.

## Installation

```bash
# Attack box (Kali/Parrot usually has it preinstalled)
sudo apt install chisel

# Or grab a static binary for the target if it's not installed there
# https://github.com/jpillora/chisel/releases
```

## Common Usage

*Start a reverse tunnel server on the attack box, exposing a SOCKS5 proxy back to itself*
```bash
chisel server -p 5555 --reverse
```

*Connect from the target and register a SOCKS proxy back through the tunnel*
```bash
chisel client <server ip>:5555 R:socks
```

*Forward a single port instead of a full SOCKS proxy (attack box listens on `local_port`, forwards to `target:remote_port` as seen by the client)*
```bash
chisel client <server ip>:5555 R:<local_port>:<target>:<remote_port>
```

## Flags Reference

| Flag | Description |
|---|---|
| `server -p <port>` | Port the chisel server listens on |
| `server --reverse` | Allow clients to create reverse-direction tunnels (required for `R:` remotes) |
| `client <addr>:<port>` | Connect to a chisel server |
| `R:socks` | Register a reverse SOCKS5 proxy through the tunnel |
| `R:<local>:<host>:<remote>` | Reverse port forward |
| `-v` | Verbose logging |

## Example Output

```
$ chisel server -p 5555 --reverse
2024/01/01 12:00:00 server: Reverse tunnelling enabled
2024/01/01 12:00:00 server: Fingerprint AbC123...
2024/01/01 12:00:00 server: Listening on http://0.0.0.0:5555

$ chisel client 10.10.14.5:5555 R:socks
2024/01/01 12:00:05 client: Connecting to ws://10.10.14.5:5555
2024/01/01 12:00:05 client: Connected (Latency 12ms)
```

## Notes / Gotchas

- Pair the SOCKS proxy with `proxychains` on the attack box to route arbitrary tools (nmap, crackmapexec, etc.) through the pivot.
- `--reverse` on the server is easy to forget - without it, reverse remotes (`R:`) are rejected.
- Traffic is HTTP-based, which helps it slide past some egress filtering that blocks raw TCP.

## Related

- [Socat](Socat.md) - similar relay/pivoting use case without needing a dedicated client/server pair
- [Sshuttle](Sshuttle.md) - simpler alternative when you already have SSH access
- [Port Forwarding](../Knowledge%20Base/Misc/Port%20Forwarding.md)
