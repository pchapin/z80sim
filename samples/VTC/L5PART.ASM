;=================================================
; EL214:      MICROPROCESSOR TECHNIQUES
; LAB5:       DIGITAL TIMER
; PROGRAMMER: ST.DENIS
; DATE:       9/91
;
; This is a partial solution to the "Digital Timer"
; software (lab #5).  It is complete enough to be
; assembled and tested immediately. The
; sections which are missing include:
;       - dealing with the backspace key,
;       - dealing with the REPEAT key,
;       - the "ticking" sound effect,
;       - blanking out the leading zeroes on the display,
;       - turning on the LED which represents the appliance,
;       - display "done" at end of timing operation,
;       - part of the down counting routine (it only handles
;         seconds now).
;=================================================
;DECLARATIONS
;LIBRARY SUBROUTINES
HL_DELAY: EQU 0FFDH     ;DELAY (HL x 1MILLISEC)
SCAN:     EQU 0FEEH     ;SINGLE PASS KEYPAD SCAN AND DISPLAY
KBRD:     EQU 0FEBH     ;SCAN AND DISPLAY, WAITS FOR KEYSTROKE
TONE:     EQU 0FFAH     ;TONE GENERATOR,DURATION=(HL X 1MILLISEC)

;-----------------------------------------
;RESERVED AREAS IN CAMI MEMORY
TG_FREQ:  EQU 1F49H     ;CONSTANT WHICH CONTROLS FREQ OF TONE GEN.
DIG_1:    EQU 1F1CH     ;PLACE 7 SEG CODE HERE BEFORE CALLING SCAN
DIG_2:    EQU 1F1DH
DIG_3:    EQU 1F1EH
DIG_4:    EQU 1F1FH
DIG_5:    EQU 1F20H
DIG_6:    EQU 1F21H

;PORTS
PORT_A:   EQU 0C0H      ;I/O PORTS ON LEFT SIDE OF CAMI
PORT_B:   EQU 0C1H
CTRLPORT: EQU 0C3H

;-----------------------------------------
;CONSTANTS USED IN THIS PROGRAM
RPT_KEY:  EQU 0AH       ;"KBRD" KEYCODE FOR "REPEAT" BUTTON
BKSP_KEY: EQU 0BH       ;                  "BACKSPACE"
CLR_KEY:  EQU 0CH       ;                   "CLEAR"
STRT_KEY: EQU 0FH       ;                   "START"
STOP_KEY: EQU 1CH       ;SCAN CODE FOR STOP KEY

DASH:     EQU 02H       ;7 SEGMENT CODE FOR A "-"
;-----------------------------------------
;TABLES AND VARIABLES USED IN THIS PROGRAM
        ORG 1C00H
MIN_TENS:  DEFS 1       ;ONE BYTE FOR EACH DIGIT OF TOTAL TIME
MIN_UNITS: DEFS 1       ;TIMEKEEPING TABLE
SEC_TENS:  DEFS 1
SEC_UNITS: DEFS 1

;=================================================
;MAIN PROGRAM
        ORG 1800H
INITPORT:
        LD A,82H                ;INITIALIZE PORT_A AS OUTPUT,
        OUT (CTRLPORT),A        ;PORT_B AS INPUT
        LD A,0
        OUT (PORT_A),A          ;TURN OFF APPLIANCE

CLR_TIMR:
        LD A, DASH              ;CREATE "------"  FOR 7 SEG DISPLAY,
        LD (DIG_1),A
        LD (DIG_2),A
        LD (DIG_3),A
        LD (DIG_4),A
        LD (DIG_5),A
        LD (DIG_6),A
        LD A, 0                 ;INITIALIZE TIMER TO ZERO
        LD (MIN_TENS),A
        LD (MIN_UNITS),A
        LD (SEC_TENS),A
        LD (SEC_UNITS),A

MAIN_DISPLAY:
        LD A,00                 ;TURN OF APPLIANCE
        OUT (PORT_A),A
        CALL KBRD               ;DISPLAYS MESSAGE AND SCANS KEYPAD

        CP CLR_KEY              ;IS IT THE "CLEAR" BUTTON?
        JP Z,CLR_TIMR

        CP 0                    ;CHECK THE TIMER BUTTONS
        JP Z, ENTER_DIG
        CP 1
        JP Z, ENTER_DIG
        CP 2
        JP Z, ENTER_DIG
        CP 3
        JP Z, ENTER_DIG
        CP 4
        JP Z, ENTER_DIG
        CP 5
        JP Z, ENTER_DIG
        CP 6
        JP Z, ENTER_DIG
        CP 7
        JP Z, ENTER_DIG
        CP 8
        JP Z, ENTER_DIG
        CP 9
        JP Z, ENTER_DIG

        CP STRT_KEY
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

UPD_MSG:                ;TAKES CONTENTS OF TIMERS
                        ;AND CREATES NEW "MESSAGE"
                        ;TO BE DISPLAYED ON 7-SEG LEDS
        LD HL,MIN_TENS  ;POINT AT TIMEKEEPING BYTES
        LD DE,DIG_2
        LD B,4

        ;--------------------------------
        ;H I N T :  ****DEAL WITH LEADING ZEROES HERE****
        ;--------------------------------

UP_L2:  LD A,(HL)       ;CONVERT REMAINING DIGITS TO 7 SEG CODES
        CALL GET7SEG
        LD (DE),A
        INC DE
        INC HL
        DEC B
        JP NZ,UP_L2
UP_C1:
        LD A,(DIG_3)    ;TURN ON DEC.PT
        SET 6,A
        LD (DIG_3),A
        LD A,8DH        ;PUT BRACKETS ON ENDS("[")
        LD (DIG_1),A
        LD A,0B8H       ;"]"
        LD (DIG_6),A
        RET

GET7SEG: PUSH HL
        PUSH DE
        LD HL, CODE7SEG
        LD E,A
        LD D,0
        ADD HL,DE
        LD A,(HL)
        POP DE
        POP HL
        RET
CODE7SEG: DEFB 10111101B   ;LOOKUP TAB FOR 7 SEGMENT CODES ('0'-'9')
        DEFB 00110000B
        DEFB 10011011B
        DEFB 10111010B
        DEFB 00110110B
        DEFB 10101110B
        DEFB 10101111B
        DEFB 00111000B
        DEFB 10111111B
        DEFB 00111110B

START_TIMR:               ;THE MAIN TIMING SOFTWARE
CHK4ZERO:LD HL,MIN_TENS   ;CHK FOR ALL ZEROS
        LD B,4
C4Z_L1: LD A,(HL)
        CP 0
        JP NZ, ST_C1
        INC HL
        DEC B
        JP NZ, C4Z_L1
        JP ST_END         ;MUST BE ZEROS, DONE
ST_C1:  CALL UPD_MSG      ;PREP DISPLAY
        LD B,100          ;FOR 1 SEC DELAY
TMRLOOP: CALL SCAN
        CP STOP_KEY
        JP Z,MAIN_DISPLAY       ;RETURN TO MAIN
        DEC B
        JP NZ, TMRLOOP
DECTIM:                         ;1 SEC. HAS PASSED, DECREMENT TIME COUNT
        LD HL,SEC_UNITS         ;HL=PTR TO TIME VALUES
        LD A, (HL)
        DEC A
        LD (HL),A
        CP 0FFH
        JP NZ, CHK4ZERO
        LD A, 9         ;RESTART UNITS OF SEC.
        LD (HL),A
        DEC HL          ;PLAY WITH TENS OF SECS
        LD A, (HL)
        DEC A
        LD (HL),A
        CP 0FFH
        JP NZ, CHK4ZERO
        ;--------------------------------
        ; H I N T: YOU'LL HAVE TO CONTINUE THIS ROUTINE
        ;          TO CHECK FOR MINUTES.
        ;--------------------------------
ST_END:                ;MUST BE DONE, DECR'D EVERYTHING BELOW ZERO
        LD A,0          ;TURN OFF APPLIANCE
        OUT (PORT_A),A

        LD HL,500
        CALL TONE       ;BEEP
        JP CLR_TIMR


        END
