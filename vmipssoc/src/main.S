#include "screen.h"
#include "system.h"
.global main

.data
	i: .word 0


	lstring1: .asciz "End of loop"
	lstring0: .asciz "i = "
.text

main:
	li $a0, BRIGHT_WHITE
	li $a1, BLACK
	jal set_color
	jal clear_screen


# ForStatement
	li $t0, 0
	sw $t0, i
	li $t1, 10
	addi $sp, $sp, -4
	sw $t1, ($sp)
.lfor0: 
	lw $t1, ($sp)
	sle $t2, $t0, $t1
	beqz $t2, .lend_for1

# PrintStatement
	la $t2, lstring0
	move $a0, $t2
	jal puts
	lw $t2, i
	move $a0, $t2
	jal put_udecimal


	li $a0, '\n' 
	jal put_char

	lw $t0, i
	addi $t0, $t0, 1
	sw $t0, i
	j .lfor0
.lend_for1: 
	addi $sp, $sp, 4

# PrintStatement
	la $t0, lstring1
	move $a0, $t0
	jal puts


	li $a0, '\n' 
	jal put_char
	jr $ra