{$I DEFINES.INC}
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

Unit JakobE; {Usurper Editor - Extra Routines}

Interface

// REETODO Remove redundant methods

{Misc}
Procedure Delay2(tics : word);
Procedure Statbar(cnum,enum,xspot,yspot,fullcolor,emptycolor: Integer);
Procedure Remove_Commas(var gulp:string);
Function Commastr( number:longint) : string;
Function CommastrP( nr:longint) : string; {som ovan fast med + eller -}

{String}
Procedure CleanString(var s : string);
Procedure Wrl(const s:string);
Procedure ClearScreen;
Function MkString( nr:integer; s:string) : string;
Function UpCaseStr( s3:string ) : string;
Function EmptyStr : string;
Function FindSub(const s1,s2:string):boolean; {is s1 somewhere in s2?}
Function Crypt(nr:word) : string; {returns a random array with length NR}
Function Long2Str(Number: LongInt):string;

{Date}
Function Packed_Date : longint;
Function DateFix(const s : string) : string ;
Function Todays_Date:string; {date string[8] american}


Implementation

Uses Dos, Crt, Init, DateUtils;

Function Todays_Date:string; {date string[8] american}
var
 d,m,y,dow: word;
 s,s2: string[8];
begin  {original code taken from the "date" function in ddscott.pas}
 getdate(y,m,d,dow);
 s:=long2str(m);
 if length(s)=1 then s:='0'+s;
 s2:=long2str(d);
 if length(s2)=1 then s2:='0'+s2;
 s:=s+s2;
 s2:=long2str(y);
 while length(s2)<4 do begin
  s2:='0'+s2;
 end;
 s:=s+s2;

 {return result}
 Todays_Date:=s;
end; {todays_date}

Function Packed_Date : longint;
begin
 packed_date:=DaysSince1Jan0001;
end;

Procedure ClearScreen;
begin
 clrscr;
end;


Procedure CleanString(Var s:String);
begin
  fillChar(s,sizeof(s),0);
end;

Function Long2Str(Number: LongInt): String;
var
 TempStr: string;

begin {converts longint to string}
 Str(Number,TempStr);
 Long2Str := TempStr;
end;

Function EmptyStr : string;
var s : string;
begin
 cleanstring(s);
 emptystr:=s;
end;


Function UpCaseStr( s3:string ) : string;
var i :integer;
begin
 for i:=1 to length(s3) do
  s3[i]:=upcase(s3[i]);
  UpcaseStr:=s3;
end;

Function MkString( nr:integer; s:string) : string;
var
    i : integer;
    temp : string;

begin

 temp:='';

 for i:=1 to nr do begin
  temp:=temp+s;
 end;

 mkstring:=temp;


end;

Procedure Remove_Commas;
var s : string;
    i : integer;
begin

 s:='';
 for i:=1 to length(gulp) do begin
  if (gulp[i]<>',') and (gulp[i]<>'.') then begin
    s:=s+gulp[i];
  end;
 end;
 gulp:=s;

end;

Function CommaStr(Number: LongInt): String;
  Var
    StrPos: Integer;
    NumberStr: String;

  Begin
  NumberStr := Long2Str(Number);
  StrPos := Length(NumberStr) - 2;
  While StrPos > 1 Do
    Begin
    Insert(',',NumberStr,StrPos);
    StrPos := StrPos - 3;
    End;
  CommaStr := NumberStr;
  End;

Function CommastrP( nr:longint) : string; {som ovan fast med + eller -}
var s : s70;
begin

 s:=commastr(nr);

 if nr>0 then begin
  s:='+'+s;
 end;

 commastrP:=s;

end;

Function DateFix(const s : string) : string ;
begin
 datefix:=s[1]+s[2]+'-'+s[3]+s[4]+'-'+s[5]+s[6]+s[7]+s[8];
end;

Procedure Delay2;
begin
 delay(tics);
end;

Function Crypt(nr:word) : string; {returns a random array with length NR}
var s : string;
    i : byte;
begin

 s:='';
 for i:=1 to nr do begin
  case random(65) of
   0: s:=s+'A';
   1: s:=s+'B';
   2: s:=s+'C';
   3: s:=s+'D';
   4: s:=s+'E';
   5: s:=s+'F';
   6: s:=s+'G';
   7: s:=s+'H';
   8: s:=s+'I';
   9: s:=s+'J';
   10: s:=s+'K';
   11: s:=s+'L';
   12: s:=s+'M';
   13: s:=s+'N';
   14: s:=s+'O';
   15: s:=s+'P';
   16: s:=s+'Q';
   17: s:=s+'R';
   18: s:=s+'S';
   19: s:=s+'T';
   20: s:=s+'U';
   21: s:=s+'V';
   22: s:=s+'W';
   23: s:=s+'X';
   24: s:=s+'Y';
   25: s:=s+'Z';
   26: s:=s+'a';
   27: s:=s+'b';
   28: s:=s+'c';
   29: s:=s+'d';
   30: s:=s+'e';
   31: s:=s+'f';
   32: s:=s+'g';
   33: s:=s+'h';
   34: s:=s+'i';
   35: s:=s+'j';
   36: s:=s+'k';
   37: s:=s+'l';
   38: s:=s+'m';
   39: s:=s+'n';
   40: s:=s+'o';
   41: s:=s+'p';
   42: s:=s+'q';
   43: s:=s+'r';
   44: s:=s+'s';
   45: s:=s+'t';
   46: s:=s+'u';
   47: s:=s+'v';
   48: s:=s+'w';
   49: s:=s+'x';
   50: s:=s+'y';
   51: s:=s+'z';
   52: s:=s+'#';
   53: s:=s+'$';
   54: s:=s+'%';
   55: s:=s+'0';
   56: s:=s+'1';
   57: s:=s+'2';
   58: s:=s+'3';
   59: s:=s+'4';
   60: s:=s+'5';
   61: s:=s+'6';
   62: s:=s+'7';
   63: s:=s+'8';
   64: s:=s+'9';
  end;
 end;

 {return result}
 crypt:=s;

end;

Function FindSub(const s1,s2:string):boolean; {is s1 somewhere in s2?}
begin
 if pos(upcasestr(s1),upcasestr(s2))>0 then findsub:=true
                                       else findsub:=false;
end;

Procedure Wrl(const s:string); {replacement for Writeln}
begin
 writeln(s);
end;


Procedure StatBar;
Procedure Dupeit(var start : byte; x,y:byte;Str: string; Num: Integer);
var Cnt: integer;
begin
 For Cnt := 1 to Num do begin
  Pupp^.writestr(start,y,Str,1);
  inc(start);
 end;
end;

var
    percentage: integer;
    s : string;
    m : longint;
    start : byte;
begin
 percentage := round(cnum / enum * 100 / 2);
 start:=xspot;
 dupeit(start,xspot,yspot,#219,Percentage);
 dupeit(start,xspot,yspot,#177,50 - Percentage);
 m:=percentage*2;
 str(m,s);
 s:='  '+s+'%';
 Pupp^.writestr(start,yspot,s,1);
end;

end.
