# bof3

## 개요

![permission](./../image/bof3/01permission.JPG)  
bof3로 접속하면 home directory에 <code>bof3</code>, <code>bof3.c</code> 파일과 bof4의 비밀번호가 있는 <code>bof4.pw</code> 파일이 있다.  
<code>bof4.pw</code>를 읽기 위해서는 bof4의 권한이 필요한데, 마침 <code>bof3</code>파일이 bof4권한으로 실행되므로 이 프로그램을 이용해보도록 하자.  


## 소스코드
![sourceCode](./../image/bof3/02sourceCode.JPG)  
코드를 분석해보면 <code>gets(buf)</code>로 <code>buf</code>에 대한 값을 받아 출력하고, <code>innocent</code>의 값이 KEY(= 0x61)일 때 <code>system("bin/sh")</code>을 실행하여 <code>bof3</code>파일로 쉘을 실행한다.  

이 때 <code>innocent</code>가 <code>buf</code>보다 먼저 정의되어 있으니, <code>gets(buf)</code>에서 <code>buf</code>에 buffer overflow를 이용하여 <code>innocent</code>까지 덮어 쓰면 쉘을 실행시킬 수 있을 것 같다.  

## buf와 innocent 사이 거리
gdb를 이용해 buf와 innocent의 주소를 찾아 거리를 구해보자.  
1. buf 주소  
![gets](./../image/bof3/03gets.JPG)  
![buf address](./../image/bof3/04bufaddress.JPG)  
<code>gets(buf)</code>에서 <code>buf</code>의 주소를 넘겨주므로, 이 때 $rdi를 보면 알 수 있다.  

2. innocent 주소  
![cmp](./../image/bof3/05cmp.JPG)  
![innocent address](./../image/bof3/06innocentaddress.JPG)  
<code>innocent</code>는 if문에서 비교할 때 사용되므로, <code>cmp</code>에서 비교하는 주소인 $rbp-0x4이다.  

3. buf - innocent 사이의 거리  
![distance](./../image/bof3/07distance.JPG)  
둘의 차이를 계산해보면 140byte 차이가 난다.


## innocent 조작하기  
우리가 이제 해야할 일은 <code>innocent</code>에 '0x61'을 넣어주는 것이다.  
그러기 위해서는 <code>buf</code>에 140byte의 글자를 넣어주고, 4byte 크기의 '0x61'을 little endian 방식으로 넣어주는 것이다.  
![poc](./../image/bof3/08poc.JPG)  
위처럼 입력해주면 아래와 같이 bof3파일로 쉘이 실행된다.  
![done](./../image/bof3/09password.JPG)  
