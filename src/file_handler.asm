if ~ defined FILE_HANDLER_ASM
FILE_HANDLER_ASM equ 1

include 'idata.asm'
include 'call64.asm'

section '.bss' readable writable
	file_bytes dd ?

macro file_init file_name, file_handle, create {
common
	if create = "true"
		call64 [CreateFileA], file_name, 0xC0000000, 0, 0, 4, 0x80, 0
	else if create = "false"
		call64 [CreateFileA], file_name, 0x80000000, 1, 0, 3, 0x80, 0
	end if
	
	cmp rax, -1
	je error_file
	
	mov [file_handle], rax
}

macro file_read file_handle, buffer, length, bytes {
common
	call64 [ReadFile], [file_handle], buffer, length, bytes, 0
	cmp dword [bytes], 0
	je error_file
}

macro file_write file_handle, text, length {
common
	call64 [WriteFile], [file_handle], text, length, file_bytes, 0
}

macro file_deinit [file_handle] {
forward
	call64 [CloseHandle], file_handle
}

end if