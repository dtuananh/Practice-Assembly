sys_exit equ 1
sys_read equ 3
sys_write equ 4

stdin equ 0
stdout equ 1

MAXBUF EQU 20
section .data
    msg1 db "N = ", 0h
    msg2 db "N so fibonacci dau tien = ", 0h

	white_space db "    ", 0h
    endl db 0Ah, 0Dh, 0h

section .bss
	n resb 10

    num1 resb MAXBUF
    num2 resb MAXBUF
    sum resb MAXBUF+1

section .text
    global _start

_start:
    push msg1
    call WriteString

    push n
    call ReadString
	mov edi, n
	call atoi

    push msg2
    call WriteString

	push eax
	call fibo

	push endl
	call WriteString

call _exit


fibo:
	push ebp
	mov ebp, esp

	mov byte [num1], 30h
	mov byte [num2], 31h

mov ecx, [ebp + 8]
;print f[0]
	push num1
	call WriteString
	push white_space
	call WriteString
	cmp ecx, 0
	je .quit

;print f[1]
	push num2
	call WriteString
	push white_space
	call WriteString
	cmp ecx, 1
	je .quit

sub ecx, 2
.L1:
	push sum
	push num2
	push num1
	call bigsum

	push eax
	call WriteString

	push white_space
	call WriteString

;num1 = num2
	push num2
  push num1
  call strcpy

;num2 = sum
	push eax
  push num2
  call strcpy

	loop .L1


.quit:
	pop ebp
	ret 4

strcpy:
  push ebp
  mov ebp, esp
  pushad

  mov  edx, [ebp + 12] ; source
  mov  cl, byte [edx]
  test cl, cl
  mov  eax, [ebp+8] ; destination
  je .L2

  .L1:
  mov  byte [eax], cl
  mov  cl, byte [edx+1]
  inc  eax
  inc  edx
  test cl, cl
  jne   .L1

  .L2:
  mov byte [eax], 0
  popad
  pop ebp
  ret 8


bigsum:
    push ebp
	mov ebp, esp
	sub esp, 8
	push ecx

	mov esi, [ebp + 8]		;offset num1
	mov edi, [ebp + 12]		;offset num2

xor eax, eax
	push esi
	call strlen
	mov [ebp - 4], eax		;len1

xor eax, eax
	push edi
	call strlen
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
	pop ecx
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

xor eax,eax
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

atoi:
   ; int result = 0
   mov eax, 0              ; Set initial total to 0

convert:
   ;mov input[i] to esi
   movzx esi, byte [edi]   ; Get the current character
   cmp esi, 0x0A          ; Check for \n
   je done
   test esi, esi           ; Check for end of string
   je done

   cmp esi, 48             ; Anything less than 0 is invalid
   jl error

   cmp esi, 57             ; Anything greater than 9 is invalid
   jg error

   sub esi, 48             ; Convert from ASCII to decimal
   imul eax, 10            ; Multiply total by 10
   add eax, esi            ; Add current digit to total

   inc edi                 ; Get the address of the next character
   jmp convert

error:
   mov eax, -1             ; Return -1 on error

done:
   ret                     ; Return total or error code
