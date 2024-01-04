.data
	input_msg1:	.asciiz "Please enter option (1: add, 2: sub, 3: mul): "
    input_msg2:	.asciiz "Please enter the first number: "
    input_msg3:	.asciiz "Please enter the second number: "
	output_msg:	.asciiz "The calculation result is: "

.text
.globl main
#------------------------- main -----------------------------
main:
# print input_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg1		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0  ( scanf("%d", &op); )
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $t0, $v0      		# store input in $t0

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0  ( scanf("%d", &a); )
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a1, $v0      		# store input in $a1

# print input_msg3 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg3		# load address of string into $a0
	syscall                 	# run the syscall

# read the input integer in $v0  ( scanf("%d", &b); )
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2

    # if t0 == 1, goto One
	beq $t0, 1, One
	
	# if  t0 == 2, goto Two
	beq $t0, 2, Two
	
	# if t0 == 3
	mul $t1, $a1, $a2          # compute $t1 = a * b
    j   End                    # jump to end

One:
	add $t1, $a1, $a2          # compute $t1 = a + b
    j   End                    # jump to end

Two:
    sub $t1, $a1, $a2          # compute $t1 = a - b

End:
# print output_msg on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg		# load address of string into $a0
	syscall                 	# run the syscall
	
# print ans
	li      $v0, 1              # call system call: print integer
	move    $a0, $t1            # load value of $t1 into $a0
	syscall                     # run the syscall

# exit the program
	li 		$v0, 10				# call system call: exit
	syscall						# run the syscall