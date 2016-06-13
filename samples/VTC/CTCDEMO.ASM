; ************************************************
;
; Lab to demonstrate the use of a Z-80 CTC.
;
; ************************************************
;
	ORG	1800H
;
	LD	A,00H		; Set up interrupt vector table.
	LD	(1A02H),A
	LD	A,19H
	LD	(1A03H),A
	LD	A,1AH
	LD	I,A
;
	LD	A,00H		; Program CTC
	OUT	(40H),A
	LD	A,35H
	OUT	(40H),A
	LD	A,0AEH
	OUT	(40H),A
	LD	A,0FDH
	OUT	(41H),A
	LD	A,40
	OUT	(40H),A
	IM	2
	EI
;
HEXTO7	EQU	0FF1H
SCAN	EQU	0FEEH
;
	LD	A,00H		; Main program.
	LD	(1F14H),A
	LD	DE,0000H
MORE:	LD	A,D
	LD	(1F12H),A
	LD	A,E
	LD	(1F13H),A
	DI
	CALL	HEXTO7
	CALL	SCAN
	EI
	INC	DE
	JP	MORE
;
	ORG	1900H
;
	PUSH	AF		; Interrupt service routine.
	LD	A,80H
	OUT	(0C3H),A
	LD	A,D
	OUT	(0C1H),A
	LD	A,E
	OUT	(0C0H),A
	POP	AF
	RETI
;
	END
