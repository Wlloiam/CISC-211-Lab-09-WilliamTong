/*** asmMult.s   ***/
/* SOLUTION; used to test C test harness
 * VB 10/14/2023
 */
    
/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

#include <xc.h>

/* Tell the assembler that what follows is in data memory    */
.data
.align
 
/* define and initialize global variables that C can access */

.global a_Multiplicand,b_Multiplier,rng_Error,a_Sign,b_Sign,prod_Is_Neg,a_Abs,b_Abs,init_Product,final_Product
.type a_Multiplicand,%gnu_unique_object
.type b_Multiplier,%gnu_unique_object
.type rng_Error,%gnu_unique_object
.type a_Sign,%gnu_unique_object
.type b_Sign,%gnu_unique_object
.type prod_Is_Neg,%gnu_unique_object
.type a_Abs,%gnu_unique_object
.type b_Abs,%gnu_unique_object
.type init_Product,%gnu_unique_object
.type final_Product,%gnu_unique_object

/* NOTE! These are only initialized ONCE, right before the program runs.
 * If you want these to be 0 every time asmMult gets called, you must set
 * them to 0 at the start of your code!
 */
a_Multiplicand:  .word     0  
b_Multiplier:    .word     0  
rng_Error:       .word     0 
a_Sign:          .word     0  
b_Sign:          .word     0 
prod_Is_Neg:     .word     0 
a_Abs:           .word     0  
b_Abs:           .word     0 
init_Product:    .word     0
final_Product:   .word     0

 /* Tell the assembler that what follows is in instruction memory    */
.text
.align

 /* Make the following functions globally visible */
.global asmUnpack, asmAbs, asmMult, asmFixSign, asmMain
.type asmUnpack,%function
.type asmAbs,%function
.type asmMult,%function
.type asmFixSign,%function
.type asmMain,%function

 
/* function: asmUnpack
 *    inputs:   r0: contains the packed value. 
 *                  MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *              r1: address where to store unpacked, 
 *                  sign-extended 32 bit a value
 *              r2: address where to store unpacked, 
 *                  sign-extended 32 bit b value
 *    outputs:  r0: No return value
 *              memory: 
 *                  1) store unpacked A value in location
 *                     specified by r1
 *                  2) store unpacked B value in location
 *                     specified by r2
 */
    
asmUnpack:   
    
    /*** STUDENTS: Place your asmUnpack code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    
    .equ constant_value1, 0xFFFF0000
    .equ constant_value2, 0x0000FFFF
    
    ldr r5,=constant_value1
    
    mov r6,r0
    ANDS r6,r6,r5
    LSR r6,16
    BMI negative_multiplicand
    str r6,[r1]
    B case_for_multiplier
    
    negative_multiplicand:
	ORR r6,r6,r5
	str r6,[r1]
	
    case_for_multiplier:
	ldr r5,=constant_value2
	mov r6,r0
	AND r6,r6,r5
	LSL r6,16
	ADDS r6,r6,0
	BMI negative_multiplier
	LSR r6,16
	str r6,[r2]
	B done_for_asmUnpack
	
    negative_multiplier:
	ldr r5,=constant_value1
	LSR r6,16
	ORR r6,r6,r5
	str r6,[r2]
	
    done_for_asmUnpack:
    
    
    pop {r4-r11,LR}

    mov pc, lr
    
    /*** STUDENTS: Place your asmUnpack code ABOVE this line!!! **************/


    /***************  END ---- asmUnpack  ************/

 
/* function: asmAbs
 *    inputs:   r0: contains signed value
 *              r1: address where to store absolute value
 *              r2: address where to store sign bit:
 *                  0 = "+", 1 = "-"
 *    outputs:  r0: Absolute value of r0 input. Same value
 *                  as stored to location given in r1
 *              memory: 
 *                  1) store absolute value in location
 *                     given by r1
 *                  2) store sign bit in location 
 *                     given by r2
 */
asmAbs:  
    /*** STUDENTS: Place your asmAbs code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r6,r0
    adds r6,r6,0
    BMI negative_case
    
    str r6,[r1]
    mov r7,0
    str r7,[r2]
    mov r0,r6
    b done_for_asmAbs
    
    negative_case:
    mvn r6,r6
    mov r7,1
    add r6,r6,r7
    str r6,[r1]
    str r7,[r2]
    mov r0,r6
    
    done_for_asmAbs:
	
    pop {r4-r11,LR}

    mov pc, lr
    /*** STUDENTS: Place your asmAbs code ABOVE this line!!! **************/


    /***************  END ---- asmAbs  ************/

  
  
/* function: asmMult
 *    inputs:   r0: contains abs value of multiplicand (a)
 *              r1: contains abs value of multiplier (b)
 *    outputs:  r0: initial product: r0 * r1
 */    
asmMult:   

    /*** STUDENTS: Place your asmMult code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r7,0
    mov r5,r0
    mov r6,r1
    
    iterate:
    cmp r6,0
    beq done_for_asmMult
    tst r6,1
    addne r7,r7,r5
    lsl r5,r5,1
    lsr r6,r6,1
    b iterate
   
    done_for_asmMult:
    mov r0,r7
    
    
    pop {r4-r11,LR}

    mov pc, lr
    

    /*** STUDENTS: Place your asmMult code ABOVE this line!!! **************/
   
    /***************  END ---- asmMult  ************/


    
/* function: asmFixSign
 *    inputs:   r0: initial product: 
 *              (abs value of A) * (abs value of B)
 *              r1: sign bit of originally unpacked value
 *                  of A
 *              r2: sign bit of originally unpacked value
 *                  of B
 *    outputs:  r0: final product:
 *                  sign-corrected version of initial product
 */ 
asmFixSign:   
    
    /*** STUDENTS: Place your asmFixSign code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    mov r4,r0
    mov r5,r1
    mov r6,r2
    
    cmp r5,0
    beq check_b_sign_a_positive
    b check_b_sign_a_negative
    
    check_b_sign_a_positive:
	cmp r6,0
	bne product_is_negative
	b  done_for_asmFixSign
	
    check_b_sign_a_negative:
	cmp r6,1
	beq done_for_asmFixSign
	b product_is_negative
	
    product_is_negative:
	mvn r4,r4
	add r4,r4,1
	mov r0,r4
	b done_for_asmFixSign
	
    done_for_asmFixSign:
	
    
    pop {r4-r11,LR}

    mov pc, lr
    
    /*** STUDENTS: Place your asmFixSign code ABOVE this line!!! **************/


    /***************  END ---- asmFixSign  ************/



    
/* function: asmMain
 *    inputs:   r0: contains packed value to be multiplied
 *                  using shift-and-add algorithm
 *           where: MSB 16bits is signed multiplicand (a)
 *                  LSB 16bits is signed multiplier (b)
 *    outputs:  r0: final product: sign-corrected product
 *                  of the two unpacked A and B input values
 *    NOTE TO STUDENTS: 
 *           To implement asmMain, follow the steps outlined
 *           in the comments in the body of the function
 *           definition below.
 */
asmMain:   
    
    /*** STUDENTS: Place your asmMain code BELOW this line!!! **************/
    push {r4-r11,LR}
    
    /* Step 1:
     * call asmUnpack. Have it store the output values in 
     * a_Multiplicand and b_Multiplier.
     */   
    ldr r1, =a_Multiplicand
    ldr r2, =b_Multiplier
    BL asmUnpack
    /* Step 2a:
     * call asmAbs for the multiplicand (A). Have it store the
     * absolute value in a_Abs, and the sign in a_Sign.
     */
    /* Load the address of a_Multiplicand */
    
    ldr r1, =a_Abs          
    ldr r2, =a_Sign
    ldr r4,=a_Multiplicand
    ldr r0,[r4]
    BL asmAbs              
    
    /* Step 2b:
     * call asmAbs for the multiplier (B). Have it store the
     * absolute value in b_Abs, and the sign in b_Sign.
     */
    /* Load the address of b_Multiplier */
    
    ldr r1, =b_Abs        
    ldr r2, =b_Sign
    ldr r4,=b_Multiplier
    ldr r0,[r4]
    BL asmAbs      
    
    
    /* Step 3:
     * call asmMult. Pass a_Abs as the multiplicand, 
     * and b_Abs as the multiplier.
     * asmMult returns the initial (positive) product in r0.
     * Store the value returned in r0 to mem location 
     * init_Product.
     */
   
   ldr r4,=a_Abs
   ldr r0,[r4]
   ldr r5,=b_Abs
   ldr r1,[r5]
   BL asmMult
   ldr r4,= init_Product
   str r0,[r4]
    

    /* Step 4:
     * call asmFixSign. Pass in the initial product, and the
     * sign bits for the original a and b inputs. 
     * asmFixSign returns the final product with the correct
     * sign. 
     * Store the value returned in r0 to mem location 
     * final_Product.
     */
    ldr r4,=init_Product
    ldr r0,[r4]
    ldr r5,=a_Sign
    ldr r1,[r5]
    ldr r6,=b_Sign
    ldr r2,[r6]
    BL asmFixSign
    ldr r4,=final_Product
    str r0,[r4]

    /* Step 5:
     * END! Return to caller. Make sure of the following:
     * 1) Stack has been correctly managed.
     * 2) the final answer is stored in r0, so that the C call
     *    can access it.
     */
    
    /*** STUDENTS: Place your asmMain code ABOVE this line!!! **************/
    pop  {r4-r11,LR}
    mov PC,LR

    /***************  END ---- asmMain  ************/
    
    
.end   /* the assembler will ignore anything after this line. */
