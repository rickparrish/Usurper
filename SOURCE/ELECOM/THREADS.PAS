unit THREADS;
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.1,    (OS/2, Win32)
**              FreePascal    v0.99.12 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.01
** Created : 07-Mar-1999
** Last update : 26-Sep-1999
**
** Note: (c) 1998-1999 by Maarten Bekers
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

{$IFDEF OS2}
 uses Os2Base;
{$ENDIF}

{$IFDEF WIN32}
 uses Windows;
{$ENDIF}

{$IFDEF OS2}
  Type THandle = Longint;
       DWORD   = Longint;
{$ENDIF}

{$IFDEF WIN32}
 {$IFDEF FPC}
   Type THandle = Handle;
 {$ENDIF}
{$ENDIF}

type TSysEventObj = Object
       {$IFDEF OS2}
         SemHandle: HEV;
       {$ENDIF}

       {$IFDEF WIN32}
         SemHandle: THandle;
       {$ENDIF}

       constructor init;
       destructor done;

       procedure DisposeEvent;
       procedure SignalEvent;
       procedure ResetEvent;
       function  CreateEvent(InitialState: Boolean): Boolean;
       function  WaitForEvent(TimeOut: Longint): Boolean;
     end; { TSysEventObj }

Type PSysEventObj = ^TSysEventObj;

type TExclusiveObj = Object
       {$IFDEF OS2}
         Exclusive: PHMtx;
       {$ENDIF}

       {$IFDEF WIN32}
         Exclusive: PRTLCriticalSection;
       {$ENDIF}

       constructor Init;
       destructor Done;

       procedure CreateExclusive;
       procedure DisposeExclusive;

       procedure EnterExclusive;
       procedure LeaveExclusive;
     end; { TExclusiveObj }

Type PExclusiveObj = ^TExclusiveObj;


type TThreadsObj = Object
       ThreadHandle : THandle;
       ThreadID     : DWORD;
       ThreadClosed : Boolean;

       constructor Init;
       destructor Done;

       function CreateThread(StackSize    : Longint;
                             CallProc,
                             Parameters   : Pointer;
                             CreationFlags: Longint): Boolean;
       procedure CloseThread;
       procedure TerminateThread(ExitCode: Longint);
     end; { TThreadsObj }

Type PThreadsObj = ^TThreadsObj;

procedure ExitThisThread;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TSysEventObj.Init;
begin
  SemHandle := 0;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TSysEventObj.Done;
begin
  if Longint(SemHandle) <> -1 then
    begin
      SignalEvent;
      DisposeEvent;
    end; { if }
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TSysEventObj.CreateEvent(InitialState: Boolean): Boolean;
{$IFDEF OS2}
var Returncode: longint;
{$ENDIF}
begin
  CreateEvent := true;

  {$IFDEF WIN32}
    SemHandle := Windows.CreateEvent(nil, true, InitialState, nil);
    if Longint(SemHandle) = -1 then CreateEvent := false;
  {$ENDIF}

  {$IFDEF OS2}
    returncode := DosCreateEventSem(nil, SemHandle, 0, InitialState);
    CreateEvent := (returncode=0);
  {$ENDIF}
end; { func. CreateEvent }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TSysEventObj.SignalEvent;
{$IFDEF OS2}
var RC: Longint;
{$ENDIF}
begin
  {$IFDEF WIN32}
    if Longint(SemHandle) <> -1 then
      SetEvent(SemHandle);
  {$ENDIF}

  {$IFDEF OS2}
    if SemHandle <> -1 then
      RC := DosPostEventSem(SemHandle);
  {$ENDIF}
end; { proc. SignalEvent }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TSysEventObj.ResetEvent;
{$IFDEF OS2}
var Flag: Longint;
    RC  : Longint;
{$ENDIF}
begin
  {$IFDEF WIN32}
    if SemHandle <> THandle(-1) then
      Windows.ResetEvent(SemHandle);
  {$ENDIF}

  {$IFDEF OS2}
    Flag := 0;
    if SemHandle <> -1 then
      RC := DosResetEventSem(SemHandle, Flag);
  {$ENDIF}
end; { proc. ResetEvent }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TSysEventObj.WaitForEvent(TimeOut: Longint): Boolean;
var ReturnCode: Longint;
{$IFDEF OS2}
    Flag      : Longint;
{$ENDIF}
begin
  {$IFDEF WIN32}
    if SemHandle <> THandle(-1) then
      ReturnCode := WaitForSingleObject(SemHandle, Timeout)
       else ReturnCode := 0;

    WaitForEvent := (ReturnCode = WAIT_OBJECT_0);
  {$ENDIF}

  {$IFDEF OS2}
    if SemHandle <> -1 then
      ReturnCode := DosWaitEventSem(SemHandle, TimeOut);

    Flag := 0;
    DosResetEventSem(SemHandle, Flag);
    WaitForEvent := (ReturnCode = 0);
{$ENDIF}
end; { func. WaitForEvent }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TSysEventObj.DisposeEvent;
{$IFDEF OS2}
var Flag: Longint;
{$ENDIF}
begin
  {$IFDEF WIN32}
    if SemHandle <> THandle(-1) then CloseHandle(SemHandle);
    SemHandle := 0;
  {$ENDIF}

  {$IFDEF OS2}
    Flag := 0;
    if SemHandle <> -1 then DosCloseEventSem(SemHandle);
    SemHandle := -1;
  {$ENDIF}
end; { proc. DisposeEvent }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TExclusiveObj.Init;
begin
  Exclusive := nil;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TExclusiveObj.Done;
begin
  if Exclusive <> nil then
    DisposeExclusive;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TExclusiveObj.CreateExclusive;
begin
  {$IFDEF WIN32}
    New(Exclusive);
    InitializeCriticalSection(Exclusive^);
  {$ENDIF}

  {$IFDEF OS2}
    New(Exclusive);
    DosCreateMutexSem(nil, Exclusive^, dcmw_Wait_All, false);
  {$ENDIF}
end; { proc. CreateExclusive }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TExclusiveObj.DisposeExclusive;
begin
  {$IFDEF WIN32}
    if Exclusive <> nil then
      begin
        DeleteCriticalSection(Exclusive^);
        Dispose(Exclusive);
      end; { if }

    Exclusive := nil;
  {$ENDIF}

  {$IFDEF OS2}
    if Exclusive <> nil then
      begin
        DosCloseMutexSem(Exclusive^);
        Dispose(Exclusive);
      end; { if }

    Exclusive := nil;
  {$ENDIF}
end; { proc. DisposeExclusive }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TExclusiveObj.EnterExclusive;
begin
  {$IFDEF WIN32}
     EnterCriticalSection(Exclusive^);
  {$ENDIF}

  {$IFDEF OS2}
    DosRequestMutexSem(Exclusive^, sem_Indefinite_Wait);
  {$ENDIF}
end; { proc. EnterExclusive }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TExclusiveObj.LeaveExclusive;
begin
  {$IFDEF WIN32}
    LeaveCriticalSection(Exclusive^);
  {$ENDIF}

  {$IFDEF OS2}
    DosReleaseMutexSem(Exclusive^);
  {$ENDIF}
end; { proc. LeaveExclusive }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

constructor TThreadsObj.Init;
begin
  ThreadHandle := 0;
  ThreadId := 0;
end; { constructor Init }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

destructor TThreadsObj.Done;
begin
  CloseThread;
  ThreadHandle := 0;
end; { destructor Done }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function TThreadsObj.CreateThread(StackSize    : Longint;
                                  CallProc,
                                  Parameters   : Pointer;
                                  CreationFlags: Longint): Boolean;
var ReturnCode: Longint;
begin
  ThreadClosed := FALSE;

 {$IFNDEF VirtualPascal}
  {$IFDEF WIN32}
    ThreadHandle := Windows.CreateThread(nil,               { Security attrs }
                                 StackSize,                     { Stack size }
                                 CallProc,                { Actual procedure }
                                 Parameters,                    { Parameters }
                                 CreationFlags,             { Creation flags }
                                 ThreadID);                   { Thread ID ?? }

     CreateThread := (ThreadHandle <> THandle(-1));
  {$ENDIF}

  {$IFDEF OS2}
    ReturnCode :=
      DosCreateThread(ThreadHandle,                           { ThreadHandle }
                      CallProc,                           { Actual procedure }
                      Longint(Parameters),                      { Parameters }
                      CreationFlags,                        { Creation flags }
                      StackSize);                                { Stacksize }

     CreateThread := (ReturnCode = 0);
     if ReturnCode <> 0 then ThreadHandle := -1;
  {$ENDIF}

  {$IFDEF LINUX}

  {$ENDIF}


 {$ELSE}
   ThreadHandle := BeginThread(nil, StackSize, CallProc, Parameters, 0, ReturnCode);
   CreateThread := (ThreadHandle > THandle(-1));
 {$ENDIF}
end; { proc. CreateThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TThreadsObj.CloseThread;
begin
  ThreadClosed := TRUE;

  {$IFDEF WIN32}
    if ThreadHandle <> Thandle(-1) then CloseHandle(ThreadHandle);
    ThreadHandle := 0;
  {$ENDIF}

  {$IFDEF OS2}
    {!! DosClose() on a ThreadHandle doesn't work - will eventually close }
    {!! other handles ... }
    { if ThreadHandle <> -1 then DosClose(ThreadHandle); }
    ThreadHandle := -1;
  {$ENDIF}
end; { proc. CloseThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure TThreadsObj.TerminateThread(ExitCode: Longint);
begin
  ThreadClosed := TRUE;

  {$IFDEF WIN32}
    if ThreadHandle <> Thandle(-1) then
      Windows.TerminateThread(ThreadHandle, ExitCode);
    ThreadHandle := 00;
  {$ENDIF}

  {$IFDEF OS2}
    if ThreadHandle <> -1 then DosKillThread(ThreadHandle);
    ThreadHandle := -1;
  {$ENDIF}
end; { proc. TerminateThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure ExitThisThread;
begin
  {$IFDEF WIN32}
    Windows.ExitThread(0);
  {$ENDIF}

  {$IFDEF OS2}
    Os2Base.DosExit(exit_Thread, 0);
  {$ENDIF}
end; { proc. ExitThread }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

end.
