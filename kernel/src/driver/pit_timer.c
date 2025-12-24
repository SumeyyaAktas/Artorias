#include <ports.h> 
#include "driver/pit_timer.h"

void pit_wait(uint32_t ms) 
{
    uint32_t total_ticks = (uint32_t)((uint32_t)ms * PIT_BASE_FREQ / 1000);

    while (total_ticks > 0) 
    {
        uint16_t current_chunk = (total_ticks > 0xFFFF) ? 0xFFFF : (uint16_t)total_ticks;

        outb(PIT_COMMAND, 0x34); 
        outb(PIT_CHANNEL_0, (uint8_t)(current_chunk & 0xFF));
        outb(PIT_CHANNEL_0, (uint8_t)((current_chunk >> 8) & 0xFF));

        uint8_t status = 0;
        do 
        {
            outb(PIT_COMMAND, 0xE2); 
            status = inb(PIT_CHANNEL_0);
        } while (!(status & 0x80)); 

        total_ticks -= current_chunk;
    }
}