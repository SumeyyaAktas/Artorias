[org 0x7E00]
[bits 16]

%define KERNEL_OFFSET 0x1000
%define KERNEL_SEGMENT 0x0000
%define KERNEL_SECTORS 16           

start_stage2:
    mov [boot_drive], dl
    
    mov bx, real_mode_str
    call print16_string
    call print16_newline

    call enable_a20
    
    mov bx, loading_kernel_str
    call print16_string
    call print16_newline

    mov cx, 3                                     
                       
.load_retry:
    push cx                    

    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13

    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov bx, KERNEL_OFFSET
    
    mov ah, 0x02               
    mov al, KERNEL_SECTORS     
    mov ch, 0                  
    mov cl, 10                 
    mov dh, 0                  
    mov dl, [boot_drive]
    int 0x13
    
    pop cx                
    jnc .load_success         

    mov bx, retry_str
    call print16_string
    loop .load_retry      
    jmp .disk_error

.load_success:
    mov ax, [KERNEL_OFFSET]
    cmp ax, 0
    je .disk_error
    
    mov bx, kernel_loaded_str
    call print16_string
    call print16_newline
    
    mov bx, switching_pm_str
    call print16_string
    call print16_newline

    mov dword [cursor_pos], 480  
    
    call switch_to_pm

.disk_error:
    mov bx, kernel_error_str
    call print16_string
    call print16_newline
    cli
    hlt
    jmp $

enable_a20:
    pusha
    in al, 0x92
    or al, 2
    out 0x92, al
    popa
    ret

[bits 32]

begin_pm:
    mov ebx, protected_mode_str
    call print32_string
    call print32_newline
    
    mov ebx, jumping_kernel_str
    call print32_string
    call print32_newline

    jmp CODE_SEG:KERNEL_OFFSET             

%include "boot/print16_string.asm"
%include "boot/print32_string.asm"
%include "boot/gdt.asm"
%include "boot/switch_to_pm.asm"

real_mode_str: db 'Running in 16-bit real mode', 0
loading_kernel_str: db 'Loading kernel from disk...', 0
kernel_loaded_str: db 'Kernel loaded successfully', 0
kernel_error_str: db 'Error: Failed to load kernel', 0
retry_str: db 'Retry...', 0
switching_pm_str: db 'Switching to protected mode...', 0
protected_mode_str: db 'Now in 32-bit protected mode', 0
jumping_kernel_str: db 'Jumping to kernel...', 0

boot_drive: db 0
cursor_pos: dd 0       

times 4096 - ($ - $$) db 0