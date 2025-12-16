%define load_address 0x7C00            
%define relocate_address 0x0600
%define stage2_address 0x7E00
%define stage2_sectors 8
%define sector_size 512
%define offset_reloc (relocate_address - load_address) 

[org load_address]        
[bits 16]                      

start_boot:
    cli                        
    xor ax, ax                               
    mov ds, ax                                 
    mov es, ax                                  
    mov ss, ax                              
    mov sp, load_address          
 
    mov [boot_drive], dl    

    sti                        

    mov si, load_address       
    mov di, relocate_address   
    mov cx, sector_size        
    cld                        
    rep movsb                  

    jmp 0x0000:(continue_boot + offset_reloc) 

continue_boot:
    call clear_screen  

    mov ah, 0x02                         
    mov al, stage2_sectors          
    mov ch, 0                                          
    mov cl, 2                             
    mov dh, 0                            

    mov dl, [boot_drive + offset_reloc]  
    mov bx, stage2_address              
    int 0x13                   

    jc disk_error                            
    cmp al, stage2_sectors            
    jne disk_error             

    mov bx, stage2_loaded_str + offset_reloc
    call print16_string
    call print16_newline  

    mov dl, [boot_drive + offset_reloc]
    jmp 0x0000:stage2_address                    

disk_error:
    mov bx, disk_error_str + offset_reloc
    call print16_string
    call print16_newline

halt:
    mov bx, system_halted_str + offset_reloc
    call print16_string
    call print16_newline
    cli                           
    hlt                                         
    jmp halt                   

clear_screen:
    pusha                                     
    mov ah, 0x00                      
    mov al, 0x03               
    int 0x10                         
    popa                                        
    ret 

%include "boot/print16_string.asm"    

stage2_loaded_str: db 'Stage 2 loaded successfully', 0
disk_error_str: db 'Error: Disk read error', 0
system_halted_str: db 'System halted', 0

boot_drive: db 0

times 446 - ($ - $$) db 0
times 64 db 0             
dw 0xAA55