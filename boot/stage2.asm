; The 512-byte MBR is too small for EHCI drivers. Stage 2 provides the
; space needed for complex hardware initialization (like A20) and 
; loading the kernel into memory.

[org 0x7E00]
[bits 16]

; We load the kernel at 0x1000 to keep it in the lower 640KB range, 
; which is guaranteed to be available and safe from BIOS 
; data structures or VGA buffers.
%define KERNEL_OFFSET 0x1000
%define KERNEL_SEGMENT 0x0000
%define KERNEL_SECTORS 16 
%define VGA_THIRD_LINE_OFFSET 480          

start_stage2:
    mov [boot_drive], dl
    
    mov bx, real_mode_str
    call print16_string
    call print16_newline

    ; The A20 line must be enabled to access even-numbered megabytes of 
    ; RAM. Without this, memory access wraps around every 1MB.
    call enable_a20
    
    mov bx, loading_kernel_str
    call print16_string
    call print16_newline

    ; Disk motors or controller timing can cause transient failures.
    ; We implement a 3-try retry mechanism to increase boot reliability.
    mov cx, 3                                     
                       
.load_retry:
    push cx                    

    ; Clears the controller state before a read attempt
    mov ah, 0x00
    mov dl, [boot_drive]
    int 0x13

    mov ax, KERNEL_SEGMENT
    mov es, ax
    mov bx, KERNEL_OFFSET
    
    mov ah, 0x02               
    mov al, KERNEL_SECTORS     
    mov ch, 0 
    ; We skip MBR (1) and stage 2 (8) to reach the kernel at sector 10                 
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
    ; Ensure the first word of the kernel isn't zero.
    ; This catches cases where the BIOS reports success but returns empty data.
    mov ax, [KERNEL_OFFSET]
    cmp ax, 0
    je .disk_error
    
    mov bx, kernel_loaded_str
    call print16_string
    call print16_newline
    
    mov bx, switching_pm_str
    call print16_string
    call print16_newline

    ; We offset the 32-bit cursor so protected mode messages don't overwrite 
    ; the real mode status messages currently on the screen.
    mov dword [cursor_pos], VGA_THIRD_LINE_OFFSET 
    
    call switch_to_pm

.disk_error:
    mov bx, kernel_error_str
    call print16_string
    call print16_newline
    cli
    hlt
    jmp $

; This uses the fast A20 method via system control port A (0x92).
; While faster than the keyboard controller method, it's 
; technically a platform-specific hack that may not work on very old hardware.
enable_a20:
    pusha
    in al, 0x92
    or al, 2                 ; Set bit 1 (A20 fast gate)
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

    ; This performs a far jump to kernel.
    ; It tells it to reload code segment with our 32-bit 
    ; code selector and jump to the kernel's memory location.
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

; Ensures stage 2 occupies exactly 8 sectors (4096 bytes)
; so that the kernel starts at a predictable sector on the disk.
times 4096 - ($ - $$) db 0