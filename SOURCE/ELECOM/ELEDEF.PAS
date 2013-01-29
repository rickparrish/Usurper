unit ELEDEF;
(*
**
** Serial and TCP/IP communication routines for DOS, OS/2 and Win9x/NT.
** Tested with: TurboPascal   v7.0,    (DOS)
**              VirtualPascal v2.1,    (OS/2, Win32)
**              FreePascal    v0.99.12 (DOS, Win32)
**              Delphi        v4.0.    (Win32)
**
** Version : 1.03
** Created : 13-Jun-1999
** Last update : 05-Aug-2000
**
** Note: (c)1998-1999 by Maarten Bekers.
**       If you have any suggestions, please let me know.
**
*)

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 INTERFACE
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

Const
  ComNameDLL = 'elecom13.dll';

type SliceProc = procedure;

procedure Com_Startup(ObjectType: Longint); stdcall;
function  Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                   Parity: Char; StopBits: Byte): Boolean; stdcall;
procedure Com_OpenQuick(Handle: Longint); stdcall;
function  Com_OpenKeep(Comport: Byte): Boolean; stdcall;
procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); stdcall;
procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); stdcall;
function  Com_GetBPSrate: Longint; stdcall;
procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); stdcall;
procedure Com_SetDtr(State: Boolean); stdcall;
function  Com_CharAvail: Boolean;  stdcall;
function  Com_Carrier: Boolean; stdcall;
function  Com_ReadyToSend(BlockLen: Longint): Boolean;
function  Com_GetChar: Char; stdcall;
function  Com_SendChar(C: Char): Boolean; stdcall;
function  Com_GetDriverInfo: String; stdcall;
function  Com_GetHandle: Longint; stdcall;
function  Com_InitSucceeded: Boolean; stdcall;
procedure Com_Close; stdcall;
procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); stdcall;
procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc); stdcall;
procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); stdcall;
procedure Com_PurgeOutBuffer; stdcall;
procedure Com_PurgeInBuffer; stdcall;
procedure Com_PauseCom(CloseCom: Boolean); stdcall;
procedure Com_ResumeCom(OpenCom: Boolean); stdcall;
procedure Com_FlushOutBuffer(Slice: SliceProc); stdcall;
procedure Com_SendString(Temp: String); stdcall;
procedure Com_ShutDown; stdcall;
procedure Com_SetDontClose(Value: Boolean); stdcall;
procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); stdcall;
function  Com_InitFailed: Boolean; stdcall;
function  Com_ErrorStr: String; stdcall;


(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)
 IMPLEMENTATION
(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Com_Startup(ObjectType: Longint); external ComNameDLL index 1;
function  Com_Open(Comport: Byte; BaudRate: Longint; DataBits: Byte;
                   Parity: Char; StopBits: Byte): Boolean; external ComNameDLL index 2;
procedure Com_OpenQuick(Handle: Longint); external ComNameDLL index 3;
function  Com_OpenKeep(Comport: Byte): Boolean; external ComNameDLL index 4;
procedure Com_GetModemStatus(var LineStatus, ModemStatus: Byte); external ComNameDLL index 5;
procedure Com_SetLine(BpsRate: longint; Parity: Char; DataBits, Stopbits: Byte); external ComNameDLL index 6;
function  Com_GetBPSrate: Longint; external ComNameDLL index 7;
procedure Com_GetBufferStatus(var InFree, OutFree, InUsed, OutUsed: Longint); external ComNameDLL index 8;
procedure Com_SetDtr(State: Boolean);  external ComNameDLL index 9;
function  Com_CharAvail: Boolean;  external ComNameDLL index 10;
function  Com_Carrier: Boolean; external ComNameDLL index 11;
function  Com_ReadyToSend(BlockLen: Longint): Boolean; external ComNameDLL index 12;
function  Com_GetChar: Char; external ComNameDLL index 13;
function  Com_SendChar(C: Char): Boolean; external ComNameDLL index 14;
function  Com_GetDriverInfo: String; external ComNameDLL index 15;
function  Com_GetHandle: Longint; external ComNameDLL index 16;
function  Com_InitSucceeded: Boolean; external ComNameDLL index 17;
procedure Com_Close; external ComNameDLL index 18;
procedure Com_SendBlock(var Block; BlockLen: Longint; var Written: Longint); external ComNameDLL index 19;
procedure Com_SendWait(var Block; BlockLen: Longint; var Written: Longint; Slice: SliceProc); external ComNameDLL index 20;
procedure Com_ReadBlock(var Block; BlockLen: Longint; var Reads: Longint); external ComNameDLL index 21;
procedure Com_PurgeOutBuffer; external ComNameDLL index 22;
procedure Com_PurgeInBuffer; external ComNameDLL index 23;
procedure Com_PauseCom(CloseCom: Boolean); external ComNameDLL index 24;
procedure Com_ResumeCom(OpenCom: Boolean); external ComNameDLL index 25;
procedure Com_FlushOutBuffer(Slice: SliceProc); external ComNameDLL index 26;
procedure Com_SendString(Temp: String); external ComNameDLL index 27;
procedure Com_ShutDown; external ComNameDLL index 28;
procedure Com_SetDontClose(Value: Boolean); external ComNameDLL index 29;
procedure Com_SetFlow(SoftTX, SoftRX, Hard: Boolean); external ComNameDLL index 30;
function  Com_InitFailed: Boolean; external ComNameDLL index 31;
function  Com_ErrorStr: String; external ComNameDLL index 32;

end.
