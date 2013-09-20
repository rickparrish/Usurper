{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
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

unit ASYNC2;

interface

{----------------------------------------------------------------------------}

const
  C_MinBaud      = 300;
  C_MaxBaud      = 115200;
  C_MaxPort      = 4;
  C_MaxCom: byte = C_MaxPort;
  D_PortAddr: array[1..C_MaxPort] of word = ($03F8, $02F8, $03E8, $02E8);
  D_PortInt: array[1..C_MaxPort] of byte = (4, 3, 4, 3);

{----------------------------------------------------------------------------}

type
  C_VectorArray  = array[0..15] of Pointer;
  C_PointerArray = array[1..C_MaxPort] of Pointer;
  C_WordArray    = array[1..C_MaxPort] of word;
  C_ByteArray    = array[1..C_MaxPort] of byte;
  C_CharArray    = array[1..C_MaxPort] of char;
  C_BooleanArray = array[1..C_MaxPort] of boolean;

{----------------------------------------------------------------------------}

var
  { Base port addresses & interrupt usage }
  C_PortAddr:     array[1..C_MaxPort] of word;
  C_PortInt:      array[1..C_MaxPort] of byte;
  ComPort:        byte;
  C_InBufPtr, C_OutBufPtr: C_PointerArray;    { Input/output buffer pointers }
  C_InHead, C_OutHead: C_WordArray;       { Input/output head pointers }
  C_InTail, C_OutTail: C_WordArray;       { Input/output tail pointers }
  C_InSize, C_OutSize: C_WordArray;       { Input/output buffer sizes }
  C_RTSOn, C_RTSOff: C_WordArray;       { RTS assert/drop buffer points }
  C_StartChar, C_StopChar: C_CharArray;       { Soft hndshake start/stop char }
  C_Status, C_Ctrl: C_ByteArray;       { STATUS and CONTROL registers }
  C_XL3Ptr:       C_ByteArray;
  C_PortOpen:     C_BooleanArray;    { Port open/close flags }
  C_Temp:         word;              { Used for debugging }
  C_msrport:      word;
  { RTSOn,RTSOff           : Word;}{ RTS assert/drop buffer points }
  oldier, oldmcr: byte;
  c_buffull:      c_wordarray;
  C_Cascade:      byte;              { Flag set 0 normally }
  C_CascadeOK:    boolean;           { Flag if IRQ > 7 }

 {----------------------------------------------------------------------------}

function ComReadCh(ComPort: byte): char;
function ComReadChW(ComPort: byte): char;
{ Procedure ComWriteCh(ComPort:Byte; Ch:Char); }
procedure ComWriteChW(ComPort: byte; Ch: char);
procedure SetDTR(ComPort: byte; Assert: boolean);
procedure SetRTS(ComPort: byte; Assert: boolean);
{
Procedure SetOUT1(ComPort:Byte; Assert:Boolean);
Procedure SetOUT2(ComPort:Byte; Assert:Boolean);
 }
function CTSStat(ComPort: byte): boolean;
function RTSStat(ComPort: byte): boolean;
function DSRStat(ComPort: byte): boolean;
function RIStat(ComPort: byte): boolean;
function DCDStat(ComPort: byte): boolean;
procedure SetRTSMode(ComPort: byte; Mode: boolean; RTSOn, RTSOff: word);
procedure SetCTSMode(ComPort: byte; Mode: boolean);
procedure SoftHandshake(ComPort: byte; Mode: boolean; Start, Stop: char);
procedure ClearCom(ComPort: byte; IO: char);
function ComBufferLeft(ComPort: byte; IO: char): word;
procedure ComWaitForClear(ComPort: byte);
procedure ComWrite(ComPort: byte; St: string);
procedure ComWriteln(ComPort: byte; St: string);
procedure ComWriteWithDelay(ComPort: byte; St: string; Dly: word);
procedure ComReadln(ComPort: byte; var St: string; Size: byte; Echo: boolean);
function ComExist(ComPort: byte): boolean;
function ComTrueBaud(Baud: longint): real;
procedure ComParams(ComPort: byte; Baud: longint; WordSize: byte; Parity: char; StopBits: byte);
function OpenCom(ComPort: byte; InBufferSize, OutBufferSize: word): boolean;
procedure CloseCom(ComPort: byte);
procedure CloseAllComs;

{----------------------------------------------------------------------------}

implementation

uses
  DOS, CRT;

{$IFDEF MSDOS}
{$L SLASYNC.OBJ}
{$ENDIF}

const
  C_IER = 1;                           { 8250 register offsets }
  C_IIR = 2;
  C_LCR = 3;
  C_MCR = 4;
  C_LSR = 5;
  C_MSR = 6;
  C_SCR = 7;

var
  C_OldINTVec: C_VectorArray;        { Storage for old hardware INT vectors }
  X:           byte;                            { Used by initialization code }

                       {****************************************************************************}
                       {*                                                                          *}
                       {*  Procedure INT_Handler; External;                                        *}
                       {*                                                                          *}
                       {*  Hardware interrupts 0-15 (vectors $08 - $0F,$70 - $77) are pointed to   *}
                       {*  this routine.  It is for internal use only and should NOT be called     *}
                       {*  directly.  Written in assembly language (see SLASYNC.ASM).              *}
                       {*                                                                          *}
                       {****************************************************************************}

procedure INT_Handler; {$IFDEF MSDOS}External;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT ASYNC2 INT_Handler');
end;

{$ENDIF}

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

function ComReadCh(ComPort: byte): char; {$IFDEF MSDOS}External;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT ASYNC2 ComReadCh');
end;

{$ENDIF}

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

function ComReadChW(ComPort: byte): char; {$IFDEF MSDOS}External;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT ASYNC2 ComReadChW');
end;

{$ENDIF}

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

procedure ComWriteCh(ComPort: byte; Ch: char); {$IFDEF MSDOS}External;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT ASYNC2 ComWriteCh');
end;

{$ENDIF}

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

procedure ComWriteChW(ComPort: byte; Ch: char); {$IFDEF MSDOS}External;{$ENDIF}
{$IFNDEF MSDOS}
begin
  WriteLn('REEPORT ASYNC2 ComWriteChW');
end;

{$ENDIF}

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

procedure SetDTR(ComPort: byte; Assert: boolean);

var
  P, X: integer;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    Exit;
  P := C_PortAddr[ComPort];

  X := Port[P + C_MCR];
  if Assert then
    X := X or $01
  else
    X := X and $FE;
  Port[P + C_MCR] := X;
end;

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

procedure SetRTS(ComPort: byte; Assert: boolean);

var
  P, X: integer;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    Exit;
  P := C_PortAddr[ComPort];

  X := Port[P + C_MCR];
  if Assert then
    X := X or $02
  else
    X := X and $FD;
  Port[P + C_MCR] := X;
end;

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

function CTSStat(ComPort: byte): boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    CTSStat := False
  else
    CTSStat := (Port[C_PortAddr[ComPort] + C_MSR] and $10 <> $10);
end;

 {****************************************************************************}
 {*                                                                          *}
 {*  Function RTSStat(ComPort:Byte) : Boolean                                *}
 {*                                                                          *}
 {*  ComPort:Byte  ->  Port # to use (1 - C_MaxCom)                          *}
 {*                    Call ignored if out-of-range                          *}
 {*  Returns status of Ready-To-Send line (TRUE if RTS asserted)             *}
 {*                                                                          *}
 {****************************************************************************}


function RTSStat(ComPort: byte): boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    RTSStat := False
  else
    RTSStat := (Port[C_PortAddr[ComPort] + C_LSR] and $20 <> $20);
end;

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

function DSRStat(ComPort: byte): boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    DSRStat := False
  else
    DSRStat := (Port[C_PortAddr[ComPort] + C_MSR] and $20) > 0;
end;

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

function RIStat(ComPort: byte): boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    RIStat := False
  else
    RIStat := (Port[C_PortAddr[ComPort] + C_MSR] and $40) > 0;
end;

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

function DCDStat(ComPort: byte): boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) then
    DCDStat := False
  else
    DCDStat := (Port[C_PortAddr[ComPort] + C_MSR] and $80) > 0;
end;

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

procedure SetRTSMode(ComPort: byte; Mode: boolean; RTSOn, RTSOff: word);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxPort) or (not C_PortOpen[ComPort]) then
    Exit;

  X := C_Ctrl[ComPort];
  if Mode then
    X := X or $01 else X := X and $FE;
  C_Ctrl[ComPort] := X;

  if Mode then
  begin
    if (RTSOff >= C_InSize[ComPort]) then
      RTSOff := C_InSize[ComPort] - 1;
    if (RTSOn > RTSOff) then
      RTSOff := RTSOn;
    C_RTSOn[ComPort] := RTSOn;
    C_RTSOff[ComPort] := RTSOff;
  end;
end;

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

procedure SetCTSMode(ComPort: byte; Mode: boolean);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxPort) or (not C_PortOpen[ComPort]) then
    Exit;

  X := C_Ctrl[ComPort];
  if Mode then
    X := X or $02 else X := X and $FD;
  C_Ctrl[ComPort] := X;
end;

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

procedure SoftHandshake(ComPort: byte; Mode: boolean; Start, Stop: char);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxPort) or (not C_PortOpen[ComPort]) then
    Exit;

  X := C_Ctrl[ComPort];
  if Mode then
  begin
    X := X or $04;
    if Start = Stop then
    begin Start := ^Q; Stop := ^S; end;
    if Start > #32 then
      Start := ^Q;
    if Stop > #32 then
      Stop := ^S;
    C_StartChar[ComPort] := Start;
    C_StopChar[ComPort] := Stop;
  end else
    X := X and $FB;
  C_Ctrl[ComPort] := X;
end;

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

procedure ClearCom(ComPort: byte; IO: char);

var
  P, X: word;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;

  IO := Upcase(IO);
  P := C_PortAddr[ComPort];

{$IFDEF MSDOS}
  inline($FA);
  if (IO = 'I') or (IO = 'B') then
  begin
    C_InHead[ComPort] := 0;
    C_InTail[ComPort] := 0;
    C_Status[ComPort] := (C_Status[ComPort] and $EC) or $01;
    X := Port[P] + Port[P + C_LSR] + Port[P + C_MSR] + Port[P + C_IIR];
  end;
  if (IO = 'O') or (IO = 'B') then
  begin
    C_OutHead[ComPort] := 0;
    C_OutTail[ComPort] := 0;
    C_Status[ComPort] := (C_Status[ComPort] and $D3) or $04;
    X := Port[P + C_LSR] + Port[P + C_MSR] + Port[P + C_IIR];
  end;
  inline($FB);
{$ENDIF}
{$IFNDEF MSDOS}
  WriteLn('REEPORT ASYNC2 ClearCom');
{$ENDIF}
end;

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

function ComBufferLeft(ComPort: byte; IO: char): word;

begin
  ComBufferLeft := 0;
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;
  IO := Upcase(IO);

  if IO = 'I' then
    if C_InHead[ComPort] >= C_InTail[ComPort] then
      ComBufferLeft := C_InSize[ComPort] - (C_InHead[ComPort] - C_InTail[ComPort])
    else
      ComBufferLeft := C_InTail[ComPort] - C_InHead[ComPort];

  if IO = 'O' then
    if C_OutHead[ComPort] >= C_OutTail[ComPort] then
      ComBufferLeft := C_OutHead[ComPort] - C_OutTail[ComPort]
    else
      ComBufferLeft := C_OutSize[ComPort] - (C_OutTail[ComPort] - C_OutHead[ComPort]);
end;

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

procedure ComWaitForClear(ComPort: byte);

var
  Empty: boolean;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;
  repeat
    Empty := (C_Status[ComPort] and $04) = $04;
    Empty := Empty and ((Port[C_PortAddr[ComPort] + C_IER] and $02) = $00);
  until Empty;
end;

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

procedure ComWrite(ComPort: byte; St: string);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;

  for X := 1 to Length(St) do
    ComWriteChW(ComPort, St[X]);
end;

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

procedure ComWriteln(ComPort: byte; St: string);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;

  for X := 1 to Length(St) do
    ComWriteChW(ComPort, St[X]);
  ComWriteChW(ComPort, #13);
  ComWriteChW(ComPort, #10);
end;

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

procedure ComWriteWithDelay(ComPort: byte; St: string; Dly: word);

var
  X: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;

  ComWaitForClear(ComPort);
  for X := 1 to Length(St) do
  begin
    ComWriteChW(ComPort, St[X]);
    ComWaitForClear(ComPort);
    Delay(Dly);
  end;
end;

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

procedure ComReadln(ComPort: byte; var St: string; Size: byte; Echo: boolean);

var
  Len, X: byte;
  Ch:     char;
  Done:   boolean;

begin
  St := '';
  if (ComPort < 1) or (ComPort > C_MaxCom) or (not C_PortOpen[ComPort]) then
    Exit;

  Done := False;
  repeat
    Len := Length(St);
    Ch := Chr(Ord(ComReadChW(ComPort)) and $7F);

    case Ch of ^H: if Len > 0 then
        begin
          Dec(Len);
          St[0] := Chr(Len);
          if Echo then
            ComWrite(ComPort, #8#32#8);
        end else
          ComWriteChW(ComPort, ^G);  ^M: begin
        Done := True;
        if Echo then
          ComWrite(ComPort, #13#10);
      end;  ^X: begin
        St := '';
        if Len = 0 then
          ComWriteCh(ComPort, ^G);
        if Echo then
          for X := 1 to Len do
            ComWrite(ComPort, #8#32#8);
      end;
      #32..#127: if Len < Size then
        begin
          Inc(Len);
          St[Len] := Ch;
          St[0] := Chr(Len);
          if Echo then
            ComWriteChW(ComPort, Ch);
        end else
        if Echo then
          ComWriteChW(ComPort, ^G);
      else if Echo then
          ComWriteChW(ComPort, ^G)
    end;

  until Done;
end;

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

function ComExist(ComPort: byte): boolean;

const
  TestByte1: byte = $0F;
  TestByte2: byte = $F1;

var
  P: word;
  M, L, B1, B2: byte;

begin
  ComExist := False;
  if (ComPort < 1) or (ComPort > C_MaxPort) then
    Exit;

  P := C_PortAddr[ComPort];
  M := Port[P + C_MCR];                            { Save MCR }
  L := Port[P + C_LCR];                            { Save LCR }
  Port[P + C_MCR] := $10;                          { Enable loopback mode }
  Port[P + C_LCR] := $80;                          { Enable divisor latch mode }
  B1 := Port[P];                                 { Save current baud rate }
  B2 := Port[P + 1];
  Port[P] := 4;                                  { Set baud rate to 28000 }
  Port[P + 1] := 0;
  Port[P + C_LCR] := $03;                          { Transmit mode 28000:8N1 }

  Port[P] := TestByte1;                          { Test byte #1 }
  Delay(20);                                     { Wait a bit for loopback }
  if Port[P] <> TestByte1 then
    Exit;             { Exit w/error if not echoed }
  Port[P] := TestByte2;                          { Test byte #2 }
  Delay(20);                                     { Wait a bit for loopback }
  if Port[P] <> TestByte2 then
    Exit;             { Exit w/error if not echoed }

  ComExist := True;                              { Test passed: Port exists }
  Port[P + C_LCR] := $80;                          { Restore baud rate }
  Port[P] := B1;
  Port[P + 1] := B2;
  Port[P + C_LCR] := L;                            { Restore parameters }
  Port[P + C_MCR] := M;                            { Restore control lines }
end;

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

function ComTrueBaud(Baud: longint): real;

var
  X: real;
  Y: word;

begin
  X := Baud;
  if X < C_MinBaud then
    X := C_MinBaud;
  if X > C_MaxBaud then
    X := C_MaxBaud;
  ComTrueBaud := 115200 / Round($900 / (X / 50));
end;

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

procedure ComParams(ComPort: byte; Baud: longint; WordSize: byte; Parity: char; StopBits: byte);

const
  C_Stopbit1    = $00;                 { Bit masks for parity, stopbits }
  C_Stopbit2    = $04;
  C_NoParity    = $00;
  C_OddParity   = $08;
  C_EvenParity  = $18;
  C_MarkParity  = $28;
  C_SpaceParity = $38;

var
  X:           real;
  Y, P:        word;
  DivMSB, DivLSB, BaudB: byte;
  WS, SB, PTY: byte;

begin
  if (ComPort < 1) or (ComPort > C_MaxPort) or (not C_PortOpen[ComPort]) then
    Exit;

{$IFDEF MSDOS}
  inline($FA);
  P := C_PortAddr[ComPort];

  { Calculate baud rate divisors }

  X := Baud;
  if X < C_MinBaud then
    X := C_MinBaud;
  if X > C_MaxBaud then
    X := C_MaxBaud;

  Y := Round($900 / (X / 50));
  DivMSB := Hi(Y);
  DivLSB := Lo(Y);

  { Determine parity mask }
  { Default if unknown: No parity }

  case UpCase(Parity) of
    'N': PTY := C_NoParity;
    'E': PTY := C_EvenParity;
    'O': PTY := C_OddParity;
    'M': PTY := C_MarkParity;
    'S': PTY := C_SpaceParity;
    else PTY := C_NoParity;
  end;

  { Determine stop-bit mask }
  { Default if out of range: 1 Stop bit }

  case StopBits of
    1: SB := C_StopBit1;
    2: SB := C_StopBit2;
    else SB := C_StopBit1;
  end;

  { Determine word-size mask }
  { Default if out of range: 8 bit word size }

  if (WordSize >= 5) and (WordSize <= 8) then
    WS := WordSize - 5
  else
    WS := 3;

  { Initialize line-control register }

  Y := Port[P] + Port[P + C_LSR];

  Port[P + C_LCR] := WS + SB + PTY;

  { Initialize baud rate divisor latches }

  Port[P + C_LCR] := Port[P + C_LCR] or $80;
  Port[P] := DivLSB;
  Port[P + 1] := DivMSB;
  Port[P + C_LCR] := Port[P + C_LCR] and $7F;
  X := Port[P] + Port[P + C_LSR] + Port[P + C_MSR] + Port[P + C_IIR];

  { Assert RS323 control lines (DTR,RTS,OUT2) & exit }

  Port[P + C_MCR] := $0B;
  ClearCom(ComPort, 'B');

  {begin new stuff srl*}
  Port[$20] := $20;
  if C_CascadeOK then
    Port[$A0] := $20;
  {end new stuff srl*}

  inline($FB);
{$ENDIF}
{$IFNDEF MSDOS}
  WriteLn('REEPORT ASYNC2 ComParams');
{$ENDIF}
end;

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

function OpenCom(ComPort: byte; InBufferSize, OutBufferSize: word): boolean;

var
  TempVec: Pointer;
  P:       word;
  IntLn, Cas_IntLn, X: byte;

begin
  { Ensure that port was not previously open }

  OpenCom := False;
  C_CascadeOK := False;
  C_cascade := 0;
  if (ComPort < 1) or (ComPort > C_MaxPort) or C_PortOpen[ComPort] then
    Exit;
  C_msrport := c_portaddr[comport] + c_msr;

  { Clear any pending activity from 8250 interrupt queue }

{$IFDEF MSDOS}
  inline($FA);

  { Set up interrupt vectors & 8259 PIC }
  P := C_PortAddr[ComPort];
  oldier := port[P + c_ier];
  oldmcr := port[P + c_mcr];
  Port[P + C_IER] := $0D;
  X := Port[P] + Port[P + C_LSR] + Port[P + C_MSR] + Port[P + C_IIR];

  IntLn := C_PortInt[ComPort];
  if IntLn > 7 then
    C_CascadeOK := True;

  if C_CascadeOK then
  begin
    Cas_IntLn := IntLn - 8;
    GetIntVec($70 + Cas_IntLn, TempVec);
    if C_OldINTVec[IntLn] <> TempVec then
    begin
      C_Cascade := 1;
      C_OldINTVec[IntLn] := TempVec;
      SetIntVec($70 + Cas_IntLn, @Int_Handler);
      Port[$21] := Port[$21] and (($01 shl $02) xor $FF);
      X := Port[$21];
      Port[$A1] := Port[$A1] and (($01 shl Cas_IntLn) xor $FF);
      X := Port[$A1];
    end;
  end else
  begin
    GetIntVec(8 + IntLn, TempVec);
    if C_OldINTVec[IntLn] <> TempVec then
    begin
      C_OldINTVec[IntLn] := TempVec;
      SetIntVec(8 + IntLn, @Int_Handler);
      Port[$21] := Port[$21] and (($01 shl IntLn) xor $FF);
      X := Port[$21];
    end;
  end;

  { new stuff srl*}
  Port[P + C_MCR] := $0B;

  { Allocate memory for I/O buffers }

  C_InSize[ComPort] := InBufferSize;
  C_OutSize[ComPort] := OutBufferSize;
  GetMem(C_InBufPtr[ComPort], InBufferSize);
  GetMem(C_OutBufPtr[ComPort], OutBufferSize);

  { Set up default parameters for port }

  C_RTSOn[ComPort] := InBufferSize - 2;
  C_RTSOff[ComPort] := InBufferSize - 1;
  C_StartChar[ComPort] := ^Q;
  C_StopChar[ComPort] := ^S;
  C_PortOpen[ComPort] := True;
  OpenCom := True;

  inline($FB);
{$ENDIF}
{$IFNDEF MSDOS}
  WriteLn('REEPORT ASYNC2 OpenCom');
{$ENDIF}
end;

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

procedure CloseCom(ComPort: byte);

var
  ClosePort: boolean;
  P, IntLn, Cas_IntLn, X: word;

begin
  if (ComPort < 1) or (ComPort > C_MaxPort) or (not C_PortOpen[ComPort]) then
    Exit;

  { Drop RS232 control lines (DTR,RTS,OUT2) and reset 8250 interrupt mode }

{$IFDEF MSDOS}
  inline($FA);
  P := C_PortAddr[ComPort];
  Port[P + C_IER] := oldier;
  C_PortOpen[ComPort] := False;

  { Reset INT vectors & 8259 PIC if all COMs on selected INT are closed }

  IntLn := C_PortInt[ComPort];
  ClosePort := True;
  for X := 1 to C_MaxCom do
    if C_PortOpen[X] and (C_PortInt[X] = IntLn) then
      ClosePort := False;

  if ClosePort then
    if C_CascadeOk then
    begin
      Cas_IntLn := IntLn - 8;
      Port[$21] := Port[$21] or ($01 shr $02);
      X := Port[$21];
      Port[$A1] := Port[$A1] or ($01 shr Cas_IntLn);
      X := Port[$A1];
      SetIntVec($70 + Cas_IntLn, C_OldINTVec[IntLn]);
    end else
    begin
      Port[$21] := Port[$21] or ($01 shr IntLn);
      X := Port[$21];
      SetIntVec(8 + IntLn, C_OldINTVec[IntLn]);
    end;

  X := Port[P] + Port[P + C_LSR] + Port[P + C_MSR] + Port[P + C_IIR];

  { Deallocate buffers }

  FreeMem(C_InBufPtr[ComPort], C_InSize[ComPort]);
  FreeMem(C_OutBufPtr[ComPort], C_OutSize[ComPort]);
  inline($FB);
{$ENDIF}
{$IFNDEF MSDOS}
  WriteLn('REEPORT ASYNC2 CloseCom');
{$ENDIF}
end;

 {****************************************************************************}
 {*                                                                          *}
 {*  Procedure CloseAllComs                                                  *}
 {*                                                                          *}
 {*  CloseAllComs will CLOSE all currently OPENed ports.  See the CloseCom   *}
 {*  procedure description for more details.                                 *}
 {*                                                                          *}
 {****************************************************************************}

procedure CloseAllComs;

var
  X: byte;

begin
  for X := 1 to C_MaxCom do
    if C_PortOpen[X] then
      CloseCom(X);
end;

 {****************************************************************************}
 {*                                                                          *}
 {*                        UNIT Initialization Code                          *}
 {*                                                                          *}
 {****************************************************************************}

begin
  for x := 1 to C_MaxPort do
  begin
    C_PortOpen[x] := False;
    C_InBufPtr[x] := nil;
    C_OutBufPtr[x] := nil;
    C_OldIntVec[x] := nil;
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
    C_buffull[x] := 0;
    C_cascade := 0;
  end;
end.
