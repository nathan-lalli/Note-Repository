
*Find what shares the machine is exporting*
```bash
showmount -e 10.10.0.10
```

*Make a directory to be the mount point*
```bash
mkdir mountHere
```

*Mount the NFS Share nfsShare to mountHere directory*
```bash
sudo mount -t nfs 10.10.0.10:/nfsShare ./mountHere
```
