---
tags:
  - tool
category: pivoting
---

# Sshuttle

## Description

Sshuttle is a proxy tool that will allow us to proxy anything over SSH without having to use proxychains. The only downside is that it only does SSH and cannot do TOR or HTTPS proxying (it isn't a SOCKS proxy - it works by setting up iptables rules that transparently route traffic for a given subnet through an SSH connection).

## Installation

```bash
sudo apt install sshuttle
```

## Common Usage

*Setting up the Sshuttle proxy*
```bash
sudo sshuttle -r ubuntu@10.129.202.64 172.16.5.0/23 -v
```

The `-r` flag tells sshuttle to connect to the remote machine with a username and password/key.
The address after `-r` is the username and IP address for our pivot host.
The next address is the network that we want to route our pivot to.

Once this is run, we can now use ANY tools on our machine as if we were on that network, because this creates an entry in our iptables to redirect all traffic to that network.

## Flags Reference

| Flag | Description |
|---|---|
| `-r <user>@<host>` | Remote host to tunnel through via SSH |
| `<subnet>` | Network(s) to route through the tunnel |
| `-v` | Verbose |
| `-x <subnet>` | Exclude a subnet from being routed |
| `--dns` | Also tunnel DNS queries through the remote host |

## Example Output

```
$ sudo sshuttle -r ubuntu@10.129.202.64 172.16.5.0/23 -v
client: Connected.
firewall manager ready.
```

## Notes / Gotchas

- Needs `sudo` locally (it manipulates iptables) and a working SSH login on the pivot host - if you only have a non-interactive shell (e.g. a web shell) on the pivot, Sshuttle isn't an option; use Chisel or Socat instead.
- Because it works at the iptables/network layer rather than as an application-level SOCKS proxy, tools "just work" against the routed subnet without needing `proxychains` in front of them.

## Related

- [Chisel](Chisel.md) - works without a full SSH login, at the cost of needing proxychains for SOCKS
- [Port Forwarding](../Knowledge%20Base/Misc/Port%20Forwarding.md)
