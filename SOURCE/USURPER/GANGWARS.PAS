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


Unit Gangwars; {Usurper - Gang War}

Interface

Uses Init;

Procedure Gang_Wars( oppo   : s70;
                     turfgo : boolean );

Implementation

Uses Cms, Jakob, Various,
     File_Io, Statusc, News, CompWar,
     Plcomp, Mail, TeamRec,
     Npc_Chec, Various3, Online,
     Relation;

var
    nice2 : array [1..global_maxteammembers*2] of s90;

    pl : array [0..9] of ^Userrec;

    pl0 : Userrec;
    bflag : array[1..global_maxteammembers] of integer;

Procedure SetRemove_TurfFlags(const oppo:s70;mailthem:byte);
var i : word;
   m1,m2,m3,m4 : s90;
begin

 m1:='';
 m2:='';
 m3:='';
 m4:='';

 {we must not forget to set PLAYERS flags to}
 player.cturf  :=true;
 player.teamrec:=0; {team record flag}

 for i:=1 to fs(FsPlayer) do begin

  load_character(pl0,1,i);

  if (pl0.team=player.team) and
     (pl0.name2<>player.name2) then begin

   pl0.cturf:=true;
   pl0.teamrec:=0;

   user_save(pl0);

   case mailthem of
    1:begin {mail player news of easy town takeover, the opponents were dead or in prison}

       m1:='Town Control!';
       m2:=uplc+player.name2+config.textcol1+' led your team to a glorious victory!';
       m3:=utec+oppo+config.textcol1+' was not able to defend the Town.';
       m4:='You are in charge now!';

       {Mail Message}
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       umailheadc+m1+config.textcol1,
       mkstring(length(m1),underscore),
       m2,
       m3,
       m4,
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
    2:begin {mail player news of town takeover, the opponents put up a fight}

       m1:='Town Control!';
       m2:=uplc+player.name2+config.textcol1+' led your team to a glorious victory!';
       m3:=utec+oppo+config.textcol1+' put up a fight, but was not able to';
       m4:='defend their turf. You are in charge now!';

       {Mail Message}
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       umailheadc+m1+config.textcol1,
       mkstring(length(m1),underscore),
       m2,
       m3,
       m4,
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
  else if (pl0.team=oppo) and (pl0.name2<>player.name2) then begin
   pl0.cturf:=false;
   user_save(pl0);

   case mailthem of
    1:begin {mail player of the opposing teams easy takeover! this beacuse the defenders were dead or in prison}
       m1:=ulred+'Lost Town Control!'+config.textcol1;
       m2:=ulred+player.name2+config.textcol1+' led '+sex3[player.sex]+' Team to a victory against your gang!';
       m3:='Your team was not ready to meet them! Everybody, inluding yourself, was';
       m4:='dead or in jail. The Town is no longer yours...';

       {Mail Message}
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       m1,
       mkstring(length(m1),underscore),
       m2,
       m3,
       m4,
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
   2:begin {mail player of the opposing teams town takeover! this beacuse the defenders were killed}
       m1:='Lost Town Control!';
       m2:=ulred+player.name2+config.textcol1+' led '+sex3[player.sex]+' Team to a victory against your bunch!';
       m3:='Your team was not able to fend off the attack! Everybody, inluding';
       m4:='yourself, was killed. The Town is no longer yours...';

       {Mail Message}
       post(MailSend,
       pl0.name2,
       pl0.ai,
       false,
       mailrequest_nothing,
       '',
       ulred+m1+config.textcol1,
       mkstring(length(m1),underscore),
       m2,
       m3,
       m4,
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

  end;
 end;

 {The Npcs don't need to have their mail posted, they can't read :) }
 for i:=1 to fs(FsNpc) do begin
  load_character(pl0,2,i);
  if (pl0.team=player.team) then begin
   pl0.cturf:=true;
   pl0.teamrec:=0;
   user_save(pl0);
  end
  else if (pl0.team=oppo) then begin
   pl0.cturf:=false;
   user_save(pl0);
  end;
 end; {for i:= .end.}

end; {SetRemove_TurfFlags *end*}

Procedure Swap_Players (var one, two : userrec); {just swaps two player records}
var slask : userrec;
begin
 slask:=one;
 one:=two;
 two:=slask;
end; {swap_players *end*}

Procedure Disposal; {dispose pointer vars}
var i : byte;
begin

 for i:=0 to (global_maxteammembers*2)-1 do begin
  dispose(pl[i]);
 end;


end; {disposal *end*}

Procedure Gang_Load( const gang : s70;
                     gang_nr : byte;
                     const oppo : s70);

var
    a, max,i,j,x : integer;
    size : word;
begin

 if gang_nr=1 then max:=global_maxteammembers-1
              else max:=global_maxteammembers;

 pl0.name2:='';
 player.gnollp:=0;


 if gang_nr=1 then begin

  for i:=1 to global_maxteammembers-1 do begin

   if (pl[i]^.name2<>'') and
      (is_online(pl[i]^.name2,online_player)=true) then begin

    add_shadow(SRemove,pl[i]^,'','',0);

   end;

   pl[i]^.name1:='';
   pl[i]^.name2:='';
   pl[i]^.hps:=0;
   pl[i]^.maxhps:=0;
   pl[i]^.gnollp:=0;

  end; {for i:= .end.}


 end
 else begin


  for i:=global_maxteammembers to ((global_maxteammembers*2)-1) do begin


   if (pl[i]^.name2<>'') and (is_online(pl[i]^.name2,online_player)=true) then begin


    add_shadow(SRemove,pl[i]^,'','',0);

   end;

   pl[i]^.name1:='';
   pl[i]^.name2:='';
   pl[i]^.hps:=0;
   pl[i]^.maxhps:=0;
   pl[i]^.gnollp:=0;
  end; {for i:= .end.}


 end;



 a:=0;

 {*locating Player and NPC team members*}
 for i:=1 to 2 do begin

  case i of
   1: size:=fs(FsPlayer);
   2: size:=fs(FsNpc);
  end;

  for j:=1 to size do begin

   if a<max then begin

    load_character(pl0,i,j);

    if (pl0.team=gang) and
       (pl0.name2<>player.name2) and
       (pl0.hps>0) and
       (pl0.allowed=true) and
       (pl0.location<>offloc_prison) and
       (pl0.deleted=false) and
       (pl0.name1<>global_delname1) and
       (pl0.name2<>global_delname2) and
       (is_online(pl0.name2,online_player)=false) then begin

     inc(a);

     if (gang_nr=1) then begin

      if add_shadow(SAdd,pl0,player.name2,'fighting '+utec+oppo+config.textcol1,0) then begin

       pl[a]^:=pl0;
       check_inventory(pl[a]^,0,Weapon,false,0);

      end;
     end
     else begin

      if add_shadow(SAdd,pl0,player.name2,'fighting '+utec+oppo+config.textcol1,0) then begin
       pl[(global_maxteammembers-1)+a]^:=pl0;
       check_inventory(pl[(global_maxteammembers-1)+a]^,0,Weapon,false,0);
      end;

     end;

    end;
   end
   else begin
    break;
   end;
  end; {for j:= .end.}

  if a>=max then break;

 end; {for i:= .end.}

 {shuffling team to get varied bouts}
 a:=0;
 case gang_nr of
  1:begin
     repeat
      x:=random(global_maxteammembers-1)+1;
      repeat
       j:=random(global_maxteammembers-1)+1;
      until j<>x;

      if (pl[x]^.name2<>'') and (pl[j]^.name2<>'') then begin
       swap_players(pl[x]^,pl[j]^);
      end;

      inc(a);
     until a>global_maxteammembers;
    end;
  2:begin
     repeat
      x:=(random(global_maxteammembers)+1)+(global_maxteammembers-1);
      repeat
       j:=(random(global_maxteammembers)+1)+(global_maxteammembers-1);
      until j<>x;

      if (pl[x]^.name2<>'') and (pl[j]^.name2<>'') then begin
       swap_players(pl[x]^,pl[j]^);
      end;

      inc(a);
     until a>global_maxteammembers;
    end;
 end; {case gang_nr .end.}

end; {gang_load *end*}

Procedure Gang_Wars; {main proc}
var
    s : s100;
    a, a2 : s70;
    rr : real;
    bround : integer;
    ch : char;
    rounds : array [0..global_maxteammembers-1] of integer;
    fastgame : boolean;
    i,j,x : longint;

    found, all_dead:boolean;

begin

 {init pointer vars}
 for i:=0 to (global_maxteammembers*2)-1 do begin
  nice2[i+1]:='';
  new(pl[i]);
  pl[i]^.name2:='';
  pl[i]^.name1:='';
  pl[i]^.hps:=0;
 end; {for i:= .end.}

 x:=0;


 if turfgo then begin

  {check if any team controls the town}
  for i:=1 to fs(FsPlayer) do begin

   load_character(pl0,1,i);

   if (pl0.team<>'') and (pl0.cturf) and (pl0.deleted=false) and
      (pl0.name1<>global_delname1) and (pl0.name2<>global_delname2) then begin

    oppo:=pl0.team;
    x:=1;
    break;

   end;

  end; {for i:= .end.}

  if x=0 then begin
   for i:=1 to fs(FsNpc) do begin
    load_character(pl0,2,i);
    if (pl0.team<>'') and (pl0.cturf) and (pl0.deleted=false) and
       (pl0.name1<>global_delname1) and (pl0.name2<>global_delname2) then begin
     oppo:=pl0.team;
     x:=1;
     break;
    end;
   end; {for i:= .end.}
  end;

  {*Get Town Control by default?*}
  {there is no gang in control of the town! let's grab it!}
  {*Yeah! Easy!*}
  if x=0 then begin
   clearscreen;
   player.cturf:=true;

   crlf;
   s:='The Town is in your hands!';
   d(14,s);
   d(config.textcolor,mkstring(length(s),underscore));
   crlf;

   if pl[1]^.name2='' then begin
    d(config.textcolor,'You walk out and proclaim to the businessmen that the town now');
    d(config.textcolor,'falls under your control. They must pay or have their shops burned.');
    crlf;
    d(config.textcolor,'You congratulate yourself to this easy takeover!');
    d(config.textcolor,'But you probably need some more gangmembers to fend off rival gangs.');
    crlf;
   end
   else begin

    if pl[2]^.name2='' then d(config.textcolor,'You and '+pl[1]^.name2);

    if (pl[2]^.name2<>'') and (pl[3]^.name2<>'') then begin
     d(config.textcolor,'You, '+pl[1]^.name2+', '+pl[2]^.name2);
    end;
    if (pl[2]^.name2<>'') and (pl[3]^.name2='') then begin
     d(config.textcolor,'You, '+pl[1]^.name2+' and '+pl[2]^.name2);
    end;
    if (pl[3]^.name2<>'') and (pl[4]^.name2<>'') then begin
     d(config.textcolor,' '+pl[3]^.name2);
    end;
    if (pl[3]^.name2<>'') and (pl[4]^.name2='') then begin
     d(config.textcolor,' and '+pl[3]^.name2);
    end;
    if pl[4]^.name2<>'' then d(config.textcolor,' and '+pl[4]^.name2);

    d(config.textcolor,'walk out and proclaim to the businessmen that the town now');
    d(config.textcolor,'fall under your control. They must pay or get their shops burned.');
    crlf;
    d(config.textcolor,'You congratulate each other to this easy takeover!');
    crlf;
   end;

   {adding winners .cturf flag}
   player.cturf:=true;
   player.teamrec:=0;
   user_save(player);

   for i:=1 to fs(FsPlayer) do begin
    load_character(pl0,1,i);
    if pl0.team=player.team then begin
     pl0.cturf:=true;
     pl0.teamrec:=0;
     user_save(pl0);

     {mail him/her}
     s:='Town Control';

     post(MailSend,
      pl0.name2,
      pl0.ai,
      false,
      mailrequest_nothing,
      '',
      umailheadc+s+config.textcol1,
      mkstring(length(s),underscore),
      uplc+player.name2+config.textcol1+' led the team to the success',
      'of dominating the Town. The opposition was none!',
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
   end;

   for i:=1 to fs(FsNpc) do begin
    load_character(pl0,2,i);
    if pl0.team=player.team then begin
     pl0.cturf:=true;
     pl0.teamrec:=0;
     user_save(pl0);
    end;
   end;

   {put easy takeover in the news-paper}
   newsy(true,
   'Gang Takeover!',
   utec+' '+player.team+config.textcol1+' took over the town without bloodshed.',
   ' '+uplc+player.name2+config.textcol1+' led '+sex3[player.sex]+' team to this victory.',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   pause;
   exit;
  end; {easy takeover .end.}

  {Fight is coming up}

  {display current Town controllers}
  sd(global_teamcol,upcasestr(oppo));
  d(15,' holds the town!');
end; 
  {check if the opposing team is around}
  found:=false;
  all_dead:=true;

  for i:=1 to fs(FsPlayer) do begin
   load_character(pl0,1,i);
   if pl0.team=oppo then begin

    if (pl0.hps>0) and (pl0.location<>offloc_prison) then begin
     found:=true;
    end;

    if is_online(pl0.name2,online_player) then begin
     all_dead:=false;
     found:=false;
    end;

    if found then begin
     break;
    end;

   end;
  end;

  if not found then begin
   for i:=1 to fs(FsNpc) do begin
    load_character(pl0,2,i);
    if pl0.team=oppo then begin

     if (pl0.hps>0) and (pl0.location<>offloc_prison) then begin
      found:=true;
     end;

     if is_online(pl0.name2,online_player) then begin
      all_dead:=false;
      found:=false;
     end;

     if found then begin
      break;
     end;

    end;
   end;
  end;
if turfgo then begin
  if (found=false) and (all_dead=false) then begin
   crlf;
   d(config.textcolor,'Sorry! Nobody in the other team can face your boys.');
   d(config.textcolor,'They are currently engaged in other activities.');
   d(config.textcolor,'Try again later!');
   crlf;
   pause;
   disposal;
   exit;
  end;
  if (found=false) and (all_dead=true) then begin
   {all in the opposing team are dead, we get the town by default}
   sd(config.textcolor,'The members of ');
   sd(11,oppo);
   d(config.textcolor,' are all dead or in prison.');
   d(config.textcolor,'You can easily take the town without bloodshed. Piece of cake!');
   d(config.textcolor,'Nice doing!');
   crlf;

   {set new and remove old enemy turf flags}
   SetRemove_TurfFlags(oppo,1); {1= mail teammates & opponents of this particular event}

   {put the event in the news}
   newsy(true,
   'Gang Takeover!',
   ' '+utec+player.team+config.textcol1+' took over the town without bloodshed.',
   ' '+uplc+player.name2+config.textcol1+' led '+sex3[player.sex]+' team to this victory.',
   ' The old rulers, '+ulred+oppo+config.textcol1+' was unable to put up a fight.',
   '',
   '',
   '',
   '',
   '',
   '');

   pause;
   disposal;
   exit;


  end;


  {Preparing for fight}


  {Add offline Town Rulers to onliners.dat file}
  x:=0;
  for i:=1 to fs(FsPlayer) do begin
   load_character(pl0,1,i);
   if (pl0.cturf) and (pl0.team<>player.team) then begin
    a2:=pl0.team;
    onliner.doing:='fighting '+utec+a2;
    add_onliner(OUpdateLocation,onliner);
    x:=1;
    break;
   end;
  end;

  if x=0 then begin
   for i:=1 to fs(FsNpc) do begin
    load_character(pl0,2,i);
    if (pl0.cturf) and (pl0.team<>player.team) then begin
     a2:=pl0.team;
     onliner.doing:='fighting '+utec+a2;
     add_onliner(OUpdateLocation,onliner);
     x:=1;
     break;
    end;
   end;
  end;

 end;
if not found then begin
   sd(config.textcolor,'Noone in ');
   sd(11,oppo);
   d(config.textcolor,' can fight right now!');
crlf;
pause;
disposal;
exit;
end;
dec(player.tfights);
 bround:=1;
 crlf;

 d(15,'Time to fight!');
 menu2('(F)ast or ');
 menu2('(D)etailed Non-player battles? :');

 repeat
  ch:=upcase(getchar);
 until ch in ['F','D',chr(13)];

 if (ch='F') or (ch=chr(13)) then fastgame:=true
                else fastgame:=false;

 clearscreen;



 {*load team-mates/enemies*}
 gang_load(player.team,1,oppo);
 gang_load(oppo,2,player.team);


 {reset player hitpoints, except 'real' player}
 pl[1]^.hps:=pl[1]^.maxhps;
 pl[2]^.hps:=pl[2]^.maxhps;
 pl[3]^.hps:=pl[3]^.maxhps;
 pl[4]^.hps:=pl[4]^.maxhps;
 pl[5]^.hps:=pl[5]^.maxhps;
 pl[6]^.hps:=pl[6]^.maxhps;
 pl[7]^.hps:=pl[7]^.maxhps;
 pl[8]^.hps:=pl[8]^.maxhps;
 pl[9]^.hps:=pl[9]^.maxhps;

 repeat
  clearscreen;
  crlf;
  sd(5,'Battle round ');
  d(3,'# '+commastr(bround));
  crlf;
  d(config.textcolor,'You call out your opponents to battle...');

  d(config.textcolor,'And here they come! Confrontation!');
  crlf;
  player.gnollp:=0;

  {*player vs player*}
  for i:=1 to global_maxteammembers do begin
   bflag[i]:=0;
  end;

  {s”ker players motst†ndare}
  for i:=5 to 9 do begin
   if pl[i]^.hps>0 then begin
    bflag[1]:=i;
    sd(global_plycol,'You ');
    sd(config.textcolor,'face ');
    d(global_plycol,pl[i]^.name2);
    break;
   end;
  end;

  for i:=1 to 4 do begin
   if pl[i]^.hps>0 then begin {leta bland motst†ndarna}
    for j:=5 to 9 do begin
     if pl[j]^.hps>0 then begin
      if (bflag[1]<>j) and (bflag[2]<>j) and (bflag[3]<>j) and
         (bflag[4]<>j) and (bflag[5]<>j) then begin

       bflag[i+1]:=j;
       sd(global_plycol,pl[i]^.name2);
       sd(config.textcolor,' is ready to meet ');
       d(global_plycol,pl[j]^.name2);
       break;

      end;
     end;
    end;
   end;
  end;

  crlf;
  sd(12,'-*- Spill blood -*-');
  ch:=getchar;

  clearscreen;
  crlf;

  rr:=0;

  {*Fight #1*}

  for i:=0 to 4 do begin
   rounds[i]:=0;
  end;

  if (player.hps>0) and (bflag[1]>0) then begin
   to_death:=false; {must be set to false before fight}
   repeat
    inc(rounds[0]);
    player_computer(player,pl[bflag[1]]^,fastgame,1);
   until (player.hps<1) or (pl[bflag[1]]^.hps<1);

   {update "killedby" variable in relations data file}
   if player.hps<1 then begin
    killed_by_stats(pl[bflag[1]]^,player);
   end;
   if pl[bflag[1]]^.hps<1 then begin
    killed_by_stats(player,pl[bflag[1]]^);
   end;

  end;

  for i:=1 to 4 do begin

   if (pl[i]^.hps>0) and (bflag[i+1]>0) then begin

    repeat
     inc(rounds[i]);
     computer_computer(false,fastgame,pl[i]^,pl[bflag[i+1]]^);
    until (pl[i]^.hps<1) or (pl[bflag[i+1]]^.hps<1);

    {update "killedby" variable in relations data file}
    if pl[i]^.hps<1 then begin
     killed_by_stats(pl[bflag[i+1]]^,pl[i]^);
    end;
    if pl[bflag[i+1]]^.hps<1 then begin
     killed_by_stats(player,pl[bflag[i+1]]^);
    end;

   end;

  end; {for i:= .end.}

  {*Battle round summary*}
  clearscreen;
  crlf;
  d(10,'Battle-Results from encounter :');
  d(5,'+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+');
  crlf;

  if bround=1 then begin
   {put war in the news}
   newsy(false,
   'Gang War!',
   ' '+utec+player.team+config.textcol1+' challenged '+utec+pl[5]^.team+config.textcol1,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');
  end;

  {jakob}
  newsy(false,
  '  '+commastr(bround)+' Bash results :',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  {d(s);}

  pl[0]^:=player;

  for i:=0 to 4 do begin
   if (pl[i]^.name2<>'') and (bflag[i+1]>0) then begin
    s:='   '+uplc+pl[i]^.name2+config.textcol1+' versus '+uplc+pl[bflag[i+1]]^.name2+config.textcol1;
    if (pl[i]^.hps<1) and (pl[bflag[i+1]]^.hps<1) then begin
     if rounds[i]>1 then begin
      s:=s+' : both dead! ('+commastr(rounds[i])+' rounds)';
     end
     else begin
      s:=s+' : both dead! ('+commastr(rounds[i])+' round)';
     end;
    end;
    if (pl[i]^.hps<1) and (pl[bflag[i+1]]^.hps>0) then begin
     if rounds[i]>1 then begin
      s:=s+' : '+ulred+pl[i]^.name2+config.textcol1+' dead ('+commastr(rounds[i])+' rounds)';
     end
     else begin
      s:=s+' : '+ulred+pl[i]^.name2+config.textcol1+' dead ('+commastr(rounds[i])+' round)';
     end;
    end;
    if (pl[i]^.hps>0) and (pl[bflag[i+1]]^.hps<1) then begin
     if rounds[i]>1 then begin
      s:=s+' : '+ulred+pl[bflag[i+1]]^.name2+config.textcol1+' dead ('+commastr(rounds[i])+' rounds)';
     end
     else begin
      s:=s+' : '+ulred+pl[bflag[i+1]]^.name2+config.textcol1+' dead ('+commastr(rounds[i])+' round)';
     end;
    end;

    newsy(false,
    s,
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    d(config.textcolor,s);

    if (i=0) and (pl[i]^.hps>0) then begin
     x:=random(50)+250;
     x:=x*pl[bflag[i+1]]^.level;
     d(15,'   You receive '+commastr(x)+' experience points!');
     inc(pl[i]^.exp,x);
     pause;
    end;

    if i>0 then begin
     {*beh”ver vi skriva till segrare i utmanande laget*}
     nice2[1]:='You were victorious in a gangwar with '+utec+oppo+config.textcol1+'!';
     if pl[bflag[i+1]]^.hps<1 then begin
      x:=random(50)+250;
      x:=x*pl[bflag[i+1]]^.level;
      nice2[2]:='You attacked '+uplc+pl[bflag[i+1]]^.name2+config.textcol1+' and wasted '+sex[pl[bflag[i+1]]^.sex]+'!';
      nice2[3]:='You received '+uyellow+commastr(x)+config.textcol1+' experience points!';
      inc(pl[i]^.exp,x);
      if pl[i]^.ai<>'C' then begin
       team_report(pl[i]^.name2,3,nice2[1],nice2[2],nice2[3],nice2[4]);
      end;
      if pl[i]^.autoheal=true then begin
       auto_healing(pl[i]^);
      end;
     end;
    end;

    {*beh”ver vi skriva till segrare i utmanade laget*}
    if pl[i]^.hps<1 then begin
     x:=random(50)+250;
     x:=x*pl[i]^.level;
     nice2[2]:='You were attacked by '+uplc+pl[i]^.name2+config.textcol1+' but killed '+sex[pl[i]^.sex]+'!';
     nice2[3]:='You received '+uyellow+commastr(x)+config.textcol1+' experience points!';
     inc(pl[bflag[i+1]]^.exp,x);

     if pl[bflag[i+1]]^.ai<>'C' then begin
      team_report(pl[bflag[i+1]]^.name2,3,nice2[1],nice2[2],nice2[3],nice2[4]);
     end;
     if pl[bflag[i+1]]^.autoheal=true then begin
      auto_healing(pl[bflag[i+1]]^);
     end;
    end;

    if i>0 then begin
     {*beh”ver vi skriva till de d”da i utmanar laget*}
     nice2[1]:='You were killed in a gangwar with '+utec+oppo+config.textcol1+'!';
     nice2[2]:='Your team was lead by '+uplc+player.name2+config.textcol1;

     if (pl[i]^.hps<1) and (pl[i]^.name2<>'') and (pl[i]^.ai<>'C') then begin
      nice2[3]:=ulred+pl[bflag[i+1]]^.name2+config.textcol1+' killed you!';
      team_report(pl[i]^.name2,3,nice2[1],nice2[2],nice2[3],nice2[4]);
     end;
    end;

    {*beh”ver vi skriva till d”da i utmanade laget*}
    nice2[1]:='You were killed in a gangwar with '+utec+player.team+config.textcol1+'!';
    nice2[2]:='They challenged your team!';

    if (pl[bflag[i+1]]^.hps<1) and (pl[bflag[i+1]]^.name2<>'') and
       (pl[bflag[i+1]]^.ai<>'C') then begin
     nice2[3]:=ulred+pl[i]^.name2+config.textcol1+' killed you!';
     team_report(pl[bflag[i+1]]^.name2,3,nice2[1],nice2[2],nice2[3],nice2[4]);
    end;

   end;
  end;

  player:=pl[0]^;

  crlf;
  pause;

  {*Have both gangs been wiped out*}
  x:=0;
  if player.hps>0 then x:=1;
  if pl[1]^.hps>0 then x:=1;
  if pl[2]^.hps>0 then x:=1;
  if pl[3]^.hps>0 then x:=1;
  if pl[4]^.hps>0 then x:=1;
  if pl[5]^.hps>0 then x:=1;
  if pl[6]^.hps>0 then x:=1;
  if pl[7]^.hps>0 then x:=1;
  if pl[8]^.hps>0 then x:=1;
  if pl[9]^.hps>0 then x:=1;

  if x=0 then begin
   clearscreen;
   crlf;
   d(12,'No survivors!');
   d(config.textcolor,'-*-*-*-*-*-*');
   crlf;
   d(config.textcolor,'No gangmember survived this slaughter!');
   d(config.textcolor,'May you all learn something from this...');
   d(config.textcolor,'Like : all wars are meaningless');
   crlf;
   d(config.textcolor,'But, I am pessimistic...');
   crlf;
   d(config.textcolor,'Darkness prevails...');
   crlf;

   newsy(true,
   '  Gangwar ended up with both teams wiped out!',
   '  Can nobody stop this meaningless violence?',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {save teams}
   team_save(pl[1]^,pl[2]^,pl[3]^,pl[4]^,
             pl[5]^,pl[6]^,pl[7]^,pl[8]^,pl[9]^);

   
   reduce_player_resurrections(player,true);
   {player.allowed:=false;}
   pause;
   normal_exit;
  end;

  {*Is player gang wiped destroyed*}
  x:=0;
  if player.hps>0 then x:=1;
  if pl[1]^.hps>0 then x:=1;
  if pl[2]^.hps>0 then x:=1;
  if pl[3]^.hps>0 then x:=1;
  if pl[4]^.hps>0 then x:=1;

  if x=0 then begin
   clearscreen;
   crlf;
   d(12,'Loser!');
   crlf;
   d(config.textcolor,'You have ruined it all...');
   d(config.textcolor,'Where are all the grandiose plans of which you');
   d(config.textcolor,'spoke? I can only see dead bodies and death staring');
   d(config.textcolor,'at your miserable team of adventurers. You promised');
   d(config.textcolor,'them victory but the only gain was pain and misery...');
   crlf;
   d(config.textcolor,'Darkness...');
   crlf;
   pause;

   case random(4) of
    0: a:='eliminated';
    1: a:='exterminated';
    2: a:='massacred';
    3: a:='wiped out';
   end;

   newsy(true,
   ' '+utec+player.team+config.textcol1+' was '+a+'.',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {save teams}
   team_save(pl[1]^,pl[2]^,pl[3]^,pl[4]^,
             pl[5]^,pl[6]^,pl[7]^,pl[8]^,pl[9]^);

   {player.allowed:=false;}
   reduce_player_resurrections(player,true);

   normal_exit;
  end;

  {*„r cust player d”d? avbryt attacken i s†na fall*}
  if player.hps<1 then begin

   team_report(player.name2,
               2,
               'You were killed in a gangwar with '+utec+pl[5]^.team+config.textcol1+'.',
               '(practice more before next fight!)',
               '',
               '');
   clearscreen;
   crlf;
   if pl[1]^.name2<>'' then begin
    d(config.textcolor,'Gang attack aborted due to death of leader!');
    crlf;
    d(config.textcolor,'As you fall to the ground, the morale within your');
    d(config.textcolor,'ranks drops....maybe next time...');
    crlf;
   end
   else begin
   crlf;
    d(12,'Gang attack failure!');
    crlf;
    d(config.textcolor,'You fall to the ground...slain by your foes!');
    d(config.textcolor,'All your hopes are gone...defeat and death was your');
    d(config.textcolor,'only gain.');
    crlf;
   end;

   newsy(true,
   '  Gang attack halted when '+uplc+player.name2+config.textcol1+' was killed!',
   '  The attack was repelled!',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {save teams}
   team_save(pl[1]^,pl[2]^,pl[3]^,pl[4]^,
             pl[5]^,pl[6]^,pl[7]^,pl[8]^,pl[9]^);

   {player.allowed:=false;}
   reduce_player_resurrections(player,true);

   pause;
   normal_exit;
  end;

  x:=0;
  if (pl[5]^.hps>0) and (pl[5]^.name2<>'') then x:=1;
  if (pl[6]^.hps>0) and (pl[6]^.name2<>'') then x:=1;
  if (pl[7]^.hps>0) and (pl[7]^.name2<>'') then x:=1;
  if (pl[8]^.hps>0) and (pl[8]^.name2<>'') then x:=1;
  if (pl[9]^.hps>0) and (pl[9]^.name2<>'') then x:=1;

  if x=0 then begin
   clearscreen;
   crlf;
   d(14,'Gang triumph!');
   crlf;
   d(config.textcolor,'You are tired but also pleased with your victory!');
   d(config.textcolor,'The bloody battle is over...');
   if pl[1]^.hps>0 then begin
    crlf;
    d(global_plycol,pl[1]^.name2+config.textcol1+' congratulates you to this heroic battle!');
   end;
   if pl[2]^.hps>0 then begin
    d(global_plycol,pl[2]^.name2+config.textcol1+' congratulates you to the glorious victory!');
   end;
   if pl[3]^.hps>0 then begin
    d(global_plycol,pl[3]^.name2+config.textcol1+' smiles and seems to be happy with your leadership!');
   end;
   if pl[4]^.hps>0 then begin
    d(global_plycol,pl[4]^.name2+config.textcol1+' is searching the dead bodies for '+config.moneytype+'.');
   end;
   crlf;
   d(config.textcolor,'Please Wait...');
   crlf;

   case random(2) of
    0: s:=utec+' '+player.team+config.textcol1+' took out their opponents!';
    1: s:=utec+' '+player.team+config.textcol1+' liquidated the enemy!';
   end;

   newsy(true,
   s,
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   {har town holders besegrats}
   if turfgo then begin

    {kollar om rekordet har tagits av gamla m„starna}
    team_record(oppo);

    newsy(true,
    ' '+utec+player.team+config.textcol1+' wiped out the opposition!',
    ' They took over the Town!',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

   end;

   pause;
   if player.hps>0 then begin
    d(config.textcolor,'Leave a note to the members in :');
    sd(global_teamcol,oppo);
    if confirm(' ','N')=true then begin
     d(config.textcolor,'Enter Message [1 line]');
     sd(config.textcolor,':');
     a:=get_String(70);

     if a<>'' then begin
      d(15,'OK.');

      for i:=1 to fs(FsPlayer) do begin
       load_character(pl0,1,i);
       if pl0.team=oppo then begin

        s:='After-Fight Message from '+player.team+' :';
        a2:=umailheadc+'After-Fight Message from '+utec+player.team+config.textcol1+' :';

        {Mail Message}
        post(MailSend,
        pl0.name2,
        pl0.ai,
        false,
        mailrequest_nothing,
        '',
        a2,
        mkstring(length(s),underscore),
        utalkc+a+config.textcol1,
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
        '',
        '');

        crlf;
        sd(config.textcolor,'Message sent to ');
        sd(global_plycol,pl0.name2);
        d(config.textcolor,' ...');
       end;
      end; {for i:= .end.}

     end;
    end;
   end;

   if player.hps<1 then begin
    crlf;
    d(config.textcolor,'Unfortunately, you can''t celebrate your glorious');
    d(config.textcolor,'victory! You lay on the ground, white as snow, dead...');
    crlf;

    {player.allowed:=false;}
    reduce_player_resurrections(player,true);
    {save teams}
    team_save(pl[1]^,pl[2]^,pl[3]^,pl[4]^,pl[5]^,pl[6]^,pl[7]^,pl[8]^,pl[9]^);

    pause;

    normal_exit;
   end;
   bround:=1000;
  end;

  inc(bround);
 until bround>999;

 crlf;

 {save teams}
 team_save(pl[1]^,pl[2]^,pl[3]^,pl[4]^,pl[5]^,pl[6]^,pl[7]^,pl[8]^,pl[9]^);

 if turfgo then begin

  {adderar Vinnarnas cturf flagga + tem.rec flaggan som s„tter rekordet}
  {tar „ven bort gamla g„nget fr†n cturf}

  SetRemove_Turfflags(oppo,2);

 end;

 {remove shadow players}
 for i:=1 to 9 do begin
  if pl[i]^.name2<>'' then begin
   add_shadow(SRemove,pl[i]^,'','',0);
  end;
 end;

 if turfgo then begin
  {The opponent could have been offline when the figt started bur then
   got online and therefore not be affected by the changes we make to
   his record, we must therefore send an online request to him as well,
   to insure that he removes his town control flag.}
  for i:=1 to fs(FsPlayer) do begin
   load_character(pl0,1,i);

   if (pl0.team=oppo) and
      (is_online(pl0.name2,online_player)) then begin
    online_send_to_player(pl0.name2,online_player,broadcast_removeturf);
   end;

  end; {for i:= .end.}

 end; {if turfgo .end.}


 {dispose temporary pointer vars}
 disposal;

end; {Gang_Wars *end*}

end. {Unit Gangwars .end.}
