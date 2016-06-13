/****************************************************************************
FILE          : commands.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to command functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef COMMANDS_HPP
#define COMMANDS_HPP

/* Initializer and uninitializer. */
int  ComInit(void);
void ComUnInit(void);

/* Prototypes for command functions. */
int unknown(void);
int none(void);
int brk(void);
int quest(void);
int clear(void);
int clock(void);
int disasm(void);
int dump(void);
int exchange(void);
int get(void);
int go(void);
int sim_init(void);
int sim_int(void);
int load(void);
int mem(void);
int sim_nmi(void);
int ports(void);
int quit(void);
int regis(void);
int reset(void);
int save(void);
int set(void);
int ss(void);
int trap(void);
int trapt(void);
int viewm(void);
int viewp(void);

#endif
