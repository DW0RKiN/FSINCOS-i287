void i287_fsincos( double radians, double *sine, double *cosine )
{

	register double cosr, sinr;
    
	__asm (
	"FLD	%%st(0);"                  // x, x
	"FPTAN;"                           // 1, tan(st0), x
	"FLD	%%st(1);"                  // tan, 1, tan, x
	"FMUL	%%st(0), %%st(0);"         // tan^2, 1, tan, x
	"FADDP	%%st(0), %%st(1);"         // 1+tan^2, tan, x
	"FSQRT;"                           // (1+tan^2)^0.5, tan, x
	"FDIVR	%%st(1),%%st(0);"          // sin, tan, x
	"FABS;"                            // sin, tan, x
	"FLD1;"                            // 1, sin, tan, x
	"FADD	%%st(0), %%st(0);"         // 2, sin, tan, x
	"FDIVR	%%st(3), %%st(0);"         // x/2, sin, tan, x
	"FPTAN;"                           // 1, tan pul, sin, tan, x
	"FSTP	%%st(0);"                  // tan pul, sin, tan, x
	"FMUL	%%st(0), %%st(1);"         // tpul, sin * tpul, tan, x
	"FABS;"                            // abs(tpul), sin * tpul, tan, x
	"FDIVRP;"                          // +-sin, tan, x
	"FSTP	%%st(2);"                  // tan, +-sin
	"FDIVR	%%st(1), %%st(0);"         // +-cos, +-sin

	: "=t" (cosr), "=u" (sinr) : "0" (radians));

	*sine = sinr;
	*cosine = cosr;
}

