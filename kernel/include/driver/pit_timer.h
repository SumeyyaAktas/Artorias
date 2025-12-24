#ifndef PIT_TIMER_H
#define PIT_TIMER_H

#include <stdint.h>

#define PIT_CHANNEL_0 0x40
#define PIT_COMMAND 0x43
#define PIT_BASE_FREQ 1193182

void pit_wait(uint32_t ms);

#endif