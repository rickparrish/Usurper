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



Unit TeamRec; {Usurper - Team Records}

Interface

Procedure Team_Record(checkteam : string);

Implementation

Uses Init, Jakob, news,
     Various3, file_io;

Procedure Team_Record;  {checks to see if the record in holding the town
                         has been broken}
type
 RekordRec = record
  team  : string[40];
  days : longint;
 end;

var
    s,
    a2 : s70;

    error : integer;
    i, xx, ctr : longint;
    member : array[1..10] of string[30];

    RekordFil : file of RekordRec;
    Rekord : ^RekordRec;

    pl0 : ^UserRec;
    txt : text;

begin

 {init}
 error:=0;

 {assign filenames}
 assign(rekordfil,global_teamrecordf);
 assign(txt,global_teamrectxt);

 if f_exists(global_teamrecordf)=false then begin
  {$I-}rewrite(rekordfil);{$I+}
  error:=Ioresult;
  if error<>0 then begin
   unable_to_create(global_teamrecordf,error);
  end
  else begin
   rekord^.team:='Dangerous Foes';
   rekord^.days:=2;
   write(rekordfil,rekord^);
   close(rekordfil);
  end;
 end;

 if f_exists(global_teamrectxt)=false then begin
  {$I-}rewrite(txt);{$I+}
  error:=Ioresult;
  if error<>0 then begin
   unable_to_create(global_teamrectxt,error);
  end
  else begin
   writeln_to_text(txt,' ************************************************************');
   writeln_to_text(txt,'*All Time High - Gangs in Possession of Town - Record Holders*');
   writeln_to_text(txt,' ************************************************************');
   close_text(txt);
  end;
 end;

 new(rekord);
 new(pl0);

 a2:=emptystr;
 xx:=0;

 for i:=1 to 5 do begin
  member[i]:=emptystr;
 end;

 for i:=1 to fs(FsPlayer) do begin

  if load_character(pl0^,1,i) then begin

   if (player_active(pl0^,false)=true) and (pl0^.team=checkteam) then begin
    inc(xx);
    member[xx]:=pl0^.name2;
    ctr:=pl0^.teamrec;
   end;

  end;

 end;

 for i:=1 to fs(FsNpc) do begin

  if load_character(pl0^,2,i) then begin
   if (player_active(pl0^,false)=true) and (pl0^.team=checkteam) then begin
    inc(xx);
    member[xx]:=pl0^.name2;
    ctr:=pl0^.teamrec;
   end;
  end;

 end;

 if member[1]<>'' then begin

  {$I-}reset(rekordfil);{$I+}
  error:=Ioresult;
  if error<>0 then unable_to_access(global_teamrecordf,error);

  {$I-}read(rekordfil,rekord^);{$I+}
  error:=IOresult;
  if error<>0 then unable_to_read(global_teamrecordf,error);

  if (ctr>rekord^.days) and (pl0^.team<>rekord^.team) then begin

   open_txtfile(tappend,txt,global_teamrectxt);
   writeln_to_text(txt,' ');
   s:=fix_date(todays_date);

   writeln_to_text(txt,'Date of Record     : '+s);
   writeln_to_text(txt,'Team               : '+checkteam);

   a2:='Members            : ';

   for i:=1 to 5 do begin
    if member[i]<>'' then begin
     if i>1 then begin
      a2:=a2+', ';
     end;
     a2:=a2+member[i];
    end;
   end;

   writeln_to_text(txt,a2);
   writeln_to_text(txt,'Days in possession : '+commastr(ctr));

   close_text(txt);

   {put the event in the news}
   newsy(true,
   'Record Broken!',
   utec+' '+checkteam+config.textcol1+' broke '+utec+rekord^.team+config.textcol1+' old ',
   ' record for Town Control',
   ' ',
   '  old record '+commastr(rekord^.days)+' day(s).',
   '  new record '+commastr(ctr)+' day(s).',
   ' ',
   uyellow+' Salute the new Masters!'+config.textcol1,
   ' ',
   '');

   rekord^.days:=ctr;
   rekord^.team:=checkteam;

   {$I-}rewrite(rekordfil);{$I+}
   error:=Ioresult;
   if error<>0 then unable_to_create(global_teamrecordf,error);

   {$I-}write(rekordfil,rekord^);{$I+}
   error:=Ioresult;
   if error<>0 then unable_to_write(global_teamrecordf,error);

  end;

  {$I-}close(rekordfil);{$I+}
  error:=Ioresult;
  if error<>0 then unable_to_close(global_teamrecordf,error);

 end;

 {dispose pointer vars}
 dispose(rekord);
 dispose(pl0);

end; {Team_Record *end*}

end. {Unit TeamRec .end.}
