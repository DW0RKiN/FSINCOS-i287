; input st = rad, rad >= 0
; output st = cos(rad), st(1) = sin(rad)
SINCOS:
	PUSH	AX                   ; 
	FLD	[PiDiv4_80bit]       ; pi/4, x
	FXCH                         ; x, pi/4
	FPREM                        ; x mod pi/4, pi/4
	FSTSW	AX                   ; FPU Status Word => AX
	                             ; Status Word:   B,  C3, top, top, top,  C2,  C1,  C0, ...
	                             ;        Flag:  SF,  ZF, res,  AF, res,  PF, res,  CF        
	WAIT                         ;
	MOV	AL, AH               ;
	SAHF                         ; AH->Flag, ZF = C3
	JNZ	zero_c3              ;
	XOR	AL,0ffh              ; C3 xor C1, C3 xor C0
zero_c3:
        
	TEST	AH, 02h              ; C1?
	JZ	without_complement
	                             ; tan ( pi/2 - x ) = sin ( pi/2 - x ) / cos ( pi/2 -x ) = cos ( x ) / sin ( x ) = 1 / tan ( x ) 
	FSUBR	st, st(1)            ; y = pi/4 - (x mod pi/4), pi/4
without_complement:

	FSTP	st(1)                ; y
	FPTAN                        ; 1, tan(y)     0 <= y <= Pi/4

	FLD	st(1)                ; tan, 1, tan
	FMUL	st, st               ; tan^2, 1, tan
	FADD	st, st(1)            ; 1+tan^2, 1, tan
	FSQRT                        ; (1+tan^2)^0.5, 1, tan
	FXCH	st(2)                ; tan, 1, (1+tan^2)^0.5
        
	TEST	AL, 02h              ; C3 xor C1
	JZ	swap_sincos
	FXCH                         ; 1, tan, (1+tan^2)^0.5
swap_sincos:
        
	FDIV	st, st(2)            ; sin, 1, (1+tan^2)^0.5
	SAHF                         ; AH->Flag, CF = C0
	JNC	postive_sin
	FCHS                         ; -sin, 1, (1+tan^2)^0.5
postive_sin:
	FXCH	st(2)                ; (1+tan^2)^0.5, 1, +-sin
	FDIVP                        ; cos, +-sin
        
	TEST	AL, 01h              ; C3 xor C0
	JZ	postive_cos
	FCHS                         ; -cos, +-sin
postive_cos:

	POP	AX                   ; 
	RET
	
	PiDiv4_80bit	dt	3ffec90fdaa22168c235h
