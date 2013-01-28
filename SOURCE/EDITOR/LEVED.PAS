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

Unit LevEd;

Interface

Procedure Level_Editor;

Implementation
uses init, jakobe;

Procedure Level_Editor;
var
    j, i, start, justval : integer;
    changes : boolean;
    rand, big : longint;

begin

 if exist('levels.dat')=false then begin
  crlf;
  display(0,14,0,'ATTENTION!');
  d('LEVELS.DAT file not found.');
  d('Reset the datafiles if you haven'+chr(39)+'t done so yet.');
  crlf;pause;
  exit;
 end;

 repeat
  clearscreen;
  crlf;
  display(0,5,0,'-* Level Editor *-');
  crlf;

  menu('(E)dit Level');
  menu('(L)ist Level Limits');

  sdisplay(0,2,0,'[');
  sdisplay(0,5,0,'Esc');
  display(0,2,0,'] for Main Menu');

  sdisplay(0,2,0,':');

  repeat
   ch:=upcase(getchar);
  until (ch='E') or (ch='L') or (ch=chr(27));

  crlf;

  if ch='L' then begin
   rand:=0;
   clearscreen;
   display(0,5,0,'-* Usurper Level Limits *-');crlf;
   start:=1;
   justval:=9;

   display(0,15,0,'# Level  Experience Points Needed');

   reset(levelfile);
   seek(levelfile,0);
   for i:=1 to filesize(levelfile)-1 do begin
    read(levelfile,level);

    sdisplay(0,14,0,ljust(commastr(i),justval));
    sdisplay(0,3,0,commastr(level.xpneed));

    crlf;
    rand:=rand+1;
    if rand>15 then begin
     crlf;
     if confirm('Continue ','Y')=false then break;
     rand:=0;
    end;
   end;
   close(levelfile);
   crlf;
   pause;
  end;

  if ch='E' then begin
   crlf;
   sdisplay(0,2,0,'Level (1-100)');
   sdisplay(0,2,0,':');

   {prompt(a,4,false);}
   val(a,rand,i);

   if (i=0) and (rand>0) and (rand<=100) then begin
    reset(levelfile);
    seek(levelfile,rand-1);
    read(levelfile,level);
    changes:=false;

    display(0,15,0,'Experience Points Needed for advancement to level # '+commastr(rand));
    display(0,14,0,commastr(level.xpneed));

    crlf;
    if confirm('Change this ','N')=true then begin
     display(0,2,0,'Enter new value ');
     sdisplay(0,2,0,':');

     {prompt(a,14,false);}
     val(a,big,i);

     if (i=0) and (big>=0) and (big<=2000000000) then begin
      if big<>level.xpneed then begin
       level.xpneed:=big;
       changes:=true;
      end;
     end;
    end;

    if (changes=true) and (confirm('Save changes ','Y')=true) then begin
     reset(levelfile);
     seek(levelfile,rand-1);
     write(levelfile,level);
     close(levelfile);
    end;

   end;
  end;

 until ch=chr(27);

end;
end.
