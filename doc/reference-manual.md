Z80SIM 1.0 Reference Manual
===========================

(C) Copyright 1990 by Peter Chapin


Introduction
============

This reference manual provides a complete description of Z80SIM. All its features, commands, and
messages are discussed. This manual is not intended to be a description of how to use Z80SIM.
Thus, it is assumed the reader already has some familiarity with the features of the program.
The Z80SIM tutorial provides information about how to use Z80SIM.


Getting Help
============

Whenever the main Z80SIM prompt is active, help is available. Typing "?" at the prompt gives a
list of Z80SIM commands with a very brief description of each command's purpose. The list is
longer than one page. At the end of the first page the prompt "-> More? [y]/n" appears. You may,
at that point, strike the return key to accept the default value of yes or enter "n" to return
to command line input.

Additional help is available for each command. Typing the command name followed by a "?"
displays a short help screen for that command. The help screen is an abstraction of the
information in this document. As an example, "load ?" displays information about the load
command. The file Z80SIM.HLP must be in the current directory in order for the more detailed
help information to be available.


Accuracy of the Simulation
==========================

Z80SIM provides an accurate simulation of the Zilog Z80 from the software perspective.

Z80SIM simulates all the registers including the alternate registers. The program provides an R
register so that the effect of the LD R,A and LD A,R instructions can be observed. Once the R
register is loaded, its value does is not changed by Z80SIM. The use of the R register in
connection with refreshing memory is outside the scope of the simulation.

All the flags are simulated, including the H and N flags. Z80SIM will set a flag to zero if its
documented behavior is "unpredictable." Z80SIM handles the two "don't care" flags similarly. The
program initializes them to zero and does not directly change them. You may change them with a
command such as "set F=FF" or by using a POP AF instruction. Z80SIM will not change them after
you do. Be aware that the real Z80 may change these bits in unpredictable ways.

All instructions are simulated except "undocumented" instructions. If an op-code is encountered
which does not correspond to an instruction documented by Zilog, Z80SIM will trap (i.e., stop).

Z80SIM simulates on an instruction by instruction basis. It is impossible for you to stop the
simulation in the middle of an instruction. When Z80SIM displays information or accepts
commands, it will do so without any partially executed instructions pending. The repeating block
instructions may stop, however, before they have completed all iterations. This does not violate
the above principle, since the repeating block instructions are actually just simple
re-executions of the same non repeating instruction.

Z80SIM correctly simulates some of the more obscure behaviors of the Z80. The list below shows
these behaviors.

1. The interrupt enable flip flops are handled correctly by the reset and nmi commands and the
   RETN instruction.

2. When an EI instruction is simulated with an interrupt pending, the interrupt is taken after
   the instruction after the EI instruction.

3. When the simulated Z80 is in the HALT state, interrupts will be accepted. When the ISR is
   finished, the simulated Z80 returns to the instruction just after the HALT instruction and
   continues execution.


Input Protocol
==============

For the most part, input is typed at Z80SIM's main prompt: "->". However, some messages will
require you to acknowledge the message with input typed at the message prompt (">") appearing on
the message line. Commands typed at the main prompt consist of a command with, perhaps,
arguments. Spaces are used in most cases to delimit the arguments from the command and from each
other.

Many messages have a default response that can be taken by simply striking the return key. In
cases like this, the default response is shown inside square brackets. For example: "[y]/n"
means that "y" (yes) is the default response. Any other response is taken as "n". All input to
Z80SIM is case insensitive. In other words "yes", "YES", and "Yes" are all treated the same way.
Also, all input to Z80SIM must be terminated with the return key---including one letter
responses.

All numeric values are in hex; no special characters are needed to indicate hex. In other words,
20 should not be typed as 20H or $20. Numbers which are treated as addresses cannot include a
negative sign. However, numbers which are treated as data may. Thus a command such as "set b =
-1F" is legal while a command such as "dump -1000" is not. Negative quantities are changed to
their two's complement form by Z80SIM. For example, after "set b = -1F" register B would be
displayed as E1.


Attributes of Memory, Ports, and Registers
==========================================

Z80SIM simulates the full memory space, port space and register set of the Z80. In addition,
Z80SIM allows memory, ports, and registers to have "attributes". These attributes can be
declared with the appropriate commands (mem, ports) and are used to guard against unusual
actions. The attributes of memory, ports and registers will each be discussed separately.

Memory attributes are controlled by three bits:

1. Exists/Not-Exists bit.
2. RAM/ROM bit.
3. Initialized/Uninitialized bit.

During a simulation Z80SIM will trap if memory is used illegally. A full description of all the
trap conditions can be found in the section "Trap Conditions".

In its start-up state, Z80SIM takes all memory to exist, be RAM, and be uninitialized. If your
system does not support the full 64K address space, you should declare sections of memory to not
exist using the mem command. Similarly, you should declare any ROM addresses as such so that
Z80SIM can catch suspicious activity on the part of your programs.

The mem command gives you control over the first two attributes. In fact, the mem command is the
only way those attributes can change. The Initialized/Uninitialized attribute, however is
automatically set to the initialized state by Z80SIM during a simulation when data is loaded
into memory. That attribute is also set when a program is loaded into memory via the load
command or when memory is changed by you via the set command. Thus, there should be no need for
you to exercise direct control over that attribute.

Keep in mind that the attributes are independently maintained by Z80SIM. Thus if you declare
some memory to not exist, then declare it to be ROM, and finally declare it to exist again, it
will return to this world as ROM. Also, values kept in memory are retained when any attributes
change.

The port attributes are:

1. Input bit.
2. Output bit.
3. Constant value.

The first two attributes define wether the port is an input or an output port. Since some ports
can be both input and output during the lifetime of a program, both input and output attributes
can be set. The constant value attribute only applies if the port is (at least) an input port.
If the port "contains a constant value", Z80SIM will use that value whenever the port is read.
The ports command allows the port attributes to be changed.

When Z80SIM starts, all ports are undefined (ie not input or output), and none contain constant
values. Note that, as with memory attributes, the three port attributes are, in concept,
independent. For example, if an constant input port is redeclared to be an output port, the
constant value is not forgotten. If the new output port is then declared to be an input port
again, that constant value attribute becomes active again as well.

The value of using port attributes are the same as with memory attributes: Z80SIM will trap if a
port is used improperly.

The registers have only one attribute bit associated with them: Initialized/Uninitialized.
Z80SIM will trap if an uninitialized register is used. As with memory, this attribute cannot be
directly controlled by you. However, Z80SIM will set this attribute to the initialized state
whenever data is loaded into a register or if you use the set command to initialize a register.
When Z80SIM starts, all registers are uninitialized.


Sim-State Files
===============

Z80SIM supports the notion of "sim-state files". A sim-state file is a file which contains a
complete description of a Z80SIM state. When a sim-state file is loaded (using the get command)
Z80SIM is returned to exactly the same state it was in when that sim-state file was saved (using
the save command). This allows you to configure Z80SIM and save the configuration in a file to
be later retrieved when needed. Also, you can stop your work and save it for later continuation.

The following data is saved in a sim-state file:

1. All memory contents and attributes.
2. All port contents and attributes.
3. All register contents and attributes.
4. All breakpoints and breakpoint active flags.
5. User defined trap condition.
6. Clock frequency and trapt time (if defined).

When you retrieve a sim-state file, you should be able to continue exactly where you left off
when that sim-state file was saved.


Display
=======

Below is a typical Z80SIM screen. This section describes the information shown on the display.

         Registers                Stack            Memory          Ports
    
    Main         Prime            FFF8 --          FFFA --         00 --
    AF = 0000    AF = ????        FFF9 --          FFFB --         01 --
    BC = 000D    BC = ????        FFFA --          FFFC --         02 2F I
    DE = 00??    DE = ????        FFFB --          FFFD --         03 ?? I/O
    HL = 0002    HL = ????        FFFC --          FFFE --         04 --
                                  FFFD --          FFFF --         05 --
          IX = 0000               FFFE --     IX-> 0000 00         06 --
          IY = ????               FFFF --          0001 00         07 ?? O
          SP = 0000          SP-> 0000 00     HL-> 0002 00 R       08 23 O
          PC = 0008               0001 00          0003 00 R       09 --
                             HL-> 0002 00 R        0004 ?? R       0A --
    I = 00       IFF1 = 0         0003 00 R        0005 ?? R       0B --
    R = 00       IFF2 = 0         0004 ?? R        0006 ?? R       0C --
                 Disabled         0005 ?? R        0007 ?? R   C-> 0D ?? I
    SZ H PNC                      0006 ?? R   PC-> 0008 CD         0E --
    00x0x000                      0007 ?? R        0009 00         0F --
    
    0008 CD0021     CALL     2100         ;....
    000B C20018     JP       1800         ;....
    
    -> command.
    message line

The display is divided into six major sections: Register, Stack, Memory, Port, Disassembly, and
Interaction. These sections may be separated from each other with "box drawing" characters on
your display (depending on what type of computer you are using).

The Register section displays the current values of the simulated Z80's registers. If a register
is uninitialized, it is shown with the value of "??". The flag register is also shown broken
down with the two don't care bits marked as "x". Note Z80SIM takes those bits to be zero unless
you explicitly change them. The P/V flag is shown as "P" or "V" depending on the last
instruction. If the last instruction treated the P/V flag as a parity flag, it will be shown as
"P" (also the default). Finally, both interrupt enable flip flops are shown (IFF1 and IFF2)
along with the current interrupt status.

The Stack section shows a portion of memory around the top of the stack. As the stack pointer
changes, the section of memory displayed adjusts so that the SP always refers to the middle of
the section. Memory which has been declared to "not exist" is shown with the value "--". Memory
which has been declared to be "uninitialized" is shown with the value "??". Finally memory which
has been declared to be ROM is shown with an "R".

The Memory section shows another region of memory. The starting address of the region shown can
be set by you using the viewm command. The initial starting address is 0000. Memory attributes
are shown the same way as with the Stack section.

For convenience, the registers HL, IX, IY, SP, and PC are also shown in the Stack and Memory
sections when they point into the displayed region of memory. If two (or more) of the register
pairs point to the same location, the highest precedence pair will be shown. The precedence
order is somewhat different for the two sections:

             Stack Section     Memory Section
    Highest  SP                PC
             HL                HL
             IX                IX
             IY                IY
    Lowest   PC                SP

The Ports section displays a section of the port space. The starting port address can be changed
by you using the viewp command. The initial starting address is 00.

Port attributes are also shown. Ports that are not defined are shown with the value "--". Ports
that are declared to be input ports are shown with an "I" while ports that are declared to be
output ports are shown with an "O". Ports which are both input and output are shown with an
"I/O".

The significance of the values shown in the ports depend on what type of port it is. For ports
marked as output ports a value of "??" means that the port has not yet been written. Otherwise
the port shows the last byte written. For ports marked as input ports a value of "??" means that
Z80SIM will trap whenever that port is read to ask you for input. Otherwise the port shows the
value taken by Z80SIM whenever the port is read (constant value). Ports which are marked as I/O
follow the same rules as output ports. If such ports have been declared to provide a constant
input value, that value cannot be seen on the display.

Register C can be used to hold port addresses for some of the Z80 instructions. Thus when
register C points into the displayed section of the port space, it is shown in a manner similar
to that used in the Stack and Memory sections.

The Disassembly section shows the next two instructions currently pointed at by the PC. The
format is exactly the same as that used by the disasm command. See the description of the disasm
command for more details.

Finally, the Interaction section is where you interact with Z80SIM. All commands are typed at
the prompt. Z80SIM will respond with messages on the message line when appropriate.

The screen is updated after every command. Some commands will cause the screen to clear. When
those commands complete, the screen is, of course, redrawn. When a simulation is started (except
for a single step), the screen is cleared and the message

"Simulating... Strike any key to interrupt..."

appears on the screen. When a trap condition occurs (the only way to exit a simulation), the
screen is updated just before the trap message is displayed. This is necessary so that you can
see what caused the trap.


Error Message Protocol
======================

All messages produced by Z80SIM are in one of five forms:

    "INFO:    Short information that doesn't warrant a full screen."
    "TRAP:    Description of what caused the simulation to stop."
    "WARNING: Minor error condition."
    "ERROR:   Major error condition. The command must abort."
    "INTERNAL ERROR: Internal data."

All of these messages appear on the message line at the bottom of the screen and all of them
require that you acknowledge the message. For some of the messages "acknowledgment" is merely
striking the return key. Other messages will require you to input a response. In most cases,
default values for the response will be shown inside square brackets. Such values can be
accepted by merely striking the return key.

The trap messages will only occur during an actual simulation. When the simulation stops---for
any reason---a trap message is issued to inform you of that reason. Most trap messages give you
the option of continuing with the simulation. Thus, the screen is updated just before the Trap
message is issued to reflect the current status of the simulated Z80 so that you may make an
informed decision.

The INTERNAL ERROR message should never be seen. If it is, then Z80SIM has detected a bug in
itself. The information printed on the message line gives details about where the bug is located
in the source code.

PLEASE REPORT ANY INTERNAL ERRORS TO ME!! See the section "Reporting Bugs" for more information.
{Don't forget to write the "Reporting Bugs" section!}

When an internal error is acknowledged, the program exits to the operating system with an return
code of 100.

Generally, error messages cause Z80SIM to abort the current command and re-issue the prompt.
Warning messages usually allow the current command to continue after acknowledgment.

General error and warning messages are described in the section "Generic Errors" below. Error
and warning messages that are specific to certain commands are described in the section on that
command. trap messages are described in the section on trap conditions below.


Generic Errors
==============

Each of the following error messages are fairly general and might be seen for a variety of
commands.

    "ERROR: Extra arguments: ARG..."

You've entered more parameters on the command line than are relevant. The offending arguments
are shown. This is an error (and not a warning) because it is assumed that you don't know how to
use the command in question and thus would like to find out before really issuing it.

    "ERROR: Command too short. Expecting: THIS"

The command expected more parameters than you provided. Z80SIM tells you what it thinks you
should have typed next. In some cases, this will be a keyword or symbol. In other cases, it will
be a description of the value you should have typed. For example, you might see "ERROR: Command
too short. Expecting: 8 BIT DATA"

    "ERROR: Command too short. Extra information required"

The command required more arguments but Z80SIM was not able to give you any indication of what
it was expecting. This occurs if there was more than one appropriate continuation.

    "ERROR: Command garbled: Was expecting 'THIS' but saw 'THAT'"

If Z80SIM cannot interpret what you've typed, you may see this message. Z80SIM displays (as
THAT) the word it doesn't understand. It displays (as THIS) the word it was expecting. Some of
the commands require the use of "noise" words such as "to" and "at". If you leave these words
out (or put them in when Z80SIM isn't expecting it), you may see this error.

    "ERROR: Command garbled: What is 'THAT' ?"

A variation of the earlier message, Z80SIM displays this message when it cannot produce the more
specific message above.

    "ERROR: Address out of range: ADDRESS"

You gave the command an address outside the range 0000 to FFFF. Z80SIM shows you what it thought
you typed.

    "ERROR: Address range is invalid: Second address is smaller."

Several Z80SIM commands allow you to specify an address range. The second address in the range
must be equal to or larger than the first. In other words a range such as 1000,0800 would be
invalid. Note that a range such as 1000,1000 would be valid. Also, the message may occur if an
invalid port address range was specified.

    "ERROR: Bad Address: ADDRESS"

This occurs if an address contains illegal characters. Z80SIM shows you what it thought you
typed.

    "ERROR: Eight bit data out of range: DATA"

You gave the command eight bit data outside the range -7F to FF. Z80SIM shows you what it
thought you typed.

    "ERROR: Sixteen bit data out of range: DATA"

You gave the command sixteen bit data outside the range -7FFF to FFFF. Z80SIM shows you what it
thought you typed.

    "ERROR: Bad data: DATA"

This occurs if the data contains illegal characters. Z80SIM shows you what it thought you typed.


Trap Conditions
===============

A simulation (initiated by the go, ss, int, or nmi commands) is interrupted if a "trap"
condition is met. As soon as a trap condition is met, Z80SIM updates the screen and displays a
message on the message line. Virtually all traps ask you if you wish to proceed with the
simulation. An answer of "n", which is usually the default, returns you to command line input.
If the trap occurred during a full simulation (initiated by the go command), Z80SIM will display
an information line before returning to command line input. The information line includes the
number of T-state simulated and, if a clock frequency has been selected, the simulated time. In
all cases, the instruction which caused the trap condition is completely unexecuted when Z80SIM
displays the trap message.

Some instructions may cause several trap conditions to be true. If that is the case, the highest
precedence trap will occur first. If you ask Z80SIM to proceed, Z80SIM will immediately trap on
the next trap (in cases where it is meaningful to do so). The instruction is simulated only if
you ask all traps to proceed.

Below is a listing of all of the trap conditions. The list is ordered with the highest
precedence traps at the top. Thus you can think of the top conditions as being checked first.

    "TRAP: User interruption detected. Proceed? y/[n]"

A simulation can be stopped by striking any key on the keyboard. If you instruct Z80SIM to
proceed, it continues normally.

    "TRAP: Breakpoint encountered. Proceed? y/[n]"

This trap occurs if the instruction which is about to be executed has a breakpoint on its first
byte. If you ask Z80SIM to proceed, it will continue normally. If ask Z80SIM to stop, the
breakpoint will be disabled until the PC changes (or the breakpoint is removed and re-added).
This allows you to issue the go command again without immediately breaking.

    "TRAP: Excessive number of T-states. Proceed? y/[n]"

This trap condition will occur only if it has been enabled with the trapt command. It means that
the instruction just executed has caused the total number of T-states since the start of the
simulation (or the last Excessive T-state trap) to exceed the number specified when the trapt
command was used. If you instruct Z80SIM to proceed, the T-state counter is set to zero. The
excessive T-state trap will occur again when the counter has again exceeded the specified value.
Note that this counter is not reset if a breakpoint is resumed.

    "TRAP: Read from uninitialized register. Proceed? y/[n]"

The instruction currently pointed at by the PC will read a register that has an undefined value
in it. This trap will occur the moment a simulation is started if the PC is undefined.

If you instruct Z80SIM to proceed, a value of 00 (or 0000) is used as the value of the register.

    "TRAP: Read from non-existent memory attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do a memory read or op-code fetch machine
cycle from a location declared to be non-existent. If you instruct Z80SIM to proceed, a value of
FF will be used as the read data.

    "TRAP: Write to non-existent memory attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do a memory write machine cycle to a
location declared to be non-existent. If you instruct Z80SIM to proceed, there will be no effect
on the memory.

    "TRAP: Write to ROM attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do a memory write machine cycle to a
location declared to be ROM. If you instruct Z80SIM to proceed, there will be no effect on the
ROM.

    "TRAP: Read from uninitialized memory attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do a memory read machine cycle from a
location which has undefined data in it. If you instruct Z80SIM to proceed, a value of 00 will
be used as the read data.

    "TRAP: Halt instruction encountered."

The instruction just executed is the HALT instruction. Z80SIM will enter the halt state when
this message is acknowledged. The halt state effectively disables the go and ss commands.
However the interrupt commands (int and nmi) are still active. The halt state persists until the
PC is changed via the set command.

    "TRAP: Read from an undefined port attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do an I/O read machine cycle from a port
that has not been declared. If you instruct Z80SIM to proceed, the value FF will be used as the
read data.

    "TRAP: Write to an undefined port attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do an I/O write machine cycle to a port that
has not been declared. If you instruct Z80SIM to proceed, there will be no effect on the port.

    "TRAP: Read from an output port attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do an I/O read machine cycle from a port
declared to be an output only port. If you instruct Z80SIM to proceed, the value FF will be used
as the read data.

    "TRAP: Write to an input port attempted. Proceed? y/[n]"

The instruction currently pointed at by the PC will do an I/O write machine cycle to a port
declared to be an input only port. If you instruct Z80SIM to proceed, there will be no effect on
the port.

    "TRAP: Read from input port PORT_NO. What value?"

The instruction currently pointed at by the PC will do an I/O read machine cycle from an input
port which has not been given a constant value. The actual message that appears has a port
number in place of PORT_NO above. Your response should be an eight bit hex constant which Z80SIM
will take as the value read from the port. If you enter an empty line, Z80SIM will return to
command line input. If your input is illegal, Z80SIM will display an appropriate error message.
When you acknowledge the error, Z80SIM will return to command line input.

    "TRAP: User defined trap condition encountered. Proceed? y/[n]"

The instruction currently pointed at by the PC will trigger the user defined trap condition. See
the description of the trap command for a full description of the user defined trap condition.
If you instruct Z80SIM to proceed, it continues normally.


Command Descriptions
====================

The following section describes all the Z80SIM commands in alphabetical order. The following
notational conventions are used.

[optional] Material inside square brackets is optional.

op1|op2 The vertical bar implies that you should select either option one or option two.

FILENAME Replace with a file name is relevant for you. Note that Z80SIM will accept a drive
designator and a path wherever it accepts a filename. No special extensions are assumed except
where noted below.

CAPITALS Generally capital letters are used to signify a quantity for which you should
substitute a relevant value. The name of the quantity (ie ADDRESS or CLOCK_FREQUENCY) makes it
clear what is expected.

?
-

The '?' command causes a brief command summary to be displayed. Since more detailed help is
available for each command by simply typing the name of the command followed by a '?', the '?'
command allows you to look up info on commands with which you aren't familiar.


brk
---

    brk at ADDRESS on|off
      or
    brk all off
      or
    brk where

The brk command manages breakpoints. A breakpoint can be set at as many locations as desired;
all 64K locations in the Z80's address space could be breakpoint locations.

If a breakpoint is placed on an instruction, then simulation will stop just before that
instruction begins execution. The breakpoint must be placed on the first byte of the
instruction. If the breakpoint is placed on a later byte, the instruction is simulated
(correctly), but the simulation will not stop.

The first form the of the brk command allows you to set and clear breakpoints. To, for example,
set a breakpoint at address 1234H, you simply enter "brk at 1234 on". The second form of the
instruction allows you to clear all breakpoints easily. Finally, the third form of the
instruction displays a list of all currently active breakpoints.

Simulation stops just before the breakpoint instruction executes. Then, provided you don't
change the PC, you can resume the simulation without breaking on the same instruction right
away.

Possible Messages:

    "WARNING: Breakpoint already set at ADDRESS."

This occurs when you try to set a breakpoint on an address which already contains an active
breakpoint. The breakpoint remains active.

    "WARNING: No breakpoint active at ADDRESS."

This occurs when you try to clear a breakpoint from an address which does not contain an active
breakpoint.

    "WARNING: No breakpoints."

This occurs in response to a "brk all off" or "brk where" command when there are no active
breakpoints.


clear
-----

    clear FLAG_NAME
      or
    clear REG_NAME
      or
    clear ADDRESS[,ADDRESS]

The clear command can be used to clear the value of various objects to zero. The first format
allows you to clear flags (see the set command if you wish to set them to 1). Allowed flag names
are: cflag, zflag, sflag, pflag, vflag, hflag, and nflag. Notice that the P/V flag is treated as
two separate flags. After a "clear pflag" or "clear vflag" command, the display will show the
flag as "P" or "V" accordingly.

The second format of the command allows you to clear a register or register pair. Allowed
register names are: A, F, B, C, D, E, H, L, BC, DE, HL, IX, IY, SP, and PC. To clear the
alternate register set, you must first use the exchange command.

The third format allows you to clear a memory location (or a range of memory locations).

Note that the clear command will cause the cleared object to be marked as initialized.


clock
-----

    clock at CLOCK_FREQUENCY
      or
    clock at

The clock command allows you to register the clock speed of your Z80 with Z80SIM. The current
version of Z80SIM will only use this information when it prints the simulation time when a
simulation terminates. You do not need to specify a clock frequency to use all of Z80SIM's
features.

The first form of the command lets you set the frequency. CLOCK_FREQUENCY must be in MHz. The
second form of the command displays the currently set clock frequency.

Possible Messages:

    "INFO: Clock set to CLOCK_FREQUENCY."

This is the response to "clock at" when a clock frequency has been set.

    "WARNING: No clock frequency has been set."

This is the response to "clock at" when a clock frequency has not been set.

    "WARNING: Unusual clock frequency: CLOCK_FREQUENCY."

This message will be seen if a clock frequency less than 1 MHz or greater than 12 MHz is
specified.

    "ERROR: Illegal clock frequency: CLOCK_FREQUENCY."

This message occurs if there are illegal characters in CLOCK_FREQUENCY or if CLOCK_FREQUENCY is
a poorly formed floating point number.


disasm
------

    disasm ADDRESS|(PC) [to FILENAME]

The disasm command displays a disassembled listing of a section of memory. You may either
specify the address of the beginning of region to be disassembled, or you may use the address
currently stored in the PC for that purpose. The disassembled listing has the following format:

    Addr  Object Code   Operator  Operand  ASCII Equivalent
    0000  CD0021        CALL      0021     ;...

A screen of disassembled code will be displayed followed by the message "--> More? [y]/n". If
you select "y", another screen of code will be displayed.

If the optional file name is specified, the disassembled listing will be written to the file as
well as displayed. The lines "--> More? [y]/n" are not written to the file.

Possible Messages:

    "WARNING: Cannot open the file FILENAME for writing."

This message only occurs, obviously, when the optional file name is specified. It is only a
warning. The disasm command will still show the listing on the screen.

    "ERROR: Illegal register specified: Only PC allowed."

Note that the parentheses are also needed. If you leave them out, the disasm command will assume your
trying to specify an address and it will issue the "Bad address" message.


dump
----

    dump ADDRESS|(REG_PAIR) [to FILENAME]

The dump command displays a substantial segment of memory on the screen. Addresses, contents,
and ASCII equivalents are all shown. If the dump command is used with an ADDRESS, the dumped
memory is centered on the specified address. If a REG_PAIR is named in the command, the dumped
memory is centered on the address currently stored in the register pair. Allowed register pairs
are HL, IX, IY, SP, and PC. After the memory is displayed the prompt "--> More? [y]/n" appears
allowing you to dump the next segment in memory.

Any memory can be dumped including non-existent and uninitialized memory. Uninitialized memory
is shown with the contents as ?? while non-existent memory is shown the contents as "--"

The format of the dump is as shown below.

    Addr Data                                                ASCII form of data
    0000 00 00 00 00 00 00 00 00 - 00 00 00 00 00 00 00 00 : ................

If the optional file name is specified, the dump listing will be written to the file as well as
displayed. The lines "--> More? [y]/n" are not written to the file.

Possible Messages:

    "WARNING: Cannot open the file FILENAME for writing."

This message only occurs, obviously, when the optional file name is specified. It is only a
warning. The dump command will still show the listing on the screen.

    "ERROR: Illegal register specified."

Only HL, IX, IY, SP, and PC can be used with the register form of this command. Note: the parentheses
are needed also; if they are left out, you will get a "Bad address" error.


exchange
--------

    exchange

The exchange command swaps the contents of the alternate or "primed" registers with the main
registers. In short the exchange command has the same effect as the two instructions EXX and EX
AF,AF' have together. The exchange command is intended to be used in connection with the set
command (for example) to set values to the alternate registers. Note: All register attributes
are swapped as well as values.


get
---

    get FILENAME

The get command reads a sim-state file (produced by the save command) into Z80SIM. See the
section on sim-state files for a description of what these files contain. If no extension is
given .SIM is assumed.

Because loading a sim-state file destroys all data previously in Z80SIM, the get command asks
for confirmation with the line "WARNING: Are you sure? [y]/n".

Possible Messages:

    "ERROR: Cannot open the file FILENAME for reading."

The specified file cannot be opened. Perhaps the name was misspelled or perhaps a PATH was
needed.

    "ERROR: Errors reading the sim-state file."

Either the format of the specified file was not compatible with that expected by Z80SIM or there
was a problem reported by the operating system during the file read. If this error message
appears, you should re-initialize Z80SIM. Depending on where the error occurred, the information
stored in Z80SIM may be inconsistent because only a portion of the sim-state file will have been
loaded.


go
--

    go

Go begins a simulation. There are no arguments. Z80SIM will clear the screen and display the
message

    "Simulating... Strike any key to interrupt..."

Under this message Z80SIM will display the number of T-states executed, the simulated time, and
the current PC value. These values will be continuously updated during the simulation.

Once a simulation has started there are only a few conditions that would cause it to stop. All
of these conditions are different types of traps.

1. A HALT instruction is executed (a HALT trap).
2. A key is typed on the keyboard (a user interrupt trap).
3. A breakpoint is encountered (a Breakpoint trap).
4. Any other trap condition is encountered.

If a breakpoint is encountered, the instruction under the breakpoint is left unexecuted.
However, if the go command is reissued without changing the PC or breakpoint, that breakpoint is
skipped.

Possible Messages:

    "ERROR: Z80 is halted."

This message occurs if Z80SIM is in the halt state. Z80SIM will only enter the halt state if it
has executed a HALT instruction. Thus you should only see this message if the PC is pointing
just past a HALT instruction.


init
----

    init

Init initializes the simulator to the same state it had when it was first invoked. Since init
destroys all the data currently in the simulator, you will be asked for confirmation with the
line "WARNING: Are you sure? [y]/n".


int
---

    int RST_INSTRUCTION_NUMBER  (for mode 0)
      or
    int                         (for mode 1)
      or
    int VECTOR_NUMBER           (for mode 2)

The int command allows you to simulate the action of an interrupt. The exact syntax to use
depends on the current interrupt mode of the Z80.

For interrupt mode zero, Z80SIM assumes that a RST instruction is gated onto the data bus during
the interrupt acknowledge machine cycle. You must tell Z80SIM which RST instruction by providing
00, 08, 10, 18, 20, 28, 30, or 38 for RST_INSTRUCTION_NUMBER.

For interrupt mode one, Z80SIM performs an automatic RST 38. No parameters are needed.

For interrupt mode two, Z80SIM requires the appropriate vector number. Z80SIM will ignore the
least significant bit of this number and use it to find the address of the interrupt service
routine (ISR).

Int instruction processing stops when the ISR address is loaded into the PC. No instructions
from the ISR are executed until you issue a go or ss command. Also, during the int instruction,
trap detection is active. If a trap condition occurs, you will be asked if you wish to proceed
as usual. If you elect not to proceed, Z80SIM will return to the same state it had before you
issued the int command.

If interrupts are disabled when you issue the int command, there is no immediate effect.
However, the interrupt is "registered" with Z80SIM so that when interrupts are enabled,
interrupt processing takes place without your intervention. If a simulation is taking place, the
interrupt service routine is then immediately executed. (Note: the interrupt is taken after the
first instruction after the EI instruction, exactly as it is done in the real Z80.)

Possible Messages:

    "ERROR: Illegal RST instruction."

This error occurs if you specify a RST_INSTRUCTION_NUMBER which is not among the allowed eight.

    "WARNING: Interrupt vector number should be even."

Z80SIM will ignore the least significant bit of the interrupt vector number.


load
----

    load FILENAME

The load command reads an Intel format hex file into the simulated memory. The hex file contains
information about starting addresses so no address data need be specified with the load command.
If no extension is given .HEX is assumed.

The data in the hex file can be loaded into memory regardless of the attributes of the memory.
If data is loaded into non-existent memory, that data will be visible as soon as the memory is
declared to exist. Loading data does not change any attributes except the initialize attribute.
Memory that is loaded with data is marked as initialize.

Possible Messages:

    "ERROR: Cannot open the file FILENAME for reading."

The specified file cannot be opened. Perhaps the name was misspelled or perhaps a PATH was
needed.

    "ERROR: Checksum error in HEX file."

The hex file had a checksum error in it. If this error occurs, part of the hex file will have
been loaded. Only the portion of the file around the error and later will be missing.


mem
---

    mem rom|ram at ADDRESS[,ADDRESS]
      or
    mem not at ADDRESS[,ADDRESS]
      or
    mem at ADDRESS[,ADDRESS]

The mem command allows you to declare the attributes of memory. See the section on attributes
for a description of memory attributes.

The mem command allows you to change either the RAM/ROM or the Exists/Not Exists attribute. To
change the Initialized/Not Initialized attribute requires that the set command be used.

All of the syntaxes allow either a single location to be changed or a range of locations.


nmi
---

    nmi

The nmi command causes the simulated Z80 to take a non-maskable interrupt with trap detection
enabled. There are no arguments. If a trap condition occurs during the action of the
non-maskable interrupt, Z80SIM will ask, as usual, if you wish to proceed. If you decide not to
proceed, Z80SIM will return to the same state it had just before you issued the nmi instruction.
Processing of the non-maskable interrupt stops when Z80SIM loads the PC with 0066H. No
instructions from the interrupt service routine are executed unless you subsequently issue a go
or ss command.


ports
-----

    ports in|out|in/out at PORT_ADDRESS[,PORT_ADDRESS]
      or
    ports const VALUE at PORT_ADDRESS[,PORT_ADDRESS]
      or
    ports not at PORT_ADDRESS[,PORT_ADDRESS]

The ports command allows you to declare the attributes of the I/O ports. See the section on
attributes for a description of port attributes.

If a port is declared to be an input port, then whenever Z80SIM tries to read that port a trap
condition is generated. The trap message asks you for the value read from the port. You can
prevent this message from appearing if you've declared the port to be a const port. In that
case, Z80SIM will use the value you gave every time it tries to read from that port. Note that
both input and output ports can be declared const; however, declaring an output port const will
have no effect unless it is later redeclared to be an input port.

Note that all the syntaxes allow you to either specify one port or a range of ports.


quit
----

    quit

This command causes Z80SIM to exit and return to the operating system. Z80SIM always returns a
status value of zero (except when Z80SIM detects an internal error). Because this command can
cause loss of information, Z80SIM asks for confirmation with the line: "WARNING: Are you sure?
[y]/n".


reset
-----

    reset

This command performs the same effect on the simulated Z80 as would be produced in the real chip
by grounding its RESET* pin. In particular it:

1. Disables both interrupt enable flip flops.
2. Sets I = 00.
3. Sets R = 00.
4. Sets the interrupt mode to mode zero.
5. Loads 0000 into the PC.

Notice that this does not reset the state of the simulator. All memory, port, and register
contents and attributes, including breakpoints and user defined traps, will be retained. To
reinitialize the simulator you must use the init command.


save
----

    save FILENAME

The save command saves a sim-state file. See the section on simstate files for a description of
these files. The get command allows you to restore Z80SIM to the saved state. If no extension is
specified, .SIM is assumed.

Possible Messages:

    "ERROR: Cannot open the file FILENAME for writing."

The specified file cannot be opened. Perhaps the disk is write protected or perhaps the
specified PATH is not valid.

    "ERROR: Errors writing file."

The sim-state file could not be completely written to disk. Perhaps the disk filled. Z80SIM
attempts to erase the aborted file.


set
---

    set FLAG_NAME
      or
    set REG_NAME=VALUE
      or
    set ADDRESS[,ADDRESS]=EIGHT_BIT_VALUE

The set command can be used to set the value of various objects. The first format allows you to
set flags (to 1 -- see the clear command if you wish to set them to 0). Allowed flag names are:
cflag, zflag, sflag, pflag, vflag, hflag, and nflag. Notice that the P/V flag is treated as two
separate flags. Note that after the command "set pflag" or "set vflag", the display will show
the flag as either "P" or "V" accordingly.

The second format of the command allows you to assign a value to a register or register pair.
Allowed register names are: A, B, C, D, E, H, L, BC, DE, HL, IX, IY, SP, and PC. To assign
values to the alternate register set, you must first use the exchange command. Note that the
value used will be interpreted as either an eight bit or a 16 bit value depending on the
register name used.

The third format allows you to assign an eight bit value to a memory location (or a range of
memory locations).

Note that the object which is set will be marked as initialized.


ss
--

    ss

This command causes Z80SIM to simulate the instruction currently pointed at by the PC. If the
instruction is simulated successfully, Z80SIM will be in a state which reflects the action of
the instruction. If a trap condition is generated by the simulation, and if you ask Z80SIM to
abort the simulation, Z80SIM will be left in the same state it had before you issued the ss
command.

If Z80SIM has just stopped on a breakpoint and if you have not changed either the breakpoint or
the PC, Z80SIM will not trap on the breakpoint again if you issue the ss command.

Possible Messages:

    "ERROR: Z80 is halted."

This message occurs if Z80SIM is in the halt state. Z80SIM will only enter the halt state if it
has executed a HALT instruction. Thus you should only see this message if the PC is pointing at
a HALT instruction.


trap
----

    trap on read|write from|to ADDRESS|REG_NAME
      or
    trap when ADDRESS|REG_NAME=VALUE
      or
    trap on|off
      or
    trap when

The trap command allows you to define a trap condition. The first time you use the trap command,
you must use one of the first two forms to specify the trap condition. That condition can then
be engaged or disengaged using the "trap on" or "trap off" commands. Note that specifying a
condition also activates that condition.

The first form of the command tells Z80SIM to trap whenever a "sensitive" location is about to
be read (or written). The noise word "from" must be used when a read is specified while "to"
must be used when a write is specified. A port address can be specified by prepending a "p" to
the address. For example, the command "trap on read from p30" would cause a trap to occur on the
instruction "IN 30". If a register name is specified, the following are allowed: A, B, C, D, E,
H, L, BC, DE, HL, IX, IY, SP, and PC. Notice that the alternate registers and the flag register
cannot be specified in the current version of Z80SIM.

The second form of the command tells Z80SIM to monitor a sensitive location and trap when it is
about to become the specified value. Again, port addresses can be specified with a "p" prefix.
Also, the same register names are allowed as with the first form.

The final form causes Z80SIM to display the currently defined trap condition on the message
line.

Possible Messages:

    "INFO: Trap enabled on TRAP_CONDITION."

This message is the response to the "trap when" command when a trap condition has been defined.
TRAP_CONDITION will be a copy of the command enter to set the condition. For example, the
message might read "INFO: Trap on READ FROM P30." The message will say "disabled" if you've
recently issued a "trap off" command.

    "INFO: User defined trap has never been enabled."

This message is the response to the "trap when" command when you have not previously defined a
trap condition or when you've issued a "trap off" command.

    "WARNING: User defined trap is not enabled."

This message occurs if you issue a "trap off" command when the trap was not active.

    "WARNING: User define trap is already enabled."

This message occurs if you issue a "trap on" command when the trap was already active.


trapt
-----

    trapt NUMBER_OF_T-STATES
      or
    trapt on|off
      or
    trapt when

The trapt command enables (or disables) the Excessive T-state trap. The first time trapt is
used, you must specify a NUMBER_OF_T-STATES. During a simulation, the number of simulated
T-states is counted. After the first instruction which causes that number to exceed the number
you specified, the Excessive Tstate trap is taken. The simulated T-state counter is reset after
every Excessive T-state trap, but not after any other kind of trap.

The second form of the command allows you to disable the Excessive T-state trap ("trapt off") or
re-enable it ("trapt on") with the same NUMBER_OF_T-STATES you specified earlier. Note that
disabling, and the re-enabling the Excessive T-state trap resets the T-state counter.

The third form of the command displays the current state of the Excessive T-state trap.

Possible Messages:

    "INFO: Excessive T-state trap enabled at NUMBER_OF_T-STATES."

This message is the response to "trapt when" if you've previously issued a "trapt
NUMBER_OF_T-STATES" command. The message will say "disabled" if you've recently issued a "trapt
off" command.

    "INFO: Excessive T-state trap has never been enabled."

This message is the response to "trapt when" if you have not previously issued a "trapt
NUMBER_OF_T-STATES".

    "WARNING: Excessive T-state trap not enabled."

This message is the response to "trapt off" if the trap is not active.

    "WARNING: Excessive T-state trap is already enabled."

This message is the response to "trapt on" if the trap is active.

    "WARNING: Excessive T-state trap set far into the future."

If you specify more than 249,999 T-states, you will see this message. For a 4 MHz Z80, this
corresponds to a simulated time of one second. Z80SIM will require considerably greater time to
reach this trap condition.

    "ERROR: No T-state count specified."

This is the response to "trapt on" if you have not yet used the "trapt NUMBER_OF_T-STATES" form.

    "ERROR: Invalid number of T-states: NUMBER_OF_T-STATES."

The number of T-states must be greater than zero and less than one billion. You will also see
this message if there are illegal characters in NUMBER_OF_T-STATES.


viewm
-----

    viewm ADDRESS

This command allows you to change the area of memory displayed on the main screen. Initially,
Z80SIM shows you the region starting at 0000H and running to 000FH. The address specified with
this command selects the starting address of the displayed area. Thus "viewm 1000" allows you to
see the region from 1000H to 100FH.


viewp
-----

    viewp PORT_ADDRESS

This command allows you to change range of ports displayed on the main screen. Initially, Z80SIM
shows you the region starting at port 00H and running to port 0FH. The port address specified
with this command selects the starting address of the displayed range of ports. Thus "viewp 10"
allows you to see the ports from 10H to 1FH.
