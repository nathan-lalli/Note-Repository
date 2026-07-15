---
tags:
  - knowledge-base
category: misc
---

# Mounting NFS Shares

## Overview

Steps for discovering and mounting an NFS export from a target so its contents can be browsed locally.

## Commands / Usage

*Find what shares the machine is exporting*
```bash
showmount -e 10.10.0.10
```

*Make a directory to be the mount point*
```bash
mkdir mountHere
```

*Mount the NFS share `nfsShare` to the `mountHere` directory*
```bash
sudo mount -t nfs 10.10.0.10:/nfsShare ./mountHere
```

## Notes / Gotchas

Check exports for `no_root_squash` - if set, files you create as root on your attacking machine keep root ownership on the share, which is a classic NFS privesc path if the share is writable and reachable from the target.

## Related

- [File Transfers](File%20Transfers.md)
