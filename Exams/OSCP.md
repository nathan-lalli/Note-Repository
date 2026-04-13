## Exam Tips and Thoughts

This is my opinion, on the OSCP exam and the best way to approach it based on my experience
I was able to pass on my first attempt by owning two stand alone machines and the entire Active Directory set
That being said, everyone is different and what worked for me may not work for you

### Timing

I took almost the entire 24 hours and only took one 30-45 minute break not including bathroom breaks here and there

I know myself well enough that if I slept I would not have gotten up and wouldn’t have had time to finish the exam
	I drank lots of caffeine and was able to push through and finish
Everyone is different when it comes to sleep, so make sure you do what is right for you and your body
### General

Take lots of screenshots, of everything

Most important is enumeration. Enumerate everything because something is vulnerable

Try not to think too hard. 
	I know this sounds dumb since it is an exam, but remember that this is the “entry” level exam. It won’t be advanced techniques or vulnerabilities.
	If you find yourself trying to edit and exploit more than changing one or two lines, you may need to reevaluate to make sure you’re on the right track. 

Think easy before thinking hard.

### Stand-Alone

Once you get a foothold, pause, take a screenshot and update your notes with everything that you had to do to get there

### Active Directory

You start as a user, but this isn’t your user account, treat it like you would an account you compromised as a foothold

Same as before, take pictures of everything as you go and once you compromise a machine, stop and make sure you have a screenshot of everything you did to get there

Start by enumerating the starting account

* Who are you
* What permissions/rights do you have
	* On the machine that you are on
	* In the Active Directory environment

Once you get admin on a machine in the AD environment, enumerate it as an admin
	With the admin privileges you can now read other user’s files, PowerShell history, etc. 

Bloodhound will be very helpful to find the probable path
	As you compromise users and machine, mark them as owned in bloodhound so you can see the path as you go
