## #Sticky_Bit 

```bash
find / -perm -4000 -type f -exec ls -al {} \; 2>/dev/null
```

## #User_Files

```bash
find / -type f -user <uid> 2>/dev/null
```
