#ifndef PORTS_H
#define PORTS_H

static inline unsigned char inb(unsigned short port) {
    unsigned char result;
    __asm__("inb %1, %0" : "=a" (result) : "Nd" (port));
    return result;
}

static inline unsigned short inw(unsigned short port) {
    unsigned short result;
    __asm__("inw %1, %0" : "=a" (result) : "Nd" (port));
    return result;
}

static inline unsigned int inl(unsigned short port) {
    unsigned int result;
    __asm__("inl %1, %0" : "=a" (result) : "Nd" (port));
    return result;
}

static inline void outl(unsigned short port, unsigned int data) {
    __asm__("outl %0, %1" : : "a" (data), "Nd" (port));
}

#endif
