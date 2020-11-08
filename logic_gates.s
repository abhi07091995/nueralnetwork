  	PRESERVE8
	AREA  logic_gates, CODE, READONLY
	IMPORT printMsgp
	IMPORT printMsg1p
	IMPORT printTable
	IMPORT get_exponential
	EXPORT __main
	ENTRY

__main FUNCTION
	 
	 MOV R0,#0;					Case 0 AND Gate
	 BL printTable;	
	 BL compute_and;
	 
	 MOV R0,#1;					Case 1 OR Gate
	 BL printTable;
	 BL compute_or;	
	 
	 MOV R0,#2;					Case 2 NAND Gate
	 BL printTable;	
	 BL compute_nand;
	 
	 MOV R0,#3;					Case 3 NOR Gate
	 BL printTable;	
	 BL compute_nor;
	 
	 MOV R0,#4;					Case 4 XOR Gate
	 BL printTable;	
	 BL compute_xor;
	 
	 MOV R0,#5;					Case 5 XNOR Gate
	 BL printTable;	
	 BL compute_xnor;
	 
	 MOV R0,#6;					Case 6 NOT Gate
	 BL printTable;	
	 BL compute_not;
	 
stop B stop
 
	 ENDFUNC	

get_sigmoid FUNCTION	 ; Compute sigmoid function 
	 	 
	 PUSH {LR}
	 VLDR.F32 S8, =1			
	 VADD.F32 S9, S7, S8			; compute (e^-x)+1
	 VDIV.F32 S9, S8, S9			; S9 has 1/(e^-x)+1
	 POP {LR};	
	 BX lr;
	 
	ENDFUNC

apply_sigmoid FUNCTION  ; apply function
	 PUSH {LR}
	 BL get_exponential						; Compute e^-x
	 BL get_sigmoid					; Sigmoid function output in S9
	 
	 VLDR.F32 S14, =0.5				
	 VCMP.F32 S9,S14				; Compare Nueral network output with 0.5		
	 VMRS    APSR_nzcv, FPSCR;
	 MOV R0, R4;
	 MOV R1, R5;
	 MOV R2, R6;
	 MOVGT	R3, #1					; If Y greater than 0.5, output is 1
	 MOVLT	R3, #0					; If Y less than 0.5, output is 0
	 POP {LR}
	 BX lr
	 
	 ENDFUNC	 
	 
apply_sigmoid_new FUNCTION
	 PUSH {LR}
	 BL get_exponential						; Compute e^-x
	 BL get_sigmoid					; Sigmoid function output in S9
	 
	 VLDR.F32 S14, =0.5				
	 VCMP.F32 S9,S14				; Compare Nueral network output with 0.5		
	 VMRS    APSR_nzcv, FPSCR;
	 MOV R0, R4;
	 MOV R1, R5;
	 MOV R2, R6;
	 MOVGT	R1, #1					; If Y greater than 0.5, output is 1
	 MOVLT	R1, #0					; If Y less than 0.5, output is 0
	 POP {LR}
	 BX lr
	 
	 ENDFUNC	 
load_FPU FUNCTION		; loads the FPU reg
	
	 PUSH {LR};
	 
	 VMOV.F32 S0,R4;			Move input1 to S0 
     VCVT.F32.S32 S0,S0
	 VMOV.F32 S1,R5;			Move input2 to S1 
     VCVT.F32.S32 S1,S1; 		
	 VMOV.F32 S2,R6;			Move input3 to S2
     VCVT.F32.S32 S2,S2; 		
	 POP {LR};
	 
	 BX lr;
	 ENDFUNC
	 
__and FUNCTION	;		logic AND
	 PUSH {LR};	 
	 VLDR.F32 S4, = 2				; W1
	 VLDR.F32 S5, = 2				; W2
	 VLDR.F32 S6, = 2				; W3
	 VLDR.F32 S7, = -5				; B
	 
	 VMUL.F32 S0, S0, S4			; A1*W1
	 VMUL.F32 S1, S1, S5			; A2*W2
	 VMUL.F32 S2, S2, S6			; A3*W3
	 VADD.F32 S3, S0, S1			; A1*W1 + A2*W2 
	 VADD.F32 S3, S3, S2			; A1*W1 + A2*W2 + A3*W3 
	 VADD.F32 S3, S3, S7			; A1*W1 + A2*W2 + A3*W3 + Bias
	 
	 VNEG.F32 S3, S3
	 VMOV.F32 S0, S3				; S0 = x
	 BL apply_sigmoid;
	 
	 POP {LR};	
	 BX lr;
	 ENDFUNC

__or FUNCTION	;		logic OR
	 PUSH {LR};	 
	 VLDR.F32 S4,= 2				; W1
	 VLDR.F32 S5,= 2				; W2
	 VLDR.F32 S6,= 2				; W3
	 VLDR.F32 S7,= -1				; B
	 
	 VMUL.F32 S0,S0,S4				; A1*W1
	 VMUL.F32 S1,S1,S5				; A2*W2
	 VMUL.F32 S2,S2,S6				; A3*W3
	 VADD.F32 S3,S0,S1				; A1*W1 + A2*W2 
	 VADD.F32 S3,S3,S2				; A1*W1 + A2*W2 + A3*W3 
	 VADD.F32 S3,S3,S7				; A1*W1 + A2*W2 + A3*W3 + Bias
	 
	 VNEG.F32 S3, S3
	 VMOV.F32 S0, S3				; S0 = x
	 BL apply_sigmoid;
	 POP {LR};	
	 BX lr;
	 ENDFUNC

__not FUNCTION	;		logic NOT	
	 PUSH {LR};	 
	 VLDR.F32 S4,= -2;			W1
	 VLDR.F32 S7,= 1;			B
	 
	 VMUL.F32 S0,S0,S4;			A1*W1
	 VADD.F32 S3,S0,S7;			A1*W1 + B
	 
	 VMOV.F32 S0, S3;			S0 = x
	 BL apply_sigmoid;
	 POP {LR};	
	 BX lr;
	 ENDFUNC

__not_new FUNCTION	;		logic NOT
	 PUSH {LR};	 
	 VLDR.F32 S4,= -2;			W1
	 VLDR.F32 S7,= 1;			B
	 
	 VMUL.F32 S0,S0,S4;			A1*W1
	 VADD.F32 S3,S0,S7;			A1*W1 + B
	 
	 VMOV.F32 S0, S3;			S0 = x
	 BL apply_sigmoid_new;
	 POP {LR};	
	 BX lr;
	 ENDFUNC

__xor FUNCTION	;		logic XOR
	
	PUSH {LR}
	 ; Store the inputs 
	 VMOV.F32 S19,S0;			S19 is A1
	 VMOV.F32 S20,S1;			S20 is A2
	 VMOV.F32 S21,S2;			S21 is A3
	 
	 BL __not;					Computes not for A
			
	 VMOV.F32 S22,R3;			
     VCVT.F32.S32 S22,S22
	 
	 VMOV.F32 S0,S20;			
	 BL __not;					Computes not for B
			
	 VMOV.F32 S23,R3;			
     VCVT.F32.S32 S23,S23
	 
	 VMOV.F32 S0,S21;			
	 BL __not;					Computes not for C
			
	 VMOV.F32 S24,R3;			
     VCVT.F32.S32 S24,S24
	 
	 VMOV.F32 S0,S22;	1)	 A1'*A2*A3'	
	 VMOV.F32 S1,S20;
	 VMOV.F32 S2,S24;
	 BL __and;					compute A1'*A2*A3' 
	 MOV R7,R3;					Store value in R4
	 
	 VMOV.F32 S0,S19;	2)	 A1*A2'*A3'	
	 VMOV.F32 S1,S23;
	 VMOV.F32 S2,S24;
	 BL __and;					compute A1*A2'*A3' 
	 MOV R8,R3;					Store value in R5

	 VMOV.F32 S0,S22;	3)	 A1'*A2'*A3	
	 VMOV.F32 S1,S23;
	 VMOV.F32 S2,S21;
	 BL __and;					compute A1'*A2'*A3 
	 MOV R9,R3;					Store value in R6
	 
	
	 VMOV.F32 S0,S19;	4)	 A1*A2*A3
	 VMOV.F32 S1,S20;
	 VMOV.F32 S2,S21;
	 BL __and;					compute A1*A2*A3 
	 MOV R10,R3;				Store value in R7	

	 VMOV.F32 S0,R10;			
     VCVT.F32.S32 S0,S0; 		
	 VMOV.F32 S1,R9;			
     VCVT.F32.S32 S1,S1; 		
	 VMOV.F32 S2,R8;			
     VCVT.F32.S32 S2,S2; 		
	 
	 BL __or;					Computes OR for R10+R9+R8
	 MOV R10,R3;					
	 
	 VMOV.F32 S0,R7;			
     VCVT.F32.S32 S0,S0; 		
	 VMOV.F32 S1,R10;			
     VCVT.F32.S32 S1,S1;
	 VLDR.F32 S2, =0;			A3
	 
	 BL __or;					Computes OR for R7+R10+0

	 POP {LR}	
	 BX lr
	 ENDFUNC
	 
	 LTORG

__xnor FUNCTION		;		logic XNOR
	 PUSH {LR}	

	 BL __xor
	 VMOV.F32 S0,R3				; Move the count in R4 to S0
     VCVT.F32.S32 S0,S0			
	 BL __not
	 
	 POP {LR}	
	 BX lr
	 ENDFUNC

__nand FUNCTION		;		logic NAND
	 PUSH {LR}
	 VLDR.F32 S4, =-2				; W1
	 VLDR.F32 S5, =-2				; W2
	 VLDR.F32 S6, =-2				; W3
	 VLDR.F32 S7, =5				; B
	                            
	 VMUL.F32 S0, S0, S4			; A1*W1
	 VMUL.F32 S1, S1, S5			; A2*W2
	 VMUL.F32 S2, S2, S6			; A3*W3
	 VADD.F32 S3, S0, S1			; A1*W1 + A2*W2 
	 VADD.F32 S3, S3, S2			; A1*W1 + A2*W2 + A3*W3 
	 VADD.F32 S3, S3, S7			; A1*W1 + A2*W2 + A3*W3 + Bias
	                            
	 VNEG.F32 S3, S3            
	 VMOV.F32 S0, S3;				; S0 = x
	 BL apply_sigmoid;
	 POP {LR}
	 BX lr
	 ENDFUNC

__nor FUNCTION		;		logic NOR
	 PUSH {LR} 
	 VLDR.F32 S4, =-10				; W1
	 VLDR.F32 S5, =-10				; W2
	 VLDR.F32 S6, =-10				; W3
	 VLDR.F32 S7, =5				; B
	                            
	 VMUL.F32 S0, S0, S4			; A1*W1
	 VMUL.F32 S1, S1, S5			; A2*W2
	 VMUL.F32 S2, S2, S6			; A3*W3
	 VADD.F32 S3, S0, S1			; A1*W1 + A2*W2 
	 VADD.F32 S3, S3, S2			; A1*W1 + A2*W2 + A3*W3 
	 VADD.F32 S3, S3, S7			; A1*W1 + A2*W2 + A3*W3 + Bias
	          
	 VNEG.F32 S3, S3   
	 VMOV.F32 S0, S3				; S0 = x
	 BL apply_sigmoid           
	 POP {LR}	
	 BX lr
	 ENDFUNC
	  		   
compute_and FUNCTION	; with different input combination
		
	 PUSH {LR}; 
	 MOV R4,#0;					A1	
	 MOV R5,#0;					A2	
	 MOV R6,#0;					A3	
	 BL load_FPU;
	 BL __and;
	 BL printMsg1p
	 
	 MOV R4,#0;					A1	
	 MOV R5,#0;					A2	
	 MOV R6,#1;					A3	
	 BL load_FPU;
	 BL __and;
	 BL printMsg1p
	 	 
	 MOV R4,#0;					A1	
	 MOV R5,#1;					A2	
	 MOV R6,#1;					A3	
	 BL load_FPU;
	 BL __and;
	 BL printMsg1p
	   
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU;
	 BL __and;
	 BL printMsg1p
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
compute_or FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#0;					A3
	 BL load_FPU;
	 BL __or;
	 BL printMsg1p
	 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#1;					A3
	 BL load_FPU;
	 BL __or;
	 BL printMsg1p
	 	 
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU;
	 BL __or;
	 BL printMsg1p
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
	 
compute_xor FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#0;					A3
	 BL load_FPU; 
	 BL __xor; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xor; 
	 BL printMsg1p;
	 	 
	 MOV R4,#0;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xor; 
	 BL printMsg1p;
	 	 
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xor; 
	 BL printMsg1p;
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
	 	 
compute_xnor FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#0;					A3
	 BL load_FPU; 
	 BL __xnor; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xnor; 
	 BL printMsg1p;
	 	 
	 MOV R4,#0;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xnor; 
	 BL printMsg1p;
	 	 
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __xnor; 
	 BL printMsg1p;
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 

compute_nand FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#0;					A3
	 BL load_FPU; 
	 BL __nand; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __nand; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#1;					A2
	 MOV R6,#0;					A3
	 BL load_FPU; 
	 BL __nand; 
	 BL printMsg1p;
	  
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __nand; 
	 BL printMsg1p;
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
	 
compute_nor FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1 is Input 1
	 MOV R5,#0;					A2	is Input 2
	 MOV R6,#0;					A3	is Input 3
	 BL load_FPU; 
	 BL __nor; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#0;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __nor; 
	 BL printMsg1p;
	 
	 MOV R4,#0;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __nor; 
	 BL printMsg1p;
	 	 
	 MOV R4,#1;					A1
	 MOV R5,#1;					A2
	 MOV R6,#1;					A3
	 BL load_FPU; 
	 BL __nor; 
	 BL printMsg1p;
	 
	 POP {LR};	
     BX lr;						
	 					
	 ENDFUNC 
compute_not FUNCTION	
	
	 PUSH {LR}; 
	 MOV R4,#0;					A1
	 BL load_FPU; 
	 BL __not_new; 
	 BL printMsgp;
	 
	 
	 MOV R4,#1;					A1
	 BL load_FPU; 
	 BL __not_new; 
	 BL printMsgp;
	 
	 POP {LR};	
     BX lr;				
	 					
	 ENDFUNC  

	END