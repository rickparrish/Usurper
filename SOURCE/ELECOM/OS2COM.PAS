unit OS2COM;
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
** Last update : 12-May-1999
**
** Note: (c) 1998-1999 by Maarten Bekers
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses Combase, BufUnit, Threads,
     {$IFDEF OS2}
       Os2Base
     {$ENDIF}

     {$IFDEF VirtualPascal}
       ,Use32
     {$ENDIF};

Const WriteTimeout   = 20000;                             { Wait max. 20 secs }
      ReadTimeOut    = 5000;                      { General event, 5 secs max }

      InBufSize      = 1024 * 32;
      OutBufSize     = 1024 * 32;

type TOs2Obj = Object(TCommObj)
        ReadProcPtr: Pointer;             { Pointer to TX/RX handler (thread) }
        WriteProcPtr: Pointer;            { Pointer to TX/RX handler (thread) }
        ThreadsInitted: Boolean;          { Are the thread(s) up and running? }

        ClientHandle  : Longint;

        InBuffer      : ^BufArrayObj;             { Buffer system internally used }
        OutBuffer     : ^BufArrayObj;

        DoTxEvent     : PSysEventObj; { Event manually set when we have to transmit }
        DoRxEvent     : PSysEventObj;      { Event manually set when we need data }

        TxClosedEvent : PSysEventObj;    { Event set when the Tx thread is closed }
        RxClosedEvent : PSysEventObj;    { Event set when the Rx thread is closed }

        CriticalTx    : PExclusiveObj;                        { Critical sections }
        CriticalRx    : PExclusiveObj;

        TxThread      : PThreadsObj;           { The Transmit and Receive threads }
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
        procedure Com_FlushOutBuffer(Slice: SliceProc); virtual;

        procedure Com_PauseCom(CloseCom: Boolean); virtual;
        procedure Com_ResumeCom(OpenCom: Boolean); virtual;
        procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); virtual;

        procedure Com_SetDataProc(ReadPtr, WritePtr: Pointer); virtual;

        procedure Com_ReadProc(var TempPtr: Pointer);
        procedure Com_WriteProc(var TempPtr: Pointer);

        function  Com_StartThread: Boolean;
        procedure Com_InitVars;
        procedure Com_StopThread;
     end; { object TOs2Obj }

Type POs2Obj = ^TOs2Obj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses SysUtils;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TOs2Obj.Init;
begin
  inherited Init;

  Com_InitVars;
  ThreadsInitted := FALSE;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TOs2Obj.Done;
begin
  inherited done;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_ReadProc(var TempPtr: Pointer);
Type TBuffRec = Record
         BytesIn   : SmallWord;               { Number of bytes in the buffer }
         MaxSize   : SmallWord;                     { Full size of the buffer }
     end; { TBuffRec }

var Available : Boolean;
    BytesRead : Longint;
    BlockLen  : Longint;
    ReturnCode: Longint;
    BufferRec : TBuffRec;
begin
  repeat
     if DoRxEvent.WaitForEvent(ReadTimeOut) then
      if NOT EndThreads then
       begin
         CriticalRx.EnterExclusive;
         ReturnCode := 0;
         DosDevIoCtl(ClientHandle,                             { File-handle }
                     ioctl_Async,                                 { Category }
                     async_GetInQueCount,                         { Function }
                     nil,                                           { Params }
                     ReturnCode,                          { Max param length }
                     @ReturnCode,                             { Param Length }
                     @BufferRec,                             { Returned data }
                     SizeOf(TBuffRec),                     { Max data length }
                     @ReturnCode);                             { Data length }

         Available := (BufferRec.BytesIn > 00);

         DoRxEvent.ResetEvent;

         if Available then
          begin
            {----------- Start reading the gathered date -------------------}

            if InBuffer^.BufRoom > 0 then
              begin
                BlockLen := BufferRec.BytesIn;
                if BlockLen > InBuffer^.BufRoom then
                  BlockLen := InBuffer^.BufRoom;
                if BlockLen > 1024 then
                  BlockLen := 1024;

                if BlockLen > 00 then
                 begin
                   DosRead(ClientHandle,
                           InBuffer^.TmpBuf,
                           BlockLen,
                           BytesRead);

                   InBuffer^.Put(InBuffer^.TmpBuf, BytesRead);
                 end; { if }

              end; { if }
          end; { if available }

         CriticalRx.LeaveExclusive;
       end; { if RxEvent }
  until EndThreads;

  RxClosedEvent.SignalEvent;
  ExitThisThread;
end; { proc. ComReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_WriteProc(var TempPtr: Pointer);
var BlockLen    : Longint;
    Written     : Longint;
    ReturnCode  : Longint;
    TempBuf     : ^CharBufType;
begin
  New(TempBuf);

  repeat
     if DoTxEvent.WaitForEvent(WriteTimeOut) then
      if NOT EndThreads then
       begin
         CriticalTx.EnterExclusive;
         DoTxEvent.ResetEvent;

         if OutBuffer^.BufUsed > 00 then
           begin
             Written := 00;
             BlockLen := OutBuffer^.Get(OutBuffer^.TmpBuf, OutBuffer^.BufUsed, false);

             DosWrite(ClientHandle,
                      OutBuffer^.TmpBuf,
                      BlockLen,
                      Written);

             ReturnCode := OutBuffer^.Get(OutBuffer^.TmpBuf, Written, true);
             if Written <> BlockLen then
                DoTxEvent.SignalEvent;
           end; { if }

         CriticalTx.LeaveExclusive;
       end; { if }

  until EndThreads;

  Dispose(TempBuf);
  TxClosedEvent.SignalEvent;
  ExitThisThread;
end; { proc. ComWriteProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_StartThread: Boolean;
begin
  Result := false;
  EndThreads := false;
  if ThreadsInitted then EXIT;
  ThreadsInitted := true;

  {----------------------- Create all the events ----------------------------}
  New(DoTxEvent, Init);
  if NOT DoTxEvent.CreateEvent(false) then EXIT;

  New(DoRxEvent, Init);
  if NOT DoRxEvent.CreateEvent(false) then EXIT;

  New(RxClosedEvent, Init);
  if NOT RxClosedEvent.CreateEvent(false) then EXIT;

  New(TxClosedEvent, Init);
  if NOT TxClosedEvent.CreateEvent(false) then EXIT;


  {-------------- Startup the buffers and overlapped events -----------------}
  New(InBuffer, Init(InBufSize));
  New(OutBuffer, Init(OutBufSize));

  {-------------------- Startup a seperate write thread ---------------------}
  New(CriticalTx, Init);
  CriticalTx.CreateExclusive;

  New(TxThread, Init);
  if NOT TxThread.CreateThread(16384,                            { Stack size }
                               WriteProcPtr,               { Actual procedure }
                               nil,                              { Parameters }
                               0)                            { Creation flags }
                                 then EXIT;

  {-------------------- Startup a seperate read thread ----------------------}
  New(CriticalRx, Init);
  CriticalRx.CreateExclusive;

  New(RxThread, Init);
  if NOT RxThread.CreateThread(16384,                            { Stack size }
                               ReadProcPtr,                { Actual procedure }
                               nil,                              { Parameters }
                               0)                            { Creation flags }
                                 then EXIT;

  Result := true;
end; { proc. Com_StartThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_InitVars;
begin
  DoTxEvent := nil;
  DoRxEvent := nil;
  RxClosedEvent := nil;
  TxClosedEvent := nil;
  TxThread := nil;
  RxThread := nil;

  InBuffer := nil;
  OutBuffer := nil;
  CriticalRx := nil;
  CriticalTx := nil;
end; { proc. Com_InitVars }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_StopThread;
begin
  EndThreads := true;
  ThreadsInitted := false;

  if DoTxEvent <> nil then DoTxEvent.SignalEvent;
  if DoTxEvent <> nil then DoRxEvent.SignalEvent;


  if TxThread <> nil then TxThread.CloseThread;
  if RxThread <> nil then RxThread.CloseThread;

  if TxClosedEvent <> nil then
   if NOT TxClosedEvent^.WaitForEvent(1000) then
     TxThread.TerminateThread(0);

  if RxClosedEvent <> nil then
   if NOT RxClosedEvent^.WaitForEvent(1000) then
     RxThread.TerminateThread(0);

  if TxThread <> nil then TxThread.Done;
  if RxThread <> nil then RxThread.Done;

  if DoTxEvent <> nil then Dispose(DoTxEvent, Done);
  if DoRxEvent <> nil then Dispose(DoRxEvent, Done);
  if RxClosedEvent <> nil then Dispose(RxClosedEvent, Done);
  if TxClosedEvent <> nil then Dispose(TxClosedEvent, Done);

  if CriticalTx <> nil then Dispose(CriticalTx, Done);
  if CriticalRx <> nil then Dispose(CriticalRx, Done);

  if InBuffer <> nil then Dispose(InBuffer, Done);
  if OutBuffer <> nil then Dispose(OutBuffer, Done);

  Com_InitVars;
end; { proc. Com_StopThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_GetHandle: Longint;
begin
  Result := ClientHandle;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_OpenQuick(Handle: Longint);
begin
  ClientHandle := Handle;

  InitFailed := NOT Com_StartThread;
end; { proc. TOs2Obj.Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_OpenKeep(Comport: Byte): Boolean;
var ReturnCode: Longint;
    OpenAction: Longint;
    Temp       : Array[0..15] of Char;
begin
  InitFailed := NOT Com_StartThread;

  if NOT InitFailed then
    begin
      OpenAction := file_Open;
      StrpCopy(Temp, 'COM' + IntToStr(ComPort));

      ReturnCode :=
        DosOpen(Temp,                                    { Filename, eg: COM2 }
                ClientHandle,
                OpenAction,
                0,                                                 { Filesize }
                0,                                               { Attributes }
                FILE_OPEN or OPEN_ACTION_OPEN_IF_EXISTS,         { Open flags }
                OPEN_ACCESS_READWRITE or OPEN_SHARE_DENYNONE or    { OpenMode }
                OPEN_FLAGS_FAIL_ON_ERROR,
                nil);                                   { Extended attributes }

      InitFailed := (ReturnCode <> 0);
    end; { if }

  Com_OpenKeep := NOT InitFailed;
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                            Parity: Char; StopBits: Byte): Boolean;
begin
  InitFailed := true;

  if Com_OpenKeep(Comport) then
    begin
      Com_SetLine(BaudRate, Parity, DataBits, StopBits);

      InitFailed := false;
    end; { if }

  Com_Open := NOT InitFailed;
end; { func. TOs2Obj.Com_OpenCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
type TBpsRec = Record
         Rate  : Longint;
         Frac  : Byte;
      end; { record }

var TempRec      : Array[1..3] of Byte;
    BpsRec       : TBpsRec;
    RetLength    : Longint;
    Temp_Parity  : Byte;
    Temp_StopBits: Byte;
begin
  if NOT (DataBits in [5,7,8]) then DataBits := 8;
  if NOT (Parity in ['O', 'E', 'N', 'M', 'S']) then Parity := 'N';
  if NOT (StopBits in [0..2]) then StopBits := 1;

  Temp_Parity := 00;
  Case Parity of
    'N' : Temp_Parity := 00;
    'O' : Temp_Parity := 01;
    'E' : Temp_Parity := 02;
    'M' : Temp_Parity := 03;
    'S' : Temp_Parity := 04;
  end; { case }

  Temp_Stopbits := 00;
  Case StopBits of
     1  : StopBits := 0;
     2  : StopBits := 2;
  end; { case }

  Fillchar(TempRec, SizeOf(TempRec), 00);
  TempRec[01] := DataBits;
  TempRec[02] := Temp_Parity;
  TempRec[03] := Temp_StopBits;

  {------------------------- Set line parameters ----------------------------}
  DosDevIoCtl(ClientHandle,                                    { File-handle }
              ioctl_Async,                                        { Category }
              async_SetLineCtrl,                                  { Function }
              @TempRec,                                             { Params }
              SizeOf(TempRec),                            { Max param length }
              @RetLength,                                     { Param Length }
              @TempRec,                                      { Returned data }
              SizeOf(TempRec),                             { Max data length }
              @RetLength);                                     { Data length }

  {------------------------- Set speed parameters ---------------------------}
  BpsRec.Rate := BpsRate;
  BpsRec.Frac := 00;
  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_ExtSetBaudRate,                                { Function }
              @BpsRec,                                               { Params }
              SizeOf(BpsRec),                              { Max param length }
              @RetLength,                                      { Param Length }
              @BpsRec,                                        { Returned data }
              SizeOf(BpsRec),                               { Max data length }
              @RetLength);                                      { Data length }
end; { proc. TOs2Obj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_Close;
begin
  if DontClose then EXIT;

  if ClientHandle <> -1 then
    begin
      Com_StopThread;
      DosClose(ClientHandle);

      ClientHandle := -1;
    end; { if }

end; { func. TOs2Obj.Com_CloseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_SendChar(C: Char): Boolean;
var Written: Longint;
begin
  Com_SendBlock(C, SizeOf(C), Written);
  Com_SendChar := (Written = SizeOf(c));
end; { proc. TOs2Obj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_GetChar: Char;
var Reads: Longint;
begin
  Com_ReadBlock(Result, SizeOf(Result), Reads);
end; { func. TOs2Obj.Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
begin
  if OutBuffer^.BufRoom < BlockLen then
   repeat
     {$IFDEF OS2}
       DosSleep(1);
     {$ENDIF}
   until (OutBuffer^.BufRoom >= BlockLen) OR (NOT Com_Carrier);

  CriticalTx.EnterExclusive;
    Written := OutBuffer^.Put(Block, BlockLen);
  CriticalTx.LeaveExclusive;

  DoTxEvent.SignalEvent;
end; { proc. TOs2Obj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
  if InBuffer^.BufUsed < BlockLen then
    begin
      repeat
        if Com_CharAvail then
          DoRxEvent.SignalEvent;

        DosSleep(1);
      until (InBuffer^.BufUsed >= BlockLen) OR (NOT Com_Carrier);
    end; { if }

  CriticalRx.EnterExclusive;
    Reads := InBuffer^.Get(Block, BlockLen, true);
  CriticalRx.LeaveExclusive;
end; { proc. TOs2Obj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_CharAvail: Boolean;

Type TBuffRec = Record
         BytesIn   : SmallWord;               { Number of bytes in the buffer }
         MaxSize   : SmallWord;                     { Full size of the buffer }
     end; { TBuffRec }

var ReturnCode: Longint;
    BufferRec : TBuffRec;
begin
  if InBuffer^.BufUsed < 1 then
    begin
      ReturnCode := 0;
      DosDevIoCtl(ClientHandle,                             { File-handle }
                  ioctl_Async,                                 { Category }
                  async_GetInQueCount,                         { Function }
                  nil,                                           { Params }
                  ReturnCode,                          { Max param length }
                  @ReturnCode,                             { Param Length }
                  @BufferRec,                             { Returned data }
                  SizeOf(TBuffRec),                     { Max data length }
                  @ReturnCode);                             { Data length }

      if (BufferRec.BytesIn > 0) then
        DoRxEvent.SignalEvent;
    end; { if }

  Result := (InBuffer^.BufUsed > 0);
end; { func. TOs2Obj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_Carrier: Boolean;
var Status    : Byte;
    RetLength : Longint;
begin
  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_GetModemInput,                                 { Function }
              nil,                                                   { Params }
              00,                                          { Max param length }
              @RetLength,                                      { Param Length }
              @Status,                                        { Returned data }
              SizeOf(Status),                               { Max data length }
              @RetLength);                                      { Data length }

  Com_Carrier := Status AND 128 <> 00;
end; { func. TOs2Obj.Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
  LineStatus := 00;
  ModemStatus := 08;

  if Com_Carrier then ModemStatus := ModemStatus OR (1 SHL 7);
end; { proc. TOs2Obj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_SetDtr(State: Boolean);
type
   TRtsDtrRec = record
      Onmask,
      Offmask : Byte;
   end; { record }

var MaskRec   : TRtsDtrRec;
    RetLength : Longint;
begin
  if State then
    begin
      MaskRec.OnMask   := $01;
      MaskRec.OffMask  := $FF;
    end
      else begin
             MaskRec.OnMask   := $00;
             MaskRec.OffMask  := $FE;
           end; { if }

  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_SetModemCtrl,                                  { Function }
              @MaskRec,                                              { Params }
              SizeOf(MaskRec),                             { Max param length }
              @RetLength,                                      { Param Length }
              @MaskRec,                                       { Returned data }
              SizeOf(MaskRec),                              { Max data length }
              @RetLength);                                      { Data length }
end; { proc. TOs2Obj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TOs2Obj.Com_GetBpsRate: Longint;
type
   TBpsRec = record
      CurBaud  : Longint;                                  { Current BaudRate }
      CurFrac  : Byte;                                     { Current Fraction }
      MinBaud  : Longint;                                  { Minimum BaudRate }
      MinFrac  : Byte;                                     { Minimum Fraction }
      MaxBaud  : Longint;                                  { Maximum BaudRate }
      MaxFrac  : Byte;                                     { Maximum Fraction }
   end; { TBpsRec }

var BpsRec   : TBpsRec;
    Status   : Byte;
    RetLength: Longint;
begin
  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_ExtGetBaudRate,                                { Function }
              nil,                                                   { Params }
              00,                                          { Max param length }
              @RetLength,                                      { Param Length }
              @BpsRec,                                        { Returned data }
              SizeOf(BpsRec),                               { Max data length }
              @RetLength);                                      { Data length }

  Com_GetBpsRate := BpsRec.CurBaud;
end; { func. TOs2Obj.Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
  DoRxEvent.SignalEvent;
  DoTxEvent.SignalEvent;

  InFree := InBuffer^.BufRoom;
  OutFree := OutBuffer^.BufRoom;
  InUsed := InBuffer^.BufUsed;
  OutUsed := OutBuffer^.BufUsed;
end; { proc. TOs2Obj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_PurgeInBuffer;
begin
  CriticalRx.EnterExclusive;

  InBuffer^.Clear;

  CriticalRx.LeaveExclusive;
end; { proc. TOs2Obj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_PurgeOutBuffer;
begin
  CriticalTx.EnterExclusive;

  OutBuffer^.Clear;

  CriticalTx.LeaveExclusive;
end; { proc. TOs2Obj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_FlushOutBuffer(Slice: SliceProc);
begin
  DosResetBuffer(ClientHandle);

  inherited Com_FlushOutBuffer(Slice);
end; { proc. Com_FlushOutBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


function TOs2Obj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Result := OutBuffer^.BufRoom >= BlockLen;
end; { func. ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_PauseCom(CloseCom: Boolean);
begin
  if CloseCom then Com_Close
    else Com_StopThread;
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_ResumeCom(OpenCom: Boolean);
begin
  if OpenCom then Com_OpenKeep(0)
    else Com_StartThread;
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_SetFlow(SoftTX, SoftRX, Hard: Boolean);
var Dcb      : DCBINFO;
    RetLength: Longint;
begin
  FillChar(Dcb, SizeOF(Dcb), 0);

  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_GetDcbInfo,                                    { Function }
              nil,                                                   { Params }
              00,                                          { Max param length }
              @RetLength,                                      { Param Length }
              @Dcb,                                           { Returned data }
              SizeOf(DcbInfo),                              { Max data length }
              @RetLength);                                      { Data length }

  if (SoftTX) or (SoftRX) then
    begin
      dcb.fbFlowReplace := dcb.fbFlowReplace + MODE_AUTO_RECEIVE + MODE_AUTO_TRANSMIT;
    end
      else begin
             dcb.fbFlowReplace := MODE_RTS_HANDSHAKE;
             dcb.fbCtlHndShake := dcb.fbCtlHndShake + MODE_CTS_HANDSHAKE;
           end; { if }

  dcb.fbTimeout := MODE_NO_WRITE_TIMEOUT + MODE_WAIT_READ_TIMEOUT;
  dcb.bXONChar := $11;
  dcb.bXOFFChar := $13;

  RetLength := SizeOf(DcbInfo);
  DosDevIoCtl(ClientHandle,                                     { File-handle }
              ioctl_Async,                                         { Category }
              async_SetDcbInfo,                                    { Function }
              @Dcb,                                                  { Params }
              SizeOf(DcbInfo),                             { Max param length }
              @RetLength,                                      { Param Length }
              nil,                                            { Returned data }
              RetLength,                                    { Max data length }
              @RetLength);                                      { Data length }

end; { proc. Com_SetFlow }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TOs2Obj.Com_SetDataProc(ReadPtr, WritePtr: Pointer);
begin
  ReadProcPtr := ReadPtr;
  WriteProcPtr := WritePtr;
end; { proc. Com_SetDataProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
