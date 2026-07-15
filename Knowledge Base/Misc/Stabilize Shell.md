---
tags:
  - knowledge-base
category: misc
---

# Stabilize Shell

## Overview

The standard sequence for turning a raw netcat/reverse shell into a fully interactive TTY that supports arrow keys, tab completion, Ctrl+C, and other special key binds.

## Commands / Usage

**Step 1** - spawn a pty:
```python
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

**Step 2** - background the current process with `Ctrl+Z`.

**Step 3** - fix terminal settings and foreground it again:
```bash
stty raw -echo; fg
```

**Step 4** - set the terminal type:
```bash
export TERM=xterm
```

## Related

- [TTY Shells](TTY%20Shells.md)
- [Python](../../Tool%20Box/Python.md)
