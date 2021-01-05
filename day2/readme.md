# HW2  

## hello.asm  

```x86asm
global    _start
section   .text
_start:
    mov       rax, 1
    mov       rdi, 1
    mov       rsi, message
    mov       rdx, 13
    syscall
    mov       rax, 60
    xor       rdi, rdi

    syscall
    section   .data

message:
    db        "Hello, World", 10
```

위의 코드는 첫번째로 분석해볼 어셈블리 코드 hello.asm이다.

### 코드 분석

```x86asm
global _start
```
