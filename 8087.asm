.model TINY
.code
.8087

org 100h

;----------------- Program Entry point -----------------
; input st = rad, rad >= 0
; output st = cos(rad), st(1) = sin(rad)
SINCOS:
	PUSH	AX					; 
	FLD		PiDiv4_80bit		; pi/4, x
	FXCH						; x, pi/4
	FPREM						; x mod pi/4, pi/4
	FSTSW	Status				; FPU Status Word => AX
								; Status Word:   B,  C3, top, top, top,  C2,  C1,  C0, ...
						   		;        Flag:  SF,  ZF, res,  AF, res,  PF, res,  CF        
	WAIT						;
    MOV     AX,Status
	MOV		AL, AH				;
	SAHF						; AH->Flag, ZF = C3
	JNZ		zero_c3				;
	XOR		AL, 255				; C3 xor C1, C3 xor C0
zero_c3:
        
	TEST	AH, 2				; C1?
	JZ	without_complement		;
								; tan ( pi/2 - x ) = sin ( pi/2 - x ) / cos ( pi/2 -x ) = cos ( x ) / sin ( x ) = 1 / tan ( x ) 
	FSUBR	st, st(1)			; y = pi/4 - (x mod pi/4), pi/4
without_complement:

	FSTP	st(1)				; y
	FPTAN						; 1, tan(y)     0 <= y <= Pi/4

	FLD		st(1)				; tan, 1, tan
	FMUL	st, st				; tan^2, 1, tan
	FADD	st, st(1)			; 1+tan^2, 1, tan
	FSQRT						; (1+tan^2)^0.5, 1, tan
	FXCH	st(2)				; tan, 1, (1+tan^2)^0.5
        
	TEST	AL, 2				; C3 xor C1
	JZ		swap_sincos
	FXCH						; 1, tan, (1+tan^2)^0.5
swap_sincos:
        
	FDIV	st, st(2)			; sin, 1, (1+tan^2)^0.5
	SAHF						; AH->Flag, CF = C0
	JNC		plus_sin
	FCHS						; -sin, 1, (1+tan^2)^0.5
plus_sin:
	FXCH	st(2)				; (1+tan^2)^0.5, 1, +-sin
	FDIVP   st(1), st			; cos, +-sin
        
	TEST	AL, 1				; C3 xor C0
	JZ		plus_cos
	FCHS						; -cos, +-sin
plus_cos:

	POP		AX					; 
	RET
	
; DT values can be
;• A constant expression that has a value between -2,147,483,648
;and 4,294,967,295 (when the 80386 is selected), or -32,768 and
;65,535 otherwise.

;	PiDiv4_80bit	dt	3ffec90fdaa22168c235h

PiDiv4_80bit label tbyte
	dw	0c235h
	dw	2168h
	dw	0daa2h
	dw	0c90fh
	dw	3ffeh

; Uninitialized data.
	Status label Word
	org $+2
	
END SINCOS


The 8087 needs to wait before each instruction that stops the CPU until the FPU has processed the previous instruction so that they can load the next FPU instruction together.

This WAIT is not written in the code, it is inserted by the compiler itself.

The programmer writes WAIT only after the FPU instruction that sent the data to the CPU, to make sure that the FPU has already sent the data before the CPU will process it.

PS: I don't know why, it wrote the PiDiv4_80bit address wrong.

0x0100:  50             push  ax
0x0101:  9B             wait  
0x0102:  DB 2E 58 01    fld   xword ptr [0x158]
0x0106:  9B             wait  
0x0107:  D9 C9          fxch  st(1)
0x0109:  9B             wait  
0x010a:  D9 01          fld   dword ptr [bx + di]
0x010c:  9B             wait  
0x010d:  A1 62 01       mov   ax, word ptr [0x162]
0x0110:  8A C4          mov   al, ah
0x0112:  9E             sahf  
0x0113:  75 02          jne   0x17
0x0115:  34 03          xor   al, 3
0x0117:  9B             wait  
0x0118:  D8 E9          fsubr st(1)
0x011a:  9B             wait  
0x011b:  DD D9          fstp  st(1)
0x011d:  9B             wait  
0x011e:  D9 F2          fptan 
0x0120:  9B             wait  
0x0121:  9B             wait  
0x0122:  D8 C1          fadd  st(1)
0x0124:  9B             wait  
0x0125:  D9 FA          fsqrt 
0x0127:  9B             wait  
0x0128:  D9 CA          fxch  st(2)
0x012a:  A8 02          test  al, 2
0x012c:  9B             wait  
0x012d:  D8 F2          fdiv  st(2)
0x012f:  9E             sahf  
0x0130:  73 03          jae   0x35
0x0132:  9B             wait  
0x0133:  D9 E0          fchs  
0x0135:  9B             wait  
0x0136:  D9 01          fld   dword ptr [bx + di]
0x0138:  74 03          je    0x3d
0x013a:  9B             wait  
0x013b:  D9 E0          fchs  
0x013d:  58             pop   ax
0x013e:  C3             ret 
0x013f:  35 c2 68 21 a2 da 0f c9 fe 3f
