CTRPRT	EQU	0C3H
PRTA	EQU	0C0H
PRTB	EQU	0C1H
PRTC	EQU	0C2H
HEXTO7	EQU	0FFAH	; check
SCAN	EQU	0FFDH	; check
DISVECT	EQU	1F1AH	; check
INTADD	EQU	1F41H	; check
;
; ------------------------------------------------------
; Main Program for Receiver. This routine simply counts.
; ------------------------------------------------------
;
	ORG 1800H
	;
	; Configure the 8255A for receiving.
	;
	LD A,10011000B
	OUT (CTRPRT),A
	;
	; Initialize CODE, the ISR address, and interrupts.
	;
	LD A,00H
	LD (CODE),A
	LD DE,1A00H
	LD (INTADD),DE
	IM 1
	EI
	;
	; Initialize LED display.
	;
	LD A,00H
	LD HL,DISVECT
	LD B,3
LOOP1:	LD (HL),A
	DJNZ LOOP1
	;
	; Initialize DE register pair.
	;
	LD DE,0000H
	;
	; Show DE on the LED display.
	;
AGAIN:	LD HL,DISVECT
	LD (HL),D
	INC HL
	LD (HL),E
	CALL HEXTO7
	CALL SCAN
	;
	; Increment DE and go back to display it.
	;
	INC DE
	JP AGAIN
;
; --------------------
; Transmitter Program.
; --------------------
;
	ORG 1900H
;
; -------------------------------------------
; Interrupt Service Routine for the Receiver.
; -------------------------------------------
;
	ORG	1A00H
ISR:	PUSH AF
	PUSH HL
	;
	; Get CODE. If CODE=3 then skip down.
	; Otherwise we are dealing with the header bytes.
	;
	LD A,(CODE)
	CP 03H
	JP Z,DATA
	;
	; Increment CODE.
	;
	INC A
	LD (CODE),A
	;
	; Adjust a pointer to point to the parameter
	; about to be received. CODE can be used as
	; an index.
	;
	DEC A
	LD HL,1A80H
	ADD A,L
	LD L,A
	;
	; Get the byte and store it. Then finish up.
	;
	CALL GET
	LD (HL),A
	JP FINISH
	;
	; Get the data byte and store it.
	;
DATA:	CALL GET
	LD HL,(PTLOW)
	LD (HL),A
	;
	; Adjust counter and pointer.
	; If counter<>0 then finish up.
	;
	INC HL
	LD (PTLOW),HL
	LD A,(COUNT)
	DEC A
	LD (COUNT),A
	JP NZ,FINISH
	;
	; If counter=0 then reset CODE before finishing up.
	;
	LD A,00H
	LD (CODE),A
	;
	; Restore registers, enable interrupts and return.
	;
FINISH:	POP HL
	POP AF
	EI
	RET
	;
	; Define local parameters.
	;
CODE:	DB	00H
PTLOW:	DB	00H
PTHIGH:	DB	00H
COUNT:	DB	00H
;
;
;
; -------------------------------------------------------------
; Subroutine GET handles the handshaking protocol for Receiver.
; -------------------------------------------------------------
;
GET:	PUSH BC
	;
	; Read the byte and stash it somewhere safe.
	;
	IN A,(PRTA)
	LD B,A
	;
	; Make ACK active (low).
	;
	LD A,00H
	OUT (PRTB),A
	;
	; Wait for OBF to become inactive (high).
	;
WAIT1:	IN A,(PRTC)
	BIT 4,A
	JP Z,WAIT1
	;
	; Make ACK inactive (high).
	;
	LD A,0FFH
	OUT (PRTB),A
	;
	; Get the data byte from its safe place and return.
	;
	LD A,B
	POP BC
	RET
	;
	END
