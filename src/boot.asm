[org 0x7c00]
KERNEL_OFFSET equ 0x1000

mov bp, 0x9000
mov sp, bp

mov bx, REAL_MODE_MSG
call print_s

mov [BOOT_DRIVE], dl

call load_kernel
call switch_to_protected_mode

jmp $

%include 'print/string.asm'
%include 'print/string32.asm'
%include 'gdt.asm'
%include 'pm.asm'
%include 'drive/load.asm'
%include 'print/hex.asm'

[bits 16]
load_kernel:
    mov bx, KERNEL_LOAD_MSG
    call print_s

    mov bx, KERNEL_OFFSET
    mov dh, 15
    mov dl, [BOOT_DRIVE]
    call load_drive

    ret

[bits 32]
BEGIN_PROTECTED_MODE:
    mov ebx, PROTECTED_MODE_MSG
    call print_s32

    call KERNEL_OFFSET

    jmp $

BOOT_DRIVE:
    db 0
REAL_MODE_MSG:
    db "Started in 16-bit mode", 0
PROTECTED_MODE_MSG:
    db "Landed in 32-bit protected mode", 0    
KERNEL_LOAD_MSG:
    db "Loading kernel into memory", 0      
    
times 510-($-$$) db 0
dw 0xaa55