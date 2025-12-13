[bits 32]

VIDEO_MEMORY equ 0xB8000       ; vga text mode buffer       
WHITE_ON_BLACK equ 0x0F            

print32_string:
    pushad                     ; save all 32-bit registers                

    mov eax, [cursor_pos]      ; load current position offset       
    mov edx, VIDEO_MEMORY      ; base address of video memory      
    add edx, eax               ; edx = video memory + offset     

.print32_loop:
    mov al, [ebx]              ; load character from string                  
    cmp al, 0                       
    je .end_print32_loop                        
    
    mov ah, WHITE_ON_BLACK          
    mov [edx], ax              ; write char (al) and color (ah)                

    add ebx, 1                 ; next character in string           
    add edx, 2                 ; next position (2 bytes per char)      
    
    jmp .print32_loop                       

.end_print32_loop:
    mov eax, edx               ; current video memory address     
    sub eax, VIDEO_MEMORY      ; convert to offset from start     
    mov [cursor_pos], eax      ; save for next print       
    
    popad                           
    ret

print32_newline:
    pushad

    mov eax, [cursor_pos]      
    mov ebx, eax               

    mov ecx, 160               
    xor edx, edx
    div ecx                    

    inc eax                    
    mov ebx, eax
    imul ebx, 160              

    mov [cursor_pos], ebx

    popad
    ret

print32_hex:
    pushad
    
    mov ecx, 8                      
    mov edi, eax                    
    
.print32_hex_loop:
    rol edi, 4                      
    mov eax, edi
    and eax, 0x0F                   
    
    cmp eax, 9
    jle .print32_zero_digit
    add eax, 'A' - 10               
    jmp .print32_hex_string

.print32_zero_digit:
    add eax, '0'                    
    
.print32_hex_string:
    push ecx
    push edi
    
    mov edi, [cursor_pos]
    add edi, VIDEO_MEMORY
    mov ah, WHITE_ON_BLACK
    mov [edi], ax
    add dword [cursor_pos], 2
    
    pop edi
    pop ecx
    
    dec ecx
    jnz .print32_hex_loop
    
    popad
    ret