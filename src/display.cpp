/****************************************************************************
FILE          : display.c
LAST REVISION : 2003-10-12
SUBJECT       : Display handling functions.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include "z80sim.hpp"

#include "display.hpp"
#include "mem.hpp"
#include "misc.hpp"
#include "register.hpp"
//#include "screen.h"    // This is PortScr

/*=====================================*/
/*           Global symbols.           */
/*=====================================*/

/* Prototypes of private functions. */
void draw_mem(address, int, int, int);
void set_color(int);

/* The following are for the PrntMessage() system. */
#define MESSAGE_LINE    24              /* Row number of message line.   */
static char message_prompt[]={"> "};   /* Acknowledgment prompt.        */
static char *message_prefix[]={        /* Possible message prefixes.    */
  "INFO: ",
  "WARNING: ",
  "ERROR: ",
  "TRAP: ",
  "INTERNAL ERROR: "
  };
static max_error_level=4;        /* Highest index in the above array.   */
#define REPLY_BUF_SIZE  80        /* Size of buffer for message replies. */

/* The following are for the DrawDisplay() system. */
#define COMMAND_LINE    23              /* Row number of command line.   */
static char major_prompt[]={"-> "};    /* Command prompt.               */
static address mem_start_address=0;    /* Address of start of mem view. */
struct headings {             /* Contains info about static headings.    */
  char *name;
  int  row;
  int  col;
  };
struct reg_layout {     /* Contains info about where to print registers. */
  int row;
  int col;
  int reg_name;
  };

/* The following are for the Prnt() system. */
static int prnt_ignore=NO; /* =YES when user doesn't want to see it all. */

/*--------------------------------------------*/

int DispInit()
  {
    return (NO_ERROR);
  }

/*--------------------------------------------*/

void DispUnInit()
  {
    printf("Uninitializing display.c\n");
    return;
  }

/*--------------------------------------------*/

static void draw_mem(start, srow, scol, length)
  address start;           /* Address of beginning of segment.        */
  int     srow, scol;      /* Row & col of first line (allow 9 cols). */
  int     length;          /* Number of lines to draw.                */
  {
    char    buffer[9+1];
    address current;
    int     i;

    /* Note that the following assumes no overflow checking on addresses!! */
    for (current=start, i=0; i<length; current++, i++) {
      PosCrsr(srow++, scol);
      sprintf(buffer,"%04X ",current);
      if (MemReadAttr(MEM_NOTEXIST,current)) {
        buffer[5]='-';
        buffer[6]='-';
        buffer[7]=' ';
        buffer[8]=' ';
      }
      else {
        sprintf(&buffer[5],"%02X",MemRead(current));
        buffer[7]=' ';
        if (MemReadAttr(MEM_ROM,current)) buffer[8]='R'; else buffer[8]=' ';
      }
      buffer[9]='\0';
      printf(buffer);
    }
    return;
  }

/*--------------------------------------------*/

static void set_color(error_level)
  int error_level;
  {
    switch (error_level) {
      case DISP_INFO:    ScrnColor(Scrn_Black, Scrn_Green);  break;
      case DISP_WARNING: ScrnColor(Scrn_Black, Scrn_Yellow); break;
      case DISP_TRAP:    ScrnColor(Scrn_White, Scrn_Yellow); break;
      case DISP_ERROR:   ScrnColor(Scrn_White, Scrn_Red);    break;

      case DISP_INTERNAL:
        ScrnAttr(SCRN_BRIGHT);
        ScrnColor(Scrn_White, Scrn_Red);
        break;

      default:
        PrntMessage(DISP_INTERNAL,
          "Bad error_level (%d) sent to set_color",error_level);
        break;
    }
    return;
  }

/*--------------------------------------------*/

void SetMemStart(new_start)
  address new_start;
  {
    mem_start_address = new_start;
    return;
  }

/*--------------------------------------------*/

void TitleScreen()
  {
    int i;
    int row;
    static char *title_info[]={
      "             Z80SIM",
      "          Version  1.0",
      "",
      "      (C) ???? Peter Chapin",
      "",
      "Registration Number: XXX-XXX-XXX"
      };
    static char *opening_info[]={
      "Use the 'REGISTER' command for information about registration.",
      "    Use the 'CHECK' command to verify program correctness.",
      "               Type '?' at the prompt for help.",
      "",
      "               Strike the RETURN key to begin.."
      };
    static int title_box[]={
      UL_CRNR,  1, 23,
      UR_CRNR,  1, 58,
      LL_CRNR,  8, 23,
      LR_CRNR,  8, 58,
      HORZ   ,  1, 24, 34,
      HORZ   ,  8, 24, 34,
      VERT   ,  2, 23,  6,
      VERT   ,  2, 58,  6,
      END_OF_LIST
      };
    static int opening_box[]={
      UL_CRNR, 12,  8,
      UR_CRNR, 12, 73,
      LL_CRNR, 18,  8,
      LR_CRNR, 18, 73,
      HORZ,    12,  9, 64,
      HORZ,    18,  9, 64,
      VERT,    13,  8,  5,
      VERT,    13, 73,  5,
      END_OF_LIST
      };

    EraseScrn(SCRN_ALL);
    DrawBox(dbl_box_chars, title_box, PosCrsr);
    for (i=0, row=2; i<6; i++,row++) {
      PosCrsr(row, 25);
      printf(title_info[i]);
    }
    DrawBox(sngl_box_chars, opening_box, PosCrsr);
    for (i=0, row=13; i<5; i++,row++) {
      PosCrsr(row, 10);
      printf(opening_info[i]);
    }
    PosCrsr(SCRN_ROW_MAX-1,1);
    while (getchar()!='\n') /* Null. */ ;
    EraseScrn(SCRN_ALL);
    return;
  }

/*--------------------------------------------*/

char *PrntMessage(error_level, message)
  int  error_level;
  char *message;
  {
    va_list args;
    static  char reply[REPLY_BUF_SIZE+1];

    va_start(args,message);
    PosCrsr(MESSAGE_LINE,1);
    if (error_level < 0 || error_level > max_error_level) {
      PrntMessage(DISP_INTERNAL,"Bad error_level: %d passed to PrntMessage",
                  error_level);
    }
    else {
      set_color(error_level);
      if (error_level == DISP_ERROR  ||  error_level == DISP_INTERNAL) {
        ScrnAttr(SCRN_BLINK);
      }
      printf(message_prefix[error_level]);
      ScrnReset();
      set_color(error_level);
    }
    vprintf(message,args);
    printf(" ");
    ScrnReset();
    printf(message_prompt);
    Get_String(reply,REPLY_BUF_SIZE);
    strupr(reply);
    PosCrsr(MESSAGE_LINE,1);   /* Clean up message line. */
    EraseScrn(SCRN_TO_EOL);
    va_end(args);
    return (reply);
  }

/*-------------------------------------------*/

void DrawDisplay()
  {
    int    i;
    static int boxes[]={
      HORZ,  2,  1, 80,
      HORZ, 19,  1, 80,
      HORZ, 22,  1, 80,
      VERT,  3, 25, 16,
      VERT,  3, 43, 16,
      VERT,  3, 61, 16,
      BS,    2, 25,
      BS,    2, 43,
      BS,    2, 61,
      TS,   19, 25,
      TS,   19, 43,
      TS,   19, 61,
      END_OF_LIST
      };
    static struct headings my_heads[]={
      {"Registers", 1, 7},
      {"Stack",     1, 32},
      {"Memory",    1, 50},
      {"Ports",     1, 66},
      {"Main",      3,  1}, {"Prime",     3, 14},
      {"AF = ",     4,  1}, {"AF = ",     4, 14},
      {"BC = ",     5,  1}, {"BC = ",     5, 14},
      {"DE = ",     6,  1}, {"DE = ",     6, 14},
      {"HL = ",     7,  1}, {"HL = ",     7, 14},
      {"IX = ",     9,  7},
      {"IY = ",    10,  7},
      {"SP = ",    11,  7},
      {"PC = ",    12,  7},
      {"I = ",     14,  1}, {"IFF1 = ",  14, 14},
      {"R = ",     15,  1}, {"IFF2 = ",  15, 14},
      {"SZ H PNC", 17,  7},
      {NULL,        0,  0}
    };
    static struct reg_layout my_layout[]={
      { 4,  6,  AF_REG},
      { 5,  6,  BC_REG},
      { 6,  6,  DE_REG},
      { 7,  6,  HL_REG},
      { 4, 19, AFP_REG},
      { 5, 19, BCP_REG},
      { 6, 19, DEP_REG},
      { 7, 19, HLP_REG},
      { 9, 12,  IX_REG},
      {10, 12,  IY_REG},
      {11, 12,  SP_REG},
      {12, 12,  PC_REG},
      { 0,  0,       0}
      };

    DrawBox(dbl_box_chars,boxes,PosCrsr);
    for (i=0; my_heads[i].name != NULL; i++) {
      PosCrsr(my_heads[i].row, my_heads[i].col);
      printf(my_heads[i].name);
    }
    for (i=0; my_layout[i].row != 0; i++) {
      PosCrsr(my_layout[i].row, my_layout[i].col);
      printf("%04X", WordRegRead(my_layout[i].reg_name));
    }
    PosCrsr(18, 7);
    printf("%1d%1dx%1dx%1d%1d%1d",
            BTST(S_FLAG, ByteRegRead(F_REG)) ? 1 : 0,
            BTST(Z_FLAG, ByteRegRead(F_REG)) ? 1 : 0,
            BTST(H_FLAG, ByteRegRead(F_REG)) ? 1 : 0,
            BTST(P_FLAG, ByteRegRead(F_REG)) ? 1 : 0,
            BTST(N_FLAG, ByteRegRead(F_REG)) ? 1 : 0,
            BTST(C_FLAG, ByteRegRead(F_REG)) ? 1 : 0);
    /*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
    /* This section is provisional... I want to see if memory works. */
    /*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
    draw_mem(0xFFF8, 3, 32, 16);
    draw_mem(mem_start_address, 3, 50, 16);
    /*- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -*/
    PosCrsr(COMMAND_LINE,1);
    EraseScrn(SCRN_TO_EOL);
    printf(major_prompt);
    return;
  }

/*-------------------------------------------*/

void StartPrnt()
  {
    EraseScrn(SCRN_ALL);
    return;
  }

/*--------------------------------------------*/

void Prnt(string)
  char *string;
  {
    if (!prnt_ignore) {
      if (!WriteLines(string,SCRN_COL_MAX,SCRN_ROW_MAX-1)) prnt_ignore = YES;
    }
    return;
  }

/*--------------------------------------------*/

void StopPrnt()
  {
    if (!prnt_ignore) {
      WriteLines("--> Strike RETURN", SCRN_COL_MAX, SCRN_ROW_MAX-1);
      while (getchar() != '\n') /* Null. */ ;
    }
    WriteLines("\f", SCRN_COL_MAX, SCRN_ROW_MAX-1);
    prnt_ignore = NO;
    EraseScrn(SCRN_ALL);
    return;
  }
