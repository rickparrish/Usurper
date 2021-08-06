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



unit Jakob;

{Usurper - Basic Door Routines Using DDPLUS door driver
             routines.

             if you plan on switching door driver, some of these
             routines will require modifying}
{$F+}
interface

const global_place: byte = 0; {see spin_cursor}

 {Uses Init;}

 {string}
procedure Remove_Commas(var gulp: string);
procedure AddBackSlash(var inpath: string);
function LeadingZero(w: word): string;
function striplead(st: string; ch: char): string;
function WithBackSlash(inpath: string): string;
function padright(const st: string; ch: char; l: integer): string;
function Str_to_Nr(const s: string): longint; {string to number}
function Str_to_Real(const s: string): real;  {string to number}
function CommaStr(Number: longint): string;
function Long2Str(Number: longint): string;
function MkString(nr: integer; const s: string): string;
function Cool_string(lngth: integer; char1, char2: char; col1, col2: integer): string;
function Ljust(const s: string; max: integer): string;
function Rjust(const s: string; max: integer): string;
function UpCaseStr(s: string): string;
function FindSub(const s1, s2: string): boolean; {is s1 somewhere in s2?}
function EmptyStr: string; {returns an empty string}
function Replace_String(Source: string; const old, new: string): string;
function LowerCase(const s: string): string; {converts a string to lower case}
function IntToHex(num: longint; digits: byte): string;
function IntToStr(Num: longint): string;
function Percent_String(num1, num2: integer): string;

{cursor}
procedure Spin_Cursor(action, cursor_color: byte);

{input routines}
procedure Get_StringW(var s: string; maxlength: integer);
procedure Get_StringDefault(var default: string; maxlength: byte);
function Get_StringSec(maxlength: integer; ch: char): string;
function Get_String(maxlength: byte): string;

{numbers}
function Get_Number_Old(rmin, rmax: longint): longint; {old routine}
function Get_Number2(rmin, rmax, default: longint): longint;
function Get_Number(rmin, rmax: longint): longint;

{date}
function Packed_Date: longint;
function Todays_Date: string;
function Todays_Time: string;
function Fix_Date(const s: string): string;
function Days_Between(const stream1, stream2: string): longint;
{time}
function Give_Me_Time: string;
function Hours_Between(const time1, time2: string): integer;
function Minutes_Between(const time1, time2: string): longint;
 {file stamp info...see file_io.pas}

 {display}
procedure Wrl(col: byte; const s: string); {replaces crt; writeln}
procedure Wr(col: byte; const s: string);  {replaces crt; write}
procedure D(col: byte; const Text: string); {display a string of text with crlf at the end}
procedure SD(col: byte; const Text: string); {same as D, but without a crlf at the end}
procedure SSwrite(const s: string); {call to DDplus SWRITE proc}
procedure SSwriteC(const c: char); {call to DDplus SWRITEC}
procedure Display_Text(const Name: string);
procedure Crlf; {provides a Line Feed/Return on both local and remote screen}
procedure ClearScreen; {clears the screen on both local and remote side}
procedure Pause; {pause prompt}
function ScreenRows: byte;
function ScreenCols: byte;

{Ansi Colors/Usurper control codes}
function ConvertToAnsi(incolor: byte): string;
function ConvertToUsurperAnsi(incolor: string): string;
function ConvertToUsurperAnsi2(incolor: string): byte;
function ConvertToUsurperAnsi3(incolor: byte): string;
function Valid_Color(const incolor: string): boolean;
function Strip(const out: string): string; {remove all Usurper ansi}
function Uconv(const out: string): string; {Usurper ANSI -> standard ANSI}

 {menu}
procedure Show_Usurper_Data(const Name: string; pausing: boolean);
procedure Menu(const Text: string);
procedure Menu2(const Text: string);
procedure Menu3(const Text: string; pos: integer);
procedure Menu5(const Text: string; pos: integer);
function Menu_Choices(const m1, m2, m3, m4, m5: string): char;

 {Other routines}
function HeapHandler(Size: word): integer; far; {handles heap errors}
procedure My_TimeSlice; {release a time slice}
procedure Normal_Exit; {HALT the program}
procedure Delay2(const milliSeconds: longint);
function UKeyPressed: boolean; {same as pascal KeyPressed function}
function GetChar: char; {get a character from local or remote keyboard}
function UnderScore: char; {returns a '_'}
function HeartSign: char; {returns a ''}
function DeathSign: char; {returns a ''}
function Confirm(const Text: string; default: char): boolean; {Y/N confirmation}
function Confirm2(const Text: string; default: char): char; {Y/N/= confirmation}

 {Misc}
procedure Display_Bar_Status(force: boolean); {call to DDplus Display_Status (bar) proc}
function Dos_Version: word;
function Is_Share: boolean; {uses netfilep.pas shareinst function}
(*REENOTE UNUSED function Jake_Tasker: byte; {call to DDScott proc}*)
function Param_Hunt(const h: string): boolean; {checking for Command Line parameters}

implementation

uses
  DDPlus,
  Dos, Crt, Init,
  Exec, AnsiColr, SwagDate,
  Various, NetFilep, DispText,
  Online, File_IO {$IFNDEF MSDOS}, RPPort{$ENDIF};

var carriage_return: boolean; {used by D and SD procedures (display routines)}


function percent_string(num1, num2: integer): string;
var {originally from SWAG/MATH (calc_p1)}
  z:    real;
  out1: string[10];
begin

  out1 := '  0';
  if (num1 = 0) or (num2 = 0) then
  begin

  end else
  begin
    z := num1 / num2;
    str(z: 2: 2, out1);
    if out1 = '1.00' then
    begin
      out1 := '100';
      percent_string := out1;
      exit;
    end;
    Delete(out1, 1, 2);
    if out1[1] = '0' then
      Delete(out1, 1, 1);
    while length(out1) <= 2 do
      insert(' ', out1, 1);
    if out1 = '0' then
      out1 := '100';
    if out1 = '' then
      out1 := '0';
  end;
  percent_string := out1;

end; {percent_string *end*}

function Long2Str(Number: longint): string;
var
  TempStr: string;

begin {converts longint to string}
  Str(Number, TempStr);
  Long2Str := TempStr;
end;

function CommaStr(Number: longint): string;
var {converts longint to string + commas 1,000 or 10,000,000}
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
end; {commastr *end*}

function Str_To_Nr(const s: string): longint;
var y: integer;
  i:   longint;
begin

  val(s, i, y);

  if y <> 0 then
  begin
    str_to_nr := 0;
  end else
  begin
    str_to_nr := i;
  end;

end;

function Str_To_Nr2(const s: string): longint;
{same as str_to_nr2 with the exception that if an error is encountered
 the routine returns -1 instead of 0}
var y: integer;
  i:   longint;
begin

  val(s, i, y);

  if y <> 0 then
  begin
    str_to_nr2 := -1;
  end else
  begin
    str_to_nr2 := i;
  end;

end; {Str_To_Nr2 *end*}

function Str_To_Real(const s: string): real;
var y: integer;
  i:   real;
begin

  val(s, i, y);

  if y <> 0 then
  begin
    str_to_real := 0;
  end else
  begin
    str_to_real := i;
  end;

end;


function Dos_Version: word;
begin
  dos_version := dosVersion; {Bp DosUnit function}
end;

function Is_Share: boolean; {is share installed?}
  {uses shareinst function from netfilep.pas}
begin
  is_share := shareinst;
end;

function Hours_Between(const time1, time2: string): integer;
var s:          s70;
  Result:       integer;
  hour1, hour2: byte;
begin {calculates passed hours between ??:??:?? and ??:??:??}
      {result=time1-time2}

  s := time1[1] + time1[2];
  hour1 := str_to_nr(s);

  s := time2[1] + time2[2];
  hour2 := str_to_nr(s);

  Result := hour1 - hour2;

  {return result}
  hours_between := Result;

end; {hours_between *end*}

function Minutes_Between(const time1, time2: string): longint;
var s:           s70;
  hours, Result: longint;
  minutes1, minutes2: byte;
begin {calculates passed minutes between ??:??:?? and ??:??:??}
      {result=time1-time2}

  s := time1[4] + time1[5];
  minutes1 := str_to_nr(s);

  s := time2[4] + time2[5];
  minutes2 := str_to_nr(s);

  Result := minutes1 - minutes2;

  {are there hours to add?}
  hours := hours_between(time1, time2);
  if hours > 0 then
  begin
    hours := hours * 60;
    Result := Result + hours;
  end;

  {return result}
  minutes_between := Result;

end; {minutes_between *end*}

function days_between(const stream1, stream2: string): longint;
var {from SWAG (a pascal library) => date/time routines => Michael Hoenie}
    {stream1,stream2 can have the 'mm-dd-yy' or 'mm-dd-yyyy' format}
    {jakob has made two changes in the code. see 'jakob' comments in source.}
  internal1, internal2: longint;
  JNUM: real;
  cd, month, day, year: integer;
  out:  string[25];

  function Jul(mo, da, yr: integer): real;
  var
    i, j, k, j2, ju: real;
  begin
    i := yr;  j := mo;  k := da;
    j2 := int((j - 14) / 12);
    ju := k - 32075 + int(1461 * (i + 4800 + j2) / 4);
    ju := ju + int(367 * (j - 2 - j2 * 12) / 12);
    ju := ju - int(3 * int((i + 4900 + j2) / 100) / 4);
    Jul := ju;
  end;

begin

  out := copy(stream1, 1, 2);
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, month, cd);
  out := copy(stream1, 4, 2);
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, day, cd);
  out := copy(stream1, 7, 4); {jakob, original code is stream1,7,2) }
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, year, cd);
  jnum := jul(month, day, year);
  str(jnum: 10: 0, out);
  val(out, internal1, cd);
  out := copy(stream2, 1, 2);
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, month, cd);
  out := copy(stream2, 4, 2);
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, day, cd);
  out := copy(stream2, 7, 4); {jakob, original code is stream1,7,2) }
  if copy(out, 1, 1) = '0' then
    Delete(out, 1, 1);
  val(out, year, cd);
  jnum := jul(month, day, year);
  str(jnum: 10: 0, out);
  val(out, internal2, cd);

  {return result}
  days_between := internal1 - internal2;

end; {days_between *end*}

procedure CleanString(var s: string);
begin
  fillChar(s, sizeof(s), 0);
end;

function EmptyStr: string;
var s: string;
begin
  s := ''; { Make FPC warning about s not being initialized go away }
  cleanstring(s);
  emptystr := s;
end;

function LowerCase(const s: string): string;
var i: integer;
  t:   string;
begin

  t := '';
  for i := 1 to length(s) do
  begin
    t := t + locase(s[i]);
  end;

  lowercase := t;
end;

function Replace_String;
var p: integer;
begin

  while POS(Old, Source) <> 0 do
  begin
    p := POS(Old, Source);
    Delete(Source, p, length(Old));
    insert(New, Source, p);
  end;
  Replace_String := Source;

end; { Replace String }

{$IFDEF MSDOS}
procedure Delay2;
const
  TicsPerDay = 1573040;      {Assumes 18.20648 tics/sec}
var
  BiosTics:   ^longint;
  DelayTics:  longint;
  ExpireTics: longint;
  StartTics:  longint;
begin
  BiosTics := Ptr($40, $6C);
  StartTics := BiosTics^;

  { Convert milliseconds to number of tics to delay for }
  DelayTics := milliSeconds div 55;
  if (DelayTics <= 0) then
    Exit;
  if (DelayTics > TicsPerDay) then
    DelayTics := TicsPerDay;

  ExpireTics := StartTics + DelayTics;

  while (True) do
  begin
    { Don't use 100% CPU }
    releasetimeslice;

    {Check normal expiration}
    if (BiosTics^ > ExpireTics) then
      Break;

    {Check wrapped expiration}
    if (BiosTics^ < StartTics) and ((BiosTics^ + TicsPerDay) > ExpireTics) then
      Break;
  end;
end;

{$ENDIF}
{$IFNDEF MSDOS}
procedure Delay2;
begin
  RPSleep(milliSeconds);
end;

{$ENDIF}

function GetChar; {get a character from the local or remote keyboard}
var temp: char;
begin

  {init}
  temp := ' ';

  {read keyboard}
  sread_char(temp); {ddplus function}

  {return the result}
  getchar := upcase(temp);

end; {getchar *end*}

procedure Wrl(col: byte; const s: string); {replacement for crt Writeln}
begin
  TextColor(col);
  writeln(s);
end; {wrl *end*}

procedure Wr(col: byte; const s: string); {replacement for crt Write}
begin
  TextColor(col);
  Write(s);
end;


procedure D; {displays the string TEXT to the screen. this routine
              accepts usurpers own ANSI control codes.}
var i: word;
  fore_col, back_col: byte;

  p:   string[3];
begin

  if (global_cfor <> col) and (global_ansi) then
  begin

    if global_carrierdropped then
    begin
      Write('');
    end else
    begin
      global_cfor := col;
      set_foreground(col);
      sswrite('');
    end;
  end;

  if Text = '' then
  begin
    if carriage_return = True then
    begin
      crlf;
    end;
    exit;
  end;

  i := 1;
  back_col := global_cback;
  repeat
    case Text[i] of
      acc: begin

        {get first/next three characters from string}
        p := Text[i] + Text[i + 1] + Text[i + 2];

        if p = ublack then
          fore_col := 0
        else
        if p = ublue then
          fore_col := 1
        else
        if p = ugreen then
          fore_col := 2
        else
        if p = ucyan then
          fore_col := 3
        else
        if p = ured then
          fore_col := 4
        else
        if p = umag then
          fore_col := 5
        else
        if p = ubrown then
          fore_col := 6
        else
        if p = ulgray then
          fore_col := 7
        else
        if p = udgray then
          fore_col := 8
        else
        if p = ulblue then
          fore_col := 9
        else
        if p = ulgreen then
          fore_col := 10
        else
        if p = ulcyan then
          fore_col := 11
        else
        if p = ulred then
          fore_col := 12
        else
        if p = ulmag then
          fore_col := 13
        else
        if p = uyellow then
          fore_col := 14
        else
        if p = uwhite then
          fore_col := 15

        else
        if p = backUblack then
          back_col := 0
        else
        if p = backUblue then
          back_col := 1
        else
        if p = BackUGreen then
          back_col := 2
        else
        if p = BackUCyan then
          back_col := 3
        else
        if p = BackURed then
          back_col := 4
        else
        if p = BackUMagenta then
          back_col := 5
        else
        if p = BackUBrown then
          back_col := 6
        else
        if p = BackULGray then
          back_col := 7


        else
        begin
          {fore_col:=2;}
        end;

        i := i + 2;

        if global_ansi then
        begin

          if global_carrierdropped = False then
          begin

            if global_cfor <> fore_col then
            begin
              global_cfor := fore_col;
              set_foreground(fore_col);
            end;

            if global_cback <> back_col then
            begin
              global_cback := back_col;
              set_background(back_col);
            end;

          end;
        end;

      end;
      else begin
        if global_carrierdropped = False then
        begin
          ssWrite(Text[I]);
        end else
        begin
          Write(Text[i]);
        end;
      end;
    end; {case .end.}
    Inc(i);

  until I > Length(Text);

  if carriage_return then
  begin
    crlf;
  end;
     {swriteln(text); {ddplus routine}

end; {D **END**}

procedure SSwrite(const s: string); {call to DDplus SWRITE proc}
begin
  {trying to make it easy to switch to another door kit}
  swrite(s);
end;

procedure SSwriteC(const c: char); {call to DDplus SWRITEC proc}
begin
  {trying to make it easy to switch to another door kit}
  swritec(c);
end;


procedure SD; {same as the procedure D above, with the exception that no
               crlf is added at the end of the line}
begin

  carriage_return := False;
  d(col, Text);
  carriage_return := True;

end;

{$IFDEF MSDOS}
procedure Upper4(var Str: string);
InLine(
 $8C/$DA/               {      mov   DX,DS               }
 $5E/                   {      pop   SI                  }
 $1F/                   {      pop   DS                  }
 $FC/                   {      cld                       }
 $AC/                   {      lodsb                     }
 $30/$E4/               {      xor   AH,AH               }
 $89/$C1/               {      mov   CX,AX               }
 $E3/$12/               {      jcxz  @30                 }
 $BB/Ord('a')/Ord('z')/ {      mov   BX,'za'             }
 $AC/                   { @15: lodsb                     }
 $38/$D8/               {      cmp   AL,BL               }
 $72/$08/               {      jb    @28                 }
 $38/$F8/               {      cmp   AL,BH               }
 $77/$04/               {      ja    @28                 }
 $80/$6C/$FF/$20/       {      sub   BYTE PTR [SI-1],$20 }
 $E2/$F1/               { @28: loop  @15                 }
 $8E/$DA);              { @30: mov   DS,DX               }
{$ENDIF}
{$IFNDEF MSDOS}
procedure Upper4(var Str: string);
var
  i, len: integer;
begin
  i := 0;
  len := Ord(Str[0]);
  repeat
    Inc(i);
    if i > len then
      Break;
    if Str[i] in ['a'..'z'] then
      Dec(Str[i], 32);
  until False;
end;

{$ENDIF}

function UpCaseStr;
begin
  upper4(s);
  UpcaseStr := s;
end;

function Confirm;
const Yadd = ' ? ([Y]/N)';
  Nadd     = ' ? (Y/[N])';

var ch:   char;
  Result: boolean;
begin

  {default choice : Y or N}
  default := upcase(default);

  case default of
    'Y': begin
      Result := True;
      sd(config.textcolor, Text + Yadd);
    end;
    else begin
      default := 'N';
      Result := False;
      sd(config.textcolor, Text + Nadd);
    end;
  end; {case .end.}

       {get user-input}
  repeat
    ch := getchar;
  until ch in ['Y', 'N', ReturnKey];

  {evaluate user-input}
  if (ch = ReturnKey) and (default = 'Y') then
    ch := 'Y';
  if (ch = ReturnKey) and (default = 'N') then
    ch := 'N';

  case ch of
    'Y': begin
      Result := True;
      sd(config.textcolor, ' Yes');
    end;
    'N': begin
      Result := False;
      sd(config.textcolor, ' No');
    end;
  end; {case .end.}

  crlf;
  {return result}
  confirm := Result;

end; {confirm *end*}

function Confirm2;
const Yadd = ' ? ([Y]/N/=)';
  Nadd     = ' ? (Y/[N]/=)';
  Eadd     = ' ? (Y/N/[=])';

var ch:   char;
  Result: char;
begin

  {default choice : Y, N or =}
  default := upcase(default);

  case default of
    'Y': begin
      Result := 'Y';
      default := 'Y';
      sd(config.textcolor, Text + Yadd);
    end;
    'N': begin
      Result := 'N';
      default := 'N';
      sd(config.textcolor, Text + Nadd);
    end;
    '=': begin
      Result := '=';
      default := '=';
      sd(config.textcolor, Text + Eadd);
    end;
  end; {case .end.}

       {get user-input}
  repeat
    ch := getchar;
  until ch in ['Y', 'N', '=', ReturnKey];

  {evaluate user-input}
  if (ch = ReturnKey) and (default = 'Y') then
    ch := 'Y';
  if (ch = ReturnKey) and (default = 'N') then
    ch := 'N';
  if (ch = ReturnKey) and (default = '=') then
    ch := '=';

  case ch of
    'Y': begin
      Result := 'Y';
      sd(config.textcolor, ' Yes');
    end;
    'N': begin
      Result := 'N';
      sd(config.textcolor, ' No');
    end;
    '=': begin
      Result := '=';
      sd(config.textcolor, ' =');
    end;
  end; {case .end.}

  crlf;
  {return result}
  confirm2 := Result;

end; {confirm2 *end*}

function Packed_Date: longint;
begin
  packed_date := swag_date;
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

  {return result}
  mkstring := temp;

end; {mkstring *end*}

function Cool_string(lngth: integer; char1, char2: char; col1, col2: integer): string;
var s:   string;
  turn1: boolean;
begin

  {creates a string containing every other char1 and char2, with colors col1 and col2}
  s := '';
  turn1 := True;
  while lngth > 0 do
  begin
    if turn1 then
    begin
      if col1 <> col2 then
      begin
        s := s + ConvertToUsurperAnsi3(col1);
      end;
      s := s + char1;
      turn1 := False;
    end else
    begin
      if col1 <> col2 then
      begin
        s := s + ConvertToUsurperAnsi3(col2);
      end;
      s := s + char2;
      turn1 := True;
    end;
    Dec(lngth);
  end; {while *end*}

       {return result}
  cool_string := s;

end; {cool_string *end*}

function Ljust;
var temp: string;
  diff:   integer;
begin

  temp := '';
  if length(s) > max then
  begin
    temp := copy(s, 1, max);
  end else
  if length(s) < max then
  begin
    diff := max - length(s);
    temp := s + mkstring(diff, ' ');
  end else
  begin
    temp := s;
  end;

  ljust := temp;

end; {ljust *end*}

function Rjust;
var temp: string;
  diff:   integer;
begin
  temp := '';
  if length(s) > max then
  begin
    temp := copy(s, 1, max);
  end else
  if length(s) < max then
  begin
    diff := max - length(s);
    temp := mkstring(diff, ' ') + s;
  end else
  begin
    temp := s;
  end;

  rjust := temp;
end; {rjust *end*}

function padright(const st: string; ch: char; l: integer): string;
var
  i:       integer;
  tempstr: string;

begin
  tempstr := st;
  if length(tempstr) > l then
    tempstr[0] := chr(l);
  if length(tempstr) < l then
  begin
    for i := length(tempstr) + 1 to l do
      tempstr[i] := ch;
    tempstr[0] := chr(l);
  end;

  {return result}
  padright := tempstr;

end; {padright *end*}

procedure AddBackSlash(var InPath: string);
begin
  if Length(InPath) > 0 then
  begin
    if InPath[Length(InPath)] <> DIRECTORY_SEPARATOR then
    begin
      InPath[0] := Chr(Length(InPath) + 1);
      InPath[Length(InPath)] := DIRECTORY_SEPARATOR;
    end;
  end;
end; {addbackslash *end*}


function WithBackSlash(InPath: string): string;
begin
  AddBackSlash(InPath);
  WithBackSlash := InPath;
end; {withbackslash *end*}

function striplead(st: string; ch: char): string;
var
  tempstr: string;

begin
  tempstr := st;
  while ((TempStr[1] = Ch) and (Length(TempStr) > 0)) do
  begin
    tempstr := copy(tempstr, 2, length(tempstr));
  end;
  striplead := tempstr;
end; {striplead *end*}

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
  end; {for i:= .end.}

  gulp := s;

end;

procedure Pause; {one of the most used procedures in the game! PAUSE}
var a: char;
begin

{ if global_ansi then begin
  set_color(config.textcolor,0);
 end;
}
  sd(8, '[Press a key]');

  sread_char(a);
  crlf;

end; {pause *end*}

procedure Show_Usurper_Data(const Name: string; pausing: boolean);
{show ansi/text/data from the usurper resource file}
var
  ch: char;

  quit, read_data, ansisave, matching, suspect_mode: boolean;

  c:  integer;

  f:  Text;

  s:  string;

begin

  {keep ansi variable}
  ansisave := ansion;
  ansion := True; {process ansi locally, ddplus variable}
  quit := False;

  suspect_mode := False;
  read_data := False;

  s := '@#' + upcasestr(Name);
  if global_ansi then
    s := s + '.ANS'
  else s := s + '.ASC';

  if open_txtfile(treset, f, global_datadir + global_textdataf) then
  begin

    while (not EOF(f)) and (not quit) do
    begin

      if read_data then
      begin
        Read(f, ch);
        if (not suspect_mode) and (ch = '@') then
        begin
          suspect_mode := True;
        end else
        if suspect_mode then
        begin
          if ch = '#' then
          begin
            quit := True;
          end else
          begin
            sswritec('@');
            sswritec(ch);
          end;
        end else
        begin
          sswritec(ch);
        end;
      end else
      begin
        {find start of picture}
        matching := False;
        c := 1;
        while (not EOF(f)) and (not read_data) do
        begin

          Read(f, ch);

          if (not matching) and (ch = s[c]) then
          begin
            Inc(c);
            matching := True;
          end else
          if (matching) and (ch = s[c]) then
          begin
            Inc(c);
            if c > length(s) then
            begin
              read_data := True;
            end;
          end else
          if (matching) and (ch <> s[c]) then
          begin
            c := 1;
            matching := False;
          end;

        end; {while .end.}

      end;

    end; {while .end.}

         {close textfile}
    Close(f);

  end else
  begin
    {error accessing resource file}
    unable_to_access(global_datadir + global_textdataf, access_error);
  end;

  {picture not found}
  if not read_data then
  begin
    Unable_to_find(s);
    if (config.errors) then pause;
  end;

  set_foreground(default_fore);
  {restore ansi variable}
  ansion := ansisave;

  {should we pause?}
  if pausing then
    pause;

end; {show_usurper_data *end*}

function Menu_Choices(const m1, m2, m3, m4, m5: string): char;
const nada = '@';
  offset   = 2;

var
  ch1, ch2, ch3, ch4, ch5, ch: char;

begin
  {create some simple menus}

  ch1 := nada;
  ch2 := nada;
  ch3 := nada;
  ch4 := nada;
  ch5 := nada;

  repeat
    if m1 <> '' then
    begin
      menu(m1);
      ch1 := m1[offset];
    end;

    if m2 <> '' then
    begin
      menu(m2);
      ch2 := m2[offset];
    end;

    if m3 <> '' then
    begin
      menu(m3);
      ch3 := m3[offset];
    end;

    if m4 <> '' then
    begin
      menu(m4);
      ch4 := m4[offset];
    end;

    if m5 <> '' then
    begin
      menu(m5);
      ch5 := m5[offset];
    end;

    sd(config.textcolor, ':');

    {get user-input}
    ch := upcase(getchar);

  until (ch in [ch1, ch2, ch3, ch4, ch5]) and not (ch in [nada]);
  d(10, ch);

  {return result}
  menu_choices := ch;

end; {menu_choices *end*}

procedure Menu5;
begin

  {first bracket}
  sd(config.bracketcolor, copy(Text, 1, 1));

  {hot key}
  sd(config.hotkeycolor, copy(Text, 2, pos));

  {second bracket}
  sd(config.bracketcolor, copy(Text, pos + 2, 1));

  {rest of text}
  sd(config.textcolor, copy(Text, pos + 3, 99));

end; {menu5 *end*}

procedure Menu3;
begin

  {first bracket}
  sd(config.bracketcolor, copy(Text, 1, pos - 1));

  {hot key}
  sd(config.hotkeycolor, copy(Text, pos, 1));

  {second bracket}
  sd(config.bracketcolor, copy(Text, pos + 1, 1));

  {rest of text}
  sd(config.textcolor, copy(Text, pos + 2, 99));

end; {menu3 *end*}

procedure Menu2; {same as menu() except for not having a CRLF at the end}
begin

  {first bracket}
  sd(config.bracketcolor, copy(Text, 1, 1));

  {hot key}
  sd(config.hotkeycolor, copy(Text, 2, 1));

  {second bracket}
  sd(config.bracketcolor, copy(Text, 3, 1));

  {rest of text}
  sd(config.textcolor, copy(Text, 4, 99));

end; {menu2 *end*}

procedure Menu;
begin

  {first bracket}
  sd(config.bracketcolor, copy(Text, 1, 1));

  {hot key}
  sd(config.hotkeycolor, copy(Text, 2, 1));

  {second bracket}
  sd(config.bracketcolor, copy(Text, 3, 1));

  {rest of text}
  sd(config.textcolor, copy(Text, 4, 99));

  {return}
  crlf;

end; {menu *end*}

procedure Crlf; {Return/Enter}
begin
  if global_carrierdropped = False then
  begin
    swriteln(''); {ddplus function}
  end else
  begin
    writeln('');
  end;
end; {crlf *end*}

procedure ClearScreen; {clears screen on both remote/local sides}
begin

  if global_carrierdropped = False then
  begin
    SCLRSCR; {ddplus function}
  end else
  begin
    ClrScr;
  end;

end; {clearscreen *end*}

function Strip; {strips string from Usurper ANSI codes}
var
  i:           integer;
  s:           string;

  cfor, cback: byte;

  p:           string[3];
  ok, fin:     boolean;
begin

  fin := False;
  cfor := global_cfor;
  s := out;
  i := 1;

  repeat
    ok := False;
    p := copy(s, i, 3);

    {kolla om ansi tecken finns}
    if p = ublack then
      cfor := 0
    else
    if p = ublue then
      cfor := 1
    else
    if p = ugreen then
      cfor := 2
    else
    if p = ucyan then
      cfor := 3
    else
    if p = ured then
      cfor := 4
    else
    if p = umag then
      cfor := 5
    else
    if p = ubrown then
      cfor := 6
    else
    if p = ulgray then
      cfor := 7
    else
    if p = udgray then
      cfor := 8
    else
    if p = ulblue then
      cfor := 9
    else
    if p = ulgreen then
      cfor := 10
    else
    if p = ulcyan then
      cfor := 11
    else
    if p = ulred then
      cfor := 12
    else
    if p = ulmag then
      cfor := 13
    else
    if p = uyellow then
      cfor := 14
    else
    if p = uwhite then
      cfor := 15

    {background color}
    else
    if p = backublack then
      cback := 0
    else
    if p = backublue then
      cback := 2
    else
    if p = BackUGreen then
      cback := 2
    else
    if p = BackUCyan then
      cback := 3
    else
    if p = BackURed then
      cback := 4
    else
    if p = BackUMagenta then
      cback := 5
    else
    if p = BackUBrown then
      cback := 6
    else
    if p = BackULGray then
      cback := 7

    else
    begin
      ok := True;
    end;

    if not ok then
    begin
      Delete(s, i, 3);
      i := 1;
    end else
    begin
      Inc(i);
    end;

    if i > length(out) then
      fin := True;

  until fin;

  {return stripped string}
  strip := s;

end; {strip *end*}

function backcolr(back_col: byte): s14;
var s: s14;
begin

  {init}
  s := '';

  {hitler complete!}

  case global_cfor of
    12: begin {light-red text on back_col background}
      case back_col of
        0: s := AbRedonBlack; {black}
        1: s := AbRedonBlue;  {blue}
        2: s := AbRedonGreen; {green}
        3: s := AbRedonCyan;  {cyan}
        4: s := AbRedonRed;   {red}
        5: s := AbRedonMagenta; {magenta}
        6: s := AbRedonBrown; {brown}
        7: s := AbRedonLtGray;{light-gray}
      end; {case .end.}
    end; {light-red *end*}
    13: begin {light-magenta text on back_col background}
      case back_col of
        0: s := AbMagentaonBlack; {black}
        1: s := AbMagentaonBlue;  {blue}
        2: s := AbMagentaonGreen; {green}
        3: s := AbMagentaonCyan;  {cyan}
        4: s := AbMagentaonRed;   {red}
        5: s := AbMagentaonMagenta; {magenta}
        6: s := AbMagentaonBrown; {brown}
        7: s := AbMagentaonLtGray;{light-gray}
      end; {case .end.}
    end; {light-magenta *end*}
    14: begin {yellow text on back_col background}
      case back_col of
        0: s := AYellowonBlack; {black}
        1: s := AYellowonBlue;  {blue}
        2: s := AYellowonGreen; {green}
        3: s := AYellowonCyan;  {cyan}
        4: s := AYellowonRed;   {red}
        5: s := AYellowonMagenta; {magenta}
        6: s := AYellowonBrown; {brown}
        7: s := AYellowonLtGray;{light-gray}
      end; {case .end.}
    end; {yellow *end*}
    15: begin {white text on back_col background}
      case back_col of
        0: s := AWhiteonBlack; {black}
        1: s := AWhiteonBlue;  {blue}
        2: s := AWhiteonGreen; {green}
        3: s := AWhiteonCyan;  {cyan}
        4: s := AWhiteonRed;   {red}
        5: s := AWhiteonMagenta; {magenta}
        6: s := AWhiteonBrown; {brown}
        7: s := AWhiteonLtGray;{light-gray}
      end; {case .end.}
    end; {white *end*}
  end; {case .end.}

       {return result}
  backcolr := s;

end; {backcolr *end*}

function Uconv; {converts Usurper ANSI codes to real ANSI}
var
  i:       integer;
  s:       string;
  c:       s70;
  p:       string[3];
  ok, fin: boolean;

begin

  fin := False;
  s := out;
  i := 1;
  c := AGreenOnBlack; {default Ansi Color}

  repeat
    ok := False;
    p := copy(s, i, 3);

    {check for (foreground) control string}
    if p = ublack then
      c := AblackonBlack
    else
    if p = ublue then
      c := ABlueonBlack
    else
    if p = ugreen then
      c := AGreenonBlack
    else
    if p = ucyan then
      c := ACyanonBlack
    else
    if p = ured then
      c := ARedonBlack
    else
    if p = umag then
      c := AMagentaonBlack
    else
    if p = ubrown then
      c := ABrownonBlack
    else
    if p = ulgray then
      c := ALtGrayonBlack
    else
    if p = udgray then
      c := ADkGrayonBlack
    else
    if p = ulblue then
      c := ALtBlueonBlack
    else
    if p = ulgreen then
      c := ALtGreenonBlack
    else
    if p = ulcyan then
      c := ALtCyanOnBlack
    else
    if p = ulred then
      c := ALtRedonBlack
    else
    if p = ulmag then
      c := ALtMagentaonBlack
    else
    if p = uyellow then
      c := AYellowonBlack
    else
    if p = uwhite then
      c := AWhiteonBlack

    {check for (background) control string}
    else
    if p = backublack then
      c := backcolr(0)
    else
    if p = backublue then
      c := backcolr(1)
    else
    if p = BackUGreen then
      c := backcolr(2)
    else
    if p = BackUCyan then
      c := backcolr(3)
    else
    if p = BackURed then
      c := backcolr(4)
    else
    if p = BackUMagenta then
      c := backcolr(5)
    else
    if p = BackUBrown then
      c := backcolr(6)
    else
    if p = BackULGray then
      c := backcolr(7)

    else
    begin
      ok := True;
    end;

    if not ok then
    begin
      Delete(s, i, 3);

      insert(C, s, i);

      i := 1;
    end else
    begin
      Inc(i);
    end;

    if i > length(s) then
      fin := True;

  until fin;

  uconv := s;

end; {uconv *end*}

procedure Get_StringW;
var s2: string;
begin

  {move string to temporary workspace}
  s2 := s;

  {get a string, using DDplus routine}
  promptwr(s2, maxlength, False);

  {Remove BadWords}
  s2 := remove_badwords(s2);

  {return result}
  s := s2;

end; {get_stringw *end*}

function Get_StringSec; {get a string, chars are echoed back as CH}
var Result: string;
begin

  Result := emptystr;
  promptsec(Result, maxlength, False, ch);

 {Remove BadWords
  We skip badwords check here...players wont be happy if team password is
  SHIT and its changed, they will not know what their password is!
{ s:=remove_badwords(s);}

  {return result}
  get_stringsec := Result;

end; {get_stringsec *end*}

function Get_String;
var Result: string;
begin

  {init vars}
  Result := '';

  {ddplus "get string" routine}
  promptj(Result, maxlength, False, True);

  {Remove BadWords}
  Result := remove_badwords(Result);

  {return result}
  get_string := Result;

end; {get_string *end*}

procedure Get_StringDefault;
begin

 {the same as GET_STRING, but here DEFAULT is printed out as default input
 }

  {ddplus "get string" routine}
  promptj(default, maxlength, False, False);

  {Remove BadWords}
  default := remove_badwords(default);

end; {get_stringdefault *end*}


procedure Door_left(howmany: byte);
begin

  if local then
  begin
    gotoxy(wherex - howmany, wherey);
  end else
  begin

    if global_ansi then
    begin
      swrite(#27'[' + IntToStr(howmany) + 'D');
    end else
    begin
      for howmany := 1 to howmany do
      begin
        swrite(#8);
      end;
    end;
  end;

end; {door_left *end*}

procedure Door_Right(howmany: byte);
begin

  if local then
  begin
    gotoxy(wherex + howmany, wherey);
  end else
  begin
    if global_ansi then
    begin
      swrite(#27'[' + IntToStr(howmany) + 'C');
    end else
    begin
      for howmany := 1 to howmany do
      begin
        swrite(#32);
      end;
    end;
  end;

end; {door_right *end*}


function Get_A_Number(rmin, rmax, default: longint): longint;
{Input routine character by character, and with special keys to produce
 various results: MaxInput_Key}
const thousand_key = 'K';
  million_key      = 'M';

var Result: longint;
  x:        longint;
  s:        s70;
  ok:       boolean;
  i:        byte;
  ch:       char;

begin

  {init vars}
  Result := 0;
  s := '';
  ok := False;

  {Delete: (#0+_Delete,#127,#127)  tty/ansi/avatar}

  repeat

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      Thousand_Key: begin {user has pressed K}

        if length(s) + 3 <= 10 then
        begin
          sd(config.textcolor, '000');
          s := s + '000';
        end else
        if length(s) < 10 then
        begin
          repeat
            sd(config.textcolor, '0');
            s := s + '0';
          until length(s) = 10;
        end;

      end;
      Million_Key: begin {user has pressed M}

        if length(s) + 6 <= 10 then
        begin
          sd(config.textcolor, '000000');
          s := s + '000000';
        end else
        if length(s) < 10 then
        begin
          repeat
            sd(config.textcolor, '0');
            s := s + '0';
          until length(s) = 10;
        end;
      end;

      MaxInput_Key: begin {Special Key to get MAX value has been pressed}

        {erase current characters}
        for i := 1 to length(s) do
        begin
          door_left(1);
          sd(config.textcolor, ' ');
          door_left(1);
        end; {for i:= .end.}

             {set string to max value}
        s := long2str(rmax);
        if s = '' then
          s := '0';

        sd(config.textcolor, s);

      end;
      ReturnKey: begin {Return/Enter key pressed}
        {check if string is valid}

        {has a default value been defined by calling procedure?}
        if default <> -1 then
        begin
          if s = '' then
          begin
            if default > rmax then
              default := rmax;
            s := long2str(default);
          end;
        end else
        begin
          if s = '' then
            s := '0';
        end;

        x := str_to_nr2(s);

        if (x > rmax) or (x < rmin) then
        begin
          crlf;
          d(config.textcolor, '(a number in the range ' + ulgray + commastr(rmin) + config.textcol1 +
            ' .. ' + ulgray + commastr(rmax) +
            config.textcol1 + ' please!)');
          sd(config.textcolor, ':');
          {reset string}
          s := '';
        end else
        begin
          ok := True;
        end;

      end;
      DeleteKey: begin {Delete key pressed}
        if length(s) > 0 then
        begin
          door_left(1);
          sd(config.textcolor, ' ');
          door_left(1);
          {delete character from string}
          Delete(s, length(s), 1);
        end;
      end;
      '0'..'9': begin {valid number pressed}
        if length(s) < 10 then
        begin
          sd(config.textcolor, ch);
          s := s + ch;
        end;
      end;
    end; {case .end.}
  until ok;

  {convert string to number}
  Result := str_to_nr(s);

  {return result}
  get_a_number := Result;

  crlf;

end; {get_a_number *end*}

function Get_Number;
var Result: longint;
begin

  {call universal numeric input routine}
  Result := get_a_number(rmin, rmax, -1);

  {return reslut}
  get_number := Result;

end; {get_number *end*}

function Get_Number2; {same as get_number, but with ability to accept a
                       default value in the parameter list}
var Result: longint;
begin

  {call universal numeric input routine}
  Result := get_a_number(rmin, rmax, default);

  {return result}
  get_number2 := Result;

end; {get_number2 *end*}

function Get_Number_Old; {get a number from the user}
var s:    string;
  x:      longint;
  bye:    boolean;
  Result: longint;

begin

  {init vars}
  Result := 0;
  bye := False;

  repeat

    {empty string}
    s := emptystr;

    {lets get a string from the user}
    promptj(s, 20, False, True);

    {we remove the ',' och '.'}
    remove_commas(s);

    {if user presses return}
    if s = '' then
      s := '0';

    {convert the string to a numeric}
    x := str_to_nr(s);

    {is input within the boundaries defined by calling paramters}
    if (x > rmax) or (x < rmin) then
    begin
      d(config.textcolor, '(a number in the range ' + commastr(rmin) + '..' + commastr(rmax) + ' please!)');
      sd(config.textcolor, ':');
    end else
    begin
      Result := x;
      bye := True;
    end;

  until bye; {loop until valid value is returned}

  {return result}
  get_number_old := Result;

end;

const
  hexid: array[$00..$0F] of char = '0123456789ABCDEF'; { For dec to hex }

function IntToHex(num: longint; digits: byte): string;
var
  s: string;
  c: byte;
  n: array[1..sizeof(longint)] of byte absolute num;
begin
  s := '';
  for c := 4 downto 1 do
    s := s + hexid[n[c] shr 4] + hexid[n[c] and $F];
  IntToHex := copy(s, 8 - digits + 1, digits);
end;

function IntToStr(Num: longint): string;
  { This function takes an integer value, and creates a string }
var st: string;
begin
  Str(Num, St);
  IntToStr := st;
end;

function Valid_Color(const incolor: string): boolean;
var Result: boolean;
begin

  Result := False;

  if upcasestr(incolor) = 'BLACK' then
    Result := True
  else
  if upcasestr(incolor) = 'BLUE' then
    Result := True
  else
  if upcasestr(incolor) = 'GREEN' then
    Result := True
  else
  if upcasestr(incolor) = 'CYAN' then
    Result := True
  else
  if upcasestr(incolor) = 'RED' then
    Result := True
  else
  if upcasestr(incolor) = 'MAGENTA' then
    Result := True
  else
  if upcasestr(incolor) = 'BROWN' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTGRAY' then
    Result := True
  else
  if upcasestr(incolor) = 'DARKGRAY' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTBLUE' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTGREEN' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTCYAN' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTRED' then
    Result := True
  else
  if upcasestr(incolor) = 'LIGHTMAGENTA' then
    Result := True
  else
  if upcasestr(incolor) = 'YELLOW' then
    Result := True
  else
  if upcasestr(incolor) = 'WHITE' then
    Result := True;

  {return result}
  valid_color := Result;

end; {valid_color *end*}

function ConvertToUsurperAnsi(incolor: string): string;
var Result: string[14];
begin

  incolor := upcasestr(incolor);
  Result := ugreen;

  if incolor = 'BLACK' then
    Result := ublack
  else
  if incolor = 'BLUE' then
    Result := ublue
  else
  if incolor = 'GREEN' then
    Result := ugreen
  else
  if incolor = 'CYAN' then
    Result := ucyan
  else
  if incolor = 'RED' then
    Result := ured
  else
  if incolor = 'MAGENTA' then
    Result := umag
  else
  if incolor = 'BROWN' then
    Result := ubrown
  else
  if incolor = 'LIGHTGRAY' then
    Result := ulgray
  else
  if incolor = 'DARKGRAY' then
    Result := udgray
  else
  if incolor = 'LIGHTBLUE' then
    Result := ulblue
  else
  if incolor = 'LIGHTGREEN' then
    Result := ulgreen
  else
  if incolor = 'LIGHTCYAN' then
    Result := ulcyan
  else
  if incolor = 'LIGHTRED' then
    Result := ulred
  else
  if incolor = 'LIGHTMAGENTA' then
    Result := ulmag
  else
  if incolor = 'YELLOW' then
    Result := uyellow
  else
  if incolor = 'WHITE' then
    Result := uwhite;

  {return result}
  ConvertToUsurperAnsi := Result;

end; {converttousurperansi *end*}

function ConvertToUsurperAnsi2(incolor: string): byte;
var Result: byte;
begin

  incolor := upcasestr(incolor);
  Result := 2;

  if incolor = 'BLACK' then
    Result := 0
  else
  if incolor = 'BLUE' then
    Result := 1
  else
  if incolor = 'GREEN' then
    Result := 2
  else
  if incolor = 'CYAN' then
    Result := 3
  else
  if incolor = 'RED' then
    Result := 4
  else
  if incolor = 'MAGENTA' then
    Result := 5
  else
  if incolor = 'BROWN' then
    Result := 6
  else
  if incolor = 'LIGHTGRAY' then
    Result := 7
  else
  if incolor = 'DARKGRAY' then
    Result := 8
  else
  if incolor = 'LIGHTBLUE' then
    Result := 9
  else
  if incolor = 'LIGHTGREEN' then
    Result := 10
  else
  if incolor = 'LIGHTCYAN' then
    Result := 11
  else
  if incolor = 'LIGHTRED' then
    Result := 12
  else
  if incolor = 'LIGHTMAGENTA' then
    Result := 13
  else
  if incolor = 'YELLOW' then
    Result := 14
  else
  if incolor = 'WHITE' then
    Result := 15;

  {return result}
  ConvertToUsurperAnsi2 := Result;

end;

function ConvertToUsurperAnsi3(incolor: byte): string;
var s: string[3];
begin

  case InColor of
    0: s := ublack;
    1: s := ublue;
    2: s := ugreen;
    3: s := ucyan;
    4: s := ured;
    5: s := umag;
    6: s := ubrown;
    7: s := ulgray;
    8: s := udgray;
    9: s := ulblue;
    10: s := ulgreen;
    11: s := ulcyan;
    12: s := ulred;
    13: s := ulmag;
    14: s := uyellow;
    15: s := uwhite;
    else s := '';
  end; {case .end.}

       {return result}
  converttoUsurperAnsi3 := s;

end; {converttoUsurperAnsi3 *end*}

function ConvertToAnsi(incolor: byte): string;
var s9: string[14];
begin

  case InColor of
    0: s9 := ABlackOnBlack;
    1: s9 := ABlueOnBlack;
    2: s9 := AGreenOnBlack;
    3: s9 := ACyanOnBlack;
    4: s9 := ARedOnBlack;
    5: s9 := AMagentaonBlack;
    6: s9 := ABrownOnBlack;
    7: s9 := ALtGrayOnBlack;
    8: s9 := ADkGrayOnBlack;
    9: s9 := ALtBlueOnBlue;
    10: s9 := ALtGreenOnBlack;
    11: s9 := ALtCyanOnBlack;
    12: s9 := ALtRedOnBlack;
    13: s9 := ALtMagentaOnBlack;
    14: s9 := AYellowOnBlack;
    15: s9 := AWhiteOnBlack;
    else s9 := AGreenOnBlack;
  end; {case .end.}

       {return result}
  ConvertToAnsi := s9;

end; {ConvertToAnsi *end*}

function FindSub(const s1, s2: string): boolean; {is s1 somewhere in s2?}
begin

  if s1 = '' then
  begin
    findsub := True;
  end else
  begin

    if pos(upcasestr(s1), upcasestr(s2)) > 0 then
      findsub := True
    else findsub := False;
  end;

end; {findsub *end*}

function LeadingZero(w: word): string;
var
  s: string;
begin
  Str(w: 0, s);
  if Length(s) = 1 then
  begin
    s := '0' + s;
  end;

  {return result}
  LeadingZero := s;

end; {leadingzero *end*}


function Give_Me_Time: string;
  {returns current time in a 'h:m:s' format}
var
  Hour, Minute, Second, Sec100: word;
  h, m, s: string[20];
begin

  GetTime(Hour, Minute, Second, Sec100);

  h := commastr(hour);
  m := commastr(minute);
  s := commastr(second);

  if length(h) < 2 then
    h := '0' + h;
  if length(m) < 2 then
    m := '0' + m;
  if length(s) < 2 then
    s := '0' + s;

  {return result}
  give_me_time := h + ':' + m + ':' + s;

end; {give_me_time *end*}

function HeartSign; {used in relation procs to indicate LOVE situations}
begin
  HeartSign := chr(3);
end;

function DeathSign; {used in relation procs to indicate DEATH/HATE situations}
begin
  DeathSign := '+';
end;

function UnderScore; {character used to represent underscore sign}
begin
  underscore := chr(196);
end;

function Todays_Time; {time string[8]}
var
  hour, min, sec, sec100: word;
  Result: string[8];
begin;  {original code taken from the "date" function in ddscott.pas}

  gettime(hour, min, sec, sec100);

  Result := LeadingZero(hour) + ':' +
    LeadingZero(min) + ':' +
    LeadingZero(sec);

  {return result}
  Todays_time := Result;

end; {todays_time *end*}

function Todays_Date; {date string[8] american, mm dd yyyy}
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

end; {todays_date *end*}

function Fix_Date; {fixes 8 string date strings}
begin
  fix_date := s[1] + s[2] + '-' + s[3] + s[4] + '-' + s[5] + s[6] + s[7] + s[8];
end;

procedure Display_Text;
begin
  display_utext(Name);
end;

{$IFDEF MSDOS}
function IsWin95: boolean; assembler;
asm
         PUSH    DS                  ;{ Pascal doesn't save these }
         PUSH    SI

         MOV     AX, 4A33h
         INT     2Fh                  ;{ AX nonzero if present }

         POP     SI
         POP     DS
end; {iswin95 *end*}
{$ENDIF}
{$IFNDEF MSDOS}
function IsWin95: boolean;
begin
  // REENOTE Does the above return true?  Is it important (for slicing or something)?
  WriteLn('REEPORT JAKOB IsWin95');
end;

{$ENDIF}

(*REENOTE UNUSED function Jake_Tasker: byte; {Which OS is running?}
var Result: byte;
begin

  Result := tasker; {ddscott 'tasker' variable}

  {return result}
  jake_tasker := Result;

end; {jake_tasker *end*}*)

procedure Display_Bar_Status; {call to DDplus Display_Status (bar) proc}
begin
  if (statline) then
    display_status(force);
end;

function Param_Hunt; {checking for Command Line parameters}
var i: byte;
begin

  param_hunt := False;
  if paramcount > 0 then
  begin
    for i := 1 to paramcount do
    begin
      if upcasestr(ParamStr(i)) = h then
      begin
        param_hunt := True;
        break;
      end;
    end;
  end;

end; {param_hunt *end*}

function UKeyPressed: boolean; {same as pascal KeyPressed function}
begin
  Ukeypressed := sKeyPressed; {using ddplus function skeypressed}
end;

procedure Normal_Exit; {exit program}
begin
  halt(0);
end;

procedure My_TimeSlice; {release a timeslice}
begin
  releasetimeslice;     {ddplus routine}
end;

function HeapHandler;
begin {handles all heap errors}

 {The HeapError function returns
   0. to indicate failure, and causes a run-time error to occur immediately.
   1. to indicate failure, and causes New or GetMem to return a nil pointer.
   2. to indicate success, and causes a retry (which could also cause
   another call to the heap error function).

 calls to GetMem and New will return NIL if there is not enough memory,
  instead of aborting with a RTE.}

  HeapHandler := 1;

end; {heaphandler *end*}


{$IFDEF MSDOS}
function ScreenRows: byte; assembler;
         { -- ScreenRows := mem[Seg0040:$84] + 1 }
         {Peter Louwen (2:283/502)}
asm
         MOV     AX, [Seg0040]
         MOV     ES, AX
         MOV     AL, ES:$84
         INC     AL
end;
{$ENDIF}
{$IFNDEF MSDOS}
function ScreenRows: byte;
var
  y: word;
begin
  y := RPScreenSizeY;
  if (y > 255) then
    y := 255;
  ScreenRows := y;
end;

{$ENDIF}

{$IFDEF MSDOS}
function ScreenCols: byte; assembler;
         { -- ScreenCols := mem[Seg0040:$4A] }
         {Peter Louwen (2:283/502)}
asm
         MOV     AX, [Seg0040]
         MOV     ES, AX
         MOV     AL, ES:$4A
end;
{$ENDIF}
{$IFNDEF MSDOS}
function ScreenCols: byte;
var
  x: word;
begin
  x := RPScreenSizeX;
  if (x > 255) then
    x := 255;
  ScreenCols := x;
end;

{$ENDIF}

procedure Spin_Cursor(action, cursor_color: byte);
const sc: array[0..3] of char = '-\|/';

  procedure take_a_spin(pause_it: boolean);
  begin
    global_place := (global_place + 1) mod 4;
    sd(cursor_color, sc[global_place]);
    if pause_it then
      delay2(250);
    sd(cursor_color, #8);
  end;

begin
  case action of
    1: begin {spin cursur until key is pressed}
      repeat
        take_a_spin(True);
      until UkeyPressed;
    end;
    2: begin {take a single spin and exit}
      take_a_spin(False);
    end;
  end; {case .end.}

end;   {spincursor *end*}

       {*Unit Initialization Code*}
begin
  carriage_return := True;

end. {Unit Jakob .end.}
