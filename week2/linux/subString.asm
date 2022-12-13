section .data
    SYS_EXIT EQU 1
    SYS_READ EQU 3
    SYS_WRITE EQU 4

    STDIN EQU 0
    STDOUT EQU 1

    msg1 db "S = ", 0x0
    msg2 db "C = ", 0x0
    not_found db "Not found!", 0xA, 0xD, 0x0

    white_space db 0x20, 0x0
    endl db 0xa, 0xd, 0x0

    tmp dd 0
    count dd 0

section .bss
    buf1 resb 100,
    buf2 resb 10,
    res resd 20,

    len1 resd 1
    len2 resd 1


section .text
    global _start

_start:
    mov eax, msg1
    call _sprint

    mov eax, buf1
    call _sscan

    mov eax, buf1
    call _strlen
    mov [len1], eax

    mov eax, msg2
    call _sprint

    mov eax, buf2
    call _sscan

    mov eax, buf2
    call _strlen
    mov [len2], eax

    call _find_pos

    call _exit


_find_pos:

	pushad

	mov edx, [len2]	;edx = length of substring
	sub edx,2

	mov ecx, [len1]	;ecx = length of string
    dec ecx
	mov edi, 0		;edi(i) = 0
	mov ebx, edi
	.L1:		;for1
		mov esi, 0		;esi(j) = 0
		mov al, [buf1+edi]
		cmp [buf2+esi], al
		jnz .quit3		;if buf1[i] != buf2[0] jump to quit2
		mov [tmp], ecx
		mov ebx, edi	;ebx = i
		mov ecx, [len2]
        dec ecx
		.L2:		;for2
			mov al, [buf1+ebx]
			cmp al, [buf2+esi]
			jnz .quit2		;if buf1[i] != buf[j] jump to quit2
			cmp esi, edx
			jnz .quit1		;if j != 1 jump to quit1

			mov ebx, [count]
			mov esi, res		;point esi to res[0]
			mov [esi+4*ebx], edi	;res[count] = edi(i)
			inc ebx
			mov [count], ebx			;count++
			.quit1:
			inc esi		;j++
			inc ebx		;i++
			loop .L2
	.quit2:
	mov ecx, [tmp]
    .quit3:
    inc edi		;i++
    loop .L1

	mov eax, [count]
	cmp eax, 0
	jnz .quit
	mov eax, not_found
    call _sprint
	popad
	ret

.quit:
	mov eax, [count]
	call _iprint

    mov eax, endl
    call _sprint

	mov ecx, [count]
	mov edx, 0
	.L3:	;for	(print position of substring in string)
		mov esi, res
		mov eax, [esi+4*edx]
		call _iprint
		mov eax, white_space
        call _sprint
		inc edx
		loop .L3

    mov eax, endl
    call _sprint

	popad
	ret



_sscan:
    push edx
    push ecx
    push ebx

    mov edx, 100
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


_exit:
    mov eax, SYS_EXIT
    xor ebx, ebx        ;return 0
    int 0x80
