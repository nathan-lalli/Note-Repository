---
tags:
  - box
platform: HTB
os: Linux
difficulty:
date_completed:
mitre_attack:
status: in-progress
---

## Target

**IP Address:** 10.129.63.206

## Recon

### Port Scan

```bash
sudo nmap -T5 -p- 10.129.63.206
```

![Pasted image 20240719110033](../../Images/Editorial/Pasted%20image%2020240719110033.png)

```bash
sudo nmap -p 22,80 -sV -sC -oA editorial.tcp 10.129.63.206
```

![Pasted image 20240719110044](../../Images/Editorial/Pasted%20image%2020240719110044.png)

## Enumeration

![Pasted image 20240719114539](../../Images/Editorial/Pasted%20image%2020240719114539.png)

![Pasted image 20240719114527](../../Images/Editorial/Pasted%20image%2020240719114527.png)

![Pasted image 20240719114501](../../Images/Editorial/Pasted%20image%2020240719114501.png)

![Pasted image 20240719114512](../../Images/Editorial/Pasted%20image%2020240719114512.png)

![Pasted image 20240719114338](../../Images/Editorial/Pasted%20image%2020240719114338.png)

![Pasted image 20240719114701](../../Images/Editorial/Pasted%20image%2020240719114701.png)

## Exploitation

<!-- Not reached yet in these notes - this write-up is screenshot-only so far with no accompanying explanation of what each step shows -->

## Privilege Escalation

<!-- Not reached yet in these notes -->

## Flags

**User/Root:** not yet captured in these notes

## Lessons Learned

<!-- This write-up is currently screenshots without commentary - worth going back through and adding a sentence of context under each image while it's still fresh -->
