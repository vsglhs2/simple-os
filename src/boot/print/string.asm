print_s:
    pusha

    mov ah, 0x0e

    start:
    mov cl, [bx]
    cmp cl, 0
    je end

    mov al, [bx]
    int 0x10
    add bx, 1
    jmp start

    end:

    popa
    ret
