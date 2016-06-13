/****************************************************************************
FILE          : commands.c
LAST REVISION : 2003-10-12
SUBJECT       : Functions that implement the commands.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "z80sim.hpp"

#include "commands.hpp"
#include "display.hpp"
#include "mem.hpp"
#include "misc.hpp"
#include "synchk.hpp"

/* Declarations of global data objects. */
extern  char *parts[];   /* Holds pointers to cmd parts. */
extern  int   n_parts;   /* Number of cmd parts.         */


/* Function prototypes for local functions. */
int  get_address(char *, address *);
int  get_address_range(address *, address *, int);

/*-----------------------------------------------*/

int ComInit()
  {
    return (NO_ERROR);
  }

/*-----------------------------------------------*/

void ComUnInit()
  {
    printf("Uninitializing commands.c\n");
    return;
  }

/*-----------------------------------------------*/

static int get_address(char *string, address *address_ptr)
  {
    int  ret_code=NO_ERROR;
    char *end_ptr;
    long temp_add;

    errno = 0;
    end_ptr = string;
    temp_add = strtol(string, &end_ptr, 16);
    if (*end_ptr != '\0') {
      PrntMessage(DISP_ERROR,
        "The address '%s' contains illegal characters", string);
      ret_code = ERROR;
    }
    else if (temp_add < 0L) {
      PrntMessage(DISP_ERROR,
        "The address '%s' is negative", string);
      ret_code = ERROR;
    }
    else if (temp_add > 65535L || errno) {
      PrntMessage(DISP_ERROR,
        "The address '%s' is out of range", string);
      ret_code = ERROR;
    }
    else {
      *address_ptr = (address) temp_add;
    }
    return (ret_code);
  }

/*-----------------------------------------------*/

static int get_address_range(address *start_ptr, address *stop_ptr, int offset)
  {
    int  ret_code=NO_ERROR;
    char *add_ptrs[2];
    int  nmbr_of_adds;

    if (n_parts < offset+1) {
      PrntMessage(DISP_INTERNAL,
        "get_address_range received bad offset: %d",offset);
      ret_code = ERROR;
    }
    else {
      if (!Split_String(parts[offset],"-", add_ptrs, 2, &nmbr_of_adds)) {
        PrntMessage(DISP_WARNING,
          "The address range has too many componets. Using %s-%s",
          add_ptrs[0], add_ptrs[1]);
      }
      if (!get_address(add_ptrs[0], start_ptr)) {
        ret_code = ERROR;
      }
      else {
        *stop_ptr = *start_ptr;
        if (nmbr_of_adds == 2) {
          if (!get_address(add_ptrs[1], stop_ptr)) ret_code = ERROR;
          else if (*start_ptr > *stop_ptr) {
            PrntMessage(DISP_ERROR,"Second address is smaller");
            ret_code = ERROR;
          }
        }
      }
    }
    return (ret_code);
  }

/*-----------------------------------------------*/

int none()
  {
    return (NO_ERROR);
  }

/*-----------------------------------------------*/

int unknown()
  {
    PrntMessage(DISP_ERROR,"The command '%s' is unknown",parts[0]);
    return (NO_ERROR);
  }

/*-----------------------------------------------*/

int quest()
  {
    int    i;
    static char *command_summary[]={
      "brk      -- Set, clear, or view breakpoint addresses.",
      "clear    -- Clear flag, register, or memory range to zero.",
      "clock    -- Sets or views the simulated clock frequency.",
      "disasm   -- Disassembles memory to full screen or file.",
      "dump     -- Displays contents of memory to full screen or file.",
      "exchange -- Exchanges main and primed registers.",
      "get      -- Get simulator configuration file.",
      "go       -- Start simulation.",
      "init     -- Force simulator to initial state.",
      "int      -- Simulate action of maskable interrupt.",
      "load     -- Load Intel format hex file into simulated memory.",
      "mem      -- Declare attributes of simulated memory.",
      "nmi      -- Simulate action of nonmaskable interrupt.",
      "ports    -- Declare attributes of simulated ports.",
      "quit     -- Exit to operating system.",
      "reset    -- Reset simulated Z-80.",
      "save     -- Save simulator configuration file.",
      "set      -- Set flag, register, or memory range to a value.",
      "ss       -- Single step the simulated Z-80.",
      "trapt    -- Define excessive T-state trap condition.",
      "viewm    -- Set starting point of displayed memory segment.",
      "viewp    -- Set starting point of displayed port segment.",
      NULL
      };

    StartPrnt();
    Prnt("For more information about a command:");
    Prnt("Type the name of the command followed by '?' at the main prompt.");
    Prnt(" ");
    for (i=0; command_summary[i]!=NULL; i++) {
      Prnt(command_summary[i]);
    }
    StopPrnt();
    return (NO_ERROR);
  }

/*-----------------------------------------------*/

int brk()
  {
    PrntMessage(DISP_INFO,"brk command entered. Address=%p", brk);
    PrntMessage(DISP_ERROR,"brk command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int clear()
  {
    PrntMessage(DISP_ERROR,"clear command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int clock()
  {
    PrntMessage(DISP_ERROR,"clock command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int disasm()
  {
    PrntMessage(DISP_ERROR,"disasm command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int dump()
  {
    PrntMessage(DISP_ERROR,"dump command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int exchange()
  {
    PrntMessage(DISP_ERROR,"exchange command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int get()
  {
    PrntMessage(DISP_ERROR,"get command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int go()
  {
    PrntMessage(DISP_ERROR,"go command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int sim_init()
  {
    PrntMessage(DISP_ERROR,"init command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int sim_int()
  {
    PrntMessage(DISP_ERROR,"int command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int load()
  {
    PrntMessage(DISP_ERROR,"load command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int mem()
  {
    address start_address;
    address stop_address;
    long    i;
    int     cur_syn;
    static struct syntax_def syntax[]={
      {{"MEM","ROM","AT","?ADDRESS RANGE",NULL},0},
      {{"MEM","R+","?ADDRESS RANGE",NULL},      1},
      {{"MEM","RAM","AT","?ADDRESS RANGE",NULL},2},
      {{"MEM","R-","?ADDRESS RANGE",NULL},      3},
      {{"MEM","NOT","AT","?ADDRESS RANGE",NULL},4},
      {{"MEM","-","?ADDRESS RANGE",NULL},       5},
      {{"MEM","AT","?ADDRESS RANGE",NULL},      6},
      {{"MEM","+","?ADDRESS RANGE",NULL},       7},
      {{NULL},                                 -1}
      };

    switch (cur_syn = check_syntax(parts, n_parts, syntax)) {
      case 0:
      case 1:
        if (get_address_range(&start_address, &stop_address,
                                          cur_syn==0 ? 3 : 2)) {
          for (i=start_address; i<=stop_address; i++)
            MemSetAttr(MEM_ROM,i);
        }
        break;

      case 2:
      case 3:
        if (get_address_range(&start_address, &stop_address,
                                          cur_syn==2 ? 3 : 2)) {
          for (i=start_address; i<=stop_address; i++)
            MemClearAttr(MEM_ROM,i);
        }
        break;

      case 4:
      case 5:
        if (get_address_range(&start_address, &stop_address,
                                          cur_syn==4 ? 3 : 2)) {
          for (i=start_address; i<=stop_address; i++)
            MemSetAttr(MEM_NOTEXIST,i);
        }
        break;

      case 6:
      case 7:
        if (get_address_range(&start_address, &stop_address, 2)) {
          for (i=start_address; i<=stop_address; i++)
            MemClearAttr(MEM_NOTEXIST,i);
        }
        break;
    }
    return (ERROR);
  }

/*-----------------------------------------------*/

int sim_nmi()
  {
    PrntMessage(DISP_ERROR,"nmi command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int ports()
  {
    PrntMessage(DISP_ERROR,"ports command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int quit()
  {
    char *response;
    int  ret_value=YES;
    static struct syntax_def syntax[]={
    {{"QUIT",NULL}, 0},
    {{NULL},       -1}
    };

    if (check_syntax(parts, n_parts, syntax)==0) {
      response = PrntMessage(DISP_WARNING,"Are you sure? [y]/n");
      if (strlen(response)==1  &&  response[0]=='N') ret_value = NO;
    }
    else ret_value = NO;
    return (ret_value);
  }

/*-----------------------------------------------*/

int regis()
  {
    int ret_code=NO_ERROR;
    int i;
    static struct syntax_def syntax[]={
      {{"REGISTER",NULL}, 0},
      {{NULL},           -1}
      };
    static char *message[]={
      "                     REGISTRATION INFORMATION",
      "",
      "To get the most out of Z80SIM, you should obtain a registered copy of",
      "the program. Registration provides the following benifits:",
      "",
      "     1) Newest version of the program.",
      "     2) Full documentation. This includes:",
      "        a) Introductory and advanced tutorial.",
      "        b) Complete reference manual.",
      "        c) Expanded on-line help file.",
      "        d) Technical documentation.",
      "     3) Complete source code (in ANSI C). This features:",
      "        a) Well modularized, well documented code.",
      "        b) High portability.",
      "        c) Right to make modifications for personal use.",
      "     4) Notification of updates.",
      "     5) Five dollar commision for all registrations spawned by your",
      "        copy.",
      "",
      "[INCLUDE DISCLAIMER!!]",
      "",
      "To register send $50.00 to:",
      "",
      "        Peter Chapin",
      "        P.O. Box 317",
      "        Randolph Center, VT 05061",
      "",
      "Please be sure to include the  registration number of the  copy you",
      "are now reviewing. This allows the registered owner of this copy to",
      "receive his/her commision.",
      NULL
      };

    if (check_syntax(parts, n_parts, syntax) == 0) {
      StartPrnt();
      for (i=0; message[i] != NULL; i++) Prnt(message[i]);
      StopPrnt();
    }
    else ret_code = ERROR;
    return (ret_code);
  }

/*-----------------------------------------------*/

int reset()
  {
    PrntMessage(DISP_ERROR,"reset command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int save()
  {
    PrntMessage(DISP_ERROR,"save command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int set()
  {
    PrntMessage(DISP_ERROR,"set command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int ss()
  {
    PrntMessage(DISP_ERROR,"ss command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int trap()
  {
    PrntMessage(DISP_ERROR,"trap command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int trapt()
  {
    PrntMessage(DISP_ERROR,"trapt command not implemented");
    return (ERROR);
  }

/*-----------------------------------------------*/

int viewm()
  {
    int     ret_code=NO_ERROR;
    address new_start_address;
    static  struct syntax_def syntax[]={
      {{"VIEWM","?ADDRESS",NULL}, 0},
      {{NULL},                   -1}
    };

    if (check_syntax(parts, n_parts, syntax)==0) {
      if (get_address(parts[1],&new_start_address))
        SetMemStart(new_start_address);
      else
        ret_code = ERROR;
    }
    else ret_code = ERROR;
    return (ret_code);
  }

/*-----------------------------------------------*/

int viewp()
  {
    PrntMessage(DISP_ERROR,"viewp command not implemented");
    return (ERROR);
  }
