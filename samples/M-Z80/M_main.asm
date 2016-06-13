;===========================================================================
; FILE     : m.asm
; PROGRAMER: Peter Chapin
;
; This program implements a multitasking kernel for a Z80 system. The hardware that goes with
; this kernel is a simple Pro-Log STD bus system. The CPU board supports a Z80 CTC for timing
; and a Z80 DART for communications.
;
; The intent of this kernel is to give the students in CS-202 a "real" multitasking system to
; study. This system, though primitive, shows off a number of important features. I hope that by
; studying the nitty-gritty details of this sytem, the student will gain some sense of what the
; larger systems are like internally even though the architecture of larger systems is going to
; be quite different.
;===========================================================================

;+++++++++++++++++++++++++++++
;          Equates
;+++++++++++++++++++++++++++++

                ; Misc symbols.
K                       EQU     1024
YES                     EQU     1       ; The boolean data type.
NO                      EQU     0       ;   ...

                ; The following equates define the memory map.
RAM_START               EQU     2000h
ROM_START               EQU     0100h   ; Must be even page boundary.

                ; Equates for the CTC.
CTC_BASE                EQU     0F0h    ; Port address for channel 0.
CTC_VECTOR              EQU     000h    ; Vector number (note IVT below).

                ; Equates for the DART
DART_VECTOR             EQU     20h
                        ; (Channel A)
DARTA_RX                EQU     0F4h    ; Received data port address.
DARTA_TX                EQU     0F4h    ; Transmitted data port address.
DARTA_RS0               EQU     0F5h    ; Primary status register address.
DARTA_RC0               EQU     0F5h    ; Primary control register address.
                        ; (Channel B)
DARTB_RX                EQU     0F6h    ; Received data port address.
DARTB_TX                EQU     0F6h    ; Transmitted data port address.
DARTB_RS0               EQU     0F7h    ; Primary status register address.
DARTB_RC0               EQU     0F7h    ; Primary control register address.

                ; Stack size control.
KERNEL_STACK_SIZE       EQU     64      ; Does not need to be large.
TASK_STACK_SIZE         EQU     128     ; Same for all tasks.

                ; Equates pertaining to the terminal.
RX_BUFFER_SIZE          EQU     64      ; Size of buffer for Rx characters.

CR                      EQU     0Dh     ; Carriage return.
LF                      EQU     0Ah     ; Line feed.

                ; Task table definitions.
NMBR_ENTRIES            EQU     4       ; Number of entries.
TASK_ENTRY_SIZE         EQU    11       ; Size of each entry (bytes).

Next_Entry              EQU     0       ; Pointer to next entry (word) -- MUST BE FIRST!
Stack_Pntr              EQU     2       ; Task's SP register (word)
Nmbr_Ticks              EQU     4       ; Number of times task has been run (double word).
Blocked_Flag            EQU     8       ; =YES if the task is blocked.
Sema_Addr               EQU     9       ; Address of semaphore we are waiting on.



;*****************************************************************************
;       Restart Entry Points.
;*****************************************************************************

                ; Reset entry point.
                ORG      0000h
cold_reset:
        ld      b, 00h                  ; WARNING! Code fills available space.
wait:
        djnz    wait
        jp      Initialize

                ; Restart entry points.

                ORG     0008h
        ret

                ORG     0010h
        ret

                ORG     0018h
        ret

                ORG     0020h
        ret

                ORG     0028h
        ret

                ORG     0030h
        ret

                ORG     0038h
        ret

                ; Non maskable interrupt entry point.
                ORG     0066h
        ret



;*****************************************************************************
;       ROM Data.
;*****************************************************************************

                ORG     ROM_START

;++++++++++++++++++++++++++++++
;          OS Data.
;++++++++++++++++++++++++++++++

        ; The interrupt vector table (this must be first after ROM START).

        ; Vectors 00h .. lEh
        ;       00h .. 06h Used for channels 0 .. 3 of CTC.
IVT:    DW      Dummy, Scheduler, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy,     Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors 20h .. 3Eh
        DW      DARTA_Rx, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy,    Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors 40h .. 5Eh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors 60h .. 7Eh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors 80h .. 9Eh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors A0h .. BEh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors C0h .. DEh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; Vectors E0h .. FEh
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy
        DW      Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy, Dummy

        ; The following table contains the starting addresses of the tasks.
Task_Start:     DW      Task_0, Task_1, Task_2, Task_3

        ; The following table contains the tasks' initial stack pointers.
Task_SP:        DW      Task_0_RAM_End, Task_1_RAM_End
                DW      Task_2_RAM_End, Task_3_RAM_End

        ; The following programs the registers of DART channel A (except Vector number)
DARTA_Init:     DB      04h, 01000100b
                DB      05h, 01101000b
                DB      03h, 11000001b
                DB      01h, 00011000b
DARTA_INIT_COUNT        EQU     8       ; Number of bytes above.

OS_ROM_End:

;++++++++++++++++++++++++++++++++
;          Task_0 Data
;++++++++++++++++++++++++++++++++

Start_Up_Message        DB      "Z-80 Multi-tasking System", CR, LF, 0
Prompt                  DB      CR, LF, "$ ", 0

Task_0_ROM_End:

;++++++++++++++++++++++++++++++++++
;          Task_1 Data
;++++++++++++++++++++++++++++++++++

Task_1_ROM_End:

;++++++++++++++++++++++++++++++++++
;          Task_2 Data
;++++++++++++++++++++++++++++++++++

Task_2_ROM_End:

;++++++++++++++++++++++++++++++++++
;          Task_3 Data
;++++++++++++++++++++++++++++++++++

Task_3_ROM_End:

;*****************************************************************************
;       ROM Code.
;*****************************************************************************

;+++++++++++++++++++++++++++++++++++++++++
;          Initialization Code
;+++++++++++++++++++++++++++++++++++++++++

	INCL	"init.asm"

;++++++++++++++++++++++++++++++++++++++++++++++++
;           Interrupt Service Routines
;++++++++++++++++++++++++++++++++++++++++++++++++

	INCL	"isr.asm"

;+++++++++++++++++++++++++++++++++++++
;          System Services
;+++++++++++++++++++++++++++++++++++++

	INCL	"service.asm"

;++++++++++++++++++++++++++++++++++++++++++
;          Application Programs
;++++++++++++++++++++++++++++++++++++++++++

	INCL	"appl.asm"

;***************************************************************************
;       RAM Data.
;***************************************************************************

        ORG     RAM_START

;+++++++++++++++++++++++
;       OS Data
;+++++++++++++++++++++++

                ; Data for managing the tasks.
Task_Table:             DS      TASK_ENTRY_SIZE * NMBR_ENTRIES
Temp_Stack_Pntr:        DS      2       ; Temporary area for SP.
Current_Task_Pntr:      DS      2       ; Pointer to current tasks' t_table entry.
Global_OS_Counter:      DS      1       ; Generic counter for use when no registers left.

                ; Buffer for characters received from terminal.
Rx_Buffer:              DS      RX_BUFFER_SIZE
Next_In:                DS      2       ; Pointer to next free slot in Rx_Buffer.
Next_Out:               DS      2       ; Pointer to next char to remove from Rx_Buffer.

                ; Stack for ISRs and startup code.
Kernel_Stack_Pntr:      DS      2       ; Holding area for kernel SP.
Kernel_Stack:           DS      KERNEL_STACK_SIZE       ; Must be last!

OS_RAM_End:

;+++++++++++++++++++++++++++
;       Task_0 Data
;+++++++++++++++++++++++++++

Task_0_Stack:           DS      TASK_STACK_SIZE         ; Must be last.
Task_0_RAM_End:

;+++++++++++++++++++++++++++
;       Task_1 Data
;+++++++++++++++++++++++++++

Task_1_Stack:           DS      TASK_STACK_SIZE         ; Must be last.
Task_1_RAM_End:

;+++++++++++++++++++++++++++
;       Task_2 Data
;+++++++++++++++++++++++++++

Task_2_Stack:           DS      TASK_STACK_SIZE         ; Must be last.
Task_2_RAM_End:

;+++++++++++++++++++++++++++
;       Task_3 Data
;+++++++++++++++++++++++++++

Task_3_Stack:           DS      TASK_STACK_SIZE         ; Must be last.
Task_3_RAM_End:

;
;===========================================================================
        END
