---
tags:
  - knowledge-base
category: active-directory
---

# Delegation

## Overview

Kerberos delegation lets a service account impersonate other users to access downstream resources on their behalf. Misconfigured delegation is one of the more common paths to privilege escalation/lateral movement in an AD environment.

## Details

### Unconstrained Delegation

An Active Directory feature that allows a service running under a user account to impersonate other users and access resources on their behalf.

<!-- Add Constrained Delegation and Resource-Based Constrained Delegation (RBCD) notes here as you work through them - both are common follow-ups to Unconstrained Delegation in real engagements -->

## Notes / Gotchas

Unconstrained delegation is dangerous because the delegating server caches a copy of any user's TGT the moment they authenticate to it - if you have admin on a box with unconstrained delegation enabled, you can potentially capture a Domain Admin's TGT just by getting them to connect to it.

## Related

- [Trusts](Trusts.md)
