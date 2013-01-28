                Title  DVAWARE
; Routines courtesy of Quarterdeck Office Systems
; Modified for Turbo Assembler by Steven R. Lorenz 1992
;**************************************************************

CODE SEGMENT
  ASSUME CS:CODE;ds:nothing
MASM
      PUBLIC  DV_AWARE_ON
      PUBLIC  DV_BEGIN_CRITICAL  
      PUBLIC  DV_END_CRITICAL

; Returns in AH/AL in DESQview major/minor version numbers,
; and sets up the IN_DV variable for later use.
; Returns 0 in AX if DESQview isn't present.

  IN_DV   DB 1
  DV_Aware_On PROC FAR
      PUSH  AX            
      PUSH  CX
      PUSH  DX
      MOV   CX,'DE'             ; Set CX to 4445H; DX to 5351H
      MOV   DX,'SQ'             ; (an invalid date)
      MOV   AX,2B01H            ; DOS' set date function
      INT   21H                 ; Call DOS
      CMP   AL,0FFH             ; Did DOS see this as invalid?
      JE    NO_DESQVIEW         ; if yes, DESQview isn't there
      MOV   AX,BX               ; AH=major version; AL=minor ver
      MOV   CS:IN_DV,1          ; Set internal variable used by
      JMP   SHORT DVGV_X        ; other routines
 NO_DESQVIEW:
      XOR    AX,AX              ; Return no DESQview (version 0)
 DVGV_X:
      POP    DX
      POP    CX
      POP    BX
      RET
 ENDP DV_Aware_On
;**************************************************************

; This local routine takes a program interface function in BX,
; and makes that call to DV after switching onto a stack that
; DV provides for your program.

 API_CALL  PROC  NEAR
      PUSH   AX
      MOV    AX,101AH           ; The function to switch to DV's stack
      INT    15H                ; DV's software interrupt
      MOV    AX,BX              ; Move the desired function to AX
      INT    15H                ; Make that call
      MOV    AX,1025H           ; Function to switch off of DV's stack
      INT    15H                ; Make that call
      POP    AX
      RET
 ENDP API_CALL

;**************************************************************
; This routine tells DV not to slice away from your program
; until you make a DV_END_CRITICAL call.
; NOTE - Then always make that DV_END_CRITICAL after this call.
; Takes no parameters and returns nothing.

 DV_BEGIN_CRITICAL  PROC  FAR
      CMP    CS:IN_DV,1         ; Is DESQview present?
      JNE    DVBC_X             ; If not, jump out of here
      PUSH   BX                 ; Else make the begin critical call
      MOV    BX,101BH           ; This is the DV function code
      CALL   API_CALL           ; Do it
      POP    BX
 DVBC_x:  RET
 ENDP DV_BEGIN_CRITICAL
;**************************************************************

; This routine tells DV that it is all right to time slice away
; from your program again.
; Takes no parameters and returns nothing.

 DV_END_CRITICAL PROC FAR
       CMP   CS:IN_DV,1         ; Is DESQview present?
       JNE   DVEC_X             ; If not, jump out of here
       PUSH  BX                 ; Else make the end critical call
       MOV   BX,101CH           ; This is the DV function code
       CALL  API_CALL           ; Do it
       POP   BX
 DVEC_X: RET
 ENDP DV_END_CRITICAL

CODE ENDS
 END
;**************************************************************
