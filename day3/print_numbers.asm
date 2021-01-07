section .text
global _start

print: ; print from %rsi, %rdx times
    mov     rax, 1
    mov     rdi, 1 
    syscall
    ret

exit: ; exit program
    mov     rax, 60
    xor     rdi, rdi
    syscall

Newline: ; print LF
   mov      rsi, newline
   mov      rdx, 1
   call print 
   ret

_start:
    mov     rax, [rsp+16]   ; %rax = argv[1]
    mov     [num1], rax     ; num1 = %rax
    mov     rax, [rsp+24]   ; %rax = argv[2]
    mov     [num2], rax     ; num2 = %rax
    mov     rsi, [num1]     ; %rsi = *num1
    mov     rdx, 3          ; %rdx = 3
    call print              ; From num1, 3 bytes
    call Newline

    mov     rax, [num1]
    shr     rax, 2
    mov     rsi, rax
    mov     rdx, 3
    call print
    ;shr     num1, 8
    ;mov     rsi, [num1]
    ;call print
    call Newline
    call exit

section .data
equals      db " = ", 0
plus        db " + ", 0
newline: db 10

section .bss
num1        resb 10
num2        resb 10
total       resb 10
