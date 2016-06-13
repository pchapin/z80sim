CTC0	EQU	030H		; CTC channel addresses.
CTC1	EQU	031H
CTC2	EQU	032H
CTC3	EQU	033H
;
VECTBL	EQU	1C00H		; Interrupt vector table.
;
; ***********************************************************
;
	ORG	1800H
;	
INIT:	LD	SP,1F00H	; Initialize SP.
;
	LD	HL,VECTBL	; Fill all interrupt vectors
	LD	B,128		;   with the address of a 
	LD	DE,DUMMY	;   dummy ISR.
CLRTBL:	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	DEC	B
	JP	NZ,CLRTBL
;
	LD	A,HIGH(VECTBL)	; Load I register.
	LD	I,A
;
	LD	HL,ISR0		; Fill first four interrupt
	LD	(VECTBL+00),HL	;   vectors with pointers
	LD	HL,ISR1		;   to the various ISRs.
	LD	(VECTBL+02),HL
	LD	HL,ISR2
	LD	(VECTBL+04),HL
	LD	HL,ISR3
	LD	(VECTBL+06),HL
;
	IM	2		; Select interrupt mode 2.
;
	LD	A,00H		; Give CTC vector address.
	OUT	(CTC0),A
	LD	A,XX		; Program CTC.
	OUT	(CTC0),A
	LD	A,TC		; Send CTC time constant.
	OUT	(CTC0),A
;
	EI			; All is ready... turn on 
				;  the interrupts.
;
MAIN:	;	Do the main job.
	;
	;
	JP	MAIN
;
; ***********************************************************
;
ISR0:	EI	; ISR for CTC channel 0.
	RET
;
ISR1:	EI	; ISR for CTC channel 1.
	RET
;
ISR2:	EI	; ISR for CTC channel 2.
	RET
;
ISR3:	EI	; ISR for CTC channel 3.
	RET
;
DUMMY:	EI	; ISR for unhandled interrupt.
	RET
;
	END

