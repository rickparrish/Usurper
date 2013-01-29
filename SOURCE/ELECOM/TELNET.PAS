unit TELNET;
{$h-}
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
** Last update : 04-Apr-1999
**
** Note: (c) 1998-1999 by Maarten Bekers
**
** Note: Same story of what we said in Win32, only we have here 2 seperate
**       threads. The Write-thread has no problems, the read-thread is run
**       max every 5 seconds, or whenever a carrier-check is performed. This
**       carrier check is run on most BBS programs each second. You can
**       optimize this by making the ReadThread a blocking select() call on
**       the fd_read socket, but this can have other issues. A better approach
**       on Win32 would be to call the WsaAsyncSelect() call, but this is
**       non portable.
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses SockFunc, SockDef, Combase, BufUnit, Threads

     {$IFDEF WIN32}
       ,Windows
     {$ENDIF}

     {$IFDEF OS2}
       ,Os2Base
     {$ENDIF}

     {$IFDEF VirtualPascal}
       ,Use32
     {$ENDIF};

Const WriteTimeout   = 5000;                              { Wait max. 5 secs }
      ReadTimeOut    = 5000;                     { General event, 5 secs max }

      InBufSize      = 1024 * 32;
      OutBufSize     = 1024 * 32;


type TTelnetObj = Object(TCommObj)
        ReadProcPtr: Pointer;             { Pointer to TX/RX handler (thread) }
        WriteProcPtr: Pointer;            { Pointer to TX/RX handler (thread) }
        ThreadsInitted : Boolean;
        NeedNewCarrier : Boolean;
        TelnetCarrier  : Boolean;

        IacDontDo     : Longint;           { ugly hack to prevent missed IACs }
        IacState      : Longint;                                { 0 = nothing }
                                                           { 1 = received IAC }
                                                        { 2 = handing the IAC }
        ClientRC      : Longint;

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

        procedure Com_PauseCom(CloseCom: Boolean); virtual;
        procedure Com_ResumeCom(OpenCom: Boolean); virtual;

        procedure Com_ReadProc(var TempPtr: Pointer);
        procedure Com_WriteProc(var TempPtr: Pointer);

        procedure Com_SetDataProc(ReadPtr, WritePtr: Pointer); virtual;

        function  Com_StartThread: Boolean;
        procedure Com_InitVars;
        procedure Com_StopThread;

        function  Com_SendWill(Option: Char): String;
        function  Com_SendWont(Option: Char): String;
        function  Com_SendDo(Option: Char): String;
        procedure Com_SendRawStr(TempStr: String);
        procedure Com_PrepareBufferRead(var CurBuffer: CharBufType; var TempOut: BufArrayObj; BlockLen: Longint);
        procedure Com_PrepareBufferWrite(var CurBuffer, TmpOutBuffer: CharBufType; var BlockLen: Longint);
     end; { object TTelnetObj }

Type PTelnetObj = ^TTelnetObj;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses SysUtils;

{$IFDEF FPC}
  {$I WINDEF.FPC}
{$ENDIF}

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


Const
  { Telnet Options }
  TELNET_IAC   = #255;                                 { Interpret as Command }
  TELNET_DONT  = #254;     { Stop performing, or not expecting him to perform }
  TELNET_DO    = #253;                    { Perform, or expect him to perform }
  TELNET_WONT  = #252;                                   { Refusal to perform }
  TELNET_WILL  = #251;                                    { Desire to perform }

  TELNET_SB    = #250;   { What follow is sub-negotiation of indicated option }
  TELNET_GA    = #249;                                      { Go ahead signal }
  TELNET_EL    = #248;                                  { Erase Line function }
  TELNET_EC    = #247;                             { Erase Character function }
  TELNET_AYT   = #246;                               { Are You There function }
  TELNET_AO    = #245;                                { Abort Output function }
  TELNET_IP    = #244;                           { Interrupt Process function }
  TELNET_BRK   = #243;                                  { NVT break character }
  TELNET_DM    = #242;                       { Data stream portion of a Synch }
  TELNET_NOP   = #241;                                         { No operation }
  TELNET_SE    = #240;                    { End of sub-negotiation parameters }
  TELNET_EOR   = #239;                                        { End of record }
  TELNET_ABORT = #238;                                        { Abort process }
  TELNET_SUSP  = #237;                              { Suspend current process }
  TELNET_EOF   = #236;                                          { End of file }

  TELNETOPT_BINARY = #0;                                    { Transmit binary }
  TELNETOPT_ECHO   = #1;                                          { Echo mode }
  TELNETOPT_SUPGA  = #3;                                  { Suppress Go-Ahead }
  TELNETOPT_TERM   = #24;                                     { Terminal Type }
  TELNETOPT_SPEED  = #32;                                    { Terminal Speed }
  TELNETOPT_FLOWCNT= #33;                               { Toggle flow-control }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TTelnetObj.Init;
begin
  inherited Init;

  ThreadsInitted := false;
  NeedNewCarrier := true;
  TelnetCarrier := TRUE;
  IacState := 0;                                           { default to none }
  Com_InitVars;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TTelnetObj.Done;
begin
  inherited done;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_SendRawStr(TempStr: String);
var BytesSnt: Longint;
    TmpByte : Longint;
    BufFlag : Longint;
    TmpError: Longint;
begin
  BufFlag := 00;
  TmpByte := 01;

  REPEAT
    BytesSnt := SockSend(ClientRC,
                         @TempStr[TmpByte],
                         Length(TempStr),
                         BufFlag);

   if BytesSnt > 0 then
     Inc(TmpByte, BytesSnt)
       else begin
              TmpError := SockErrorNo;
              if TmpError <> WSAEWOULDBLOCK then EXIT;
            end; { else }

  UNTIL (TmpByte > Length(TempStr));
end; { proc. Com_SendRawStr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_SendWill(Option: Char): String;
begin
  Result[1] := TELNET_IAC;
  Result[2] := TELNET_WILL;
  Result[3] := Option;
  SetLength(Result, 3);
end; { func. Com_SendWill }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_SendWont(Option: Char): String;
begin
  Result[1] := TELNET_IAC;
  Result[2] := TELNET_WONT;
  Result[3] := Option;
  SetLength(Result, 3);
end; { func. Com_SendWont }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_SendDo(Option: Char): String;
begin
  Result[1] := TELNET_IAC;
  Result[2] := TELNET_DO;
  Result[3] := Option;
  SetLength(Result, 3);
end; { func. Com_SendDo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_PrepareBufferRead(var CurBuffer: CharBufType; var TempOut: BufArrayObj; BlockLen: Longint);
var Counter   : Longint;
begin
  Counter := 00;
  if BlockLen = 0 then EXIT;

  While Counter <= (Blocklen - 01) do
    begin
      {-- and now handle the IAC state ---------------------------------------}
      Case IacState of
        1 : begin                                                 { DO / DONT }
              {-- we received an IAC, and this is the next char --------------}
              if CurBuffer[Counter] = TELNET_IAC then
                begin
                  TempOut.Put(CurBuffer[Counter], 1);
                  IacState := 0;                         { reset parser state }
                end
                  else begin
                         IacState := 2;

                         Case CurBuffer[Counter] of
                           TELNET_DONT,
                           TELNET_DO     : IacDontDo := 1;
                             else IacDontDo := 0;
                         end; { case }
                       end; { else }
            end; { DO/DONT }
        2 : begin                                                      { WHAT }
{              if IacDontDo = 1 then }
                begin
                  Case CurBuffer[Counter] of
                    TELNETOPT_BINARY,
                    TELNETOPT_SUPGA,
                    TELNETOPT_ECHO   : begin
                                        Com_SendRawStr(Com_SendWill(CurBuffer[Counter]));
                                       end
                        else begin
                              Com_SendRawStr(Com_SendWont(CurBuffer[Counter]));
                            end; { if }
                  end; { case }
                end; { if this is a state we will reply to }

              IacState := 0;                     { reset IAC state machine }
            end; { WHAT }
          else begin
                 if CurBuffer[Counter] = TELNET_IAC then
                   begin
                     IacState := 1
                   end
                    else TempOut.Put(CurBuffer[Counter], 1);
               end; { else }
      end; { case }

      {-- and loop through the buffer ----------------------------------------}
      Inc(Counter);
    end; { while }

end; { proc. Com_PrepareBufferRead }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_PrepareBufferWrite(var CurBuffer, TmpOutBuffer: CharBufType; var BlockLen: Longint);
var Counter   : Longint;
    NewCounter: Longint;
begin
  Counter := 00;
  NewCounter := 00;
  if BlockLen = 0 then EXIT;

  While Counter <= Blocklen do
    begin
      Case CurBuffer[Counter] of
        TELNET_IAC : begin                        { Escape command character }
                       TmpOutBuffer[NewCounter] := TELNET_IAC;
                       Inc(NewCounter);
                       TmpOutBuffer[NewCounter] := TELNET_IAC;
                       Inc(NewCounter);
                     end; { if }
          else begin
                 TmpOutBuffer[NewCounter] := CurBuffer[Counter];
                 Inc(NewCounter);
               end; { if }
      end; { case }

      Inc(Counter);
    end; { while }

  BlockLen := NewCounter - 1;
end; { proc. Com_PrepareBufferWrite }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_ReadProc(var TempPtr: Pointer);
var Available : Boolean;
    BytesRead : Longint;
    BlockLen  : Longint;
    ReturnCode: Longint;
begin
  repeat
     if DoRxEvent^.WaitForEvent(ReadTimeOut) then
      if NOT EndThreads then
       begin
         CriticalRx^.EnterExclusive;
         Available := (SockSelect(ClientRC) > 00);

         DoRxEvent^.ResetEvent;

         if (Available) OR (NeedNewCarrier) then
          begin
            {----------- Start reading the gathered date -------------------}
            NeedNewCarrier := false;

            if InBuffer^.BufRoom > 0 then
              begin
                BlockLen := InBuffer^.BufRoom;
                if BlockLen > 1024 then
                  BlockLen := 1024;

                if BlockLen > 00 then
                 begin
                   BytesRead := SockRecv(ClientRC,
                                         @InBuffer^.TmpBuf,
                                         BlockLen,
                                         0);

                   if BytesRead = 0 then
                     begin
                       TelnetCarrier := false;

                       ReturnCode := SockErrorNo;

                       ErrorStr := 'Error in communications(1), #'+IntToStr(Returncode)+ ' / '+SysErrorMessage(Returncode);
                     end; { if }

                   if BytesRead = -1 then
                    begin
                       ReturnCode := SockErrorNo;

                       if ReturnCode <> WSAEWOULDBLOCK then
                         begin
                           TelnetCarrier := false;

                           ErrorStr := 'Error in communications(2), #'+IntToStr(ReturnCode)+ ' / '+SysErrorMessage(ReturnCode);
                           EndThreads := true;
                         end; { if }
                    end; { error }

                  if BytesRead > 00 then
                    begin
                      Com_PrepareBufferRead(InBuffer^.TmpBuf, InBuffer^, BytesRead);
                    end; { if }
                 end; { if }
              end; { if }
          end; { if available }

         CriticalRx^.LeaveExclusive;
       end; { if RxEvent }
  until EndThreads;

  RxClosedEvent^.SignalEvent;
  ExitThisThread;
end; { proc. Com_ReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_WriteProc(var TempPtr: Pointer);
var BlockLen    : Longint;
    Written     : Longint;
    ReturnCode  : Longint;
    TempBuf     : ^CharBufType;
begin
  New(TempBuf);

  repeat
     if DoTxEvent^.WaitForEvent(WriteTimeOut) then
      if NOT EndThreads then
       begin
         CriticalTx^.EnterExclusive;
         DoTxEvent^.ResetEvent;

         if OutBuffer^.BufUsed > 00 then
           begin
             BlockLen := OutBuffer^.Get(OutBuffer^.TmpBuf, OutBuffer^.BufUsed, false);

             Com_PrepareBufferWrite(OutBuffer^.TmpBuf, TempBuf^, BlockLen);
             Written := SockSend(ClientRC,
                                 TempBuf,
                                 BlockLen,
                                 0);
             {-- remove the data from the buffer, but only remove the data ---}
             {-- thats actually written --------------------------------------}
             ReturnCode := OutBuffer^.Get(OutBuffer^.TmpBuf, Written, true);

             if ReturnCode <> Longint(Written) then
               begin
                 { not everything is removed! }
               end; { if }

             {-- if theres data in the buffer left, run this event again -----}
             if Written <> BlockLen then
               begin
                  DoTxEvent^.SignalEvent;
               end; { if }
           end; { if }

         CriticalTx^.LeaveExclusive;
       end; { if }

  until EndThreads;

  Dispose(TempBuf);

  TxClosedEvent^.SignalEvent;
  ExitThisThread;
end; { proc. Com_WriteProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_StartThread: Boolean;
begin
  Result := false;
  EndThreads := false;
  if ThreadsInitted then EXIT;
  ThreadsInitted := true;

  {----------------------- Create all the events ----------------------------}
  New(DoTxEvent, Init);
  if NOT DoTxEvent^.CreateEvent(false) then EXIT;

  New(DoRxEvent, Init);
  if NOT DoRxEvent^.CreateEvent(false) then EXIT;

  New(RxClosedEvent, Init);
  if NOT RxClosedEvent^.CreateEvent(false) then EXIT;

  New(TxClosedEvent, Init);
  if NOT TxClosedEvent^.CreateEvent(false) then EXIT;

  {-------------- Startup the buffers and overlapped events -----------------}
  New(InBuffer, Init(InBufSize));
  New(OutBuffer, Init(OutBufSize));

  {-------------------- Startup a seperate write thread ---------------------}
  New(CriticalTx, Init);
  CriticalTx^.CreateExclusive;

  New(TxThread, Init);
  if NOT TxThread^.CreateThread(16384,                            { Stack size }
                                WriteProcPtr,               { Actual procedure }
                                nil,                              { Parameters }
                                0)                            { Creation flags }
                                 then EXIT;

  {-------------------- Startup a seperate read thread ----------------------}
  New(CriticalRx, Init);
  CriticalRx^.CreateExclusive;

  New(RxThread, Init);
  if NOT RxThread^.CreateThread(16384,                            { Stack size }
                                ReadProcPtr,                { Actual procedure }
                                nil,                              { Parameters }
                                0)                            { Creation flags }
                                 then EXIT;

  Result := true;
end; { proc. Com_StartThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_InitVars;
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

procedure TTelnetObj.Com_StopThread;
begin
  EndThreads := true;
  ThreadsInitted := false;

  if DoTxEvent <> nil then DoTxEvent^.SignalEvent;
  if DoTxEvent <> nil then DoRxEvent^.SignalEvent;

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

function TTelnetObj.Com_GetHandle: Longint;
begin
  Result := ClientRC;
end; { func. Com_GetHandle }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_OpenQuick(Handle: Longint);
var ReturnCode: Longint;
begin
  ClientRC := Handle;

  if (NOT (SockInit=0)) then
    begin
      ReturnCode := SockErrorNo;

      ErrorStr := 'Error in initializing socket, #'+IntToStr(Returncode)+ ' / '+SysErrorMessage(Returncode);
      InitFailed := true;
    end
      else InitFailed := NOT Com_StartThread;

  { Set the telnet to binary transmission }
  Com_SendRawStr(Com_SendWill(TELNETOPT_ECHO));
  Com_SendRawStr(Com_SendWill(TELNETOPT_BINARY));
end; { proc. TTelnetObj.Com_OpenQuick }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_OpenKeep(Comport: Byte): Boolean;
begin
  InitFailed := NOT Com_StartThread;
  Com_OpenKeep := InitFailed;
end; { func. Com_OpenKeep }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                            Parity: Char; StopBits: Byte): Boolean;
begin
  Com_Open := true;
end; { func. TTelnetObj.Com_OpenCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte);
begin
  // Duhhh ;)
end; { proc. TTelnetObj.Com_SetLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_Close;
begin
  if DontClose then EXIT;

  if ClientRC <> -1 then
    begin
      Com_StopThread;
      SockShutdown(ClientRC, 02);
      SockClose(ClientRC);

      ClientRC := -1;
    end; { if }

end; { func. TTelnetObj.Com_CloseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_SendChar(C: Char): Boolean;
var Written: Longint;
begin
  Com_SendBlock(C, SizeOf(C), Written);
  Com_SendChar := (Written = SizeOf(c));
end; { proc. TTelnetObj.Com_SendChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_GetChar: Char;
var Reads: Longint;
begin
  Com_ReadBlock(Result, SizeOf(Result), Reads);
end; { func. TTelnetObj.Com_GetChar }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint);
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
end; { proc. TTelnetObj.Com_SendBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint);
begin
  if InBuffer^.BufUsed < BlockLen then
    begin
      DoRxEvent^.SignalEvent;

      repeat
        {$IFDEF OS2}
          DosSleep(1);
        {$ENDIF}

        {$IFDEF WIN32}
          Sleep(1);
        {$ENDIF}

        if Com_CharAvail then
          DoRxEvent^.SignalEvent;
      until (InBuffer^.BufUsed >= BlockLen) OR (NOT Com_Carrier);
    end; { if }

  Reads := InBuffer^.Get(Block, BlockLen, true);
end; { proc. TTelnetObj.Com_ReadBlock }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_CharAvail: Boolean;
begin
  if InBuffer^.BufUsed < 1 then
    begin
      if (SockSelect(ClientRC) > 0) then
        DoRxEvent^.SignalEvent;
    end; { if }

  Result := (InBuffer^.BufUsed > 0);
end; { func. TTelnetObj.Com_CharAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_Carrier: Boolean;
begin
  if TelnetCarrier then             { Carrier is only lost in 'read' sections }
    begin
      DoRxEvent^.SignalEvent;
      NeedNewCarrier := true;
    end; { if }

  Result := TelnetCarrier;
end; { func. TTelnetObj.Com_Carrier }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_GetModemStatus(var LineStatus, ModemStatus: Byte);
begin
  LineStatus := 00;
  ModemStatus := 08;

  if Com_Carrier then ModemStatus := ModemStatus OR (1 SHL 7);
end; { proc. TTelnetObj.Com_GetModemStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_SetDtr(State: Boolean);
begin
  if NOT State then
    begin
      Com_Close;
    end; { if }
end; { proc. TTelnetObj.Com_SetDtr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_GetBpsRate: Longint;
begin
  Com_GetBpsRate := 115200;
end; { func. TTelnetObj.Com_GetBpsRate }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint);
begin
  DoRxEvent^.SignalEvent;
  DoTxEvent^.SignalEvent;

  InFree := InBuffer^.BufRoom;
  OutFree := OutBuffer^.BufRoom;
  InUsed := InBuffer^.BufUsed;
  OutUsed := OutBuffer^.BufUsed;
end; { proc. TTelnetObj.Com_GetBufferStatus }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_PurgeInBuffer;
begin
  CriticalRx^.EnterExclusive;

  InBuffer^.Clear;

  CriticalRx^.LeaveExclusive;
end; { proc. TTelnetObj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_PurgeOutBuffer;
begin
  CriticalTx^.EnterExclusive;

  OutBuffer^.Clear;

  CriticalTx^.LeaveExclusive;
end; { proc. TTelnetObj.Com_PurgeInBuffer }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TTelnetObj.Com_ReadyToSend(BlockLen: Longint): Boolean;
begin
  Result := OutBuffer^.BufRoom >= BlockLen;
end; { func. ReadyToSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_PauseCom(CloseCom: Boolean);
begin
  if CloseCom then Com_Close
    else Com_StopThread;
end; { proc. Com_PauseCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_ResumeCom(OpenCom: Boolean);
begin
  if OpenCom then Com_OpenKeep(0)
    else Com_StartThread;
end; { proc. Com_ResumeCom }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TTelnetObj.Com_SetDataProc(ReadPtr, WritePtr: Pointer);
begin
  ReadProcPtr := ReadPtr;
  WriteProcPtr := WritePtr;
end; { proc. Com_SetDataProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
