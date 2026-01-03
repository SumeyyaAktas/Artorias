; After switching to protected mode, BIOS interrupts 
; are unavailable. We must interact directly with the VGA text 
; buffer via Memory Mapped I/O (MMIO).

[bits 32]

VIDEO_MEMORY equ 0xB8000       
WHITE_ON_BLACK equ 0x0F            

; This takes in ebx, which is the address of null-terminated 
; string. This assumes that a cursor_pos variable exists in 
; the data segment to track state.
print32_string:
    pushad                                

    mov eax, [cursor_pos]      
    mov edx, VIDEO_MEMORY     
    add edx, eax               

.print32_loop:
    mov al, [ebx]                        
    cmp al, 0                       
    je .end_print32_loop                        
    
    ; Each character in the buffer occupies 2 bytes.
    ; Byte 0 - ASCII character
    ; Byte 1 - Attribute (color)
    mov ah, WHITE_ON_BLACK          
    mov [edx], ax                     

    add ebx, 1                   
    add edx, 2                      
    
    jmp .print32_loop                       

.end_print32_loop:
    ; Update persistent cursor position so the next print call resumes correctly.
    mov eax, edx               
    sub eax, VIDEO_MEMORY      
    mov [cursor_pos], eax       
    
    popad                           
    ret

print32_newline:
    pushad

    mov eax, [cursor_pos]      
    mov ebx, eax               

    ; Each row is 80 characters * 2 bytes per character.
    mov ecx, 160               
    xor edx, edx
    div ecx                  ; eax = current row, edx = current col offset             

    ; Move to the first column of the next row
    inc eax                    
    mov ebx, eax
    imul ebx, 160              

    mov [cursor_pos], ebx

    popad
    ret

; This takes eax, which is the value to print. 
; This is critical for debugging EHCI memory-mapped registers and memory addresses.
print32_hex:
    pushad
    
    mov ecx, 8               ; 8 nibbles in a 32-bit register                 
    mov edi, eax                    
    
.print32_hex_loop:
    ; Process high nibble first (bits 28-31)
    rol edi, 4                      
    mov eax, edi
    and eax, 0x0F                   
    
    ; Convert 0-F to ASCII 0-9 or A-F
    cmp eax, 9
    jle .print32_zero_digit
    add eax, 'A' - 10               
    jmp .print32_hex_string

.print32_zero_digit:
    add eax, '0'                    
    
.print32_hex_string:
    push ecx
    push edi
    
    ; Inline write to VGA buffer to avoid overhead of calling print32_string
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