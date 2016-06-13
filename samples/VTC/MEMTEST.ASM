; ===========================================================================
; FILE          : memtest.asm
; LAST REVISION : September 1995
; SUBJECT       : Simple memory test program for the CAMI trainer.
; PROGRAMMER    : Peter Chapin
;
; This program scans memory looking for bad memory locations. It displays the
;   current memory address during the scan on the trainer's LEDs. Here is
;   an outline of the program:
;
; <Initialize ports>
; <Get starting address for the scan>
; <Get size of the scan>
; REPEAT
;   <Display current address>
;   <Save memory data>
;   IF <location cannot accept 00h> THEN
;     <Remember that we found a bad spot>
;   END
;   IF <location cannot accept FFh> THEN
;     <Remember that we found a bad spot>
;   END
;   <Restore memory data>
;   <Increment pointer>
;   <Decrement counter>
; UNTIL <bad location found> OR <counter = 0>
; IF <no bad locations found> THEN
;   <Clear LEDs>
; END
;
; Please send comments and bug reports to
;
;      Peter Chapin
;      P.O. Box 375
;      Randolph Center, VT 05061
;      pchapin@night.vtc.vsc.edu
; ===========================================================================

CTRL_PORT       EQU     0C3h    ; Nice names for the 8255 ports.
PORT_A          EQU     0C0h
PORT_B          EQU     0C1h

ADDRESS         EQU     1900h
SIZE            EQU     1902h

        ORG     1800h

        ; Initialize ports as outputs.
        LD      A, 80h
        OUT     (CTRL_PORT), A

        ; Get the starting address in HL and the number of locations
        ;   to examine in BC.
        LD      HL, (ADDRESS)
        LD      BC, (SIZE)
Next:
        ; Display the current address.
        LD      A, L
        OUT     (PORT_A), A
        LD      A, H
        OUT     (PORT_B), A

        ; Register D will be set to 01h if the location is bad.
        LD      D, 00h
        LD      E, (HL)         ; Save memory data in register E.

        ; Will location accept 00h?
        LD      A, 00h
        LD      (HL), A
        CP      (HL)
        JP      Z, Ok_So_Far    ; Jump if so.
        LD      D, 01h          ; Otherwise mark location as bad.

Ok_So_Far:
        ; Will location accept 0FFh?
        LD      A, 0FFh
        LD      (HL), A
        CP      (HL)
        JP      Z, Ok           ; Jump if so.
        LD      D, 01h          ; Otherwise mark location as bad.

Ok:
        LD      (HL), E         ; Restore data.

        ; Adjust pointer and counter.
        INC     HL
        DEC     BC

        ; Bad location found?
        LD      A, D
        CP      01h
        JP      Z, Done         ; Yes... skip down.

        ; Counter = 0000h?
        LD      A, B
        CP      00h
        JP      NZ, Next        ; No... Try next location.
        LD      A, C
        CP      00h
        JP      NZ, Next        ; No... Try next location.

Done:
        ; Bad location found?
        LD      A, D
        CP      01h
        JP      Z, Finish       ; Yes... skip to halt.
        LD      A, 00h          ; No... Turn off LEDs.
        OUT     (PORT_A), A
        OUT     (PORT_B), A

Finish:
        HALT

        END

