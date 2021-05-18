.data
	string1: .asciiz "Please input vector A:\n"
	string2: .asciiz "Please input vector B:\n"
	lowerBracket: .asciiz  ")\n\0"
	string3: .asciiz "A+B = ("
	string4: .asciiz  "A-B = ("	
	string5: .asciiz  "A*B = "
	array_s: .space 100
	array_i: .space 100
	array_j: .space 100
	char: .space 100 
	null: .asciiz "" 
	space: .asciiz " " 
	newline: .asciiz "\n" 
	comma: .asciiz ","
	minus: .asciiz "-"
	
.text

#--------------------------Array one---------------------------------------------
main: 
	add $v0, $zero, $zero	# initialize
	add $a0, $zero, $zero
	li $v0, 4   	 
	la $a0, string1 
	syscall   		#print prompt

gets:   
	la $s1, array_s 		 #set base address of array to $s1 
loop:   				#start of read loop 
	jal getchar 	 	#jump to getchar in order to get  one charactor in buffer 
	lb $t0, char 	 	#load the char from char buffer into t0
	sb $t0, 0($s1) 	 	#store the char into the nth element of array 
	lb $t1, newline 		 #load newline char into t1 
	beq $t0, $t1, done	 #if end of string then jump to done 
	addi $s1, $s1, 1 		# base address ++
	j loop   		#jump to  loop 

getchar:  				 #read char from  buffer  
	li $v0, 8  		# read string 
	la $a0, char  		
	li $a1, 2 		
	syscall   		#store the char byte from  buffer into char 
	jr $ra   		#jump back to the gerchar function

	
done:  
	beq $t9, 1, done2
	
	lb  $s4, comma 		 # load comma into $s4
	lb  $s7, minus		# load minus into $s7
	add $t0, $zero, $zero	#set $t0 as a counter for minus sign
	addi $s1, $s1, -1 	# relocate address to as the end point
	la $s0, array_s 	 	#set base address of array_s to as the start point 
	la $s5, array_i  		#set base address t of array_i to as the integer array start point to store
	 
	lb $s1, newline		#load newline char into $s1
	
	
transition:
	beq $t9, 1, transition2		# if $t9 is 1,that was mean it's in reading second array
	lb $t1, 0($s0) 	#load char from array into t1 
	beq $t1, $s1, nextarray	# if read the newline then goto execute
	addi $s0, $s0, 1		# address ++
	jal m_count 	# check if minus or not
	jal checkcomma	# check if comma or not 
	jal trans_i
	j transition 	# loop to transfer the char array to integer array
	

#----------------------------Array two------------------------------------
nextarray:
	li $v0, 4   	 
	la $a0, string2
	syscall   		#print prompt
	addi $t9, $t9, 1
	j gets
done2:	
	lb  $s4, comma 		 # load comma into $s4
	lb  $s7, minus		# load minus into $s7
	add $t0, $zero, $zero	#set $t0 as a counter for minus sign
	addi $s1, $s1, -1 	# relocate address to as the end point
	la $s0, array_s 	 	#set base address of array_s to as the start point 
	la $s2, array_j	#set base address t of array_i to as the integer array start point to store
	 
	lb $s1, newline		#load newline char into $s1
	
	
transition2:
	lb $t1, 0($s0) 	#load char from array into t1 
	beq $t1, $s1, pre_plus	# if read the newline then goto execute
	addi $s0, $s0, 1		# address ++
	jal m_count 	# check if minus or not
	jal checkcomma	# check if comma or not 
	jal trans_i
	j transition2	# loop to transfer the char array to integer array
	

#------------------------A+B--------------------------------------
pre_plus:
	la $s0, array_i   	#set base address of array_i to as the start point 
	la $s3, array_j  		#set base address of array_j to as the integer array start
	li $v0, 4
	la $a0, string3
	syscall
	add $t9, $zero, $zero  	#initialize $t9 as a count

plus:
	lb $t1, 0($s0)
	lb $t2, 0($s3)
	jal plus_exe
	li $v0, 1
	add $a0, $t3, $zero
	syscall
	addi $t9, $t9,1
	beq $t9, 8, pre_minus		#if counter is 8 then goto next operation
	li $v0, 4
	la $a0, comma
	syscall
	j plus
#------------------------A-B--------------------------------------
pre_minus:
	li $v0, 4
	la $a0, lowerBracket
	syscall
	la $s0, array_i   	#set base address of array_i to as the start point 
	la $s3, array_j  		#set base address of array_j to as the integer array start
	li $v0, 4
	la $a0, string4
	syscall
	add $t9, $zero, $zero  	#initialize $t9 as a count
minus2:
	lb $t1, 0($s0)
	lb $t2, 0($s3)
	jal minus_exe
	li $v0, 1
	add $a0, $t3, $zero
	syscall
	addi $t9, $t9,1
	beq $t9, 8, pre_multiply		#if counter is 8 then goto next operation
	li $v0, 4
	la $a0, comma
	syscall
	j minus2
#------------------------A*B--------------------------------------
pre_multiply:
	add $t3, $zero, $zero 	 #initialize $t3
	add $t4, $zero, $zero	#initialize $t4
	li $v0, 4
	la $a0, lowerBracket
	syscall
	la $s0, array_i   	#set base address of array_i to as the start point 
	la $s3, array_j  		#set base address of array_j to as the integer array start
	li $v0, 4
	la $a0, string5
	syscall
	add $t9, $zero, $zero  	#initialize $t9 as a count
multiply:
	lb $t1, 0($s0)
	lb $t2, 0($s3)
	jal multiply_exe
	addi $t9, $t9,1
	beq $t9, 8, end
	j multiply
	
end:	
	li $v0, 1		#print the product of both vector
	add $a0, $t3, $zero
	syscall
	j FIN
#-------------------------function--------------------------------

m_count:		#to check it have minus or not
	beq $t1, $s7, m_count_e
	jr $ra
m_count_e:
	addi $t0, $t0, 1
	j transition	
checkcomma:	# if charactor is comma then it means that it have to be the end sign of  a number, so i have to combine $t2 $t3 $t4
	beq $t1, $s4, transition 
	jr $ra
trans_i:
	addi $t1, $t1, -48
	beq $t0, 1, trans_m
	j finalnum
trans_m:			# if minus sign is 1 , the number should be change to negative
	add $t0, $zero, $zero
	sub $t1, $zero, $t1
	j finalnum
finalnum:			 #get the integer
	beq $t9, 1, finalnum2	#if it have minus sign 
	sb $t1, 0($s5)
	addi $s5, $s5, 1
	j transition
finalnum2:		# change to the minus one
	sb $t1, 0($s2)
	addi $s2, $s2, 1
	j transition2
plus_exe:			# plus
	add $t3, $t1, $t2
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	jr $ra
minus_exe:		#minus
	sub $t3, $t1, $t2
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	jr $ra
multiply_exe:		#multiply
	mul $t4, $t1, $t2
	add $t3, $t3, $t4
	addi $s0, $s0, 1
	addi $s3, $s3, 1
	jr $ra

FIN: 
	li $v0, 10  #ends program 
	syscall 
