sys_exit equ 1
sys_read equ 3
sys_write equ 4

stdin equ 0 
stdout equ 1

MAXSIZE EQU 10

section .data
    msg1 db  "1_Cong", 0Ah, "2_Tru", 0Ah, "3_Nhan", 0Ah, "4_Chia", 0Ah, "5_Thoat", 0Ah, "Nhap lua chon : ", 0h 
    msg2 db "Num1 = ", 0h
    msg3 db "Num2 = ", 0h
    res_msg db "Result = ", 0h 
    remainder_msg db "Remainder = ", 0h

    endl db 0Ah, 0Dh, 0h
    tmp db "----------------------------------", 0Ah, 0Dh, 0h

section .bss
    num1 resb MAXSIZE
    num2 resb MAXSIZE
    choice resb MAXSIZE
    res resd 1
    remainder resd 1

section .text
    global _start

_start:

.repeat:
    push msg1
    call WriteString
    
    push choice
    call ReadString
    mov edi, choice
    call atoi
    mov [choice], eax
    cmp eax, 5
    je .quit

    push msg2
    call WriteString
    push num1
    call ReadString
    mov edi, num1
    call atoi
    mov [num1], eax

    push msg3
    call WriteString
    push num2
    call ReadString
    mov edi, num2
    call atoi
    mov [num2], eax

    mov eax, [choice]
    cmp eax, 1
    je .L1
    cmp eax, 2
    je .L2
    cmp eax, 3
    je .L3
    cmp eax, 4
    je .L4


.quit:
    call _exit

.L1:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sum
    jmp .repeat

.L2:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sub
    jmp .repeat

.L3:
    mov esi, [num1]
    mov edi, [num2]
    call calc_mul
    jmp .repeat

.L4:
    mov esi, [num1]
    mov edi, [num2]
    call calc_div
    jmp .repeat





calc_sum:
    push ebp
    mov ebp, esp

    mov eax, esi
    add eax, edi
    mov [res], eax
    
    push res_msg
    call WriteString
    mov edi, [res]
    call WriteNum
    push endl
    call WriteString
    push tmp
    call WriteString

    pop ebp
    ret

calc_sub:
    push ebp
    mov ebp, esp

    mov eax, esi
    sub eax, edi
    mov [res], eax

    push res_msg
    call WriteString
    mov edi, [res]
    call WriteNum
    push endl
    call WriteString
    push tmp
    call WriteString

    pop ebp
    ret

calc_mul:
    push ebp
    mov ebp, esp

    mov eax, esi
    mul edi
    mov [res], eax

    push res_msg
    call WriteString
    mov edi, [res]
    call WriteNum
    push endl
    call WriteString
    push tmp
    call WriteString

    pop ebp
    ret

calc_div:
    push ebp
    mov ebp, esp

    mov eax, esi
    div edi
    mov [res], eax
    mov [remainder], edx

    push res_msg
    call WriteString
    mov edi, [res]
    call WriteNum
    push endl
    call WriteString

    push remainder_msg
    call WriteString
    mov edi, [remainder]
    call WriteNum
    push endl
    call WriteString

    push tmp
    call WriteString

    pop ebp
    ret


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