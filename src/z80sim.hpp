/****************************************************************************
FILE          : z80sim.h
LAST REVISION : 2003-10-12
SUBJECT       : General #defines, etc.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef Z80SIM_HPP
#define Z80SIM_HPP

/*-------------------------------------------------------*/
/* Defined types for better readibility and portability. */
/*-------------------------------------------------------*/
typedef unsigned short address;
typedef unsigned char  p_address;
typedef unsigned char  byte;
typedef unsigned short word;
typedef int            boolean;

/*------------------------------*/
/* Public symbols from z80sim.c */
/*------------------------------*/
extern char *parts[];
extern int  n_parts;

/*--------------------------*/
/* Bit manipulation macros. */
/*--------------------------*/
#define BSET(bit,number) ( (number) |=  (1 << (bit)) )
#define BCLR(bit,number) ( (number) &= ~(1 << (bit)) )
#define BTST(bit,number) ( (number) &   (1 << (bit)) )

/*-------------------------*/
/* Various useful symbols. */
/*-------------------------*/
#define YES      1
#define NO       0
#define NO_ERROR 1
#define ERROR    0

#endif
