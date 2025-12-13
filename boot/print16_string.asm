[bits 16]

print16_string:
    pusha
    mov si, bx                 ; copy string pointer to si (lodsb uses si)          
    
.print16_loop:
    lodsb                      ; load byte from si into al, si++               
    cmp al, 0                  ; check for null terminator
    je .end_print16_loop       ; exit if end of string
    
    mov ah, 0x0E               ; print character using bios teletype       
    mov bh, 0                  ; page number is 0        
    mov bl, 0x07               ; color is light gray on black 
    int 0x10                
    
    jmp .print16_loop          ; process next character

.end_print16_loop:
    popa
    ret

print16_newline:
    pusha
    
    mov ah, 0x0E
    mov al, 0x0D               ; carriage return        
    int 0x10
    mov al, 0x0A               ; line feed   
    int 0x10
    
    popa
    ret