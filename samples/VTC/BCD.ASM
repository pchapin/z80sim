; ***********************************************************
INCBCD:
;	This routine increments the BCD number pointed to by HL.
; ***********************************************************
	PUSH	AF		; Save register.
;
	INC	(HL)		; Increment LSD.
	LD	A,(HL)		; Get number.
	AND	0FH		; Mask for LSD.
	CP	0AH		; Is it an "A" ?
	JR	NZ,_END1	; No... all done.
;
	LD	A,(HL)		; Yes... Get fresh copy.
	AND	0F0H		; Make LSD a zero.
	ADD	A,10H		; Increment MSD.
	LD	(HL),A		; Save new number.
	CP	0A0H		; Is it an "A0" ?
	JR	NZ,_END1	; No... all done.
;
	LD	A,00H		; Yes... set number to zero.
	LD	(HL),A
;
_END1:	POP	AF		; Restore registers.
	RET
;
; ***********************************************************
DECBCD:
;	This routine decrements the BCD number pointed to by HL.
; ***********************************************************
	PUSH	AF		; Save registers.
;
	DEC	(HL)		; Decrement LSD.
	LD	A,(HL)		; Get number.
	AND	0FH		; Mask for LSD.
	CP	0FH		; Is it a "F" ?
	JR	NZ,_END2	; No... all done.
;
	LD	A,(HL)		; Yes... Get fresh copy.
	AND	0F9H		; Force LSD to "9".
	SUB	10H		; Decrement MSD.
	LD	(HL),A		; Save new number.
	CP	0F9H		; Is it "F9" ?
	JR	NZ,_END2	; No... all done.
;
	LD	A,99H		; Yes... Make number "99".
	LD	(HL),A
;
_END2:	POP	AF		; Restore registers.
	RET
;
; ***********************************************************
