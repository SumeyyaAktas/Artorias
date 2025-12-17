#include <stdint.h>
#include "driver/pci.h"
#include <ports.h>
#include <kernel.h>
#include "driver/serial.h"
#include "driver/vga.h"
#include "driver/pit_timer.h"

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

void pci_print_device_info(uint8_t bus, uint8_t slot, uint8_t func, uint32_t id, uint8_t class_code, uint8_t subclass, uint8_t prog_if) 
{
    vga_print_color("PCI", LIGHT_BLUE, BLACK); vga_print(" ["); vga_print_hex8(bus); vga_print(":"); 
    vga_print_hex8(slot); vga_print(":"); vga_print_hex8(func); vga_print("]");
    vga_print_color(" ID", LIGHT_BLUE, BLACK); vga_print(" = "); vga_print_hex(id);
    vga_print_color(" Class", LIGHT_BLUE, BLACK); vga_print(" = "); vga_print_hex8(class_code);
    vga_print_color(" Subclass", LIGHT_BLUE, BLACK); vga_print(" = "); vga_print_hex8(subclass);
    vga_print_color(" ProgIF", LIGHT_BLUE, BLACK); vga_print(" = "); vga_print_hex8(prog_if);
    vga_print("\n");
}

void ehci_init_controller(uint8_t bus, uint8_t slot, uint8_t func) 
{
    serial_print("EHCI controller found\n");

    uint32_t bar0 = pci_read(bus, slot, func, PCI_BAR0);
    vga_print_color("\nBAR0 Raw", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(bar0);
    vga_print("\n"); 

    uint32_t mmio_base = bar0 & 0xFFFFFFF0;
    vga_print_color("MMIO Base", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(mmio_base);
    vga_print("\n"); 

    uint8_t caplength = mmio_read8(mmio_base, EHCI_CAPLENGTH);
    vga_print_color("CAPLENGTH", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(caplength);
    vga_print("\n"); 

    uint32_t opreg_base = mmio_base + caplength;
    vga_print_color("OPREG Base", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(opreg_base);
    vga_print("\n"); 

    uint32_t usbcmd = mmio_read32(opreg_base, EHCI_USBCMD);
    vga_print_color("USBCMD", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(usbcmd);
    vga_print("\n"); 

    mmio_write32(opreg_base, EHCI_USBCMD, usbcmd & ~0x1);

    int halt_timeout = 100; 
    while (!(mmio_read32(opreg_base, EHCI_USBSTS) & (1 << 12))) 
    {
        pit_wait(1); 
        if (--halt_timeout == 0) 
        { 
            serial_print("error: EHCI fail to halt\n"); 
            return; 
        }
    }

    mmio_write32(opreg_base, EHCI_USBCMD, mmio_read32(opreg_base, EHCI_USBCMD) | (1 << 1));
    int reset_timeout = 100;
    while (mmio_read32(opreg_base, EHCI_USBCMD) & (1 << 1)) 
    {
        pit_wait(1); 
        if (--reset_timeout == 0) 
        { 
            serial_print("error: EHCI fail to reset\n"); 
            return; 
        }
    }
    serial_print("EHCI reset complete\n");

    uint32_t hcsparams = mmio_read32(mmio_base, EHCI_HCSPARAMS);
    uint8_t num_ports = hcsparams & 0xF;
    vga_print_color("HCSPARAMS", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(hcsparams);
    vga_print(" (");
    vga_print_hex8(num_ports);
    vga_print(" ports)\n");
    
    uint8_t port = 0;
    uint32_t portsc_addr = EHCI_PORTSC_BASE + (port * 4);
    uint32_t portsc = mmio_read32(opreg_base, portsc_addr);
    vga_print_color("Final PORTSC", CYAN, BLACK);
    vga_print(" = 0x");
    vga_print_hex(portsc);
    vga_print("\n");

    for (uint8_t port = 0; port < num_ports; port++) 
    {
        uint32_t portsc_addr = EHCI_PORTSC_BASE + (port * 4);
        uint32_t portsc = mmio_read32(opreg_base, portsc_addr);

        mmio_write32(opreg_base, portsc_addr, portsc | EHCI_PORTSC_PP);
        
        pit_wait(20);

        portsc = mmio_read32(opreg_base, portsc_addr);
        if (portsc & EHCI_PORTSC_CCS) 
        {
            vga_print_color("\nDevice Detected on Port ", CYAN, BLACK);
            vga_print_hex8(port + 1);
            vga_print("\n");
            
            vga_print_color("PORTSC", CYAN, BLACK);
            vga_print(" = 0x");
            vga_print_hex(portsc);
            vga_print("\n");

            mmio_write32(opreg_base, portsc_addr, portsc | EHCI_PORTSC_PR);
            pit_wait(50); 
            mmio_write32(opreg_base, portsc_addr, portsc & ~EHCI_PORTSC_PR);
            pit_wait(10);
        }
    }
}

void pci_check_device(uint8_t bus, uint8_t slot, uint8_t func) 
{
    uint32_t id = pci_read(bus, slot, func, PCI_VENDOR_ID);
    
    if ((id & 0xFFFF) == 0xFFFF) 
    {
        return; 
    }

    uint32_t class_info = pci_read(bus, slot, func, PCI_CLASS_INFO);
    uint8_t class_code = (class_info >> 24) & 0xFF;
    uint8_t subclass = (class_info >> 16) & 0xFF;
    uint8_t prog_if = (class_info >> 8)  & 0xFF;

    pci_print_device_info(bus, slot, func, id, class_code, subclass, prog_if);

    if (class_code == PCI_CLASS_SERIAL && subclass == PCI_SUBCLASS_USB && prog_if == 0x20) 
    {
        ehci_init_controller(bus, slot, func);
    }
}

void pci_enumerate(void)
{ 
    vga_print_color("                            Welcome to Artorias!", LIGHT_MAGENTA, BLACK);
    vga_print("\n");
    vga_print_color("     A Custom x86 Bootloader with Minimal EHCI (USB 2.0) Controller Support", LIGHT_MAGENTA, BLACK);
    vga_print("\n");
    vga_print("\n");

    for (uint16_t bus = 0; bus < 256; bus++)
    {
        for (uint8_t slot = 0; slot < 32; slot++)
        {
            uint32_t id = pci_read(bus, slot, 0, PCI_VENDOR_ID);
            
            if ((id & 0xFFFF) == 0xFFFF) 
            {
                continue;
            }
            
            pci_check_device(bus, slot, 0);

            uint32_t header_type = pci_read(bus, slot, 0, PCI_HEADER_TYPE);
            if ((header_type >> 16) & 0x80) 
            {
                for (uint8_t func = 1; func < 8; func++) 
                {
                    pci_check_device(bus, slot, func);
                }
            }
        }
    }
}