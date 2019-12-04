	.bss
	
	.data
	N: .word 0                   @Read the number N
	OUTPUT: .word 1              @Output to store the Nth fibonacci number

	ENTER_N_VALUE: .asciz "Enter N value\n"
	NTH_FIBONACCI_NUMBER: .asciz "Nth Fibonacci number is : "
	.text

.global _main
.text

_main:

	MOV R0, #1                               @print message on console to enter size of array
	LDR R1, =ENTER_N_VALUE
	SWI 0x69

	LDR R0, =IntRead                         @Interrupt to read input from keyboard:
	LDR R0, [R0]                             @read N
	SWI 0x6c
	LDR R9, =N
	STR R0, [R9]
	MOV R1, R0

	MOV R2, #1							@if N=1 or 2, return 1 in R9
	MOV R3, #1
	MOV R9, #1
	CMP R1, #1
	BEQ OUTPUT_SECTION
	CMP R1, #2
	BEQ OUTPUT_SECTION
	MOV R5, #2							@if N>2, call subroutine
		
	BL FIBONACCI                        @Call subroutine FIBONACCI

OUTPUT_SECTION:
	MOV R0, #1
	LDR R1, =NTH_FIBONACCI_NUMBER       @an output console message which also prints the output
	SWI 0x69
	MOV R0,#1
	MOV R1, R9                          @R9 holds the final OUTPUT
	SWI 0x6b
	LDR R5, =OUTPUT                                    
	STR R9, [R5]                        @output result is stored in OUTPUT address

	SWI 0x11

.text	
FIBONACCI:
	STMFD SP!,{R1,LR}            		@N value copied from registers to stack
	ADD R5, R5, #1				
	ADD R9, R2, R3						@At anypoint of time, maintain result in R9 for corresponding N in R5
	MOV R2, R3							@keep moving f(n-1),f(n-2) for each iteration in R2, R3
	MOV R3, R9
	CMP R5, R1
	BEQ OUTPUT_SECTION
	BL FIBONACCI
	LDMFD SP!,{R1,PC}             @STACK is popped, R0 is returned & PC is updated with LR

IntRead: .word 0