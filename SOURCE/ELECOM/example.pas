program Example;
(*
**
** EXAMPLE how to use communications
** You can install this program from within EleBBS and test how it works :)
** This is only an example of how to use EleCOM for writing so-called "doors",
** to see an example how to use EleCOM independent off a BBS program, see
** EXAM2.PAS
**
** version: 1.01
** Created: 08-Apr-1999
**
** EleBBS install lines:
**
** DOS install line:             EXAMPLE.EXE -H*P
** Win32 install line:           EXAMPLE.EXE -H*W
** Win32 (telnet) install line:  EXAMPLE.EXE -H*W -XT
** OS/2 install line:            EXAMPLE.EXE -H*W
** OS/2 (telnet) install line:   EXAMPLE.EXE -H*W -XT
**
*)

{.DEFINE FOSSIL}
{.DEFINE OS2COM}
{$DEFINE W32COM}

{$IFNDEF FOSSIL}
 {$IFNDEF OS2COM}
  {$IFNDEF W32COM}
    You need to define one of these..
  {$ENDIF}
 {$ENDIF}
{$ENDIF}

uses Combase,
      {$IFDEF FOSSIL}
        Fos_Com
      {$ENDIF}

      {$IFDEF OS2COM}
        Os2Com,
        Telnet
      {$ENDIF}

      {$IFDEF W32COM}
        W32SNGL,
        Telnet
      {$ENDIF} ;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

var ComObj    : PCommObj;
    IsTelnet  : Boolean;
    ComHandle : Longint;
    ReadCH    : Char;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComReadProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case IsTelnet of
      FALSE : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
      TRUE  : PTelnetObj(ComObj)^.Com_ReadProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case IsTelnet of
      FALSE : POs2Obj(ComObj)^.Com_ReadProc(TempPtr);
      TRUE  : PTelnetObj(ComObj)^.Com_ReadProc(TempPtr);
    end; { case }
  {$ENDIF}
end; { proc. Int_ComReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComWriteProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case IsTelnet of
      FALSE : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
      TRUE  : PTelnetObj(ComObj)^.Com_WriteProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case IsTelnet of
      FALSE : POs2Obj(ComObj)^.Com_WriteProc(TempPtr);
      TRUE  : PTelnetObj(ComObj)^.Com_WriteProc(TempPtr);
    end; { case }
  {$ENDIF}
end; { proc. Int_ComWriteProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure ParseCommandLine;
var Counter: Longint;
    TempStr: String;
  {$IFDEF MSDOS}
    Code   : Integer;
  {$ELSE}
    Code   : Longint;
  {$ENDIF}
begin
  for Counter := 01 to ParamCount do
    begin
      TempStr := ParamStr(Counter);

      if TempStr[1] in ['/', '-'] then
        Case UpCase(TempStr[2]) of
           'H' : begin

                   TempStr := Copy(TempStr, 3, Length(TempStr) - 2);
                   Val(TempStr, ComHandle, Code);


                 end; { 'H' }
           'X' : begin

                   if UpCase(TempStr[3]) = 'T' then                      { XT }
                        IsTelnet := true;

                 end; { 'X' }
        end; { case }

    end; { for }
end; { proc. ParseCommandLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

Function  FStr (N : LongInt) : String;           { Convert integer to string }
var Temp: String;
begin
  Str(n,temp);
  FStr:=Temp;
end; { func. FStr }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

begin
  IsTelnet := false;
  ParseCommandLine;

  {$IFDEF W32COM}
    if IsTelnet then ComObj := New(PTelnetObj, Init)
      else ComObj := New(PWin32Obj, Init);
  {$ENDIF}

  {$IFDEF FOSSIL}
    ComObj := New(PFossilObj, Init);
  {$ENDIF}

  {$IFDEF OS2COM}
    if IsTelnet then ComObj := New(PTelnetObj, Init)
      else ComObj := New(POs2Obj, Init);
  {$ENDIF}

  {$IFDEF WIN32}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}

  {$IFDEF OS2}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}

  ComObj^.DontClose := true;    { We use an inherited handle, never close it! }
  ComObj^.Com_OpenQuick(ComHandle);       { Open the comport using the handle }
  ComObj^.Com_SendString('Hello there!' + #13#10);
  ComObj^.Com_SendString('We are using handle #' + FStr(ComHandle) + #13#10);


  repeat
    ReadCH := ComObj^.Com_GetChar;

    if ReadCH <> #13 then
      Writeln('Other..');
  until (ReadCH = #13) OR (NOT ComObj^.Com_Carrier);

  Dispose(ComObj, Done);                  { Dispose the communications object }
end.
