if i387 
	FSINCOS			; +-cos, +-sin
else
	FLD	st		; x, x
	FPTAN			; 1, tan(st0), x
	FLD	st(1)		; tan, 1, tan, x
	FMUL	st, st		; tan^2, 1, tan, x
	FADDP	st(1), st	; 1+tan^2, tan, x
	FSQRT			; (1+tan^2)^0.5, tan, x
	FDIVR	st, st(1)	; sin, tan, x
	FABS			; sin, tan, x
	FLD1			; 1, sin, tan, x
	FADD	st, st		; 2, sin, tan, x
	FDIVR	st, st(3)	; x/2, sin, tan, x
	FPTAN			; 1, tan pul, sin, tan, x
	FSTP	st		; tan pul, sin, tan, x
	FMUL	st(1), st	; tpul, sin * tpul, tan, x
	FABS			; abs(tpul), sin * tpul, tan, x
	FDIVP			; +-sin, tan, x
	FSTP	st(2)		; tan, +-sin
	FDIVR	st, st(1)	; +-cos, +-sin
endif
  
