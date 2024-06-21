##  #SMBClient

*Connect to a machine over SMB*
```bash
smbclient -U <username>%<password> //<target>/<sharename>
```

*Get Entire Share*
```bash
mask ""
recurse on
prompt off
mget *
```
