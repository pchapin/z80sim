/****************************************************************************
FILE          : mem.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to simulated memory.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef MEM_HPP
#define MEM_HPP

/*----------------------*/
/* Function prototypes. */
/*----------------------*/
int  MemInit(void);
void MemUnInit(void);

#ifdef DEBUG
void MemSnap(void);
#endif

/*--------------------------*/
/* Public global variables. */
/*--------------------------*/
extern byte *Mem;
extern byte *MemAttr;

/*-------------------*/
/* Pseudo-functions. */
/*-------------------*/
#define MemRead(x)        Mem[x]       /* Read memory with no checking.  */
#define MemWrite(y,x)     Mem[x] = y   /* Write memory with no checking. */
#define MemReadAttr(y,x)  BTST(y,MemAttr[x])  /* Check memory attribute. */
#define MemSetAttr(y,x)   BSET(y,MemAttr[x])  /* Set memory attribute.   */
#define MemClearAttr(y,x) BCLR(y,MemAttr[x])  /* Clear memory attribute. */

/*--------------------------*/
/* Names of attribute bits. */
/*--------------------------*/
#define MEM_INIT     0  /* bit 0 equals one if location initialized.    */
#define MEM_NOTEXIST 1  /* bit 1 equals one if location does not exist. */
#define MEM_ROM      2  /* bit 2 equals one if location is ROM.         */

#endif
