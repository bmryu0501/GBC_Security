section .text
global _start

print:
    mov     rax, 1
    mov     rdi, 1
    syscall
    ret

exit:
    mov     rax, 60
    xor     rdi, rdi
    syscall

strlen:
    mov     rax,0 
.looplabel:
    cmp byte [rdi], 0
    je  .end
    inc     rdi
    inc     rax
    jmp .looplabel
.end:
    ret

Newline:
    mov rsi, newline
    mov rdx, 1
    call print

_start:
    ; print rsp16
    mov     rsi, rsp16
    mov     rdx, 10
    call print
    ; get length of argv[1]
    mov     rdi, [rsp+16]
    call strlen
    ; print argv[1]
    mov     rsi, [rsp+16]
    mov     rdx, rax
    call print
    ; print LF
    call Newline

    call exit

section .data
    rsp16: db "[rsp+16] ", 0
    newline: db 10
