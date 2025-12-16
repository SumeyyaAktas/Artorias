ASM := nasm
QEMU := qemu-system-x86_64

CC := i686-elf-gcc
LD := i686-elf-ld
OBJCOPY := i686-elf-objcopy

BUILD_DIR := build
IMAGE_DIR := images
BOOT_DIR := boot
KERNEL_DIR := kernel
KERNEL_SRC_DIR := $(KERNEL_DIR)/src

MBR_BIN := $(BUILD_DIR)/mbr.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
DISK_IMG := $(IMAGE_DIR)/boot.img

MBR_SRC := $(BOOT_DIR)/mbr.asm
STAGE2_SRC := $(BOOT_DIR)/stage2.asm
KERNEL_ENTRY_SRC := $(KERNEL_DIR)/kernel_entry.asm

KERNEL_C_SRC := $(shell find $(KERNEL_SRC_DIR) -name "*.c")

KERNEL_ENTRY_OBJ := $(BUILD_DIR)/kernel_entry.o
KERNEL_C_OBJ := $(patsubst $(KERNEL_SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(KERNEL_C_SRC))
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
          -O2 \
          -Ikernel/include

LDFLAGS := -m elf_i386 \
           -T linker.ld \
           -nostdlib

all: $(DISK_IMG)

$(BUILD_DIR) $(IMAGE_DIR):
	@mkdir -p $@

$(MBR_BIN): $(MBR_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@ -I $(BOOT_DIR)/

$(KERNEL_ENTRY_OBJ): $(KERNEL_ENTRY_SRC) | $(BUILD_DIR)
	$(ASM) -f elf32 $< -o $@

$(BUILD_DIR)/%.o: $(KERNEL_SRC_DIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_ELF): $(KERNEL_ENTRY_OBJ) $(KERNEL_C_OBJ) | $(BUILD_DIR)
	$(LD) $(LDFLAGS) -o $@ $(KERNEL_ENTRY_OBJ) $(KERNEL_C_OBJ)

$(KERNEL_BIN): $(KERNEL_ELF) | $(BUILD_DIR)
	$(OBJCOPY) -O binary --strip-all $< $@

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(IMAGE_DIR)
	@cat $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) > $@

run: $(DISK_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy -boot a \
		-device usb-ehci,id=ehci \
		-device usb-storage,bus=ehci.0,drive=usbstick \
		-drive id=usbstick,file=/dev/null,if=none,format=raw -serial stdio

clean:
	@rm -rf $(BUILD_DIR) $(IMAGE_DIR)

.PHONY: all clean run