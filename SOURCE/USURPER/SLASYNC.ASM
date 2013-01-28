;	Status byte definition (C_Status):

;	7   6   5   4   3   2   1   0
;	|   |   |   |   |   |   |   |____ Input buffer empty
;	|   |   |   |   |   |   |________ Input buffer full
;	|   |   |   |   |   |____________ Output buffer empty
;	|   |   |   |   |________________ Output buffer full
;	|   |   |   |____________________ Input buffer overflow
;	|   |   |________________________ Output buffer overflow
;	|   |____________________________ Hard handshake active (xmit stopped)
;	|________________________________ Soft handshake active (xmit stopped)

;	Control byte definition (C_Ctrl):

;	7   6   5   4   3   2   1   0
;	|   |   |   |   |   |   |   |____ Enable RTS handshake
;	|   |   |   |   |   |   |________ Enable CTS handshake
;	|   |   |   |   |   |____________ Enable software handshake
;	|   |   |   |   |________________
;	|   |   |   |____________________
;	|   |   |________________________
;	|   |____________________________
;	|________________________________

;********************************************************

; Macro:	PutChar
; Function:	Place character in transmit buffer (transmit a character)
; Entry:	AL <- Port # (0-3)
;		AH <- Status register
;		BX <- Byte array pointer
;		CH <- Character to put in buffer
;		DX <- Base address of port
; Destroyed:	ES,SI,DI,AL

; Note:	Port address passed is NOT checked for validity.
;	Subroutine ChkPort will create the proper entry environment

PUTCHAR MACRO

        test    ah, 00001000b           ;Is buffer full?
        JZ      @@putch1                ;No, OK to put character
        or      ah, 00100000b           ;set overflow flag
        JMP     @@putchx                ;and exit

@@putch1:
        shl     bl,1                    ;bx <- word array index
        mov     di, [C_outhead+bx]      ;bump the head pointer
        mov     si, [c_outtail+bx]
        inc     di
        cmp     di, [C_outsize+bx]
        jb      @@putch2
        xor     di,di
@@putch2:
        mov     [C_outhead+bx],di       ;save head pointer
        inc     [C_buffull+bx]          ;increment buffer-full word

        shl     bl,1                    ;BX <- pointer array index
        LES     BX, [C_outbufptr+bx]    ;Load ES with segment of output buf
        mov     [ES:BX+DI],ch           ;save the byte

        cmp     di, si                  ;Is output buffer full?
        jnz     @@putch3                ;no, go enable xmitter
        or      ah, 00001000b           ;Set status to output buffer full
@@putch3:
        xor     bh, bh
        mov     bl, al                  ;Save AL in BL and make BX byte index

        test    ah, 11000000b           ;soft/hard handshake on?
        jnz     @@putchx
;        test    ah, 00000100b
;        jz      @@putchx

        and     ah, 11111011b           ;Buffer is no longer empty
        inc     dl                      ;Change to IER register
        in      al, dx                  ;Read in the IER
        or      al, 00000010b           ;Turn on xmt interrupt
        NOP                             ;Slow down for slow machines
        NOP
        out     dx, al                  ;Write out the IER
        dec     dl                      ;Back to base reg
@@putchx:
        mov     [C_status+bx],ah        ;set status byte
;        mov     al,bl                   ;get port num back in AL
	ENDM

;******************************************************************
; MACRO: Test for modem status change
;
; Entry: DX - port base
;        BX - byte array index
;
; Destroyed: AX, CX

MSCHG   MACRO

;	Get modem status & control/status registers

@@Msc0:	ADD	DL,MSR			;DX <- 8250 MSR port address
	IN	AL,DX			;AL <- 8250 Modem status
	SUB	DL,MSR			;Back to base

	MOV	CL,[C_Status+BX]	;CL <- Status register
	MOV	CH,[C_Ctrl+BX]		;CH <- Control register

;	Control CTS status flag based on CTS status and handshake enable

	TEST	CH,00000010b		;CTS handshake enabled ?
	JZ	@@Msc2			; No, ignore CTS status
	TEST	AL,00010000b		;CTS asserted ?
	JNZ	@@Msc1			; Yes, enable transmit
	OR	CL,01000000b		;CTS inactive - hard handshake on
	JMP	@@Msc2			;
@@Msc1:	AND	CL,10111111b		;CTS active - hard handshake off
@@Msc2:	MOV	[C_Status+BX],CL	;Save status flags

;	Determine if transmitter should be enabled

@@Msc3:	ADD	DL,IER			;DX <- 8250 IER port address
	IN	AL,DX			;AL <- Interrupt enable register
	OR	AL,00000010b		;Enable transmitter by default
	TEST	CL,11000100b		;Enable transmitter ?
	JZ	@@Msc4			; Yes
	AND	AL,11111101b		; No - disable transmitter
@@Msc4:	OUT	DX,AL			;Update IER
        SUB     DL, IER

        ENDM

	IDEAL

	SEGMENT	DATA 	WORD PUBLIC

;	Externally accessed (TP program) variables
;	Note: 	Most of these variables are declared as arrays in the main
;		program; i.e. C_InSize : Array[1..4] Of Word

	EXTRN	C_InBufPtr :DWORD	;Pointer to input buffers
	EXTRN	C_OutBufPtr:DWORD	;Pointer to output buffers
	EXTRN	C_InSize   :WORD	;Size (bytes) of input buffers
	EXTRN	C_OutSize  :WORD	;Size (bytes) of output buffers
	EXTRN	C_InHead   :WORD	;Input (receive) head pointers
	EXTRN	C_OutHead  :WORD	;Output (transmit) head pointers
	EXTRN	C_InTail   :WORD	;Input (receive) tail pointers
	EXTRN	C_OutTail  :WORD	;Output (transmit) tail pointers
	EXTRN	C_RTSOn    :WORD	;Point at which RTS line is asserted
	EXTRN	C_RTSOff   :WORD	;Point at which RTS line is dropped
	EXTRN	C_StartChar:BYTE	;Start character for soft handshake
	EXTRN	C_StopChar :BYTE	;Stop character for soft handshake
	EXTRN	C_Status   :BYTE	;Status byte (see above)
	EXTRN	C_Ctrl     :BYTE	;Control byte (see above)
	EXTRN	C_PortOpen :BYTE	;Port-open flags
	EXTRN	C_PortAddr :WORD	;Base address of ports
	EXTRN	C_MaxCom   :BYTE	;Highest port # defined (single byte)
        EXTRN   C_bufFull  :WORD
        EXTRN   C_cascade  :BYTE
;        EXTRN   C_CharSend  :WORD
;        EXTRN   C_CharWrite :WORD
;        EXTRN   C_Temp      :WORD	;Used for debugging

;	8250 register offsets

IER	EQU	1			;Interrupt enable register
IIR	EQU	2			;Interrupt identification register
LCR	EQU	3			;Line control register
MCR	EQU	4			;Modem control register
LSR	EQU	5			;Line status register
MSR	EQU	6			;Modem status register
SCR	EQU	7			;8250 scratch register

	ENDS	DATA

;	Code segment declaration

	SEGMENT	CODE	BYTE PUBLIC

	ASSUME	CS:CODE,DS:DATA

;	Externally accessable procedures defined here

        PUBLIC  INT_Handler
	PUBLIC	ComReadCh
	PUBLIC	ComReadChW
	PUBLIC	ComWriteCh
	PUBLIC	ComWriteChW

;********************************************************
;*							*
;*	Subroutines that are used internally		*
;*							*
;********************************************************

; Subroutine:	ChkPort
; Function:	Check port parameter(s), ensure that port is OPEN
; Entry:	AL <- Port # (1 - C_MaxCom)
; Exit:		AL -> Adjusted port # (0 - 3)
;		AH -> Status register
;		BX -> Byte array index
;		DX -> Base address of port
;		Carry flag SET if parameters & port are OK
;
;	PROC	ChkPort		FAR
;
;	Determine if port # is valid
;
;	CMP	AL,[C_MaxCom]		;Port # > Maximum port # ?
;	JA	ChkErr			; Yes, exit w/error
;	CMP	AL,0			;Port # = 0 (invalid port #)
;	JZ	ChkErr			; Yes, exit w/error
;	DEC	AL			;AL <- Adjusted port #
;
;	Check if port open
;
;	XOR	BH,BH			;
;	MOV	BL,AL			;BX <- Byte array index
;	MOV	AH,[C_PortOpen+BX]	;AH <- Port-open flag
;	CMP	AH,0			;Port open ?
;	JZ	ChkErr			; No, exit w/error
;
;	Get status register and base port address in DX
;
;	MOV	AH,[C_Status+BX]	;AH <- Status register
;	SHL	BL,1			;BX <- Word array index
;	MOV	DX,[C_PortAddr+BX]	;DX <- Port address
;	SHR	BL,1			;BX <- Byte array index
;	STC				;Set carry (valid return)
;	RET				;Exit
;
;	Here if error
;
;ChkErr:	CLC				;Clear carry (invalid return)
;	RET				;Exit
;
;	ENDP	ChkPort

;	PROC	PutChar		FAR
;
;;	Check for buffer overflow
;
;	TEST	AH,00001000b		;Buffer full ?
;	JZ	PutCh1			; No, continue
;	OR	AH,00100000b		;Set buffer-overflow flag
;	JMP	PutChX			;Exit
;
;;	Increment head pointer
;
;PutCh1:	SHL	BL,1			;BX <- Word array index
;	MOV	DI,[C_OutHead+BX]	;DI <- Output head pointer
;	MOV	SI,[C_OutTail+BX]	;SI <- Output tail pointer
;	INC	DI			;Bump head pointer
;	CMP	DI,[C_OutSize+BX]	;Head >= Buffer size ?
;	JB	PutCh2			; No, continue
;	XOR	DI,DI			; Yes, reset pointer
;PutCh2:	MOV	[C_OutHead+BX],DI	;Save head pointer
;        INC     [C_buffull+bx]          ;Increment chars in buffer
;;        INC     [C_charwrite+bx]
;
;;	Place character in buffer
;
;	SHL	BL,1			;BX <- Pointer array index
;	LES	BX,[C_OutBufPtr+BX]	;ES:BX <- Pointer to output buffer
;	MOV	[ES:BX+DI],CH		;Place character in buffer
;
;;	Check for full buffer
;
;	CMP	DI,SI			;Head = Tail (buffer full) ?
;	JNZ	PutCh3			; No, buffer not full
;	OR	AH,00001000b		;Set buffer-full flag
;
;;	Determine if transmitter should be activated
;
;PutCh3:	XOR	BH,BH			;
;	MOV	BL,AL			;BX <- Byte array index
;
;	TEST	AH,11000000b		;Any inhibits (soft/hard hshake) ?
;	JNZ	PutChX			; Yes, do not activate xmit interrupt
;;	TEST	AH,00000100b		;Buffer empty ?
;;	JZ	PutChX			; No, xmit interrupt is on already
;
;	AND	AH,11111011b		;Reset buffer-empty flag
;	ADD	DL,IER			;Point to interrupt enable register
;	IN	AL,DX			;AL <- Interrupt enable register
;	OR	AL,00000010b		;Enable transmit interrupt
;       NOP                             ;Slow down for slow machines
;       NOP
;	OUT	DX,AL			;Update port
;	SUB	DL,IER			;Point back to base
;
;;	Here to exit
;
;PutChX:	MOV	[C_Status+BX],AH	;Save status byte
;	MOV	AL,BL			;
;	RET				;Exit
;
;	ENDP	PutChar


;********************************************************
;*							*
;*	Interrupt service routine for INT3,INT4		*
;*							*
;*	    INT3 typically used by COM2, COM4		*
;* 	    INT4 typically used by COM1, COM3		*
;*							*
;********************************************************

	PROC	INT_Handler 	FAR

	PUSH	AX			;Save environment
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	PUSH	SI			;
	PUSH	DI			;
	PUSH	DS			;
	PUSH	ES			;
	PUSH	BP			;

	MASM
	MOV	AX,SEG DATA		;AX <- Current data segment
	IDEAL
	MOV	DS,AX			;Set new data segment

INT_Id:	XOR	BX,BX			;BL <- Port # (start at 0)

;	Identify active port

IntID1:	MOV	AL,[C_PortOpen+BX]	;AL <- Port-open flag
	CMP	AL,0			;Port open ?
	JZ	IntID2			; No, don't check
	SHL	BL,1			;BX <- Word array index
	MOV	DX,[C_PortAddr+BX]	;DX <- Base address of port
	SHR	BL,1			;BX <- Byte array index
	ADD	DL,IIR			;Add in offset for IIR
	IN	AL,DX			;AL <- COMn IIR
	TEST	AL,00000001b		;Interrupt active on this port ?
	JZ	INT_Active		; (Bit 0 = 0 if active)
IntID2:	INC	BL			;Bump port #
	CMP	BL,[C_MaxCom]		;All ports checked ?
	JB	IntID1			; No, continue

;	Here to reset 8259 controller

	MOV	AL,20h			;AL <- EOI Acknowledge code
	OUT	20h,AL			;To 8259 PIC
        MOV     AL,[C_Cascade]          ;Move cascade flag
        CMP     AL,0                    ;No cascade?
        JE      IntID3                  ;Check it no cascaded irq

;	Reset cascade port

	MOV	DX,0A0h                 ;DX To 8259 cascade PIC
	MOV	AL,20h			;AL <- EOI Acknowledge code
	OUT	DX,AL			;To 8259 cascade PIC

;	Here to leave interrupt handler

IntID3:	POP	BP			;Restore envirionment
	POP	ES			;
	POP	DS			;
	POP	DI			;
	POP	SI			;
	POP	DX			;
	POP	CX			;
	POP	BX			;
	POP	AX			;

	IRET				;Interrupt exit

;	Active port (8250) found.
;	Determine cause of interrupt and execute appropriate handler.
;	Upon entry into routine, registers are set as follows:
;	BX <- Byte array index
;	DX <- Port address

INT_Active:
	DEC	DX			;
	DEC	DX			;DX <- Base address of COM port

	CMP	AL,0			;IIR = 0 (Modem status change) ?
	JZ	ComMsc			; Yes
	CMP	AL,2			;IIR = 2 (Character transmitted) ?
	JZ	ComXmt			; Yes
	CMP	AL,4			;IIR = 4 (Character received) ?
	JNZ	Next			;
	JMP	ComRcv			; Yes
Next:	CMP	AL,6			;IIR = 6 (Line status change) ?
	JZ	ComLsc			; Yes
	JMP	INT_Id			;Check other ports & exit

;*******************************************************
;		Line status change
;		NOTE: Currently unused
;*******************************************************

ComLsc:	ADD	DL,LSR			;Point to line status register
	IN	AL,DX			;Get LSR

;	The following code (which disables then enables the transmit
;	interrupt) is required to compensate for some "buggy" 8250's and
;	8250-emulating gate arrays.

	SUB	DL,LSR			;Back to base
	ADD	DL,IER			;Point to interrupt enable register
	IN	AL,DX			;Get IER
	MOV	AH,AL			;Save IER
	AND	AL,11111101b		;Mask transmit interrupt
	OUT	DX,AL			;Send modified to port
	MOV	AL,AH			;
        NOP                             ;slow down for slow machines
        NOP
	OUT	DX,AL			;Send original to port

	JMP	INT_Id			;Exit

;*******************************************************
;		Modem status change
;*******************************************************

ComMsc:	NOP

;	Get modem status & control/status registers

Msc0:	ADD	DL,MSR			;DX <- 8250 MSR port address
	IN	AL,DX			;AL <- 8250 Modem status
	SUB	DL,MSR			;Back to base

	MOV	CL,[C_Status+BX]	;CL <- Status register
	MOV	CH,[C_Ctrl+BX]		;CH <- Control register

;	Control CTS status flag based on CTS status and handshake enable

	TEST	CH,00000010b		;CTS handshake enabled ?
	JZ	Msc2			; No, ignore CTS status
	TEST	AL,00010000b		;CTS asserted ?
	JNZ	Msc1			; Yes, enable transmit
	OR	CL,01000000b		;CTS inactive - hard handshake on
	JMP	Msc2			;
Msc1:	AND	CL,10111111b		;CTS active - hard handshake off
Msc2:	MOV	[C_Status+BX],CL	;Save status flags

;	Determine if transmitter should be enabled

Msc3:	ADD	DL,IER			;DX <- 8250 IER port address
	IN	AL,DX			;AL <- Interrupt enable register
	OR	AL,00000010b		;Enable transmitter by default
	TEST	CL,11000100b		;Enable transmitter ?
	JZ	Msc4			; Yes
	AND	AL,11111101b		; No - disable transmitter
Msc4:	OUT	DX,AL			;Update IER
	JMP	INT_Id			;Exit

;*******************************************************
;		Character transmitted
;*******************************************************

; Register usage:
; AH : Status register
; BX : Array pointer
; DX : Port address
; SI : Output tail pointer
; DI : Output head pointer

;	Get status and control registers

ComXmt:	MOV	AH,[C_Status+BX]	;AH <- Status register
	TEST	AH,00000100b		;Buffer empty ?
	JNZ	Xmt2			; Yes, stop transmitter

;	Bump tail pointer

	PUSH	BX			;Save byte array pointer
	SHL	BL,1			;BX <- Word array pointer
	MOV	SI,[C_OutTail+BX]	;SI <- Output tail pointer
	MOV	DI,[C_OutHead+BX]	;DI <- Output head pointer

	INC	SI			;Bump tail pointer
	CMP	SI,[C_OutSize+BX]	;Tail < Buffer size ?
	JB	Xmt1			; Yes, proceed normally
	XOR	SI,SI			; No, reset to 0
Xmt1:	MOV	[C_OutTail+BX],SI	;Save tail pointer

        DEC     [C_buffull+bx]          ;Decrement chars in buffer
;        INC     [C_charsend+bx]

;	Send character

	SHL	BL,1			;BX <- Pointer array pointer
	LES	BX,[C_OutBufPtr+BX]	;ES:BX <- Pointer to output buffer
	MOV	AL,[ES:BX+SI]		;AL <- Character from buffer
	OUT	DX,AL			;Send
	POP	BX			;Recover byte array pointer

;	Determine if buffer is empty
;	Reset output-buffer-full flag & exit

	CMP	DI,SI			;Head = Tail (buffer empty) ?
	JNZ	Xmt2			; No, continue normally
	OR	AH,00000100b		;Set buffer-empty flag
Xmt2:	AND	AH,11010111b		;Reset FULL and OVERFLOW flags
	MOV	[C_Status+BX],AH	;Save status flags
	JMP	Msc0			;Exit (check xmit mask)

;*******************************************************
;		Character received
;*******************************************************

; Register usage:
; AL : Status register
; AH : Control register
; BX : Array index
; CL : Character received
; CH : Temporary storage
; DX : Port address
; SI : Input tail pointer
; DI : Input head pointer

ComRcv:	IN	AL,DX			;
	MOV	CL,AL			;CL <- Received character

;	Check for software handshake

	MOV	AL,[C_Status+BX]	;AL <- Status byte
	MOV	AH,[C_Ctrl+BX]		;AH <- Control byte
	TEST	AH,00000100b		;Software handshake enabled ?
	JZ	Rcv3			; No, don't check software handshake
	CMP	CL,[C_StopChar+BX]	;STOP TRANSMIT character ?
	JZ	Rcv1			; Yes
	CMP	CL,[C_StartChar+BX]	;START TRANSMIT character ?
	JNZ	Rcv3			; No

;	Soft-handshake character received.
;	Activate or deactive transmitter depending on status

	AND	AL,01111111b		;Reset soft-handshake flag (start)
	JMP	Rcv2			;Save status & exit
Rcv1:	OR	AL,10000000b		;Set soft-handshake flag (stop)
Rcv2:	MOV	CL,AL			;Routines in MSC2 require status in CL
	JMP	Msc2			;Exit (xmit interrupt controlled here)

;	Clear buffer empty flag / check for buffer overflow


Rcv3:	AND	AL,11111110b		;Clear buffer-empty flag
	TEST	AL,00000010b		;Buffer full ?
	JZ	Rcv4			; No, continue
	OR	AL,00010000b		;Set overflow flag
	JMP	Rcv10			;Exit

;	Bump receive buffer pointer

Rcv4:	SHL	BL,1			;BX <- Word array index
	MOV	DI,[C_InHead+BX]	;DI <- Input head pointer
	MOV	SI,[C_InTail+BX]	;SI <- Input tail pointer

	INC	DI			;Bump buffer pointer
	CMP	DI,[C_InSize+BX]	;Head > buffer size ?
	JB	Rcv5			; No, continue
	XOR	DI,DI			; Yes, reset pointer

;	Store character in buffer

Rcv5:	PUSH	BX			;Save word array pointer
	MOV	[C_InHead+BX],DI	;Save updated input head pointer
	SHL	BL,1			;BX <- Doubleword array index
	LES	BX,[C_InBufPtr+BX]	;ES:BX <- Pointer to buffer
	MOV	[ES:BX+DI],CL		;Save character in buffer
	POP	BX			;Recover word array pointer

;	Check for full buffer

	CMP	SI,DI			;Tail = Head ?
	JNZ	Rcv6			;If Tail <> Head, buffer is not full
	OR	AL,00000010b		;Set buffer-full flag
	JMP	Rcv8			;Reset RTS and exit

;	Check for near-full buffer (buffer used >= RTSOff)

Rcv6:	CMP	SI,DI			;Tail <= Head ?
	JBE	Rcv7			; Yes, use standard formula
	SUB	SI,DI			;SI <- Tail - Head
	MOV	DI,[C_InSize+BX]	;DI <- Input buffer size
Rcv7:	SUB	DI,SI			;DI <- Head - Tail (amt used)
	CMP	DI,[C_RTSOff+BX]	;Used < Limit ?
	JB	Rcv9			; Yes, leave RTS on

;	Buffer is (near) full, force RTS off & exit

Rcv8:	TEST	AH,00000001b		;RTS handshake enabled ?
	JZ	Rcv9			; No, exit now

	MOV	CH,AL			;Keep status byte
	ADD	DL,MCR			;DX <- Address of modem control reg.
	IN	AL,DX			;AL <- MCR
	AND	AL,11111101b		;Disable RTS
	OUT	DX,AL			;Update MCR
	SUB	DL,MCR			;DX <- Base of port
	MOV	AL,CH			;Recover status byte

;	Exit - receive

Rcv9:	SHR	BL,1			;BX <- Byte array index
Rcv10:	MOV	[C_Status+BX],AL	;Save status byte

;	The following code corrects a "bug" present in some 8250's

	ADD	DL,IER			;DX <- Interrupt Enable Register
	IN	AL,DX			;AL <- IER
	MOV	AH,AL			;Save IER
	AND	AL,11111101b		;Mask off transmit interrupt
	OUT	DX,AL			;Send to IER
	MOV	AL,AH			;
        NOP                             ;Slow down for slow machines
        NOP
	OUT	DX,AL			;Restore original IER state

	JMP	INT_Id			;Check for pending INTs and exit

	ENDP	INT_Handler

;********************************************************
;*							*
;*	Start of Pascal low-level procedures		*
;*							*
;********************************************************
;*							*
;*	Function ComReadCh(ComPort:Byte) : Char		*
;*							*
;********************************************************

	PROC	ComReadCh 	FAR

	CLI				;Interrupts disabled

	MOV	BX,SP			;BX <- Stack pointer
	MOV	AL,[SS:BX+4]		;AL <- Port #

        dec     al                      ;Adjust port number (COM1=0)
        xor     bh,bh                   ;Nuke BH
        mov     bl,al                   ;Get byte index into BL
        shl     bl,1                    ;Convert to word index
        mov     dx,[C_Portaddr+BX]      ;Get port base address
        shr     bl,1                    ;Convert back to byte index

;	Check buffer, return null if empty

	MOV	AH,[C_Status+BX]	;AH <- Status byte
	TEST	AH,00000001b		;Buffer empty ?
	JZ	ComRd2			; No, continue normally

;	Buffer empty, port not open or port # invalid - exit

ComRd1:	MOV	CH,0			;Return null (port error or empty)
ComRdX:	MOV	AL,CH			;AL <- Char from buffer
	STI				;Enable interrupts
	RET	2			;Exit

;	Increment tail pointer
;	NOTE: Entry point for ComReadChW

ComRd2:	SHL	BL,1			;BX <- Word array index
	MOV	SI,[C_InTail+BX]	;SI <- Tail pointer
	MOV	DI,[C_InHead+BX]	;DI <- Input head pointer
	INC	SI			;Bump tail pointer
	CMP	SI,[C_InSize+BX]	;Tail past end of buffer ?
	JB	ComRd3			; No, continue
	XOR	SI,SI			; Yes, reset pointer
ComRd3:	MOV	[C_InTail+BX],SI	;Save updated tail pointer

;	Get character from buffer

	SHL	BL,1			;BX <- Pointer array index
	LES	BX,[C_InBufPtr+BX]	;ES:BX <- Pointer to input buffer
	MOV	CH,[ES:BX+SI]		;CH <- Character from buffer

;	Clear FULL and OVERFLOW flags
;	Check for empty buffer

	XOR	BH,BH			;
	MOV	BL,AL			;Byte array index
	AND	AH,11101101b		;Reset FULL and OVERFLOW status flags
	CMP	DI,SI			;Head = Tail (buffer empty ?)
	JNZ	ComRd4			; No, continue normally
	OR	AH,00000001b		; Yes, set empty flag
ComRd4:	MOV	[C_Status+BX],AH	;Save status byte

        MOV     AL,[c_ctrl+bx]          ;get control byte in AL
        TEST    AL,00000001b            ;is RTS handshake enabled?
        JZ      ComRdX                  ;no, exit


;	Check for RTS assert (Used <= RTSOn)
;	Variable USED (# of used bytes in buffer) calculated as :
;	  IF (Head >= Tail) THEN
;	    Used = Head-Tail
;	  ELSE
;	    Used = BufferSize - (Tail-Head)

	SHL	BL,1			;BX <- Word array index
	CMP	DI,SI			;Head >= Tail ?
	JAE	ComRd5			; Yes, use alternate formula
	SUB	SI,DI			;SI <- Tail - Head
	MOV	DI,[C_InSize+BX]	;DI <- Input buffer size
ComRd5:	SUB	DI,SI			;DI <- Amount of buffer used
	CMP	DI,[C_RTSOn+BX]		;Used > Limit ?
	JA	ComRdX			; Yes, not ready for receive

;	Here to assert RTS

	ADD	DL,MCR			;DX <- 8250 MCR port address
	IN	AL,DX			;AL <- 8250 MCR
	OR	AL,00000010b		;Assert RTS
        NOP                             ;Slow down for slow machines
        NOP
	OUT	DX,AL			;Send to port
	JMP	ComRdX			;Exit

	ENDP	ComReadCh

;********************************************************
;*							*
;*	Function ComReadChW(ComPort:Byte) : Char	*
;*							*
;********************************************************

	PROC	ComReadChW	FAR

	MOV	BX,SP			;BX <- Stack pointer
	MOV	AL,[SS:BX+4]		;AL <- Port #

        dec     al                      ;Adjust port number (COM1=0)
        xor     bh,bh                   ;Nuke BH
        mov     bl,al                   ;Get byte index into BL
        shl     bl,1                    ;Convert to word index
        mov     dx,[C_Portaddr+BX]      ;Get port base address
        shr     bl,1                    ;Convert back to byte index

;	Wait for character

ComRW1:	MOV	AH,[C_Status+BX]	;AL <- Status byte
	TEST	AH,00000001b		;Input buffer empty ?
	JNZ	ComRW1			; Yes, continue waiting

	CLI				;Disable interrupts
	JMP	ComRd2			;Proceed with normal read

	ENDP	ComReadChW

;********************************************************
;*							*
;*    Procedure ComWriteCh(ComPort:Byte; Var Ch:Char)	*
;*							*
;********************************************************

	PROC	ComWriteCh	FAR

;	Check port # for validity

	MOV	BX,SP			;Point BX at parameters
	MOV	AL,[SS:BX+6]		;AL <- Port #
	MOV	CH,[SS:BX+4]		;CH <- Character to send

        dec     al                      ;Adjust port number (COM1=0)
        xor     bh,bh                   ;Nuke BH
        mov     bl,al                   ;Get byte index into BL
        shl     bl,1                    ;Convert to word index
        mov     dx,[C_Portaddr+BX]      ;Get port base address
        shr     bl,1                    ;Convert back to byte index

        mov     ah, [c_status+bx]       ;get status word for PUTCHAR

	CLI				;Disable interrupts
	PutChar	                        ;Place character in buffer (AL nuked)
	STI				;Enable interrupts

ComWr1:	RET	4			;Exit

	ENDP	ComWriteCh

;********************************************************
;*							*
;*   Procedure ComWriteChW(ComPort:Byte; Var Ch:Char)	*
;*							*
;********************************************************

	PROC	ComWriteChW	FAR

;	Check port # for validity

	MOV	BX,SP			;Point BX at parameters
	MOV	AL,[SS:BX+6]		;AL <- Port #
	MOV	CH,[SS:BX+4]		;CH <- Character to send

        dec     al                      ;Adjust port number (COM1=0)
        xor     bh,bh                   ;Nuke BH
        mov     bl,al                   ;Get byte index into BL
        shl     bl,1                    ;Convert to word index
        mov     dx,[C_Portaddr+BX]      ;Get port base address
        shr     bl,1                    ;Convert back to byte index

;	Wait for buffer to open up

ComWW1:	MOV	AH,[C_Status+BX]	;AH <- Status byte
	TEST	AH,00101000b		;Buffer filled ?
	JNZ	ComWW1			; Yes, loop until open

	CLI				;Turn off interrupts
	PutChar			        ;Place character in buffer (AL nuked)
	STI				;Enable interrupts

ComWW2:	RET	4			;Exit

	ENDP	ComWriteChW

;********************************************************

	ENDS	CODE
	END
