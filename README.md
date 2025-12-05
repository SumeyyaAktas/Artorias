<div align="center">
  
# Custom x86 Bootloader

**A x86 bootloader with USB driver support, written from scratch**

| Start Date  | End Date |
| ------------- | ------------- |
| December 5, 2025  | Unknown  |

</div>

## Resources
- [OSDev Wiki - Rolling Your Own Bootloader](<https://wiki.osdev.org/Rolling_Your_Own_Bootloader>)
- [Carnegie Mellon University - Writing a Bootloader from Scratch](<https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf>)

## Building
```bash
make all    # Build boot sector and disk image
make run    # Run in QEMU
```

**macOS**
```bash
make all TOOLCHAIN=x86_64-elf  
make run TOOLCHAIN=x86_64-elf  
```

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE) file for details.