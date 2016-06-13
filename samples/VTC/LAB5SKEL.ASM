;=================================================
; EL214:      MICROPROCESSOR TECHNIQUES
; LAB5:       MICROWAVE CONTROL SOFTWARE
; PROGRAMMER: 
; DATE:       9/18/90
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
PLUS10M EQU 0           ;KEYCODE FOR "+10MIN" BUTTON
PLUS1M  EQU 1           ;KEYCODE FOR "+1MIN" BUTTON
    .
    .
;TABLES AND VARIABLES USED IN THIS PROGRAM
        ORG 1900H
MIN_TENS:  DEFB 0       ;ONE BYTE FOR EACH DIGIT OF TOTAL TIME
MIN_UNITS: DEFB 0
SEC_TENS:  DEFB 0
SEC_UNITS: DEFB 0
POW_LEV:   DEFB 0       ;HOLD CURRENT POWER LEVEL (0-3?)
    .
    .
;=================================================
;MAIN PROGRAM
        ORG 1800H
INITPORT: 
        LD A,82H                ;INITIALIZE PORT_A AS OUTPUT, 
        OUT (CTRLPORT),A        ;PORT_B AS INPUT

CLR_OVEN:
          .                     ;CREATE "------"  FOR 7 SEG DISPLAY,
          .                     ;INITIALIZE TIMERS AND POWER LEVEL
          .
MAIN_DISPLAY:
        CALL KBRD               ;DISPLAYS MESSAGE AND SCANS KEYPAD

        CP CLR_KEY              ;IS IT THE "CLEAR" BUTTON?
        JP Z,CLR_OVEN

        CP PLUS10M              ;CHECK THE TIMER BUTTONS
        JP Z, UPD_TOM
        CP PLUS1M
        JP Z, UPD_UOM
          .
          .
          (CHECK THE OTHER KEYCODES HERE)
          .
          .

        CP START_KEY
        JP Z, START_OVEN
        JP MAIN_DISPLAY         ;NOT LEGAL KEY, GOTO TOP OF LOOP
;-----------------------------------
; KEYPAD TASKS
UPD_TOM:                ;UPDATE TENS OF MINUTES DIGIT
        LD A,(MIN_TENS)
        CALL INC_MOD_10
        LD (MIN_TENS)
        JP UPD_MSG
UPD_UOM:                ;UPDATE UNITS OF MINUTES DIGIT
          .
          .
          .
          (ALL OTHER ROUTINES WHICH IMPLEMENT THE KEYSTROKES
          GO HERE)
          .
UPD_MSG:  .             ;TAKE CONTENTS OF TIMERS AND POW_LEV 
          .             ;AND CREATE NEW MESSAGE
          .
        JP MAIN_DISPLAY

START_OVEN:             ;THE MAIN "COOKING" SOFTWARE
          .
          .

        JP CLR_OVEN

;-----------------------------------
; SUBROUTINES
INC_MOD_10:             ;INCREMENT THE VALUE IN THE A REGISTER,
          .             ;MODULUS 10 (GOES ..8,9,0,1,2,...)
          .
        RET

IS_TIME_ZERO:           ;CHECKS IF ALL TIMER DIGITS ARE ZERO 
          .             ;AND SETS THE Z FLAG IF TRUE
          .
        RET





