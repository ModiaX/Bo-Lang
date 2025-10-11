if ~ defined IDATA
IDATA equ 1

include 'call64.asm'

section '.idata' import readable writeable
	import_directory_table KERNEL32, USER32
	
	import_functions KERNEL32, \
						CreateFileA, \
						ReadFile, \
						CloseHandle, \
						ExitProcess, \
						WriteConsoleA, \
						GetStdHandle, \
						WriteFile, \
						GetLastError
	
	import_functions USER32, \
						MessageBoxA

end if