
;-----------------------------------------------------------------------------
; PROC Initialize
;
; The following code takes control as soon as the Z80 is clear of a reset. It performs
; initialization activities of interest to the kernel and system service code. When finished, it
; starts Task 0. Multi-tasking will allow the other tasks to start in due time. Note that each
; task is responsible for its own initializations.
;-----------------------------------------------------------------------------

Initialize:

        ; Make sure we have a stack.
        ld      sp, OS_RAM_End

        ; Initialize general OS data.
        ld      hl, Rx_Buffer
        ld      (Next_In), hl
        ld      (Next_Out), hl

        ; Set up task table and task stacks.
        call    Initialize_Tasks

        ; Set up for interrupt handling.
        ld      a, HIGH(IVT)
        ld      i, a
        im      2

        ; Configure hardware devices.
        call    Program_CTC
        call    Program_DART

        ld      (Kernel_Stack_Pntr), sp

        ; Make Task 0 the first executing task...
        ld      ix, Task_Table
        ld      (Current_Task_Pntr), ix
        ld      l, (ix + Stack_Pntr)
        ld      h, (ix + Stack_Pntr + 1)
        ld      (Temp_Stack_Pntr), hl
        ld      sp, (Temp_Stack_Pntr)

        ; Get the task's registers and return to start of task.
        pop     iy
        pop     ix
        pop     hl
        pop     de
        pop     bc
        pop     af
        exx
        ex      af, af'
        pop     hl
        pop     de
        pop     bc
        pop     af
        ei
        ret

;---------------------------------------------------------------------------
; PROC Initialize_Tasks
;
; The following routine initializes all tasks. It first links the task table and initializes all
; the task table's fields. It then pushes initial task registers onto each stack and installs
; the resulting stack pointer into the task table. Note that this routine uses the
; Global_OS_Counter.
;
;         ENTER:
;         Global_OS_Counter not in current use.
;
;         EXIT:
;         All registers changed!
;---------------------------------------------------------------------------

Initialize_Tasks:

        ; Save Kernel sp in bc' -- we'll need sp for other things here.
        exx
        ld      (Temp_Stack_Pntr), sp
        ld      bc, (Temp_Stack_Pntr)
        exx

        ; Point at tables of critical task initial values.
        ld      de, Task_Start
        ld      hl, Task_SP

        ; Point at task table.
        ld      ix, Task_Table

        ; Loop over the tasks in the task table.
        ld      a, NMBR_ENTRIES
        ld      (Global_OS_Counter), a

init_task_loop:

        ; Point at task's stack.
        ld      c, (hl)
        inc     hl
        ld      b, (hl)
        inc     hl
        ld      (Temp_Stack_Pntr), bc
        ld      sp, (Temp_Stack_Pntr)

        ; Push starting address of task onto the task's stack.
        ld      a, (de)
        ld      c, a
        inc     de
        ld      a, (de)
        ld      b, a
        inc     de
        push    bc

        ; Initialize task's registers. Note the switch to the primed registers.
        exx
        call    Initialize_Registers

        ; Save resulting stack pointer in the task table.
        ld      (Temp_Stack_Pntr), sp
        ld      hl, (Temp_Stack_Pntr)
        ld      (ix + Stack_Pntr), l
        ld      (ix + Stack_Pntr + 1), h

        ; Zero out the number of ticks for this task.
        ld      a, 00h
        ld      (ix + Nmbr_Ticks + 0), a
        ld      (ix + Nmbr_Ticks + 1), a
        ld      (ix + Nmbr_Ticks + 2), a
        ld      (ix + Nmbr_Ticks + 3), a

        ; Task is not blocked.
        ld      a, NO
        ld      (ix + Blocked_Flag), a
        ld      a, 0
        ld      (ix + Sema_Addr + 0), a
        ld      (ix + Sema_Addr + 1), a

        ; Link to next task table entry.
        push    ix              ; Transfer current pointer to iy for safekeeping.
        pop     iy
        ld      de, TASK_ENTRY_SIZE
        add     ix, de          ; Advance ix to next task table entry.
        push    ix              ; Move the advanced pointer into de.
        pop     de
        ld      (iy + Next_Entry), e    ; Install link to next table entry.
        ld      (iy + Next_Entry + 1), d

        ; Loop back if more tasks to handle. Note restoration of primary registers.
        exx
        ld      a, (Global_OS_Counter)
        dec     a
        ld      (Global_OS_Counter), a
        jp      nz, init_task_loop

        ; Fixup last link to form circular list out of the task table.
        ld      ix, Task_Table + (NMBR_ENTRIES - 1) * TASK_ENTRY_SIZE
        ld      de, Task_Table
        ld      (ix + Next_Entry), e
        ld      (ix + Next_Entry + 1), d

        ; Restore Kernel sp.
        exx
        ld      (Temp_Stack_Pntr), bc
        ld      sp, (Temp_Stack_Pntr)
        exx

        ret

;---------------------------------------------------------------------------
; PROC Initialize_Registers
;
; The following routine pushes a number of zeros onto the stack. These zeros will be used for
; the initial values of a task's registers. Before this routine is called, sp must be adjusted
; to point at the stack for the desired task.
;
; Note that this routine must first pull the return address off the stack before it can push
; zeros. It then must replace that address so the ret at the end will return normally.
;
;         ENTER:
;         Sp points at a task's stack (with return address for this routine on top).
;
;         EXIT:
;         Several copies of 16 bit zero pushed onto the stack. Routine returns "normally." HL
; and DE destroyed.
;---------------------------------------------------------------------------

Initialize_Registers:

        ; Get the return address.
        pop     de

        ; Push enough zeros.
        ld      hl, 0000h
        push    hl              ; af
        push    hl              ; bc
        push    hl              ; de
        push    hl              ; hl
        push    hl              ; af'
        push    hl              ; bc'
        push    hl              ; de'
        push    hl              ; hl'
        push    hl              ; ix
        push    hl              ; iy

        ; Put the return address back.
        push    de

        ; Done.
        ret

;---------------------------------------------------------------------------
; PROC Program_CTC
;
; The following routine programs channel 0 of the CTC to provide the correct baud rate for the
; DART. Channel 1 of the CTC will generate 10 mS interrupts. These interrupts drive the
; scheduler.
;
;       ENTER
;       No conditions
;
;       EXIT
;       No registers changed
;---------------------------------------------------------------------------

Program_CTC:
        push    af

        ; Inform CTC of the vectors to use for interrupts.
        ld      a, CTC_VECTOR
        out     (CTC_BASE), a

        ; Program ch0 to generate 1200 baud for the DART
        ld      a, 01000101b
        out     (CTC_BASE+0), a
        ld      a, 104
        out     (CTC_BASE+0), a

        ; Program Ch1 for 10 mS timer interrupts.
        ld      a, 10100101b            ; Int On, Timer, /256, Auto
        out     (CTC_BASE+1), a
        ld      a, 156                  ; Assumes 4 MHz clock.
        out     (CTC_BASE+1), a

        pop     af
        ret

;---------------------------------------------------------------------------
; PROC Program DART
;
; This routine sets up Channel A of the DART to interact with a terminal.
;
;        ENTRY
;        No conditions.
;
;        EXIT
;        DART chip programmed.
;---------------------------------------------------------------------------

Program_DART:
        ; Save registers.
        push    af
        push    bc
        push    hl

        ; Program the Interrupt vector for the DART. Only one in this application.
        ld      a, 02h
        out     (DARTB_RC0), a
        ld      a, DART_VECTOR
        out     (DARTB_RC0), a

        ; Fire the configuration bytes for channel A at the DART.
        ld     c, DARTA_RC0
        ld     b, DARTA_INIT_COUNT
        ld     hl, DARTA_Init
        otir

        ; Restore registers.
        pop    hl
        pop    bc
        pop    af
        ret

