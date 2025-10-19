format PE64 NX CONSOLE 6.0
entry start

BUFFER_SIZE equ 1024

include 'idata.asm'
include 'call64.asm'
include 'console_handler.asm'
include 'file_handler.asm'

section '.data' data readable writable
	suffix_asm db ".asm", 0
	suffix_bol db ".bol", 0
	
	suffix_pointer dq 0
	name_pointer dq 0
	
	file_name_txt rb 128
	file_name_parsetxt rb 128
	file_name_outtxt rb 128
	file_handle_parsetxt dq 0
	file_handle_outtxt dq 0
	file_length_parsetxt dq 0
	file_length_outtxt dq 0
	file_bytes_read dd 0
	
	input_buffer rb BUFFER_SIZE
	index_pointer dq 0
	
	char db 0
	
	error_str db "Error", 0
	error_file_str db "FError", 0
	error_console_str db "CError", 0
	success_str db 13, 10, "Success", 0
	newline_str db 13, 10, 0
	tab_str db 9
	
	var_index dq 0
	var_text db "Identifier: [VAR]"
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
	instruction_var db " db "
	
	char_inst db " db "
	short_inst db " dw "
	int_inst db " dd "
	long_inst db " dq "
	float_inst db " dd "
	double_inst db " dq "
	
	zero db "0", 0
	one db "1", 0
	two db "2", 0
	three db "3", 0
	four db "4", 0
	five db "5", 0
	six db "6", 0
	seven db "7", 0
	eight db "8", 0
	
	temp rb 64

section '.text' code readable executable
start:
	write_init
	
	call64 [GetCommandLineA]
	
	call64 skip_until_args_loop
	call64 get_file_names_loop
	write file_name_txt, 128
	write newline_str, 2
	write file_name_parsetxt, 128
	write newline_str, 2
	write file_name_outtxt, 128
	write newline_str, 2

	file_init file_name_parsetxt, file_handle_parsetxt, "false"
	file_init file_name_outtxt, file_handle_outtxt, "true"
	
	file_read file_handle_parsetxt, input_buffer, BUFFER_SIZE, file_bytes_read
	write input_buffer, BUFFER_SIZE
	mov eax, [file_bytes_read]
	mov [file_length_parsetxt], rax

	write newline_str, 2
	
	file_write file_handle_outtxt, out_format, 28
	call64 loop_buffer
	
	file_deinit [file_handle_parsetxt], [file_handle_outtxt]
	
	write success_str, 9

	call64 [ExitProcess], 0

get_file_names_loop:
    movzx ecx, byte [rax]
    cmp cl, 34                ; "
    jne copy_loop_entry
    inc rax
	jmp copy_loop_entry

copy_loop_entry:
    mov rbx, [name_pointer]
    movzx ecx, byte [rax + rbx]
    mov [char], cl
    cmp cl, 0
    je add_suffix
    cmp cl, 32                ; space
    je add_suffix
    cmp cl, 9                 ; tab
    je add_suffix
    cmp cl, 34                ; "
    je add_suffix
    mov byte [file_name_txt + rbx], cl
    inc qword [name_pointer]
    jmp copy_loop_entry

add_suffix:
	lea rsi, [file_name_txt]
	lea rdi, [file_name_outtxt]
	mov rcx, [name_pointer]
	rep movsb
	lea rsi, [file_name_txt]
	lea rdi, [file_name_parsetxt]
	mov rcx, [name_pointer]
	rep movsb
	jmp add_suffix_loop

add_suffix_loop:
	mov rbx, [suffix_pointer]
	mov rdx, [name_pointer]
	movzx ecx, byte [suffix_asm + rbx]
	mov [file_name_outtxt + rdx + rbx], cl
	
	movzx ecx, byte [suffix_bol + rbx]
	mov [file_name_parsetxt + rdx + rbx], cl
	
	cmp cl, 0
	je done_suffix
	
	inc qword [suffix_pointer]
	jmp add_suffix_loop

done_suffix:
	ret

skip_until_args_loop:
    mov dl, byte [rax]
    cmp dl, 34          ; "
    je skip_quoted_path
    jmp skip_unquoted_loop

skip_quoted_path:
    inc rax
	jmp skip_quote_loop

skip_quote_loop:
    mov dl, byte [rax]
    test dl, dl
    jz skip_done
    cmp dl, 34          ; "
    je skip_after_name
    inc rax
    jmp skip_quote_loop

skip_unquoted_loop:
    mov dl, byte [rax]
    test dl, dl
    jz skip_done
    cmp dl, 32          ; space
    je skip_after_name
    cmp dl, 9           ; tab
    je skip_after_name
    inc rax
    jmp skip_unquoted_loop

skip_after_name:
    inc rax
    mov dl, byte [rax]
    cmp dl, 32          ; space
    je skip_after_name
    cmp dl, 9           ; tab
    je skip_after_name
    jmp skip_done

skip_done:
    ret


loop_buffer:
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
	cmp [var_index], 8
	je var_eight
	
	after_var:
	mov [var_index], 0
	inc qword [index_pointer]
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
	cmp byte [char], 58
	je var_type
	jmp after_var

var_four:
	write four, 1
	write var_text, 17
	write newline_str, 2
	cmp byte [char], 32 ; Space
	je inc_var
	jmp after_var

var_five:
	; Identifier of variable
	write five, 1
	mov [var_id_index], 0
	jmp var_id_loop

var_six:
	write six, 1
	write var_id_str, 7
	mov rax, [var_id_index]
	mov byte [var_id + rax], 0
	write var_id, rax
	write closing_sbracket, 1
	write newline_str, 2
	cmp byte [char], 61 ; =
	je inc_var
	jmp after_var

var_seven:
	write seven, 1
	write var_equ_text, 20
	write newline_str, 2
	; Value of variable
	mov [var_val_index], 0
	jmp skip_val_spaces

var_eight:
	write eight, 1
	write var_val_str, 9
	mov rax, [var_val_index]
	mov byte [var_val + rax], 0
	write var_val, rax
	write closing_sbracket, 1
	write newline_str, 2
	jmp var_finish


var_finish:
	; Console output
	write var_text, 17
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
	file_write file_handle_outtxt, tab_str, 1
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
	mov qword [var_index], 0
    jmp loop_buffer

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

var_type:
	inc qword [index_pointer]
	mov rbx, [index_pointer]
	movzx eax, byte [input_buffer + rbx]
	mov [char], al
	cmp byte [char], 67
	je type_char
	cmp byte [char], 83
	je type_short
	cmp byte [char], 73
	je type_int
	cmp byte [char], 76
	je type_long
	cmp byte [char], 70
	je type_float
	cmp byte [char], 68
	je type_double
	jmp after_var

type_char:
	mov eax, dword [char_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

type_short:
	mov eax, dword [short_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

type_int:
	mov eax, dword [int_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

type_long:
	mov eax, dword [long_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

type_float:
	mov eax, dword [float_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

type_double:
	mov eax, dword [double_inst]
	mov dword [instruction_var], eax
	inc qword [index_pointer]
    inc qword [var_index]
    jmp loop_buffer

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

error_file:
	call64 [GetLastError]
	call64 [MessageBoxA], 0, error_file_str, error_file_str, 0
	call64 [ExitProcess], 1

error_console:
	call64 [GetLastError]
	call64 [MessageBoxA], 0, error_console_str, error_console_str, 0
	call64 [ExitProcess], 1

error:
	call64 [GetLastError]
	call64 [MessageBoxA], 0, error_str, error_str, 0
	call64 [ExitProcess], 1