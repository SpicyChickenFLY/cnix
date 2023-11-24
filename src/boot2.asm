org 0x7c00
; same as [org 0x7c00]

; 将ds和es均指向cs位置，方便后续代码的定位
mov ax, cs
mov ds, ax
mov es, ax
call dispStr
jmp $

dispStr:
    mov ax, greeting
    mov bp, ax
    mov cx, 4
    mov ax, 0x1301
    mov bx, 0x001c
    mov dl, 0
    int 0x10
    ret

greeting: db "Cnix"

times 510- ($-$$) db 0
dw 0xaa55
