global _start

section .data
num: dq 0
f_exit db 0
txt_dup db "dup", 0
txt_swap db "swap", 0
txt_drop db "drop", 0
txt_over db "over", 0
txt_rot db "rot", 0
txt_plus db "+", 0
txt_minus db "-", 0
txt_mul db "*", 0
txt_div db "/", 0
txt_error db " error", 0
txt_ok db " ok", 0
txt_sn db 10, 0
txt_space db ' ',0
txt_exit db "exit",0
txt_less db '<',0
txt_great db '>',0
txt_if db "if",0
txt_else db "else",0
txt_then db "then",0
txt_do db "do",0
txt_loop db "loop",0
txt_begin db "begin",0
txt_until db "until",0
txt_equ db '=',0
txt_tt db ':',0
txt_tz db ';',0
n1 dq 0
n2 dq 0
sgn dq -1
for_div dd 10
point_str dq 0
if_num dq 0
p_if_else dq 0 
p_if_then dq 0
do_num dq 0
do_tmp dq 0
p_loop dq 0
p_until dq 0
begin_num dq 0
begin_tmp dq 0
num_fu dq 0

section .bss
str: resb 2048
tmp: resb 2048
tmp2: resb 2048
tmp3: resb 16384
tmp4: resb 16384
forth_stack: resq 2048
do_buf: resb 16384
do_l: resq 64
do_r:resq 64
begin_buf:resb 16384
name_fu: resb 65536
buf_fu: resb 65536


section .text
_start:
	mov rbx, str
	call read_str
	mov rbx, str
	call split_str
	call pr_stack
	cmp byte[f_exit],0
	jz _start
	mov rax, 60
	mov rdi, 22
	syscall
	
read_str:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, 0
	mov [rbx+2047], al
	mov rdi, 0
	mov rsi, rbx
	mov rdx, 2047
	syscall
	mov rcx, 0
rep_str:
	cmp byte [rbx+rcx], 0
	jz endstr
	cmp byte [rbx+rcx], 10
	jz endstr
	inc rcx
	jmp rep_str
endstr:
	mov rdx, 0
	mov [rbx+rcx], dl
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
write_str:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax,1
	mov rdi,1
	mov rsi, rbx
	call len_str
	mov rdx, rcx
	syscall
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
len_str:
	push rax
	push rbx
	push rdi
	push rsi
	push rdx
	mov rcx, 0
run_len:
	cmp byte [rbx+rcx], 0
	jz end_len
	inc rcx
	jmp run_len
end_len:
	pop rdx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
split_str:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
s_w1:
	cmp byte [rbx], 0
	jz split_end
	cmp byte [rbx], 32
	jnz n_split1
	inc rbx
	jmp s_w1
n_split1:
	mov rax, tmp
s_w2:
	cmp byte [rbx], 32
	jz n_split2
	cmp byte [rbx], 0
	jz n_split2
	mov cl, [rbx]
	mov [rax], cl
	inc rax
	inc rbx
	jmp s_w2
n_split2:
	mov byte[rax],0
	mov [point_str], rbx
	push rbx
	mov rbx, tmp
	call check_comm
	pop rbx
	cmp byte [rbx], 0
	jnz s_w1
split_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
check_comm:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	finit
	mov rax, txt_dup
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_swap
	call f_dup
	jmp ch_end
ch_swap:
	mov rax, txt_swap
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_drop
	call f_swap
	jmp ch_end
ch_drop:
	mov rax, txt_drop
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_over
	call f_drop
	jmp ch_end
ch_over:
	mov rax, txt_over
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_rot
	call f_over
	jmp ch_end
ch_rot:
	mov rax, txt_rot
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_plus
	call f_rot
	jmp ch_end
ch_plus:
	mov rax, txt_plus
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_minus
	call f_plus
	jmp ch_end
ch_minus:
	mov rax, txt_minus
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_mul
	call f_minus
	jmp ch_end
ch_mul:
	mov rax, txt_mul
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_div
	call f_mul
	jmp ch_end
ch_div:
	mov rax, txt_div
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_num
	call f_div
	jmp ch_end
ch_num:
	mov rbx, tmp
	call check_num
	cmp rcx, 1
	jnz ch_exit
	mov rcx, [num]
	fstp qword[forth_stack+rcx*8]
	inc rcx
	mov [num], rcx
	jmp ch_end
ch_exit:
	mov rax, txt_exit
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_less
	mov byte [f_exit], 1
	jmp ch_end
ch_less:
	mov rax, txt_less
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_great
	call f_less
	jmp ch_end
ch_great:
	mov rax, txt_great
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_if
	call f_great
	jmp ch_end
ch_if:
	mov rax, txt_if
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_equ
	call f_if
	jmp ch_end
ch_equ:
	mov rax, txt_equ
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_do
	call f_equ
	jmp ch_end
ch_do:
	mov rax, txt_do
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_begin
	call f_do
	jmp ch_end
ch_begin:
	mov rax, txt_begin
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_tt
	call f_begin
	jmp ch_end
ch_tt:
	mov rax, txt_tt
	mov rbx, tmp
	call cmp_str
	cmp rcx, 1
	jnz ch_fu
	call f_tt
	jmp ch_end
ch_fu:
	call f_fu
ch_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

check_num:
	push rax
	push rbx
	push rdi
	push rsi
	push rdx
	mov rcx, 1
	mov rdx, 1
	mov [sgn],rdx
	mov [n2], rdx
	mov rdx, 0
	mov [n1], rdx
	cmp byte[rbx], '-'
	jnz num_plus
	mov rdx,-1
	mov [sgn],rdx
	inc rbx
num_plus:
	cmp byte[rbx],'.'
	jz num_2
	cmp byte[rbx],0
	jz num_end
	cmp byte[rbx],'0'
	jl num_bad
	cmp byte[rbx],'9'
	jg num_bad
	mov rax,[n1]
	push rcx
	mov rcx, 10
	mul rcx
	xor rcx,rcx
	mov cl,[rbx]
	sub cl,'0'
	add rax, rcx
	pop rcx
	mov [n1],rax
	inc rbx
	jmp num_plus
num_2:
	inc rbx
	cmp byte[rbx],0
	jz num_end
	cmp byte[rbx],'0'
	jl num_bad
	cmp byte[rbx],'9'
	jg num_bad
	mov rax,[n2]
	push rcx
	mov rcx, 10
	mul rcx
	xor rcx,rcx
	mov cl,[rbx]
	sub cl,'0'
	add rax, rcx
	pop rcx
	mov [n2],rax
	jmp num_2
num_bad:
	mov rcx,0
num_end:
	push rcx
	mov rax,[n1]
	mov rcx,[sgn]
	mul rcx
	mov [n1],rax
	mov rax,[n2]
	mov rcx,[sgn]
	mul rcx
	mov [n2],rax
	pop rcx
num_fend:
	fild qword [n1]
	fild qword [n2]
	push rcx
	mov rax,[n2]
	mov rcx,[sgn]
	mul rcx
	mov [n2],rax
	pop rcx
num_div:
	mov rdx, 0	
	cmp rax,1
	jz num_ff
	push rcx
	mov rcx, 10
	div rcx
	pop rcx
	fidiv dword [for_div]
	jmp num_div
num_ff:
	fld1
	fild qword [sgn]
	fmulp
	fsubp
	faddp
	pop rdx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

cmp_str:
	push rax
	push rbx
	push rdi
	push rsi
	push rdx
	mov rcx, 1
cmp_c:
	mov dl, [rax]
	cmp dl, [rbx]
	jnz cmp_bad
	cmp dl, 0
	jz cmp_end
	inc rax
	inc rbx
	jmp cmp_c
cmp_bad:
	mov rcx, 0
cmp_end:
	pop rdx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
pr_fl:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rdi, 0
	fld st0
	fimul dword [for_div]
	fistp qword [n1]
	mov rax,[n1]
	cqo
	mov rcx, 10
	idiv rcx
	mov [n1],rax
	fild qword [n1]
	fsubp
	fabs
	fld1
	faddp
pr_p:
	fimul dword [for_div]
	inc rdi
	cmp rdi, 4
	jl pr_p
	fistp qword [n2]
	mov rbx,0
	mov rax,[n1]
	cmp rax,0
	jge pr_next
	cqo
	mov rcx, -1
	imul rcx
	mov byte[tmp2], '-'
	mov rbx,1
pr_next:
	mov rsi, rbx
pr_1:
	cqo
	mov rcx,10
	idiv rcx
	add dl,'0'
	mov [tmp2+rbx],dl
	inc rbx
	cmp rax,0
	jnz pr_1
	mov byte[tmp2+rbx],0
	lea rdi, [rbx-1]
pr_p1:
	cmp rsi, rdi
	jge pr_2
	mov cl,[tmp2+rsi]
	mov dl,[tmp2+rdi]
	mov [tmp2+rsi],dl
	mov [tmp2+rdi],cl
	inc rsi
	dec rdi
	jmp pr_p1
pr_2:
	mov byte[tmp2+rbx],'.'
	inc rbx
	mov rax,[n2]
	mov rsi,rbx
pr_22:
	cqo
	mov rcx,10
	idiv rcx
	add dl,'0'
	mov [tmp2+rbx],dl
	inc rbx
	cmp rax,1
	jnz pr_22
	mov byte[tmp2+rbx],0
	lea rdi, [rbx-1]
pr_p2:
	cmp rsi, rdi
	jge pr_end
	mov cl,[tmp2+rsi]
	mov dl,[tmp2+rdi]
	mov [tmp2+rsi],dl
	mov [tmp2+rdi],cl
	inc rsi
	dec rdi
	jmp pr_p2
pr_end:
	mov rbx,tmp2
	call write_str
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
pr_stack:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rcx,0
pr_s_c:
	cmp rcx,[num]
	jz pr_s_end
	finit
	mov rax, [forth_stack+rcx*8]
	fld qword[forth_stack+rcx*8]
	mov [forth_stack+rcx*8],rax
	call pr_fl
	mov rbx,txt_space
	call write_str
	inc rcx
	jmp pr_s_c
pr_s_end:
	mov rbx,txt_sn
	call write_str
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_dup:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,0
	jz dup_end
	mov rbx, rax
	dec rbx
	mov rcx,[forth_stack+rbx*8]
	mov [forth_stack+rax*8], rcx
	inc rax
	mov [num],rax
dup_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_swap:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl swap_end
	dec rax
	lea rbx, [rax-1]
	mov rcx,[forth_stack+rbx*8]
	mov rdx,[forth_stack+rax*8]
	mov [forth_stack+rax*8],rcx
	mov [forth_stack+rbx*8],rdx
swap_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_drop:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,0
	jz drop_end
	dec rax
	mov [num],rax
drop_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_over:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl over_end
	lea rbx, [rax-2]
	mov rcx,[forth_stack+rbx*8]
	mov [forth_stack+rax*8], rcx
	inc rax
	mov [num],rax
over_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

f_rot:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,3
	jl rot_end
	dec rax
	lea rsi,[rax-1]
	lea rdi,[rax-2]
	mov rbx,[forth_stack+rsi*8]
	mov rcx,[forth_stack+rax*8]
	mov rdx,[forth_stack+rdi*8]
	mov [forth_stack+rax*8],rdx
	mov [forth_stack+rdi*8],rbx
	mov [forth_stack+rsi*8],rcx
rot_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_plus:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl plus_end
	dec rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rax*8]
	fld qword[forth_stack+rbx*8]
	faddp
	fstp qword[forth_stack+rbx*8]
	mov [num], rax
plus_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_minus:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl minus_end
	dec rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rbx*8]
	fld qword[forth_stack+rax*8]
	fsubp
	fstp qword[forth_stack+rbx*8]
	mov [num], rax
minus_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_mul:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl mul_end
	dec rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rax*8]
	fld qword[forth_stack+rbx*8]
	fmulp
	fstp qword[forth_stack+rbx*8]
	mov [num], rax
mul_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_div:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl div_end
	dec rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rbx*8]
	fld qword[forth_stack+rax*8]
	fdivp
	fstp qword[forth_stack+rbx*8]
	mov [num], rax
div_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_less:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl less_end
	dec rax
	mov [num], rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rax*8]
	fld qword[forth_stack+rbx*8]
	fcomip st0, st1
	fstp
	jae less_false
	fld1
	fld1
	fsubp
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
	jmp less_end
less_false:
	fld1
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
less_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_great:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl great_end
	dec rax
	mov [num], rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rbx*8]
	fld qword[forth_stack+rax*8]
	fcomip st0, st1
	fstp
	jae great_false
	fld1
	fld1
	fsubp
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
	jmp great_end
great_false:
	fld1
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
great_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

f_if:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,1
	jl if_end
	fld1
	fld1
	fsubp
	mov rax,[num]
	dec rax
	mov [num],rax
	fld qword[forth_stack+rax*8]
	fcomip st0,st1
	fstp
	jz if_cont
	mov rdx,1
if_cont:
	call find_else_then
	test rdx, rdx
	jnz if_s_else
	mov rsi,[point_str]
	mov rdi,[p_if_else]
	jmp if_clr
if_s_else:
	mov rsi,[p_if_else]
	mov rdi,[p_if_then]
if_clr:
	test rsi, rsi
	jz if_end
	cmp rsi, rdi
	jge if_end
	mov byte[rsi], 32
	inc rsi
	jmp if_clr
if_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
find_else_then:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov qword[p_if_else], 0
	mov qword[p_if_then], 0
	mov rsi, [point_str]
f_e_t_start:
	cmp byte[rsi],0
	jz f_e_t_end
	cmp byte[rsi+2], 32
	jz f_e_t_if
	cmp byte[rsi+2],0
	jz f_e_t_if
	jmp f_e_t_co
f_e_t_if:
	mov dl, [rsi+2]
	mov byte[rsi+2],0
	mov rax,txt_if
	mov rbx,rsi
	call cmp_str
	mov [rsi+2],dl
	cmp rcx, 1
	jnz f_e_t_co
	mov rax, [if_num]
	inc rax
	mov [if_num], rax
f_e_t_co:
	cmp byte[rsi+4], 32
	jz f_e_t_else
	cmp byte[rsi+4],0
	jz f_e_t_else
	jmp f_e_t_co_2
f_e_t_else:
	cmp qword[if_num],0
	jnz f_e_t_co_3
	mov dl, [rsi+4]
	mov byte[rsi+4],0
	mov rax,txt_else
	mov rbx,rsi
	call cmp_str
	mov [rsi+4],dl
	cmp rcx, 1
	jnz f_e_t_co_3
	mov [p_if_else], rsi
f_e_t_co_3:
	mov dl, [rsi+4]
	mov byte[rsi+4],0
	mov rax,txt_then
	mov rbx,rsi
	call cmp_str
	mov [rsi+4],dl
	cmp rcx, 1
	jnz f_e_t_co_2
	cmp qword[if_num],0
	jz f_e_t_co_4
	jmp f_e_t_end
f_e_t_co_4:
	mov rax, [if_num]
	dec rax
	mov [if_num], rax
f_e_t_co_2:
	inc rsi
	jmp f_e_t_start
f_e_t_end:
	mov qword[if_num], 0
	cmp qword[p_if_else],0
	jnz f_e_t_end_2
	mov [p_if_else],rsi
f_e_t_end_2:
	mov [p_if_then], rsi
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_equ:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rax, [num]
	cmp rax,2
	jl equ_end
	dec rax
	mov [num], rax
	lea rbx, [rax-1]
	fld qword[forth_stack+rbx*8]
	fld qword[forth_stack+rax*8]
	fcomip st0, st1
	fstp
	jne equ_false
	fld1
	fld1
	fsubp
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
	jmp equ_end
equ_false:
	fld1
	fld1
	fsubp
	mov rax,[num]
	dec rax
	fstp qword[forth_stack+rax*8]
equ_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_do:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rcx,[do_num]
	inc rcx
	mov [do_num],rcx
	mov rax, [num]
	cmp rax,2
	jl do_end
	lea rax,[rax-2]
	mov [num], rax
	mov rbx, rax
	inc rax
	fld qword[forth_stack+rbx*8]
	fld qword[forth_stack+rax*8]
	mov rcx,[do_num]
	dec rcx
	fistp qword[do_l+rcx*8]
	fistp qword[do_r+rcx*8]
	call find_loop
do_end:
	lea rax,[rcx*4]
	lea rax,[rax*8]
	lea rax,[rax*8]
	lea rax,[do_buf+rax]
	mov rsi,[point_str]
	mov rdi,[p_loop]
do_rep:
	cmp rsi,rdi
	jge do_final
	mov bl,[rsi]
	mov [rax],bl
	mov byte[rsi], 32
	inc rsi
	inc rax
	jmp do_rep
do_final:
	mov byte[rax],0
	mov rsi,[do_l+rcx*8]
	mov rdi,[do_r+rcx*8]
do_play:
	cmp rsi, rdi
	jge do_super_final
	lea rax,[rcx*4]
	lea rax,[rax*8]
	lea rax,[rax*8]
	lea rax,[do_buf+rax]
	lea rbx,[rcx*4]
	lea rbx,[rbx*8]
	lea rbx,[rbx*8]
	lea rbx,[tmp3+rbx]
	cmp byte[rax],0
	jz do_super_final
do_cc:
	mov dl, [rax]
	mov [rbx], dl
	inc rax
	inc rbx
	cmp byte[rax],0
	jnz do_cc
	lea rbx,[rcx*4]
	lea rbx,[rbx*8]
	lea rbx,[rbx*8]
	lea rbx,[tmp3+rbx]
	call split_str
	inc rsi
	jmp do_play
do_super_final:
	mov rcx,[do_num]
	dec rcx
	mov [do_num], rcx
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
find_loop:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rdi,[point_str]
	mov rcx,[do_num]
	dec rcx
	mov rax,0
f_l_start:
	cmp byte[rdi],0
	jz f_l_end
	cmp byte[rdi+2],32
	jz f_l_do
	cmp byte[rdi+2],0
	jz f_l_do
	jmp f_l_co
f_l_do:
	mov dl, [rdi+2]
	mov byte[rdi+2],0
	mov rax,txt_do
	mov rbx,rdi
	call cmp_str
	mov [rdi+2],dl
	cmp rcx, 1
	jnz f_l_co
	mov rax, [do_tmp]
	inc rax
	mov [do_tmp], rax
f_l_co:
	cmp byte[rdi+4],32
	jz f_l_loop
	cmp byte[rdi+4],0
	jz f_l_loop
	jmp f_l_co_2
f_l_loop:
	mov dl, [rdi+4]
	mov byte[rdi+4],0
	mov rax,txt_loop
	mov rbx,rdi
	call cmp_str
	mov [rdi+4],dl
	cmp rcx, 1
	jnz f_l_co_2
	cmp qword[do_tmp],0
	jz f_l_end
	mov rax,[do_tmp]
	dec rax
	mov [do_tmp],rax
f_l_co_2:
	inc rdi
	jmp f_l_start
f_l_end:
	mov [p_loop], rdi
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
f_begin:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rcx,[begin_num]
	inc rcx
	mov [begin_num], rcx
	dec rcx
	call find_until
	lea rax,[rcx*4]
	lea rax,[rax*8]
	lea rax,[rax*8]
	lea rax,[begin_buf+rax]
	mov rsi,[point_str]
	mov rdi,[p_until]
begin_rep:
	cmp rsi,rdi
	jz begin_co
	mov dl,[rsi]
	mov [rax],dl
	mov byte[rsi], 32
	inc rsi
	inc rax
	jmp begin_rep
begin_co:
	mov byte[rax],0
begin_play:
	lea rax,[rcx*4]
	lea rax,[rax*8]
	lea rax,[rax*8]
	lea rax,[begin_buf+rax]
	lea rbx,[rcx*4]
	lea rbx,[rbx*8]
	lea rbx,[rbx*8]
	lea rbx,[tmp4+rbx]
	cmp byte[rax],0
	jz begin_end
begin_cc:
	mov dl, [rax]
	mov [rbx], dl
	inc rax
	inc rbx
	cmp byte[rax],0
	jnz begin_cc
	lea rbx,[rcx*4]
	lea rbx,[rbx*8]
	lea rbx,[rbx*8]
	lea rbx,[tmp4+rbx]
	call split_str
	mov rax,[num]
	cmp rax,0
	jz begin_end
	dec rax
	fld qword[forth_stack+rax*8]
	mov [num],rax
	fld1
	fld1
	fsubp
	fcomip st0,st1
	fstp
	jnz begin_end
	jmp begin_play
begin_end:
	mov rcx,[begin_num]
	dec rcx
	mov [begin_num], rcx
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret
	
find_until:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rdi,[point_str]
	mov rcx,[begin_num]
	dec rcx
	mov rax,0
f_u_start:
	cmp byte[rdi],0
	jz f_u_end
	cmp byte[rdi+5],32
	jz f_u_begin
	cmp byte[rdi+5],0
	jz f_u_begin
	jmp f_u_co
f_u_begin:
	mov dl, [rdi+5]
	mov byte[rdi+5],0
	mov rax,txt_begin
	mov rbx,rdi
	call cmp_str
	mov [rdi+5],dl
	cmp rcx, 1
	jnz f_u_until
	mov rax, [begin_tmp]
	inc rax
	mov [begin_tmp], rax
f_u_until:
	mov dl, [rdi+5]
	mov byte[rdi+5],0
	mov rax,txt_until
	mov rbx,rdi
	call cmp_str
	mov [rdi+5],dl
	cmp rcx, 1
	jnz f_u_co
	cmp qword[begin_tmp],0
	jz f_u_end
	mov rax,[begin_tmp]
	dec rax
	mov [begin_tmp],rax
f_u_co:
	inc rdi
	jmp f_u_start
f_u_end:
	mov [p_until], rdi
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

f_tt:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rcx, [num_fu]
	inc rcx
	mov [num_fu],rcx
	dec rcx
	mov rsi, [point_str]
tt_re:
	cmp byte[rsi], 32
	jnz tt_co
	inc rsi
	jmp tt_re
tt_co:
	cmp byte[rsi],';'
	jz tt_fail
	cmp byte[rsi],0
	jz tt_fail
	lea rax,[rcx*8]
	lea rax,[rax*8]
	lea rax,[rax*4]
	lea rax,[name_fu+rax]
tt_na:
	mov dl,[rsi]
	mov [rax], dl
	mov byte[rsi],32
	inc rsi
	inc rax
	cmp byte[rsi],0
	jz tt_fail
	cmp byte[rsi],32
	jz tt_co_2
	jmp tt_na
tt_co_2:
	lea rax,[rcx*8]
	lea rax,[rax*8]
	lea rax,[rax*4]
	lea rax,[buf_fu+rax]
tt_buf:
	mov dl,[rsi]
	mov [rax],dl
	mov byte[rsi],32
	inc rsi
	inc rax
	cmp byte[rsi],0
	jz tt_end
	cmp byte[rsi],';'
	jz tt_end
	jmp tt_buf
tt_fail:
	mov rcx, [num_fu]
	dec rcx
	mov [num_fu], rcx
tt_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret

f_fu:
	push rax
	push rbx
	push rdi
	push rsi
	push rcx
	push rdx
	mov rdx,[num_fu]
fu_re:
	cmp rdx,0
	jz fu_end
	dec rdx
	lea rax,[rdx*8]
	lea rax,[rax*8]
	lea rax,[rax*4]
	lea rax,[name_fu+rax]
	mov rbx, tmp
	call cmp_str
	cmp rcx,1
	jnz fu_re
	lea rbx,[rdx*8]
	lea rbx,[rbx*8]
	lea rbx,[rbx*4]
	lea  rbx,[buf_fu+rbx]
	call split_str
fu_end:
	pop rdx
	pop rcx
	pop rsi
	pop rdi
	pop rbx
	pop rax
	ret