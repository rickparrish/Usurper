TITLE Turbo Pascal XMS support for loading overlays - By Wilbert van Leijen
PAGE 65, 132
LOCALS @@

Data       SEGMENT Word Public
           ASSUME  DS:Data

;  XMS block move record

XmsMoveType STRUC
           BlkSize     DD    ?
           SrcHandle   DW    ?
           SrcOffset   DD    ?
           DestHandle  DW    ?
           DestOffset  DD    ?
XmsMoveType ENDS

;  TP overlay manager record

OvrHeader  STRUC
           ReturnAddr  DD    ?         ; Virtual return address
           FileOfs     DD    ?         ; Offset into overlay file
           CodeSize    DW    ?         ; Size of overlay
           FixupSize   DW    ?         ; Size of fixup table
           EntryPts    DW    ?         ; Number of procedures
           CodeListNext DW   ?         ; Segment of next overlay
           LoadSeg     DW    ?         ; Start segment in memory
           Reprieved   DW    ?         ; Loaded in memory flag
           LoadListNext DW   ?         ; Segment of next in load list
           XmsOffset   DD    ?         ; Offset into allocated XMS block
           UserData    DW    3 DUP(?)
OvrHeader  ENDS

XmsDriver  DD      ?                   ; Entry point of XMS driver
ExitSave   DD      ?                   ; Pointer to previous exit proc
XmsMove    XmsMoveType <>
OvrXmsHandle DW    ?                   ; Returned by XMS driver

           Extrn   PrefixSeg : Word
           Extrn   ExitProc : DWord
           Extrn   OvrResult : Word
           Extrn   OvrCodeList : Word
           Extrn   OvrDosHandle : Word
           Extrn   OvrHeapOrg : Word
           Extrn   OvrReadBuf : DWord
Data       ENDS

Code       SEGMENT Byte Public
           ASSUME  CS:Code
           Public  OvrInitXMS

ovrIOError     EQU     -4
ovrNoXMSDriver EQU     -7
ovrNoXMSMemory EQU     -8

OvrXmsExit PROC

; Release handle and XMS memory

        MOV    DX, [OvrXmsHandle]
        MOV    AH, 10
        CALL   [XmsDriver]

; Restore pointer to previous exit procedure

        LES    AX, [ExitSave]
        MOV    Word Ptr [ExitProc], AX
        MOV    Word Ptr [ExitProc+2], ES
        RETF
OvrXmsExit ENDP

AllocateXms PROC

;  Determine the size of the XMS block to allocate:
;  Walk the CodeListNext chain
;  Store the total codesize in DX:AX

        XOR    AX, AX
        XOR    DX, DX
        MOV    BX, [OvrCodeList]
@@1:    ADD    BX, [PrefixSeg]
        ADD    BX, 10h
        MOV    ES, BX
        ADD    AX, ES:[OvrHeader.CodeSize]
        ADC    DX, 0
        MOV    BX, ES:[OvrHeader.CodeListNext]
        OR     BX, BX
        JNZ    @@1

;  Obtain number of kilobytes to allocate

        MOV    BX, 1024
        DIV    BX
        XCHG   DX, AX
        INC    DX

;  Allocate the block

        MOV    AH, 9
        CALL   [XmsDriver]
        OR     AX, AX
        JZ     @@2
        MOV    [OvrXmsHandle], DX
@@2:    RETN
AllocateXms ENDP

;  Function XmsReadFunc(OvrSeg : Word) : Integer; Far;

XmsReadFunc PROC

;  Swap the code from XMS to the heap

        PUSH   BP
        MOV    BP, SP
        MOV    ES, [BP+6]
        MOV    AX, ES:[OvrHeader.CodeSize]
        MOV    Word Ptr [XmsMove.BlkSize], AX
        XOR    AX, AX
        MOV    Word Ptr [XmsMove.BlkSize+2], AX
        MOV    AX, [OvrXmsHandle]
        MOV    [XmsMove.SrcHandle], AX
        MOV    AX, Word Ptr ES:[OvrHeader.XmsOffset]
        MOV    Word Ptr [XmsMove.SrcOffset], AX
        MOV    AX, Word Ptr ES:[OvrHeader.XmsOffset+2]
        MOV    Word Ptr [XmsMove.SrcOffset+2], AX
        XOR    AX, AX
        MOV    [XmsMove.DestHandle], AX
        MOV    Word Ptr [XmsMove.DestOffset], AX
        MOV    AX, ES:[OvrHeader.LoadSeg]
        MOV    Word Ptr [XmsMove.DestOffset+2], AX
        MOV    AH, 11
        LEA    SI, XmsMove
        CALL   [XmsDriver]
        OR     AX, AX
        JZ     @@1
        DEC    AX
        JMP    @@2

@@1:    MOV    AX, ovrIOError
@@2:    POP    BP
        RETF   2
XmsReadFunc ENDP

;  Copy an overlaid unit from the heap to XMS
;  If successful, carry flag is cleared
;  In/Out:
;    BX:DI = offset into XMS memory block

CopyUnitToXms PROC

;  XMS requires that an even number of bytes is moved

        MOV    DX, ES:[OvrHeader.CodeSize]
        TEST   DX, 1
        JZ     @@1
        INC    DX
        INC    ES:[OvrHeader.CodeSize]

;  Get the fields of the XMS block move structure

@@1:    MOV    Word Ptr [XmsMove.BlkSize], DX
        XOR    AX, AX
        MOV    Word Ptr [XmsMove.BlkSize+2], AX
        MOV    [XmsMove.SrcHandle], AX
        MOV    Word Ptr [XmsMove.SrcOffset], AX
        MOV    AX, [OvrHeapOrg]
        MOV    Word Ptr [XmsMove.SrcOffset+2], AX
        MOV    AX, [OvrXmsHandle]
        MOV    [XmsMove.DestHandle], AX
        MOV    Word Ptr [XmsMove.DestOffset], DI
        MOV    Word Ptr [XmsMove.DestOffset+2], BX
        MOV    AH, 11
        LEA    SI, XmsMove
        CALL   [XmsDriver]

;  Bump code size

        ADD    DI, DX
        ADC    BX, 0

;  Check return code from XMS driver

        OR     AX, AX
        JZ     @@2
        CLC
        RETN

@@2:    STC
        RETN
CopyUnitToXms ENDP

OvrXmsLoad PROC
        PUSH   BP
        MOV    BP, SP

;  Walk the CodeList chain
;  First segment is PrefixSeg+10h+OvrCodeList
;  Push each element of overlaid unit list on the stack
;  Keep the size of the linked list in CX

        MOV    AX, [OvrCodeList]
        XOR    CX, CX
@@1:    ADD    AX, [PrefixSeg]
        ADD    AX, 10h
        MOV    ES, AX
        PUSH   AX
        INC    CX
        MOV    AX, ES:[OvrHeader.CodeListNext]
        OR     AX, AX
        JNZ    @@1

;  Loop:
;    Pop each element of the overlaid unit list from the stack

        XOR    BX, BX
        XOR    DI, DI
@@2:    POP    ES
        PUSH   CX
        MOV    AX, [OvrHeapOrg]
        MOV    ES:[OvrHeader.LoadSeg], AX
        MOV    Word Ptr ES:[OvrHeader.XmsOffset+2], BX
        MOV    Word Ptr ES:[OvrHeader.XmsOffset], DI

;  Load overlay from disk

        PUSH   BX
        PUSH   DI
        PUSH   ES
        PUSH   ES
        CALL   [OvrReadBuf]
        POP    ES
        POP    DI
        POP    BX

;  Flag unit as 'unloaded'; check return code

        MOV    ES:[OvrHeader.LoadSeg], 0
        NEG    AX
        JC     @@3

        CALL   CopyUnitToXms
        JC     @@3

        POP    CX
        LOOP   @@2

@@3:    MOV    SP, BP
        POP    BP
        RETN
OvrXMSLoad ENDP

OvrInitXMS PROC

;  Make sure the file's been opened

        XOR    AX, AX
        CMP    AX, [OvrDOSHandle]
        JNE    @@1
        DEC    AX                      ; ovrError
        JMP    @@5

;  Check presence of XMS driver

@@1:    MOV    AX, 4300h
        INT    2Fh
        CMP    AL, 80h
        JE     @@2
        MOV    AX, ovrNoXmsDriver
        JMP    @@5

;  Get XMS driver's entry point

@@2:    MOV    AX, 4310h
        INT    2Fh
        MOV    Word Ptr [XmsDriver], BX
        MOV    Word Ptr [XmsDriver+2], ES
        CALL   AllocateXms
        JNZ    @@3
        MOV    AX, ovrNoXMSMemory
        JMP    @@5

;  Load the overlay into XMS

@@3:    CALL   OvrXmsLoad
        JNC    @@4

;  An error occurred.  Release handle and XMS memory

        MOV    DX, [OvrXmsHandle]
        MOV    AH, 10
        CALL   [XmsDriver]
        MOV    AX, ovrIOError
        JMP    @@5

;  Close file

@@4:    MOV    BX, [OvrDOSHandle]
        MOV    AH, 3Eh
        INT    21h

;  OvrReadBuf := XmsReadFunc

        MOV    Word Ptr [OvrReadBuf], Offset XmsReadFunc
        MOV    Word Ptr [OvrReadBuf+2], CS

;  ExitSave := ExitProc
;  ExitProc := OvrXmsExit

        LES    AX, [ExitProc]
        MOV    Word Ptr [ExitSave], AX
        MOV    Word Ptr [ExitSave+2], ES
        MOV    Word Ptr [ExitProc], Offset OvrXmsExit
        MOV    Word Ptr [ExitProc+2], CS

;  Return result of initialisation

        XOR    AX, AX
@@5:    MOV    [OvrResult], AX
        RETF
OvrInitXMS ENDP

Code       ENDS
           END