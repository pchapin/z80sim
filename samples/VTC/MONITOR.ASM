;***********************************************************
;
; Monitor Program for the CAMI trainer.
;            Version 1.0
;                by:
;
; Charles Barker
; Matt Bilodeau
; Peter Chapin
; Bill Dodson
; Bob Howard
; Ted Lewis
; Don Martin
; Scott McClure
; Tom Ryan
; Ken Vandermark
; Peter Young
; Rodney Young
;
; Spring 1987
;
;***********************************************************
;
; The following equates define the memory map for the monitor.
;
MONBOT  EQU     0100H           ; Program on pages 21H - 2FH.
MONTOP  EQU     0800H
MONVAR  EQU     1F00H           ; Monitor variables on page 1FH.
;
; The following equates are for the keyboard/display 8255A.
;
MATRIX  EQU     00H
SGCODE  EQU     01H
SKSCAN  EQU     02H
IOCNTL  EQU     03H
;
; The following equates are for the Z80 CTC.
;
CTC0    EQU     40H
CTC1    EQU     41H
CTC2    EQU     42H
CTC3    EQU     43H
RODNEY  EQU     MONVAR+256-8    ; Address of CTC ISR address
                                ; table.
;
; The following are the variables used by the monitor.
;
VERNUM  EQU     MONVAR+0        ; Version number.
MODE    EQU     MONVAR+1        ; bit 0: M/U, bit 1: A/D.
MADDR   EQU     MONVAR+2        ; These four locations hold 7
                                ;   segment codes for the
                                ;   address display while in
                                ;   monitor mode.
MDATA   EQU     MONVAR+6        ; These locations hold 7 seg
                                ;   for monitor data.
UADDR   EQU     MONVAR+8        ; These locations hold 7 seg
                                ;   for address display while
                                ;   in user mode.
UDATA   EQU     MONVAR+12       ; These locations hold 7 seg
                                ;   for user data.
VADDR   EQU     MONVAR+14       ; 16 bit view address.
USERA   EQU     MONVAR+16       ; These locations hold the user
USERF   EQU     MONVAR+17       ;   registers while in monitor
USERB   EQU     MONVAR+18       ;   mode.
USERC   EQU     MONVAR+19       ;   .
USERD   EQU     MONVAR+20       ;   .
USERE   EQU     MONVAR+21       ;   .
USERH   EQU     MONVAR+22       ;   .
USERL   EQU     MONVAR+23       ;   .
USERAP  EQU     MONVAR+24       ;   .
USERFP  EQU     MONVAR+25       ;   .
USERBP  EQU     MONVAR+26       ;   .
USERCP  EQU     MONVAR+27       ;   .
USERDP  EQU     MONVAR+28       ;   .
USEREP  EQU     MONVAR+29       ;   .
USERHP  EQU     MONVAR+30       ;   .
USERLP  EQU     MONVAR+31       ;   .
USERIX  EQU     MONVAR+32       ;   .
USERIY  EQU     MONVAR+34       ;   .
TCHPER  EQU     MONVAR+36       ; Pitch constant for TONE.
MPXTB   EQU     MONVAR+37       ; Multiplex table for display
                                ;   (see RSCAN). The table is
                                ;   6 bytes.
KYCODE  EQU     MONVAR+43       ; Used by RSCAN to hold hard
                                ;   keycode. 0=no key pressed.
;
;***********************************************************
;***********************************************************
;
; What follows defines all RST entry points.
;
        ORG     0000H
        JP      START
;
        ORG     0008H
        JP      UINIT
;
        ORG     0010H
        JP      UINIT
;
        ORG     0018H
        JP      UINIT
;
        ORG     0020H
        JP      UINIT
;
        ORG     0028H
        JP      UINIT
;
        ORG     0030H
        JP      UINIT
;
        ORG     0038H
        JP      UINIT
;
; What follows defines the NMI interrupt entry point.
;
        ORG     0066H
        JP      UINIT
;
; **********************************************************
; **********************************************************
;
        ORG     MONBOT
;
;       The following initialization is done only after
;       a cold start or reset.
;
START:  LD      SP,MONVAR       ; Initialize SP
;
        LD      A,00H           ; Zero out system variable area.
        LD      B,00H           ;   256 bytes are zeroed.
        LD      HL,MONVAR
ZERO:   LD      (HL),A
        INC     HL
        DJNZ    ZERO
;
        LD      HL,STORE        ; Copy system vars out of cold
        LD      DE,MONVAR       ;   storage and into RAM.
        LD      BC,FREE-STORE
        LDIR
;
;       LD      A,90H           ; Configure 8255A for display.
;       OUT     (IOCNTL),A
;
        LD      HL,RSCAN        ; Load ISR address into table.
        LD      (RODNEY),HL
        LD      A,HIGH(RODNEY)  ; Set up mode 2 ISR handling.
        LD      I,A
        LD      A,LOW(RODNEY)
        OUT     (CTC0),A
        LD      A,0A5H          ; Program CTC as timer.
        OUT     (CTC0),A
        LD      A,02AH          ; Time for 6 mS.
        OUT     (CTC0),A
        IM      2               ; Start interrupts.
        EI
        JP      CINIT
;
;       The following initialization is done only
;       when returning from a user program.
;
UINIT:  CALL    SAVREG          ; Save user registers.
        CALL    UDONE           ; Display done message.
;
;       The following initiailization is done both
;       after a startup and after returning from
;       a user program.
;
CINIT:  LD      IX,MONVAR       ; Point to variables.
        SET     0,(IX+1)        ; Go to monitor mode.
        RES     1,(IX+1)        ; Go to data accept mode.
        LD      BC,1800H        ; Set view address to 1800.
        LD      (VADDR),BC
;
;
; !!!!!!!!!!!!!!!!!! The Main Program !!!!!!!!!!!!!!!!!!!!!
;
;
MAIN:   LD      BC,(VADDR)      ; Get view address.
        CALL    ADDDSP          ; Display view address.
        LD      A,(BC)          ; Display data at the view add.
        CALL    DATDSP
        CALL    DOTS            ; Turn on the dots.
;
        CALL    GETKEY          ; Get a key press from the user.
;
DATKEY: CP      14H             ; Is it the Data key?
        JP      NZ,ADDKEY
        RES     1,(IX+1)        ; If yes, go to data mode.
        JP      MAIN
;
ADDKEY: CP      19H             ; Is it the Address key?
        JP      NZ,PLSKEY
        SET     1,(IX+1)        ; If yes, go to address mode.
        JP      MAIN
;
PLSKEY: CP      10H             ; Is it the Plus key?
        JP      NZ,MINKEY
        LD      BC,(VADDR)      ; Increment the view address.
        INC     BC
        LD      (VADDR),BC
        JP      MAIN
;
MINKEY: CP      11H             ; Is it the Minus key?
        JP      NZ,GOKEY
        LD      BC,(VADDR)      ; Decrement the view address.
        DEC     BC
        LD      (VADDR),BC
        JP      MAIN
;
GOKEY:  CP      12H             ; Is it the go key?
        JP      NZ,REGKEY
        LD      HL,UINIT        ; Prepare stack: push ret add.
        PUSH    HL
        LD      HL,(VADDR)      ; Push user routine add.
        PUSH    HL
        RES     0,(IX+1)        ; Go to user mode.
        CALL    GETREG          ; Get user registers.
        RET                     ; Go to user routine.
;
;       The REGKEY section is due to Don Martin & Ted Lewis
;
REGKEY: CP      1BH             ; Is it the register key?
        JP      NZ,DIGKEY
        LD      (IX+2),003H     ; Display reg-
        LD      (IX+3),08FH
        LD      (IX+4),0AFH
        LD      (IX+5),002H
        CALL    GETKEY          ; Get keypress.
AFREG:  CP      00H             ; Is it the AF register?
        JP      NZ,BCREG
        LD      A,(USERA)       ; Get user's AF & put it into
        LD      B,A             ;  BC.
        LD      A,(USERF)
        LD      C,A
        CALL    ADDDSP          ; Display it.
        LD      (IX+6),03FH     ; Display 'AF'
        LD      (IX+7),00FH
        CALL    GETKEY          ; Wait for keypress.
BCREG:  CP      01H             ; Is it the BC register?
        JP      NZ,DEREG
        LD      A,(USERB)
        LD      B,A
        LD      A,(USERC)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),0A7H
        LD      (IX+7),08DH
        CALL    GETKEY
DEREG:  CP      02H             ; Is it the DE register?
        JP      NZ,HLREG
        LD      A,(USERD)
        LD      B,A
        LD      A,(USERE)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),0B3H
        LD      (IX+7),08FH
        CALL    GETKEY
HLREG:  CP      03H             ; Is it the HL register?
        JP      NZ,IXREG
        LD      A,(USERH)
        LD      B,A
        LD      A,(USERL)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),037H
        LD      (IX+7),085H
        CALL    GETKEY
IXREG:  CP      08H             ; Is it the IX register?
        JP      NZ,IYREG
        LD      BC,(USERIX)
        CALL    ADDDSP
        LD      (IX+6),030H
        LD      (IX+7),020H
        CALL    GETKEY
IYREG:  CP      09H             ; Is it the IY register?
        JP      NZ,AFPREG
        LD      BC,(USERIY)
        CALL    ADDDSP
        LD      (IX+6),030H
        LD      (IX+7),0B6H
        CALL    GETKEY
AFPREG: CP      04H             ; Is it the AF' register?
        JP      NZ,BCPREG
        LD      A,(USERAP)
        LD      B,A
        LD      A,(USERFP)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),03FH
        LD      (IX+7),04FH
        CALL    GETKEY
BCPREG: CP      05H             ; Is it the BC' register?
        JP      NZ,DEPREG
        LD      A,(USERBP)
        LD      B,A
        LD      A,(USERCP)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),0A7H
        LD      (IX+7),0CDH
        CALL    GETKEY
DEPREG: CP      06H             ; Is it the DE' register?
        JP      NZ,HLPREG
        LD      A,(USERDP)
        LD      B,A
        LD      A,(USEREP)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),0B3H
        LD      (IX+7),0CFH
        CALL    GETKEY
HLPREG: CP      07H             ; Is it the HL' register?
        JP      NZ,AFREG        ; If no, go back and try others.
        LD      A,(USERHP)
        LD      B,A
        LD      A,(USERLP)
        LD      C,A
        CALL    ADDDSP
        LD      (IX+6),037H
        LD      (IX+7),0C5H
        CALL    GETKEY
;
DIGKEY: CP      10H             ; Is it one of the digit keys?
        JP      NC,ERROR
        BIT     1,(IX+1)        ; Which mode?
        JP      NZ,AMODE
        CALL    DATIN           ; If data accept mode ...
        JP      MAIN
AMODE:  CALL    ADDIN           ; If address accept mode ...
        JP      MAIN
;
ERROR:  LD      HL,250          ; Bad key was pressed.
        CALL    TONE            ; Do double beep.
        LD      HL,50
        CALL    DELAY
        LD      HL,50
        CALL    TONE
        JP      MAIN
;
;
; !!!!!!!!!!!!!!!!! The Subroutines !!!!!!!!!!!!!!!!!!!!
;
;
; ****************************
; * This routine looks up the seven segment codes for the
; * number in the BC register pair and writes them into
; * the appropriate area in memory to display in the address
; * field.
; *     ENTRY: BC contains number to be displayed.
; *     EXIT : No registers changed.
; *
; * by Rodney Young & Ken Vandermark
; ****************************
;
_ADDDS: PUSH    AF              ; SAVE THE REGISTERS FROM
        PUSH    BC              ; PREVIOUS COMPUTATIONS
        PUSH    DE              ; ONTO THE STACK
        PUSH    HL              ;
        PUSH    IX              ;
        LD      IX,MADDR        ; LOAD INTO IX ADDRESS STARTING
                                ; LOCATION
        LD      D,C             ; LOAD D WITH LOW BYTE FOR DIS.
        CALL    DSPCON          ; GET SUB. TO PLACE LOW BYTE
        LD      D,B             ; LOAD D WITH HIGH BYTE FOR DIS.
        CALL    DSPCON          ; GET SUB. TO PLACE HIGH BYTE
        POP     IX              ; RETURN THE REGISTERS FROM
        POP     HL              ; THE STACK
        POP     DE
        POP     BC
        POP     AF
        RET                     ; RETURN TO MAIN PROGRAM
DSPCON: LD      A,D             ; LOAD A WITH BYTE TO WORK
        AND     0FH             ; MASK TO GET RID OF HIGH NIB.
        CALL    HEXTO7          ; CHANGE LOW NIBBLE TO HEX
        DEC     IX              ; DEC IX FOR PROPER ADDRESS
        LD      (IX+04H),A      ; PUT HEX INTO PROPER ADDRESS
        LD      A,D             ; LOAD A WITH BYTE TO WORK
        SRL     A               ; SHIFT RIGHT 4 TIMES TO GET RID
        SRL     A               ; OF LOW NIBBLE
        SRL     A
        SRL     A
        CALL    HEXTO7          ; CHANGE HIGH NIBBLE TO HEX
        DEC     IX              ; DEC IX FOR PROPER ADDRESS
        LD      (IX+04H),A      ; PUT HEX INTO PROPER ADDRESS
        RET
;
; ****************************
; * This routine looks up the seven segment codes for the
; * number in the accumulator. It writes them to the appropriate
; * place in memory so that they will be displayed in the data
; * field.
; *
; *     ENTRY: A contains the number to be displayed.
; *     EXIT : No registers changed.
; *
; * by Rodney Young & Ken Vandermark
; ****************************
;
_DATDS: PUSH    AF              ; SAVE THE REGISTERS FROM
        PUSH    BC              ; PREVIOUS COMPUTATIONS
        PUSH    DE              ; ONTO THE STACK
        PUSH    HL
        PUSH    IX
        LD      D,A
        LD      IX,MADDR        ; LOAD INTO IX ADDR. STARTING
                                ; LOCATION
        INC     IX              ; INCREMENT IX TWICE TO GET TO
        INC     IX              ; PROPER MEMORY ADDR.
        CALL    DSPCON          ; GET SUB. TO PLACE HIGH BYTE
        POP     IX              ; RETURN THE REGISTERS FROM
        POP     HL              ; THE STACK
        POP     DE
        POP     BC
        POP     AF
        RET
;
; ****************************
; * This routine controls the dots in the address display area.
; *
; *     ENTRY: If A=1, the dots are turned on.
; *            Otherwise they are turned off.
; *     EXIT : No registers changed.
; *
; * by Peter Chapin
; ****************************
;
ADDDOT: CP      01H                     ; On or off?
        JP      Z,TURNON
        RES     6,(IX+2)                ; A=0 so turn off bit 6.
        RES     6,(IX+3)
        RES     6,(IX+4)
        RES     6,(IX+5)
        JP      ALLDON
TURNON: SET     6,(IX+2)                ; A=1 so turn on bit 6.
        SET     6,(IX+3)
        SET     6,(IX+4)
        SET     6,(IX+5)
ALLDON: RET
;
; ****************************
; * This routine controls the dots in the data display area.
; *
; *     ENTRY: If A=1, the dots are turned on.
; *            If A=0, the dots are turned off.
; *     EXIT : No registers changed.
; *
; * by: Matt Bilodeau
; ****************************
;
DATDOT: PUSH    AF              ; Saves AF reg pair.
        CP      1               ; Compares Acc with 1.
        JP      NZ,DOTOFF       ; If C=1 then goto dotoff.
        LD      A,(IX+6)        ; Loads low mode word into A.
        OR      40H             ; Masks word for bit 6.
        LD      (IX+6),A        ; Restores mode word.
        LD      A,(IX+7)        ; Loads high mode word into A.
        OR      40H             ; Masks word for bit 6.
        LD      (IX+7),A        ; Restores high mode word.
        JP      NN              ; Jumps to end.
DOTOFF: LD      A,(IX+6)        ; Loads low mode word into A.
        AND     0BFH            ; Masks for bit 6.
        LD      (IX+6),A        ; Restores low mode word.
        LD      A,(IX+7)        ; Loads high mode word.
        AND     0BFH            ; Masks for bit 6.
        LD      (IX+7),A        ; Restores high mode word.
NN:     POP     AF              ; Restores AF
        RET
;
; ****************************
; * This routine loads all the registers except the
; * stack pointer from the user register holding area.
; *
; *     ENTRY: No conditions.
; *     EXIT : Registers become the user registers.
; ****************************
;
GETREG: LD      L,(IX+31)               ; Get user primed regs.
        LD      H,(IX+30)
        LD      E,(IX+29)
        LD      D,(IX+28)
        LD      C,(IX+25)               ; Get user F'.
        PUSH    BC
        POP     AF
        LD      C,(IX+27)
        LD      B,(IX+26)
        LD      A,(IX+24)
        EXX                             ; Swap into position.
        EX      AF,AF'
        LD      L,(IX+23)               ; Get user regs.
        LD      H,(IX+22)
        LD      E,(IX+21)
        LD      D,(IX+20)
        LD      C,(IX+17)               ; Get user flags.
        PUSH    BC
        POP     AF
        LD      C,(IX+19)
        LD      B,(IX+18)
        LD      A,(IX+16)
        LD      IY,(USERIY)             ; Get user index regs.
        LD      IX,(USERIX)
        RET
;
; ****************************
; * This routine copies all the registers except the
; * stack pointer into the user register holding area.
; *
; *     ENTRY: No conditions.
; *     EXIT : No registers changed.
; ****************************
;
SAVREG: LD      (USERIX),IX             ; Save user index regs.
        LD      (USERIY),IY
        LD      IX,MONVAR               ; Point to monitor vars.
        LD      (IX+16),A               ; Save user regs.
        LD      (IX+18),B
        LD      (IX+19),C
        PUSH    AF                      ; Save user flag reg.
        POP     BC
        LD      (IX+17),C
        LD      (IX+20),D
        LD      (IX+21),E
        LD      (IX+22),H
        LD      (IX+23),L
        EX      AF,AF'                  ; Get user primed regs.
        EXX
        LD      (IX+24),A               ; Save them.
        LD      (IX+26),B
        LD      (IX+27),C
        PUSH    AF                      ; Save user F'.
        POP     BC
        LD      (IX+25),C
        LD      (IX+28),D
        LD      (IX+29),E
        LD      (IX+30),H
        LD      (IX+31),L
        RET
;
; ****************************
; * This routine finds the seven segment codes for the one
; * nibble number in the accumulator.
; *
; *     ENTRY: Number in accumulator.
; *     EXIT : Seven segment code in the accumulator. If the
; *            number was greater than 0FH, the seven seg code
; *            is for a dash.
; *
; * by Bill Dodson & Bob Howard
; ****************************
;
_HEXTO: PUSH    HL              ; Save the contents of HL.
        CP      10H             ; Check if value is valid.
        JP      NC,DASH
        LD      HL,TABLE        ; Load table location.
        ADD     A,L             ; Add what's in A to low byte.
        LD      L,A
        LD      A,00H           ; Reset A to 00H.
        ADC     A,H             ; Add w/ c to high byte.
        LD      H,A             ; Adjust table pointer.
        LD      A,(HL)          ; Load A with seven seg code.
        JP      FINI2
DASH:   LD      A,02H           ; Load A with value for dash.
FINI2:  POP     HL
        RET
;
; ****************************
; * This is a table of seven segment codes which is
; * used by HEXTO7. There is one entry for each hex digit.
; *
; * by Scott McClure & Peter Young
; ****************************
;
TABLE:  DB      0BDH,030H,09BH,0BAH
        DB      036H,0AEH,0AFH,038H
        DB      0BFH,03EH,03FH,0A7H
        DB      08DH,0B3H,08FH,00FH
;
; ****************************
; * This routine inserts one nibble of data into the view
; * address. The least significant byte is shifted over to the
; * most significant position.
; *
; *     ENTRY: Accumulator contains the nibble to be inserted.
; *     EXIT : No registers changed.
; *
; * by Charles Barker & Tom Ryan
; ****************************
;
ADDIN:  PUSH    HL              ; Saves registers.
        PUSH    BC
        LD      HL,(VADDR)      ; Loads previous value.
        LD      B,04H           ; Loads counter value.
SHIFT:  SLA     L               ; Performs the shift.
        RL      H
        DJNZ    SHIFT
        ADD     A,L             ; Adds new value.
        LD      L,A
        LD      (VADDR),HL      ; Replaces view address.
        POP     BC              ; Retrieves original
        POP     HL              ; register values
        RET
;
; ****************************
; * This routine inserts one nibble of data into the memory
; * location with address VADDR. The least significant byte is
; * shifted over to the most significant position.
; *
; *     ENTRY: Accumulator contains the nibble to be inserted.
; *     EXIT : No registers changed.
; *
; * by: Ted Lewis & Don Martin
; ****************************
;
DATIN:  PUSH    AF              ; Pushed onto stack to save.
        PUSH    HL              ; Pushed onto stack to save.
        PUSH    BC              ; Pushed onto stack to save.
        LD      HL,(VADDR)      ; Loads HL with address @ VADDR.
        LD      B,(HL)          ; Loads data in HL into B.
        SLA     B               ; Shifts data one bit left.
        SLA     B               ; Shifts data one bit left.
        SLA     B               ; Shifts data one bit left.
        SLA     B               ; Shifts data one bit left.
        ADD     A,B             ; Puts data in correct order.
        LD      (HL),A          ; Puts data in location HL.
        POP     BC              ; Popped off stack.
        POP     HL              ; Popped off stack.
        POP     AF              ; Popped off stack.
        RET
;
; ****************************
; * This routine waits until the user presses a key.
; * It returns with a soft keycode in the accumulator.
; ****************************
;
_GETKY: PUSH    BC              ; Save registers.
        PUSH    DE
        PUSH    HL
;
        LD      B,04H           ; Wait for KYCODE to be zero
WAIT1:  LD      A,01H           ;  for at least four passes of
        LD      (KYCODE),A      ;  RSCAN. This will insure that
TEST1:  LD      A,(KYCODE)      ;  No key is being pressed be-
        OR      A               ;  fore going on.
        JP      NZ,TEST1
        DJNZ    WAIT1
;
        LD      B,04H           ; Wait for KYCODE to be non-
WAIT2:  LD      A,(KYCODE)      ;  zero for at least four
        OR      A               ;  passes of RSCAN. This will
        JP      Z,WAIT2         ;  insure full debouncing of
        DJNZ    WAIT2           ;  the keys.
;
        DEC     A               ; Hard key code min = 0.
;
        LD      D,00H           ; Add hard key code to table
        LD      E,A             ;  base address and look up
        LD      HL,KEYTBL       ;  soft key code.
        ADD     HL,DE
        LD      A,(HL)
;
        POP     HL              ; Restore registers.
        POP     DE
        POP     BC
        RET
;
KEYTBL: DB      015H,011H,014H,010H     ; Table to translate
        DB      016H,01CH,01AH,018H     ; hard key codes to
        DB      01BH,019H,017H,01DH     ; soft key codes.
        DB      000H,004H,008H,00CH
        DB      012H,01EH,001H,005H
        DB      009H,00DH,013H,01FH
        DB      002H,006H,00AH,00EH
        DB      000H,000H,003H,007H
        DB      00BH,00FH
;
; ****************************
; * The following routine beeps, displays the message
; * "donE", and waits so that the user can read the
; * message.
; *
; *     ENTRY: No conditions.
; *     EXIT : No registers changed.
; ****************************
;
UDONE:  PUSH    HL
        LD      HL,00FAH                ; Beep.
        CALL    TONE
        LD      (IX+2),0B3H             ; Display "donE".
        LD      (IX+3),0A3H
        LD      (IX+4),023H
        LD      (IX+5),08FH
        LD      (IX+6),000H             ; Blank out data field.
        LD      (IX+7),000H
        LD      HL,0200H                ; Wait.
        CALL    DELAY
        POP     HL
        RET
;
; ****************************
; * The following routine insures that the dots
; * in the display are turned on correctly. It
; * checks the A/D bit in MODE to determin which
; * set of dots should be active.
; *
; *      ENTRY: No conditions.
; *      EXIT : No registers changed.
; ****************************
;
DOTS:   PUSH    AF
        BIT     1,(IX+1)        ; Which mode?
        JP      Z,DATAM
        LD      A,01H           ; If address accept mode,
        CALL    ADDDOT          ; turn on address display dots &
        LD      A,00H           ; turn off data display dots.
        CALL    DATDOT
        JP      FINI
DATAM:  LD      A,00H           ; If data accept mode,
        CALL    ADDDOT          ; turn off address disp dots &
        LD      A,01H           ; turn on data display dots.
        CALL    DATDOT
FINI:   POP     AF
        RET
;
;
; ****************************
; * The following time delay routine was taken
; * from the original CAMI monitor.
; *
; *     ENTRY: HL contains the number of milliseconds
; *            to delay.
; *     EXIT : No registers changed.
; ****************************
;
_DELAY: PUSH    AF              ; Save registers.
        PUSH    HL
DL1:    LD      A,126           ; 126 loops per millisecond.
DL2:    DEC     A               ; Inner loop.
        JP      NZ,DL2
        DEC     HL              ; Decrement outer loop.
        LD      A,H             ; HL=0?
        OR      L
        JP      NZ,DL1          ; Repeat until HL=0.
        POP     HL              ; Restore registers.
        POP     AF
        RET
;
; ****************************
; * The following routine to scan the keyboard and
; * display was taken from the original CAMI monitor.
; * Minor modifications were made so that it would refer
; * to the variables defined with this monitor and so that
; * it would run as an interrupt service routine.
; *
; *     ENTRY: No conditions (called as an ISR).
; *     EXIT : The hard key code of the key pressed is
; *            in KYCODE.
; ****************************
;
RSCAN:  PUSH    AF              ; Save registers.
        PUSH    BC
        PUSH    DE
        PUSH    IX
        LD      IX,MADDR        ; Point at 7 seg codes.
        XOR     A               ; Clear A,C, and KYCODE.
        LD      C,A
        LD      (KYCODE),A
;
        LD      E,06H           ; Six digits; six columns.
;
SCLP2:  LD      A,(IX+0)        ; Get 7 seg code.
        OUT     (SGCODE),A
        LD      A,(IX+35)       ; Get digit enable code.
        OUT     (SKSCAN),A
        LD      B,201           ; Dwell on digit 1.5 mS.
SCDWEL: DJNZ    SCDWEL
        XOR     A               ; Turn off all digits.
        OUT     (SGCODE),A
;
        LD      A,(IX+35)       ; Pull one column low.
        XOR     00111111B
        OUT     (SKSCAN),A
        IN      A,(MATRIX)      ; Read keyboard matrix.
        LD      D,06H           ; Six rows in keyboard matrix.
SCLP1:  INC     C               ; Advance to next key code.
        RRCA                    ; Is key pressed?
        JR      C,SCNOKY
        PUSH    AF              ; If yes, save key code.
        LD      A,C
        LD      (KYCODE),A
        POP     AF
SCNOKY: DEC     D               ; Try next key.
        JP      NZ,SCLP1
;
        LD      A,11000000B     ; Turn off column driver.
        OUT     (SKSCAN),A
        INC     IX              ; Point to next 7 seg code.
        DEC     E               ; Loop back if more.
        JP      NZ,SCLP2
;
        POP     IX              ; Restore registers.
        POP     DE
        POP     BC
        POP     AF
        EI
        RETI
;
; ****************************
; * The following tone generation routine was
; * taken from the original CAMI monitor.
; *
; *     ENTRY: HL contains the duration control,
; *            TCHPER contains the pitch control.
; *     EXIT : No registers changed.
; ****************************
;
_TONE:  DI                      ; Don't interrupt the beep.
        PUSH    AF              ; Save registers.
        PUSH    BC
        PUSH    HL
        ADD     HL,HL           ; Multiply time by 4.
        ADD     HL,HL
        LD      A,(TCHPER)      ; Get pitch constant.
        LD      C,A
TONELP: IN      A,(SKSCAN)      ; Get current port C value.
        XOR     10000000B       ; Compliment speaker bit.
        OUT     (SKSCAN),A      ; Replace port C value.
        LD      B,C
TONEDW: DJNZ    TONEDW          ; Wait for 1/2 cycle.
        DEC     HL              ; Advance loop index.
        LD      A,H             ; Is loop index zero?
        OR      L
        JR      NZ,TONELP       ; If no, repeat.
        POP     HL              ; If yes, restore reg & return.
        POP     BC
        POP     AF
        EI                      ; Resume interrupt handling.
        RET
;
;***********************************************************
;
; Cold storage for the system variables. After reset, these
; values are copied into the active variable area in RAM.
;
STORE:  DB      001H,000H,000H,000H     ; MONVAR+0
        DB      000H,000H,000H,000H     ; MONVAR+4
        DB      000H,000H,000H,000H     ; MONVAR+8
        DB      000H,000H,000H,000H     ; MONVAR+12
        DB      000H,000H,000H,000H     ; MONVAR+16
        DB      000H,000H,000H,000H     ; MONVAR+20
        DB      000H,000H,000H,000H     ; MONVAR+24
        DB      000H,000H,000H,000H     ; MONVAR+28
        DB      000H,000H,000H,000H     ; MONVAR+32
        DB      01EH,0E0H,0D0H,0C8H     ; MONVAR+36
        DB      0C4H,0C2H,0C1H,000H     ; MONVAR+40
FREE:   NOP                     ; Marks start of unused area.
;
;***********************************************************
;
        ORG     MONTOP-18
;
; Jump Table.
;
GETKEY: JP      _GETKY
DATDSP: JP      _DATDS
ADDDSP: JP      _ADDDS
HEXTO7: JP      _HEXTO
DELAY:  JP      _DELAY
TONE:   JP      _TONE
;
;***********************************************************

        END
