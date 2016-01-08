{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
unit RPPort;

interface

{$IFDEF WIN32}
  uses
    Windows;
{$ENDIF}
{$IFDEF UNIX}
  uses
    Unix;
{$ENDIF}

type
  {$IFDEF FPC}
    SmallWord = System.Word;
  {$ENDIF}
  {$IFNDEF WIN32}
    TCharInfo = packed record
      Ch:   char;
      Attr: byte;
    end;
  {$ENDIF}
  TScreenBuf = array[1..25, 1..80] of TCharInfo; // REETODO Don't hardcode to 80x25

{$IFDEF FPC}
  var
    FileModeReadWrite: Integer;
    TextModeRead: Integer;
    TextModeReadWrite: Integer;
{$ENDIF}

procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
function RPGetAttrAt(AX, AY: Byte): Byte;
function RPGetCharAt(AX, AY: Byte): Char;
procedure RPGotoXY(xy: SmallWord);
procedure RPHideCursor;
function RPLockFile(handle, start, length: longint): longint;
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
procedure RPSaveScreen(var screenBuf: TScreenBuf);
function RPScreenSizeX: word;
function RPScreenSizeY: word;
procedure RPSetAttrAt(AAttr, AX, AY: Byte);
procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
procedure RPSleep(ms: word);
procedure RPShowCursor;
function RPUnLockFile(handle, start, length: longint): longint;
function RPWhereXY: SmallWord;

implementation

{$IFDEF FPC}
  uses
    Crt, SysUtils;
{$ENDIF}
{$IFDEF VPASCAL}
  uses
    {$IFDEF OS2}OS2Base,{$ENDIF} VPUtils, VpSysLow, VpUsrLow;
{$ENDIF}

{$IFDEF GO32V2}
  var
    Screen: TScreenBuf absolute $B800:0000;
{$ENDIF}
{$IFDEF WIN32}
  var
    StdOut: THandle;
{$ENDIF}


{$IFDEF GO32V2}
procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
var
  I: Integer;
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

  { Trim to fit within 80 columns }
  if (Length(ALine) > (80 - AX + 1)) then ALine := Copy(ALine, 1, 80 - AX + 1);

  for I := 1 to Length(ALine) do
  begin
    Screen[AY, AX + (I - 1)].Ch := ALine[I];
    Screen[AY, AX + (I - 1)].Attr := AAttr;
  end;
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
begin
  SysWrtCharStrAtt(@ALine[1], Length(ALine), AX - 1, AY - 1, AAttr);
end;
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF FPC}
  procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
  var
    NeedWindow: Boolean;
    SavedAttr: Integer;
    SavedWindMinX: Integer;
    SavedWindMinY: Integer;
    SavedWindMaxX: Integer;
    SavedWindMaxY: Integer;
    SavedXY: Integer;
  begin
    { Validate parameters }
    if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

    { Trim to fit within 80 columns }
    if (Length(ALine) > (80 - AX + 1)) then ALine := Copy(ALine, 1, 80 - AX + 1);

    // Save
    NeedWindow := ((WindMinX > 1) OR (WindMinY > 1) OR (WindMaxX < 80) OR (WindmaxY < 25));
    SavedAttr := TextAttr;
    SavedWindMinX := WindMinX;
    SavedWindMinY := WindMinY;
    SavedWindMaxX := WindMaxX;
    SavedWindMaxY := WindMaxY;
    SavedXY := WhereX + (WhereY SHL 8);

    // Update
    if (NeedWindow) then Window(1, 1, 80, 25);
    GotoXY(AX, AY);
    TextAttr := AAttr;

    // Trim to fit within 79 columns if on line 25
    if ((AY = 25) AND (Length(ALine) > (79 - AX + 1))) then ALine := Copy(ALine, 1, 79 - AX + 1);

    // Output
    Write(ALine);

    // Restore
    TextAttr := SavedAttr;
    if (NeedWindow) then Window(SavedWindMinX, SavedWindMinY, SavedWindMaxX, SavedWindMaxY);
    GotoXY(SavedXY AND $00FF, (SavedXY AND $FF00) SHR 8);
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
  begin
    SysWrtCharStrAtt(@ALine[1], Length(ALine), AX - 1, AY - 1, AAttr);
  end;
  {$ENDIF}
{$ENDIF}
{$IFDEF WINDOWS}
procedure RPFastWrite(ALine: String; AX, AY, AAttr: Byte);
var
  Buffer: Array[0..255] of TCharInfo;
  BufferCoord: TCoord;
  BufferSize: TCoord;
  I: Integer;
  WriteRegion: TSmallRect;
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

  { Trim to fit within 80 columns }
  if (Length(ALine) > (80 - AX + 1)) then ALine := Copy(ALine, 1, 80 - AX + 1);

  for I := 0 to Length(ALine) - 1 do
  begin
    Buffer[I].Attributes := AAttr;
    Buffer[I].AsciiChar := ALine[I + 1];
  end;
  BufferSize.X := Length(ALine);
  BufferSize.Y := 1;
  BufferCoord.X := 0;
  BufferCoord.Y := 0;
  WriteRegion.Left := AX - 1;
  WriteRegion.Top := AY - 1;
  WriteRegion.Right := AX + Length(ALine) - 2;
  WriteRegion.Bottom := AY - 1;
  WriteConsoleOutput(StdOut, @Buffer, BufferSize, BufferCoord, WriteRegion);
end;
{$ENDIF}

{$IFDEF GO32V2}
function RPGetAttrAt(AX, AY: Byte): Byte;
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  begin
    RPGetAttrAt := 7;
    Exit;
  end;

  RPGetAttrAt := Screen[AY, AX].Attr;
end;
{$ENDIF}
{$IFDEF OS2}
function RPGetAttrAt(AX, AY: Byte): Byte;
begin
  RPGetAttrAt := SysReadAttributesAt(AX - 1, AY - 1);
end;
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF FPC}
  function RPGetAttrAt(AX, AY: Byte): Byte;
  begin
    { Validate parameters }
    if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
    begin
      RPGetAttrAt := 7;
      Exit;
    end;

    RPGetAttrAt := ConsoleBuf^[((AY - 1) * ScreenWidth) + (AX - 1)].attr;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  function RPGetAttrAt(AX, AY: Byte): Byte;
  begin
    RPGetAttrAt := SysReadAttributesAt(AX - 1, AY - 1);
  end;
  {$ENDIF}
{$ENDIF}
{$IFDEF WINDOWS}
function RPGetAttrAt(AX, AY: Byte): Byte;
var
  Attr: Word;
  Coord: TCoord;
  {$IFDEF FPC}NumRead: Cardinal;{$ENDIF}
  {$IFDEF VPASCAL}NumRead: Integer;{$ENDIF}
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  begin
    RPGetAttrAt := 7;
    Exit;
  end;

  Coord.X := AX - 1;
  Coord.Y := AY - 1;
  ReadConsoleOutputAttribute(StdOut, @Attr, 1, Coord, NumRead);
  RPGetAttrAt := Attr;
end;
{$ENDIF}

{$IFDEF GO32V2}
function RPGetCharAt(AX, AY: Byte): Char;
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  begin
    RPGetCharAt := ' ';
    Exit;
  end;

  RPGetCharAt := Screen[AY, AX].Ch;
end;
{$ENDIF}
{$IFDEF OS2}
function RPGetCharAt(AX, AY: Byte): Char;
begin
  RPGetCharAt := SysReadCharAt(AX - 1, AY - 1);
end;
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF FPC}
  function RPGetCharAt(AX, AY: Byte): Char;
  begin
    { Validate parameters }
    if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
    begin
      RPGetCharAt := ' ';
      Exit;
    end;

    RPGetCharAt := ConsoleBuf^[((AY - 1) * ScreenWidth) + (AX - 1)].ch;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  function RPGetCharAt(AX, AY: Byte): Char;
  begin
    RPGetCharAt := SysReadCharAt(AX - 1, AY - 1);
  end;
  {$ENDIF}
{$ENDIF}
{$IFDEF WINDOWS}
function RPGetCharAt(AX, AY: Byte): Char;
var
  Ch: Char;
  Coord: TCoord;
  {$IFDEF FPC}NumRead: Cardinal;{$ENDIF}
  {$IFDEF VPASCAL}NumRead: Integer;{$ENDIF}
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then
  begin
    RPGetCharAt := ' ';
    Exit;
  end;

  Coord.X := AX - 1;
  Coord.Y := AY - 1;
  ReadConsoleOutputCharacter(StdOut, @Ch, 1, Coord, NumRead);
  if (NumRead = 0) then
  begin
    RPGetCharAt := #32
  end else
  begin
    RPGetCharAt := Ch;
  end;
end;
{$ENDIF}

// REENOTE Can't to platform specific since cursor position is stored internally in VP units
procedure RPGotoXY(xy: SmallWord);
begin
  {$IFDEF VPASCAL}
    SysTVSetCurPos(xy and $00FF, xy and $FF00 shr 8);
  {$ENDIF}
  {$IFNDEF VPASCAL}
    // REETODO This doesn't work right if in a window()
    GotoXY(xy and $00FF, xy and $FF00 shr 8);
  {$ENDIF}
end;

{$IFDEF WIN32}
procedure RPHideCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := False;
  SetConsoleCursorInfo(StdOut, CCI);
end;
{$ENDIF}
{$IFNDEF WIN32}
  {$IFDEF FPC}
  procedure RPHideCursor;
  begin
    cursoroff;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  procedure RPHideCursor;
  begin
    HideCursor;
  end;
  {$ENDIF}
{$ENDIF}

function RPLockFile(handle, start, length: longint): longint;
begin
  {$IFDEF VPASCAL}
    RPLockFile := SysLockFile(handle, start, length);
  {$ENDIF}
  {$IFNDEF VPASCAL}
    {$IFDEF GO32V2}
      WriteLn('RPPORT RPPORT RPLockFile'); Halt;
    {$ENDIF}
    {$IFDEF UNIX}
      RPLockFile := fpFlock(handle, LOCK_EX);
    {$ENDIF}
    {$IFDEF WIN32}
      if (Windows.LockFile(handle, start, 0, length, 0)) then
      begin
        RPLockFile := 0;
      end else
      begin
        RPLockFile := GetLastError;
      end;
    {$ENDIF}
  {$ENDIF}
end;

{ REETODO Should detect screen size }
{$IFDEF WIN32}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  BufSize:  TCoord;
  WritePos: TCoord;
  DestRect: TSmallRect;
begin
  // REETODO Don't hardcode to 80x25
  BufSize.X := 80;
  BufSize.Y := 25;
  WritePos.X := 0;
  WritePos.Y := 0;
  DestRect.Left := 0;
  DestRect.Top := 0;
  DestRect.Right := 79;
  DestRect.Bottom := 24;
  WriteConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), @screenBuf[1][1], BufSize, WritePos, DestRect);
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  Size: SmallWord;
begin
  Size := SizeOf(TScreenBuf);
  VioWrtCellStr(@screenBuf, Size, 0, 0, 0);
end;
{$ENDIF}
{$IFDEF UNIX}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  X, Y: integer;
begin
  // REETODO Don't hardcode to 80x25
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      RPFastWrite(screenBuf[Y][X].Ch, X, Y, screenBuf[Y][X].Attr);
    end;
  end;
end;
{$ENDIF}
{$IFDEF GO32V2}
procedure RPRestoreScreen(var screenBuf: TScreenBuf);
var
  X, Y: integer;
begin
  // REETODO Don't hardcode to 80x25
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      RPFastWrite(screenBuf[Y][X].Ch, X, Y, screenBuf[Y][X].Attr);
    end;
  end;
end;
{$ENDIF}

{ REETODO Should detect screen size }
{$IFDEF WIN32}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  BufSize:    TCoord;
  ReadPos:    TCoord;
  SourceRect: TSmallRect;
begin
  // REETODO Don't hardcode to 80x25
  BufSize.X := 80;
  BufSize.Y := 25;
  ReadPos.X := 0;
  ReadPos.Y := 0;
  SourceRect.Left := 0;
  SourceRect.Top := 0;
  SourceRect.Right := 79;
  SourceRect.Bottom := 24;
  ReadConsoleOutput(GetStdHandle(STD_OUTPUT_HANDLE), @screenBuf[1][1], BufSize, ReadPos, SourceRect);
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  Size: SmallWord;
begin
  Size := SizeOf(TScreenBuf);
  VioReadCellStr(screenBuf, Size, 0, 0, 0);
end;
{$ENDIF}
{$IFDEF UNIX}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  X, Y: integer;
begin
  {$IFDEF VPASCAL}
    Move(SysTVGetSrcBuf^, screenBuf, SizeOf(TScreenBuf));
  {$ENDIF}
  {$IFNDEF VPASCAL}
    for Y := 1 to 25 do
    begin
      for X := 1 to 80 do
      begin
        screenBuf[Y][X].Ch := RPGetCharAt(X, Y);
        screenBuf[Y][X].Attr := RPGetAttrAt(X, Y);
      end;
    end;
  {$ENDIF}
end;
{$ENDIF}
{$IFDEF GO32V2}
procedure RPSaveScreen(var screenBuf: TScreenBuf);
var
  X, Y: integer;
begin
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      screenBuf[Y][X].Ch := RPGetCharAt(X, Y);
      screenBuf[Y][X].Attr := RPGetAttrAt(X, Y);
    end;
  end;
end;
{$ENDIF}

{$IFDEF WIN32}
function RPScreenSizeX: word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeX := CSBI.srWindow.Right - CSBI.srWindow.Left + 1;
end;
{$ENDIF}
{$IFNDEF WIN32}
  {$IFDEF FPC}
  function RPScreenSizeX: word;
  begin
    RPScreenSizeX := ScreenWidth;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  function RPScreenSizeX: word;
  var
    Size: TSysPoint;
  begin
    SysTVGetScrMode(@Size, False);
    RPScreenSizeX := Size.X;
  end;
  {$ENDIF}
{$ENDIF}

{$IFDEF WIN32}
function RPScreenSizeY: word;
var
  CSBI: TConsoleScreenBufferInfo;
begin
  GetConsoleScreenBufferInfo(StdOut, CSBI);
  RPScreenSizeY := CSBI.srWindow.Bottom - CSBI.srWindow.Top + 1;
end;
{$ENDIF}
{$IFNDEF WIN32}
  {$IFDEF FPC}
  function RPScreenSizeY: word;
  begin
    RPScreenSizeY := ScreenHeight;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
    function RPScreenSizeY: word;
    var
      Size: TSysPoint;
    begin
      SysTVGetScrMode(@Size, False);
      RPScreenSizeY := Size.Y;
    end;
  {$ENDIF}
{$ENDIF}

{$IFDEF GO32V2}
procedure RPSetAttrAt(AAttr, AX, AY: Byte);
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

  Screen[AY, AX].Attr := AAttr;
end;
{$ENDIF}
{$IFDEF WIN32}
procedure RPSetAttrAt(AAttr, AX, AY: Byte);
var
  NumWritten: longint;
  WriteCoord: TCoord;
begin
  WriteCoord.X := AX - 1;
  WriteCoord.Y := AY - 1;
  WriteConsoleOutputAttribute(StdOut, @AAttr, 1, WriteCoord, NumWritten);
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPSetAttrAt(AAttr, AX, AY: Byte);
var
  Ch: char;
begin
  Ch := SysReadCharAt(AX - 1, AY - 1);
  SysWrtCharStrAtt(@Ch, 1, AX - 1, AY - 1, AAttr);
end;
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF FPC}
  procedure RPSetAttrAt(AAttr, AX, AY: Byte);
  var
    NeedWindow: Boolean;
    SavedAttr: Integer;
    SavedWindMinX: Integer;
    SavedWindMinY: Integer;
    SavedWindMaxX: Integer;
    SavedWindMaxY: Integer;
    SavedXY: Integer;
  begin
    { Validate parameters }
    if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

    // Save
    NeedWindow := ((WindMinX > 1) OR (WindMinY > 1) OR (WindMaxX < 80) OR (WindmaxY < 25));
    SavedAttr := TextAttr;
    SavedWindMinX := WindMinX;
    SavedWindMinY := WindMinY;
    SavedWindMaxX := WindMaxX;
    SavedWindMaxY := WindMaxY;
    SavedXY := WhereX + (WhereY SHL 8);

    // Update
    if (NeedWindow) then Window(1, 1, 80, 25);
    GotoXY(AX, AY);
    TextAttr := AAttr;

    // Output
    Write(RPGetCharAt(AX, AY));

    // Restore
    TextAttr := SavedAttr;
    if (NeedWindow) then Window(SavedWindMinX, SavedWindMinY, SavedWindMaxX, SavedWindMaxY);
    GotoXY(SavedXY AND $00FF, (SavedXY AND $FF00) SHR 8);
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  procedure RPSetAttrAt(AAttr, AX, AY: Byte);
  var
    Ch: char;
  begin
    Ch := SysReadCharAt(AX - 1, AY - 1);
    SysWrtCharStrAtt(@Ch, 1, AX - 1, AY - 1, AAttr);
  end;
  {$ENDIF}
{$ENDIF}

{$IFDEF GO32V2}
procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

  Screen[AY, AX].Ch := ACh;
end;
{$ENDIF}
{$IFDEF OS2}
procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
var
  Attr: byte;
begin
  Attr := SysReadAttributesAt(AX - 1, AY - 1);
  SysWrtCharStrAtt(@ACh, 1, AX - 1, AY - 1, Attr);
end;
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF FPC}
  procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
  var
    NeedWindow: Boolean;
    SavedAttr: Integer;
    SavedWindMinX: Integer;
    SavedWindMinY: Integer;
    SavedWindMaxX: Integer;
    SavedWindMaxY: Integer;
    SavedXY: Integer;
  begin
    { Validate parameters }
    if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

    // Save
    NeedWindow := ((WindMinX > 1) OR (WindMinY > 1) OR (WindMaxX < 80) OR (WindmaxY < 25));
    SavedAttr := TextAttr;
    SavedWindMinX := WindMinX;
    SavedWindMinY := WindMinY;
    SavedWindMaxX := WindMaxX;
    SavedWindMaxY := WindMaxY;
    SavedXY := WhereX + (WhereY SHL 8);

    // Update
    if (NeedWindow) then Window(1, 1, 80, 25);
    GotoXY(AX, AY);
    TextAttr := RPGetAttrAt(AX, AY);

    // Output
    Write(ACh);

    // Restore
    TextAttr := SavedAttr;
    if (NeedWindow) then Window(SavedWindMinX, SavedWindMinY, SavedWindMaxX, SavedWindMaxY);
    GotoXY(SavedXY AND $00FF, (SavedXY AND $FF00) SHR 8);
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
  var
    Attr: byte;
  begin
    Attr := SysReadAttributesAt(AX - 1, AY - 1);
    SysWrtCharStrAtt(@ACh, 1, AX - 1, AY - 1, Attr);
  end;
  {$ENDIF}
{$ENDIF}
{$IFDEF WINDOWS}
procedure RPSetCharAt(ACh: Char; AX, AY: Byte);
var
  WriteCoord: TCoord;
  {$IFDEF FPC}NumWritten: Cardinal;{$ENDIF}
  {$IFDEF VPASCAL}NumWritten: Integer;{$ENDIF}
begin
  { Validate parameters }
  if ((AX < 1) OR (AX > 80) OR (AY < 1) OR (AY > 25)) then Exit;

  WriteCoord.X := AX - 1;
  WriteCoord.Y := AY - 1;
  WriteConsoleOutputCharacter(StdOut, @ACh, 1, WriteCoord, NumWritten);
end;
{$ENDIF}

{$IFDEF WIN32}
procedure RPShowCursor;
var
  CCI: TConsoleCursorInfo;
begin
  GetConsoleCursorInfo(StdOut, CCI);
  CCI.bVisible := True;
  SetConsoleCursorInfo(StdOut, CCI);
end;
{$ENDIF}
{$IFNDEF WIN32}
  {$IFDEF FPC}
  procedure RPShowCursor;
  begin
    cursoron;
  end;
  {$ENDIF}
  {$IFDEF VPASCAL}
  procedure RPShowCursor;
  begin
    ShowCursor;
  end;
  {$ENDIF}
{$ENDIF}

procedure RPSleep(ms: word);
begin
  {$IFDEF VPASCAL}
    SysCtrlSleep(ms);
  {$ENDIF}
  {$IFNDEF VPASCAL}
    Sleep(ms);
  {$ENDIF}
end;

function RPUnLockFile(handle, start, length: longint): longint;
begin
  {$IFDEF VPASCAL}
    RPUnLockFile := SysUnLockFile(handle, start, length);
  {$ENDIF}
  {$IFNDEF VPASCAL}
    {$IFDEF GO32V2}
      WriteLn('RPPORT RPPORT RPUnLockFile'); Halt;
    {$ENDIF}
    {$IFDEF UNIX}
      RPUnLockFile := fpFlock(handle, LOCK_UN);
    {$ENDIF}
    {$IFDEF WIN32}
      if (Windows.UnLockFile(handle, start, 0, length, 0)) then
      begin
        RPUnLockFile := 0;
      end else
      begin
        RPUnLockFile := GetLastError;
      end;
    {$ENDIF}
  {$ENDIF}
end;

// REENOTE Can't to platform specific since cursor position is stored internally in VP units
function RPWhereXY: SmallWord;
var
  X, Y: SmallWord;
begin
  {$IFDEF VPASCAL}
    SysGetCurPos(X, Y);
  {$ENDIF}
  {$IFNDEF VPASCAL}
    // REETODO This doesn't work right if in a window()
    X := WhereX;
    Y := WhereY;
  {$ENDIF}
  RPWhereXY := X + (Y shl 8);
end;

begin
{$IFDEF WIN32}
  StdOut := GetStdHandle(STD_OUTPUT_HANDLE);
{$ENDIF}
{$IFDEF UNIX}
  {$IFDEF VPASCAL}
    SysTVSetScrMode($FB); { $FB = COL2 = Color, graphics chars }
  {$ENDIF}
{$ENDIF}
end.
