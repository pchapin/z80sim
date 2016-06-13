	ORG	1800H
; ***********************************************************
KSCAN:
; Subroutine to scan an external 64 key keyboard connected to
; the 8255A ports on the CAMI trainer. This routine returns the
; hard key code of the key being pressed in the accumulator. If
; no key is being pressed, the routine returns FFH to indicate
; the condition. The routine will not wait for a key press.
; ***********************************************************
;	Initialize hard key code to zero.
;	Initialize return value to FFH
;	Initialize driver byte.
;	REPEAT
;	  Send driver byte to keyboard columns.
;	  Read keyboard rows.
;	  REPEAT
;	    IF row is active.
;	      Set return code to current hard key code.
;	    ENDIF
;	    increment hard key code.
;	  UNTIL all rows are done.
;	  form next driver byte.
;	UNTIL all columns are done.
;
; ***********************************************************
;
COLS	EQU	0C0H		; Drives cols of matrix.
ROWS	EQU	0C1H		; Reads rows of matrix.
;
CCOUNT	EQU	0		; Column counter.
RCOUNT	EQU	1		; Row counter.
DRIVER	EQU	2		; Driver byte.
INBYTE	EQU	3		; Result from keyboard matrix.
HARDCD	EQU	4		; Hard key code.
RETURN	EQU	5		; Return value.
;
	PUSH	IX			; Save register.
;
	LD	IX,VARS			; Initialize variables.
	LD	(IX+HARDCD),00H
	LD	(IX+RETURN),0FFH
	LD	(IX+DRIVER),7FH
;
	LD	(IX+CCOUNT),08H		; Outer loop done x 8.
OUTER:	LD	A,(IX+DRIVER)		; Drive columns.
	OUT	(COLS),A
	IN	A,(ROWS)		; Read rows.
	LD	(IX+INBYTE),A
;
	LD	(IX+RCOUNT),08H		; Inner loop done x 8.
INNER:	SRL	(IX+INBYTE)		; Is row active?
	JP	C,NOKEY			; Yes... skip.
;
	LD	A,(IX+HARDCD)		; No... set return code.
	LD	(IX+RETURN),A
;
NOKEY:	INC	(IX+HARDCD)		; Next hard code.
	DEC	(IX+RCOUNT)		; Next row.
	JP	NZ,INNER
;
	SCF				; Adjust driver byte.
	RR	(IX+DRIVER)
	DEC	(IX+CCOUNT)		; Next column.
	JP	NZ,OUTER
;
	LD	A,(IX+RETURN)		; Return result in A.
	POP	IX			; Restore register.
	RET
;
VARS:	DS	6
;
	END
