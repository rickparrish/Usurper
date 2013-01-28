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

Unit NPC; {Usurper NPC characters, used by Editor to create all Npcs}

Interface

Procedure Reset_Npcs;

Implementation

Uses Init, Jakobe, File_IO;

type
  Gender = (Male, Female);

var
    i , j  : integer;
    x : longint;

Function Scream : s70;
var s :s70;
begin
 {creates a random battle cry}
 s:='';
 case random(15) of
  0: s:='On your knees cowboy!';
  1: s:='Show me your stuff!';
  2: s:='Are you kidding me!';
  3: s:='Hehe!';
  4: s:='Hoho! Here I come!';
  5: s:='Bastard!';
  6: s:='Here I come!';
  7: s:='You will regret this!';
  8: s:='Hello there!';
  9: s:='I''m the only one!';
 10: s:='What''s up?';
 11: s:='Are you potty-trained?';
 12: s:='Hello stinker!';
 13: s:='Run home to mama!';
 14: s:='You are ugly!';
 end;

 scream:=s;

end;

Procedure Add_Npc( const name : s70;   {name of NPC}
                   race    : races;    {race}
                   maxhps  : integer;  {maxhps}
                   strength: integer;  {strength}
                   defin   : integer;  {defence}
                   loyin   : integer;  {loyalty}
                   class   : classes;  {class}
                   agein   : integer;  {age}
                   const teamin  : s70;      {team}
                   sex     : gender;   {gender}
                   exp     : longint;  {experience}
                   const cry     : s70;      {battle cry}
                   addict  : integer;  {drug addiction}
                   mental  : integer;  {mental stability}
                   darkness: longint;  {darkness}
                   chivalry: longint); {chivalry}

begin

 if add_fake then begin
  inc(counter);
  exit;
 end;

 {*** Character definition ***START***}

 player0.Name1   :='NPC';
 player0.name2   :=name;
 player0.ai      :='C';
 player0.race    :=race;
 player0.age     :=agein;
 player0.gold    :=random(30000);
 player0.maxhps  :=maxhps;
 player0.hps     :=maxhps;
 player0.exp     :=exp;
 player0.level   :=1; {setting correct value later on}
 player0.bankgold:=0;
 player0.chiv    :=chivalry;
 player0.dark    :=darkness;
 player0.fights  :=3;
 player0.strength:=strength;
 player0.defence :=defin;
 player0.healing :=150; {healing potions}
 player0.allowed  :=true;
 player0.laston  :=packed_date;
 player0.ageplus :=0;
 player0.darknr  :=3;
 player0.chivnr  :=3;
 player0.pfights :=3;
 player0.king    :=false;
 player0.loc     :=1;
 player0.team    :=teamin;
 player0.teampw  :=emptystr;
 player0.bguard  :=0;
 player0.cturf   :=false;
 player0.gnollp  :=0;
 player0.mental  :=mental;
 player0.addict  :=addict;
 player0.wellwish:=false;
 player0.height  :=0;
 player0.weight  :=0;
 player0.eyes    :=0;
 player0.hair    :=0;
 player0.skin    :=0;

 case sex of
  Male  : player0.sex:=1;
  Female: player0.sex:=2;
 end;

 player0.mana       :=0;
 player0.maxmana    :=0;
 player0.stamina    :=0;
 player0.agility    :=0;
 player0.charisma   :=0;
 player0.dex        :=0;
 player0.wisdom     :=0;
 player0.weap       :=0;
 player0.arm        :=0;
 player0.poison     :=0;
 player0.m_kills    :=random(45);
 player0.m_defeats  :=random(15);
 player0.p_kills    :=random(3);
 player0.p_defeats  :=random(5);
 player0.interest   :=0;
 player0.alive_bonus:=0;
 player0.teamrec    :=0;
 player0.autoheal   :=true;
 player0.class      :=class;
 player0.loyalty    :=loyin;
 player0.haunt      :=0;
 player0.trains     :=2;

 player0.blind    :=false;
 player0.plague   :=false;
 player0.smallpox :=false;
 player0.measles  :=false;
 player0.leprosy  :=false;

 player0.mercy    :=0;
 player0.tfights  :=3;
 player0.thiefs   :=3;
 player0.brawls   :=2;
 player0.assa     :=3;
 player0.immortal :=true;
 player0.battlecry:=cry;
 player0.bguardnr :=0;
 player0.casted   :=false;
 player0.punch    :=0;
 player0.maxtime  :=0;
 player0.ear      :=1;
 player0.castin   :=' ';
 player0.weapon   :=0;
 player0.armor    :=0;
 player0.wpow     :=0;
 player0.apow     :=0;
 player0.disres   :=0;
 player0.amember  :=false;
 player.bankguard :=false;
 player.bankwage  :=0;
 player.weaphag   :=3;
 player.armhag    :=3;
 player.recnr     :=0;
 player.auto_meny :=false;
 player.quests    :=random(5);
 player.god       :=emptystr;
 player.royquests :=0;
 player.roytaxpaied:=0;
 player.wrestlings:=0;
 player.drinksleft:=3;
 player.daysInPrison:=0; {days left in prison}

 player.deleted   :=false;

 player0.desc[1] :=emptystr;
 player0.desc[2] :=emptystr;
 player0.desc[3] :=emptystr;
 player0.desc[4] :=emptystr;


 {inventory}
 for i:=1 to maxitem do begin
  player0.item[i]:=0;
 end;

 {phrases}
 for i:=1 to 6 do begin
  player0.phr[i]:=emptystr;
 end;

 player0.master:='1';
 case random(10) of
  0: player0.master:='0';
  1: player0.master:='1';
  2: player0.master:='2';
  3: player0.master:='3';
  4: player0.master:='4';
  5: player0.master:='5';
  6: player0.master:='6';
  7: player0.master:='7';
  8: player0.master:='8';
  9: player0.master:='9';
 end;

 for i:=1 to maxspells do begin
  for j:=1 to 2 do begin
   player0.spell[i,j]:=false;
  end;
 end; {for i:= .end.}

 for i:=1 to 14 do begin
  player0.skill[i]:=random(7)+1;
 end; {for i:= .end.}

 for i:=1 to 20 do begin
  player0.medal[i]:=false;
 end; {for i:= .end.}

 {dress up}
 player0.rhand  :=0;
 player0.lhand  :=0;
 player0.head   :=0;
 player0.body   :=0;
 player0.arms   :=0;
 player0.lfinger:=0;
 player0.rfinger:=0;
 player0.legs   :=0;
 player0.feet   :=0;
 player0.waist  :=0;
 player0.neck   :=0;
 player0.neck2  :=0;
 player0.face   :=0;
 player0.shield :=0;
 player0.hands  :=0;
 player0.abody  :=0;

 {new for 0.18}
 player0.UmanBearTries:=0; {times player have tried to tame the bear}
 player0.Massage:=0; {times player have had massage this day}
 player0.Gym_Sessions:=5; {workout sessions at the Gym / day}
 player0.Gym_Owner:=0; {controller of the gym? has to be in a team}
 player0.gym_card:=0; {free member card, if not gym_owning team}
 player0.RoyQuestsToday:=0; {how many royal quests have the player completed today}
 player0.KingVotePoll:=200; {how many days since voted for king popularity}
 player0.KingLastVote:=0; {how did player vote last time}
 player0.married     :=false; {is player married, only used in score writing/display}
 player0.Kids        :=0; {how many kids this playeer is father/mother to}
 player0.IntimacyActs:=5; {how many acts of intimacy has player left today?}
 player0.Pregnancy   :=0; {is player pregnant? 0=no, 1...X = days pregnant}
 player0.FatherId    :=''; {fathers id tag, set when pregnancy starts}

 player0.id:=crypt(15); {important!}
 player0.autohate:=1; {auto-worsen relation with attacking player?}
 player0.Tax_Relief:=false; {free from tax?}
 player0.MarriedTimes:=0; {counter for marriages}
 player0.Bard_Songs_Left:=0; {ehhh..quite self-explanatory huh?}
 player0.prison_escapes:=2; {allowed prison escape attempts}
 player0.Filtyp:=2; {type of file player resides in (1=player file, 2=npc file)}
 player0.resurrections:=3; {self explanatory}

 {below is new for 0.20}
 player0.PickPocketAttempts:=5; {allowed pick pocket attempts}
 player0.BankRobberyAttempts:=3; {allowed Bank Robbery attempts}


 {*** Character definition ***END***}

 {$I-}write(playerfile,player0);{$I+}
 if IOResult<>0 then unable_to_write(global_npfile);

 inc(counter);   {statbaren m†ste ha exakt antal poster..}
 Statbar(Counter,totobj,global_masterx,global_mastery,1,1);

end;

Procedure Reset_Npcs;
begin

 if not add_fake then begin
  totobj:=totobj*2;
  assign(playerfile,global_npfile);
  {$I-}rewrite(playerfile);{$I+}
  if IOResult<>0 then unable_to_create(global_npfile);
 end;

 {*** START of Npc LIST ***}


 Add_Npc('Pogo',   {name}
         Troll,    {race}
         50,       {maxhps}
         19,       {strength}
         19,       {defence}
         10,       {loyalty}
         Warrior,  {class}
         24,       {age}
         emptystr, {team}
         Male,     {Gender}
         9560,     {experience}
         scream,   {battle cry}
         0,        {drug addiction}
         100,      {mental stability}
         7590,     {darkness}
         0);       {chivalry}

 Add_Npc('Guillame',
         Gnome,
         40,
         13,
         13,
         15,
         Ranger,
         15,
         emptystr,
         Male,
         11340,
         scream,
         0,
         100,
         550,
         10);

 Add_Npc('Racine',
         Gnoll,
         30,
         12,
         12,
         40,
         Bard,
         21,
         emptystr,
         Male,
         5490,
         scream,
         0,
         100,
         1050,
         0);

 Add_Npc('Camal',Mutant,45,16,16,25,Jester,16,emptystr,Male
 ,12410,scream,0,100,3410,180);

 Add_Npc('Mysghnak',Orc,25,10,10,60,Warrior,34,emptystr,Male
 ,7800,scream,0,100,670,980);

 Add_Npc('Roland',Human,50,18,18,90,Paladin,28,emptystr,Male
 ,13410,scream,0,100,0,7830);

 Add_Npc('Alawin',Elf,37,20,20,95,Assassin,35,emptystr,Male
 ,3980,scream,0,100,0,12900);

 Add_Npc('Pertinax',HalfElf,50,20,20,80,Warrior,40,emptystr,Male
 ,15700,scream,0,100,250,2150);

 Add_Npc('Gwindli',Dwarf,40,16,16,98,Warrior,56,emptystr,Male
 ,7108,scream,0,100,10,2902);

 Add_Npc('Selwyn',Troll,29,15,15,75,Sage,17,emptystr,Male
 ,10820,scream,0,100,780,1210);

 Add_Npc('Raphael',Human,55,25,25,90,Paladin,22,emptystr,Male
 ,21090,scream,0,100,340,1190);

 Add_Npc('Tilt',Hobbit,90,45,45,85,Assassin,19,emptystr,Male
 ,66090,scream,0,100,550,120);

 Add_Npc('Grim',Dwarf,85,40,40,80,Warrior,16,emptystr,Male
 ,57800,scream,0,100,0,7500);

 Add_Npc('Melissa',Gnome,29,15,15,15,Ranger,23,emptystr,FeMale
 ,17450,scream,0,100,0,25);

 Add_Npc('Gawain',Human,75,38,38,99,Paladin,24,emptystr,Male
 ,26304,scream,0,100,0,24700);

 Add_Npc('Hiquet',Gnoll,17,7,7,5,Cleric,50,emptystr,Male
 ,4900,scream,0,100,10,0);

 Add_Npc('Psychopompos',Troll,38,22,22,30,Barbarian,34,emptystr,Male
 ,10505,scream,0,100,14700,0);

 Add_Npc('Fukoro',Human,25,9,9,45,Alchemist,18,emptystr,Male
 ,6420,scream,0,100,5310,0);

 Add_Npc('Edgar',Human,40,25,25,85,Ranger,30,emptystr,Male
 ,15790,scream,0,100,390,4120);

 Add_Npc('Dumuzi',Dwarf,60,30,30,94,Warrior,45,emptystr,Male
 ,28300,scream,0,100,190,1630);

 Add_Npc('Chuck',HalfElf,100,72,72,65,Jester,55,emptystr,Male
 ,124804,scream,0,100,1810,17500);

 Add_Npc('Cindy',HalfElf,18,5,5,70,Ranger,32,emptystr,Male
 ,3590,scream,0,100,110,0);

 Add_Npc('Gambrinus',Gnoll,33,10,10,55,Paladin,19,emptystr,Male
 ,12509,scream,0,100,0,290);

 Add_Npc('Attila',Troll,75,39,39,35,Barbarian,43,emptystr,Male
 ,80400,scream,0,100,990,34);

 Add_Npc('Typhoon',HalfElf,99,75,75,30,Warrior,29,emptystr,Male
 ,115700,scream,0,100,9808,0);

 Add_Npc('Voluptas',Elf,88,60,60,25,Cleric,28,emptystr,Male
 ,98450,scream,0,100,560,2180);

 Add_Npc('Kate',Mutant,12,5,5,98,Assassin,39,emptystr,FeMale
 ,2581,scream,0,100,0,760);

 Add_Npc('Raijin',Mutant,30,11,11,86,Ranger,18,emptystr,Male
 ,20110,scream,0,100,0,1290);

 Add_Npc('Lola',Mutant,50,19,19,40,Assassin,20,emptystr,FeMale
 ,35180,scream,0,100,210,0);

 Add_Npc('Philibert',Human,60,23,23,90,Paladin,30,emptystr,Male
 ,41720,scream,0,100,0,6800);

 Add_Npc('Lord Mino',Human,34,12,12,10,Warrior,18,emptystr,Male
 ,13710,scream,0,100,440,0);

 Add_Npc('Tina',HalfElf,10,4,4,88,Cleric,24,emptystr,FeMale
 ,4190,scream,0,100,0,30);

 Add_Npc('Falstaff',Mutant,135,15,15,70,Barbarian,26,emptystr,Male
 ,23600,scream,0,100,2580,12500);

 Add_Npc('Leonard',Human,45,20,20,55,Paladin,32,emptystr,Male
 ,37880,scream,0,100,1150,0);

 Add_Npc('Beth',Gnoll,26,11,11,22,Magician,42,emptystr,FeMale
 ,9140,scream,0,100,0,9560);

 Add_Npc('Thor',Human,105,46,46,60,Barbarian,19,emptystr,Male
 ,145249,scream,0,100,120,25800);

 Add_Npc('Sarah',Gnome,19,9,9,45,Sage,23,emptystr,FeMale
 ,17120,scream,0,100,970,0);

 Add_Npc('Boissay',Human,67,25,25,92,Paladin,46,emptystr,Male
 ,35190,scream,0,100,0,5412);

 Add_Npc('Gloria',Human,50,17,17,15,Sage,37,emptystr,FeMale
 ,40910,scream,0,100,712,0);

 Add_Npc('Boucher',Human,22,10,10,22,Barbarian,34,emptystr,Male
 ,9490,scream,0,100,0,120);

 Add_Npc('Gumprecht',Orc,89,35,35,38,Cleric,22,emptystr,Male
 ,113619,scream,0,100,3210,5670);

 Add_Npc('Griskhina',Orc,39,17,17,46,Ranger,25,emptystr,FeMale
 ,40650,scream,0,100,540,980);

 Add_Npc('Zoaglio',Orc,20,8,8,28,Cleric,41,emptystr,Male
 ,6950,scream,0,100,0,0);

 Add_Npc('Tuula',Gnome,25,12,12,74,Assassin,35,emptystr,FeMale
 ,8300,scream,0,100,5600,0);

 Add_Npc('Ruprecht',Troll,35,16,16,62,Alchemist,19,emptystr,Male
 ,18230,scream,0,100,3200,0);

 Add_Npc('Bedford',HalfElf,85,36,36,88,Sage,33,emptystr,Male
 ,132790,scream,0,100,905,1290);

 Add_Npc('Marlurnia',Troll,110,45,45,98,Ranger,18,emptystr,FeMale
 ,169400,scream,0,100,0,801);

 Add_Npc('Luttrell',Human,90,39,39,92,Bard,26,emptystr,Male
 ,142880,scream,0,100,0,1010);

 Add_Npc('Ophelia',Human,45,21,21,96,Paladin,60,emptystr,FeMale
 ,93700,scream,0,100,1260,4312);

 Add_Npc('Reynold',Human,17,7,7,5,Paladin,23,emptystr,Male
 ,6120,scream,0,100,350,10);

 Add_Npc('Marion',Orc,125,45,45,85,Warrior,32,emptystr,FeMale
 ,73619,scream,0,100,24900,0);

 Add_Npc('Caractacus',Troll,153,67,67,76,Barbarian,38,emptystr,Male
 ,90650,scream,0,100,1490,750);

 Add_Npc('Elin',Elf,70,28,28,78,Ranger,69,emptystr,FeMale
 ,135500,scream,0,100,11800,0);

 Add_Npc('Fubar',Mutant,130,72,72,14,Barbarian,15,emptystr,Male
 ,88301,scream,0,100,32800,0);

 Add_Npc('Helen',Elf,59,22,22,22,Bard,25,emptystr,FeMale
 ,28230,scream,0,100,560,0);

 Add_Npc('Rose',Elf,85,36,36,38,Sage,33,emptystr,FeMale
 ,32790,scream,0,100,730,950);

 Add_Npc('Lina',Human,49,20,20,28,Cleric,38,emptystr,FeMale
 ,16908,scream,0,100,0,240);

 Add_Npc('Tingeling',Elf,49,20,20,28,Warrior,27,emptystr,FeMale
 ,16908,scream,0,100,0,240);

 Add_Npc('Azrael',Dwarf,129,59,59,92,Barbarian,32,emptystr,Male
 ,152880,scream,0,100,2001,5710);

 Add_Npc('Damien',Human,145,71,71,96,Paladin,35,emptystr,Male
 ,193700,scream,0,100,0,45600);

 Add_Npc('Egil',Dwarf,117,67,67,95,Warrior,27,emptystr,Male
 ,67120,scream,0,100,0,3290);

 Add_Npc('Jasper',Human,235,101,101,55,Barbarian,40,emptystr,Male
 ,470009,scream,0,100,450,2140);

 Add_Npc('Yum Kax',Orc,353,167,167,26,Magician,32,emptystr,Male
 ,590900,scream,0,100,0,19601);

 Add_Npc('Abed Nego',Gnome,170,88,38,18,Cleric,58,emptystr,Male
 ,635500,scream,0,100,34800,0);

 Add_Npc('Changis Cham',Dwarf,430,172,172,71,Warrior,38,emptystr,Male
 ,905000,scream,0,100,15800,13800);

 Add_Npc('Erkenbrand',Human,590,220,220,22,Barbarian,29,emptystr,Male
 ,1290000,scream,0,100,0,44100);

 Add_Npc('Grismal',Troll,605,360,360,8,Warrior,21,emptystr,Male
 ,1507000,scream,0,100,38606,10);

 Add_Npc('Garulf',Mutant,409,250,250,39,Bard,38,emptystr,Male
 ,1250000,scream,0,100,4490,1180);

 Add_Npc('Eothain',Human,329,190,190,90,Warrior,32,emptystr,Male
 ,992800,scream,0,100,0,9090);

 Add_Npc('Sadrak',Troll,545,271,271,16,Sage,44,emptystr,Male
 ,1337000,scream,0,100,15600,0);

 Add_Npc('Grimbold',Dwarf,617,167,167,98,Barbarian,34,emptystr,Male
 ,1858000,scream,0,100,490,10900);

 Add_Npc('Lottie',Troll,590,227,227,98,Magician,27,emptystr,FeMale
 ,1858000,scream,0,100,490,10900);

 Add_Npc('Birgitte',Orc,353,167,167,26,Magician,32,emptystr,FeMale
 ,590900,scream,0,100,0,19601);

 Add_Npc('Rosalyn',Gnome,170,88,38,18,Cleric,58,emptystr,FeMale
 ,635500,scream,0,100,34800,0);


 {*** END of Npc LIST ***}




 {add_fake tells us if we are just here to count the number of npcs}
 if add_fake then exit;

 {writing right LEVEL depending on experience points}
 {also writing in start money}
 {also writing weapon & armor}

 {$I-}close(playerfile);{$I+}
 if IOResult<>0 then unable_to_close(global_npfile);

 for i:=1 to fs(fsplayer) do begin
  load_player(fload,player0,i);

  player0.level:=1;
  if player0.exp>=900 then player0.level:=2;
  if player0.exp>=5000 then player0.level:=3;
  if player0.exp>=10000 then player0.level:=4;
  if player0.exp>=15000 then player0.level:=5;
  if player0.exp>=20000 then player0.level:=6;
  if player0.exp>=30000 then player0.level:=7;
  if player0.exp>=40000 then player0.level:=8;
  if player0.exp>=60000 then player0.level:=9;
  if player0.exp>=85000 then player0.level:=10;
  if player0.exp>=120000 then player0.level:=11;
  if player0.exp>=140000 then player0.level:=12;
  if player0.exp>=180000 then player0.level:=13;
  if player0.exp>=240000 then player0.level:=14;
  if player0.exp>=290000 then player0.level:=15;
  if player0.exp>=340000 then player0.level:=16;
  if player0.exp>=400000 then player0.level:=17;
  if player0.exp>=500000 then player0.level:=18;
  if player0.exp>=600000 then player0.level:=19;
  if player0.exp>=850000 then player0.level:=20;
  if player0.exp>=1000000 then player0.level:=21;
  if player0.exp>=1200000 then player0.level:=22;
  if player0.exp>=1400000 then player0.level:=23;
  if player0.exp>=1600000 then player0.level:=24;
  if player0.exp>=1800000 then player0.level:=25;
  if player0.exp>=2200000 then player0.level:=26;
  if player0.exp>=2500000 then player0.level:=27;
  if player0.exp>=2700000 then player0.level:=28;
  if player0.exp>=2900000 then player0.level:=29;
  if player0.exp>=3200000 then player0.level:=30;
  if player0.exp>=3400000 then player0.level:=31;
  if player0.exp>=3600000 then player0.level:=32;
  if player0.exp>=3800000 then player0.level:=33;
  if player0.exp>=4200000 then player0.level:=34;
  if player0.exp>=4400000 then player0.level:=35;
  if player0.exp>=4600000 then player0.level:=36;
  if player0.exp>=4800000 then player0.level:=37;
  if player0.exp>=5000000 then player0.level:=38;
  if player0.exp>=5200000 then player0.level:=39;
  if player0.exp>=5400000 then player0.level:=40;
  if player0.exp>=5600000 then player0.level:=41;
  if player0.exp>=5800000 then player0.level:=42;
  if player0.exp>=6000000 then player0.level:=43;
  if player0.exp>=6200000 then player0.level:=44;
  if player0.exp>=6500000 then player0.level:=45;
  if player0.exp>=6800000 then player0.level:=46;
  if player0.exp>=7200000 then player0.level:=47;
  if player0.exp>=7500000 then player0.level:=48;
  if player0.exp>=8000000 then player0.level:=49;
  if player0.exp>=8500000 then player0.level:=50;
  if player0.exp>=9000000 then player0.level:=51;
  if player0.exp>=10000000 then player0.level:=52;
  if player0.exp>=12000000 then player0.level:=53;
  if player0.exp>=14000000 then player0.level:=54;
  if player0.exp>=16000000 then player0.level:=55;
  if player0.exp>=18000000 then player0.level:=56;
  if player0.exp>=20000000 then player0.level:=57;
  if player0.exp>=22000000 then player0.level:=58;
  if player0.exp>=24000000 then player0.level:=59;
  if player0.exp>=26000000 then player0.level:=60;
  if player0.exp>=28000000 then player0.level:=61;
  if player0.exp>=30000000 then player0.level:=62;
  if player0.exp>=31000000 then player0.level:=63;
  if player0.exp>=32000000 then player0.level:=64;
  if player0.exp>=33000000 then player0.level:=65;
  if player0.exp>=34000000 then player0.level:=66;
  if player0.exp>=36000000 then player0.level:=67;
  if player0.exp>=38000000 then player0.level:=68;
  if player0.exp>=40000000 then player0.level:=69;
  if player0.exp>=41000000 then player0.level:=70;
  if player0.exp>=42000000 then player0.level:=71;
  if player0.exp>=44000000 then player0.level:=72;
  if player0.exp>=47000000 then player0.level:=73;
  if player0.exp>=50000000 then player0.level:=74;
  if player0.exp>=55000000 then player0.level:=75;
  if player0.exp>=60000000 then player0.level:=76;
  if player0.exp>=65000000 then player0.level:=77;
  if player0.exp>=75000000 then player0.level:=78;
  if player0.exp>=80000000 then player0.level:=79;
  if player0.exp>=85000000 then player0.level:=80;
  if player0.exp>=90000000 then player0.level:=81;
  if player0.exp>=95000000 then player0.level:=82;
  if player0.exp>=100000000 then player0.level:=83;
  if player0.exp>=120000000 then player0.level:=84;
  if player0.exp>=130000000 then player0.level:=85;
  if player0.exp>=140000000 then player0.level:=86;
  if player0.exp>=150000000 then player0.level:=87;
  if player0.exp>=160000000 then player0.level:=88;
  if player0.exp>=170000000 then player0.level:=89;
  if player0.exp>=180000000 then player0.level:=90;
  if player0.exp>=190000000 then player0.level:=91;
  if player0.exp>=200000000 then player0.level:=92;
  if player0.exp>=210000000 then player0.level:=93;
  if player0.exp>=220000000 then player0.level:=94;
  if player0.exp>=230000000 then player0.level:=95;
  if player0.exp>=240000000 then player0.level:=96;
  if player0.exp>=250000000 then player0.level:=97;
  if player0.exp>=260000000 then player0.level:=98;
  if player0.exp>=270000000 then player0.level:=99;
  if player0.exp>=280000000 then player0.level:=100;
  if player0.exp>=300000000 then player0.level:=101;
  if player0.exp>=310000000 then player0.level:=102;

  {distributing charisma, agility,dex,wisdom ... depending on level}
  player0.stamina :=player0.level*random(3)+1;
  player0.agility :=player0.level*random(3)+1;
  player0.charisma:=player0.level*random(3)+1;
  player0.dex     :=player0.level*random(3)+1;
  player0.wisdom  :=player0.level*random(3)+1;

  if player0.class in [Cleric,Magician,Sage] then begin
   player0.maxmana:=player0.level*30;
   player0.mana:=player0.maxmana;
  end
  else begin
   player0.mana:=0;
   player0.maxmana:=0;
  end;
  player0.gold:=player0.level*5000;

  x:=player0.level+random(5)+3;
  if x>100 then begin
   x:=90;
  end;

  {reset(objektfile);
  seek(objektfile,x);
  read(objektfile,objekt);
  close(objektfile);}

  x:=player0.level+random(5)+3;
  if x>100 then begin
   x:=90;
  end;

  {reset(objektfile);
  seek(objektfile,x);
  read(objektfile,objekt);
  close(objektfile);}

  {save player}
  load_player(fsave,player0,i);

  inc(counter);
  Statbar(Counter,totobj,global_masterx,global_mastery,1,1);

 end;

end;

end.
