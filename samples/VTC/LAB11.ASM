
DELAY   EQU     0FFDh
HEXTO7  EQU     0FF1h
SCAN    EQU     0FEEh

        ORG     1800h
        JP      Start

Count:  DW      0000h

Start:
        LD      A, 80h
        OUT     (0C3h), A

        LD      A, LOW(ISR)
        LD      (1F41h), A
        LD      A, HIGH(ISR)
        LD      (1F42h), A

        LD      BC, 0000h
        LD      (Count), BC

        IM      1
        EI

Loop:
        LD      BC, (Count)
        LD      A, B
        LD      (1F12h), A
        LD      A, C
        LD      (1F13h), A
        LD      A, 00h
        LD      (1F14h), A
        CALL    HEXTO7

        CALL    SCAN

        LD      BC, (Count)
        INC     BC
        LD      (Count), BC
        JP      Loop

ISR:
        PUSH    AF
        PUSH    BC
        LD      BC, (Count)
        LD      A, B
        OUT     (0C1h), A
        LD      A, C
        OUT     (0C0h), A
        POP     BC
        POP     AF
        EI
        RET

        END

