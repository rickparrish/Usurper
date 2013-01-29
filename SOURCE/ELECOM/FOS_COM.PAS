unit FOS_COM;
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.1,    (OS/2, Win32)
**              FreePascal    v0.99.12 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.01
** Created : 21-May-1998
** Last update : 07-Apr-1999
**
** Note: (c) 1998-1999 by Maarten Bekers
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses Dos, Combase;

type TFossilObj = Object(TCommObj)
        Regs   : Registers;
        FosPort: Byte;

        constructor Init;
        destructor Done;

        function  Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                           Parity: Char; StopBits: Byte): Boolean; virtual;
        function  Com_OpenKeep(Comport: Byte): Boolean; virtual;
        function  Com_GetChar: Char; virtual;
        function  Com_CharAvail: Boolean; virtual;
        function  Com_Carrier: Boolean; virtual;
        function  Com_SendChar(C: Char): Boolean; virtual;
        function  Com_ReadyToSend(BlockLen: Longint): Boolean; virtual;
        function  Com_GetBPSrate: Longint; virtual;
        function  Com_GetDriverInfo: String; virtual;
        function  Com_GetHandle: longint; virtual;

        procedure Com_OpenQuick(Handle: Longint); virtual;
        procedure Com_Close; virtual;
        procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); virtual;
        procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc); virtual;
        procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); virtual;
        procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); virtual;
        procedure Com_SetDtr(State: Boolean); virtual;
        procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); virtual;
        procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); virtual;
        procedure Com_PurgeInBuffer; virtual;
        procedure Com_PurgeOutBuffer; virtual;
        procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); virtual;
     end; { object TFossilObj }

Type PFossilObj = ^TFossilObj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses Strings
       {$IFDEF GO32V2}
         ,Go32
       {$ENDIF} ;


(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure DosAlloc(var Selector: Word; var SegMent: Word; Size: Longint);
var Res: Longint;
begin
  {$IFDEF GO32V2}
    Res := Global_DOS_Alloc(Size);
    Selector := Word(Res);

    Segment := Word(RES SHR 16);
  {$ENDIF}
end; { proc. DosAlloc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure DosFree(Selector: Word);
begin
  {$IFDEF GO32V2}
    Global_DOS_Free(Selector);
  {$ENDIF}
end; { proc. DosFree }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TFossilObj.Init;
begin
  inherited Init;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TFossilObj.Done;
begin
  inherited Done;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure FossilIntr(var Regs: Registers);
begin
  Intr($14, Regs);
end; { proc. FossilIntr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                             Parity: Char; StopBits: Byte): Boolean;
begin
  {-------------------------- Open the comport -----------------------------}
  FosPort := (ComPort - 01);

  Regs.AH := $04;
  Regs.DX := FosPort;
  Regs.BX := $4F50;

  FossilIntr(Regs);

  Com_Open := (Regs.AX = $1954);
  InitFailed := (Regs.AX <> $1954);
  Com_SetLine(BaudRate, Parity, DataBits, StopBits);
end; { func. TFossilObj.Com_OpenCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_OpenKeep(Comport: Byte): Boolean;
begin
  FosPort := (ComPort - 01);

  Regs.AH := $04;
  Regs.DX := FosPort;
  Regs.BX := $4F50;

  FossilIntr(Regs);

  Com_OpenKeep := (Regs.AX = $1954);
  InitFailed := (Regs.AX <> $1954);
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_OpenQuick(Handle: Longint);
begin
  {-------------------------- Open the comport -----------------------------}
  FosPort := (Handle - 01);

  Regs.AH := $04;
  Regs.DX := FosPort;
  Regs.BX := $4F50;

  FossilIntr(Regs);
  InitFailed := (Regs.AX <> $1954);
end; { proc. Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
var BPS: Byte;
begin
  if BpsRate > 65534 then
    BpsRate := 65534;

  Case Word(BpsRate) of { have to typecast to word, else will rte201 in dos }
    1200  : BPS := 128;
    2400  : BPS := 160;
    4800  : BPS := 192;
    9600  : BPS := 224;
    19200 : BPS := 0
     else BPS := 32;
   end; { case }

  if DataBits in [6..8] then
    BPS := BPS + (DataBits - 5);

  if Parity = 'O' then BPS := BPS + 8 else
   If Parity = 'E' then BPS := BPS + 24;

  if StopBits = 2 then BPS := BPS + 04;

  Regs.AH := $00;
  Regs.AL := BPS;
  Regs.DX := FosPort;
  FossilIntr(Regs);
end; { proc. TFossilObj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_GetBPSrate: Longint;
begin
  Com_GetBpsRate := 115200;
end; { func. TFossilObj.Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_Close;
begin
  if Dontclose then EXIT;

  Regs.AH := $05;
  Regs.DX := FosPort;
  FossilIntr(Regs);
end; { proc. TFossilObj.Com_Close }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_SendChar(C: Char): Boolean;
var Written: Longint;
begin
  Com_SendWait(C, SizeOf(c), Written, nil);

  Com_SendChar := (Written >= SizeOf(c));
end; { proc. TFossilObj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_GetChar: Char;
begin
  Regs.AH := $02;
  Regs.DX := FosPort;
  FossilIntr(Regs);

  Com_GetChar := Chr(Regs.AL);
end; { proc. TFossilObj.Com_ReadChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
{$IFDEF GO32V2}
var Selector,
    Segment   : Word;
{$ENDIF}
begin
  {$IFDEF MSDOS}
    Regs.AH := $18;
    Regs.DX := FosPort;
    Regs.CX := Blocklen;
    Regs.ES := Seg(Block);
    Regs.DI := Ofs(Block);
    FossilIntr(Regs);

    Reads := Regs.AX;
  {$ENDIF}

  {$IFDEF GO32V2}
    DosAlloc(Selector, Segment, BlockLen);

    if Int31Error <> 0 then EXIT;
    DosmemPut(Segment, 0, Block, BlockLen);

    Regs.AH := $18;
    Regs.DX := FosPort;
    Regs.CX := Blocklen;
    Regs.ES := Segment;
    Regs.DI := 0;
    FossilIntr(Regs);

    Reads := Regs.AX;

    DosMemGet(Segment, 0, Block, BlockLen);
    DosFree(Selector);
  {$ENDIF}
end; { proc. TFossilObj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
{$IFDEF GO32V2}
var Selector,
    Segment   : Word;
{$ENDIF}
begin
  {$IFDEF MSDOS}
    Regs.AH := $19;
    Regs.DX := FosPort;
    Regs.CX := Blocklen;
    Regs.ES := Seg(Block);
    Regs.DI := Ofs(Block);
    FossilIntr(Regs);

    Written := Regs.AX;
  {$ENDIF}

  {$IFDEF GO32V2}
    DosAlloc(Selector, Segment, BlockLen);

    if Int31Error <> 0 then EXIT;
    DosmemPut(Segment, 0, Block, BlockLen);

    Regs.AH := $19;
    Regs.DX := FosPort;
    Regs.CX := Blocklen;
    Regs.ES := Segment;
    Regs.DI := 0;
    FossilIntr(Regs);

    Written := Regs.AX;

    DosMemGet(Segment, 0, Block, BlockLen);
    DosFree(Selector);
  {$ENDIF}
end; { proc. TFossilObj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_CharAvail: Boolean;
begin
  Regs.AH := $03;
  Regs.DX := FosPort;
  FossilIntr(Regs);

  Com_CharAvail := (Regs.AH AND 01) <> 00;
end;  { func. TFossilObj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function  TFossilObj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Regs.AH := $03;
  Regs.DX := FosPort;
  FossilIntr(Regs);

  Com_ReadyToSend := (Regs.AH AND $20) = $20;
end; { func. TFossilObj.Com_ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_Carrier: Boolean;
begin
  Regs.AH := $03;
  Regs.DX := FosPort;
  FossilIntr(Regs);

  Com_Carrier := (Regs.AL AND 128) <> 00;
end; { func. TFossilObj.Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_SetDtr(State: Boolean);
begin
  Regs.AH := $06;
  Regs.AL := Byte(State);
  Regs.DX := Fosport;
  FossilIntr(Regs);
end; { proc. TFossilObj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
  Regs.AH := $03;
  Regs.DX := FosPort;
  FossilIntr(Regs);

  ModemStatus := Regs.AL;
  LineStatus := Regs.AH;
end; { proc. TFossilObj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
type
  FosRec = record
    Size      : Word;
    Spec      : Byte;
    Rev       : Byte;
    ID        : Pointer;
    InSize    : Word;
    InFree    : Word;
    OutSize   : Word;
    OutFree   : Word;
    SWidth    : Byte;
    SHeight   : Byte;
    BaudMask  : Byte;
    Junk      : Word;
  end;

var Com_Info: FosRec;

    Selector,
    Segment : Word;
begin
  {$IFDEF MSDOS}
    Regs.AH := $1B;
    Regs.DX := FosPort;
    Regs.ES := Seg(Com_Info);
    Regs.DI := Ofs(Com_Info);
    Regs.CX := SizeOf(Com_Info);
  {$ENDIF}

  {$IFDEF GO32V2}
    DosAlloc(Selector, Segment, SizeOf(Com_Info));
    if Int31Error <> 0 then EXIT;

    DosmemPut(Segment, 0, Com_Info, SizeOf(Com_Info));

    Regs.AH := $1B;
    Regs.DX := FosPort;
    Regs.ES := Segment;
    Regs.DI := 0;
    Regs.CX := SizeOf(Com_Info);
    FossilIntr(Regs);

    DosMemGet(Segment, 0, Com_Info, SizeOf(Com_Info));
    DosFree(Selector);
  {$ENDIF}

  FossilIntr(Regs);

  InFree := Com_Info.InFree;
  InUsed := Com_Info.InSize - Com_Info.InFree;

  OutFree := Com_Info.OutFree;
  OutUsed := Com_Info.OutSize - Com_Info.OutFree;
end; { proc. TFossilObj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_GetDriverInfo: String;
type
  FosRec = record
    Size      : Word;
    Spec      : Byte;
    Rev       : Byte;
    ID        : PChar;
    InSize    : Word;
    InFree    : Word;
    OutSize   : Word;
    OutFree   : Word;
    SWidth    : Byte;
    SHeight   : Byte;
    BaudMask  : Byte;
    Junk      : Word;
  end;

var Com_Info: FosRec;
    Segment,
    Selector: Word;
begin
  FillChar(Com_Info, SizeOf(FosRec), #00);

  {$IFDEF MSDOS}
    Regs.AH := $1B;
    Regs.DX := FosPort;
    Regs.ES := Seg(Com_Info);
    Regs.DI := Ofs(Com_Info);
    Regs.CX := SizeOf(Com_Info);
  {$ENDIF}

  {$IFDEF GO32V2}
    DosAlloc(Selector, Segment, SizeOf(Com_Info));
    if Int31Error <> 0 then EXIT;

    DosmemPut(Segment, 0, Com_Info, SizeOf(Com_Info));

    Regs.AH := $1B;
    Regs.DX := FosPort;
    Regs.ES := Segment;
    Regs.DI := 0;
    Regs.CX := SizeOf(Com_Info);
    FossilIntr(Regs);

    DosMemGet(Segment, 0, Com_Info, SizeOf(Com_Info));
    DosFree(Selector);
  {$ENDIF}

  FossilIntr(Regs);
  Com_GetDriverInfo := StrPas(Com_Info.ID);
end; { proc. TFossilObj.Com_GetDriverInfo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_PurgeInBuffer;
begin
  Regs.AH := $0A;
  Regs.DX := FosPort;

  FossilIntr(Regs);
end; { proc. TFossilObj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_PurgeOutBuffer;
begin
  Regs.AH := $09;
  Regs.DX := FosPort;

  FossilIntr(Regs);
end; { proc. TFossilObj.Com_PurgeOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TFossilObj.Com_GetHandle: longint;
begin
  Com_GetHandle := FosPort;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc);
var RestLen : Longint;
    Temp    : Array[0..(1024 * 50)] of Char ABSOLUTE Block;
    MaxTries: Longint;
begin
  RestLen := BlockLen;
  MaxTries := (Com_GetBpsRate div 8);

  repeat
    Com_SendBlock(Temp[BlockLen - RestLen], RestLen, Written);

    Dec(RestLen, Written);
    Dec(MaxTries);

    if RestLen <> 0 then
     if @Slice <> nil then
       Slice;
  until (RestLen <= 0) OR (NOT COM_Carrier) OR (MaxTries < 0);

  Written := (BlockLen - RestLen);
end; { proc. Com_SendWait }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TFossilObj.Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
begin
  Regs.AH := $0F;

  if SoftTX then
    Regs.AL := $01
     else Regs.AL := $00;

  if SoftRX then
    Regs.AL := Regs.AL OR $08;

  if Hard then
    Regs.AL := Regs.AL OR $02;

  Regs.DX := FosPort;
  FossilIntr(Regs);
end; { proc. Com_SetFlow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
