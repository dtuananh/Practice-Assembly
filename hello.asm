section .data
    msg db 'Hello, World!', 0xa, 0x0
    len equ  $-msg
section .text
    global _start

_start:
  mov edx, len
  mov ecx, msg
  mov ebx, 1        ;syscall sys_out
  mov eax, 4        ;syscal sys_write
  int 0x80          ;call kernel

  mov eax, 1        ;sys_exit
  mov ebx, 0        ;clear ebx
  int 0x80          ;call kernel