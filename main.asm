format PE64 NX CONSOLE 6.0
entry start

include 'idata.asm'
include 'call64.asm'
include 'console_handler.asm'
include 'file_handler.asm'

section '.data' data readable writable
	file_name_parsetxt db "parse.bol", 0
	file_name_outtxt db "out.asm", 0
	file_handle_parsetxt dq 0
	file_handle_outtxt dq 0
	file_length_parsetxt dq 0
	file_length_outtxt dq 0
	file_bytes_read dd 0
	
	input_buffer rb 26
	index_pointer dq 0
	
	char db 0
	
	error_str db "Error", 0
	success_str db 13, 10, "Success", 0
	newline_str db 13, 10, 0
	
	var_index dq 0
	var_text db "Indentifier: [VAR]"
	var_id rb 64
	var_id_index dq 0
	var_id_str db "Name: [", 0
	closing_sbracket db "]", 0
	var_equ_text db "Operation: [Equals]", 0
	var_val rb 64
	var_val_index dq 0
	var_val_str db "Value: [", 0
	
	out_format db "format PE64 NX CONSOLE 6.0", 13, 10
	section_data db "section '.data' data readable writable", 13, 10
	instruction_var db " dq "
	
	zero db "0", 0
	one db "1", 0
	two db "2", 0
	three db "3", 0
	four db "4", 0
	five db "5", 0
	six db "6", 0
	seven db "7", 0
	
	temp rb 64

section '.text' code readable executable
start:
	write_init
	file_init file_name_parsetxt, file_handle_parsetxt, "false"
	file_init file_name_outtxt, file_handle_outtxt, "true"
	
	file_read file_handle_parsetxt, input_buffer, 26, file_bytes_read
	write input_buffer, 26
	mov eax, [file_bytes_read]
	mov [file_length_parsetxt], rax
	
	write newline_str, 2
	
	file_write file_handle_outtxt, out_format, 28
	call64 loop_buffer
	
	file_deinit [file_handle_parsetxt], [file_handle_outtxt]
	
	write success_str, 9

	call64 [ExitProcess], 0

loop_buffer:
	; int3
	mov rbx, [index_pointer]
	movzx eax, byte [input_buffer + rbx]
	mov [char], al
	
	cmp [var_index], 0
	je var_zero
	cmp [var_index], 1
	je var_one
	cmp [var_index], 2
	je var_two
	cmp [var_index], 3
	je var_three
	cmp [var_index], 4
	je var_four
	cmp [var_index], 5
	je var_five
	cmp [var_index], 6
	je var_six
	cmp [var_index], 7
	je var_seven
	
	after_var:
	mov [var_index], 0
	
	mov rbx, [index_pointer]
	mov rax, [file_length_parsetxt]
	cmp rbx, rax
	jae done
	
	jmp loop_buffer

skip:
	inc qword [index_pointer]
    jmp loop_buffer

var_zero:
	write zero, 1
	cmp byte [char], 86	; V
	je inc_var
	jmp after_var

var_one:
	write one, 1
	cmp byte [char], 65	; A
	je inc_var
	jmp after_var

var_two:
	write two, 1
	cmp byte [char], 82	; R
	je inc_var
	jmp after_var

var_three:
	write three, 1
	write var_text, 18
	write newline_str, 2
	cmp byte [char], 32 ; Space
	je inc_var
	jmp after_var

var_four:
	; Identifier of variable
	write four, 1
	mov [var_id_index], 0
	jmp var_id_loop

var_five:
	write five, 1
	write var_id_str, 7
	mov rax, [var_id_index]
	mov byte [var_id + rax], 0
	write var_id, rax
	write closing_sbracket, 1
	write newline_str, 2
	cmp byte [char], 61 ; =
	je inc_var
	jmp after_var

var_six:
	write six, 1
	write var_equ_text, 20
	write newline_str, 2
	; Value of variable
	mov [var_val_index], 0
	jmp skip_val_spaces

var_seven:
	write seven, 1
	write var_val_str, 9
	mov rax, [var_val_index]
	mov byte [var_val + rax], 0
	write var_val, rax
	write closing_sbracket, 1
	write newline_str, 2
	jmp var_finish

var_finish:
	; Console output
	write var_text, 18
	write var_id_str, 7
	mov rax, [var_id_index]
	write var_id, rax
	write closing_sbracket, 1
	write var_equ_text, 20
	write var_val_str, 9
	mov rbx, [var_val_index]
	write var_val, rbx
	write closing_sbracket, 1
	write newline_str, 2
	
	; File output
	file_write file_handle_outtxt, section_data, 40
	file_write file_handle_outtxt, var_id, [var_id_index]
	file_write file_handle_outtxt, instruction_var, 4
	file_write file_handle_outtxt, var_val, [var_val_index]
	file_write file_handle_outtxt, newline_str, 2
	
	jmp skip_newlines_after_var

skip_newlines_after_var:
	mov rbx, [index_pointer]
	movzx eax, byte [input_buffer + rbx]
	cmp al, 13
	je skip_crlf
	cmp al, 10
	je skip_crlf
	jmp after_var

skip_crlf:
	inc qword [index_pointer]
	jmp skip_newlines_after_var

skip_val_spaces:
    inc qword [index_pointer]
    mov rbx, [index_pointer]
    movzx eax, byte [input_buffer + rbx]
    mov [char], al
    cmp byte [char], 32
    je skip_val_spaces
    jmp var_val_loop

var_id_loop:
	mov rbx, [index_pointer]
	movzx eax, byte [input_buffer + rbx]
	mov [char], al
	cmp byte [char], 32
	je inc_var
	movzx eax, byte [var_id_index]
	mov bl, [char]
	mov byte [var_id + eax], bl
	inc qword [index_pointer]
	inc qword [var_id_index]
	jmp var_id_loop

var_val_loop:
	mov rbx, [index_pointer]
    mov rax, [file_length_parsetxt]
    cmp rbx, rax
    jae inc_var
	mov rbx, [index_pointer]
	movzx eax, byte [input_buffer + rbx]
	mov [char], al
	cmp byte [char], 13
	je carriage_return
	cmp byte [char], 10
	je inc_var
	movzx eax, byte [var_val_index]
	mov bl, [char]
	mov byte [var_val + eax], bl
	inc qword [index_pointer]
	inc qword [var_val_index]
	jmp var_val_loop

carriage_return:
	inc qword [index_pointer]
    jmp var_val_loop

inc_var:
	inc qword [var_index]
	jmp skip

done:
	ret

error:
	call64 [GetLastError]
	call64 [MessageBoxA], 0, error_str, error_str, 0
	call64 [ExitProcess], 1