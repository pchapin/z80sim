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

;CONSTANTS USED IN THIS PROGRAM
;RPT_KEY:  EQU 0AH       ;KEYCODES, "REPEAT" BUTTON
SEQ_KEY:  EQU 0AH       ;"SEQUENCER" KEY
BKSP_KEY: EQU 0BH       ;"BACKSPACE"
CLR_KEY:  EQU 0CH       ;"CLEAR"
STOP_KEY: EQU 1CH       ;SCAN CODE FOR STOP KEY
STRT_KEY: EQU 0FH       ;START KEY

;TABLES AND VARIABLES USED IN THIS PROGRAM
        ORG 1C00H

CURR_SEQ: DEFB 0         ;HOLDS CURRENT SEQ. MEM # (1 - 4)
CURR_PTR: DEFW 0         ;HOLDS PTR TO CURRENTLY ACTIVE SEQ. MEM
SEQ_MEM: DEFS 4*4         ;RESERVE SPACE FOR SEQUENCE STORAGE

;=================================================
;MAIN PROGRAM
        ORG 1800H
INITPORT:
        LD A,82H                ;INITIALIZE PORT_A AS OUTPUT,
        OUT (CTRLPORT),A        ;PORT_B AS INPUT
        LD A,0
        OUT (PORT_A),A          ;TURN OFF APPLIANCE

        LD A,0                  ;CLEAR ALL TIMERS
        LD HL,SEQ_MEM
        LD B,16
IP_L1:  LD (HL),A
        INC HL
        DEC B
        JP NZ, IP_L1

        LD A,1                  ;SELECT TIMER #1 AS DEFAULT
        LD (CURR_SEQ),A
        LD HL,SEQ_MEM
        LD (CURR_PTR),HL

MAIN_DISPLAY:
        CALL UPD_MSG            ;UPDATE 7 SEG DISPLAY
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

        CP BKSP_KEY
        JP Z, BACKSPACE
;        CP RPT_KEY
;        JP Z, REPEAT
        CP SEQ_KEY
        JP Z,SEQ_SELECT
        CP STRT_KEY
        JP Z, START_TIMR
        JP MAIN_DISPLAY         ;NOT LEGAL KEY, GOTO TOP OF LOOP
;-----------------------------------
; KEYPAD TASKS
SEQ_SELECT:             ;POLLING ROUTINE FOR TWO-KEY FUNCTIONS
        LD A,00H        ;CLR SEQ # IN FIRST DIGIT
        LD (DIG_1),A

        CALL KBRD               ;GET 2ND KEY IN SEQUENCE
        CP 1
        JP Z, STOR_SEQ
        CP 2
        JP Z, STOR_SEQ
        CP 3
        JP Z, STOR_SEQ
        CP 4
        JP Z, STOR_SEQ
        JP MAIN_DISPLAY

STOR_SEQ: LD (CURR_SEQ),A      ;STOR NEW VALUES FOR SEQ # AND PTR
        LD HL,SEQ_MEM   ;STORE THE DISPLAYED TIME DATA IN SEQ MEM
        DEC A                   ;MAKE SEQ # 0 TO 3
        RLCA                    ;MULTIPLY SEQ # BY 4
        RLCA
        LD E,A
        LD D,0
        ADD HL,DE               ;GETS POINTER TO SEQUERCE MEMORY
        LD (CURR_PTR),HL
        JP MAIN_DISPLAY
;---------------------------
CLR_TIMR:
        LD A, 0                  ;INITIALIZE CURRENT TIMER TO ZERO
        LD IX,(CURR_PTR)
        LD (IX+0),A
        LD (IX+1),A
        LD (IX+2),A
        LD (IX+3),A
        JP MAIN_DISPLAY

ENTER_DIG: LD IX,(CURR_PTR)       ;MOVE ALL DIGITS UP ONE POSITION
        LD B,(IX+1)
        LD (IX+0),B
        LD B,(IX+2)
        LD (IX+1),B
        LD B,(IX+3)
        LD (IX+2),B
        LD (IX+3),A             ;FINALLY, SAVE NEW DIGIT
        JP MAIN_DISPLAY
UPD_MSG:               ;TAKE CONTENTS OF CURRENT (ACTIVE) TIMER
                       ;AND CREATE NEW MESSAGE (FORMAT:"#=XX.XX")
        LD HL,(CURR_PTR)  ;SCAN TIMEKEEPING BYTES
        LD DE,DIG_3
        LD B,4
UP_L1:  LD A,(HL)       ;LOOK FOR LEADING ZEROS
        CP 0
        JP NZ,NO_DASH
        LD A,02         ;REPLACE LEADING ZEROS WITH DASHES
        LD (DE),A
        INC HL
        INC DE
        DEC B
        JP NZ,UP_L1
        JP UP_C1
UP_L2:  LD A,(HL)       ;CONVERT REMAINING DIGITS TO 7 SEG CODES
NO_DASH: CALL GET7SEG
        LD (DE),A
        INC DE
        INC HL
        DEC B
        JP NZ,UP_L2
UP_C1:
        LD A,(DIG_4)    ;TURN ON DEC.PT
        SET 6,A
        LD (DIG_4),A
        LD A,82H        ;PUT "=" IN 2ND DIGIT
        LD (DIG_2),A
        LD A,(CURR_SEQ) ;PUT SEQ # IN FIRST DIGIT
        CALL GET7SEG
        LD (DIG_1),A
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

START_TIMR:             ;THE MAIN TIMING SOFTWARE
        LD A,1          ;START AT TMR # 1
        LD (CURR_SEQ),A
        LD HL,SEQ_MEM
        LD (CURR_PTR),HL

CHK4ZERO:LD HL,(CURR_PTR)   ;CHK FOR ALL ZEROS
        LD B,4
C4Z_L1: LD A,(HL)
        CP 0
        JP NZ, ST_C1
        INC HL
        DEC B
        JP NZ, C4Z_L1
        JP ST_END       ;MUST BE ZEROS, DONE
ST_C1:  CALL UPD_MSG    ;PREP DISPLAY

        LD A,(CURR_SEQ) ;TURN ON APPLIANCE
        LD C,1
ST_L2:  DEC A           ;XFORMS SEQ# TO 1 OF 4 CODE
        JP Z, ST_C2
        SLA C
        JP ST_L2
ST_C2:  LD A,C          ;TURN ON APPLIANCE
        OUT (0C0H),A

        LD B,100        ;FOR 1 SEC DELAY
TMRLOOP: CALL SCAN
        CP STOP_KEY
        JP Z,MAIN_DISPLAY       ;RETURN TO MAIN
        DEC B
        JP NZ, TMRLOOP
        LD HL,2
        CALL TONE               ;PROVIDE A "TICKING"SOUND
DECTIM:                         ;1 SEC. HAS PASSED, DECREMENT TIME COUNT
        LD HL,(CURR_PTR)        ;HL=PTR TO TIME VALUES
        LD D,0
        LD E,3
        ADD HL,DE               ;GO TO UNITS OF SECONDS

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
        LD A, 5         ;RESTART TENS OF SEC.
        LD (HL),A
        DEC HL          ;PLAY WITH UNIT OF MINS
        LD A, (HL)
        DEC A
        LD (HL),A
        CP 0FFH
        JP NZ, CHK4ZERO
        LD A, 9         ;RESTART UNITS OF MINS
        LD (HL),A
        DEC HL          ;PLAY WITH TENS OF MINS
        LD A, (HL)
        DEC A
        LD (HL),A
        CP 0FFH
        JP NZ, CHK4ZERO

ST_END:                ;DONE?, CHK IF ALL TIMERS DONE
        LD A,(CURR_SEQ)
        CP 4
        JP Z, ALL_DONE
        INC A           ;NOT DONE WITH ALL TIMERS, ADVANCE TO NEXT
        LD (CURR_SEQ),A
        LD HL,(CURR_PTR)
        LD D,0
        LD E,4
        ADD HL,DE
        LD (CURR_PTR),HL

        JP CHK4ZERO

ALL_DONE:
        LD A,0          ;TURN OFF APPLIANCE
        OUT (0C0H),A

        LD A,1          ;RESTART AT TMR # 1
        LD (CURR_SEQ),A
        LD HL,SEQ_MEM
        LD (CURR_PTR),HL

        LD HL,500
        CALL TONE       ;BEEP
        JP MAIN_DISPLAY


BACKSPACE: LD IX,(CURR_PTR)       ;MOVE ALL DIGITS DOWN ONE POSITION
        LD B,(IX+2)
        LD (IX+3),B
        LD B,(IX+1)
        LD (IX+2),B
        LD B,(IX+0)
        LD (IX+1),B
        LD A,0                  ;FINALLY, SAVE A ZERO IN MSD
        LD (IX),A
        JP MAIN_DISPLAY


        END
