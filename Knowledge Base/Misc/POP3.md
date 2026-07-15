---
tags:
  - knowledge-base
category: misc
---

# POP3

## Overview

Command reference for interacting with a POP3 mail server directly (e.g. over telnet) - useful once you have credentials and want to read mail manually rather than through a client.

## Commands / Usage

| Command | Description | Example |
|---|---|---|
| `USER [username]` | 1st login command | `USER Stan` → `+OK Please enter a password` |
| `PASS [password]` | 2nd login command | `PASS SeCrEt` → `+OK valid logon` |
| `QUIT` | Logs out and saves any changes | `QUIT` → `+OK Bye-bye.` |
| `STAT` | Returns total number of messages and total size | `STAT` → `+OK 2 320` |
| `LIST` | Lists all messages: returns indexed list of messages, along with size | `LIST` → `+OK 2 messages (320 octets)` / `1 120` / `2 200` |
| `RETR [message index]` | Retrieves the whole message | `RETR 1` → `+OK 120 octets follow.` |
| `DELE [message index]` | Deletes the specified message | `DELE 2` → `+OK message deleted` |
| `TOP [message index] [num lines]` | Returns the headers and top X lines of a message by index. Headers are always returned. | `TOP 2 1` → headers + first line |
| `UIDL [message index]` | Returns a unique ID for a message index, used by POP3 clients to identify previously downloaded messages | `UIDL 1` → `+OK 1 6866N` |
| `NOOP` | Server does nothing, replies with a positive response | `NOOP` → `+OK` |
| `RSET` | Undeletes any message marked for deletion | `RSET` → `+OK maildrop has 2 messages (320 octets)` |

## Notes / Gotchas

A typical session flow: connect, `USER`, `PASS`, `LIST` to see what's there, `UIDL` per message to check what a client would consider "already downloaded," then `RETR` to actually pull message content.

## Related

- [File Transfers](File%20Transfers.md)
