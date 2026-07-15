---
tags:
  - tool
category: recon
---

# FPing

## Description

A ping-like tool built for scanning many hosts at once instead of one at a time - the go-to for a quick host-discovery sweep across a subnet before a full Nmap scan.

## Installation

```bash
sudo apt install fping
```

## Common Usage

*Send ICMP traffic over a network to discover all live hosts and save to file*
```bash
fping -q -a -s -g <subnet> | tee <filename>
```

## Flags Reference

| Flag | Description |
|---|---|
| `-a` | Show only hosts that are alive |
| `-q` | Quiet - don't show per-host results, only summary |
| `-s` | Print final stats |
| `-g` | Generate a target list from a subnet/range (CIDR notation) |
| `-c <n>` | Number of pings to send per host |

## Example Output

```
$ fping -a -g 10.10.10.0/24 2>/dev/null
10.10.10.1
10.10.10.15
10.10.10.22
```

## Notes / Gotchas

- Relies on ICMP - if the target network filters ICMP (common on segmented/hardened networks), live hosts won't show up here even though they're up. Follow up with a TCP-based sweep (`nmap -sn -PS<ports>`) if fping comes back empty.
- Faster than looping `ping` in a shell script because it sends all probes in parallel rather than waiting for each timeout sequentially.

## Related

- [Ping Sweep](../Knowledge%20Base/Misc/Ping%20Sweep.md)
- [Nmap](Nmap.md)
