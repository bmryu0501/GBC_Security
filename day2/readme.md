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
처음엔 시작 지점을 설정해 주기 위해 global로 _start 포인트를 넘겨주었다.  

```x86asm
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
아래는 .text section이고, _start point가 있어 이 지점부터 프로그램이 시작된다.  

시작점부터 첫 syscall 까지의 코드를 보면 다음과 같은데,

```x86asm
    mov       rax, 1
    mov       rdi, 1
    mov       rsi, message
    mov       rdx, 13
    syscall

section   .data
message:
    db        "Hello, World", 10
```
system call 표를 참고하면 %rax == 1일 때 다음과 같다.
| %rax | System Call | %rdi | $rsi | %rdx |
|:---:|:---:|:---:|:---:|:---:|
| 1 | sys_write | unsigned int fd | const char *buf | size_t count|  
위의 표에 넣어준 값들을 대입해보면  
표준출력으로 message부터 13만큼 sys_write를 실행한다는 뜻이 된다.  
이 때 message는 .data section에 message branch가 있으므로, 해당 branch의 시작지점인 'H'의 위치이다.

다음 syscall까지 또 보면

```x86asm
    mov       rax, 60
    xor       rdi, rdi
    syscall
```
%rax = 60으로 syscall을 해주고,  
%rdi = 1 ^ 1 = 0이 된다.
| %rax | System Call | %rdi | $rsi | %rdx |
|:---:|:---:|:---:|:---:|:---:|
| 60 | sys_exit | int error_code | | |  
따라서 0을 error_code로 가지며 프로그램을 종료하게 된다.

---

## strlen.asm

두번째는 strlen.asm이다.
```x86asm
BITS 64

section .text
global _start

strlen:
    mov rax, 0
.looplabel:
    cmp byte [rdi], 0
    je  .end
    inc rdi
    inc rax
    jmp .looplabel
.end:
    ret
    
_start:
    mov   rdi, msg
    call  strlen
    add   al, '0'
    mov  [len],al
    mov   rax, 1
    mov   rdi, 1
    mov   rsi, len
    mov   rdx, 2
    syscall
    mov   rax, 60
    mov   rdi, 0
    syscall

section .data
    msg db "hello",0xA,0
    len db 0,0xA
```

이번에는 접근법을 바꿔서 프로그램 실행 순서를 따라 설명하겠다.  
```x86asm
_start:
    mov   rdi, msg
    call  strlen
```  
먼저 시작지점에서 %rdi에 .data section의 msg 주소를 넣어주고 strlen을 호출한다.  
아래는 사용된 레지스터에 저장된 값들이다.
|register| %rdi | %rax |%al|
|:------:|:----:|:----:|:-:|
| value  | &msg |      |   |


```x86asm
strlen:
    mov rax, 0
.looplabel:
    cmp byte [rdi], 0
    je  .end
    inc rdi
    inc rax
    jmp .looplabel
.end:
    ret
```
strlen가 호출되어 strlen branch로 왔다.  
%rax는 0으로 초기화해주고, 내려와 byte단위로 [rdi]와 0을 비교해준다. [rdi]는 .data section의 rdi의 시작부분인 "h"이므로 flag는 false인 0이다.
je는 jump if equal로 flag가 0이므로 jump 하지 않는다.  
|register| %rdi | %rax |%al|
|:------:|:----:|:----:|:-:|
| value  | &msg |   0  |   |
inc는 increase로 %rdi와 %rax를 1씩 더해준다.
|register| %rdi     | %rax |%al|
|:------:|:--------:|:----:|:-:|
| value  | &msg + 1 |  1   |   |

이를 반복하다보면 %rdi가 '0'의 위치로 갈 때까지 반복되어 다음과 같이 될 것이다. (msg의 db에서 '0'의 위치가 msg+6이다.)
|register| %rdi     | %rax |%al|
|:------:|:--------:|:----:|:-:|
| value  | &msg + 6 |  6   |   |


```x86asm
    cmp byte [rdi], 0
    je  .end

.end:
    ret
```
이제는 둘이 같아 flag = 1이므로 .end로 jump하고, return한다.  
return할 때는 %rax의 값이 %al에 저장되는 것 같다.  
|register| %rdi     | %rax |%al|
|:------:|:--------:|:----:|:-:|
| value  | &msg + 6 |  6   | 6 |  

```x86asm
    add   al, '0'
    mov   [len], al
    mov   rax, 1
    mov   rdi, 1
    mov   rsi, len
    mov   rdx, 2
    syscall
```
한 줄씩  
Call 지점으로 return하여  
al에 '0'(=48)을 더해주고  
len에 al값을 넣어주고  
각 레지스터에 값을 넣어준다.

|register| %rdi     | %rax | %al           | %rsi | %rdx |
|:------:|:--------:|:----:|:-------------:|:----:|:----:|
| value  | 1        |  1   | '0' + 6 = 54  | &len | 2    |

system call을 하면 len부터 2만큼 표준출력 한다.

```x86asm
    mov   rax, 60
    mov   rdi, 0
    syscall
```
마지막으로 error_code 0 으로 exit한다.
|register| %rdi     | %rax | %al           | %rsi | %rdx |
|:------:|:--------:|:----:|:-------------:|:----:|:----:|
| value  | 0        |  60  | '0' + 6 = 54  | &len | 2    |