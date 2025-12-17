<div align="center">
  
  # Artorias 
  
</div>

<div align="center">

<div align="center">
<img src="assets/QEMU_WINDOW.png" height="720" width="420">
</div>

<br>

[![Assembly](https://img.shields.io/badge/x86--64-Assembly-b9375e?style=flat-square)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-b9375e?style=flat-square)]()
  
</div>

<p>Artorias is a bare-metal x86 boot system that starts from the master boot record (MBR), loads a second-stage bootloader, transitions to 32-bit protected mode, and executes a C kernel with minimal EHCI (USB 2.0) controller support.</p>

### Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Building](#building)
- [Limitations](#limitations)
- [Resources](#resources)

## Features
- Custom x86 bootloader (MBR-based)
- Freestanding 32-bit kernel
- VGA text output, serial port (COM1), and programmable interval timer (PIT) drivers
- PCI bus enumeration
- Minimal EHCI (USB 2.0) controller support
  - Detects EHCI controllers via PCI class/subclass/progIF
  - Maps MMIO registers and parses EHCI capability and operational registers
  - Properly halts, resets, and starts the controller
  - Powers USB ports and detects connected high-speed devices
  - Performs basic port resets and reports connection status

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
- This project implements an EHCI (Enhanced Host Controller Interface) driver, which only handles USB 2.0 high-speed (480 Mbps) devices.
Low-speed (1.5 Mbps) and full-speed (12 Mbps) devices require companion controllers (UHCI/OHCI) and port handoff logic, which are not implemented. USB 3.x (xHCI) devices are also unsupported.
- The driver does not issue additional control transfers to retrieve string descriptors (such as manufacturer name, product name, or serial number). As a result, devices cannot be identified by human-readable names and are only detected at a structural level.
- The driver cannot guarantee reliable control transfer completion due to limitations in hardware testing and QEMU EHCI emulation, meaning device enumeration beyond basic detection is incomplete.

## Resources
- [Writing a Bootloader from Scratch - Carnegie Mellon University](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)
- [Rolling Your Own Bootloader - OSDev Wiki](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [USB - OSDev Wiki](<https://wiki.osdev.org/Universal_Serial_Bus>)
- [EHCI - OSDev Wiki](<https://wiki.osdev.org/Enhanced_Host_Controller_Interface>)

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
