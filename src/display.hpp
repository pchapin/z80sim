/****************************************************************************
FILE          : display.h
LAST REVISION : 2003-10-12
SUBJECT       : Interface to display handling functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#ifndef DISPLAY_HPP
#define DISPLAY_HPP

int  DispInit(void);
void DispUnInit(void);
void TitleScreen(void);
char *PrntMessage(int, char *, ...);
#define DISP_INFO     0   /* The following symbols are used in connection */
#define DISP_WARNING  1   /*     with PrntMessage.                        */
#define DISP_ERROR    2
#define DISP_TRAP     3
#define DISP_INTERNAL 4
void DrawDisplay(void);
void SetMemStart(address);
void StartPrnt(void);
void Prnt(char *);
void StopPrnt(void);

#endif
