if ~ defined CONSOLE_HANDLER_ASM
CONSOLE_HANDLER_ASM equ 1

include 'idata.asm'
include 'call64.asm'

section '.bss' readable writable
	console_bytes_written dq ?
	console_handle dq ?

macro write_init {
common
	call64 [GetStdHandle], -11
	cmp rax, -1
	je error
	
	mov [console_handle], rax
}

macro write text, length {
common
	call64 [WriteConsoleA], [console_handle], text, length, [console_bytes_written], 0
}

end if