_next_char:
    cmp al, 0
    je done

    mov cx, dx
    call _next_hex_char

    mov [bx], cl
    shr dx, 4

    sub bx, 1
    sub al, 1

    jmp _next_char

    done:
        ret

_next_hex_char:
    and cx, 0x000F
    add cl, 0x30

    cmp cl, 0x39
    jle skip
    add cl, 0x07

    skip:
        ret

print_h:
    pusha

    mov dx, bx
    mov bx, _HEX_OUTPUT + 5
    mov al, 4
    call _next_char

    mov bx, _HEX_OUTPUT
    call print_s

    popa
    ret

_HEX_OUTPUT:
    db "0x0000", 0
