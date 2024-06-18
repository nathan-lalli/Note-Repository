## Useful Tools
* [Seatbelt](https://github.com/GhostPack/Seatbelt)
* [winPEAS](https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite/tree/master/winPEAS)
* [PowerUp](https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1)
* [SharpUp](https://github.com/GhostPack/SharpUp)
* [JAWS](https://github.com/411Hall/JAWS)
* [SessionGopher](https://github.com/Arvanaghi/SessionGopher)
* [Watson](https://github.com/rasta-mouse/Watson)
* [LaZagne](https://github.com/AlessandroZ/LaZagne)
* [Windows Exploit Suggester - Next Generation](https://github.com/bitsadmin/wesng)
* [Sysinternals Suite](https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite)

[Compiled Binaries of Seatbelt and SharpUp](https://github.com/r3motecontrol/Ghostpack-CompiledBinaries)\
[Standalone LaZagne](https://github.com/AlessandroZ/LaZagne/releases/)

> Note: Depending on how we gain access to a system we may not have many directories that are writeable by our user to upload tools. It is always a safe bet to upload tools to C:\Windows\Temp because the BUILTIN\Users group has write access. 

## Getting a Lay of the Land

### Enumerating Network Information

#### Get interfaces, ip information, and DNS information
```cmd
ipconfig /all
```

#### Get arp table
```cmd
arp -a
```

#### Get routing table information
```cmd
route print
```

### Enumerating Windows Protections

#### Check Windows Defender Status
```powershell
Get-MpComputerStatus
````

#### List AppLocker Rules
```powershell
Get-AppLockerPolicy -Effective | select -ExpandProperty RuleCollections
```

#### Test AppLocker Policy
```powershell
Get-AppLockerPolicy -Local | Test-AppLockerPolicy -path C:\Windows\System32\cmd.exe -User Everyone
```

### Enumerating System Information

#### Enumerate Detailed Configuration Information
```cmd
systeminfo
```

#### TaskList
```cmd
tasklist /svc
```

#### Display All Environment Variables
```cmd
set
```

#### Enumerate Patches and Updates
```cmd
wmic qfe
```
```powershell
Get-HotFix | ft -AutoSize
```

### Enumerate Installed Programs
```cmd
wmic product get name
```
```powershell
Get-WmiObject -Class Win32_Product | select Name, Version
```

#### Enumerate Running Processes
```cmd
netstat -ano
```

### Enumerate User and Group Information

#### Logged-In Users
```cmd
query user
```

#### Current User
```cmd
echo %USERNAME%
```

#### Current User Privileges
```cmd
whoami /priv
```

#### Current User Goup Information
```cmd
whoami /groups
```

#### Get All Users
```cmd
net user
```

#### Get All Groups
```cmd
net localgroup
```

#### Get Details About a Specific Group
```cmd
net localgroup Administrators
```

#### Get Password Policy and Other Account Information
```cmd
net accounts
```
### Communication With Processess

Pipelist and AccessChk are part of the SysInternals Suite

#### Listing Named Pipes
```cmd
pipelist.exe /accepteula
```
```powershell
gci \\.\pipe\
```

#### Reviewing Named Pipe Permissions
```cmd
accesschk.exe -accepteula -w \pipe\lsass -v
```





