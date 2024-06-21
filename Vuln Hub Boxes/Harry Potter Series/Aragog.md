There are 2 horcruxes to find in this machine, 8 in total across all three Harry Potter machines.

**IP Address: 192.168.1.101** 

## Recon

```bash
sudo nmap -T4 -O -sV -sC -p- -oA aragogMapping 192.168.1.101
```

###   Findings:

There are two ports that are open on this target
    22
    80

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | SSH   | OpenSSH 7.9p1 |
| 80    | HTTP   | Apache httpd 2.4.38 |

![[aragogMappingScan.png]]

I check searchsploit to see if these versions where vulnerable, but I did not see any results to this

Using the browser Firefox, I navigated to the http page and was greeted with an image from Harry Potter

![[aragogHomePage.png]]

I checked to see if there was a robots.txt file, but I got a 404 page

Using dirb, I was able to scan the website to see if there were any hidden directories on the site. I found the following directories
    blog
    javascript
    wp-admin
    wp-content
    wp-includes

![[Images/Aragog/dirbScan.png]]

Based on the wp-* directories, it seems that this is a Word Press website

Using Firefox, I was able to navigate to the javascript directory but I was greeted with a forbidden page

![[javascriptDirectoryForbidden.png]]

I was able to navigate to the blog directory though and found that it is a very basic Word Press website, it came across as a little broken though

![[wordPressBlog.png]]

Clicking on a link that was on the page, I saw that it was trying to direct me to "aragog.hogwarts" and "wordpress.aragog.hogwarts"
    I added these to my /etc/hosts file and then was able to fully load the website

![[loadedWordPressSite.png]]

Looking at some of the posts on the site, I saw one that was named "notice" and when I navigated to it I saw that it was mentioning that some of the unused WordPress plugins are going to be deleted
    This could be interesting because it could have some good vulnerabilities in these plugins and it seems that the plugins may not be removed yet

![[wordPressPluginNotice.png]]

Looking into the page source, I was able to find the version of WordPress that this site is running
    WordPress 5.0.12

![[wordPressVersion.png]]

Now that I have verified that the site is running WordPress, I used WPScan to scan the site to check for all the plugins, versions, etc that is on the site

```bash
wpscan --url http://wordpress.aragog.hogwarts/blog
```

From the scan I was able to find that XML-RPC is enabled on the WordPress site and I might be able to use this to get a foot hold

![[wordPressXMLRPC.png]]

![[wordPressVersionAndTheme.png]]

WPScan was unable to detect the plugins in passive mode, I then had it use aggressive mode instead and was able to find what plugins it was using that way

![[wpscanPlugins.png]]

Using searchsploit, I found that wp-file-manager has multiple exploits and it seems that the version they are using is vulnerable to some of these. There are two exploits for akismet but WPScan could not find the version that the site was running

Using Firefox, I went to the WordPress login page and tried the default login for the admin account but was met with an invalid username error

![[wordPressLoginError.png]]

I tried to use the lost password field with different default usernames, but each time I was told that it was an invalid username or email
    admin
    wp-admin
    username

Looking more into the plugins that were running on the system. I was able to get a foothold with the "wp-file-manager" plugin that was out of date on the system

There is a vulnerability in the plugin that allows for a file upload and RCE by moving an arbitrary file to the system and allowing for it to be run as the system on the target machine. I was able to use this in MetaSploit and get a meterpreter shell back

![[meterpreterShellAchieved.png]]

I have gotten on as the user www-data on the  system, so I am going to need to look for some way to escalate my privileges

Reading the /etc/passwd file I found that there are a couple of different users on this machine that I might be able to try and pivot to
    hagrid98
    ginny

There is also a mysql account which could be useful if mysql is being used to store creds somewhere

Looking into the two users on the system, I was able to list out their home directories and I found the first horcrux inside of Hagrid's home directory

![[horcrux1.png]]

Using Linpeas to search the system, I was able to find what I believe are database credentials for the mysql database

![[databaseCredentials.png]]

Using the above username and password, I was able to login to the mysql service on the system

![[mysqlRootLogin.png]]

From the database I was able to get the user list for the WordPress site which has an entry for Hagrid, along with the hashed password for his account

![[hagridUserEntry.png]]

`$P$BYdTic1NGSb8hJbpVEMiJaAiNJDHtc.`

I was able to use hashcat to crack the hash of his password
    password123

![[crackedPassword.png]]

I was able to use this password to log in as Hagrid with ssh

![[hagridLoggedIn.png]]

Now that I have already done recon on the machine as www-data I need to dig further to see if something else is going on now that I have creds and a more stable shell.

I tried to run "sudo -l" to see what commands I might be able to run, unfortunately "sudo" is not on this machine

![[sudoNotOnMachine.png]]

I then uploaded "pspy64" to the machine to find out what else might be running on the machine that I cannot see from the files since I had found a few scripts earlier.

When I ran pspy I found that the UID 0 was running a script on the machine that Hagrid is an owner of. I might be able to use this to get root access on the machine.

![[backupScriptRunning.png]]

I was able to open up the .backup.sh file and add an entry of my own to the script. I added a reverse shell line to it and started up a listener on my attack box to see if I got a result

![[backupScriptEdit.png]]

After the Root user ran the script again I got a connection on my listener and was able to get logged in as the root user

![[rootShellAchieved.png]]

I was then able to navigate into the /root directory and see that the second horcrux was sitting there for me and was able to read it

![[horcrux2.png]]
