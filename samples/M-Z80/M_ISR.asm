
;---------------------------------------------------------------------------
; PROC Dummy
;
; What follows is the interrupt service routine to handle "spurious" interrupts. This routine
; should never be called. However, its existance may prevent the system from crashing if
; hardware requests an unknown interrupt.
;---------------------------------------------------------------------------

Dummy:
        ei
        reti

;---------------------------------------------------------------------------
; PROC Scheduler
;
; What follows is the timer interrupt service routine which performs the context switch. It is
; this routine that actually produces the illusion of multi-tasking.
;---------------------------------------------------------------------------

Scheduler:

        ; First order of business is saving the outgoing task's registers.
        push    af
        push    bc
        push    de
        push    hl
        ex      af, af'
        exx
        push    af
        push    bc
        push    de
        push    hl
        push    ix
        push    iy

        ; Look up pointer to Task Table entry for current task and save sp.
        ld      ix, (Current_Task_Pntr)
        ld      (Temp_Stack_Pntr), sp
        ld      hl, (Temp_Stack_Pntr)
        ld      (ix + Stack_Pntr), l
        ld      (ix + Stack_Pntr + 1), h

        ; Set stack pointer for kernel code.
        ld      sp, (Kernel_Stack_Pntr)

        ; Update statistics on outgoing task.
        inc     (ix + Nmbr_Ticks)        ; increment the tick counter
        jp      nz, sch_which
        inc     (ix + Nmbr_Ticks + 1)
        jp      nz, sch_which
        inc     (ix + Nmbr_Ticks + 2)
        jp      nz, sch_which
        inc     (ix + Nmbr_Ticks + 3)

        ; -----
        ; Decide which task gets to run next.
        ; -----
sch_which:

        ; Set ix to point at the Task_Table entry for next task.
        ld      l, (ix + Next_Entry)
        ld      h, (ix + Next_Entry + 1)
        push    hl
        pop     ix

        ; If this task is blocked, loop back and try the next one.
        ld      a, YES
        cp      (ix + Blocked_Flag)
        jp      z, sch_which

        ; -----
        ; We have scheduled the next task... let's return to it.
        ; -----

        ; Save stack pointer for kernel code.
        ld      (Kernel_Stack_Pntr), sp

        ; Load up the CPU with the incoming task's registers.
        ld      l, (ix + Stack_Pntr)
        ld      h, (ix + Stack_Pntr + 1)
        ld      (Temp_Stack_Pntr), hl
        ld      sp, (Temp_Stack_Pntr)

        ; Save ix for use at next scheduler call.
        ld      (Current_Task_Pntr), ix

        ; Get new task's registers.
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

        ; Return to new task!
        ei
        reti

;---------------------------------------------------------------------------
; PROC DARTA_Rx
;
; What follows is the interrupt service routine which is called whenever the DART has received a
; character. This routine just reads the character out of the DART and loads it into an internal
; buffer for the Get Char routine.
;---------------------------------------------------------------------------

DARTA_Rx:
        ; Save registers for later restoration.
        push   af
        push   de
        push   hl

        ; Read the DART and install the character in the buffer.
        in     a, (DARTA_RX)
        ld     hl, (Next_In)
        ld     (hl), a

        ; Advance Next_In
        inc    hl

        ; See if Next_In has gone off the end of the Rx_Buffer
        ld     de, Rx_Buffer + RX_BUFFER_SIZE
        ld     a, l
        cp     e
        jp     nz, next_in_ok
        ld     a, h
        cp     d
        jp     nz, next_in_ok

        ; If it has, reset it.
        ld     hl, Rx_Buffer

next_in_ok:
        ld      (Next_In), hl

        ; Restore registers
        pop    hl
        pop    de
        pop    af

        ei
        reti

