; Before the switch to 32-bit protected mode, we rely on 
; BIOS interrupts (specifically int 0x10) for output. 
; This is a lightweight way to debug the boot sequence without 
; writing a full VGA driver immediately.

[bits 16]

; The input here is bx, which is the address of the 
; null-terminated string to print. This function uses 
; teletype output which automatically handles cursor increments.
print16_string:
    pusha                    ; Preserve all registers to avoid side effects
    mov si, bx               ; lodsb expects source address in si   
    
.print16_loop:
    lodsb                    ; Load byte from [ds:si] into al and increment si         
    cmp al, 0                ; Standard C-style null terminator check   
    je .end_print16_loop       
    
    ; This interrupt may modify some registers (like bp) 
    ; on certain BIOS implementations, but 'pusha' guards our state.
    mov ah, 0x0E             ; BIOS function - Teletype output          
    mov bh, 0                ; Page number (0 is standard for bootloaders)         
    mov bl, 0x07             ; Attribute - Light grey on black background 
    int 0x10                 ; Call video BIOS
    
    jmp .print16_loop          

.end_print16_loop:
    popa
    ret

; BIOS TTY (0x0E) does not automatically wrap or advance lines on CR.
; We must manually send the carriage return and line feed pair.
print16_newline:
    pusha
    
    mov ah, 0x0E
    mov al, 0x0D             ; ASCII - Carriage return (\r)            
    int 0x10
    mov al, 0x0A             ; ASCII - Line feed (\n)  
    int 0x10
    
    popa
    ret