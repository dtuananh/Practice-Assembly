.386
.model	flat, stdcall
.stack	4096
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc

MAXBUF EQU 100

.data
	msg1 byte "So luong phan tu = ", 0
    msg2 byte "Mang: ", 0Ah, 0Dh, 0
    msg3 db "Sum Odd = ", 0
    msg4 byte "Sum Even = ", 0

    endl byte 0Ah, 0Dh, 0

	arr dword MAXBUF dup(0), 0
	sumOdd dword ?
	sumEven dword ?
	tmp byte 10 dup(0), 0

	hInput HANDLE ?
	hOutput HANDLE ?

.code
main proc
	call GetHandle	

	push offset msg1
	call WriteString

	push offset tmp
	call ReadString
	push offset tmp
	call atoi

	push offset msg2
	call WriteString

	push eax
	call ReadArray

	push eax
	call calc

;print sum odd
    push offset msg3
    call WriteString

    push sumOdd
    call WriteDec
	push offset endl
    call WriteString

;print sum even
    push offset msg4
    call WriteString

    push sumEven
    call WriteDec
    push offset endl
    call WriteString

	push 0
	call ExitProcess

main endp



calc proc
    push ebp
    mov ebp, esp

    mov sumEven, 0			;sumEven = 0
    mov sumOdd, 0		;sumOdd = 0
    
    lea esi, dword ptr [arr]			;point to array
    mov ecx, dword ptr [ebp + 8]	;ecx = n
L1:
    mov ebx, 2			;divisor
	mov edx, 0				;clear remainder
    mov eax, [esi]
	div ebx			;eax /= ebx
    cmp edx, 0
    jnz c1				;if eax ! 0 jmp to c1
    mov eax, [esi]
    add sumEven, eax		;sumEven += eax
    c1:
        add esi, 4		;point to the next element
    loop L1

lea esi, dword ptr [arr]
mov ecx, dword ptr [ebp + 8]
L2:
    mov ebx, 2
	mov edx, 0
    mov eax, [esi]
    div ebx
    cmp edx, 0
    jz c2
    mov eax, [esi]
    add sumOdd, eax

    c2:
        add esi, 4
    loop L2

    pop ebp
    ret 4

calc endp



ReadArray proc
	push ebp
	mov ebp, esp
	pushad

	mov ecx, dword ptr [ebp + 8]		;ecx = n
	mov ebx, 0	;i = 0
L1:
	push offset tmp
	call ReadString
	push offset tmp
	call atoi
	mov [arr+ebx*4], eax		;arr[i] = eax
	inc ebx	;i++
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