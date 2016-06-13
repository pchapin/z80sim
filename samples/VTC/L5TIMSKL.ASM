;=================================================
; EL214:      MICROPROCESSOR TECHNIQUES
; LAB5:       DIGITAL TIMER
; PROGRAMMER: ST.DENIS
; DATE:       3/5/91
;=================================================
;DECLARATIONS
;LIBRARY SUBROUTINES
HL_DELAY: EQU 0FFDH     ;DELAY (HL x 1MILLISEC)
SCAN:     EQU 0FEEH     ;SINGLE PASS KEYPAD SCAN AND DISPLAY
KBRD:     EQU 0FEBH     ;SCAN AND DISPLAY, WAITS FOR KEYSTROKE
TONE:     EQU 0FFAH     ;TONE GENERATOR,DURATION=(HL X 1MILLISEC)
    .
    .
;RESERVED AREAS IN CAMI MEMORY
TG_FREQ:  EQU 1F49H     ;CONSTANT WHICH CONTROLS FREQ OF TONE GEN.
DIG_1:    EQU 1F1CH     ;PLACE 7 SEG CODE HERE BEFORE CALLING SCAN
DIG_2:    EQU 1F1DH
DIG_3:    EQU 1F1EH
    .
    .
;PORTS
PORT_A:   EQU 0C0H      ;I/O PORTS ON LEFT SIDE OF CAMI
PORT_B:   EQU 0C1H
CTRLPORT: EQU 0C3H
    .
    .
;CONSTANTS USED IN THIS PROGRAM
RPT_KEY:  EQU 0AH       ;KEYCODE FOR "REPEAT" BUTTON
CLR_KEY:  EQU 0CH       ;KEYCODE FOR "CLEAR" BUTTON
    .
    .
;TABLES AND VARIABLES USED IN THIS PROGRAM
        ORG 1C00H
MIN_TENS:  DEFB 0       ;ONE BYTE FOR EACH DIGIT OF TOTAL TIME
MIN_UNITS: DEFB 0       ;TIMEKEEPING TABLE
SEC_TENS:  DEFB 0
SEC_UNITS: DEFB 0
    .
    .
;=================================================
;MAIN PROGRAM
        ORG 1800H
INITPORT:
        LD A,82H                ;INITIALIZE PORT_A AS OUTPUT,
        OUT (CTRLPORT),A        ;PORT_B AS INPUT

CLR_TIMR:
          .                     ;CREATE "[--.--]"  FOR 7 SEG DISPLAY,
          .                     ;INITIALIZE TIMERS TO ZERO
          .
MAIN_DISPLAY:
        CALL KBRD               ;DISPLAYS MESSAGE AND SCANS KEYPAD

        CP CLR_KEY              ;IS IT THE "CLEAR" BUTTON?
        JP Z,CLR_TIMR

        CP 0                    ;CHECK THE TIMER BUTTONS
        JP Z, ENTER_DIG
        CP 1
        JP Z, ENTER_DIG
          .
          .
          (CHECK THE OTHER KEYCODES HERE)
          .
          .

        CP START_KEY
        JP Z, START_TIMR
        JP MAIN_DISPLAY         ;NOT LEGAL KEY, GOTO TOP OF LOOP
;-----------------------------------
; KEYPAD TASKS
ENTER_DIG: LD IX,MIN_TENS       ;MOVE ALL DIGITS UP ONE POSITION
        LD B,(IX+1)
        LD (IX+0),B
        LD B,(IX+2)
        LD (IX+1),B
        LD B,(IX+3)
        LD (IX+2),B
        LD (IX+3),A             ;FINALLY, SAVE NEW DIGIT
        CALL UPD_MSG
        JP MAIN_DISPLAY
UPD_MSG:  .             ;TAKE CONTENTS OF TIMERS
          .             ;AND CREATE NEW MESSAGE
          (MAKE THIS A SUBROUTINE!!)
          RET
START_TIMR:             ;THE MAIN TIMING SOFTWARE
          .
          .

        JP CLR_TIMR
        JP MAIN_DISPLAY
          .
          .
   (ALL OTHER ROUTINES WHICH IMPLEMENT THE KEYSTROKES
          GO HERE)


        END
