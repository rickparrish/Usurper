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



Unit Jakob; {Usurper - Basic Door Routines Using DDPLUS door driver
             routines.

             if you plan on switching door driver, some of these
             routines will require modifying}
Interface

const global_place : byte = 0; {see spin_cursor}

{Uses Init;}

{string}
Procedure Remove_Commas(var gulp:string);
Procedure AddBackSlash(var inpath: string);
Function LeadingZero(w : Word) : String;
Function striplead(st:string;ch:char):string;
Function WithBackSlash(inpath:string):string;
Function padright(const st:string;ch:char;l:integer):string;
Function Str_to_Nr(const s:string) : longint; {string to number}
Function Str_to_Real(const s:string) : real; {string to number}
Function CommaStr(Number: LongInt):string;
Function Long2Str(Number: LongInt):string;
Function MkString( nr : integer;const s:string) :string;
Function Cool_string(lngth:integer;char1,char2:char;col1,col2:integer) : string;
Function Ljust(const s:string; max:integer) :string;
Function Rjust(const s:string; max:integer) :string;
Function FindSub(const s1,s2:string):boolean; {is s1 somewhere in s2?}
Function EmptyStr : string; {returns an empty string}
Function Replace_String(Source:string; const old,new : string) : string;
Function IntToHex(num: longint; digits: byte): string;
Function IntToStr(Num: longint): string;
Function Percent_String(num1,num2:integer):string;

{cursor}
Procedure Spin_Cursor(action,cursor_color:byte);

{input routines}
Procedure Get_StringW(var s :string;maxlength:integer);
Procedure Get_StringDefault(var default:string;maxlength:byte);
Function Get_StringSec(maxlength:integer;ch:char):string;
Function Get_String(maxlength:byte):string;

{numbers}
Function Get_Number_Old(rmin,rmax:longint):longint; {old routine}
Function Get_Number2(rmin,rmax,default:longint):longint;
Function Get_Number(rmin,rmax:longint):longint;

{date}
Function Packed_Date : longint;
Function Todays_Date:string;
Function Todays_Time:string;
Function Fix_Date(const s:string): string;
Function Days_Between(const stream1,stream2:string) : longint;
{time}
Function Give_Me_Time : string;
Function Hours_Between(const time1,time2:string) : integer;
Function Minutes_Between(const time1,time2:string) : longint;
{file stamp info...see file_io.pas}

{display}
Procedure Wrl(col:byte;const s:string); {replaces crt; writeln}
Procedure Wr(col:byte;const s:string);  {replaces crt; write}
Procedure D(col:byte;const text : string); {display a string of text with crlf at the end}
Procedure SD(col:byte;const text : string); {same as D, but without a crlf at the end}
Procedure SSwrite(const s:string); {call to DDplus SWRITE proc}
Procedure SSwriteC(const c:char); {call to DDplus SWRITEC}
Procedure Display_Text(const name : string);
Procedure Crlf; {provides a Line Feed/Return on both local and remote screen}
Procedure ClearScreen; {clears the screen on both local and remote side}
Procedure Pause; {pause prompt}

{Ansi Colors/Usurper control codes}
Function ConvertToAnsi(incolor:byte):string;
Function ConvertToUsurperAnsi(incolor:string):string;
Function ConvertToUsurperAnsi2(incolor:string):byte;
Function ConvertToUsurperAnsi3(incolor:byte):string;
Function Valid_Color(const incolor:string):boolean;
Function Strip(const out : string) : string; {remove all Usurper ansi}
Function Uconv(const out : string) : string; {Usurper ANSI -> standard ANSI}

{menu}
Procedure Show_Usurper_Data(const name:string;pausing:boolean);
Procedure Menu(const text:string);
Procedure Menu2(const text:string);
Procedure Menu3(const text:string; pos:integer);
Procedure Menu5(const text:string; pos:integer);
Function Menu_Choices(const m1,m2,m3,m4,m5:string):char;

{Other routines}
Procedure Normal_Exit; {HALT the program}
Function UKeyPressed : boolean; {same as pascal KeyPressed function}
Function GetChar : char; {get a character from local or remote keyboard}
Function UnderScore : char; {returns a '_'}
Function HeartSign : char; {returns a ''}
Function DeathSign : char; {returns a ''}
Function Confirm(const text: string; default:char):boolean; {Y/N confirmation}
Function Confirm2(const text: string; default:char):char; {Y/N/= confirmation}

{Misc}
Procedure Drop_Dos; {drop to dos}
Procedure Display_Bar_Status(force:boolean); {call to DDplus Display_Status (bar) proc}
Function Dos_Version : word;
Function Param_Hunt(const h:string) : boolean; {checking for Command Line parameters}

Implementation

Uses Dos, Crt, Init,
     DDplus,
     AnsiColr,
     Various, DispText,
     File_IO, DateUtils, VideoUtils, Comm, SysUtils;

var carriage_return : boolean; {used by D and SD procedures (display routines)}
    SavedX, SavedY: Word;
    ScreenBuffer: TScreenBuffer;


Function percent_string(num1,num2:integer):string;
var {originally from SWAG/MATH (calc_p1)}
 z:real;
 out1:string[10];
begin

 out1:='  0';
 if (num1=0) or (num2=0) then begin
  {}
 end
 else begin
  z:=num1/num2;
  str(z:2:2,out1);
  if out1='1.00' then begin
   out1:='100';
   percent_string:=out1;
   exit;
  end;
  delete(out1,1,2);
  if out1[1]='0' then delete(out1,1,1);
  while length(out1)<=2 do insert(' ',out1,1);
  if out1='0' then out1:='100';
  if out1='' then out1:='0';
 end;
 percent_string:=out1;

end; {percent_string *end*}

Function Long2Str(Number: LongInt): String;
var
 TempStr: string;

begin {converts longint to string}
 Str(Number,TempStr);
 Long2Str := TempStr;
end;

Function CommaStr(Number: LongInt): String;
var {converts longint to string + commas 1,000 or 10,000,000}
 StrPos: Integer;
 NumberStr: String;

begin
 NumberStr := Long2Str(Number);
 StrPos := Length(NumberStr) - 2;
 While StrPos > 1 do begin
  Insert(',',NumberStr,StrPos);
  StrPos := StrPos - 3;
 end;
 CommaStr := NumberStr;
end; {commastr *end*}

Function Str_To_Nr(const s:string) : longint;
var y : integer;
    i : longint;
begin

 val(s,i,y);

 if y<>0 then begin
  str_to_nr:=0;
 end
 else begin
  str_to_nr:=i;
 end;

end;

Function Str_To_Nr2(const s:string) : longint;
{same as str_to_nr2 with the exception that if an error is encountered
 the routine returns -1 instead of 0}
var y : integer;
    i : longint;
begin

 val(s,i,y);

 if y<>0 then begin
  str_to_nr2:=-1;
 end
 else begin
  str_to_nr2:=i;
 end;

end; {Str_To_Nr2 *end*}

Function Str_To_Real(const s:string) : real;
var y : integer;
    i : real;
begin

 val(s,i,y);

 if y<>0 then begin
  str_to_real:=0;
 end
 else begin
  str_to_real:=i;
 end;

end;


Function Dos_Version : word;
begin
 dos_version:=dosVersion; {Bp DosUnit function}
end;

Function Hours_Between(const time1,time2:string) : integer;
var s : s70;
    result : integer;
    hour1, hour2 : byte;
begin {calculates passed hours between ??:??:?? and ??:??:??}
      {result=time1-time2}

 s:=time1[1]+time1[2];
 hour1:=str_to_nr(s);

 s:=time2[1]+time2[2];
 hour2:=str_to_nr(s);

 result:=hour1-hour2;

 {return result}
 hours_between:=result;

end; {hours_between *end*}

Function Minutes_Between(const time1,time2:string) : longint;
var s : s70;
    hours,
    result : longint;
    minutes1, minutes2 : byte;
begin {calculates passed minutes between ??:??:?? and ??:??:??}
      {result=time1-time2}

 s:=time1[4]+time1[5];
 minutes1:=str_to_nr(s);

 s:=time2[4]+time2[5];
 minutes2:=str_to_nr(s);

 result:=minutes1-minutes2;

 {are there hours to add?}
 hours:=hours_between(time1,time2);
 if hours>0 then begin
  hours:=hours*60;
  result:=result+hours;
 end;

 {return result}
 minutes_between:=result;

end; {minutes_between *end*}

Function days_between(const stream1,stream2:string) : longint;
var {from SWAG (a pascal library) => date/time routines => Michael Hoenie}
    {stream1,stream2 can have the 'mm-dd-yy' or 'mm-dd-yyyy' format}
    {jakob has made two changes in the code. see 'jakob' comments in source.}
  internal1,internal2:longint;
  JNUM:real;
  month,day,year: integer;
  out:string[25];

function Jul( mo, da, yr: integer): real;
var
 i, j, k, j2, ju: real;
begin
 i := yr;     j := mo;     k := da;
 j2 := int( (j - 14)/12 );
 ju := k - 32075 + int(1461 * ( i + 4800 + j2 ) / 4 );
 ju := ju + int( 367 * (j - 2 - j2 * 12) / 12);
 ju := ju - int(3 * int( (i + 4900 + j2) / 100) / 4);
 Jul := ju;
end;

begin

  out:=copy(stream1,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  month := StrToIntDef(out, 0);
  out:=copy(stream1,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  day := StrToIntDef(out, 0);
  out:=copy(stream1,7,4); {jakob, original code is stream1,7,2) }
  if copy(out,1,1)='0' then delete(out,1,1);
  year := StrToIntDef(out, 0);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  internal1 := StrToIntDef(out, 0);
  out:=copy(stream2,1,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  month := StrToIntDef(out, 0);
  out:=copy(stream2,4,2);
  if copy(out,1,1)='0' then delete(out,1,1);
  day := StrToIntDef(out, 0);
  out:=copy(stream2,7,4); {jakob, original code is stream1,7,2) }
  if copy(out,1,1)='0' then delete(out,1,1);
  year := StrToIntDef(out, 0);
  jnum:=jul(month,day,year);
  str(jnum:10:0,out);
  internal2 := StrToIntDef(out, 0);

  {return result}
  days_between:=internal1-internal2;

end; {days_between *end*}

Procedure CleanString(Var s:String);
begin
  fillChar(s,sizeof(s),0);
end;

Function EmptyStr : string;
var s : string;
begin
 cleanstring(s);
 emptystr:=s;
end;

Function Replace_String;
var p : INTEGER;
begin

 while POS( Old, Source ) <> 0 do begin
  p := POS( Old, Source );
  delete( Source, p, length( Old ) );
  insert( New, Source, p );
 end;
 Replace_String := Source;

end; { Replace String }

Function GetChar; {get a character from the local or remote keyboard}
var temp : char;
begin

 {init}
 temp:=' ';

 {read keyboard}
 sread_char(temp); {ddplus function}

 {return the result}
 getchar:=upcase(temp);

end; {getchar *end*}

Procedure Wrl(col:byte;const s:string); {replacement for crt Writeln}
begin
 TextColor(col);
 writeln(s);
end; {wrl *end*}

Procedure Wr(col:byte;const s:string); {replacement for crt Write}
begin
 TextColor(col);
 write(s);
end;


Procedure D; {displays the string TEXT to the screen. this routine
              accepts usurpers own ANSI control codes.}
var i : word;
    fore_col,
    back_col : byte;

    p : string[3];
begin

 if (global_cfor<>col) and (global_ansi) then begin

  if global_carrierdropped then begin
   write('');
  end
  else begin
   global_cfor:=col;
   set_foreground(col);
   sswrite('');
  end;
 end;

 if text='' then begin
  if carriage_return=true then begin
   crlf;
  end;
  exit;
 end;

 i:=1;
 back_col:=global_cback;
 repeat
  Case Text[i] of
   acc:begin

        {get first/next three characters from string}
        p:=text[i]+text[i+1]+text[i+2];

        if      p = ublack  then fore_col:=0
        else if p = ublue   then fore_col:=1
        else if p = ugreen  then fore_col:=2
        else if p = ucyan   then fore_col:=3
        else if p = ured    then fore_col:=4
        else if p = umag    then fore_col:=5
        else if p = ubrown  then fore_col:=6
        else if p = ulgray  then fore_col:=7
        else if p = udgray  then fore_col:=8
        else if p = ulblue  then fore_col:=9
        else if p = ulgreen then fore_col:=10
        else if p = ulcyan  then fore_col:=11
        else if p = ulred   then fore_col:=12
        else if p = ulmag   then fore_col:=13
        else if p = uyellow then fore_col:=14
        else if p = uwhite  then fore_col:=15

        else if p = backUblack then back_col:=0
        else if p = backUblue  then back_col:=1
        else if p = BackUGreen then back_col:=2
        else if p = BackUCyan  then back_col:=3
        else if p = BackURed   then back_col:=4
        else if p = BackUMagenta then back_col:=5
        else if p = BackUBrown   then back_col:=6
        else if p = BackULGray   then back_col:=7


        else begin
         {fore_col:=2;}
        end;

        i:=i+2;

        if global_ansi then begin

         if global_carrierdropped=false then begin

          if global_cfor<>fore_col then begin
           global_cfor:=fore_col;
           set_foreground(fore_col);
          end;

          if global_cback<>back_col then begin
           global_cback:=back_col;
           set_background(back_col);
          end;

         end;
        end;

       end;
   else begin
    if global_carrierdropped=false then begin
     ssWrite(Text[I]);
    end
    else begin
     write(text[i]);
    end;
   end;
  end; {case .end.}
  inc(i);

 until I>Length(Text);

 if carriage_return then begin
  crlf;
 end;
 {swriteln(text); {ddplus routine}

end; {D **END**}

Procedure SSwrite(const s:string); {call to DDplus SWRITE proc}
begin
 {trying to make it easy to switch to another door kit}
 swrite(s);
end;

Procedure SSwriteC(const c:char); {call to DDplus SWRITEC proc}
begin
 {trying to make it easy to switch to another door kit}
 swritec(c);
end;


Procedure SD; {same as the procedure D above, with the exception that no
               crlf is added at the end of the line}
begin

 carriage_return:=false;
 d(col,text);
 carriage_return:=true;

end;

Function Confirm;
const Yadd = ' ? ([Y]/N)';
      Nadd = ' ? (Y/[N])';

var ch : char;
   result : boolean;
begin

 {default choice : Y or N}
 default:=upcase(default);

 case default of
  'Y':begin
       result:=true;
       sd(config.textcolor,text+Yadd);
      end;
  else begin
        default:='N';
        result:=false;
        sd(config.textcolor,text+Nadd);
       end;
 end; {case .end.}

 {get user-input}
 repeat
  ch:=getchar;
 until ch in ['Y','N',ReturnKey];

 {evaluate user-input}
 if (ch=ReturnKey) and (default='Y') then ch:='Y';
 if (ch=ReturnKey) and (default='N') then ch:='N';

 case ch of
  'Y':begin
       result:=true;
       sd(config.textcolor,' Yes');
      end;
  'N':begin
       result:=false;
       sd(config.textcolor,' No');
      end;
 end; {case .end.}

 crlf;
 {return result}
 confirm:=result;

end; {confirm *end*}

Function Confirm2;
const Yadd = ' ? ([Y]/N/=)';
      Nadd = ' ? (Y/[N]/=)';
      Eadd = ' ? (Y/N/[=])';

var ch : char;
   result : char;
begin

 {default choice : Y, N or =}
 default:=upcase(default);

 case default of
  'Y':begin
       result:='Y';
       default:='Y';
       sd(config.textcolor,text+Yadd);
      end;
  'N':begin
       result:='N';
       default:='N';
       sd(config.textcolor,text+Nadd);
      end;
  '=':begin
       result:='=';
       default:='=';
       sd(config.textcolor,text+Eadd);
      end;
 end; {case .end.}

 {get user-input}
 repeat
  ch:=getchar;
 until ch in ['Y','N','=',ReturnKey];

 {evaluate user-input}
 if (ch=ReturnKey) and (default='Y') then ch:='Y';
 if (ch=ReturnKey) and (default='N') then ch:='N';
 if (ch=ReturnKey) and (default='=') then ch:='=';

 case ch of
  'Y':begin
       result:='Y';
       sd(config.textcolor,' Yes');
      end;
  'N':begin
       result:='N';
       sd(config.textcolor,' No');
      end;
  '=':begin
       result:='=';
       sd(config.textcolor,' =');
      end;
 end; {case .end.}

 crlf;
 {return result}
 confirm2:=result;

end; {confirm2 *end*}

Function Packed_Date : longint;
begin
 packed_date:=DaysSince1Jan0001;
end;

Function MkString;
var
    i : integer;
    temp : string;

begin

 temp:='';

 for i:=1 to nr do begin
  temp:=temp+s;
 end;

 {return result}
 mkstring:=temp;

end; {mkstring *end*}

Function Cool_string(lngth:integer;char1,char2:char;col1,col2:integer) : string;
var s : string;
   turn1:boolean;
begin

 {creates a string containing every other char1 and char2, with colors col1 and col2}
 s:='';
 turn1:=true;
 while lngth>0 do begin
  if turn1 then begin
   if col1<>col2 then begin
    s:=s+ConvertToUsurperAnsi3(col1);
   end;
   s:=s+char1;
   turn1:=false;
  end
  else begin
   if col1<>col2 then begin
    s:=s+ConvertToUsurperAnsi3(col2);
   end;
   s:=s+char2;
   turn1:=true;
  end;
  dec(lngth);
 end; {while *end*}

 {return result}
 cool_string:=s;

end; {cool_string *end*}

Function Ljust;
var temp : string;
    diff : integer;
begin

 temp:='';
 if length(s)>max then begin
  temp:=copy(s,1,max);
 end
 else if length(s)<max then begin
  diff:=max-length(s);
  temp:=s+mkstring(diff,' ');
 end
 else begin
  temp:=s;
 end;

 ljust:=temp;

end; {ljust *end*}

Function Rjust;
var temp : string;
    diff : integer;
begin
 temp:='';
 if length(s)>max then begin
  temp:=copy(s,1,max);
 end
 else if length(s)<max then begin
  diff:=max-length(s);
  temp:=mkstring(diff,' ')+s;
 end
 else begin
  temp:=s;
 end;

 rjust:=temp;
end; {rjust *end*}

Function padright(const st:string;ch:char;l:integer):string;
var
    i : integer;
    tempstr : string;

begin
 tempstr := st;
 if length(tempstr) > l then
  tempstr[0] := chr(l);
 if length(tempstr) < l then begin
  for i := length(tempstr)+1 to l do
  tempstr[i] := ch;
  tempstr[0] := chr(l);
 end;

 {return result}
 padright := tempstr;

end; {padright *end*}

Procedure AddBackSlash(Var InPath: String);
Begin
 If Length(InPath) > 0 Then Begin
  If InPath[Length(InPath)] <> DIRECTORY_SEPARATOR Then Begin
   InPath[0] := Chr(Length(InPath) + 1);
   InPath[Length(InPath)] := DIRECTORY_SEPARATOR;
  End;
 End;
End; {addbackslash *end*}


Function WithBackSlash(InPath: String): String;
Begin
 AddBackSlash(InPath);
 WithBackSlash := InPath;
End; {withbackslash *end*}

function striplead(st:string;ch:char):string;
var
 tempstr:        string;

begin
 tempstr := st;
 while ((TempStr[1] = Ch) and (Length(TempStr) > 0)) do begin
  tempstr := copy (tempstr,2,length(tempstr));
 end;
 striplead := tempstr;
end; {striplead *end*}

Procedure Remove_Commas;
var s : string;
    i : integer;
begin

 s:='';

 for i:=1 to length(gulp) do begin
  if (gulp[i]<>',') and (gulp[i]<>'.') then begin
    s:=s+gulp[i];
  end;
 end; {for i:= .end.}

 gulp:=s;

end;

Procedure Pause; {one of the most used procedures in the game! PAUSE}
var a : char;
begin

{ if global_ansi then begin
  set_color(config.textcolor,0);
 end;
}
 sd(8,'[Press a key]');

 sread_char(a);
 crlf;

end; {pause *end*}

Procedure Show_Usurper_Data(const name:string;pausing:boolean);
{show ansi/text/data from the usurper resource file}
var
    ch : char;

    quit,
    read_data,
    ansisave,
    matching,
    suspect_mode : boolean;

    c : integer;

    f : text;

    s : string;

begin

 {keep ansi variable}
 ansisave:=ansion;
 ansion:=true; {process ansi locally, ddplus variable}
 quit:=false;

 suspect_mode:=false;
 read_data:=false;

 if open_txtfile(treset,f,global_datadir+global_textdataf) then begin

  while (not eof(f)) and (not quit) do begin

   if read_data then begin
    read(f,ch);
    if (not suspect_mode) and (ch='@') then begin
     suspect_mode:=true;
    end
    else if suspect_mode then begin
     if ch='#' then begin
      quit:=true;
     end
     else begin
      sswritec('@');
      sswritec(ch);
     end;
    end
    else begin
    sswritec(ch);
    end;
   end
   else begin
    {find start of picture}
    s:='@#'+UpperCase(name);
    if global_ansi then s:=s+'.ANS'
                   else s:=s+'.ASC';

    matching:=false;
    c:=1;
    while (not eof(f)) and (not read_data) do begin

     read(f,ch);

     if (not matching) and (ch=s[c]) then begin
      inc(c);
      matching:=true;
     end
     else if (matching) and (ch=s[c]) then begin
      inc(c);
      if c>length(s) then begin
       read_data:=true;
      end;
     end
     else if (matching) and (ch<>s[c]) then begin
      c:=1;
      matching:=false;
     end;

    end; {while .end.}

   end;

  end; {while .end.}

  {close textfile}
  close(f);

 end
 else begin
  {error accessing resource file}
  unable_to_access(global_datadir+global_textdataf,access_error);
 end;

 {picture not found}
 if not read_data then begin
  Unable_to_find(s);
  pause;
 end;

 set_foreground(default_fore);
 {restore ansi variable}
 ansion:=ansisave;

 {should we pause?}
 if pausing then pause;

end; {show_usurper_data *end*}

Function Menu_Choices(const m1,m2,m3,m4,m5:string):char;
const nada='@';
      offset=2;

var
    ch1,ch2,ch3,ch4,ch5,

    ch : char;

begin
 {create some simple menus}

 ch1:=nada;
 ch2:=nada;
 ch3:=nada;
 ch4:=nada;
 ch5:=nada;

 repeat
  if m1<>'' then begin
   menu(m1);
   ch1:=m1[offset];
  end;

  if m2<>'' then begin
   menu(m2);
   ch2:=m2[offset];
  end;

  if m3<>'' then begin
   menu(m3);
   ch3:=m3[offset];
  end;

  if m4<>'' then begin
   menu(m4);
   ch4:=m4[offset];
  end;

  if m5<>'' then begin
   menu(m5);
   ch5:=m5[offset];
  end;

  sd(config.textcolor,':');

  {get user-input}
  ch:=upcase(getchar);

 until (ch in [ch1,ch2,ch3,ch4,ch5]) and NOT (ch in [nada]);
 d(10,ch);

 {return result}
 menu_choices:=ch;

end; {menu_choices *end*}

Procedure Menu5;
begin

 {first bracket}
 sd(config.bracketcolor,copy(text,1,1));

 {hot key}
 sd(config.hotkeycolor,copy(text,2,pos));

 {second bracket}
 sd(config.bracketcolor,copy(text,pos+2,1));

 {rest of text}
 sd(config.textcolor,copy(text,pos+3,99));

end; {menu5 *end*}

Procedure Menu3;
begin

 {first bracket}
 sd(config.bracketcolor,copy(text,1,pos-1));

 {hot key}
 sd(config.hotkeycolor,copy(text,pos,1));

 {second bracket}
 sd(config.bracketcolor,copy(text,pos+1,1));

 {rest of text}
 sd(config.textcolor,copy(text,pos+2,99));

end; {menu3 *end*}

Procedure Menu2; {same as menu() except for not having a CRLF at the end}
begin

 {first bracket}
 sd(config.bracketcolor,copy(text,1,1));

 {hot key}
 sd(config.hotkeycolor,copy(text,2,1));

 {second bracket}
 sd(config.bracketcolor,copy(text,3,1));

 {rest of text}
 sd(config.textcolor,copy(text,4,99));


end; {menu2 *end*}

Procedure Menu;
begin

 {first bracket}
 sd(config.bracketcolor,copy(text,1,1));

 {hot key}
 sd(config.hotkeycolor,copy(text,2,1));

 {second bracket}
 sd(config.bracketcolor,copy(text,3,1));

 {rest of text}
 sd(config.textcolor,copy(text,4,99));

 {return}
 crlf;

end; {menu *end*}

Procedure Crlf; {Return/Enter}
begin
 if global_carrierdropped=false then begin
  swriteln(''); {ddplus function}
 end
 else begin
  writeln('');
 end;
end; {crlf *end*}

Procedure ClearScreen; {clears screen on both remote/local sides}
begin

 if global_carrierdropped=false then begin
  SCLRSCR; {ddplus function}
 end
 else begin
  ClrScr;
 end;

end; {clearscreen *end*}

Function Strip; {strips string from Usurper ANSI codes}
var
    i : integer;
    s : string;

    cfor,
    cback : byte;

    p : string[3];
    ok,fin : boolean;
begin

 fin:=false;
 cfor:=global_cfor;
 s:=out;
 i:=1;

 repeat
  ok:=false;
  p:=copy(s,i,3);

  {kolla om ansi tecken finns}
  if      p = ublack  then cfor:=0
  else if p = ublue   then cfor:=1
  else if p = ugreen  then cfor:=2
  else if p = ucyan   then cfor:=3
  else if p = ured    then cfor:=4
  else if p = umag    then cfor:=5
  else if p = ubrown  then cfor:=6
  else if p = ulgray  then cfor:=7
  else if p = udgray  then cfor:=8
  else if p = ulblue  then cfor:=9
  else if p = ulgreen then cfor:=10
  else if p = ulcyan  then cfor:=11
  else if p = ulred   then cfor:=12
  else if p = ulmag   then cfor:=13
  else if p = uyellow then cfor:=14
  else if p = uwhite  then cfor:=15

  {background color}
  else if p = backublack then cback:=0
  else if p = backublue then  cback:=2
  else if p = BackUGreen then cback:=2
  else if p = BackUCyan  then cback:=3
  else if p = BackURed   then cback:=4
  else if p = BackUMagenta then cback:=5
  else if p = BackUBrown   then cback:=6
  else if p = BackULGray   then cback:=7

  else begin
   ok:=true;
  end;

  if NOT ok then begin
   delete(s,i,3);
   i:=1;
  end
  else begin
   inc(i);
  end;

  if i>length(out) then fin:=true;

 until fin;

 {return stripped string}
 strip:=s;

end; {strip *end*}

function backcolr(back_col:byte) : s14;
var s : s14;
begin

 {init}
 s:='';

 {hitler complete!}

 case global_cfor of
  12:begin {light-red text on back_col background}
      case back_col of
       0: s:=AbRedonBlack; {black}
       1: s:=AbRedonBlue;  {blue}
       2: s:=AbRedonGreen; {green}
       3: s:=AbRedonCyan;  {cyan}
       4: s:=AbRedonRed;   {red}
       5: s:=AbRedonMagenta; {magenta}
       6: s:=AbRedonBrown; {brown}
       7: s:=AbRedonLtGray;{light-gray}
      end; {case .end.}
    end; {light-red *end*}
  13:begin {light-magenta text on back_col background}
      case back_col of
       0: s:=AbMagentaonBlack; {black}
       1: s:=AbMagentaonBlue;  {blue}
       2: s:=AbMagentaonGreen; {green}
       3: s:=AbMagentaonCyan;  {cyan}
       4: s:=AbMagentaonRed;   {red}
       5: s:=AbMagentaonMagenta; {magenta}
       6: s:=AbMagentaonBrown; {brown}
       7: s:=AbMagentaonLtGray;{light-gray}
      end; {case .end.}
    end; {light-magenta *end*}
  14:begin {yellow text on back_col background}
      case back_col of
       0: s:=AYellowonBlack; {black}
       1: s:=AYellowonBlue;  {blue}
       2: s:=AYellowonGreen; {green}
       3: s:=AYellowonCyan;  {cyan}
       4: s:=AYellowonRed;   {red}
       5: s:=AYellowonMagenta; {magenta}
       6: s:=AYellowonBrown; {brown}
       7: s:=AYellowonLtGray;{light-gray}
      end; {case .end.}
    end; {yellow *end*}
  15:begin {white text on back_col background}
      case back_col of
       0: s:=AWhiteonBlack; {black}
       1: s:=AWhiteonBlue;  {blue}
       2: s:=AWhiteonGreen; {green}
       3: s:=AWhiteonCyan;  {cyan}
       4: s:=AWhiteonRed;   {red}
       5: s:=AWhiteonMagenta; {magenta}
       6: s:=AWhiteonBrown; {brown}
       7: s:=AWhiteonLtGray;{light-gray}
      end; {case .end.}
    end; {white *end*}
 end; {case .end.}

 {return result}
 backcolr:=s;

end; {backcolr *end*}

Function Uconv; {converts Usurper ANSI codes to real ANSI}
var
    i : integer;
    s : string;
    c : s70;
    p : string[3];
    ok,fin : boolean;


begin

 fin:=false;
 s:=out;
 i:=1;
 c:=AGreenOnBlack; {default Ansi Color}

 repeat
  ok:=false;
  p:=copy(s,i,3);

  {check for (foreground) control string}
  if      p = ublack  then c:=AblackonBlack
  else if p = ublue   then c:=ABlueonBlack
  else if p = ugreen  then c:=AGreenonBlack
  else if p = ucyan   then c:=ACyanonBlack
  else if p = ured    then c:=ARedonBlack
  else if p = umag    then c:=AMagentaonBlack
  else if p = ubrown  then c:=ABrownonBlack
  else if p = ulgray  then c:=ALtGrayonBlack
  else if p = udgray  then c:=ADkGrayonBlack
  else if p = ulblue  then c:=ALtBlueonBlack
  else if p = ulgreen then c:=ALtGreenonBlack
  else if p = ulcyan  then c:=ALtCyanOnBlack
  else if p = ulred   then c:=ALtRedonBlack
  else if p = ulmag   then c:=ALtMagentaonBlack
  else if p = uyellow then c:=AYellowonBlack
  else if p = uwhite  then c:=AWhiteonBlack

  {check for (background) control string}
  else if p = backublack then c:=backcolr(0)
  else if p = backublue then c:=backcolr(1)
  else if p = BackUGreen then c:=backcolr(2)
  else if p = BackUCyan  then c:=backcolr(3)
  else if p = BackURed   then c:=backcolr(4)
  else if p = BackUMagenta then c:=backcolr(5)
  else if p = BackUBrown   then c:=backcolr(6)
  else if p = BackULGray   then c:=backcolr(7)

  else begin
   ok:=true;
  end;

  if NOT ok then begin
   delete(s,i,3);

   insert(C,s,i);

   i:=1;
  end
  else begin
   inc(i);
  end;

  if i>length(s) then fin:=true;

 until fin;

 uconv:=s;

end; {uconv *end*}

Procedure Get_StringW;
var s2 : string;
begin

 {move string to temporary workspace}
 s2:=s;

 {get a string, using DDplus routine}
 promptwr(s2,maxlength,false);

 {Remove BadWords}
 s2:=remove_badwords(s2);

 {return result}
 s:=s2;

end; {get_stringw *end*}

Function Get_StringSec; {get a string, chars are echoed back as CH}
var result : string;
begin

 result:=emptystr;
 promptsec(result,maxlength,false,ch);

 {Remove BadWords
  We skip badwords check here...players wont be happy if team password is
  SHIT and its changed, they will not know what their password is!
{ s:=remove_badwords(s);}

 {return result}
 get_stringsec:=result;

end; {get_stringsec *end*}

Function Get_String;
var result : string;
begin

 {init vars}
 result:='';

 {ddplus "get string" routine}
 promptj(result,maxlength,false,true);

 {Remove BadWords}
 result:=remove_badwords(result);

 {return result}
 get_string:=result;

end; {get_string *end*}

Procedure Get_StringDefault;
begin

 {the same as GET_STRING, but here DEFAULT is printed out as default input
 }

 {ddplus "get string" routine}
 promptj(default,maxlength,false,false);

 {Remove BadWords}
 default:=remove_badwords(default);

end; {get_stringdefault *end*}


Procedure Door_left(howmany: byte);
Begin

 If local then begin
  gotoxy(wherex-howmany,wherey);
 end
 else begin

  if global_ansi then begin
   swrite(#27'['+IntToStr(howmany)+'D');
  end
  else begin
   for howmany := 1 to howmany do begin
    swrite(#8);
   end;
  end;
 end;

end; {door_left *end*}

Procedure Door_Right(howmany: byte);
Begin

 If local then begin
  gotoxy(wherex + howmany,wherey);
 end
 else begin
  if global_ansi then begin
   swrite(#27'['+IntToStr(howmany)+'C');
  end
  else begin
   for howmany := 1 to howmany do begin
    swrite(#32);
   end;
  end;
 end;

End; {door_right *end*}


Function Get_A_Number(rmin,rmax,default:longint):longint;
{Input routine character by character, and with special keys to produce
 various results: MaxInput_Key}
const thousand_key = 'K';
      million_key  = 'M';

var result : longint;
    x : longint;
    s : s70;
    ok : boolean;
    i : byte;
    ch : char;
begin

 {init vars}
 result:=0;
 s:='';
 ok:=false;

 {Delete: (#0+_Delete,#127,#127)  tty/ansi/avatar}

 repeat

  {get user-input}
  ch:=upcase(getchar);

  {evaluate user-input}
  case ch of
   Thousand_Key:begin {user has pressed K}

                 if length(s)+3<=10 then begin
                  sd(config.textcolor,'000');
                  s:=s+'000';
                 end
                 else if length(s)<10 then begin
                  repeat
                   sd(config.textcolor,'0');
                   s:=s+'0';
                  until length(s)=10;
                 end;

                end;
   Million_Key:begin {user has pressed M}

                if length(s)+6<=10 then begin
                 sd(config.textcolor,'000000');
                 s:=s+'000000';
                end
                else if length(s)<10 then begin
                 repeat
                  sd(config.textcolor,'0');
                  s:=s+'0';
                 until length(s)=10;
                end;
               end;

   MaxInput_Key:begin {Special Key to get MAX value has been pressed}

                 {erase current characters}
                 for i:=1 to length(s) do begin
                  door_left(1);
                  sd(config.textcolor,' ');
                  door_left(1);
                 end; {for i:= .end.}

                 {set string to max value}
                 s:=long2str(rmax);
                 if s='' then s:='0';

                 sd(config.textcolor,s);

           end;
   ReturnKey:begin {Return/Enter key pressed}
              {check if string is valid}

              {has a default value been defined by calling procedure?}
              if default<>-1 then begin
               if s='' then begin
                if default>rmax then default:=rmax;
                s:=long2str(default);
               end;
              end
              else begin
               if s='' then s:='0';
              end;

              x:=str_to_nr2(s);

              if (x>rmax) or (x<rmin) then begin
               crlf;
               d(config.textcolor,'(a number in the range '+ulgray+commastr(rmin)+config.textcol1+' .. '+ulgray+commastr(rmax)+
                                   config.textcol1+' please!)');
               sd(config.textcolor,':');
               {reset string}
               s:='';
              end
              else begin
               ok:=true;
              end;

             end;
   DeleteKey:begin {Delete key pressed}
              if length(s)>0 then begin
               door_left(1);
               sd(config.textcolor,' ');
               door_left(1);
               {delete character from string}
               delete(s,length(s),1);
              end;
             end;
   '0'..'9':begin {valid number pressed}
             if length(s)<10 then begin
              sd(config.textcolor,ch);
              s:=s+ch;
             end;
            end;
  end; {case .end.}
 until ok;

 {convert string to number}
 result:=str_to_nr(s);

 {return result}
 get_a_number:=result;

 crlf;

end; {get_a_number *end*}

Function Get_Number;
var result : longint;
begin

 {call universal numeric input routine}
 result:=get_a_number(rmin,rmax,-1);

 {return reslut}
 get_number:=result;

end; {get_number *end*}

Function Get_Number2; {same as get_number, but with ability to accept a
                       default value in the parameter list}
var result : longint;
begin

 {call universal numeric input routine}
 result:=get_a_number(rmin,rmax,default);

 {return result}
 get_number2:=result;

end; {get_number2 *end*}

Function Get_Number_Old; {get a number from the user}
var s : string;
    x : longint;
    bye:boolean;
    result : longint;

begin

 {init vars}
 result:=0;
 bye:=false;

 repeat

  {empty string}
  s:=emptystr;

  {lets get a string from the user}
  promptj(s,20,false,true);

  {we remove the ',' och '.'}
  remove_commas(s);

  {if user presses return}
  if s='' then s:='0';

  {convert the string to a numeric}
  x:=str_to_nr(s);

  {is input within the boundaries defined by calling paramters}
  if (x>rmax) or (x<rmin) then begin
   d(config.textcolor,'(a number in the range '+commastr(rmin)+'..'+commastr(rmax)+' please!)');
   sd(config.textcolor,':');
  end
  else begin
   result:=x;
   bye:=true;
  end;

 until bye; {loop until valid value is returned}

 {return result}
 get_number_old:=result;

end;

const
 hexid: array[$00..$0F] of char = '0123456789ABCDEF'; { For dec to hex }

Function IntToHex(num: longint; digits: byte): String;
var
  s: String;
  c: byte;
  n: array[1..sizeof(longint)] of byte absolute num;
begin
  s := '';
  for c := 4 downto 1 do s := s + hexid[n[c] shr 4]+hexid[n[c] and $F];
  IntToHex := copy(s,8-digits+1,digits);
End;

Function IntToStr(Num: longint): String;
{ This function takes an integer value, and creates a string }
Var st: string;
Begin
  Str(Num,St);
  IntToStr := st;
End;

Function Valid_Color(const incolor:string):boolean;
var result : boolean;
begin

 result:=false;

 if UpperCase(incolor)='BLACK' then result:=true
 else if UpperCase(incolor)='BLUE' then result:=true
 else if UpperCase(incolor)='GREEN' then result:=true
 else if UpperCase(incolor)='CYAN' then result:=true
 else if UpperCase(incolor)='RED' then result:=true
 else if UpperCase(incolor)='MAGENTA' then result:=true
 else if UpperCase(incolor)='BROWN' then result:=true
 else if UpperCase(incolor)='LIGHTGRAY' then result:=true
 else if UpperCase(incolor)='DARKGRAY' then result:=true
 else if UpperCase(incolor)='LIGHTBLUE' then result:=true
 else if UpperCase(incolor)='LIGHTGREEN' then result:=true
 else if UpperCase(incolor)='LIGHTCYAN' then result:=true
 else if UpperCase(incolor)='LIGHTRED' then result:=true
 else if UpperCase(incolor)='LIGHTMAGENTA' then result:=true
 else if UpperCase(incolor)='YELLOW' then result:=true
 else if UpperCase(incolor)='WHITE' then result:=true;

 {return result}
 valid_color:=result;

end; {valid_color *end*}

Function ConvertToUsurperAnsi(incolor:string):string;
var result : string[14];
begin

 incolor:=UpperCase(incolor);
 result:=ugreen;

 if incolor='BLACK' then             result:=ublack
 else if incolor='BLUE' then         result:=ublue
 else if incolor='GREEN' then        result:=ugreen
 else if incolor='CYAN' then         result:=ucyan
 else if incolor='RED' then          result:=ured
 else if incolor='MAGENTA' then      result:=umag
 else if incolor='BROWN' then        result:=ubrown
 else if incolor='LIGHTGRAY' then    result:=ulgray
 else if incolor='DARKGRAY' then     result:=udgray
 else if incolor='LIGHTBLUE' then    result:=ulblue
 else if incolor='LIGHTGREEN' then   result:=ulgreen
 else if incolor='LIGHTCYAN' then    result:=ulcyan
 else if incolor='LIGHTRED' then     result:=ulred
 else if incolor='LIGHTMAGENTA' then result:=ulmag
 else if incolor='YELLOW' then       result:=uyellow
 else if incolor='WHITE' then        result:=uwhite;

 {return result}
 ConvertToUsurperAnsi:=Result;

end; {converttousurperansi *end*}

Function ConvertToUsurperAnsi2(incolor:string):byte;
var result : byte;
begin

 incolor:=UpperCase(incolor);
 result:=2;

 if incolor='BLACK' then result:=0
 else if incolor='BLUE' then result:=1
 else if incolor='GREEN' then result:=2
 else if incolor='CYAN' then result:=3
 else if incolor='RED' then result:=4
 else if incolor='MAGENTA' then result:=5
 else if incolor='BROWN' then result:=6
 else if incolor='LIGHTGRAY' then result:=7
 else if incolor='DARKGRAY' then result:=8
 else if incolor='LIGHTBLUE' then result:=9
 else if incolor='LIGHTGREEN' then result:=10
 else if incolor='LIGHTCYAN' then result:=11
 else if incolor='LIGHTRED' then result:=12
 else if incolor='LIGHTMAGENTA' then result:=13
 else if incolor='YELLOW' then result:=14
 else if incolor='WHITE' then result:=15;

 {return result}
 ConvertToUsurperAnsi2:=Result;

end;

Function ConvertToUsurperAnsi3(incolor:byte):string;
var s : string[3];
begin

 case InColor of
  0: s:=ublack;
  1: s:=ublue;
  2: s:=ugreen;
  3: s:=ucyan;
  4: s:=ured;
  5: s:=umag;
  6: s:=ubrown;
  7: s:=ulgray;
  8: s:=udgray;
  9: s:=ulblue;
  10:s:=ulgreen;
  11:s:=ulcyan;
  12:s:=ulred;
  13:s:=ulmag;
  14:s:=uyellow;
  15:s:=uwhite;
  else s:='';
 end; {case .end.}

 {return result}
 converttoUsurperAnsi3:=s;

end; {converttoUsurperAnsi3 *end*}

Function ConvertToAnsi(incolor:byte):string;
var s9:string[14];
begin

 case InColor of
  0: s9:=ABlackOnBlack;
  1: s9:=ABlueOnBlack;
  2: s9:=AGreenOnBlack;
  3: s9:=ACyanOnBlack;
  4: s9:=ARedOnBlack;
  5: s9:=AMagentaonBlack;
  6: s9:=ABrownOnBlack;
  7: s9:=ALtGrayOnBlack;
  8: s9:=ADkGrayOnBlack;
  9: s9:=ALtBlueOnBlue;
  10: s9:=ALtGreenOnBlack;
  11: s9:=ALtCyanOnBlack;
  12: s9:=ALtRedOnBlack;
  13: s9:=ALtMagentaOnBlack;
  14: s9:=AYellowOnBlack;
  15: s9:=AWhiteOnBlack;
  else s9:=AGreenOnBlack;
 end; {case .end.}

 {return result}
 ConvertToAnsi:=s9;

end; {ConvertToAnsi *end*}

Function FindSub(const s1,s2:string):boolean; {is s1 somewhere in s2?}
begin

 if s1='' then begin
  findsub:=true;
 end
 else begin

  if pos(UpperCase(s1),UpperCase(s2))>0 then findsub:=true
                                        else findsub:=false;
 end;

end; {findsub *end*}

Function LeadingZero(w : Word) : String;
Var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then begin
   s := '0' + s;
  end;

  {return result}
  LeadingZero := s;

end; {leadingzero *end*}


Function Give_Me_Time : string;
{returns current time in a 'h:m:s' format}
var
   Hour, Minute, Second, Sec100 : word;
   h,m,s : string[20];
begin

 GetTime(Hour, Minute, Second, Sec100);

 h:=commastr(hour);
 m:=commastr(minute);
 s:=commastr(second);

 if length(h)<2 then h:='0'+h;
 if length(m)<2 then m:='0'+m;
 if length(s)<2 then s:='0'+s;

 {return result}
 give_me_time:=h+':'+m+':'+s;

end; {give_me_time *end*}

Function HeartSign; {used in relation procs to indicate LOVE situations}
begin
 HeartSign:=chr(3);
end;

Function DeathSign; {used in relation procs to indicate DEATH/HATE situations}
begin
 DeathSign:='+';
end;

Function UnderScore; {character used to represent underscore sign}
begin
 underscore:=chr(196);
end;

Function Todays_Time; {time string[8]}
var
 hour, min, sec, sec100: word;
 result: string[8];
begin  {original code taken from the "date" function in ddscott.pas}

 gettime(hour,min,sec,sec100);

 result:=LeadingZero(hour)+':'+
         LeadingZero(min)+':'+
         LeadingZero(sec);

 {return result}
 Todays_time:=result;

end; {todays_time *end*}

Function Todays_Date; {date string[8] american, mm dd yyyy}
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

end; {todays_date *end*}

Function Fix_Date; {fixes 8 string date strings}
begin
 fix_date:=s[1]+s[2]+'-'+s[3]+s[4]+'-'+s[5]+s[6]+s[7]+s[8];
end;

Procedure Display_Text;
begin
 display_utext(name);
end;

Procedure Drop_Dos; {Sysop/local user has activated DROP TO DOS function}
begin

 if not local then begin
  d(15,'A God has entered the underworld ...');
  crlf;
  d(14,'Suddenly you feel a strong hand on your shoulder ...');
  d(14,'You try to turn around but can''t. You hear a deep voice :');
  d(15,'"Please rest a while my friend! I must attend to some');
  d(15,'important things in this realm."');
 end
 else begin
  crlf;
  d(15,'Shell to DOS ...');
  writeln(' type "EXIT" to return)');
 end;

 ScreenSave(ScreenBuffer);
 SavedX := WhereX;
 SavedY := WhereY;
 if not local then CommClose(false);
 swapvectors;
 Exec(getenv('COMSPEC'),'');
 swapvectors;
 if not local then CommOpen(com_port);
 ScreenRestore(ScreenBuffer);
 GotoXY(SavedX, SavedY);

 if not local then begin
  crlf;
  d(15,'A God is back from the underworld ...');
  crlf;
  d(14,'A spell is lifted from you. You can move again!');
  d(14,'Perhaps it was just a dream ...');
 end
 else begin
  crlf;
  d(15,'Back from DOS ...');
 end;

 {Has Screen Size Changed}
 if local then begin
  global_screenlines:=ScreenSizeY-1; {-1 because the statline takes up 1}
  {this is also used in usurper.pas}
 end;


{ savescreen;
 if not local then AsyncCloseUp;
 swapvectors;
 exec(getenv('COMSPEC'),'');
 swapvectors;
 if not local then AsyncSelectPort(com_port);
 restorescreen;
}

end; {drop_dos *end*}

Procedure Display_Bar_Status; {call to DDplus Display_Status (bar) proc}
begin
 if (statline) then display_status(force);
end;

Function Param_Hunt; {checking for Command Line parameters}
var i : byte;
begin

 param_hunt:=false;
 if paramcount>0 then begin
  for i:=1 to paramcount do begin
   if UpperCase(paramstr(i))=h then begin
    param_hunt:=true;
    break;
   end;
  end;
 end;

end; {param_hunt *end*}

Function UKeyPressed : boolean; {same as pascal KeyPressed function}
begin
 Ukeypressed := sKeyPressed; {using ddplus function skeypressed}
end;

Procedure Normal_Exit; {exit program}
begin
 halt(0);
end;

Procedure Spin_Cursor(action,cursor_color:byte);
const sc: array[0..3] of char = '-\|/';

procedure take_a_spin(pause_it:boolean);
begin
 global_place := (global_place+1) mod 4;
 sd(cursor_color,sc[global_place]);
 if pause_it then Sleep(250);
 sd(cursor_color,#8);
end;

begin
 case action of
  1:begin {spin cursur until key is pressed}
     repeat
      take_a_spin(true);
     until UkeyPressed;
    end; {}
  2:begin {take a single spin and exit}
     take_a_spin(false);
    end; {}
 end; {case .end.}

end; {spincursor *end*}

{*Unit Initialization Code*}
begin
 carriage_return:=true;

end. {Unit Jakob .end.}
