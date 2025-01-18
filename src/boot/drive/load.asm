load_drive:
    push dx

    mov ah, 0x02
    mov al, dh
    mov dh, 0x00
    mov ch, 0x00
    mov cl, 0x02

    int 0x13
    jc error_branch

    pop dx

    cmp dh, al
    jne error_branch

    ret

    error_branch:
    call _drive_error

    ret

_drive_error:
    mov bx, _DRIVE_ERROR_MSG
    call print_s

    ret

_DRIVE_ERROR_MSG:
    db "Drive read error!", 0