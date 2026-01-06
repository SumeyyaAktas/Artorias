#include "ports.h"
#include "driver/pit_timer.h"

/**
 * @brief Performs a synchronous wait for a specified number of milliseconds.
 * EHCI initialization requires specific delays (e.g., waiting for the 
 * HCRESET bit to clear). Since we may not have an interrupt-driven scheduler 
 * yet, this function uses the Programmable Interval Timer (PIT) in a polling mode.
 * @param ms The number of milliseconds to wait.
 */
void pit_wait(uint32_t ms) 
{
    // The PIT frequency is fixed at 1.193182 MHz.
    // Calculation - (ms * 1,193,182) / 1000 converts time to oscillator ticks.
    uint32_t total_ticks = (uint32_t)((uint32_t)ms * PIT_BASE_FREQ / 1000);

    while (total_ticks > 0) 
    {
        // The PIT channel counters are only 16 bits wide (max 65535).
        // To wait for periods longer than ~55ms, we must break the wait into 
        // smaller chunks that fit into the hardware registers.
        uint16_t current_chunk;

        if (total_ticks > 0xFFFF) 
        {
            current_chunk = 0xFFFF;
        } 
        else 
        {
            current_chunk = (uint16_t) total_ticks;
        }

        /**
         * PIT command byte: 0x34 (00 11 010 0)
         * 00 - Select channel 0
         * 11 - Access mode: lobyte/hibyte
         * 010 - Mode 2: Rate generator (counts down and resets)
         * 0 - Binary mode
         */
        outb(PIT_COMMAND, 0x34); 
        outb(PIT_CHANNEL_0, (uint8_t)(current_chunk & 0xFF));
        outb(PIT_CHANNEL_0, (uint8_t)((current_chunk >> 8) & 0xFF));

        uint8_t status = 0;
        do 
        {
            /**
             * We use the read-back command (0xE2) to poll the status.
             * 0xE2 (11 10 001 0) 
             * 11 - Read-back command
             * 10 - Don't latch count, only status
             * 001 - Select channel 0
             */
            outb(PIT_COMMAND, 0xE2); 
            status = inb(PIT_CHANNEL_0);

        // Bit 7 of the status byte is the OUT pin state.
        // In mode 2, the OUT pin stays high during the countdown and 
        // goes low for one clock cycle when the counter reaches zero.
        } while (!(status & 0x80)); 

        total_ticks -= current_chunk;
    }
}