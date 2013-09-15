{$I DEFINES.INC}
unit Restore;

interface

uses
  Views;

const
  MaxScreenHeight = 60;

implementation

uses
  Crt, Drivers, VideoUtils;

var
  SavedScreen: TScreenBuffer;

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
  RestoreScreen(SavedScreen);
  GotoXY(CursorCoords AND $00FF, (CursorCoords AND $FF00) SHR 8);
  ExitProc := ExitSave
end; { MyExitProc }

{ Initialization code performed on program startup }
begin
  CursorCoords := WhereX + (WhereY SHL 8);
  SaveScreen(SavedScreen);
  ExitSave := ExitProc;
  ExitProc := @MyExitProc
end. { Restore }
