.386
.model	flat, stdcall
.stack	4096
option casemap:none


include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib


.data
	msg1 byte "String = ", 0
	msg2 byte "Rev = ", 0

	string byte 256 dup(?), 0
	rev byte 256 dup(?), 0
	len dword ?
	
	hInput HANDLE ?
	hOutput HANDLE ?

.code
main proc
	
	call GetHandle

	push offset msg1
	call WriteString

	push offset string
	call ReadString
	
	push offset string
	call Strlen
	mov len, eax

	push offset msg2
	call WriteString

	call revStr

	push offset rev
	call WriteString

	mov ecx, 0
	call ExitProcess

main endp


revStr proc
	pushad

	mov esi, offset string
	mov edi, offset rev

	mov eax, len
	dec eax
	add esi, eax
do:	
	mov dl, [esi]
	mov [edi], dl
	cmp eax, 0
	jl quit
	dec eax
	dec esi
	inc edi
	jmp do
quit:
	popad
	ret
	
revStr endp


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