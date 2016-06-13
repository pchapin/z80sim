	ORG	1800H
; ***********************************************************
START:
;	This is a solution to the searching problem.
; ***********************************************************
	LD	HL,(1000H)	; Get pointer.
	LD	C,A		; Save search number.
	LD	A,(1002H)	; Get counter and put it in B.
	LD	B,A
	LD	A,C		; Restore search number.
;
NEXT:	CP	(HL)		; Found number?
	JP	Z,FOUND		; If yes, we're done.
	INC	HL		; Try next number.
	DEC	B
	JP	NZ,NEXT
;
	LD	HL,0000H	; All numbers tried. Zero HL.
FOUND:	HALT
;
	END
