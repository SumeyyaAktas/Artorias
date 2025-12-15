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

#define PCI_BAR0 0x10
#define PCI_BAR1 0x14
#define PCI_BAR2 0x18
#define PCI_BAR3 0x1C
#define PCI_BAR4 0x20
#define PCI_BAR5 0x24

#define EHCI_CAPLENGTH 0x00
#define EHCI_HCSPARAMS 0x04

#define EHCI_USBCMD 0x00
#define EHCI_USBSTS 0x04

#define EHCI_PORTSC_BASE 0x44
#define EHCI_PORTSC_CCS (1 << 0)   
#define EHCI_PORTSC_PED (1 << 2)   
#define EHCI_PORTSC_PR (1 << 7)   
#define EHCI_PORTSC_PO (1 << 12)  
#define EHCI_PORTSC_PP (1 << 13) 

uint32_t pci_read(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset);
void pci_enumerate(void);

#endif