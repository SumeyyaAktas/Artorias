#ifndef PORTS_H
#define PORTS_H

static inline unsigned short inw(unsigned short port) 
{
    unsigned short result;
    __asm__("inw %1, %0" : "=a" (result) : "Nd" (port));
    return result;
}

static inline unsigned int inl(unsigned short port) 
{
    unsigned int result;
    __asm__ __volatile__("inl %1, %0" : "=a"(result) : "Nd"(port) : "memory");
    return result;
}

static inline void outl(unsigned short port, unsigned int data) 
{
    __asm__ __volatile__("outl %0, %1" : : "a"(data), "Nd"(port) : "memory");
}

static inline uint8_t inb(uint16_t port)
{
    uint8_t ret;
    __asm__ volatile("inb %w1, %b0" : "=a"(ret) : "Nd"(port) : "memory");
    return ret;
}

static inline void outb(uint16_t port, uint8_t val)
{
    __asm__ volatile("outb %b0, %w1" : : "a"(val), "Nd"(port) : "memory");
}

static inline uint8_t mmio_read8(uint32_t base, uint32_t offset)
{
    volatile uint8_t* addr = (volatile uint8_t*)(base + offset);
    return *addr;
}

static inline uint32_t mmio_read32(uint32_t base, uint32_t offset)
{
    volatile uint32_t* addr = (volatile uint32_t*)(base + offset);
    return *addr;
}

static inline void mmio_write32(uint32_t base, uint32_t offset, uint32_t value)
{
    volatile uint32_t* addr = (volatile uint32_t*)(base + offset);
    *addr = value;
}

#endif