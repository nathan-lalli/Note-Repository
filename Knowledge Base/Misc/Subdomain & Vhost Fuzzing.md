---
tags:
  - knowledge-base
category: misc
---

# Subdomain & Vhost Fuzzing

## Overview

Three common tools for the same job: discovering virtual hosts/subdomains that aren't advertised anywhere but still respond on the target's web server.

## Commands / Usage

### gobuster

```bash
gobuster vhost --useragent "PENTEST" --wordlist "/path/to/wordlist.txt" --url $URL
```

### wfuzz

```bash
wfuzz -H "Host: FUZZ.something.com" --hc 404,403 -H "User-Agent: PENTEST" -c -z file,"/path/to/wordlist.txt" $URL
```

### ffuf

```bash
ffuf -H "Host: FUZZ.$DOMAIN" -H "User-Agent: PENTEST" -c -w "/path/to/wordlist.txt" -u $URL
```

```bash
ffuf -c -r -w "/path/to/wordlist.txt" -u "http://FUZZ.$TARGET/"
```

## Notes / Gotchas

Always set a distinct `User-Agent` (as above) so vhost-fuzzing traffic is easy to pick out of server logs during an authorized engagement, and use `--hc`/`-fs` to filter out the default "no such vhost" response size/status once you know what it looks like.

#gobuster #wfuzz #ffuf

## Related

- [Attacking Web Applications with Ffuf](../../HTB/Cheatsheets/Attacking%20Web%20Applications%20with%20Ffuf.md)
- [Footprinting](../../HTB/Cheatsheets/Footprinting.md)
