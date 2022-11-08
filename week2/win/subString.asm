.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

.data
	msg1 byte "S = ", 0
	msg2 byte "C = ", 0
	not_found byte "Not found!", 0

	buf1 byte 100 dup(0), 0
	len1 dword ?
	buf2 byte 10 dup(0), 0
	len2 dword ?
	
	res dword 20 dup(?)
	tmp dword 0
	count dword 0


.code
main proc

	mov edx, offset msg1
	call WriteString

	mov edx, offset buf1
	mov ecx, sizeof buf1
	call ReadString
	mov len1, eax

	mov edx, offset msg2
	call WriteString

	mov edx, offset buf2
	mov ecx, sizeof buf2
	call ReadString
	mov len2, eax

	call find_pos

	mov ecx, 0
	call ExitProcess

main endp


find_pos proc

	pushad

	mov edx, len2	;edx = length of substring
	dec edx		

	mov ecx, len1	;ecx = length of string
	mov edi, 0		;edi(i) = 0
	mov ebx, edi	
	L1:		;for1
		mov esi, 0		;esi(j) = 0
		mov al, buf1[edi]
		cmp buf2[esi], al	
		jnz quit2		;if buf1[i] != buf2[0] jump to quit2
		mov tmp, ecx	
		mov ebx, edi	;ebx = i
		mov ecx, len2
		L2:		;for2
			mov al, buf1[ebx]
			cmp al, buf2[esi]
			jnz quit2		;if buf1[i] != buf[j] jump to quit2
			cmp esi, edx	
			jnz quit1		;if j != 1 jump to quit1
			
			mov ebx, count
			mov esi, offset res		;point esi to res[0]
			mov [esi+4*ebx], edi	;res[count] = edi(i)
			inc ebx
			mov count, ebx			;count++
			quit1:
			inc esi		;j++
			inc ebx		;i++
			loop L2
		mov ecx, tmp
		quit2:
		inc edi		;i++
		loop L1

	cmp count, 0
	jnz quit
	mov edx, offset not_found
	mov ecx, sizeof not_found
	call WriteString
	popad
	ret

quit:
	mov eax, count
	call WriteDec
	call Crlf

	mov ecx, count
	mov edx, 0
	L3:	;for	(print position of substring in string)
		mov esi, offset res
		mov eax, [esi+4*edx]
		call WriteDec
		mov al, 20h
		call WriteChar
		inc edx
		loop L3

	popad
	ret 

find_pos endp

end main