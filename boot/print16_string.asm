[bits 16]

print16_string:
    pusha
    mov si, bx                  
    
.print16_loop:
    lodsb                               
    cmp al, 0                  
    je .end_print16_loop       
    
    mov ah, 0x0E                 
    mov bh, 0                         
    mov bl, 0x07               
    int 0x10                
    
    jmp .print16_loop          

.end_print16_loop:
    popa
    ret

print16_newline:
    pusha
    
    mov ah, 0x0E
    mov al, 0x0D                   
    int 0x10
    mov al, 0x0A              
    int 0x10
    
    popa
    ret