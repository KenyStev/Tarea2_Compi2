#include "screen.h"
#include "system.h"
.global main

.data
	x: .word 0
	y: .word 0


	lstring1: .asciz " Y = "
	lstring0: .asciz "X = "
	lstring2: .asciz "X is equal to Y"
	lstring3: .asciz "X is not equal to Y"
.text

main:
	li $a0, BRIGHT_WHITE
	li $a1, BLACK
	jal set_color
	jal clear_screen


# CallStatement
	lw $v0, MS_COUNTER_REG_ADDR

	move $a0, $v0
	jal rand_seed

# AssignStatement
	li $t0, 5
	sw $t0, x

# AssignStatement
	li $t0, 5
	sw $t0, y

# PrintStatement

	la $t0, lstring0
	move $a0, $t0
	jal puts
	lw $t0, x
	move $a0, $t0
	jal put_udecimal
	la $t0, lstring1
	move $a0, $t0
	jal puts
	lw $t0, y
	move $a0, $t0
	jal put_udecimal

	li $a0, '\n' 
	jal put_char

# IfStatement
	lw $t0, x
	lw $t1, y
	seq $t0, $t0, $t1
	beqz $t0, .lelse0
# PrintStatement

	la $t1, lstring2
	move $a0, $t1
	jal puts

	li $a0, '\n' 
	jal put_char


j .lend_if1
.lelse0:

# PrintStatement

	la $t1, lstring3
	move $a0, $t1
	jal puts

	li $a0, '\n' 
	jal put_char

.lend_if1: 

	jr $ra