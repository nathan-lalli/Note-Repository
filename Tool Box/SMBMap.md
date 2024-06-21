## #SMBMap

SMBMap is used to map out a target SMB share
It will connect to the system as either a guest user or a credentialed user, if credentials are provided, then return the shares that it finds as well as permissions to those shares

*Non-Credentialed Scan*
```bash
smbmap -H <target>
```

*Credentialed Scan*
```bash
smbmap -u <username> -p <password> -H <target>
```

*Credentialed Scan with user and password lists*
```bash
smbmap -U <list.txt> -P <list.txt> -H <target>
```

*Specify a domain (default is WORKGROUP*
```bash
smbmap -H <target> -d <domain>
```

*Specify port (default is 445)*
```bash
smbmap -H <target> -P <port>
```