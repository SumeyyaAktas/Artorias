ENTRY(_start)

SECTIONS
{
    /* Kernel loads at 0x1000 (4KB) */
    . = 0x1000;
    
    .text : {
        *(.text)
    }
    
    .rodata : {
        *(.rodata)
    }
    
    .data : {
        *(.data)
    }
    
    .bss : {
        *(.bss)
    }
}