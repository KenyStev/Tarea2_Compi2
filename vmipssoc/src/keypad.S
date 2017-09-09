#include "system.h"

.globl keypad_init
.globl keypad_getkey

.data
	next_key_time: .word 0

.text

keypad_init:
	lui $t0, %hi(next_key_time)
	sw $zero, %lo(next_key_time)($t0)
	jr $ra

keypad_getkey:
	lui $t0, %hi(BTN_STATE_REG_ADDR)
	lb $t0, %lo(BTN_STATE_REG_ADDR)($t0)

	li $t1, KEYPAD_COUNT
	li $t3, 1
	move $t2, $zero

.gk_loop:
	beq $t2, $t1, .gk_end_loop
	and $t4, $t0, $t3
	sll $t3, $t3, 1
	beq $t4, $zero, .gk_inc_loop

	lui $t0, %hi(next_key_time)
	lw $t0, %lo(next_key_time)($t0)
	lui $t1, %hi(MS_COUNTER_REG_ADDR)
	lw $t1, %lo(MS_COUNTER_REG_ADDR)($t1)
	sltu $t3, $t1, $t0
	beqz $t3, .set_key

	move $v0, $zero
.set_key:
	addiu $t1, $t1, 200
	lui $t0, %hi(next_key_time)
	sw $t1, %lo(next_key_time)($t0)
	move $v0, $t2
	addiu $v0, $v0, 1
	#sw $v0, 0xa8($zero)
	jr $ra

.gk_inc_loop:
	addiu $t2, $t2, 1
	j .gk_loop

.gk_end_loop:
	move $v0, $zero
	jr $ra
