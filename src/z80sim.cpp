/****************************************************************************
FILE          : z80sim.c
LAST REVISION : 2003-10-12
SUBJECT       : Main program file of Z-80 Simulator
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#include "z80sim.hpp"
#include "commands.hpp"
#include "display.hpp"
#include "mem.hpp"
#include "misc.hpp"

/*=======================================*/
/*           Arbitrary Limits.           */
/*=======================================*/

#define MAX_CMD_LEN    70      /* Maximum command line length.        */
#define MAX_NMBR_PARTS 15      /* Max nmbr of parts in the cmd line.  */

/*=========================================*/
/*           Global Data Objects           */
/*=========================================*/

static char *cmds[]={
  "NONE",                     /* Array of command names.              */
  "?",
  "BRK",
  "CLEAR",
  "CLOCK",
  "DISASM",
  "DUMP",
  "EXCHANGE",
  "GET",
  "GO",
  "INIT",
  "INT",
  "LOAD",
  "MEM",
  "NMI",
  "PORTS",
  "QUIT",
  "REGISTER",
  "RESET",
  "SAVE",
  "SET",
  "SS",
  "TRAP",
  "TRAPT",
  "VIEWM",
  "VIEWP",
  NULL
  };

enum command_name {
  NONE,     QUEST,    BRK,      CLEAR,    CLOCK,    DISASM,   DUMP,
  EXCHANGE, GET,      GO,       INIT,     INT,      LOAD,     MEM,
  NMI,      PORTS,    QUIT,     REGISTER, RESET,    SAVE,     SET,
  SS,       TRAP,     TRAPT,    VIEWM,    VIEWP
  };

       char *parts[MAX_NMBR_PARTS];   /* Holds pointers to cmd parts. */
       int  n_parts;                  /* Number of cmd parts.         */
static char delim[]={" ,="};          /* String of cmd delimiters.    */
static char cmd_line[MAX_CMD_LEN+1];  /* Holds the command line.      */
static int  cmd;                      /* Command index.               */
static int (*init_fncts[])(void)={    /* Pointers to initializers.    */
  DispInit,   ComInit,   MemInit,   NULL
  };
static void (*uninit_fncts[])(void)={ /* Pointers to uninitializers.  */
  DispUnInit, ComUnInit, MemUnInit, NULL
  };

/*------------------------*/
/* For the help function. */
/*------------------------*/

#define HLPFILE        "Z80SIM.HLP"  /* Name of the help file.        */
#define HELP_BUFFER    80     /* Max line length in the help file.    */
#define SPECIAL_CHAR   '!'    /* Marker character in the help file.   */

/*====================================================================*/
/* What follows are the definitions of the functions:                 */
/*     init()     : Initializes the program modules.                  */
/*     set_cmd()  : Decides which command was invoked.                */
/*     help()     : Searches help file for information.               */
/*====================================================================*/

int  init(void);      /* Function prototypes. */
int  set_cmd(void);
void help(int);

/*-------------------------------------*/

static int init()
  {
    int ret_value = NO_ERROR;
    int abort = NO;
    int i;

    for (i=0; init_fncts[i]!=NULL  &&  !abort; i++) {
      if (init_fncts[i]() == NO_ERROR) atexit(uninit_fncts[i]);
      else {
	abort = YES;
	ret_value = ERROR;
      }
    }
    return (ret_value);
  }

/*-------------------------------------*/

static int set_cmd()
  {
    int i;
    int ret_code = NO_ERROR;

    cmd = -1;               /* index = -1 : command unknown. */
    if (n_parts == 0) parts[0] = cmds[0];
    for (i=0; cmds[i] != NULL; i++) if (strcmp(parts[0],cmds[i]) == 0) cmd = i;
    return (ret_code);
  }

/*-------------------------------------*/

static void help(int x)
  {
    FILE *helpfile;
    char buffer[HELP_BUFFER+2];
    int  printing = NO;
    int  done     = NO;

    if ((helpfile=fopen(HLPFILE,"r")) == NULL) {
      PrntMessage(DISP_ERROR,"Cannot open the help file: %s",HLPFILE);
    }
    else {
      while (!done && fgets(buffer,HELP_BUFFER+2,helpfile) != NULL) {
        buffer[strlen(buffer+1)] = '\0';   /* Kill \n at end of buffer. */
        if (!printing) {
          if (buffer[0] == SPECIAL_CHAR  &&
              strcmp(&buffer[1],cmds[x]) == 0) {
            printing = YES;
            StartPrnt();
          }
        }
        else {
          if (buffer[0] != SPECIAL_CHAR) {
            Prnt(buffer);
          }
	  else {
            fclose(helpfile);
	    done = YES;
            StopPrnt();
          }
        }
      }  /* End of main while loop. */
      if (!done) {
        fclose(helpfile);
        PrntMessage(DISP_ERROR,"No help available");
      }
    }  /* End of overall if...else... */
    return;
  }

/***********************************************************************/

int main(void)
  {
    int exit_code = 0;  /* Returned to operating system. */
    int done = NO;     /* =YES when user wants to quit. */


    if (init() == ERROR) {
      exit_code = 1;
    }
    else {
      TitleScreen();
      do {
	DrawDisplay();

	/* Get a command, parse it, and see if its a legal command. */
	/* Proceed only if all those activities occur ok.           */
	if (!Get_String(cmd_line, MAX_CMD_LEN)) {
	  PrntMessage(DISP_ERROR,"Too many characters in the command line");
	}
	else if (strupr(cmd_line),
		!Split_String(cmd_line,delim,parts,MAX_NMBR_PARTS,&n_parts)) {
	  PrntMessage(DISP_ERROR,"Too many arguments in the command line");
	}
	else if (set_cmd() == ERROR) {
	  PrntMessage(DISP_INTERNAL,"set_cmd() returned ERROR to main()");
	}
	else {

	  /* Check for help option. Otherwise call appropriate command */
	  /* function.                                                 */
	  if (n_parts==2 && strcmp(parts[1],"?")==0) help(cmd);
          else
          switch (cmd) {

            default:
              /* Handle the case of an unknown command. */
	      unknown();
              break;

            case NONE:
              /* Handle the null command. */
              none();
	      break;

            case BRK:       brk();      break;
            case QUEST:     quest();    break;
            case CLEAR:     clear();    break;
            case CLOCK:     clock();    break;
            case DISASM:    disasm();   break;
            case DUMP:      dump();     break;
            case EXCHANGE:  exchange(); break;
            case GET:       get();      break;
            case GO:        go();       break;
            case INIT:      sim_init(); break;
            case INT:       sim_int();  break;
            case LOAD:      load();     break;
	    case MEM:       mem();      break;
            case NMI:       sim_nmi();  break;
            case PORTS:     ports();    break;
            case QUIT:
              if (quit() == YES) done = YES;
              break;
	    case REGISTER:  regis();    break;
            case RESET:     reset();    break;
            case SAVE:      save();     break;
            case SET:       set();      break;
            case SS:        ss();       break;
            case TRAP:      trap();     break;
            case TRAPT:     trapt();    break;
            case VIEWM:     viewm();    break;
            case VIEWP:     viewp();    break;

          }            /* End of switch block.     */
        }              /* End of if-else-if chain. */
      } while (!done); /* End of command loop.     */
    }                  /* End of else block (after init() call.) */
    exit(exit_code);   /* Performs all actions specified using atexit(). */
    printf("INTERNAL ERROR: exit() returned\n");
    return 100;
  }  /* End of main program. */
