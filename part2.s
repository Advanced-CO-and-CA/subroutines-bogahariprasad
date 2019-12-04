	.bss
	
	.data
	SIZE: .word 0                 @number of elements
	A: .skip 80                   @ARRAY
	N: .word 0                    @At addr N, user input for "element to be searched" is stored
	OUTPUT: .word -1              @Output to store the position of N in array

	ENTER_NUM_ARRAY_ELEMENTS: .asciz "Enter number of array elements\n"
	ENTER_ARRAY_ELEMENTS: .asciz "Enter array elements\n"
	ENTER_SEARCH_ELEMENT: .asciz "Enter Element to be searched\n"
	ELEMENT_FOUND_AT: .asciz "Element found at position: "
	.text

.global _main
.text

_main:

	MOV R0, #1                               @print message on console to enter size of array
	LDR r1, =ENTER_NUM_ARRAY_ELEMENTS
	SWI 0x69

	LDR R0, =IntRead                         @Interrupt to read input from keyboard:
	LDR R0, [R0]                             @read SIZE
	SWI 0x6c
	LDR R9, =SIZE
	STR R0, [R9]
	
	MOV R0, #1                               @print message on console to enter array elements
	LDR R1, =ENTER_ARRAY_ELEMENTS
	SWI 0x69

	LDR R1, [R9]
	MOV R6, R1                               @Read array elements from input and store them in ARRAY.
	LDR R2, =A                           
READ_ARRAY_ELEMENTS:                         
	LDR R0, =IntRead
	LDR R0, [R0]
	SWI 0x6c
	STR R0, [R2], #4
	SUBS R6, R6, #1
	BGT READ_ARRAY_ELEMENTS

	MOV R0, #1                              @print message on output to enter search element
	LDR R1, =ENTER_SEARCH_ELEMENT
	SWI 0x69

	LDR R0, =IntRead                        @read search element from input
	LDR R0, [R0]                            
	SWI 0x6c
	MOV R3, R0                              
	LDR R0, =N
	STR R3, [R0]							@R3 contains N value

	LDR R9, =SIZE
	LDR R1, [R9]							@R1 contains size of array
	LDR R2, =A							    @R2 contains ARRAY base address
	BL BINARY_SEARCH                        @Call subroutine SEARCH
	LDR R5, =OUTPUT                                    
	MOV R9, R0                              @result returned by subroutine in R0 saved in r9
	STR R9, [R5]                            @output index is stored in OUTPUT address

	MOV R0, #1
	LDR R1, =ELEMENT_FOUND_AT               @an output console message which also prints the output
	SWI 0x69
	MOV R0,#1
	MOV R1, R9                              @r9 holds final OUTPUT
	SWI 0x6b

	SWI 0x11

.text	
BINARY_SEARCH:
	STMFD SP!,{R1,R2,R3,LR}            @ARRAY SIZE, ELEMENTS, SEARCH ELEMENT are copied from registers to stack   
	SUB R6, R1, #1                     @Maintain max element in R6 (SIZE-1)
	MOV R5, #0						   @Maintain min element in R5 (0)
	MOV R4, #4
LOOP:
	ADD R7, R5, R6					   @ R7 (mid) = (R5 (low) + R6 (high))/2
	ASR R7, #1
	MLA R8, R7, R4, R2				   @ read element at address = array + index * 4
	LDR R9, [R8]
	CMP R3, R9						   @ compare element at middle index with search element in R3.
	BEQ OUTPUT_INDEX				   @ if element = A[mid], element is found at mid index in A.
	BGT CHANGE_MIN_INDEX			   @ if element > A[mid], change low index to mid+1
	B CHANGE_MAX_INDEX				   @ if element < A[mid], change low index to mid+1
CHANGE_MIN_INDEX:
	ADDGT R5, R7, #1
	CMP R6, R5
	BGE LOOP
CHANGE_MAX_INDEX:
	SUB R6, R7, #1
	CMP R6, R5
	BGT LOOP
	B NOT_FOUND
	
OUTPUT_INDEX:                              
	ADD R0, R7, #1						@as elements are indexed from 0 to SIZE-1. add 1 return position.
	B RETURN_TO_MAIN

NOT_FOUND:                                 
	MOV R0, #-1                         @As element not found,R0=-1
RETURN_TO_MAIN:
	LDMFD SP!,{R1,R2,R3,PC}             @STACK is popped, R0 is returned & PC is updated with LR

IntRead: .word 0