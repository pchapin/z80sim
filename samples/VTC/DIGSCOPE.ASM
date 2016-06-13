;-----------------------------------------------------------
;
;	Digital Storage Program (EL 214, Lab 12)
;
;	This program uses the hardware you've built in lab 12
;	to implement a simple "digital storage scope". When the
;	"USER" key is pressed, the program uses the A to D
;	converter to sample an input voltage. It accumulates 200
;	samples, at intervals of 10 msec (two seconds total),
;	and stores them in a table in RAM. The data in this
;	table is continually outputted to the D to A converter
;	(at a higher rate), which results in a stable
;	reproduction of the original input.
;
;				(St.Denis; 10/27/86)
;-----------------------------------------------------------

	ORG 1800H

ADCPORT	EQU 40H
DACPORT	EQU 0E0H
USERPRT	EQU 00H

TABLE	EQU 1A00H
TABLEN	EQU 200

TONEDLY	EQU 1000	;ONE SEC TONE
SAMPDLY EQU 10		;10 MSEC BETWEEN SAMPLES
TONE	EQU 0FFAH
DELAY	EQU 0FFDH

;-----------------------------------------------------------
; Register  Useage:
;	A: general, inputs, outputs
;	B: down counter, table length
;	C: not used
;	DE: pointer to the data table
;	HL: to pass values into DELAY and TONE subroutines
;
; CAMI Port Useage:
;	USERPRT (00H): bit 6 is connected to USER key
;	ADCPORT (40H): the A to D converter; requires an output
;			to start conversion, wait a while, then
;			input the result
;	DACPORT (E0H): the D to A converter
;
; CAMI Memory Useage:
;	1800-?   : the main program with new subroutines
;	1A00-1AXX: the data table (the default length is 200)
:-----------------------------------------------------------


INIT:	LD A, 0		;CLEAR TABLE
	LD DE, TABLE
	LD B,TABLEN
CLRNXT:	LD (DE),A
	INC DE
	DJNZ CLRNXT


;-----------------------------------------------------------
; This is the main part of the program; it continually updates
; the oscilloscope display from the table of data at TABLE.
;-----------------------------------------------------------

MAIN:	LD DE, TABLE
	LD B, TABLEN

DISPLAY: LD A,(DE)
	OUT (DACPORT),A
	INC DE
	DJNZ DISPLAY

	IN A,(USERPRT)	;CHECK "USER" KEY
	AND 01000000B	;MASK ALL BUT BIT 6
	CALL Z, AQUIRE
	JR MAIN

;-----------------------------------------------------------
; This is the data aquisition part of the program: it is called
; when the user key is pressed.
; A tone is sounded at the start and end of the sampling and
; readings are taken every 10 millseconds. The data accumulated
; is stored in the table at TABLE and will be displayed by the
; main part of the program above.
;-----------------------------------------------------------

AQUIRE:	PUSH HL
	PUSH DE
	PUSH BC
	PUSH AF

	LD HL, TONEDLY		;SIGNALS START OF SAMPLING
	CALL TONE

	LD DE, TABLE		;INITIALIZE POINTERS AND
	LD B, TABLEN		;COUNTERS
	LD HL, SAMPDLY

GETNXT:	OUT (ADCPORT),A		;OUTPUT TO ADC TO START 
	CALL DELAY		;CONVERSION, AND WAIT A WHILE
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

	END
