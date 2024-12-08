.data
MESSAGE1: .asciiz "Enter an IP address\n"
MESSAGE2: .asciiz "First: "
MESSAGE3: .asciiz "Second: "
MESSAGE4: .asciiz "Third: "
MESSAGE5: .asciiz "Fourth: "
MESSAGE6: .asciiz "The IP address you entered: "
MESSAGE7: .asciiz "."
MESSAGE8: .asciiz "\nClass A address\n"
MESSAGE9: .asciiz "\nClass B address\n"
MESSAGE10: .asciiz "\nClass C address\n"
MESSAGE11: .asciiz "\nClass D address\n"
MESSAGE12: .asciiz "\nInvalid domain class\n"
MESSAGE13: .asciiz "\nProgram successfully completed . . .\n"
MESSAGE14: .asciiz "\n"
MESSAGE15: .asciiz "Matching domain found at: "
MESSAGE16: .asciiz "Matching domain was NOT found . . . \n"
ERROROVER: .asciiz "The entered number is larger than 255.\n"
ERRORUNDER: .asciiz "The entered number is smaller than 0.\n"
IP_ROUTING_TABLE_SIZE:
		.word	25

IP_ROUTING_TABLE:
		# line #, x.x.x.x -------------------------------------
		.byte  25,  10, 153,   1,   8	# 10.153.1.8
		.byte  24, 191,  28, 255, 255	# 191.28.255.255
		.byte  23, 191,  28,  88,  90	# 191.28.88.90
		.byte  22, 192, 151, 100,  56	# 192.151.100.56
		.byte  21, 192, 951, 100, 100	# 192.151.100.100
		.byte  20,  82, 163, 140,  80	# 82.163.140.80
		.byte  19,  82, 163, 147,  80	# 146.163.147.80
		.byte  10, 201,  88, 102,  80	# 201.88.102.1
		.byte  11, 148, 163, 170,  80	# 146.163.170.80
		.byte  12, 193,  77,  77,  10	# 193.77.77.10
		.byte	0, 146,  92, 255, 255	# 146.92.255.255
		.byte	1, 147, 163, 255, 255	# 147.163.255.255
		.byte	2, 201,  88,  88,  90	# 201.88.88.90
		.byte	3, 182, 151,  44,  56	# 182.151.44.56
		.byte	4,  24, 125, 100, 100	# 24.125.100.100
		.byte	5, 146, 163, 140,  80	# 146.163.170.80
		.byte	6, 146, 163, 147,  80	# 146.163.147.80
		.byte   7, 201,  88, 102,  80	# 201.88.102.1
		.byte   8, 148, 163, 170,  80	# 146.163.170.80
		.byte   9, 193,  77,  77,  10	# 193.77.77.10
		.byte  30,  22,   8,   5,   1	# 22.8.5.1
		.byte  31,  22,  12, 188, 192	# 22.12.188.192
		.byte  32, 201,  88, 102,   1	# 201.88.102.1
		.byte  33, 148, 200, 170,  80	# 146.163.170.80
		.byte  34, 193,  77,  77,  10	# 193.77.78.10


.text
.globl main

main:
    li $v0, 4
    la $a0, MESSAGE1
    syscall

    # Prompt and read 
    li $v0, 4
    la $a0, MESSAGE2
    syscall
    li $v0, 5
    syscall
    li $t1, 255
    move $s0, $v0  # Store first 

    # Prompt and read 
    li $v0, 4
    la $a0, MESSAGE3
    syscall
    li $v0, 5
    syscall
    move $s1, $v0  # Store second

    # Prompt and read the third 
    li $v0, 4
    la $a0, MESSAGE4
    syscall
    li $v0, 5
    syscall
    move $s2, $v0  # Store third 

    # Prompt and read the fourth octet
    li $v0, 4
    la $a0, MESSAGE5
    syscall
    li $v0, 5
    syscall
    move $s3, $v0  # Store fourth

# Determine the class
    li $t1, 128            # Start of class B
    li $t2, 192            # Start of class C

    slt $t8, $s0, $t1      
    bne $t8, $zero, classA
    slt $t8, $s0, $t2      
    bne $t8, $zero, classB
    j classC

classA:
    li $v0, 4
    la $a0, MESSAGE8
    syscall
    j init_table

classB:
    li $v0, 4
    la $a0, MESSAGE9
    syscall
    j init_table

classC:
    li $v0, 4
    la $a0, MESSAGE10
    syscall
    j init_table

 # Initialize
init_table:
    li $t6, 0              # Line counter
    li $t7, -1             
    la $a1, IP_ROUTING_TABLE  
    lw $a2, IP_ROUTING_TABLE_SIZE  

    # Scanning logic
scan_loop:
    beq $t6, $a2, end  # End loop

    # Load the domain part of the current table entry
    lbu $t8, 1($a1)  # Load first byte
    lbu $t9, 2($a1)  # Load second byte
    lbu $t0, 3($a1)  # Load third byte

    # Compare with the input IP address's domain part
    bne $s0, $t8, continue_scan  
    bne $s1, $t9, continue_scan  
    bne $s2, $t0, continue_scan  

    # found a match
    li $v0,4
    la $a0, MESSAGE15
    syscall
# Print
    li $v0, 1
    lbu $a0, 0($a1)  # Load the line number
    syscall
    
 # Print a newline character 
    li $v0, 11       # syscall for printing a character
    li $a0, '\n'     # Newline character
    syscall

continue_scan:
    addiu $a1, $a1, 5 
    addiu $t6, $t6, 1  
    j scan_loop

check_match:
    bltz $t7, no_match  # If $t7 is still -1, no match was found
    # Output
    li $v0, 4
    la $a0, MESSAGE15
    syscall
    li $v0, 1
    move $a0, $t7
    syscall
    j end
   
no_match:
    # Output 
    li $v0, 4
    la $a0, MESSAGE16
    syscall
    j end

end:
    li $v0, 4              
    la $a0, MESSAGE13      
    syscall

    li $v0, 10             
    syscall