ASM := nasm
QEMU := qemu-system-x86_64

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
KERNEL_SRC := $(KERNEL_DIR)/kernel.asm

STAGE2_DEPS := $(BOOT_DIR)/print16_string.asm \
               $(BOOT_DIR)/print32_string.asm \
               $(BOOT_DIR)/gdt.asm \
               $(BOOT_DIR)/switch_to_pm.asm

all: $(DISK_IMG)

$(BUILD_DIR) $(IMAGE_DIR) $(KERNEL_DIR):
	@mkdir -p $@

$(MBR_BIN): $(MBR_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(STAGE2_BIN): $(STAGE2_SRC) $(STAGE2_DEPS) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@ -I $(BOOT_DIR)/

$(KERNEL_BIN): $(KERNEL_SRC) | $(BUILD_DIR) $(KERNEL_DIR)
	$(ASM) -f bin $< -o $@

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) | $(IMAGE_DIR)
	@cat $(MBR_BIN) $(STAGE2_BIN) $(KERNEL_BIN) > $@

run: $(DISK_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),if=floppy \
		-boot a

clean:
	@rm -rf $(BUILD_DIR) $(IMAGE_DIR)

.PHONY: all clean run