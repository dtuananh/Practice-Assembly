.386    ; use 80386 instruction
.model flat,stdcall ; uses flat memory addressing model
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc

.const
MAXBUF equ 255
WIN_WIDTH equ 400
WIN_HEIGHT equ 300

.data
ClassName db "SimpleWinClass", 0
WindowName db "Reverse String", 0

title1 db "Static", 0
enterTitle db "Enter a string:", 0
title2 db "Edit", 0
outTitle db "Reverse string:", 0
space db " ", 0

.data?
; HINSTANCE & LPSTR typedef DWORD in windows.inc
; reserve the space for future use
hInstance HINSTANCE ?

; use for create window
wc WNDCLASSEX <?>
msg MSG <?> ; handle message
hwnd HWND ? ; handle window procedure
hStr HWND ?
hRev HWND ?

string db MAXBUF DUP(?), 0
rev db MAXBUF DUP(?), 0

.code
WinMainCRTStartup proc
    ; call GetModuleHandle(null)
    push NULL
    call GetModuleHandle    ; module handle same as instance handle in Win32
    mov hInstance, eax  ; return an instance to handle in eax

    ; call WinMain(hInstance, hPrevInstance, CmdLine, CmdShow)
    ; our main function
    push SW_SHOW
    push NULL
    push NULL
    push hInstance
    call WinMain

    ; call ExitProcess
    push eax
    call ExitProcess
WinMainCRTStartup endp

    ; Define WinMain
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD

    mov wc.cbSize, sizeof WNDCLASSEX    ; size of this structure
    mov wc.style, CS_HREDRAW or CS_VREDRAW  ; style of windows
    mov wc.lpfnWndProc, offset WndProc  ; andress of window procedure
    mov wc.cbClsExtra, NULL
    mov wc.cbWndExtra, NULL
    push hInstance
    pop wc.hInstance
    ; Load default cursor
    push IDC_ARROW
    push NULL
    call LoadCursor
    mov wc.hCursor, eax
    ; Load default icon
    push IDI_APPLICATION
    push NULL
    call LoadIcon
    mov wc.hIcon, eax
    mov wc.hIconSm, eax
    push WHITE_BRUSH
    call GetStockObject
    mov wc.hbrBackground, eax    ; background color = white
    mov wc.lpszMenuName, NULL
    mov wc.lpszClassName, offset ClassName

    ; we register our own class, named in ClassName
    push offset wc
    call RegisterClassEx

    ; after register ClassName, we use it to create windows compond
    push NULL
    push hInstance
    push NULL
    push NULL
    push WIN_HEIGHT
    push WIN_WIDTH
    push CW_USEDEFAULT
    push CW_USEDEFAULT
    push WS_OVERLAPPEDWINDOW
    push offset WindowName
    push offset ClassName
    push NULL
    call CreateWindowEx

    mov hwnd, eax   ; return windows handle

    ; display window
    push CmdShow
    push hwnd
    call ShowWindow

    ; update window
    push hwnd
    call UpdateWindow

    ; Message Loop
gettingMsg:
    ; get message
    push 0
    push 0
    push NULL
    push offset msg
    call GetMessage

    ; return in eax
    ; if the function retrieves a message other than WM_QUIT, the return value is nonzero.
    ; if the function retrieves the WM_QUIT message, the return value is zero.
    test eax, eax
    jle quit

    ; translate virtual-key messages into character messages - ASCII in WM_CHAR
    push offset msg
    call TranslateMessage

    ; sends the message data to the window procedure responsible for the specific window the message is for
    push offset msg
    call DispatchMessage

    jmp gettingMsg

quit:
    mov eax, msg.wParam
    ret
WinMain endp

; Handle message with switch(notification)
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    cmp uMsg, WM_CREATE
    je ON_WM_CREATE

    CMP uMsg, WM_COMMAND
    je ON_WM_COMMAND

    cmp uMsg, WM_DESTROY
    je ON_WM_DESTROY

    jmp ON_DEFAULT


; user close program
ON_WM_DESTROY:
    push NULL
    call PostQuitMessage
    jmp quit

ON_WM_CREATE:
    push NULL       ;lpParam
    push NULL       ;hInstance
    push NULL       ;hMenu
    push hWnd       ;hWndParent
    push 20     
    push 100
    push 10
    push 10
    push WS_VISIBLE or WS_CHILD
    push offset enterTitle
    push offset title1
    push NULL
    call CreateWindowEx

    push NULL       ;lpParam
    push NULL       ;hInstance
    push NULL       ;hMenu
    push hWnd       ;hWndParent
    push 50     
    push 300
    push 30
    push 10
    push WS_VISIBLE or WS_CHILD or WS_BORDER or ES_MULTILINE or ES_AUTOHSCROLL
    push offset space
    push offset title2
    push NULL
    call CreateWindowEx
    mov hStr, eax

    push NULL       ;lpParam
    push NULL       ;hInstance
    push NULL       ;hMenu
    push hWnd       ;hWndParent
    push 20     
    push 100
    push 80
    push 10
    push WS_VISIBLE or WS_CHILD
    push offset outTitle
    push offset title1
    push NULL
    call CreateWindowEx

    push NULL       ;lpParam
    push NULL       ;hInstance
    push NULL       ;hMenu
    push hWnd       ;hWndParent
    push 50     
    push 300
    push 100
    push 10
    push WS_VISIBLE or WS_CHILD or WS_BORDER or ES_MULTILINE or ES_AUTOHSCROLL
    push offset space
    push offset title2
    push NULL
    call CreateWindowEx
    mov hRev, eax

    jmp quit

ON_WM_COMMAND:
    push MAXBUF
    push offset string
    push hStr
    call GetWindowTextA

    call revStr

    push offset rev
    push hRev
    call SetWindowTextA


    jmp quit

ON_DEFAULT:
    ; handle any message that program don't handle
    push lParam
    push wParam
    push uMsg   ; message
    push hWnd   ; windows
    call DefWindowProc

quit:
    ret
WndProc endp

revStr proc
	pushad

	mov esi, offset string
	mov edi, offset rev
    
    push esi
    call Strlen
	dec eax
	add esi, eax
do:	
	mov dl, [esi]
	mov [edi], dl
	cmp eax, 0
	jl quit
	dec eax
	dec esi
	inc edi
	jmp do
quit:
	popad
	ret
	
revStr endp

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

end