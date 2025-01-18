[bits 32]

VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

print_s32:
    pusha
    mov edx, VIDEO_MEMORY
    mov ah, WHITE_ON_BLACK

_next_char32:
    mov al, [ebx]

    cmp al, 0
    je _done32

    mov [edx], ax

    add ebx, 1
    add edx, 2

    jmp _next_char32

_done32:
    popa
    ret