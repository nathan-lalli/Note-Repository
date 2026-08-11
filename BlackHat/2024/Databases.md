
## MySQL

**Attacking MySQL**

* MySQL is very widely used - which makes it an attractive target
* Listens on TCP port 3306 by default
* Typically secured by default with network access controls and built in ACLs
* Vulnerabilities
	* SQL Injection Attacks
	* Abusing Management Console access (such as phpMyAdmin)
	* Brute force attack if a direct connection is possible
* The root user of MySQL is almost always present and not configured to lockout by default

**MySQL Exploitation

* Getting access to a database is just the beginning
* Various attacks can be performed depending on privileges
* FILE* privilege allows the user to read files on the server

```mysql
select LOAD_FILE('/etc/passwd');
```

* Database credential's location: mysql.user table

```mysql
select * from mysql.user;
```

*  Note: It's always worth checking if your database account has the FILE privilege. The MySQL root user has this access

## Oracle

To connect to an Oracle database, you need the following:

* IP:Port default port 1521
	* use nmap for this
* SID (database name)
	* use odat here
* Credentials
	* use odat here

**Oracle: The real world**
 * Typically, you will be able to connect to Oracle as an unprivileged account such as SCOTT/TIGER
 * After connecting you may want to:
	 * Escalate privileges to become DBA
	 * With DBA privs execute OS Code

## PostgreSQL

**PostgreSQL:**

* Listens on TCP port 5432 by default
* Default configuration is might limited to localhost
* Default user postgres
* OS code execution as the DBA
	* UDF - User defined function
	* copy command

**PostgreSQL: Intro. to SECURITY DEFINER**

* Is an attribute of a PostgreSQL function or procedure that allows it to execute with the privileges of the ‘owner’.
* By default, functions and procedures run with the privileges of the calling user (SECURITY INVOKER).
* Enables the function to act with elevated privileges.

**PostgreSQL: SECURITY DEFINER Operations**

* Audit logging:
	* A function that logs user activity to a table that should not be directly writable by all users
* Sensitive data access:
	* Provide controlled access to sensitive data

**PostgreSQL: SECURITY DEFINER Risks**

* Privilege Escalation:
	* If not implemented carefully, SECURITY DEFINER functions can be exploited to gain higher privileges than intended.
* Injection Vulnerabilities:
	* Functions must be designed to prevent SQL injection attacks, as elevated privileges can lead to severe consequences.
* Extension Vulnerabilities:
	* Vulnerability in an extension might lead to privilege escalation.