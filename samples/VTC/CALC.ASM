KBRD	EQU	0FEBH
;
LIFT	EQU	1E00H
CLEARX	EQU	1E01H
WINDOW	EQU	1E02H
;
	ORG	2000H
; ===========================================================
;	The following program implements the 256 digit cal-
;	culator p-code. All the hard stuff is in subroutine
;	calls.
; ===========================================================
START:	CALL	CLRREG		; Clear calculator registers.
	LD	A,00H
	LD	(LIFT),A	; Clear Lift variable.
	LD	(CLEARX),A	; Clear Clearx variable.
;
;	Start of main loop.
;
REPEAT:	CALL	SETDSP		; Set up display.
	CALL	KBRD		; Get key press.
	CP	10H		; Is it a digit?
	JP	NC,PLS
	;			; Yes... Insert new digit.
	;
	;
	JP	ENDSW
;
;
PLS:	CP	10H		; Is it the + key?
	JP	NZ,MNS
	CALL	ADDXY		; Yes... do x+y.
	CALL	LOWER		; Lower calculator registers.
	LD	A,0FFH
	LD	(LIFT),A	; Set Lift.
	LD	(CLEARX),A	; Set Clearx.
	JP	ENDSW
;
;
MNS:	CP	11H		; Is it the - key?
	JP	NZ,CBR
	CALL	SUBXY		; Yes... do y-x.
	CALL	LOWER		; Lower calculator registers.
	LD	A,0FFH
	LD	(LIFT),A	; Set Lift.
	LD	(CLEARX),A	; Set Clearx.
	JP	ENDSW
;
;
CBR:	CP	1AH		; Is it the CBR key?
	JP	NZ,SBR
	CALL	MULTXY		; Yes... do x*y.
	CALL	LOWER		; Lower calculator registers.
	LD	A,0FFH
	LD	(LIFT),A	; Set Lift.
	LD	(CLEARX),A	; Set Clearx.
	JP	ENDSW
;
;
SBR:	CP	15H		; Is it the SBR key?
	JP	NZ,GO
	CALL	DIVXY		; Yes... do y/x.
	CALL	LOWER		; Lower calculator registers.
	LD	A,0FFH
	LD	(LIFT),A	; Set Lift.
	LD	(CLEARX),A	; Set Clearx.
	JP	ENDSW
;
;
GO:	CP	12H		; Is it the GO key?
	JP	NZ,MOVE
	CALL	RAISE		; Yes... lift registers.
	LD	A,00H
	LD	(LIFT),A	; Clear Lift.
	LD	A,0FFH
	LD	(CLEARX),A	; Set Clearx.
	JP	ENDSW
;
;
MOVE:	CP	1CH		; Is it the MOVE key?
	JP	NZ,INS
	;			; Yes... bump window to left.
	;
	;
	JP	ENDSW
;
;
INS:	CP	16H		; Is it the INS key?
	JP	NZ,DEL
	;			; Yes... bump window to right.
	;
	;
	JP	ENDSW
;
;
DEL:	CP	17H		; Is it the DEL key?
	JP	NZ,RELA
	LD	A,00H		; Yes... Set Window to zero.
	LD	(WINDOW),A
	JP	ENDSW
;
;
RELA:	CP	1DH		; Is it the RELA key?
	JP	NZ,ENDSW
	CALL	TOMSD		; Yes... Set Window to MSD.
	JP	ENDSW
;
;
ENDSW:	JP	REPEAT		; Handle next keypress.
;
; 	====================================================
;	!!! What follows is the definitions of the subs. !!!
; 	====================================================
;
; ***********************************************************
CLRREG:
;	This routine zeros out the calculator registers.
; ***********************************************************
	RET
;
; ***********************************************************
LOWER:
;	This routine copies the z register into the y register,
;	and the t register into the z register.
; ***********************************************************
	RET
;
; ***********************************************************
RAISE:
;	This routine copies the z register into the t register,
;	the y register into the z register, and the x register
;	into the y register.
; ***********************************************************
	RET
;
; ***********************************************************
ADDXY:
;	This routine adds the unpacked BCD number in the y
;	register to the unpacked BCD number in the x register.
;	The result is left in the x register.
; ***********************************************************
	RET
;
; ***********************************************************
SUBXY:
;	This routine subtracts the unpacked BCD number in the
;	x register from the unpacked BCD number in the y reg-
;	ister. The result is left in the x register.
; ***********************************************************
	RET
;
; ***********************************************************
MULTXY:
;	This routine multiplies the unpacked BCD number in the
;	y register with the unpacked BCD number in the x reg-
;	ister. The result is left in the x register.
; ***********************************************************
	RET
;
; ***********************************************************
DIVXY:
;	This routine divides the unpacked BCD number in the y
;	register by the unpacked BCD number in the x register.
;	The result is left in the x register.
; ***********************************************************
	RET
;
; ***********************************************************
TOMSD:
;	This routine moves WINDOW so that the MSD of the x reg-
;	ister will be on the left hand edge of the display.
; ***********************************************************
	RET
;
; ***********************************************************
SETDSP:
;	This routine puts the seven segment control bytes of
;	the digits currently displayed in the window into the
;	CAMI "segment vector" so that a call to KBRD will dis-
;	play the digits properly.
; ***********************************************************
	RET
;
	END
