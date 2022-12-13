.386
.model	flat, stdcall
.stack	4096
option casemap:none

include windows.inc
include user32.inc
include kernel32.inc

MAXBUF EQU 100

.data
	msg1 byte "So luong phan tu = ", 0
    msg2 byte "Mang: ", 0Ah, 0Dh, 0
    msg3 byte "Min = ", 0
    msg4 byte "Max = ", 0

    endl byte 0Ah, 0Dh, 0

	num byte 10 dup(0), 0
	tmp byte 10 dup(0), 0

	arr dword MAXBUF dup(0), 0
	min dword ?
	max dword ?

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
	call ReadArray

	push eax
	call findMinMax
	mov min, eax
	mov max, edx

;print Min
    push offset msg3
    call WriteString

    push min
    call WriteDec
    push offset endl
    call WriteString

;print Max
    push offset msg4
    call WriteString

    push max
    call WriteDec
    push offset endl
    call WriteString

	push 0
	call ExitProcess

main endp


findMinMax proc
    push ebp
    mov ebp, esp
    sub esp, 8

;find min
	mov eax, arr		;eax = arr[0]
    mov dword ptr [ebp - 4], eax		;min = eax
    lea esi, dword ptr [arr]
	add esi, 4		;esi = arr[1]
    mov ecx, dword ptr [ebp + 8]
	dec ecx
L1:
    mov eax, [esi]
    cmp eax, dword ptr [ebp - 4]
    jae continue1                 ;if eax > min jmp to L2
    mov dword ptr [ebp - 4], eax      ;else min = eax
    continue1:
        add esi, 4       ;point to next element
    
    loop L1

;find max
	mov eax, arr			;eax = arr[0]
    mov dword ptr [ebp - 8], eax		;max = eax
	lea esi, dword ptr [arr]
	add esi, 4		;esi = arr[1]
	mov ecx, dword ptr [ebp + 8]
	dec ecx
L2:
	mov eax, [esi]
    cmp eax, dword ptr [ebp - 8]
    jbe continue2               ;if eax < max => continue
    mov dword ptr [ebp - 8], eax      ;else max = eax
    continue2:
		add esi, 4

	loop L2
	
    mov eax, dword ptr [ebp - 4]
    mov edx, dword ptr [ebp - 8]

    add esp, 8
    pop ebp
    ret 4

findMinMax endp


ReadArray proc
	push ebp
	mov ebp, esp
	pushad

	mov ecx, dword ptr [ebp + 8]
	mov ebx, 0
L1:
	push offset tmp
	call ReadString
	push offset tmp
	call atoi	
	mov [arr+ebx*4], eax
	inc ebx
	loop L1

	popad
	pop ebp
	ret 4
ReadArray endp


WriteDec proc
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
	
WriteDec endp


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