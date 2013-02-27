unit LinuxCom;
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

uses Combase, Linux;

type TLinuxObj = Object(TCommObj)
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
     end; { object TLinuxObj }

Type PLinuxObj = ^TLinuxObj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

var
  FCarrier: Boolean;

procedure SignalHandler(ASig: LongInt); cdecl;
begin
  FCarrier := False;
end;

constructor TLinuxObj.Init;
var
  Act, Old: TSigAction;
begin
  inherited Init;

  FCarrier := True;

  FillChar(Act, SizeOf(Act), 0);
  Act.sa_Handler := @SignalHandler;
  Act.sa_Flags := SA_NODEFER;
  LnxSigAction(SIGHUP, Act, Old);
  LnxSigAction(SIGTERM, Act, Old); 
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TLinuxObj.Done;
begin
  inherited Done;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: 
Byte;
                             Parity: Char; StopBits: Byte): Boolean;
begin
  {-------------------------- Open the comport -----------------------------}
  FosPort := (ComPort - 01);

  Com_Open := True;
  InitFailed := False;
end; { func. TLinuxObj.Com_OpenCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_OpenKeep(Comport: Byte): Boolean;
begin
  FosPort := (ComPort - 01);

  Com_OpenKeep := True;
  InitFailed := False;
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_OpenQuick(Handle: Longint);
begin
  {-------------------------- Open the comport -----------------------------}
  FosPort := (Handle - 01);

  InitFailed := False;
end; { proc. Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, 
Stopbits: Byte);
begin
end; { proc. TLinuxObj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_GetBPSrate: Longint;
begin
  Com_GetBPSrate := 57600;
end; { func. TLinuxObj.Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_Close;
begin
end; { proc. TLinuxObj.Com_Close }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_SendChar(C: Char): Boolean;
begin
  Com_SendChar := True;
end; { proc. TLinuxObj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_GetChar: Char;
begin
  Com_GetChar := #0;
end; { proc. TLinuxObj.Com_ReadChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
  Reads := 0;
end; { proc. TLinuxObj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
begin
  Written := 0;
end; { proc. TLinuxObj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_CharAvail: Boolean;
begin
  Com_CharAvail := False;
end;  { func. TLinuxObj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function  TLinuxObj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Com_ReadyToSend := True;
end; { func. TLinuxObj.Com_ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_Carrier: Boolean;
begin
  Com_Carrier := FCarrier;
end; { func. TLinuxObj.Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_SetDtr(State: Boolean);
begin
end; { proc. TLinuxObj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
end; { proc. TLinuxObj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
end; { proc. TLinuxObj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_GetDriverInfo: String;
begin
  Com_GetDriverInfo := '';
end; { proc. TLinuxObj.Com_GetDriverInfo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_PurgeInBuffer;
begin
end; { proc. TLinuxObj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_PurgeOutBuffer;
begin
end; { proc. TLinuxObj.Com_PurgeOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TLinuxObj.Com_GetHandle: longint;
begin
  Com_GetHandle := FosPort;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc);
begin
  Written := 0;
end; { proc. Com_SendWait }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TLinuxObj.Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
begin
end; { proc. Com_SetFlow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end. { unit FOS_COM }
