---
tags:
  - tool
category: privesc
---

# LinPEAS

## Description

A large shell script (part of the PEASS-ng project) that enumerates a Linux system for privilege escalation vectors - SUID binaries, writable cron jobs, kernel exploits, credentials in config files, misconfigured permissions, and more - and color-codes the output by how likely each finding is to be exploitable.

## Installation

```bash
# Run directly from GitHub (no install needed on the target)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Or download once, then transfer to the target
curl -L -o linpeas.sh https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh
```

## Common Usage

*Run Linpeas straight from GitHub*
```bash
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

*Save output to a file for later review (strip color codes so the file is readable outside a terminal)*
```bash
./linpeas.sh -a | tee linpeas_output.txt
```

## Flags Reference

| Flag | Description |
|---|---|
| `-a` | All checks (includes slower/noisier ones) |
| `-s` | Superfast mode - skip the slowest checks |
| `-o <checks>` | Only run specific check categories |
| `-P` | Force pdf-friendly (no color) output |

## Example Output

```
====================================( Basic information )=====================================
OS: Linux version 5.4.0-generic
Sudo version: Sudo version 1.8.31

╔══════════╣ Executing Linux Exploit Suggester
Suggestions from the tool linux-exploit-suggester

╔══════════╣ SUID
-rwsr-xr-x 1 root root /usr/bin/find    <-- GTFOBins entry, likely exploitable
```

## Notes / Gotchas

- Piping straight from `curl` to `sh` won't leave a file on disk (useful for opsec on an engagement, but means you lose the output unless you redirect it yourself).
- The output is long - always search for the highlighted/colored ("interesting") lines first rather than reading top to bottom.
- Check [GTFOBins](https://gtfobins.github.io) against anything LinPEAS flags as an unusual SUID binary or sudo rule.

## Related

- [Linux Privilege Escalation](../HTB/Cheatsheets/Linux%20Privilege%20Escalation.md)
- [Finding Files](../Knowledge%20Base/Misc/Finding%20Files.md)
