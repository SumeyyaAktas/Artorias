[bits 16]

gdt_start:

; null descriptor
gdt_null:
    dd 0x00000000           
    dd 0x00000000           

gdt_code:
    dw 0xFFFF                       ; limit (bits 0-15)             
    dw 0x0000                       ; base (bits 0-15)
    db 0x00                         ; base (bits 16-23)    
    db 10011010B                    ; p=1, dpl=00, s=1, type=1010
                                    ; present, ring 0, code, execute/read
    db 11001111B                    ; g=1, d/b=1, l=0, avl=0, limit=1111
                                    ; 4kb granularity, 32-bit, limit bits 16-19
    db 0x00                         ; base (bits 24-31)     


gdt_data:
    dw 0xFFFF                              
    dw 0x0000                        
    db 0x00                         
    db 10010010B                    ; p=1, dpl=00, s=1, type=0010
                                    ; present, ring 0, data, read/write
    db 11001111B                       
    db 0x00                            

gdt_end:

; tells cpu where gdt is located
gdt_descriptor:
    dw gdt_end - gdt_start - 1      ; size of gdt - 1 
    dd gdt_start                    ; linear address of gdt  

CODE_SEG equ gdt_code - gdt_start   ; 0x08 (8 bytes from start)
DATA_SEG equ gdt_data - gdt_start   ; 0x10 (16 bytes from start)