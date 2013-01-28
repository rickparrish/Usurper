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


Unit AutoGang; {Usurper - AutoGangWar. Npc gangs fight it out.}

Interface

Procedure Auto_Gangwar(const gang1,gang2 : string);

Implementation

Uses Init, Cms, Jakob,
     Compwar, News, Mail,
     Various3, TeamRec, Relation,
     File_Io;

Function Gang_War_Header : s30;
var result : s30;
begin

 case random(6) of
  0: result:='Gang War!';
  1: result:='Team Bash!';
  2: result:='Team War!';
  3: result:='Turf War!';
  4: result:='Gang Fight!';
  5: result:='Rival Gangs Clash!';
 end; {case .end.}

 {return result}
 gang_war_header:=result;

end; {gang_war_header .end.}

Procedure Auto_Gangwar;
var

 i : longint;

 turf,
 game_over : boolean;

 rounds,x,y,j : integer;

 bround : word;

 s, s2 : ^string;

 pl : array [0..10] of ^Userrec;
 busy : array [1..10] of boolean;

 m1,m2,m3 : s90;

begin

 player.name2:='*';
 player.name1:='*';

 {init pointer variables}
 for i:=0 to 10 do begin

  new(pl[i]);
  pl[i]^.name2:=emptystr;
  pl[i]^.hps:=0;
  pl[i]^.cturf:=false;
 end;
 new(s);
 new(s2);

 {load team members}
 x:=0;
 y:=5;

 for i:=1 to fs(FsPlayer) do begin

  if load_character(pl[0]^,1,i) then begin

   if (pl[0]^.team=gang1) and
      (player_active(pl[0]^,true)=true) then begin

    inc(x);
    pl[x]^:=pl[0]^;

   end;

   if (pl[0]^.team=gang2) and
      (player_active(pl[0]^,true)=true) then begin

    inc(y);
    pl[y]^:=pl[0]^;

   end;

  end;

 end; {for i:= .end.}

 for i:=1 to fs(FsNpc) do begin

  if load_character(pl[0]^,2,i) then begin

   if (pl[0]^.team=gang1) and
      (player_active(pl[0]^,true)=true) then begin

    inc(x);
    pl[x]^:=pl[0]^;

   end;

   if (pl[0]^.team=gang2) and
      (player_active(pl[0]^,true)=true) then begin

    inc(y);
    pl[y]^:=pl[0]^;

   end;
  end;

 end; {for i:= .end.}


 {are both team intact? Both teams need to have at least 1 member ready}
 if (x>0) and (y>5) then begin

 {announce the duel}
 s^:=' '+utec+gang1+config.textcol1+' challenged '+utec+gang2+config.textcol1;
 s2^:=emptystr;

 turf:=false;
 for i:=6 to 10 do begin
  if pl[i]^.cturf=true then begin
   turf:=true;
   s2^:='A challenge for Town Control!'+config.textcol1;
   break;
  end;
 end;

 {put event in the news-paper}
 newsy(false,
  config.textcol1+gang_war_header,
  s^,
  s2^,
  '',
  '',
  '',
  '',
  '',
  '',
  '');

 {reset hps}
 for i:=1 to 10 do begin
  if pl[i]^.name2<>'' then begin
   pl[i]^.hps:=pl[i]^.maxhps;
  end;
 end;

 game_over:=false;
 bround:=0;
 repeat

  inc(bround);

  {put bash result in the news-paper}
  newsy(false,
   config.textcol1+'  '+commastr(bround)+' Bash results :',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

  for i:=1 to 10 do begin
   busy[i]:=false;
  end;

  for i:=1 to 5 do begin
   for j:=6 to 10 do begin
    if (pl[i]^.name2<>'') and (pl[j]^.name2<>'') and
       (pl[i]^.hps>0) and (pl[j]^.hps>0) and
       (busy[i]=false) and (busy[j]=false) then begin

     busy[i]:=true;
     busy[j]:=true;

     rounds:=0;
     repeat
      inc(rounds);
      computer_computer(true,true,pl[i]^,pl[j]^);
     until (pl[i]^.hps<1) or (pl[j]^.hps<1);

     {update "killedby" variable in relations data file}
     if pl[i]^.hps<1 then begin
      killed_by_stats(pl[j]^,pl[i]^);
     end;
     if pl[j]^.hps<1 then begin
      killed_by_stats(pl[i]^,pl[j]^);
     end;

     s^:='   '+uplc+pl[i]^.name2+config.textcol1+' versus '+uplc+pl[j]^.name2+config.textcol1;

     if (pl[i]^.hps<1) and (pl[j]^.hps<1) then begin
      s^:=s^+' : '+ulred+'both dead!'+config.textcol1+' (in round '+ulgray+commastr(rounds)+config.textcol1+')';
      if pl[j]^.ai='H' then begin
       if pl[i]^.sex=1 then s^:='his'
                       else s^:='her';

       {mail offline player}
       post(MailSend,
            pl[j]^.name2,
            pl[j]^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Gang-Combat!'+config.textcol1,
            mkstring(12,underscore),
            uplc+pl[i]^.name2+config.textcol1+' attacked you and killed you!',
            'However, the scumbag died of '+s^+' wounds...',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

      end;
     end
     else if pl[i]^.hps<1 then begin
      if rounds>1 then begin
       s^:=s^+' : '+ulred+pl[i]^.name2+config.textcol1+' dead ('+ulgray+commastr(rounds)+config.textcol1+' rounds)';
      end
      else begin
       s^:=s^+' : '+ulred+pl[i]^.name2+config.textcol1+' dead ('+ulgray+commastr(rounds)+config.textcol1+' round)';
      end;

      case random(3) of
       0:begin
          post(MailSend,
           pl[j]^.name2,
           pl[j]^.ai,
           false,
           mailrequest_nothing,
           '',
           umailheadc+'Gang-Combat!'+config.textcol1,
           mkstring(12,underscore),
           uplc+pl[i]^.name2+config.textcol1+' attacked you but failed!',
           'The worthless worm died like a coward!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
         end;
       1:begin
          post(MailSend,
           pl[j]^.name2,
           pl[j]^.ai,
           false,
           mailrequest_nothing,
           '',
           umailheadc+'Gang-War!'+config.textcol1,
           mkstring(9,underscore),
           uplc+pl[i]^.name2+config.textcol1+' attacked you but lost!',
           'You earned some nice experience there!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');
         end;
       2:begin
          post(MailSend,
           pl[j]^.name2,
           pl[j]^.ai,
           false,
           mailrequest_nothing,
           '',
           umailheadc+'Gang-War!'+config.textcol1,
           mkstring(9,underscore),
           uplc+pl[i]^.name2+config.textcol1+' attacked you!',
           'After a nice little fight you killed '+sex[pl[i]^.sex]+'!',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '',
           '');

         end;
      end; {case .end.}
     end
     else if pl[j]^.hps<1 then begin
      if rounds>1 then begin
       s^:=s^+' : '+ulred+pl[j]^.name2+config.textcol1+' dead ('+ulgray+commastr(rounds)+config.textcol1+' rounds)';
      end
      else begin
       s^:=s^+' : '+ulred+pl[j]^.name2+config.textcol1+' dead ('+ulgray+commastr(rounds)+config.textcol1+' round)';
      end;

       post(MailSend,
            pl[j]^.name2,
            pl[j]^.ai,
            false,
            mailrequest_nothing,
            '',
            umailheadc+'Gang-Combat!'+config.textcol1,
            mkstring(12,underscore),
            uplc+pl[i]^.name2+config.textcol1+' attacked you!',
            'You were killed!',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

     end;

     {news-paper}
     newsy(false,
     s^+config.textcol1,
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     break;

    end;
   end;
  end; {for i:= .end.}

  {game_over ??}

  if (pl[1]^.hps+pl[2]^.hps+pl[3]^.hps+pl[4]^.hps+pl[5]^.hps+
      pl[6]^.hps+pl[7]^.hps+pl[8]^.hps+pl[9]^.hps+pl[10]^.hps)<1 then begin

   {news-paper}
   newsy(false,
   ulred+'Both gangs were destroyed!'+config.textcol1,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   game_over:=true;

  end;

  if (pl[1]^.hps+pl[2]^.hps+pl[3]^.hps+pl[4]^.hps+pl[5]^.hps)<1 then begin
   s^:=emptystr;
   if turf then begin
    s^:=ulred+'The attack for Town control was repelled.'+config.textcol1;
   end;

   {news-paper}
   newsy(false,
   utec+gang1+config.textcol1+' was wiped out!',
   s^,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

    if turf then begin
     turf:=false;
    end;
    game_over:=true;
  end;

  if (pl[6]^.hps+pl[7]^.hps+pl[8]^.hps+pl[9]^.hps+pl[10]^.hps)<1 then begin

   s^:=emptystr;
   if turf then begin
    s^:=utec+gang1+config.textcol1+' took over Town Control!'+config.textcol1;
   end;

   {news-paper}
   newsy(false,
   utec+gang2+config.textcol1+' has been destroyed!',
   s^,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {kollar om rekordet har tagits av gamla m„starna}
   team_record(gang2);

   {mail old town controllers and tell them about this loss}
   for i:=6 to 10 do begin
    if (pl[i]^.ai='H') and (pl[i]^.name2<>'') and (pl[i]^.deleted=false) then begin
     m1:='Lost Town Control!';
     m2:='Your team was not able to fend off the '+utec+gang1+config.textcol1+'!';
     m3:='Your gang was completely destroyed.';

     {Mail Message}
     post(MailSend,
     pl[i]^.name2,
     pl[i]^.ai,
     false,
     mailrequest_nothing,
     '',
     ulred+m1+config.textcol1,
     mkstring(length(m1),underscore),
     m2,
     m3,
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

    end;
   end; {for i:= .end.}


   game_over:=true;
  end;

 until game_over;

 newsy(true,
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '',
 '');

 end;

 {save users and dispose of temporary pointer vars}
 for i:=0 to 10 do begin
  if i>0 then begin
   if pl[i]^.name2<>'' then begin
    user_save(pl[i]^);
   end;
  end;
  dispose(pl[i]);
 end;

 {we write to all involved members of town control that has been lost}
 {adding, removing .townturf flag}
 if turf=true then begin
  for i:=1 to fs(FsPlayer) do begin

   if load_character(pl[0]^,1,i) then begin

    if pl[0]^.team=gang1 then begin
     pl[0]^.cturf:=true;
     user_save(pl[0]^);
    end
    else if pl[0]^.team=gang2 then begin

     pl[0]^.cturf:=false;
     user_save(pl[0]^);

    end;
   end;

  end; {for i:= .end.}

  for i:=1 to fs(FsNpc) do begin

   if load_character(pl[0]^,2,i) then begin

    if pl[0]^.team=gang1 then begin
     pl[0]^.cturf:=true;
     user_save(pl[0]^);
    end
    else if pl[0]^.team=gang2 then begin
     pl[0]^.cturf:=false;
     user_save(pl[0]^);
    end;
   end;

  end; {for i:= .end.}

 end; {turf .end.}

 {dispose of the remaining pointer variables}
 dispose(s);
 dispose(s2);

end; {Auto_Gangwar *end*}

end. {Unit AutoGang .end.}
