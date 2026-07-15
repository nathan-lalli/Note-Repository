---
tags:
  - knowledge-base
category: misc
---

# TTY Shells

## Overview

Quick one-liners for spawning a pty from a raw shell - the first step in shell stabilization.

## Commands / Usage

#Python

```python
python -c 'import pty; pty.spawn("/bin/bash")'
```
```python
python3 -c 'import pty; pty.spawn("/bin/bash")'
```

```python
python -c 'import os; os.system("/bin/bash")'
```
```python
python3 -c 'import os; os.system("/bin/bash")'
```

## Related

- [Stabilize Shell](Stabilize%20Shell.md)
- [Python](../../Tool%20Box/Python.md)
