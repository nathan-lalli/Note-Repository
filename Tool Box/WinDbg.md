---
tags:
  - tool
category: reverse engineering
---
## Description

<!-- One or two sentences: what the tool does and when you'd reach for it -->

## x86 Registers

| Register | Role |
|---|---|
| `EAX` | Accumulator, return value |
| `EBX` | General purpose (often preserved) |
| `ECX` | Counter (loops, string ops) |
| `EDX` | General purpose / I/O |
| `ESI` / `EDI` | Source / Destination index (string/memcpy ops) |
| `ESP` | Stack pointer — top of stack |
| `EBP` | Base pointer — current stack frame base |
| `EIP` | Instruction pointer — next instruction to execute |
| `EFL` | Flags register (ZF, CF, SF, OF...) |

## Stack Frame (grows downward, low addr = top)

```
[higher addresses]
  ...caller's stack...
  function arguments        <- EBP+8, EBP+0Ch, ...
  return address             <- EBP+4
  saved EBP                  <- EBP+0
  local variables            <- EBP-4, EBP-8, ...
[lower addresses]            <- ESP (current top)
```

## Calling Conventions

| Convention | Args passed | Stack cleanup |
|---|---|---|
| `__cdecl` | Stack, right-to-left | Caller cleans |
| `__stdcall` | Stack, right-to-left | Callee cleans (`ret N`) |
| `__fastcall` | ECX, EDX, then stack | Callee cleans |

---

## WinDbg — Execution Control

| Command | Action |
|---|---|
| `g` | Go (continue execution) |
| `p` | Step over (procedure step) |
| `t` | Step into (trace step) |
| `pt` | Execute until next `ret` |
| `ph` | Execute until next branch |
| `bp <addr/sym>` | Set breakpoint |
| `bl` | List breakpoints |
| `bc <n>` / `bc *` | Clear breakpoint(s) |
| `bd <n>` / `be <n>` | Disable / enable breakpoint |
| `.restart` | Restart process |

## WinDbg — Inspecting State

| Command | Action |
|---|---|
| `r` | Show all registers |
| `r eip` | Show/set specific register |
| `k` | Show call stack |
| `u <addr>` | Unassemble at address |
| `u <addr> L<n>` | Unassemble n instructions |
| `dd <addr>` | Dump memory as DWORDs |
| `dw` / `db` | Dump memory as WORDs / bytes |
| `da` / `du` | Dump ASCII / Unicode string |
| `!address <addr>` | Info about memory region (heap/stack/etc) |
| `!vprot <addr>` | Memory protection flags for address |

## WinDbg — Modules & Symbols

| Command | Action |
|---|---|
| `lm` | List loaded modules |
| `lm m <pattern>*` | List modules matching wildcard |
| `.reload /f` | Force reload symbols |
| `x <module>!<pattern>*` | Search symbols by wildcard |
| `!dh <module>` / `!dh -a <module>` | Dump PE headers |

## WinDbg — Misc / Utility

| Command | Action |
|---|---|
| `? <expr>` | Evaluate expression (calculator) |
| `ed <addr> <value>` | Edit DWORD at address |
| `eb <addr> <bytes>` | Edit bytes at address |
| `.formats <expr>` | Show value in all formats |
| `$exentry`, `$ip`, `$scmp` | Common pseudo-registers |

## Common Mona.py Commands (Immunity/WinDbg extension)

| Command | Action |
|---|---|
| `!mona bytearray` | Generate byte array to test for bad chars |
| `!mona compare -f <file> -a <addr>` | Compare memory to bytearray, find bad chars |
| `!mona findmsp` | Find offset to EIP / metasploit pattern match |
| `!mona jmp -r esp -m <module>` | Find JMP ESP in a module |
| `!mona modules` | List modules with protection flags (ASLR/SafeSEH/DEP) |

---

## SEH Cheat Sheet

- Structure on stack: `[Next SEH][SE Handler]`
- Overwrite goal: `SE Handler` -> **POP POP RET** gadget -> lands back at `Next SEH`
- `Next SEH` (nseh) typically holds a **short jump** to hop over the 4-byte handler and into your buffer
- SafeSEH blocks handlers not in the module's registered table — pick your POP POP RET from a **non-SafeSEH module**

## DEP / ROP Cheat Sheet

- Goal: chain gadgets ending in `ret` to call `VirtualProtect` / `VirtualAlloc` / `WriteProcessMemory`
- Gadget source must be: **no ASLR**, **no bad chars in address**, ideally no SafeSEH conflict
- Basic write-primitive gadget chain: `POP ECX; RET` -> `POP EAX; RET` -> `MOV [ECX], EAX; RET`

## ASLR Bypass Cheat Sheet

- Look for a **non-ASLR module** loaded into the process (`!mona modules`, or Narly `!nmod`) to source gadgets/JMP ESP
- Alternative: leak an address via an info-disclosure bug (format string, logic bug) to compute module base at runtime

## Format String Cheat Sheet

| Specifier | Effect |
|---|---|
| `%x` | Read stack value as hex |
| `%s` | Read stack value as pointer, dereference as string |
| `%n` | **Write** number of chars printed so far to address on stack |

- Read primitive: walk `%x`/`%s` specifiers to leak stack/heap/module addresses
- Write primitive: use `%n` (often as `%<count>x%<n>$n` byte-by-byte) to write a DWORD one byte at a time to a controlled address

---

## Bad Character Workflow

1. Generate full byte array (`\x01`-`\xff`, skipping `\x00`)
2. Send in buffer, crash target, dump buffer in memory
3. Compare byte-for-byte against original — first mismatch = bad char
4. Remove that byte from array, repeat until clean
5. Common troublemakers: `\x00` (null), `\x0a`/`\x0d` (newline/CR), `\x25` (`%` in format-string contexts), `\x2f`/`\x5c` (`/` `\` in path contexts)

