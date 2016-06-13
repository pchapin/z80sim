;==============================================================
; buttons2.asm
;
; This program solves the demo problem (this is more optimized)
;==============================================================

	ORG	1800h

	LD	A, 82h		; Configure ports.
	OUT	(0C3h),A
TOP:
	IN	A, (0C1h)	; Does user want to halt?
	BIT	0, A
	JP	NZ, DONE	; If yes, jump to halt.
	BIT	1, A		; Is user pushing a button?
	JP	Z, TOP		; If no, jump.
	LD	C, 01h		; User has pushed button once.
OUTER:
	IN	A, (0C1h)	; Is user still pushing that button?
	BIT	1, A
	JP	NZ, OUTER	; Yes... wait.
	LD	HL, 20		; Nope, wait another 20 mS for debounce.
	CALL	0FFDh
	LD	B, 100		; Ready to check the button 100 times.
	LD	D, 00h		; =01h if user pushes button again.
	LD	HL, 10		; Wait 10 mS.
INNER:
	CALL	0FFDh
	IN	A, (0C1h)	; Is user pushing button again?
	BIT	1, A
	JP	Z, NO_PRESS
	LD	D, 01h		; If yes, set D = 1.
NO_PRESS:
	DEC	B		; Going to check button any more?
	JP	Z, SKIP		; Jump if no, have checked 100 times.
	LD	A, D
	CP	01h
	JP	NZ, INNER	; Jump back if user didn't push button.
SKIP:
	LD	A, D		; Did the above loop break because of push?
	CP	01h
	JP	NZ, FLASH	; No, loop must have timed out, do flashing.
	INC	C		; Yes, increment push count.
	JP	OUTER		; And jump back.
FLASH:
	LD	A, 0FFh		; Flash LEDs 1/2 sec on; 1/2 sec off.
	OUT	(0C0h), A
	LD	HL, 500
	CALL	0FFDh
	LD	A, 00h
	OUT	(0C0h), A
	CALL	0FFDh
	DEC	C		; Decrement button count.
	JP	NZ, FLASH	; Jump back if more flashing to do.
	JP	TOP		; Check halt button again.
DONE:
	HALT

	END

