<div align="center">
<img src="https://images.unsplash.com/vector-1759145395760-de60a128408d?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDR8fGJ1bm55fGVufDB8fDB8fHww" width="120" height="120">

  # Custom x86 Bootloader

</div>

<div align="center">
  
[![Assembly](https://img.shields.io/badge/x86--64-Assembly-blue)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

<sub>Bootloader From Scratch • 100% Assembly • USB Driver Support</sub>

</div>

<p>During stage one, the master boot record loads stage 2 from disk. In stage 2, the 16-bit real mode is initialized with outputs on screen through BIOS interrupts. Using a global descriptor table, we can transition from 16-bit real mode to 32-bit protected mode. Stage 2 outputs messages to the screen using both 16-bit (BIOS) and 32-bit (direct VGA memory) printing routines.</p>

### Table of Contents

- [Requirements](#requirements)
- [Building](#building)
- [Resources](#resources)

## Requirements
- x86_64-elf Cross-Compiler
- GNU Make
- NASM 
- QEMU

## Building
```bash
make all    # Build boot sector and disk image
make run    # Run in QEMU
```

## Resources
- [Rolling Your Own Bootloader - OSDev Wiki](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [Writing a Bootloader from Scratch - Carnegie Mellon University](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)
- [Writing a Simple Operating System from Scratch - Nick Blundell](<https://github.com/tpn/pdfs/blob/master/Writing%20a%20Simple%20Operating%20System%20from%20Scratch%20-%20Nick%20Blundell%20-%20Dec%202010.pdf>) (Visit the 'boot sector programming' section)


## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
