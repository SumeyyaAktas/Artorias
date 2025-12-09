[bits 32]
[org 0x1000]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

kernel_entry:
    mov byte [VIDEO_MEMORY], ' '
    mov byte [VIDEO_MEMORY + 1], 0x0f    

    mov edi, VIDEO_MEMORY + 2
    mov ecx, (80 * 25) - 1
    mov ax, 0x0F20              
    rep stosw

    mov eax, [VIDEO_MEMORY]

    mov esi, kernel_msg
    mov edi, VIDEO_MEMORY + 2
    call print_string

    mov esi, usb_msg
    mov edi, VIDEO_MEMORY + 160
    call print_string

    mov eax, [VIDEO_MEMORY + 160]

    cli
    hlt
    jmp $

print_string:
    push eax
    push edi

.loop:
    lodsb
    cmp al, 0
    je .done
    mov ah, WHITE_ON_BLACK
    stosw
    jmp .loop
    
.done:
    pop edi
    pop eax
    ret

kernel_msg: db 'KERNEL LOADED! Hello from 32-bit protected mode!', 0
usb_msg: db 'Initializing PCI enumeration for USB EHCI driver...', 0

times 8192 - ($ - $$) db 0