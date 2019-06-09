section .text
str_length:
	xor rax, rax
.loop:
	cmp byte [rdi+rax], 0
	jz .end
	inc rax
	jmp .loop
.end:
	ret

print_str:
	push rdi
	call str_length
	pop rsi
	mov rdx, rax
	mov rax, 1
	mov rdi, 1
	syscall
	ret

print_char:
	push rdi
	mov rsi, rsp
	mov rax, 1
	mov rdx, 1
	mov rdi, 1
	syscall
	pop rdi
	ret

print_newline:
    mov rdi, 0xA
	call print_char
    ret

print_int:
    test rdi, rdi
	jns .plus
	jmp .minus
.plus:
	call print_uint
    ret
.minus:
	push rdi
	mov rdi, '-'
	call print_char
	pop rdi
	neg rdi
	jmp .plus

print_uint:
	mov rax, rdi
	xor r8, r8
	mov rbx, 10
.loop:
	xor rdx, rdx
	div rbx
	push rdx
	inc r8
	test rax, rax
	jnz .loop
	mov rax, 1
	mov rdx, 1
	mov rdi, 1
.print:
	pop r10
	add r10, '0'
	push r10
	mov rsi, rsp
	syscall
	pop r10
	dec r8
	test r8, r8
	jnz .print
	ret

str_equals:
    mov al, byte [rdi]
    cmp al, byte [rsi]
jne .fail
    inc rdi
    inc rsi
    test al, al
    jnz str_equals
    mov rax, 1
    ret
.fail:
    xor rax, rax
    ret

read_char:
	xor rax, rax
	push rax
	mov rax, 0
	mov rsi, rsp
	mov rdi, 0
	mov rdx, 1
	syscall
	pop rax
	ret

section .text

read_word:
    push r14
    xor r14, r14 

    .fst:
    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .fst
    cmp al, 10
    je .fst
    cmp al, 13
    je .fst 
    cmp al, 9 
    je .fst
    test al, al
    jz .third

    .scnd:
    mov byte [rdi + r14], al
    inc r14

    push rdi
    call read_char
    pop rdi
    cmp al, ' '
    je .third
    cmp al, 10
    je .third
    cmp al, 13
    je .third 
    cmp al, 9
    je .third
    test al, al
    jz .third
    cmp r14, 254
    je .third 

    jmp .scnd

    .third:
    mov byte [rdi + r14], 0
    mov rax, rdi 
   
    mov rdx, r14 
    pop r14
    ret

parse_uint:
	xor r9, r9
	mov r9, 10d
   	xor rax, rax
	xor r8, r8
	xor r11, r11
.loop:
	xor r10, r10
	mov r10b, byte[rdi+r11]
	inc r11
.scndelow:
	cmp r10b, '0'
	jb .end
.fstbove:
	cmp r10b, '9'
	ja .end
.value:
	sub r10b, '0'
	mul r9
	add rax, r10
	inc r8
	jmp .loop
.end:
	mov rdx, r8
	ret

parse_int:
	xor r8, r8
	xor rax, rax
	cmp byte [rdi], '-'
	jz .minus
	call parse_uint
	ret
.minus:
	lea rdi, [rdi+1]
	call parse_uint
	test rdx, rdx
	jz .end
	neg rax
	inc rdx
	ret
.end:
	xor rdx, rdx
	ret

str_copy:
    push rdi
    push rsi
    call str_length
    xor r10, r10
    xor r11, r11
    pop rsi
    pop rdi
.loop:
    cmp rax, r10
    jae .thirdopy
    jmp .end
.thirdopy:
    mov r11, [rdi+r10]
    mov qword [rsi], r11
    inc rsi
    inc r10
    jmp .loop
.end:
    ret

print_not_found:
    mov rdi, wb
    call print_str
    mov rdi, not_found
    call print_str
    ret

; rdi <- word
; w_word -> rax
find_word:
    mov rsi, [lw]

    mov rax, [state]
    test rax, rax
    jz .loop
    mov rsi, [rsi]
.loop:
    push rdi
    push rsi

    add rsi, 9
    call str_equals

    pop rsi
    pop rdi

    test rax, rax
    jnz .found

    mov rsi, [rsi]
    test rsi, rsi
    jnz .loop

    xor rax, rax
    ret
.found:
    mov rax, rsi
    ret

; rdi <- w_word
; xt -> rax
cfa:
    add rdi, 9
    call str_length
    add rdi, rax
    add rdi, 2
    mov rax, rdi
    ret
