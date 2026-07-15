# Personal Note Repository

This is my personal knowledge base for penetration testing: course notes, tool references, and write-ups from HTB, VulnHub, and other labs, built up over years of training. It's an [Obsidian](https://obsidian.md) vault, and the source of truth lives in this repo.

> **Note on images:** notes are authored in Obsidian and may still contain `![[wikilink]]` style embeds in a few places. These render correctly in Obsidian but not in GitHub's markdown viewer. Standard `![alt](path)` images have been converted and will display normally here.

> **Legal:** everything here refers to authorized testing only - HTB/VulnHub labs, my own OSCP coursework, and licensed training. Nothing in this repo should be used against systems you don't have explicit permission to test.

## Structure

| Folder                                | What's in it                                                                                                                                           |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`Boxes/`](Boxes)                     | Full write-ups for retired HTB machines and VulnHub VMs, one file per box (recon → enumeration → exploitation → privesc)                               |
| [`HTB/Cheatsheets/`](HTB/Cheatsheets) | Reference cheatsheets from HTB Academy modules, organized by topic                                                                                     |
| [`Knowledge Base/`](Knowledge%20Base) | Deeper conceptual notes on protocols, AD concepts, Wi-Fi attacks, and Windows internals - things that apply across boxes rather than being tied to one |
| [`Tool Box/`](Tool%20Box)             | Quick command reference per tool (Nmap, Hydra, Chisel, etc.)                                                                                           |
| [`BlackHat/`](BlackHat)               | Notes from Black Hat training courses                                                                                                                  |
| [`Exams/`](Exams)                     | Exam prep notes and post-exam retrospectives (OSCP, etc.)                                                                                              |
| [`AI/`](AI)                           | Notes on AI-driven pentesting tools                                                                                                                    |
| [`Templates/`](Templates)             | Standard templates for new box write-ups, tool pages, and Knowledge Base notes, so new notes stay consistent with old ones                             |
| [`Images/`](Images)                   | Screenshots referenced by the notes above, organized into one subfolder per box/topic                                                                  |

**Rule of thumb for where something goes:** if it's a step you'd only take on one specific box, it belongs in that box's write-up. If it's true regardless of which box you're on, it belongs in Knowledge Base or Tool Box. Cheatsheets under `HTB/Cheatsheets` are HTB Academy module references specifically - if a topic already has a page in Knowledge Base or Tool Box, that page is the canonical one and the cheatsheet should link to it rather than duplicating it.

## Boxes

### HTB

- [Active](Boxes/HTB%20Boxes/Active.md)
- [Cozy Hosting](Boxes/HTB%20Boxes/Cozy%20Hosting.md)
- [Dante](Boxes/HTB%20Boxes/Dante/Dante.md)
- [Devel](Boxes/HTB%20Boxes/Devel.md)
- [Download](Boxes/HTB%20Boxes/Download.md)
- [Editorial](Boxes/HTB%20Boxes/Editorial.md)
- [Forest](Boxes/HTB%20Boxes/Forest.md)
- [Intentions](Boxes/HTB%20Boxes/Intentions.md)
- [Keeper](Boxes/HTB%20Boxes/Keeper.md)
- [Office](Boxes/HTB%20Boxes/Office.md)
- [OnlyForYou](Boxes/HTB%20Boxes/OnlyForYou.md)
- [PC](Boxes/HTB%20Boxes/PC.md)
- [Sandworm](Boxes/HTB%20Boxes/Sandworm.md)
- [Soccer](Boxes/HTB%20Boxes/Soccer.md)
- [Topology](Boxes/HTB%20Boxes/Topology.md)
- [Usage](Boxes/HTB%20Boxes/Usage.md)
- [Visual](Boxes/HTB%20Boxes/Visual.md)
- [Zipping](Boxes/HTB%20Boxes/Zipping.md)

### VulnHub

- [Basic Pentesting 1](Boxes/Vuln%20Hub%20Boxes/Basic%20Pentesting%201.md)
- [Basic Pentesting 2](Boxes/Vuln%20Hub%20Boxes/Basic%20Pentesting%202.md)
- [Fall](Boxes/Vuln%20Hub%20Boxes/Fall.md)
- [Golden Eye](Boxes/Vuln%20Hub%20Boxes/Golden%20Eye.md)
- [Aragog](Boxes/Vuln%20Hub%20Boxes/Harry%20Potter%20Series/Aragog.md)
- [Lupin](Boxes/Vuln%20Hub%20Boxes/Lupin.md)
- [Nully Cybersecurity](Boxes/Vuln%20Hub%20Boxes/Nully%20Cybersecurity.md)
- [SickOS](Boxes/Vuln%20Hub%20Boxes/SickOS.md)
- [WinterMute](Boxes/Vuln%20Hub%20Boxes/WinterMute.md)
- [Zico](Boxes/Vuln%20Hub%20Boxes/Zico.md)

## Status

Actively maintained as I continue training - new boxes, cheatsheets, and knowledge base pages get added regularly. See [`Templates/`](Templates) before adding a new box write-up or tool page so the structure stays consistent.
