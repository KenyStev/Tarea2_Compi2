#include "screen.h"
#include "system.h"
.global main

.data

msg: .asciz "Hello World\n"

.text

main:
    li $a0, BRIGHT_WHITE
    li $a1, BLACK
    jal set_color
    jal clear_screen
    
.get_key_loop:
    jal keypad_getkey
    beqz $v0, .get_key_loop
    
    move $a0, $v0
    jal put_udecimal
    
    li $a0, '\n'
    jal put_char
    
    la $a0, msg
    jal puts
    li $a0, 100
    jal put_udecimal
    
    li $a0, '\n'
    jal put_char
    
    lw $a0, MS_COUNTER_REG_ADDR
    jal rand_seed
    
    jal rand
    
    move $a0, $v0
    jal put_udecimal
     
    li $a0, '\n'
    jal put_char
  
    jal rand
    
    move $a0, $v0
    jal put_udecimal
    
    li $a0, '\n'
    jal put_char
  
    jal rand
    
    move $a0, $v0
    jal put_udecimal
  
    
    jr $ra