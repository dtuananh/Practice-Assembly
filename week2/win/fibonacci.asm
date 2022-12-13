.386
.model	flat, stdcall
.stack	4096
option casemap:none

include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc 
include D:\masm32\include\user32.inc 

includelib D:\masm32\lib\kernel32.lib 
includelib D:\masm32\lib\user32.lib 

MAXBUF EQU 20

.data
	msg1 byte "N = ", 0
	msg2 byte "N so Fibonacci dau tien: ", 0
	
	num byte 10 dup(?), 0

	white_space byte "    ", 0
	endl byte 0Dh, 0Ah, 0


	hInput HANDLE ?
	hOutput HANDLE ?

.code
main proc
	call GetHandle
	push offset msg1
	call WriteString

	push offset num
	call ReadString
	push offset num
	call atoi
	
	push offset msg2
	call WriteString

	push eax
	call fibo

	push 0
	call ExitProcess

main endp


fibo proc
.data
	num1 byte MAXBUF dup(?), 0
	num2 byte MAXBUF dup(?), 0
	sum byte MAXBUF+1 dup(?), 0

.code
	push ebp
	mov ebp, esp
	sub esp, 4
	
	mov dword ptr [num1], 30h
	mov dword ptr [num2], 31h


	;print f[0], f[1]
	push offset num1
	call WriteString
	push offset white_space
	call WriteString

	mov ecx, dword ptr [ebp + 8]
	cmp ecx, 1
	je quit
	
	push offset num2
	call WriteString
	push offset white_space
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

	push eax
	call WriteString

	push offset white_space
	call WriteString

	;num1 = num2
	push offset num2
	push offset num1
	call strcpy	

	;num2 = sum
	push eax
	push offset num2
	call strcpy	
	

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

strcpy PROC 
	push ebp
	mov ebp, esp
	pushad

	mov  edx, dword ptr [ebp + 12] ; source
	mov  cl, byte ptr [edx]
	test cl, cl
	mov  eax, dword ptr [ebp+8] ; destination
	je L2

L1:
	mov  byte ptr [eax], cl
	mov  cl, byte ptr [edx+1]
	inc  eax
	inc  edx
	test cl, cl
	jne   L1

L2:
	mov byte ptr [eax], 0
	popad
	pop ebp
	ret 8
	
strcpy ENDP



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
	jz L2 
	inc edi 
	inc eax 
	jmp L1 
L2:
	pop edi  
	pop ebp 
	ret 4
Strlen endp

atoi proc
	push ebp
	mov ebp, esp
	
	push ebx
	push ecx
	push edx
	push esi
	
    mov esi, DWORD PTR [ebp + 8]
    mov eax, 0
    mov ecx, 0
	
multiLoop:
    xor ebx, ebx
    mov bl, BYTE PTR [esi + ecx]	;search 
    cmp bl, 30h    ;ASCII '0'
    jl next
    cmp bl, 39h    ;ASCII '9'
    jg next

    sub bl, 30h    ;convert ASCII to Integer
    add eax, ebx		;result = eax
    mov ebx, 10		;ebx = 10
    mul ebx			;eax *= ebx
    inc ecx
    jmp multiLoop
	
next:
    cmp ecx, 0		;if ecx == 0 => done
    je done
    mov ebx, 10	
    div ebx
	
done:
    pop esi
	pop edx
	pop ecx
	pop ebx
	pop ebp
    ret 4
	
atoi endp

end main