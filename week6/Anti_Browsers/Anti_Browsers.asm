extrn ExitProcess: proc
extrn GetModuleHandleA: proc
extrn LoadCursorA: proc
extrn LoadIconA: proc
extrn GetStockObject: proc
extrn RegisterClassExA: proc
extrn CreateWindowExA: proc
extrn ShowWindow: proc
extrn UpdateWindow: proc
extrn GetMessageA: proc
extrn TranslateMessage: proc
extrn DispatchMessageA: proc
extrn PostQuitMessage: proc
extrn DefWindowProcA: proc
extrn GetWindowThreadProcessId: proc
extrn GetClassNameA: proc
extrn OpenProcess: proc
extrn TerminateProcess: proc
extrn CloseHandle: proc
extrn SetTimer: proc
extrn EnumWindows: proc
extrn KillTimer: proc

.const
MAXBUF equ 255
WIN_WIDTH equ 300
WIN_HEIGHT equ 200

.data
ClassName db "SimpleWinClass", 0
WindowName db "Anti_Browsers", 0
process_id dd 0

browsers db "Chrome_WidgetWin_1", 0

class_name db MAXBUF DUP(0), 0
hProcess dq 0

WNDCLASSEX struct 
    cbSize          dd      ?
    style           dd      ?
    lpfnWndProc     dq      ?
    cbClsExtra      dd      ?
    cbWndExtra      dd      ?
    hInstance       dq      ?
    hIcon           dq      ?
    hCursor         dq      ?
    hbrBackground   dq      ?
    lpszMenuName    dq      ?
    lpszClassName   dq      ?
    hIconSm         dq      ?
WNDCLASSEX ends

.data?
; HINSTANCE & LPSTR typedef DWORD in windows.inc
; reserve the space for future use
hInstance dq ?

; use for create window
wc WNDCLASSEX 1 dup({?})

msg db 48 dup(?) ; handle message
hwnd dq ? ; handle window procedure

.code
mainCRTStartup proc
    mov rbp, rsp
    sub rsp, 28h        ;shadow space
    ; call GetModuleHandle(null)
    xor rcx, rcx
    call GetModuleHandleA    
    mov hInstance, rax  ; return an instance to handle in eax

    mov rcx, hInstance
    xor rdx, rdx
    xor r8, r8
    mov r9, 5          ;SW_SHOW
    call WinMain

    ; call ExitProcess
    mov ecx, eax
    call ExitProcess
mainCRTStartup endp

    ; Define WinMain
WinMain proc
    push rbp
    mov rbp, rsp
    sub rsp, 70h
    
    mov wc.cbSize, sizeof WNDCLASSEX    ; size of this structure
    mov wc.style, 3              ;CS_HREDRAW or CS_VREDRAW  ; style of windows
    mov rax, offset WndProc
    mov wc.lpfnWndProc, rax  ; andress of window procedure
    mov wc.cbClsExtra, 0
    mov wc.cbWndExtra, 0
    mov rax, hInstance
    mov wc.hInstance, rax
    mov wc.hCursor, 0           ;default cursor
    mov wc.hIcon, 0         ;default icon
    mov wc.hIconSm, 0
    xor rcx, rcx
    call GetStockObject
    mov wc.hbrBackground, rax    ; background color = white
    mov wc.lpszMenuName, 0
    mov rax, offset ClassName
    mov wc.lpszClassName, rax

    ; we register our own class, named in ClassName
    mov rcx, offset wc
    call RegisterClassExA
    test eax, eax
    jz quit

    ; after register ClassName, we use it to create windows compond
    xor rcx, rcx
    mov rdx, offset ClassName
    mov r8, offset WindowName
    mov r9, 20ce0000h       ;WS_OVERLAPPEDWINDOW
    mov dword ptr [rsp + 20h], 80000000h      ;CW_USEDEFAULT
    mov dword ptr [rsp + 28h], 80000000h 
    mov dword ptr [rsp + 30h], WIN_WIDTH
    mov dword ptr [rsp + 38h], WIN_HEIGHT
    mov qword ptr [rsp + 40h], 0
    mov qword ptr [rsp + 48h], 0
    mov rax, hInstance
    mov qword ptr [rsp + 50h], rax
    mov qword ptr [rsp + 58h], 0
    call CreateWindowExA

    mov hwnd, rax   ; return windows handle

    ; display window
    mov rcx, hwnd
    mov rdx, 5          ;SW_SHOW
    call ShowWindow

    ; update window
    mov rcx, hwnd
    call UpdateWindow

    ; Message Loop
gettingMsg:
    ; get message
    mov rcx, offset msg
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call GetMessageA

    ; return in eax
    ; if the function retrieves a message other than WM_QUIT, the return value is nonzero.
    ; if the function retrieves the WM_QUIT message, the return value is zero.
    test eax, eax
    jle quit

    ; translate virtual-key messages into character messages - ASCII in WM_CHAR
    mov rcx, offset msg
    call TranslateMessage

    ; sends the message data to the window procedure responsible for the specific window the message is for
    mov rcx, offset msg
    call DispatchMessageA
    jmp gettingMsg

quit:
    leave   
    ret
WinMain endp

; Handle message with switch(notification)
WndProc proc
    push rbp
    mov rbp, rsp
    sub rsp, 70h
    mov [rbp + 10h], rcx    ; hwnd
    mov [rbp + 18h], rdx    ; msg
    mov [rbp + 20h], r8     ; wParam
    mov [rbp + 28h], r9     ; lParam

    cmp dword ptr [rbp + 18h], 1            ;WM_CREATE
    je ON_WM_CREATE

    CMP dword ptr [rbp + 18h], 0113h        ;WM_TIMER
    je ON_WM_TIMER

    cmp dword ptr [rbp + 18h], 2            ;WM_DESTROY
    je ON_WM_DESTROY

    jmp ON_DEFAULT


; user close program
ON_WM_DESTROY:
    mov rcx, [rbp + 10h]
    mov rdx, 1
    call KillTimer
    xor rcx, rcx
    call PostQuitMessage
    jmp quit

ON_WM_CREATE:
    mov rcx, [rbp + 10h]
    mov rdx, 1
    mov r8, 5000
    xor r9, r9
    call SetTimer
    jmp quit

ON_WM_TIMER:
    mov rcx, offset EnumWnd
    xor rdx, rdx
    call EnumWindows
    jmp quit

ON_DEFAULT:
    ; handle any message that program don't handle
    mov rcx, [rbp + 10h]
    mov rdx, [rbp + 18h]
    mov r8, [rbp + 20h]
    mov r9, [rbp + 28h]
    call DefWindowProcA

quit:
    leave
    ret
WndProc endp


EnumWnd proc
    push rbp
    mov rbp, rsp
    sub rsp, 50h
    mov [rbp + 10h], rcx        ;hWnd
    mov [rbp + 18h], rdx        ;lParam

    mov rcx, [rbp + 10h]
    lea rdx, process_id
    call GetWindowThreadProcessId
    
    mov rcx, [rbp + 10h]
    mov rdx, offset class_name
    mov r8, sizeof class_name
    call GetClassNameA

    mov rcx, offset class_name
    mov rdx, offset browsers
    call strcmp
    cmp rax, 1
    jnz quit
    mov ecx, 1      ;dwDesureAccess = PROCESS_TERMINATE
    xor edx, edx            ;bInheritHandle = FALSE
    mov r8d, [process_id]
    call OpenProcess
    mov hProcess, rax
    cmp rax, 0
    jz quit

    ;Terminates the specified process and all of its threads.
    mov rcx, hProcess
    mov rdx, 1
    call TerminateProcess
    
    mov rcx, hProcess
    call CloseHandle

quit:
    mov rax, 1      ;return true
    leave
    ret

EnumWnd endp


strcmp proc
    push rbp
    mov rbp, rsp
    sub rsp, 8

    mov qword ptr [rbp - 8], 0        ;result = 0

L1:
    mov al, byte ptr [rcx]
    mov ah, byte ptr [rdx]
    cmp al, ah
    jnz quit
    inc rcx
    inc rdx
    cmp byte ptr [rcx], 0
    jz L2
    cmp byte ptr [rdx], 0
    jz L2

    jmp L1

L2:
    mov al, byte ptr [rcx]
    mov ah, byte ptr [rdx]
    cmp al, ah
    jnz quit
    mov qword ptr [rbp - 8], 1

quit:
    mov rax, qword ptr [rbp - 8]
    add rsp, 8
    pop rbp
    ret 

strcmp endp

end