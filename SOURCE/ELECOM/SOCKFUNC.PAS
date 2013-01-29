unit SockFunc;
(*
**
** SOCKFUNC routines
**
** Copyright (c) 1998 by Thomas W. Mueller
** Linux additions (c)1999 by Maarten Bekers
**
** Created : 24-Oct-1998
** Last update : 24-Oct-1998
**
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-
** Copyright (c) 1982, 1985, 1986 Regents of the University of California.
** All rights reserved.
**
** Redistribution and use in source and binary forms are permitted
** provided that this notice is preserved and that due credit is given
** to the University of California at Berkeley. The name of the University
** may not be used to endorse or promote products derived from this
** software without specific prior written permission. This software
** is provided ``as is'' without express or implied warranty.
s**
**      @(#)socket.h    7.2 (Berkeley) 12/30/87
-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

uses
{$IFDEF OS2}
  OS2Def,
  IBMSO32,
  IBMTCP32,
{$ENDIF}

{$IFDEF WIN32}
  windows,
  W32Sock,
{$ENDIF}

{$IFDEF LINUX}
  linux,
  Linsock,
{$ENDIF}

  Sysutils,
  SockDef;

Const SockInitted : Boolean = false;

function  SockErrorNo: Longint;
function  SockGetErrStr(_ErrNo: integer): ShortString;
procedure SockRaiseError(const _prefix: String; _ErrNo: integer);
procedure SockRaiseLastError(const _prefix: String);

function  SockAccept(_SockDesc: tSockDesc; _SockAddr: pSockAddr;
                    var _SockAddrLen: Longint): tSockDesc;
function  SockBind(_SockDesc: tSockDesc; var _SockAddr: tSockAddr): Longint;
function  SockCancel(_SockDesc: tSockDesc): Longint;
function  SockConnect(_SockDesc: tSockDesc; var _SockAddr: tSockAddr): Longint;
function  SockGetHostByName(Hostname: ShortString): phostent;
function  SockShutdown(_SockDesc: tSockDesc; _how: ULong): Longint;
function  SockGetSockAddr(_SockDesc: tSockDesc; var _SockAddr: tSockAddr): Longint;
function  SockGetSockOpt(_SockDesc: tSockDesc; _Level, _OptName: Integer;
                         _OptVal: PChar; var _OptLen: Integer): Longint;
function  SockSetSockOpt(_SockDesc: tSockDesc; _Level: uLong; _OptName: Ulong;
                         _OptVal: pChar; _OptLen: uLong ): Longint;
function  SockSetBlockingIO(_SockDesc: tSockDesc; _BlockingIO: boolean): Longint;
function  SockIoCtlSocket(_SockDesc: tSockDesc; Func: Longint): Longint;
function  SockListen(_SockDesc: tSockDesc; _SockQueue:  ULong): Longint;
function  SockRecv(_SockDesc: tSockDesc; _SockBuffer: pointer;
                   _SockBufLen: ULong; _SockFlags:  ULong): Longint;
function  SockSend(_SockDesc: tSockDesc; _SockBuffer: pointer;
                   _SockBufLen: ULong; _SockFlags:  ULong ): Longint;
function  SockSocket(_SockFamily: word; _SockType: word;
                     _SockProtocol: word ): tSockDesc;
function  SockClose(_SockDesc: tSockDesc): Longint;
function  SockInit: Longint;
function  SockClientAlive(_SockDesc: tSockDesc): Boolean;

function  SockGetHostAddrByName(_HostName: ShortString): ULONG;
function  SockGetHostNameByAddr(_HostAddr: pIn_Addr): ShortString;
function  SockGetHostname: ShortString;

function  SockGetServByName(_Name, _Proto: ShortString): pServEnt;
function  SockGetServPortByName(_Name, _Proto: ShortString): Longint;

function  SockHtonl(_Input: LongInt): longint;
function  SockHtons(_Input: SmallWord): SmallWord;

function  SockNtohl(_Input: LongInt): longint;
function  SockNtohs(_Input: SmallWord): longint;
function  SockDataAvail(_SockDesc: tSockDesc): Boolean;
function  SockSelect(_SockDesc: tSockDesc): Longint;
function  SockInetAddr(_s: ShortString):tIn_Addr;

{$IFNDEF LINUX}
 {$IFNDEF FPC}
  {$R SOCKFUNC.RES}
 {$ENDIF}
{$ENDIF}

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

Const
  Version    = '1.00';
  UseString:  ShortString = '@(#)socket interface unit for IBM TCP/IP and WinSock'#0;
  CopyRight1: ShortString = '@(#)socket Version '+Version+' - 26.08.1998'#0;
  CopyRight2: ShortString = '@(#}(C) Thomas Mueller 1998'#0;
  CopyRight3: ShortString = '@(#)(C) Chr.Hohmann BfS ST2.2 1996'#0;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


function SockErrorNo: Longint;
begin
 {$IFDEF OS2}
   Result := IBM_sock_errno;
 {$ENDIF}

 {$IFDEF WIN32}
   Result := WsaGetLastError;
 {$ENDIF}

 {$IFDEF LINUX}
   Result := SocketError;
 {$ENDIF}
end; { func. SockErrorNo }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetErrStr(_ErrNo: integer): ShortString;
begin
  Result:=LoadStr(_ErrNo);
end; { func. SockGetErrStr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure SockRaiseError(const _prefix: String; _ErrNo: integer);
begin
  raise eSocketErr.CreateFmt('%s: %s (%d)',
                             [_prefix, SockGetErrStr(_ErrNo), _ErrNo]);
end; { proc. SockRaiseError }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure SockRaiseLastError(const _prefix: String);
begin
  SockRaiseError(_Prefix, SockErrorNo);
end; { proc. SockRaiseLastError }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


function SockGetServByName(_Name, _Proto: ShortString): pServEnt;
begin
  _Name  := _Name + #00;
  _Proto := _Proto + #00;

  {$IFDEF WIN32}
    Result := getservbyname(@_Name[01], @_Proto[01]);
  {$ENDIF}

  {$IFDEF OS2}
    Result := ibm_getservbyname(@_Name[01], @_Proto[01]);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := getservbyname(@_Name[1], @_Proto[01]);
  {$ENDIF}
end; { func. SockGetServByName }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetServPortByName(_Name, _Proto: ShortString): longint;
var ServEnt: pServEnt;
begin
  ServEnt := SockGetServByName(_Name, _Proto);

  if Assigned(ServEnt) then
    Result := ServEnt^.s_Port
      else Result := -01;
end; { func. SockGetServPortByName }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockHtonl( _Input: longint): longint;
type SwapLong = packed record
                 case integer of
                   0: (SLong:  longint);
                   1: (SArray: packed array[1..4] of byte);
                end;
var Inp,
    Tmp: SwapLong;
begin
  Inp.SLong     := _Input;
  Tmp.SArray[1] := Inp.SArray[4];
  Tmp.SArray[2] := Inp.SArray[3];
  Tmp.SArray[3] := Inp.SArray[2];
  Tmp.SArray[4] := Inp.SArray[1];
  result := Tmp.SLong;
end;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockHtons( _Input: SmallWord): SmallWord;
type SwapWord = packed record
                 case integer of
                   0: (SWord:  SmallWord);
                   1: (SArray: packed array[1..2] of byte);
               end;
var Inp,Tmp: SwapWord;
begin
  Inp.SWord     := _Input;
  Tmp.SArray[1] := Inp.SArray[2];
  Tmp.SArray[2] := Inp.SArray[1];
  Result        := Tmp.SWord;
end; { func. SockhToNl }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockNtohl( _Input: longint): longint;
begin
  {$IFNDEF LINUX}
     Result:=ntohl(_Input);
  {$ELSE}
     {!!!!!!!!!!!!!!!!!!!!!!!}
     Result :=  _Input;
  {$ENDIF}
end; { func. sockNToHl }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockNtohs( _Input: SmallWord): longint;
begin
  {$IFDEF WIN32}
    Result := ntohs( _input);
  {$ENDIF}

  {$IFDEF OS2}
{!!!!!    Result := ntohs( _input);}
    Result := Lo(_Input) * 256 + Hi(_Input);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := ntohs(_input);
  {$ENDIF}
end; { func. SockNToHs }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockAccept(_SockDesc: tSockDesc;
                    _SockAddr: pSockAddr;
                    var _SockAddrLen: Longint): longint;
begin
  {$IFDEF WIN32}
    Result := Accept(_SockDesc, _SockAddr, @_SockAddrLen);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_Accept(_SockDesc, _SockAddr, @_SockAddrLen);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := Accept(_SockDesc, _SockAddr^, _SockAddrLen);
  {$ENDIF}
end; { func. SockAccept }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockBind(_SockDesc:  tSockDesc;
                  var _SockAddr: tSockAddr ): Longint;
begin
  {$IFDEF WIN32}
    SockBind := Bind(_SockDesc, @_SockAddr, SockAddr_Len);
  {$ENDIF}

  {$IFDEF OS2}
    SockBind := IBM_Bind(_SockDesc, @_SockAddr, SockAddr_Len);
  {$ENDIF}

  {$IFDEF LINUX}
    SockBind := Longint(Bind(_SockDesc, _SockAddr, SockAddr_Len));
  {$ENDIF}
end; { func. SockBind }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockConnect(_SockDesc: tSockDesc;
                     var _SockAddr: tSockAddr): Longint;
begin
  {$IFDEF WIN32}
    SockConnect := connect(_SockDesc, @_SockAddr, SockAddr_Len);
  {$ENDIF}

  {$IFDEF OS2}
    SockConnect := ibm_connect(_SockDesc, @_SockAddr, SockAddr_Len);
  {$ENDIF}

  {$IFDEF LINUX}
    SockConnect := connect(_SockDesc, _SockAddr, sockAddr_Len);
  {$ENDIF}
end; { func. SockConnect }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockCancel(_SockDesc: tSockDesc): Longint;
begin
  {$IFDEF WIN32}
    Result := SockCancel(_SockDesc);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_So_Cancel(_SockDesc);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := longint(true);
    if _SockDesc=0 then ;

    {$WARNING SockCancel function not implemented }
    {!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!}
  {$ENDIF}
end; { func. SockCancel }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockShutdown(_SockDesc:  tSockDesc;
                      _how: ULong): Longint;
begin
  {$IFDEF WIN32}
    SockShutdown := ShutDown(_SockDesc, _How);
  {$ENDIF}

  {$IFDEF OS2}
    SockShutDown := IBM_ShutDown(_SockDesc, _How);
  {$ENDIF}

  {$IFDEF LINUX}
    SockShutDown := ShutDown(_SockDesc, _How);
  {$ENDIF}
end; { func. SockShutDown }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetSockAddr(_SockDesc: tSockDesc; var _SockAddr: tSockAddr): Longint;
var sLength: Integer;
begin
  FillChar(_SockAddr, SizeOf(_SockAddr), #00);
  sLength := SizeOf(_SockAddr);

  {$IFDEF WIN32}
    Result := GetSockName(_SockDesc, @_SockAddr, sLength);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_GetSockName(_SockDesc, @_SockAddr, @sLength);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := GetSocketName(_SockDesc, _SockAddr, sLength);
  {$ENDIF}
end; { func. sockGetSockAddr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockSetBlockingIO(_SockDesc: tSockDesc;
                          _BlockingIO: boolean): Longint;
var Arg: ULONG;
begin
  {$IFDEF OS2}
    if _BlockingIO then Arg := 00
      else Arg := 01;

    Result := IBM_IOCtl(_SockDesc, FIONBIO, @Arg, SizeOf(Arg));
  {$ENDIF}

  {$IFDEF WIN32}
    if _BlockingIO then Arg := 00
      else Arg := 01;

    Result := IOCtlSocket(_SockDesc, FIONBIO, Arg);
  {$ENDIF}

  {$IFDEF LINUX}
    if _BlockingIO then Arg := 00
      else Arg := 01;

    Result := Longint(ioctl(_SockDesc, Linux.FIONBIO, @Arg));
  {$ENDIF}
end; { func. SockSetBlockingIO }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function  SockIoCtlSocket(_SockDesc: tSockDesc; Func: Longint): Longint;
var Arg: ULONG;
begin
  Arg := 0;

  {$IFDEF OS2}
    Result := IBM_IOCtl(_SockDesc, FUNC, @Arg, SizeOf(Arg));
  {$ENDIF}

  {$IFDEF WIN32}
    Result := IOCtlSocket(_SockDesc, FUNC, Arg);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := Longint(IoCtl(_SockDesc, Func, @Arg));
  {$ENDIF}
end; { func. SockIoCtlSocket }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetSockOpt(_SockDesc: tSockDesc; _Level, _OptName: Integer;
                        _OptVal: PChar; var _OptLen: Integer): Longint;
begin
  {$IFDEF WIN32}
    Result := GetSockOpt(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_GetSockOpt(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := SetSocketOptions(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}
end; { func. SockGetSockOpt }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockSetSockOpt(_SockDesc: tSockDesc; _Level: uLong; _OptName: Ulong;
                        _OptVal: pChar; _OptLen: uLong ): Longint;
begin
  {$IFDEF WIN32}
    Result := SetSockOpt(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_SetSockOpt(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := SetSocketOptions(_SockDesc, _Level, _OptName, _OptVal, _OptLen);
  {$ENDIF}
end; { func. SockSetSockOpt }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockDataAvail(_SockDesc: tSockDesc): Boolean;
{$IFDEF LINUX}
  var ReadFDS  : FDSet;
      Temp     : Longint;
{$ENDIF}
begin
   {$IFNDEF LINUX}
     Result := (SockSelect(_SockDesc) > 00);
   {$ELSE}
     fd_Zero(ReadFDS);
     fd_Set(_SockDesc, ReadFDS);

     Temp := Select(_SockDesc + 01, @ReadFDS, nil, nil, 0);
     if (Temp > 0) then
       begin
         SockDataAvail := FD_ISSET(_SockDesc, ReadFDS);
       end { if }
         else SockDataAvail := false;
   {$ENDIF}
(*
  {$IFDEF OS2}
    Arg := 00;
    Result := IBM_IOCTL(_SockDesc, FIONREAD, @Arg, SizeOf(Arg));

    if Arg > 00 then Result := Arg
      else Result := $FFFFFFFF;
  {$ENDIF}

  {$IFDEF WIN32}
    Result := IOCtlSocket(_SockDesc, FIONREAD, Arg);
    if Arg > 00 then Result := Arg
      else Result := $FFFFFFFF;
  {$ENDIF}
*)
end; { func. SockDataAvail }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockListen(_SockDesc: tSockDesc;
                    _SockQueue:  ULong): Longint;
begin
  {$IFDEF WIN32}
    SockListen := listen(_SockDesc, _SockQueue);
  {$ENDIF}

  {$IFDEF OS2}
    SockListen := ibm_listen(_SockDesc, _SockQueue);
  {$ENDIF}

  {$IFDEF LINUX}
    SockListen := Longint(Listen(_SockDesc, _SockQueue));
  {$ENDIF}
end; { func. SockListen }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockSelect(_SockDesc: tSockDesc ): Longint;
{$IFDEF OS2}
var SockCopy: ULONG;
{$ENDIF}

{$IFDEF WIN32}
var SockArr : TFDSet;
    Timeout : TTimeVal;
{$ENDIF}

{$IFDEF LINUX}
var ReadFDS  : FDSet;
{$ENDIF}
begin
  {$IFDEF OS2}
    SockCopy := _SockDesc;
    Result := IBM_Select(@SockCopy, 1, 0, 0, 0);
  {$ENDIF}

  {$IFDEF WIN32}
    SockArr.fd_Count := 01;
    SockArr.fd_Array[00] := _SockDesc;
    Timeout.tv_sec := 00;
    Timeout.tv_usec := 00;

    Result := Select(00, @SockArr, NIL, NIL, @Timeout);
  {$ENDIF}

  {$IFDEF LINUX}
    fd_Zero(ReadFDS);
    fd_Set(_SockDesc, ReadFDS);

    SockSelect := Select(_SockDesc + 01, @ReadFDS, nil, nil, 0);
  {$ENDIF}
end; { func. SockSelect }

(*-+-*-+-*-+-*-+-*-+-*-+ -*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockRecv(_SockDesc: tSockDesc;
                  _SockBuffer: pointer;
                  _SockBufLen: ULong;
                  _SockFlags:  ULong): Longint;
var Counter: Longint;
begin
  {$IFDEF WIN32}
    SockRecv := recv(_SockDesc,
                     _SockBuffer,
                     _SockBufLen,
                     _SockFlags);
  {$ENDIF}

  {$IFDEF OS2}
    SockRecv := ibm_recv(_SockDesc,
                         _SockBuffer,
                         _SockBufLen,
                         _SockFlags);
  {$ENDIF}

  {$IFDEF LINUX}
    SockRecv := Recv(_SockDesc,
                     _SockBuffer^,
                     _SockBufLen,
                     _SockFlags);
  {$ENDIF}
end; { func. SockRecv }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockSend(_SockDesc: tSockDesc;
                  _SockBuffer: pointer;
                  _SockBufLen: ULong;
                  _SockFlags:  ULong): Longint;
begin
  {$IFDEF WIN32}
    SockSend := Send(_SockDesc,
                     _SockBuffer,
                     _SockBufLen,
                     _SockFlags);
  {$ENDIF}

  {$IFDEF OS2}
    SockSend := IBM_Send(_SockDesc,
                         _SockBuffer,
                         _SockBufLen,
                         _SockFlags);
  {$ENDIF}

  {$IFDEF LINUX}
    SockSend := Send(_SockDesc,
                     _SockBuffer^,
                     _SockBufLen,
                     _SockFlags);
  {$ENDIF}
end; { func. SockSend }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockSocket(_SockFamily:   word;
                    _SockType:     word;
                    _SockProtocol: word): tSockDesc;
begin
  {$IFDEF WIN32}
    SockSocket := Socket(_SockFamily, _SockType, _SockProtocol);
  {$ENDIF}

  {$IFDEF OS2}
    SockSocket := ibm_Socket(_SockFamily, _SockType, _SockProtocol);
  {$ENDIF}

  {$IFDEF LINUX}
    SockSocket :=  Socket(_SockFamily, _SockType, _SockProtocol);
  {$ENDIF}
end; { func. SockSocket }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockClose(_SockDesc: tSockDesc): Longint;
begin
 {$IFDEF OS2}
    Result := IBM_soclose(_SockDesc);
 {$ENDIF}

 {$IFDEF WIN32}
    Result := Closesocket(_SockDesc);
 {$ENDIF}

 {$IFDEF LINUX}
   Result := Longint(fdClose(_SockDesc));
 {$ENDIF}
end; { func. SockClose }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockInit: Longint;
{$IFDEF WIN32}
var Data: TWSAData;
{$ENDIF}
begin
  if SockInitted then EXIT;
  SockInitted := true;

  {$IFDEF OS2}
    SockInit := IBM_Sock_Init;
  {$ENDIF}

  {$IFDEF WIN32}
    SockInit := WsaStartup($0101, Data);
  {$ENDIF}

  {$IFDEF LINUX}
    SockInit :=  0;
  {$ENDIF}
end; { func. SockInit }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetHostByName(Hostname: ShortString): phostent;
begin
  HostName := HostName + #00;
  {$IFDEF WIN32}
    Result := GetHostByName(@HostName[01]);
  {$ENDIF}

  {$IFDEF OS2}
    Result := IBM_GetHostByName(@HostName[01]);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := GetHostByName(@HostName[1]);
  {$ENDIF}
end; { func. SockGetHostByName }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetHostAddrByName(_HostName: ShortString): ULong;
var ReturnCode: pHostEnt;
    InAddr    : tIn_Addr;
begin
  ReturnCode := SockGetHostbyName(_HostName);
  if Assigned(ReturnCode) then
    begin
      InAddr := ReturnCode^.H_Addr_List^^;
      Result := InAddr.IpAddr;
    end
      else Result:=$FFFFFFFF;
end; { func. SockGetHostAddrByName }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetHostByAddr(HostAddr:     pIn_Addr;
                           HostAddrLen:  ULong;
                           HostAddrType: ULong): pointer;
begin
  {$IFDEF WIN32}
    SockGetHostByAddr := GetHostbyAddr(HostAddr,
                                       HostAddrLen,
                                       HostAddrType);
  {$ENDIF}

  {$IFDEF OS2}
    SockGetHostByAddr := IBM_GetHostbyAddr(HostAddr,
                                           HostAddrLen,
                                           HostAddrType);
  {$ENDIF}

  {$IFDEF LINUX}
    Result := GetHostByAddr(HostAddr, HostAddrLen, HostAddrtype);
  {$ENDIF}
end; { func. SockGetHostbyAddr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetHostNameByAddr(_HostAddr: pIn_Addr): ShortString;
var Counter   : Integer;
    ReturnCode: pHostEnt;
    HName     : ShortString;
begin
  ReturnCode := SockGetHostByAddr(_HostAddr,
                                  In_Addr_Len,
                                  AF_INET);

  if (ULong(ReturnCode) <> 00) then
    begin
      HName := '';
      Counter := 00;

      While ReturnCode^.H_Name^[Counter] <> #00 do
        begin
          HName := HName + ReturnCode^.H_Name^[Counter];
          Inc(Counter);
        end; { while }
    end
      else HName := 'Hostname not found';

  SockGetHostNameByAddr := HName;
end; { func. SockGetHostNameByAddr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockGetHostname: ShortString;
var Counter   : Longint;
    sResult   : Longint;
    HostName  : ShortString;
    InAddr    : TIn_Addr;
begin
  FillChar(HostName, SizeOf(HostName), #00);

  {$IFDEF WIN32}
    sResult := GetHostName(@HostName[01], SizeOf(HostName));
  {$ENDIF}

  {$IFDEF OS2}
    sResult := IBM_GetHostName(@HostName[01], SizeOf(HostName));
  {$ENDIF}

  {$IFDEF LINUX}
    {!!!!!!!!!!!!!!!!!!!}
    InAddr.ClassA := 127;
    InAddr.ClassB := 0;
    InAddr.ClassC := 0;
    InAddr.ClassD := 1;

    HostName := SockGetHostNameByAddr(@InAddr) + #00;
    sResult := Length(HostName);
  {$ENDIF}

  Counter := 01;
  While (Counter < SizeOf(HostName)) AND (HostName[Counter] <> #00) do
    Inc(Counter);

  if (Counter > 01) then
    SetLength(HostName, Counter)
      else HostName := 'amnesiac';

  SockGetHostname := HostName;
end; { func. SockGetHostName }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockInetAddr(_s: ShortString): tIn_Addr;
begin
  _s := _s + #00;

  {$IFNDEF LINUX}
    Result.IpAddr := INet_Addr(@_S[01]);
  {$ELSE}
    {$WARNING SockInetAddr function not implemented! }
    Result.IpAddr := INADDR_NONE;
  {$ENDIF}
end; { func. SockInetAddr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

function SockClientAlive(_SockDesc: tSockDesc): Boolean;
var TempCH     : Char;
    Returncode : Longint;
    TempError  : Longint;
    TempStr    : String;
begin
  Result := true;

  ReturnCode := SockRecv(_SockDesc, @TempCH, SizeOf(TempCH), MSG_PEEK);
  TempError := SockErrorNo;

  TempStr := SockGetErrStr(TempError);

  if ReturnCode = 0 then Result := false; { was: = 0 }
  if (TempError <> WSAEWOULDBLOCK) AND (TempError <> 00) then
    Result := false;
end; { func. SockClientAlive }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

initialization
 {!!   SockInit; }

finalization
  {$IFDEF WIN32}
    //WsaCleanUp;
  {$ENDIF}
end.  { unit SockFunc }
