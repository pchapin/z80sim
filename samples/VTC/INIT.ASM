;*********************************************************
;	Below is a realistic example of the initialization
;	code that might be executed by a Z-80 system. This
;	code is burned into a ROM. Note: The Z-80 is going
;	to use interrupt mode 2.
;*********************************************************
;
ROMSTART	EQU	00000H	; 4K ROM
ROMEND		EQU	00FFFH
RAMSTART	EQU	08000H	; 8K RAM
RAMEND		EQU	09FFFH
STKBOT		EQU	0A000H	; 256 bytes for stack.
STKTOP		EQU	09F00H
VECTBL		EQU	09E00H	; Table of ISR addresses.
;
CTC0		EQU	030H	; CTC channel addresses.
CTC1		EQU	031H
CTC2		EQU	032H
CTC3		EQU	033H
;
CTC_CONFIG0	EQU	00H	; Configuration bytes for CTC.
CTC_CONFIG1	EQU	00H
CTC_CONFIG2	EQU	00H
CTC_CONFIG3	EQU	00H
CTC_TC0		EQU	00H	; Time constants for CTC.
CTC_TC1		EQU	00H
CTC_TC2		EQU	00H
CTC_TC3		EQU	00H
;
; ***********************************************************
;
	ORG	0000H		; Cold start entry point.
	JP	INIT
;=============================================================
;	All RST entry points are defined below. They load A
;	with the associated RST number and CALL a routine
;	to handle the situation. Note: No RST entry points are
;	used during normal operation.
;=============================================================
	ORG	0008H
	PUSH	AF
	LD	A,08H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0010H
	PUSH	AF
	LD	A,10H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0018H
	PUSH	AF
	LD	A,18H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0020H
	PUSH	AF
	LD	A,20H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0028H
	PUSH	AF
	LD	A,28H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0030H
	PUSH	AF
	LD	A,30H
	CALL	RST_ERROR
	POP	AF
	RET

	ORG	0038H
	PUSH	AF
	LD	A,38H
	CALL	RST_ERROR
	POP	AF
	RET

;========================================================
;	What follows defines the non-maskable interrupt
;	entry point. Normally, the non-maskable interrupt
;	would be defined -- even when mode 2 ints are
;	being used.
;========================================================
	ORG	0066H
	JP	NMI_INT

;=======================================================
;	What follows is the ROM version of the interrupt
;	vector table. This table is copied out of ROM
;	when the processor makes a cold start.
;=======================================================
	ORG	0080H
;
COLD_VECTBL:

;	Vectors 00H-1EH
	DW	CTC_ISR_CH0
	DW	CTC_ISR_CH1
	DW	CTC_ISR_CH2
	DW	CTC_ISR_CH3
	DW	DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors 20H-3EH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors 40H-5EH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors 60H-7EH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors 80H-9EH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors A0H-BEH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors C0H-DEH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM

;	Vectors E0H-FEH
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
	DW	DUM, DUM, DUM, DUM, DUM, DUM, DUM, DUM
;
INIT:	LD	SP,STKBOT	; Initialize SP.
;
	LD	DE,VECTBL	; Copy interrupt vector
	LD	HL,COLD_VECTBL	;   table out of ROM.
	LD	BC,128
	LDIR
;
	LD	A,HIGH(VECTBL)	; Load I register.
	LD	I,A
;
	IM	2		; Select interrupt mode 2.
;
	LD	A,00H		; Give CTC vector address.
	OUT	(CTC0),A
	LD	A,CTC_CONFIG0	; Program CTC.
	OUT	(CTC0),A
	LD	A,CTC_TC0
	OUT	(CTC0),A
	LD	A,CTC_CONFIG1
	OUT	(CTC1),A
	LD	A,CTC_TC1
	OUT	(CTC1),A
	LD	A,CTC_CONFIG2
	OUT	(CTC2),A
	LD	A,CTC_TC2
	OUT	(CTC2),A
	LD	A,CTC_CONFIG3
	OUT	(CTC3),A
	LD	A,CTC_TC3
	OUT	(CTC3),A
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
;	--------------------------------------------
;	What follows is the routine that handles RST
;	instructions. In a real system, this routine
;	would do something useful.
;	--------------------------------------------
RST_ERROR:
	EI
	RET
;
;	------------------------------------------------------
;	What follows are the ISRs for the CTC device. These
;	routines do nothing. Of course, in a real system, they
;	would do something useful.
;	------------------------------------------------------
CTC_ISR_CH0:
	EI
	NOP
	RETI
;
CTC_ISR_CH1:
	EI
	NOP
	RETI
;
CTC_ISR_CH2:
	EI
	NOP
	RETI
;
CTC_ISR_CH3:
	EI
	NOP
	RETI
;
;	--------------------------------------
;	ISR for an unhandled mode 2 interrupt.
;	--------------------------------------
DUM:
	EI
	RETI
;
;	-----------------------------------------------
;	ISR for the non-maskable interrupt. In a real
;	system, this routine would do something useful.
;	-----------------------------------------------
NMI_INT:
	NOP
	RETN
;
;*********************************************************
	END
