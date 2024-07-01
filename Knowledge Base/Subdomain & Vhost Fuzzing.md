## gobuster 

```bash
gobuster vhost --useragent "PENTEST" --wordlist "/path/to/wordlist.txt" --url $URL
```
## wfuzz 

```bash
wfuzz -H "Host: FUZZ.something.com" --hc 404,403 -H "User-Agent: PENTEST" -c -z file,"/path/to/wordlist.txt" $URL
```
## ffuf 

```bash
ffuf -H "Host: FUZZ.$DOMAIN" -H "User-Agent: PENTEST" -c -w "/path/to/wordlist.txt" -u $URL
```

```bash
ffuf -c -r -w "/path/to/wordlist.txt" -u "http://FUZZ.$TARGET/"
```


#gobuster #wfuzz #ffuf