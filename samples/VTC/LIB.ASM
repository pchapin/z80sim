;==================================================================
; LIB.ASM
;
;	This file contains a number of useful (?) assembly language
; routines.  These routines form the basis of an assembly  language
; library.
;==================================================================

;==============================
;	Math Functions
;==============================

;------------------------------------------------------------------
; ADD_32
;	This  routine adds two 32  bit integers which are stored in 
; memory. The integers must be stored in low byte first format. The
; current version of this routine provides no overflow indication.
;
; Entry:
;	DE points at source number. HL points at destination number.
;
; Exit:
;	HL points at sum. Source number is unchanged.  No registers
;	changed.
;------------------------------------------------------------------

ADD_32:
	PUSH	AF		; Save registers.
	PUSH	BC
	PUSH	DE
	PUSH	HL

	LD	B, 04h		; Four bytes to deal with.
	SCF			; Clear the carry flag.
	CCF

ADD_32_01:
	LD	A, (DE)		; Get byte from source.
	ADC	A, (HL)		; Add byte from destination.
	LD	(HL), A		; Save sum in destination.
	INC	DE		; Advance pointers.
	INC	HL
	DEC	B		; Any more to do?
	JP	NZ, ADD_32_01	; If yes, jump back.

	POP	HL		; Otherwise, restore registers and return.
	POP	DE
	POP	BC
	POP	AF
	RET

;=====================================
;	Searching and Sorting
;=====================================

;------------------------------------------------------------------
; BUB_SORT
;	This routine implements a bubble sorting algorithim. This 
; version sorts 8 bit unsigned numbers into ascending order only.
; P-code for the method is  shown below for reference.  Note that 
; this routine uses 4 bytes of memory following the code for data
; storage. (This could be changed to use the stack!)
;
; Entry:
;	IX points at the first byte in the block to be sorted. BC
;	contains the number of bytes in the block.
;
; Exit:
;	The block is sorted. No registers changed.
;
; Save initial counter and pointer;
; REPEAT
;   Point at first two array elements;
;   Set counter to initial value;
;   switch_flag = NO;
;   WHILE (there are more array elements to consider)
;     IF (the current two elements are out of order)
;       Switch them;
;       switch_flag = YES;
;     ENDIF
;     Advance pointers;
;   ENDWHILE
; UNTIL (switch_flag == NO);
;------------------------------------------------------------------

BUB_SORT:
	PUSH	AF			; Save registers.
	PUSH	BC
	PUSH	DE
	PUSH	IX
	PUSH	IY

	LD	(BUB_SORT_05), BC	; Save counter.
	LD	(BUB_SORT_06), IX	; Save pointer.

BUB_SORT_01:				; Top of REPEAT loop.
	LD	IX, (BUB_SORT_06)	; Get pointer.
	PUSH	IX			; Make IY point at the next array element.
	POP	IY
	INC 	IY
	LD	BC, (BUB_SORT_05)	; Get counter.
	DEC	BC			; BC = number of elements IY will deal with.
	LD	E, 00h			; =01h if a switch occurs.

BUB_SORT_02:				; Top of WHILE loop.
	LD	A, B			; Is BC == 0000 ?
	OR	C
	JP	Z, BUB_SORT_04		; Jump if yes to ENDWHILE.

	LD	A, (IY)			; (IY) < (IX) ?
	CP	(IX)
	JP	NC, BUB_SORT_03		; Jump if not, skipping the switch.
	LD	D, (IX)			; Switch (IX) and (IY).
	LD	(IX), A
	LD	(IY), D
	LD	E, 01h			; A switch has occured.

BUB_SORT_03:
	INC	IX			; Advance pointers.
	INC	IY
	JP	BUB_SORT_02		; Goto top of WHILE.

BUB_SORT_04:
	LD	A, E			; Has any switch occured?
	CP	00h
	JP	NZ, BUB_SORT_01		; Jump if yes to REPEAT.

	POP	IY			; Otherwise, done. Restore registers.
	POP	IX
	POP	DE
	POP	BC
	POP	AF
	RET

BUB_SORT_05:	DW	0000h		; Used to hold initial counter.
BUB_SORT_06:	DW	0000h		; Used to hold initial pointer.

;------------------------------------------------------------------
; TRAV_LIST
;	This routine traverses a linked list. It assumes that the
; pointer to the next node in the list is placed in the first two
; slots of the current node.  This assumption allows this routine
; to work with list without regard to the size of the node.  This
; routine assumes a zero pointer marks the end of the list.
;
; Entry:
;	A contains the node number of the node to find. A == 0
;	means the current node.  HL contains  pointer to first
;	node in the list.
;
; Exit:
;	HL contains a pointer to the desired node. HL will contain
;	0000h if the list terminates before the desired node is
;	found.
;
; WHILE (A != 0)
;   Get pointer to next node from current node.
;   IF (pointer is zero)
;     Set A = 1 (To force the loop to terminate).
;   ENDIF
;   Decrement A;
; ENDWHILE
;------------------------------------------------------------------

TRAV_LIST:
	PUSH	AF			; Save registers.
	PUSH	DE
	PUSH	HL

TRAV_LIST_01:
	CP	00h			; Is A == 00h ?
	JP	Z, TRAV_LIST_03		; Jump if so to end.
	LD	E, (HL)			; Put pointer to next into DE.
	INC	HL
	LD	D, (HL)
	PUSH	DE			; Transfer pointer to HL.
	POP	HL

	LD	D, A			; Save A in register D.
	LD	A, H			; Is HL == 0000h ?
	OR	L
	JP	NZ, TRAV_LIST_02	; Jump if not.
	LD	D, 01h			; If so, set original A to 01h.

TRAV_LIST_02:
	LD	A, D			; Restore original A.
	DEC	A			; We've traversed one link.
	JP	TRAV_LIST_01		; See if we have to do more.

TRAV_LIST_03:
	POP	HL			; Done, restore registers.
	POP	DE
	POP	AF
	RET

;==============================
;	End of Library
;==============================

	END

