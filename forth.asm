%include "macro.asm"
%include "IOlib.inc"
%include "dict.asm"

%define pc r12
%define w r13
%define rstack r14

section .data
lw: 	dq link
rsp_b: 		dq 0
not_found: 	db ' -> cannot find word', 10, 0
curr: 		dq dict
xt_exit: 	dq exit
program_stub: 	dq 0
xt_interpreter: dq .interpreter
.interpreter: 	dq loop_i

section .text
global _start
_start:
	mov rstack, rs + 65536 * 8
	mov [rsp_b], rsp
    mov pc, xt_interpreter
    jmp next

loop_i:
    cmp qword [state], 0  		
    jne loop_c
	xor rax, rax
	mov qword [wb], rax
	mov rdi, wb
	call read_word		    	
	cmp qword [wb], 0x00
	jz .EOF			            		 
	call find_word			
	test rax, rax
	jz .parse_num	    	
	mov rdi, rax
	call cfa		       

	mov [program_stub], rax
	mov pc, program_stub		
	jmp next
.parse_num:
	mov rdi, wb
	call parse_int

	test rdx, rdx
	jz .not_found		        
	push rax		        
	mov pc, xt_interpreter
	jmp next
.not_found:
	call print_not_found
	mov pc, xt_interpreter
	jmp next
.EOF:
	mov rax, 60
    	xor rdi, rdi
    	syscall


loop_c:
    cmp qword [state], 1      	
    jne loop_i

    mov rdi, wb
    call read_word              	
    call find_word              	
					
	test rax, rax
    jz .parse_num	        

    mov rdi, rax
    call cfa		        

    cmp byte [rax - 1], 1		
    je .immediate               
	
    	mov rdi, [curr]			
   	mov [rdi], rax              	
   	add qword [curr], 8
    	jmp loop_c
.parse_num:
    mov rdi, wb
    call parse_int

    test rdx, rdx
    jz .not_found		        

	mov rdi, [curr]
    cmp qword [rdi - 8], xt_branch	
	je .branch
	cmp qword [rdi - 8], xt_branch0
	je .branch

    mov rdi, [curr]			
    mov qword [rdi], xt_lit     	
    add qword [curr], 8
.branch:
	mov rdi, [curr]			
	mov [rdi], rax
	add qword [curr], 8
	jmp loop_c
.immediate:
    mov [program_stub], rax
    mov pc, program_stub
    jmp next
.not_found:
	call print_not_found
    mov pc, xt_interpreter
	jmp next

next:
    mov w, pc		
    add pc, 8		
    mov w, [w]		
    jmp [w]			

docol:
	sub rstack, 8		
	mov [rstack], pc	
	add w, 8	    	
	mov pc, w	    	
	jmp next	    	

exit:
	mov pc, [rstack]	
	add rstack, 8		
	jmp next	
