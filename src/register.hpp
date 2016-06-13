/****************************************************************************
FILE          : register.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to the register handling functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef REGISTER_HPP
#define REGISTER_HPP

#define A_REG     0    /* Values for the registers must must */
#define F_REG     1    /*    correspond to  index into array */
#define B_REG     2    /*    RegArray[].  Note that  this is */
#define C_REG     3    /*    true for the register pairs.    */
#define D_REG     4
#define E_REG     5
#define H_REG     6
#define L_REG     7

#define AP_REG    8
#define FP_REG    9
#define BP_REG   10
#define CP_REG   11
#define DP_REG   12
#define EP_REG   13
#define HP_REG   14
#define LP_REG   15

#define AF_REG    0
#define BC_REG    2
#define DE_REG    4
#define HL_REG    6

#define AFP_REG   8
#define BCP_REG  10
#define DEP_REG  12
#define HLP_REG  14

#define IX_REG   16
#define IY_REG   18
#define SP_REG   20
#define PC_REG   22

#define C_FLAG    0    /* Must be the same as the bit number in F_REG */
#define N_FLAG    1
#define P_FLAG    2
#define V_FLAG    2
#define H_FLAG    4
#define Z_FLAG    6
#define S_FLAG    7

extern byte RegArray[];

/*-----------------------------------------------------*/
/* Pseudo functions for reading and writing registers. */
/*-----------------------------------------------------*/

#define ByteRegRead(x)     RegArray[x]
#define WordRegRead(x)     (256*RegArray[x] + RegArray[x+1])
#define ByteRegWrite(y,x)  RegArray[x] = y

void ByteWordWrite(word, int);

#endif
