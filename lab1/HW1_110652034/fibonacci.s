.data
	input_msg:	.asciiz "Please input a number: "
    output_msg: .asciiz "The result of fibonacci(n) is "

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0  ( scanf("%d", &n); )
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a0, $v0      		# store input in $a0
    
# jump to procedure fibonacci
	jal 	fibonacci
	move 	$t0, $v0			# save return value in $t0 (because $v0 will be used by system call) 

# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall

# print the result of procedure fibonacci on the console interface
	move 	$a0, $t0            # save return value in $a0
	li 		$v0, 1		        # call system call
	syscall                     # run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall

#------------------------- procedure fibonacci -----------------------------
# load argument n in $a0, return value in $v0. 
.text
fibonacci:
    addi 	$sp, $sp, -12		# adiust stack for 3 items
    sw 		$ra, 8($sp)			# save the return address      
	sw 		$s0, 4($sp)			
	sw 		$s1, 0($sp)		

    li      $v0, 0
    beq     $a0, 0, return
    
    li      $v0, 1
    move    $s0, $a0
    slti    $t1, $s0, 2
    bne     $t1, $zero, return

    addi    $a0, $s0, -1       # n = n-1
    jal fibonacci
    move    $s1, $v0           # store fibonacci(n-1)

    addi    $a0, $s0, -2       # n = n-2
    jal fibonacci

    add     $v0, $v0, $s1      # return fibonacci(n-1) + fibonacci(n-2)

return:		
    lw      $ra, 8($sp)
    lw      $s0, 4($sp)
    lw      $s1, 0($sp)
    addi    $sp, $sp, 12
	jr 	    $ra			        # return to caller