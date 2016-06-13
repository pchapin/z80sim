
;---------------------------------------------------------------------------
; PROC Get_Char
;
; The following routine returns a character from the terminal. It waits until a character is
; available before returning. It works by watching the buffer that is loaded up by the interrupt
; service routine. When something appears in that buffer (Next_In != Next_Out), this routine
; immediately reads it out. This routine also adjusts Next_Out.
;
; The logic of this routine is currently such that race conditions between multiple tasks are
; NOT prevented. Do NOT CALL THIS ROUTINE FROM MORE THAN ONE TASK!! Furthermore, this routine
; busy waits. It does not "block."
;
;     ENTRY:
;     No conditions.
;
;     EXIT:
;     A contains ASCII code of character from terminal. No other registers changed.
;---------------------------------------------------------------------------

Get_Char:
        push    bc
        push    de
        push    hl

wait_for_char:
        ld      hl, (Next_In)   ; Important to read Next_In all the time.
        ld      de, (Next_Out)
        ld      a, h
        cp      d
        jp      nz, char_exists
        ld      a, l
        cp      e
        jp      z, wait_for_char

        ; Character in Rx Buffer, get it.
char_exists:
        ld      a, (de)
        ld      b, a

       ; Advance Next_Out
        inc     de

        ; Have we advanced Next_Out of the end of the buffer?
        ld      hl, Rx_Buffer + RX_BUFFER_SIZE
        ld      a, h
        cp      d
        jp      nz, next_out_ok
        ld      a, l
        cp      e
        jp      nz, next_out_ok

        ; If so, reset it to the start of the buffer.
        ld      de, Rx_Buffer

next_out_ok:
        ld      (Next_Out), de

        ; Get the saved away character for returning in A.
        ld      a, b

        ; Restore registers
        pop     hl
        pop     de
        pop     bc

        ret

;-----------------------------------------------------------------------------
; PROC Put Char
;
; The following routine writes a character to the terminal. It waits until the DART is finished
; transmitting the previous character before it outputs the current character.
;
; The logic of this routine is currently such that race conditions between multiple tasks are
; NOT prevented. DO NOT CALL THIS ROUTINE FROM MORE THAN ONE TASK!! Notice that this routine
; does busy waiting for the UART.
;-----------------------------------------------------------------------------

Put_Char:

        ; Wait until the DART is finished transmitting its current character.
        push    af

wait_for_TX:
        in      a, (DARTA_RS0)
        bit     2, a
        jp      z, wait_for_TX
        pop     af

        ; Send out the given character.
        out     (DARTA_TX), a
        ret

;-----------------------------------------------------------------------------
; PROC Sema_Up
;
; The following routine performs an atomic UP operation on a semaphore. It increments the
; semaphore unless it is zero and there is a task blocked on it. If there is a task blocked on
; it, that task is unblocked and the semaphore remains at zero.
;
;     ENTRY:
;     HL points at the semaphore.
;
;     EXIT:
;     Semaphore is released by the calling task.
;-----------------------------------------------------------------------------

Sema_Up:
        push    af

        ; Don't interrupt this operation!
        di

        ; Is the semaphore a zero now?
        ld      a, 0
        cp      (hl)
        jp      z, up_zero

        ; Nope. Just increment it normally and we're done.
        inc     (hl)
        ei

        pop     af
        ret

up_zero:
        push    bc
        push    de
        push    ix

        ; Yep. Get the pointer to this task's task table entry.
        ld      ix, (Current_Task_Pntr)

        ; Look at all other tasks to see if there is anybody blocked on this semaphore.
        ld      b, NMBR_ENTRIES - 1

up_loop:
        ; Get the task pointer for the next task.
        ld      e, (ix + Next_Entry + 0)
        ld      d, (ix + Next_Entry + 1)
        push    de
        pop     ix

        ; Only consider tasks that are blocked.
        ld      a, (ix + Blocked_Flag)
        cp      NO
        jp      z, up_skip

        ; If the task is blocked, only consider ones that are blocked on the given semaphore.
        ld      a, (ix + Sema_Addr + 0)
        cp      l
        jp      nz, up_skip
        ld      a, (ix + Sema_Addr + 1)
        cp      h
        jp      nz, up_skip

        ; We found one! Unblock it and leave the semaphore at zero.
        ld      a, NO
        ld      (ix + Blocked_Flag), a
        ld      a, 0
        ld      (ix + Sema_Addr + 0), a
        ld      (ix + Sema_Addr + 1), a

        ; We're done. Blast outta here.
        ei
        pop     ix
        pop     de
        pop     bc
        pop     af
        ret

up_skip:
        djnz    up_loop

        ; If we are here, there was nobody blocked on the semaphore. Just increment it normally.
        inc     (hl)
        ei

        pop     ix
        pop     de
        pop     bc
        pop     af
        ret

;-----------------------------------------------------------------------------
; PROC Sema_Down
;
; The following routine performs an atomic DOWN operation on a semaphore. It decrements the
; semaphore unless it is zero. If the semaphore is zero, the calling task is marked as blocked
; on the semaphore.
;
;     ENTRY:
;     HL points at the semaphore.
;
;     EXIT:
;     Semaphore is grabbed by the calling task.
;-----------------------------------------------------------------------------

Sema_Down:
        push    af

        ; Don't interrupt this operation!
        di

        ; Is the semaphore a zero now?
        ld      a, 0
        cp      (hl)
        jp      z, down_zero

        ; Nope. Just decrement it normally and we're done.
        dec     (hl)
        ei

        pop     af
        ret

down_zero:
        push    ix

        ; Yep. Get the pointer to this task's task table entry.
        ld      ix, (Current_Task_Pntr)

        ; Mark this task as blocked and install pointer to semaphore into the task table.
        ld      a, YES
        ld      (ix + Blocked_Flag), a
        ld      (ix + Sema_Addr + 0), l
        ld      (ix + Sema_Addr + 1), h

        ; Turn interrupts back on and wait until we are no longer blocked. This will busy wait
        ; only until the next timer interrupt.
        ei

down_wait:
        ld      a, (ix + Blocked_Flag)
        cp      YES
        jp      z, down_wait

        pop     ix
        pop     af
        ret

