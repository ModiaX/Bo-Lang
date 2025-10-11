if ~ defined LETTER_UTILS_ASM
LETTER_UTILS equ 1

macro is_whitespace letter, skip {
common
	cmp byte [letter], 32
	je skip
	cmp byte [letter], 9
	je skip
	cmp byte [letter], 10
	je skip
	cmp byte [letter], 13
	je skip
	cmp byte [letter], 11
	je skip
	cmp byte [letter], 12
	je skip
}

end if