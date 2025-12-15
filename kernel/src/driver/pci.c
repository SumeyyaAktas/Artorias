#include <stdint.h>
#include "driver/pci.h"
#include <ports.h>
#include <kernel.h>
#include "driver/serial.h"

static uint32_t pci_addr(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) 
{
    return (1U << 31)
         | ((uint32_t)bus  << 16)
         | ((uint32_t)slot << 11)
         | ((uint32_t)func << 8)
         | (offset & 0xFC);
}

uint32_t pci_read(uint8_t bus, uint8_t slot, uint8_t func, uint8_t offset) 
{
    outl(PCI_CONFIG_ADDRESS, pci_addr(bus, slot, func, offset));
    return inl(PCI_CONFIG_DATA);
}

void pci_enumerate(void)
{
    uint32_t previous_device_id = 0;  

    for (uint8_t bus = 0; bus < 1; bus++)
    {
        for (uint8_t slot = 0; slot < 32; slot++)
        {
            uint32_t id = pci_read(bus, slot, 0, PCI_VENDOR_ID);
            if ((id & 0xFFFF) == 0xFFFF)
                continue;  

            if (id == previous_device_id)
                continue;
            previous_device_id = id;  

            uint32_t class_info = pci_read(bus, slot, 0, PCI_CLASS_INFO);

            uint8_t class_code = (class_info >> 24) & 0xFF;
            uint8_t subclass   = (class_info >> 16) & 0xFF;
            uint8_t prog_if    = (class_info >> 8)  & 0xFF;

            serial_print("PCI ");
            serial_print_hex(id);
            serial_print(" Class=");
            serial_print_hex8(class_code);
            serial_print(" Subclass=");
            serial_print_hex8(subclass);
            serial_print(" ProgIF=");
            serial_print_hex8(prog_if);
            serial_print("\n");

            if (class_code == PCI_CLASS_SERIAL &&
                subclass   == PCI_SUBCLASS_USB &&
                prog_if    == 0x20)
            {
                print("EHCI controller found", 3);

                uint32_t bar0 = pci_read(bus, slot, 0, PCI_BAR0);
                serial_print("BAR0 raw = 0x");
                serial_print_hex(bar0);
                serial_print("\n");

                if (bar0 & 0x1)
                {
                    serial_print("error: BAR0 is I/O space (unexpected)\n");
                    return;
                }

                uint32_t mmio_base = bar0 & 0xFFFFFFF0;
                serial_print("MMIO base = 0x");
                serial_print_hex(mmio_base);
                serial_print("\n");

                uint8_t caplength = mmio_read8(mmio_base, EHCI_CAPLENGTH);
                uint32_t hcsparams = mmio_read32(mmio_base, EHCI_HCSPARAMS);

                serial_print("CAPLENGTH = 0x");
                serial_print_hex8(caplength);
                serial_print("\n");

                serial_print("HCSPARAMS = 0x");
                serial_print_hex(hcsparams);
                serial_print("\n");

                uint32_t opreg_base = mmio_base + caplength;
                serial_print("OPREG base = 0x");
                serial_print_hex(opreg_base);
                serial_print("\n");

                uint32_t usbcmd = mmio_read32(opreg_base, EHCI_USBCMD);
                uint32_t usbsts = mmio_read32(opreg_base, EHCI_USBSTS);

                serial_print("USBCMD = 0x");
                serial_print_hex(usbcmd);
                serial_print("\n");

                serial_print("USBSTS = 0x");
                serial_print_hex(usbsts);
                serial_print("\n");

                usbcmd &= ~0x1;
                mmio_write32(opreg_base, EHCI_USBCMD, usbcmd);

                while (!(mmio_read32(opreg_base, EHCI_USBSTS) & (1 << 12)));

                print("EHCI halted", 4);

                usbcmd = mmio_read32(opreg_base, EHCI_USBCMD);
                usbcmd |= (1 << 1);
                mmio_write32(opreg_base, EHCI_USBCMD, usbcmd);

                while (mmio_read32(opreg_base, EHCI_USBCMD) & (1 << 1));

                print("EHCI reset complete", 5);
                print("Enumerating EHCI root hub ports...", 6);
                print("Powering and resetting EHCI ports...", 7);

                uint8_t num_ports = hcsparams & 0xF;

                for (uint8_t port = 0; port < num_ports; port++)
                {
                    uint32_t portsc_addr = EHCI_PORTSC_BASE + port * 4;
                    uint32_t portsc = mmio_read32(opreg_base, portsc_addr);

                    serial_print("PORT ");
                    serial_print_hex8(port + 1);
                    serial_print(" initial: 0x");
                    serial_print_hex(portsc);
                    serial_print("\n");

                    if (!(portsc & EHCI_PORTSC_PP))
                    {
                        portsc |= EHCI_PORTSC_PP;
                        mmio_write32(opreg_base, portsc_addr, portsc);
                    }

                    for (volatile int i = 0; i < 100000; i++);

                    portsc = mmio_read32(opreg_base, portsc_addr);
                    if (portsc & EHCI_PORTSC_PO)
                    {
                        serial_print("  -> Owned by companion controller\n");
                        continue;
                    }

                    if (portsc & EHCI_PORTSC_CCS)
                    {
                        serial_print("  -> Device detected, resetting port\n");

                        portsc |= EHCI_PORTSC_PR;
                        mmio_write32(opreg_base, portsc_addr, portsc);

                        for (volatile int i = 0; i < 500000; i++);

                        portsc &= ~EHCI_PORTSC_PR;
                        mmio_write32(opreg_base, portsc_addr, portsc);

                        for (volatile int i = 0; i < 100000; i++);

                        portsc = mmio_read32(opreg_base, portsc_addr);

                        serial_print("  -> After reset: 0x");
                        serial_print_hex(portsc);
                        serial_print("\n");

                        if (portsc & EHCI_PORTSC_PED)
                        {
                            serial_print("  -> High-speed device enabled\n");
                        }
                        else
                        {
                            serial_print("  -> Device not high-speed\n");
                        }
                    }
                    else
                    {
                        serial_print("  -> No device connected\n");
                    }
                }
            }
        }
    }
}