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


Unit PlvsPlC; {Usurper - Player vs Player}

Interface

Uses Init;

Procedure Player_vs_Player(var pl2 : UserRec);

Implementation

Uses Jakob, Cms, Statusc,
     SwapEq, Invent, Plvspl2,
     Cast, News, Mail,
     Npc_Chec, Various, Various2,
     Various3, Relation, File_Io, SysUtils;

Procedure Player_vs_Player;
const soulstrike:longint=0;
var
    stab1,zz,x, gold_mem : longint;

    cho : char;

    beg, to_death,
    expert_press, fastgame, offkill, backstab : boolean;

    s,s2, gold_string : s100;

    i, dummy : byte;

begin

 expert_press:=false;
 fastgame:=false;

 {OFFLINE KILL? .CFG}
 offkill:=false;

 s:=cfg_string(34);
 if s='' then offkill:=false;
 if UpperCase(s)='NO' then offkill:=true;

 {resetting spells}
 for i:=1 to global_maxspells do begin
  player.spell[i,2]:=false;
  pl2.spell[i,2]:=false;
 end;

 {let the offline player reinventory his stuff}
 check_inventory(pl2,0,weapon,false,2);

 {to handle "carrier-dropping" cheaters}
 global_PlayerInFight:=true;

 s:=pl2.name2;
 pl2.hps:=pl2.maxhps;
 dec(player.pfights,1);
 clearscreen;
 crlf;
 d(5,'Player Fight!!');

 crlf;
 if pl2.rhand+pl2.lhand>0 then begin
  sd(global_plycol,s);
  d(config.textcolor,' looks grim as '+sex2[pl2.sex]+' swings '+sex3[pl2.sex]+' weapon!');
 end
 else begin
  sd(global_plycol,s);
  d(config.textcolor,' looks a little worried as '+sex2[pl2.sex]+' swings '+sex3[pl2.sex]+' fists!');
 end;

 case random(10) of
  0: s:='Hey you! come and meet your destiny!';
  1: s:='You fight me? Hahaha!';
  2: s:='Come on!';
  3: s:='I''m gonna hack you to pieces!';
  4: s:='Come on '+race_display(2,pl2.race,0)+'! I''m waiting!';
  5: s:='Come over here and I''ll teach you a lesson!';
  6: s:='Bah! Another piece of garbage that needs taking care of!';
  7: s:='Oh my! Why don''t you run back to mama!';
  8: s:='Prepare to die, you worthless worm!';
  9: s:='Scared?';
 end; {case .end.}

 if pl2.phr[1]<>'' then s:=pl2.phr[1];

 sd(global_talkcol,s);
 sd(config.textcolor,', ');
 sd(global_plycol,pl2.name2);
 d(config.textcolor,' screams!');
 crlf;


 beg:=false;
 to_death:=false;

 repeat
  player.used_item:=false;
  pl2.used_item:=false;

  soulstrike:=0;
  sd(global_plycol,'Your');
  sd(config.textcolor,' hitpoints : ');
  d(global_hpcol,commastr(player.hps));

  sd(global_plycol,pl2.name2+'s');
  sd(config.textcolor,' hitpoints : ');
  d(global_hpcol,commastr(pl2.hps));

  if to_death=false then begin
   if (player.expert=false) or (expert_press=true) then begin
    expert_press:=false;
    crlf;
    menu2('(A)ttack  ');
    menu2('(H)eal  ');
    menu2('(Q)uick Heal ');
    menu2('(F)ight to Death');
    crlf;
    menu2('(S)tatus  ');
    menu2('(B)eg for Mercy  ');
    menu2('(U)se Item  ');

    if player.class in [Cleric,Magician,Sage] then begin
     menu2('(C)ast Spell  ');
    end;

    if player.class=Paladin then menu2('(1) Soul Strike  ');
    if player.class=Assassin then menu2('(1) Backstab  ');
    crlf;
    sd(6,':');
   end
   else begin
    sd(config.textcolor,'Fight (A,H,Q,F,S,B,U,*');
    if player.class in [Cleric,Magician,Sage] then sd(config.textcolor,',C');
    if player.class in [Paladin,Assassin] then sd(config.textcolor,',1');
    sd(config.textcolor,',?) :');
   end;

   {get user-input}
   repeat
    cho:=upcase(getchar);
   until cho in ['A','B','Q','H','1','S','F','U','C','?'];

   crlf;
   if cho='?' then begin
    expert_press:=true;
   end
   else if cho='C' then begin
    cho:=' ';
    if player.class in [Cleric,Magician,Sage] then begin
     player.casted:=false;

     cast_spell(fastgame,1,2,player,pl2,false,dummy);

     if player.casted=true then begin
      cho:='A';
     end
     else begin
      cho:=' ';
     end;
    end;
   end;

   if cho='1' then begin
    cho:=' ';
    if (player.class=Assassin) or (player.class=Paladin) then begin
     cho:='1';
    end;
   end;
  end
  else begin
   if player.hps+3<player.maxhps then begin
    quick_healing(player);
   end;
   cho:='A';
  end;

  if cho='U' then begin
   inventory_display(player);
   use_item(0);
   cho:='A';
  end
  else if cho='F' then begin
   if confirm('Fight to Death','n')=true then begin
    to_death:=true;
    cho:='A';
   end;
  end
  else if cho='S' then begin
   status(player);
   s:=player.name2;
  end
  else if cho='H' then begin
   healing(player);
  end
  else if cho='Q' then begin
   quick_healing(player);
  end
  else if cho='B' then begin

   if confirm('Plead for Mercy','n')=true then begin
    beg:=true;

    if random(2)=0 then begin
     crlf;
     d(config.textcolor,'*Surrender!*');
     d(config.textcolor,'************');
     d(config.textcolor,'You throw yourself to the ground and beg for mercy!');
     d(global_plycol,pl2.name2+config.textcol1+' looks at you! The crowd around you scream for blood!');

     if pl2.phr[6]<>'' then begin
      d(global_plycol,pl2.name2+config.textcol1+' laughs at you!');
      d(global_talkcol,pl2.phr[6]);
     end;

     d(config.textcolor,'They hand '+uplc+pl2.name2+config.textcol1+' a big axe... A quick swing, and your head');
     d(config.textcolor,'is seperated from your body....');
     crlf;
     d(config.textcolor,'Darkness surrounds you....');
     d(config.textcolor,'');
     pause;

     {should pl2 take players equipment?}
     swap_objects(pl2,player,true);

     {update "killedby" variable in relations data file}
     killed_by_stats(pl2,player);

     {statistics}
     inc(player.p_defeats);
     inc(pl2.p_kills);
     xplose(player);

     {writing pl2:s record to disk}
     if player.gold>0 then begin
      gold_string:='You emptied '+uplc+player.name2+'s'+config.textcol1+' purse and found '+uyellow+commastr(player.gold)
                   +config.textcol1+' '+many_money(player.gold)+'!';
     end
     else begin
      gold_string:='You took '+uplc+player.name2+'s'+config.textcol1+' purse but it was empty!';
     end;

     pl2.hps:=pl2.maxhps;

     {gold swap}
     gold_mem:=player.gold;
     incplayermoney(pl2,player.gold);
     player.gold:=0;

     {experience}
     x:=random(50)+250;
     x:=x*player.level;
     inc(pl2.exp,x);

     if pl2.autoheal=true then begin
      auto_healing(pl2);
     end;

     user_save(pl2);

     if pl2.ai='H' then begin

      s:='Self-Defence!';

      post(MailSend,
       pl2.name2,
       pl2.ai,
       false,
       mailrequest_nothing,
       '',
       umailheadc+s+config.textcol1,
       mkstring(length(s),underscore),
       'You killed '+uplc+player.name2+config.textcol1+' in self defence! The idiot begged for mercy.',
       'But you chopped '+sex3[player.sex]+' head clean off! NO MERCY!',
       'You received '+uwhite+commastr(x)+config.textcol1+' experience points for this win!',
       gold_string,
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
     ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+' but lost and begged for mercy!',
     ' '+uplc+pl2.name2+config.textcol1+' showed no mercy. '+uplc+player.name2+config.textcol1+' was slaughtered!',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     if gold_mem>0 then begin
      gold_string:=uplc+pl2.name2+config.textcol1+' emptied your purse. You lost '+uyellow+commastr(gold_mem)+config.textcol1
                   +' '+many_money(gold_mem)+'!'
     end
     else begin
      gold_string:='';
     end;

     player.hps:=0;

     reduce_player_resurrections(player,true);
     {player.allow:=false;}

     s:='Your Death';

     post(MailSend,
      player.name2,
      player.ai,
      false,
      mailrequest_nothing,
      '',
      ulred+s+config.textcol1,
      mkstring(length(s),underscore),
      'You were slain by '+uplc+pl2.name2+config.textcol1+'!',
      'You begged for mercy, but the ignorant bastard killed you!',
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
      '');

     pause;
     {remove playerinfight flag}
     global_PlayerInFight:=false;
     normal_exit;
    end
    else begin
     crlf;
     d(config.textcolor,'*Surrender!*');
     d(config.textcolor,'************');
     d(config.textcolor,'You throw yourself to the ground and beg for mercy!');
     d(global_plycol,pl2.name2+config.textcol1+' looks at you! The crowd around you scream for blood!');
     d(config.textcolor,'They hand '+uplc+pl2.name2+config.textcol1+' a big sword. You wait for the deathblow!');
     d(config.textcolor,'But you have been spared! '+uplc+pl2.name2+config.textcol1+' just looks at you with contempt.');

     if pl2.phr[5]<>'' then begin
      d(global_talkcol,pl2.phr[5]);
     end
     else begin
      d(global_talkcol,'I don''t have time to kill worms like you!');
      d(config.textcolor,'You crawl away, happy to be alive, but with no pride!');
     end;
     crlf;

     inc(player.p_defeats);
     inc(pl2.p_kills);

     {writing pl2:s record}
     pl2.hps:=pl2.maxhps;
     x:=random(50)+250;
     x:=x*player.level;
     pl2.exp:=pl2.exp+x;

     user_save(pl2);

     if pl2.ai='H' then begin
      s:='Enemy Surrender!';

      post(MailSend,
       pl2.name2,
       pl2.ai,
       false,
       mailrequest_nothing,
       '',
       umailheadc+s+config.textcol1,
       mkstring(length(s),underscore),
       uplc+player.name2+config.textcol1+' cowardly attacked You! But the scumbag surrendered!',
       'You had '+sex[player.sex]+' begging at your feet, and perhaps should have killed '+sex[player.sex]+'.',
       'But you were in a good mood and spared '+sex3[player.sex]+' miserable life!',
       'You received '+uwhite+commastr(x)+config.textcol1+' experience points from this victory.',
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
     'Coward in action',
     ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+' but turned chicken and '
        +'begged for mercy!',
     ' '+uplc+pl2.name2+config.textcol1+' decided to spare '+uplc+player.name2+'s'+config.textcol1+' miserable life!',
     '',
     '',
     '',
     '',
     '',
     '',
     '');

     player.pfights:=0;
     pause;

     {remove playerinfight flag}
     global_PlayerInFight:=false;
     exit;

    end;
   end;
  end;

  stab1:=0;
  {*Attacking player uses Backstab*}
  if (cho='1') and (player.class=Assassin) then begin
   backstab:=false;
   if config.classic then begin
    if player.weapon=0 then begin
     d(12,'You don''t have a weapon!');
     pause;
     cho:=' ';
    end
    else begin
     backstab:=true;
    end;
   end
   else begin
    if player.rhand+player.lhand=0 then begin
     d(12,'You don''t have a weapon!');
     pause;
     cho:=' ';
    end
    else begin
     backstab:=true;
    end;
   end;

   if backstab then begin
    d(config.textcolor,'You try to Backstab '+pl2.name2+'!');
    if random(3)=0 then begin
     d(config.textcolor,'You manage to cut '+uplc+pl2.name2+config.textcol1+'!');
     d(config.textcolor,uplc+pl2.name2+config.textcol1+' screams in pain!');
     stab1:=player.maxhps div 2;
    end
    else begin
     stab1:=-1;
     d(config.textcolor,'But you miss!');
     d(global_plycol,pl2.name2+config.textcol1+' laughs at your pathetic attempt.');
    end;
    cho:='A';
   end;
  end;

  {*Attacking player uses soul strike*}
  if (cho='1') and (player.class=Paladin) then begin
   if player.hps<2 then begin
    d(12,'Too few hitpoints left!')
   end
   else begin
    d(config.textcolor,'How many hitpoints to use (max '+commastr(player.hps-1)+')');
    sd(config.textcolor,':');
    zz:=get_number(0,player.hps-1);
    if (zz>0) and (zz<=player.hps) then begin
     soulstrike:=zz;
     player.hps:=player.hps-zz;
     cho:='A';
    end
    else begin
     d(config.textcolor,'Aborted.');
     cho:=' ';
    end;
   end;
  end;

  if cho='A' then begin
   player_vs_player2(fastgame,pl2,stab1,beg,soulstrike);
   stab1:=0;
  end;
  player.casted:=false;
  pl2.casted:=false;
 until (player.hps<1) or (pl2.hps<1);

 if (player.hps<1) and (pl2.hps<1) then begin

  {both players have died}
  crlf;
  crlf;
  d(config.textcolor,'Victory and Defeat!');
  d(config.textcolor,'You have slain your foe!');
  d(config.textcolor,'But you were also killed in the final attack!');
  x:=random(50)+250;
  x:=x*pl2.level;
  d(config.textcolor,'You receive '+uwhite+commastr(x)+config.textcol1+' experience points!');

  inc(player.exp,x);
  inc(pl2.exp,x);

  if offkill=true then begin
   reduce_player_resurrections(pl2,false);
   {pl2.allowed:=false;}
  end;

  {update "killedby" variable in relations data file}
  killed_by_stats(pl2,player);
  killed_by_stats(player,pl2);

  {write other player to disk}
  user_save(pl2);

  {news-paper}
  newsy(true,
  'Player Fight!',
  ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+'!',
  ' They killed each other!',
  '',
  '',
  '',
  '',
  '',
  '',
  '');

  if pl2.ai='H' then begin

   s:='Defeat!';

   {inform other player}
   post(MailSend,
   pl2.name2,
   pl2.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s+config.textcol1,
   mkstring(length(s),underscore),
   'You were slain by '+uplc+player.name2+config.textcol1+'!',
   'But you managed to kill '+sex[player.sex]+' to! Victory and defeat!',
   'You received '+uwhite+commastr(x)+config.textcol1+' experience points from this fight!',
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

  player.hps:=0;
  reduce_player_resurrections(player,true);
  {player.allowed:=false;}


  s:='Victory and Defeat';

  {inform player}
  post(MailSend,
  player.name2,
  player.ai,
  false,
  mailrequest_nothing,
  '',
  umailheadc+s+config.textcol1,
  mkstring(length(s),underscore),
  'You were slain by '+uplc+pl2.name2+config.textcol1+'. You killed each other!',
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
  d(config.textcolor,'Darkness...');
  crlf;
  crlf;
  pause;
  {remove playerinfight flag}
  global_PlayerInFight:=false;
  normal_exit;
 end;

 if not beg then begin

  if pl2.hps<1 then begin
   if pl2.phr[3]<>'' then begin
    d(global_plycol,pl2.name2+'s'+config.textcol1+' last words before '+sex2[pl2.sex]+' dies :');
    d(global_talkcol,pl2.phr[3]);
   end;
   crlf;
   d(config.textcolor,'Victory!');
   d(config.textcolor,'You have slain your foe!');
   x:=random(50)+250;
   x:=x*pl2.level;

   xplose(pl2);

   inc(player.exp,x);

   inc(player.p_kills);
   inc(pl2.p_defeats);

   {update "killedby" variable in relations data file}
   killed_by_stats(player,pl2);

   sd(config.textcolor,'You receive ');
   sd(15,commastr(x));
   d(config.textcolor,' experience points!');

   {sd(config.textcolor,'You took ');
   sd(14,commastr(pl2.gold));
   d(config.textcolor,' '+many_money(pl2.gold)+' from the corpse!');
   }

   crlf;
   crlf;
   pause;

   {take losers gold?}
   gold_mem:=-1;
   gold_string:='';
   if pl2.gold>0 then begin
    d(global_plycol,pl2.name2+'s'+config.textcol1+' purse has '+uyellow+commastr(pl2.gold)+config.textcol1
               +' '+many_money(pl2.gold)+' in it!');
    if confirm('Take the '+config.moneytype+' ','Y')=true then begin
     gold_mem:=pl2.gold;
     incplayermoney(player,pl2.gold);
     pl2.gold:=0;
    end
    else begin
     gold_mem:=0;
    end;
   end;

   {swap equipment}
   swap_objects(player,pl2,true);

   crlf;
   sd(config.textcolor,'Leave a note to ');
   sd(global_plycol,pl2.name2);

   if confirm(' ','n')=true then begin
    d(config.textcolor,'Enter Message [1 line]');
    sd(config.textcolor,':');

    s:=get_string(70);
    if s<>'' then begin
     if pl2.ai='H' then begin

      s2:='After-Fight Message';

      post(MailSend,
       pl2.name2,
       pl2.ai,
       false,
       mailrequest_nothing,
       '',
       umailheadc+s2+config.textcol1,
       mkstring(length(s2),underscore),
       'Just before you died, '+uplc+player.name2+config.textcol1+' said:',
       utalkc+s+config.textcol1,
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
     crlf;
     d(10,'Message sent...');
    end;
   end;

   pl2.hps:=0;

   if offkill=true then begin
    {pl2.allowed:=false;}
    reduce_player_resurrections(pl2,false);
   end;

   {write pl2 to disk}
   user_save(pl2);

   case random(7) of
    0: s:=ulred+pl2.name2+config.textcol1+' screamed when cold steel took '+sex3[pl2.sex]+' life!';
    1: s:=ulred+pl2.name2+config.textcol1+' screamed in horror when '+sex2[pl2.sex]+' met death!';
    2: s:=ulred+pl2.name2+config.textcol1+' looked surprised when '+sex2[pl2.sex]+' was cut to pieces!';
    3: s:=ulred+pl2.name2+config.textcol1+' screamed as '+sex2[pl2.sex]+' received the deathblow!';
    4: s:=ulred+pl2.name2+config.textcol1+' gave a short scream when '+sex3[pl2.sex]+' skull was cut in two!';
    5: s:=ulred+pl2.name2+config.textcol1+' died like a wimp!';
    6: s:=ulred+pl2.name2+'s'+config.textcol1+' skull was cut in two by a battleaxe!';
   end; {case .end.}

   {news-paper}
   newsy(true,
   'Player Fight!',
   ' '+uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+' and won!',
   ' '+s,
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   if gold_mem>0 then begin
    {player took opponents gold}
    gold_string:=uplc+player.name2+config.textcol1+' emptied your purse, you lost '+uyellow+commastr(gold_mem)
                 +config.textcol1+' '+many_money(gold_mem)+'!';
   end
   else if gold_mem=0 then begin
    {player was noble and didn't take opponents gold}
    gold_string:=uplc+player.name2+config.textcol1+' let you keep your purse with '+uyellow+commastr(pl2.gold)
                 +config.textcol1+' '+many_money(pl2.gold)+'.';
   end;

   s:='Defeat!';
   {inform opponent}
   post(MailSend,
   pl2.name2,
   pl2.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s+config.textcol1,
   mkstring(length(s),underscore),
   'You were slain by '+uplc+player.name2+config.textcol1+'! '+sex2[player.sex]+' was too strong for you!',
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

   {check to see if there's a reward set for player2}
   reward_check(true,player,pl2);

   crlf;
   d(11,'Good work!');
  end;

  if player.hps<1 then begin
   d(config.textcolor,'With your last strength you try a blow aginst your foe,');
   d(config.textcolor,'but in vain! You have lost the fight!');
   if pl2.phr[2]<>'' then begin
    d(config.textcolor,'You hear '+uplc+pl2.name2+config.textcol1+' speak :');
    d(global_talkcol,pl2.phr[2]);
   end
   else begin
    sd(config.textcolor,'Just before you die, you hear ');
    sd(global_plycol,pl2.name2);
    d(config.textcolor,' laughing at your');
    d(config.textcolor,'pathetic attempt!');
   end;

   {check if there's a reward set for player}
   reward_check(false,pl2,player);

   {take equipment}
   swap_objects(pl2,player,true);

   {update stats}
   inc(player.p_defeats);
   inc(pl2.p_kills);

   {update "killedby" variable in relations data file}
   killed_by_stats(pl2,player);

   if player.gold>0 then begin
    sd(global_plycol,pl2.name2);
    d(config.textcolor,' took your '+config.moneytype+'!');
   end;

   xplose(player);

   player.hps:=0;
   reduce_player_resurrections(player,true);
   {player.allowed:=false;}

   case random(5) of
    0: s:='(buy some steroids and pump your muscles!)';
    1: s:='(better luck next time)';
    2: s:='(buy a better weapon next time)';
    3: s:='(oh no!)';
    4: s:='(loser!)';
   end; {case .end.}

   gold_string:='';
   gold_mem:=0;
   if player.gold>0 then begin
    gold_mem:=player.gold;
    gold_string:=uplc+pl2.name2+config.textcol1+' emptied your purse. You lost '+uyellow+commastr(gold_mem)+config.textcol1
                 +' '+many_money(gold_mem)+'!'
   end;

   s:='Your Death';
   {inform player}
   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   ulred+s+config.textcol1,
   mkstring(length(s),underscore),
   'You were slain by '+uplc+pl2.name2+config.textcol1+'!',
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

   s2:='';
   case random(8) of
    0:begin
       s:=uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+'!';
       s2:=' '+ulred+player.name2+config.textcol1+' lost both the fight and '+sex3[player.sex]+' head!';
      end;
    1:begin
       s:=uplc+player.name2+config.textcol1+' challenged '+uplc+pl2.name2+config.textcol1+' but was massacred!';
      end;
    2:begin
       s:=uplc+player.name2+config.textcol1+' assaulted '+uplc+pl2.name2+config.textcol1+' but died in the attempt!';
      end;
    3:begin
       s:=uplc+player.name2+config.textcol1+' attacked '+uplc+pl2.name2+config.textcol1+'! It was a mistake...';
      end;
    4:begin
       s:=uplc+player.name2+config.textcol1+' attacked '+uplc+pl2.name2+config.textcol1+'! ';
       s2:=' '+ulred+pl2.name2+config.textcol1+' was killed.';
      end;
    5:begin
       s:=uplc+player.name2+config.textcol1+' attacked '+uplc+pl2.name2+config.textcol1+' but was terminated.';
      end;
    6:begin
       s:=uplc+player.name2+config.textcol1+' assaulted '+uplc+pl2.name2+config.textcol1+' but was defeated!';
      end;
    7:begin
       s:=uplc+player.name2+config.textcol1+' jumped '+uplc+pl2.name2+config.textcol1+' but was mangled!';
      end;

   end; {case .end.}

   s:=' '+s;

   {news-paper}
   newsy(true,
   'Player Fight!',
   s,
   s2,
   '',
   '',
   '',
   '',
   '',
   '',
   '');

   x:=random(50)+250;
   x:=x*player.level;
   inc(pl2.exp,x);
   incplayermoney(pl2,player.gold);
   player.gold:=0;

   if pl2.autoheal=true then begin
    auto_healing(pl2);
   end;

   if pl2.ai='H' then begin
    s:='Self-Defence!';

    gold_string:='';
    if gold_mem>0 then begin
     gold_string:='You emptied '+uplc+player.name2+'s'+config.textcol1+' purse and found '+uyellow+commastr(gold_mem)
                  +config.textcol1+' '+many_money(gold_mem)+'!';
    end
    else begin
     gold_string:='You took '+uplc+player.name2+'s'+config.textcol1+' purse but it was empty!';
    end;

    {inform other player}
    post(MailSend,
     pl2.name2,
     pl2.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+s+config.textcol1,
     mkstring(length(s),underscore),
     'You killed '+uplc+player.name2+config.textcol1+' in self-defence! No big deal really.',
     'You received '+uwhite+commastr(x)+config.textcol1+' experience points for the kill.',
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
     '');

   end;

   {write pl2 to disk}
   user_save(pl2);

   crlf;
   show_usurper_data(picture_DEATH_HEAD,false);
   d(config.textcolor,'Darkness surround you....');
   crlf;
   pause;

   {remove playerinfight flag}
   global_PlayerInFight:=false;

   normal_exit;
  end;
  pause;
 end; {beg=false .end.}

 {remove playerinfight flag}
 global_PlayerInFight:=false;

end; {Player_vs_Player *end*}

end. {Unit PlvsPlC .end.}
