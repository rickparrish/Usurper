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



Unit PlvsPl2; {Usurper - Player vs Player [continued from plvsplc.pas]}

Interface

Uses Init;

Procedure Player_vs_Player2( fastgame : boolean;
                              var pl0 : UserRec;
                                stab1 : integer;
                               var beg: boolean;
                        var soulstrike:longint);

Implementation

Uses Jakob, Cms, Mail,
     Cast, Invent, SwapEq,
     News, Various, Various2,
     Relation, File_Io;

Procedure Player_vs_Player2;
var
    stab2 : integer;

    slask, zz, x,q : longint;

    s : s70;

    gold_mem : longint;
    gold_string : s100;

    dummy : byte;

begin

 stab2:=0;

 {This unit is called upon from Pl_vs_plc, when 'A'ttack is chosen}

 {restoring overmaxed hps}
 if pl0.hps>pl0.maxhps then pl0.hps:=pl0.maxhps;
 if player.hps>player.maxhps then player.hps:=player.maxhps;

 {*does player2 need to quaff potions?*}
 computer_healing(true,pl0);

 {*should pl0. use spells?*}
 if (pl0.used_item=false) and (pl0.casted=false) then begin
  if pl0.class in [Cleric,Magician,Sage] then begin
   cast_spell(fastgame,1,2,pl0,player,false,dummy);
  end;
 end;

 if (player.race=Gnoll) and (pl0.gnollp=0) and (player.used_item=false) and (player.casted=false) then begin
  {x:=random(pl0.level+5);}
  x:=random(4)+1;
  if x=3 then begin
   d(4,'**Poisonous Gnollbite!**');
   d(4,'You managed to poison '+sex[pl0.sex]+'!');
   pl0.gnollp:=1;
  end;
 end;
 if (pl0.race=Gnoll) and (player.gnollp=0) and (pl0.used_item=false) and (pl0.casted=false) then begin
  {x:=random(player.level+5);}
  x:=random(4)+1;
  if x=3 then begin
   d(4,'**Poisonous Gnollbite!**');
   d(4,'The swine managed to poison you!');
   player.gnollp:=1;
  end;
 end;

 if player.gnollp>0 then begin
  pl0.punch:=random(pl0.level)+1;
  d(4,'You suffered '+uwhite+commastr(pl0.punch)+config.textcol1+' points from poison!');
  player.hps:=player.hps-pl0.punch;
 end;

 if pl0.gnollp>0 then begin
  player.punch:=random(player.level)+1;
  sd(global_plycol,pl0.name2);
  d(12,' suffers '+uwhite+commastr(player.punch)+ulred+' points from poison!');
  pl0.hps:=pl0.hps-player.punch;
 end;

 player.punch:=0;
 player.absorb:=0;
 pl0.punch:=0;
 pl0.absorb:=0;

 {strength in player attacks}
 if (player.used_item=false) and (player.casted=false) then begin
  player.punch:=normal_attack(false,player);
 end;

 if (pl0.used_item=false) and (pl0.casted=false) then begin
  pl0.punch:=normal_attack(false,pl0);
 end;

 {dra av av f”r spells}

 cast_spell(fastgame,2,2,pl0,player,false,dummy);
 cast_spell(fastgame,2,2,player,pl0,false,dummy);

 {har spelaren valt en soulstrike?}
 if soulstrike>0 then begin
  zz:=soulstrike;
  player.punch:=soul_effect(player,zz);
  soulstrike:=0;
  sd(config.textcolor,'Soulstrike hits ');
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' for '+uwhite+commastr(player.punch)+config.textcol1+' points!');
 end;

 {*should computer controlled player ues Backstab?*}
 if config.classic then begin
  if (pl0.class=Assassin) and (random(3)=0) and (pl0.used_item=false) and
     (pl0.casted=false) and (pl0.weapon>0) then begin

   sd(global_plycol,pl0.name2);
   d(config.textcolor,' tries to Backstab you!');
   if random(3)=0 then begin
    sd(config.textcolor,'You scream out in pain as ');
    sd(global_plycol,pl0.name2);
    d(config.textcolor,' cuts you !');
    stab2:=pl0.maxhps div 2;
   end
   else begin
   stab2:=-1;
   d(config.textcolor,'But misses!');
   end;
  end;
 end
 else begin
  if (pl0.class=Assassin) and (random(3)=0) and (pl0.used_item=false) and
     (pl0.casted=false) and (pl0.rhand+pl0.lhand>0) then begin

   sd(global_plycol,pl0.name2);
   d(config.textcolor,' tries to Backstab you!');
   if random(3)=0 then begin
    sd(config.textcolor,'You scream out in pain as ');
    sd(global_plycol,pl0.name2);
    d(config.textcolor,' cuts you !');
    stab2:=pl0.maxhps div 2;
   end
   else begin
   stab2:=-1;
    d(config.textcolor,'But misses!');
   end;
  end;

 end;

 {*should computer controlled player use soul strike? *}
 if (pl0.class=Paladin) and (pl0.hps>100) and (random(3)=0) and
 (pl0.used_item=false) and (pl0.casted=false) then begin
  zz:=pl0.hps div 3;
  soulstrike:=zz;
  dec(pl0.hps,zz);
  pl0.punch:=soul_effect(pl0,zz);
  soulstrike:=0;
  sd(config.textcolor,'Soulstrike from ');
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' hits you for '+uwhite+commastr(zz)+config.textcol1+' points!');
 end;

 if random(4)=0 then begin
  battle_comment(1,pl0.name2);
 end;

 if (player.punch+player.poison=0) and (player.used_item=false) and (player.casted=false) and (stab1<>-1) then begin
  sd(config.textcolor,'You miss your blow against ');
  d(global_plycol,pl0.name2+'!');
 end;
 if (player.punch+player.poison>0) and (player.used_item=false) and (player.casted=false) and (stab1<>-1) then begin
  sd(config.textcolor,'You hit ');
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' for '+uwhite+commastr(player.punch+player.poison)+config.textcol1+' points!');

  if random(3)=0 then begin
   battle_comment(2,pl0.name2);
  end;

  normal_defence(pl0);

  if pl0.absorb>player.punch then pl0.absorb:=player.punch;
  if pl0.absorb>0 then begin
   sd(global_plycol,pl0.name2+'s');
   sd(config.textcolor,' armor absorbed ');
   sd(15,commastr(pl0.absorb));
   d(config.textcolor,' points!');
   player.punch:=player.punch-pl0.absorb;
   if player.punch<0 then player.punch:=0;
  end;
 end;
 if (pl0.punch+pl0.poison=0) and (pl0.used_item=false) and (pl0.casted=false) and (stab2<>-1) then begin
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' missed you completely!');
 end;
 if (pl0.punch+pl0.poison>0) and (pl0.used_item=false) and (pl0.casted=false) and (stab2<>-1) then begin
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' hits you for '+uwhite+commastr(pl0.punch)+config.textcol1+' points!');

  if random(3)=0 then begin
   battle_comment(3,pl0.name2);
  end;

  normal_defence(player);

  if player.absorb>pl0.punch then player.absorb:=pl0.punch;
  if player.absorb>0 then begin
   d(config.textcolor,'Your armor absorbed '+uwhite+commastr(player.absorb)+config.textcol1+' points!');
   pl0.punch:=pl0.punch-player.absorb;
   if pl0.punch<0 then pl0.punch:=0;
  end;
 end;

 {infektioner}
 infections;
 infections2(fastgame,pl0);

 {„ntligen kan slagen f† effekt!}

 {backstab effekt}
 if stab1>0 then player.punch:=player.punch+stab1;
 if stab2>0 then pl0.punch:=pl0.punch+stab2;

 if stab1=-1 then begin
  player.punch:=0;
  pl0.punch:=pl0.punch+player.level;
 end;

 if stab2=-1 then begin
  pl0.punch:=0;
  player.punch:=player.punch+pl0.level;
 end;


 {poison effect}
 if player.poison>0 then player.punch:=player.punch+player.poison;
 if pl0.poison>0 then pl0.punch:=pl0.punch+pl0.poison;

 if player.punch<0 then player.punch:=0;
 if pl0.punch<0 then pl0.punch:=0;

 {eternal fight ?}
 if (player.punch<2) and (pl0.punch<2) then begin
  player.punch:=player.punch+random(5)+2;
  pl0.punch:=pl0.punch+random(5)+2;
 end;

 dec(player.hps,pl0.punch);
 dec(pl0.hps,player.punch);

 {*should player2 beg for mercy?*}
 if (pl0.hps<4) and (pl0.hps>0) and (player.hps>0) and (pl0.healing<1) and (random(5)=1) then begin
  beg:=true;
  crlf;
  crlf;
  d(config.textcolor,'Enemy Surrender!');
  d(config.textcolor,'*****************');
  sd(global_plycol,pl0.name2);
  d(config.textcolor,' throws '+sex4[pl0.sex]+' before your feet and begs for mercy!');
  if pl0.phr[4]<>'' then begin
   d(global_talkcol,'  '+pl0.phr[4]);
  end;
  sd(config.textcolor,'The crowd around you scream for blood, except ');
  sd(global_plycol,pl0.name2+'s');
  d(config.textcolor,' friends!');
  d(config.textcolor,'They hand you a big axe...and then there is silence when everybody');
  d(config.textcolor,'awaits your decision.');
  crlf;

  sd(config.textcolor,'Spare ');
  sd(global_plycol,pl0.name2+'s');
  sd(config.textcolor,' miserable life');

  if confirm('','N')=true then begin
   x:=100*pl0.level;
   x:=x+random(250);
   crlf;
   sd(config.textcolor,'To the crowds disappointment you let ');
   sd(global_plycol,pl0.name2);
   d(config.textcolor,' go.');
   d(config.textcolor,'That was an act of chivalry!');
   sd(config.textcolor,'You receive ');
   sd(15,commastr(x));
   d(config.textcolor,' experience points for this fight!');
   d(config.textcolor,'Your soul lightens!');
   crlf;
   crlf;

   inc(player.exp,x);
   inc(player.chiv,(random(25)+15));

   pl0.hps:=0;

   {pl0.gold:=0;}

   {save opponent to disk}
   user_save(pl0);

   if pl0.ai='H' then begin
    {inform opponent}
    post(MailSend,
    pl0.name2,
    pl0.ai,
    false,
    mailrequest_nothing,
    '',
    umailheadc+'Enemy Spared You!'+config.textcol1,
    mkstring(17,underscore),
    'You begged for mercy when '+uplc+player.name2+config.textcol1+' attacked you.',
    uplc+player.name2+config.textcol1+' spared your miserable life.',
    '(you are a such a coward!)',
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
   newsy(true,
   'Player Fight!',
   ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl0.name2+config.textcol1+' and won! '+uplc+pl0.name2
      +config.textcol1+' begged for mercy!',
   ' and '+uplc+player.name2+config.textcol1+' spared his life! What an act of chivalry!',
   '',
   '',
   '',
   '',
   '',
   '',
   '');
   pause;

  end
  else begin
   crlf;
   d(config.textcolor,'With a beautiful swing, you took '+sex3[pl0.sex]+' head off!');
   x:=100*pl0.level;
   x:=x+random(250);

   sd(config.textcolor,'The crowd cheer when you hold up ');
   sd(global_plycol,pl0.name2+'s');
   d(config.textcolor,' head for them!');
   sd(config.textcolor,'You receive ');
   sd(15,commastr(x));
   d(config.textcolor,' experience points for this fight!');
   d(config.textcolor,'Your soul darkens!');
   crlf;

   {update statistics}
   inc(player.p_kills);
   inc(pl0.p_defeats);
   xplose(pl0);

   {update "killedby" variable in relations data file}
   killed_by_stats(player,pl0);

   {take losers gold?}
   gold_mem:=-1;
   gold_string:='';
   if pl0.gold>0 then begin
    d(global_plycol,pl0.name2+'s'+config.textcol1+' purse has '+uyellow+commastr(pl0.gold)+config.textcol1
               +' '+many_money(pl0.gold)+' in it!');
    if confirm('Take the '+config.moneytype+' ','Y')=true then begin
     gold_mem:=pl0.gold;
     incplayermoney(player,pl0.gold);
     pl0.gold:=0;
    end
    else begin
     gold_mem:=0;
    end;
   end;

   {check to see if reward is set for pl0}
   reward_check(true,player,pl0);

   {swap equipment}
   swap_objects(player,pl0,true);

   {darkness}
   inc(player.exp,x);

   Give_Darkness(player,25);
   dec(player.darknr);

   {if pl0.gold>0 then begin
    sd(config.textcolor,'You took ');
    sd(14,commastr(pl0.gold));
    d(config.textcolor,' '+many_money(pl0.gold)+' from the dead body!');
    pause;
   end;}

   {incplayermoney(player,pl0.gold);}

   {writing pl0:s record}
   pl0.hps:=0;
   {pl0.gold:=0;}
   user_save(pl0);

   if pl0.ai='H' then begin

    if gold_mem>0 then begin
     {player took opponents gold}
     gold_string:=uplc+player.name2+config.textcol1+' emptied your purse, you lost '+uyellow+commastr(gold_mem)
                  +config.textcol1+' '+many_money(gold_mem)+'!';
    end
    else if gold_mem=0 then begin
     {player was noble and didn't take opponents gold}
     gold_string:=uplc+player.name2+config.textcol1+' let you keep your purse with '+uyellow+commastr(pl0.gold)
                  +config.textcol1+' '+many_money(pl0.gold)+'.';
    end;

    {inform other player}
    post(MailSend,
    pl0.name2,
    pl0.ai,
    false,
    mailrequest_nothing,
    '',
    umailheadc+'You Begged For Mercy!'+config.textcol1,
    mkstring(21,underscore),
    'You were killed by '+uplc+player.name2+config.textcol1+' when begging for mercy',
    gold_string,
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

   case random(2) of
    0:begin
       newsy(true,
       'Player Fight!',
       ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl0.name2+config.textcol1+' and won! '+uplc+pl0.name2
          +config.textcol1+' begged for mercy!',
       ' '+uplc+player.name2+config.textcol1+' showed no mercy. '+uplc+pl0.name2+config.textcol1+' was slaughtered!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    1:begin
       newsy(true,
       'Player Fight!',
       ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl0.name2+config.textcol1+' and won! '+uplc+pl0.name2
          +config.textcol1+' begged for mercy!',
       ' '+uplc+player.name2+config.textcol1+' showed no pity. '+uplc+pl0.name2+'s'+config.textcol1+' head was cut off!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    2:begin
       newsy(true,
       'Player Fight!',
       ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl0.name2+config.textcol1+' and won! '+uplc+pl0.name2
          +config.textcol1+' begged for mercy!',
       ' '+uplc+player.name2+config.textcol1+' was merciless, and put '+uplc+pl0.name2+config.textcol1+' out of '
          +sex3[pl0.sex]+' misery!',
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;

   end; {case .end.}

   pause;

  end;
 end;

end; {Player_vs_Player2 *end*}

end. {Unit PlvsPl2 .end.}
