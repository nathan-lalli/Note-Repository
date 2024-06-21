#POP3 

|   |   |   |
|---|---|---|
|**Command**|**Description**|**Example**|
|USER [username]|1st login command|USER Stan  <br>+OK Please enter a password|
|PASS [password]|2nd login command|PASS SeCrEt  <br>+OK valid logon|
|QUIT|Logs out and saves any changes|QUIT  <br>+OK Bye-bye.|
|STAT|Returns total number of messages and total size|STAT  <br>+OK 2 320|
|LIST|Lists all messages: Returns indexed list of messages, along with size|LIST  <br>+OK 2 messages (320 octets)  <br>1 120  <br>2 200  <br>…  <br>LIST 2  <br>+OK 2 200|
|RETR [message index]|Retrieves the whole message|RETR 1  <br>+OK 120 octets follow.  <br>|
| DELE [message index]|Deletes the specified message|DELE 2  <br>+OK message deleted|
|TOP [message index] [num lines to return]|Returns the headers and top X lines of a message by message index (from LIST). Can be used to display the 1st few lines of a message. Headers are always returned.|TOP 2 1  <br>+OK  <br>< MIME-Version: 1.0X-Mailer: MailBee.NET 6.5.2.236To: user@company.comFrom: …., etc.>|
|UIDL [message index]|Returns a unique ID for a message index (from LIST). This ID is used by POP3 clients to identify previously downloaded messages.  A client would connect, pull a LIST of messages, then pull a UIDL for each message index listed. If the UIDL had been downloaded prior, message can be skipped.  If UIDL has not yet been downloaded, use the RETR command to download this new message.|UIDL 1 <br><br>+OK 1 6866N|
|NOOP|The POP3 server does nothing, it merely replies with a positive response.|NOOP  <br>+OK|
|RSET|Undelete the message if any marked for deletion|RSET  <br>+OK maildrop has 2 messages (320 octets)|
