{*--------------------------------------------------------------------------*}
{*                                                                          *}
{*  Status byte definition (C_Status):                                      *}
{*                                                                          *}
{*  7   6   5   4   3   2   1   0                                           *}
{*  |   |   |   |   |   |   |   |____ Input buffer empty                    *}
{*  |   |   |   |   |   |   |________ Input buffer full                     *}
{*  |   |   |   |   |   |____________ Output buffer empty                   *}
{*  |   |   |   |   |________________ Output buffer full                    *}
{*  |   |   |   |____________________ Input buffer overflow                 *}
{*  |   |   |________________________ Output buffer overflow                *}
{*  |   |____________________________ Hard handshake active (xmit stopped)  *}
{*  |________________________________ Soft handshake active (xmit stopped)  *}
{*                                                                          *}
{*  Control byte definition (C_Ctrl):                                       *}
{*                                                                          *}
{*  7   6   5   4   3   2   1   0                                           *}
{*  |   |   |   |   |   |   |   |____ Enable RTS handshake                  *}
{*  |   |   |   |   |   |   |________ Enable CTS handshake                  *}
{*  |   |   |   |   |   |____________ Enable software handshake             *}
{*  |   |   |   |   |________________                                       *}
{*  |   |   |   |____________________                                       *}
{*  |   |   |________________________                                       *}
{*  |   |____________________________                                       *}
{*  |________________________________                                       *}
{*                                                                          *}
{****************************************************************************}

{$R-,V-,B-,S-}

Unit ASYNC2;

INTERFACE

{----------------------------------------------------------------------------}

Const
  C_MinBaud = 300;
  C_MaxBaud = 115200;
  C_MaxPort = 4;
  C_MaxCom : byte = C_MaxPort;
  D_PortAddr : Array[1..C_MaxPort] Of Word = ($03F8,$02F8,$03E8,$02E8);
  D_PortInt  : Array[1..C_MaxPort] Of Byte = (4,3,4,3);

{----------------------------------------------------------------------------}

Type
  C_VectorArray  = Array[0..15] Of Pointer;
  C_PointerArray = Array[1..C_MaxPort]  Of Pointer;
  C_WordArray    = Array[1..C_MaxPort] Of Word;
  C_ByteArray    = Array[1..C_MaxPort] Of Byte;
  C_CharArray    = Array[1..C_MaxPort] Of Char;
  C_BooleanArray = Array[1..C_MaxPort] Of Boolean;

{----------------------------------------------------------------------------}

Var
  { Base port addresses & interrupt usage }
  C_PortAddr : Array[1..C_MaxPort] Of Word;
  C_PortInt  : Array[1..C_MaxPort] Of Byte;
  ComPort  : Byte;
  C_InBufPtr,C_OutBufPtr : C_PointerArray;    { Input/output buffer pointers }
  C_InHead,C_OutHead     : C_WordArray;       { Input/output head pointers }
  C_InTail,C_OutTail     : C_WordArray;       { Input/output tail pointers }
  C_InSize,C_OutSize     : C_WordArray;       { Input/output buffer sizes }
  C_RTSOn,C_RTSOff       : C_WordArray;       { RTS assert/drop buffer points }
  C_StartChar,C_StopChar : C_CharArray;       { Soft hndshake start/stop char }
  C_Status,C_Ctrl        : C_ByteArray;       { STATUS and CONTROL registers }
  C_XL3Ptr               : C_ByteArray;
  C_PortOpen             : C_BooleanArray;    { Port open/close flags }
  C_Temp                 : Word;              { Used for debugging }
  C_msrport              : word;
{ RTSOn,RTSOff           : Word;}             { RTS assert/drop buffer points }
  oldier,oldmcr          : byte;
  c_buffull              : c_wordarray;
  C_Cascade              : Byte;              { Flag set 0 normally }
  C_CascadeOK            : boolean;           { Flag if IRQ > 7 }

{----------------------------------------------------------------------------}

Function  ComReadCh(ComPort:Byte) : Char;
Function  ComReadChW(ComPort:Byte) : Char;
{ Procedure ComWriteCh(ComPort:Byte; Ch:Char); }
Procedure ComWriteChW(ComPort:Byte; Ch:Char);
Procedure SetDTR(ComPort:Byte; Assert:Boolean);
Procedure SetRTS(ComPort:Byte; Assert:Boolean);
{
Procedure SetOUT1(ComPort:Byte; Assert:Boolean);
Procedure SetOUT2(ComPort:Byte; Assert:Boolean);
 }
Function  CTSStat(ComPort:Byte) : Boolean;
Function  RTSStat(ComPort:Byte) : Boolean;
Function  DSRStat(ComPort:Byte) : Boolean;
Function  RIStat(ComPort:Byte) : Boolean;
Function  DCDStat(ComPort:Byte) : Boolean;
Procedure SetRTSMode(ComPort:Byte; Mode:Boolean; RTSOn,RTSOff:Word);
Procedure SetCTSMode(ComPort:Byte; Mode:Boolean);
Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char);
Procedure ClearCom(ComPort:Byte; IO:Char);
Function  ComBufferLeft(ComPort:Byte; IO:Char) : Word;
Procedure ComWaitForClear(ComPort:Byte);
Procedure ComWrite(ComPort:Byte; St:String);
Procedure ComWriteln(ComPort:Byte; St:String);
Procedure ComWriteWithDelay(ComPort:Byte; St:String; Dly:Word);
Procedure ComReadln(ComPort:Byte; Var St:String; Size:Byte; Echo:Boolean);
Function  ComExist(ComPort:Byte) : Boolean;
Function  ComTrueBaud(Baud:Longint) : Real;
Procedure ComParams(ComPort:Byte; Baud:LongInt; WordSize:Byte; Parity:Char; StopBits:Byte);
Function  OpenCom(ComPort:Byte; InBufferSize,OutBufferSize:Word) : Boolean;
Procedure CloseCom(ComPort:Byte);
Procedure CloseAllComs;

{----------------------------------------------------------------------------}

IMPLEMENTATION

Uses DOS,CRT;

{$L SLASYNC.OBJ}

Const
  C_IER = 1;                           { 8250 register offsets }
  C_IIR = 2;
  C_LCR = 3;
  C_MCR = 4;
  C_LSR = 5;
  C_MSR = 6;
  C_SCR = 7;

Var
  C_OldINTVec : C_VectorArray;        { Storage for old hardware INT vectors }
  X : Byte;                            { Used by initialization code }

{****************************************************************************}
{*                                                                          *}
{*  Procedure INT_Handler; External;                                        *}
{*                                                                          *}
{*  Hardware interrupts 0-15 (vectors $08 - $0F,$70 - $77) are pointed to   *}
{*  this routine.  It is for internal use only and should NOT be called     *}
{*  directly.  Written in assembly language (see SLASYNC.ASM).              *}
{*                                                                          *}
{****************************************************************************}

Procedure INT_Handler; External;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComReadCh(ComPort:Byte) : Char; External;                     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                                                                          *}
{*  Returns character from input buffer of specified port.  If the buffer   *}
{*  is empty, the port # invalid or not opened, a Chr(0) is returned.       *}
{*  Written in assembly language for best possible speed (see ASYNC11.ASM)  *}
{*                                                                          *}
{****************************************************************************}

Function ComReadCh(ComPort:Byte) : Char; External;

{****************************************************************************}
{*                                                                          *}
{*  Function ComReadChW(ComPort:Byte) : Char; External;                     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                                                                          *}
{*  Works like ComReadCh, but will wait until at least 1 character is       *}
{*  present in the specified input buffer before exiting.  Thus, ComReadChW *}
{*  works much like the ReadKey predefined function.  Written in assembly   *}
{*  language to maximize performance (see ASYNC11.ASM)                      *}
{*                                                                          *}
{****************************************************************************}

Function ComReadChW(ComPort:Byte) : Char; External;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteCh(ComPort:Byte; Ch:Char); External                   *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*  Ch:Char       ->  Character to send                                     *}
{*                                                                          *}
{*  Places the character [Ch] in the transmit buffer of the specified port. *}
{*  If the port specified is not open or nonexistent, or if the buffer is   *}
{*  filled, the character is discarded.  Written in assembly language to    *}
{*  maximize performance (see ASYNC11.ASM)                                  *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteCh(ComPort:Byte; Ch:Char); External;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteChW(ComPort:Byte; Ch:Char); External;                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*  Ch:Char       ->  Character to send                                     *}
{*                                                                          *}
{*  Works as ComWriteCh, but will wait until at least 1 free position is    *}
{*  available in the output buffer before attempting to place the character *}
{*  [Ch] in it.  Allows the programmer to send characters without regard to *}
{*  available buffer space.  Written in assembly language to maximize       *}
{*  performance (see ASYNC11.ASM)                                           *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteChW(ComPort:Byte; Ch:Char); External;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetDTR(ComPort:Byte; Assert:Boolean);                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  DTR assertion flag (TRUE to assert DTR)             *}
{*                                                                          *}
{*  Provides a means to control the port's DTR (Data Terminal Ready) signal *}
{*  line.  When [Assert] is TRUE, the DTR line is placed in the "active"    *}
{*  state, signalling to a remote system that the host is "on-line"         *}
{*  (although not nessesarily ready to receive data - see SetRTS).          *}
{*                                                                          *}
{****************************************************************************}

Procedure SetDTR(ComPort:Byte; Assert:Boolean);

Var
  P,X : Integer;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then Exit;
  P := C_PortAddr[ComPort];

  X := Port[P+C_MCR];
  If Assert Then
    X := X Or $01
  Else
    X := X And $FE;
  Port[P+C_MCR] := X;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetRTS(ComPort:Byte; Assert:Boolean)                          *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  RTS assertion flag (Set TRUE to assert RTS)         *}
{*                                                                          *}
{*  SetRTS allows a program to manually control the Request-To-Send (RTS)   *}
{*  signal line.  If RTS handshaking is disabled (see C_Ctrl definition     *}
{*  and the the SetRTSMode procedure), this procedure may be used.  SetRTS  *}
{*  should NOT be used if RTS handshaking is enabled.                       *}
{*                                                                          *}
{****************************************************************************}

Procedure SetRTS(ComPort:Byte; Assert:Boolean);

Var
  P,X : Integer;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then Exit;
  P := C_PortAddr[ComPort];

  X := Port[P+C_MCR];
  If Assert Then
    X := X Or $02
  Else
    X := X And $FD;
  Port[P+C_MCR] := X;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetOUT1(ComPort:Byte; Assert:Boolean)                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  OUT1 assertion flag (set TRUE to assert OUT1 line)  *}
{*                                                                          *}
{*  SetOUT1 is provided for reasons of completeness only, since the         *}
{*  standard PC/XT/AT configurations do not utilize this control signal.    *}
{*  If [Assert] is TRUE, the OUT1 signal line on the 8250 will be set to a  *}
{*  LOW logic level (inverted logic).  The OUT1 signal is present on pin 34 *}
{*  of the 8250 (but not on the port itself).                               *}
{*                                                                          *}
{****************************************************************************}
{
Procedure SetOUT1(ComPort:Byte; Assert:Boolean);

Var
  P,X : Integer;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then Exit;
  P := C_PortAddr[ComPort];

  X := Port[P+C_MCR];
  If Assert Then
    X := X Or $04
  Else
    X := X And $FB;
  Port[P+C_MCR] := X;
End;
 }
{****************************************************************************}
{*                                                                          *}
{*  Procedure SetOUT2(ComPort:Byte; Assert:Boolean)                         *}
{*                                                                          *}
{*  ComPort:Byte    ->  Port # to use (1 - C_MaxCom)                        *}
{*                      Call ignored if out-of-range                        *}
{*  Assert:Boolean  ->  OUT2 assertion flag (set TRUE to assert OUT2 line)  *}
{*                                                                          *}
{*  The OUT2 signal line, although not available on the port itself, is     *}
{*  used to gate the 8250 <INTRPT> (interrupt) line and thus acts as a      *}
{*  redundant means of controlling 8250 interrupts.  When [Assert] is TRUE, *}
{*  the /OUT2 line on the 8250 is lowered, which allows the passage of the  *}
{*  <INTRPT> signal through a gating arrangement, allowing the 8250 to      *}
{*  generate interrupts.  Int's can be disabled bu unASSERTing this line.   *}
{*                                                                          *}
{****************************************************************************}
{
Procedure SetOUT2(ComPort:Byte; Assert:Boolean);

Var
  P,X : Integer;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then Exit;
  P := C_PortAddr[ComPort];

  X := Port[P+C_MCR];
  If Assert Then
    X := X Or $08
  Else
    X := X And $F7;
  Port[P+C_MCR] := X;
End;
 }
{****************************************************************************}
{*                                                                          *}
{*  Function CTSStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*  Returns status of Clear-To-Send line (TRUE if CTS asserted)             *}
{*                                                                          *}
{*  CTSStat provides a means to interrogate the Clear-To-Send hardware      *}
{*  handshaking line.  In a typical arrangement, when CTS is asserted, this *}
{*  signals the host (this computer) that the receiver is ready to accept   *}
{*  data (in contrast to the DSR line, which signals the receiver as        *}
{*  on-line but not nessesarily ready to accept data).  An automated mech-  *}
{*  ansim (see CTSMode) is provided to do this, but in cases where this is  *}
{*  undesirable or inappropriate, the CTSStat function can be used to int-  *}
{*  terrogate this line manually.                                           *}
{*                                                                          *}
{****************************************************************************}

Function CTSStat(ComPort:Byte) : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then
    CTSStat := False
  Else
    CTSStat := (Port[C_PortAddr[ComPort]+C_MSR] And $10 <> $10);
End;

{****************************************************************************}
{*                                                                          *}
{*  Function RTSStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*  Returns status of Ready-To-Send line (TRUE if RTS asserted)             *}
{*                                                                          *}
{****************************************************************************}


Function RTSStat(ComPort:Byte) : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then
    RTSStat := False
  Else
    RTSStat := (Port[C_PortAddr[ComPort]+C_LSR] And $20 <> $20);
End;

{****************************************************************************}
{*                                                                          *}
{*  Function DSRStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*  Returns status of Data Set Ready (DSR) signal line.                     *}
{*                                                                          *}
{*  The Data Set Ready (DSR) line is typically used by a remote station     *}
{*  to signal the host system that it is on-line (although not nessesarily  *}
{*  ready to receive data yet - see CTSStat).  A remote station has the DSR *}
{*  line asserted if DSRStat returns TRUE.                                  *}
{*                                                                          *}
{****************************************************************************}

Function DSRStat(ComPort:Byte) : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then
    DSRStat := False
  Else
    DSRStat := (Port[C_PortAddr[ComPort]+C_MSR] And $20) > 0;
End;

{****************************************************************************}
{*                                                                          *}
{*  Function RIStat(ComPort:Byte) : Boolean                                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*                                                                          *}
{*  Returns the status of the Ring Indicator (RI) line.  This line is       *}
{*  typically used only by modems, and indicates that the modem has detect- *}
{*  ed an incoming call if RIStat returns TRUE.                             *}
{*                                                                          *}
{****************************************************************************}

Function RIStat(ComPort:Byte) : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then
    RIStat := False
  Else
    RIStat := (Port[C_PortAddr[ComPort]+C_MSR] And $40) > 0;
End;

{****************************************************************************}
{*                                                                          *}
{*  Function DCDStat(ComPort:Byte) : Boolean                                *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Call ignored if out-of-range                          *}
{*                                                                          *}
{*  Returns the status of the Data Carrier Detect (DCD) line from the rem-  *}
{*  ote device, typically a modem.  When asserted (DCDStat returns TRUE),   *}
{*  the modem indicates that it has successfuly linked with another modem   *}
{*  device at another site.                                                 *}
{*                                                                          *}
{****************************************************************************}

Function DCDStat(ComPort:Byte) : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Then
    DCDStat := False
  Else
    DCDStat := (Port[C_PortAddr[ComPort]+C_MSR] And $80) > 0;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetRTSMode(ComPort:Byte; Mode:Boolean; RTSOn,RTSOff:Word)     *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  TRUE to enable automatic RTS handshake                *}
{*  RTSOn:Word    ->  Buffer-usage point at which the RTS line is asserted  *}
{*  RTSOff:Word   ->  Buffer-usage point at which the RTS line is dropped   *}
{*                                                                          *}
{*  SetRTSMode enables or disables automated RTS handshaking.  If [MODE] is *}
{*  TRUE, automated RTS handshaking is enabled.  If enabled, the RTS line   *}
{*  will be DROPPED when the # of buffer bytes used reaches or exceeds that *}
{*  of [RTSOff].  The RTS line will then be re-asserted when the buffer is  *}
{*  emptied down to the [RTSOn] usage point.  If either [RTSOn] or [RTSOff] *}
{*  exceeds the input buffer size, they will be forced to (buffersize-1).   *}
{*  If [RTSOn] > [RTSOff] then [RTSOn] will be the same as [RTSOff].        *}
{*  The actual handshaking control is located in the interrupt driver for   *}
{*  the port (see ASYNC11.ASM).                                             *}
{*                                                                          *}
{****************************************************************************}

Procedure SetRTSMode(ComPort:Byte; Mode:Boolean; RTSOn,RTSOff:Word);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxPort) Or (Not C_PortOpen[ComPort]) Then Exit;

  X := C_Ctrl[ComPort];
  If Mode Then X := X Or $01 Else X := X And $FE;
  C_Ctrl[ComPort] := X;

  If Mode Then
    Begin
      If (RTSOff >= C_InSize[ComPort]) Then RTSOff := C_InSize[ComPort] - 1;
      If (RTSOn > RTSOff) Then RTSOff := RTSOn;
      C_RTSOn[ComPort] := RTSOn;
      C_RTSOff[ComPort] := RTSOff;
    End;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SetCTSMode(ComPort:Byte; Mode:Boolean)                        *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  Set to TRUE to enable automatic CTS handshake.        *}
{*                                                                          *}
{*  SetCTSMode allows the enabling or disabling of automated CTS handshak-  *}
{*  ing.  If [Mode] is TRUE, CTS handshaking is enabled, which means that   *}
{*  if the remote drops the CTS line, the transmitter will be disabled      *}
{*  until the CTS line is asserted again.  Automatic handshake is disabled  *}
{*  if [Mode] is FALSE.  CTS handshaking and "software" handshaking (pro-   *}
{*  vided by the SoftHandshake procedure) ARE compatable and may be used    *}
{*  in any combination.  The actual logic for CTS handshaking is located    *}
{*  in the communications interrupt driver (see ASYNC11.ASM).               *}
{*                                                                          *}
{****************************************************************************}

Procedure SetCTSMode(ComPort:Byte; Mode:Boolean);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxPort) Or (Not C_PortOpen[ComPort]) Then Exit;

  X := C_Ctrl[ComPort];
  If Mode Then X := X Or $02 Else X := X And $FD;
  C_Ctrl[ComPort] := X;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char)    *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  Mode:Boolean  ->  Set to TRUE to enable transmit software handshake     *}
{*  Start:Char    ->  START control character (usually ^Q)                  *}
{*                    Defaults to ^Q if character passed is >= <Space>      *}
{*  Stop:Char     ->  STOP control character (usually ^S)                   *}
{*                    Defaults to ^S if character passed is >= <Space>      *}
{*                                                                          *}
{*  SoftHandshake controls the usage of "Software" (control-character)      *}
{*  handshaking on transmission.  If "software handshake" is enabled        *}
{*  ([Mode] is TRUE), transmission will be halted if the character in       *}
{*  [Stop] is received.  Transmission is re-enabled if the [Start] char-    *}
{*  acter is received.  Both the [Start] and [Stop] characters MUST be      *}
{*  CONTROL characters (i.e. Ord(Start) and Ord(Stop) must both be < 32).   *}
{*  Also, <Start> and <Stop> CANNOT be the same character.  If either one   *}
{*  of these restrictions are violated, the defaults (^Q for <Start> and ^S *}
{*  for <Stop>) will be used.  Software handshaking control is implimented  *}
{*  within the communications interrupt driver (see ASYNC11.ASM).           *}
{*                                                                          *}
{****************************************************************************}

Procedure SoftHandshake(ComPort:Byte; Mode:Boolean; Start,Stop:Char);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxPort) Or (Not C_PortOpen[ComPort]) Then Exit;

  X := C_Ctrl[ComPort];
  If Mode Then
    Begin
      X := X Or $04;
      If Start=Stop Then Begin Start := ^Q; Stop := ^S; End;
      If Start>#32 Then Start := ^Q;
      If Stop>#32 Then Stop := ^S;
      C_StartChar[ComPort] := Start;
      C_StopChar[ComPort] := Stop;
    End
  Else
    X := X And $FB;
  C_Ctrl[ComPort] := X;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ClearCom(ComPort:Byte); IO:Char)                              *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Request ignored if out of range or unopened.          *}
{*  IO:Char       ->  Action code; I=Input, O=Output, B=Both                *}
{*                    No action taken if action code unrecognized.          *}
{*                                                                          *}
{*  ClearCom allows the user to completely clear the contents of either     *}
{*  the input (receive) and/or output (transmit) buffers.  The "action      *}
{*  code" passed in <IO> determines if the input (I) or output (O) buffer   *}
{*  is cleared.  Action code (B) will clear both buffers.  This is useful   *}
{*  if you wish to cancel a transmitted message or ignore part of a         *}
{*  received message.                                                       *}
{*                                                                          *}
{****************************************************************************}

Procedure ClearCom(ComPort:Byte; IO:Char);

Var
  P,X : Word;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;

  IO := Upcase(IO);
  P := C_PortAddr[ComPort];

  Inline($FA);
  If (IO='I') Or (IO='B') Then
    Begin
      C_InHead[ComPort] := 0;
      C_InTail[ComPort] := 0;
      C_Status[ComPort] := (C_Status[ComPort] And $EC) Or $01;
      X := Port[P] + Port[P+C_LSR] + Port[P+C_MSR] + Port[P+C_IIR];
    End;
  If (IO='O') Or (IO='B') Then
    Begin
      C_OutHead[ComPort] := 0;
      C_OutTail[ComPort] := 0;
      C_Status[ComPort] := (C_Status[ComPort] And $D3) Or $04;
      X := Port[P+C_LSR] + Port[P+C_MSR] + Port[P+C_IIR];
    End;
  Inline($FB);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComBufferLeft(ComPort:Byte; IO:Char) : Word                   *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Returns 0 if Port # invalid or unopened.              *}
{*  IO:Char       ->  Action code; I=Input, O=Output                        *}
{*                    Returns 0 if action code unrecognized.                *}
{*                                                                          *}
{*  ComBufferLeft will return a number (bytes) indicating how much space    *}
{*  remains in the selected buffer.  The INPUT buffer is checked if <IO> is *}
{*  (I), and the output buffer is interrogated when <IO> is (O).  Any other *}
{*  "action code" will return a result of 0.  Use this function when it is  *}
{*  important to avoid program delays due to calls to output procedures or  *}
{*  to prioritize the reception of data (to prevent overflows).             *}
{*                                                                          *}
{****************************************************************************}

Function ComBufferLeft(ComPort:Byte; IO:Char) : Word;

Begin
  ComBufferLeft := 0;
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;
  IO := Upcase(IO);

  If IO = 'I' Then
    If C_InHead[ComPort] >= C_InTail[ComPort] Then
      ComBufferLeft := C_InSize[ComPort]-(C_InHead[ComPort]-C_InTail[ComPort])
    Else
      ComBufferLeft := C_InTail[ComPort]-C_InHead[ComPort];

  If IO = 'O' Then
    If C_OutHead[ComPort] >= C_OutTail[ComPort] Then
      ComBufferLeft := C_OutHead[ComPort]-C_OutTail[ComPort]
    Else
      ComBufferLeft := C_OutSize[ComPort]-(C_OutTail[ComPort]-C_OutHead[ComPort]);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWaitForClear(ComPort:Byte)                                 *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*                                                                          *}
{*  A call to ComWaitForClear will stop processing until the selected out-  *}
{*  put buffer is completely emptied.  Typically used just before a call    *}
{*  to the CloseCom procedure to prevent premature cut-off of messages in   *}
{*  transit.                                                                *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWaitForClear(ComPort:Byte);

Var
  Empty : Boolean;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;
  Repeat
    Empty := (C_Status[ComPort] And $04) = $04;
    Empty := Empty And ((Port[C_PortAddr[ComPort]+C_IER] And $02) = $00);
  Until Empty;
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWrite(ComPort:Byte; St:String)                             *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*                                                                          *}
{*  Sends string <St> out communications port <ComPort>.                    *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWrite(ComPort:Byte; St:String);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;

  For X := 1 To Length(St) Do
    ComWriteChW(ComPort,St[X]);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteln(ComPort:Byte; St:String);                          *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*                                                                          *}
{*  Sends string <St> with a CR and LF appended.                            *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteln(ComPort:Byte; St:String);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;

  For X := 1 To Length(St) Do
    ComWriteChW(ComPort,St[X]);
  ComWriteChW(ComPort,#13);
  ComWriteChW(ComPort,#10);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComWriteWithDelay(ComPort:Byte; St:String; Dly:Word);         *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     ->  String to send                                        *}
{*  Dly:Word      ->  Time, in milliseconds, to delay between each char.    *}
{*                                                                          *}
{*  ComWriteWithDelay will send string <St> to port <ComPort>, delaying     *}
{*  for <Dly> milliseconds between each character.  Useful for systems that *}
{*  cannot keep up with transmissions sent at full speed.                   *}
{*                                                                          *}
{****************************************************************************}

Procedure ComWriteWithDelay(ComPort:Byte; St:String; Dly:Word);

Var
  X : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;

  ComWaitForClear(ComPort);
  For X := 1 To Length(St) Do
    Begin
      ComWriteChW(ComPort,St[X]);
      ComWaitForClear(ComPort);
      Delay(Dly);
    End;
End;

{****************************************************************************}
{*                                                                          *}
{* Procedure ComReadln(ComPort:Byte; Var St:String; Size:Byte; Echo:Boolean)*}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom).                         *}
{*                    Exits immediately if out of range or port unopened.   *}
{*  St:String     <-  Edited string from remote                             *}
{*  Size:Byte;    ->  Maximum allowable length of input                     *}
{*  Echo:Boolean; ->  Set TRUE to echo received characters                  *}
{*                                                                          *}
{*  ComReadln is the remote equivalent of the standard Pascal READLN pro-   *}
{*  cedure with some enhancements.  ComReadln will accept an entry of up to *}
{*  40 printable ASCII characters, supporting ^H and ^X editing commands.   *}
{*  Echo-back of the entry (for full-duplex operation) is optional.  All    *}
{*  control characters, as well as non-ASCII (8th bit set) characters are   *}
{*  stripped.  If <Echo> is enabled, ASCII BEL (^G) characters are sent     *}
{*  when erroneous characters are intercepted.  Upon receipt of a ^M (CR),  *}
{*  the procedure is terminated and the final string result returned.       *}
{*                                                                          *}
{****************************************************************************}

Procedure ComReadln(ComPort:Byte; Var St:String; Size:Byte; Echo:Boolean);

Var
  Len,X : Byte;
  Ch : Char;
  Done : Boolean;

Begin
  St := '';
  If (ComPort<1) Or (ComPort>C_MaxCom) Or (Not C_PortOpen[ComPort]) Then Exit;

  Done := False;
  Repeat
    Len := Length(St);
    Ch := Chr(Ord(ComReadChW(ComPort)) And $7F);

    Case Ch Of
      ^H : If Len > 0 Then
             Begin
               Dec(Len);
               St[0] := Chr(Len);
               If Echo Then ComWrite(ComPort,#8#32#8);
             End
           Else
             ComWriteChW(ComPort,^G);
      ^M : Begin
             Done := True;
             If Echo Then ComWrite(ComPort,#13#10);
           End;
      ^X : Begin
             St := '';
             If Len = 0 Then ComWriteCh(ComPort,^G);
             If Echo Then
               For X := 1 to Len Do
                 ComWrite(ComPort,#8#32#8);
           End;
      #32..#127 : If Len < Size Then
                    Begin
                      Inc(Len);
                      St[Len] := Ch;
                      St[0] := Chr(Len);
                      If Echo Then ComWriteChW(ComPort,Ch);
                    End
                  Else
                    If Echo Then ComWriteChW(ComPort,^G);
    Else
      If Echo Then ComWriteChW(ComPort,^G)
    End;

  Until Done;
End;

{****************************************************************************}
{*                                                                          *}
{*  Function ComExist(ComPort:Byte) : Boolean                               *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
{*                    Returns FALSE if out of range                         *}
{*  Returns TRUE if hardware for selected port is detected & tests OK       *}
{*                                                                          *}
{*  Function ComExist performs a high-speed short loopback test on the      *}
{*  selected port to determine if it indeed exists.  Use this function      *}
{*  before attempts to OPEN a port for I/O (although this function is       *}
{*  called by OpenCom to prevent such an occurance).                        *}
{*  NOTE!  Although pains are taken to preserve the 8250 state before the   *}
{*  port test takes place, it is nonetheless recommended that this function *}
{*  NOT be called while a port is actually OPEN.  Doing so may cause the    *}
{*  port to behave erratically.                                             *}
{*                                                                          *}
{****************************************************************************}

Function ComExist(ComPort:Byte) : Boolean;

Const
  TestByte1 : Byte = $0F;
  TestByte2 : Byte = $F1;

Var
  P : Word;
  M,L,B1,B2 : Byte;

Begin
  ComExist := False;
  If (ComPort<1) Or (ComPort>C_MaxPort) Then Exit;

  P := C_PortAddr[ComPort];
  M := Port[P+C_MCR];                            { Save MCR }
  L := Port[P+C_LCR];                            { Save LCR }
  Port[P+C_MCR] := $10;                          { Enable loopback mode }
  Port[P+C_LCR] := $80;                          { Enable divisor latch mode }
  B1 := Port[P];                                 { Save current baud rate }
  B2 := Port[P+1];
  Port[P] := 4;                                  { Set baud rate to 28000 }
  Port[P+1] := 0;
  Port[P+C_LCR] := $03;                          { Transmit mode 28000:8N1 }

  Port[P] := TestByte1;                          { Test byte #1 }
  Delay(20);                                     { Wait a bit for loopback }
  If Port[P] <> TestByte1 Then Exit;             { Exit w/error if not echoed }
  Port[P] := TestByte2;                          { Test byte #2 }
  Delay(20);                                     { Wait a bit for loopback }
  If Port[P] <> TestByte2 Then Exit;             { Exit w/error if not echoed }

  ComExist := True;                              { Test passed: Port exists }
  Port[P+C_LCR] := $80;                          { Restore baud rate }
  Port[P] := B1;
  Port[P+1] := B2;
  Port[P+C_LCR] := L;                            { Restore parameters }
  Port[P+C_MCR] := M;                            { Restore control lines }
End;

{****************************************************************************}
{*                                                                          *}
{*  Function ComTrueBaud(Baud:Longint) : Real                               *}
{*                                                                          *}
{*  Baud:Longint  ->  User baud rate to test.                               *}
{*                    Should be between C_MinBaud and C_MaxBaud.            *}
{*  Returns the actual baud rate based on the accuracy of the 8250 divider. *}
{*                                                                          *}
{*  The ASYNC11 communications package allows the programmer to select ANY  *}
{*  baud rate, not just those that are predefined by the BIOS or other      *}
{*  agency.  Since the 8250 uses a divider/counter chain to generate it's   *}
{*  baud clock, many non-standard baud rates can be generated.  However,    *}
{*  the binary counter/divider is not always capable of generating the      *}
{*  EXACT baud rate desired by a user.  This function, when passed a valid  *}
{*  baud rate, will return the ACTUAL baud rate that will be generated.     *}
{*  The baud rate is based on a 8250 input clock rate of 1.73728 MHz.       *}
{*                                                                          *}
{****************************************************************************}

Function ComTrueBaud(Baud:Longint) : Real;

Var
  X : Real;
  Y : Word;

Begin
  X := Baud;
  If X < C_MinBaud Then X := C_MinBaud;
  If X > C_MaxBaud Then X := C_MaxBaud;
  ComTrueBaud := 115200 / Round($900/(X/50));
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure ComParams(ComPort:Byte; Baud:Longint;                         *}
{*                      WordSize:Byte; Parity:Char; StopBits:Byte);         *}
{*                                                                          *}
{*  ComPort:Byte   ->  Port # to initialize.  Must be (1 - C_MaxCom)        *}
{*                     Procedure aborted if port # invalid or unopened.     *}
{*  Baud:Longint   ->  Desired baud rate.  Should be (C_MinBaud - C_MaxBaud)*}
{*                     C_MinBaud or C_MaxBaud used if out of range.         *}
{*  WordSize:Byte  ->  Word size, in bits.  Must be 5 - 8 bits.             *}
{*                     8-bit word used if out of range.                     *}
{*  Parity:Char    ->  Parity classification.                               *}
{*                     May be N)one, E)ven, O)dd, M)ark or S)pace.          *}
{*                     N)one selected if classification unknown.            *}
{*  StopBits:Byte  ->  # of stop bits to pad character with.  Range (1-2)   *}
{*                     1 stop bit used if out of range.                     *}
{*                                                                          *}
{*  ComParams is used to configure an OPEN'ed port for the desired comm-    *}
{*  unications parameters, namely baud rate, word size, parity form and     *}
{*  # of stop bits.  A call to this procedure will set up the port approp-  *}
{*  riately, as well as assert the DTR, RTS and OUT2 control lines and      *}
{*  clear all buffers.                                                      *}
{*                                                                          *}
{****************************************************************************}

Procedure ComParams(ComPort:Byte; Baud:LongInt; WordSize:Byte; Parity:Char; StopBits:Byte);

Const
  C_Stopbit1    = $00;                 { Bit masks for parity, stopbits }
  C_Stopbit2    = $04;
  C_NoParity    = $00;
  C_OddParity   = $08;
  C_EvenParity  = $18;
  C_MarkParity  = $28;
  C_SpaceParity = $38;

Var
  X : Real;
  Y,P : Word;
  DivMSB,DivLSB,BaudB : Byte;
  WS,SB,PTY : Byte;

Begin
  If (ComPort<1) Or (ComPort>C_MaxPort) Or (Not C_PortOpen[ComPort]) Then Exit;

  Inline($FA);
  P := C_PortAddr[ComPort];

  { Calculate baud rate divisors }

  X := Baud;
  If X < C_MinBaud Then X := C_MinBaud;
  If X > C_MaxBaud Then X := C_MaxBaud;

  Y := Round($900/(X/50));
  DivMSB := Hi(Y);
  DivLSB := Lo(Y);

  { Determine parity mask }
  { Default if unknown: No parity }

  Case UpCase(Parity) Of
    'N' : PTY := C_NoParity;
    'E' : PTY := C_EvenParity;
    'O' : PTY := C_OddParity;
    'M' : PTY := C_MarkParity;
    'S' : PTY := C_SpaceParity;
  Else
    PTY := C_NoParity;
  End;

  { Determine stop-bit mask }
  { Default if out of range: 1 Stop bit }

  Case StopBits Of
    1 : SB := C_StopBit1;
    2 : SB := C_StopBit2;
  Else
    SB := C_StopBit1;
  End;

  { Determine word-size mask }
  { Default if out of range: 8 bit word size }

  If (WordSize >= 5) And (WordSize <= 8) Then
    WS := WordSize - 5
  Else
    WS := 3;

  { Initialize line-control register }

  Y := Port[P] + Port[P+C_LSR];

  Port[P+C_LCR] := WS + SB + PTY;

  { Initialize baud rate divisor latches }

  Port[P+C_LCR] := Port[P+C_LCR] Or $80;
  Port[P] := DivLSB;
  Port[P+1] := DivMSB;
  Port[P+C_LCR] := Port[P+C_LCR] And $7F;
  X := Port[P] + Port[P+C_LSR] + Port[P+C_MSR] + Port[P+C_IIR];

  { Assert RS323 control lines (DTR,RTS,OUT2) & exit }

  Port[P+C_MCR] := $0B;
  ClearCom(ComPort,'B');

  {begin new stuff srl*}
  Port[$20] := $20;
  If C_CascadeOK then
    Port[$A0] := $20;
  {end new stuff srl*}

  Inline($FB);

End;

{****************************************************************************}
{*                                                                          *}
{*  Function OpenCom(ComPort:Byte; InBufferSize,OutBufferSize:Word):Boolean *}
{*                                                                          *}
{*  ComPort:Byte        ->  Port # to OPEN (1 - C_MaxCom)                   *}
{*                          Request will fail if out of range or port OPEN  *}
{*  InBufferSize:Word   ->  Requested size of input (receive) buffer        *}
{*  OutBufferSize:Word  ->  Requested size of output (transmit) buffer      *}
{*  Returns success/fail status of OPEN request (TRUE if OPEN successful)   *}
{*                                                                          *}
{*  OpenCom must be called before any activity (other than existence check, *}
{*  see the ComExist function) takes place.  OpenCom initializes the        *}
{*  interrupt drivers and serial communications hardware for the selected   *}
{*  port, preparing it for I/O.  Memory for buffers is allocated on the     *}
{*  Pascal "heap", thus freeing data-segment memory for larger more data-   *}
{*  intensive programs.  Once a port has been OPENed, a call to ComParams   *}
{*  should be made to set up communications parameters (baud rate, parity   *}
{*  and the like).  Once this is done, I/O can take place on the port.      *}
{*  OpenCom will return a TRUE value if the opening procedure was success-  *}
{*  ful, or FALSE if it is not.                                             *}
{*                                                                          *}
{****************************************************************************}

Function OpenCom(ComPort:Byte; InBufferSize,OutBufferSize:Word) : Boolean;

Var
  TempVec : Pointer;
  P : Word;
  IntLn,Cas_IntLn,X : Byte;

Begin
  { Ensure that port was not previously open }

  OpenCom := False;
  C_CascadeOK := False;
  C_cascade :=0;
  If (ComPort<1) Or (ComPort>C_MaxPort) Or C_PortOpen[ComPort] Then Exit;
  C_msrport:=c_portaddr[comport]+c_msr;

  { Clear any pending activity from 8250 interrupt queue }

  Inline($FA);

  { Set up interrupt vectors & 8259 PIC }
  P := C_PortAddr[ComPort];
  oldier:=port[P+c_ier];
  oldmcr:=port[P+c_mcr];
  Port[P+C_IER] := $0D;
  X := Port[P] + Port[P+C_LSR] + Port[P+C_MSR] + Port[P+C_IIR];

  IntLn := C_PortInt[ComPort];
  If IntLn > 7 then
     C_CascadeOK := true;

  If C_CascadeOK then
    Begin
      Cas_IntLn := IntLn-8;
      GetIntVec($70+Cas_IntLn,TempVec);
      If C_OldINTVec[IntLn] <> TempVec Then
        Begin
          C_Cascade := 1;
          C_OldINTVec[IntLn] := TempVec;
          SetIntVec($70+Cas_IntLn,@Int_Handler);
          Port[$21] := Port[$21] And (($01 SHL $02) XOR $FF);
          X := Port[$21];
          Port[$A1] := Port[$A1] And (($01 SHL Cas_IntLn) XOR $FF);
          X := Port[$A1];
        End;
    End
  else
    Begin
      GetIntVec(8+IntLn,TempVec);
      If C_OldINTVec[IntLn] <> TempVec Then
        Begin
          C_OldINTVec[IntLn] := TempVec;
          SetIntVec(8+IntLn,@Int_Handler);
          Port[$21] := Port[$21] And (($01 SHL IntLn) XOR $FF);
          X := Port[$21];
        End;
    End;

  { new stuff srl*}
  Port[P+C_MCR] := $0B;

  { Allocate memory for I/O buffers }

  C_InSize[ComPort] := InBufferSize;
  C_OutSize[ComPort] := OutBufferSize;
  GetMem(C_InBufPtr[ComPort],InBufferSize);
  GetMem(C_OutBufPtr[ComPort],OutBufferSize);

  { Set up default parameters for port }

  C_RTSOn[ComPort] := InBufferSize - 2;
  C_RTSOff[ComPort] := InBufferSize - 1;
  C_StartChar[ComPort] := ^Q;
  C_StopChar[ComPort] := ^S;
  C_PortOpen[ComPort] := True;
  OpenCom := True;

  Inline($FB);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure CloseCom(ComPort:Byte)                                        *}
{*                                                                          *}
{*  ComPort:Byte  ->  Port # to close                                       *}
{*                    Request ignored if port closed or out of range.       *}
{*                                                                          *}
{*  CloseCom will un-link the interrupt drivers for a port, deallocate it's *}
{*  buffers and drop the DTR and RTS signal lines for a port opened with    *}
{*  the OpenCom function.  It should be called before exiting your program  *}
{*  to ensure that the port is properly shut down.                          *}
{*  NOTE:  CloseCom shuts down a communications channel IMMEDIATELY,        *}
{*         even if there is data present in the input or output buffers.    *}
{*         Therefore, you may wish to call the ComWaitForClear procedure    *}
{*         before closing the ports.                                        *}
{*                                                                          *}
{****************************************************************************}

Procedure CloseCom(ComPort:Byte);

Var
  ClosePort : Boolean;
  P,IntLn,Cas_IntLn,X : Word;

Begin
  If (ComPort<1) Or (ComPort>C_MaxPort) Or (Not C_PortOpen[ComPort]) Then Exit;

  { Drop RS232 control lines (DTR,RTS,OUT2) and reset 8250 interrupt mode }

  Inline($FA);
  P := C_PortAddr[ComPort];
  Port[P+C_IER] := oldier;
  C_PortOpen[ComPort] := False;

  { Reset INT vectors & 8259 PIC if all COMs on selected INT are closed }

  IntLn := C_PortInt[ComPort];
  ClosePort := True;
  For X := 1 To C_MaxCom Do
    If C_PortOpen[X] And (C_PortInt[X] = IntLn) Then
      ClosePort := False;

  If ClosePort Then
    If C_CascadeOk then
      Begin
        Cas_IntLn := IntLn-8;
        Port[$21] := Port[$21] Or ($01 SHR $02);
        X := Port[$21];
        Port[$A1] := Port[$A1] Or ($01 SHR Cas_IntLn);
        X := Port[$A1];
        SetIntVec($70+Cas_IntLn,C_OldINTVec[IntLn]);
      End
    else
      Begin
        Port[$21] := Port[$21] Or ($01 SHR IntLn);
        X := Port[$21];
        SetIntVec(8+IntLn,C_OldINTVec[IntLn]);
      End;

  X := Port[P] + Port[P+C_LSR] + Port[P+C_MSR] + Port[P+C_IIR];

  { Deallocate buffers }

  FreeMem(C_InBufPtr[ComPort],C_InSize[ComPort]);
  FreeMem(C_OutBufPtr[ComPort],C_OutSize[ComPort]);
  Inline($FB);
End;

{****************************************************************************}
{*                                                                          *}
{*  Procedure CloseAllComs                                                  *}
{*                                                                          *}
{*  CloseAllComs will CLOSE all currently OPENed ports.  See the CloseCom   *}
{*  procedure description for more details.                                 *}
{*                                                                          *}
{****************************************************************************}

Procedure CloseAllComs;

Var
  X : Byte;

Begin
  For X := 1 To C_MaxCom Do
    If C_PortOpen[X] Then
      CloseCom(X);
End;

{****************************************************************************}
{*                                                                          *}
{*                        UNIT Initialization Code                          *}
{*                                                                          *}
{****************************************************************************}

Begin
  For x := 1 to C_MaxPort Do
    Begin
      C_PortOpen[x] := False;
      C_InBufPtr[x] := Nil;
      C_OutBufPtr[x] := Nil;
      C_OldIntVec[x] := Nil;
      C_InHead[x] := 0;
      C_OutHead[x] := 0;
      C_InTail[x] := 0;
      C_OutTail[x] := 0;
      C_InSize[x] := 0;
      C_OutSize[x] := 0;
      C_RTSOn[x] := $FFFF;
      C_RTSOff[x] := $FFFF;
      C_StartChar[x] := ^Q;
      C_StopChar[x] := ^S;
      C_Status[x] := $05;
      C_Ctrl[x] := 0;
      C_XL3Ptr[x] := 0;
      C_buffull[x]:=0;
      C_cascade := 0;
    End;
End.
