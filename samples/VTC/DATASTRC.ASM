; ***********************************************************
;	The linked list structure.
; ***********************************************************
	ORG	2000H
ELEM01:	DW	ELEM02
	DB	01H
	DB	01H
;
	ORG	2324H
ELEM02:	DW	ELEM03
	DB	02H
	DB	02H
;
	ORG	21A0H
ELEM03:	DW	ELEM04
	DB	04H
	DB	03H
;
	ORG	21B0H
ELEM04:	DW	ELEM05
	DB	08H
	DB	04H
;
	ORG	2553H
ELEM05:	DW	ELEM06
	DB	10H
	DB	05H
;
	ORG	2086H
ELEM06:	DW	ELEM07
	DB	20H
	DB	06H
;
	ORG	2443H
ELEM07:	DW	ELEM08
	DB	40H
	DB	07H
;
	ORG	2AAAH
ELEM08:	DW	ELEM09
	DB	80H
	DB	08H
;
	ORG	2ABAH
ELEM09:	DW	ELEM10
	DB	81H
	DB	09H
;
	ORG	21F9H
ELEM10:	DW	ELEM11
	DB	82H
	DB	0AH
;
	ORG	2004H
ELEM11:	DW	ELEM12
	DB	84H
	DB	0BH
;
	ORG	2CC1H
ELEM12:	DW	ELEM13
	DB	88H
	DB	0CH
;
	ORG	2C00H
ELEM13:	DW	ELEM14
	DB	90H
	DB	0DH
;
	ORG	2D07H
ELEM14:	DW	ELEM15
	DB	0A0H
	DB	0EH
;
	ORG	2D20H
ELEM15:	DW	ELEM16
	DB	0C0H
	DB	0FH
;
	ORG	2D88H
ELEM16:	DW	ELEM01
	DB	00H
	DB	10H
;
; ***********************************************************
;	The byte table structure.
; ***********************************************************
	ORG	2200H
	DB	081H,042H,024H,018H
	DB	018H,024H,042H,081H
; ***********************************************************
;	The word table structure.
; ***********************************************************
	ORG	2280H
	DW	8001H,4002H
	DW	2004H,1008H
	DW	0810H,0420H
	DW	0240H,0180H
;
	END
