section .data
    SYS_EXIT EQU 1
    SYS_READ EQU 3
    SYS_WRITE EQU 4

    STDIN EQU 2 
    STDOUT EQU 1

    msg db "Enter your name: ", 0x0, 0xa
    len equ $-msg
    msg2 db "My name is: ", 0x0, 0xa, 0xd
    len2 equ $-msg2

section .bss
    name resb 50

section .text
    global _start

_start:
;Print msg
mov eax, SYS_WRITE
mov ebx, STDOUT
mov ecx, msg
mov edx, len
int 0x80

;Enter a string
mov eax, SYS_READ
mov ebx, STDIN
mov ecx, name
mov edx, 50
int 0x80

;Print msg2
mov eax, SYS_WRITE
mov ebx, STDOUT
mov ecx, msg2
mov edx, len2
int 0x80

;Print result
mov eax, SYS_WRITE
mov ebx, STDOUT
mov ecx, name
mov edx, 50
int 0x80

;Exit 
mov eax, SYS_EXIT
xor ebx, ebx
int 0x80