sys_exit equ 1
sys_read equ 3
sys_write equ 4

stdin equ 0 
stdout equ 1

MAXSIZE EQU 100

section .data
    msg1 db "So luong phan tu = ", 0h
    msg2 db "Mang = ", 0h
    msg3 db "Sum Odd = ", 0h
    msg4 db "Sum Even = ", 0h

    endl db 0Ah, 0Dh, 0h

section .bss
    n resb 10
    arr resd MAXSIZE
    odd resd 1
    even resd 1
    tmp resb 10

section .text
    global _start

_start:
    push msg1
    call WriteString

    push n
    call ReadString

    push msg2
    call WriteString

    mov edi, n
    call atoi
    push eax
    call ReadArray

    push eax
    call calc

;print odd
    push msg3
    call WriteString

    mov edi, [odd]
    call WriteNum
    push endl
    call WriteString

;print Max
    push msg4
    call WriteString

    mov edi, [even]
    call WriteNum
    push endl
    call WriteString


call _exit


calc:
    push ebp
    mov ebp, esp

    mov byte [even], 0
    mov byte [odd], 0
    
    mov esi, arr
    mov ecx, [ebp + 8]
.L1:
    mov ebx, 2
    mov eax, [esi]
    div ebx
    cmp edx, 0
    jnz .c1
    mov eax, [esi]
    add [even], eax

    .c1:
        add esi, 4
    loop .L1

mov esi, arr
mov ecx, [ebp + 8]
.L2:
    mov ebx, 2
    mov eax, [esi]
    div ebx
    cmp edx, 0
    jz .c2
    mov eax, [esi]
    add [odd], eax

    .c2:
        add esi, 4
    loop .L2

    pop ebp
    ret 4

ReadArray:
    push ebp
    mov ebp, esp
    pushad

mov ecx, [ebp + 8]      ;ecx = n
mov ebx, 0     ;i = 0
.L1:
    push tmp
    call ReadString
    mov edi, tmp
    call atoi
    mov [arr+ebx*4], eax
    inc ebx

    loop .L1

    popad
    pop ebp
    ret 4


WriteNum:
;input: edi
    push ebp
    mov ebp, esp
    pushad

    mov ecx, 0      ;count digit
    mov eax, edi
.L1:
    inc ecx
    mov edx, 0      ;clear edx
    mov esi, 10     
    idiv esi        ;eax /= 10
    add edx, 30h        ;convert remainder to ascii
    push edx    ;push remainder onto stack
    cmp eax, 0
    jnz .L1         ;if eax != 0 => loop L1

.L2:
    dec ecx 
    mov esi, esp
    push esi
    call WriteString
    pop esi
    cmp ecx, 0
    jnz .L2

    popad
    pop ebp
    ret


atoi:
   ; int result = 0
   mov eax, 0              ; Set initial total to 0
     
.convert:
   ;mov input[i] to esi 
   movzx esi, byte [edi]   ; Get the current character
   cmp esi, 0Ah          ; Check for \n
   je .done
   test esi, esi           ; Check for end of string 
   je .done
   
   cmp esi, 30h             ; Anything less than 0 is invalid
   jl .error
    
   cmp esi, 39h          	; Anything greater than 9 is invalid
   jg .error
   
   sub esi, 30h             ; Convert from ASCII to decimal 
   imul eax, 10            ; Multiply total by 10
   add eax, esi            ; Add current digit to total
    
   inc edi                 ; Get the address of the next character
   jmp .convert

.error:
   mov eax, -1             ; Return -1 on error
 
.done:
   ret                     ; Return total or error code


ReadString:
    push ebp
    mov ebp,esp
    pushad

    mov edx, MAXSIZE
    mov ecx, [ebp + 8]
    mov ebx, stdin
    mov eax, sys_read
    int 80h

    popad
    pop ebp
    ret 4


WriteString:
    push ebp
    mov ebp, esp
    pushad

    mov esi, [ebp + 8]
    push esi
    call strlen

    mov edx, eax
    mov ecx, [ebp + 8]
    mov ebx, stdout
    mov eax, sys_write
    int 80h

    popad
    pop ebp
    ret 4


strlen:
    push ebp
    mov ebp, esp
    push edi
    
    mov edi, [ebp + 8]
    mov eax, 0
.L1:
    cmp byte [edi], 0
    je .L2
    inc edi
    inc eax
    jmp .L1
.L2:
    pop edi
    pop ebp
    ret 4


_exit:
    mov eax, sys_exit
    xor ebx, ebx
    int 80h