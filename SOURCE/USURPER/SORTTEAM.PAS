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


Unit SortTeam; {Usurper - Sort Teams to disk/screen}

Interface

Procedure Sort_Teams ( bye  : boolean;
                       info1: boolean;
                       fighters  : boolean;
                       teamfight : boolean );

Implementation

Uses Init, jakob, various,
     gangwars, online, AnsiColr,
     file_io;

var
     maxdef2 : word;
     counter : integer;
     gap, k, count : integer;
     currentmax : word; {holds the number of initalized pointer vars}
     nice  : array [1..global_maxplayers] of ^longint;
     infos : array [1..global_maxplayers] of ^s120;
     xx, yy, i, x, j, y : longint;
     rulers : s30;
     player0 : ^UserRec;
     motivation : boolean;


Procedure Write_Asci(var infile : s70);
const Header ='Usurper Team Rankings                     Scores';
var ascifile : text;
    s,a : s70;
begin

 if open_txtfile(trewrite,ascifile,infile) then begin
  {to local screen only}
  wrl(10,'    '+infile);

  writeln_to_text(ascifile,header);
  writeln_to_text(ascifile,mkstring(length(header),underscore));

  if x>0 then begin
   counter:=x;
   for i:=1 to x do begin
    if i<10 then begin
     write_to_text(ascifile,'( '+commastr(i)+') ');
    end
    else begin
     write_to_text(ascifile,'('+commastr(i)+') ');
    end;

    write_to_text(ascifile,infos[i]^);
    x:=length(infos[i]^);
    a:=mkstring(57,'.');
    x:=42-x;

    s:=commastr(nice[i]^);
    y:=length(s);
    if y<13 then begin
     y:=13-y;
     s:=mkstring(y,'.')+s;
    end;

    if length(s)>1 then begin
     x:=x+1-length(s);
    end;
    writeln_to_text(ascifile,copy(a,1,x)+s);
   end; {for i:= .end.}
  end
  else begin
   writeln_to_text(ascifile,' ');
   writeln_to_text(ascifile,'No teams created');
  end;
  close_text(ascifile);
 end
 else begin
  {Unable to Create File}
  unable_to_create(infile,access_error);
 end;
end; {Write_Asci *end*}

Procedure Write_Ansi(var infile : s70);
const Header ='Usurper Team Rankings                     Scores';
var ansifile : text;
    s, a :s70;
begin

 if open_txtfile(trewrite,ansifile,infile) then begin

  {to local screen only}
  wrl(10,'    '+infile);

  writeln_to_text(ansifile,AMagentaOnBlack+header+ALtGrayOnBlack);
  writeln_to_text(ansifile,mkstring(length(header),underscore)+ConvertToAnsi(config.textcolor));

  if counter>0 then begin
   for i:=1 to counter do begin
    if i<10 then begin
     if i=1 then begin
      write_to_text(ansifile,AYellowonBlack);
     end;
     write_to_text(ansifile,'( '+commastr(i)+') ');
    end
    else begin
     write_to_text(ansifile,'('+commastr(i)+') ');
    end;

    {team name}
    write_to_text(ansifile,ACyanOnBlack+infos[i]^+ConvertToAnsi(config.textcolor));
    x:=length(infos[i]^);

    {team score}
    a:=mkstring(57,'.');
    x:=42-x;
    s:=commastr(nice[i]^);
    y:=length(s);
    if y<13 then begin
     y:=13-y;
     s:=mkstring(y,'.')+s;
    end;

    if length(s)>1 then begin
     x:=x+1-length(s);
    end;
    writeln_to_text(ansifile,copy(a,1,x)+s);

    if i=1 then begin
     write_to_text(ansifile,ConvertToAnsi(config.textcolor));
    end;
   end; {for i:= .end.}
  end
  else begin
   writeln_to_text(ansifile,' ');
   writeln_to_text(ansifile,'No teams created');
  end;
  close_text(ansifile);
 end
 else begin
  {Unable to Create File}
  unable_to_create(infile,access_error);
 end;

end; {Write_Ansi *end*}


Procedure Disposal; {dispose of pointer vars}
begin

 dispose(player0);

 if currentmax>0 then begin
  for i:=1 to currentmax do begin
   dispose(infos[i]);
   dispose(nice[i]);
  end; {for i:= .end.}
 end;

end; {disposal *end*}

Procedure Sort_Teams;
var s, a : s70;
    ch : char;
    col : byte;
    size : longint;
    pause_check : boolean;
begin

 {init vars}
 maxdef2:=global_maxplayers;
 xx:=1;
 currentmax:=0;

 maxdef2:=fs(FsPlayer)+fs(FsNpc);

 if maxdef2>global_maxplayers then begin
  maxdef2:=global_maxplayers;
 end;

 {init pointer vars}
 new(player0);


 {'C'ombat Ready Teams chosen from Gangwars menu}
 if fighters=true then begin
  crlf;
  crlf;
  s:='Teams ready to fight    Current Power';
  d(5,s);
  d(5,mkstring(length(s),underscore));

  for i:=1 to 2 do begin
   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to size do begin

    if load_character(player0^,i,j) then begin

     if player0^.cturf then begin
      rulers:=player0^.team;
     end;

     if (player0^.team<>'') and
        (player0^.hps>0) and
        (player0^.deleted=false) and
        (player0^.name1<>global_delname1) and
        (player0^.name2<>global_delname2) then begin

      x:=0;
      if currentmax>0 then begin
       for k:=1 to currentmax do begin
        if infos[k]^=player0^.team then begin
         inc(nice[k]^,player0^.maxhps+(player0^.level*10));
         x:=1;
         break;
        end;
       end; {for k:= .end.}
      end;

      if x=0 then begin
       {setup a new string}

       if currentmax<maxdef2 then begin
        inc(currentmax);
        new(infos[currentmax]);
        new(nice[currentmax]);
       end;

       infos[currentmax]^:=player0^.team;
       nice[currentmax]^:=player0^.maxhps+(player0^.level*10);

       if player0^.cturf then begin
        rulers:=player0^.team;
       end;
      end;

     end;
    end;
   end; {for j:= .end.}
  end; {for i:= .end.}


  {display teams}
  y:=25;
  i:=2;
  pause_check:=true;
  if currentmax>0 then begin
  for j:=1 to currentmax do begin
   if (infos[j]^<>'') then begin

    {team name}
    if (infos[j]^=player.team) and (player.team<>'') then begin
     sd(14,ljust(infos[j]^,y));
    end
    else begin
     sd(12,ljust(infos[j]^,y));
    end;

    {power}
    s:=commastr(nice[j]^);
    x:=length(s);
    if x<10 then begin
     x:=10-x;
     s:=mkstring(x,' ')+s;
    end;
    sd(15,s);

    {special info}
    sd(config.textcolor,mkstring(3,' '));

    if infos[j]^=rulers then begin
     sd(10,'*** Town Rulers ***   ');
    end;

    if (player.team<>'') and (infos[j]^=player.team) then begin
     sd(10,'*** Your Team ***');
    end;

    crlf;

    {pause}
    if pause_check=true then begin
     inc(i);
     if i>global_screenlines-2 then begin
      i:=0;
      ch:=confirm2('Continue','Y');
      if ch='N' then begin
       break;
      end
      else if ch='=' then begin
       pause_check:=false;
      end;
     end;
    end;

   end
   else begin
    break;
   end;
  end; {for j:= .end.}
  end;
  crlf;

  disposal;

  exit; {exit proc}
 end;


 {Info On Teams, 'I' choosen from TEAM CORNER}
 if info1=true then begin
  crlf;
  crlf;
  s:='Active Teams in Usurper';

  d(5,s);
  d(5,mkstring(length(s),underscore));
  xx:=0;

  for i:=1 to 2 do begin
   case i of
    1: size:=fs(FsPlayer);
    2: size:=fs(FsNpc);
   end;

   for j:=1 to Size do begin

    if load_character(player0^,i,j)=true then begin

     if (player0^.team<>'') and
        (player0^.deleted=false) and
        (player0^.name1<>global_delname1) and
        (player0^.name2<>global_delname2) then begin
      x:=0;

      if currentmax>0 then begin
       for k:=1 to currentmax do begin
        if copy(infos[k]^,1,length(player0^.team))=player0^.team then begin
         infos[k]^:=infos[k]^+', '+uplc+player0^.name2+config.textcol1;
         x:=1;
        end;
       end; {for k:= .end.}
      end;

      if x=0 then begin

       if currentmax<maxdef2 then begin
        inc(currentmax);
        new(infos[currentmax]);
        new(nice[currentmax]); {this isn't really necessary, but the disposal proc will bug out otherwise}
       end;

       infos[currentmax]^:=player0^.team+config.textcol1+' ('+uplc+player0^.name2+config.textcol1;
      end;
     end;
    end;

   end; {for j:= .end.}
  end; {for i:= .end.}

  if currentmax>0 then begin
   count:=2;
   pause_check:=true;
   for j:=1 to currentmax do begin
    sd(config.textcolor,commastr(j)+'. ');
    d(config.textcolor,utec+infos[j]^+')');

    if pause_check=true then begin
     inc(count);
     if count>global_screenlines-2 then begin
      count:=0;
      ch:=confirm2('More','Y');
      if ch='N' then begin
       break;
      end
      else if ch='=' then begin
       pause_check:=false;
      end;
     end;
    end;

   end; {for j:= .end.}
  end
  else begin
   crlf;
   d(config.textcolor,'No teams created.');
  end;
  crlf;

  disposal;
  exit;
 end; {Info On Teams .end.}

 {sort_teams continues...}

 for i:=1 to 2 do begin
  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to size do begin;
   if load_character(player0^,i,j)=true then begin

    if (player0^.team<>'') and
       (player0^.deleted=false) and
       (player0^.name1<>global_delname1) and
       (player0^.name2<>global_delname2) then begin

     x:=0;
     if currentmax>0 then begin
      for k:=1 to currentmax do begin
       if (infos[k]^=player0^.team) then begin
         inc(nice[k]^,player0^.maxhps+(player0^.level*10));
        x:=1;
        break;
       end;
      end; {for k:= .end.}
     end;

     if x=0 then begin

      if currentmax<maxdef2 then begin
       inc(currentmax);
       new(infos[currentmax]);
       new(nice[currentmax]);
      end;

      infos[currentmax]^:=player0^.team;
       nice[currentmax]^:=player0^.maxhps+(player0^.level*10);
     end;

    end;
   end;
  end; {for j:= .end.}
 end; {for i:= .end.}

 {sort teams}
 x:=currentmax-1;
 gap:=x div 2;
 while gap>0 do begin
  for i:=(gap+1) to x do begin
   j:=i-gap;
   while (j>0) do begin
    k:=j+gap;
    if nice[j]^>=nice[k]^ then begin
     j:=0
    end
    else begin
     xx:=nice[j]^;
     nice[j]^:=nice[k]^;
     nice[k]^:=xx;
     a:=infos[j]^;
     infos[j]^:=infos[k]^;
     infos[k]^:=a;
     j:=j-gap;
    end;
   end;
  end;
  gap:=gap div 2;
 end;
 {sort routine *end*}

 if bye=false then begin

  if x>0 then begin
   count:=2;
   pause_check:=true;
   for i:=1 to x do begin

    {top team color}
    if i=1 then col:=14;

    {#}
    if i<10 then begin
     sd(col,' '+commastr(i)+'. ');
    end
    else begin
     sd(col,commastr(i)+'. ');
    end;

    {team name}
    sd(global_teamcol,infos[i]^);
    x:=length(infos[i]^);
    a:=mkstring(57,'.');
    x:=42-x;

    {team scores}
    s:=commastr(nice[i]^);
    y:=length(s);
    if y<13 then begin
     y:=13-y;
     s:=mkstring(y,'.')+s;
    end;

    if length(s)>1 then begin
     x:=x+1-length(s);
    end;
    sd(col,copy(a,1,x)+s);
    crlf;

    {pause}
    if pause_check=true then begin
     inc(count);
     if count>global_screenlines-2 then begin
      count:=0;
      ch:=confirm2('More','Y');
      if ch='N' then begin
       break;
      end
      else if ch='=' then begin
       pause_check:=false;
      end;
     end;
    end;

    if i=1 then col:=config.textcolor;
   end; {for i:= .end.}

  end
  else begin
   d(config.textcolor,'No teams created.');
  end;
  d(config.textcolor,'');
 end
 else begin

  {has Sysop defined the external scorelists?}

  {name of asci score file}
  s:=cfg_string(73);
  if s<>'' then begin
   write_asci(s);
  end;

  {name of ansi score file}
  s:=cfg_string(72);
  if s<>'' then begin
   write_ansi(s);
  end;

 end;

 {dispose pointer vars}
 disposal;

end; {Sort_Teams *end*}

end. {Unit *end*}
