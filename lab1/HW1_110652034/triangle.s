.data
	input_msg1:	 .asciiz "Please enter option (1: triangle, 2: inverted triangle): "
    input_msg2:	 .asciiz "Please input a triangle size: "
    output_msg1: .asciiz " "
	output_msg2: .asciiz "*"
    output_msg3: .asciiz "\n"

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
	move    $a1, $v0      		# store input in $a1

# print input_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, input_msg2		# load address of string into $a0
	syscall                 	# run the syscall
		
# read the input integer in $v0  ( scanf("%d", &n); )
	li      $v0, 5          	# call system call: read integer
	syscall                 	# run the syscall
	move    $a2, $v0      		# store input in $a2

    move $s7, $zero       # load 0 at s7(i)
    addi $s7, $s7, -1
Loop:
    addi $s7, $s7, 1
    slt $t1, $s7, $a2
    beq $t1, $zero, return

    slti $t1, $a1, 2
    bne  $t1, $zero, C1
    beq  $t1, $zero, C2
    j Loop

C1:
    move $s0, $a2               # s0 = n
    move $s1, $s7               # s1 = i = l
    j print_layer

C2:
    move $s0, $a2               # s0 = n
    move $s1, $a2
    sub  $s1, $s1, $s7
    addi $s1, $s1, -1           # s1 = n-i-1 = l
    j print_layer   

return:
    li 	    $v0, 10			    # call system call: exit
	syscall				        # run the syscall

#------------------------- procedure print_layer -----------------------------
.text
print_layer:
    addi $s2, $zero, 1         # s2 = j = 1
    sub  $s3, $s0, $s1         # s3 = n-l
    add  $s4, $s0, $s1         # s4 = n+l
    addi $s4, $s4, 1           # s4 = n+l+1

space:
    slt $t7, $s2, $s3         # if j < n-l
    beq $t7, $zero, star   
    # print output_msg1 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg1	# load address of string into $a0
	syscall                 	# run the syscall
    addi $s2, $s2, 1
    j space

star:
    slt $t7, $s2, $s4         # if j < n+l+1
    beq $t7, $zero, newline
    # print output_msg2 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg2	# load address of string into $a0
	syscall                 	# run the syscall
    addi $s2, $s2, 1    
    j star

newline:
    # print output_msg3 on the console interface
	li      $v0, 4				# call system call: print string
	la      $a0, output_msg3	# load address of string into $a0
	syscall                 	# run the syscall
    j Loop