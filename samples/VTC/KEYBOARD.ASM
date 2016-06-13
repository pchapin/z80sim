;===========================================================================
; FILE        : KEYBOARD.ASM
; LAST REVISED: September 30, 1993
; PROGRAMMER  : Peter Chapin
;
; This routine scans an 8x8 keyboard matrix connected the the CAMI trainer.
; It scans the keyboard once and then returns at once. It returns with A = 0
; if there were no keys pressed. Otherwise it returns a keycode related to
; the row, col coordinates of the key.
;
; P-code of Scan_Key:
;
; <Initialize data objects>
; REPEAT
;   <Apply column driver to the columns of the matrix>
;   <Read rows>
;   REPEAT
;     <Increment key_count; This serves as the key code for the current key>
;     <Shift row byte to force MSB into CY flag>
;     IF <CY clear> THEN
;       <Set key_code = current key_count>
;     END
;   UNTIL <All rows have been considered>
;   <Shift column driver byte>
; UNTIL <All columns have been considered>
;===========================================================================

PORT_A          EQU     0C0h    ; Nice names for the ports.
PORT_B          EQU     0C1h
CNTRL_PORT      EQU     0C3h

;---------------------------------------------------------------------------
; The following is the Scan_Key routine.
;
; Register Usage.
; b     Used to count number of rows processed.
; c     Used to count number of cols processed.
; d     Applied to the columns of the matrix.
; e     Total number of keys processed.
; h     =KEY_COUNT of key pressed (0 if none pressed).
;---------------------------------------------------------------------------

Scan_Key:
        ; Save registers.
        push    bc
        push    de
        push    hl

        ; Initialize data objects.
        ld      d, 01111111b
        ld      e, 00h
        ld      h, 00h
        ld      c, 08h          ; Eight columns to consider.

        ; Process each column...
next_col:
        ld      a, d            ; Write column driver to matrix.
        out     (PORT_A), a
        in      a, (PORT_B)     ; Get row information.

        ; Within each column, process each row...
        ld      b, 08h          ; Eight rows to consider.
next_row:
        inc     e               ; KEY_COUNT = key number about to consider.
        sla     a               ; Was it pressed?
        jp      c, skip         ; Skip if not; otherwise update KEY_CODE.
        ld      h, e
skip:
        djnz    next_row        ; Jump back if more rows to do.

        ; Prepare to handle the next column and handle it.
        rrc     d
        dec     c
        jp      nz, next_col

        ; Return result in A.
        ld      a, h

        ; Restore registers.
        pop     hl
        pop     de
        pop     bc
        ret

        END

