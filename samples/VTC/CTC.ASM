
;====================================
;           Useful Equates
;====================================

        ; Equates for interrupt handling.
IVT_START       EQU     1D00h   ; Starting address of interrupt vector table.
CTC_VECTOR_BASE EQU     00h     ; Offset into IVT for CTC vectors.
TIMER_VECTOR    EQU     CTC_VECTOR_BASE+02h     ; Timer vector.
COUNTER_VECTOR  EQU     CTC_VECTOR_BASE+04h     ; Counter vector.

        ; Equates for device port addresses.
PORT_A          EQU     0C0h    ; Port address of 8255A's first port.
PORT_B          EQU     0C1h    ; etc...
PORT_C          EQU     0C2h    ; etc...
CNTRL_PORT      EQU     0C3h    ; etc...

CTC_0           EQU     40h     ; Port address of CTC channel 0.
CTC_1           EQU     41h     ; etc...
CTC_2           EQU     42h     ; etc...
CTC_3           EQU     43h     ; etc...

;==================================
;           Main Program
;==================================

        ORG     1800h
        CALL    Set_Up_Interrupts
        CALL    Set_Up_LEDs
        CALL    Set_Up_CTC

Main_Loop:
        ; See if there is frequency overflow.
        LD      A, (Overflow)
        CP      00h
        JP      NZ, Overflow_Error

        ; Display the frequency and clear the overflow indication.
        LD      A, (Count)
        OUT     (PORT_A), A
        LD      A, 00h
        OUT     (PORT_B), A
        JP      Main_Loop

Overflow_Error:
        ; Display frequency of zero and set overflow indication.
        LD      A, 00h
        OUT     (PORT_A), A
        LD      A, 0FFh
        OUT     (PORT_B), A
        JP      Main_Loop

;=========================================
;           Support Subroutines
;=========================================

;---------------------------------------------------------------------------

Set_Up_Interrupts:
        ; Fill the interrupt vector table with pointer to Dummy_ISR.
        LD      HL, Dummy_ISR
        LD      IX, IVT_START
        LD      B, 128

Table_Init:
        LD      (IX+0), L
        LD      (IX+1), H
        INC     IX
        INC     IX
        DJNZ    Table_Init

        ; Load vector number 0 and vector number 2 with correct addresses.
        LD      HL, Timer_ISR
        LD      (IVT_START+TIMER_VECTOR), HL
        LD      HL, Counter_ISR
        LD      (IVT_START+COUNTER_VECTOR), HL

        ; Set up mode 2 interrupt handling in the Z-80.
        LD      A, HIGH(IVT_START)
        LD      I, A
        IM      2
        EI
        RET

;---------------------------------------------------------------------------

Set_Up_LEDs:
        ; Set up LEDs on left side of trainer for outputs.
        LD      A, 80h
        OUT     (CNTRL_PORT), A
        RET

;---------------------------------------------------------------------------

Set_Up_CTC:
        ; Tell CTC about interrupt vector.
        LD      A, CTC_VECTOR_BASE
        OUT     (CTC_0), A

        CALL    Reset_Timer
        CALL    Reset_Counter
        RET

;---------------------------------------------------------------------------

Reset_Timer:
        PUSH    AF

        ; Channel 0 as timer for 20 mS.
        LD      A, 00100111b    ; no Int, Timer, /256, Auto, TC next, Reset
        OUT     (CTC_0), A
        LD      A, 140          ; T = 558.7 nS gives 20.02 mS
        OUT     (CTC_0), A

        ; Channel 1 as counter to 50 counts. Wired to Ch0 yields 1 second.
        LD      A, 11000111b    ; Int, Counter, TC next, Reset
        OUT     (CTC_1), A
        LD      A, 50
        OUT     (CTC_1), A

        POP     AF
        RET

;---------------------------------------------------------------------------

Reset_Counter:
        PUSH    AF

        ; Channel 2 as counter to count incoming pulses.
        LD      A, 11000111b    ; Int, Counter, TC next, Reset
        OUT     (CTC_2), A
        LD      A, 00h          ; Try to count 256 pulses.
        OUT     (CTC_2), A

        POP     AF
        RET

;================================================
;           Interrupt Service Routines
;================================================

Dummy_ISR:
        EI
        RETI

;---------------------------------------------------------------------------

Timer_ISR:
        ; Save registers.
        PUSH    AF

        ; Get count.
        IN      A, (CTC_2)
        NEG
        LD      (Count), A

        ; Clear overflow indication.
        LD      A, 00h
        LD      (Overflow), A

        ; Set counter back to zero.
        CALL    Reset_Counter

        ; Restore registers.
        POP     AF
        EI
        RETI

;---------------------------------------------------------------------------

Counter_ISR:
        ; Save registers.
        PUSH    AF

        ; Set overflow status.
        LD      A, 01h
        LD      (Overflow), A

        ; Set timer back to zero.
        CALL    Reset_Timer

        ; Restore registers.
        POP     AF
        EI
        RETI

;=======================================
;           Data Declarations
;=======================================

Overflow        DB      00h     ; =1 if frequency overflow occured.
Count           DB      00h     ; Frequency in Hz.

        END

