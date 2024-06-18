## Enumerating Network Information

### Get interfaces, ip information, and DNS information
```cmd
ipconfig /all
```

### Get arp table
```cmd
arp -a
```

### Get routing table information
```cmd
route print
```

## Enumerating Windows Protections

### Check Windows Defender Status
```powershell
Get-MpComputerStatus
````

### List AppLocker Rules
```powershell
Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections
```

### Test AppLocker Policy
```powershell
Get-AppLockerPolicy -Local | Test-AppLockerPolicy -path C:\Windows\System32\cmd.exe -User Everyone
```

## Enumerating System Information

### Enumerate Detailed Configuration Information
```cmd
systeminfo
```

### TaskList
```cmd
tasklist /svc
```

### Display All Environment Variables
```cmd
set
```

### Enumerate Patches and Updates
```cmd
wmic qfe
```
```powershell
Get-HotFix | ft -AutoSize
```

## Enumerate Installed Programs
```cmd
wmic product get name
```
```powershell
Get-WmiObject -Class Win32_Product | select Name, Version
```

### Enumerate Running Processes
```cmd
netstat -ano
```

## Enumerate User and Group Information

### Logged-In Users
```cmd
query user
```

### Current User
```cmd
echo %USERNAME%
```

### Current User Privileges
```cmd
whoami /priv

### Current User Goup Information
```cmd
whoami /groups
```

### Get All Users
```cmd
net user
```

### Get All Groups
```cmd
net localgroup
```

### Get Details About a Specific Group
```cmd
net localgroup Administrators
```

### Get Password Policy and Other Account Information
```cmd
net accounts
```
### Communication With Processess

Pipelist and AccessChk are part of the SysInternals Suite

## Listing Named Pipes
```cmd
pipelist.exe /accepteula
```
```powershell
gci \\.\pipe\
```

### Reviewing Named Pipe Permissions
```cmd
accesschk.exe /accepteula \\.\Pipe\lsass -v
```





