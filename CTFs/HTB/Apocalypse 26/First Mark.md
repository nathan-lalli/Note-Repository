---
tags:
  - ctf
difficulty: easy
category: reverse engineering
---
# Challenge

Veylen Marr kept one secret from Maelor even while he was helping him dig for it: he never intended the First Mark to reach anyone's hands again, least of all a king's. When the vault flooded and the dust of that night finally settled, Veylen went back down alone and built something out of what he understood better than any living man, the old vow-forms, the sanctified marks, the grammar the first kings used to bind an oath to the sky. He built a stone that would listen for the First Mark and answer with only two words: true, or nothing at all. He left four of its instructions undocumented on purpose. Veylen had spent his whole career watching manuals get copied, stolen, and forged, and he'd learned the only ward worth trusting is one nobody can read secondhand. So he etched four runes into the spaces the old makers marked "for the kings to come," gave them no key, and let the stone keep its own counsel. Common chisels read most of it and stall exactly there, the same wall Veylen built into every safeguard he ever made for a king he didn't trust. If you want the stone to attest, don't go looking for the manual Veylen never wrote. Learn what those four runes do from the company they keep, the same way every claimant who ever wanted Veylen's trust had to earn it instead of being handed it. They found one last thing in the vault, cut in Veylen's own hand on the final dry stone, the closest he ever came to leaving a key. It reads: "The third rune is not a plain XOR. Each round it computes out = a0 ^ state ^ carry, then updates the hidden carry as carry = old_a0 & state. The carry starts at 0, and the state starts at 0xA5 and becomes the rune's output each round.

## Solution

### Files

A zip file with a single binary in it called 'first-mark.elf'

```bash
file first-mark.elf
	first-mark.elf: ELF 32-bit LSB executable, UCB RISC-V, soft-float ABI, version 1 (SYSV), statically linked, stripped
```

### Research

I tried to run the file but got an error message when I did it.

```bash
./first-mark.elf
	zsh: exec format error: ./first-mark.elf
```

That was when I noticed that the file has a .elf at the back instead of a normal ELF file not having any extension.

Looking back at the `file` output I see that it is for a `UCB RISC-V` architecture and not a x86 like my machine is, to run this I will have to emulate a different architecture.

I ran the following to get more information on the binary file

```bash
readelf -h first-mark.elf
2026-07-24 13:26:20-05:00
ELF Header:
  Magic:   7f 45 4c 46 01 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF32
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
  Version:                           0x1
  Entry point address:               0x20000000
  Start of program headers:          52 (bytes into file)
  Start of section headers:          4752 (bytes into file)
  Flags:                             0x0
  Size of this header:               52 (bytes)
  Size of program headers:           32 (bytes)
  Number of program headers:         4
  Size of section headers:           40 (bytes)
  Number of section headers:         6
  Section header string table index: 5
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ readelf -S first-mark.elf
2026-07-24 13:26:29-05:00
There are 6 section headers, starting at offset 0x1290:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        20000000 001000 000178 00  AX  0   0  4
  [ 2] .rodata           PROGBITS        20000178 001178 0000bc 00   A  0   0  4
  [ 3] .bss              NOBITS          80000000 002000 000010 00  WA  0   0  4
  [ 4] .riscv.attributes RISCV_ATTRIBUTE 00000000 001234 00002a 00      0   0  1
  [ 5] .shstrtab         STRTAB          00000000 00125e 000030 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  D (mbind), p (processor specific)
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ readelf -l first-mark.elf
2026-07-24 13:26:32-05:00

Elf file type is EXEC (Executable file)
Entry point 0x20000000
There are 4 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  RISCV_ATTRIBUT 0x001234 0x00000000 0x00000000 0x0002a 0x00000 R   0x1
  LOAD           0x001000 0x20000000 0x20000000 0x00234 0x00234 R E 0x1000
  LOAD           0x001000 0x80000000 0x20000234 0x00000 0x00010 RW  0x1000
  GNU_STACK      0x000000 0x00000000 0x00000000 0x00000 0x00000 RW  0x10

 Section to Segment mapping:
  Segment Sections...
   00     .riscv.attributes 
   01     .text .rodata 
   02     .bss 
   03     
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ objdump -s -j .rodata first-mark.elf 
2026-07-24 13:27:09-05:00

first-mark.elf:     file format elf32-little

Contents of section .rodata:
 20000178 74686520 73746f6e 65207769 746e6573  the stone witnes
 20000188 7365732e 20697420 646f6573 206e6f74  ses. it does not
 20000198 20626172 6761696e 2e207265 61642074   bargain. read t
 200001a8 68652066 6f757220 6d61726b 73206f72  he four marks or
 200001b8 20626520 63617374 206f7574 2e000000   be cast out....
 200001c8 41434345 50544544 3a205468 65204669  ACCEPTED: The Fi
 200001d8 72737420 4d61726b 20776173 20637574  rst Mark was cut
 200001e8 20696e20 73746565 6c2e0000 03070105   in steel.......
 200001f8 02060400 03070105 02060400 03020302  ................
 20000208 05070203 05070203 05070203 117a3590  .............z5.
 20000218 7e88b059 797f566a 3a10e905 206b6565  ~..Yy.Vj:... kee
 20000228 7020796f 75722073 7465656c           p your steel    
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ objdump -s -j .text first-mark.elf
2026-07-24 13:27:23-05:00

first-mark.elf:     file format elf32-little

Contents of section .text:
 20000000 17010160 13010100 17050060 130585ff  ...`.......`....
 20000010 97050060 93850500 6378b500 23200500  ...`....cx..# ..
 20000020 13054500 e36cb5fe 17050000 1305c520  ..E..l......... 
 20000030 97050060 938505fd 17060060 130686fc  ...`.......`....
 20000040 63fcc500 83220500 23a05500 13054500  c...."..#.U...E.
 20000050 93854500 e3e8c5fe ef00c003 6f000000  ..E.........o...
 20000060 b7070010 03470500 631c0700 03a70700  .....G..c.......
 20000070 e34e07fe 1307a000 23a0e700 67800000  .N......#...g...
 20000080 13051500 83a60700 e3ce06fe 23a0e700  ............#...
 20000090 6ff05ffd 130101ff 17050000 1305050e  o._.............
 200000a0 23261100 eff0dffb 17050060 130585f5  #&.........`....
 200000b0 ef000002 17050000 13054511 eff05ffa  ..........E..._.
 200000c0 8320c100 13050000 13010101 67800000  . ..........g...
 200000d0 130101fd 23261102 23248102 23229102  ....#&..#$..#"..
 200000e0 23202103 232e3101 232c4101 13040500  # !.#.1.#,A.....
 200000f0 93040000 1306500a 17090000 1309c90f  ......P.........
 20000100 97090000 93894910 170a0000 130aca10  ......I.........
 20000110 b3029400 03c50200 b3029900 83c50200  ................
 20000120 93f57500 0b05b500 b3829900 83c50200  ..u.............
 20000130 0b15b500 2b05c500 13060500 b3029a00  ....+...........
 20000140 83c60200 2b00d502 93841400 93020001  ....+...........
 20000150 e3c054fc 13050000 8320c102 03248102  ..T...... ...$..
 20000160 83244102 03290102 8329c101 032a8101  .$A..)...)...*..
 20000170 13010103 67800000                    ....g...        
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ objdump -s -j .bss first-mark.elf
2026-07-24 13:27:31-05:00

first-mark.elf:     file format elf32-little

Contents of section .bss:
 80000000 00000000 00000000 00000000 00000000  ................
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/first_mark]
└─$ objdump -s -j .riscv.attributes first-mark.elf
2026-07-24 13:27:52-05:00

first-mark.elf:     file format elf32-little

Contents of section .riscv.attributes:
 0000 41290000 00726973 63760001 1f000000  A)...riscv......
 0010 04100572 76333269 3270315f 6d327030  ...rv32i2p1_m2p0
 0020 5f7a6d6d 756c3170 3000               _zmmul1p0.
```
## Lessons Learned

<!-- Anything worth remembering for next time - technique, gotcha, tool quirk -->
