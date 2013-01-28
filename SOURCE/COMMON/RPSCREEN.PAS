{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}
unit RPScreen;

interface

{$IFDEF WIN32}
uses
  Windows;

type
  TScreenBuf = Array[1..25, 1..80] of TCharInfo; // REETODO Don't hardcode to 80x25
{$ENDIF}

procedure RPGotoXY(xy: SmallWord);
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
procedure RPSaveScreen(var screenBuf: TScreenBuf);
procedure RPSetAttrAt(x, y, attr: SmallWord);
function  RPWhereXY: SmallWord;

implementation

{$IFDEF WIN32}
var
  StdOut: THandle;
{$ENDIF}

{$IFDEF WIN32}
procedure RPGotoXY(xy: SmallWord);
var
  Coord: TCoord;
begin
  Coord.x := xy AND $00FF;
  Coord.y := xy AND $FF00 SHR 8;
  SetConsoleCursorPosition(StdOut, Coord);
end;

{ REETODO Should detect screen size }
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  WritePos   : TCoord;
  DestRect   : TSmallRect;
begin
  BufSize.X       := 80;
  BufSize.Y       := 25;
  WritePos.X      := 0;
  WritePos.Y      := 0;
  DestRect.Left   := 0;
  DestRect.Top    := 0;
  DestRect.Right  := 79;
  DestRect.Bottom := 24;
  WriteConsoleOutput(StdOut, @screenBuf[1][1], BufSize, WritePos, DestRect);
end;

{ REETODO Should detect screen size }
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  ReadPos    : TCoord;
  SourceRect : TSmallRect;
begin
  BufSize.X         := 80;
  BufSize.Y         := 25;
  ReadPos.X         := 0;
  ReadPos.Y         := 0;
  SourceRect.Left   := 0;
  SourceRect.Top    := 0;
  SourceRect.Right  := 79;
  SourceRect.Bottom := 24;
  ReadConsoleOutput(StdOut, @screenBuf[1][1], BufSize, ReadPos, SourceRect);
end;

procedure RPSetAttrAt(x, y, attr: SmallWord);
var
  NumWritten: Longint;
  WriteCoord: TCoord;
begin
  WriteCoord.X := x;
  WriteCoord.Y := y;
  WriteConsoleOutputAttribute(StdOut, @attr, 1, WriteCoord, NumWritten);
end;

function RPWhereXY: SmallWord;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPWhereXY := CSBI.dwCursorPosition.x + (CSBI.dwCursorPosition.y SHL 8);
end;
{$ENDIF}


{$IFDEF WIN32}
BEGIN
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
{$ENDIF}
END.