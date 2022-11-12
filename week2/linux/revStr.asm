section .data
	msg1 db "Enter a string: ", 0x0
	len1 equ $- msg1
	
section .bss
	string resb 100
	len resd 1
	
section .text
	global _start

_start:
	
; Displaying msg1
	mov eax, msg1
	call _sPrint

; Read stdin
	mov eax, string
	call _scanStr

	xor eax, eax		; eax = 0	
	mov eax, string
	call _strlen
	mov [len], eax
	
	xor eax, eax
	mov eax, string
	call _revStr
	
; Print rev-string
	xor eax, eax
	mov eax, string
	call _sPrint

; Exit	
	call _quit

_revStr:
	push ebx
	mov ebx, eax
	
	mov esi, 0
	mov edi, 0
	mov ecx, [len]
	mov esi, eax
	mov edi, eax
	add edi, [len]
	dec edi
	.rev:
		cmp esi, edi
		jg .finished
		mov cl, [esi]
		mov ch, [edi]
		mov [esi], ch
		mov [edi], cl
		inc esi
		dec edi
		jmp .rev
	
	.finished:		
		sub eax, ebx
		inc edi
		sub edi, [len]
		mov eax, edi
		pop ebx
		ret


_scanStr:
	push edx
	push ecx
	push ebx
	push eax
	
	mov edx, 255
	pop eax
	
	mov ecx, eax
	mov ebx, 0
	mov eax, 3
	int 0x80
	
	pop ebx
	pop ecx
	pop edx
	ret



; Print string	
_sPrint:
	push edx
	push ecx
	push ebx
	push eax
	call _strlen
	
	mov edx, eax
	pop eax
	
	mov ecx, eax
	mov ebx, 1
	mov eax, 4
	int 0x80
	
	pop ebx
	pop ecx
	pop edx
	ret
	
; End program
_quit:
	xor ebx, ebx
	mov eax, 1
	int 0x80
	ret
    
    
_strlen:
  push ebx
  mov ebx, eax
 
  .nextChar:
	cmp byte [eax], 0x0
	jz .finished
	inc eax
	jmp .nextChar
 
  .finished:
	sub eax, ebx
	pop ebx
	ret