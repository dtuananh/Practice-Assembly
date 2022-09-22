section .data
    SYS_EXIT EQU 1
    SYS_READ EQU 3
    SYS_WRITE EQU 4

    STDIN EQU 2 
    STDOUT EQU 1

    msg db "Enter a string: ", 0x0
    len_msg equ $-msg

section .bss
    string resb 255

section .text
    global _start

_start:
    ;Print msg
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, msg
    mov edx, len_msg
    int 0x80

    ;User enter string
    mov eax, SYS_READ
    mov ebx, STDIN
    mov ecx, string
    mov edx, 255
    int 0x80

    ;to Uppercase
    mov edx, string
    call _toUpper

    ;print string
    mov eax, SYS_WRITE
    mov ebx, STDOUT
    mov ecx, string
    mov edx, 255
    int 0x80

    ;Exit
    mov eax, SYS_EXIT
    xor ebx, ebx
    int 0x80

_toUpper:
    mov al, [edx]
    cmp al, 0x0
    je done
    cmp al, 0x61
    jb next
    cmp al, 0x7a
    ja next
    sub al, 0x20    ;to Uppercase
    mov [edx], al
    jmp next
next:
    inc edx
    jmp _toUpper
done:
    ret
