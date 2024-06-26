# Windows Privilege Escalation

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

```cmd
netstat -ano | findstr 6064
```

```powershell
Get-Process -Id 1234
```

```powershell
Get-Service | ? {$_.DisplayName -like 'Druva*'}
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

> Pipelist and AccessChk are part of the SysInternals Suite

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

## Windows User Privileges

### Rights and Privileges in Windows

| Group | Description |
| ----- | ----------- |
| Default Administrators | Domain Admins and Enterprise Admins are "super" groups. |
| Server Operators | Members can modify services, access SMB shares, and backup files. |
| Backup Operators | Members are allowed to log onto DCs locally and should be considered Domain Admins. They can make shadow copies of the SAM/NTDS database, read the registry remotely, and access the file system on the DC via SMB. This group is sometimes added to the local Backup Operators group on non-DCs. |
| Print Operators | Members can log on to DCs locally and "trick" Windows into loading a malicious driver. |
| Hyper-V Administrators | If there are virtual DCs, any virtualization admins, such as members of Hyper-V Administrators, should be considered Domain Admins. |
| Account Operators | Members can modify non-protected accounts and groups in the domain. |
| Remote Desktop Users | Members are not given any useful permissions by default but are often granted additional rights such as Allow Login Through Remote Desktop Services and can move laterally using the RDP protocol. |
| Remote Management Users | Members can log on to DCs with PSRemoting (This group is sometimes added to the local remote management group on non-DCs). |
| Group Policy Creator Owners | Members can create new GPOs but would need to be delegated additional permissions to link GPOs to a container such as a domain or OU. |
| Schema Admins | Members can modify the Active Directory schema structure and backdoor any to-be-created Group/GPO by adding a compromised account to the default object ACL. |
| DNS Admins | Members can load a DLL on a DC, but do not have the necessary permissions to restart the DNS server. They can load a malicious DLL and wait for a reboot as a persistence mechanism. Loading a DLL will often result in the service crashing. A more reliable way to exploit this group is to create a WPAD record. |

### User Rights Assignment

| Setting Constant | Setting Name | Standard | Description |
| ---------------- | ------------ | -------- | ----------- |
| SeNetworkLogonRight | Access this computer from the network | Administrators, Authenticated Users | Determines which users can connect to the device from the network. This is required by network protocols such as SMB, NetBIOS, CIFS, and COM+. |
| SeRemoteInteractiveLogonRight | Allow log on through Remote Desktop Services| Administrators, Remote Desktop Users | This policy setting determines which users or groups can access the login screen of a remote device through a Remote Desktop Services connection. A user can establish a Remote Desktop Services connection to a particular server but not be able to log on to the console of that same server. |
| SeBackupPrivilege | Back up files and directories | Administrators | This user right determines which users can bypass file and directory, registry, and other persistent object permissions for the purposes of backing up the system. |
| SeSecurityPrivilege | Manage auditing and security log | Administrators | This policy setting determines which users can specify object access audit options for individual resources such as files, Active Directory objects, and registry keys. These objects specify their system access control lists (SACL). A user assigned this user right can also view and clear the Security log in Event Viewer. |
| SeTakeOwnershipPrivilege | Take ownership of files or other objects | Administrators | This policy setting determines which users can take ownership of any securable object in the device, including Active Directory objects, NTFS files and folders, printers, registry keys, services, processes, and threads. |
| SeDebugPrivilege | Debug programs | Administrators | This policy setting determines which users can attach to or open any process, even a process they do not own. Developers who are debugging their applications do not need this user right. Developers who are debugging new system components need this user right. This user right provides access to sensitive and critical operating system components. |
| SeImpersonatePrivilege | Impersonate a client after authentication | Administrators, Local Service, Network Service, Service | This policy setting determines which programs are allowed to impersonate a user or another specified account and act on behalf of the user. |
| SeLoadDriverPrivilege | Load and unload device drivers | Administrators | This policy setting determines which users can dynamically load and unload device drivers. This user right is not required if a signed driver for the new hardware already exists in the driver.cab file on the device. Device drivers run as highly privileged code. |
| SeRestorePrivilege | Restore files and directories | Administrators | This security setting determines which users can bypass file, directory, registry, and other persistent object permissions when they restore backed up files and directories. It determines which users can set valid security principals as the owner of an object. |

### SeImpersonate and SeAssignPrimary Token

> In Windows, every process has a token that has information about the account that is running it. These tokens are not considered secure resources, as they are just locations within memory that could be brute-forced by users that cannot read memory. To utilize the token, the SeImpersonate privilege is needed.

#### Possible SeImpersonate Exploits

* JuicyPotato
* PrintSpoofer
* RoguePotato

## User Account Access Control

| Group Policy Setting                                                                                                                                                                                                                                                                                                                                                           | Registry Key                | Default Setting                                              |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------- | ------------------------------------------------------------ |
| [User Account Control: Admin Approval Mode for the built-in Administrator account](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-admin-approval-mode-for-the-built-in-administrator-account)                                                     | FilterAdministratorToken    | Disabled                                                     |
| [User Account Control: Allow UIAccess applications to prompt for elevation without using the secure desktop](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-allow-uiaccess-applications-to-prompt-for-elevation-without-using-the-secure-desktop) | EnableUIADesktopToggle      | Disabled                                                     |
| [User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-behavior-of-the-elevation-prompt-for-administrators-in-admin-approval-mode)                     | ConsentPromptBehaviorAdmin  | Prompt for consent for non-Windows binaries                  |
| [User Account Control: Behavior of the elevation prompt for standard users](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-behavior-of-the-elevation-prompt-for-standard-users)                                                                   | ConsentPromptBehaviorUser   | Prompt for credentials on the secure desktop                 |
| [User Account Control: Detect application installations and prompt for elevation](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-detect-application-installations-and-prompt-for-elevation)                                                       | EnableInstallerDetection    | Enabled (default for home) Disabled (default for enterprise) |
| [User Account Control: Only elevate executables that are signed and validated](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-only-elevate-executables-that-are-signed-and-validated)                                                             | ValidateAdminCodeSignatures | Disabled                                                     |
| [User Account Control: Only elevate UIAccess applications that are installed in secure locations](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-only-elevate-uiaccess-applications-that-are-installed-in-secure-locations)                       | EnableSecureUIAPaths        | Enabled                                                      |
| [User Account Control: Run all administrators in Admin Approval Mode](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-run-all-administrators-in-admin-approval-mode)                                                                               | EnableLUA                   | Enabled                                                      |
| [User Account Control: Switch to the secure desktop when prompting for elevation](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-switch-to-the-secure-desktop-when-prompting-for-elevation)                                                       | PromptOnSecureDesktop       | Enabled                                                      |
| [User Account Control: Virtualize file and registry write failures to per-user locations](https://docs.microsoft.com/en-us/windows/security/identity-protection/user-account-control/user-account-control-group-policy-and-registry-key-settings#user-account-control-virtualize-file-and-registry-write-failures-to-per-user-locations)                                       | EnableVirtualization        | Enabled                                                      |

### Setting DLL Safe Searching

1. Press Windows key + R to open the Run dialog box.
2. Type in Regedit and press Enter. This will open the Registry Editor.
3. Navigate to HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\Session Manager.
4. In the right pane, look for the SafeDllSearchMode value. If it does not exist, right-click the blank space of the folder or right-click the Session Manager folder, select New and then DWORD (32-bit) Value. Name this new value as SafeDllSearchMode.
5. Double-click SafeDllSearchMode. In the Value data field, enter 1 to enable and 0 to disable Safe DLL Search Mode.
6. Click OK, close the Registry Editor and Reboot the system for the changes to take effect.

### Searching for Passwords in Files

```powershell
findstr /SIM /C:"password" *.txt *.ini *.cfg *.config *.xml
```

```powershell
findstr /spin "password" *.*
```

```powershell
select-string -Path C:\Users\htb-student\Documents\*.txt -Pattern password
```

### Looking Through all User's PS History

```powershell
foreach($user in ((ls C:\users).fullname)){cat "$user\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -ErrorAction SilentlyContinue}
```

### Sticky Notes Passwords

> People often use the StickyNotes app on Windows workstations to save passwords and other information, not realizing it is a database file. This file is located at C:\Users\<user>\AppData\Local\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite and is always worth searching for and examining. We can copy the three plum.sqlite* files down to our system and open them with a tool such as DB Browser for SQLite and view the Text column in the Note table with the query 'select Text from Note;'.

### CMD Key Saved Credentials

> The cmdkey command can be used to create, list, and delete stored usernames and passwords. Users may wish to store credentials for a specific host or use it to store credentials for terminal services connections to connect to a remote host using Remote Desktop without needing to enter a password. This may help us either move laterally to another system with a different user or escalate privileges on the current host to leverage stored credentials for another user.

```cmd
cmdkey /list
```

> We can attempt to use the saved cred to run commands with it

```cmd
runas /savecred /user:inlanefreight\bob "COMMAND HERE"
```

### AutoLogon

> Registry key for AutoLogon "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

```cmd
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
```
### Putty Saved Credentials

> Putty credentials are stored in cleartext at this registry key location "Computer\HKEY_CURRENT_USER\SOFTWARE\SimonTatham\PuTTY\Sessions\<SESSION NAME>"

### Stored WiFi Credentials

```cmd
netsh wlan show profile
```

```cmd
netsh wlan show profile <profile_name> key=clear
```
