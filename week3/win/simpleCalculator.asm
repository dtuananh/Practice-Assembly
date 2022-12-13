.386
.model	flat, stdcall
.stack	4096
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc

MAXBUF EQU 100

.data
	msg1 byte  "1_Cong", 0Ah, "2_Tru", 0Ah, "3_Nhan", 0Ah, "4_Chia", 0Ah, "5_Thoat", 0Ah, "Nhap lua chon : ", 0
    msg2 byte "Num1 = ", 0
    msg3 byte "Num2 = ", 0
    res_msg byte "Result = ", 0
    remainder_msg byte "Remainder = ", 0

    endl byte 0Ah, 0Dh, 0
    line byte "----------------------------------", 0Ah, 0Dh, 0

    tmp byte 10 dup(0), 0
	num1 dword ?
	num2 dword ?
	choice dword ?
	res dword ?
	remainder dword ?

    hInput HANDLE ?
    hOutput HANDLE ?

.code
main proc
    call GetHandle 
    
rp:     ;repeat
	push offset msg1
	call WriteString

    ;read choice
	push offset tmp
    call ReadString 
    push offset tmp
    call atoi   
	mov [choice], eax
	cmp eax, 5
	je quit

    ;read num1
	push offset msg2
	call WriteString
    push offset tmp
	call ReadString
    push offset tmp
    call atoi
	mov [num1], eax

    ;read num2
	push offset msg3
	call WriteString
    push offset tmp
	call ReadString 
    push offset tmp
    call atoi   
	mov [num2], eax

	mov eax, [choice]
	cmp eax, 1
    je L1
    cmp eax, 2
    je L2
    cmp eax, 3
    je L3
    cmp eax, 4
    je L4


quit:
	push 0
	call ExitProcess

L1:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sum
    jmp rp

L2:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sub
    jmp rp

L3:
    mov esi, [num1]
    mov edi, [num2]
    call calc_mul
    jmp rp

L4:
    mov esi, [num1]
    mov edi, [num2]
    call calc_div
    jmp rp
main endp


calc_sum proc
    push ebp
    mov ebp, esp

    mov eax, esi
    add eax, edi
    mov [res], eax
    
    push offset res_msg
    call WriteString
    push res
    call WriteDec
    push offset endl
    call WriteString
    push offset line
    call WriteString

    pop ebp
    ret

calc_sum endp


calc_sub proc
    push ebp
    mov ebp, esp

    mov eax, esi
    sub eax, edi
    mov [res], eax

    push offset res_msg
    call WriteString
    push res
    call WriteDec
    push offset endl
    call WriteString
    push offset line
    call WriteString

    pop ebp
    ret

calc_sub endp


calc_mul proc
    push ebp
    mov ebp, esp

    mov eax, esi
    mul edi
    mov [res], eax

    push offset res_msg
    call WriteString
    push res
    call WriteDec
    push offset endl
    call WriteString
    push offset line
    call WriteString

    pop ebp
    ret

calc_mul endp


calc_div proc
    push ebp
    mov ebp, esp

    mov edx, 0
    mov eax, esi
    div edi
    mov [res], eax
    mov [remainder], edx

    push offset res_msg
    call WriteString
    push res
    call WriteDec
    push offset endl
    call WriteString

    push offset remainder_msg
    call WriteString
    push remainder
    call WriteDec
    push offset endl
    call WriteString
    
    push offset line
    call WriteString

    pop ebp
    ret

calc_div endp

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