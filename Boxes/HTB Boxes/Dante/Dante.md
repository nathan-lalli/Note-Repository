---
tags:
  - box
  - overview
platform: HTB (Pro Lab)
os: mixed (Windows and Linux)
difficulty:
date_completed:
mitre_attack:
status: in-progress
---

## Overview

Dante is a modern, yet beginner-friendly pro lab that provides the opportunity to learn common penetration testing methodologies, and gain familiarity with tools included in the Parrot OS Linux distribution. Dante LLC have enlisted your services to audit their network. The company has not undergone a comprehensive penetration test in the past, and want to reduce their technical debt. They are concerned that any actual breach could lead to a loss of earnings and reputation damage.

Upon breaching the perimeter, you are required to explore the network, moving laterally and vertically, until you gain administrative control over all hosts and reach domain admin. You will level up your skills in information gathering and situational awareness, be able to exploit Windows and Linux buffer overflows, gain familiarity with the Metasploit Framework, and much else!

There are many flags to be captured along the way, some on the main attack path and others in side-quests that you must go looking for. Submitting flags will propel you through the Hall of Fame, rewarding you with badges in the process.

This **Penetration Tester Level I** lab will expose players to:

- Enumeration
- Exploit Development
- Lateral Movement
- Privilege Escalation
- Web Application Attacks

Your entry point is in **10.10.110.0/24**. The firewall at **10.10.110.2** is out of scope.

## Machines

Since this is a multi-host pro lab rather than a single box, each machine gets its own write-up file in this folder instead of one combined page:

- [First Box](First%20Box.md) - 10.10.110.100
