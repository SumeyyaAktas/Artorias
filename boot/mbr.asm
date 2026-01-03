; The BIOS loads this sector at 0x7C00. We relocate ourselves to 0x0600 
; to free up the 0x7C00-0x7DFF range. This is a standard practice to ensure 
; compatibility with chain-loading other bootloaders or operating systems 
; that strictly expect to be loaded at 0x7C00.

%define LOAD_ADDRESS 0x7C00            
%define RELOCATE_ADDRESS 0x0600
%define STAGE2_ADDRESS 0x7E00
%define STAGE2_SECTORS 8
%define SECTOR_SIZE 512
%define OFFSET_RELOC (RELOCATE_ADDRESS - LOAD_ADDRESS) 

[org LOAD_ADDRESS]        
[bits 16]                      

start_boot:
    cli                      ; Disable interrupts until stack/segments are valid
    xor ax, ax                               
    mov ds, ax                                 
    mov es, ax                                  
    mov ss, ax                              
    mov sp, LOAD_ADDRESS          
 
    ; dl register contains the boot drive id from BIOS.
    ; We save it immediately before any instructions modify it.
    mov [boot_drive], dl    

    sti                        

    ; This is the relocation logic. We do this because moving 
    ; the MBR to 0x0600 prevents memory collisions during 
    ; multi-stage loading.
    mov si, LOAD_ADDRESS       
    mov di, RELOCATE_ADDRESS   
    mov cx, SECTOR_SIZE        
    cld                        
    rep movsb                  

    ; Perform a far jump to the relocated code to update 
    ; the instruction pointer (IP) and ensure 
    ; code segment is synchronized (0x0000).
    jmp 0x0000:(continue_boot + OFFSET_RELOC) 

continue_boot:
    call clear_screen  

    ; This is where we load stage 2 since the 512-byte MBR limit 
    ; is too small for EHCI initialization. We load 8 sectors (4KB) 
    ; immediately following the MBR.
    mov ah, 0x02                         
    mov al, STAGE2_SECTORS          
    mov ch, 0                ; Cylinder 0                            
    mov cl, 2                ; Sector 2 (Sector 1 is the MBR)             
    mov dh, 0                ; Head 0           

    mov dl, [boot_drive + OFFSET_RELOC]  
    mov bx, STAGE2_ADDRESS   ; Destination buffer in memory       
    int 0x13                   

    jc disk_error            ; Carry flag set indicates a BIOS disk failure                
    cmp al, STAGE2_SECTORS   ; BIOS returns number of sectors actually read         
    jne disk_error             

    mov bx, stage2_loaded_str + OFFSET_RELOC
    call print16_string
    call print16_newline  

    ; Pass the boot drive ID to Stage 2 in DL
    mov dl, [boot_drive + OFFSET_RELOC]
    jmp 0x0000:STAGE2_ADDRESS                    

disk_error:
    mov bx, disk_error_str + OFFSET_RELOC
    call print16_string
    call print16_newline

halt:
    mov bx, system_halted_str + OFFSET_RELOC
    call print16_string
    call print16_newline
    cli                      ; Do not allow interrupts while halted         
    hlt                                         
    jmp halt                   

clear_screen:
    pusha                                     
    mov ah, 0x00             ; BIOS set video mode        
    mov al, 0x03             ; 80x25 color text mode
    int 0x10                         
    popa                                        
    ret 

%include "boot/print16_string.asm"    

stage2_loaded_str: db 'Stage 2 loaded successfully', 0
disk_error_str: db 'Error: Disk read error', 0
system_halted_str: db 'System halted', 0

boot_drive: db 0

; 446 bytes - Bootstrap code area
; 64 bytes - Partition table (reserved/empty here)
; 2 bytes - Boot signature 0xAA55
times 446 - ($ - $$) db 0
times 64 db 0             
dw 0xAA55