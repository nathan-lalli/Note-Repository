---
tags:
  - knowledge-base
category: misc
---

# MySQL & MariaDB

## Overview

Basic connection syntax and a handy query for converting a MySQL password hash into a Hashcat-crackable format.

## Commands / Usage

### Connect to Database

```bash
mysql -h (ip address) -P (port) -u (username) -p (password)
```

### Convert MySQL Hash to Hashcat Format

```mysql
select user,Concat ('$mysql',Left(authentication_string, 6), '*', insert(Hex(Substr(authentication_string, 8)), 41, 0, '*')) as hash from user where plugin = 'caching_sha2_password' and authentication_string not like '%INVALIDSALTANDPASSWORD%';
```

## Related

- [HashCat](HashCat.md)
