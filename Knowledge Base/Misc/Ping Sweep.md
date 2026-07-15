---
tags:
  - knowledge-base
category: misc
---

# Ping Sweep

## Overview

Using a ping sweep can be useful to find hosts on a network from a pivot machine that you cannot use Nmap or fping on. It allows you to use the basic `ping` command to send out a bunch of ICMP requests and see who replies. This won't work on hosts that have ICMP turned off, filtered, or blocked, but is a good starting point for recon on a new network.

You can run a ping sweep in multiple different ways, depending on the access you have on that machine and the OS of that host.

## Commands / Usage

### Metasploit

#MetaSploit #meterpreter

Can be run through a Metasploit/Meterpreter session using the module `post/multi/gather/ping_sweep` - either through the Metasploit command interface with an existing session by setting the network and session, or directly from within the session with the line below (just change `rhosts` to the subnet you want to scan):

```meterpreter
run post/multi/gather/ping_sweep rhosts=172.16.16.1/23
```

### Terminal

If you don't have a Meterpreter session, a ping sweep can be run with Bash, Windows CMD, or PowerShell as long as you have access to the `ping` command.

```bash
for i in {1..254} ;do (ping -c 1 172.16.5.$i | grep "bytes from" &) ;done
```

```CMD
for /L %i in (1 1 254) do ping 172.16.5.%i -n 1 -w 100 | find "Reply"
```

```PowerShell
1..254 | % {"172.16.5.$($_): $(Test-Connection -count 1 -comp 172.15.5.$($_) -quiet)"}
```

## Related

- [FPing](../../Tool%20Box/FPing.md)
- [Nmap](../../Tool%20Box/Nmap.md)
