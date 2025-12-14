<div align="center">
  
  # Artorias

</div>

<div align="center">
  
[![Assembly](https://img.shields.io/badge/x86--64-Assembly-4361EE?style=flat-square)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-4361EE?style=flat-square)]()

<sub>Two-stage x86 Bootloader • C Kernel • USB Driver Support</sub>

</div>

<p>The bare-metal x86 boot system starts from the master boot record (MBR), loads a second-stage bootloader, transitions to 32-bit protected mode, and executes a C kernel. PCI enumeration and USB controller initialization (EHCI) are under active development.</p>

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
