Z80SIM Technical Documentation
==============================

(C) Copyright 1988 by Peter Chapin

Introduction
============

This document is your guide to the source code of z80sim. Hopefully, you will find this document
useful if you want to modify z80sim. If you're just interested in learning how a program like
z80sim was constructed you may find this document to be educational as well.

z80sim is entirely written in C. In this document I assume that you have had good exposure to
that language. This document is not intended to be a tutorial on programming in C. If you are
not familiar with C, you will need to study the language to get the most out of this document.

z80sim was written to be portable. It was constructed in accordance to the ANSI standard and
should compile correctly on any ANSI conforming compiler (and many near ANSI conforming
compilers). Details on portability aspects are described in the section "Portability" below.

This document begins by discussing topics that apply to z80sim as a whole. It is then broken
down into sections with one section for each source module. The information on each module
consists of a description of the module's overall function and purpose, descriptions of all the
module's public symbols, descriptions of all the module's private symbols, and finally
descriptions of test cases for each module.


Copyrights and All That
=======================

z80sim is a copyrighted program. I grant you, as a registered user, permission to modify z80sim
in any way you see fit. However, you must not distribute your modified version. On the other
hand, you may distribute the copy of the executable program which you received with your
registration. In fact, I encourage you to do so.

I have released portions of the z80sim source code into the public domain and thus you may
distribute and use those portions any way you want. They are the portions which have general
applicability; the portions which are not in the public domain are those that are specific to
z80sim anyway. My intention here is to encourage a lively (and legal) programming community. If
you (or your friends) write better programs because of my routines, maybe you'll buy my products
again.

I, naturally, don't want to encourage you to come into direct competition with me. Consequently,
the z80sim specific routines are not in the public domain. Thus you cannot use them to write a
Z80 simulator of your own for sale. If you have an idea for improvements to z80sim, let me make
it worth your while to work with me rather than against me. Feel free to contact me if you think
of improvements.


Design Philosophy
=================

z80sim is written as a set of "modules". Each module consists of a .c file and a .h file. The .c
file contains the implementation of all the "public" functions in the module as well as any
functions "private" to the module. The .c file also contains declarations of global variables,
symbolic constants, and macros private to the module. That is, global variables, etc that are
used by the functions in the module but that are not visable to other modules.

The .h file contains the declarations of the public symbols from the module. This includes
function prototypes of the public functions, extern declarations of public global variables, and
#defines for public symbolic constants and macros.

If a module needs to use the resources from another module, it must #include the .h file for
that other module.

The guiding principle for this organization is that of "data hiding". In a well written program
the modules should all present a small, simple interface to external modules. Each module should
hide as much as possible from the other modules. This allows the details of each module to
change -- perhaps radically -- without the other modules being effected.

In addition to being highly modularized, z80sim was written with the assumption that bugs would
be present in the draft versions. z80sim contains numerous calls to a debugging system with a
fairly simple interface. Although the debugging system I used is not provided (it's a fairly
substaintial program in its own right and may be released as a future product), you could write
your own and take advantage of all the debug calls already built into the code. This could be
important if you plan to make significant modifications to the program. More information on the
debugging system interface is in the section "Debug Calls" below.

Congruent with the assumption that bugs will exist in the draft versions, this documentation
contains a full description of all test cases used during the testing of the z80sim modules.
Again, this information can be useful to you if you change the program. By repeating my tests
you can verify that your changed version works at least as well as the original.

z80sim.h and mydefs.h
---------------------

All modules #include the two header files z80sim.h and mydefs.h. z80sim.h contains the
definitions of a few symbols that are of program-wide use. Also z80sim.h contains the
declarations of public symbols from the module z80sim.c. mydefs.h contain the definitions of
several symbols I find useful personally. These symbols include YES, NO, ERROR, NO_ERROR,
PUBLIC, PRIVATE, and others. So that I may use these symbols freely, it is my habit to #include
mydefs.h into every program I develop.

Because z80sim.h and mydefs.h are #included into every module, these two header files set up a
customized "symbolic environment". Keep this feature in mind if you change either of those
headers.


Debug Calls
-----------

During the development of z80sim I used a debugging system to aid my bug killing activities. I
have not provided the system since I may release it as a seperate product in the future.
However, to assist your efforts at writing your own I will provide in this section a brief
description of the functions you must implement.

First note that the debug calls are only inserted in the executable file if the symbol DEBUG is
defined. The D() macro (#defined in mydefs.h) expands only when DEBUG is defined. Consequently
you don't need to provide functions to catch my debug calls to compile z80sim successfully.

The debugging system I used provides a public interface of six functions. Two functions are
simply to set up and terminate the debugging system. Three functions are used by snapshot
functions to dump debug data. The last function is used to mark trace and/or stop points in the
code.

The debug system is initialized with a call to dbg_init(). This call should be the first line in
main(). dbg_init() takes a variable number of parameters. The first is an integer specifying the
number of snapshot functions that are being used. The other parameters come in pairs. The first
member of each pair is a pointer to the snapshot function (of type: void (*)(void)) and the
second member of each pair is the name of the snapshot function (of type: char *).H&0*''@@Each
module has a snapshot function encased between "#ifdef DEBUG...#endif" conditional compliation
directives. I used the snapshot functions to dump private global data in each module whenever I
felt the need.

Just before the program terminates, the function dbg_terminate() must be called so that the
debugging system can clean up.

Most of the calls to the debugging system are made via the dbg() function. dbg() has at least
three parameters. The first is a char * which gives the name of the particular call. The second
is an int giving the detail level of the call. The third is a char * giving a printf-like format
string which is displayed whenever the dbg() call is acknowledged. Other parameters are provided
as specified by the format string.

The debugging system I used displays all its output in windows so that the z80sim display was
not disturbed. As a result, I needed to provide a way for the snapshot functions to display
their output in a window. dbg_start_prnt() informs the system that a snapshot function wants to
print something. The first two parameters are integers specifying the dimensions of the
requested window (rows, cols). The third parameter is a char * specifying a header to be
displayed at the top of the window. dbg_prnt() prints the specified string in the window and
dbg_stop_prnt() cleans up the window.


Initialization Convention
-------------------------

Each module provides a public initializer function and a public "un"-initializer function. When
z80sim starts -- before the title screen is drawn -- it will call all the initializers from each
module. The initializers return NO_ERROR if they initialized without a problem. Otherwise they
return ERROR. If any of the initializers return ERROR, z80sim immediately aborts.

Assuming a given initializer returns NO_ERROR, the corresponding uninitializer is registered
with the exit() function using atexit(). The gaurentees that the correct uninitializers are
called when the program terminates. Note that only the uninitializers for successfully
intialized modules are called.

Some of the modules do not need any special initialization. However they still provide the
initializer function. This is done because of the data hiding idea mentioned above. The main
module (z80sim.c) does not know which modules need initializing and which don't. Consequently,
it assumes that all do. If a module is changed, the initializer function is already in place and
can be elaborated on if necessary.

Note that there are no debug calls in the uninitializer functions. This is because the debug
system terminates before exit() is called. Since the uninitializers are called by exit(),
obviously they cannot use the debugging system.


Overview of the Modules
-----------------------

The descriptions are only meant to give you an overview of the modules. More detailed
descriptions of each module can be found in the following sections.

Some of the modules are "generic" and can be treated in isolation of z80sim. Other modules are
z80sim specific. The documentation for the generic modules can stand alone and be read without
any knowledge of the existance of z80sim. Additionally, the generic modules have been released
by me into the Public Domain as discussed above.


z80sim.c: (Public Domain: Use freely)

This is the main module (ie it contains the function main() ). It is mostly concerned with
accepting and processing commands. In fact, this module is a generic command line processor and
knows nothing about the commands it is handling. There are a number of z80sim specific items in
this module. However the structure of the module is general enough to be easily adapted for
other programs that desire a simple command line interface.

In addition to processing commands, this module also provides an on-line help facility.


commands.c, commands.h: (z80sim specific)

This modules implements all the z80sim commands and support functions. Many of the commands are
completely implemented in this module.


synchk.c, synchk.h: (Public domain)

This module handles the checking of the command line syntax and printing the appropriate error
message.


display.c, display.h: (z80sim specific)

This module contains the functions for drawing the screen, handling error messages, help
messages, etc. All screen I/O is done through this module. As a result, changes to the screen
layout can be reliably made by simply changing the functions here. This module maintains
portability by using screen.c for the low level screen activities.


mem.c, mem.h (z80sim specific)

This module implements the simulated memory. This is a low level module. Although it will call
error handling functions when a defined error condition occurs, it knows nothing about the
nature of the error conditions.


simul.c, simul.h: (z80sim specific)

This module does the actual simulation (and disassembly) of Z80 instructions. It consists of
one function for each class of Z80 instruction. z80sim decides which function to use by
indexing into a table with the current op-code. The table (which is fairly large) is in table.c.


table.c, table.h: (z80sim specific)

This module contains only data. In particular, it contains only a table relating op-codes to
functions which implement the simulation of those op-codes.


lib.c, lib.h: (Public Domain)

This module contains functions from my library which z80sim used. Although, I want to be
generous with registered users, I didn't want to include my entire library with this package.
All functions is this module stand alone.


screen.c, screen.h: (Public Domain)

This module contains the low level screen handling functions. z80sim makes use of this module to
position the cursor and set the screen colors. This module presents a uniform interface for
machine specific activity.


z80sim.c
--------

This module handles the grunt work of starting z80sim and dispatching the commands. Although it
has a number of z80sim specific references in it, this module can easily be adapted for use with
other programs.

This module initializes the program by calling the initializers from each of the other modules.
If any of the initializers fail (ie return ERROR), the program immediately exits (thus calling
the un-initializers from all initialized modules) with a status of 1. If initialization is
successful, the program calls TitleScreen() (in display.c) and enters the command loop.

The command loop draws the display by calling DrawDisplay(). It then accepts a command string,
breaks the command string into its parts, and checks to see if it reconizes the command.
Finally, a switch statement is used to dispatch control to the appropriate command function (in
commands.c). If help has been requested, this module reconizes that fact and calls an internal
function to process the help request instead of calling the command function.

The command loop is broken when the quit() function returns YES.

Public Symbols:

char *parts[]

This array contains pointers to the various parts of the command string. For example if the user
entered "set 1234=fe", parts[] would contain pointers to "SET", "1234", and "FE". Notice that
all characters are converted to uppercase.


int n_parts

This integer gives the number of parts in the command string. For the example above, it would
have the value 3. Note that n_parts is zero only when the user types an empty line (or a line
full of delimiter characters).


Private Symbols:

MAX_CMD_LENH

This symbolic constant defines the maximum number of characters that can be legally entered on
the command line. If more than this number is entered, an error message is the result. This
length does not include space for the \n character or the \0 character.


MAX_NMBR_PARTS

This constant defines the maximum number of "parts" that the command string can have. If more
than this number is entered, an error message is the result.


char *cmds[]

This array contains pointers to all the legal commands. The commands names must be all
uppercase. Otherwise they would never match with user input since the user input is converted to
uppercase immediately. The first entry in this array must point to the string "NONE".
Furthermore no command can be named "NONE". This is due to the way z80sim.c responds to no
input. As a result of this, the user could enter "none" at the prompt and get the same effect as
striking the return key alone.

The last entry in the array must be NULL. z80sim.c uses the NULL entry to terminate its search
of the array.

Along with the cms[] array, symbolic names are defined for all the commands using the enum
declaration. Here enum is used as an easy way to assign consequtive integer values to all the
command name symbols. It is important that names are declared in the enumeration in exactly the
same order that they appear in the array cmds[]. Using an enum here rather than #defines
simplifies the process of adding new commands.


char delim[]

This string (must be \0 terminated!) gives a list of delimiter characters used by z80sim.c to
split the command string into parts. Because of the way SplitString() works, all delimiters are
treated equally and multiple delimiters are skipped. Thus "set 1234=ff" could have been entered
"set=,=1234,= ,ff".


char cmd_line[]

This string contains the command line. The version typed by the user without a \n is converted
to uppercase. SplitString() inserts \0 bytes in cmd_line to split the parts of the string.


int cmd

This integer specifies the index in cmds[] (and the corresponding enum command_name value) of
the current command. If the user types an empty string cmd=0 because *cmds[0] = "NONE". If the
user types an illegal command set_cmd() sets cmd=-1.


int (*init_fncts[])(void)

This array contains pointers to all the initializer functions from the other modules. The last
entry in the array must be NULL. init() uses this information to call all the functions. Because
this information is stored as an initialized array, added more initializer functions is trivial;
init() does not need to be changed.


void (*uninit_fncts[])(void)

This array contains pointers to all the uninitializer functions from the other modules. The last
entry in the array must be NULL. init() registers these pointers with exit() using the atexit()
function. Because of the way init() works, it is extermely important that the uninitializers in
uninit_fncts[] are in positions which correspond with the initializers in init_fncts[]. This
amounts to having the functions placed in the two arrays in the same order. Note: this array
must not contain more than 32 pointers.


HLPFILE

This symbolic constant contains the string form of the help file name. The current version of
z80sim uses only the default name stored here for its help file.


HELP_BUFFER

This symbolic constant contains the size of the the buffer used to hold each line from the help
file. This size does not include space for the \n and the \0 bytes. If a line longer than this
size is encountered in the help file, the search of the help file is aborted prematurly.


SPECIAL_CHAR

Lines in the help file that begin with this character are treated as delimiter lines between
blocks of help information.


int init(void)

This function calls the initializers of all the other modules. It is also responsible for
initializing z80sim.c; however, there are no initialization activities needed for the current
version of z80sim.c If any of the initializers returns ERROR, init() immediately returns ERROR.
Otherwise init() returns NO_ERROR.

Init() also registers uninitializers for each initialized module with the exit() function using
atexit(). Since the ANSI standard gaurentees that only 32 functions can be registered with
exit() in this manner, z80sim is limited to a maximum of 32 modules.


int set_cmd(void)

The set_cmd() function sets cmd to the appropriate value. If parts[0] is a reconized command,
set_cmd() sets cmd to the index of the command in the cmds[] array. If parts[0] is not a
reconized command, set_cmd() sets cmd to -1. If the user typed an empty line (or a line full of
delimiter characters) set_cmd() forces parts[0] to point at "NONE". The current version of
set_cmd() always returns NO_ERROR since it always sets cmd to a meaningful value.


void help(int)

The help() function searchs the help file for information on the specified command. The integer
passed to the help function is the index into cmds[] of the desired command. This index is, of
course, stored in the variable cmd.

The help file must be in the following form:

    !COMMAND1
    help info for command number 1.
    !COMMAND2
    help info for command number 2.
    !COMMAND3
    etc.
    !

The help information can extend over several lines.

The '!' is the SPECIAL_CHAR mentioned above. Following the '!' is a name which must match the
command name in cmds[]. (Note: the order of the command information in the help file does not
have to be the same as that in cmds[].) There must not be a space between the '!' and the
command name and there must not be any extra characters (including white space characters) on
the line after the command name. A lone '!' must appear at the end of the file.

help() first attempts to open the file. If it succeeds, it begins to scan the file line by line.
What help() does with each line depends on wether or not it is already printing help
information. If not, help() checks the line for a leading SPECIAL_CHAR and, if necessary, for
the correct command name. If help() is already printing, it prints the line if it does not start
with SPECIAL_CHAR; otherwise it concludes that it is done printing help information and cleans
up. Note that empty lines in the file are not a problem when it checks for SPECIAL_CHAR since
buffer[0] will be a meaningful character ('\0') in such a case.

help() uses the functions StartPrnt(), Prnt(), and StopPrnt() from display.c to do the actual
printing. These functions handle the problem of clearing and redrawing the screen as well as
pausing the output.

You may notice that the current version of help() is fairly slow since it scans the file
sequentially. Although help() is smart enough to exit as soon as it's done with the request, it
still must scan the entire file if the requested help info is at the end (or nonexistant).
Future versions of z80sim should provide a better help() system.


main()

The action of the main function is farily evident from the comments made so far and in the code.
An if...else if... chain is used to test for successful reading of the command string, splitting
of the command string, and setting cmd. Notice the use of the comma operator to slip two actions
in one if expression. Although this may reduce readiblity somewhat, I decided that the
alternative of opening another set of {} would be worse.

The command loop is implemented as a do...while loop which breaks cleanly when quit() returns
YES. In fact, the ONLY exit point in the program is at the bottom of main(). The structured
programming discpline dictates that every program block have one entry and exit point. This
concept applies to whole programs as much as it does to loops, etc. Although many people don't
seem to be very concerned with this point as it applies to whole programs, I've been burnt by it
before and I am very careful about it now.

Finally note that each of the command functions returns int. However, with the exception of
quit(), none of the returned values are used. Future versions of z80sim are expected to make
more of the command functions returned values.


Test Cases:


commands.c
----------

This module contains one function for each of the z80sim commands. In addition it contains some
"support functions". For example, many commands require addresses or data. This module also
contains the necessary functions to convert strings to addresses with appropriate error
checking.

The syntax of commands are checked using the library module synchk.c. Synchk.c does fairly
complicated analysis of the command line so that it may display the most meaningful error
message possible. As a result, each command defines an array of struct syntax_def which contains
the definitions of the legal syntax variations for that command. See the description of synchk.c
for more information about struct syntax_def.

Public Symbols:


int ComInit(void)

This function initializes the commands module. The current version of commands.c does not
require any initialization so this function just returns at once.


void ComUnInit(void)

This function unitializes the commands module. The current version of commands.c does not
require any uninitializing so this function just returns at once.


int none(void)

The none() function does nothing. It is called whenever the user types an empty line (or a line
full of delimiter characters).


int unknown(void)

The unknown() function is called whenever z80sim.c detects a command it doesn't know. The
current version just prints an appropriate error message.


int quest(void)

The quest() function is called when the user enters '?' on the command line. This function
simply prints a brief summary of all the commands. It uses Prnt(), etc. from display.c to
handling redrawing the screen and pausing the output.


int mem(void)

The mem() function implements the mem command. The function is quite straightforward since there
are no specific messages emmitted by mem(). After checking the command syntax, mem() branches to
the appropriate code to manipulate the requested memory attribute. For more information about
the memory attribute macros, see the section on mem.c.

Notice that the loop index is declared to be long. This is to insure correct operation if a
range extends all the way to FFFF. Without this, the for loops would wrap FFFF to 0000 and their
exit conditions would never be satisfied.


int quit(void)

This function prints the "Are you sure?" message and returns YES if the user is sure and NO if
the user is not sure. z80sim.c uses the returned value from quit to decide if it's time to break
out of the command loop.


int viewm(void)

This function implements the viewm command. It simply calls SetMemStart() from display.c to set
the starting address of the displayed section of memory.


Private Symbols:


int get_address(char *, address *)

This function provides a bullit proof way to convert a string to an address. The conversion
centers around the ANSI standard's strtol() function. Errno and end_ptr are initialized so that
strtol() can record information about a bad conversion (if end_ptr == NULL, strtol() won't mess
with it!). When strtol() returns, various error conditions are checked. If all is well, the
validated address is loaded.

Get_address() returns ERROR if there is a problem with the conversion and NO_ERROR otherwise.


int get_address_range(address *, address *, int)

This function breaks an address range string into a start address and a stop address. The third
parameter is the index into parts[] where the address range is to be found. Since an address
range uses a '-' character (with no space!) between addresses, the range is taken to be one
argument by z80sim.c. Get_address_range() tries to further break down the string.

Get_address_range() knows how to handle a range with only one componet.
It correctly takes it to be a range of one.


Test Cases:


synchk.c
--------

This module checks the command line syntax. It consists of only one significant function:
check_syntax(). However that function is somewhat complicated because it tries to print the most
meaningful error message possible for bad command lines.

The module is general purpose. Check_syntax() can be used in any command line driven program
that uses commands which conform to the syntax definition described below.

Public Symbols:


SYN_NMBR_KEYS

Each syntax definition can contain no more than this number of keywords.


MAX_NMBR_SYNS

Each command can define several legal syntaxes. However, no more than this number of syntaxes
can be defined.


struct syntax_def

This structure contains the definition of a syntax. Each command declares an array of these
structures with one structure for each of the command's legal syntax variations.

The structure contains an array of pointers to keywords and an id code. The keywords must match
the command line. The first keyword must match parts[0] (the name of the command), etc. The last
pointer in the list must be NULL to mark the end of the list.

Any keyword which begins with a '?' is handled as a special case. Such keywords will match
anything on the command line (as long as there is something on the command line). The characters
after the '?' name what is expected and are used by some error messages. Note that all keywords
must be uppercase so that they match the processed command line correctly.

For example, a possible syntax might be:

    {{"MOVE","?SOURCE ADDRESS","TO","?DESTINATION ADDRESS",NULL},0}

The above syntax has id code of zero. The following commands would match the above syntax:

    "move 1234 to abcd"
    "move here to there"

The '?' character allows matches to anything. However, check_syntax() will use the extra
information in certain error messages. For example if the user typed:

    "move 1234 to"

check_syntax() will print the message:

    "ERROR: Command too short. Expecting: DESTINATION ADDRESS"

int check_syntax(sytax_def *this_syntax)

This function accepts a pointer to the beginning of an array of syntax_defs. The last syntax_def
in the array must have an id_code of -1 to mark the end of the array. Check_syntax() returns -1
if there was a syntax error. Otherwise it returns the id_code of the matched syntax.

Check_syntax() is somewhat involved. It maintains an array of struct syntax_def_info. These
structures (described in more detail below) contain information about a given syntax definition.
Check_syntax() first initializes each element in this array by scanning through all the syntax
definitions. Here check_syntax() will display an error if too many definitions are passed to it.

Once the syntax_def_info structures are initialized, check_syntax() loops on each word in the
command line. For each word, it sweeps through all syntax definitions trying to advance a
pointer to the next keyword in the definition. This is done by calling advance_key_ptrs(). If
the current command line word does not match the current syntax definition keyword, or if there
aren't enough keywords in the syntax definition, advance_key_ptrs() updates the appropriate
fields in the syntax_def_info structure. Advance_key_ptrs() also keep track of the best match
found so far.

After all command line componets have been handled, all the syntax_def_info structures are
examined to see how many match. A syntax matches if there has not been any mismatched keywords,
and if the syntax is not yet terminated, and if the next keyword in the syntax is NULL.
Check_syntax() prints an error if there are multiple matches.

If there are no multiple matches check_syntax() uses a if... else... if chain to examine several
mutually exclusive possibilites.

If there is only one match, its id_code is returned. If the best match terminated, there must be
too many things on the command line. If the best match did not involve a mismatch, then the
command line was too short. Otherwise the best match involved a mismatch and so the command line
contains an unreconized entity.


Private Symbols:


int best_match_length

This integer holds the lenght of the best match found so far. It is initialized to zero in the
code of check_syntax(). It is used by check_best() to determin if the current syntax has been
matched deeper than the best.


struct syntax_def_info

This structure contains information about a syntax definition. In particular it contains a
pointer to the syntax definition in question, a pointer the keyword that needs to be matched
next, a flag which is TRUE if the syntax has "terminated", a flag which is TRUE if there has
been a mismatch in the syntax, and an integer to hold the number of keywords matched.


    void advance_key_ptrs(int    com_indx,
                          struct syntax_def_info *syn_info,
                          struct syntax_def_info **best_syn_info,
                          int    *unique)

This function tries to advance a pointer to the next keyword for the given syntax. It updates
the information in syn_info depending on how sucessful it is. This function uses check_best() to
determin if the current syntax is the best so far.


    void check_best(struct syntax_def_info *syn_info,
                    struct syntax_def_info **best_syn_info,
                    int    *unique)

This function compares the current match length with the best match length. If the current is
better than the best, it updates best_syn_info. If the current is the same as the best, it
forces unique to NO. Check_syntax() uses unique to decided which error message is appropriate.


Test Cases:


display.c
---------

This module hides the details of the screen from the rest of the program. It remains portable by
using screen.c to do machine specific actions.


Public Symbols:


void DispInit(void)

This function initializes the display module. In the current version of display.c this function
has no effect.


void DispUninit(void)

This function undoes the effect of DispInit(). In the current version of display.c, this
function has no effect.


void SetMemStart(address)

This function simply copies it argument into the private variable mem_start_address. It is
provided so that mem_start_address does not have to be made public. Although the function call
contains significant overhead for this function, I felt that it would not be a problem since it
is called infrequently. The existance of this function strengthens the data hiding design.


void TitleScreen(void)

This function draws the title screen and waits for the user to strike the return key. The
function makes use of the function DrawBox from my library to draw text boxes on the screen.
Much of the bulk of the function is the static data used to control DrawBox and the opening
text.


char *PrntMessage(int error_level, char *message, ...)

This function prints a message on the message line, printsH&0*''@@the message prompt (">"), and
accepts input from the user. Message points at a printf-like format string to be printed. Note
that PrntMessage accepts a variable number of arguments depending on the requirments of the
format string. It makes extensive use of the ANSI defined macros in the standard header
STDARGS.H.

Errorlevel must have one of the values DISP_INFO, DISP_WARNING, DISP_ERROR, DISP_TRAP, or
DISP_INTERNAL (defined in display.h). PrntMessage prepends "INFO:", "WARNING:", etc to the
message automatically. These message prefixes are defined in a private array (discussed below).
Thus a call such as:

    PrntMessage(DISP_TRAP,"ERROR: Bad value");

will produce the message: "TRAP: ERROR: Bad value".

PrntMessage returns a pointer to the string entered by the user to acknowledge the message
(without the \n). Note that the string returned will contain only uppercase letters. If the user
acknowledged by simply hitting return, PrntMessage returns a pointer to a null byte.

All messages are printed through PrntMessage. Thus, if a fancier output was desired (errors
appearing in a window for example), PrntMessage is the only place that would have to be
modified.

Note that PrntMessage cleans up the message line before returning. This is in keeping with the
"clean up your own mess" philosphoy that I follow.


void DrawDisplay(void)

This function updates the display. It is the main event in the module display.c. DrawDisplay is
"semi-intelligent". It maintains the display as five distinct sections and redraws only those
sections that need to change. DrawDisplay keeps a record of what it thinks is being displayed in
each section. When it is called, it updates that record for all sections and then redraws the
sections that have changed.

DrawDisplay can be controlled somewhat by other functions in display.c by the private global
variable draw_all. If draw_all is set to YES, DrawDisplay will update the entire screen -- even
if it thinks nothing has changed. draw_all is YES when z80sim is loaded so that DrawDisplay
knows to draw everything. The following pseudo-code explains the action of DrawDisplay in more
detail.

    if (draw_all == YES) {
      Clear screen;
      Draw Boxes around sections;
      Draw static headings;
    }
    changed = NO;
    Update local copy of registers. Set changed to YES if necessary;
    if (draw_all == YES  ||  changed == YES) {
      Draw register section;
      changed = NO;
    }
    Update local copy of stack memory. Set changed to YES if necessary;
    if (draw_all == YES  ||  changed == YES) {
      Draw stack section;
      changed = NO;
    }
    Update local copy of memory. Set changed to YES if necessary;
    if (draw_all == YES  ||  changed == YES) {
      Draw memory section;
      changed = NO;
    }
    Update local copy of ports. Set changed to YES if necessary;
    if (draw_all == YES  ||  changed == YES) {
      Draw ports section;
      changed = NO;
    }
    Update local copy of disassembly records. Set changed if necessary;
    if (draw_all == YES  ||  changed == YES) {
      Draw disassembly section;
      changed = NO;
    }
    Erase command line and draw prompt;
    draw_all = NO;

Whenever two sections share a piece of data, they maintain their own copies of that data. For
example, the PC is maintained by the register section, the stack section, the memory section,
and the disassembly section. (The stack and memory need the PC to know if they are supposed to
draw a "PC->" somewhere.) This may seem inefficient. However, the decoupling of sections allows
modifications to be made more easily.

DrawDisplay gets it's information from reg.c, mem.c, and port.c using the unprotected access
functions. Thus trapH&0*''@@conditions are not active when the screen is being drawn. Without
this, you would see trap messages whenever DrawDisplay read non-existant memory, etc. Obviously
this is not what one would want.


void StartPrnt(void)

This function is called whenever another module wants to print information on the full screen.
It erases the screen. It also sets draw_all so that when full screen printing is done,
DrawDisplay knows to update everything.


void Prnt(char *string)

This function is called for each line that another module wants to print on the full screen. The
module that uses Prnt() must not put a \n character at the end of each line (WriteLines does).

Prnt() uses WriteLines() to do the actual work of displaying the string on the screen.
WriteLines worries about pausing the output. However, Prnt needs to watch the private variable
prnt_ignore to see if the user wants to abort the print session (by answering "n" to the prompt
"--> More? [y]/n"). Note that if the user does abort the session, Prnt() has no way to inform
the module that is using Prnt(). Thus Prnt() (and the user) have to wait until that module is
satisfied. In practice, this does not take long.


void StopPrnt(void)

This function is called whenever another module is finished printing on the full screen.
StopPrnt() will inform WriteLines() that the session is over and clear the screen. DrawDisplay
will redraw the normal screen since StartPrnt() set draw_all to YES.


Private Symbols:

MESSAGE_LINE

This is the row number for the message line. The current version of display.c assumes a 25 row
screen. Since MESSAGE_LINE is at 24, the user can type a \n without scrolling the screen
(provided the message + acknowledgment is less than the screen width in length.


char message_prompt[]

This is the prompt which is displayed after a message. It is at this prompt that the user will
enter their reply (acknowledgment) to the message.


char *message_prefix[]

This array contains the prefixes used by PrntMessage(). It is important that the prefixes are in
the same order as the corresponding #defines in display.h. For example, "INFO: " is the zeroth
entry in the array and DISP_INFO is #defined to be 0.


int max_error_level

This integer is the largest index in the array message_prefix[]. PrntMessage() checks its
incoming error_level to insure that it is smaller than this value before accessing
message_prefix[].


REPLY_BUF_SIZE

This symbolic constant defines the size of the buffer reserved for message acknowledgments. This
number does not include space for the \0 byte.


COMMAND_LINE

This is the row number of the command line.


char major_prompt[]

This is the prompt used by DrawDisplay(). It is at this prompt that the user enters commands,
etc.


int draw_all

This variable controls weither or not DrawDisplay completely redraws the entire screen. If
draw_all is YES, DrawDisplay will redraw the boxes which seperate the screen sections as well as
the static headings (which are not redrawn normally).


struct headings

This structure is used to specify static headings. A static heading is one which normally does
not need to be redrawn. These headings are used to label areas on the screen. This structure
contains a name field to specify the heading and both a row and col field to specify the point
where the heading starts.

DrawDisplay defines an array of these structures to control the overall display layout.

int prnt_ignore

The variable is used by Prnt(). If it is YES, Prnt() does not actually print the strings being
passed to it. Normally this variable is NO. It is changed to YES when the user asks to abort a
full screen printing session by replying "n" to the prompt "--> More? [y]/n".


void draw_mem(address start, int srow, int scol, int length)

This function is used by DrawDisplay to handle one column of memory. The memory drawn starts at
address start. The column on the screen begins at row srow and column scol. Length bytes are
drawn.

This function concerns itself with handling the memory attributes correctly. See the description
of mem.c for more information about the Mem macros.

Note that this function assumes there will be no overflow if FFFF is incremented. Most C
compilers do not check for overflow on unsigned types.


void set_color(int errorlevel)

This function is used to by PrntMessage() to set the colors of its messages.


Test Cases:

mem.c
-----

This module implements the simulated memory itself. This module presents an interface that
allows other modules to read and write the simulated memory on a byte by byte basis. Also this
module allows error conditions to be defined based on memory attributes. This module does not,
however, know the significance of the memory attributes that it is manipulating. As a result it
implements a fairly general purpose simulated memory.

Public Symbols:

int MemInit(void)

This function's main task is to allocate 64K bytes for the simulated memory and 64K bytes for
the memory attributes. In addition, the allocated memory is zeroed. If either of the allocations
fail, MemInit() returns ERROR. Otherwise it returns NO_ERROR.

Unfortunately, Turbo C v1.5, which I used to develop z80sim, does not follow the ANSI standard
rigorously with respect to its allocation functions. Strictly calloc() should take a size_t
argument. However, Turbo C's calloc() takes an unsigned argument. This forced me to use a
non-standard function (farcalloc()) to allocate the full 64K bytes. (Turbo C's normal calloc()
could only allocate 64K-1 bytes.)

In addition, the pointer returned by farcalloc() does not, in general, start at the beginning of
a segment. Thus I had to declare Mem and MemAttr to be "huge" pointers. This declaration injects
another non ANSI keyword into the code. Sorry...


void MemUnInit(void)

This function frees the memory allocated by MemInit(). If it can't free the memory correctly it
prints a bail-out error message. The message is a "bail-out" message because it can't be printed
using the usual PrntMessage() function. MemUnInit() is called during the shutdown phase of the
program and so cannot count on PrntMessage() being in service.

As with MemInit(), I was forced to use a non-standard function in the Turbo C library to free
the allocated memory.

MemRead(address)

This macro reads the byte out of simulated memory with no checking active. This macro is safe
for side-effects.


MemWrite(byte, address)

This macro writes the provided byte into simulated memory with no checking active. This macro is
also safe for sideeffects


MemReadAttr(int, address)

This macro evaluates to 'true' if the attribute specified by the first argument for the address
specified by the second argument is set. It evaluates to 'false' otherwise. This macro is not
safe for side-effects. If the attribute number exceeds 7, the results are undefined.


MemSetAttr(int, address)

This macro forces the attribute specified by the first argument for the address specified by the
second argument to be 'true'. This macro is not safe for side-effects. If the attribute number
exceeds 7, the effects are undefined.


MemClearAttr(int, address)

This macro forces the attribute specified by the first argument for the address specified by the
second argument to be 'false'. This macro is not safe for side-effects. If the attribute number
exceeds 7, the effects are undefined.


Private Symbols:


Test Cases:


table.c
-------

This module contains the tables used to drive a simulation and do a disassembly. If the Z80 had
only one byte opcodes, there would be only one table and that table would have 256 entries.
During a simulation or disassembly, z80sim would use the opcode to index into the table to find
out what it needs to know about the instruction. Since the Z80 has a few two byte opcodes there
are actually several tables. The main table handles the first byte (and most of the
instructions) while the other tables handle any additional bytes. The tables are linked together
in a tree structure.

Each table is an array of structures. The structures contain what z80sim "needs to know" about
the corresponding instruction. That structure is defined below.

    struct instruction {
      int    legal;
      int    multi_byte_opcode;
      struct instruction *next_table;
      int    nmbr_of_bytes;
      int    nmbr_of_tstates[2];
      char   *disasm_string;
      int    (*sim_funct)();
      };

The members of this structure are described below.


legal

This member takes on the values YES or NO. It is NO if the structure corresponds to an opcode
that is not a legal Z80 instruction. If legal is NO, all the other members are invalid.


multi_byte_opcode

This member is YES if the opcode is the first of a two byte opcode. Otherwise this member is NO.
If this member is YES, next_table member points to the table that should be used with the second
byte of the opcode. All other members are invalid.


next_table

This member is used in connection with the multi_byte_opcode member and is described above.


nmbr_of_bytes

This member contains the total number of bytes in the instruction.


nmbr_of_tstates

This member contains the number of t-states required to execute the instruction. It is an array
because some instructions require different numbers of t-states depending on the results of the
instruction, notably the relative conditional jumps. The first element of the array is the
t-state requirement if the condition is false.


disasm_string

This member points at a string used during disassembly. The string contains the mnumonic and
special codes which z80sim replaces with relevant values. An example of a disassembly string
might be

    "LD     BC,nn"

z80sim will replace the "nn" with a 16 bit value (the next two bytes of the instruction) when it
does a disassembly. All the codes are shown below:

    n       8 bit value from instruction stream.
    nn      16 bit value from instruction stream.


sim_funct

This points at a function which will handle the simulation of the instruction. These functions
are in the file SIM.c. There aren't as many functions are there are opcodes (although there are
a lot of functions) because some functions will handle several opcodes. The Zilog documentation
was used strictly to decide which functions handle which opcodes and to provide the function
names. For example, the Zilog documentation has a page describing the instructions "LD r,r'".
All of these instructions are handled by the function ldrrp().
