		;		ARM Programming Assignment #2: 64 bit signed integer multiplier
		;
		;		Write a 64-bit SIGNED multiplier. It should take only a small modification to your
		;       unsigned version. Remember (-6)*(-6) = 36, (-6)*6 = -36.
		;		Use the standard shift-and-add operation.
		;		Use the two numbers as an example but write it so it works for any two 16-bit numbers.
		;       Note that in VisUAL you cannot store 64-bit values (double words) directly. The upper
		;       and lower words are your higher 32 bits and lower 32 bits of the two numbers,
		;       respectively.
		;		Write the result in the provided "fill" word.
		;		Indicate if there was a high-bit carry using the provided "fill" word.

		;		Your code here
		
		
main
			adr	r0,upper
			ldr	r1,[r0],#4
			ldr	r3,[r0],#4
			ldr	r2,[r0],#4
			ldr	r4,[r0]
			mov	r5,#0
			cmp	r1,#0
			movlt	r5,#1
			mvnlt	r1,r1
			mvnlt	r2,r2
			addslt	r2,r2,#1
			bge	skip		
			addcs	r1,r1,#1
			
getMSB
			ldmia	sp!,{r0}
			stmdb	sp!,{lr}
			mov	r1,r0
			mov	r2,#0
			
bit
			cmp	r2, #rwidth
			beq	getMSBreturn
			lsls	r1,r1,#1
			addcc	r2,r2,#1
			bcc	bit		
			
getMSBreturn
			rsbs	r2,r2, #rwidth
			mov	r0,r2
			ldmia	sp!,{Lr}
			mov	pc,lr
			
mult
			ldmia	sp!,{r0,r1,r2,r3}
			stmdb	sp!,{r4,r5,r6,r7,r8,r9,r10,lr}
			
			mov	r4,#1    
			mov	r5,#-1    
			mov	r6,#0    
			mov	r7,#0
			mov	r8,#0    
			mov	r9,#0    
			stmdb	sp!,{r0,r1,r2,r3}    
			stmdb	sp!,{r3}            
			bl	getMSB            
			mov	r9,r0            
			ldmia	sp!,{r0,r1,r2,r3}    
			
multloop
			add	r5,r5,#1		
			cmp	r5, #rwidth
			bge	multupper		
			tst	r1,r4,lsl r5
			beq	multloop
			
			add	r10,r5,r9
			cmp	r10, #rwidth
			blt	multloweradd
			sub	r10,r10,#rwidth
			
			mov	r10,r4,lsl r10    
			sub	r8,r10,#1        
			mov	r10,r5        
			rsb	r10,r10,#rwidth
			lsl	r8,r8,r10        
			and	r8,r8,r3        
			lsr	r8,r8,r10        
			add	r7,r7,r8        
			
multloweradd
			add	r6,r6,r3, lsl r5    
			add	r7,r7,r2, lsl r5    
			adrcs	r10,carry
			strcs	r4,[r10]
			mov	r8,#0		
			bal	multloop
			
multupper
			cmp	r5,#64	
			beq	multreturn
			sub	r9,r5,#rwidth
			tst	r0,r4,lsl r9
			beq	multloop
			add	r7,r7,r3,lsl r9
			adrcs	r10,carry
			strcs	r4,[r10]
			cmp	r2,#0
			adrne	r10,carry
			strne	r4,[r10]
			bal	multloop
			
multreturn
			mov	r0,r7
			mov	r1,r6
			ldmia	sp!,{r4,r5,r6,r7,r8,r9,r10,lr}
			mov	pc,lr
			
skip
			cmp	r3,#0
			eorlt	r5,r5,#1
			mvnlt	r3,r3
			mvnlt	r4,r4
			addslt	r4,r4,#1
			stmdb	sp!,{r1,r2,r3,r4}
			bl	mult
			adr	r2,result
			cmp	r5,#1
			mvneq	r0,r0
			mvneq	r1,r1
			addseq	r1,r1,#1
			str	r0,[r2],#4
			str	r1,[r2]
			
			end
upper		DCD		0xFFFFFFFF, 0x00000000
lower		DCD		0xFFFFFFFB, 0x82481248
rwidth		EQU		32
result		FILL		8        ;only need 8 bytes for 64 bit result
carry		FILL		4


