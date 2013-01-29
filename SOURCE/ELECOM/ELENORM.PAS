unit EleNORM;
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.1,    (OS/2, Win32)
**              FreePascal    v0.99.12 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.01
** Created : 13-Jun-1999
** Last update : 28-Jun-2000
**
** Note: (c)1998 - 2000 by Maarten Bekers. This unit tries to make it easier
**       to use EleCOM.
**
**  Usage:
**     Before calling any of these routines, first call Com_StartUp:
**     Pass the following number to it:
**        01 - Use the "modem" communications (OS/2, Win32 or FOSSIL)
**        02 - Use the TELNET type (OS/2 or Win32 only).
**
*)
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses ComBase
       {$IFDEF WIN32}
         , W32SNGL
         , Telnet
       {$ENDIF}

       {$IFDEF OS2}
         , Telnet
         , Os2com
       {$ENDIF}

       {$IFDEF GO32V2}
         , Fos_Com
       {$ENDIF}
        	
       {$IFDEF MSDOS}
         , Fos_com
       {$ENDIF}  ;


function  Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                    Parity: Char; StopBits: Byte): Boolean;
function  Com_OpenKeep(Comport: Byte): Boolean;
function  Com_CharAvail: Boolean;
function  Com_Carrier: Boolean;
function  Com_ReadyToSend(BlockLen: Longint): Boolean;
function  Com_GetChar: Char;
function  Com_SendChar(C: Char): Boolean;
function  Com_GetDriverInfo: String;
function  Com_GetHandle: Longint;
function  Com_InitSucceeded: Boolean;
procedure Com_Startup(ObjectType: Longint);
procedure Com_OpenQuick(Handle: Longint);
procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
procedure Com_SetDtr(State: Boolean);
procedure Com_Close;
procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc);
procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
procedure Com_PurgeOutBuffer;
procedure Com_PurgeInBuffer;
procedure Com_PauseCom(CloseCom: Boolean);
procedure Com_ResumeCom(OpenCom: Boolean);
procedure Com_FlushOutBuffer(Slice: SliceProc);
procedure Com_SendString(Temp: String);
procedure Com_SetDontClose(Value: Boolean);
procedure Com_ShutDown;
procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);


(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 var ComObj   : pCommObj;
     ComSystem: Longint;
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComReadProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case ComSystem of
      1 : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
      2 : PTelnetObj(ComObj)^.Com_ReadProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case ComSystem of
      1 : POs2Obj(ComObj)^.Com_ReadProc(TempPtr);
      2 : PTelnetObj(ComObj)^.Com_ReadProc(TempPtr);
    end; { case }
  {$ENDIF}
end; { proc. Int_ComReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComWriteProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case ComSystem of
      1 : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
      2 : PTelnetObj(ComObj)^.Com_WriteProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case ComSystem of
      1 : POs2Obj(ComObj)^.Com_WriteProc(TempPtr);
      2 : PTelnetObj(ComObj)^.Com_WriteProc(TempPtr);
    end; { case }
  {$ENDIF}
end; { proc. Int_ComWriteProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_Startup(ObjectType: Longint);
begin
  ComSystem := ObjectType;

  Case Objecttype of
    {$IFDEF WIN32}
      01 : ComObj := New(pWin32Obj, Init);
      02 : ComObj := New(pTelnetObj, Init);
    {$ENDIF}

    {$IFDEF OS2}
      01 : ComObj := New(pOs2Obj, Init);
      02 : ComObj := New(pTelnetObj, Init);
    {$ENDIF}

    {$IFDEF MSDOS}
      01 : ComObj := New(pFossilObj, Init);
    {$ENDIF}

    {$IFDEF GO32V2}
      01 : ComObj := New(pFossilObj, Init);
    {$ENDIF}
  end; { case }

  {$IFDEF WIN32}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}

  {$IFDEF OS2}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}
end; { proc. Com_Startup }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_OpenQuick(Handle: Longint);
begin
  ComObj^.Com_OpenQuick(Handle);
end; { proc. Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                   Parity: Char; StopBits: Byte): Boolean;
begin
  Com_Open := ComObj^.Com_Open(Comport, BaudRate, DataBits, Parity, StopBits);
end; { func. Com_Open }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_OpenKeep(Comport: Byte): Boolean;
begin
  Com_OpenKeep := ComObj^.Com_OpenKeep(Comport);
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
  ComObj^.Com_GetModemStatus(LineStatus, ModemStatus);
end; { proc. Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
begin
  ComObj^.Com_SetLine(BpsRate, Parity, DataBits, StopBits);
end; { proc. Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetBPSrate: Longint;
begin
  Com_GetBpsRate := ComObj^.Com_GetBpsRate;
end; { func. Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
  ComObj^.Com_GetBufferStatus(InFree, OutFree, InUsed, OutUsed);
end; { proc. Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetDtr(State: Boolean);
begin
  ComObj^.Com_SetDtr(State);
end; { proc. Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_CharAvail: Boolean;
begin
  Com_CharAvail := ComObj^.Com_CharAvail;
end; { func. Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_Carrier: Boolean;
begin
  Com_Carrier := ComObj^.Com_Carrier;
end; { func. Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Com_ReadyToSend := ComObj^.Com_ReadyToSend(BlockLen);
end; { func. Com_ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetChar: Char;
begin
  Com_GetChar := ComObj^.Com_GetChar;
end; { func. Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_SendChar(C: Char): Boolean;
begin
  Com_SendChar := ComObj^.Com_SendChar(C);
end; { func. Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetDriverInfo: String;
begin
  Com_GetDriverInfo := ComObj^.Com_GetDriverInfo;
end; { func. Com_GetDriverInfo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetHandle: Longint;
begin
  Com_GetHandle := ComObj^.Com_GetHandle;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_InitSucceeded: Boolean;
begin
  Com_InitSucceeded := ComObj^.Com_InitSucceeded;
end; { func. Com_InitSucceeded }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_Close;
begin
  ComObj^.Com_Close;
end; { proc. Com_Close }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
begin
  ComObj^.Com_SendBlock(Block, BlockLen, Written);
end; { proc. Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc);
begin
  ComObj^.Com_SendWait(Block, BlockLen, Written, Slice);
end; { proc. Com_SendWait }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
  ComObj^.Com_ReadBlock(Block, BlockLen, Reads);
end; { proc. Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PurgeOutBuffer;
begin
  ComObj^.Com_PurgeOutBuffer;
end; { proc. Com_PurgeOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PurgeInBuffer;
begin
  ComObj^.Com_PurgeInBuffer;
end; { proc. Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PauseCom(CloseCom: Boolean);
begin
  ComObj^.Com_PauseCom(CloseCom);
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ResumeCom(OpenCom: Boolean);
begin
  ComObj^.Com_ResumeCom(OpenCom);
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_FlushOutBuffer(Slice: SliceProc);
begin
  ComObj^.Com_FlushOutBuffer(Slice);
end; { proc. Com_FlushOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendString(Temp: String);
begin
  ComObj^.Com_SendString(Temp);
end; { Com_SendString }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetDontClose(Value: Boolean);
begin
  ComObj^.DontClose := Value;
end; { proc. Com_SetDontClose }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ShutDown;
begin
  Dispose(ComObj, Done);
end; { proc. Com_ShutDown }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
begin
  ComObj^.Com_SetFlow(SoftTX, SoftRX, Hard);
end; { proc. Com_SetFlow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

begin
  ComObj := nil;
end.
