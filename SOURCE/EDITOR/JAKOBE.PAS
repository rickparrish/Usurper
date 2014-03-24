{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
{

Copyright 2007 Jakob Dangarden

 This file is part of Usurper.

    Usurper is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    Usurper is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Usurper; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
}

unit JakobE; {Usurper Editor - Extra Routines}

interface

{Misc}
procedure Delay2(tics: word);
procedure Statbar(cnum, enum, xspot, yspot, fullcolor, emptycolor: integer);
procedure Remove_Commas(var gulp: string);
function Commastr(number: longint): string;
function CommastrP(nr: longint): string; {som ovan fast med + eller -}

 {String}
procedure CleanString(var s: string);
procedure Wrl(const s: string);
procedure ClearScreen;
function MkString(nr: integer; s: string): string;
function UpCaseStr(s3: string): string;
function EmptyStr: string;
function FindSub(const s1, s2: string): boolean; {is s1 somewhere in s2?}
function Crypt(nr: word): string; {returns a random array with length NR}
function Long2Str(Number: longint): string;

{Date}
function Packed_Date: longint;
function DateFix(const s: string): string;
function Todays_Date: string; {date string[8] american}


implementation

uses
  Dos, Crt, Init, DDscott, SwagDate;

function Todays_Date; {date string[8] american}
var
  d, m, y, dow: word;
  s, s2:        string[8];
begin;  {original code taken from the "date" function in ddscott.pas}
  getdate(y, m, d, dow);
  s := long2str(m);
  if length(s) = 1 then
    s := '0' + s;
  s2 := long2str(d);
  if length(s2) = 1 then
    s2 := '0' + s2;
  s := s + s2;
  s2 := long2str(y);
  while length(s2) < 4 do
  begin
    s2 := '0' + s2;
  end;
  s := s + s2;

     {return result}
  Todays_Date := s;
end; {todays_date}

function Packed_Date;
begin
  packed_date := swag_date;
end;

procedure ClearScreen;
begin
  clrscr;
end;


procedure CleanString(var s: string);
begin
  fillChar(s, sizeof(s), 0);
end;

function Long2Str(Number: longint): string;
var
  TempStr: string;

begin {converts longint to string}
  Str(Number, TempStr);
  Long2Str := TempStr;
end;

function EmptyStr: string;
var s: string;
begin
  { REETODO s not initialized -- this function seems stupid, can't it just do emptystr := ''? }
  { CleanString does this: fillChar(s, sizeof(s), 0); which means the fact that s is not
    initialized is not a problem -- but I still wonder what the purpose of this is?  Based on
    what CleanString does, my guess is that this created "prettier" data files, since if you
    do StringVariable := '' and then that string variable is written to a data file, you wind
    up with a NULL byte (indicating the length of the string is zero) followed by random junk
    padding out the rest of the length of the string variable, but based on what CleanString
    does I think you'll wind up with all NULL bytes padding out the rest of the length of the
    string (I could be wrong though, maybe you still wind up with random junk).  Assuming that's 
    the only difference between StringVariable := '' and  StringVariable := EmptyStr, this 
    functions seems silly! }
  cleanstring(s);
  emptystr := s;
end;


function UpCaseStr;
var i: integer;
begin
  for i := 1 to length(s3) do
    s3[i] := upcase(s3[i]);
  UpcaseStr := s3;
end;

function MkString;
var
  i:    integer;
  temp: string;

begin

  temp := '';

  for i := 1 to nr do
  begin
    temp := temp + s;
  end;

  mkstring := temp;

end;

procedure Remove_Commas;
var s: string;
  i:   integer;
begin

  s := '';
  for i := 1 to length(gulp) do
  begin
    if (gulp[i] <> ',') and (gulp[i] <> '.') then
    begin
      s := s + gulp[i];
    end;
  end;
  gulp := s;

end;

function CommaStr(Number: longint): string;
var
  StrPos:    integer;
  NumberStr: string;

begin
  NumberStr := Long2Str(Number);
  StrPos := Length(NumberStr) - 2;
  while StrPos > 1 do
  begin
    Insert(',', NumberStr, StrPos);
    StrPos := StrPos - 3;
  end;
  CommaStr := NumberStr;
end;

function CommastrP;
var s: s70;
begin

  s := commastr(nr);

  if nr > 0 then
  begin
    s := '+' + s;
  end;

  commastrP := s;

end;

function DateFix;
begin
  datefix := s[1] + s[2] + '-' + s[3] + s[4] + '-' + s[5] + s[6] + s[7] + s[8];
end;

procedure Delay2;
begin
  delay(tics);
end;

function Crypt(nr: word): string; {returns a random array with length NR}
var s: string;
  i:   byte;
begin

  s := '';
  for i := 1 to nr do
  begin
    case random(65) of
      0: s := s + 'A';
      1: s := s + 'B';
      2: s := s + 'C';
      3: s := s + 'D';
      4: s := s + 'E';
      5: s := s + 'F';
      6: s := s + 'G';
      7: s := s + 'H';
      8: s := s + 'I';
      9: s := s + 'J';
      10: s := s + 'K';
      11: s := s + 'L';
      12: s := s + 'M';
      13: s := s + 'N';
      14: s := s + 'O';
      15: s := s + 'P';
      16: s := s + 'Q';
      17: s := s + 'R';
      18: s := s + 'S';
      19: s := s + 'T';
      20: s := s + 'U';
      21: s := s + 'V';
      22: s := s + 'W';
      23: s := s + 'X';
      24: s := s + 'Y';
      25: s := s + 'Z';
      26: s := s + 'a';
      27: s := s + 'b';
      28: s := s + 'c';
      29: s := s + 'd';
      30: s := s + 'e';
      31: s := s + 'f';
      32: s := s + 'g';
      33: s := s + 'h';
      34: s := s + 'i';
      35: s := s + 'j';
      36: s := s + 'k';
      37: s := s + 'l';
      38: s := s + 'm';
      39: s := s + 'n';
      40: s := s + 'o';
      41: s := s + 'p';
      42: s := s + 'q';
      43: s := s + 'r';
      44: s := s + 's';
      45: s := s + 't';
      46: s := s + 'u';
      47: s := s + 'v';
      48: s := s + 'w';
      49: s := s + 'x';
      50: s := s + 'y';
      51: s := s + 'z';
      52: s := s + '#';
      53: s := s + '$';
      54: s := s + '%';
      55: s := s + '0';
      56: s := s + '1';
      57: s := s + '2';
      58: s := s + '3';
      59: s := s + '4';
      60: s := s + '5';
      61: s := s + '6';
      62: s := s + '7';
      63: s := s + '8';
      64: s := s + '9';
    end;
  end;

  {return result}
  crypt := s;

end;

function FindSub;
begin
  if pos(upcasestr(s1), upcasestr(s2)) > 0 then
    findsub := True
  else findsub := False;
end;

procedure Wrl(const s: string); {replacement for Writeln}
begin
  writeln(s);
end;


procedure StatBar;
  procedure Dupeit(var start: byte; x, y: byte; Str: string; Num: integer);
  var Cnt: integer;
  begin
    for Cnt := 1 to Num do
    begin
      Pupp^.writestr(start, y, Str, 1);
      Inc(start);
    end;
  end;

var
  percentage: integer;
  s:          string;
  m:          longint;
  start:      byte;
begin
  percentage := round(cnum / enum * 100 / 2);
  start := xspot;
  dupeit(start, xspot, yspot, #219, Percentage);
  dupeit(start, xspot, yspot, #177, 50 - Percentage);
  m := percentage * 2;
  str(m, s);
  s := '  ' + s + '%';
  Pupp^.writestr(start, yspot, s, 1);
end;

end.
