.global mult
.global divide
.global rand_seed
.global rand
.global exponent

.data
rnd_state: .word 0, 0, 0, 0

.text

divide:
    move $t1, $zero
.while:
    slt $t0, $a0, $a1
    bnez $t0, .end_while
    sub $a0, $a0, $a1
    addi $t1, $t1, 1
    j .while

.end_while:
    sw $t1, 0($a2)
    sw $a0, 0($a3)
    jr $ra

mult:
    move $t0, $zero
    move $v0, $zero
.mult_loop:
    sltu $t1, $t0, $a0
    beqz $t1, .mult_end
    add $v0, $v0, $a1
    addi $t0, $t0, 1
    j .mult_loop
.mult_end:
	jr $ra

#$a0: seed
rand_seed:
	la $t0, rnd_state
	sw $a0, 0($t0) ##rnd_state[0]
	addiu $t1, $a0, 1
	sw $t1, 4($t0) #rnd_state[1]
	addiu $t1, $a0, 2
	sw $t1, 8($t0) #rnd_state[2]
	addiu $t1, $a0, 3
	sw $t1, 12($t0) #rnd_state[3]
	jr $ra

rand:
	la $t0, rnd_state
	lw $t1, 12($t0)
	sll $t2, $t1, 11
	xor $t1, $t1, $t2
	srl $t2, $t1, 8
	xor $t1, $t1, $t2

	lw $t2, 8($t0)
	sw $t2, 12($t0)

	lw $t2, 4($t0)
	sw $t2, 8($t0)

	lw $t2, 0($t0)
	sw $t2, 4($t0)

	xor $t1, $t1, $t2
	srl $t2, $t2, 19
	xor $t1, $t1, $t2

	sw $t1, 0($t0)
	li $t0, 0x000fffff
	and $v0, $t1, $t0
	# move $v0, $t1
	jr $ra

exponent:
	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)

	move $s0, $a0	#p
	move $s1, $a1	#q
	move $s2, $ra 	#ra
	li $s3, 1		#r

.while_exp:
	beqz $s1, .while_end_expr

.if_exp:
	move $a0, $s1
	li $a1, 2
	addi $a2, $sp, 16
	addi $a3, $sp, 20
	jal divide
	lw $t0, 0($a3)
	li $t1, 1
	seq $t0, $t0, $t1
	beqz $t0, .if_exp_end
	move $a0, $s3
	move $a1, $s0

	jal mult
	move $s3, $v0
	addi $s1, $s1, -1

.if_exp_end:
	move $a0, $s0
	move $a1, $s0

	jal mult
	move $s0, $v0

	move $a0, $s1
	li $a1, 2
	addi $a2, $sp, 16
	addi $a3, $sp, 20
	jal divide

	lw $s1, 0($a2)
	j .while_exp

.while_end_expr:
	move $a0, $s0
	move $a1, $s1
	move $ra, $s2
	move $v0, $s3

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	
	addi $sp, $sp, 24
	jr $ra