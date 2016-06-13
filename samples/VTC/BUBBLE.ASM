;===========================================================================
; FILE          : BUBBLE.ASM
; LAST REVISION : September 1991
; PROGRAMMER    : Peter Chapin
;
; This file contains a program which sorts a 256 byte block of memory
; starting at location 1A00h. This program uses a bubble sorting technique.
;===========================================================================

        ORG     1800h

Start:
        ; Get ready to do one pass over the data.
        LD      C, 00h          ; Set switchflag = NO.
        LD      IX, 1A00h       ; Point at the start of the data to sort.
        LD      B, 0FFh         ; 255 overlapping pairs of bytes.

Table_Loop:
        ; Skip the exchange if (IX+0) <= (IX+1)
        LD      A, (IX+1)
        CP      (IX+0)
        JP      NC, Skip

        ; Exchange (IX+0) and (IX+1)
        LD      D, (IX+0)
        LD      (IX+0), A
        LD      (IX+1), D
        LD      C, 01h          ; Set switchflag = YES.

Skip:
        ; Get ready to process the next pair of bytes.
        INC     IX

        ; Jump back if there are more pairs to look at.
        DEC     B
        JP      NZ, Table_Loop

        ; Do another pass if switchflag = YES.
        LD      A, C
        CP      01h
        JP      Z, Start

        ; Done.
        HALT

        END
