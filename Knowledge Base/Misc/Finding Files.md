---
tags:
  - knowledge-base
category: misc
---

# Finding Files

## Overview

Common `find` one-liners for privesc enumeration - SUID/SGID binaries and files owned by a specific user.

## Commands / Usage

#Sticky_Bit

```bash
find / -perm -4000 -type f -exec ls -al {} \; 2>/dev/null
```

#User_Files

```bash
find / -type f -user <uid> 2>/dev/null
```

## Related

- [Linux Privilege Escalation](../../HTB/Cheatsheets/Linux%20Privilege%20Escalation.md)
- [LinPEAS](../../Tool%20Box/LinPeas.md)
