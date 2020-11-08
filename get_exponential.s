; Exponential series implementation on Cortex-M4 by Taylor Series Expansion

	AREA get_exp_series, CODE, READONLY
	EXPORT get_exponential
	ENTRY
  
get_exponential FUNCTION
	
	;VLDR.F32 S0, =15				; S0 input
	VLDR.F32 S1, =1					; S1 current loop 
	VLDR.F32 S2, =30				; max loop counter where to run
	VMOV.F32 S3, S0					; multiply with  x
	VLDR.F32 S4, =1					; find factorial by multiply with term
	VLDR.F32 S6, =1					; S6 -> counter incrementer
	VLDR.F32 S7, =1					; S7 -> output
	
loop
	VDIV.F32 S5, S3, S4				; computing (x^n/n!)
	VADD.F32 S7, S7, S5				
	
	VADD.F32 S1, S1, S6				; updating current term index
	VMUL.F32 S3, S3, S0				; updating numerator by multiplying by 'x'
	VMUL.F32 S4, S4, S1				; updating denominator by re-computing factorial
	
	VCMP.F32 S1, S2					
	VMRS APSR_nzcv, FPSCR			; VCMP sets FPSCR Flags so ought to move those flags values into ARM Core registers
	BNE loop						

	BX LR
	
	ENDFUNC
	END 