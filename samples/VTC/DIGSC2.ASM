;-----------------------------------------------------------
;	
;	Advanced Digital Storage Program (EL 214, Lab 9)
;
;				(St.Denis; 10/27/86)
;				(Prog. Name: DIGSC2.ASM)
;-----------------------------------------------------------

	ORG 1900H

ADCPORT	EQU 40H		;DEFINE ALL THE PORTS
DACPORT	EQU 0E0H
USERPRT	EQU 00H
PORTA	EQU 0C0H
PORTB	EQU 0C1H
CTRLPRT	EQU 0C3H

TABPNTR	EQU 1B00H	;DATA TABLE POINTER, STORES START'G ADDR
TABLEN	EQU 1B02H	;ADDR. FOR STORING THE LENGTH OF TABLE

TONEDLY	EQU 1000	;ONE SECOND TONE 
TONE	EQU 0FFAH	;ADDRESS OF TONE SUBROUTINE
SAMPDLY	EQU 10		;DELAY BETW'N SAMPLES IN AQUISIT'N MODE
DEBDLY	EQU 10		;DEBOUNCE DELAY
DELAY	EQU 0FFDH	;ADDRESS OF UNIVERSAL TIME DELAY

;-----------------------------------------------------------
; Register  Useage:
;	A: general, inputs, outputs
;	B: down counter, table length
;	C: not used
;	DE: pointer to the data table
;	HL: to pass values into DELAY and TONE subroutines
;
; CAMI Port Useage:
;	PORTA (C0H): lsb used as sweep trigger
;	USERPRT (00H): bit 6 is connected to USER key
;	ADCPORT (40H): the A to D converter; requires an output
;			to start conversion, wait a while, then
;			input the result
;	DACPORT (E0H): the D to A converter
;
; CAMI Memory Useage:
;	1800-?   : the main program with new subroutines
;	1A00-1AXX: the data table (the length is set by the
;			value at 1B00)
;	1B00	 : the value here is the starting address of
;			the data table (dafault = 1A00H)
;	1B02	 : the value here determines the length of the 
;			data table (default = 200 )
:-----------------------------------------------------------

INIT:	LD A,200	;SET THE DEFAULT TABLE LENGTH
	LD (TABLEN),A
	LD DE, 1A00H	;USE THE DEFAULT TABLE
	LD (TABPNTR),DE

;-----------------------------------------------------------
; Start here if you've established you own pointers in memory.
:-----------------------------------------------------------

RERUN:	LD A,80H		;INITIALIZE PORTS A & B
	OUT (CTRLPRT),A
	
	
	LD A, 0			;CLEAR TABLE
	LD DE, (TABPNTR)
	LD A,(TABLEN)
	LD B,A
CLRNXT:	LD (DE),A
	INC DE
	DJNZ CLRNXT

;-----------------------------------------------------------
; This is the main part of the program; it continually updates
; the oscilloscope display from the table of data at TABPNTR.
;-----------------------------------------------------------

MAIN:	CALL TRIG		;CREATE A TRIGGER PULSE 

	LD DE, (TABPNTR)	;SET UP POINTERS FOR TABLE
	LD A, (TABLEN)
	LD B,A

DISPLAY: LD A,(DE)
	OUT (DACPORT),A
	INC DE
	DJNZ DISPLAY

	IN A,(USERPRT)		;CHECK "USER" KEY
	AND 01000000B		;MASK ALL BUT BIT 6
	CALL Z, AQUIRE
	JR MAIN

;-----------------------------------------------------------
; This is the data aquisition part of the program: it is called
; when the user key is pressed.
; A tone is sounded at the start and end of the sampling and
; readings are taken every 10 millseconds. The data accumulated
; is stored in the table at TABPNTR and will be displayed by the
; main part of the program above.
;-----------------------------------------------------------

AQUIRE:	PUSH HL
	PUSH DE
	PUSH BC
	PUSH AF

DEBNCE:	LD HL,DEBDLY	  	;COMPLETELY DEBOUNCE THE SWITCH
	CALL DELAY
	IN A,(USERPRT)
	AND 01000000B
	RET NZ

	LD HL, TONEDLY		;SIGNALS START OF SAMPLING
	CALL TONE
	CALL TRIG		;ACTIVATE THE SCOPE TRIGGER

	LD DE, (TABPNTR)	;INITIALIZE POINTERS AND
	LD A, (TABLEN)		;COUNTERS
	LD B,A
	LD HL, SAMPDLY

GETNXT:	OUT (ADCPORT),A		;ACTIVATES ADC
	CALL DELAY		;WAIT FOR CONVERSION
	IN A,(ADCPORT)
	LD (DE),A		;STORE DATA IN TABLE
	OUT (DACPORT),A		;OUTPUT DATA TO DAC
	INC DE
	DJNZ GETNXT

ENDAQU:	LD HL,TONEDLY		;SOUND A TONE TO SIGNAL END
	CALL TONE

	POP AF
	POP BC
	POP DE
	POP HL
	RET

;-----------------------------------------------------------
; This subroutine toggles the lsb of PORTA to trigger the
; scope.
;-----------------------------------------------------------

TRIG:	PUSH AF

	IN A,(PORTA)		;CREATE A TRIGGER FOR THE SWEEP
	XOR 00000001B		;TOGGLE THE LSB
	OUT (PORTA),A
	XOR 00000001B		;TOGGLE LSB AGAIN
	OUT (PORTA),A

	POP AF
	RET

	END
