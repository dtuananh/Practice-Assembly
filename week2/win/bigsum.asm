.386
.model	flat, stdcall
.stack	4096
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc

MAXBUF EQU 20

.data
	msg1 byte "Num1 = ", 0
	msg2 byte "Num2 = ", 0
	msg3 byte "Sum = ", 0

	num1 byte 20 dup(0), 0
	num2 byte 20 dup(0), 0
	sum byte 21 dup(0), 0

	hInput HANDLE ?
	hOutput HANDLE ?

.code
main proc
	call GetHandle	
	push offset msg1
	call WriteString

	push offset num1
	call ReadString
	
	push offset msg2
	call WriteString

	push offset num2
	call ReadString

	push offset msg3
	call WriteString

	push offset sum
	push offset num2
	push offset num1
	call calc

	push eax
	call WriteString

	push 0
	call ExitProcess

main endp

calc proc
	push ebp
	mov ebp, esp
	sub esp, 8		
	
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

	;move num2 to the right eax pos
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
	add edx, 20
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
	add esp, 8
	pop ebp
	ret 12

calc endp


GetHandle proc 
	push STD_INPUT_HANDLE 
	call GetStdHandle 
	mov hInput, eax 

	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov hOutput, eax 
	ret
GetHandle endp 


ReadString proc 
	push ebp
	mov ebp, esp
	sub esp,4 
	pushad 

	push NULL					; pInputControl = NULL 
	lea ebx, dword ptr [ebp - 4]	
	push ebx 					; lpNumberOfCharsRead = ebp - 4
	push MAXBUF 				; nNumberOfCharsToRead = MAXBUF 
	push dword ptr [ebp + 8]	; lpBuffer = offset string 
	push hInput 			; hConsoleInput = hInput
	call ReadConsole 

	;search line feed (0Dh) character and remove it 
	mov edi, dword ptr [ebp + 8]
	mov ecx, MAXBUF 
	cld 						; search forward 
	mov al, 0Dh 
	repne scasb 
	jne L2 						; if not found 0Dh 
	;sub dword ptr [ebp - 4],2 	; 
	dec edi 
	jmp L3 
L2:
	mov edi, dword ptr [ebp + 8]
	add edi, MAXBUF 
L3:	mov byte ptr [edi], 0 		; add null byte 
	
	popad 
	add esp, 4
	pop ebp 
	ret 4
ReadString endp


WriteString proc 
	push ebp
	mov ebp, esp 
	sub esp, 4 
	pushad 
	;get length 
	push dword ptr [ebp + 8]
	call Strlen 

	push NULL 						; lpReserved = NULL 
	lea ebx, dword ptr [ebp - 4]	
	push ebx 						; lpNumberOfCharsWritten = ebp - 4
	push eax 						; nNumberOfCharsToWrite = eax = Str_length
	push dword ptr [ebp + 8]		; lpBuffer = offset string 
	push hOutput 				; hConsoleOutput = hOutput
	call WriteConsole 				

	popad 
	add esp, 4
	pop ebp 
	ret 4
WriteString endp 


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