.386
.model flat, stdcall
.stack 4096
option casemap: none

include D:\masm32\include\windows.inc
include D:\masm32\include\kernel32.inc
include D:\masm32\include\masm32.inc
includelib D:\masm32\lib\kernel32.lib
includelib D:\masm32\lib\masm32.lib


NULL equ 0

.data
	STD_OUTPUT_HANLDE dd -11
	
	msg db "Hello world!", 0
	msgLen dd $-msg
	numOfCharsWritten dd ?
	
	StdOutHandle HANDLE ?
	
.code
main proc
	;Get output handle
	push STD_OUTPUT_HANLDE
	call GetStdHandle
	mov StdOutHandle, eax	;StdOutHandle = eax
	
	;Print "Hello world!"
	push NULL						;lpReserved = NULL
	push offset numOfCharsWritten	;lpNumberOfCharsWritten = numOfCharsWritten
	push msgLen						;nNumberOfCharsToWrite = msgLen
	push offset msg					;*lpBuffer = msg
	push StdOutHandle				;hConsoleOutput = StdOutHandle
	call WriteConsole
	
	;Exit
	push NULL
	call ExitProcess

main endp
end main