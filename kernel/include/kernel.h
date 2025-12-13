#ifndef KERNEL_H
#define KERNEL_H

#define VIDEO_MEMORY 0xB8000
#define WHITE_ON_BLACK 0x0F

void print(const char* str, int row);
void clear_screen(void);
void kernel_main(void);

#endif KERNEL_H