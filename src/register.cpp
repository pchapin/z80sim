/****************************************************************************
FILE          : register.c
LAST REVISION : 2003-10-12
SUBJECT       : Implementation of register handling functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include "z80sim.hpp"
#include "display.hpp"
#include "register.hpp"

byte RegArray[24];    /* See #define's in register.h           */
                      /* Note that registers are =0 initially. */

void WordRegWrite(word value, int reg_name)
  {
    if (value > PC_REG  ||  value % 2 != 0)
      PrntMessage(DISP_INTERNAL, "Bad register name passed to WordRegWrite");
    else {
      RegArray[reg_name]   = (value & 0xff00) >> 8;
      RegArray[reg_name+1] = (value & 0x00ff);
    }
    return;
  }
