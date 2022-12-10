.386    ; use 80386 instruction
.model flat,stdcall ; uses flat memory addressing model
option casemap:none

include windows.inc
include kernel32.inc
include user32.inc
include gdi32.inc

.const
DRAWING equ 1
WAITING equ 0
BALL_SIZE equ 80
BALL_SPEED equ 20

WIN_WIDTH equ 700
WIN_HEIGHT equ 500
.data
ClassName db "SimpleWinClass", 0
WindowName db "Bouncing Ball", 0

state db WAITING


.data?
; HINSTANCE & LPSTR typedef DWORD in windows.inc
; reserve the space for future use
hInstance HINSTANCE ?

tlPoint POINT <?>
brPoint POINT <?>
vectorX dd ?
vectorY dd ?

; use for create window
wc WNDCLASSEX <?>
msg MSG <?> ; handle message
hwnd HWND ? ; handle window procedure

hdc HDC ?
ps PAINTSTRUCT <?>

lpRect RECT <?>
lpTime SYSTEMTIME <?>

hPen_Black HPEN ?
hBrush_Red HBRUSH ?

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

TimerProc PROC thwnd:HWND, uMsg:UINT, idEvent:UINT, dwTime:DWORD
        push TRUE
        push NULL
        push thwnd
        call InvalidateRect
        ret
TimerProc ENDP

; Handle message with switch(notification)
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    
    cmp uMsg, WM_CREATE
    je ON_WM_CREATE

    cmp uMsg, WM_LBUTTONDOWN
    je ON_WM_LBUTTONDOWN

    cmp uMsg, WM_PAINT
    je ON_WM_PAINT

    cmp uMsg, WM_DESTROY
    je ON_WM_DESTROY

    jmp ON_DEFAULT

; user close program
ON_WM_DESTROY:
    push NULL
    call PostQuitMessage
    jmp quit

ON_WM_CREATE:
    ; create a pen with specific color and size
    push 00000000h
    push 2
    push PS_SOLID
    call CreatePen
    mov hPen_Black, eax

    push 000000FFh
    call CreateSolidBrush
    mov hBrush_Red, eax
    ;initialize direction of the ball
    call InitDir

    jmp quit

ON_WM_LBUTTONDOWN:
    cmp [state], DRAWING
    je quit

    ; get low word that contain x
    xor eax, eax
    movzx eax, word ptr [lParam]
    mov tlPoint.x, eax
    mov brPoint.x, eax
    add brPoint.x, BALL_SIZE
    ; get high word that contain y
    mov eax, dword ptr [lParam]
    shr eax, 16
    mov tlPoint.y, eax
    mov brPoint.y, eax
    add brPoint.y, BALL_SIZE

    ; when clicked, set state to DRAWING
    mov [state], DRAWING

    push offset TimerProc
    push BALL_SPEED
    push 1
    push hWnd
    call SetTimer
    jmp quit

ON_WM_PAINT:
    push offset ps
    push hWnd
    call BeginPaint
    mov hdc, eax

    ; apply pen to hdc
    push hPen_Black
    push hdc
    call SelectObject

    push hBrush_Red
    push hdc
    call SelectObject

    call CreateBall

    push offset ps
    push hWnd
    call EndPaint
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

CreateBall proc
    push brPoint.y
    push brPoint.x
    push tlPoint.y
    push tlPoint.x
    push hdc
    call Ellipse

    call MoveBall

    ret
CreateBall endp

MoveBall proc
    mov eax, dword ptr [vectorX]
    mov ecx, dword ptr [vectorY]

    add tlPoint.x, eax
    add tlPoint.y, ecx
    add brPoint.x, eax
    add brPoint.y, ecx

    push offset lpRect
    push hwnd
    call GetClientRect
    mov eax, lpRect.right
    cmp brPoint.x, eax
    jg MEET_RIGHT_LEFT

    mov eax, lpRect.bottom
    cmp brPoint.y, eax
    jg MEET_BOTTOM_TOP

    cmp tlPoint.x, 0
    jl MEET_RIGHT_LEFT

    cmp tlPoint.y, 0
    jl MEET_BOTTOM_TOP

    jmp MEET_NONE

    MEET_RIGHT_LEFT:
        mov eax, vectorX
        neg eax
        mov vectorX, eax
        jmp MEET_NONE

    MEET_BOTTOM_TOP:
        mov eax, vectorY
        neg eax
        mov vectorY, eax
        jmp MEET_NONE

    MEET_NONE:
    ret
MoveBall endp

InitDir proc
    push offset lpTime
    call GetLocalTime
    mov eax, dword ptr [lpTime.wSecond]
    mov ebx, 4
    xor edx, edx
    div ebx
    cmp dl, 0   
    jz D1           ;top-right
    cmp dl, 1
    jz D2           ;bottom-right
    cmp dl, 2
    jz D3           ;bottom-left
    cmp dl, 3
    jz D4           ;top-left

D1:
    mov vectorX, 5
    mov vectorY, 5
    jmp quit
D2:
    mov vectorX, 5
    mov vectorY, -5
    jmp quit
D3:
    mov vectorX, -5
    mov vectorY, -5
    jmp quit
D4:
    mov vectorX, -5
    mov vectorY, 5

quit:
    ret

InitDir endp

end