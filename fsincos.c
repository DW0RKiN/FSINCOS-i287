unsigned char PiDiv4_80bit[10] = { 0x35, 0xc2, 0x68, 0x21, 0xa2, 0xda, 0x0f, 0xc9, 0xfe, 0x3f };   // 0x3ffec90fdaa22168c235


/* radians > 0 */
void i287_fsincos( double radians, double *sine, double *cosine )
{
    
    register double _sin, _cos;   
        
    __asm (
	"FLDT	%3\n"                  // pi/4
	"FLDL	%2\n"                  // x, pi/4
	"FPREM\n"                      // x mod pi/4, pi/4
	"FSTSW\n"                      // FPU Status Word => AX
	                               // Status Word:   B,  C3, top, top, top,  C2,  C1,  C0, ...
	                               //        Flag:  SF,  ZF, res,  AF, res,  PF, res,  CF        
	"MOV	%%ah, %%al\n"          //
	"SAHF\n"                       // AH->Flag, ZF = C3
	"JNZ	zero_c3%=\n"           //
	"XOR	$0xff, %%al\n"         // C3 xor C1, C3 xor C0
"zero_c3%=:\n"
        
	"TEST	$0x02, %%ah\n"         // C1?
	"JZ	without_complement%=\n"
	                               // tan ( pi/2 - x ) = sin ( pi/2 - x ) / cos ( pi/2 -x ) = cos ( x ) / sin ( x ) = 1 / tan ( x ) 
	"FSUBR	%%st(1), %%st(0)\n"    // y = pi/4 - (x mod pi/4), pi/4
"without_complement%=:\n"

	"FSTP	%%st(1)\n"             // y
	"FPTAN\n"                      // 1, tan(y)     0 <= y <= Pi/4

	"FLD	%%st(1)\n"             // tan, 1, tan
	"FMUL	%%st(0), %%st(0)\n"    // tan^2, 1, tan
	"FADD	%%st(1), %%st(0)\n"    // 1+tan^2, 1, tan
	"FSQRT\n"                      // (1+tan^2)^0.5, 1, tan
	"FXCH	%%st(2)\n"             // tan, 1, (1+tan^2)^0.5
        
	"TEST	$0x02, %%al\n"         // C3 xor C1
	"JZ	swap_sincos%=\n"
	"FXCH\n"                       // 1, tan, (1+tan^2)^0.5
"swap_sincos%=:\n"
        
	"FDIV	%%st(2), %%st(0)\n"    // sin, 1, (1+tan^2)^0.5
        "SAHF\n"                       // AH->Flag, CF = C0
	"JNC	postive_sin%=\n"
	"FCHS\n"                       // -sin, 1, (1+tan^2)^0.5
"postive_sin%=:\n"
	"FXCH	%%st(2)\n"             // (1+tan^2)^0.5, 1, +-sin
	"FDIVRP\n"                     // cos, +-sin
        
	"TEST	$0x01, %%al\n"         // C3 xor C0
	"JZ	postive_cos%=\n"
	"FCHS\n"                       // -cos, +-sin
"postive_cos%=:\n"

//  2.36   1.57  0.78            1.57
//      \   |C1 /                 |
//     C1 \ | /                C3 |  
// 3.14 ----+---- 0.00   3.14 ----+---- 0.00
//        / | \C1              C0 | C0
//      / C1|   \                 | C3
//  3.93   4.71  5.50            4.71 
/* */
        : "=t" (_cos), "=u" (_sin) : "m" (radians), "m" (PiDiv4_80bit)
    );

    *sine   = _sin;
    *cosine = _cos;
}
