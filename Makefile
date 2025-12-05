ASM := nasm
QEMU := qemu-system-x86_64

BUILD_DIR := build
IMAGE_DIR := images
BOOT_DIR := boot

MBR_BIN := $(BUILD_DIR)/master-boot-record.bin
STAGE2_BIN := $(BUILD_DIR)/stage2.bin
DISK_IMG := $(IMAGE_DIR)/boot.img

MBR_SRC := $(BOOT_DIR)/master-boot-record.asm

all: $(DISK_IMG)

$(BUILD_DIR) $(IMAGE_DIR):
	@mkdir -p $@

$(MBR_BIN): $(MBR_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(STAGE2_BIN): | $(BUILD_DIR)
	@dd if=/dev/zero of=$@ bs=512 count=8 2>/dev/null

$(DISK_IMG): $(MBR_BIN) $(STAGE2_BIN) | $(IMAGE_DIR)
	@cat $(MBR_BIN) $(STAGE2_BIN) > $@

run: $(DISK_IMG)
	$(QEMU) -drive format=raw,file=$(DISK_IMG),index=0,media=disk

clean:
	@rm -rf $(BUILD_DIR) $(IMAGE_DIR)

.PHONY: all clean run 