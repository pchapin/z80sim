;
	ORG	1800H
;
; ***********************************************************
;	The program starts off by validating that all strings
;	to be sorted are acceptable. In the process, it converts
;	all the letters to uppercase. If a string is found which
;	is not acceptable, the program halts before sorting.
; ***********************************************************
;
START:	LD	C,00H		; C=0 means strings suitable
	LD	B,40H		; 40H strings to check.
	LD	DE,1A00H	; Starting address of ptr table.
;
NXTPTR:	LD	A,(DE)		; Get a ptr from the table.
	LD	L,A
	INC	DE
	LD	A,(DE)
	LD	H,A
	INC	DE
;
	CALL	TOUPR		; Convert all letters to upper.
	CALL	ALLUPR		; Check for only upper letters.
	JP	NZ,ALLOK
	LD	C,01		; C=01 means bad string.
;
ALLOK:	DEC	B		; Do next string.
	JP	NZ,NXTPTR
;
	LD	A,C		; If bad string found, HALT.
	CP	01H
	JP	NZ,REPEAT
	HALT
;
; ***********************************************************
;	If there were no bad strings, the array of pointers
;	is sorted using the bubble sort method. Note: the actual
;	strings are not moved. Only the pointers are adjusted.
; ***********************************************************
;
REPEAT:	LD	IX,1A00H	; Initialize minor and major.
	LD	IY,1A02H
	LD	C,00H		; Switchflag = NO.
	LD	B,40H		; 40H pointers to sort.
;
LOOP:	LD	E,(IX+0)	; Are strings out of order?
	LD	D,(IX+1)
	LD	L,(IY+0)
	LD	H,(IY+1)
	CALL	STRCMP
	JP	NZ,NSWTCH
;
	LD	(IX+0),L	; If yes... switch them.
	LD	(IX+1),H
	LD	(IY+0),E
	LD	(IY+1),D
	LD	C,01H		; Switchflag = YES.
;
NSWTCH:	INC	IX		; Point at next pointers.
	INC	IX
	INC	IY
	INC	IY
	DEC	B		; Jump back if more to do.
	JP	NZ,LOOP
;
	LD	A,C		; Switchflag = YES ?
	CP	00H
	JP	NZ,REPEAT	; If so, do it again.
	HALT			; Otherwise, HALT.
;
	END
