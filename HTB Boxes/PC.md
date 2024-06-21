## Target

**IP Address:** 10.129.203.128

## Recon

#Nmap 

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan 10.129.203.128
```

###   Findings:

| Port  | Service     | Version          |
| ----- | ----------- | ---------------- |
| 22    | ssh   | OpenSSH 8.2p1 |
| 50051 | unknown   | unknown |

