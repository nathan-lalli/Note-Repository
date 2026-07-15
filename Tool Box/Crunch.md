---
tags:
  - tool
category: cracking
---

# Crunch

## Description

A wordlist generator that builds every possible combination of characters within a given length range and character set - useful for building targeted wordlists when you know something about a password policy (e.g. all-numeric PINs, a known prefix).

## Installation

```bash
sudo apt install crunch
```

## Common Usage

*Create a wordlist out of given specifications*
```bash
crunch <min> <max> -o <filename>
```

*Generate all combinations of a specific character set (e.g. digits only, for a 4-digit PIN)*
```bash
crunch 4 4 0123456789 -o pins.txt
```

*Generate a wordlist matching a known pattern (`@` = lowercase, `,` = uppercase, `%` = digit, `^` = symbol)*
```bash
crunch 8 8 -t Pass%%%% -o pattern.txt
```

## Flags Reference

| Flag | Description |
|---|---|
| `<min> <max>` | Minimum and maximum string length |
| `-o <filename>` | Output file |
| `-t <pattern>` | Generate based on a pattern instead of pure brute force |
| `-c <number>` | Number of lines per output file (splits large wordlists) |
| `charset` | Optional positional arg restricting which characters are used |

## Example Output

```
$ crunch 4 4 0123456789 -o pins.txt
Crunch will now generate the following amount of data: 55000 bytes
0 MB
0 GB
0 TB
0 PB
Crunch will now generate the following number of lines: 10000
```

## Notes / Gotchas

- Output size grows fast - always check crunch's own size estimate before letting it run against a large charset/length combination, it will happily try to write gigabytes to disk.
- For real-world password cracking, a curated list (rockyou.txt, etc.) combined with rules in Hashcat/John is usually far more effective than pure brute force with Crunch - reach for Crunch specifically when the target space is small and structured (PINs, known formats).

## Related

- [Hydra](Hydra.md) - uses wordlists like the ones Crunch generates for online brute force
- [HashCat](../Knowledge%20Base/Misc/HashCat.md) - offline cracking against generated or captured hashes
