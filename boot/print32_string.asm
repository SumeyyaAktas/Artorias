[bits 32]

VIDEO_MEMORY equ 0xB8000       
WHITE_ON_BLACK equ 0x0F            

print32_string:
    pushad                                

    mov eax, [cursor_pos]      
    mov edx, VIDEO_MEMORY     
    add edx, eax               

.print32_loop:
    mov al, [ebx]                        
    cmp al, 0                       
    je .end_print32_loop                        
    
    mov ah, WHITE_ON_BLACK          
    mov [edx], ax                     

    add ebx, 1                   
    add edx, 2                      
    
    jmp .print32_loop                       

.end_print32_loop:
    mov eax, edx               
    sub eax, VIDEO_MEMORY      
    mov [cursor_pos], eax       
    
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