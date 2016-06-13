;==============================================================================
; FLOW.ASM
;
; Peter Chapin; September 7, 1989; EL-214
;
;	This program does nothing important.
;==============================================================================

	ORG	1800h

	LD	A, 92h		; Configure 8255A for input.
	OUT	(0C3h), A
	LD	HL, 1A00h	; Point at 256 block of memory.
	LD	B, 00h		; Counter = 256.

TOP_1:
	IN	A, (0C0h)	; Get a byte.
	CP	80h		; Ignore bytes >= 80h (unsigned).
	JP	NC, TOP_1
	ADD	A, A		; Double byte.
	LD	(HL), A		; Install byte into memory.
	INC	HL		; Loop back for other bytes.
	DEC	B
	JP	NZ, TOP_1

	LD	HL, 1A00h	; Reset pointer to 256 byte block.
	IN	A, (0C1h)	; Get search byte from other port.
	LD	B, 00h		; Don't check more than 256 bytes.

TOP_2:
	CP	(HL)		; Is it this one?
	JP	Z, FOUND_IT	; If yes, jump.
	INC	HL		; Try next one.
	DEC	B
	JP	NZ, TOP_2
	CALL	ERROR		; No bytes matched the search byte.
	JP	CONTINUE	; Continue.

FOUND_IT:
	CALL	DO_STUFF	; Do stuff if a match found (HL) is match.

CONTINUE:
	HALT

	END

