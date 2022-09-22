SECTION .data
    SYS_EXIT EQU 1
    SYS_READ EQU 3
    SYS_WRITE EQU 4

    STDIN EQU 2 
    STDOUT EQU 1

    msg1 db "Num 1: ", 0x0
    
    msg2 db "Num 2: ", 0x0
    
    msg3 db "Sum = ", 0x0
    
    endl db 0xA, 0xD, 0x0

SECTION .bss
    num1 resb 20
    num2 resb 20
    sum resb 21

SECTION .text
    global _start

_start:
    mov eax, msg1
    call _sprint
    
    mov eax, num1
    call _sscan

    mov eax, msg2
    call _sprint

    mov eax, num2
    call _sscan

    call _calc

    mov eax, msg3
    call _sprint

    mov eax, [sum]
    call _iprint

    mov eax, endl
    call _sprint

    call _exit
 
_strlen:
    push ebx
    mov ebx, eax
.next:
    cmp BYTE [eax], 0x0
    je .done
    inc eax
    jmp .next
.done:
    sub eax, ebx
    pop ebx
    ret

_sscan:
    push edx
    push ecx
    push ebx

    mov edx, 20
    mov ecx, eax
    mov ebx, STDIN
    mov eax, SYS_READ
    int 0x80

    pop ebx
    pop ecx
    pop edx
    ret


_sprint:
    push edx
    push ecx
    push ebx
    push eax
    call _strlen

    mov edx, eax
    pop eax

    mov ecx, eax
    mov ebx, STDOUT
    mov eax, SYS_WRITE
    int 0x80

    pop ebx
    pop ecx
    pop edx
    ret

_calc:
    push eax
    push esi
    push edi

    mov eax, num1
    call _atoi
    mov esi, eax

    mov eax, num2
    call _atoi
    mov edi, eax

    add esi, edi
    mov [sum], esi
    
    pop edi
    pop esi
    pop eax
    ret

_atoi:
    push ebx
    push ecx
    push edx
    push esi
    mov esi, eax
    mov eax, 0
    mov ecx, 0
.multiLoop:
    xor ebx, ebx
    mov bl, [esi + ecx]
    cmp bl, 0x30    ;ASCII '0'
    jl .next
    cmp bl, 0x39    ;ASCII '9'
    jg .next

    sub bl, 0x30    ;convert ASCII to Integer
    add eax, ebx
    mov ebx, 10
    mul ebx
    inc ecx
    jmp .multiLoop
.next:
    cmp ecx, 0
    je .done
    mov ebx, 10
    div ebx
.done:
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret


_iprint:
    push eax
    push ecx
    push edx
    push esi
    mov ecx, 0  ;count digits
.divLoop:
    inc ecx
    mov edx, 0
    mov esi, 10     ;divisor
    idiv esi
    add edx, 0x30
    push edx
    cmp eax, 0
    jnz .divLoop

.printLoop:
    dec ecx
    mov eax, esp
    call _sprint
    pop eax
    cmp ecx, 0
    jnz .printLoop

    pop esi
    pop edx
    pop ecx 
    pop eax
    ret
    

_exit:
    mov eax, SYS_EXIT
    xor ebx, ebx        ;return 0
    int 0x80
    ret
