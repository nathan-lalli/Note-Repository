## Course Map (13 Modules)

| # | Module | Core Skill | Case Study / Target |
|---|--------|-----------|---------------------|
| 1 | General Course Information | Logistics, lab rules, exam format | — |
| 2 | WinDbg and x86 Architecture | Registers, stack, calling conventions, WinDbg fundamentals | Notepad |
| 3 | Exploiting Stack Overflows | Classic EIP overwrite | Sync Breeze |
| 4 | Exploiting SEH Overflows | SEH chain abuse, SafeSEH bypass | Sync Breeze |
| 5 | Introduction to IDA Pro | Static analysis, WinDbg/IDA sync | Notepad |
| 6 | Overcoming Space Restrictions: Egghunters | Small-buffer exploitation, bad chars, partial overwrites | Savant Web Server |
| 7 | Creating Custom Shellcode | PEB walking, EAT resolution, hash-based symbol lookup | Hand-rolled shellcode |
| 8 | Reverse Engineering For Bugs | Full RE workflow (install → protocol RE → bug hunting) | FastBackServer.exe |
| 9 | Stack Overflows and DEP Bypass | ROP fundamentals, ret2libc origins | FastBackServer |
| 10 | Stack Overflows and ASLR Bypass | Non-ASLR module abuse, WriteProcessMemory ROP, bad-char ROP decoders | FastBackServer |
| 11 | Format String Specifier Attack Part I | Format string theory, building a **read primitive** | FastBackServer (event log) |
| 12 | Format String Specifier Attack Part II | Building a **write primitive**, EIP control without a 2nd bug | FastBackServer |
| 13 | Trying Harder: The Labs | 3 unguided challenge boxes | Unknown targets |

**The throughline:** 2→5 builds your tooling and mental model. 6→7 builds primitives you'll reuse constantly (egghunters, shellcode). 8 is the pivot — real unguided RE. 9→12 is one continuous exploit against FastBackServer that gets a new mitigation bolted on every module. 13 is the closest thing to the exam you get.

---

## Module-by-Module Study Guide

### Module 2 — WinDbg and x86 Architecture
**Must be automatic, not "looked up," by the time you leave this module:**
- Stack frame anatomy: saved EBP, return address, args, locals — draw it from memory, don't reference a diagram
- Calling conventions (`__cdecl`, `__stdcall`, `__fastcall`) — who cleans the stack, argument order
- EIP/ESP/EBP roles + general purpose registers
- WinDbg command fluency: `g`, `p`, `t`, `pt`, `ph`, `bp`, `r`, `dd`/`dw`/`db`, `u`, `k`, `lm`, `.reload /f`, `?` (calculator), `x` (symbol search), pseudo-registers (`$exentry`, etc.)

**Pentester note:** if you're coming from web/network/AD pentesting, this module is the actual bottleneck for most people, not the "advanced" modules later. Don't rush it — SEH/ROP modules assume this is second nature.

### Module 3 — Exploiting Stack Overflows
- Fuzzing → crash → EIP control workflow, bad character identification (mona.py `!mona bytearray` / `!mona compare`)
- JMP ESP hunting, offset calculation (`!mona findmsp` / pattern_offset)
- **Key gap to watch for:** knowing *why* you pick a particular JMP ESP instruction (module without ASLR/rebasing, no bad chars) vs. just copy-pasting one

### Module 4 — Exploiting SEH Overflows
- `_EXCEPTION_REGISTRATION_RECORD` structure, TEB `ExceptionList`
- POP POP RET gadget mechanics and why they're needed
- SafeSEH and how `RtlIsValidHandler` checks defeat naive SEH overwrites
- Short jump / long jump trick when buffer space before nseh is limited

### Module 5 — Introduction to IDA Pro
- Static/dynamic sync (rebasing IDA to match WinDbg's loaded base)
- Graph view vs text view, xrefs (`x` key), Functions/Imports/Exports windows
- This module is tooling, not theory — the real test is whether you *use* IDA fluently in Module 8 onward, not whether you can recite this module

### Module 6 — Egghunters
- Egghunter mechanics: why 2-syscall validation (`NtAccessCheckAndAuditAlarm` / `NtDisplayString`) avoids crashing on unmapped pages
- Keystone Engine for assembling shellcode from Python instead of hand-computing opcodes
- SEH-based egghunter as a portability improvement over syscall-based one across Windows versions
- **This module is where "small buffer, big payload elsewhere" thinking starts** — a recurring exam pattern

### Module 7 — Creating Custom Shellcode
- PEB → PEB_LDR_DATA → InInitializationOrderModuleList walk to find kernel32.dll base *without* calling any API
- Export Directory Table (`IMAGE_EXPORT_DIRECTORY`): `AddressOfFunctions`/`AddressOfNames`/`AddressOfNameOrdinals` — the one-to-one relationship between these three arrays is the crux of manual symbol resolution
- Hash-based API resolution (avoiding null bytes / bad chars in shellcode by hashing function names instead of embedding strings)
- **This is arguably the single hardest module conceptually** — budget extra time

### Module 8 — Reverse Engineering For Bugs
- Full RE loop: install target → enumerate with TCPView → static+dynamic protocol RE with IDA+WinDbg → identify multiple bug classes (memory corruption, DoS, logic bugs)
- This is the first module with **no hand-holding toward a specific bug** — treat it like a mini-exam
- 15+ vulnerabilities exist in the extra-mile target (Deep Freeze Enterprise Server) — use it for practice reps, not just the primary FastBackServer path

### Module 9 — Stack Overflows and DEP Bypass
- DEP theory: NX bit, Permanent DEP / `/NXCOMPAT`, why `NtSetInformationProcess` per-process DEP-disable got patched
- ROP origins (ret2libc → Krahmer/Shacham/Solé gadget-chaining evolution)
- Manual ROP chain construction against a non-ASLR, no-bad-chars DLL (CSFTPAV6.DLL) — **do this by hand before trusting any automated gadget finder**

### Module 10 — Stack Overflows and ASLR Bypass
- ASLR implementation: `/DYNAMICBASE`, per-boot vs per-process randomization nuance
- Locating non-ASLR modules as your gadget source (`!nmod` in Narly)
- ROP chain calling `WriteProcessMemory` to copy shellcode into an executable page — bypasses DEP+ASLR together
- Dynamic bad-character encoding scheme + a ROP-based runtime decoder — this is a genuinely advanced technique, expect to revisit it

### Module 11 — Format String Specifier Attack Part I
- Format string theory (`printf`/`sprintf`/`vsnprintf` mechanics, specifier-to-argument mismatch)
- Building a **read primitive** from a format string bug — leaking stack + module base addresses through an application side channel (event log)
- This is a genuinely different exploitation mental model from stack overflows — don't try to force stack-overflow intuition onto it

### Module 12 — Format String Specifier Attack Part II
- The `%n` specifier — writes byte count to a supplied address (why it's normally compiler-disabled)
- Byte-by-byte DWORD write primitive construction, target selection (stack return address far down the call stack, away from CFG-sensitive locations)
- Achieving EIP control and code execution **without a second (memory corruption) bug at all** — this is the conceptual payoff of the whole 11→12 arc

### Module 13 — Trying Harder: The Labs
- 3 unguided challenges. Treat this as your dress rehearsal for the 47h45m OSED exam. No solutions provided — this is the real signal of readiness.

---

## Study Plan

Assume ~15–20 hrs/week. Adjust the week counts to your actual pace — the point is the *ordering and gating*, not the calendar. Given your general pentest background, I'm assuming Module 2 (x86 fundamentals) is your slowest module unless you've already done binary exploitation work — budget accordingly rather than assuming it's "easy because it's early."

| Phase | Weeks | Modules | Gate before moving on |
|---|---|---|---|
| Foundations | 1–2 | 1, 2 | You can read raw disassembly and explain stack frame layout without notes |
| Classic overflows | 2–3 | 3, 4 | You've built a stack overflow *and* SEH exploit from scratch, no copy-paste from the book |
| Tooling | 0.5 | 5 | You can sync WinDbg↔IDA and navigate xrefs without the book open |
| Constrained exploitation | 1.5 | 6 | You understand *why* the egghunter's 2-value check works, not just that it does |
| Shellcode internals | 2 | 7 | You can explain PEB-walking and EAT parsing on a whiteboard, cold |
| Unguided RE | 1.5–2 | 8 | You found ≥2 bug classes in the extra-mile target unaided |
| DEP/ROP | 2 | 9 | You built a ROP chain by hand (no auto-ROP tool) that gets a shell |
| ASLR/DEP combined | 2–2.5 | 10 | Your exploit handles bad-char encoding and non-ASLR-module gadget hunting independently |
| Format strings | 2.5–3 | 11, 12 | You built read AND write primitives without re-reading the walkthrough mid-exploit |
| Exam simulation | 1–2 | 13 | Timed, unguided, all 3 boxes attempted under exam-like conditions |
| Buffer / review | 1–2 | — | Redo your weakest 2 modules' exercises cold, revisit Extra Miles you skipped |

**Total: ~16–21 weeks** at that pace. Compress by cutting review time, not by skipping Extra Miles — those are doing the actual exam-readiness work.

**Hard rule:** don't start a new module until you've completed that module's *regular* exercises without checking the solution first. If you check the solution before attempting, log it — that module goes on your review-pass list.

---

## A Better Way to Ingest This Material

The default approach (read book → watch video → do exercises → next module) works but leaves two gaps for someone at your level: it doesn't force *unaided recall*, and it doesn't build a reusable toolkit you can draw on quickly during a timed exam or a real engagement.

**1. Read/watch in reverse order per module.**
Watch the video first for the big picture, *then* read the book for the depth and the blue-box details it leaves out. Reading dense structure definitions (like `IMAGE_EXPORT_DIRECTORY`) cold is harder than reviewing them after you've already seen the concept demoed.

**2. Keep a single running "primitives" reference doc, not per-module notes.**
Instead of notes organized by module (mirrors the book, low retrieval value), organize by *technique*:
- WinDbg command cheat sheet (built incrementally, not copied from the book)
- Bad-character identification workflow
- Egghunter template + when to use syscall vs SEH variant
- PEB-walk / EAT-resolution shellcode template
- Manual ROP chain-building checklist
- Format string read/write primitive templates

This mirrors how you'll actually work during OSED or on an engagement — you won't be thinking "what did module 7 say," you'll be thinking "I need to resolve an API address without calling GetProcAddress."

**3. Force recall before consulting solutions.**
For every exercise, write down your approach *before* opening the solution — even a rough one. If your approach was wrong, log *why* it was wrong. This single habit does more for exam performance than re-reading chapters.

**4. Rebuild, don't copy, the code.**
The book explicitly warns that copy-pasting introduces whitespace bugs — but more importantly, retyping the PEB-walk shellcode or ROP-chain-building code from scratch (referencing structure, not literally re-reading each line) is what makes it recallable at 2am on exam day.

**5. Treat Extra Miles and Module 13 as spaced-repetition checkpoints, not optional content.**
Come back to Module 6 and 9's Extra Miles again *after* finishing Module 12 — your understanding of ROP and bad-char handling will be much deeper by then, and a second pass at earlier material with that hindsight is one of the highest-value things you can do with review time.

**6. Track a "bugs I found unaided" log starting at Module 8.**
This becomes your best predictor of exam readiness — the OSED exam gives you unguided targets, and your Module 8/13 unaided performance is the closest analog the course material gives you to that experience.
