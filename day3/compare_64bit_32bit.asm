global _start

section .text

print:
    mov     rax, 1
    mov     rdi, 1
    syscall
    ret

exit:
    mov     rax 60
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

_strat:
    mov     rsi, rsp16
    mov     rdx, 10
    call print

    mov     rdi, [rsp+16]
    call strlen

    mov     rsi, [rsp+16]
    mov     rdx, rax
    call print

    mov     rsi, esp16
    mov     rdx, 10
    call print

    mov     rdi, [esp+16]
    call strlen

    mov     rsi, [esp+16]
    mov     rdx, rax
    call print

    mov     rsi, newline
    mov     rdx, 1
    call print







section .data
    rsp16: db "[rsp+16] ", 0
    esp16: db "[esp+16] ", 0
    newline: db 10