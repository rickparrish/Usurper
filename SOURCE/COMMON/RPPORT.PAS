{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit RPPort;

interface

{$IFDEF WIN32}
uses
  Windows;
{$ENDIF}

type
{$IFNDEF WIN32}
  TCharInfo = packed record
    Ch: Char;
    Attr: Byte;
  end;
{$ENDIF}
  TScreenBuf = Array[1..25, 1..80] of TCharInfo; // REETODO Don't hardcode to 80x25

procedure RPGotoXY(xy: Word);
procedure RPHideCursor;
function  RPLockFile(handle, start, length: LongInt): LongInt;
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
procedure RPSaveScreen(var screenBuf: TScreenBuf);
function  RPScreenSizeX: Word;
function  RPScreenSizeY: Word;
procedure RPSetAttrAt(x, y: Word; attr: Byte);
procedure RPSleep(ms: Word);
procedure RPShowCursor;
function  RPUnLockFile(handle, start, length: LongInt): LongInt;
function  RPWhereXY: Word;

implementation

{$IFDEF VPASCAL}
uses
  {$IFDEF OS2}OS2Base,{$ENDIF} VPUtils, VpSysLow, VpUsrLow;
{$ENDIF}
{$IFNDEF VPASCAL}
uses
  Crt;
{$ENDIF}

{$IFDEF WIN32}
var
  StdOut: THandle;
{$ENDIF}
  
// REENOTE Can't to platform specific since cursor position is stored internally in VP units
procedure RPGotoXY(xy: Word);
begin
{$IFDEF VPASCAL}
  SysTVSetCurPos(xy AND $00FF, xy AND $FF00 SHR 8);
{$ENDIF}
{$IFNDEF VPASCAL}
  // REETODO values are offset by Window()
  GotoXY(xy AND $00FF, xy AND $FF00 SHR 8);
{$ENDIF}
end;

{$IFDEF WIN32}
procedure RPHideCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := false;
  SetConsoleCursorInfo(StdOut, CCI);
end;
{$ENDIF}
{$IFNDEF WIN32}
procedure RPHideCursor;
begin
  HideCursor;
end;
{$ENDIF}

function  RPLockFile(handle, start, length: LongInt): LongInt;
begin
{$IFDEF VPASCAL}
  RPLockFile := SysLockFile(handle, start, length);
{$ENDIF}
{$IFNDEF VPASCAL}
  WriteLn('REETODO RPPort RPLockFile'); Halt;
{$ENDIF}
end;

{ REETODO Should detect screen size }
{$IFDEF WIN32}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  WritePos   : TCoord;
  DestRect   : TSmallRect;
begin
  // REETODO Don't hardcode to 80x25
  BufSize.X       := 80;
  BufSize.Y       := 25;
  WritePos.X      := 0;
  WritePos.Y      := 0;
  DestRect.Left   := 0;
  DestRect.Top    := 0;
  DestRect.Right  := 79;
  DestRect.Bottom := 24;
  WriteConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), @screenBuf[1][1], BufSize, WritePos, DestRect);
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  Size: Word;
begin
  Size := SizeOf(TScreenBuf);
  VioWrtCellStr(@screenBuf, Size, 0, 0, 0);
end;
{$ENDIF}
{$IFDEF LINUX}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  X, Y: Integer;
begin
  // REETODO Don't hardcode to 80x25
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      SysWrtCharStrAtt(@screenBuf[Y][X].Ch, 1, X - 1, Y - 1, screenBuf[Y][X].Attr);
    end;
  end;
end;
{$ENDIF}

{ REETODO Should detect screen size }
{$IFDEF WIN32}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  BufSize    : TCoord;
  ReadPos    : TCoord;
  SourceRect : TSmallRect;
begin
  // REETODO Don't hardcode to 80x25
  BufSize.X         := 80;
  BufSize.Y         := 25;
  ReadPos.X         := 0;
  ReadPos.Y         := 0;
  SourceRect.Left   := 0;
  SourceRect.Top    := 0;
  SourceRect.Right  := 79;
  SourceRect.Bottom := 24;
  ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), @screenBuf[1][1], BufSize, ReadPos, SourceRect);
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  Size: Word;
begin
  Size := SizeOf(TScreenBuf);
  VioReadCellStr(screenBuf, Size, 0, 0, 0);
end;
{$ENDIF}
{$IFDEF LINUX}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
begin
  Move(SysTVGetSrcBuf^, screenBuf, SizeOf(TScreenBuf));
end;
{$ENDIF}

{$IFDEF WIN32}
function  RPScreenSizeX: Word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeX := CSBI.srWindow.Right - CSBI.srWindow.Left + 1;
end;
{$ENDIF}
{$IFNDEF WIN32}
function  RPScreenSizeX: Word;
var
  Size: TSysPoint;
begin
  SysTVGetScrMode(@Size, False);
  RPScreenSizeX := Size.X;
end;
{$ENDIF}

{$IFDEF WIN32}
function  RPScreenSizeY: Word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeY := CSBI.srWindow.Bottom - CSBI.srWindow.Top + 1;
end;
{$ENDIF}
{$IFNDEF WIN32}
function  RPScreenSizeY: Word;
var
  Size: TSysPoint;
begin
  SysTVGetScrMode(@Size, False);
  RPScreenSizeY := Size.Y;
end;
{$ENDIF}

{$IFDEF WIN32}
procedure RPSetAttrAt(x, y: Word; attr: Byte);
var
{$IFDEF VPASCAL}
  NumWritten: Longint;
{$ENDIF}
{$IFNDEF VPASCAL}
  NumWritten: LongWord;
{$ENDIF}

  WriteCoord: TCoord;
begin
  WriteCoord.X := x;
  WriteCoord.Y := y;
  WriteConsoleOutputAttribute(StdOut, @attr, 1, WriteCoord, NumWritten);
end;
{$ENDIF}
{$IFNDEF WIN32}
procedure RPSetAttrAt(x, y: Word; attr: Byte);
var
  Ch: Char;
begin
  Ch := SysReadCharAt(x, y);
  SysWrtCharStrAtt(@Ch, 1, x, y, attr);
end;
{$ENDIF}

{$IFDEF WIN32}
procedure RPShowCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := true;
  SetConsoleCursorInfo(StdOut, CCI);
end;
{$ENDIF}
{$IFNDEF WIN32}
procedure RPShowCursor;
begin
  ShowCursor;
end;
{$ENDIF}

procedure RPSleep(ms: Word);
begin
{$IFDEF VPASCAL}
  SysCtrlSleep(ms);
{$ENDIF}
{$IFNDEF VPASCAL}
  WriteLn('REETODO RPPort RPSleep'); Halt;
{$ENDIF}
end;

function  RPUnLockFile(handle, start, length: LongInt): LongInt;
begin
{$IFDEF VPASCAL}
  RPUnLockFile := SysUnLockFile(handle, start, length);
{$ENDIF}
{$IFNDEF VPASCAL}
  WriteLn('REETODO RPPort RPUnLockFile'); Halt;
{$ENDIF}
end;

// REENOTE Can't to platform specific since cursor position is stored internally in VP units
function RPWhereXY: Word;
var
  X, Y: Word;
begin
{$IFDEF VPASCAL}
  SysGetCurPos(X, Y);
{$ENDIF}
{$IFNDEF VPASCAL}
  // REETODO values are offset by Window()
  X := WhereX;
  Y := WhereY;
{$ENDIF}
  RPWhereXY := X + (Y SHL 8);
end;

begin
{$IFDEF WIN32}  
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
{$ENDIF}  
{$IFDEF LINUX}
  SysTVSetScrMode($FB); { $FB = COL2 = Color, graphics chars }
{$ENDIF}
end.
