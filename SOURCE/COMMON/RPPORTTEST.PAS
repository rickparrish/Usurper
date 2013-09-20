program RPPortTest;

uses
  Crt, RPPort, VpSysLow;

  procedure PauseOrQuit;
  var
    Ch: char;
  begin
    WriteLn('Hit a key to continue or Q to quit');
    Ch := ReadKey;
    if (UpCase(Ch) = 'Q') then Halt;
  end;

var
  Attr:        byte;
  Ch:          char;
  X, Y, XY:    SmallWord;
  SavedScreen: TScreenBuf;
begin
  TextAttr := 7;

  ClrScr;
  WriteLn('Test #1: RPGotoXY and RPWhereXY');
  XY := RPWhereXY;
  WriteLn;
  WriteLn('  This line should be the second line');
  RPGotoXY(XY);
  WriteLn('  This line should be the first line');
  WriteLn;
  PauseOrQuit;

  ClrScr;
  WriteLn('Test #2: RPHideCursor and RPShowCursor');
  WriteLn('  Cursor should be showing by default');
  PauseOrQuit;
  WriteLn('  Cursor should now be hidden');
  RPHideCursor;
  PauseOrQuit;
  WriteLn('  Cursor should be showing again');
  RPShowCursor;
  PauseOrQuit;

  ClrScr;
  WriteLn('Test #3: RPRestoreScreen and RPSaveScreen');
  WriteLn('  Hit a key to fill the screen with a specific pattern');
  WriteLn('  Then hit it again to fill it with a random pattern');
  WriteLn('  Then hit it one more time to restore the specific pattern');
  PauseOrQuit;
  ClrScr;
  Attr := 31;
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      XY := (X - 1) + ((Y - 1) * 80);
      Ch := Chr(65 + (XY mod 26));
      SysWrtCharStrAtt(@Ch, 1, X - 1, Y - 1, Attr);
    end;
  end;
  RPSaveScreen(SavedScreen);
  ReadKey;
  ClrScr;
  Attr := 7;
  for Y := 1 to 25 do
  begin
    for X := 1 to 80 do
    begin
      Ch := Chr(65 + Random(26));
      SysWrtCharStrAtt(@Ch, 1, X - 1, Y - 1, Attr);
    end;
  end;
  ReadKey;
  RPRestoreScreen(SavedScreen);
  GotoXY(1, 24);
  PauseOrQuit;

  ClrScr;
  WriteLn('Test #4: RPScreenSizeX and RPScreenSizeY');
  WriteLn('  X Size: ', RPScreenSizeX);
  WriteLn('  Y Size: ', RPScreenSizeY);
  PauseOrQuit;

  WriteLn;
  WriteLn('Test #5: RPSetAttrAt and RPSleep');
  WriteLn('  The "X Size" text above should slowly become white on blue');
  RPSleep(500);
  RPSetAttrAt(2, 1, 31);
  RPSleep(500);
  RPSetAttrAt(3, 1, 31);
  RPSleep(500);
  RPSetAttrAt(4, 1, 31);
  RPSleep(500);
  RPSetAttrAt(5, 1, 31);
  RPSleep(500);
  RPSetAttrAt(6, 1, 31);
  RPSleep(500);
  RPSetAttrAt(7, 1, 31);
  PauseOrQuit;
end.
