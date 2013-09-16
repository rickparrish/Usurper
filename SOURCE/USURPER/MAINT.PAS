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



Unit Maint; {Usurper - Maintenance, runs automatically every day}

Interface

Procedure Maintenance;

Implementation

Uses Crt, DDplus, Init, Cms,
     Jakob, NpcMaint, Wantedsc,
     Mail, News, Various,
     Various2, Various3, VarGods,
     Children, Relation, Online,
     File_Io;

Procedure Maintenance;
var
   pay,
   mem,
   save,
   truly,
   found,
   king_found,
   resurrect : boolean;

   inact,
   plfights : integer;

   s,
   s1: s90;

   y,
   rep,
   mem2,
   maxtime,
   tfights,
   interest,
   dngfights : integer;

   rr : real;

   i,
   j,
   x,
   xx,
   yy,
   townpot,
   townpotv,
   treasury_mem : longint;

   memy : byte;

   txt : text;

   pl0 : UserRec;
   aarmor : armrec;
   wweapon : weaprec;
   wanted : wantedrec;
   king : kingrec;
   guard : guardrec;

begin

 {display maint picture}
 clearscreen;
 show_usurper_data('MAINTENANCE',false);
 sgoto_xy(1,1);

 {start text}
 {crlf;
 sd(11,'Injections of Evil... ');
 d(global_mainttxt,' '+datefix(todays_date)+ured+'  ['+ulred+'Usurper Maintenance'+ured+']'+config.textcol1);
 }

 pack_mail;
 {load king}
 load_king(fload,king);

 {we must remember how much there was in the royal treasury}
 treasury_mem:=king.treasury;

 king_found:=false; {to prevent several kings floating around}
 ansion:=true;

 {set global flag, indicating maintenance running}
 global_maintrunning:=true;

 {no global multi node procs are allowed to be executed while maint is
  running}
 mem:=global_multi;
 global_multi:=false;

 {rewrite maint date file, keeps track of when to run maintenance}
 create_maint_flag; {various.pas}

 {fetching dungeon fights/day 6}
 s:=cfg_string(6);
 dngfights:=str_to_nr(s);
 if (dngfights<1) or (dngfights>99) then dngfights:=10;

 {fetching player fights 40}
 s:=cfg_string(40);
 plfights:=str_to_nr(s);
 if (plfights<1) or (plfights>99) then plfights:=3;

 {we fetch Bank Interest 41}
 s:=cfg_string(41);
 interest:=str_to_nr(s);
 if (interest<1) or (interest>15) then interest:=3;

 {we fetch player fights 89}
 s:=cfg_string(89);
 townpotv:=str_to_nr(s);
 if (townpotv<100) or (townpotv>500000000) then begin
  townpotv:=5000;
 end;

 {we fetch resurrection}
 s:=cfg_string(68);
 resurrect:=false;
 if upcasestr(s)='YES' then begin
  resurrect:=true;
 end;

 {we fetch MaxTime from .CFG}
 maxtime:=999;
 s:=cfg_string(87);
 x:=str_to_nr(s);
 if (x>0) and (x<10000) then maxtime:=x;

 {we fetch inactivity before deletion - from .cfg #7}
 s:=cfg_string(7);
 inact:=str_to_nr(s);
 if (inact<15) or (inact>999) then inact:=30;

 {we fetch teamfights/day - from #13}
 s:=cfg_string(13);
 tfights:=str_to_nr(s);
 if (tfights<1) or (tfights>99) then tfights:=2;

 {new bank safe value}
 Safe_Reset;

 {Reset Truth files}
 if f_exists(global_truthfile1) then Delete_File(global_truthfile1);
 if f_exists(global_truthfile2) then Delete_File(global_truthfile2);
  Check_TruthFile(true); {make empty truth file}
 {add some NPC comments to the Inn Chat file}
 if Config.AddNpcInnComments>0 then begin

  for i:=1 to fs(FsNpc) do begin

   load_character(pl0,2,i);

   case config.AddNpcInnComments of
    1: x:=random(15); {seldom}
    2: x:=random(10); {sometimes}
    3: x:=random(5); {often}
   end;

   if x=0 then begin

    {add some text to the inn chat file}
    s:=Get_NpcInnComment;

    if s<>'' then begin
     Write_To_Inn_File(pl0.name2,s,'','','','');
    end;

   end
   else if x=1 then begin
    {add some text to the truthfile}
     s:='';
    case random(27) of
     0: s:='Am I tired of gang banging!? No, way!';
     1: s:='I''m not full of lies anymore.';
     2: s:='Who stole my equipment!?';
     3: s:='Welcome to hell.';
     4: s:='You''re just a bunch of ignorant bastards!';
     5: s:='See me later at my place, ok?';
     6: s:='Confusion is my master.';
     7: s:='There''s no opposition in this game...too easy.';
     9: s:='Where is the Castle??';
     10: s:='Cry Baby!';
     11: s:='First in, first out!';
     12: s:='I saw Death yesterday evening!';
     13: s:='No, we are NOT americans! We are the NPCs';
     14: s:='My Master is not Apollonia!';
     15: s:='No, I did not do the old couple!';
     16: s:='I know who took out the town masters!';
     17: s:='Ha! You all have such pathetic names...';
     18: s:='Worthless worms.';
     19: s:='The steroids helped me to a better life (at least a stronger one)';
     20: s:='Ha ha ha!';
     21: s:='Puppets!';
     22: s:='I was robbed!!';
     23: s:='I am the greatest!';
     24: s:='Oh boy! Do I hate Slash or what!';
     25: s:='I hate Slashs guts!';
     26: s:='Blow your nose!';
     27: s:='Nananana...';
    end; {case .end.}

    if s<>'' then begin
     s:=' '+utalkc+s;
     Write_to_Truth_File(pl0.name2,s);
    end;

    if random(5)=0 then break;

   end;

  end; {for i:= .end.}
 end;

 {*Creating Yesterdays News File*}
 sd(global_mainttxt,'Updating News files ... ');

 if f_exists(global_ynwfileans) then delete_file(global_ynwfileans);
 if f_exists(global_ynwfileasc) then delete_file(global_ynwfileasc);

 if (f_exists(global_nwfileans)) and (global_ynwfileans<>'') then begin
  rename_file(global_nwfileans,global_ynwfileans);
 end;

 if (f_exists(global_nwfileasc)) and (global_ynwfileasc<>'') then begin
  rename_file(global_nwfileasc,global_ynwfileasc);
 end;

 d(11,'DONE');

 most_wanted('S');

 sd(global_mainttxt,'Awarding Town Masters ... ');
 {*how big should the pot for Town Control be*}
 x:=0;
 s:='';
 townpot:=0;

 for i:=1 to fs(FsPlayer) do begin
  load_character(player,1,i);
  if player.cturf=true then begin
   inc(townpot,(player.level*townpotv));
   inc(x);
   s:=player.team;
  end;
 end; {for :=i .end.}

 if s<>'' then begin
  for i:=1 to fs(FsNpc) do begin
   load_character(pl0,2,i);
   if pl0.team=s then begin
    inc(townpot,(pl0.level*townpotv));
    inc(x);
   end;
  end; {for i:= .end.}
 end;

 if x<=0 then begin
  x:=1;
 end;

 if townpot>2 then begin
  townpot:=townpot div x;
 end;
 d(11,'DONE');

 sd(global_mainttxt,'Cutting event-files down to size ... ');

 {pack indian wrestling file, the results are in this file}
 pack_txtfile(global_indianfile,5);

 {pack ANSI chatfile}
 pack_txtfile(global_innfile1,90);
 pack_txtfile(global_innfile2,90);
 d(11,'DONE');

 {* UPDATE PLAYER RECORDS *}
 ansion:=true;
 xx:=fs(FsPlayer);
 mem2:=xx;

 {BIG-LOOP}
 memy:=wherey;
 for i:=1 to fs(FsPlayer) do begin

  xx:=mem2;
  rr:=i;
  if xx>0 then begin
   rr:=rr / xx;
   xx:=round(rr*100);
  end
  else begin
   xx:=0;
  end;

  sgoto_xy(1,memy);
  sd(global_mainttxt,'Browsing characters ('+commastr(xx)+'%)');

  load_character(player,1,i);

  {Player receives bonus for Staying alive}
  if (player.hps>0) and (player.alive_bonus<1500000000) and
     (player.allowed=true) then begin
   yy:=player.level*350;
   inc(player.alive_bonus,yy);
  end;

  {pay-check for Royal Guard Duty?}
  Pay_Royal_Guard(player,king);

  {bard songs}
  if player.class=bard then begin
   player.bard_songs_left:=config.bardsongs;
  end;

  {prison escape attempts}
  player.prison_escapes:=config.prison_escapes;

  {pick-pocket attempts}
  player.pickpocketattempts:=config.pickpocketattempts;

  {bank robbery attempts}
  player.BankRobberyAttempts:=config.BankRobberyAttempts;

  {resurrect dead player, if config allows us}
  if (resurrect) and (player.hps<1) then begin
   player.hps:=player.maxhps;
   player.allowed:=true;
   player.resurrections:=config.resurrections;
  end;

  {set auto_hate}
  if (player.ai='C') and (player.AutoHate<>1) then begin
   player.AutoHate:=1;
  end;

  {resetting all kinds of "daily" parameters}
  player.UmanBearTries:=0;
  player.massage:=0;
  player.gym_sessions:=config.gymsessions;
  player.wellwish:=false;
  player.allowed:=true;
  player.resurrections:=config.resurrections;
  player.fights:=dngfights;
  player.darknr:=6;
  player.chivnr:=6;
  player.pfights:=plfights;
  player.tfights:=tfights;
  player.thiefs:=3;
  player.brawls:=3;
  player.assa:=3;
  player.drinksleft:=Config.DrinksatOrbs; {drinks / day at Orbs}
  player.intimacyActs:=Config.IntimacyActs;
  player.wrestlings:=Config.MaxWrestlings; {when you change this value, check with UMAN.PAS
                         and the WWTRIES constant, they should match}

  if player.class=Assassin then begin
   inc(player.thiefs,2);
  end;

  {the King?}
  if (player.king) and (king_found) then begin
   player.king:=false;
  end
  else if (player.king) and
          (player_active(player,false)=true) and
          (king_found=false) then begin

   king_found:=true;

   s1:=KingString(player.sex);

   x:=king.daysinpower+1;
   s:='day';
   if x>1 then s:=s+'s';

   {news-paper}
   newsy(true,'The '+s1,
    ' Long live '+s1+ukingc+' '+player.name2+config.textcol1+'! Hooray, Hooray, Hooray!',
    ' '+ukingc+player.name2+config.textcol1+' has ruled the land for '+uwhite+commastr(x)+config.textcol1+' '+s+'.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');
  end;


  {If it is a Computer Controlled character then delete his newsfiles}
  {and revive him/her}
  if player.ai='C' then begin

   {remove diseases}
   player.blind:=false;
   player.plague:=false;
   player.smallpox:=false;
   player.measles:=false;
   player.leprosy:=false;

   player.gold:=0;
   player.bankgold:=0;

   if config.classic then begin
    if player.weapon=0 then begin
     x:=player.level+random(5)+3;
     if x>100 then begin
      x:=90;
     end;

     load_weapon(x,wweapon);
     player.weapon:=x;
     player.wpow:=wweapon.pow;
    end;

    if player.armor=0 then begin
     x:=player.level+random(5)+3;
     if x>100 then x:=90;

     load_armor(x,aarmor);
     player.armor:=x;
     player.apow:=aarmor.pow;
    end;
   end;

   if player.gold>1000000000 then player.gold:=1000000000;
   if player.bankgold>1000000000 then player.bankgold:=1000000000;

   if random(3)=0 then begin
    if player.exp<2000000000 then begin
     player.exp:=player.exp+random(25000);
    end;
   end;
   player.hps:=player.maxhps;
   player.gnollp:=0;
   player.healing:=config.maxheals;

   {buy items to computer player}
   {this is done in NPCmaint.pas}

   {level raise?}
   raise_player(player,true,false,false,true,'');

   {put computer at the Inn?}
   if (player.location=offloc_dormitory) and (random(5)=0) then begin

    {set floor}
    case random(4) of
     0: player.location:=offloc_innroom1;
     1: player.location:=offloc_innroom2;
     2: player.location:=offloc_innroom3;
     3: player.location:=offloc_innroom4;
    end;

    {get doorguards?}
    if random(2)=0 then begin

     {get doorguards}
     x:=fs(FsGuard);
     if x>0 then begin
      x:=random(x)+1;

      player.bguard:=x;
      {have to check if you are allowed to rent more than one
       see config.file}
      load_guard(Fload,guard,x);
      if guard.multiple then player.bguardnr:=random(10)+1
                        else player.bguardnr:=1;
     end;
    end;

   end; {put computer controlled character at the Inn}

  end;

  {Player gets money for Town Control}
  if player.cturf=true then begin

   {mail money}
   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Team Income'+config.textcol1,
   mkstring(11,underscore),
   'You received '+uyellow+commastr(townpot)+config.textcol1+' '+many_money(townpot)+' for controlling the Town',
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

   {give money}
   incplayermoney(player,townpot);
   inc(player.teamrec);

  end;

  {has player begged during night, and survived?}
  if (player.location=offloc_beggarwall) and (player.hps>0) then begin

   {get money}
   incbankmoney(player,1000);

   {mail}
   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+'Begging'+config.textcol1,
   mkstring(7,underscore),
   'You received '+uyellow+'1,000'+config.textcol1+' '+many_money(1000)+' when you sat begging.',
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
  end;

  {a clumsy way to set back player.haunts, demons}
  if player.haunt>30000 then player.haunt:=30000;

  {reset mana}
  player.mana:=player.maxmana;

  {give player time}
  player.maxtime:=maxtime;

  {give player haggle turns}
  player.weaphag:=3;
  player.armhag:=4;
  if player.class=Jester then begin
   inc(player.weaphag);
   inc(player.armhag);
  end;

  {bank interest}
  if (player.bankgold>100) and (player.interest<1000000000) and
     (player.bankgold<1500000000) then begin
   {rr:=1.02;}
   rr:=interest;
   rr:=rr / 100;
   rr:=1.00+rr;
   rr:=(player.bankgold*rr);

   x:=round(rr);

   IncInterest(player,(x-player.bankgold));

  end;

  {baby production}
  if (player.sex=2) and (player.pregnancy>0) then begin
   inc(player.pregnancy);
   give_birth(player);
  end;

  {reset questsaccomplished today}
  player.RoyQuestsToday:=0;

  {how many days since voted for king popularity}
  if player.KingVotePoll<200 then begin
   inc(player.KingVotePoll);
  end;

  {birthday?}
  if player.ageplus<32000 then begin
   inc(player.ageplus);
  end;

  {is it birthday?}
  if (player_active(player,false)=true) and
     (player.ageplus>20) and
     (player.age<200) and
     (random(4)=0) then begin

   {player gets older!}
   inc(player.age);
   player.ageplus:=0;

   if player.hps<1 then begin
    s:=' Unfortunately, '+uplc+player.name2+config.textcol1+' isn''t feeling to well.'
   end
   else begin
    case random(6) of
     0: s:=' We all wish '+sex[player.sex]+' a good and long life.';
     1: s:=' Signs in the sky tell us that '+uplc+player.name2+config.textcol1+' is destined to do good.';
     2: s:=' '+uplc+player.name2+config.textcol1+' celebrated with '+sex3[player.sex]+' family.';
     3: s:=' People say that '+uplc+player.name2+config.textcol1+' has a pact with the Devil!';
     4: s:=' People say that '+uplc+player.name2+config.textcol1+' should be driven out of Town.';
     5: s:=' The wise men think '+uplc+player.name2+config.textcol1+' should be more cautious.';
    end; {case .end.}
   end;

   {mail the birthday object}
   if player.ai='H' then begin
    post(MailSend,
    player.name2,
    player.ai,
    false,
    mailrequest_birthday,
    commastr(player.age), {1.line carries the age player has reached}
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
    '',
    '',
    '',
    '');
   end;

   {put the birthday celebration in the news-paper}
   case random(2) of
    0:begin
       newsy(true,'Birthday',
       ' '+uplc+player.name2+config.textcol1+' has come to be '+uwhite+commastr(player.age)+config.textcol1+' years old.',
       s,
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
    1:begin
       newsy(true,'Birthday',
       ' '+uplc+player.name2+config.textcol1+' celebrated '+sex3[player.sex]+' '+uwhite+commastr(player.age)
          +config.textcol1+' birthday.',
       s,
       '',
       '',
       '',
       '',
       '',
       '',
       '');
      end;
   end; {case .end.}

  end; {birthday *END*}


  {** Should player get salary from the bank (guard duty) ? **}
  if (player.bankguard=true) and (player.bankwage<1500000000) and
     (player.hps>0) then begin
   yy:=player.level*1500;
   yy:=yy+(player.strength*9);
   incbankwage(player,yy);
  end;

  {allowed to enter game}
  player.allowed:=true;
  player.resurrections:=config.resurrections;



  {pay Royal tax?}
  if (player.king=false) and
     (king.tax>0) and
     (player.ai='H') and
     (player_active(player,false)=true) and
     (player.tax_relief=false) and
     (king.name<>'') then begin

   pay:=true;
   if (king.taxalignment=1) and (player.chiv<player.dark) then pay:=false;
   if (king.taxalignment=2) and (player.dark<player.chiv) then pay:=false;

   if (pay) and (player.bankgold>100) then begin
    {amount to pay}

    rr:=king.tax;
    rr:=rr / 100;
    {rr:=1.00+rr;}
    rr:=(player.bankgold*rr);

    yy:=round(rr);

    if king.treasury<2000000000 then begin

     if IncKingTreasury2(king,yy)=false then begin
      {royal purse would overflow}
     end
     else begin
      DecBankMoney(player,yy);

      if player.bankgold<0 then player.bankgold:=0;

      {store accumulated}
      if player.RoyTaxPaied<2000000000 then begin
       player.roytaxpaied:=player.roytaxpaied+yy;
      end;
     end;

    end;



   end;

  end;

  {Should player be released from prison?}
  if player.location=offloc_prison then begin

   if player.daysinprison<1 then begin
    player.location:=offloc_dormitory;

    {news-paper}
    newsy(true,'Prisoner Released',
    ' '+uplc+player.name2+config.textcol1+' was released from prison.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');
   end
   else begin
    {player stays in prison}
    dec(player.daysinprison);
   end;

  end;

  {** Should the player receive money for his poverty? **}
  if (player.gold=0) and (player.bankgold=0) then begin

   yy:=random(500)+random(100)+50;

   IncBankMoney(player,yy);

   s:='Gift from Town Council';

   {mail}
   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s+config.textcol1,
   mkstring(length(s),underscore),
   'You received '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+' to help you in your poverty',
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
  end;

  {**Should player receive money for goodness? **}
  if (player.chiv>700) and (player.dark<50) and (player.king=false) then begin
   yy:=random(3000)+random(3000)+1;
   incbankmoney(player,yy);

   s:='Gift from the King';

   post(MailSend,
   player.name2,
   player.ai,
   false,
   mailrequest_nothing,
   '',
   umailheadc+s+config.textcol1,
   mkstring(length(s),underscore),
   'You received '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+' for your good character.',
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
  end;

  {delete playe for inactivity?}
  if (player_active(player,false)=true) and
     (player.ai='H') and
     (player.immortal=false) then begin

   {when was player last on-line?}
   x:=packed_date-player.laston;

   if x>inact then begin

    {news-paper}
    newsy(true,'Player Deleted!',
    ' '+uplc+player.name2+config.textcol1+' was deleted because of inactivity.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

    deactivate_player(player); {remove certain flags}
    player.deleted:=true;
   end;
  end;

  {save user}
  user_save(player);

 end; {BIG-LOOP *end*}

 sd(global_mainttxt,' ... ');
 d(11,'DONE');

 {*which gang controls the town?*}
 x:=0;
 for i:=1 to fs(FsPlayer) do begin
  load_character(player,1,i);

  if player.teamrec>1 then s:='days'
                      else s:='day';

  if player.cturf=true then begin
   x:=1;
   newsy(true,'Gang Influence',
   utec+' '+player.team+config.textcol1+' control the Town.',
   ' They have done so for '+uwhite+commastr(player.teamrec)+config.textcol1+' '+s+' now.',
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

 if x=0 then begin

  for i:=1 to fs(FsNPC) do begin

   {load character}
   load_character(player,2,i);

   if player.cturf=true then begin
    x:=1;
    newsy(true,'Gang Power',
    utec+' '+player.team+config.textcol1+' control the Town.',
    ' They have done so for '+uwhite+commastr(player.teamrec)+config.textcol1+' days now.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');
    break;
   end;

  end; {for i:= .end.}

 end;

 if x=0 then begin
  newsy(true,'Free Town!',
  ' Our loved Town is free from gang control! May it last.',
  '',
  '',
  '',
  '',
  '',
  '',
  '',
  '');
 end;

 {Update the Bounty file, players on the Wanted lists may have disappeared
  from the game}
 if f_exists(global_wwfile) then begin

  sd(global_mainttxt,'Updating Bounties ... ');

  for i:=1 to fs(FsWanted) do begin
   load_wanted(Fload,wanted,i);
   if (wanted.name<>'') and (wanted.collected=false) then begin

    {lets see if wanted.name exists}
    x:=look_for_alias(wanted.name,wanted.ai2);

    if x=0 then begin
     {killing this wanted person from the wanted list}
     wanted.collected:=true;
     load_wanted(Fsave,wanted,i);

    end;

   end;
  end; {for i:= .end.}
  d(11,'DONE');
 end;

 {update king record}

 {new prison sentences}
 king.PrisonsLeft:=4;
 king.ExecuteLeft:=3;
 king.QuestsLeft:=Config.MaxNewQuestsPerDay; {max # of new quests the KING can issue/day}
 king.MarryActions:=Config.MarryActionsPerDay; {max # of marriages the King can interfer every day}
 king.WolfFeed:=config.allowfeedingthewolves; {how many kids can be tossed to the wolves every day}
 king.RoyalAdoptions:=config.allowroyaladoption; {how many kids can be placed in the Royal Orphanage every day}

 {new days in power}
 inc(king.daysinpower);

 {save king}
 load_king(fsave,king);
 {update king record .end.}

 {Update the Kings Royal Guard, players on the Guard may have disappeared
  from the game}
 sd(global_mainttxt,'Inspecting Royal Guard ... ');
 if f_exists(global_kingf) then begin

  load_king(fload,king);

  for i:=1 to global_kingGuards do begin
   if king.guard[i]<>'' then begin

    {lets see if guard[i] exists}
    x:=look_for_alias(king.guard[i],king.guardai[i]);

    if x=0 then begin
     {not found! remove him now!}
     king.guard[i]:=emptystr;

     {d(15,'Royal Guard removed!');}
    end;

   end;
  end; {for i:= .end.}
 end;
 d(11,'DONE');


 {Update the QUESTS, they may fail here if players haven't finished
  their missions in time}
 sd(global_mainttxt,'Browsing Quests ... ');
 if f_exists(global_rquestf) then begin
  quest_maintenance;
 end;
 d(11,'DONE');

 {Update the DRINK file, delete old drinks}
 sd(global_mainttxt,'Browsing Drinks ... ');
 if f_exists(global_drinkfile) then begin
  drink_maintenance;
 end;
 d(11,'DONE');

 {Update the config.textcol1 file}
 sd(global_mainttxt,'Browsing Relations ... ');

 relation_maintenance;
 d(11,'DONE');

 {Update the CHILDREN file}
 sd(global_mainttxt,'Browsing Children ... ');
 children_maintenance;
 d(11,'DONE');

 {The last stuff to do}
 i:=1;
 load_character(player,1,i);

 user_save(player);

 player.name1:=emptystr;
 player.name2:=emptystr;


 {The Gods}
 god_maintenance;


 {The Npcs}
 npc_maint(king_found);

 {remove ONLINERS.DAT file}
 if f_exists(global_onfile) then begin
  i:=1;
  repeat
   delete_file(global_onfile);
   inc(i);
   delay2(300);
  until (f_exists(global_onfile)=false) or (i>150);
 end;

 load_king(fload,king);
 {send mail to the king about tax incomes}

 if (king.treasury>treasury_mem) and (king.ai='H') then begin
  yy:=king.treasury-treasury_mem;

  {mail}
  post(MailSend,
  king.name,
  king.ai,
  false,
  mailrequest_nothing,
  '',
  umailheadc+'Royal Income'+config.textcol1,
  mkstring(12,underscore),
  'The people payed their taxes. The '+ulgray+'Royal Treasury'+config.textcol1+' can report',
  'an addition of '+uyellow+commastr(yy)+config.textcol1+' '+many_money(yy)+'.',
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

 {remove MAINT.FLG flag}
 i:=1;
 repeat
  delete_file(global_maintfile);
  inc(i);
  delay2(50);
 until (f_exists(global_maintfile)=false) or (i>150);

 sd(2,'þ');
 d(12,' All Deeds are done!');

 {set global vars indicating maintenance is done}
 global_multi:=mem;
 global_maintrunning:=false;
 ansion:=false;

end; {Maintenance *end*}

end. {Unit Maint .end.}
