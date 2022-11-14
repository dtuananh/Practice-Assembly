.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

MAXBUF EQU 20

.data
	msg1 byte "N = ", 0
	msg2 byte "N so Fibonacci dau tien: ", 0
	
	num dword ?

	white_space byte "    ", 0
	endl byte 0Dh, 0Ah, 0


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
	call fibo

	mov ecx, 0
	call ExitProcess

main endp


fibo proc
.data
	num1 byte MAXBUF dup(?), 0
	num2 byte MAXBUF dup(?), 0
	sum byte MAXBUF+1 dup(?), 0

.code
	push ebp
	mov ebp,esp
	sub esp, 4
	
	mov dword ptr [num1], 30h
	mov dword ptr [num2], 31h


	;print f[0], f[1]
	mov edx, offset num1
	mov ecx, sizeof num1
	call WriteString
	mov edx, offset white_space
	mov ecx, sizeof white_space
	call WriteString

	mov ecx, dword ptr [ebp + 8]
	cmp ecx, 1
	je quit
	
	mov edx, offset num2
	mov ecx, sizeof num2
	call WriteString
	mov edx, offset white_space
	mov ecx, sizeof white_space
	call WriteString

	mov ecx, dword ptr [ebp + 8]
	cmp ecx, 2
	je quit

mov dword ptr [ebp - 4], 2
L1:
	
	push offset sum
	push offset num2
	push offset num1
	call bigsum

	mov edx, eax
	call WriteString

	mov edx, offset white_space
	mov ecx, sizeof white_space
	call WriteString

	;num1 = num2
	mov esi, dword ptr [num2]
	mov dword ptr [num1], esi

	;num2 = sum
	mov esi, [eax]
	mov dword ptr [num2], esi

	inc dword ptr [ebp - 4]
	mov edx, dword ptr [ebp - 4]
	cmp edx, dword ptr [ebp + 8]
	je quit
	jmp L1

quit:
	add esp, 4
	pop ebp
	ret 4

fibo endp


bigsum proc
	push ebp
	mov ebp, esp
	sub esp, 8
	push ecx
	
	mov esi, dword ptr [ebp + 8]		;offset num1
	mov edi, dword ptr [ebp + 12]		;offset num2
	
	push esi
	call Strlen
	mov dword ptr [ebp - 4], eax		;len1

	push edi
	call Strlen
	mov dword ptr [ebp - 8], eax		;len2

	mov eax, dword ptr [ebp - 4]
	cmp eax, dword ptr [ebp - 8]
	jae L1			;if len1 > len2 jump to L1

	;if len1 < len2 => swap(num1, num2) && swap(len1, l)
	xchg esi, edi

	xchg eax, dword ptr [ebp - 8]
	mov dword ptr [ebp - 4], eax
L1:
	mov eax, dword ptr [ebp - 4]
	sub eax, dword ptr [ebp - 8]		;eax = len1 - len2
	cmp eax, 0			;if len1 == len2 jump to L2
	je L2

	;move num2 to the left eax pos
	;edx = offset num2, edi = offset num2 + eax
	add edi, dword ptr [ebp - 8]
	dec edi
	mov edx, edi
	add edi, eax

	mov ecx, dword ptr [ebp - 8]
	L3:
		mov bl, byte ptr [edx]
		mov byte ptr [edi], bl
		dec edi
		dec edx
		loop L3

	;add '0' to the begin of num2
	mov ecx, eax
	L4:
		mov byte ptr [edi], 30h
		dec edi
		loop L4

L2:
	;read from right to left
	mov esi, dword ptr [ebp + 8]
	add esi, dword ptr [ebp - 4]
	dec esi

	mov edi, dword ptr [ebp + 12]
	add edi, dword ptr [ebp - 4]
	dec edi

	mov edx, dword ptr [ebp + 16]
	add edx, MAXBUF
	mov bh, 0			;carry = bh = 0
	
	mov ecx, dword ptr [ebp - 4]
	L5:
		mov ah, 0		
		mov al, byte ptr [esi]	;al = num1
		add al, bh				;al += carry
		aaa			;if af = 1 => ah = 1
		mov bh, ah		;carry = ah
		add bh, 30h		;convert to ascii

		add al, byte ptr [edi]	;al += num2
		aaa			;if (al & 0xF) > 9 => ah = 1
		add ah, 30h		;convert to ascii
		or bh, ah	;if bh = 0 && ah = 1 => bh = 1
		add al, 30h		;convert to ascii
		mov byte ptr [edx], al		;sum = al
		dec edx
		dec edi
		dec esi
		loop L5
	cmp bh, 30h		
	jne L6			;if bh != 0 jmp to L6
	inc edx		
	jmp L7			
L6:
	mov byte ptr [edx], bh		;add carry = '1' to begin of sum

L7:
	mov eax, edx
	pop ecx
	add esp, 8
	pop ebp
	ret 12

bigsum endp


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