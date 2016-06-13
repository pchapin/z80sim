;====================================================================
; lab5-f89.asm
;
; This program implements a solution to the EL-214 software lab #5/6.
; This program solves the "Phase 3" problem.
; Vermont Technical College, Fall 1989.
;====================================================================

;=============================
;	General Equates
;=============================

; Nice names for useful constants.
YES		equ	1
NO		equ	0

; Nice names for special memory locations.
DISP_RAM	equ	1f1ch	; Address of RAM which defines the 7 segment display.
TONE_FREQ	equ	1f49h	; Address of TONE frequency control.

; Nice names for CAMI ROM routines.
KBRD		equ	0febh
SCAN		equ	0feeh
TONE		equ	0ffah

; Nice names for KBRD keycodes
PLUS_KEY	equ	10h
GO_KEY		equ	12h
STEP_KEY	equ	13h
MOVE_KEY	equ	1ch

; Nice names for CAMI ports
PORT_A		equ	0c0h
PORT_B		equ	0c1h
PORT_CNTRL	equ	0c3h
CONFIG_8255A	equ	82h	; PORT_A is output; PORT_B is input.

; Nice names for the various beeping constants required.
GOOD_FREQ	equ	30	; 2000 Hz
BAD_FREQ	equ	133	; 500  Hz
ERROR_FREQ	equ	133	; 500  Hz
GOOD_TIME	equ	200	; 0.2  Sec.	(Frequency dependent)
BAD_TIME	equ	250	; 1.0  Sec.     (Frequency dependent)
ERROR_TIME	equ	50	; 0.2  Sec.     (Frequency dependent)

;=================================
;	Program Entry Point
;=================================

	org	1800h
	jp	start		; Hop over the data and subroutine sections.

;==========================
;	Data Section
;==========================

;---------------------------------------------------------------
; Seven segment codes for the various messages the program uses.
;---------------------------------------------------------------

prompt_mes:	db	002h, 002h, 002h, 002h, 000h, 000h	; Prompt.
error_mes:	db	08fh, 003h, 003h, 000h, 000h, 000h	; Errors.
lrn_mes:	db	030h, 003h, 023h, 000h, 000h, 000h	; Learn mode.
bad_mes:	db	000h, 0a7h, 03fh, 0b3h, 000h, 000h	; Bad chip.

;------------------------------------------------------------------------------
; Seven segment codes for the digits 0-4. Used to make full "bad chip" message.
;------------------------------------------------------------------------------

digits:		db	0bdh, 030h, 09bh, 0bah, 036h

;-------------------------------------------------------
; Table of data applied to chips' inputs during testing.
;-------------------------------------------------------

inputs:		db	000h, 055h, 0aah, 0ffh


;--------------------------------------------------------------------------
; The following table contains information on the different chips which can
; be tested.  Each table entry  contains several fields.  The equates below
; will facilitate referencing the fields. They define the offsets into each
; table entry.
;--------------------------------------------------------------------------

SEVEN_SEG	equ	0	; 7 Seg codes for the chip's name.
OUTPUTS		equ	6	; Table of correct output data.
SHOW		equ	10	; =YES if chip to be shown in list.
NEXT		equ	11	; Pointer to next chip in list.

chip_7400:	db	038h, 036h, 0bdh, 0bdh, 000h, 000h	; SEVEN_SEG
		db	00fh, 00fh, 00fh, 000h			; OUTPUTS
		db	YES					; SHOW
		dw	chip_7408				; NEXT

chip_7408:	db	038h, 036h, 0bdh, 0bfh, 000h, 000h	; SEVEN_SEG
		db	000h, 000h, 000h, 00fh			; OUTPUTS
		db	YES					; SHOW
		dw	chip_7432				; NEXT

chip_7432	db	038h, 036h, 0bah, 09bh, 000h, 000h	; SEVEN_SEG
		db	000h, 00fh, 00fh, 00fh			; OUTPUTS
		db	YES					; SHOW
		dw	chip_udef				; NEXT

chip_udef	db	0a1h, 0b3h, 08fh, 00fh, 000h, 000h	; SEVEN_SEG
		db	000h, 000h, 000h, 000h			; OUTPUTS
		db	NO					; SHOW
		dw	chip_7400				; NEXT

;------------------------------------------------------------------------------
; Points at currently selected chip. Will be zero if no chip has been selected.
;------------------------------------------------------------------------------

current_chip:	dw	0000h

;========================================
;	Code Section (Subroutines)
;========================================

;-----------------------------------------------------------------------------
; The following routines handle the display. They have the following specs.
;
; disp_copy
;	Entry:	Ix points at 6 seven segment codes.
;	Exit :	Seven segment codes are copied into display RAM. No other
;		effect.
;
; display
;	Entry:	Ix points at 6 seven segment codes. Routine will turn on the
;		display and wait for the user to press a key.
;	Exit :	A contains KBRD keycode of key pressed. Display shut off.
;		A,F changed.
;-----------------------------------------------------------------------------

;--------------------------------> disp_copy <--------------------------------

disp_copy:
	push	af		; Save registers.
	push	bc
	push	de
	push	hl

	ld	de, DISP_RAM	; Point DE at display RAM.
	push	ix		; Point HL at source bytes.
	pop	hl
	ld	bc, 0006h	; Six bytes to move.
	ldir			; Move them.

	pop	hl		; Restore registers.
	pop	de
	pop	bc
	pop	af
	ret

;--------------------------------> display <----------------------------------

display:
	call	disp_copy	; Copy 7 segment codes into display RAM.
	call	KBRD		; Turn on display and wait.
	ret			; Return value returned by KBRD.

;-------------------------------------------------------------------------
; The following routines handle the various beeping requirements. They all
; work by loading the  appropriate frequency  constant into TONE's special
; memory location and by loading the appropriate time value into HL.  None
; of the registers are changed by any of the routines.
;-------------------------------------------------------------------------

;--------------------------------> good_beep <--------------------------------

good_beep:
	push	af
	push	hl
	ld	a, GOOD_FREQ
	ld	(TONE_FREQ), a
	ld	hl, GOOD_TIME
	call	TONE
	pop	hl
	pop	af
	ret

;--------------------------------> bad_beep <---------------------------------

bad_beep:
	push	af
	push	hl
	ld	a, BAD_FREQ
	ld	(TONE_FREQ), a
	ld	hl, BAD_TIME
	call	TONE
	pop	hl
	pop	af
	ret

;--------------------------------> error_beep <-------------------------------

error_beep:
	push	af
	push	hl
	ld	a, ERROR_FREQ
	ld	(TONE_FREQ), a
	ld	hl, ERROR_TIME
	call	TONE
	pop	hl
	pop	af
	ret

;------------------------------------------------------------------------
; The following routine deals with the case of a bad chip. It assumes:
;	Entry:	A contains bad result from chip. HL points at expected
;		result. The routine will determine which gate on the chip
;		was bad and display an appropriate message. It will then
;		wait for the user to acknowledge the message.
;	Exit :	No registers changed.
;------------------------------------------------------------------------

;--------------------------------> find_bad <--------------------------------

find_bad:
	push	af		; Save registers.
	push	de
	push	hl
	push	ix

	xor	(hl)		; Form error byte. (1 bits are bad gates).
	ld	d, 00h		; DE = 16 bit version of 1 (gate number).
	ld	e, 01h

next_gate:
	srl	a		; Look for 1 bits in error byte (LSB first).
	jp	c, found_it	; Jump if a 1 bit found.
	inc	e		; Otherwise increment gate number and try again.
	jp	next_gate	;   Note: at least 1 bad gate assumed.

found_it:
	ld	hl, digits	; Point at table of 7 seg codes for the digits.
	add	hl, de		; Calculate address of appropriate digit.
	ld	a, (hl)		; Get 7 seg code of digit.
	ld	hl, bad_mes+5	; Put it into message.
	ld	(hl), a

	call	bad_beep	; Beep speaker for bad chip.
	ld	ix, bad_mes	; Display message.
	call	display

	pop	ix		; Restore registers.
	pop	hl
	pop	de
	pop	af
	ret

;--------------------------------------------------------------------------
; The following routine performs the actual test.  It first verifies that a 
; chip has been selected.  If the chip checks out ok,  this routine handles
; the good beep, etc. If there is a problem find_bad is called to analysize
; the bad results. This routine trashes registers at will.
;--------------------------------------------------------------------------

;--------------------------------> test_chip <--------------------------------

test_chip:
	ld	hl, (current_chip)	; Get pointer to selected chip.
	ld	a, l			; Is it zero (ie none selected) ?
	or	h
	jp	nz, do_test		; Jump if not.

	call	error_beep		; No chip selected. Do error handling.
	ld	ix, error_mes		; Display message.
	call	display
	jp	abort_test		; Bag this test!

do_test:
	ld	de, OUTPUTS		; Calculate pointer to output table.
	add	hl, de
	ld	de, inputs		; Point at universal input table.
	ld	b, 04h			; Four states to consider.

next_state:
	ld	a, (de)			; Get data to send to chip & send it.
	out	(PORT_A), a
	in	a, (PORT_B)		; Get chip's response.
	cp	(hl)			; Is it right?
	jp	z, chip_ok		; If so, try next state.
	call	find_bad		; Otherwise, process bad chip and abort.
	jp	abort_test

chip_ok:
	inc	de			; Advance to next state.
	inc	hl
	djnz	next_state

	call	good_beep		; Chip must be good.

abort_test:
	ld	a, 00h			; Make sure LEDs are out.
	out	(PORT_A), a
	ret

;---------------------------------------------------------------------------
; The following routine allows the user to select a chip from the chip list.
; Only those chips for which SHOW is YES are put up for selection. Note also
; that  the chip  list is circular.  This allows the code to be simpler. The
; following routine loads "current chip"  with a pointer  to the appropriate
; chip table entry. The routine trashes registers at will.
;---------------------------------------------------------------------------

;--------------------------------> select_chip <------------------------------

select_chip:
	ld	hl, (current_chip)	; Get pointer to currently selected chip.
	ld	a, l			; Is it zero?
	or	h
	jp	nz, do_select		; Jump if not (start with current chip).

	ld	hl, chip_7400		; If this first selection, start with 7400.

do_select:
	push	hl			; Transfer pointer to ix.
	pop	ix

	ld	a, (ix+SHOW)		; Is SHOW == YES for this chip?
	cp	YES
	jp	nz, next_selection	; If not, skip down.

show_choice:
	call	display			; Display name of chip (Ix already points at 7 seg codes).
	cp	GO_KEY			; Was "go" key pressed.
	jp	z, made_selection	; Jump out of loop if so.
	cp	STEP_KEY		; Was "step" key pressed.
	jp	nz, show_choice		; Jump back if not.

next_selection:
	ld	l, (ix+NEXT)		; Load HL with pointer to next chip on list.
	ld	h, (ix+NEXT+1)
	jp	do_select		; Jump back to deal with new choice.

made_selection:
	ld	(current_chip), ix	; Load "current_chip"
	ret

;-------------------------------------------------------------------------
; The following routine "learns" about a new chip by performing a test and
; simply  loading the results into the "chip_udef" entry in the chip list.
; The routine also marks that entry as SHOWable. This routine trashes reg-
; isters at will.
;-------------------------------------------------------------------------

;--------------------------------> learn_mode <-------------------------------

learn_mode:
	ld	ix, lrn_mes		; Display "lrn" prompt and wait for GO.
	call	display
	cp	GO_KEY
	jp	nz, learn_mode

	ld	de, OUTPUTS		; Calculate pointer to output table.
	ld	hl, chip_udef
	add	hl, de
	ld	de, inputs		; Load universal input table pointer.
	ld	b, 04h

learn_next:
	ld	a, (de)			; Get a byte from input table.
	out	(PORT_A), a		; Send it to the chip.
	in	a, (PORT_B)		; Get result.
	ld	(hl), a			; Install it in output table.
	inc	de			; Adjust pointers, etc.
	inc	hl
	djnz	learn_next

	ld	ix, chip_udef		; Mark chip_udef as SHOWable.
	ld	a, YES
	ld	(ix+SHOW), a

	ret

;=========================================
;	Code Section (Main Program)
;=========================================

start:
	ld	a, CONFIG_8255A		; Set up ports.
	out	(PORT_CNTRL), a

	ld	hl, 0000h		; Make sure current_chip == NULL.
	ld	(current_chip), hl
	ld	ix, chip_udef		; Make sure user defined chip is off.
	ld	(ix+SHOW), NO

main_loop:
	ld	ix, prompt_mes		; Display the prompt.
	call	display			; Wait for user command.
	cp	GO_KEY			; Was it the "go" key?
	jp	nz, plus_key?
	call	test_chip		; If so, test the chip.
	jp	main_loop

plus_key?:
	cp	PLUS_KEY		; Was it the "+" key?
	jp	nz, move_key?
	call	select_chip		; If so, let user select a chip.
	jp	main_loop

move_key?:
	cp	MOVE_KEY		; Was it the "move" key?
	jp	nz, main_loop
	call	learn_mode		; If so, learn about the new chip.
	jp	main_loop

	END

