.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

MAXBUF EQU 100

.data
	msg1 byte "So luong phan tu = ", 0
    msg2 byte "Mang: ", 0Ah, 0Dh, 0
    msg3 db "Sum Odd = ", 0
    msg4 byte "Sum Even = ", 0

    endl byte 0Ah, 0Dh, 0

	num dword ?
	arr dword MAXBUF dup(0), 0
	sumOdd dword ?
	sumEven dword ?
	tmp byte 10 dup(0), 0

.code
main proc
	mov edx, offset msg1
	mov ecx, sizeof msg1
	call WriteString

	call ReadDec
	mov num, eax

	mov edx, offset msg2
	mov ecx, sizeof msg2
	call WriteString

	push num
	call ReadArray

	push num
	call calc

;print sum odd
    mov edx, offset msg3
	mov ecx, sizeof msg3
    call WriteString

    mov eax, sumOdd
    call WriteDec
    mov edx, offset endl
	mov ecx, sizeof endl
    call WriteString

;print sum even
    mov edx, offset msg4
	mov ecx, sizeof msg4
    call WriteString

    mov eax, sumEven
    call WriteDec
    mov edx, offset endl
	mov ecx, sizeof endl
    call WriteString

	
	mov ecx, 0
	call ExitProcess

main endp



calc proc
    push ebp
    mov ebp, esp

    mov sumEven, 0			;sumEven = 0
    mov sumOdd, 0		;sumOdd = 0
    
    lea esi, dword ptr [arr]			;point to array
    mov ecx, dword ptr [ebp + 8]	;ecx = n
L1:
    mov ebx, 2			;divisor
	mov edx, 0				;clear remainder
    mov eax, [esi]
	div ebx			;eax /= ebx
    cmp edx, 0
    jnz c1				;if eax ! 0 jmp to c1
    mov eax, [esi]
    add sumEven, eax		;sumEven += eax
    c1:
        add esi, 4		;point to the next element
    loop L1

lea esi, dword ptr [arr]
mov ecx, dword ptr [ebp + 8]
L2:
    mov ebx, 2
	mov edx, 0
    mov eax, [esi]
    div ebx
    cmp edx, 0
    jz c2
    mov eax, [esi]
    add sumOdd, eax

    c2:
        add esi, 4
    loop L2

    pop ebp
    ret 4

calc endp



ReadArray proc
	push ebp
	mov ebp, esp

	mov ecx, dword ptr [ebp + 8]		;ecx = n
	mov ebx, 0	;i = 0
L1:
	call ReadDec
	mov [arr+ebx*4], eax		;arr[i] = eax
	inc ebx	;i++
	loop L1

	pop ebp
	ret 4


ReadArray endp


Strlen proc 
	; return eax = length 
	push ebp 
	mov ebp, esp 
	push edi 

	mov edi, dword ptr [ebp + 8]
	mov eax, 0
L1:
	cmp byte ptr [edi], 0		; if [edi] = NULL => break
	je L2 
	inc edi 
	inc eax 
	jmp L1 
L2:
	pop edi  
	pop ebp 
	ret 4
Strlen endp 

end main