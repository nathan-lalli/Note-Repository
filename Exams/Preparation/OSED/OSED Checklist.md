## Phase 0 — Setup
- [ ] VPN lab pack downloaded and connected
- [ ] Reverted Module VM once to confirm control panel access
- [ ] Kali VM up to date (64-bit, latest stable)
- [ ] IDA Freeware installed on Kali, symlinked to `/usr/bin`
- [ ] Skimmed Module 1 (logistics, exam format, revert limits)

---

## Module 2 — WinDbg and x86 Architecture
- [ ] Read book module
- [ ] Watched course video
- [ ] Can draw a stack frame from memory (saved EBP, return addr, args, locals) without notes
- [ ] Comfortable with `__cdecl` / `__stdcall` / `__fastcall` differences
- [ ] Practiced: `g p t pt ph bp r dd u k lm .reload /f x ?`
- [ ] Completed module exercises unaided
- [ ] **GATE:** Can read raw disassembly and explain what's happening without the book open

## Module 3 — Exploiting Stack Overflows
- [ ] Read book module
- [ ] Watched course video
- [ ] Installed Sync Breeze in lab
- [ ] Fuzzed target and reproduced crash
- [ ] Calculated EIP offset independently (not from book listing)
- [ ] Ran bad character analysis (`!mona bytearray` / `!mona compare`)
- [ ] Found and validated a JMP ESP gadget
- [ ] Got working shell — built exploit script myself, referenced book only when stuck
- [ ] Completed module exercises unaided
- [ ] **GATE:** Built a full stack overflow exploit from scratch, no copy-paste

## Module 4 — Exploiting SEH Overflows
- [ ] Read book module
- [ ] Watched course video
- [ ] Understand `_EXCEPTION_REGISTRATION_RECORD` / TEB `ExceptionList` structure
- [ ] Understand SafeSEH and `RtlIsValidHandler` at a conceptual level
- [ ] Found POP POP RET gadget in a non-SafeSEH module
- [ ] Built short-jump-in-nseh exploit
- [ ] Completed module exercises unaided
- [ ] **GATE:** Built a full SEH exploit from scratch, no copy-paste

## Module 5 — Introduction to IDA Pro
- [ ] Read book module
- [ ] Watched course video
- [ ] Rebased IDA to match a running process's WinDbg base address
- [ ] Comfortable in graph view + text view + xrefs (`x` key)
- [ ] Completed module exercises unaided
- [ ] **GATE:** Can sync WinDbg <-> IDA and navigate xrefs without the book open

## Module 6 — Egghunters
- [ ] Read book module
- [ ] Watched course video
- [ ] Installed and crashed Savant Web Server
- [ ] Understand why the egghunter's 2-value syscall check avoids crashing on unmapped pages
- [ ] Built egghunter with Keystone Engine (not hand-assembled)
- [ ] Ported/tested SEH-based egghunter variant
- [ ] Got working shell on Windows 10 target
- [ ] Completed module exercises unaided
- [ ] Attempted Extra Mile (log outcome below if skipped/stuck)
- [ ] **GATE:** Can explain *why* the egghunter works, not just recite the steps

## Module 7 — Creating Custom Shellcode
- [ ] Read book module
- [ ] Watched course video
- [ ] Can explain PEB -> PEB_LDR_DATA -> InInitializationOrderModuleList walk without notes
- [ ] Understand `IMAGE_EXPORT_DIRECTORY` and the 3-array relationship (Functions/Names/NameOrdinals)
- [ ] Implemented kernel32.dll base address resolution by hand
- [ ] Implemented hash-based API resolution (avoiding bad chars in function names)
- [ ] Built and tested a custom reverse shell shellcode
- [ ] Completed module exercises unaided
- [ ] **GATE:** Can whiteboard PEB-walk + EAT parsing cold, no reference material

## Module 8 — Reverse Engineering For Bugs
- [ ] Read book module
- [ ] Watched course video
- [ ] Installed FastBackServer in lab
- [ ] Enumerated listening ports with TCPView
- [ ] Reverse engineered protocol using IDA + WinDbg together
- [ ] Identified at least one memory corruption bug **unaided**
- [ ] Started "bugs found unaided" log (see below)
- [ ] Attempted extra-mile target (Deep Freeze Enterprise Server) for additional reps
- [ ] Completed module exercises unaided
- [ ] **GATE:** Found ≥2 bug classes in the extra-mile target without hints

## Module 9 — Stack Overflows and DEP Bypass
- [ ] Read book module
- [ ] Watched course video
- [ ] Understand DEP theory: NX bit, Permanent DEP, `/NXCOMPAT`
- [ ] Understand why `NtSetInformationProcess` per-process disable was patched
- [ ] Understand ROP origins (ret2libc -> gadget chaining)
- [ ] Built a ROP chain **by hand** against CSFTPAV6.DLL (no auto-ROP tool)
- [ ] Got working shell bypassing DEP
- [ ] Completed module exercises unaided
- [ ] Attempted Extra Mile(s) (log outcome below if skipped/stuck)
- [ ] **GATE:** Can build a basic ROP chain manually, no gadget-finder shortcuts

## Module 10 — Stack Overflows and ASLR Bypass
- [ ] Read book module
- [ ] Watched course video
- [ ] Understand `/DYNAMICBASE` and ASLR randomization scope
- [ ] Located non-ASLR module for gadget sourcing (`!nmod` / mona)
- [ ] Built ROP chain calling `WriteProcessMemory` to place shellcode in executable memory
- [ ] Implemented dynamic bad-character encoding + ROP-based runtime decoder
- [ ] Got working shell bypassing DEP + ASLR together
- [ ] Completed module exercises unaided
- [ ] Attempted Extra Mile(s) (log outcome below if skipped/stuck)
- [ ] **GATE:** Exploit handles bad-char encoding and non-ASLR module hunting independently

## Module 11 — Format String Specifier Attack Part I
- [ ] Read book module
- [ ] Watched course video
- [ ] Understand format string theory and specifier/argument mismatch bug class
- [ ] Identified format string vulnerability in FastBackServer (event log path)
- [ ] Built a **read primitive** — leaked stack address
- [ ] Built a **read primitive** — leaked kernelbase.dll address, computed module base
- [ ] Completed module exercises unaided
- [ ] Attempted Extra Mile(s) (log outcome below if skipped/stuck)
- [ ] **GATE:** Built the read primitive without re-reading the walkthrough mid-exploit

## Module 12 — Format String Specifier Attack Part II
- [ ] Read book module
- [ ] Watched course video
- [ ] Understand `%n` specifier mechanics and why it's compiler-disabled by default
- [ ] Built byte-by-byte DWORD write primitive
- [ ] Selected valid overwrite target (return address, away from CFG-sensitive spots)
- [ ] Achieved EIP control and code execution via the write primitive alone (no 2nd bug)
- [ ] Completed module exercises unaided
- [ ] Attempted Extra Mile(s) (log outcome below if skipped/stuck)
- [ ] **GATE:** Built the write primitive without re-reading the walkthrough mid-exploit

## Module 13 — Trying Harder: The Labs
- [ ] Attempted Challenge 1 — unguided, timed
- [ ] Attempted Challenge 2 — unguided, timed
- [ ] Attempted Challenge 3 — unguided, timed
- [ ] Simulated exam conditions for at least one full session (no book, timer running)
- [ ] Reviewed what slowed me down most and logged it below

---

## Review Pass (after Module 13)
- [ ] Redid weakest 2 modules' exercises cold (pick from Review Log below)
- [ ] Revisited any skipped Extra Miles
- [ ] Refreshed "primitives" reference doc (WinDbg commands, egghunter template, PEB-walk template, ROP checklist, format string templates)
- [ ] Second attempt at any Module 13 challenge not solved on first pass
