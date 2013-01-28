
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


Unit CompWar; {Usurper - Computer player versus Computer player}
              {can be offline human players as well}

Interface

Uses Init;

Procedure Computer_Computer(maintcombat : boolean;
                               fastgame : boolean;
                            var player1 : UserRec;
                            var player2 : UserRec);

Implementation

Uses Jakob, various, various2,
     invent, cast, swapeq;

Procedure Computer_Computer;
var
    stab1, stab2 : longint;
    zz, x : longint;
    skrik : boolean;
    reward : boolean;
    dummy : byte;

const soulstrike : longint = 0;

begin

 skrik:=true;
 if (maintcombat) or (fastgame) then begin
  skrik:=false;
 end;

 stab1:=0;
 stab2:=0;

 player1.casted:=false;
 player2.casted:=false;

 player1.absorb:=0;
 player2.absorb:=0;

 player1.punch:=0;
 player2.punch:=0;

 {player1 versus player2 in battle}
 if (maintcombat=false) and (fastgame=false) then begin
  sd(global_plycol,player1.name2);
  sd(config.textcolor,' clashes into combat with ');
  sd(global_plycol,player2.name2+'!');
  crlf;

  sd(global_plycol,player1.name2+'s');
  sd(config.textcolor,' hitpoints : ');
  d(global_hpcol,commastr(player1.hps));

  sd(global_plycol,player2.name2+'s');
  sd(config.textcolor,' hitpoints : ');
  d(global_hpcol,commastr(player2.hps));

 end;

 {restoring overmaxed hps}
 if player1.hps>player1.maxhps then player1.hps:=player1.maxhps;
 if player2.hps>player2.maxhps then player2.hps:=player2.maxhps;

 {should somebody use healing potions?}
 if skrik then computer_healing(true,player1)
          else computer_healing(false,player1);

 if skrik then computer_healing(true,player2)
          else computer_healing(false,player2);

 player1.used_item:=false;
 player2.used_item:=false;

 {Gnoll bite?}
 if (player1.race=Gnoll) and (player2.gnollp=0) and (player1.used_item=false) and (player1.casted=false) then begin
  x:=random(player2.level+5);
  if x=3 then begin
   if skrik then begin
    d(config.textcolor,'**Poisonous Gnollbite!**');
    d(config.textcolor,player1.name2+' poisoned '+player2.name2+'!');
   end;
   player2.gnollp:=1;
  end;
 end;

 if (player2.race=Gnoll) and (player1.gnollp=0) and (player2.used_item=false) and (player2.casted=false) then begin
  x:=random(player1.level+5);
  if x=3 then begin
   if skrik then begin
    d(config.textcolor,'**Poisonous Gnollbite!**');
    d(global_plycol,player2.name2+config.textcol1+' poisoned '+uplc+player1.name2+config.textcol1+'!');
   end;
   player1.gnollp:=1;
  end;
 end;

 if player1.gnollp>0 then begin
  player2.punch:=random(player2.level)+1;
  if skrik then begin
   d(global_plycol,player1.name2+config.textcol1+' suffered '+uwhite+commastr(player2.punch)+config.textcol1
     +' points from poison!');
  end;
  player1.hps:=player1.hps-player2.punch;
 end;
 if player2.gnollp>0 then begin
  player1.punch:=random(player1.level)+1;
  if skrik then begin
   d(global_plycol,player2.name2+config.textcol1+' suffered '+uwhite+commastr(player1.punch)+config.textcol1
     +' points from poison!');
  end;
  dec(player2.hps,player1.punch);
 end;

 player1.punch:=0;
 player2.punch:=0;

 {*should player1 use spells?*}
 if (player1.used_item=false) and (player1.casted=false) then begin
  if player1.class in [Cleric,Magician,Sage] then begin
   cast_spell(fastgame,1,2,player1,player2,false,dummy);
  end;
 end;

 {*should player2 use spells?*}
 if (player2.used_item=false) and (player2.casted=false) then begin
  if player1.class in [Cleric,Magician,Sage] then begin
   cast_spell(fastgame,1,2,player2,player1,false,dummy);
  end;
 end;

 {*should player1 use Backstab?*}
 if config.classic then begin
  if (player1.class=Assassin) and (random(3)=0) and
     (player1.used_item=false) and (player1.casted=false) and
     (player1.rhand+player1.lhand>0) then begin
   if skrik then begin
    d(global_plycol,player1.name2+config.textcol1+' tries to backstab '+uplc+player2.name2+config.textcol1+'!');
   end;
   if random(3)=0 then begin
    if skrik then begin
     d(global_plycol,player2.name2+config.textcol1+' screams in pain as '+uplc+player1.name2+config.textcol1+' cuts '
       +sex[player2.sex]+'!');
    end;
    stab1:=player1.maxhps div 3;
   end
   else begin
    stab1:=-1;
    if skrik then begin
     d(12,'But misses!');
    end;
   end;
  end;
 end
 else begin
  if (player1.class=Assassin) and (random(3)=0) and
     (player1.used_item=false) and (player1.casted=false) and
     (player1.weapon>0) then begin

   if skrik then begin
    d(global_plycol,player1.name2+config.textcol1+' tries to backstab '+uplc+player2.name2+config.textcol1+'!');
   end;
   if random(3)=0 then begin
    if skrik then begin
     d(global_plycol,player2.name2+config.textcol1+' screams in pain as '+uplc+player1.name2+config.textcol1+' cuts '
       +sex[player2.sex]+'!');
    end;
    stab1:=player1.maxhps div 3;
   end
   else begin
    stab1:=-1;
    if skrik then begin
     d(12,'But misses!');
    end;
   end;
  end;
 end;

 {*should player1 use soul strike? *}
 if (player1.class=Paladin) and (player1.hps>100) and (random(2)=0) and (player1.used_item=false)
 and (player1.casted=false) then begin
  zz:=player1.hps div 3;
  soulstrike:=zz;
  dec(player1.hps,zz);
  player1.punch:=soul_effect(player1,zz);

  if skrik then begin
   d(config.textcolor,'Soulstrike from '+uplc+player1.name2+config.textcol1+' hits '+uplc+player2.name2+config.textcol1
     +' for '+uwhite+commastr(player1.punch)+config.textcol1+' points!');
  end;
 end
 else begin
  if player1.casted=false then begin
   {strength in player1:s attack}
   player1.punch:=normal_attack(fastgame,player1);

   if (player1.punch=0) and (player1.used_item=false) and (player1.casted=false) then begin
    if skrik then begin
     d(global_plycol,player1.name2+config.textcol1+' missed '+uplc+player2.name2+config.textcol1+' completely!');
    end;
   end
   else begin
    if (player1.used_item=false) and (player1.casted=false) then begin
     if skrik then begin
      d(global_plycol,player1.name2+config.textcol1+' hits '+uplc+player2.name2+config.textcol1+' for '+uwhite
        +commastr(player1.punch)+config.textcol1+' points!');
     end;
    end;
   end;
  end;
 end;

 {*Should player2 use Backstab?*}
 if config.classic then begin
  if (player2.class=Assassin) and (random(3)=0) and
     (player2.used_item=false) and (player2.casted=false) and
     (player2.rhand+player2.lhand>0) then begin
   if skrik then begin
    d(global_plycol,player2.name2+config.textcol1+' tries to backstab '+uplc+player1.name2+config.textcol1+'!');
   end;
   if random(3)=0 then begin
    if skrik then begin
     d(global_plycol,player1.name2+config.textcol1+' screams in pain as '+uplc+player2.name2+config.textcol1+' cuts '
      +sex[player1.sex]+'!');
    end;
    stab2:=player2.maxhps div 3;
   end
   else begin
    stab2:=-1;
    if skrik then begin
     d(12,'But misses!');
    end;
   end;
  end;
 end
 else begin
  if (player2.class=Assassin) and (random(3)=0) and
     (player2.used_item=false) and (player2.casted=false) and
     (player2.weapon>0) then begin

   if skrik then begin
    d(global_plycol,player2.name2+config.textcol1+' tries to backstab '+uplc+player1.name2+config.textcol1+'!');
   end;
   if random(3)=0 then begin
    if skrik then begin
     d(global_plycol,player1.name2+config.textcol1+' screams in pain as '+uplc+player2.name2+config.textcol1+' cuts '
       +sex[player1.sex]+'!');
    end;
    stab2:=player2.maxhps div 3;
   end
   else begin
    stab2:=-1;
    if skrik then begin
     d(12,'But misses!');
    end;
   end;
  end;

 end;

 {*should player2 use soul strike? *}
 if (player2.class=Assassin) and (player2.hps>100) and (random(2)=0) and
    (player2.used_item=false) and (player2.casted=false) then begin
  zz:=player2.hps div 3;
  soulstrike:=zz;
  dec(player2.hps,zz);
  player2.punch:=soul_effect(player2,zz);

  if skrik then begin
   d(config.textcolor,'Soulstrike from '+uplc+player2.name2+config.textcol1+' hits '+uplc+player1.name2+config.textcol1
     +' for '+uwhite+commastr(player2.punch)+config.textcol1+' points!');
  end;
 end
 else begin
  if player2.casted=false then begin
   {strength in player2:s attack}
   player2.punch:=normal_attack(fastgame,player2);

   if (player2.punch=0) and (player2.used_item=false) and (player2.casted=false) then begin
    if skrik then begin
     d(global_plycol,player2.name2+config.textcol1+' missed '+sex3[player2.sex]+' blow against '+uplc+player1.name2
       +config.textcol1+'!');
    end;
   end
   else begin
    if (player2.used_item=false) and (player2.casted=false) then begin
     if skrik then begin
      d(global_plycol,player2.name2+config.textcol1+' hits '+uplc+player1.name2+config.textcol1+' for '+uwhite
        +commastr(player2.punch)+config.textcol1+' points!');
     end;
    end;
   end;
  end;
 end;

 player1.absorb:=0;
 player2.absorb:=0;

 {spell attacks}
 cast_spell(fastgame,2,2,player2,player1,false,dummy);
 cast_spell(fastgame,2,2,player1,player2,false,dummy);

 {absorbed points are displayed}
 normal_defence(player2);
 if player2.absorb>player1.punch then player2.absorb:=player1.punch;
 if player2.absorb>0 then begin
  if fastgame=false then begin
   d(global_plycol,player2.name2+'s'+config.textcol1+' armor absorbed '+uwhite+commastr(player2.absorb)
     +config.textcol1+' points!');
  end;
  player1.punch:=player1.punch-player2.absorb;
  if player1.punch<0 then player1.punch:=0;
 end;

 normal_defence(player1);
 if player1.absorb>player2.punch then player1.absorb:=player2.punch;
 if player1.absorb>0 then begin

  if fastgame=false then begin
   d(global_plycol,player1.name2+'s'+config.textcol1+' armor absorbed '+uwhite+commastr(player1.absorb)
     +config.textcol1+' points!');
  end;
  player2.punch:=player2.punch-player1.absorb;
  if player2.punch<0 then player2.punch:=0;

 end;

 {infections}
 infections2(fastgame,player1);
 infections2(fastgame,player2);

 {at last the actual punches can take effect!}

 {backstab effect}
 if stab1>0 then player1.punch:=player1.punch+stab1;
 if stab2>0 then player2.punch:=player2.punch+stab2;

 if stab1=-1 then begin
  player1.punch:=0;
  player2.punch:=player2.punch+player1.level;
 end;

 if stab2=-1 then begin
  player2.punch:=0;
  player1.punch:=player1.punch+player2.level;
 end;

 {poison effekt}
 if player1.poison>0 then player1.punch:=player1.punch+player1.poison;
 if player2.poison>0 then player2.punch:=player2.punch+player2.poison;

 if player1.punch<0 then player1.punch:=0;
 if player2.punch<0 then player2.punch:=0;

 {eternal battle?}
 if (player1.punch<2) and (player2.punch<2) then begin
  player1.punch:=player1.punch+(random(5)+2);
  player2.punch:=player2.punch+(random(5)+2);
 end;

 dec(player1.hps,player2.punch);
 dec(player2.hps,player1.punch);

 if player1.hps<0 then player1.hps:=0;
 if player2.hps<0 then player2.hps:=0;

 reward:=true;
 if (player1.hps<1) and (player2.hps<1) then begin
  reward:=false;
 end;

 if player1.hps<1 then begin
  if maintcombat=false then begin
   sd(global_plycol,player1.name2);
   d(config.textcolor,' has been killed!');
  end;

  inc(player1.p_defeats);
  inc(player2.p_kills);

  xplose(player1);

  if player2.hps>0 then begin
   swap_objects(player2,player1,skrik);
  end;

  if player2.autoheal=true then begin
   auto_healing(player2);
  end;

  if reward then begin
   reward_check(false,player2,player1);
  end;

 end;

 if player2.hps<1 then begin
  if maintcombat=false then begin
   sd(global_plycol,player2.name2);
   d(config.textcolor,' has been killed!');
  end;
  xplose(player2);

  inc(player2.p_defeats);
  inc(player1.p_kills);

  if player.hps>0 then begin
   swap_objects(player1,player2,skrik);
  end;

  if player1.autoheal=true then begin
   auto_healing(player1);
  end;

  if reward then begin
   reward_check(false,player1,player2);
  end;

 end;

 if fastgame=false then begin
  pause;
 end;

end; {Computer_Computer *end*}

end. {Unit Compwar .end.}
