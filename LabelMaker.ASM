;***************************************
;*                                     *
;*           LABEL - MAKER             *
;*                                     *
;*            VERSION 1.0              *
;*                                     *
;*                VON                  *
;*                                     *
;*          LUTZ GROßHENNIG            *
;*                                     *
;*                                     *
;*            28.03.1989               *
;*                                     *
;***************************************

; OFFSETS EXEC

OPENLIBRARY    = -408
CLOSELIBRARY   = -414
GETMSG         = -372
ALLOCMEM       = -198
FREEMEM        = -210
ALLOCSIGNAL    = -330
FREESIGNAL     = -336
FINDTASK       = -294
DOIO           = -456
OPENDEVICE     = -444
CLOSEDEVICE    = -450
ADDPORT        = -354
REMPORT        = -360


; OFFSETS INTUITION

OPENSCREEN     = -198
CLOSESCREEN    = -066
OPENWINDOW     = -204
CLOSEWINDOW    = -072
DISPLAYALERT   = -090
SCREENTOFRONT  = -252
SCREENTOBACK   = -246
DRAWIMAGE      = -114

; OFFSETS GRAPHICS

DRAWTO         = -246
MOVETO         = -240
SETAPEN        = -342
RECTFILL       = -306
SETRGB4        = -288
PRINTTEXT      = -060

; OFFSETS DOS

OPEN           = -030
CLOSE          = -036
OUTPUT         = -048

; KONSTANTEN

EXECBASE       = 4
MOUSEBUTTON    = $BFE001
COMMAND        = 11
DESTROWS       = 0
DESTCOLS       = 0
SPECIAL        = $84
REQUEST        = 65537

 CODE

;---------  MACROS  -----------------------------------------

WRITE:MACRO *\TEXT,%\LAENGE,%\X,%\Y

       PEN_TO  \X,\Y
       LEA     \TEXT,A0
       MOVE.L  #\LAENGE,D0
       JJS     PRINTTEXT(A6)
       ENDM

OPENLIB:MACRO *\NAME,*\BASE

       MOVE.L  EXECBASE,A6
       LEA     \NAME,A1
       JSR     OPENLIBRARY(A6)
       MOVE.L  D0,\BASE
       ENDM

CLOSELI:MACRO *\BASE

       MOVE.L  EXECBASE,A6
       MOVE.L  \BASE,A1
       JSR     CLOSELIBRARY(A6)
       ENDM

OPENSCR:MACRO  *\SCREENDEVS,*\HD

       MOVE.L  INTBASE,A6
       LEA     \SCREENDEVS,A0
       JSR     OPENSCREEN(A6)
       MOVE.L  D0,\HD
       ADD.L   #44,D0
       MOVE.L  D0,VIEWPORT
       ENDM

CLOSESC:MACRO *\HD

       MOVE.L  INTBASE,A6
       MOVE.L  \HD,A0
       JSR     CLOSESCREEN(A6)
       ENDM

OPENWIN:MACRO *\WINDOWDEVS,*\HD

       MOVE.L  INTBASE,A6
       LEA     \WINDOWDEVS,A0
       JSR     OPENWINDOW(A6)
       MOVE.L  D0,\HD
       MOVE.L  D0,A0
       MOVE.L  50(A0),RASTPORT
       ENDM

CLOSEWI:MACRO *\HD

       MOVE.L  INTBASE,A6
       MOVE.L  \HD,A0
       JSR     CLOSEWINDOW(A6)
       ENDM

PEN_TO:MACRO %\X,%\Y

       MOVE.L  GFXBASE,A6
       MOVE.L  RASTPORT,A1
       MOVE.L  #\X,D0
       MOVE.L  #\Y,D1
       JSR     MOVETO(A6)
       ENDM

LINE:MACRO %\X1,%\Y1,%\X2,%\Y2

       PEN_TO  \X1,\Y1
       MOVE.L  #\X2,D0
       MOVE.L  #\Y2,D1
       JSR     DRAWTO(A6)
       ENDM

RECT:MACRO %\X1,%\Y1,%\X2,%\Y2

       LINE  \X1,\Y1,\X2,\Y1
       LINE  \X2,\Y1,\X2,\Y2
       LINE  \X2,\Y2,\X1,\Y2
       LINE  \X1,\Y2,\X1,\Y1
       ENDM

PENCOL:MACRO %\COLOR

       MOVE.L  GFXBASE,A6
       MOVE.L  RASTPORT,A1
       MOVEQ   #\COLOR,D0
       JSR     SETAPEN(A6)
       ENDM

BOX:MACRO %\X1,%\Y1,%\X2,%\Y2,%\COLOR

       PENCOL  \COLOR
       MOVE.L  #\X1,D0
       MOVE.L  #\Y1,D1
       MOVE.L  #\X2,D2
       MOVE.L  #\Y2,D3
       JSR     RECTFILL(A6)
       PENCOL  1
       ENDM

MOUSEXY:MACRO %\X1,%\Y1,%\X2,%\Y2,*\ADRESS
       
       MOVE.L  #\X1,D2
       MOVE.L  #\Y1,D3
       MOVE.L  #\X2,D4
       MOVE.L  #\Y2,D5
       LEA     \ADRESS,A1
       BSR     TESTMOUSE
       ENDM

MOUSE2:MACRO %\X1,%\Y1,%\X2,%\Y2,*\JUMPTO,*\JUMPBACK
       
       MOVE.L  #\X1,D2
       MOVE.L  #\Y1,D3
       MOVE.L  #\X2,D4
       MOVE.L  #\Y2,D5
       LEA     \JUMPTO,A1
       LEA     \JUMPBACK,A2
       ENDM

SCRCOL:MACRO %\NR,%\R,%\G,%\B

       MOVE.L  GFXBASE,A6
       MOVE.L  VIEWPORT,A0
       MOVEQ   #\NR,D0
       MOVEQ   #\R,D1
       MOVEQ   #\G,D2
       MOVEQ   #\B,D3
       JSR     SetRGB4(A6)
       EndM

IMAGE:MACRO *\POINTER,%\X,%\Y

       MOVE.L  INTBASE,A6
       MOVE.L  RASTPORT,A0
       LEA     \POINTER,A1
       MOVE.L  #\X,D0
       MOVE.L  #\Y,D1
       JSR     DRAWIMAGE(A6)
       ENDM

GETMEM:MACRO %\BYTES,%\REQ,*\POINTER

       MOVE.L  EXECBASE,A6
       MOVE.L  #\BYTES,D0
       MOVE.L  #\REQ,D1
       JSR     ALLOCMEM(A6)
       MOVE.L  D0,\POINTER
       ENDM

BACKMEM:MACRO %\BYTES,*\POINTER

       MOVE.L  EXECBASE,A6
       MOVE.L  #\BYTES,D0
       MOVE.L  \POINTER,A1
       JSR     FREEMEM(A6)
       ENDM

TOFRONT:MACRO *\SCREENHD

       MOVE.L  INTBASE,A6
       MOVE.L  \SCREENHD,A0
       JSR     SCREENTOFRONT(A6)
       ENDM

TOBACK:MACRO *\SCREENHD

       MOVE.L  INTBASE,A6
       MOVE.L  \SCREENHD,A0
       JSR     SCREENTOBACK(A6)
       ENDM

DISPALERT:MACRO

       MOVE.L  INTBASE,A6
       MOVEQ   #0,D0
       MOVE.W  ERRORNR,D2
       LSL.L   #2,D2
       LEA     ALERTS,A1
       ADDA.L  D2,A1
       MOVE.L  (A1),A0
       MOVE.L  #24,D1
       JSR     DISPLAYALERT(A6)
       ENDM

; -- Hauptprogramm --

START:
       OPENLIB INTNAME,INTBASE
       OPENLIB GFXNAME,GFXBASE
       OPENLIB DOSNAME,DOSBASE
    
       OPENSCR SCREENDEVS,SCREENHD

       TOBACK  SCREENHD

       SCRCOL  0,15,15,15
       SCRCOL  1,0,0,0
       SCRCOL  2,7,7,7
       SCRCOL  3,11,11,11

       OPENWIN WINDOWDEVS,WINDOWHD
       
       IMAGE   DESKTOP,0,0
       IMAGE   GADGETENDE,10,10
       IMAGE   GADGETENDE,560,10

       IMAGE   GADGETDRUCKEN,15,100
       IMAGE   GADGETBILDER,485,100
       IMAGE   GADGETINFO,15,170
       IMAGE   GADGETMUSIK,485,170

       TOFRONT SCREENHD
  
MAINLOOP:

       MOUSEXY 15,100,155,158,DRUCKEN
       MOUSEXY 15,170,155,228,INFO
       MOUSEXY 485,100,625,158,PICSNAP
       MOUSEXY 485,170,625,228,MUSIK
     
       MOUSE2  10,10,80,39,ENDE,MAINLOOP
       BRA     TESTMOUSE2

ENDE:
       CLOSEWI WINDOWHD
       CLOSESC SCREENHD

       CLOSELI INTBASE
       CLOSELI GFXBASE
       CLOSELI DOSBASE

       CLR.L   D0

       RTS                           ; Programm Ende

; -------------- MAUS PROGRAMME ----------------

TESTMOUSE:

       BTST    #6,MOUSEBUTTON
       BNE     TESTENDE
       MOVE.L  WINDOWHD,A0
       MOVE.W  12(A0),D1
       MOVE.W  14(A0),D0

       CMP.W   D3,D1
       BLO     TESTENDE
       CMP.W   D5,D1
       BHI     TESTENDE

       CMP.W   D2,D0
       BLO     TESTENDE
       CMP.W   D4,D0
       BHI     TESTENDE

       JSR     (A1)

TESTMOUSELOOP:

       BTST    #6,MOUSEBUTTON
       BEQ     TESTMOUSELOOP

TESTENDE:

       RTS

TESTMOUSE2:

       BTST    #6,MOUSEBUTTON
       BNE     TESTENDE2
       MOVE.L  WINDOWHD,A0
       MOVE.W  12(A0),D1
       MOVE.W  14(A0),D0

       CMP.W   D3,D1
       BLO     TESTENDE2
       CMP.W   D5,D1
       BHI     TESTENDE2

       CMP.W   D2,D0
       BLO     TESTENDE2
       CMP.W   D4,D0
       BHI     TESTENDE2

       JMP     (A1)

TESTENDE2:

       JMP     (A2)

; --------------------  NEBEN PROGS -----------------

MUSIK:

       IMAGE   GADGETMUSIK1,485,170
       MOVE.L  #$FFFF,D0

MUSIK_LOOP:

       NOP     ; Not implemented yet!
       DBRA    D0,MUSIK_LOOP

       IMAGE   GADGETMUSIK,485,170
       RTS

;---------------------------------------------------

INFO:

       IMAGE   GADGETINFO1,15,170
       MOVE.L  #$FFFF,D0

INFO_LOOP:

       NOP     ; Not implemented yet!
       DBRA    D0,INFO_LOOP

       IMAGE   GADGETINFO,15,170
       RTS

;---------------------------------------------------

PICSNAP:

       IMAGE   GADGETBILDER1,485,100

       MOVE.L  RASTPORT,DUMMYRASTPORT
       MOVE.L  WINDOWHD,DUMMYHD

       OPENSCR SCREEN2DEVS,SCREEN2HD

       SCRCOL  0,15,15,15
       SCRCOL  1,0,0,0

       OPENWIN WINDOW2DEVS,WINDOWHD

       IMAGE   ACTION,10,0
       IMAGE   COPYS,220,0
       IMAGE   PUBLIC,430,0

       IMAGE   TEXTVER,10,65
       IMAGE   PROGS,220,65
       IMAGE   GRAFIK,430,65

       IMAGE   SOUNDS,10,130

       RECT    220,130,419,189
       RECT    430,130,629,189

    IMAGE BACK,10,195
       IMAGE BLANK,220,195

       RECT    430,195,629,254

PIC_LOOP:

       MOUSEXY 10,0,210,60,IMAGE1
       MOUSEXY 220,0,420,60,IMAGE2
       MOUSEXY 430,0,630,60,IMAGE3
       MOUSEXY 10,65,210,145,IMAGE4
       MOUSEXY 220,65,420,145,IMAGE5
       MOUSEXY 430,65,630,145,IMAGE6
       MOUSEXY 10,130,210,190,IMAGE7
       MOUSEXY 220,195,420,254,LEER
       MOUSE2  10,200,170,250,PICCLOSE,PIC_LOOP
       BRA     TESTMOUSE2

PICCLOSE:

       CLOSEWI WINDOWHD
       CLOSESC SCREEN2HD

       MOVE.L  DUMMYHD,WINDOWHD
       MOVE.L  DUMMYRASTPORT,RASTPORT

       IMAGE   GADGETBILDER,485,100

PICSELECT:

       MOVE.W  IMAGEPOINTER,D0
       CMP.W   #1,D0
       BEQ     PRINT1
       CMP.W   #2,D0
       BEQ     PRINT2
       CMP.W   #3,D0
       BEQ     PRINT3
       CMP.W   #4,D0
       BEQ     PRINT4
       CMP.W   #5,D0
       BEQ     PRINT5
       CMP.W   #6,D0
       BEQ     PRINT6
       CMP.W   #7,D0
       BEQ     PRINT7

       BRA     PRINT0

PRINT0:
       BOX     220,70,420,130,0
       RTS
PRINT1:
       IMAGE   ACTION,220,70
       RTS
PRINT2:
       IMAGE   COPYS,220,70
       RTS
PRINT3:
       IMAGE   PUBLIC,220,70
       RTS
PRINT4:
       IMAGE   TEXTVER,220,70
       RTS
PRINT5:
       IMAGE   PROGS,220,70
       RTS
PRINT6:
       IMAGE   GRAFIK,220,70
       RTS
PRINT7:
       IMAGE   SOUNDS,220,70
       RTS

IMAGE1:
       MOVE.W  #1,IMAGEPOINTER
       IMAGE   ACTION,430,195
       RTS
IMAGE2:
       MOVE.W  #2,IMAGEPOINTER
       IMAGE   COPYS,430,195
       RTS
IMAGE3:
       MOVE.W  #3,IMAGEPOINTER
       IMAGE   PUBLIC,430,195
       RTS
IMAGE4:
       MOVE.W  #4,IMAGEPOINTER
       IMAGE   TEXTVER,430,195
       RTS
IMAGE5:
       MOVE.W  #5,IMAGEPOINTER
       IMAGE   PROGS,430,195
       RTS
IMAGE6:
       MOVE.W  #6,IMAGEPOINTER
       IMAGE   GRAFIK,430,195
       RTS
IMAGE7:
       MOVE.W  #7,IMAGEPOINTER
       IMAGE   SOUNDS,430,195
       RTS
LEER:
       MOVE.W  #0,IMAGEPOINTER
       IMAGE   BLANK,430,195
       RTS

;------------------------------------------------------

DRUCKEN:

       IMAGE   GADGETDRUCKEN1,15,100
       MOVE.W  #0,OK_WORD

       MOVE.L  EXECBASE,A6
       MOVE.L  SCREENHD,D1
       ADD.L   #44,D1
       MOVE.L  D1,SVIEWPORT
       ADD.L   #40,D1
       MOVE.L  D1,SRASTPORT
       MOVE.L  SVIEWPORT,A1
       MOVE.L  4(A1),SCOLORMAP
       MOVE.L  32(A1),VIEWMODES

       MOVEQ   #0,D0
       MOVE.L  #-1,D0
       JSR     ALLOCSIGNAL(A6)
       MOVE.B  D0,SIGBIT

       GETMEM  40,REQUEST,MSGPORT

       MOVE.L  MSGPORT,A1
       MOVE.B  #4,8(A1)
       MOVE.B  #0,9(A1)
       LEA     PORTNAME,A0
       MOVE.L  A0,10(A1)
       MOVE.B  #0,14(A1)
       MOVE.B  SIGBIT,15(A1)
       MOVE.L  #0,A0
       MOVE.L  A0,A1

       MOVEQ   #0,D1
       MOVEQ   #0,D0
       JSR     FINDTASK(A6)
       MOVE.L  D0,SIGTASK
       MOVE.L  MSGPORT,A1
       MOVE.L  SIGTASK,16(A1)

       MOVE.L  MSGPORT,A1
       JSR     ADDPORT(A6)
  
       GETMEM  64,REQUEST,IOREQUEST

       MOVE.L  IOREQUEST,A1
       MOVE.B  #5,8(A1)
       MOVE.B  #10,9(A1)
       MOVE.L  MSGPORT,14(A1)

       MOVE.L  EXECBASE,A6
       LEA     DEVNAME,A0
       MOVEQ   #0,D0
       MOVE.L  IOREQUEST,A1
       MOVEQ   #0,D1
       JSR     OPENDEVICE(A6)
       BNE     NOPRINTER

       MOVE.L  IOREQUEST,A0
       MOVE.W  #COMMAND,28(A0)
       MOVE.L  SRASTPORT,32(A0)
       MOVE.L  SCOLORMAP,36(A0)
       MOVE.L  VIEWMODES,40(A0)
       MOVE.W  SCRX,44(A0)
       MOVE.W  SCRY,46(A0)
       MOVE.W  SCRWIDTH,48(A0)
       MOVE.W  SCRHEIGHT,50(A0)
       MOVE.L  #DESTCOLS,52(A0)
       MOVE.L  #DESTROWS,56(A0)
       MOVE.W  #SPECIAL,60(A0)

       MOVE.L  EXECBASE,A6
       MOVE.L  IOREQUEST,A1
       JSR     DOIO(A6)
       BNE     FEHLER

       MOVE.W  #1,OK_WORD

CLEANUP1:

       MOVE.L  EXECBASE,A6
       MOVE.L  IOREQUEST,A1
       JSR     CLOSEDEVICE(A6)

CLEANUP2:

       MOVE.L  IOREQUEST,A1
       MOVE.B  #$FF,8(A1)
       MOVE.L  #-1,20(A1)
       MOVE.L  #-1,24(A1)
 
       BACKMEM 64,IOREQUEST

CLEANUP3:

       MOVE.L  EXECBASE,A6
       MOVE.L  MSGPORT,A1
       JSR     REMPORT(A6)

       MOVE.L  MSGPORT,A1
       MOVE.B  #$FF,8(A1)
       MOVE.L  #-1,20(A1)
       MOVEQ   #0,D0
       MOVE.B  SIGBIT,D0
       JSR     FREESIGNAL(A6)

       BACKMEM 40,MSGPORT

CLEANUP4:

       MOVE.W  OK_WORD,D0
       CMP.W   #1,D0
       BNE     CLEANUP5

       MOVEQ   #3,D3
       JSR     VORSCHUB

CLEANUP5:
       IMAGE   GADGETDRUCKEN,15,100
       RTS

; ------------    FEHLERROUTINEN FÜR DRUCKERAUSGABE   -------------

NOMEM:

       MOVE.W  #0,ERRORNR               ; Zuwenig Speicher

       DISPALERT

       TOFRONT SCREENHD
       BRA     CLEANUP4

NOPRINTER:

       MOVE.W  #1,ERRORNR               ; Printer.device nicht

       DISPALERT                        ; auf Diskette vorhanden

       TOFRONT SCREENHD
       BRA     CLEANUP2

NOREQUEST:

       MOVE.W  #0,ERRORNR               ; Zuwenig Speicher

       DISPALERT

       TOFRONT SCREENHD
       BRA     CLEANUP3

FEHLER:

       MOVE.W  #2,ERRORNR               ; Fehler bei Ausgabe

       DISPALERT

       TOFRONT SCREENHD
       BRA     CLEANUP1

VORSCHUB:

       MOVE.L  DOSBASE,A6
       MOVE.L  #PRTNAME,D1
       MOVE.L  #1006,D2
       JSR     OPEN(A6)
       MOVE.L  D0,PRTHD

       MOVE.L  DOSBASE,A6
       MOVE.L  PRTHD,D1
       MOVE.L  #VOR,D2
       JSR     OUTPUT(A6)

       MOVE.L  DOSBASE,A6
       MOVE.L  PRTHD,D1
       JSR     CLOSE(A6)

       RTS

; ---------------------   DATEN BEREICH  -------------------------
  DATA

SCREENDEVS:

       DC.W    0,0,640,256,2
       DC.B    0,1
       DC.W    $8002,15
       DC.L    0,0,0,0

WINDOWDEVS:

       DC.W    0,0,640,256
       DC.B    1,0
       DC.L    0,$11800,GADGET1,0,0
SCREENHD:  DC.L    0
       DC.L    0
       DC.W    500,200,640,256,15

SCREEN2DEVS:

       DC.W    0,0,640,256,1
       DC.B    0,1
       DC.W    $8002,15
       DC.L    0,0,0,0

WINDOW2DEVS:

       DC.W    0,0,640,256
       DC.B    1,0
       DC.L    0,$11800,0,0,0
SCREEN2HD:  DC.L    0
       DC.L    0
       DC.W    500,200,640,256,15

WINDOWHD:      DC.L    0
PRTHD:         DC.L    0
RASTPORT:      DC.L    0
INTBASE:       DC.L    0
GFXBASE:       DC.L    0
DOSBASE:       DC.L    0
VIEWPORT:      DC.L    0
IMAGEPOINTER:  DC.W    0
DUMMYRASTPORT: DC.L    0
DUMMYHD:       DC.L    0



SVIEWPORT:     DC.L    0
SRASTPORT:     DC.L    0
SCOLORMAP:     DC.L    0
VIEWMODES:     DC.L    0
SCRX:          DC.W    207
SCRY:          DC.W    50
SCRWIDTH:      DC.W    241
SCRHEIGHT:     DC.W    202
MSGPORT:       DC.L    0
SIGTASK:       DC.L    0
IOREQUEST:     DC.L    0
OK_WORD:       DC.W    0
SIGBIT:        DC.B    0,0

STRBUF1:   DS.B   24,0
STRBUF2:   DS.B   24,0
STRBUF3:   DS.B   24,0
STRBUF4:   DS.B   24,0
STRBUF5:   DS.B   24,0
STRBUF6:   DS.B   24,0
STRBUF7:   DS.B   24,0
STRBUF8:   DS.B   24,0
UNDO:      DS.B   24,0

ERRORNR:   DC.W   0
ALERTS:    DC.L   ALERT0,ALERT1,ALERT2

; -----------   SYSTEM STRUKTUREN FÜR DIE GADGETS, IMAGES  --------

GADGET1:
       DC.L    GADGET2
       DC.W    220,142,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO1
       DC.W    0
       DC.L    0
STRINGINFO1:
       DC.L    STRBUF1,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET2:
       DC.L    GADGET3
       DC.W    220,153,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO2
       DC.W    0
       DC.L    0
STRINGINFO2:
       DC.L    STRBUF2,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET3:
       DC.L    GADGET4
       DC.W    220,164,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO3
       DC.W    0
       DC.L    0
STRINGINFO3:
       DC.L    STRBUF3,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET4:
       DC.L    GADGET5
       DC.W    220,175,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO4
       DC.W    0
       DC.L    0
STRINGINFO4:
       DC.L    STRBUF4,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET5:
       DC.L    GADGET6
       DC.W    220,186,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO5
       DC.W    0
       DC.L    0
STRINGINFO5:
       DC.L    STRBUF5,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET6:
       DC.L    GADGET7
       DC.W    220,197,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO6
       DC.W    0
       DC.L    0
STRINGINFO6:
       DC.L    STRBUF6,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET7:
       DC.L    GADGET8
       DC.W    220,208,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO7
       DC.W    0
       DC.L    0
STRINGINFO7:
       DC.L    STRBUF7,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

GADGET8:
       DC.L    0
       DC.W    220,219,200,10,0,$202,4
       DC.L    0,0,0,0,STRINGINFO8
       DC.W    0
       DC.L    0
STRINGINFO8:
       DC.L    STRBUF8,UNDO
       DC.W    0,24,0,0,0,0,0,0
       DC.L    0,0,0

; ------------- IMAGES --------------------------

DESKTOP:
       DC.W    0,0,640,256,2
       DC.L    DESKTOP_DATA
       DC.B    3,0
       DC.L    0

GADGETDRUCKEN:
       DC.W    0,0,140,58,2
       DC.L    DRUCKEN_DATA
       DC.B    3,0
       DC.L    0
GADGETDRUCKEN1:
       DC.W    0,0,140,58,2
       DC.L    DRUCKEN1_DATA
       DC.B    3,0
       DC.L    0

GADGETINFO:
       DC.W    0,0,140,58,2
       DC.L    INFO_DATA
       DC.B    3,0
       DC.L    0
GADGETINFO1:
       DC.W    0,0,140,58,2
       DC.L    INFO1_DATA
       DC.B    3,0
       DC.L    0

GADGETBILDER:
       DC.W    0,0,140,58,2
       DC.L    BILDER_DATA
       DC.B    3,0
       DC.L    0
GADGETBILDER1:
       DC.W    0,0,140,58,2
       DC.L    BILDER1_DATA
       DC.B    3,0
       DC.L    0

GADGETMUSIK:
       DC.W    0,0,140,58,2
       DC.L    MUSIK_DATA
       DC.B    3,0
       DC.L    0
GADGETMUSIK1:
       DC.W    0,0,140,58,2
       DC.L    MUSIK1_DATA
       DC.B    3,0
       DC.L    0

GADGETENDE:
       DC.W    0,0,70,29,2
       DC.L    ENDE_DATA
       DC.B    3,0
       DC.L    0

ACTION:
       DC.W    0,0,200,60,1
       DC.L    ACTION_DATA
       DC.B    1,0
       DC.L    0

COPYS:
       DC.W    0,0,200,60,1
       DC.L    COPYS_DATA
       DC.B    1,0
       DC.L    0

PUBLIC:
       DC.W    0,0,200,60,1
       DC.L    PUBLIC_DATA
       DC.B    1,0
       DC.L    0

TEXTVER:
       DC.W    0,0,200,60,1
       DC.L    TEXTVER_DATA
       DC.B    1,0
       DC.L    0

PROGS:
       DC.W    0,0,200,60,1
       DC.L    PROGS_DATA
       DC.B    1,0
       DC.L    0

GRAFIK:
       DC.W    0,0,200,60,1
       DC.L    GRAFIK_DATA
       DC.B    1,0
       DC.L    0

SOUNDS:
       DC.W    0,0,200,60,1
       DC.L    SOUNDS_DATA
       DC.B    1,0
       DC.L    0

BACK:

       DC.W    0,0,200,60,1
       DC.L    BACK_DATA
       DC.B    1,0
       DC.L    0

BLANK:
       DC.W    0,0,200,60,1
       DC.L    BLANK_DATA
       DC.B    1,0
       DC.L    0

; -------------------      TEXTE        -------------------------
 
ALERT0:    DC.B   0,16,16,"Zuwenig Speicher. Sorry !!!",0,0
ALERT1:    DC.B   0,16,16,"Kann den Drucker Port nicht öffnen",0,0
ALERT2:    DC.B   0,16,16,"Fehler beim Ausdrucken",0,0

INTNAME:       DC.B    "intuition.library",0
GFXNAME:       DC.B    "graphics.library",0
DOSNAME:       DC.B    "dos.library",0

DEVNAME:       DC.B    "printer.device",0
PORTNAME:      DC.B    "MyPrinterPort",0
PRTNAME:       DC.B    "PAR:",0
VOR:           DC.B    10,10,10,10

; -------------  BILD DATEN ---------------------------------

  ALIGN.L

DESKTOP_DATA:

       IBYTES  "BITS/DESKTOP.BIT"

DRUCKEN_DATA:
       IBYTES  "BITS/DRUCKEN.BIT"

DRUCKEN1_DATA:
       IBYTES  "BITS/DRUCKEN1.BIT"

ENDE_DATA:
       IBYTES  "BITS/ENDE.BIT"

ENDE1_DATA:
       IBYTES  "BITS/ENDE1.BIT"

BILDER_DATA:

       IBYTES  "BITS/BILDER.BIT"

BILDER1_DATA:

       IBYTES  "BITS/BILDER1.BIT"

INFO_DATA:

       IBYTES  "BITS/INFO.BIT"

INFO1_DATA:

       IBYTES  "BITS/INFO1.BIT"

MUSIK_DATA:

       IBYTES  "BITS/MUSIK.BIT"

MUSIK1_DATA:

       IBYTES  "BITS/MUSIK1.BIT"

ACTION_DATA:

       IBYTES  "BITS/ACTION.BIT"

TEXTVER_DATA:

       IBYTES  "BITS/TEXTVER.BIT"

PROGS_DATA:

       IBYTES  "BITS/PROGS.BIT"

PUBLIC_DATA:

       IBYTES  "BITS/PUBLIC.BIT"

GRAFIK_DATA:

       IBYTES  "BITS/GRAPHIC.BIT"

COPYS_DATA:

       IBYTES  "BITS/COPYS.BIT"

SOUNDS_DATA:

       IBYTES  "BITS/SOUNDS.BIT"

BACK_DATA:
       IBYTES  "BITS/BACK.BIT"

BLANK_DATA:
       IBYTES  "BITS/BLANK.BIT"

       END
