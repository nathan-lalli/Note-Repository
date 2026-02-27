
## Target Scanning

###   Tools Used:

#Nmap 

###   Findings:

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan $ipAddress
```

| Port  | Service     | Version      |
| ----- | ----------- | ------------ |
| 22    | SSH         | OpenSSH 8.9p1|
| 80    | HTTP        | nginx 1.18.0 |

##  Enumeration

###    Tools Used:

#Browser 

###    Findings:

I went to the web page and got a page to sign in or register an account to the website that seem to be an image gallery

![[IntentionsLogIn.png]]

I created a user account with the following
    Name: Test Name
    Email: test@email.com
    Password: password

Once logged in I have 4 tabs
    News
    Gallery
    Your Feed
    Your Profile

![[IntentionsLoggedIn.png]]

The News has a welcome message
The Gallery has a lot of pictures in it
The Your Feed has a lot of pictures in it
The Your Profile just has my user info

I downloaded one of the images and the name of the file is
    "ashlee-w-wv36v9TGNBw-unsplash.jpg"

This could be a user in the system, but I am not sure yet

Looking at the file names of the other images I see a lot of different random names that seem to be in the format first-last
    I am not sure yet if I can do anything with this since I don't have anyway to get a password yet

When looking at the "Your Profile" page I was able to change my "Favorite Genres" to a single quote to test for sql injections
    After going to the "Your Feed" page and looking at the request in Burp I was able to see that the injection sort of worked because it gave me an error

I was able to capture the post request in Burp and use it in sqlmap but it gave me an error saying that it is not injectable because it is not looking at the right place
    I am going to look into using a "Second Order Attack" to see if I can get this to work

##  Root Access Obtained
