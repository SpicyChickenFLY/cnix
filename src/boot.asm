[org 0x7c00]

mov ax, 3 ; set screen to text mode
int 0x10 ; make BIOS syscall to clean screen

; init segment reg(ds, es, ss),
mov ax, 0
mov ds, ax ; data seg
mov es, ax ; extra seg
mov ss, ax ; stack seg
mov sp, 0x7c00 ; stack pointer

; show "Cnix" by modify byte
; mov ax, 0xb800 ; screen memory
; mov ds, ax
; mov byte[0] , 'C'
; mov byte[2] , 'n'
; mov byte[4] , 'i'
; mov byte[6] , 'x'

; show "Cnix" by using syscall
xchg bx, bx ; bochs magic break point
mov si, title
call print

; block
jmp $

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret


title:
    db "Cnix", 10, 13, 0 ; \n\r EOL

; fill rest with 0
times 510 - ($ - $$) db 0

; master boot sector must end with 0x55 0xaa
db 0x55, 0xaa ; dw 0xaa55
