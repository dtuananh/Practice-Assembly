.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

MAXBUF EQU 100

.data
	msg1 byte "So luong phan tu = ", 0
    msg2 byte "Mang: ", 0Ah, 0Dh, 0
    msg3 db "Min = ", 0
    msg4 byte "Max = ", 0

    endl byte 0Ah, 0Dh, 0

	num dword ?
	arr dword MAXBUF dup(0), 0
	min dword ?
	max dword ?
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
	call findMinMax
	mov min, eax
	mov max, edx

;print Min
    mov edx, offset msg3
	mov ecx, sizeof msg3
    call WriteString

    mov eax, min
    call WriteDec
    mov edx, offset endl
	mov ecx, sizeof endl
    call WriteString

;print Max
    mov edx, offset msg4
	mov ecx, sizeof msg4
    call WriteString

    mov eax, max
    call WriteDec
    mov edx, offset endl
	mov ecx, sizeof endl
    call WriteString


	
	mov ecx, 0
	call ExitProcess

main endp


findMinMax proc
    push ebp
    mov ebp, esp
    sub esp, 8
    
    mov dword ptr [ebp - 4], -1     ;min = -1
    mov dword ptr [ebp - 8], 0      ;max = 0
    lea esi, dword ptr [arr]
    mov ecx, dword ptr [ebp + 8]
;find min_max
L1:
    mov eax, [esi]
    cmp eax, dword ptr [ebp - 4]
    jae L2                 ;if eax > min jmp to L2
    mov dword ptr [ebp - 4], eax      ;else min = eax
    jmp continue
        L2:
            cmp eax, dword ptr [ebp - 8]
            jbe continue               ;if eax < max => continue
            mov dword ptr [ebp - 8], eax      ;else max = eax
            jmp continue
    continue:
        add esi, 4       ;point to next element
    
    loop L1

    mov eax, dword ptr [ebp - 4]
    mov edx, dword ptr [ebp - 8]

    add esp, 8
    pop ebp
    ret 4

findMinMax endp


ReadArray proc
	push ebp
	mov ebp, esp

	mov ecx, dword ptr [ebp + 8]
	mov ebx, 0
L1:
	call ReadDec
	mov [arr+ebx*4], eax
	inc ebx
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