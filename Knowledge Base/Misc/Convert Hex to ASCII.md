---
tags:
  - knowledge-base
category: misc
---

# Convert Hex to ASCII

## Overview

Quick one-liner for turning a hex dump/file into readable ASCII.

## Commands / Usage

```bash
echo "$(<hexFile)" | xxd -r -p > hexfileDecoded
```

## Related

- [HashCat](HashCat.md)
