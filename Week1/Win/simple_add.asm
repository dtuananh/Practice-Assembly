.386
.model flat, stdcall
.stack 4096
option Casemap:None

include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib


MAXSIZE equ 10
NULL equ 0

.data
	msg1 db "Num1: ", 0
	msg2 db "Num2: ", 0
	msg3 db "Sum = ", 0
	endl db 0Ah, 0Dh, 0
	
	num1 db MAXSIZE DUP(0), 0
	num2 db MAXSIZE DUP(0), 0
	sum db MAXSIZE+1 DUP(0), 0
	
	hInput HANDLE ?
	hOuput HANDLE ?
	
.code
main proc
	call GetHandle
	
	;Read num1
	push offset msg1
	call WriteString
	push offset num1
	call ReadString
	
	;Read num2
	push offset msg2
	call WriteString
	push offset num2
	call ReadString
	
	;Calc
	push offset num2
	push offset num1
	call calc
	
	;Print sum
	push offset msg3
	call WriteString
	push offset sum
	call WriteNumber
	
	;Exit 
	push NULL
	call ExitProcess
	
main endp

GetHandle proc
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov hInput, eax		;hInput = eax

	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov hOuput, eax		;hOuput = eax
	
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
	push MAXSIZE					;nNumberOfCharsToRead = MAXSIZE = 10
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
	push hOuput							;hConsoleOutput
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
    add eax, ebx
    mov ebx, 10d	;ebx = 10
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

WriteNumber proc
	push ebp
	mov ebp, esp
    pushad
    mov ecx, 0  ;count digits
	mov eax, DWORD PTR [sum]
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

calc proc
	push ebp
	mov ebp, esp
	pushad

	push DWORD PTR [ebp + 8]		;num1
    call atoi
    mov DWORD PTR [sum], eax		;sum = num1

    push DWORD PTR [ebp + 12]		;num2
    call atoi
    add DWORD PTR [sum], eax		;sum += num2
    
    popad
	pop ebp
    ret 8
	
calc endp

end main