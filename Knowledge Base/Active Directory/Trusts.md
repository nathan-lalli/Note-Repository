---
tags:
  - knowledge-base
category: active-directory
---

# Trusts

## Overview

A trust lets users in one AD domain/forest authenticate to and access resources in another. Understanding what trusts exist (and their direction/transitivity) matters for mapping out lateral movement paths across domain and forest boundaries.

## Details

### Trust Types

- **Parent-Child** - Relationship between a parent domain and a child domain within the same forest. The parent inherently trusts the child domain and the child inherently trusts the parent.
- **Tree-Root** - Relationship that links the root domain of one tree to the root domain of another tree within the same forest.
- **External** - Relationship between a domain in one forest and a domain in a separate forest. Allows users from one domain to access resources in the other domain.
- **Forest** - Relationship between two forests, specifically between the root domains of each forest. Allows users from one forest to access resources hosted in the other forest.
- **Shortcut / Cross-Link** - Relationship between two child domains belonging to different trees/parents within the same forest. Aims to minimize authentication hops between distant domains and can be one-way or two-way.
- **Realm** - Relationship between a Windows domain and a non-Windows domain. Allows users within the Windows domain to access resources situated in the non-Windows domain.

## Commands / Usage

```PowerShell
Import-Module activedirectory
Get-ADTrust -Filter *
```

```PowerShell
Import-Module ./PowerView.ps1
Get-DomainTrust
Get-DomainTrustMapping
```

`Get-DomainTrustMapping` gets the trusts in the current domain, then attempts to enumerate all trusts for every domain that is uncovered.

## Related

- [Delegation](Delegation.md)
