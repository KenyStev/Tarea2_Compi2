#include "screen.h"
#include "system.h"
.global main

.data
	count: .word 0
	number: .word 0
	total: .word 0


	lstring1: .asciz " = "
	lstring0: .asciz "Number "
	lstring2: .asciz "The total is "
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
	li $t0, 0
	sw $t0, total

# AssignStatement
	li $t0, 0
	sw $t0, count

# WhileStatement
.lwhile0: 
	lw $t0, count
	li $t1, 3
	slt $t0, $t0, $t1
	beqz $t0, .lend_while1

# AssignStatement
	li $t1, 0
	li $t2, 100
	sub $t1, $t2, $t1
	addi $t1, 1
	move $a0, $t1
	jal rand
	move $a0, $v0
	move $a1, $t1
	addi $sp, -8
	move $a2, $sp
	addi $a3, $sp, 4
	jal divide
	lw $t1, ($a3)
	addi $sp, $sp, 8
	add $v0, $t1, $t1
	sw $v0, number

# PrintStatement
	la $t1, lstring0
	move $a0, $t1
	jal puts
	lw $t1, count
	move $a0, $t1
	jal put_udecimal
	la $t1, lstring1
	move $a0, $t1
	jal puts
	lw $t1, number
	move $a0, $t1
	jal put_udecimal


	li $a0, '\n' 
	jal put_char

# AssignStatement
	lw $t1, count
	li $t2, 1
	add $t1, $t1, $t2
	sw $t1, count

# AssignStatement
	lw $t1, total
	lw $t2, number
	add $t1, $t1, $t2
	sw $t1, total



	j .lwhile0
.lend_while1: 


# PrintStatement
	la $t0, lstring2
	move $a0, $t0
	jal puts
	lw $t0, total
	move $a0, $t0
	jal put_udecimal


	li $a0, '\n' 
	jal put_char
	jr $ra