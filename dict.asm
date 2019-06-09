section .bss
rs: 		resq 65536
u_mem: 		resq 65536
dict: 		resq 65536
wb: 	resb 1024
state: 		resq 1	

%define pc r12
%define w r13
%define rstack r14

section .text

native ".", printi
      pop rdi
      call print_int
      jmp next

native ".S", show
	mov rax, rsp
.loop:
	cmp rax, [rsp_b]
	jz next
	mov rdi, [rax]
	push rax
	call print_int
	call print_newline
	pop rax
	add rax, 8
	jmp .loop

native "quit", quit
    	mov rax, 60
    	xor rdi, rdi
    	syscall

native "+", plus
	pop rax
	add [rsp], rax
	jmp next

native "-", minus
	pop rax
	sub [rsp], rax
	jmp next

native "*", mul
	pop rax
	pop rcx
	imul rax, rcx
	push rax
	jmp next

native "/", div
	xor rdx, rdx
	pop rbx
	pop rax
	idiv rbx
	push rax
	jmp next

native "=", equal
    	pop rax
    	pop rcx
    	cmp rax, rcx
   	jz .eq
    	push 0
   	jmp next
.eq:
    	push 1
    	jmp next

native "<", ls
    	pop rax
    	pop rcx
    	cmp rcx, rax
    	jl .less
    	push 0
    	jmp next
.less:
    	push 1
    	jmp next

native "land", land
    	pop rax
    	pop rcx
    	test rax, rax
    	jz .no
    	push rcx
    	jmp next
.no:
    	push rax
    	jmp next

native "lor", lor
    	pop rax
    	pop rcx
    	test rax, rax
    	jnz .yes
    	push rcx
    	jmp next
.yes:
    	push rax
    	jmp next

native "not", not
    	pop rax
    	test rax, rax
    	setz al
    	movzx rax, al
    	push rax
    	jmp next

native "and", and
    	pop rax
    	and [rsp], rax
    	jmp next

native "or", or
    	pop rax
    	or [rsp], rax
    	jmp next

native "rot", rot
    	pop rax
    	pop rcx
    	pop rdx
    	push rcx
    	push rax
    	push rdx
    	jmp next

native "swap", swap
    	pop rax
    	pop rcx
    	push rax
    	push rcx
    	jmp next

native "dup", dup
    	push qword [rsp]
    	jmp next
	
native "drop", drop
    	pop rax
    	xor rax, rax
    	jmp next

native "key", key
    	call read_char
    	push rax
    	jmp next

native "emit", emit
   	pop rdi
    	call print_char
    	jmp next

native "num", num
    	mov rdi, wb
    	call read_word
    	call parse_int
    	push rax
    	jmp next

native "mem_addr", mem
    	push qword u_mem
	jmp next

native "lw_addr", lw
    	push qword lw
    	jmp next

native "state_addr", state
    	push qword state
    	jmp next

native "curr_addr", curr
    	push qword [curr]
    	jmp next

native "wb_addr", wb
    	push qword wb
    	jmp next

native "!", write
    	pop rax
    	pop rdx
    	mov [rax], rdx
    	jmp next

native "@", read
    	pop rax
    	push qword [rax]
    	jmp next

native "lit", lit
    	push qword [pc]
    	add pc, 8
    	jmp next

native "%", mod
    	pop rcx
    	pop rax
    	cqo
    	idiv rcx
    	push rdx
    	jmp next
    
native "count", count
    	pop rdi
    	call str_length
    	push rax
    	jmp next

native "word", word
    	pop rdi
    	call read_word
    	push rdx
    	jmp next

native ">r", to_rstack
    	pop rax
    	sub rstack, 8
    	mov qword [rstack], rax
    	jmp next

native "r>", from_rstack
    	mov rax, [rstack]
    	push rax
    	add rstack, 8
    	jmp next

native "r@", nondestr_rstack
    	push qword [rstack]
    	jmp next

native "c!", write_c
    	pop rax
    	pop rdx
    	mov [rax], dl
    	jmp next

native "c@", read_c
    	pop rax
    	movzx rax, byte [rax]
    	push rax
    	jmp next
    
native "branch", branch
    	mov pc, [pc]
    	jmp next

native "branch0", branch0
   	pop rax
   	test rax, rax
   	jz .true
   	add pc, 8
   	jmp next
.true:
   	mov pc, [pc]
   	jmp next

colon "printc", printc
   	dq xt_to_rstack
.loop:
   	dq xt_nondestr_rstack
   	dq xt_branch0, .end
   	dq xt_dup
   	dq xt_read_c
   	dq xt_emit
   	dq xt_lit, 1, xt_plus
   	dq xt_from_rstack
   	dq xt_lit, 1, xt_minus
   	dq xt_to_rstack
   	dq xt_branch, .loop
.end:
  	dq xt_from_rstack
   	dq xt_drop
   	dq xt_drop
   	dq xt_exit

colon "prints", prints
   	dq xt_dup
   	dq xt_count
   	dq xt_printc
   	dq xt_exit
   
native "syscall", syscall
  	pop r9
  	pop r8
  	pop r10
   	pop rdx
  	pop rsi
   	pop rdi
   	pop rax
   	syscall
   	push rax
   	push rdx
   	jmp next

native ",", comma
   	mov rax, [curr]
   	pop qword [rax]
   	add qword [curr], 8
   	jmp next
	
native "c,", c_comma
   	mov rax, [curr]
   	pop rdx
   	mov [rax], dl
   	add qword [curr], 1
   	jmp next

native "find_word", find_word
   	pop rdi
   	call find_word
   	push rax
   	jmp next

native "cfa", cfa
   	pop rdi
   	call cfa
   	push rax
   	jmp next

native "'", tick, 1
   	mov rdi, wb
   	call read_word
   	call find_word

   	test rax, rax
   	jz .not_found

   	mov rdi, rax
   	call cfa
   
   	cmp qword[state], 1		
   	jne .interpret

   	mov rdi, [curr]			
   	mov qword [rdi], xt_lit             	
   	add qword [curr], 8

   	mov rdi, [curr]
   	mov [rdi], rax              	
   	add qword [curr], 8
   	jmp next
.not_found:
   	call print_not_found
   	jmp next 
.interpret:
   	push rax
   	jmp next

native "execute", execute
    	pop rax
    	mov w, rax
    	jmp [rax]
   
native ":", col
    	mov qword [state], 1     	
    
    	mov rax, [curr]
    	mov rcx, [lw]

    	; define header
    	mov [rax], rcx          	

    	mov [lw], rax    	
    	add rax, 8

    	mov byte[rax], 0		
    	inc rax

    	push rax
    	mov rdi, wb
    	call read_word
    	pop rax
    	mov rsi, rax
    	call str_copy        	

    	mov rax, rsi
    	mov byte[rax], 0		
    	inc rax                 	

   	; define ex token
   	mov qword [rax], docol   	
    	add rax, 8
    	mov [curr], rax
    	jmp next

native ";", semicol, 1
    	mov qword [state], 0

    	mov rax, [curr]
    	mov qword [rax], xt_exit    		
    	add rax, 8
    	mov [curr], rax
    	jmp next

native "print_colon", print_colon
     	mov rdi, wb
     	call read_word
     	call find_word
     	test rax, rax
     	jz .not_found
     	mov rdi, rax
     	call cfa
     	push rax			
	
	mov rdi, rax			
	call print_int
	mov rdi, ' '		
	call print_char
	mov rdi, 'd'
	call print_char
	call print_newline
.loop:
    	pop rax
     	add rax, 8			
	push rax
	
	mov rdi, rax			
	call print_int
	mov rdi, ' '		
	call print_char
	mov rax, [rsp]

     	cmp qword[rax], xt_exit		
     	je .end
     	cmp qword[rax - 8], xt_lit	
     	je .print_int
	cmp qword[rax - 8], xt_branch0	
     	je .print_int
	cmp qword[rax - 8], xt_branch	
     	je .print_int

     	mov rax, [rax]	
     	sub rax, 3
.inner_loop:
     	cmp byte[rax], 0
        je .print

	dec rax
        jmp .inner_loop
.print:
	inc rax
	mov rdi, rax
	call print_str
	call print_newline
	jmp .loop
.print_int:
	mov rdi, [rax]
	call print_int
	call print_newline
	jmp .loop
.end:
	pop rax
	mov rdi, 'e'			
	call print_char
	call print_newline			
	jmp next
.not_found:
    	call print_not_found
    	jmp next 
