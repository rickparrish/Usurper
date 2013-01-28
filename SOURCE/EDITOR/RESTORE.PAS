unit Restore;

interface

uses
  Views;

const
  MaxScreenHeight = 60;

type
  PTheScreen = ^TTheScreen;
  TTheScreen = array[1..MaxScreenHeight] of TDrawBuffer;

var
  PScreen: PTheScreen;

implementation

uses
  Drivers;

const
  ScreenMode = $49;
  ScreenCols = $4A;
  CursorPos  = $50;
  ScreenRows = $84;

{$ifdef VER60}
var
  Seg0040, SegB000, SegB800: Word;
{$endif}

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
  for Loop := 1 to Mem[Seg0040:ScreenRows] do
  begin
    P := Ptr(Segment, Index);
    Move(PScreen^[Loop], P^, RowSize);
    Inc(Index, RowSize)
  end;
  { Free buffer }
  Dispose(PScreen);
  { Restore cursor coordinates }
  MemW[Seg0040:CursorPos] := CursorCoords;
  ExitProc := ExitSave
end; { MyExitProc }

{ Initialization code performed on program startup }
begin
{$ifdef VER60}
  Seg0040 := $40;
  SegB000 := $B000;
  SegB800 := $B800;
{$endif}
  { Save cursor position }
  CursorCoords := MemW[Seg0040:CursorPos];
  { Allocate memory to save screen }
  New(PScreen);
  { Zero the memory }
  FillChar(PScreen^, SizeOf(TTheScreen), 0);
  { Identify what screen type we have }
  if Mem[Seg0040:ScreenMode] = smMono then
    Segment := SegB000
  else
    Segment := SegB800;
  Index := 0;
  { How wide is each row? }
  RowSize := Mem[Seg0040:ScreenCols] shl 1;
  { Iterate over all rows, copying from screen to memory }
  for Loop := 1 to Mem[Seg0040:ScreenRows] do
  begin
    P := Ptr(Segment, Index);
    Move(P^, PScreen^[Loop], RowSize);
    Inc(Index, RowSize)
  end;
  ExitSave := ExitProc;
  ExitProc := @MyExitProc
end. { Restore }