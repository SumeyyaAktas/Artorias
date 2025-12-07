<div align="center">
  
# Custom x86 Bootloader

</div>

<p>A bootloader written from scratch that lays the foundation for USB driver support. During stage one, the master boot record loads stage 2 from disk. In stage 2, the 16-bit real mode is initialized with outputs on screen through BIOS interrupts. Using a global descriptor table, we can transition from 16-bit real mode to 32-bit protected mode. Stage 2 outputs messages to the screen using both 16-bit (BIOS) and 32-bit (direct VGA memory) printing routines.</p>

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
- [OSDev Wiki - Rolling Your Own Bootloader](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [Carnegie Mellon University - Writing a Bootloader from Scratch](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)


## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.
