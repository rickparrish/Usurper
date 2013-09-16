{$I DEFINES.INC}
unit Restore;

interface

uses
  Views;

const
  MaxScreenHeight = 60;

implementation

uses
  Drivers;

var
  SavedScreen: TScreenBuf;

const
  ScreenMode = $49;
  ScreenCols = $4A;
  CursorPos  = $50;
  ScreenRows = $84;

var
  Loop: Byte;
  P: Pointer;
  CursorCoords, Segment, RowSize, Index: Word;
  ExitSave: Pointer;

{ Exit code performed on program exit }
procedure MyExitProc; far;
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