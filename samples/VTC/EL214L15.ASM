;==============================================================
;       EL214L15.ASM
;       This file contains the software for the last EL214 lab
;       This software uses two D/A converters and an 'scope
;         to create a simple computer type video system
;==============================================================
BEAM_PORT       EQU     0C0H    ;BIT 0 CONTROLS Z AXIS OF SCOPE
DAC_PORT        EQU     0C1H    ;UPPER 4 BITS DETERMINE ROW
                                ;LOWER 4 BITS DETERMINE COLUMN
CT_PORT         EQU     0C3H    ;8255 CONTROL PORT
CT_WORD         EQU     080H    ;PORTS A & B ARE OUTPUTS
DELAY           EQU     0FFDH   ;CAMI DELAY
;MAIN PROGRAM
                ORG     1800H

INIT:           LD      A, CT_WORD      ;INITIALIZE 8255
                OUT     (CT_PORT), A
                XOR     A
                LD      (SWEEP_CTR), A  ;X-Y POSITION CONTROL

SWEEP:          LD      IX, BIT_TABLE   ;INIT POINTER AND CTR
                LD      C, 32           ;32 BYTES OF BIT PATRNS
READ_TABLE:     LD      D, (IX)         ;GET PATTERN BYTE
                LD      B, 8            ;8 Z AXIS BITS PER BYTE

PROCESS_BYTE:   LD      A, (SWEEP_CTR)  ;MOVE BEAM THEN UPDATE
                OUT     (DAC_PORT), A   ;FOR NEXT BIT-EVERY 16
                INC     A               ;BITS ROW CHANGES
                LD      (SWEEP_CTR), A
                RLC     D               ;IF BIT=1 TURN ON
                JP      NC, NOT_ON      ;Z AXIS
                LD      A, 01H          ;BIT 0 PORTA IS Z AXIS
                OUT     (BEAM_PORT), A

NOT_ON:         LD      HL, 1           ;DELAY-CAN BE REMOVED
                CALL    DELAY           ;TO REDUCE FLICKER
                XOR     A               ;TURN OFF BEAM
                OUT     (BEAM_PORT), A
                DJNZ    PROCESS_BYTE    ;LOOP FOR 8 BITS IN D

NEXT_BYTE:      INC     IX
                DEC     C
                JP      NZ, READ_TABLE  ;GET NEXT BYTE OF VIDEO
                JP      SWEEP           ;DONE 32 BYTES

SWEEP_CTR:      DEFB    00H             ;STORES SWEEP LOCATION
                                        ;BOTH X & Y

BIT_TABLE: DEFB 00000000B, 00000000B    ;DISPLAY
           DEFB 00000000B, 00000000B
           DEFB 11000011B, 11111111B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11111111B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 00011000B
           DEFB 11000011B, 11111111B
           DEFB 00000000B, 00000000B
           DEFB 00000000B, 00000000B
           DEFB 00000000B, 00000000B

           END

