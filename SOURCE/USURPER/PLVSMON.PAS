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



Unit PlvsMon; {Usurper - Generic Player versus Monsters routine}

Interface
Uses Init;

var killed_by : array[1..5] of string[30];
 {the monster who took the players and teammates lives killed_by[1] is
  player}

Procedure Player_vs_Monsters( monster_mode : byte;
                              var pl1,pl2,pl3,pl4 : Userrec );
                            {see cms.pas for constants
                             1 = pl vs dungeon monsters
                             2 = pl vs door guards
                             3 = pl vs supreme being
                             4 = pl vs demon
                             5 = pl vs alchemist opponent
                             6 = pl vs prison guards (attempting to free a friend}

Implementation

Uses Jakob, Statusc, Invent,
     Cms, Cast, Npc_Chec, News,
     Spellsu, Various, Various2,
     Various3, Online, File_Io;

var
    dispat, norm_att, found, done, first : boolean;

    ch : char;

    justval : integer;

    tempman : userrec;

    healed : boolean;

 {start, spell related variables, start}
 monster_magic: boolean;
 monster_spell: byte;
 damage       : longint;
 ms,ms2       : byte;
 {start, spell related variables, end}

Function Retreat : boolean;
var s : s100;
    xx : longint;
begin

 case random(2) of
  0:begin
     crlf;
     d(config.textcolor,'You have escaped battle!');
     retreat:=true;
    end;
  1:begin
     crlf;
     d(config.textcolor,'The monster won''t let you escape!');
     xx:=random(global_dungeonlevel*10)+3;

     d(config.textcolor,'As you cowardly turn and run, you feel pain when something');
     d(config.textcolor,'hits you in the back for '+commastr(xx)+' points');
     crlf;

     dec(player.hps,xx);
     if player.hps<=0 then begin
      crlf;
      d(12,'You have been slain!');
      crlf;
      player.hps:=0;
      {player.allowed:=false;}

      s:=uplc+player.name2+config.textcol1;

      case random(3) of
       0: s:=s+' was killed by a ';
       1: s:=s+' was slain by a ';
       2: s:=s+' was slaughtered by a ';
       3: s:=s+' was defeated by a ';
      end;

      s:=s+'monster, when trying to escape battle!';


      {news-paper}
      newsy(true,
      'Coward!',
      ' '+s,
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

      Reduce_Player_Resurrections(player,true);

      d(config.textcolor,'Darkness...');
      crlf;

      {set killed flags}
      global_killed:=true;
      retreat:=false;
      global_PlayerInFight:=false;

      {exit program}
      normal_exit;

     end;
    end;
 end; {case .end.}

end; {retreat **end**}

Procedure Monster_Charge(mode : integer);
var i : longint;
    xx : longint;
begin

 case mode of
  1:begin
     for i:=1 to global_maxmon do begin
      xx:=3;
      if monster[i]^.strength<10 then monster[i]^.strength:=10;
      monster[i]^.punch:=0;
      if monster[i]^.weappow>32000 then monster[i]^.weappow:=32000;
      monster[i]^.punch:=monster[i]^.weappow+(random(monster[i]^.weappow));
      monster[i]^.punch:=monster[i]^.punch+(monster[i]^.strength div xx);

      {lucky freak attack}
      if random(3)=0 then begin
       monster[i]^.punch:=monster[i]^.punch+random(5)+1;
      end;

     end; {for i:= .end.}
    end;
  2:begin {player versus doorguard(s)}
     for i:=1 to global_maxmon do begin
      xx:=monster[i]^.strength*2;
      monster[i]^.punch:=random(xx);
     end; {for i:= .end.}
    end;
  3:begin
     dispat:=false;
     for i:=1 to global_maxmon do begin
      monster[i]^.punch:=random(player.maxhps)+3;

      if (global_s_sword=true) and (dispat=false) then begin
       d(15,'The Black Sword attacks the Supreme Being!');
       dec(monster[i]^.hps,75);
       dispat:=true;
      end;
      if (global_s_lantern=true) and (dispat=false) then begin
       d(15,'The Lantern starts to glow before you!');
       monster[i]^.punch:=monster[i]^.punch div 2;
       dispat:=true;
      end;
      if (global_s_wstaff=true) and (dispat=false) then begin
       d(15,'The White Staff starts to glow before you!');
       dec(monster[i]^.punch,50);
       if monster[i]^.punch<0 then monster[i]^.punch:=0;
       dispat:=true;
      end;
      if (global_s_bstaff=true) and (dispat=false) then begin
       d(15,'The Black Staff increases your strength!');
       dispat:=true;
      end;

      monster[i]^.magicres:=100;
     end; {for i:= .end.}
    end;
  4:begin

     {demon}
     monster[1]^.punch:=100+(random(player.maxhps));
     monster[1]^.armpow:=100;
     monster[1]^.magicres:=100;

    end;
  5..6:begin
        for i:=1 to global_maxmon do begin
         xx:=3;
         if monster[i]^.strength<10 then monster[i]^.strength:=10;
         monster[i]^.punch:=0;

         if monster[i]^.weappow>32000 then monster[i]^.weappow:=32000;

         monster[i]^.punch:=monster[i]^.weappow+(random(monster[i]^.weappow));
         monster[i]^.punch:=monster[i]^.punch+(monster[i]^.strength div xx);
        end; {for i:= .end.}
       end;
 end; {case .end.}

end; {monster_charge **end**}


Function Hit_Output (const inval : longint) : s70;
var
    s : string[8];

begin

 s:='MAX';
 case inval of
  1..5       : s:='Light';
  6..20      : s:='Medium';
  21..100    : s:='Hard';
  101..200   : s:='Heavy';
  201..2000  : s:='Extreme';
  2001..9999 : s:='ULTRA';
 end;

 {return result}
 hit_output:=s;

end;

Procedure Monster_Magic_Attack(const i:integer);
var s,s2 : s70;
    j : byte;
begin         {monster #i casts monster_spell against tempman}

 sd(global_moncol,monster[i]^.name);

 if spell_multi_monster(monster_spell) then begin
  sd(15,' casts a SPELL!');
 end
 else begin
  sd(15,' casts a SPELL on ');
  if tempman.name2=player.name2 then sd(15,'You!')
                                else sd(global_plycol,tempman.name2);
 end;

 d(config.textcolor,' ('+spell_name_monster(monster_spell)+')');

 {should the spell fail?}
 if random(2)=0 then begin
  d(5,'But it failed.');
 end
 else begin

  {spell affects target(s)}
  case monster_spell of
   1:begin {Spell : CAUSE DAMAGE}
      damage:=monster[i]^.magiclevel*3; {damage}
      if tempman.name2=player.name2 then s:='You are'
                                    else s:=tempman.name2+' is';

      d(11,s+' hurt for '+commastr(damage)+' damage!');
      dec(tempman.hps,damage);
     end;
   2:begin {Spell : Snakes}
      d(12,'Silver Snakes appear in a puff of smoke!');
      damage:=monster[i]^.magiclevel*2; {damage}
      if tempman.name2=player.name2 then s:='You are'
                                    else s:=tempman.name2+' is';

      d(11,s+' bitten for '+commastr(damage)+' damage!');

      dec(tempman.hps,damage);
     end;
   3:begin  {Spell : Cyclone}
      d(12,'They have summoned a CYCLONE!');
      damage:=monster[i]^.magiclevel*2; {damage}
      if tempman.name2=player.name2 then s:='You are'
                                    else s:=tempman.name2+' is';

      d(11,s+' swept away and hurt for '+commastr(damage)+' damage!');

      dec(tempman.hps,damage);
     end;
   4:begin {Spell : Summon Undead}

      {decide undead type}
      case random(2) of
       0:begin
          s:='Zombie';
          s2:='Sabre';
         end;
       1:begin
          s:='Corpse';
          s2:='Rotten arms';
         end;
      end; {case .end.}

      d(12,'From the ground, a '+s+' suddenly rises!');

      {check in any empty monster spots are available}
      for j:=1 to global_maxmon do begin
       if monster_active(j)=false then begin
        create_monster(j,             {#}
                       s,             {name}
                       50,            {hps}
                       15,            {strength}
                       15,            {defence}
                       'Kill.Kill.',  {phrase}
                       false,         {grabweap}
                       false,         {grabarm}
                       s2,            {weapon-string}
                       '',            {armor-string}
                       false,         {poisoned-should be false}
                       false,         {disease -should be false}
                       25,            {punch}
                       7,             {armpow}
                       7);            {weappow}
        break;
       end;
      end;

     end;

   5:begin {Spell : Vice of Death}
      d(12,tempman.name2+' has been seized by cramps!');
      d(12,tempman.name2+' is incapaciated!');

      damage:=monster[i]^.magiclevel*2; {damage}
      if tempman.name2=player.name2 then s:='You are'
                                    else s:=tempman.name2+' is';

      d(11,s+' hurt for '+commastr(damage)+' damage!');
      dec(tempman.hps,damage);

     end;
   6:begin {Spell : Drain Life}
      d(12,'A bright spark of red energy hits '+tempman.name2+'!');

      damage:=monster[i]^.magiclevel*1; {damage}
      if tempman.name2=player.name2 then s:='You are'
                                    else s:=tempman.name2+' is';

      d(11,s+' zapped for '+commastr(damage)+' damage!');
      dec(tempman.hps,damage);
     end;
  end; {case .end.}

 end;

 { USED WHEN TESTING Monster spell functions
 d(config.textcolor,'Monster knows the following spells :');
 for j:=1 to maxmspells do begin
  if monster[i]^.spell[j] then begin
   d(4,spell_name_monster(j));
  end;
 end;
 }

 {monsters mana is reduced}
 dec(monster[i]^.mana,spell_cost_monster(monster_spell));

end; {monster_magic_attack **end**}

Procedure Player_vs_Monsters; {Main START}
const soulstrike:longint=0;

var

 cho : char;

 fastgame,
 to_death,
 expert_press : boolean;

 s,
 dungeon : s70;

 i,
 j,
 x,
 zz,
 yy,
 xx  : longint;

 y,
 diff,
 stab1 : integer;

 k,
 mon,
 attack_order,
 dummy : byte;


 mtemp1 : array [1..global_maxmon] of s70;
 mtemp2 : array [1..global_maxmon] of integer;

Procedure Has_Monster_Died;
var result,
    plynr : byte;
begin

 {has monster died?}
 if (monster[mon]^.name<>'') and (monster[mon]^.hps<1) then begin
  if random(5)=0 then begin
   d(config.textcolor,'The '+monster[mon]^.name+' looks surprised when your final blow');
   d(config.textcolor,'causes its instant death!');
  end;
  d(14,'You have killed the '+monster[mon]^.name+'!');
  pause;
  inc(player.m_kills);
  monster[mon]^.name:='';
  xx:=dungeon_reward(global_dungeonlevel);

  {does XP haves to be split with teammates?}
  yy:=1;
  if player_active(pl1,true) then inc(yy);
  if player_active(pl2,true) then inc(yy);
  if player_active(pl3,true) then inc(yy);
  if player_active(pl4,true) then inc(yy);

  if yy>1 then d(3,'The experience and '+config.moneytype+' are split equally...');

  xx:=xx div yy;
  incplayerexp(player,xx);

  if yy>1 then sd(config.textcolor,'You receive your share of ')
  else sd(config.textcolor,'You receive ');

  sd(14,commastr(xx));
  d(config.textcolor,' experience points!');

  if player_active(pl1,true) then incplayerexp(pl1,xx);
  if player_active(pl2,true) then incplayerexp(pl2,xx);
  if player_active(pl3,true) then incplayerexp(pl3,xx);
  if player_active(pl4,true) then incplayerexp(pl4,xx);

  xx:=random(300)*global_dungeonlevel;
  inc(xx,random(500));
  sd(config.textcolor,'You search the corpse and find ');
  sd(14,commastr(xx));
  d(config.textcolor,' '+many_money(xx)+'!');

  xx:=xx div yy;
  incplayermoney(player,xx);

  if yy>1 then begin
   sd(config.textcolor,'Your share is ');
   sd(14,commastr(xx));
   d(config.textcolor,' '+many_money(xx)+'!');
  end;
  if player_active(pl1,true) then incplayermoney(pl1,xx);
  if player_active(pl2,true) then incplayermoney(pl2,xx);
  if player_active(pl3,true) then incplayermoney(pl3,xx);
  if player_active(pl4,true) then incplayermoney(pl4,xx);

  {should player take monster weapon/armor?}
  if (random(5)=0) and (monster[mon]^.weapon<>'') and
     (monster[mon]^.grabweap=true) and (config.classic=false) then begin
   crlf;
   sd(14,'You have found something : ');
   d(global_itemcol,monster[mon]^.weapon);

   if confirm('Take it ','Y')=true then begin

    xx:=inventory_empty(player);
    if xx=0 then begin
     d(15,'Your inventory is full!');
     if confirm('Drop something ','Y')=true then begin
      drop_item(player);
     end;
    end;

    xx:=inventory_empty(player);
    if xx>0 then begin
     player.item[xx]:=monster[mon]^.weapnr;
     player.itemtype[xx]:=weapon;
     sd(config.textcolor,'You place the ');
     sd(global_itemcol,monster[mon]^.weapon);
     d(config.textcolor,' in your backpack');
     pause;
    end;

   end
   else begin
    {player decided not to take the weapon...teammembers can have
     their go at it now.}

    for plynr:=1 to 4 do begin
     case plynr of
      1: tempman:=pl1;
      2: tempman:=pl2;
      3: tempman:=pl3;
      4: tempman:=pl4;
     end; {case .end.}

     if (tempman.name2<>'') and (tempman.hps>0) then begin

      crlf;
      sd(global_plycol,tempman.name2);
      sd(config.textcolor,' picks up the ');
      d(global_itemcol,monster[mon]^.weapon+config.textcol1+'.');

      result:=check_inventory(tempman,monster[mon]^.weapnr,weapon,true,4);

      {tempman took the item}
      if result>0 then begin
       case plynr of
        1: pl1:=tempman;
        2: pl2:=tempman;
        3: pl3:=tempman;
        4: pl4:=tempman;
       end; {case .end.}
       break;
      end;

     end;

    end; {for plynr:= .end.}

   end;
  end;

  if (random(5)=0) and (monster[mon]^.armor<>'') and
     (monster[mon]^.grabarm=true) and
     (config.classic=false) then begin

   crlf;
   sd(14,'You have found something : ');
   d(global_itemcol,monster[mon]^.armor);
   if confirm('Take it ','Y')=true then begin
    xx:=inventory_empty(player);

    if xx=0 then begin
     d(15,'Your inventory is full!');
     if confirm('Drop something ','Y')=true then begin
      drop_item(player);
     end;
    end;
    xx:=inventory_empty(player);

    if xx>0 then begin
     player.item[xx]:=monster[mon]^.armnr;
     player.itemtype[xx]:=abody;
     sd(config.textcolor,'You place the ');
     sd(global_itemcol,monster[mon]^.armor);
     d(config.textcolor,' in your backpack');
     pause;
    end;

   end
   else begin
    {player decided not to take the armor...teammembers can have
     their go at it now.}

    for plynr:=1 to 4 do begin
     case plynr of
      1: tempman:=pl1;
      2: tempman:=pl2;
      3: tempman:=pl3;
      4: tempman:=pl4;
     end; {case .end.}

     if (tempman.name2<>'') and (tempman.hps>0) then begin

      crlf;
      sd(global_plycol,tempman.name2);
      sd(config.textcolor,' picks up the ');
      d(global_itemcol,monster[mon]^.armor+config.textcol1+'.');

      result:=check_inventory(tempman,monster[mon]^.armnr,abody,true,4);

      {tempman took the item}
      if result>0 then begin
       case plynr of
        1: pl1:=tempman;
        2: pl2:=tempman;
        3: pl3:=tempman;
        4: pl4:=tempman;
       end; {case .end.}
       break;
      end;

     end;

    end; {for plynr:= .end.}
   end;
  end;
 end;

end; {has_monster_died **end**}

begin {MAIN PROC **START**}

 {init}
 attack_order:=1;
 healed:=false;
 to_death:=false;
 done:=false;

 {to handle "carrier-dropping" cheaters}
 global_PlayerInFight:=true;

 mon:=0;

 {code here used to set hps to strength*3.
  This made setting hitpoints in the monster editor completely
  pointless.}

 repeat
  player.casted:=false;
  pl1.casted:=false;
  pl2.casted:=false;
  pl3.casted:=false;
  pl4.casted:=false;

  healed:=false;

  crlf;
  d(7,'You are fighting :');
  crlf;

  for i:=1 to global_maxmon do begin
   mtemp1[i]:='';
   mtemp2[i]:=0;
  end;

  for i:=1 to global_maxmon do begin
   found:=false;
   if monster[i]^.hps>0 then begin
    for j:=1 to global_maxmon do begin
     if mtemp1[j]=monster[i]^.name then begin
      inc(mtemp2[j],1);
      found:=true;
      break;
     end;
    end;
    if found=false then begin
     for j:=1 to global_maxmon do begin
      if mtemp1[j]='' then begin
       mtemp1[j]:=monster[i]^.name;
       inc(mtemp2[j],1);
       break;
      end;
     end;
    end;
   end;
  end; {for i:= .end.}

  x:=0;
  y:=0;
  for i:=1 to global_maxmon do begin
   if mtemp1[i]<>'' then begin
    inc(y);
    if y<>1 then begin
     sd(global_moncol,', ');
    end;

    inc(x);
    if x>3 then begin
     x:=0;
     crlf;
    end;

    if mtemp2[i]=1 then sd(global_moncol,mtemp1[i])
                   else sd(global_moncol,commastr(mtemp2[i])+' '+mtemp1[i]);
    if mtemp2[i]>1 then begin
     sd(global_moncol,'s');
    end;

   end;
  end;
  crlf;

  sd(global_plycol,'Your ');
  sd(config.textcolor,'hitpoints : ');
  sd(global_hpcol,commastr(player.hps));
  sd(config.textcolor,'/');
  d(global_hpcol,commastr(player.maxhps));

  for i:=1 to 4 do begin
   case i of
    1: tempman:=pl1;
    2: tempman:=pl2;
    3: tempman:=pl3;
    4: tempman:=pl4;
   end; {case .end.}

   if tempman.name2<>'' then begin
    if tempman.hps>0 then begin
     sd(global_plycol,tempman.name2+' ');
     d(3,condition(tempman.hps,tempman.maxhps));
    end
    else begin
     d(12,tempman.name2+'s corpse, laying in a pool of blood...');
    end;
   end;
  end;

  expert_press:=false;
  if to_death=false then cho:='?'
                    else cho:='A';

  repeat

   if cho='?' then begin
    if (player.expert=false) or (expert_press=true) then begin
     expert_press:=false;
     crlf;
     menu2('(A)ttack  ');
     menu2('(R)un  ');
     menu2('(H)eal  ');
     menu2('(Q)uick Heal ');
     menu2('(D)etailed Monster list');
     crlf;
     menu2('(S)tatus  ');
     menu2('(F)ight to Death ');
     menu2('(B)eg for Mercy  ');
     menu2('(*) Team command ');

     if player.class in [Cleric,Magician,Sage] then begin
      menu2('(C)ast Spell  ');
     end;

     if player.class=Paladin  then menu2('(1) Soul Strike  ');
     if player.class=Assassin then menu2('(1) Backstab  ');
     crlf;
     sd(6,':');
    end
    else begin
     crlf;
     sd(config.textcolor,'Dng Fight (A,R,H,Q,D,S,F,B,*');
     if player.class in [Cleric,Magician,Sage] then begin
      sd(config.textcolor,',C');
     end;
     if player.class in [Paladin,Assassin] then begin
       sd(config.textcolor,',1');
     end;
     sd(config.textcolor,',?) :');
    end;
   end;

   cho:=' ';

   if to_death=false then begin

    cho:=upcase(getchar);

    if cho=chr(13) then cho :='A';


    if cho='?' then begin
     expert_press:=true;
    end;

   end
   else begin
    if player.hps+3<player.maxhps then begin
     quick_healing(player);
    end;
    cho:='A';
   end;

   case cho of
    'U':begin {use item - -only in NEW game mode}

         if config.classic=false then begin
          inventory_display(player);
          use_item(0);
          crlf;
          cho:='A';
         end
         else begin
          cho:='?';
         end;

        end;
    'S':begin
         status(player);
         crlf;
         cho:='?';
        end;
    'F':begin {fight to the death}
         crlf;
         if confirm('Fight to Death ','Y')=true then begin
          d(4,'IT''S YOU OR THEM!!');
          to_death:=true;
          cho:='A';
         end
         else begin
          cho:='?';
         end;
        end;

    '*':begin {team commands / options}
         crlf;
         if player.team='' then begin
          d(5,'You are not a member of a team!');
         end;
         if (pl1.name2='') and (pl2.name2='') and
            (pl3.name2='') and (pl4.name2='') then begin
          d(5,'You have no teammembers with you!');
          pause;
         end
         else begin
          repeat
           d(14,'Command :');
           menu('(A)ttack order');
           menu('(B)rief Status report');
           menu('(D)etailed report');

           sd(config.textcolor,'[');
           sd(5,'Enter');
           d(config.textcolor,'] to continue');
           sd(config.textcolor,':');
           cho:=upcase(getchar);

           case cho of
            'A':begin {attack order}
                 crlf;
                 sd(config.textcolor,'Current order : ');

                 case attack_order of
                  1: d(global_talkcol,'Pick your own targets');
                  2: d(global_talkcol,'Follow MY example');
                  3: d(global_talkcol,'Attack the strongest opponent');
                  4: d(global_talkcol,'Attack the weakest opponent');
                 end;

                 menu('(P)ick your own targets.');
                 menu('(F)ollow my example!');
                 menu('(S) attack strongest opponent');
                 menu('(W) attack weakest opponent');

                 sd(config.textcolor,':');
                 repeat
                  cho:=upcase(getchar);
                 until cho in ['P','F','S','W'];
                 crlf;

                 case cho of
                  'P':begin
                       attack_order:=1;
                       d(global_talkcol,'Pick your own targets!');
                      end;
                  'F':begin
                       attack_order:=2;
                       d(global_talkcol,'Follow my example!');
                      end;
                  'S':begin
                       attack_order:=3;
                       d(global_talkcol,'Attack the strongest opponent!');
                      end;
                  'W':begin
                       attack_order:=4;
                       d(global_talkcol,'Attack the weakest!');
                      end;
                 end; {case .end.}

                end;
            'D':begin
                 crlf;
                 if player_active(pl1,true) then menu('[1] '+pl1.name2)
                                            else menu('[1] ---');
                 if player_active(pl2,true) then menu('[2] '+pl2.name2)
                                            else menu('[2] ---');
                 if player_active(pl3,true) then menu('[3] '+pl3.name2)
                                            else menu('[3] ---');
                 if player_active(pl4,true) then menu('[4] '+pl4.name2)
                                            else menu('[4] ---');
                 sd(config.textcolor,':');
                 cho:=upcase(getchar);

                 case cho of
                  '1': if player_active(pl1,true) then status(pl1);
                  '2': if player_active(pl2,true) then status(pl2);
                  '3': if player_active(pl3,true) then status(pl3);
                  '4': if player_active(pl4,true) then status(pl4);
                 end;
                 cho:=' ';

                end;
            'B':begin
                 crlf;

                 for i:=1 to 4 do begin
                  case i of
                   1: tempman:=pl1;
                   2: tempman:=pl2;
                   3: tempman:=pl3;
                   4: tempman:=pl4;
                  end; {case .end.}
                  if tempman.name2<>'' then begin
                   if tempman.hps<1 then begin
                    d(12,tempman.name2+', dead');
                   end
                   else begin
                    sd(global_plycol,tempman.name2);
                    sd(config.textcolor,' has ');
                    sd(5,commastr(tempman.healing));
                    d(config.textcolor,' healing potions');
                   end;
                  end;
                 end;

                 crlf;
                end;
           end;
          until cho=ReturnKey;
         end;
         cho:='?';
        end;

    'D':begin {display monsters}
         crlf;
         for i:=1 to global_maxmon do begin
          if monster_active(i)=true then begin
           sd(global_moncol,monster[i]^.name+' ('+commastr(monster[i]^.hps)+' hps)');

           if monster[i]^.weapon<>'' then begin
            sd(7,'  Weapon : '+monster[i]^.weapon);
           end;
           if monster[i]^.armor<>'' then begin
            sd(7,'  Armor : '+monster[i]^.armor);
           end;

           crlf;

           if (first=false) and (config.mon_talk=true) then begin
            d(global_talkcol,'  '+monster[1]^.phrase);
            first:=true;
           end;
          end;
         end;
         pause;
         cho:='?';
        end;
    'C':begin {can spells be used?}

         cho:=' ';
         if player.class in [Cleric,Magician,Sage] then begin
          player.casted:=false;

          cast_spell(false,1,1,player,player,false,mon);

          if player.casted=true then begin
           has_monster_died;
           cho:='A';
          end
          else begin
           cho:='?';
          end;

         end;
        end;
    '1':begin {Backstab, poison option available?}
         if (player.race=Gnoll) or (player.class in [Paladin,Assassin]) then begin
          {}
         end
         else begin
          cho:='?';
         end;
        end;
    'Q':begin {check if healing is necessary}
         if player.hps>=player.maxhps then begin
          d(7,'You are in no need of healing!');
          cho:='?';
         end;
        end;
   end;
  until cho in ['A','R','H','Q','B','1'];

  stab1:=0;
  case cho of

   'Q':begin {* Player uses Quick heal *}
        quick_healing(player);
        case config.quaffopt of
         1:begin {player Quaffs potion and then autoattacks}
            {healed:=true;}
            cho:='A';
           end;
         2:begin {player Quaffs potion and then monster attack}
            healed:=true;
            cho:='A';
           end;
         3:begin {player Quaffs potion and then chooses another option}
            {healed:=true;}
            cho:='?';
           end;
        end;
       end;
   'H':begin {* Player heals himself *}
        healing(player);
        case config.quaffopt of
         1:begin
            {healed:=true;}
            cho:='A';
           end;
         2:begin
            healed:=true;
            cho:='A';
           end;
         3:begin
            {healed:=true;}
            cho:='?';
           end;
        end;
       end;

   'B':begin {* Player begs for Mercy *}
        if monster_mode=pl_vs_prisonguards then begin
         {give up to the prison guards! immediately imprisoned!}
         crlf;
         d(15,'You surrender to the guards!');
         crlf;
         pause;
         inc(player.m_defeats);
         global_begged:=true;
         global_PlayerInFight:=false;
         exit;
        end
        else if (global_nobeg) or (monster_mode<>pl_vs_monster) then begin
         d(15,'No Mercy is given here!');
         cho:='A';
        end
        else if monster_mode=pl_vs_monster then begin
         crlf;
         if confirm('Beg for Mercy','N')=true then begin
          if (random(3)=0) or (global_nobeg=true) then begin
           crlf;
           d(config.textcolor,'You throw yourself to the ground and plead for mercy!');
           d(config.textcolor,'But the monster doesn'+chr(39)+'t seem to care');
           d(config.textcolor,'about your pathetic whining!');
           crlf;
           d(config.textcolor,'You soon realize that your life has come to an end...');
           d(4,'Splatt! Splatt! Your limbs are torn apart...');
           crlf;
           d(config.textcolor,'Darkness...');
           crlf;

           inc(player.m_defeats);
           global_begged:=true;
           global_killed:=true;
           global_PlayerInFight:=false;
           crlf;

           exit;
          end
          else begin
           crlf;
           d(config.textcolor,'You throw yourself to the ground and plead for mercy!');
           d(config.textcolor,'Your foe doesn''t seem to care');
           d(config.textcolor,'about whether you live or die.');
           crlf;
           d(config.textcolor,'You soon realize that you will make it out of this situation!');
           d(config.textcolor,'You watch how your foe slowly lurks away...');
           cho:='R';
           X:=99;
           break;
          end;
         end;
        end;
       end;

   '1':begin {*Attacking player uses Backstab*}
        if player.class=Assassin then begin
         stab1:=0;
         if config.classic then begin
           if player.weapon=0 then begin
             crlf;
             d(config.textcolor,'You don''t have a weapon!');
             crlf;
             pause;
             cho:=' ';
           end;
         end
         else begin
           if player.rhand+player.lhand=0 then begin
             crlf;
             d(config.textcolor,'You don''t have a weapon!');
             crlf;
             pause;
             cho:=' ';
           end;
         end;

         { Make sure we still can backstab }
         if (cho = '1') then
         begin
          mon:=target_monster;
          crlf;
          d(config.textcolor,'You try to Backstab the '+monster[mon]^.name+'!');
          if random(3)=0 then begin
           d(config.textcolor,'You manage to cut the '+monster[mon]^.name+'!');
           d(config.textcolor,'The '+monster[mon]^.name+' screams in pain!');
           stab1:=player.maxhps div 2;
          end
          else begin
           d(config.textcolor,'You missed!');
           stab1:=-1;
          end;
          cho:='A';
         end;
        end;

        if player.class=Paladin then begin
         crlf;
         if player.hps<2 then begin
          d(config.textcolor,'Sorry, too few hitpoints left!')
         end
         else begin
          mon:=target_monster;
          sd(6,'How many hitpoints to use (max '+commastr(player.hps-1)+') :');
          zz:=get_number(0,player.hps-1);
          if (zz>0) and (zz<=player.hps) then begin
           soulstrike:=zz;
           dec(player.hps,zz);
           if (player.mental<50) and (random(3)=0) then begin
            if random(player.mental)<random(player.mental) then begin
             d(config.textcolor,'Soulstrike failed due to weak concentration.');
             soulstrike:=0;
            end;
           end;
           if (player.addict>50) and (soulstrike>0) and (random(3)=0) then begin
            if random(player.addict)>random(player.addict) then begin
             d(config.textcolor,'Soulstrike failed due to your weakness.');
             soulstrike:=0;
            end;
           end;
           cho:='A';
          end
          else begin
           d(config.textcolor,'Aborted.');
           cho:=' ';
          end;
         end;
        end;
       end;
  end;

  if cho='A' then begin {attack option has been activated}

   crlf;
   if mon<1 then begin
    x:=0;
    for i:=1 to global_maxmon do begin
     if monster[i]^.hps>0 then begin
      if x<1 then mon:=i;
      inc(x);
     end;
    end; {for i:= .end.}
    if x>1 then begin
     mon:=target_monster;
    end;
   end;

   {strength in monster attacks, depending on the MODE variable}
   monster_charge(monster_mode);

   {monster picks target, if there are more than 1}
   for i:=1 to global_maxmon do begin
    monster[i]^.target:=1;

    if monster_mode<>pl_vs_demon then begin
     if (player_active(pl1,true)) and (random(3)=0) then begin
      monster[i]^.target:=2;
     end;
     if (player_active(pl2,true)) and (random(3)=0) then begin
      monster[i]^.target:=3;
     end;
     if (player_active(pl3,true)) and (random(3)=0) then begin
      monster[i]^.target:=4;
     end;
     if (player_active(pl4,true)) and (random(3)=0) then begin
      monster[i]^.target:=5;
     end;
    end;

   end;

   {styrkan i spelarnas attacker}
   player.punch:=normal_attack(false,player);

   if healed=true then begin
    player.punch:=0;
   end;

   if soulstrike>0 then begin
    zz:=soul_effect(player,soulstrike);

    inc(player.punch,zz);
    soulstrike:=0;
    d(config.textcolor,'Soulstrike hits '+monster[mon]^.name+' for '+commastr(zz)+' points!');
   end;

   {*Gnoll poison?*}
   if (player.race=Gnoll) and (monster[mon]^.poisoned=false) then begin
    {x:=random(global_dungeonlevel+5);}
    x:=random(4)+1;
    if x=3 then begin
     d(config.textcolor,'**Poisonous Gnollbite!**');
     monster[mon]^.poisoned:=true;
    end;
   end;

   {restoring overmaxed hps}
   if player.hps>player.maxhps then player.hps:=player.maxhps;

   {backstab effect}
   if stab1>0 then player.punch:=player.punch+stab1;

   if stab1=-1 then begin
    monster[mon]^.punch:=monster[mon]^.punch+player.level+3;
    player.punch:=0;
   end;

   {poison effect}
   if player.poison>0 then begin
    player.punch:=player.punch+player.poison;
   end;

   if (stab1<>-1) and (player.punch=0) and (healed=false) and (player.casted=false) then begin
    d(config.textcolor,'You missed your blow!');
   end;

   if (player.punch>0) and (healed=false) and (player.casted=false) then begin

    if player.punch>0 then begin
     if monster[mon]^.name='' then begin
      mon:=target_monster;
     end;
     d(12,'You hit the '+monster[mon]^.name+' for '+commastr(player.punch)+' damage!');

     x:=0;
     {monster armor/defence}
     
     
     zz:=0;
     zz:=monster[mon]^.defence+random(monster[mon]^.defence div 8);
     
if monster[mon]^.armnr>0 then begin
zz:=zz+random(monster[mon]^.armpow);
end;

     if zz>0 then begin
      inc(x,zz);
     end;
 
 if x>0 then begin

      {kludge, the programmer (jakob) is sloppy, he admits!}
      if x>player.punch then x:=player.punch;
      dec(player.punch,x);
      d(3,monster[mon]^.name+'s armor absorbed '+commastr(x)+' points!');

     end;

     dec(monster[mon]^.hps,player.punch);

     has_monster_died;

    end;
   end;

   {TeamMates attacks monster(s)}
   for i:=1 to 4 do begin
    case i of
     1: tempman:=pl1;
     2: tempman:=pl2;
     3: tempman:=pl3;
     4: tempman:=pl4;
    end;

    if (tempman.name2<>'') and (tempman.hps>0) then begin

     x:=tempman.healing;
     {need to heal?}
     computer_healing(true,tempman);
     if (x<>tempman.healing) and (config.quaffopt=2) then x:=-1;

     if x<>-1 then begin {quaff=2 inneb„r n„mligen att spelaren binds en runda}

      {picks monster dependending on attack_order [1..4] }
      j:=0;
      case attack_order of
       1:begin {pick the first monster available}

          for k:=1 to global_maxmon do begin
           if monster_active(k)=true then begin
            j:=k;
            break;
           end;
          end; {for k:= .end.}

         end;
       2:begin {follow PLAYERS example}

          if mon>0 then begin
           if monster_active(mon)=true then begin
            j:=mon;
           end;
          end;

          if j=0 then begin
           for k:=1 to global_maxmon do begin
            if monster_active(k)=true then begin
             j:=k;
             break;
            end;
           end; {for k:= .end.}
          end;

         end;
       3:begin {pick the strongest opponent}

          xx:=0;
          for k:=1 to global_maxmon do begin
           if monster_active(k)=true then begin
            if monster_power(k)>xx then begin
             xx:=monster_power(k);
             j:=k;
            end;
           end;
          end; {for k:= .end.}

          if j=0 then begin
           for k:=1 to global_maxmon do begin
            if monster_active(k)=true then begin
             j:=k;
             break;
            end;
           end; {for k:= .end.}
          end;

         end;
       4:begin {pick the weakest opponent}

          xx:=0;
          for k:=1 to global_maxmon do begin
           if monster_active(k)=true then begin
            xx:=monster_power(k);
            break;
           end;
          end; {for k:= .end.}

          for k:=1 to global_maxmon do begin
           if monster_active(k)=true then begin
            if monster_power(k)<xx then begin
             xx:=monster_power(k);
             j:=k;
            end;
           end;
          end; {for k:= .end.}

          if j=0 then begin
           for k:=1 to global_maxmon do begin
            if monster_active(k)=true then begin
             j:=k;
             break;
            end;
           end; {for k:= .end.}
          end;

         end;
      end;


      if j>0 then begin

       {suitable monster found, now deciding type of attack}

       norm_att:=true;
       {*soul strike?*}
       if (tempman.class=Paladin) and (tempman.hps>100) and
          (random(3)=0) and (tempman.casted=false) then begin

        zz:=tempman.hps div 3;
        dec(tempman.hps,zz);

        zz:=soul_effect(tempman,zz);
        dec(monster[j]^.hps,zz);
        s:=hit_output(zz);
        sd(config.textcolor,'Soulstrike from ');
        sd(global_plycol,tempman.name2);
        sd(config.textcolor,' hits ');
        sd(global_moncol,monster[j]^.name);
        d(config.textcolor,' for '+s+' damage!');
        norm_att:=false;
       end

       else if (tempman.class=Assassin) and (random(3)=0) and
               (tempman.rhand+tempman.lhand>0) then begin
        {*Backstab?*}
        sd(global_plycol,tempman.name2);
        d(3,' tries to Backstab the '+monster[j]^.name+'!');
        if random(3)=0 then begin
         d(3,'SUCCESS! The '+monster[j]^.name+' is covered with blood!');
         zz:=tempman.maxhps div 2;
         dec(monster[j]^.hps,zz);
        end
        else begin
         d(3,'But misses!');
        end;
        norm_att:=false;
       end
       else if tempman.class in [Cleric,Magician,Sage] then begin
        if (tempman.mana>15) and (random(3)=0) then begin
         {spell casting?}
         tempman.absorb:=0;
         cast_spell(false,1,1,tempman,tempman,false,dummy);
         cast_spell(false,j+9999,1,tempman,tempman,false,dummy);
         norm_att:=false;
        end;
       end;

       if norm_att=true then begin
        {*Normal attack}
        zz:=normal_attack(false,pl1);
        s:=hit_output(zz);
             x:=monster[j]^.defence+random(monster[j]^.defence div 8);
if monster[j]^.armnr>0 then begin
x:=x+random(monster[j]^.armpow);
end;
        
        if x>0 then begin
         if x>zz then x:=zz;

         dec(zz,x);
        end;
        dec(monster[j]^.hps,zz);

        if (random(6)=0) and (tempman.battlecry<>'') then begin
         sd(global_talkcol,tempman.battlecry);
         sd(config.textcolor,', ');
         sd(global_plycol,tempman.name2);
         d(config.textcolor,' screams!');
        end;

        if zz>0 then begin
         sd(global_plycol,tempman.name2);
         sd(3,' slashes ');
         sd(global_moncol,monster[j]^.name);
         d(3,' for '+s+' damage!');
         if x>0 then begin
          sd(global_moncol,monster[j]^.name+'s ');
          d(3,'armor absorbed '+uwhite+commastr(x)+ucyan+' points!');
         end;
        end
        else begin
         sd(global_plycol,tempman.name2);
         sd(3,' attacks ');
         sd(global_moncol,monster[j]^.name);
         d(config.textcolor,' but misses!');
        end;
       end;

       if monster[j]^.hps<1 then begin
        inc(tempman.m_kills);

        kill_comment(tempman,monster[j]^.name);
        monster[j]^.name:='';
        if j=mon then mon:=0;

        xx:=dungeon_reward(global_dungeonlevel);
        {does the XP have to be split with teammates?}
        yy:=1;
        if player_active(pl1,true) then inc(yy);
        if player_active(pl2,true) then inc(yy);
        if player_active(pl3,true) then inc(yy);
        if player_active(pl4,true) then inc(yy);

        if yy>1 then d(3,'The Experience and '+config.moneytype+' are split equally...');

        xx:=xx div yy;
        incplayerexp(player,xx);

        sd(config.textcolor,'You receive your share of ');
        sd(14,commastr(xx));
        d(config.textcolor,' experience points!');

        if player_active(pl1,true) then incplayerexp(pl1,xx);
        if player_active(pl2,true) then incplayerexp(pl2,xx);
        if player_active(pl3,true) then incplayerexp(pl3,xx);
        if player_active(pl4,true) then incplayerexp(pl4,xx);

        {search monster corpse for gold}
        xx:=random(300)*global_dungeonlevel;
        inc(xx,random(500));
        sd(global_plycol,tempman.name2);
        sd(config.textcolor,' search the corpse and finds ');
        sd(14,commastr(xx));
        d(config.textcolor,' '+many_money(xx)+'!');

        xx:=xx div yy;
        incplayermoney(player,xx);

        sd(config.textcolor,'Your share is ');
        sd(14,commastr(xx));
        d(config.textcolor,' '+many_money(xx)+'!');

        if player_active(pl1,true) then incplayermoney(pl1,xx);
        if player_active(pl2,true) then incplayermoney(pl2,xx);
        if player_active(pl3,true) then incplayermoney(pl3,xx);
        if player_active(pl4,true) then incplayermoney(pl4,xx);

        {should the player take monster weapon/armor?}
        if (monster[j]^.weapon<>'') and (monster[j]^.grabweap=true) and
           (config.classic=false) then begin
         crlf;
         sd(global_plycol,tempman.name2);
         d(config.textcolor,' has found : ');
         d(global_itemcol,' '+monster[j]^.weapon);

         check_inventory(tempman,monster[j]^.weapnr,weapon,true,3);

        end;

        if (monster[j]^.armor<>'') and (monster[j]^.grabarm=true) and
           (config.classic=false) then begin
         crlf;
         sd(global_plycol,tempman.name2);
         d(config.textcolor,' has found : ');
         d(global_itemcol,' '+monster[j]^.armor);

         check_inventory(tempman,monster[j]^.armnr,abody,true,3);

        end;
       end;
      end;
     end;
    end;

    case i of
     1: pl1:=tempman;
     2: pl2:=tempman;
     3: pl3:=tempman;
     4: pl4:=tempman;
    end;

   end;

   for i:=1 to global_maxmon do begin
    if (monster_active(i)=true) and (monster[i]^.poisoned=true) then begin
     x:=random(5)+1;
     sd(global_moncol,monster[i]^.name);
     d(config.textcolor,' suffers from poison!');
     dec(monster[i]^.hps,x);
    end;

    if (monster_active(i)=true) and (monster[i]^.disease=true) then begin
     x:=random(14)+1;
     sd(global_moncol,monster[i]^.name);
     d(config.textcolor,' suffers from a disease!');
     dec(monster[i]^.hps,x);
    end;
   end;

   {take into account long lasting spells}

   cast_spell(false,mon+9999,1,player,player,false,dummy);


   {monster attacks}
   xx:=0;
   y:=0;
   for i:=1 to global_maxmon do begin

    case monster[i]^.target of
     1: tempman:=player;
     2: tempman:=pl1;
     3: tempman:=pl2;
     4: tempman:=pl3;
     5: tempman:=pl4;
    end;

    tempman.absorb:=0;

    if tempman.hps>0 then begin

     inc(y);
     if (y>8) and (to_death=false) then begin
      y:=0;
      pause;
     end;

     {**START** monster decides if it should cast a spell **START**}

     {fusk! ger monster alla spells!}
     {for j:=1 to global_maxmspells do begin
      monster[i]^.spell[j]:=true;
     end;}

     monster_magic:=false;
     monster_spell:=0;
     ms:=0;

     if monster_active(i) then begin
      for j:=1 to global_maxmspells do begin
       if monster[i]^.spell[j] then begin
        if monster[i]^.mana>=spell_cost_monster(j) then begin
         inc(ms);
        end;
       end;
      end; {for j:= .end.}

      if (ms>0) and (random(2)=0) then begin
       ms:=random(ms)+1;
       ms2:=0;
       for j:=1 to global_maxmspells do begin
        if (monster[i]^.spell[j]) and (monster[i]^.mana>=spell_cost_monster(j)) then begin
         inc(ms2);
         if ms2=ms then begin
          ms:=j;
          monster_spell:=ms;
          monster_magic:=true;
          break;
         end;
        end;
       end;
      end;
     end;

     {**END** monster cast spell decision **END**}





     if (monster[i]^.punch<1) and (monster[i]^.name<>'') and
        (not monster_magic) then begin
      if tempman.name2=player.name2 then begin
       sd(global_moncol,monster[i]^.name);
       d(13,' missed you completely!')
      end
      else begin
       sd(global_moncol,monster[i]^.name);
       sd(13,' missed ');
       d(global_plycol,tempman.name2+'!');
      end;
      inc(xx);
     end;

     if (monster_active(i)) then begin

      if (monster[i]^.punch>0) or (monster_magic) then begin

       if NOT monster_magic then begin
        s:=hit_output(monster[i]^.punch);

        if tempman.name2=player.name2 then begin
         sd(global_moncol,monster[i]^.name);
         sd(12,' hits You for '+s+' damage!')
        end
        else begin
         sd(global_moncol,monster[i]^.name);
         sd(12,' hits ');
         sd(global_plycol,tempman.name2);
         d(12,' for '+s+' damage!');
        end;

        inc(xx);

        {cast_spell(2,1,tempman,tempman);}
        normal_defence(tempman);

        if tempman.absorb>monster[i]^.punch then begin
         tempman.absorb:=monster[i]^.punch;
        end;
        if tempman.absorb<0 then begin
         tempman.absorb:=0;
        end;

        if (tempman.absorb>0) and (tempman.name2=player.name2) then begin
         d(3,'  (armor absorbed '+commastr(percent(tempman.absorb,monster[i]^.punch))+'%)');
         monster[i]^.punch:=monster[i]^.punch-tempman.absorb;
         if monster[i]^.punch<0 then begin
          monster[i]^.punch:=0;
         end;
        end
        else begin
         crlf;
        end;

        if monster[i]^.punch>0 then begin
         tempman.hps:=tempman.hps-monster[i]^.punch;
        end;
       end
       else begin {Monster_magic=true}

        monster_magic_attack(i);;
        {MONSTER Decided to CAST a Spell}

       end;

       if tempman.hps<1 then begin

        if tempman.name2=player.name2 then begin
         show_usurper_data(picture_death_head,false);
         d(4,'You are DEAD!');

         {the monster who took players life}
         killed_by[1]:=monster[i]^.name;

         {announce it node-wide}
         online_send_to_all(uplc+player.name2+config.textcol1+' has been killed by a '+umonc+monster[i]^.name
                            +config.textcol1,player.name2,'');

         xplose(tempman);
         inc(tempman.m_defeats);
         pause;

        end
        else begin

         {teammates last words}
         case random(4) of
          0:begin
             d(15,'A horrifying scream is heard!!');
            end;
          1:begin
             sd(global_plycol,tempman.name2);
             d(12,' goes down!');
            end;
          2:begin
             sd(global_talkcol,'Jesus! They got me!');
             sd(15,', ');
             sd(global_plycol,tempman.name2);
             d(15,' whispers.');
            end;
          3:begin
             d(global_talkcol,'Gosh, I''m really BLEEDING guys...!');
            end;
         end;

         show_usurper_data(picture_death_head,false);
         d(4,'** '+tempman.name2+' is DEAD! **');

         {the monster who took players life}
         killed_by[monster[i]^.target]:=monster[i]^.name;

         {announce it node-wide}
         online_send_to_all(uplc+tempman.name2+config.textcol1+' has been killed by a '+umonc+monster[i]^.name+
                            config.textcol1,player.name2,player.name2);

         if tempman.name2<>player.name2 then begin
          update_shadow(tempman.name2,'',true);
         end;
         xplose(tempman);
         inc(tempman.m_defeats);
         pause;

         s:='';
         if random(4)=0 then begin
          if (pl1.name2<>'') and (pl1.name2<>tempman.name2) and
             (pl1.hps>0) then begin
           s:=pl1.name2;
          end
          else if (pl2.name2<>'') and (pl2.name2<>tempman.name2) and
                  (pl2.hps>0) then begin
           s:=pl2.name2;
          end
          else if (pl3.name2<>'') and (pl3.name2<>tempman.name2) and
                  (pl3.hps>0) then begin
           s:=pl3.name2;
          end
          else if (pl4.name2<>'') and (pl4.name2<>tempman.name2) and
                  (pl4.hps>0) then begin
           s:=pl4.name2;
          end;

          if s<>'' then begin
           case random(3) of
            0:begin
               sd(global_talkcol,'We must avenge '+tempman.name2+'!');
               sd(config.textcolor,', ');
               sd(global_plycol,s);
               d(config.textcolor,' screams!');
              end;
            1:begin
               sd(global_talkcol,'Poor '+tempman.name2+'! Too weak to follow!');
               sd(config.textcolor,', ');
               sd(global_plycol,s);
               d(config.textcolor,' remarks.');
              end;
            2:begin
               sd(global_talkcol,'REVENGE! REVENGE FOR '+tempman.name2+'s DEATH!');
               sd(config.textcolor,', ');
               sd(global_plycol,s);
               d(config.textcolor,' screams!');
              end;
           end;
          end;
         end;
        end;

       end;
      end;
     end;
    end;

    case monster[i]^.target of
     1: player:=tempman;
     2: pl1:=tempman;
     3: pl2:=tempman;
     4: pl3:=tempman;
     5: pl4:=tempman;
    end;

   end;

   done:=true;
   for i:=1 to global_maxmon do begin
    if monster[i]^.hps>0 then begin
     done:=false;
     break;
    end;
   end;

   if player.hps<=0 then begin
    global_killed:=true;
    global_PlayerInFight:=false;
    exit;
   end;
   {infections?}
   infections;

  end;
  {** end of 'A' <attack> **}


  {RUN AWAY}
  if cho='R' then begin
   if (global_escape=false) or (monster_mode<>pl_vs_monster) then begin
    d(12,'YOU CAN''T ESCAPE!');
    cho:='A';
   end
   else if monster_mode=pl_vs_monster then begin
    if Retreat=true then begin
     d(15,'You managed to escape!');
     global_PlayerInFight:=false;
     exit;
    end
    else begin
     d(12,'You failed to escape!');
     crlf;
     cho:='A';
    end;
   end;
  end; {if cho='R'}

 until done;

 {player has left fight}
 global_PlayerInFight:=false;

end;
end.
