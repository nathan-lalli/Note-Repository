---
tags:
  - box
platform: # HTB / VulnHub / other
os: # Windows / Linux
difficulty: # Easy / Medium / Hard / Insane
date_completed: # YYYY-MM-DD
mitre_attack: # e.g. T1110, T1558.003 - fill in as techniques are used below
status: # in-progress / rooted
---

## Target

**IP Address:**

**Platform / OS:**

## Recon

### Port Scan

```bash
sudo nmap -T4 -O -sV -sC -p- -oA targetScan <target>
```

#### Findings

## Enumeration

<!-- One subsection per service/vector enumerated. Tag the tool used, e.g. #Nmap #SMBMap #Ffuf -->

## Exploitation

<!-- What got initial access, and why it worked -->

## Privilege Escalation

<!-- Path from initial foothold to full admin/root/system -->

## Flags

**User:**

**Root/System:**

## Lessons Learned

<!-- Anything worth remembering for next time - technique, gotcha, tool quirk -->
