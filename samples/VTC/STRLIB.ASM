	ORG	1C00H
; ***********************************************************
;	Jump table for the following subroutine library.
; ***********************************************************
;
STRLEN:	JP	_STRLEN		; Finds length of a string.
STRCHR:	JP	_STRCHR		; Searchs string for character.
STRCAT:	JP	_STRCAT		; Appends one string to another.
;
	ORG	1C80H
; ***********************************************************
_STRLEN:
;	Subroutine to find the length of a string.
;
;	ENTRY:	HL Points at string.
;	EXIT :	A contains length (assumed to be < 256).
;		F changed.
; ***********************************************************
;
	PUSH	BC		; Save registers.
	PUSH	HL
;
	LD	B,00H		; Count = 0.
	LD	A,00H
TRYNXT:	CP	(HL)		; Have we found null character?
	JP	Z,FNDNUL
;
	INC	B		; No... count = count+1.
	INC	HL
	JP	TRYNXT
;
FNDNUL:	LD	A,B		; Yes... copy count into A.
	POP	HL		; Restore registers.
	POP	BC
	RET
;
; ***********************************************************
_STRCHR:
;	Subroutine to find a character in a string.
;
;	ENTRY:	A contains character. HL points to the string.
;	EXIT :	HL points to character if found, otherwise HL
;		points to null character.
; ***********************************************************
;
	PUSH	AF		; Save registers.
	PUSH	BC
;
	LD	C,00H		; Set up B and C.
	LD	B,A
;
NEXT:	LD	A,C		; Is (HL) null character?
	CP	(HL)
	JP	Z,FNDIT
	LD	A,B		; No... is it search char?
	CP	(HL)
	JP	Z,FNDIT
	INC	HL		; No... try next character.
	JP	NEXT
;
FNDIT:	POP	BC		; Restore regs if time to stop.
	POP	AF
	RET
;
; ***********************************************************
_STRCAT:
;	Subroutine to append one string onto the end of another.
;
;	ENTRY:	DE points at the source string.
;		HL points at the destination string.
;	EXIT:	No registers changed.
; ***********************************************************
;
	PUSH	AF		; Save registers.
	PUSH	DE
	PUSH	HL
;
	LD	A,00H		; Is (HL) null character?
SEARCH:	CP	(HL)
	JP	Z,DOCOPY	; Yes... starting copying.
	INC	HL		; No... try next character.
	JP	SEARCH
;
DOCOPY:	LD	A,(DE)		; Move a char from (DE) to (HL).
	LD	(HL),A
	CP	00H		; Was it the null character?
	JP	Z,DONE		; Yes... all done!
	INC	DE		; No... move next character.
	INC	HL
	JP	DOCOPY
;
DONE:	POP	HL		; Restore registers.
	POP	DE
	POP	AF
	RET
;
	END
