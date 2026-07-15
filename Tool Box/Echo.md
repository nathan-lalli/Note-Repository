---
tags:
  - tool
category: general
---

# Echo

## Description

Shell builtin for printing text. Comes up constantly in pentesting for quick file dumps, and for encoding/decoding base64 without needing extra tools.

## Installation

Built into every POSIX shell (bash, sh, zsh) - nothing to install.

## Common Usage

*Echo the contents of file*
```bash
echo "$(<my_file.txt)"
```

*Convert text to base64*
```bash
echo <text> | base64 -e
```

*Convert text from base64*
```bash
echo <text> | base64 -d
```

## Flags Reference

| Flag | Description |
|---|---|
| `-e` | Interpret backslash escapes (`\n`, `\t`, etc.) |
| `-n` | Suppress the trailing newline |
| `base64 -e` | Encode stdin to base64 |
| `base64 -d` | Decode base64 from stdin |

## Example Output

```
$ echo "hello" | base64
aGVsbG8K
$ echo "aGVsbG8K" | base64 -d
hello
```

## Notes / Gotchas

- `base64 -e` isn't a real flag on GNU coreutils - the default behavior of `base64` (no flag) already encodes; `-d` is what switches it to decode. Worth double-checking on the actual target since BSD/macOS `base64` has different flags than GNU.
- Useful for smuggling small payloads through filters that block certain characters - base64-encode on the attack box, decode on the target with `echo <blob> | base64 -d`.

## Related

- [Convert Hex to ASCII](../Knowledge%20Base/Misc/Convert%20Hex%20to%20ASCII.md)
- [Python](Python.md) - for encoding/decoding when `base64` itself isn't available on the target
