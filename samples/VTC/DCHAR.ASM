;
ZAXIS	EQU	0D0H
XAXIS	EQU	0F0H
YAXIS	EQU	0E0H
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
NXTBYT:	  LD	  A,(HL)	; Get a byte.
	  CPL			; Invert its bits.
	  LD	  B,8		; 8 bits in a byte.
NXTBIT:	    OUT	    (ZAXIS),A	; Send MSB.
	    RLCA		; Shift new bit into position.
	    LD	    E,A		; Save.
	    LD	    A,(BEAMX)	; Increment beam x coord.
	    INC	    A
	    LD	    (BEAMX),A
	    OUT	    (XAXIS),A
	    LD	    A,E		; Restore.
	  DJNZ	  NXTBIT
	  LD	  A,80H		; Shut off beam.
	  OUT	  (ZAXIS),A
	  LD	  A,(OLDX)	; Restore beam initial x coord.
	  LD	  (BEAMX),A
	  OUT	  (XAXIS),A
	  LD	  A,(BEAMY)	; Decrement beam y coord.
	  DEC	  A
	  LD	  (BEAMY),A
	  OUT	  (YAXIS),A
	  INC	  HL		; Point to next code in charrom.
	DEC	C
	JP	NZ,NXTBYT
;
	POP	DE
	POP	BC
	POP	AF
	RET
;
OLDX:	DB	00H
;
;	The following memory locations were added just to test
;	the assembly of the above routine.
;
BEAMX:	DB	00H
BEAMY:	DB	00H
;
	END
