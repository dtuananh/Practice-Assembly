.386
.model	flat, stdcall
.stack	4096
ExitProcess proto, dwExitCode:dword

include Irvine32.inc

MAXBUF EQU 100

.data
	msg1 byte  "1_Cong", 0Ah, "2_Tru", 0Ah, "3_Nhan", 0Ah, "4_Chia", 0Ah, "5_Thoat", 0Ah, "Nhap lua chon : ", 0
    msg2 byte "Num1 = ", 0
    msg3 byte "Num2 = ", 0
    res_msg byte "Result = ", 0
    remainder_msg byte "Remainder = ", 0

    endl byte 0Ah, 0Dh, 0
    tmp byte "----------------------------------", 0Ah, 0Dh, 0

	num1 dword ?
	num2 dword ?
	choice dword ?
	res dword ?
	remainder dword ?


.code
main proc

R:
	mov edx, offset msg1
	mov ecx, sizeof msg1
	call WriteString

	call ReadDec
	mov [choice], eax
	cmp eax, 5
	je Quit

	mov edx, offset msg2
	mov ecx, sizeof msg2
	call WriteString
	call ReadDec
	mov [num1], eax

	mov edx, offset msg3
	mov ecx, sizeof msg3
	call WriteString
	call ReadDec
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


Quit:
	mov ecx, 0
	call ExitProcess

L1:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sum
    jmp R

L2:
    mov esi, [num1]
    mov edi, [num2]
    call calc_sub
    jmp R

L3:
    mov esi, [num1]
    mov edi, [num2]
    call calc_mul
    jmp R

L4:
    mov esi, [num1]
    mov edi, [num2]
    call calc_div
    jmp R

main endp


calc_sum proc
    push ebp
    mov ebp, esp

    mov eax, esi
    add eax, edi
    mov [res], eax
    
    mov edx, offset res_msg
    mov ecx, sizeof res_msg
    call WriteString
    mov eax, [res]
    call WriteDec
    mov edx, offset endl
    mov ecx, sizeof endl
    call WriteString
    mov edx, offset tmp
    mov ecx, sizeof tmp
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

    mov edx, offset res_msg
    mov ecx, sizeof res_msg
    call WriteString
    mov eax, [res]
    call WriteDec
    mov edx, offset endl
    mov ecx, sizeof endl
    call WriteString
    mov edx, offset tmp
    mov ecx, sizeof tmp
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

    mov edx, offset res_msg
    mov ecx, sizeof res_msg
    call WriteString
    mov eax, [res]
    call WriteDec
    mov edx, offset endl
    mov ecx, sizeof endl
    call WriteString
    mov edx, offset tmp
    mov ecx, sizeof tmp
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

    mov edx, offset res_msg
    mov ecx, sizeof res_msg
    call WriteString
    mov eax, [res]
    call WriteDec
    mov edx, offset endl
    mov ecx, sizeof endl
    call WriteString

    mov edx, offset remainder_msg
    mov ecx, sizeof remainder_msg
    call WriteString
    mov eax, [remainder]
    call WriteDec
    mov edx, offset endl
    mov ecx, sizeof endl
    call WriteString
    
    mov edx, offset tmp
    mov ecx, sizeof tmp
    call WriteString

    pop ebp
    ret

calc_div endp

end main