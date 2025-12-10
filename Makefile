ASM := nasm
QEMU := qemu-system-x86_64

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
	CC := i686-elf-gcc
	LD := i686-elf-ld
	OBJCOPY := i686-elf-objcopy
else
	CC := gcc
	LD := ld
	OBJCOPY := objcopy
endif

BUILD_DIR := build
IMAGE_DIR := images
BOOT_DIR := boot
KERNEL_DIR := kernel

MBR_BIN := $(BUILD_DIR)/mbr.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
DISK_IMG := $(IMAGE_DIR)/boot.img

MBR_SRC := $(BOOT_DIR)/mbr.asm
STAGE2_SRC := $(BOOT_DIR)/stage2.asm
KERNEL_ENTRY_SRC := $(KERNEL_DIR)/kernel_entry.asm
KERNEL_C_SRC := $(KERNEL_DIR)/kernel.c

KERNEL_ENTRY_OBJ := $(BUILD_DIR)/kernel_entry.o
KERNEL_C_OBJ := $(BUILD_DIR)/kernel.o
KERNEL_ELF := $(BUILD_DIR)/kernel.elf

STAGE2_DEPS := $(BOOT_DIR)/print16_string.asm \
               $(BOOT_DIR)/print32_string.asm \
               $(BOOT_DIR)/gdt.asm \
               $(BOOT_DIR)/switch_to_pm.asm

CFLAGS := -m32 \
          -ffreestanding \
          -nostdlib \
          -fno-pie \
          -fno-stack-protector \
          -fno-builtin \
          -Wall \
          -Wextra \
          -O2

LDFLAGS := -m elf_i386 \
           -T linker.ld \
           -nostdlib

all: $(DISK_IMG)

ifeq ($(UNAME_S),Darwin)
check-toolchain:
	@which $(CC) > /dev/null || (echo "error: $(CC) not found. Install with: brew install i686-elf-gcc" && exit 1)
	@which $(LD) > /dev/null || (echo "error: $(LD) not found. Install with: brew install i686-elf-gcc" && exit 1)
else
check-toolchain:
	@echo "Using native toolchain"
endif

$(BUILD_DIR) $(IMAGE_DIR) $(KERNEL_DIR):
	@mkdir -p $@

$(MBR_BIN): $(MBR_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@ -I $(BOOT_DIR)/

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILD_DIR) check-toolchain
	$(ASM) -f elf32 $< -o $@

$(KERNEL_C_OBJ): $(KERNEL_C_SRC) | $(BUILD_DIR) check-toolchain
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_ENTRY_OBJ) $(KERNEL_C_OBJ) | $(BUILD_DIR)
	$(LD) $(LDFLAGS) -o $@ $^

$(KERNEL_BIN): $(KERNEL_ELF) | $(BUILD_DIR)
	$(OBJCOPY) -O binary $< $@
	@# Pad kernel to 8KB (16 sectors)
	@if [ $(uname -s) = "Darwin" ]; then \
		dd if=/dev/zero of=$@ bs=8192 count=1 conv=notrunc 2>/dev/null || true; \
	else \
		truncate -s 8192 $@; \
	fi

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(IMAGE_DIR)
	@cat $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) > $@

run: $(DISK_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy -boot a

clean:
	@rm -rf $(BUILD_DIR) $(IMAGE_DIR)

.PHONY: all clean run check-toolchain