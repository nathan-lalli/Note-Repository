---
tags:
  - tool
category: general
---

# Python

## Description

General-purpose scripting language, used constantly in pentesting for quick one-liners: spinning up an ad-hoc web server for file transfers, upgrading a raw shell to a pty, or writing small exploit/parsing scripts.

## Installation

```bash
# Usually already installed on Kali/Parrot/most Linux distros
python3 --version
```

## Common Usage

*Host a python server in your current directory*
```bash
python3 -m http.server <port>
```

*Spawn a proper pty from a raw reverse shell (stabilization, step 1)*
```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

## Flags Reference

| Flag | Description |
|---|---|
| `-m http.server <port>` | Quick HTTP file server in the current directory |
| `-c '<code>'` | Run a one-liner without a script file |
| `-i` | Start interactive interpreter after running a script |

## Example Output

```
$ python3 -m http.server 8000
Serving HTTP on 0.0.0.0 port 8000 (http://0.0.0.0:8000/) ...
10.10.10.10 - - [01/Jan/2026 12:00:00] "GET /linpeas.sh HTTP/1.1" 200 -
```

## Notes / Gotchas

- `python -m http.server` is Python 3 syntax; on older targets with only Python 2, it's `python -m SimpleHTTPServer <port>`.
- After `pty.spawn`, the shell is still not fully stable (no job control, Ctrl+C kills it) - follow up with `export TERM=xterm`, `stty raw -echo`, and backgrounding/foregrounding per your usual shell stabilization routine.

## Related

- [Stabilize Shell](../Knowledge%20Base/Misc/Stabilize%20Shell.md)
- [File Transfers](../Knowledge%20Base/Misc/File%20Transfers.md)
- [TTY Shells](../Knowledge%20Base/Misc/TTY%20Shells.md)
