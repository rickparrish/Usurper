program DLLEXAM;
{$H-} { important, turn off Ansi-Strings }
(*
**
** Example how to use communications with the DLL file
** You can install this program from within EleBBS and test how it works :)
**
** version: 1.02
** Created: 13-Jun-1999
**
** EleBBS install lines:
**
** DOS install line:             DLLEXAM.EXE -H*P
** Win32 install line:           DLLEXAM.EXE -H*W
** Win32 (telnet) install line:  DLLEXAM.EXE -H*W -XT
** OS/2 install line:            DLLEXAM.EXE -H*W
** OS/2 (telnet) install line:   DLLEXAM.EXE -H*W -XT
**
*)

uses EleDEF;

(*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-+-*-*)

var IsTelnet  : Boolean;
    ComHandle : Longint;
    ReadCH    : Char;

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

begin
  IsTelnet := false;
  ParseCommandLine;

  Case IsTelnet of
    FALSE : Com_StartUp(1);
    TRUE  : Com_StartUp(2);
  end; { case }

  Com_SetDontClose(true);       { We use an inherited handle, never close it! }
  Com_OpenQuick(ComHandle);               { Open the comport using the handle }

  Com_SendString('Hello there!' + #13#10);
  Com_SendString('Press [ENTER]');

  repeat
    ReadCH := Com_GetChar;
  until (ReadCH = #13) OR (NOT Com_Carrier);

  Com_ShutDown;
end.
