[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

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

    mov eax, edx
    sub eax, VIDEO_MEMORY    
    mov [cursor_pos], eax

    jmp .print32_loop

.end_print32_loop:
    mov eax, [cursor_pos]
    shr eax, 1               

    mov ebx, eax            
    and ebx, 0xffff         

    mov dx, 0x3d4
    mov al, 0x0f            
    out dx, al
    mov dx, 0x3d5
    mov al, bl              
    out dx, al

    mov dx, 0x3d4
    mov al, 0x0e            
    out dx, al
    mov dx, 0x3d5
    mov al, bh              
    out dx, al

    popad
    ret