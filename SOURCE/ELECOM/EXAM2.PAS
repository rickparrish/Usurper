program Exam2;
(*
**
** EXAMPLE how to use communications
** This is only an example of how to use EleCOM independently of a BBS program,
** to see an example how to use EleCOM as a door from a BBS program, see
** EXAMPLE.PAS
** TELNET is not supported as we dont have a telnet server
**
** version: 1.01
** Created: 30-Sep-1999
**
** Fire up line: EXAM2.EXE -C<comport>
** eg: EXAM2.EXE -C4
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
        Os2Com
      {$ENDIF}

      {$IFDEF W32COM}
        W32SNGL
      {$ENDIF} ;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

var ComObj    : PCommObj;
    ComPort   : Longint;
    ReadCH    : Char;
    IsTelnet  : Boolean;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComReadProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case IsTelnet of
      FALSE : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case IsTelnet of
      FALSE : POs2Obj(ComObj)^.Com_ReadProc(TempPtr);
    end; { case }
  {$ENDIF}
end; { proc. Int_ComReadProc }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

procedure Int_ComWriteProc(var TempPtr: Pointer);
begin
  {$IFDEF WIN32}
    Case IsTelnet of
      FALSE : PWin32Obj(ComObj)^.Com_DataProc(TempPtr);
    end; { case }
  {$ENDIF}

  {$IFDEF OS2}
    Case IsTelnet of
      FALSE : POs2Obj(ComObj)^.Com_WriteProc(TempPtr);
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
           'C' : begin

                   TempStr := Copy(TempStr, 3, Length(TempStr) - 2);
                   Val(TempStr, ComPort, Code);

                 end; { 'C' }
        end; { case }

    end; { for }
end; { proc. ParseCommandLine }

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)


begin
  IsTelnet := false;
  ParseCommandLine;

  {$IFDEF W32COM}
     ComObj := New(PWin32Obj, Init);
  {$ENDIF}

  {$IFDEF FOSSIL}
    ComObj := New(PFossilObj, Init);
  {$ENDIF}

  {$IFDEF OS2COM}
    ComObj := New(POs2Obj, Init);
  {$ENDIF}

  {$IFDEF WIN32}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}

  {$IFDEF OS2}
    ComObj^.Com_SetDataProc(@Int_ComReadProc, @Int_ComWriteProc);
  {$ENDIF}

  ComObj^.Com_OpenKeep(Comport);           { Dont change any comport settings }
  ComObj^.Com_SendString('Hello there!' + #13#10);

  repeat
    ReadCH := ComObj^.Com_GetChar;

    if ReadCH <> #13 then
      Writeln('Other..');
  until (ReadCH = #13) OR (NOT ComObj^.Com_Carrier);

  Dispose(ComObj, Done);                  { Dispose the communications object }
end.
