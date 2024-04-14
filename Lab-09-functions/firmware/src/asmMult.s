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
    /**constant value to get MSB 16 and LSB 16**/
    .equ constant_value1, 0xFFFF0000			    
    .equ constant_value2, 0x0000FFFF
    
    ldr r5,=constant_value1	/**store constant_value 1 in r5 **/
    
    mov r6,r0			/**storing input r0 in r6**/
    ANDS r6,r6,r5		/**using AND operation, r6 and r5, to get MSB 16 bits, and store it in r6, and update the flags**/
    LSR r6,16			/**shifting r6 16 places right**/
    BMI negative_multiplicand	/**if the negative flag is set, it will direct to the negative_multiplicand branch**/
    str r6,[r1]			/**storing MSB 16 bits in the memory location specified by r1**/
    B case_for_multiplier	/**this will direct to case_for_multiplier branch which is for the LSB 16 Bits**/
    
    /**This branch is for negative multiplicand. IF the MSB 16bits is negative, this branch will perform**/
    negative_multiplicand:
	ORR r6,r6,r5		/**Using Or operator, r6 or r5, to get the signed negative value of the multiplicand**/
	str r6,[r1]		/**storing r6 in the memory location specified by r1**/
	
    /**This branch is for multiplier.**/
    case_for_multiplier:
	ldr r5,=constant_value2	/**storing constant_value2 in the r5**/
	mov r6,r0		/**storing input r0 in the r6**/
	AND r6,r6,r5		/**Using And Operation, r6 AND r5, to get the LSB 16bits, and store it in r6**/
	LSL r6,16		/**shifting r6 16 bits left**/
	ADDS r6,r6,0		/**add r6 to 0 and store it in r6, then update the flags**/
	BMI negative_multiplier	/**If the negative flag is set, it will direct to the negative_multiplier branch**/
	/**If the negative flag is not set, store it in memory location specified by r2**/
	LSR r6,16		/**shifting r6 16 bits right**/
	str r6,[r2]		/**store the r6 values in memory location specified by r2**/
	B done_for_asmUnpack	/**direct to the done_for_asmUnpack**/
    /**This branch is for negative multiplier**/
    negative_multiplier:
	ldr r5,=constant_value1	/**sotre the constan_value1 in the r5**/
	LSR r6,16		/**shfiting r6 right 16 bits**/
	ORR r6,r6,r5		/**using OR operation, r6 OR r5, to get the negative signed value for the multiplier**/
	str r6,[r2]		/**store the r6 value in the memory location specified by the r2**/
	
    done_for_asmUnpack:		/**This is the end of the function asmUnpack**/
    
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
    
    mov r6,r0		/**storing r0, which contains signed value, in r6**/
    adds r6,r6,0	/**add r6 to 0 and store it in r6, then update the flags**/
    BMI negative_case	/**If the negative flag is set, direct to the negative_case branch**/
    /**If the negative flag is not set, store the value in memory location specified by r1, and store 0 in memory location specified by r2 **/
    str r6,[r1]		/**store the r6 value in the memory location specified by r1**/
    mov r7,0		/**store 0 in r7**/
    str r7,[r2]		/**store r7 in memory location specified by r2**/
    mov r0,r6		/**store r6, the absolut value of the input,  in the r0**/
    b done_for_asmAbs	/**direct to the done_for_asmAbs branch**/
    /**This is for the time when the input value is negative**/
    negative_case:
    mvn r6,r6		/**flip the btis in r6, and store it in r6**/
    mov r7,1		/**store 1 in r7**/
    add r6,r6,r7	/**add r6 to r7 and store it in the r6, This is 2'complement method to get the absolut value of the input**/
    str r6,[r1]		/**store r6, absoult value of the input, in the memory location specified by r1**/
    str r7,[r2]		/**store r7, which conatins 1, in the memory location specified by r2**/
    mov r0,r6		/**storing r6, absolute value of the input, in r0 as a initial product**/
    
    done_for_asmAbs:	/**This is the end of the done_for_asmAbs function**/
	
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
    
    mov r7,0		/**storing 0 in the r7**/
    mov r5,r0		/**storing input r0,abs value of multiplicand, in the r5**/ 
    mov r6,r1		/**storing input r1, abs value of multiplier, in the r6**/
    /**This is the iterate branch, it will perform multiplication function by doing shifting and adding method. This method will perform until
    the multiplier is equal to 0**/
    iterate:
    cmp r6,0		/**comparing r6 with 0, to know the multiplier is 0**/
    beq done_for_asmMult/**If the multiplier is equal to 0, it will direct to the done_for_asmMult branch**/
    tst r6,1		/**using TST instruction to  check r6 whether the least significant bit (LSB) of R6 is 0 or 1**/ 
    addne r7,r7,r5	/**If the LSB of r6 is 1, add the r7 to r5 and sotre it in r5. IF not this step will not perform**/
    lsl r5,r5,1		/**shifting r5 left 1 bit and store it in r5**/
    lsr r6,r6,1		/**shifting r6 right 1 bit and store it in r6**/
    b iterate		/**back to the start of the iterate brach**/
   
    done_for_asmMult:	/**This branch will store the result of the multiplication of multiplier and multiplicand in r0**/
    mov r0,r7		/**store the multiplication result r7 in the r0**/
    
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
    
    mov r4,r0			/**Storing the input r0, the intial product, in r4**/
    mov r5,r1			/**Storing the input r1, the sign bit of the multiplicand, in r5**/
    mov r6,r2			/**Storing the input r2, the sign bit of the mulitiplier in r6**/
    
    cmp r5,0			/**compare r5 with 0 to know the multiplicand is positive(0) or negative(1)**/
    beq check_b_sign_a_positive	/**If the r5 equals to 0, the sign of the multiplicand is positive, so will direct to check_b_sign_a_positive branch**/
    b check_b_sign_a_negative	/**If the r5 does not equal to 0, the sign of the multiplicand is negative, so direct to the check_b_sign_a_negative branch**/
    
    /** This branch is to check the sign of the multiplier when the multiplicand is positive.**/
    check_b_sign_a_positive:
	cmp r6,0		/**compare r6 with 0 to know the multiplier is positive(0) or negative(1)**/
	bne product_is_negative	/**If r6 does not equals to 0, the prodcut will be negative, and direct to the product_is_negative branch**/
	b  done_for_asmFixSign	/**If r6 equals to 0, the product is positve, and direct to the done_for_asmFixSign**/
    /**This branch is to check the sign of the mulitplier when the multiplican is negative**/
    check_b_sign_a_negative:
	cmp r6,1		/**compare r6 with 1 to know the multiplier is positve(0) or negative(1)**/
	beq done_for_asmFixSign	/**If the r6 equals to 0, the product is positive, direct to the done_for_asmFixSign branch**/
	b product_is_negative	/**If the r6 does not equal to 0, the product is negative, direct to the product_is_negative branch**/
    /**This branch is for when the product is negative**/
    product_is_negative:
	mvn r4,r4		/**flip the btis of r4, which contains inital product, and store it in r4**/
	add r4,r4,1		/**add r4 to 1, and store it in r4, doing 2's complement method to get the negative value of the inital product**/
	mov r0,r4		/**store the r4, negative value of the inital product, in r0**/
	b done_for_asmFixSign   /**direct to the done_for_asmFixSign branch**/
	
    /**If the product is positive,we dont need to do anything changes in r0**/
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
