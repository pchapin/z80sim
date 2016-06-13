/****************************************************************************
FILE          : misc.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to various useful functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef MISC_H
#define MISC_H

#ifdef __cplusplus
extern "C" {
#endif

extern boolean Get_String(
  char *Buffer,      /* Buffer to hold the input characters.                */
  int   Buffer_Size  /* Buffer must be Buffer_Size + 1 long to handle null. */
  );

extern boolean Split_String(
  char *Buffer,                 /* String to be split.                          */
  char *Delimiters,             /* String of delimiter characters.              */
  char *Strings[],              /* Array to be filled with pntrs to substrings. */
  int   Max_Nmbr_Of_Strings,    /* Maximum number of substrings allowed.        */
  int  *Actual_Nmbr_Of_Strings  /* Actual number of substrings found.           */
  );

extern int   WriteLines(char *, int, int);
extern char *AdjDate(char *);
extern int   DrawBox(char *, int *, int (*)(int, int));

#ifdef __cplusplus
}
#endif

/* The following symbols are defined for DrawBox(). */

#define UL_CRNR 0
#define UR_CRNR 1
#define LL_CRNR 2
#define LR_CRNR 3
#define RS      4
#define LS      5
#define BS      6
#define TS      7
#define CROSS   8
#define VERT    9
#define HORZ    10
#define END_OF_LIST 11

#endif
