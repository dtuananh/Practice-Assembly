.386
.model flat, stdcall
.stack 4096
option Casemap:None

include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib

NULL equ 0

.data
	msg1 db "S = ", 0
	msg2 db "C = ", 0
	not_found db "Not found!", 0
	
	String db 100 DUP(0), 0
	SubString db 10 DUP(0), 0
	res dd 20 DUP(?)
	
	len1 dd ?
	len2 dd ?
	count dd 0
	tmp dd 0
	
	endl db 0dh, 0ah, 0
	white_space db 20h, 0
	
	hInput HANDLE ?
	hOutput HANDLE ?

.code
main proc
	; to get handle
	call GetHandle
	
	; print "S = "
	push offset msg1
	call WriteString
	; read String from user
	push offset String
	call ReadString
	
	;print "C = "
	push offset msg2
	call WriteString
	; read SubString from user
	push offset SubString
	call ReadString
	
	push offset String
	call Strlen
	sub eax, 2		;remove '\0' and '0Ah'
	mov len1, eax
	push offset SubString
	call Strlen
	sub eax, 2		;remove '\0' and '0Ah'
	mov len2, eax
	
	call find_pos
	
	
	push NULL
	call ExitProcess
main endp


find_pos proc
	pushad

	mov edx, len2
	dec edx

	mov ecx, len1
	mov edi, 0
	mov ebx, edi
	L1:
		mov esi, 0
		mov al, String[edi]
		cmp SubString[esi], al
		jnz quit3
		mov tmp, ecx
		mov ebx, edi
		mov ecx, len2
		L2:
			mov al, String[ebx]
			cmp al, SubString[esi]
			jnz quit2
			cmp esi, edx
			jnz quit1
			
			mov ebx, count
			mov esi, offset res
			mov [esi+4*ebx], edi
			inc ebx
			mov count, ebx
			quit1:
			inc esi
			inc ebx
			loop L2
	quit2:
		mov ecx, tmp
		quit3:
		inc edi
		loop L1

	cmp count, 0
	jnz quit
	push offset not_found
	call WriteString
	popad
	ret

	quit:
		push count 
		call WriteNumber
	
		push offset endl
		call WriteString
	
		mov ecx, count
		mov edx, 0
		L3:
			mov esi, offset res
			push [esi+4*edx]
			call WriteNumber
			push offset white_space
			call WriteString
			inc edx
			loop L3

		popad
		ret 
	
find_pos endp


GetHandle proc
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov hInput, eax		;hInput = eax

	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov hOutput, eax		;hOutput = eax
	
	ret
GetHandle endp


ReadString proc
	push ebp
	mov ebp, esp
	sub esp, 4
	pushad
	
	push NULL						;pInputControl = NULL
	lea ebx, DWORD PTR [ebp - 4]
	push ebx						;lpNumberOfCharsRead = [ebp - 4]
	push 100						;nNumberOfCharsToRead = MAXBUF = 100
	push DWORD PTR [ebp + 8] 		;lpBuffer = [ebp + 8]
	push hInput						;hConsoleInput
	call ReadConsole
	
	popad
	add esp, 4
	pop ebp
	ret 4
	
ReadString endp


WriteString proc
	push ebp
	mov ebp, esp
	sub esp, 4			;allocated space for lpNumberOfCharsWritten
	pushad				;push EAX, ECX, EDX, EBX, EBP, ESP, EBP, ESI, EDI onto the stack
	
	push DWORD PTR [ebp + 8]
	call Strlen
	
	push NULL							;lpReserved = NULL
	lea ebx, DWORD PTR [ebp - 4]		
	push ebx							;lpNumberOfCharsWritten = [ebp - 4]
	push eax							;nNumberOfCharsToWrite = eax = Strlen
	push DWORD PTR [ebp + 8]			;*lpBuffer = [ebp + 8]
	push hOutput							;hConsoleOutput
	call WriteConsole
	
	popad
	add esp, 4
	pop ebp
	ret 4
	
WriteString endp


WriteNumber proc
	push ebp
	mov ebp, esp
    pushad
    mov ecx, 0  ;count digits
	mov eax, DWORD PTR [ebp + 8]
divLoop:
    inc ecx
    mov edx, 0
    mov esi, 10     ;divisor
    idiv esi		
    add edx, 30h	;convert to integer
    push edx		;push onto stack
    cmp eax, 0		;if eax == 0 => break
    jnz divLoop
	
printLoop:
    dec ecx
    mov eax, esp
	push eax
	call WriteString
    pop eax
	inc ebx
    cmp ecx, 0
    jnz printLoop
	
	popad
	pop ebp
    ret 4
	
WriteNumber endp


Strlen proc
	push ebp
	mov ebp, esp
	push edi
	
	mov edi, DWORD PTR [ebp + 8]
	mov eax, 0
L1:
	cmp BYTE PTR [edi], NULL		;if [edi] == NULL => break
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