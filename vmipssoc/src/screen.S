#include "system.h"
#include "screen.h"

.global set_color
.global clear_screen
.global get_color
.global set_cursor
.global put_char
.global puts
.global put_udecimal
.global draw_rect
.global fill_rect

.data

chr_attr: .byte 0
cursor_col: .byte 0
cursor_row: .byte 0

.text

set_color:
    sll $a1, $a1, 4
    andi $a0, $a0, 0x0f
    or $t0, $a1, $a0
    sb $t0, chr_attr
    jr $ra

get_color:
	lb $t0, chr_attr
 	andi $t1, $t0, 0x0f
	sb $t1, ($a0)
	srl $t0, $t0, 4
	sb $t0, ($a1)
	jr $ra

set_cursor:
	sltiu $t0, $a0, MAX_ROWS
	beq $t0, $zero, .end_if
	sltiu $t0, $a1, MAX_COLS
	beq $t0, $zero, .end_if

	sb $a0, cursor_row
	sb $a1, cursor_col

.end_if:
	jr $ra

put_char:
	li $t0, 10
	bne $a0, $t0, .else

	lb $t0, cursor_row
	sltiu $t1, $t0,  MAX_ROWS - 1
	beq $t1, $zero, .cursor_zero

	addiu $t0, $t0, 1
	sb $t0, cursor_row

.cursor_zero:
	sb $zero, cursor_col
	jr $ra

.else:
	lb $t0, cursor_row
	sll $t1, $t0, 6 #2^6*r
	sll $t2, $t0, 4 #2^4*r
	add $t2, $t1, $t2
	lb $t0, cursor_col
	add $t0, $t2, $t0 #offset = VGA_MEM_OFFSET result

	lb $t1, chr_attr
	sll $t1, $t1, 8
	or $t1, $t1, $a0 #d

	li $t2, VGA_START_ADDR
	sll $t0, $t0, 1
	add $t2, $t0, $t2 #(VGA_START_ADDR+offset)
	sw $t1, 0($t2)

	lb $t0, cursor_col
	slt $t1, $t0, (MAX_COLS-1)
	beqz $t1, .else_cursor
	addi $t0, $t0, 1
	sb $t0, cursor_col
	j .end_if_cursor

	.else_cursor:
		sb $zero, cursor_col
		lb $t0, cursor_row
		addi $t0, $t0, 1
		sb $t0, cursor_row

	.end_if_cursor:
		jr $ra

puts:
	addiu $sp, $sp, -8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	move $s0, $a0

.while_begin:
	lb $t1, ($s0)
	beqz $t1, .while_end
	move $a0, $t1
	addi $s0, $s0, 1
	jal put_char
	j .while_begin

.while_end:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	addiu $sp, $sp, 8
	jr $ra

clear_screen:
	lb $t0, chr_attr
	sll $t0, $t0, 8
	ori $t0, $t0, 32

	li $t1, VGA_START_ADDR
.for_begin:
	sltiu $t2, $t1, VGA_END_ADDR + 1
	beqz $t2, .for_end

	sh $t0, ($t1)
	addiu $t1, $t1, 2
	j .for_begin
.for_end:
	move $a0, $zero
	move $a1, $zero
	j set_cursor

put_udecimal:
	addi $sp, $sp, -24
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	move $s0, $a0
	addi $s1, $sp, 12

	bne $s0, $zero, .pu_else
	li $a0, 48
	jal put_char
	j .epilogo

.pu_else:
	addi $s1, $s1, 11
	addi $sp, $sp, -8
	sb $zero, ($s1)
	addi $s1, $s1, -1

.pu_while:
	sltu $t0, $zero, $s0
	beq $zero, $t0, .pu_end_while
	move $a0, $s0
	li $a1, 10
	addi $a2, $sp, 0
	addi $a3, $sp, 4
	jal divide
	lw $t1, 4($sp)
	addiu $t1, $t1, 48
	sb $t1, ($s1)
	addi $s1, $s1, -1
	lw $s0, ($sp)
	j .pu_while

.pu_end_while:
	addi $sp, $sp, 8
	addi $s1,$s1,1
	move $a0, $s1
	jal puts

.epilogo:
	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 24
	jr $ra

draw_rect:
	lw $t0,($a0) #row
	lw $t1, 4($a0) #col
	lw $t3, 8($a0) #w
	lw $t2, 12($a0)	#h

	sll $t4, $t0, 6 #2^6*r
	sll $t5, $t0, 4 #2^4*r
	add $t4, $t4, $t5
	add $t4, $t4, $t1
	sll $t4, $t4, 1
	li $t5, VGA_START_ADDR
	add $t4, $t4, $t5 #p1

	add $t6, $t0, $t3
	addi $t6, $t6, -1
	sll $t7, $t6, 6 #2^6*r
	sll $t6, $t6, 4 #2^4*r
	add $t6, $t6, $t7
	add $t6, $t6, $t1
	sll $t6, $t6, 1
	add $t6, $t6, $t5 #p2

	add $t5, $t1, $t2
	move $t7, $t1
.dw_for1:
	slt $t8, $t7, $t5
	beqz $t8, .dw_end_for1
	lb $t8, chr_attr
	sll $t8, $t8, 8
	ori $t8, $t8, 196
	sh $t8, ($t4)
	sh $t8, ($t6)
	addi $t4, $t4, 2
	addi $t6, $t6, 2
	addi $t7, $t7, 1
	j .dw_for1

.dw_end_for1:

	sll $t4, $t0, 6 #2^6*r
	sll $t5, $t0, 4 #2^4*r
	add $t4, $t4, $t5
	add $t4, $t4, $t1
	sll $t4, $t4, 1
	li $t5, VGA_START_ADDR
	add $t4, $t4, $t5 #p1

	add $t6, $t1, $t2
	addi $t6, $t6, -1
	sll $t8, $t0, 6 #2^6*r
	sll $t7, $t0, 4 #2^4*r
	add $t7, $t8, $t7
	add $t7, $t7, $t6
	sll $t7, $t7, 1
	add $t7, $t7, $t5 #p2

	add $t6, $t0, $t3
	move $t5, $t0
.dw_for2:
	slt $t8, $t5, $t6
	beqz $t8, .dw_end_for2
	lb $t8, chr_attr
	sll $t8, $t8, 8
	ori $t8, $t8, 179
	sh $t8, ($t4)
	sh $t8, ($t7)

	addi $t4, $t4, 160
	addi $t7, $t7, 160
	addi $t5, $t5, 1
	j .dw_for2
.dw_end_for2:
	addi $sp, $sp, -20
	sw $ra, ($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)

	move $s0, $t0
	move $s1, $t1
	move $s2, $t2
	move $s3, $t3

	move $a0, $s0
	move $a1, $s1
	jal set_cursor
	li $a0, 218
	jal put_char
	move $a0, $s0
	addu $a1, $s2, $s1
	addiu $a1, $a1, -1
	jal set_cursor
	li $a0, 191
	jal put_char
	addu $a0, $s0, $s3
	addiu $a0, $a0, -1
	move $a1, $s1
	jal set_cursor
	li $a0, 192
	jal put_char
	addu $a0, $s0, $s3
	addiu $a0, $a0, -1
	addu $a1, $s2, $s1
	addiu $a1, $a1, -1
	jal set_cursor
	li $a0, 217
	jal put_char

	lw $ra, ($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)

	addi $sp, $sp, 20

	jr $ra

fill_rect:

	lw $t0, ($a0) #row
	lw $t1, 4($a0) #col
	lw $t2, 8($a0) #h
	lw $t3, 12($a0)	#w

	li $t4, VGA_START_ADDR
	sll $t5, $t0, 6 #2^6*r
	sll $t6, $t0, 4 #2^4*r
	add $t6, $t5, $t6
	add $t6, $t6, $t1 #offset = VGA_MEM_OFFSET result
	sll $t6, $t6, 1
	addu $t6, $t6, $t4 # p_start

	lb $t4, chr_attr
	sll $t4, $t4, 8
	or $t4, $t4, $a1 # d

	li $t5, 0 # i = 0

.fill_rect_for:
	sltu $t7, $t5, $t2
	beqz $t7, .end_fill_rect

	move $t7, $t6

	li $t8, 0 # j = 0

.fill_rect_inner_for:
	sltu $t9, $t8, $t3

	beqz $t9, .fill_rect_inner_for_end

	sh $t4, 0($t7)
	addiu $t7, $t7, 2
	addiu $t8, $t8, 1
	j .fill_rect_inner_for

.fill_rect_inner_for_end:
	addiu $t6, $t6, (MAX_COLS * 2)
	addiu $t5, $t5, 1
	j .fill_rect_for

.end_fill_rect:
	jr $ra
