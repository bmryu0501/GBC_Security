global _start

section .text

print:
    mov rax, 1
    mov rdi, 1
    syscall
    ret

exit:
    mov rax 60
    xor rdi, rdi
    syscall

_strat:
    



section .data
