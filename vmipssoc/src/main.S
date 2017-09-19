#include "screen.h"
#include "system.h"
.global main

.data
	num: .word 0


	lstring0: .asciz "Press a key : "
	lstring1: .asciz "Your input was: "
.text

main:
	li $a0, BRIGHT_WHITE
	li $a1, BLACK
	jal set_color
	jal clear_screen


# AssignStatement
	la $a0, lstring0
	jal puts

.get_key_loop:
	jal keypad_getkey
	beqz $v0, .get_key_loop

	li $a0, '\n' 
	jal put_char
	sw $v0, num

# PrintStatement
	la $t0, lstring1
	move $a0, $t0
	jal puts
	lw $t0, num
	move $a0, $t0
	jal put_udecimal


	li $a0, '\n' 
	jal put_char
	jr $ra