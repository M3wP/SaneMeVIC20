; SaneMeVIC20 VIC20 Init/Loader
;
; Original work 2014, Daniel England
;
; PUBLIC DOMAIN.  SEE BELOW.
;
;
;-------------------------------------------------------------------------------
;
;   This is free and unencumbered software released into the public domain.
;
;   Anyone is free to copy, modify, publish, use, compile, sell, or
;   distribute this software, either in source code form or as a compiled
;   binary, for any purpose, commercial or non-commercial, and by any
;   means.
;
;   In jurisdictions that recognize copyright laws, the author or authors
;   of this software dedicate any and all copyright interest in the
;   software to the public domain. We make this dedication for the benefit
;   of the public at large and instead of and in preference to, those of our 
;   own interests, estates and holdings.  We intend this dedication to be an 
;   overt act of relinquishment in perpetuity of all present and future rights 
;   to this software under copyright law.
;   
;   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
;   IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
;   OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
;   ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
;   OTHER DEALINGS IN THE SOFTWARE.
;   
;-------------------------------------------------------------------------------
;
; 
; This program initialises the VIC20 so that it is configured the same whether
; it has the 8/16/24KB memory expansion/s attached or not.  This allows programs
; that will fit into the unexpanded VIC20 to be run on an expanded VIC20 or
; unexpanded VIC20 without modification by first executing this intialisation.
;
; The program to be run after this intialisation should be in a PRG file called 
; "MAIN".
;
; This routine should be packaged with a BASIC Boot Loader and called "INIT" in
; most cases.
;
;

*       =       $0334

BASPRST =       $CB1E
BASPEND =       $C831
BASPRUN =       $C871
BASPNEW =       $C642
KNLRESH =       $E518
KNLSTNM =       $FFBD
KNLSLFS =       $FFBA
KNLLOAD =       $FFD5
KNLCLAL =       $FFE7


MAIN    SEI                                     ; DISABLE INTERRUPTS

        PLA                                     ; REMOVE SYS CALL FROM STACK
        PLA                                     ;  THERE IS OTHER JUNK THERE BUT
                                                ;  REMOVING IT CAUSES PROBLEMS

        JSR     BASPEND                         ; END THE PROGRAM

        LDA     #$12                            ; SET BASIC START PAGE
        STA     $2C                     
        STA     $0284                   

        LDA     #$10                            ; SET SCREEN PAGE
        STA     $0288
        JSR     KNLRESH                         ; RESET THE HARDWARE

        JSR     BASPNEW                         ; CALL BASIC NEW

        LDA     #<LOADMSG                       ; PRINT THE LOADING MESSAGE
        LDY     #>LOADMSG
        JSR     BASPRST                         

        LDA     #MAINFL0-MAINFIL                ; SETUP THE FILENAME
        LDX     #<MAINFIL
        LDY     #>MAINFIL
        JSR     KNLSTNM

        LDA     #$01                            ; INIT A CHANNEL
        LDX     #$08
        LDY     #$01
        JSR     KNLSLFS

        LDA     #$00                            ; LOAD
        LDX     #$FF
        LDY     #$FF
        JSR     KNLLOAD

        STX     $2D                             ; EVEN WITH THIS, BASIC IS STILL
        STY     $2E                             ;  CONFUSED ABOUT WHERE THE 
                                                ;  PROGRAM ENDS - FIXME?

        JSR     KNLCLAL                         ; CLOSE ALL.  I DON'T KNOW IF 
                                                ;  THIS IS NECESSARY BUT SEEMS
                                                ;  WISE SOMEHOW

        CLI                                     ; ENABLE INTERRUPTS

        LDA     #$00                            ; BASIC RUN (FROM START)
        JMP     BASPRUN

        HLT                                     ; IF WE GET HERE, WE'RE DEAD

LOADMSG BYTE    $93,$1F,$0D,$0D,$0D,$0D
        BYTE    "LOADING...",$00
MAINFIL BYTE    "0:MAIN",$2C,"P",$2C,"R"        ; MAIN PROGRAM FILENAME
MAINFL0