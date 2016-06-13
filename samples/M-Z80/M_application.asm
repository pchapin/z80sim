
;###########################################################################
; PROC Task_0
;
;      The following code implements....
;###########################################################################

Task_0:
        ; Print start up string.
        ld     hl, Start_Up_Message
        call   Print_String

print_prompt:
        ld      hl, Prompt
        call    Print_String

        ; Accept input from user. Here we will just take a single keystroke.
        call    Get_Char
        call    Put_Char
        jp      print_prompt

        ; Be sure task is infinite loop.
        jp      Task_0

;---------------------------------------------------------------------------
; PROC Print_String
;
; The following routine writes a null terminated string to the terminal. It does not put a CR/LF
; at the end of the string.
;
;     ENTRY:
;     HL points at the null terminated string.
;
;     EXIT:
;     No registers changed.
;---------------------------------------------------------------------------


Print_String:
        ; save registers
        push    af
        push    hl

        ; Write characters to the terminal until a null character is seen.
char_to_print:

        ld      a, (hl)
        cp      00h
        jp      z, finished_printing
        call    Put_Char
        inc     hl
        jp      char_to_print

        ; Restore registers
finished_printing:
        pop     hl
        pop     af
        ret

;###########################################################################
; PROC Task_1
;
; The following code implements...
;###########################################################################

Task_1:
        jp      Task_1

;###########################################################################
; PROC Task_2
;
; The following code implements...
;###########################################################################

Task_2:
        jp      Task_2

;###########################################################################
; PROC Task_3
;
; The following code implements...
;###########################################################################

Task_3:
        jp      Task_3

