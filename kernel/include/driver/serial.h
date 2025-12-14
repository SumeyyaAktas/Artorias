#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>

#define COM1 0x3F8

void serial_init(void);
void serial_write_char(char c);
void serial_print(const char* str);
void serial_print_hex(uint32_t value);
void serial_print_hex8(uint8_t value);

#endif