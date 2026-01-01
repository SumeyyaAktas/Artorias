; The x86 processor requires a Global Descriptor Table to 
; define memory segments before entering 32-bit protected mode. 
; This setup implements a flat memory model where code and data segments 
; overlap the entire 4GB space (0x0 to 0xFFFFFFFF). This bypasses complex 
; segmentation in favor of a simpler linear address space.

[bits 16]

gdt_start:

; The null descriptor is the mandatory first entry. The processor 
; hardware expects the first 8 bytes to be zero. Using index 0 results 
; in a general protection fault, which helps catch null pointer errors. 
gdt_null:
    dd 0x00000000           
    dd 0x00000000           

; This is the code segment descriptor where 0x08 is the first entry 
; after null (8 bytes), used for code segment register.
gdt_code:
    dw 0xFFFF           ; Limit - Sets bits 0-15 of the segment size                                           
    dw 0x0000           ; Base - Bits 0-15 of the starting address (0x0)                     
    db 0x00             ; Base - Bits 16-23                     
    
    
    ; This is the access byte. Ring 0 is required for kernel-level EHCI/hardware access.
    ; 1 (Present) | 00 (Privilege: Ring 0) | 1 (S: Code/Data) | 1 (Type: Code) 
    ; | 0 (Conforming) | 1 (Readable) | 0 (Accessed)
    db 10011010B                    

    ; This is the flags & limit. Granularity bit is needed; it turns 0xFFFF into 4GB total limit.
    ; 1 (Granularity: 4KiB blocks) | 1 (Size: 32-bit PM) | 0 (L: 64-bit) | 0 (AVL)
    ; | 1111 (Limit bits 16-19)                                
    db 11001111B                    
                                    
    db 0x00             ; Base - Bits 24-31                       


; This is the data segment descriptor where 0x10 is 
; the second entry (16 bytes), used for DS, SS, ES, FS, GS registers.
gdt_data:
    dw 0xFFFF                              
    dw 0x0000                        
    db 0x00 

    
    ; This is the same as code segment, but Type bit 
    ; is 0 (Data) and 1 (Writable). Code segments are not writable 
    ; but data segments are.                        
    db 10010010B                    
                                    
    db 11001111B                       
    db 0x00                            

gdt_end:


; This is the pointer passed to the LGDT instruction.
; The size is always (length - 1) because the 
; max value 0xFFFF represents a 65536-byte table.
gdt_descriptor:
    dw gdt_end - gdt_start - 1      
    dd gdt_start                   


; These are the constants for loading segment registers during 
; the protected mode switch. These define the offset 
; from the start of the GDT.
CODE_SEG equ gdt_code - gdt_start      
DATA_SEG equ gdt_data - gdt_start   