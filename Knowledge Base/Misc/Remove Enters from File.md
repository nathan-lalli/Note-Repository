---
tags:
  - knowledge-base
category: misc
---

# Remove Enters from File

## Overview

One-liner for stripping newlines out of a file - useful for turning multi-line output into a single-line value (e.g. before feeding it somewhere that expects one token).

## Commands / Usage

```bash
tr -d '\n' < yourfile.txt
```
