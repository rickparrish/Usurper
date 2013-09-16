{$I DEFINES.INC}
unit Restore;

interface

const
  MaxScreenHeight = 60;

implementation

uses
  Drivers, VideoUtils, Crt;

var
  SavedScreen: TScreenBuffer;

var
  Index: Word;
  ExitSave: Pointer;
  SavedX, SavedY: Integer;

{ Exit code performed on program exit }
procedure MyExitProc;
begin
  Index := 0;
  { Iterate over all rows, copying from memory to screen }
  ScreenRestore(SavedScreen);
  GotoXY(SavedX, SavedY);
  ExitProc := ExitSave
end; { MyExitProc }

{ Initialization code performed on program startup }
begin
  SavedX := WhereX;
  SavedY := WhereY;
  ScreenSave(SavedScreen);
  ExitSave := ExitProc;
  ExitProc := @MyExitProc
end. { Restore }
