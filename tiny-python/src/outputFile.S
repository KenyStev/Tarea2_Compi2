#include "screen.h"
#include "system.h"
.global main

.data
	x: .word 0
	y: .word 0


	lstring1: .asciz " Y = "
	lstring2: .asciz "Add "
	lstring5: .asciz "Div "
	lstring7: .asciz "Exp "
	lstring6: .asciz "Mod "
	lstring4: .asciz "Mul "
	lstring3: .asciz "Sub "
	lstring0: .asciz "X = "
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
li $t1, 100
sub $t0, $t1, $t0
addi $t0, 1
move $a0, $t0
jal rand
move $a0, $v0
move $a1, $t0
addi $sp, -8
move $a2, $sp
addi $a3, $sp, 4
jal divide
lw $t0, ($a3)
addi $sp, $sp, 8
add $v0, $t0, $t0
sw $v0, x

# AssignStatement
li $t0, 0
li $t1, 100
sub $t0, $t1, $t0
addi $t0, 1
move $a0, $t0
jal rand
move $a0, $v0
move $a1, $t0
addi $sp, -8
move $a2, $sp
addi $a3, $sp, 4
jal divide
lw $t0, ($a3)
addi $sp, $sp, 8
add $v0, $t0, $t0
sw $v0, y

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

# PrintStatement

la $t0, lstring2
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
add $t0, $t0, $t1
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char

# PrintStatement

la $t0, lstring3
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
sub $t0, $t0, $t1
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char

# PrintStatement

la $t0, lstring4
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
move $a0, $t0
move $a1, $t1
jal mult
move $t0, $v0
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char

# PrintStatement

la $t0, lstring5
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
move $a0, $t0
move $a1, $t1
addi $sp, -8
move $a2, $sp
addi $a3, $sp, 4
jal divide
lw $t0, ($a2)
addi $sp, $sp, 8
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char

# PrintStatement

la $t0, lstring6
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
move $a0, $t0
move $a1, $t1
addi $sp, -8
move $a2, $sp
addi $a3, $sp, 4
jal divide
lw $t0, ($a3)
addi $sp, $sp, 8
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char

# PrintStatement

la $t0, lstring7
move $a0, $t0
jal puts
lw $t0, x
lw $t1, y
move $a0, $t0
move $a1, $t1
jal exponent
move $t0, $v0
move $a0, $t0
jal put_udecimal

li $a0, '\n' 
jal put_char
	jr $ra