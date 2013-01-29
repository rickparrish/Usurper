unit WIN32COM;
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.0,    (OS/2, Win32)
**              FreePascal    v0.99.15 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.01
** Created : 21-May-1998
** Last update : 20-Feb-2000
**
** Note: (c) 1998-2000 by Maarten Bekers
**
*)

This unit is not supported anymore.
Remove this in order to be compiled anyway. The next release of EleCOM will
not include WIN32COM.PAS anymore. W32SNGL.PAS is the replacement unit.

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses Windows, Combase, BufUnit, Threads
     {$IFDEF VirtualPascal}
       ,Use32
     {$ENDIF};

Const WriteTimeout   = 20000;                             { Wait max. 20 secs }
      ReadTimeOut    = 20000;                    { General event, 20 secs max }

      InBufSize      = 1024 * 32;
      OutBufSize     = 1024 * 32;


type TWin32Obj = Object(TCommObj)
        ReadProcPtr: Pointer;             { Pointer to TX/RX handler (thread) }
        WriteProcPtr: Pointer;            { Pointer to TX/RX handler (thread) }
        ThreadsInitted: Boolean;          { Are the thread(s) up and running? }

        SaveHandle    : THandle;

        InitPortNr    : Longint;
        InitHandle    : Longint;

        ReadOL        : TOverLapped;    { Overlapped structure for ReadFile }
        WriteOL       : TOverLapped;   { Overlapped structure for WriteFile }

        InBuffer      : ^BufArrayObj;       { Buffer system internally used }
        OutBuffer     : ^BufArrayObj;

        ReadEvent     : PSysEventObj; { Event set by ReadFile overlapped routine }
        WriteEvent    : PSysEventObj; { Event set by WriteFile overlapped routine }
        RecvEvent     : PSysEventObj;

        DoTxEvent     : PSysEventObj;{ Event manually set when we have to transmit }

        TxClosedEvent : PSysEventObj; { Event set when the Tx thread is closed }
        RxClosedEvent : PSysEventObj; { Event set when the Rx thread is closed }

        CriticalTx    : PExclusiveObj;                   { Critical sections }
        CriticalRx    : PExclusiveObj;

        TxThread      : PThreadsObj;     { The Transmit and Receive threads }
        RxThread      : PThreadsObj;

        EndThreads    : Boolean;    { Set to true when we have to end the threads }

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
        function  Com_GetHandle: Longint; virtual;

        procedure Com_OpenQuick(Handle: Longint); virtual;
        procedure Com_Close; virtual;
        procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); virtual;
        procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); virtual;
        procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); virtual;
        procedure Com_SetDtr(State: Boolean); virtual;
        procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); virtual;
        procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); virtual;
        procedure Com_PurgeInBuffer; virtual;
        procedure Com_PurgeOutBuffer; virtual;

        procedure Com_PauseCom(CloseCom: Boolean); virtual;
        procedure Com_ResumeCom(OpenCom: Boolean); virtual;
        procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); virtual;

        procedure Com_SetDataProc(ReadPtr, WritePtr: Pointer); virtual;

        procedure Com_ReadProc(var TempPtr: Pointer);
        procedure Com_WriteProc(var TempPtr: Pointer);

        function  Com_StartThread: Boolean;
        procedure Com_InitVars;
        procedure Com_StopThread;
        procedure Com_InitDelayTimes;
     end; { object TWin32Obj }

type PWin32Obj = ^TWin32Obj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses SysUtils;

{$IFDEF FPC}
  {$I WINDEF.FPC}
{$ENDIF}

const
  dcb_Binary              = $00000001;
  dcb_ParityCheck         = $00000002;
  dcb_OutxCtsFlow         = $00000004;
  dcb_OutxDsrFlow         = $00000008;
  dcb_DtrControlMask      = $00000030;
  dcb_DtrControlDisable   = $00000000;
  dcb_DtrControlEnable    = $00000010;
  dcb_DtrControlHandshake = $00000020;
  dcb_DsrSensivity        = $00000040;
  dcb_TXContinueOnXoff    = $00000080;
  dcb_OutX                = $00000100;
  dcb_InX                 = $00000200;
  dcb_ErrorChar           = $00000400;
  dcb_NullStrip           = $00000800;
  dcb_RtsControlMask      = $00003000;
  dcb_RtsControlDisable   = $00000000;
  dcb_RtsControlEnable    = $00001000;
  dcb_RtsControlHandshake = $00002000;
  dcb_RtsControlToggle    = $00003000;
  dcb_AbortOnError        = $00004000;
  dcb_Reserveds           = $FFFF8000;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TWin32Obj.Init;
begin
  inherited Init;

  InitPortNr := -1;
  InitHandle := -1;
  ThreadsInitted := false;
  Com_InitVars;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TWin32Obj.Done;
begin
  inherited done;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_ReadProc(var TempPtr: Pointer);
var EventMask : DWORD;
    Success   : Boolean;
    Props     : TCommProp;
    ReturnCode: Longint;
    DidRead   : DWORD;
    BlockLen  : Longint;

    RecvOL    : tOverlapped;
begin
  New(RecvEvent, Init);
  if NOT RecvEvent^.CreateEvent(true) then EXIT;

  FillChar(RecvOL, SizeOf(tOverLapped), 0);
  RecvOL.hEvent := RecvEvent^.SemHandle;

  EventMask := EV_RXCHAR;
  SetCommMask(SaveHandle, EventMask);     { Signal us if anything is received }

  repeat
     WaitCommEvent(SaveHandle, EventMask, @RecvOL);
     if EndThreads then EXIT;

     repeat
        ReturnCode := WaitForSingleObject(RecvOL.hEvent, 500);
        if ReturnCode = WAIT_OBJECT_0 then
         begin
           Success := true
         end { if }
           else Success := false;

        if EndThreads then BREAK;
     until (Success);

     DidRead := 00;

     if (NOT Success) OR (EventMask = 0) then EXIT;
     if (EndThreads) then EXIT;

     {----------------- Start reading the gathered date ---------------------}
     CriticalRx^.EnterExclusive;

     FillChar(Props, SizeOf(TCommProp), 0);

     if GetCommProperties(SaveHandle, Props) then
      if InBuffer^.BufRoom > 0 then
        begin
          BlockLen := Props.dwCurrentRxQueue;

          if BlockLen > InBuffer^.BufRoom then
            BlockLen := InBuffer^.BufRoom;

          Success := ReadFile(SaveHandle,
                              InBuffer^.TmpBuf^,
                              BlockLen,
                              DidRead,
                              @ReadOL);

          if NOT Success then
            begin
              ReturnCode := GetLastError;

              if ReturnCode = ERROR_IO_PENDING then
                begin
                  ReturnCode := WaitForSingleObject(ReadOL.hEvent, ReadTimeOut);

                  if ReturnCode = WAIT_OBJECT_0 then
                    begin
                      GetOverLappedResult(SaveHandle, ReadOL, DidRead, false);
                    end; { if }
                end; { if }
            end
              else GetOverlappedResult(SaveHandle, ReadOL, DidRead, false);

          if DidRead > 00 then
            InBuffer^.Put(InBuffer^.TmpBuf^, DidRead);
       end; { if }

     CriticalRx^.LeaveExclusive;
  until EndThreads;

  RxClosedEvent^.SignalEvent;
  ExitThisThread;
end; { proc. ComReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_WriteProc(var TempPtr: Pointer);
var BlockLen  : Longint;
    Written   : DWORD;
    ReturnCode: Longint;
    Success   : Boolean;
begin
  repeat
     if DoTxEvent^.WaitForEvent(WriteTimeOut) then
      if NOT EndThreads then
       begin
         CriticalTx^.EnterExclusive;
         DoTxEvent^.ResetEvent;

         if OutBuffer^.BufUsed > 00 then
           begin
             Written := 00;
             BlockLen := OutBuffer^.Get(OutBuffer^.TmpBuf^, OutBuffer^.BufUsed, false);

             Success := WriteFile(SaveHandle,
                                  OutBuffer^.TmpBuf^,
                                  BlockLen,
                                  Written,
                                  @WriteOL);
             if NOT Success then
               begin
                 ReturnCode := GetLastError;

                 if ReturnCode = ERROR_IO_PENDING then
                   begin
                     ReturnCode := WaitForSingleObject(WriteOL.hEvent, WriteTimeOut);

                     if ReturnCode = WAIT_OBJECT_0 then
                       begin
                         if GetOverLappedResult(SaveHandle, WriteOL, Written, false) then
                           begin
                             ResetEvent(WriteOL.hEvent);
                           end; { if }
                       end; { if }
                   end; { result is pending }
               end { if }
                 else begin

                         if GetOverLappedResult(SaveHandle, WriteOL, Written, false) then
                           begin
                             ResetEvent(WriteOL.hEvent);
                           end; { if }
                      end; { if (did succeed) }

             ReturnCode := OutBuffer^.Get(OutBuffer^.TmpBuf^, Written, true);
             if Written <> BlockLen then
               DoTxEvent^.SignalEvent;
           end; { if }

         CriticalTx^.LeaveExclusive;
       end; { if }

  until EndThreads;

  TxClosedEvent^.SignalEvent;
  ExitThisThread;
end; { proc. ComWriteProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_StartThread: Boolean;
begin
  Result := false;
  EndThreads := false;
  if ThreadsInitted then EXIT;
  ThreadsInitted := true;

  {----------------------- Create all the events ----------------------------}
  New(ReadEvent, Init);
  if NOT ReadEvent^.CreateEvent(true) then EXIT;

  New(WriteEvent, Init);
  if NOT WriteEvent^.CreateEvent(true) then EXIT;

  New(DoTxEvent, Init);
  if NOT DoTxEvent^.CreateEvent(false) then EXIT;

  New(RxClosedEvent, Init);
  if NOT RxClosedEvent^.CreateEvent(false) then EXIT;

  New(TxClosedEvent, Init);
  if NOT TxClosedEvent^.CreateEvent(false) then EXIT;

  {-------------- Startup the buffers and overlapped events -----------------}
  FillChar(WriteOL, SizeOf(tOverLapped), 0);
  FillChar(ReadOL, SizeOf(tOverLapped), 0);
  WriteOl.hEvent := WriteEvent^.SemHandle;
  ReadOl.hEvent := ReadEvent^.SemHandle;

  New(InBuffer, Init(InBufSize));
  New(OutBuffer, Init(OutBufSize));

  if (InBuffer^.TxtArr=nil) OR (InBuffer^.TmpBuf=nil) then EXIT;
  if (OutBuffer^.TxtArr=nil) OR (OutBuffer^.TmpBuf=nil) then EXIT;

  {-------------------- Startup a seperate write thread ---------------------}
  New(CriticalTx, Init);
  CriticalTx^.CreateExclusive;

  New(TxThread, Init);
  if NOT TxThread^.CreateThread(16384,                           { Stack size }
                                @WriteProcPtr,             { Actual procedure }
                                nil,                             { Parameters }
                                0)                           { Creation flags }
                                 then EXIT;

  {-------------------- Startup a seperate read thread ----------------------}
  New(CriticalRx, Init);
  CriticalRx^.CreateExclusive;

  New(RxThread, Init);
  if NOT RxThread^.CreateThread(16384,                           { Stack size }
                                @ReadProcPtr,              { Actual procedure }
                                nil,                             { Parameters }
                                0)                           { Creation flags }
                                 then EXIT;

  Result := true;
end; { proc. Com_StartThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_InitVars;
begin
  DoTxEvent := nil;
  RxClosedEvent := nil;
  TxClosedEvent := nil;
  RecvEvent := nil;
  ReadEvent := nil;
  WriteEvent := nil;
  TxThread := nil;
  RxThread := nil;

  InBuffer := nil;
  OutBuffer := nil;
  CriticalRx := nil;
  CriticalTx := nil;
end; { proc. Com_InitVars }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_StopThread;
begin
  EndThreads := true;
  ThreadsInitted := false;

  if DoTxEvent <> nil then DoTxEvent^.SignalEvent;

  if TxThread <> nil then TxThread^.CloseThread;
  if RxThread <> nil then RxThread^.CloseThread;

  if TxClosedEvent <> nil then
   if NOT TxClosedEvent^.WaitForEvent(1000) then
     TxThread^.TerminateThread(0);

  if RxClosedEvent <> nil then
   if NOT RxClosedEvent^.WaitForEvent(1000) then
     RxThread^.TerminateThread(0);

  if TxThread <> nil then Dispose(TxThread, Done);
  if RxThread <> nil then Dispose(RxThread, Done);
  if DoTxEvent <> nil then Dispose(DoTxEvent, Done);
  if RxClosedEvent <> nil then Dispose(RxClosedEvent, Done);
  if TxClosedEvent <> nil then Dispose(TxClosedEvent, Done);

  if CriticalTx <> nil then Dispose(CriticalTx, Done);
  if CriticalRx <> nil then Dispose(CriticalRx, Done);

  if InBuffer <> nil then Dispose(InBuffer, Done);
  if OutBuffer <> nil then Dispose(OutBuffer, Done);

  if RecvEvent <> nil then Dispose(RecvEvent, Done);
  if ReadEvent <> nil then Dispose(ReadEvent, Done);
  if WriteEvent <> nil then Dispose(WriteEvent, Done);

  Com_InitVars;
end; { proc. Com_StopThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_InitDelayTimes;
var CommTimeOut: TCommTimeouts;
    RC         : Longint;
begin
  FillChar(CommTimeOut, SizeOf(TCommTimeOuts), 00);
  CommTimeOut.ReadIntervalTimeout := MAXDWORD;

  if NOT SetCommTimeOuts(SaveHandle, CommTimeOut) then
    begin
       RC := GetLastError;
       { ErrorStr := 'Error setting communications timeout: #'+IntToStr(RC) + ' / ' + SysErrorMessage(rc)); }
    end; { if }

end; { proc. InitDelayTimes }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_GetHandle: Longint;
begin
  Result := SaveHandle;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_OpenQuick(Handle: Longint);
var LastError: Longint;
begin
  SaveHandle := Handle;
  InitHandle := Handle;

  FillChar(ReadOl, SizeOf(ReadOl), 00);
  FillChar(WriteOl, SizeOf(WriteOl), 00);

  Com_InitDelayTimes;

  if NOT SetupComm(Com_GetHandle, 1024, 1024) then
    begin
      LastError := GetLastError;

      { ErrorStr := 'Error setting up communications buffer: #'+IntToStr(LastError) + ' / '+SysErrorMessage(LastError); }
    end; { if }

  InitFailed := NOT Com_StartThread;
  Com_SetLine(-1, 'N', 8, 1);
end; { proc. TWin32Obj.Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_OpenKeep(Comport: Byte): Boolean;
var TempSave   : THandle;
    Security   : TSECURITYATTRIBUTES;
    LastError  : Longint;
begin
  InitPortNr := Comport;

  FillChar(ReadOl, SizeOf(ReadOl), 00);
  FillChar(WriteOl, SizeOf(WriteOl), 00);

  FillChar(Security, SizeOf(TSECURITYATTRIBUTES), 0);
  Security.nLength := SizeOf(TSECURITYATTRIBUTES);
  Security.lpSecurityDescriptor := nil;
  Security.bInheritHandle := true;

  TempSave := CreateFile(PChar('\\.\COM' + IntToStr(ComPort)),
                         GENERIC_READ or GENERIC_WRITE,
                         0,
                         @Security,                             { No Security }
                         OPEN_EXISTING,                     { Creation action }
                         FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED,
                         0);                                    { No template }
  LastError := GetLastError;
  if LastError <> 0 then
    ErrorStr := 'Unable to open communications port';

  SaveHandle := TempSave;
  Result := (TempSave <> INVALID_HANDLE_VALUE);

  if Result then             { Make sure that "CharAvail" isn't going to wait }
    begin
      Com_InitDelayTimes;
    end; { if }

  if NOT SetupComm(Com_GetHandle, 1024, 1024) then
    begin
      LastError := GetLastError;

      { ErrorStr := 'Error setting up communications buffer: #'+IntToStr(LastError) + ' / '+SysErrorMessage(LastError); }
    end; { if }

  InitFailed := NOT Com_StartThread;
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                            Parity: Char; StopBits: Byte): Boolean;
begin
  Com_Open := Com_OpenKeep(Comport);
  Com_SetLine(Baudrate, Parity, DataBits, StopBits);
end; { func. TWin32Obj.Com_OpenCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
var DCB   : TDCB;
    BPSID : Longint;
begin
  if BpsRate = 11520 then
    BpsRate := 115200;

  GetCommState(Com_GetHandle, DCB);

  if NOT (Parity in ['N', 'E', 'O', 'M']) then Parity := 'N';
  if BpsRate >= 0 then dcb.BaudRate := BpsRate;
  dcb.StopBits := ONESTOPBIT;

  Case Parity of
    'N' : dcb.Parity := NOPARITY;
    'E' : dcb.Parity := EVENPARITY;
    'O' : dcb.Parity := ODDPARITY;
    'M' : dcb.Parity := MARKPARITY;
  end; { case }

  if StopBits = 1 then
    dcb.StopBits := ONESTOPBIT;
  dcb.ByteSize := DataBits;
  dcb.Flags := dcb.Flags OR dcb_Binary or Dcb_DtrControlEnable;

  if not SetCommState (Com_GetHandle, DCB) then
    begin
      BPSId := GetLastError;

      { ErrorStr := 'Error setting up communications parameters: #'+IntToStr(BpsId) + ' / '+SysErrorMessage(BpsId); }
    end; { if }
end; { proc. TWin32Obj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_Close;
begin
  if DontClose then EXIT;

  if Com_GetHandle <> INVALID_HANDLE_VALUE then
    begin
      Com_StopThread;
      CloseHandle(Com_GetHandle);

      SaveHandle := INVALID_HANDLE_VALUE;
    end;

end; { func. TWin32Obj.Com_CloseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_SendChar(C: Char): Boolean;
var Written: Longint;
begin
  Com_SendBlock(C, SizeOf(C), Written);
  Com_SendChar := (Written = SizeOf(c));
end; { proc. TWin32Obj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_GetChar: Char;
var Reads: Longint;
begin
  Com_ReadBlock(Result, SizeOf(Result), Reads);
end; { func. TWin32Obj.Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
begin
  if OutBuffer^.BufRoom < BlockLen then
   repeat
    {$IFDEF WIN32}
      Sleep(1);
    {$ENDIF}

    {$IFDEF OS2}
      DosSleep(1);
    {$ENDIF}
   until (OutBuffer^.BufRoom >= BlockLen) OR (NOT Com_Carrier);

  CriticalTx^.EnterExclusive;
    Written := OutBuffer^.Put(Block, BlockLen);
  CriticalTx^.LeaveExclusive;

  DoTxEvent^.SignalEvent;
end; { proc. TWin32Obj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
  if InBuffer^.BufUsed < BlockLen then
    begin
      repeat
        Sleep(1);
      until (InBuffer^.BufUsed >= BlockLen) OR (NOT Com_Carrier);
    end; { if }

  CriticalRx^.EnterExclusive;
    Reads := InBuffer^.Get(Block, BlockLen, true);
  CriticalRx^.LeaveExclusive;
end; { proc. TWin32Obj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_CharAvail: Boolean;
begin
  Result := (InBuffer^.BufUsed > 0);
end; { func. TWin32Obj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_Carrier: Boolean;
var Status: DWORD;
begin
  GetCommModemStatus(Com_GetHandle,
                     Status);

  Result := (Status AND MS_RLSD_ON) <> 00;
end; { func. TWin32Obj.Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
var Data: DWORD;
begin
  GetCommModemStatus(Com_GetHandle, Data);

  ModemStatus := ModemStatus and $0F;
  ModemStatus := ModemStatus or Byte(Data);
end; { proc. TWin32Obj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_SetDtr(State: Boolean);
begin
  if State then
    EscapeCommFunction(Com_GetHandle, SETDTR)
     else EscapeCommFunction(Com_GetHandle, CLRDTR);
end; { proc. TWin32Obj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_GetBpsRate: Longint;
var DCB   : TDCB;
    BPSID : Longint;
begin
  GetCommState(Com_GetHandle, DCB);

  Com_GetBpsRate := dcb.Baudrate;
end; { func. TWin32Obj.Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
  InFree := InBuffer^.BufRoom;
  OutFree := OutBuffer^.BufRoom;
  InUsed := InBuffer^.BufUsed;
  OutUsed := OutBuffer^.BufUsed;
end; { proc. TWin32Obj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_PurgeInBuffer;
begin
  CriticalRx^.EnterExclusive;

  InBuffer^.Clear;
  PurgeComm(Com_GetHandle, PURGE_RXCLEAR);

  CriticalRx^.LeaveExclusive;
end; { proc. TWin32Obj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_PurgeOutBuffer;
begin
  CriticalTx^.EnterExclusive;

  OutBuffer^.Clear;
  PurgeComm(Com_GetHandle, PURGE_TXCLEAR);

  CriticalTx^.LeaveExclusive;
end; { proc. TWin32Obj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TWin32Obj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Result := OutBuffer^.BufRoom >= BlockLen;
end; { func. ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_PauseCom(CloseCom: Boolean);
begin
  if CloseCom then Com_Close
    else Com_StopThread;
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_ResumeCom(OpenCom: Boolean);
begin
  if OpenCom then
      begin
        if InitPortNr <> -1 then Com_OpenKeep(InitPortNr)
          else Com_OpenQuick(InitHandle);
      end
       else InitFailed := NOT Com_StartThread;
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
var DCB   : TDCB;
    BPSID : Longint;
begin
  GetCommState(Com_GetHandle, DCB);

  if Hard then
    dcb.Flags := dcb.Flags OR dcb_OutxCtsFlow OR dcb_RtsControlHandshake;

  if SoftTX then
    dcb.Flags := dcb.Flags OR dcb_OutX;

  if SoftRX then
    dcb.Flags := dcb.Flags OR dcb_InX;

  if not SetCommState (Com_GetHandle, DCB) then
    begin
      BPSId := GetLastError;

      { ErrorStr := 'Error setting up communications parameters: #'+IntToStr(BpsId) + ' / '+SysErrorMessage(BpsId); }
    end; { if }
end; { proc. Com_SetFlow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TWin32Obj.Com_SetDataProc(ReadPtr, WritePtr: Pointer);
begin
  ReadProcPtr := ReadPtr;
  WriteProcPtr := WritePtr;
end; { proc. Com_SetDataProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
