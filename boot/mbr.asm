%define load_address 0x7C00            
%define relocate_address 0x0600
%define stage2_address 0x7E00
%define stage2_sectors 8
%define sector_size 512

[org load_address]        
[bits 16]                      ; cpu starts in 16-bit real mode

; entry point where bios jumps here after loading mbr
start_boot:
    cli                        ; disable interrupts during setup

    xor ax, ax                 ; ax = 0                    
    mov ds, ax                 ; data segment = 0                    
    mov es, ax                 ; extra segment = 0                   
    mov ss, ax                 ; stack segment = 0               
    mov sp, load_address       ; stack grows down from 0x7c00     

    ; bios passes boot drive number in dl (0x00 = floppy, 0x80 = hard disk)   
    mov [boot_drive], dl

    sti                        ; re-enable interrupts

    ; relocate mbr from 0x7c00 to 0x0600
    ; to free up 0x7c00-0x7dff for stage 2 bootloader
    mov si, load_address       ; current location 
    mov di, relocate_address   ; destination is 0x0600
    mov cx, sector_size        ; copy 512 bytes
    cld                        ; forward direction
    rep movsb                  ; copy byte by byte

    
    ; jump to relocated code by
    ; calculating the offset (label - load_address + relocate_address)
    jmp 0x0000:(continue_boot - load_address + relocate_address) 

continue_boot:
    call clear_screen  

    ; load stage 2 from disk
    mov ah, 0x02               ; read sectors              
    mov al, stage2_sectors     ; number of sectors to read (8)          
    mov ch, 0                  ; cylinder 0                              
    mov cl, 2                  ; start at sector 2 (sector 1 is mbr)                   
    mov dh, 0                  ; head 0             
    mov dl, [boot_drive - load_address + relocate_address]  
    mov bx, stage2_address              
    int 0x13                   ; call bios

    jc disk_error              ; carry flag set = error              
    cmp al, stage2_sectors     ; verify all sectors were read       
    jne disk_error             ; jump if mismatch

    mov bx, stage2_loaded_str - load_address + relocate_address
    call print16_string
    call print16_newline  

    mov dl, [boot_drive - load_address + relocate_address]

    ; jump to stage 2 bootloader
    jmp 0x0000:stage2_address                    

disk_error:
    mov bx, disk_error_str - load_address + relocate_address
    call print16_string
    call print16_newline

halt:
    mov bx, system_halted_str - load_address + relocate_address
    call print16_string
    call print16_newline

    cli                           
    hlt                        ; halt cpu                        
    jmp halt                   ; halt again in case of nmi 

clear_screen:
    pusha                      ; save all registers                       
    
    mov ah, 0x00               ; set video mode                 
    mov al, 0x03               ; 80x25 text, 16 colors    
    int 0x10                   ; call bios video interrupt                  
    
    popa                       ; restore registers                        
    ret 

%include "boot/print16_string.asm"    

stage2_loaded_str: db 'Stage 2 loaded successfully', 0
disk_error_str: db 'error: disk read error', 0
system_halted_str: db 'System halted', 0

boot_drive: db 0

times 510 - ($ - $$) db 0      ; pad to 510 bytes
dw 0xAA55                      ; boot signature (bytes 510-511)