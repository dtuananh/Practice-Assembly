sys_exit equ 1
sys_read equ 3
sys_write equ 4

stdin equ 0 
stdout equ 1

MAXBUF EQU 20
section .data
    msg1 db "Num1 = ", 0h
    msg2 db "Num2 = ", 0h
    msg3 db "Sum = ", 0h

    endl db 0Ah, 0Dh, 0h

section .bss
    num1 resb MAXBUF
    num2 resb MAXBUF
    sum resb MAXBUF+1

section .text
    global _start

_start:
    push msg1
    call WriteString

    push num1
    call ReadString

    push msg2
    call WriteString

    push num2
    call ReadString

    push msg3
    call WriteString

    push sum
    push num2
    push num1
    call bigsum

    push eax
    call WriteString

call _exit


bigsum:
    push ebp
	mov ebp, esp
	sub esp, 8		
	
	mov esi, [ebp + 8]		;offset num1
	mov edi, [ebp + 12]		;offset num2
	
	push esi
	call strlen
    dec eax
	mov [ebp - 4], eax		;len1

xor eax, eax
	push edi
	call strlen
    dec eax
	mov [ebp - 8], eax		;len2

	mov eax, [ebp - 4]
	cmp eax, [ebp - 8]
	jae .L1			;if len1 > len2 jump to L1

	;if len1 < len2 => swap(num1, num2) && swap(len1, l)
	xchg esi, edi

	xchg eax, [ebp - 8]
	mov [ebp - 4], eax
.L1:
	mov eax, [ebp - 4]
	sub eax, [ebp - 8]		;eax = len1 - len2
	cmp eax, 0			;if len1 == len2 jump to L2
	je .L2

	;move num2 to the right eax pos
	add edi, [ebp - 8]
	dec edi
	mov edx, edi
	add edi, eax

	mov ecx, [ebp - 8]
	.L3:
		mov bl, byte [edx]
		mov byte [edi], bl
		dec edi
		dec edx
		loop .L3

	;add '0' to the begin of num2
	mov ecx, eax
	.L4:
		mov byte [edi], 30h
		dec edi
		loop .L4

.L2:
	;read from right to left
	mov esi, [ebp + 8]
	add esi, [ebp - 4]
	dec esi

	mov edi, [ebp + 12]
	add edi, [ebp - 4]
	dec edi

	mov edx, [ebp + 16]
	add edx, MAXBUF
	mov bh, 0			;carry = bh = 0
	
	mov ecx, [ebp - 4]
	.L5:
		mov ah, 0		
		mov al, byte [esi]	;al = num1
		add al, bh				;al += carry
		aaa			;if af = 1 => ah = 1
		mov bh, ah		;carry = ah
		add bh, 30h		;convert to ascii

		add al, byte [edi]	;al += num2
		aaa			;if (al & 0xF) > 9 => ah = 1
		add ah, 30h		;convert to ascii
		or bh, ah	;if bh = 0 && ah = 1 => bh = 1
		add al, 30h		;convert to ascii
		mov byte [edx], al		;sum = al
		dec edx
		dec edi
		dec esi
		loop .L5
	cmp bh, 30h		
	jne .L6			;if bh != 0 jmp to L6
	inc edx		
	jmp .L7			
.L6:
	mov byte [edx], bh		;add carry = '1' to begin of sum
.L7:
	mov eax, edx
	add esp, 8
	pop ebp
	ret 12



ReadString:
    push ebp
    mov ebp,esp
    pushad

    mov edx, MAXBUF
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
    mov ecx, 0
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