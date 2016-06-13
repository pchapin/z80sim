;=============================================================
; Lab12.asm
;
; This program solves the problem presented in EL-214 Lab #12.
; Written by Peter Chapin; November 16, 1989.
;=============================================================

;=================================
;	Equates Section
;=================================

PORT_A		EQU	0c0h	; Nice names for 8255A ports.
PORT_B		EQU	0c1h
PORT_C		EQU	0c2h
CNTRL_PORT	EQU	0c3h

PORT_CONFIG	EQU	080h	; Configuration byte for 8255A.

CTC_0		EQU	040h	; Nice names for CTC ports.
CTC_1		EQU	041h
CTC_2		EQU	042h
CTC_3		EQU	043h

TC_MIN		EQU	10		; Don't allow time constants less than this.
TC_MAX		EQU	256-TC_MIN	; Don't allow time constants greater than this.

CTC_CONTROL	EQU	10000111b	; Int, Timer, /16, auto trig, TC follows, reset.
CTC_TC_INIT	EQU	TC_MIN		; Initial time constant.

VECTOR_TABLE	EQU	1d00h	; Interrupt vector table specifics.
VECTOR_NUMBER	EQU	00h

SCAN		EQU	0feeh	; Nice names for SCAN, etc.
PLUS_KEY	EQU	04h
MINUS_KEY	EQU	02h
ZERO_KEY	EQU	0dh
ONE_KEY		EQU	13h
TWO_KEY		EQU	19h
THREE_KEY	EQU	1fh
FOUR_KEY	EQU	0eh

FF_ENABLED	EQU	0	; Marks flip flop as active.
FF_DISABLED	EQU	1
FF_OFF		EQU	0	; Marks flip flop as clear.
FF_ON		EQU	1

;=====================================
;	Program Entry Point
;=====================================

	ORG	1800h
	jp	init			; Hop over data.

;==============================
;	Data Section
;==============================

TC_on:		db	CTC_TC_INIT	; Start off with this speed.
ff_state:	db	00h		; Initial state doesn't matter.
ff_active:	db	00h		; Initial activity doesn't matter.

;==============================
;	Code Section
;==============================

init:
	; Configure 8255A
	ld	a, PORT_CONFIG
	out	(CNTRL_PORT), a

	; Initialize flip flop records and synchronize with hardware.
	call	turn_ff_off
	call	turn_ff_on

	; Initialize interrupt vector table.
	ld	a, HIGH(VECTOR_TABLE)
	ld	i,a
	ld	hl, isr
	ld	(VECTOR_TABLE+VECTOR_NUMBER), hl

	; Program CTC.
	ld	a, VECTOR_NUMBER
	out	(CTC_0), a
	ld	a, CTC_CONTROL
	out	(CTC_0), a
	ld	a, CTC_TC_INIT
	out	(CTC_0), a

	; Prepare for interrupts.
	im	2
	ei

main_loop:
	; Is the user pressing a key? Check each key and handle it.
	call	SCAN
	cp	PLUS_KEY
	call	z, do_plus
	cp	MINUS_KEY
	call	z, do_minus
	cp	ZERO_KEY
	call	z, do_zero
	cp	ONE_KEY
	call	z, do_one
	cp	TWO_KEY
	call	z, do_two
	cp	THREE_KEY
	call	z, do_three
	cp	FOUR_KEY
	call	z, do_four
	jp	main_loop


turn_ff_off:
	push	af
	ld	a, 00h			; Shut off flip flop.
	out	(PORT_A), a
	ld	a, FF_DISABLED		; Tell ISR that flip flop is not being used.
	ld	(ff_active), a
	ld	a, FF_OFF		; Tell ISR that flip flop is off.
	ld	(ff_state), a
	pop	af
	ret
	
turn_ff_on:
	push	af
	ld	a, 01h			; Release flip flop.
	out	(PORT_B), a
	ld	a, FF_ENABLED		; Tell ISR that flip flop is being used.
	ld	(ff_active), a
	pop	af
	ret

do_plus:
	push	af
	ld	a, (TC_on)		; Get TC for on cycle.
	cp	TC_MAX			; Is it already at max?
	jp	z, ret_plus		; If yes, ignore this request.
	inc	a			; If no, boost and save it.
	ld	(TC_on), a
ret_plus:
	call	turn_ff_on
	pop	af
	ret

do_minus:
	push	af
	ld	a, (TC_on)		; Get TC for on cycle.
	cp	TC_MIN			; Is it already at min?
	jp	z, ret_minus		; If yes, ignore this request.
	dec	a			; If no, lower and save it.
	ld	(TC_on), a
ret_minus:
	pop	af
	ret

do_zero:
	push	af
	call	turn_ff_off
	ld	a, TC_MIN		; Store minimum TC for +/- key action.
	ld	(TC_on), a
	pop	af
	ret

do_one:
	push	af
	ld	a, 40h			; Store 1/4 of 256.
	ld	(TC_on), a
	call	turn_ff_on
	pop	af
	ret

do_two:
	push	af
	ld	a, 80h			; Store 2/4 of 256.
	ld	(TC_on), a
	call	turn_ff_on
	pop	af
	ret

do_three:
	push	af
	ld	a, 0c0h			; Store 3/4 of 256.
	ld	(TC_on), a
	call_turn_ff_on
	pop	af
	ret

do_four:
	push	af
	ld	a, TC_MAX		; Store 4/4 of 256 (max).
	ld	(TC_on), a
	pop	af
	ret


isr:
	push	af
	ld	a, (ff_active)		; Get flip flop use flag.
	cp	FF_ENABLED		; Is it disabled?
	jp	nz, isr_done		; Do nothing if disabled.
using_ff:
	ld	a, (ff_state)		; Get last flip flop state.
	cp	FF_ON			; Was last cycle an ON cycle?
	jp	z, was_on		; Jump if it was.
was_off:
	ld	a, CTC_CONTROL		; Load on time constant.
	out	(CTC_0), a
	ld	a, (TC_on)
	out	(CTC_0), a
	ld	a, FF_ON		; Mark flip flop as on.
	ld	(ff_state), a
	jp	isr_done
was_on:
	ld	a, CTC_CONTROL		; Load off time constant.
	out	(CTC_0), a
	ld	a, (TC_on)
	neg
	out	(CTC_0), a
	ld	a, FF_OFF		; Mark flip flop as off.
	ld	(ff_state), a
isr_done:
	pop	af
	ei
	reti

	END

