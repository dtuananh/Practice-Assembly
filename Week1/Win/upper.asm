.386
.model flat, stdcall
.stack 4096
option Casemap:None

include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib



MAXBUF equ 255
NULL equ 0

.data
	;STD_INPUT_HANDLE dd -10
	;STD_OUTPUT_HANDLE dd -11

	msg db "Enter a string: ", 0
	msgLen dd $-msg
	Buffer db MAXBUF DUP(?)
	
	numOfCharsRead dd ?
	numOfCharsWritten dd ?
	
	StdInHandle HANDLE ?
	StdOutHandle HANDLE ?

.code
main proc
	;Get output handle
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov StdOutHandle, eax	;StdOutHandle = eax
	
	;Print msg
	push NULL						;lpReserved = NULL
	push offset numOfCharsWritten	;lpNumberOfCharsWritten = numOfCharsWritten
	push msgLen						;nNumberOfCharsToWrite = msgLen
	push offset msg					;*lpBuffer = msg
	push StdOutHandle				;hConsoleOutput = StdOutHandle
	call WriteConsole
	
	;Get input handle
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov StdInHandle, eax	;StdInHandle = eax
	
	;Get buffer from user
	push NULL						;pInputControl = NULL
	push offset numOfCharsRead		;lpNumberOfCharsRead = numOfcharsRead
	push MAXBUF						;nNumberOfCharsToRead = MAXBUF
	push offset Buffer				;lpBuffer = Buffer
	push StdInHandle				;hConsoleInput = StdInHandle
	call ReadConsole
	
	;To uppercase
	mov edx, offset Buffer
	call toUpper
	
	;Print string after to uppercase
	push NULL						;lpReserved = NULL
	push offset numOfCharsWritten	;lpNumberOfCharsWritten = numOfCharsWritten
	push MAXBUF						;nNumberOfCharsToWrite = MAXBUF
	push offset Buffer				;*lpBuffer = Buffer
	push StdOutHandle				;hConsoleOutput = StdOutHandle
	call WriteConsole
	
	;Exit
	push NULL
	call ExitProcess
	
main endp
	
	
toUpper proc
upper:
    mov al, [edx]
    cmp al, 0
    je done
    cmp al, 61h	; 'a'
    jb next
    cmp al, 7ah ; 'z'
    ja next
    sub al, 20h    ;to Uppercase
    mov [edx], al
    jmp next
next:
    inc edx
    jmp upper
done:
    ret
	
toUpper endp


end main