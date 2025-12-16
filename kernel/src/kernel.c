#include "driver/pci.h"
#include <kernel.h>
#include "driver/serial.h"
#include "driver/vga.h"

void clear_screen(void) 
{
    char* video = (char*)VIDEO_MEMORY;
    
    for (int i = 0; i < 80 * 25 * 2; i += 2) 
    {
        video[i] = ' ';
        video[i + 1] = WHITE_ON_BLACK;
    }
}

void kernel_main(void) 
{
    vga_init();
    clear_screen();
    serial_init();

    serial_print("\n");
    serial_print("Kernel loaded successfully\n");
    serial_print("Scanning PCI bus...\n");
    serial_print("Enumerating PCI devices...\n");

    pci_enumerate();

    serial_print("PCI scan complete\n");

    while (1) 
    {
        __asm__ __volatile__("hlt");
    }
}