---
tags:
  - ctf
  - micropython
  - mpy
  - Python
difficulty: very easy
category: reverse engineering
---
# Challenge

The Ash-Vault kept two kinds of oath. The first were pressed into black stone by hand, the old way, one Cinderbound scribe to one vow-stone, the same craft the priesthood has used since before Crownspire had walls. The second kind nobody talks about, because it only exists thanks to what Maelor did to the first. After the white fire, when the Cinderbound went back into the drowned undercroft to count what survived, they found half their vow-stones cracked from the same heat that took the king. A cracked stone can be forged again by anyone patient enough to fake the grain. So the priesthood that outlived Maelor made a call the old masters would have called heresy: a handful of vows, the ones too dangerous to lose to a good forger, would never touch stone again. They would be pressed into a foreign engine instead, something built outside the Ashguard's own craft, unreadable to any priest trained only on the old chisels, and sealed shut. You found one of those vows. It sat in the wreckage looking like nothing, a scrap the looters passed over because every tool they carried called it "data" and left it at that. They were not wrong to be confused. This was never meant to be read by common chisels, or by the honest engines the Cinderbound trust. It was built to be misread by exactly the kind of person now holding it. Somewhere inside, a single ward is still doing its one job: listening for a syllable, and judging whether the voice offering it is the one the vow was sealed for. Learn the engine's foreign grammar. Find the ward. Give it the syllable it wants, and see if the vow answers back.

## Solution
### Files

Provided a zip file with a single file in it called `cinderbound.mpy`

```bash
file cinderbound.mpy
	cinderbound.mpy: data
```

### Research

Quick Google search shows that this is a [micropython](https://docs.micropython.org/en/latest/reference/mpyfiles.html) file. There is a tool called mpy-tool.py inside of the [MicroPython](https://github.com/micropython/micropython.git) repository that should help read/decipher this. 

```bash
git clone https://github.com/micropython/micropython.git
cd micropython
python3 ./tools/mpy-tool.py -xd ../cinderbound.mpy
```

```output
00000000: 4d06 001f 0801 186a 7564 6765 5f73 7263  M......judge_src  judge_src.py
00000010: 2e70 7900 0f0a 6a75 6467 6500 7910 7379  .py...judge.y.sy  <module> judge append syllable
00000020: 6c6c 6162 6c65 0081 5781 6f81 590a 1007  llable..W.o.Y...  len ord list
00000030: 0235 3707 0331 3239 0703 3135 3407 0233  .57..129..154..3  57 129 154 31
00000040: 3107 0331 3939 0703 3139 3207 0237 3307  1..199..192..73.  199 192 73
00000050: 0332 3433 0702 3433 0703 3137 3607 0332  .243..43..176..2  243 43 176 255
00000060: 3535 0703 3137 3307 0235 3407 0332 3033  55..173..54..203  173 54 203
00000070: 0702 3637 0702 3135 4c00 0201 3200 1602  ..67..15L...2...  67 15 <module>
00000080: 5163 0185 4059 1402 0420 2324 232a 322e  Qc..@Y... #$#*2.  judge
00000090: 3023 00c1 2280 5ac2 2b00 c312 05b0 3401  0#..".Z.+.....4. 
000000a0: 8042 6b57 c412 06b0 b455 3401 b2ee b48d  .BkW.....U4..... 
000000b0: f422 817f efee c5b2 1206 b0b4 5534 01f2  ."..........U4.. 
000000c0: 2281 7fef c2b3 1403 b536 0159 81e5 585a  "........6.Y..XZ 
000000d0: d743 1059 59b3 1207 b134 01d9 63         .C.YY....4..c 

mpy_source_file: ../cinderbound.mpy
source_file: judge_src.py
header: 4d:06:00:1f
arch: NONE
qstr_table[8]:
    judge_src.py
    <module>
    judge
    append
    syllable
    len
    ord
    list
obj_table: [(57, 129, 154, 31, 199, 192, 73, 243, 43, 176, 255, 173, 54, 203, 67, 15)]
simple_name: <module>
  raw bytecode: 9 00:02:01:32:00:16:02:51:63
  prelude: (1, 0, 0, 0, 0, 0)
  args: []
  line info: 
  32:00       MAKE_FUNCTION 0
  16:02       STORE_NAME judge
  51          LOAD_CONST_NONE 
  63          RETURN_VALUE 
  children: [judge]
simple_name: judge
  raw bytecode: 88 59:14:02:04:20:23:24:23:2a:32:2e:30:23:00:c1:22:80:5a:c2:2b:00:c3:12:05:b0:34:01:80:42:6b:57:c4:12:06:b0:b4:55:34:01:b2:ee:b4:8d:f4:22:81:7f:ef:ee:c5:b2:12:06:b0:b4:55:34:01:f2:22:81:7f:ef:c2:b3:14:03:b5:36:01:59:81:e5:58:5a:d7:43:10:59:59:b3:12:07:b1:34:01:d9:63
  prelude: (12, 0, 0, 1, 0, 0)
  args: ['syllable']
  line info: 20:23:24:23:2a:32:2e:30
  23:00       LOAD_CONST_OBJ (57, 129, 154, 31, 199, 192, 73, 243, 43, 176, 255, 173, 54, 203, 67, 15)
  c1          STORE_FAST 1 
  22:80:5a    LOAD_CONST_SMALL_INT 90
  c2          STORE_FAST 2 
  2b:00       BUILD_LIST 0
  c3          STORE_FAST 3 
  12:05       LOAD_GLOBAL len
  b0          LOAD_FAST 0 
  34:01       CALL_FUNCTION 1
  80          LOAD_CONST_SMALL_INT 0 
  42:6b       JUMP 43
  57          DUP_TOP 
  c4          STORE_FAST 4 
  12:06       LOAD_GLOBAL ord
  b0          LOAD_FAST 0 
  b4          LOAD_FAST 4 
  55          LOAD_SUBSCR 
  34:01       CALL_FUNCTION 1
  b2          LOAD_FAST 2 
  ee          BINARY_OP 23 __xor__ 
  b4          LOAD_FAST 4 
  8d          LOAD_CONST_SMALL_INT 13 
  f4          BINARY_OP 29 __mul__ 
  22:81:7f    LOAD_CONST_SMALL_INT 255
  ef          BINARY_OP 24 __and__ 
  ee          BINARY_OP 23 __xor__ 
  c5          STORE_FAST 5 
  b2          LOAD_FAST 2 
  12:06       LOAD_GLOBAL ord
  b0          LOAD_FAST 0 
  b4          LOAD_FAST 4 
  55          LOAD_SUBSCR 
  34:01       CALL_FUNCTION 1
  f2          BINARY_OP 27 __add__ 
  22:81:7f    LOAD_CONST_SMALL_INT 255
  ef          BINARY_OP 24 __and__ 
  c2          STORE_FAST 2 
  b3          LOAD_FAST 3 
  14:03       LOAD_METHOD append
  b5          LOAD_FAST 5 
  36:01       CALL_METHOD 1
  59          POP_TOP 
  81          LOAD_CONST_SMALL_INT 1 
  e5          BINARY_OP 14 __iadd__ 
  58          DUP_TOP_TWO 
  5a          ROT_TWO 
  d7          BINARY_OP 0 __lt__ 
  43:10       POP_JUMP_IF_TRUE -48
  59          POP_TOP 
  59          POP_TOP 
  b3          LOAD_FAST 3 
  12:07       LOAD_GLOBAL list
  b1          LOAD_FAST 1 
  34:01       CALL_FUNCTION 1
  d9          BINARY_OP 2 __eq__ 
  63          RETURN_VALUE 
  children: []
```

I Googled how to recompile the previous output into working code but it told me to either use an LLM or manually decipher the byte code. So I threw it into Claude to see what it could make of it.

```claude-out
### What `-xd` actually gave you

Just a disassembly — the raw opcodes with qstr/const names resolved, plus a "prelude" and "line info" block that took up the first 12 bytes of the raw bytecode before the real opcode stream started. There's no automatic decompiler for this format, so I hand-walked it as a stack machine (tracking push/pop per instruction) and cross-checked the jump target math against the raw hex offsets to make sure control flow was reconstructed correctly, then verified the result by actually executing it.

### Reconstructed source (`judge_src.py`)

def judge(syllable):
    target = (57, 129, 154, 31, 199, 192, 73, 243, 43, 176,
              255, 173, 54, 203, 67, 15)
    acc = 90
    result = []
    i = 0
    n = len(syllable)
    while i < n:
        c = ord(syllable[i])
        val = (c ^ acc) ^ ((i * 13) & 0xFF)
        acc = (acc + c) & 0xFF
        result.append(val)
        i += 1
    return result == list(target)

Key translation notes, since these are the non-obvious parts:

- `LOAD_CONST_OBJ` pulled the 16-int tuple straight from `obj_table` — that's your `target`.
- The counter `i` was never put in a named local — it lived on the value stack the whole loop (`DUP_TOP`/`DUP_TOP_TWO`/`ROT_TWO` juggling), which is why there's no obvious `STORE_FAST` for it. That's a classic MicroPython-compiler pattern for `while` loops with a jump-to-test-first entry (`JUMP` forward past the increment straight to the comparison on the first pass, so `i=0` gets tested before ever being incremented).
- Two separate `ord(syllable[i])` calls happen per iteration (one feeding `val`, one feeding the `acc` update) rather than reusing a stored value — a quirk of how the compiler emitted it, not a bug.

### The check

It's a rolling XOR/checksum cipher: `target` has 16 entries, so `syllable` must be 16 characters. Each output byte depends on the running `acc` (a mod-256 sum of characters so far, seeded at 90) and the index-derived mask `(i*13) & 0xFF`. Because it's built from XOR and modular addition, it's directly invertible character-by-character.

### Result (verified by running both the forward check and the inversion)


recovered syllable: c1nd3rbound_v0w5
judge() check: True

That's `"cinderbound_vows"` in leetspeak — thematically it lines up with the "Cinderbound priesthood guarded the realm's sacred oaths" story text for this CTF, so this is very likely the exact string this checker is meant to validate.
Flag is probably HTB{c1nd3rbound_v0w5}
```

### Solved

I tried the flag HTB{c1nd3rbound_v0w5} and it was correct.

# Claude's Walkthrough 

## Manual MicroPython Bytecode Reverse Engineering

A step-by-step method for turning `mpy-tool.py -xd` output back into working Python by hand, with no automated decompiler. Worked example throughout: `cinderbound.mpy` / `judge(syllable)`.

There is no reliable `.mpy → .py` decompiler (unlike CPython, which has `uncompyle6`/`pycdc`). `mpy-tool.py` only disassembles. Getting source back out is a manual stack-simulation exercise. It's mechanical once you have the rhythm — this doc is that rhythm.

Reference while you work: the opcode table lives in [`mpy-tool.py`](https://github.com/micropython/micropython/blob/master/tools/mpy-tool.py) itself (`MP_BC_*` constants) and the file-format layout is documented at [docs.micropython.org/.../mpyfiles.html](https://docs.micropython.org/en/latest/reference/mpyfiles.html). Treat those as ground truth if a mnemonic here doesn't match what you see — opcode numbering has shifted across MicroPython versions.

---

### Step 0 — Confirm your tool matches the target's bytecode version

`mpy-tool.py`'s disassembler hardcodes an opcode table for one specific bytecode format. If your tool version doesn't match the version that compiled the `.mpy`, you'll get nonsense mnemonics or a crash — not a clear error. The header's version byte (`4d:06:00:1f` → `06` was the version field in our example) is your check. If output looks wrong (mnemonics that don't exist, operand counts that don't make sense), your first move is swapping in a different tag of `micropython/tools/mpy-tool.py`, not doubting your reading of the bytes.

---

### Step 1 — Harvest the free information before touching the disassembly

Two blocks in the `-xd` output cost nothing to read and often tell you most of the story:

- **`qstr_table`** — every name (functions, args, module attrs) MicroPython needed to keep. In our file: `judge_src.py`, `<module>`, `judge`, `append`, `syllable`, `len`, `ord`, `list`. This alone told us the function's name, its one argument, and every builtin it calls — before reading a single opcode.
- **`obj_table`** — embedded constants: strings, byte tuples, floats. In our file: `(57, 129, 154, 31, 199, 192, 73, 243, 43, 176, 255, 173, 54, 203, 67, 15)`. This is very often the actual target of a check — sometimes you don't even need the algorithm if it's a straight string compare.

**Habit:** always read these two tables first. Sometimes the challenge is solvable from constants alone.

---

### Step 2 — Separate the prelude from the real opcode stream

The `raw bytecode` line is _not_ all opcodes. It starts with prelude bytes (state/argument counts, encoded per the `prelude:` tuple) and a `line info` block, and _then_ the opcode stream begins. `mpy-tool.py` conveniently starts its mnemonic listing at the correct byte — but to resolve jump targets later (Step 4) you need to know the **raw byte offset** of every instruction, and the tool doesn't print that for you.

**Do this:** copy the raw bytecode hex string into a scratch file, split it on `:`, and number every byte starting at 0. Example, first 15 bytes of `judge`'s raw bytecode:

```
0:59  1:14  2:02  3:04  4:20  5:23  6:24  7:23  8:2a  9:32  10:2e  11:30  12:23  13:00  14:c1 ...
```

Compare against the disassembly: the first printed instruction was `23:00 LOAD_CONST_OBJ`. Byte 12 is `23`, byte 13 is `00` — confirmed, the prelude/line-info occupies bytes 0–11, and the real opcode stream starts at byte 12. Keep numbering the rest of the bytes; you'll need this map.

---

### Step 3 — Walk the disassembly as a stack machine

This is the core skill. MicroPython bytecode is stack-based: every instruction either pushes, pops, or both. Go top to bottom and keep a running list of what's on the stack, left = bottom, right = top.

Notation that works well on paper:

- `PUSH x` → append `x` to your stack list
- `POP a, b` (two values) → remove the top two, name them for the next line
- Write the stack state after _every_ instruction, don't skip lines — the moment you skip one, jump math and comparisons stop making sense.

Opcode families you'll see constantly, and their stack effect (all confirmed from this file's actual output):

|Mnemonic|Effect|
|---|---|
|`LOAD_CONST_SMALL_INT n` / `LOAD_CONST_OBJ x` / `LOAD_CONST_NONE`|push a literal|
|`LOAD_FAST n`|push local variable `n`|
|`STORE_FAST n`|pop top, store into local `n`|
|`LOAD_GLOBAL name`|push a builtin/global by name|
|`LOAD_METHOD name`|pop object, push (object, bound-method) pair for method call|
|`CALL_FUNCTION n` / `CALL_METHOD n`|pop `n` args + callable, push return value|
|`BINARY_OP k __dunder__`|pop two, push `second OP top` (op is named for you — `__xor__`, `__add__`, `__lt__`, `__eq__`, `__and__`, `__mul__`, `__iadd__`, etc.)|
|`LOAD_SUBSCR`|pop container + index, push `container[index]`|
|`BUILD_LIST n`|build and push a list of `n` popped items (0 = empty list)|
|`DUP_TOP` / `DUP_TOP_TWO`|duplicate top 1 or 2 stack items|
|`ROT_TWO`|swap top two items|
|`POP_TOP`|discard top (usually discarding an unused call return, e.g. `list.append`'s `None`)|
|`MAKE_FUNCTION n` / `STORE_NAME name`|push a function object / bind it at module scope|
|`RETURN_VALUE`|pop top, function returns it|

**Worked fragment.** From `judge`, bytes producing the per-character value:

```
LOAD_FAST 4        stack: [n, i, partial, i]      (i = local4, the loop index copy)
LOAD_CONST 13       stack: [n, i, partial, i, 13]
BINARY_OP __mul__   stack: [n, i, partial, i*13]     <- pops (i, 13), pushes i*13
LOAD_CONST 255      stack: [n, i, partial, i*13, 255]
BINARY_OP __and__   stack: [n, i, partial, (i*13)&255]
BINARY_OP __xor__   stack: [n, i, partial ^ ((i*13)&255)]
```

Read left to right, that's just `partial ^ ((i * 13) & 255)`. This is the entire technique — do this for every instruction, in order, no shortcuts.

---

### Step 4 — Resolve jumps using your byte offset map

`mpy-tool.py` prints a _computed_ jump value next to `JUMP`, `POP_JUMP_IF_TRUE`, etc. — but you have to know what it's relative to. From this file, the rule that checked out:

> **Jump target = byte offset immediately _after_ the jump instruction, plus the printed value** (printed value is signed — negative for backward jumps).

Verify this on your own file before trusting it — don't assume, compute it once and check the byte you land on makes sense as an instruction boundary.

Example from `judge`:

- `JUMP 43` sits at raw offset 28–29 (opcode + 1 operand byte). The instruction right after it is at offset 30. `30 + 43 = 73`. Byte 73 in the raw stream was `58` → `DUP_TOP_TWO`, which is exactly the start of the loop's condition test. Lands on an instruction boundary → confirmed correct.
- `POP_JUMP_IF_TRUE -48` sits at offset 76–77; the following instruction is at 78. `78 + (-48) = 30`. Byte 30 was `57` → `DUP_TOP`, the very start of the loop body. Confirmed.

If your arithmetic lands you mid-instruction (not on a byte where a disassembled line actually starts), you've made an offset error — recount.

**Recognize the shape, not just the numbers.** A forward jump immediately after the loop counter is initialized, landing on a _comparison_ further down, with a backward jump at the bottom of that comparison back to right after the initial jump — that's a `while` loop compiled with a test-only-first entry (so a 0-length input never runs the body). Once you've seen this shape once, you'll recognize it instantly in future files.

---

### Step 5 — Translate the stack trace into Python, respecting the jump-derived structure

Once you've got (a) the full linear stack trace and (b) the jump targets telling you where loop/if bodies begin and end, write the Python by:

1. Give locals real names based on how they're used (a value that only ever increases via `__iadd__` inside a loop and gets compared each pass is your counter; a value re-stored every pass by combining with a per-char value is an accumulator; a `BUILD_LIST`-origin local being `.append`ed to is your result list).
2. Turn each isolated instruction run (per Step 3) into one expression.
3. Use the jump boundaries (per Step 4) to decide indentation — everything between the forward jump's landing spot and the backward jump's origin is the loop body; nest accordingly.
4. Sanity-check argument order for non-commutative ops (`__lt__`, `__sub__`, subscripting) — `BINARY_OP` pops `(second, top)` and applies `second OP top`, so get the operand order from your stack trace, not from guessing.

This is exactly how `judge_src.py` came out of the raw listing:

```python
def judge(syllable):
    target = (57, 129, 154, 31, 199, 192, 73, 243, 43, 176,
              255, 173, 54, 203, 67, 15)
    acc = 90
    result = []
    i = 0
    n = len(syllable)
    while i < n:
        c = ord(syllable[i])
        val = (c ^ acc) ^ ((i * 13) & 0xFF)
        acc = (acc + c) & 0xFF
        result.append(val)
        i += 1
    return result == list(target)
```

---

### Step 6 — Verify, don't trust your derivation

Two checks, in order of preference:

1. **Re-run it.** Paste your reconstructed function into a real Python interpreter (CPython is fine for logic like this — only reach for real MicroPython if native hardware calls are involved) and feed it inputs you can reason about, or the extracted constants, to confirm behavior matches what you'd expect from the disassembly.
2. **Differential compilation**, for when you're _not_ sure an opcode means what you think: write a small guess `.py`, compile it with the exact same `mpy-cross` version, run it through `mpy-tool.py -xd`, and diff the output against your unknown function. Matching instruction shapes confirm your semantics; mismatches tell you exactly where your model is wrong. This is far faster than re-deriving the whole opcode table from documentation.

For an XOR/modular-arithmetic checker like this one, there's a third, stronger check available: **algebraic inversion**. If every step is XOR or `(a ± b) & 0xFF`, it's reversible byte-by-byte:

```
c_i = val_i ^ ((i * 13) & 0xFF) ^ acc_i          # invert the two XORs
acc_(i+1) = (acc_i + c_i) & 0xFF                  # then advance the accumulator
```

starting from `acc_0 = 90` and solving `i = 0..15` in order against the `target` tuple recovers the exact input the checker accepts — which is how `c1nd3rbound_v0w5` was derived, and then confirmed by running the forward `judge()` against it and getting `True`.

---

### Quick troubleshooting checklist

- **Mnemonics look wrong / nonexistent** → tool/file bytecode version mismatch (Step 0).
- **Jump math doesn't land on an instruction boundary** → offset counting error; recount bytes from the start of the real opcode stream (Step 2), not from the start of the raw hex line.
- **Can't tell what a `BINARY_OP` number means** → `mpy-tool.py`'s `-d` output already names the dunder for you (`__xor__`, `__lt__`, etc.) — if it's not shown, check you're on the version of the tool that resolves names, not just raw bytecode.
- **Stuck on one opcode's exact semantics** → differential compilation (Step 6) beats reading source code cold, every time.
- **Function references other qstrs/functions not shown** → check the `children:` field at the end of each scope's dump; nested scopes (closures, nested defs) are disassembled separately and listed there.
## Lessons Learned

MicroPython exists, there is a Git repo for working with it, you need either a good understanding of  byte code or an LLM to really "decompile and recompile" it.