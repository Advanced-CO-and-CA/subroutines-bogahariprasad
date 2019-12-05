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

	stmfd	sp!, {fp, lr}
	add	fp, sp, #4
	sub	sp, sp, #8
	mov	r3, r1
	str	r3, [fp, #-8]
	ldr	r0, [fp, #-8]
		
	BL fib                        @Call subroutine FIBONACCI

	MOV R0, #1
	LDR R1, =NTH_FIBONACCI_NUMBER           @an output console message which also prints the output
	SWI 0x69
	MOV R0,#1
	MOV R1, R3                              @r3 holds final OUTPUT
	SWI 0x6b
	
	SWI 0x11

.text	
fib:
	stmfd	sp!, {r4, fp, lr}     @registers are stored in stack
	add	fp, sp, #8
	sub	sp, sp, #12
	str	r0, [fp, #-16]
	ldr	r3, [fp, #-16]			  @N is stored in the stack w.r.t FP
	cmp	r3, #1					  @compare R3 with 1
	bgt	.L2
	ldr	r3, [fp, #-16]
	b	.L3
.L2:
	ldr	r3, [fp, #-16]
	sub	r3, r3, #1
	mov	r0, r3
	bl	fib
	mov	r4, r0
	ldr	r3, [fp, #-16]
	sub	r3, r3, #2
	mov	r0, r3
	bl	fib
	mov	r3, r0
	add	r3, r4, r3
.L3:
	mov	r0, r3
	sub	sp, fp, #8
	ldmfd	sp!, {r4, fp, pc}

IntRead: .word 0