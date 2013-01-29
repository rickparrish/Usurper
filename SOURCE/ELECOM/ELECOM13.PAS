library ELECOM13;
{$H-} { important, turn off Ansi-Strings }
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.1,    (OS/2, Win32)
**              FreePascal    v0.99.12 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.02
** Created : 13-Jun-1999
** Last update : 28-Jun-2000
**
** Note: (c)1998-1999 by Maarten Bekers.
**       If you have any suggestions, please let me know.
**
*)
uses ComBase,
       {$IFDEF WIN32}
         W32SNGL,
       {$ENDIF}

       {$IFDEF OS2}
         Os2Com,
       {$ENDIF}

       Telnet;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 var ComObj   : pCommObj;
     ComSystem: Longint;
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComReadProc(var TempPtr: Pointer); stdcall;
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

procedure Int_ComWriteProc(var TempPtr: Pointer); stdcall;
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

procedure Com_Startup(ObjectType: Longint); stdcall;
begin
  ComSystem := ObjectType;

  Case Objecttype of
    {$IFDEF WIN32}
      01 : ComObj := New(pWin32Obj, Init);
    {$ENDIF}

    {$IFDEF OS2}
      01 : ComObj := New(pOs2Obj, Init);
    {$ENDIF}

      02 : ComObj := New(pTelnetObj, Init);
  end; { case }

  ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
end; { proc. Com_Startup }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_OpenQuick(Handle: Longint); stdcall;
begin
  ComObj^.Com_OpenQuick(Handle);
end; { proc. Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                   Parity: Char; StopBits: Byte): Boolean; stdcall;
begin
  Result := ComObj^.Com_Open(Comport, BaudRate, DataBits, Parity, StopBits);
end; { func. Com_Open }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_OpenKeep(Comport: Byte): Boolean; stdcall;
begin
  Result := ComObj^.Com_OpenKeep(Comport);
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); stdcall;
begin
  ComObj^.Com_GetModemStatus(LineStatus, ModemStatus);
end; { proc. Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); stdcall;
begin
  ComObj^.Com_SetLine(BpsRate, Parity, DataBits, StopBits);
end; { proc. Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetBPSrate: Longint; stdcall;
begin
  Result := ComObj^.Com_GetBpsRate;
end; { func. Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); stdcall;
begin
  ComObj^.Com_GetBufferStatus(InFree, OutFree, InUsed, OutUsed);
end; { proc. Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetDtr(State: Boolean); stdcall;
begin
  ComObj^.Com_SetDtr(State);
end; { proc. Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_CharAvail: Boolean; stdcall;
begin
  Result := ComObj^.Com_CharAvail;
end; { func. Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_Carrier: Boolean; stdcall;
begin
  Result := ComObj^.Com_Carrier;
end; { func. Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_ReadyToSend(BlockLen: Longint): Boolean; stdcall;
begin
  Result := ComObj^.Com_ReadyToSend(BlockLen);
end; { func. Com_ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetChar: Char; stdcall;
begin
  Result := ComObj^.Com_GetChar;
end; { func. Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_SendChar(C: Char): Boolean; stdcall;
begin
  Result := ComObj^.Com_SendChar(C);
end; { func. Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetDriverInfo: String; stdcall;
begin
  Result := ComObj^.Com_GetDriverInfo;
end; { func. Com_GetDriverInfo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_GetHandle: Longint; stdcall;
begin
  Result := ComObj^.Com_GetHandle;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_InitSucceeded: Boolean; stdcall;
begin
  Result := ComObj^.Com_InitSucceeded;
end; { func. Com_InitSucceeded }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_Close; stdcall;
begin
  ComObj^.Com_Close;
end; { proc. Com_Close }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); stdcall;
begin
  ComObj^.Com_SendBlock(Block, BlockLen, Written);
end; { proc. Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc); stdcall;
begin
  ComObj^.Com_SendWait(Block, BlockLen, Written, Slice);
end; { proc. Com_SendWait }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); stdcall;
begin
  ComObj^.Com_ReadBlock(Block, BlockLen, Reads);
end; { proc. Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PurgeOutBuffer; stdcall;
begin
  ComObj^.Com_PurgeOutBuffer;
end; { proc. Com_PurgeOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PurgeInBuffer; stdcall;
begin
  ComObj^.Com_PurgeInBuffer;
end; { proc. Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_PauseCom(CloseCom: Boolean); stdcall;
begin
  ComObj^.Com_PauseCom(CloseCom);
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ResumeCom(OpenCom: Boolean); stdcall;
begin
  ComObj^.Com_ResumeCom(OpenCom);
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_FlushOutBuffer(Slice: SliceProc); stdcall;
begin
  ComObj^.Com_FlushOutBuffer(Slice);
end; { proc. Com_FlushOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SendString(Temp: String); stdcall;
begin
  ComObj^.Com_SendString(Temp);
end; { Com_SendString }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetDontClose(Value: Boolean); stdcall;
begin
  ComObj^.DontClose := Value;
end; { proc. Com_SetDontClose }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); stdcall;
begin
  ComObj^.Com_SetFlow(SoftTX, SoftRX, Hard);
end; { proc. Com_Setflow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_ShutDown; stdcall;
begin
  Dispose(ComObj, Done);
end; { proc. Com_ShutDown }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_InitFailed: Boolean; stdcall;
begin
  Result := ComObj^.InitFailed;
end; { func. Com_Initfailed }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function Com_ErrorStr: String; stdcall;
begin
  Result := ComObj^.ErrorStr;
end; { func. Com_ErrorStr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

exports
  Com_Startup            index 1 name 'Com_Startup',
  Com_Open               index 2 name 'Com_Open',
  Com_OpenQuick          index 3 name 'Com_OpenQuick',
  Com_OpenKeep           index 4 name 'Com_OpenKeep',
  Com_GetModemStatus     index 5 name 'Com_GetModemStatus',
  Com_SetLine            index 6 name 'Com_SetLine',
  Com_GetBPSrate         index 7 name 'Com_GetBPSrate',
  Com_GetBufferStatus    index 8 name 'Com_GetBufferStatus',
  Com_SetDtr             index 09 name 'Com_SetDtr',
  Com_CharAvail          index 10 name 'Com_CharAvail',
  Com_Carrier            index 11 name 'Com_Carrier',
  Com_ReadyToSend        index 12 name 'Com_ReadyToSend',
  Com_GetChar            index 13 name 'Com_GetChar',
  Com_SendChar           index 14 name 'Com_SendChar',
  Com_GetDriverInfo      index 15 name 'Com_GetDriverInfo',
  Com_GetHandle          index 16 name 'Com_GetHandle',
  Com_InitSucceeded      index 17 name 'Com_InitSucceeded',
  Com_Close              index 18 name 'Com_Close',
  Com_SendBlock          index 19 name 'Com_SendBlock',
  Com_SendWait           index 20 name 'Com_SendWait',
  Com_ReadBlock          index 21 name 'Com_ReadBlock',
  Com_PurgeOutBuffer     index 22 name 'Com_PurgeOutBuffer',
  Com_PurgeInBuffer      index 23 name 'Com_PurgeInBuffer',
  Com_PauseCom           index 24 name 'Com_PauseCom',
  Com_ResumeCom          index 25 name 'Com_ResumeCom',
  Com_FlushOutBuffer     index 26 name 'Com_FlushOutBuffer',
  Com_SendString         index 27 name 'Com_SendString',
  Com_ShutDown           index 28 name 'Com_ShutDown',
  Com_SetDontClose       index 29 name 'Com_SetDontClose',
  Com_SetFlow            index 30 name 'Com_SetFlow',
  Com_InitFailed         index 31 name 'Com_InitFailed',
  Com_ErrorStr           index 32 name 'Com_ErrorStr';

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

begin
  ComObj := nil;
end.
