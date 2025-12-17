<div align="center">
  
  # Artorias 
  
</div>

<div align="center">

<div align="center">
<img src="assets/QEMU_SUCCESS_WINDOW.png" width="720" height="430">
</div>

<br>

[![Assembly](https://img.shields.io/badge/x86--64-Assembly-b9375e?style=flat-square)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-b9375e?style=flat-square)]()
  
</div>

<p>Artorias is a bare-metal x86 boot system that starts from the master boot record (MBR), loads a second-stage bootloader, transitions to 32-bit protected mode, and executes a C kernel with minimal USB driver support.</p>

### Table of Contents

- [Requirements](#requirements)
- [Building](#building)
- [Limitations](#limitations)
- [Resources](#resources)

## Requirements
- GCC Cross-Compiler (i686-elf-gcc)
- GNU Make
- NASM 
- QEMU

## Building
```bash
make all    # Build boot sector and disk image
make run    # Run in QEMU
make clean  # Clean build artifacts
```
> The ```make run``` command attaches a virtual USB EHCI controller to QEMU to test the driver logic.

## Limitations
- Only supports USB 2.0 high-speed devices
- Doesn't fetch manufacturer/product name through string descriptors
- No control transfers

## Resources
- [Writing a Bootloader from Scratch - Carnegie Mellon University](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)
- [Rolling Your Own Bootloader - OSDev Wiki](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [USB - OSDev Wiki](<https://wiki.osdev.org/Universal_Serial_Bus>)
- [EHCI - OSDev Wiki](<https://wiki.osdev.org/Enhanced_Host_Controller_Interface>)

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
