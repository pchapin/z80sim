	ORG	1900H
; ***********************************************************
;
AMPM	EQU	1D00H		; Memory locations for time.
HOURS	EQU	1D01H
MINUTES	EQU	1D02H
SECONDS	EQU	1D03H
TENTHS	EQU	1D04H
;
USER	EQU	00H		; User key port.
;
DELAY	EQU	0FFDH		; CAMI routines used.
HEXTO7	EQU	0FF1H
KBRD	EQU	0FEBH
;
HEX2	EQU	1F12H		; Display vector.
HEX1	EQU	1F13H
HEX0	EQU	1F14H
ADDR3	EQU	1F1CH		; Segment vector.
ADDR2	EQU	1F1DH
ADDR1	EQU	1F1EH
ADDR0	EQU	1F1FH
DATA1	EQU	1F20H
DATA0	EQU	1F21H
;
TIME	EQU	100		; Time delay unit (mS).
AM	EQU	3FH		; AM flag (7 seg code for "A").
PM	EQU	1FH		; PM flag (7 seg code for "P").
;
; ***********************************************************
FREE:
;	The following routine implements the free run mode. It
;	keeps time in units of 1/10 second until the user
;	presses the USER key. At that point, this routine ret-
;	urns. Registers are changed.
; ***********************************************************
	LD	HL,TIME		; Delay for 100 mS.
	CALL	DELAY
;
	IN	A,(USER)	; Check user key.
	BIT	6,A
	JP	Z,EXIT
;
	LD	HL,TENTHS	; Increment tenths of second.
	CALL	INCBCD
	LD	A,(HL)
	CP	10H		; Go back if not 10 tenths.
	JP	NZ,FREE
;
	LD	(HL),00H	; Make tenths = 0.
	LD	HL,SECONDS	; Increment seconds.
	CALL	INCBCD
	LD	A,(HL)
	CP	60H		; Go back if not 60 seconds.
	JP	NZ,FREE
;
	LD	(HL),00H	; Make seconds = 0.
	LD	HL,MINUTES	; Increment minutes.
	CALL	INCBCD
	LD	A,(HL)
	CP	60H		; Go back if not 60 minutes.
	JP	NZ,FREE
;
	LD	(HL),00H	; Make minutes = 0.
	LD	HL,HOURS	; Increment hours.
	CALL	INCBCD
	LD	A,(HL)
	CP	12H		; Reached 12:00 ??
	JP	NZ,NOTGGL
;
	LD	HL,AMPM		; Yes... toggle am/pm flag.
	LD	A,(HL)
	CP	AM		; Is am/pm flag = am?
	JP	NZ,ITSPM
	LD	(HL),PM		; Yes... make it pm.
	JP	FREE
ITSPM:	LD	(HL),AM		; No... make it am (it's pm).
	JP	FREE
;
NOTGGL:	CP	13H		; Not 12:00. How about 13:00 ??
	JP	NZ,FREE		; No... go back.
	LD	(HL),01H	; Yes... Make 1:00.
	JP	FREE
;
EXIT:	RET
;
; ***********************************************************
DISPLAY:
;	The following displays the current time on the main
;	7 segment LEDs. It returns with a soft keycode in the
;	accumulator indicating which key was pressed by the
;	user. Registers are changed.
; ***********************************************************
	LD	A,(MINUTES)	; Put minutes and hours into
	LD	(HEX1),A	;   the display vector.
	LD	A,(HOURS)
	LD	(HEX2),A
	CALL	HEXTO7		; Convert to seven seg codes.
	CP	10H		; Blank MSD?
	JP	NC,NOBLNK
;
	LD	A,00H		; Yes...
	LD	(ADDR3),A
;
NOBLNK:	LD	A,00H		; Blank most sig. data digit.
	LD	(DATA1),A
	LD	A,(AMPM)	; Put 7 seg code for am or pm.
	LD	(DATA0),A
;
	CALL	KBRD		; Wait for keypress.
	RET			; Keycode in accumulator.
;
; ***********************************************************
INCBCD:
;	The following routine increments the BCD number pointed
;	at by HL. No registers are changed by the routine.
; ***********************************************************
	PUSH	AF
	LD	A,(HL)
	ADD	A,01H
	DAA
	LD	(HL),A
	POP	AF
	RET
;
	END
