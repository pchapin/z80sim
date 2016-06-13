/****************************************************************************
FILE          : synchk.c
LAST REVISION : 2003-10-12
SUBJECT       : Simple minded syntax checking.
PROGRAMMER    : (C) Copyright 2003 by Peter C. Chapin

This file contains a function which compares strings stored in an array of
char * to a given "syntax definition". The encoding of the syntax is simple
minded, but easy enough to set up.

Please send comments or bug reports to

     Peter C. Chapin
     Vermont Technical College
     Randolph Center, VT 05061
     pchapin@ecet.vtc.edu
****************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "z80sim.hpp"
#include "synchk.hpp"

/*=================================*/
/*           Global Data           */
/*=================================*/

static int    best_match_length;
static char **syn_parts;
static int    n_parts;
static char   buffer[80+1];

/*-------------------------------------------------------------------*/
/* The following  structure is used to  hold information  about each */
/* defined syntax. If a syntax is not valid, it is used to determine */
/* which error message should be issued.                             */
/*-------------------------------------------------------------------*/

struct syntax_def_info {
  struct syntax_def *syntax;  /* Points to the syntax in question.      */
  char   **stop_key;          /* Points to element in keywords.         */
  int    mismatch;            /* = YES if mismatched keywords.          */
  int    terminated;          /* = YES if command line over ran syntax. */
  int    match_length;        /* Number of keywords matched.            */
};

/*----------------------------------------------------------*/
/* The following function must be provided by the consumer. */
/*----------------------------------------------------------*/

extern void syntax_error(int level, char *);

/*------------------------------------------*/
/* Function prototypes for local functions. */
/*------------------------------------------*/

void advance_key_ptrs(
         int,
  struct syntax_def_info *,
  struct syntax_def_info **,
         int *);

void check_best(
  struct syntax_def_info *,
  struct syntax_def_info **,
         int *);

/*==========================================*/
/*           Function Definitions           */
/*==========================================*/

int check_syntax(char **tokens, int n_tokens, struct syntax_def *this_syntax)
  {
    struct syntax_def       *good_syntax=NULL;   /* !=NULL if good found.  */
    struct syntax_def_info  *best_syn_info=NULL; /* Points at best guess.  */
    struct syntax_def_info  results[MAX_NMBR_SYNS]; /* One per syntax.     */
    int n_syns=0;           /* Number of syntax definitions found.         */
    int abort=NO;           /* =YES if too many syntax defs found.         */
    int unique=YES;         /* "Best guess" syntax is unique.              */
    int n_good=0;           /* Number of "good" syntaxes found.            */
    int i,j;                /* Generic loop indicies.                      */
    int ret_code=-1;        /* Returns id_code of good syntax if possible. */

    syn_parts = tokens;
    n_parts = n_tokens;

    /*----------------------------------------------------------*/
    /* Sweep through all the syntax defs to initialize results. */
    /*----------------------------------------------------------*/
    while (this_syntax->id_code != -1  &&  !abort) {
      if (n_syns < MAX_NMBR_SYNS) {
        results[n_syns].syntax       = this_syntax;
        results[n_syns].stop_key     = this_syntax->keywords;
        results[n_syns].mismatch     = NO;
        results[n_syns].terminated   = NO;
        results[n_syns].match_length = 0;
        n_syns++;
      }
      else abort = YES;
      this_syntax++;
    }

    /*--------------------------------------------------------------------*/
    /* If abort == YES, there were more syntax defs than we could handle. */
    /* If n_syns = 0, there were no syntax defs. Both cases are fatal.    */
    /*--------------------------------------------------------------------*/
    if (abort || n_syns==0) {
      syntax_error(1,
        "Invalid number of syntax definitions passed to check_syntax");
    }
    else {

      /*------------------------------------------------------------------*/
      /* Sweep down com line matching up command words with the keywords. */
      /*------------------------------------------------------------------*/
      best_match_length = 0;
      for (j=0; j<n_parts; j++) {
        for (i=0; i<n_syns; i++) {
          advance_key_ptrs(j, &results[i], &best_syn_info, &unique);
        }
      }

      /*----------------------------------------*/
      /* Analyize results for error conditions. */
      /*----------------------------------------*/
      for (i=0; i<n_syns; i++) {
        if (!results[i].mismatch    &&
            !results[i].terminated  &&
            *results[i].stop_key == NULL) {
          good_syntax = results[i].syntax;
          n_good++;
        }
      }
      if (n_good > 1) {
        syntax_error(1,
          "More than one command syntax matches command line");
      }
      else if (n_good == 1) {
        ret_code = good_syntax->id_code;
      }
      else if (best_syn_info->terminated) {
        sprintf(buffer,
          "Extra arguments: %s...",syn_parts[best_syn_info->match_length]);
        syntax_error(0, buffer);
      }
      else if (!best_syn_info->mismatch) {
        if (unique  &&  **best_syn_info->stop_key != '?') {
          sprintf(buffer,
            "Command too short. Expecting: %s", *best_syn_info->stop_key);
          syntax_error(0, buffer);
        }
        else if (unique  &&  **best_syn_info->stop_key == '?') {
          sprintf(buffer,
            "Command too short. Expecting: %s", &((*best_syn_info->stop_key)[1]));
          syntax_error(0, buffer);
        }
        else if (!unique)
          syntax_error(0, "Command too short. Extra information required");
      }
      else {
        if (unique) {
          sprintf(buffer,
            "Command garbled. Was expecting '%s' but saw '%s'",
            *best_syn_info->stop_key, syn_parts[best_syn_info->match_length]);
          syntax_error(0, buffer);
        }
        else {
          sprintf(buffer,
            "Command garbled. What is '%s' ?",
            syn_parts[best_syn_info->match_length]);
          syntax_error(0, buffer);
        }
      }
    }
    return ret_code;
  }

/*------------------------------------------------------------------------*/
/* The following function advances the keyword pointer for one of the     */
/* syntaxes. This function is also responsible for updating all the       */
/* syntax_def_info fields. The function's parameters are:                 */
/*                                                                        */
/* com_index:                                                             */
/*     The index into the command line (syn_parts[]) to be used.          */
/*     Advance_key_ptrs uses this info to find the word on the command    */
/*     line to compare with the syntax_def's current keyword.             */
/*                                                                        */
/* syn_info:                                                              */
/*     Pointer to a syntax_def_info structure. This is where information  */
/*     about the current syntax is found. The syntax definition itself    */
/*     is pointed to by syn_info->syntax.                                 */
/*                                                                        */
/* best_syn_info:                                                         */
/*     Pointer to a spot to stick the pointer to the best syntax_def_info */
/*     structure found so far.                                            */
/*                                                                        */
/* unique:                                                                */
/*     Pointer to a place to put the unique flag. This flag is NO if      */
/*     the current syntax is as good as the best. This flag is YES if     */
/*     the current syntax is better than the best.                        */
/*------------------------------------------------------------------------*/

static
void advance_key_ptrs(
  int    com_indx,
  struct syntax_def_info *syn_info,
  struct syntax_def_info **best_syn_info,
  int    *unique)
  {
    /*------------------------------------------------------------*/
    /* Skip this syntax if it's already terminated or mismatched. */
    /*------------------------------------------------------------*/
    if (!syn_info->terminated  &&  !syn_info->mismatch) {

      /*------------------------------------------------------*/
      /* If there are no more keywords left in this syntax... */
      /*------------------------------------------------------*/
      if (*syn_info->stop_key==NULL) {
        syn_info->terminated=YES;
      }

      /*------------------------------------------------------------*/
      /* Otherwise, if the keyword isn't a '?' and the keyword      */
      /* doesn't agree with the current word on the command line... */
      /*------------------------------------------------------------*/
      else if (**syn_info->stop_key != '?'  &&
               strcmp(*syn_info->stop_key, syn_parts[com_indx]) != 0) {
        syn_info->mismatch = YES;
      }

      /*-----------------------------------------------------*/
      /* Otherwise, the keyword is a '?' or the keyword does */
      /* agree with the current word on the command line...  */
      /*-----------------------------------------------------*/
      else {
        syn_info->stop_key++;
        syn_info->match_length++;
        check_best(syn_info, best_syn_info, unique);
      }
    }
    return;
  }

/*---------------------------------------------------------------------*/
/* The  following  function adjusts the best_syn_info pointer and the  */
/* unique flag  using the  information in  *syn_info.  The parameters  */
/* have the same meaning as for the advance_key_ptrs() function above. */
/*---------------------------------------------------------------------*/

static
void check_best(
  struct syntax_def_info *syn_info,
  struct syntax_def_info **best_syn_info,
  int    *unique)
  {
    if (syn_info->match_length > best_match_length) {
      *best_syn_info = syn_info;
      *unique = YES;
      best_match_length = syn_info->match_length;
    }
    else if (syn_info->match_length == best_match_length) {
      *unique = NO;
    }
    return;
  }
