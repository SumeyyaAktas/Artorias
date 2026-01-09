<div align="center">
  
  # Artorias 
  
</div>

<div align="center">

### EHCI (USB 2.0) Controller
[![Assembly](https://img.shields.io/badge/EHCI-USB--2.0-0466c8?style=flat-square)]()
[![License](https://img.shields.io/badge/License-Apache_2.0-0466c8?style=flat-square)]()
  
</div>

<p>Artorias is a bare-metal 32-bit x86 boot system that starts from the master boot record (MBR), loads a second-stage bootloader, transitions to 32-bit protected mode, and executes a C kernel with minimal EHCI (USB 2.0) controller support.</p>

### Table of Contents

- [Documentation](#documentation)
- [Features](#features)
- [Requirements](#requirements)
- [Building](#building)
- [Limitations](#limitations)
- [Resources](#resources)

## Documentation
The complete documentation and tutorial for the bootloader code can be found on my Medium page titled "[Writing a 32-bit x86 Bootloader from Scratch](<https://medium.com/@sumeyyaaktas/part-1-writing-a-custom-x86-bootloader-with-ehci-support-from-scratch-43cb7a5b736d>)".

## Features
- Custom x86 bootloader (MBR-based)
- VGA text output, serial port (COM1), and programmable interval timer (PIT) drivers
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

## Resources
- [Writing a Bootloader from Scratch - Carnegie Mellon University](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)
- [Rolling Your Own Bootloader - OSDev Wiki](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [EHCI - OSDev Wiki](<https://wiki.osdev.org/Enhanced_Host_Controller_Interface>)
- [EHCI Specification for USB - Intel](<https://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/ehci-specification-for-usb.pdf>)

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
