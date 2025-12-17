#include "driver/vga.h"
#include <kernel.h>
#include <stdint.h>


uint8_t vga_attr;
int vga_row;
int vga_col;

void vga_init(void) 
{
    vga_row = 0;
    vga_col = 0;
    vga_attr = VGA_COLOR(WHITE, BLACK);
}

void vga_print(const char* str) 
{
    char* video = (char*)VIDEO_MEMORY;

    while (*str) 
    {
        if (*str == '\n') 
        {
            vga_col = 0;
            vga_row++;
            str++;
            continue;
        }

        if (vga_col >= 80) 
        {
            vga_col = 0;
            vga_row++;
        }

        if (vga_row >= 25) 
        {
            vga_row = 0; 
        }

        video[(vga_row * 80 + vga_col) * 2] = *str;
        video[(vga_row * 80 + vga_col) * 2 + 1] = vga_attr;

        vga_col++;
        str++;
    }
}

void vga_print_hex(uint32_t value) 
{
    static const char hex[] = "0123456789ABCDEF";
    char buf[9];
    buf[8] = '\0';
    
    for (int i = 7; i >= 0; i--) 
    {
        buf[i] = hex[value & 0xF];
        value >>= 4;
    }
    
    vga_print(buf);
}

void vga_print_hex8(uint8_t value) 
{
    static const char hex[] = "0123456789ABCDEF";
    char buf[3];

    buf[0] = hex[(value >> 4) & 0xF];
    buf[1] = hex[value & 0xF];
    buf[2] = '\0';

    vga_print(buf);
}

void vga_print_color(const char* str, uint8_t fg, uint8_t bg) 
{
    uint8_t old = vga_attr;
    vga_attr = VGA_COLOR(fg, bg);
    vga_print(str);
    vga_attr = old;
}