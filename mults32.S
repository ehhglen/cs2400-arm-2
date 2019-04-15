		;		ARM Programming Assignment #2: 32 bit signed integer multiplier
		;
		;		Write a 32-bit SIGNED multiplier. It should take only a small modification to your
		;       unsigned version. Remember (-6)*(-6) = 36, (-6)*6 = -36.
		;		Use the standard shift-and-add operation.
		;		Use the two numbers as an example but write it so it works for any two 16-bit numbers.
		;		Write the result in the provided "fill" word.
		;		Indicate if there was a high-bit carry using the provided "fill" word.

		;		Your code here
		
		adr		r0, numbers ;adr num -> r0
		adr		r7, result  ;adr result -> r7
		adr		r8, carry   ;adr carry -> r8
		
		ldr		r1, [r0]	  ;first num -> r1
		ldr		r2, [r0,#4] ;second num -> r2
		mov		r3, #1	  ;setting mask to 1

		; num1: looks at the sign and changes to positive if flags are set
		movs		r3, r1, lsr #31	
		mvnne	r1, r1			
		addne	r1, r1, #1		
		addne	r8, r8, #1		
		; num2: looks at the sign and changes to positive if flags are set
		movs		r3, r2, lsr #31	
		mvnne	r2, r2			
		addne	r2, r2, #1		
		addne	r8, r8, #1
		
		;splits	two numbers into halfs to be multiplied
		mov		r9, r1, lsr #16
		bic		r11, r1, r9, lsl #16
		mov		r10, r2, lsr #16
		bic		r12, r2, r10, lsl #16
		
		;num1	bottom half * num2 bottom half
		mov		r1,r11
		mov		r2,r12
		bl		ctr
		str		r6, [r0] ;stores result in memory for due to lack of registers
		
		;num1	bottom half * num2 top half
		mov		r1,r11
		mov		r2,r10
		bl		ctr
		str		r6,[r0,#4]
		
		;num		1 top half * num 2 bottom half
		mov		r1, r9
		mov		r2,r12
		bl		ctr
		str		r6,[r0,#8]
		
		;num		1 top half * num 2 top half
		mov		r1,r9
		mov		r2,r10
		bl		ctr
		str		r6, [r0,#12]
		
		;adding	results together and setting flags
		ldr		r1, [r0,#4]
		ldr		r2, [r0,#8]
		adds		r1, r1,r2
		
		;loads	results from memory into registers
		ldr		r2, [r0, #12]
		ldr		r3,[r0,#8]
		ldr		r4,[r0,#4]
		ldr		r5,[r0]
		
		;adds	carry and shifts result 16 bits
		addcs	r2,r2, #&10000
		adds		r5,r5,r1,lsl #16
		adc		r2,r2,r1, lsr #16

				;compares results from earlier checking signed bits and moves negate(twos complement) for each number
		CMP		r8, #1
		MVNEQ	r2, r2
		MVNEQ	r5, r5
		
		;stores	result
		str		r2, [r0]
		str		r5, [r0,#4]
		
		end
		
		;resets	ctr register and accumulator
ctr		mov		r5, #16
		mov		r6, #0
		
loop
		and		r4,r3,r2	  ;logical operator AND to check bits
		subs		r4,r4,#1	  ;checks if the result is 0 or negative
		addpl	r6,r6,r1	  ;if 0 add first num -> accumulator
		lsr		r2,r2,#1	  ;shift number being checked right for the next digit
		lsl		r1,r1,#1	  ;shift number put into acc left
		subs		r5,r5,#1	  ;decrement loop ctr
		bne		loop		  ;branch to loop
		mov		pc, lr
numbers	DCD		0xA0BCFF0D, 0xFFF0ADEA
result	FILL		8
carry	FILL		4



