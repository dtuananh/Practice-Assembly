.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

.data
	msg1 byte "String = ", 0
	msg2 byte "Rev = ", 0

	string byte 256 dup(?), 0
	rev byte 256 dup(?), 0
	len dword ?
	

.code
main proc

	mov edx, offset msg1
	call WriteString

	mov edx, offset string
	mov ecx, sizeof string
	call ReadString
	dec eax				;remove '\0'
	mov len, eax

	mov edx, offset msg2
	call WriteString

	call revStr

	mov edx, offset rev
	call WriteString

	mov ecx, 0
	call ExitProcess

main endp


revStr proc
	pushad

	mov esi, offset string
	mov edi, offset rev

	mov eax, len
	add esi, eax
do:	
	mov dl, [esi]
	mov [edi], dl
	cmp eax, 0
	jl quit		;if eax < 0 goto quit
	dec eax
	dec esi
	inc edi
	jmp do
quit:
	popad
	ret
	
revStr endp

end main