; ***********************************************************
;
;	THE SUBROUTINES!!!
;
; ***********************************************************
;	Subroutine to convert all letters
;	in a string to upper case.
;
;	ENTRY:	HL Points at string.
;	EXIT :	No registers changed.
; ***********************************************************
;
TOUPR:	PUSH	AF		; Save registers.
	PUSH	HL
;
NXT:	LD	A,00H		; WHILE (HL) is not null.
	CP	(HL)
	JP	Z,EOS
;
	LD	A,60H		; IF (HL) is lowercase letter.
	CP	(HL)
	JP	NC,ENDIF
	LD	A,7AH
	CP	(HL)
	JP	C,ENDIF
;
	LD	A,(HL)		; Make it uppercase.
	SUB	20H
	LD	(HL),A
;
ENDIF:	INC	HL		; Next character...
	JP	NXT
;
EOS:	POP	HL		; Restore registers.
	POP	AF
	RET
;
; ***********************************************************
;	Subroutine to verify that every character
;	in a string is an uppercase letter.
;
;	ENTRY:	HL points to the string.
;	EXIT :	Zflag=0 if all characters upper case letters.
;		Zflag=1 otherwise. No registers changed.
; ***********************************************************
;
ALLUPR:	PUSH	BC		; Save registers.
	PUSH	HL
	LD	C,A
;
	LD	B,00H		; Clear error flag.
;
MORE:	LD	A,00H		; WHILE (HL) is not null.
	CP	(HL)
	JP	Z,END
;
	LD	A,40H		; IF (HL) is not uppercase.
	CP	(HL)
	JP	NC,SKIP
	LD	A,5AH
	JP	NC,UPPR
;
SKIP:	LD	B,01		; Then set error flag.
;
UPPR:	INC	HL		; Next byte.
	JP	MORE
;
	LD	A,B		; Adjust zero flag.
	CP	01H
;
	LD	A,C		; Restore registers.
	POP	HL
	POP	BC
	RET
;
; ***********************************************************
;	Subroutine to compare two strings to see if they
;	are in alphabetical order or not.
;
;	ENTRY:	DE points at the "first" string.
;		HL points at the "second" string.
;	EXIT:	Zflag=0 if in order ("first", then "second").
;		Zflag=1 if out of order. No other registers
;		changed.
; ***********************************************************
;
STRCMP:	PUSH	BC		; Save registers.
	PUSH	DE
	PUSH	HL
	LD	C,A
;
	LD	B,00H		; Assume in order to start.
;
AGAIN:	LD	A,(DE)		; WHILE (DE) is not null.
	CP	00H
	JP	Z,DONE
;
	CP	(HL)		; IF (DE) > (HL)...
	JP	C,OK
	JP	Z,OK
;
	LD	B,01H		; THEN they are out of order.
;
OK:	INC	DE		; Next characters...
	INC	HL
	JP	AGAIN
;
DONE:	LD	A,B		; Set Z flag if out of order.
	CP	01H
;
	LD	A,C		; Restore registers.
	POP	HL
	POP	DE
	POP	BC
	RET
;
	END
