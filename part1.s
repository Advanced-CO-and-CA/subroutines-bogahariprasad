	.bss
	
	.data
	SIZE: .word 0       @number of elements
	A: .skip 80         @ARRAY
	N: .word 0          @At addr N, user input for "element to be searched" is stored
	OUTPUT: .word -1    @Output to store the position of N in array

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
	LDR R2, =A							@R2 contains ARRAY base address
	BL SEARCH                               @Call subroutine SEARCH
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
SEARCH:
	STMFD SP!,{R1,R2,R3,LR}                @ARRAY SIZE, ELEMENTS, SEARCH ELEMENT are copied from registers to stack   
	MOV R4, R1                             @Maintain backup of SIZE in R4
	
LOOP_OVER_ARRAY: 
	LDR R9, [R2], #4                       @iterate over array elements in array elements starting R2 address.
	CMP R9, R3                             @compare with search element in R3 for each element in array R9
	BEQ OUTPUT_INDEX                       @if elements are equal calculate the index
	SUBS R4, R4, #1                        
	BGT LOOP_OVER_ARRAY                    @there are few more elements to be compared
    B NOT_FOUND                            @entire array is searched for element

OUTPUT_INDEX:                              
	SUB R0, R1, R4                         
	ADD R0, #1                             @index is identified and is updated in R0
	B RETURN_TO_MAIN

NOT_FOUND:                                 
	MOV R0, #-1                            @As element not found,R0=-1
RETURN_TO_MAIN:
	LDMFD SP!,{R1,R2,R3,PC}                @STACK is popped, R0 is returned & PC is updated with LR

IntRead: .word 0