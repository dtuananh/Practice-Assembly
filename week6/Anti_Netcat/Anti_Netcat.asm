section .const
	sys_read equ 0
	sys_write equ 1
	sys_open equ 2
	sys_exit equ 60

	rt_sigaction equ 13
	rt_sigreturn equ 15
	setitimer equ 38
	kill equ 62
	getdents equ 78

section .rodata
    msg        db "Killing all netcat processes...",0
    len equ $-msg
    PROC_DIR    db  "/proc",0
    PROC        db  "/proc/",0
    status      db  "/status",0
    nc          db  "nc",0
section .data
    act         db  156 dup(0)
    timer       db  32 dup(0)
    buf         db  1024 dup(0)
    tempName    db  256 dup(0)
    direntPtr   dq  0
    tempName2   db  256 dup(0)

section .text
	global _start
_start:
    push rbp
    mov rbp, rsp

    ; print message
    mov rdi, 0
    mov rax, sys_write
    mov rsi, msg
    mov rdx, len
    syscall

    ; set up sigaction structure
    mov qword [act], timer_handler             ; -> sa_handler
    mov qword [act + 8], 4000000h       ; -> sa_flags
    mov dword [act + 10h], restore      ; -> restores
    ; set up sigaction
    mov rdi, 14
    mov rsi, act
    mov rdx, 0
    mov r10d, 8
    mov rax, rt_sigaction             
    syscall                     ; rt_sigaction(SIGALRM, &act, NULL, 8)

    cmp rax, 0
    jne error1

    ; set up timer
    mov dword [timer + 10h], 5  ; 5 seconds
    mov rax, qword [timer + 10h]
    mov qword [timer], rax  ; timer.it_interval = timer.it_value
    mov rdi, 0              ; ITIMER_REAL
    mov rsi, timer
    mov rdx, 0
    mov rax, setitimer
    syscall                     ; setitimer(ITIMER_REAL, &timer, NULL)

    endless_loop:
    jmp endless_loop

    mov rdi, 0
    mov rax, sys_exit
    syscall

    error1:
    mov rdi, -1
    mov rax, 60
    syscall

timer_handler:
    push rbp
    mov rbp, rsp
    sub rsp, 0x20

    mov rdi, PROC_DIR
    mov rsi, 0
    mov rdx, 0
    mov rax, sys_open
    syscall

    ; open dir /proc
    mov rdi, PROC_DIR
    mov rax, sys_open
    mov rsi, 0x10000
    syscall

    mov dword [rbp - 0x18], eax  ; save fd1
    cmp eax, 0
    jle errorStart

    L1:
    ; readdir with getdents
    mov rax, getdents
    mov edi, dword [rbp - 0x18]    
    mov rsi, buf
    mov rdx, 1024
    syscall
    cmp rax, 0
    jle errorStart
    mov qword  [rbp - 8], rax ; save bytes read
    mov qword [rbp - 0x10], 0 ; bpos = 0
    jmp L2

    insideL2:                              
    mov rax, qword [rbp - 0x10]
    lea rdx, buf
    add rax, rdx
    mov qword [direntPtr], rax
    mov rax, qword [direntPtr]
    add rax, 12h
    mov rdi, rax
    call isNumber    ; check if is number like /proc/1234
    test eax, eax
    jz next
    lea rax, PROC       ; "/proc/"
    mov rsi, rax
    lea rax, tempName
    mov rdi, rax
    call strcpy
    mov rax, qword [direntPtr]
    add rax, 12h
    mov rsi, rax
    lea rax, tempName
    mov rdi, rax
    call append
    lea rax, status     ; "/status"
    mov rsi, rax
    lea rax, tempName
    mov rdi, rax
    call append
    mov esi, 0          ; oflag
    lea rax, tempName
    mov rdi, rax        ; file
    mov rax, sys_open
    syscall
    mov dword [rbp - 0x14], eax ; save fd2
    mov eax, dword [rbp - 0x14]
    mov edx, 100h       ; nbytes
    lea rcx, tempName2
    mov rsi, rcx        ; buf
    mov edi, eax        ; fd
    mov rax, sys_read
    syscall
    mov dword [rbp - 0x1c], 0   ; j = 0
    jmp checkNewLine

prepareName:        
    mov eax, dword [rbp - 0x1c]
    cdqe
    lea rdx, tempName2
    movzx eax, byte [rax+rdx]
    cmp al, 0Ah
    jnz incJ
    mov eax, dword [rbp - 0x1c]
    cdqe
    lea rdx, tempName2
    mov byte [rax+rdx], 0
    jmp cmpWnetcat


incJ:                          
    add dword [rbp - 0x1c], 1

checkNewLine:                            
    cmp dword [rbp - 0x1c], 0FFh
    jle prepareName

cmpWnetcat:                           
    mov rax, tempName2
    add rax, 6
    lea rdx, nc         ; "nc"
    mov rsi, rdx        ; s2
    mov rdi, rax        ; s1
    call strcmp
    cmp rax, 0
    je next
    mov rax, qword [direntPtr]
    add rax, 12h
    mov rdi, rax        ; nptr
    call atoi
    mov esi, 9	;SIGKILL
    mov edi, eax
    mov eax, kill
    syscall

next: 
    mov rax, qword [direntPtr]
    movzx eax, word [rax+10h]
    movzx eax, ax
    add qword [rbp - 0x10], rax

L2:           
    mov rax, qword [rbp - 0x10]
    cmp rax, qword [rbp - 8]
    jl insideL2
    jmp L1

errorStart:
    leave
    ret
         


restore:
    mov rax, rt_sigreturn
    syscall

strcpy:
	push rbp
	mov rbp, rsp
	
	mov qword [rbp - 18h], rdi		;des
	mov qword [rbp - 20h], rsi		;src
	
	mov rdx, qword [rbp - 20h] 
	mov cl, byte [rdx]
	test cl, cl
	mov rax, qword [rbp - 18h] 
	je .L2

	.L1:
	mov byte [rax], cl
	mov cl, byte [rdx + 1]
	inc rax
	inc rdx
	test cl, cl
	jne .L1

	.L2:
	mov byte [rax], 0
	pop rbp
	retn

isNumber:
    push rbp
    mov rbp, rsp
    mov qword [rbp-0x18], rdi
    mov dword [rbp-0x4], 0
    jmp loopi
check0_9:                               
    mov eax, dword [rbp-0x4]
    movsxd rdx, eax
    mov rax, qword [rbp-0x18]
    add rax, rdx
    movzx eax, byte [rax]
    cmp al, 2Fh ; '/'
    jle notNumber
    mov eax, dword [rbp-0x4]
    movsxd rdx, eax
    mov rax, qword [rbp-0x18]
    add rax, rdx
    movzx eax, byte [rax]
    cmp al, 39h ; '9'
    jle inc_i

notNumber:                               
    mov eax, 0
    jmp retR
inc_i:   
    add dword [rbp-0x4], 1
loopi:                
    mov eax, dword [rbp-0x4]
    movsxd rdx, eax
    mov rax, qword [rbp-0x18]
    add rax, rdx
    movzx eax, byte [rax]
    test al, al
    jnz check0_9
    mov eax, 1
retR:              
    pop rbp
    retn
 
append: 
    push rbp
    mov rbp, rsp
    sub rsp, 20h
    mov qword [rbp-0x18], rdi
    mov qword [rbp-0x20], rsi
    mov dword [rbp-0x4], 0
    jmp callStrcpy
inc1:                             
    add dword [rbp-0x4], 1
callStrcpy:                              
    mov eax, dword [rbp-0x4]
    movsxd rdx, eax
    mov rax, qword [rbp-0x18]
    add rax, rdx
    movzx eax, byte [rax]
    test al, al
    jnz inc1
    mov eax, dword [rbp-0x4]
    movsxd rdx, eax
    mov rax, qword [rbp-0x18]
    add rdx, rax
    mov rax, [rbp-0x20]
    mov rsi, rax        ; src
    mov rdi, rdx        ; dest
    call strcpy
    nop
    leave
    retn


strcmp:
    push rbp
    mov rbp, rsp
    sub rsp, 50h
    mov [rbp - 8h], rdi    ;    address of buffer1               aa
    mov [rbp - 10h], rsi    ;    address of buffer2              aaaa
    mov byte [rbp - 11h], 0       ;   result

    f1: 
    mov al, byte [rdi]
    mov ah, byte [rsi]
    cmp al, ah
    jnz exitProc
    inc rdi
    inc rsi
    cmp byte [rdi], 0
    jz f2
    cmp byte [rsi], 0
    jz f2
    jmp f1

    f2:
    mov al, byte [rdi]
    mov ah, byte [rsi]
    cmp al, ah
    jnz exitProc
    mov byte [rbp - 11h], 1
    
    exitProc:
    movzx rax, byte [rbp - 11h]
    leave
    ret

atoi:
    mov rax, 0              ; Set initial total to 0
    movzx rsi, byte [rdi]   ; Get the current character
    test rsi, rsi           ; Check for \0
    je error2
    cmp rsi, 0xa            ; Check for newline
    je error2
    ; check if rdi is a number 
convert:
    movzx rsi, byte [rdi]   ; Get the current character
    test rsi, rsi           ; Check for \0
    je done1
    cmp rsi, 0xa            ; Check for newline
    je done1
    
    cmp rsi, 48             ; Anything less than 0 is invalid
    jl error2
    
    cmp rsi, 57             ; Anything greater than 9 is invalid
    jg error2
     
    sub rsi, 48             ; Convert from ASCII to decimal 
    imul rax, 10            ; Multiply total by 10
    add rax, rsi            ; Add current digit to total
    
    inc rdi                 ; Get the address of the next character
    jmp convert

error2:
    mov rax, -1             ; Return -1 on error
 
done1:
    ret                     ; Return total or error code
    ret                     ; Return total or error code
