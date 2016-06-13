;	Program to drive the video display.
;
ZAXIS	EQU	0D0H	; Port address of D flip flop.
XAXIS	EQU	0F0H	; Port address of X D/A.
YAXIS	EQU	0E0H	; Port address of Y D/A.
NROWS	EQU	16	; Number of rows on display.
NCOLS	EQU	32	; Number of columns in display.
VIDRAM	EQU	1C00H	; Address of character array.
NULL	EQU	00H	; Null character.
CURSOR	EQU	47H	; ASCII code of cursor character.
NEWLIN	EQU	0AH	; Newline character.
;
; The following equates are for the keyboard/display 8255A.
;
MATRIX	EQU	00H
SGCODE	EQU	01H
SKSCAN	EQU	02H
IOCNTL	EQU	03H
;
;
	ORG	1800H
	;
	JP	START
;
BEAMX:	DB	00H	; X coordinate of beam
BEAMY:	DB	00H	; Y coordinate of beam
OLDX:	DB	00H	; X coordinate of left edge of char.
CROW:	DB	00H	; Row number of cursor.
CCOL:	DB	00H	; Col number of cursor.
;
;	ASCII 30 = '0'
;
CHAROM:	DB	00H,00H,3CH,7EH
	DB	66H,66H,66H,6EH
	DB	76H,66H,66H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 31 = '1'
;
	DB	00H,00H,18H,18H
	DB	38H,38H,18H,18H
	DB	18H,18H,18H,18H
	DB	7EH,7EH,00H,00H
;
;	ASCII 32 = '2'
;
	DB	00H,00H,3CH,7EH
	DB	66H,66H,0CH,0CH
	DB	18H,18H,30H,30H
	DB	7EH,7EH,00H,00H
;
;	ASCII 33 = '3'
;
	DB	00H,00H,7EH,7EH
	DB	0CH,0CH,18H,18H
	DB	0CH,0CH,66H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 34 = '4'
;
	DB	00H,00H,0CH,0CH
	DB	1CH,1CH,3CH,3CH
	DB	6CH,6CH,7EH,7EH
	DB	0CH,0CH,00H,00H
;
;	ASCII 35 = '5'
;
	DB	00H,00H,7EH,7EH
	DB	60H,60H,7CH,7EH
	DB	06H,06H,06H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 36 = '6'
;
	DB	00H,00H,1CH,3CH
	DB	70H,60H,60H,7CH
	DB	7EH,66H,66H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 37 = '7'
;
	DB	00H,00H,7EH,7EH
	DB	06H,06H,0CH,0CH
	DB	18H,18H,30H,30H
	DB	30H,30H,00H,00H
;
;	ASCII 38 = '8'
;
	DB	00H,00H,3CH,7EH
	DB	66H,66H,3CH,3CH
	DB	66H,66H,66H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 39 = '9'
;
	DB	00H,00H,3CH,7EH
	DB	66H,66H,7EH,3EH
	DB	06H,06H,06H,07H
	DB	3CH,38H,00H,00H
;
;	ASCII 3A = ':'
;
	DB	00H,00H,00H,00H
	DB	18H,18H,18H,18H
	DB	00H,00H,18H,18H
	DB	18H,18H,00H,00H
;
;	ASCII 3B = ';'
;
	DB	00H,00H,00H,00H
	DB	18H,18H,18H,18H
	DB	00H,00H,18H,18H
	DB	18H,18H,30H,20H
;
;	ASCII 3C = '<'
;
	DB	00H,00H,00H,07H
	DB	0EH,1CH,38H,70H
	DB	38H,1CH,0EH,07H
	DB	00H,00H,00H,00H
;
;	ASCII 3D = '='
;
	DB	00H,00H,00H,00H
	DB	7EH,7EH,00H,00H
	DB	7EH,7EH,00H,00H
	DB	00H,00H,00H,00H
;
;	ASCII 3E = '>'
;
	DB	000H,000H,000H,0E0H
	DB	070H,038H,01CH,00EH
	DB	01CH,038H,070H,0E0H
	DB	000H,000H,000H,000H
;
;	ASCII 3F = '?'
;
	DB	00H,00H,3CH,7EH
	DB	66H,66H,0CH,0CH
	DB	18H,18H,18H,00H
	DB	18H,18H,00H,00H
;
;	ASCII 40 = '@'
;
	DB	00H,00H,1CH,3EH
	DB	73H,61H,6DH,6BH
	DB	6BH,6EH,60H,71H
	DB	3FH,1EH,00H,00H
;
;	ASCII 41 = 'A'
;
	DB	00H,00H,18H,3CH
	DB	7EH,66H,66H,66H
	DB	7EH,7EH,66H,66H
	DB	66H,66H,00H,00H
;
;	ASCII 42 = 'B'
;
	DB	00H,00H,7CH,7EH
	DB	66H,66H,7EH,7CH
	DB	66H,66H,66H,66H
	DB	7CH,7EH,00H,00H
;
;	ASCII 43 = 'C'
;
	DB	00H,00H,3CH,7EH
	DB	66H,66H,60H,60H
	DB	60H,60H,66H,66H
	DB	7EH,3CH,00H,00H
;
;	ASCII 44 = 'D'
;
	DB	00H,00H,78H,7CH
	DB	6EH,66H,66H,66H
	DB	66H,66H,66H,6EH
	DB	7CH,78H,00H,00H
;
;	ASCII 45 = 'E'
;
	DB	00H,00H,7EH,7EH
	DB	60H,60H,7CH,7CH
	DB	60H,60H,60H,60H
	DB	7EH,7EH,00H,00H
;
;	ASCII 46 = 'F'
;
	DB	00H,00H,7EH,7EH
	DB	60H,60H,7CH,7CH
	DB	60H,60H,60H,60H
	DB	60H,60H,00H,00H
;
;	Cursor character = ASCII 47H
;
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,000H,000H
	DB	000H,000H,0FFH,0FFH
;
START:
;	Initialization.
;	The following fills the first column of each row in
;	video RAM with a zero byte. Thus each row is erased.
;	The cursor is then postioned in the upper left hand
;	corner of the array.
;
	LD	HL,VIDRAM	; Init HL and DE.
	LD	D,00H
	LD	E,NCOLS
	LD	B,NROWS		; For each row.
AGAIN:	LD	(HL),NULL
	ADD	HL,DE
	DJNZ	AGAIN		; Next row.
;
	LD	A,00H		; Row & Col of cursor.
	LD	(CROW),A
	LD	(CCOL),A
	CALL	CURON		; Turn cursor on.
;
ALWAYS:
;	The beginning of the main loop.
;	The following major block of code refreshes the screen.
;	Register usage:
;		B	current row number (0 to NROWS-1)
;		C	current col number (0 to NCOLS-1)
;		DE	stratch pad
;		HL	pointer
;
	LD	B,00H		; Initialize row counter.
NXTROW:	LD	C,00H		; Initialize col counter.
;
;	While (character(row,col) is not null)
;
WHILE:
	CALL	VPTR		; Calculate pointer into array.
	LD	A,(HL)		; Look up character.
	CP	NULL		; If NULL, skip inner loop.
	JP	Z,ONWARD
;
;	Point at the codes for the character in the char ROM.
;
	SUB	30H		; Subtract ASCII offset
	LD	E,A		; 16 bit version
	LD	D,00H
	SLA	E		; Multiply by 16: 16 bytes
	RL	D		;   per character in CHAROM.
	SLA	E
	RL	D
	SLA	E
	RL	D
	SLA	E
	RL	D
	LD	HL,CHAROM
	ADD	HL,DE		; Address of codes in CHAROM.
;
;	Position beam to the upper left corner of the character.
;
	LD	A,C		; Column number in A.
	SLA	A		; Multiply by 8.
	SLA	A
	SLA	A
	LD	(BEAMX),A	; Save in BEAMX & tell D/A.
	OUT	(XAXIS),A
;
	LD	E,B		; Row number in B.
	SLA	E		; Multiply by 16.
	SLA	E
	SLA	E
	SLA	E
	LD	A,0FFH		; Form FF-16*row_number
	SUB	E
	LD	(BEAMY),A	; Save in BEAMY & tell D/A.
	OUT	(YAXIS),A
;
;	Draw a char at the postion and with codes specified.
;
	CALL	DCHAR
;
;	Consider the next column and jump back to see if NULL.
;
	INC	C
	JP	WHILE
;
ONWARD:
;
;	The while loop has finished. This means that a null
;	character has been found in the current row. Go to the
;	next row.
;
	INC	B
	LD	A,B
	CP	NROWS
	JP	C,NXTROW
;
;	If we get here then all rows have been done.
;	Scan the keyboard. If no key is being pressed,
;	then jump back and refresh the screen.
;
	CALL	KSCAN
	CP	NULL
	JP	Z,ALWAYS
;
;	A key is being pressed.
;	If it's the newline key, advance cursor to the beginning
;	of the next line and jump back to refresh the screen.
;
	CP	NEWLIN		; Character is newline?
	JP	NZ,INCHAR	; No, goto next section.
	CALL	CUROFF		; Yes, turn off cursor.
	LD	A,00H		; Make cursor column = 0.
	LD	(CCOL),A
	LD	A,(CROW)	; Increment cursor row.
	INC	A
	CP	NROWS		; Cursor off screen?
	JP	C,OK
	CALL	SCROLL		; Yes, scroll screen.
	DEC	A
OK:	LD	(CROW),A	; Update cursor row number.
	CALL	CURON		; Turn on cursor.
;
	JP	ALWAYS		; Refresh screen.
;
;	A key is being pressed but it is not the newline key.
;	The following code puts the ASCII code of the key
;	into the array at the location specified by the cursor.
;	The cursor column position is then incremented.
;
INCHAR:	LD	E,A		; Save character in E.
	LD	A,(CROW)	; Cursor row & col into BC.
	LD	B,A
	LD	A,(CCOL)
	LD	C,A
	CALL	VPTR		; Pointer into array.
	LD	(HL),E		; Save character in array.
	INC	A		; Increment CCOL.
	LD	(CCOL),A
	CALL	CURON		; Turn on cursor.
;
	JP	ALWAYS		; Refresh screen.
;
; 	********************************
;
;	Draw_Character:
;		This routine will actually draw a character on
;	the screen. It assumes that the beam has already been
;	positioned and that the x and y coordinates of the beam
;	are in BEAMX and BEAMY. Furthermore, it assumes that a
;	pointer to the appropriate character codes resides in
;	HL.
;		This routine returns nothing. All registers are
;	unchanged except for the pointer in HL. This routine
;	insures that the beam is off before returning.
;		This routine maintains one byte of memory for
;	the variable OLDX. OLDX contains the x coordinate of the
;	beam when it is on the left edge of the character.
;
DCHAR:	PUSH	AF
	PUSH	BC
	PUSH	DE
;
	LD	A,(BEAMX)	; Save initial x coord of beam.
	LD	(OLDX),A
	LD	C,16		; 16 bytes of char code.
NXTBYT:	LD	A,(HL)		; Get a byte.
	CPL			; Invert its bits.
	LD	B,8		; 8 bits in a byte.
NXTBIT:	OUT	(ZAXIS),A	; Send MSB.
	RLCA			; Shift new bit into position.
	LD	E,A		; Save.
	LD	A,(BEAMX)	; Increment beam x coord.
	INC	A
	LD	(BEAMX),A
	OUT	(XAXIS),A
	LD	A,E		; Restore.
	DJNZ	NXTBIT
	LD	A,80H		; Shut off beam.
	OUT	(ZAXIS),A
	LD	A,(OLDX)	; Restore beam initial x coord.
	LD	(BEAMX),A
	OUT	(XAXIS),A
	LD	A,(BEAMY)	; Decrement beam y coord.
	DEC	A
	LD	(BEAMY),A
	OUT	(YAXIS),A
	INC	HL		; Point to next code in charrom.
	DEC	C
	JP	NZ,NXTBYT
;
	POP	DE
	POP	BC
	POP	AF
	RET
;
;
;	Curon:
;	This routine turns the cursor on. Using the data in the
;	memory locations CROW and CCOL it replaces the character
;	at that row and column with the cursor character and
;	insures that the next character is NULL.
;
CURON:
	PUSH	AF
	PUSH	BC
	PUSH	HL
;
	LD	A,(CROW)	; Row, Col into BC
	LD	B,A
	LD	A,(CCOL)
	LD	C,A
	CALL	VPTR		; Pointer into array.
	LD	(HL),CURSOR	; Cursor char into array.
	INC	HL
	LD	(HL),NULL	; Null char at next char.
;
	POP	HL
	POP	BC
	POP	AF
	RET
;
;	Curoff:
;	This routine turns the cursor off. It replaces the
;	cursor with a null character to properly terminate the
;	line.
;
CUROFF:
	PUSH	AF
	PUSH	BC
	PUSH	HL
;
	LD	A,(CROW)	; Row, Col into BC
	LD	B,A
	LD	A,(CCOL)
	LD	C,A
	CALL	VPTR		; Pointer into array.
	LD	(HL),NULL	; Null into array.
;
	POP	HL
	POP	BC
	POP	AF
	RET
;
;	Vptr:
;	This routine calculates a pointer into the character
;	array. The row number is assumed to be in B while the
;	the column number is assumed to be in C. This routine
;	returns the pointer in HL.
;
VPTR:
	PUSH	DE
	LD	E,B		; 16 bit row number.
	LD	D,00H
	SLA	E		; Multiply row number by 32.
	RL	D		;   Strictly this should be
	SLA	E		;   done with a subroutine
	RL	D		;   call using the defined
	SLA	E		;   symbol NROWS. However,
	RL	D		;   in interest of efficiency
	SLA	E		;   I will make use of the
	RL	D		;   fact that NROWS = 32.
	SLA	E
	RL	D
	LD	HL,VIDRAM	; Add 32*row_number to base.
	ADD	HL,DE
	LD	E,C		; 16 bit column number.
	LD	D,00H
	ADD	HL,DE		; Add in for final result.
	POP	DE
	RET
;
;	Scroll:
;	This routine scrolls the screen up one line. It leaves a
;	blank line at the bottom of the screen. This routine
;	changes no registers.
;
SCROLL:
	PUSH	AF
	PUSH	BC
	PUSH	DE
	PUSH	HL
;
	LD	BC,NCOLS*(NROWS-1)		; Counter.
	LD	HL,VIDRAM+NCOLS			; Source pointer
	LD	DE,VIDRAM			; Dest pointer
	LDIR
	LD	HL,VIDRAM+NCOLS*(NROWS-1)	; Bottom row
	LD	(HL),NULL
;
	POP	HL
	POP	DE
	POP	BC
	POP	AF
	RET
;
;	Kscan:
;	This routine scans the key board and returns the ASCII
;	code of the key being pressed in the accumulator. If no
;	key is pressed, it will return a NULL.
;	This routine will not wait for a key.
;	This routine changes no registers.
;
KSCAN:	PUSH	BC		; Save registers.
	PUSH	DE
	PUSH	HL
;
	IN	A,(MATRIX)	; Is USER key being pushed?
	BIT	6,A
	JP	NZ,NOUSER	; No, do more.
	LD	A,NEWLIN	; Yes, return newline character.
	JP	FINI
;
NOUSER:	CALL	SCAN		; Scan keyboard.
	LD	A,(KYCODE)	; Get hard keycode.
	CP	00H		; If null, return.
	JP	Z,FINI
	LD	E,A		; 16 bit version.
	LD	D,00H
	LD	HL,KEYTBL	; Add in base address.
	ADD	HL,DE
	LD	A,(HL)		; Look up ASCII.
;
FINI:	POP	HL		; Restore registers.
	POP	DE
	POP	BC
	RET
;
KEYTBL:	DB	03AH,03BH,03CH,03DH	; Table to translate
	DB	000H,000H,000H,000H	; hard key codes to
	DB	000H,000H,000H,000H	; soft key codes.
	DB	030H,034H,038H,043H
	DB	000H,000H,031H,035H
	DB	039H,044H,000H,000H
	DB	032H,036H,041H,045H
	DB	000H,000H,033H,037H
	DB	042H,046H
;
; ****************************
; * The following routine to scan the keyboard and
; * display was taken from the original CAMI monitor.
; *
; *	ENTRY: No conditions.
; *	EXIT : The hard key code of the key pressed is
; *            in KYCODE.
; ****************************
;
SCAN:	PUSH	AF		; Save registers.
	PUSH	BC
	PUSH	DE
	PUSH	IX
;
	XOR	A		; Clear A,C, and KYCODE.
	LD	C,A
	LD	(KYCODE),A
	LD	IX,MPXTB	; Point at multiplex table.
;
	LD	E,06H		; Six columns.
SCLP2:	LD	A,(IX)		; Pull one column low.
	XOR	00111111B
	OUT	(SKSCAN),A
	IN	A,(MATRIX)	; Read keyboard matrix.
	LD	D,06H		; Six rows in keyboard matrix.
SCLP1:	INC	C		; Advance to next key code.
	RRCA			; Is key pressed?
	JR	C,SCNOKY
	PUSH	AF		; If yes, save key code.
	LD	A,C
	LD	(KYCODE),A
	POP	AF
SCNOKY:	DEC	D		; Try next key.
	JP	NZ,SCLP1
;
	LD	A,11000000B	; Turn off column driver.
	OUT	(SKSCAN),A
	INC	IX		; Point to next entry in table.
	DEC	E		; Loop back if more.
	JP	NZ,SCLP2
;
	POP	IX
	POP	DE
	POP	BC
	POP	AF
	RET
;
MPXTB:	DB	0E0H,0D0H,0C8H,0C4H
	DB	0C2H,0C1H
KYCODE:	DB	000H
;
	END
