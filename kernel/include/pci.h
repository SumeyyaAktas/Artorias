#ifndef PCI_H
#define PCI_H

#include <stdint.h>

#define PCI_CONFIG_ADDRESS 0xCF8
#define PCI_CONFIG_DATA 0xCFC

#define PCI_VENDOR_ID 0x00
#define PCI_DEVICE_ID 0x02
#define PCI_CLASS 0x0B
#define PCI_CLASS_INFO 0x08
#define PCI_SUBCLASS 0x0A
#define PCI_HEADER_TYPE 0x0E
#define PCI_CLASS_SERIAL 0x0C
#define PCI_SUBCLASS_USB 0x03

uint32_t pci_read(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset);
void pci_enumerate(void);

#endif