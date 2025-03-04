### Phishing Campaign

I am given a pcap file and a dd image file to analyze and find clues and info about what happened during a phishing incident inside of this company.
#### Question 1 

What is the campaign id in the link for downloading the avcleaner software that was received via email on 04/20/2023? Note: the file name is in the link

I was able to mount the dd file 'usermachine.dd' from to my local system and browse to the email folder to find the below email in the user's inbox

```bash
sudo mount /media/cdrom0/usermachine.dd /tmp/usermachine
```

I found the email inside of the user's home directory inside of the thunderbird mail folder. I had to do an ls -a of the files in order to find the directory since the thunderbird folder is a hidden directory.

From there, I was able to find the 'ImapMail' folder that contains all of the user's email data including the phishing campaign email below.

Campaign ID: 330

![[campaignID.png]]

#### Question 2

According to the logs, what time was the second execution of avcleaner malware ? (Answer is in MM/DD/YYYY H:MM:SS XM format eg: 01/01/1970 00:00:00)

Answer: 04/25/2023 05:51:53 PM

#### Question 3

What is the TCP stream number for transmitting whistleblowing.docx from the user's machine to a remote server?

Answer: 3

#### Question 4

Browse to the remote server that the files were exfiltrated to. How many .ogg files are on the remote malware target server?

Answer: 7

#### Question 5

Enter the token that is provided by challenge.us once the files are deleted from the remote server.

