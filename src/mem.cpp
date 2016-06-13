/****************************************************************************
FILE          : mem.c
LAST REVISION : 2003-10-12
SUBJECT       : Implements simulated memory.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include <stdlib.h>
#include <stdio.h>

#ifdef DEBUG
#include <dbg.h>     /* My libraries.     */
#endif

#include "z80sim.hpp"
#include "mem.hpp"

/*===================*/
/* Global variables. */
/*===================*/

byte *Mem=NULL;
byte *MemAttr=NULL;

/*-----------------------------------*/

int MemInit()
  {
    int ret_code=NO_ERROR;

    if ((Mem = (byte *)malloc(65536)) == NULL) {
      ret_code = ERROR;
    }
    else if ((MemAttr = (byte *)malloc(65536)) == NULL) {
      ret_code = ERROR;
    }
    return (ret_code);
  }

/*-----------------------------------*/

void MemUnInit()
  {
    if (Mem != NULL) free(Mem);
    if (MemAttr != NULL) free(MemAttr);
    printf("Uninitializing mem.c\n");
    return;
  }

/*-----------------------------------*/

#ifdef DEBUG

void MemSnap()
  {
   int i;

    dbg_start_prnt(16, 14, "Dump of Memory");
    for (i=0; i<16; i++) {
      dbg_prnt("%04X  %02X  %02X",i,Mem[i],MemAttr[i]);
    }
    dbg_stop_prnt();
    return;
  }

#endif

/*-----------------------------------*/
