unit ComBase;
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
** Last update : 14-May-1999
**
** Note: (c)1998-2003 by Maarten Bekers
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

{$IFDEF VirtualPascal}
uses Use32;
{$ENDIF}

{$IFDEF MSDOS}
  Type ShortString = String;
{$ENDIF}

type SliceProc = procedure;

type TCommObj = Object
        DontClose  : Boolean;
        InitFailed : Boolean;
        ErrorStr   : ShortString;
        BlockAll   : Boolean;

        constructor Init;
        destructor Done;

        procedure Com_OpenQuick(Handle: Longint); virtual;
        function  Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                           Parity: Char; StopBits: Byte): Boolean; virtual;
        function  Com_OpenKeep(Comport: Byte): Boolean; virtual;
        procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); virtual;

        procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); virtual;
        function  Com_GetBPSrate: Longint; virtual;

        procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); virtual;
        procedure Com_SetDtr(State: Boolean); virtual;

        function  Com_CharAvail: Boolean; virtual;
        function  Com_Carrier: Boolean; virtual;
        function  Com_ReadyToSend(BlockLen: Longint): Boolean; virtual;

        function  Com_GetChar: Char; virtual;
        function  Com_SendChar(C: Char): Boolean; virtual;
        function  Com_GetDriverInfo: String; virtual;
        function  Com_GetHandle: Longint; virtual;
        function  Com_InitSucceeded: Boolean; virtual;

        procedure Com_Close; virtual;
        procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); virtual;
        procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc); virtual;
        procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); virtual;
        procedure Com_PurgeOutBuffer; virtual;
        procedure Com_PurgeInBuffer; virtual;
        procedure Com_PauseCom(CloseCom: Boolean); virtual;
        procedure Com_ResumeCom(OpenCom: Boolean); virtual;
        procedure Com_FlushOutBuffer(Slice: SliceProc); virtual;
        procedure Com_SendString(Temp: ShortString); virtual;
        procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); virtual;

        procedure Com_SetDataProc(ReadPtr, WritePtr: Pointer); virtual;

     end; { object TCommObj }

Type PCommObj = ^TCommObj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

{-- We disable warnings as this is just an abstract -}

constructor TCommObj.Init;
begin
  DontClose := false;
  InitFailed := false;
  BlockAll := false;
  ErrorStr := '';
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TCommObj.Done;
begin
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                   Parity: Char; StopBits: Byte): Boolean;
begin
  Com_Open := FALSE;
end; { func. Com_Open }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_OpenQuick(Handle: Longint);
begin
end; { proc. TCommObj.Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_Close;
begin
end; { proc. TCommObj.Com_Close }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_GetChar: Char;
begin
  Com_GetChar := #0;
end; { func. TCommObj.Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_SendChar(C: Char): Boolean;
begin
  Com_SendChar := FALSE;
end; { proc. TCommObj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
begin
end; { proc. TCommObj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
end; { proc. TCommObj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_CharAvail: Boolean;
begin
  Com_CharAvail := FALSE;
end; { func. TCommObj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_Carrier: Boolean;
begin
  Com_Carrier := FALSE;
end; { func. Comm_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SetDtr(State: Boolean);
begin
end; { proc. TCommObj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_OpenKeep(Comport: Byte): Boolean;
begin
  Com_OpenKeep := FALSE;
end; { func. TCommObj.Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Com_ReadyToSend := FALSE;
end; { func. TCommObj.Com_ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
end; { proc. TCommObj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_GetBPSrate: Longint;
begin
  Com_GetBpsRate := -1;
end; { func. TCommObj.Com_GetBPSrate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
begin
end; { proc. TCommObj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
end; { proc. TCommObj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_PurgeInBuffer;
begin
end; { proc. TCommObj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_PurgeOutBuffer;
begin
end; { proc. TCommObj.Com_PurgeOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_GetDriverInfo: String;
begin
  Com_GetDriverInfo := '';
end; { func. Com_GetDriverInfo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_GetHandle: Longint;
begin
  Com_GetHandle := -1;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_PauseCom(CloseCom: Boolean);
begin
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_ResumeCom(OpenCom: Boolean);
begin
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TCommObj.Com_InitSucceeded: Boolean;
begin
  Com_InitSucceeded := NOT InitFailed;
end; { func. Com_InitFailed }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_FlushOutBuffer(Slice: SliceProc);
var InFree,
    OutFree,
    InUsed,
    OutUsed  : Longint;
begin
  Com_GetBufferStatus(InFree, OutFree, InUsed, OutUsed);

  while (OutUsed > 1) AND (Com_Carrier) do
   { X00 (fossil) will never go below 1 ! }
    begin
      Com_GetBufferStatus(InFree, OutFree, InUsed, OutUsed);

      if @Slice <> nil then
        begin
          Slice;
          Slice;
        end; { if }
    end; { while }
end; { proc. Com_FlushOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc);
begin
  Com_SendBlock(Block, BlockLen, Written);
end; { proc. Com_SendWait }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SendString(Temp: ShortString);
var Written: Longint;
begin
  Com_SendBlock(Temp[1], Length(Temp), Written);
end; { proc. Com_SendString }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
begin
end; { proc. Com_Setflow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TCommObj.Com_SetDataProc(ReadPtr, WritePtr: Pointer);
begin
end; { Com_SetDataProc }

end.
