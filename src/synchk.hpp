/****************************************************************************
FILE          : synchk.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to syntax checking functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

This file contains the public interface to the command line syntax checker.
It defines the structure used to hold syntax information (as well as gives
appropriate function prototypes.

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef SYNCHK_H
#define SYNCHK_H

#define SYN_NMBR_KEYS 10  /* Max number of keywords in a syntax.            */
#define MAX_NMBR_SYNS 10  /* Max number of syntax_defs that can be handled. */

/*----------------------------------------------------------------*/
/* The following structure contains the definition of the syntax. */
/*----------------------------------------------------------------*/

struct syntax_def {
  char *keywords[SYN_NMBR_KEYS];
  int  id_code;
  };

/*-------------------------------------------*/
/* Function prototypes for public functions. */
/*-------------------------------------------*/

#ifdef __cplusplus
extern "C" {
#endif

extern int check_syntax(char **tokens, int n_tokens, struct syntax_def *);

#ifdef __cplusplus
}
#endif

#endif
