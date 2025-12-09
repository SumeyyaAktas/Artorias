[org 0x7e00]
[bits 16]

start_stage2:
    mov [boot_drive], dl

    mov bx, real_mode_str
    call print16_string
    call print16_newline

    mov bx, switching_pm_str
    call print16_string
    call print16_newline

    mov ah, 0x03
    mov bh, 0x00
    int 0x10

    xor ax, ax
    mov al, dh
    mov bx, 160
    mul bx
    mov si, ax

    xor ax, ax
    mov al, dl
    shl ax, 1
    add si, ax

    mov [cursor_pos], si

    call switch_to_pm

[bits 32]

begin_pm:
    mov ebx, protected_mode_str
    call print32_string
    
    call pci_scan_usb
    
    cmp byte [usb_controller_found], 0
    je .no_usb
    
    mov ebx, usb_init_str
    call print32_string
    call print32_newline
    
    jmp .halt
    
.no_usb:
    mov ebx, usb_failed_str
    call print32_string
    call print32_newline
    
.halt:
    jmp $

%include "boot/print16_string.asm"
%include "boot/print32_string.asm"
%include "boot/gdt.asm"
%include "boot/switch_to_pm.asm"
%include "boot/pci.asm"                

real_mode_str: db 'Running in 16-bit real mode', 0
switching_pm_str: db 'Switching to protected mode...', 0
protected_mode_str: db 'Now in 32-bit protected mode | ', 0
usb_init_str: db 'USB controller ready for initialization', 0
usb_failed_str: db 'Cannot proceed without USB controller', 0

boot_drive: db 0

cursor_pos: dd 0

usb_controller_found: db 0     ; 1 if found
usb_controller_type: db 0      
usb_controller_bar0: dd 0      ; mmio base address
usb_controller_bus: db 0            
usb_controller_device: db 0            
usb_controller_function: db 0           

times 4096 - ($ - $$) db 0