{$IFDEF WIN32}
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

Unit Get_Num;

Interface

Uses init, Jakobe;

Function Get_Numeric (s1,s2,s3,s4,s5 : s70;
                      minval, maxval, oldval : longint) : longint;

Implementation

Function Get_Numeric;
var
   tcol, i  : integer;
   st : s70;
   big : longint;

begin

 tcol:=15;
 get_numeric:=oldval;

 if s1<>'' then display(0,tcol,0,s1);
 if s2<>'' then display(0,tcol,0,s2);
 if s3<>'' then display(0,tcol,0,s3);
 if s4<>'' then display(0,tcol,0,s4);
 if s5<>'' then display(0,tcol,0,s5);

 display(0,15,0,'Enter a value between '+commastr(minval)+' and '+commastr(maxval));

 sdisplay(0,2,0,':');

 prompt(st,30,false);
 val(st,big,i);
 if i=0 then begin
  if (big>=minval) and (big<=maxval) then begin
   get_numeric:=big;
  end;
 end;

end;
end.
