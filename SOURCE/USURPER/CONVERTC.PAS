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


Program ConvertB; {Converter. Usurper 0.20x to 0.20e}

Uses Crt, Dos;

const

 {Versions}
 OldVersion = '0.20x';
 NewVersion = '0.20e';

 {color defs}
 FileColor       = 11;
 NewVersionColor = 14;
 OldVersionColor = 9;

 {data dir}
 datadir  = 'DATA\';

 {config file}
 ucfg = 'USURPER.CFG';

 {relation file}
 relationfile     = datadir+'RELATION.DAT';
 relationfiletemp = datadir+'RELATION.TMP';

 {god file}
 godfile     = datadir+'GODS.DAT';
 godfiletemp = datadir+'GODS.TMP';


 {children file}
 childfile     = datadir+'CHILDREN.DAT';
 childfiletemp = datadir+'CHILDREN.TMP';

 {user file}
 pfile     = datadir+'USERS.DAT';
 pfiletemp = datadir+'USERS.TMP';

 {npc file}
 npfile     = datadir+'NPCS.DAT';
 npfiletemp = datadir+'NPCS.TMP';

 {king file}
 kingfile     = datadir+'KING.DAT';
 kingfiletemp = datadir+'KING.TMP';

 {mail file}
 mailfile     = datadir+'MAIL.DAT';
 mailfiletemp = datadir+'MAIL.TMP';

 {quest file}
 questfile     = datadir+'RQUESTS.DAT';
 questfiletemp = datadir+'RQUESTS.TMP';

 {drink file}
 drinkfile     = datadir+'DRINKS.DAT';
 drinkfiletemp = datadir+'DRINKS.TMP';

 {market file}
 marketfile     = datadir+'PLMARKET.DAT';
 marketfiletemp = datadir+'PLMARKET.TMP';

 {wanted file}
 wantedfile     = datadir+'WANTED.DAT';
 wantedfiletemp = datadir+'WANTED.TMP';

 {structure constants}
 global_maxmaillines= 15; {max # of lines in mailrecord}
 global_KingGuards  = 5;  {max body guards the king can have }

 {misc}
 underscore=chr(196);

type {string types}

 s15 = string[15];
 s20 = string[20];
 s30 = string[30];
 s70 = string[70];
 s90 = string[90];
 s100= string[100];

{Date Type, used by ALL record type DATE definitions in the game (usually defined in record structures)}
type UDate = string[8];

type
 ObjType = (Head,
            Body,
            Arms,
            Hands,
            Fingers,
            Legs,
            Feet,
            Waist,
            Neck,
            Face,
            Shield,
            Food,
            Drink,
            Weapon,
            Abody);

type
 Classes = (Alchemist, {change RATING.PAS and VARIOUS.PAS when changing # of classes}
            Assassin,
            Barbarian, {no special ability}
            Bard,      {no special ability}
            Cleric,
            Jester,    {no special ability}
            Magician,
            Paladin,
            Ranger,    {no special ability}
            Sage,
            Warrior);  {no special ability}

type
 races = (Human, {change RATING.PAS and VARIOUS.PAS when changing # of races}
          Hobbit,
          Elf,
          HalfElf,
          Dwarf,
          Troll,
          Orc,
          Gnome,
          Gnoll,
          Mutant);
const
 global_maxitem     = 15;  {max # of items a player can have in inventory}
 global_maxspells   = 12;  {max # of spells available}
 global_maxcombat   = 14;  {max # of close combat moves}

type
 OldGodRec = Record {God record}
  realname : s30;  {real (user/bbs) name}
  name : s30;      {alias}
  id   : s15;      {unique ID tag, this id follows the player from the
                    user file!}
  recnr: word;      {rec # in file}
  age  : word;      {age}
  sex  : byte;      {sex, 1=male, 2=female}
  ai   : char;      {ai: 'H'uman or 'C'omputer }
  level: word;      {level}
  exp  : longint;   {experience}
  deleted  : boolean; {deleted}
  believers: word;    {believers, disciples, # of players who worship this god}
  darkness : longint; {good points, follows from the player time}
  goodness : longint; {dark points, follows from the player time}
 end; {OldGodRec *end*}

type
 NewGodRec = Record {God record}
  realname : s30;  {real (user/bbs) name}
  name : s30;      {alias}
  id   : s15;      {unique ID tag, this id follows the player from the
                    user file!}
  recnr: word;      {rec # in file}
  age  : word;      {age}
  sex  : byte;      {sex, 1=male, 2=female}
  ai   : char;      {ai: 'H'uman or 'C'omputer }
  level: word;      {level}
  exp  : longint;   {experience}
  deedsleft : word; {deedsleft today, new ones given at maintenance}
  deleted  : boolean; {deleted}
  believers: word;    {believers, disciples, # of players who worship this god}
  darkness : longint; {good points, follows from the player time}
  goodness : longint; {dark points, follows from the player time}
 end; {NewGodRec *end*}

type
 OldRelationRec = Record
  name1       : s30;  {player 1 name}
  name2       : s30;  {player 2 name}
  ai1         : char; {player 1 ai}
  ai2         : char; {player 2 ai}
  race1       : races; {pl1 race}
  race2       : races; {pl2 race}
  relation1   : word; {pl1s relation to pl2 ,see:relation constants}
  relation2   : word; {pl2s relation to pl1 ,see:relation constants}
  idtag1      : s15; {holds pl1.id - necessary when identifying kids parents}
  idtag2      : s15; {holds pl2.id - necessary when identifying kids parents}
  recnr1      : word; {pl1 recnr in userfile}
  recnr2      : word; {pl2 recnr in userfile}
  deleted     : boolean; {deleted}
  recnr       : word; {record #, file position}
  bannedmarry : boolean; {not allowed to marry, only the King can set this flag}
  marriedtimes: word; {how many times have this couple been married}
  marrieddays : longint; {how many days has the current marriage lasted}
  kids        : word; {# of children this relation has produced}
  killedby1   : word; {name2 has been killed this many times by name1}
  killedby2   : word; {name1 has been killed this many times by name2}
 end;

 NewRelationRec = Record
  name1       : s30;  {player 1 name}
  name2       : s30;  {player 2 name}
  ai1         : char; {player 1 ai}
  ai2         : char; {player 2 ai}
  race1       : races; {pl1 race}
  race2       : races; {pl2 race}
  relation1   : word; {pl1s relation to pl2 ,see:relation constants}
  relation2   : word; {pl2s relation to pl1 ,see:relation constants}
  idtag1      : s15; {holds pl1.id - necessary when identifying kids parents}
  idtag2      : s15; {holds pl2.id - necessary when identifying kids parents}
  recnr1      : word; {pl1 recnr in userfile}
  recnr2      : word; {pl2 recnr in userfile}
  filetype1  : byte; {pl1 is residing in (1)user/(2)npc file}
  filetype2  : byte; {pl1 is residing in (1)user/(2)npc file}
  deleted     : boolean; {deleted}
  recnr       : word; {record #, file position}
  bannedmarry : boolean; {not allowed to marry, only the King can set this flag}
  marriedtimes: word; {how many times have this couple been married}
  marrieddays : longint; {how many days has the current marriage lasted}
  kids        : word; {# of children this relation has produced}
  killedby1   : word; {name2 has been killed this many times by name1}
  killedby2   : word; {name1 has been killed this many times by name2}
 end;

type

 OldChildRec = Record {kids produced by players/npc, not necessarily married
                    couples. remember that a divorce will split the kids}
  name    : s30;  {name}
  sex     : byte; {sex, 1=male, 2=female}
  age     : word; {age}
  recnr   : word; {record #, position in file}
  ageplus : word; {how soon before getting one year older}
  bastard: boolean; {set to true if product of secret lay or whore intercourse}
  named  : boolean; {has kid been named yet? if not it's not accessible in lists etc}
  deleted: boolean; {is this record deleted}

  mother : s30;  {name of current mother}
  father : s30;  {name of current father}

  orgmother : s30; {name of original mother}
  orgfather : s30; {name of original father}

  motherid : s15; {current mother ID - to match userrec ID}
  fatherid : s15; {current father ID - to match userrec ID}

  orgmotherid : s15; {original mother ID - to match userrec ID}
  orgfatherid : s15; {original father ID - to match userrec ID}

  motherai : char; {current mother ai}
  fatherai : char; {current father ai}

  orgmotherai : char; {original mother ai}
  orgfatherai : char; {original father ai}

  motherrace : races; {current mother race}
  fatherrace : races; {current father race}

  orgmotherrace : races; {original mother race}
  orgfatherrace : races; {original father race}


  motheraccess : boolean; {does the mother have access to the child}
  fatheraccess : boolean; {does the father have access to the child}

  soul     : integer; {-500 .. 0 .. +500,  -500=pure evil, +500=angel heart}
  health   : byte; {see CMS.PAS for ChildHealth_XX constants}
  location : byte; {see CMS.PAS for ChildLocation_XX constants}
  kidnapper: s30; {name of kidnapper}
  kidnapperid : s15; {kidnapper id}
  ransom_demanded : longint; {gold demanded for the release of child}
  cursed_by_god  : s30; {name of god who cursed}
  cursed_by_godID: s15; {god unique id}
  royal : byte; {royal blood? 0=no, 1=half, 2=full}

 end;


 NewChildRec = Record {kids produced by players/npc, not necessarily married
                    couples. remember that a divorce will split the kids}
  name    : s30;  {name}
  sex     : byte; {sex, 1=male, 2=female}
  age     : word; {age}
  birth   : udate; {date of birth}
  recnr   : word; {record #, position in file}
  ageplus : word; {how soon before getting one year older}
  bastard: boolean; {set to true if product of secret lay or whore intercourse}
  named  : boolean; {has kid been named yet? if not it's not accessible in lists etc}
  deleted: boolean; {is this record deleted}

  mother : s30;  {name of current mother}
  father : s30;  {name of current father}

  orgmother : s30; {name of original mother}
  orgfather : s30; {name of original father}

  motherid : s15; {current mother ID - to match userrec ID}
  fatherid : s15; {current father ID - to match userrec ID}

  orgmotherid : s15; {original mother ID - to match userrec ID}
  orgfatherid : s15; {original father ID - to match userrec ID}

  motherai : char; {current mother ai}
  fatherai : char; {current father ai}

  orgmotherai : char; {original mother ai}
  orgfatherai : char; {original father ai}

  motherrace : races; {current mother race}
  fatherrace : races; {current father race}

  orgmotherrace : races; {original mother race}
  orgfatherrace : races; {original father race}


  motheraccess : boolean; {does the mother have access to the child}
  fatheraccess : boolean; {does the father have access to the child}

  soul     : integer; {-500 .. 0 .. +500,  -500=pure evil, +500=angel heart}
  health   : byte; {see CMS.PAS for ChildHealth_XX constants}
  location : byte; {see CMS.PAS for ChildLocation_XX constants}
  kidnapper: s30; {name of kidnapper}
  kidnapperid : s15; {kidnapper id}
  ransom_demanded : longint; {gold demanded for the release of child}
  cursed_by_god  : s30; {name of god who cursed}
  cursed_by_godID: s15; {god unique id}
  royal : byte; {royal blood? 0=no, 1=half, 2=full}

 end;

type {Player/Npc Record}
 OldUserRec = record
 Name1 : s30;
 name2 : s30;
 ai    : char;
 race  : races;
 age   : integer;
 gold  : longint; {gold in hand}
 hps   : longint; {hitpoints}
 exp   : longint; {experience}
 level : longint; {level}
 bankgold : longint; {gold in bank}
 chiv  : longint; {chivalry}
 dark  : longint; {darkness}
 fights: integer; {player fights}
 strength : longint; {strength}
 defence  : longint; {defence}
 healing  : longint; {healing potions}
 allowed   : boolean;  {allowed to play}
 maxhps  : longint;  {max hitpoints}
 laston  : longint;  {laston, date}
 ageplus : integer;  {how soon before getting one year older}
 darknr  : integer;  {dark deeds left}
 chivnr  : integer;  {good deeds left}
 pfights : integer;  {dungoen fights}
 king    : boolean;  {king?}
 location: integer;  {offline location, se offloc_?? constants}
 team    : string[25]; {team name}
 teampw  : string[20]; {team password}
 teamrec : word;       {team record, how many days have we had the town}
 bguard  : integer; {type of guard, # in door guard file}
 cturf   : boolean; {is team in control of town}
 gnollp  : integer; {gnoll poison, temporary used in fights}
 mental  : integer; {mental health}
 addict  : integer; {drug addiction}
 wellwish : boolean; {has player visited the Wishing Well}
 height   : integer; {height}
 weight   : integer; {weight}
 eyes : integer; {eye color}
 hair : integer; {hair color}
 skin : integer; {skin color}
 sex  : integer; {sex, male=1 female=2}
 mana : longint; {mana, spellcasters only}
 maxmana  : longint; {maxmana}
 stamina  : longint; {stamina}
 agility  : longint;
 charisma : longint;
 dex      : longint;
 wisdom   : longint;
 weappow  : longint;
 armpow   : longint;
 blind    : boolean; {blindhet}
 plague   : boolean; {pesten}
 smallpox : boolean; {smittkoppor}
 measles  : boolean; {m„ssling}
 leprosy  : boolean; {spet„lska}
 mercy    : integer;
 item     : array[1..global_maxitem] of integer;
 itemtype : array[1..global_maxitem] of objtype;
 phr      : array[1..6] of s70;
 autoheal : boolean;
 class    : classes;
 loyalty  : integer;
 haunt    : integer; {how many demons are set to haunt player}
 master   : char;    {level master player uses}
 tfights  : integer; {team fights}
 thiefs   : integer; {thieverys left}
 brawls   : integer; {brawls left}
 assa     : integer; {assainations left}
 desc     : array[1..4] of s70; {player description}
 poison   : integer; {poison, adds to weapon. used by ALCHEMISTS}
 spell    : array[1..global_maxspells,1..2] of boolean; {spells}
 skill    : array[1..global_maxcombat] of integer; {close combat skills}
 trains   : integer; {training sessions at Close-Combat master}
 lhand    : word; {item carried in left hand}
 rhand    : word; {item in right hand}
 head     : word; {head}
 body     : word; {body}
 arms     : word; {arms}
 lfinger  : word; {left finger}
 rfinger  : word; {right fignger}
 legs     : word; {legs}
 feet     : word; {feet}
 waist    : word; {waist}
 neck     : word; {neck}
 neck2    : word; {neck2}
 face     : word; {face}
 shield   : word; {shield}
 hands    : word; {hands}
 abody    : word; {around body}
 immortal  : boolean; {if yes, never deleted for inactivity}
 battlecry : s70;     {battle cry}
 bguardnr  : integer; {number of doorguards, type is specified in bguard}
 casted    : boolean; {used as temporary flag in battles}
 punch     : longint; {player punch, temporary flag in battles}
 absorb    : longint; {absorbe punch, temporary flag in battles}
 used_item : boolean; {has player used an item, temporary flag in battles}
 m_kills   : longint; {monster kills}
 m_defeats : longint; {monster defeats}
 p_kills   : longint; {player kills}
 p_defeats : longint; {player defeats}

 {below is new for 0.08}
 interest    : longint; {accumulated bank interest}
 alive_bonus : longint; {accumulated staying alive bonus}
 expert      : boolean; {expert menus ON/OFF}
 maxtime     : integer; {maxtime per session in game}
 ear         : byte; {how should player deal with internode messages}
 castin      : char;
 weapon      : word; {OLD mode}
 armor       : word; {OLD mode}
 apow        : word; {OLD mode}
 wpow        : word; {OLD mode}
 disres      : byte; {disease resistance}
 amember     : boolean; {medlem i alchemist s„llskapet}
 medal       : array[1..20] of boolean;
 bankguard   : boolean; {frivillig bankvakt?}
 bankwage    : longint; {l”n fr†n banken, f”r guard duty}
 weaphag     : byte; {ggr en spelare har hagglat i weaponshop}
 armhag      : byte; {ggr en spelare har hagglat i armorshop}
 recnr       : word; {fil pekare, anv„nds vid sparning av spelare}
 auto_meny   : boolean; {spelaren vill ha menyerna automatiskt utritade}

 {below is new for 0.14}
 quests      : integer; {# of completed missions/quests}
 deleted     : boolean;  {is this record deleted}
 god         : string[30]; {spelaren tilber GUD med detta namn}
 royquests   : longint;  {royal quests accomplished}

 {below is new for 0.17}
 RoyTaxPaied : longint; {royal taxes paied since player was last logged in}
 Wrestlings  : byte; {indian cave wrestlings}
 DrinksLeft  : byte; {drinks left today, at Orbs}
 DaysInPrison: byte; {days left in prison}

 {below is new for 0.18}
 UmanBearTries : byte; {times player have tried to tame the bear}
 Massage  : byte; {times player have had massage this day}
 Gym_Sessions:byte; {workout sessions at the Gym / day}
 Gym_Owner: byte; {controller of the gym? has to be in a team}
 Gym_Card :byte; {free card to the gym? if not gym_owner that is}
 RoyQuestsToday: word;{how many royal quests have the player completed today}
 KingVotePoll: byte; {how many days since voted for king popularity}
 KingLastVote: byte; {last vote, to be used for polls}
 Married     : boolean; {is player married}
 Kids        : word; {how many kids this playeer is father/mother to}
 IntimacyActs: word; {how many acts of intimacy has player left today?}
 Pregnancy   : byte; {is player pregnant? 0=no, 1...X = days pregnant}
 FatherID    : s15;  {fathers id tag, set when pregnancy starts}
 AutoHate    : byte; {automatically worsen relation with a person that
                      attacks you? (0=no 1=one step worse)}
 ID          : s15; {unique ID tag, to keep players in touch with relations
                     and children. without thios new players with the same
                     name as a deceased father will inherit a the old guys
                     children. relations.id correspond to playe.id}
 Tax_Relief : boolean; {free from tax?}
 MarriedTimes : word; {counter for marriages}
 Bard_Songs_Left: word; {ehhh..quite self-explanatory huh?}
 prison_escapes:byte; {allowed prison escape attempts}
 Filtyp : byte; {type of file player resides in (1=player file, 2=npc file)}
 resurrections : word; {times left allowed to play...decreases after each death}
 {below is new for 0.20}
 PickPocketAttempts : word; {allowed pick pocket attempts}
end;

type {Player/Npc Record}
 NewUserRec = record
 Name1 : s30;
 name2 : s30;
 ai    : char;
 race  : races;
 age   : integer;
 gold  : longint; {gold in hand}
 hps   : longint; {hitpoints}
 exp   : longint; {experience}
 level : longint; {level}
 bankgold : longint; {gold in bank}
 chiv  : longint; {chivalry}
 dark  : longint; {darkness}
 fights: integer; {player fights}
 strength : longint; {strength}
 defence  : longint; {defence}
 healing  : longint; {healing potions}
 allowed   : boolean;  {allowed to play}
 maxhps  : longint;  {max hitpoints}
 laston  : longint;  {laston, date}
 ageplus : integer;  {how soon before getting one year older}
 darknr  : integer;  {dark deeds left}
 chivnr  : integer;  {good deeds left}
 pfights : integer;  {dungoen fights}
 king    : boolean;  {king?}
 location: integer;  {offline location, se offloc_?? constants}
 team    : string[25]; {team name}
 teampw  : string[20]; {team password}
 teamrec : word;       {team record, how many days have we had the town}
 bguard  : integer; {type of guard, # in door guard file}
 cturf   : boolean; {is team in control of town}
 gnollp  : integer; {gnoll poison, temporary used in fights}
 mental  : integer; {mental health}
 addict  : integer; {drug addiction}
 wellwish : boolean; {has player visited the Wishing Well}
 height   : integer; {height}
 weight   : integer; {weight}
 eyes : integer; {eye color}
 hair : integer; {hair color}
 skin : integer; {skin color}
 sex  : integer; {sex, male=1 female=2}
 mana : longint; {mana, spellcasters only}
 maxmana  : longint; {maxmana}
 stamina  : longint; {stamina}
 agility  : longint;
 charisma : longint;
 dex      : longint;
 wisdom   : longint;
 weappow  : longint;
 armpow   : longint;
 blind    : boolean; {blindhet}
 plague   : boolean; {pesten}
 smallpox : boolean; {smittkoppor}
 measles  : boolean; {m„ssling}
 leprosy  : boolean; {spet„lska}
 mercy    : integer;
 item     : array[1..global_maxitem] of integer;
 itemtype : array[1..global_maxitem] of objtype;
 phr      : array[1..6] of s70;
 autoheal : boolean;
 class    : classes;
 loyalty  : integer;
 haunt    : integer; {how many demons are set to haunt player}
 master   : char;    {level master player uses}
 tfights  : integer; {team fights}
 thiefs   : integer; {thieverys left}
 brawls   : integer; {brawls left}
 assa     : integer; {assainations left}
 desc     : array[1..4] of s70; {player description}
 poison   : integer; {poison, adds to weapon. used by ALCHEMISTS}
 spell    : array[1..global_maxspells,1..2] of boolean; {spells}
 skill    : array[1..global_maxcombat] of integer; {close combat skills}
 trains   : integer; {training sessions at Close-Combat master}
 lhand    : word; {item carried in left hand}
 rhand    : word; {item in right hand}
 head     : word; {head}
 body     : word; {body}
 arms     : word; {arms}
 lfinger  : word; {left finger}
 rfinger  : word; {right fignger}
 legs     : word; {legs}
 feet     : word; {feet}
 waist    : word; {waist}
 neck     : word; {neck}
 neck2    : word; {neck2}
 face     : word; {face}
 shield   : word; {shield}
 hands    : word; {hands}
 abody    : word; {around body}
 immortal  : boolean; {if yes, never deleted for inactivity}
 battlecry : s70;     {battle cry}
 bguardnr  : integer; {number of doorguards, type is specified in bguard}
 casted    : boolean; {used as temporary flag in battles}
 punch     : longint; {player punch, temporary flag in battles}
 absorb    : longint; {absorbe punch, temporary flag in battles}
 used_item : boolean; {has player used an item, temporary flag in battles}
 m_kills   : longint; {monster kills}
 m_defeats : longint; {monster defeats}
 p_kills   : longint; {player kills}
 p_defeats : longint; {player defeats}

 {below is new for 0.08}
 interest    : longint; {accumulated bank interest}
 alive_bonus : longint; {accumulated staying alive bonus}
 expert      : boolean; {expert menus ON/OFF}
 maxtime     : integer; {maxtime per session in game}
 ear         : byte; {how should player deal with internode messages}
 castin      : char;
 weapon      : word; {OLD mode}
 armor       : word; {OLD mode}
 apow        : word; {OLD mode}
 wpow        : word; {OLD mode}
 disres      : byte; {disease resistance}
 amember     : boolean; {medlem i alchemist s„llskapet}
 medal       : array[1..20] of boolean;
 bankguard   : boolean; {frivillig bankvakt?}
 bankwage    : longint; {l”n fr†n banken, f”r guard duty}
 weaphag     : byte; {ggr en spelare har hagglat i weaponshop}
 armhag      : byte; {ggr en spelare har hagglat i armorshop}
 recnr       : word; {fil pekare, anv„nds vid sparning av spelare}
 auto_meny   : boolean; {spelaren vill ha menyerna automatiskt utritade}

 {below is new for 0.14}
 quests      : integer; {# of completed missions/quests}
 deleted     : boolean;  {is this record deleted}
 god         : string[30]; {spelaren tilber GUD med detta namn}
 royquests   : longint;  {royal quests accomplished}

 {below is new for 0.17}
 RoyTaxPaied : longint; {royal taxes paied since player was last logged in}
 Wrestlings  : byte; {indian cave wrestlings}
 DrinksLeft  : byte; {drinks left today, at Orbs}
 DaysInPrison: byte; {days left in prison}

 {below is new for 0.18}
 UmanBearTries : byte; {times player have tried to tame the bear}
 Massage  : byte; {times player have had massage this day}
 Gym_Sessions:byte; {workout sessions at the Gym / day}
 Gym_Owner: byte; {controller of the gym? has to be in a team}
 Gym_Card :byte; {free card to the gym? if not gym_owner that is}
 RoyQuestsToday: word;{how many royal quests have the player completed today}
 KingVotePoll: byte; {how many days since voted for king popularity}
 KingLastVote: byte; {last vote, to be used for polls}
 Married     : boolean; {is player married}
 Kids        : word; {how many kids this playeer is father/mother to}
 IntimacyActs: word; {how many acts of intimacy has player left today?}
 Pregnancy   : byte; {is player pregnant? 0=no, 1...X = days pregnant}
 FatherID    : s15;  {fathers id tag, set when pregnancy starts}
 AutoHate    : byte; {automatically worsen relation with a person that
                      attacks you? (0=no 1=one step worse)}
 ID          : s15; {unique ID tag, to keep players in touch with relations
                     and children. without thios new players with the same
                     name as a deceased father will inherit a the old guys
                     children. relations.id correspond to playe.id}
 Tax_Relief : boolean; {free from tax?}
 MarriedTimes : word; {counter for marriages}
 Bard_Songs_Left: word; {ehhh..quite self-explanatory huh?}
 prison_escapes:byte; {allowed prison escape attempts}
 Filtyp : byte; {type of file player resides in (1=player file, 2=npc file)}
 resurrections : word; {times left allowed to play...decreases after each death}
 {below is new for 0.20}
 PickPocketAttempts : word; {allowed pick pocket attempts}
 {below is new for 0.20e}
 BankRobberyAttempts : word; {bank robbery attempts / day}

end;

type {used to issue King orders, open shoppes etc etc}
 NewKingRec = record
  name          : s30; {name of ruler}
  ai            : char; {ai - C or H}
  sexy          : byte; {male or female}
  daysinpower   : longint; {days in power}
  tax           : byte; {tax level}
  taxalignment  : byte; {tax who? 0=all,1=only good,2=only evil}
  treasury      : longint; {money in the royal vault}
  prisonsleft   : byte; {# of people king can imprison today. new every day}
  executeleft   : byte; {# of death sentences left today. new every day}
  questsleft    : word; {# of new quests the king can issue today}
  MarryActions  : word; {new for v0.18! times king can mess around with couples}
  WolfFeed      : byte; {new for v0.18! how many kids have been tossed to the wolves every day?}
  RoyalAdoptions: byte; {new for v0.18! how many kids can be put in the Royal Orphanage every day?}
  moatID        : s15; {unique moat creature ID}
  moatnr        : integer; {how many crocodiles (or whatever) in the moat?}
  guard         : array[1..global_KingGuards] of s30; {king body guards, name}
  guardpay      : array[1..global_KingGuards] of longint; {king guard, salary}
  guardai       : array[1..global_KingGuards] of char; {king guard, AI}
  guardsex      : array[1..global_KingGuards] of byte; {king guard,sex}
  shop_weapon   : boolean; {is weapon shop open}
  shop_armor    : boolean; {is armor shop open}
  shop_magic    : boolean; {is magic shop open}
  shop_alabat   : boolean; {is alabats shop open}
  shop_plmarket : boolean; {is player market open}
  shop_healing  : boolean; {is healing center}
  shop_drugs    : boolean; {is drug palace open}
  shop_steroids : boolean; {is steroid shop open}
  shop_orbs     : boolean; {is Orbs club open}
  shop_evilmagic: boolean; {is evil mage shop open}
  shop_bobs     : boolean; {is bobs beer open}
  shop_whores   : boolean; {is whore house open}
  shop_gigolos  : boolean; {is gigolos place open}
 end; {kingrec .end.}

type {used to issue King orders, open shoppes etc etc}
 OldKingRec = record
  name          : s30; {name of ruler}
  ai            : char; {ai - C or H}
  sexy          : byte; {male or female}
  daysinpower   : longint; {days in power}
  tax           : byte; {tax level}
  taxalignment  : byte; {tax who? 0=all,1=only good,2=only evil}
  treasury      : longint; {money in the royal vault}
  prisonsleft   : byte; {# of people king can imprison today. new every day}
  executeleft   : byte; {# of death sentences left today. new every day}
  questsleft    : word; {# of new quests the king can issue today}
  moatID        : s15; {unique moat creature ID}
  moatnr        : integer; {how many crocodiles (or whatever) in the moat?}
  guard         : array[1..global_KingGuards] of s30; {king body guards, name}
  guardpay      : array[1..global_KingGuards] of longint; {king guard, salary}
  guardai       : array[1..global_KingGuards] of char; {king guard, AI}
  guardsex      : array[1..global_KingGuards] of byte; {king guard,sex}
  shop_weapon   : boolean; {is weapon shop open}
  shop_armor    : boolean; {is armor shop open}
  shop_magic    : boolean; {is magic shop open}
  shop_alabat   : boolean; {is alabats shop open}
  shop_plmarket : boolean; {is player market open}
  shop_healing  : boolean; {is healing center}
  shop_drugs    : boolean; {is drug palace open}
  shop_steroids : boolean; {is steroid shop open}
  shop_orbs     : boolean; {is Orbs club open}
  shop_evilmagic: boolean; {is evil mage shop open}
  shop_bobs     : boolean; {is bobs beer open}
  shop_whores   : boolean; {is whore house open}
  shop_gigolos  : boolean; {is gigolos place open}
 end; {kingrec .end.}

const global_maxmon      = 17;  {max monster avtive at same time, OBS! WARNING! QUESTREC is dependant on this!}
type
 QuestTypes   = (SingleQuest,TeamQuest);
 QuestTargets = (qMonster,qAssassin,qSeduce,qClaimTown,qGangWar);
 {quest reward types}
 QRewardTypes = (qNothing,qExp,qMoney,qPotions,QDarkness,QChivalry);

type NewQuestRec = Record {Royal Quests, initiated by the King/Queen}

      Id          : s20; {unique identification # number, useful when offering requests via mail}
      Initiator   : s30; {name of (KING/QUEEN) who initiated this quest}
      date        : string[8]; {date when quest was created}
      QuestType   : QuestTypes; {single or team effort, see QuestTypes}
      QuestTarget : QuestTargets; {monsters,assassinatio,seduce,claim town,gang war}
      difficulty  : byte; {difficulty, especially when encountering monsters}
      deleted     : boolean; {is this quest deleted}
      comment     : s90; {comment by initiator}
      occupier    : s30; {is quest taken at this moment/name of the person}
      occrace     : races; {occupiers race}
      occsex      : byte; {occupiers sex 1=male,2=female}
      occdays     : word; {quest has been occupied for X days}
      daystocomple: word; {days given to complete quest before failed}

      offerto     : s30; {is this quest an offer to player}
      offerrefused: byte; {if offer is refused (1=delete,2=add to list}
      forced      : boolean; {is quest forced upon OCCUPIER}
      minlevel    : word; {min level required to take on quest}
      maxlevel    : word; {max level required to take on quest}

      reward      : byte; {nothing,low,medium,high}
      rewardtype  : qrewardtypes; {type of reward, see qrewardtypes}

      penalty     : byte; {nothing,low,medium,high}
      penaltytype : qrewardtypes; {type of penalty, see qrewardtypes}

      monsters    : array[1..global_maxmon,1..2] of word; {1=type of monster,2=how many}

     end; {NewQuestRec *end*}

type OldQuestRec = Record {Royal Quests, initiated by the King/Queen}

      Id          : s20; {unique identification # number, useful when offering requests via mail}
      Initiator   : s30; {name of (KING/QUEEN) who initiated this quest}
      date        : string[6]; {date when quest was created}
      QuestType   : QuestTypes; {single or team effort, see QuestTypes}
      QuestTarget : QuestTargets; {monsters,assassinatio,seduce,claim town,gang war}
      difficulty  : byte; {difficulty, especially when encountering monsters}
      deleted     : boolean; {is this quest deleted}
      comment     : s90; {comment by initiator}
      occupier    : s30; {is quest taken at this moment/name of the person}
      occrace     : races; {occupiers race}
      occsex      : byte; {occupiers sex 1=male,2=female}
      occdays     : word; {quest has been occupied for X days}
      daystocomple: word; {days given to complete quest before failed}

      offerto     : s30; {is this quest an offer to player}
      offerrefused: byte; {if offer is refused (1=delete,2=add to list}
      forced      : boolean; {is quest forced upon OCCUPIER}
      minlevel    : word; {min level required to take on quest}
      maxlevel    : word; {max level required to take on quest}

      reward      : byte; {nothing,low,medium,high}
      rewardtype  : qrewardtypes; {type of reward, see qrewardtypes}

      penalty     : byte; {nothing,low,medium,high}
      penaltytype : qrewardtypes; {type of penalty, see qrewardtypes}

      monsters    : array[1..global_maxmon,1..2] of word; {1=type of monster,2=how many}

     end; {OldQuestRec *end*}

type {mail record definition}
 NewMailRec = record
  receiver : s30; {destination <player.name2>}
  recgod   : boolean; {is receiver a god?}
  date     : string[8]; {mail was created this date MONTH,DAY,YEAR MM-DD-YYYY}
  readflag : boolean; {has this mail record been read/processed}
  sender   : s30; {who sent this mail <player.name2>}
  sendgod  : boolean; {is sender a god}
  special  : byte; {special request, see mailrequest_nothingXX constants}
  mess : array [1..global_maxmaillines] of s100; {message text}
 end;

type {mail record definition}
 OldMailRec = record
  receiver : s30; {destination <player.name2>}
  date     : string[6]; {mail was created this date MONTH,DAY,YEAR 00-00-00}
  readflag : boolean; {has this mail record been read/processed}
  sender   : s30; {who sent this mail <player.name2>}
  special  : byte; {special request, see mailrequest_nothingXX constants}
  mess : array [1..global_maxmaillines] of s90; {message text}
 end;

type {Orbs Bar, Special Drinks, made by Players => saved to drinkfile}
 NewDrinkRec = record
  name   : s30; {the drink}
  creator: s30; {creator}
  date   : string[8]; {when was the drink created}
  comment: s70; {comment by creator}
  ordered: longint; {how many times have the drink been used/drank}
  lasthad: s30; {last customer that had this drink}
  lastrac: races; {last customers race}
  lastdat: string[8]; {date when this drink was last ordered}
  deleted: boolean; {deleted?}
  secret : boolean; {secret recipe? creators choice}
  amount : array[1..17] of integer; {ingredients}
 end;

type {Orbs Bar, Special Drinks, made by Players => saved to drinkfile}
 OldDrinkRec = record
  name   : s30; {the drink}
  creator: s30; {creator}
  date   : string[6]; {when was the drink created}
  comment: s70; {comment by creator}
  ordered: longint; {how many times have the drink been used/drank}
  lasthad: s30; {last customer that had this drink}
  lastrac: races; {last customers race}
  deleted: boolean; {deleted?}
  secret : boolean; {secret recipe? creators choice}
  amount : array[1..17] of integer; {ingredients}
 end;

type {Players Market, stuff that players want to sell}
 NewMarketRec = record
  pekare : word; {points to item # in the objXX file}
  ityp   : objtype; {type of item}
  seller : s30;     {name of seller}
  date   : string[8]; {when the item was put in}
  price  : longint; {price}
  target : s30;     {marked for someone special}
  team   : boolean; {marked for some special team?}
  comment: s70;     {comment by seller}
  sold   : boolean; {has item been sold?}
 end;

type {Players Market, stuff that players want to sell}
 OldMarketRec = record
  pekare : word; {points to item # in the objXX file}
  ityp   : objtype; {type of item}
  seller : s30;     {name of seller}
  date   : string[6]; {when the item was put in}
  price  : longint; {price}
  target : s30;     {marked for someone special}
  team   : boolean; {marked for some special team?}
  comment: s70;     {comment by seller}
  sold   : boolean; {has item been sold?}
 end;

type {Most Wanted people}
 NewWantedRec = record
  name      : s30;       {who is wanted?}
  level     : byte;      {the wanteds level}
  date      : string[8]; {when was this poster created?}
  mad       : s30;       {person who created the poster}
  gold      : longint;   {gold reward}
  collected : boolean;   {has the reward been collected?}
  elig      : char;      {vem kan collecta rewarden? A=all,C=npcs,H=players}
  ai1       : char;      {posters creator AI npC / Human}
  ai2       : char;      {wanted persons  AI npC / Human}
  anonym    : boolean;   {is the creator of the poster anonymous?}
 end;

type {Most Wanted people}
 OldWantedRec = record
  name      : s30;       {who is wanted?}
  level     : byte;      {the wanteds level}
  date      : string[6]; {when was this poster created?}
  mad       : s30;       {person who created the poster}
  gold      : longint;   {gold reward}
  collected : boolean;   {has the reward been collected?}
  elig      : char;      {vem kan collecta rewarden? A=all,C=npcs,H=players}
  ai1       : char;      {posters creator AI npC / Human}
  ai2       : char;      {wanted persons  AI npC / Human}
  anonym    : boolean;   {is the creator of the poster anonymous?}
 end;

var

 {textfiles used when converting usurper.cfg (ucfg)}
 NewText : text;
 OldText : text;

 {god.dat definitions}
 NewGod : NewGodRec;
 OldGod : OldGodRec;
 NewGodFile : file of NewGodRec;
 OldGodFile : file of OldGodRec;

 {relation.dat definitions}
 NewRelation : NewRelationRec;
 OldRelation : OldRelationRec;
 NewRelationFile : file of NewRelationRec;
 OldRelationFile : file of OldRelationRec;

 {children.dat definitions}
 NewChild : NewChildRec;
 OldChild : OldChildRec;
 NewChildrenFile : file of NewChildRec;
 OldChildrenFile : file of OldChildRec;

 {users.dat definitions}
 NewPlayer : NewUserRec;
 OldPlayer : OldUserRec;
 NewPlayerFile : file of NewUserRec;
 OldPlayerFile : file of OldUserRec;

 {king.dat definitions}
 NewKing : NewKingRec;
 OldKing : OldKingRec;
 NewKingFile : file of NewKingRec;
 OldKingFile : file of OldKingRec;

 {mail.dat definitions}
 NewMail : NewMailRec;
 OldMail : OldMailRec;
 NewMailFile : file of NewMailRec;
 OldMailFile : file of OldMailRec;

 {rquests.dat definitions}
 NewQuest : NewQuestRec;
 OldQuest : OldQuestRec;
 NewQuestFile : file of NewQuestRec;
 OldQuestFile : file of OldQuestRec;

 {drinks.dat definitions}
 NewDrink : NewDrinkRec;
 OldDrink : OldDrinkRec;
 NewDrinkFile : file of NewDrinkRec;
 OldDrinkFile : file of OldDrinkRec;

 {plmarket.dat definitions}
 NewMarket : NewMarketRec;
 OldMarket : OldMarketRec;
 NewMarketFile : file of NewMarketRec;
 OldMarketFile : file of OldMarketRec;

 {wanted.dat definitions}
 NewWanted : NewWantedRec;
 OldWanted : OldWantedRec;
 NewWantedFile : file of NewWantedRec;
 OldWantedFile : file of OldWantedRec;

{*** VARIABLES END ***}

const error_col = 12; {display color of i/o errors}
      error_mes = 'File-Alert! '; {displayed before actual error message}




function Long2Str(Number: LongInt): String;
var
    TempStr: string;
begin
 Str(Number,TempStr);
 Long2Str := TempStr;
end;

Function Todays_Date : string; {date string[8] american, mm dd yyyy}
var
 d,m,y,dow: word;
 s,s2: string[8];
begin;  {original code taken from the "date" function in ddscott.pas}

 getdate(y,m,d,dow);

 s:=long2str(m);
 if length(s)=1 then s:='0'+s;
 s2:=long2str(d);
 if length(s2)=1 then s2:='0'+s2;
 s:=s+s2;
 s2:=long2str(y);
 while length(s2)<4 do begin
  s2:='0'+s2;
 end;
 s:=s+s2;

 {return result}
 Todays_Date:=s;

end; {todays_date *end*}

Function Update_Sixdate(const Olddate:string) : string;
begin {converts a MMDDYY string to a MMDDYYYY string}

 update_sixdate:=todays_date;
{ update_sixdate:=olddate[1]+olddate[2]+olddate[3]+olddate[4]+'19'
                +olddate[5]+olddate[6];
                }

end; {update_sixdate *end*}

Function Crypt(nr:word) : s70; {returns a random array with length NR}
var s : string[100];
    i : byte;
begin

 s:='';
 for i:=1 to nr do begin
  case random(65) of
   0: s:=s+'A';
   1: s:=s+'B';
   2: s:=s+'C';
   3: s:=s+'D';
   4: s:=s+'E';
   5: s:=s+'F';
   6: s:=s+'G';
   7: s:=s+'H';
   8: s:=s+'I';
   9: s:=s+'J';
   10: s:=s+'K';
   11: s:=s+'L';
   12: s:=s+'M';
   13: s:=s+'N';
   14: s:=s+'O';
   15: s:=s+'P';
   16: s:=s+'Q';
   17: s:=s+'R';
   18: s:=s+'S';
   19: s:=s+'T';
   20: s:=s+'U';
   21: s:=s+'V';
   22: s:=s+'W';
   23: s:=s+'X';
   24: s:=s+'Y';
   25: s:=s+'Z';
   26: s:=s+'a';
   27: s:=s+'b';
   28: s:=s+'c';
   29: s:=s+'d';
   30: s:=s+'e';
   31: s:=s+'f';
   32: s:=s+'g';
   33: s:=s+'h';
   34: s:=s+'i';
   35: s:=s+'j';
   36: s:=s+'k';
   37: s:=s+'l';
   38: s:=s+'m';
   39: s:=s+'n';
   40: s:=s+'o';
   41: s:=s+'p';
   42: s:=s+'q';
   43: s:=s+'r';
   44: s:=s+'s';
   45: s:=s+'t';
   46: s:=s+'u';
   47: s:=s+'v';
   48: s:=s+'w';
   49: s:=s+'x';
   50: s:=s+'y';
   51: s:=s+'z';
   52: s:=s+'#';
   53: s:=s+'$';
   54: s:=s+'%';
   55: s:=s+'0';
   56: s:=s+'1';
   57: s:=s+'2';
   58: s:=s+'3';
   59: s:=s+'4';
   60: s:=s+'5';
   61: s:=s+'6';
   62: s:=s+'7';
   63: s:=s+'8';
   64: s:=s+'9';
  end; {case .end.}

 end; {for i:= .end.}

 {return result}
 crypt:=s;

end; {crypt *end*}

Function file_exist(file_name: string): boolean;
var
 f: text;
 b: boolean;
begin;

 assign(f,file_name);
 {$I-} reset(f); {$I+}
 if ioresult<>0 then b:=false else b:=true;
 if b then close(f);

 {return result}
 file_exist:=b;

end; {file_exist *end*}

Function MkString(nr:integer;const s:string) : string;
var
    i : integer;
    temp : string;
begin

 temp:='';

 for i:=1 to nr do begin
  temp:=temp+s;
 end;

 {return result}
 mkstring:=temp;

end; {mkstring *end*}



Function GetChar : char;
begin
 getchar:=readkey;
end;

function CommaStr(Number: LongInt): String;
var
 StrPos: Integer;
 NumberStr: String;

begin
 NumberStr := Long2Str(Number);
 StrPos := Length(NumberStr) - 2;
 While StrPos > 1 do begin
  Insert(',',NumberStr,StrPos);
  StrPos := StrPos - 3;
 end;
 CommaStr := NumberStr;
end; {commastr *end*}

Procedure SD(nr:byte;s:string);
begin
 textcolor(nr);
 write(s);
end;

Procedure D(nr:byte;s:string);
begin
 textcolor(nr);
 writeln(s);
end;

Function Str_To_Nr(const s:string) : longint;
var y : integer;
    i : longint;
begin

 val(s,i,y);

 if y<>0 then begin
  str_to_nr:=0;
 end
 else begin
  str_to_nr:=i;
 end;

end; {str_to_nr *end*}

Procedure Upper4(var Str: String);
InLine(
 $8C/$DA/               {      mov   DX,DS               }
 $5E/                   {      pop   SI                  }
 $1F/                   {      pop   DS                  }
 $FC/                   {      cld                       }
 $AC/                   {      lodsb                     }
 $30/$E4/               {      xor   AH,AH               }
 $89/$C1/               {      mov   CX,AX               }
 $E3/$12/               {      jcxz  @30                 }
 $BB/Ord('a')/Ord('z')/ {      mov   BX,'za'             }
 $AC/                   { @15: lodsb                     }
 $38/$D8/               {      cmp   AL,BL               }
 $72/$08/               {      jb    @28                 }
 $38/$F8/               {      cmp   AL,BH               }
 $77/$04/               {      ja    @28                 }
 $80/$6C/$FF/$20/       {      sub   BYTE PTR [SI-1],$20 }
 $E2/$F1/               { @28: loop  @15                 }
 $8E/$DA);              { @30: mov   DS,DX               }

Function UpCaseStr(s : string ) : string;
begin
 upper4(s);
 UpcaseStr:=s;
end;

Function Get_String : string;
var tempstring : string;
begin
 tempstring:='';
 readln(tempstring);
 get_String:=tempstring;
end;

Function Get_Number(amin,amax:longint) : longint;
var result : longint;
    str : string;
  done : boolean;
begin

 result:=0;
 done:=false;
 repeat
  readln(str);

  result:=str_to_nr(str);
  if( result>=amin) and (result<=amax) then begin
   done:=true;
  end
  else begin
   d(15,'Try again ('+commastr(amin)+'..'+commastr(amax)+')');
   sd(2,':');
  end;

 until done;

 {return result}
 get_number:=result;

end; {get_number *end*}

Procedure Unable_to_Access(const s:s70);
begin
 {displayed when file access is denied}
 d(error_col,error_mes+'Denied ACCESS : '+s);
end;

Procedure Unable_to_FileSize(const s:s70);
begin
 {displayed when filesize function fails}
 d(error_col,error_mes+'Unable to get FILESIZE of : '+s);
end;

Procedure Unable_to_Delete(const s:s70);
begin
 {displayed when file can't be deleted}
 d(error_col,error_mes+'Unable to DELETE : '+s);
end;

Procedure Unable_to_Close(const s:s70);
begin
 {displayed when unable to close file}
 d(error_col,error_mes+'Unable to CLOSE : '+s);
end;

Procedure Unable_to_Write(const s:s70);
begin
 {displayed when unable to write to file}
 d(error_col,error_mes+'Unable to WRITE : '+s);
end;

Procedure Unable_to_Seek(const s:s70;recnr:word);
begin
 {displayed when unable to seek in file, record RECNR}
 d(error_col,error_mes+'Unable to SEEK RECORD:'+commastr(recnr)+' in : '+s);
end;

Procedure Unable_to_Read(const s:s70);
begin
 {displayed when unable to read from file}
 d(error_col,error_mes+'Unable to READ : '+s);
end;

Procedure Unable_to_Create(const s:s70);
begin
 {displayed when unable to create file}
 d(error_col,error_mes+'Unable to CREATE : '+s);
end;

Procedure Unable_to_Rename(const s1,s2:s70);
begin
 {displayed when rename procedure fails}
 d(error_col,error_mes+'Unable to RENAME "'+s1+'" to "'+s2+'"');
end;

Procedure Rename_File(const s1,s2:string);
var f : file;
begin

 sd(10,'Renaming '+s1+' to '+s2+' ');

 assign(f,s1);
 {$I-}rename(f,s2);{$I+}
 if IOResult<>0 then begin
  unable_to_rename(s1,s2);
 end
 else begin
  d(14,'Done.');
 end;

end; {rename_file *end*}

Procedure Move_File(filen:String;dest:string);
var f :file;
begin

 sd(10,'Moving ');
 sd(FileColor,filen);
 sd(10,' to ');
 sd(FileColor,dest+' ');

 if file_exist(filen)=false then begin
  d(15,'FILE NOT FOUND.');
 end
 else begin
  dest:=dest+filen;
  assign(f,filen);
  {$I-} rename(f,dest); {$I+}
  if IOResult<>0 then begin
   d(15,'ERROR!');
  end
  else begin
   d(14,'DONE');
  end;
 end;

end; {move_file *end*}

Procedure CleanString(Var s:String);
begin
 fillChar(s,sizeof(s),0);
end;

Function EmptyStr : string;
var s : string;
begin
 cleanstring(s);
 emptystr:=s;
end;

procedure crlf;
begin
 writeln('');
end;

procedure clearscreen;
begin
 clrscr;
end;


Function Confirm( const text: string;
                  def : char) : boolean;
var cho : char;
begin

 def:=upcase(def);

 if def='Y' then begin
  confirm:=true;
  write(text+' ? ([Y]/N)');
 end
 else if def='N' then begin
  confirm:=false;
  write(text+' ? (Y/[N])');
 end
 else begin
  def:='N';
  confirm:=false;
  write(text+' ? (Y/[N])');
 end;

 repeat
  cho:=upcase(readkey);
 until cho in ['Y','N',chr(13)];

 if (cho=chr(13)) and (def='Y') then cho:='Y';
 if (cho=chr(13)) and (def='N') then cho:='N';

 case cho of
  'Y':begin
      confirm:=true;
      d(2,' Yes');
      end;
  'N':begin
      confirm:=false;
      d(2,' No');
      end;
 end; {case .end.}

 crlf;

end; {confirm *end*}

Procedure Pause;
var a : char;
begin

 write('*Press a key*');

 a:=readkey;
 crlf;

end; {pause *end*}


Procedure display_color_options;
begin
 d(2,'Choose from: Black, Blue, Green, Cyan, Red, Magenta,');
 d(2,'Brown, LightGray, DarkGray, LightBlue, LightGreen,');
 d(2,'LightCyan, LightRed, LightMagenta, Yellow, White');
end; {display_color_options *end*}


Function delete_file(const fn: string) : boolean;
var
 f: file;
begin;

 assign(f,fn);
 {$I-} erase(f); {$I+}
 if ioresult=0 then begin
  delete_file:=true
 end
 else begin
  unable_to_delete(fn);
  delete_file:=false;
 end;

end; {delete_file *end*}

     {Main Program Starts Here}
var

    i,j,k : longint;

    ok,
    wrong,
    go_ahead,
    go_ahead53 : boolean;

    s : string;

    Option197
    : string[40]; {Items stored at home, 0-300 .. default is 10}
    Option198  {Bank Robbery Attempts / Day}
    : string[40];


procedure ask_all_the_questions;
var x : word;
begin

 ok:=true;

 if ok then begin

  if file_exist(ucfg) then begin
   crlf;
   s:='New/Changed Editor Option(s) for this Version';
   d(5,s);
   d(5,mkstring(length(s),underscore));


    {Editor #197}
   d(7,'Option 197.');
   d(2,'Store Items at Home, How many: (0-300, default is 10)');
   sd(2,':');
   x:=get_number(0,300);
   Option197:=commastr(x);



   {Editor #198}
   d(7,'Option 198.');
   d(2,'How many Bank Robbery attempts: player / day (0-60000, default is 3)');
   sd(2,':');
   x:=get_number(0,60000);
   Option198:=commastr(x);


   {update text}
   sd(2,'Updating ');
   sd(filecolor,ucfg);
   sd(2,' to ');
   sd(NewVersionColor,NewVersion);
   sd(2,' format...');

   {insert #198 as a new/replacing options}
   assign(NewText,'TEMP.CFG');
   assign(OldText,ucfg);

   rewrite(NewText);
   reset(OldText);

   i:=1;
   while not eof(OldText) do begin

    go_ahead:=true;
    go_ahead53:=true;


    if i=197 then begin

       {insert new option 197 for 0.20e}
       writeln(NewText,Option197);

    end;


    if i=198 then begin

       {insert new option 198 for 0.20e}
       writeln(NewText,Option198);

    end;



    readln(OldText,s);

    if (go_ahead=true) and (go_ahead53=true) then begin
     writeln(NewText,s);
    end;

    inc(i);

   end; {while .end.}


   {Close and Rename}
   close(NewText);
   close(OldText);

   delete_file(ucfg);
   rename(NewText,ucfg);

   d(15,' DONE.');
  end;
 end;
 {Updating Config File *END*}

end;

procedure convert_children;
var x : word;
begin
 {converting CHILDREN.DAT}
 if not file_exist(childfile) then begin
  sd(filecolor,childfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,childfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewChildrenFile,childfiletemp);
  assign(OldChildrenFile,childfile);

  {$I-}reset(OldChildrenFile);{$I+}
  if IOResult<>0 then unable_to_access(childfile);

  {$I-}rewrite(NewChildrenFile);{$I+}
  if IOResult<>0 then unable_to_create(childfiletemp);

  {$I-}close(NewChildrenFile);{$I+}
  if IOResult<>0 then unable_to_close(childfiletemp);

  {$I-}reset(NewChildrenFile);{$I+}
  if IOResult<>0 then unable_to_access(childfiletemp);

  {$I-}seek(NewChildrenFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(childfiletemp,1);

  {$I-}x:=filesize(OldChildrenFile);{$I+}
  if IOResult<>0 then unable_to_filesize(childfile);

  for i:=1 to x do begin

   {$I-}read(OldChildrenFile,OldChild);{$I+}
   if IOResult<>0 then unable_to_read(childfile);

   NewChild.name   :=OldChild.name; {name}
   NewChild.sex    :=OldChild.sex; {sex, 1=male, 2=female}
   NewChild.age    :=OldChild.age; {age}
   NewChild.birth  :=todays_date; {date of birth}

   NewChild.recnr  :=OldChild.recnr; {record #, position in file}
   NewChild.ageplus:=OldChild.ageplus; {how soon before getting one year older}
   NewChild.bastard:=OldChild.bastard; {set to true if product of secret lay or whore intercourse}
   NewChild.named  :=OldChild.named; {has kid been named yet? if not it's not accessible in lists etc}
   NewChild.deleted:=OldChild.deleted; {is this record deleted}

   NewChild.mother :=OldChild.mother;  {mother to the child}
   NewChild.father :=OldChild.father;  {father to the child}

   NewChild.motherid :=OldChild.motherid; {unique mother ID - to match userrec ID}
   NewChild.fatherid :=OldChild.fatherid; {unique father ID - to match userrec ID}

   NewChild.motherai :=OldChild.motherai; {mother ai}
   NewChild.fatherai :=OldChild.fatherai; {father ai}

   NewChild.motherrace :=OldChild.motherrace; {important info so we can evaluate what the child is!}
   NewChild.fatherrace :=OldChild.fatherrace; {important info so we can evaluate what the child is!}

   NewChild.motheraccess := OldChild.motheraccess; {does the mother have access to the kid}
   NewChild.fatheraccess := OldChild.fatheraccess; {does the father have access to the kid}

   NewChild.soul     :=OldChild.soul; {-500 .. +500, -500=pure evil, +500=angel heart}
   NewChild.health   :=OldChild.health; {see CMS.PAS for ChildHealth_XX constants}
   NewChild.location :=OldChild.location; {see CMS.PAS for Childlocation_XX constants}
   NewChild.kidnapper:=OldChild.kidnapper; {name of kidnapper}
   NewChild.kidnapperid:=OldChild.kidnapperid;
   NewChild.ransom_demanded:=OldChild.ransom_demanded;
   NewChild.cursed_by_god:=OldChild.cursed_by_god; {name of god who cursed}
   NewChild.cursed_by_godID:=OldChild.cursed_by_godId; {god unique id}

   NewChild.orgmother:=OldChild.mother; {name of original mother}
   NewChild.orgfather:=OldChild.father; {name of original father}
   NewChild.orgmotherid:=OldChild.motherid; {original mother ID - to match userrec ID}
   NewChild.orgfatherid:=OldChild.fatherid; {original father ID - to match userrec ID}
   NewChild.orgmotherai:=OldChild.motherai; {original mother ai}
   NewChild.orgfatherai:=OldChild.fatherai; {original father ai}
   NewChild.orgmotherrace:=OldChild.motherrace; {original mother race}
   NewChild.orgfatherrace:=OldChild.fatherrace; {original father race}
   NewChild.royal:=OldChild.royal; {is child of royal blood}

   {$I-}write(NewChildrenFile,NewChild);{$I+}
   If IOResult<>0 then unable_to_write(childfiletemp);

  end; {for i:= .end.}

  {$I-}close(OldChildrenFile);{$I+}
  if IOResult<>0 then unable_to_close(childfile);

  {$I-}close(NewChildrenFile);{$I+}
  if IOResult<>0 then unable_to_close(childfiletemp);

  {$I-}erase(OldChildrenFile);{$I+}
  if IOresult<>0 then unable_to_delete(childfile);

  {$I-}rename(NewChildrenFile,childfile);{$I+}
  if IOResult<>0 then unable_to_rename(childfiletemp,childfile);

  d(15,' DONE.');
  {--CHILDREN.DAT END---}
 end;

end; {convert_children .end.}

procedure Convert_Gods;
var x : word;
begin
 {converting GODS.DAT}
 if not file_exist(godfile) then begin
  sd(filecolor,godfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,godfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewGodFile,godfiletemp);
  assign(OldGodFile,godfile);

  {$I-}reset(OldGodFile);{$I+}
  if IOResult<>0 then unable_to_access(godfile);

  {$I-}rewrite(NewGodFile);{$I+}
  if IOResult<>0 then unable_to_create(godfiletemp);

  {$I-}close(NewGodFile);{$I+}
  if IOResult<>0 then unable_to_close(godfiletemp);

  {$I-}reset(NewGodFile);{$I+}
  if IOResult<>0 then unable_to_access(godfiletemp);

  {$I-}seek(NewGodFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(godfiletemp,1);

  {$I-}x:=filesize(OldGodFile);{$I+}
  if IOResult<>0 then unable_to_filesize(godfile);

  for i:=1 to x do begin

   {$I-}read(OldGodFile,OldGod);{$I+}
   if IOResult<>0 then unable_to_read(godfile);

   NewGod.realname :=OldGod.realname;  {real (user/bbs) name}
   NewGod.name     :=OldGod.name;      {alias}
   NewGod.id       :=OldGod.id;      {unique ID tag, this id follows the player from the user file!}
   NewGod.recnr    :=OldGod.recnr;      {rec # in file}
   NewGod.age      :=OldGod.age;     {age}
   NewGod.sex      :=OldGod.sex;      {sex, 1=male, 2=female}
   NewGod.ai       :=OldGod.ai;      {ai: 'H'uman or 'C'omputer }
   NewGod.level    :=OldGod.level;      {level}
   NewGod.exp      :=OldGod.exp;   {experience}
   NewGod.deleted  :=OldGod.deleted; {deleted}
   NewGod.believers:=OldGod.believers;    {believers, disciples, # of players who worship this god}
   NewGod.darkness :=OldGod.darkness; {good points, follows from the player time}
   NewGod.goodness :=OldGod.goodness; {dark points, follows from the player time}
   NewGod.deedsleft:=5;

   {$I-}write(NewGodFile,NewGod);{$I+}
   If IOResult<>0 then unable_to_write(godfiletemp);

  end; {for i:= .end.}

  {$I-}close(OldGodFile);{$I+}
  if IOResult<>0 then unable_to_close(godfile);

  {$I-}close(NewGodFile);{$I+}
  if IOResult<>0 then unable_to_close(godfiletemp);

  {$I-}erase(OldGodFile);{$I+}
  if IOresult<>0 then unable_to_delete(godfile);

  {$I-}rename(NewGodFile,godfile);{$I+}
  if IOResult<>0 then unable_to_rename(godfiletemp,godfile);

  d(15,' DONE.');
  {--GODS.DAT END---}
 end;

end; {convert_gods .end.}

var x : word;
Begin {Main Program ***START***}

 ClearScreen;

 crlf;

 {Opening Menu}
 s:=mkstring(51,UnderScore);
 d(13,s);
 sd(5,' Usurper Upgrader, version ');
 sd(OldVersionColor,OldVersion);
 sd(5,'  to  ');
 d(NewVersionColor,NewVersion);
 d(13,s);
 crlf;

 d(10,'This program will Update the following files :');
 d(filecolor,' '+pfile);
 d(filecolor,' '+npfile);

 {
 d(filecolor,' '+kingfile);
 d(filecolor,' '+mailfile);
 d(filecolor,' '+questfile);
 d(filecolor,' '+drinkfile);
 d(filecolor,' '+marketfile);
 d(filecolor,' '+wantedfile);
 d(filecolor,' '+ucfg);
 }

 crlf;
 crlf;

 d(12,'You should backup your Usurper game (all files) before proceeding.');
 d(2,'');

 {Go Ahead with Conversion?}
 if confirm('Go ahead with Conversion','N')=false then begin
  crlf;
  d(12,'Aborted.');
  halt;
 end;

 clearscreen;
 crlf;


 ok:=true;
 wrong:=false;
 {converting USERS.DAT + NPCS.DAT}
 if ok then begin

  for i:=1 to 2 do begin

   wrong:=false;
   case i of
    1:begin {user file}
       if not file_exist(pfile) then begin
        sd(filecolor,pfile);
        d(12,' not found. Skipped.');
        wrong:=true;
       end
       else begin
        sd(2,'Converting ');
        sd(filecolor,pfile);
        sd(2,' to ');
        sd(NewVersionColor,NewVersion);
        sd(2,' format...');

        assign(NewPlayerFile,pfiletemp);
        assign(OldPlayerFile,pfile);
       end;
      end;
    2:begin {npc file}
       if not file_exist(npfile) then begin
        sd(filecolor,npfile);
        d(12,' not found. Skipped.');
        wrong:=true;
       end
       else begin
        sd(2,'Converting ');
        sd(filecolor,npfile);
        sd(2,' to ');
        sd(NewVersionColor,NewVersion);
        sd(2,' format...');

        assign(NewPlayerFile,npfiletemp);
        assign(OldPlayerFile,npfile);
       end;

      end;
   end; {case .end.}


   if not wrong then begin

    {$I-}reset(OldPlayerFile);{$I+}
    if IOResult<>0 then unable_to_access('FILEX');

    {$I-}rewrite(NewPlayerFile);{$I+}
    if IOResult<>0 then unable_to_create('FILEX');

    {$I-}close(NewPlayerFile);{$I+}
    if IOResult<>0 then unable_to_close('FILEX');

    {$I-}reset(NewPlayerFile);{$I+}
    if IOResult<>0 then unable_to_access('FILEX');

    {$I-}seek(NewPlayerFile,0);{$I+}
    if IOResult<>0 then unable_to_seek('FILEX',1);


    for j:=1 to filesize(OldPlayerFile) do begin

     {$I-}read(OldPlayerFile,OldPlayer);{$I+}
     if IOResult<>0 then unable_to_read('FILEX');

     {convert}

     {skit}
     {crlf;
     d(2,oldplayer.name2);
     }

     NewPlayer.name1 :=OldPlayer.name1;
     NewPlayer.name2 :=OldPlayer.name2;
     NewPlayer.ai    :=OldPlayer.ai;
     NewPlayer.race  :=OldPlayer.race;
     NewPlayer.age   :=OldPlayer.age;
     NewPlayer.gold  :=OldPlayer.gold; {gold in hand}
     NewPlayer.hps   :=OldPlayer.hps; {hitpoints}
     NewPlayer.exp   :=OldPlayer.exp; {experience}
     NewPlayer.level :=OldPlayer.level; {level}
     NewPlayer.bankgold:=OldPlayer.bankgold; {gold in bank}
     NewPlayer.chiv  :=OldPlayer.chiv; {chivalry}
     NewPlayer.dark  :=OldPlayer.dark; {darkness}
     NewPlayer.fights:=OldPlayer.fights; {player fights}
     NewPlayer.strength:=OldPlayer.strength; {strength}
     NewPlayer.defence :=OldPlayer.defence; {defence}
     NewPlayer.healing :=OldPlayer.healing; {healing potions}
     NewPlayer.allowed  :=OldPlayer.allowed;  {allowed to play}
     NewPlayer.resurrections:=5; {new shit}
     NewPlayer.maxhps  :=OldPlayer.maxhps;  {max hitpoints}
     NewPlayer.laston  :=OldPlayer.laston;  {laston, date}
     NewPlayer.ageplus :=OldPlayer.ageplus;  {how soon before getting one year older}
     NewPlayer.darknr  :=OldPlayer.darknr;  {dark deeds left}
     NewPlayer.chivnr  :=OldPlayer.chivnr;  {good deeds left}
     NewPlayer.pfights :=OldPlayer.pfights;  {dungoen fights}
     NewPlayer.king    :=OldPlayer.king;  {king?}
     NewPlayer.location:=OldPlayer.location;  {offline location, se offloc_?? constants}
     NewPlayer.team    :=OldPlayer.team; {team name}
     NewPlayer.teampw  :=OldPlayer.teampw; {team password}
     NewPlayer.teamrec :=OldPlayer.teamrec;       {team record, how many days have we had the town}
     NewPlayer.bguard  :=OldPlayer.bguard; {type of guard, # in door guard file}
     NewPlayer.cturf   :=OldPlayer.cturf; {is team in control of town}
     NewPlayer.gnollp  :=OldPlayer.gnollp; {gnoll poison, temporary used in fights}
     NewPlayer.mental  :=OldPlayer.mental; {mental health}
     NewPlayer.addict  :=OldPlayer.addict; {drug addiction}
     NewPlayer.wellwish:=OldPlayer.wellwish; {has player visited the Wishing Well}
     NewPlayer.height  :=OldPlayer.height; {height}
     NewPlayer.weight  :=OldPlayer.weight; {weight}
     NewPlayer.eyes :=OldPlayer.eyes; {eye color}
     NewPlayer.hair :=OldPlayer.hair; {hair color}
     NewPlayer.skin :=OldPlayer.skin; {skin color}
     NewPlayer.sex  :=OldPlayer.sex; {sex, male=1 female=2}
     NewPlayer.mana :=OldPlayer.mana; {mana, spellcasters only}
     NewPlayer.maxmana :=OldPlayer.maxmana; {maxmana}
     NewPlayer.stamina :=OldPlayer.stamina; {stamina}
     NewPlayer.agility :=OldPlayer.agility;
     NewPlayer.charisma:=OldPlayer.charisma;
     NewPlayer.dex     :=OldPlayer.dex;
     NewPlayer.wisdom  :=OldPlayer.wisdom;
     NewPlayer.weappow :=OldPlayer.weappow;
     NewPlayer.armpow  :=OldPlayer.armpow;
     NewPlayer.blind   :=OldPlayer.blind; {blindhet}
     NewPlayer.plague  :=OldPlayer.plague; {pesten}
     NewPlayer.smallpox:=OldPlayer.smallpox; {smittkoppor}
     NewPlayer.measles :=OldPlayer.measles; {m„ssling}
     NewPlayer.leprosy :=OldPlayer.leprosy; {spet„lska}
     NewPlayer.mercy   :=OldPlayer.mercy;
     for k:=1 to global_maxitem do begin
      NewPlayer.item[k]    :=OldPlayer.item[k];
      NewPlayer.itemtype[k]:=OldPlayer.itemtype[k];
     end;
     for k:=1 to 6 do begin
      NewPlayer.phr[k]:=OldPlayer.phr[k];
     end;
     NewPlayer.autoheal:=OldPlayer.autoheal;
     NewPlayer.class   :=OldPlayer.class;
     NewPlayer.loyalty :=OldPlayer.loyalty;
     NewPlayer.haunt   :=OldPlayer.haunt; {how many demons are set to haunt player}
     NewPlayer.master  :=OldPlayer.master;    {level master player uses}
     NewPlayer.tfights :=OldPlayer.tfights; {team fights}
     NewPlayer.thiefs  :=OldPlayer.thiefs; {thieverys left}
     NewPlayer.brawls  :=OldPlayer.brawls; {brawls left}
     NewPlayer.assa    :=OldPlayer.assa; {assainations left}
     for k:=1 to 4 do begin
      NewPlayer.desc[k]:=OldPlayer.desc[k]; {player description}
     end;
     NewPlayer.poison  :=OldPlayer.poison; {poison, adds to weapon. used by ALCHEMISTS}
     for k:=1 to global_maxspells do begin
      NewPlayer.spell[k,1]:=OldPlayer.spell[k,1];
      NewPlayer.spell[k,2]:=OldPlayer.spell[k,2];
     end;
     for k:=1 to global_maxcombat do begin
      NewPlayer.skill[k]:=OldPlayer.skill[k];
     end;
     NewPlayer.trains  :=OldPlayer.trains; {training sessions at Close-Combat master}
     NewPlayer.lhand   :=OldPlayer.lhand; {item carried in left hand}
     NewPlayer.rhand   :=OldPlayer.rhand; {item in right hand}
     NewPlayer.head    :=OldPlayer.head; {head}
     NewPlayer.body    :=OldPlayer.body; {body}
     NewPlayer.arms    :=OldPlayer.arms; {arms}
     NewPlayer.lfinger :=OldPlayer.lfinger; {left finger}
     NewPlayer.rfinger :=OldPlayer.rfinger; {right fignger}
     NewPlayer.legs    :=OldPlayer.legs; {legs}
     NewPlayer.feet    :=OldPlayer.feet; {feet}
     NewPlayer.waist   :=OldPlayer.waist; {waist}
     NewPlayer.neck    :=OldPlayer.neck; {neck}
     NewPlayer.neck2   :=OldPlayer.neck2; {neck2}
     NewPlayer.face    :=OldPlayer.face; {face}
     NewPlayer.shield  :=OldPlayer.shield; {shield}
     NewPlayer.hands   :=OldPlayer.hands; {hands}
     NewPlayer.abody   :=OldPlayer.abody; {around body}
     NewPlayer.immortal :=OldPlayer.immortal; {if yes, never deleted for inactivity}
     NewPlayer.battlecry:=OldPlayer.battlecry;     {battle cry}
     NewPlayer.bguardnr :=OldPlayer.bguardnr; {number of doorguards, type is specified in bguard}
     NewPlayer.casted   :=OldPlayer.casted; {used as temporary flag in battles}
     NewPlayer.punch    :=OldPlayer.punch; {player punch, temporary flag in battles}
     NewPlayer.absorb   :=OldPlayer.absorb; {absorbe punch, temporary flag in battles}
     NewPlayer.used_item:=OldPlayer.used_item; {has player used an item, temporary flag in battles}
     NewPlayer.m_kills  :=OldPlayer.m_kills; {monster kills}
     NewPlayer.m_defeats:=OldPlayer.m_defeats; {monster defeats}
     NewPlayer.p_kills  :=OldPlayer.p_kills; {player kills}
     NewPlayer.p_defeats:=OldPlayer.p_defeats; {player defeats}

     {below is new for 0.08}
     NewPlayer.interest    :=OldPlayer.interest; {accumulated bank interest}
     NewPlayer.alive_bonus :=OldPlayer.alive_bonus; {accumulated staying alive bonus}
     NewPlayer.expert      :=OldPlayer.expert; {expert menus ON/OFF}
     NewPlayer.maxtime     :=OldPlayer.maxtime; {maxtime per session in game}
     NewPlayer.ear         :=OldPlayer.ear; {how should player deal with internode messages}
     NewPlayer.castin      :=OldPlayer.castin;
     NewPlayer.weapon      :=OldPlayer.weapon; {OLD mode}
     NewPlayer.armor       :=OldPlayer.armor; {OLD mode}
     NewPlayer.apow        :=OldPlayer.apow; {OLD mode}
     NewPlayer.wpow        :=OldPlayer.wpow; {OLD mode}
     NewPlayer.disres      :=OldPlayer.disres; {disease resistance}
     NewPlayer.amember     :=OldPlayer.amember; {medlem i alchemist s„llskapet}
     for k:=1 to 20 do begin
      NewPlayer.medal[k]:=OldPlayer.medal[k];
     end;
     NewPlayer.bankguard   :=OldPlayer.bankguard; {frivillig bankvakt?}
     NewPlayer.bankwage    :=OldPlayer.bankwage; {l”n fr†n banken, f”r guard duty}
     NewPlayer.weaphag     :=OldPlayer.weaphag; {ggr en spelare har hagglat i weaponshop}
     NewPlayer.armhag      :=OldPlayer.armhag; {ggr en spelare har hagglat i armorshop}
     NewPlayer.recnr       :=OldPlayer.recnr; {fil pekare, anv„nds vid sparning av spelare}
     NewPlayer.auto_meny   :=OldPlayer.auto_meny; {spelaren vill ha menyerna automatiskt utritade}

     {below is new for 0.14}
     NewPlayer.quests      :=OldPlayer.quests; {# of completed missions/quests}
     NewPlayer.deleted     :=OldPlayer.deleted;  {is this record deleted}
     NewPlayer.god         :=OldPlayer.god; {spelaren tilber GUD med detta namn}
     NewPlayer.royquests   :=OldPlayer.royquests;  {royal quests accomplished}

     {below is new for 0.17}
     NewPlayer.RoyTaxPaied:=OldPlayer.RoyTaxPaied; {royal taxes paied since player was last logged in}
     NewPlayer.Wrestlings :=OldPlayer.Wrestlings; {Uman Cave, Indian Wrestlings}
     NewPlayer.DrinksLeft :=OldPlayer.DrinksLeft; {drinks left}
     NewPlayer.DaysInPrison:=OldPlayer.DaysInPrison; {days left in prison}

     {below is real new for 0.18}
     Newplayer.UmanBearTries:=OldPlayer.UmanBearTries; {times player have tried to tame the bear}
     NewPlayer.Massage     :=OldPlayer.Massage; {times player have had massage this day}
     NewPlayer.Gym_Sessions:=OldPlayer.Gym_Sessions; {workout sessions at the gYm / day}
     NewPlayer.Gym_Owner   :=OldPlayer.Gym_Owner; {controller of the gym? has to be in a team}
     Newplayer.Gym_Card    :=OldPlayer.Gym_Card; {free card to the gym? if not gym_owner that is}
     NewPlayer.RoyQuestsToday:=OldPlayer.RoyQuestsToday; {how many royal quests have the player completed today}
     NewPlayer.KingVotePoll:=OldPlayer.KingVotePoll; {how many days since voted for king popularity}
     NewPlayer.KingLastVote:=OldPlayer.KingLastVote;  {last vote, to be used for polls}
     NewPlayer.Married     :=OldPlayer.Married; {married? only used when creating/displaying lists}
     NewPlayer.Kids        :=OldPlayer.Kids; {how many kids this player is father/mother to}
     NewPlayer.IntimacyActs:=OldPlayer.IntimacyActs; {how many acts of intimacy has player left today?}
     NewPlayer.Pregnancy   :=OldPlayer.Pregnancy; {is player pregnant? 0=no, 1...X = days pregnant}
     NewPlayer.AutoHate    :=OldPlayer.AutoHate; {auto-hate when attacked?}

     NewPlayer.ID:=OldPlayer.ID; {unique ID tag}
     NewPlayer.Tax_Relief:=OldPlayer.Tax_Relief; {free from tax?}
     NewPlayer.MarriedTimes:=OldPlayer.MarriedTimes; {counter for marriages}
     NewPlayer.Bard_Songs_Left:=OldPlayer.Bard_Songs_Left; {ehhh..quite self-explanatory huh?}

     {below is new for 0.20}
     NewPlayer.PickPocketAttempts:=OldPlayer.PickPocketAttempts; {allowed pick pocket attempts}

     {below is new for 0.20e}
     NewPlayer.BankRobberyAttempts:=3; {bank robbery attempts / day}


     {save record}
     {$I-}write(NewPlayerFile,NewPlayer);{$I-}
     if IOResult<>0 then unable_to_write('FILEX');

    end; {for j:= .end.}

    {$I-}close(OldPlayerFile);{$I+}
    if IOresult<>0 then unable_to_close('FILEX');

    {$I-}close(NewPlayerFile);{$I+}
    if IOresult<>0 then unable_to_close('FILEX');

    {$I-}erase(OldPlayerFile);{$I+}
    if IOResult<>0 then unable_to_delete('FILEX');

    case i of
     1:begin
        {$I-}rename(NewPlayerFile,pfile);{$I+} {user file}
        if IOResult<>0 then unable_to_rename(pfiletemp,pfile);
       end;
     2:begin
        {$I-}rename(NewPlayerFile,npfile);{$I+} {npc file}
        if IOResult<>0 then unable_to_rename(npfiletemp,npfile);
       end;
    end; {case .end.}

    d(15,' DONE.');
   end;

  {--END---}
  end; {for i:= .end.}

 end;


 ok:=false;
 {converting KING.DAT}
 if not file_exist(kingfile) then begin
  sd(filecolor,kingfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,kingfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewKingFile,KingFileTemp);
  assign(OldKingFile,KingFile);

  {$I-}reset(OldKingFile);{$I+}
  if IOResult<>0 then unable_to_access(kingfile);

  {$I-}rewrite(NewKingFile);{$I+}
  if IOResult<>0 then unable_to_create(KingFileTemp);

  {$I-}close(NewKingFile);{$I+}
  if IOResult<>0 then unable_to_close(KingFileTemp);

  {$I-}reset(NewKingFile);{$I+}
  if IOResult<>0 then unable_to_access(KingFileTemp);

  {$I-}seek(NewKingFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(KingFileTemp,1);

  {$I-}x:=filesize(OldKingFile);{$I+}
  if IOResult<>0 then unable_to_filesize(KingFile);

  {$I-}read(OldKingFile,OldKing);{$I+}
  if IOResult<>0 then unable_to_read(kingfile);

  NewKing.name          :=OldKing.name; {name of ruler}
  NewKing.ai            :=OldKing.ai; {ai - C or H}
  NewKing.sexy          :=OldKing.sexy; {male or female}
  NewKing.daysinpower   :=OldKing.daysinpower; {days in power}
  NewKing.tax           :=OldKing.tax; {tax level}
  NewKing.taxalignment  :=OldKing.taxalignment; {tax who? 0=all,1=only good,2=only evil}
  NewKing.treasury      :=OldKing.treasury; {money in the royal vault}
  NewKing.prisonsleft   :=OldKing.prisonsleft; {# of people king can imprison today. new every day}
  NewKing.executeleft   :=OldKing.executeleft; {# of death sentences left today. new every day}
  NewKing.questsleft    :=OldKing.questsleft; {# of new quests the king can issue today}
  NewKing.MarryActions  :=5; {NEW FOR 0.18!}
  NewKing.WolfFeed      :=0; {NEW FOR 0.18!, how many kids have been tossed to the wolves every day?}
  NewKing.RoyalAdoptions:=1; {NEW FOR 0.18!, how many kids can be placed in the Royal Orphanage every day?}
  NewKing.moatID        :=OldKing.moatID; {unique moat creature ID}
  NewKing.moatnr        :=OldKing.moatnr; {how many crocodiles (or whatever) in the moat?}
  for j:=1 to global_KingGuards do begin
   NewKing.guard[j]     :=OldKing.guard[j]; {king body guards, name}
   NewKing.guardpay[j]  :=OldKing.guardpay[j]; {king guard, salary}
   NewKing.guardai[j]   :=OldKing.guardai[j]; {king guard, AI}
   NewKing.guardsex[j]  :=OldKing.guardsex[j]; {king guard,sex}
  end; {for j:= .end.}
  NewKing.shop_weapon   :=OldKing.shop_weapon; {is weapon shop open}
  NewKing.shop_armor    :=OldKing.shop_armor; {is armor shop open}
  NewKing.shop_magic    :=OldKing.shop_magic; {is magic shop open}
  NewKing.shop_alabat   :=OldKing.shop_alabat; {is alabats shop open}
  NewKing.shop_plmarket :=OldKing.shop_plmarket; {is player market open}
  NewKing.shop_healing  :=OldKing.shop_healing; {is healing center}
  NewKing.shop_drugs    :=OldKing.shop_drugs; {is drug palace open}
  NewKing.shop_steroids :=OldKing.shop_steroids; {is steroid shop open}
  NewKing.shop_orbs     :=OldKing.shop_orbs; {is Orbs club open}
  NewKing.shop_evilmagic:=OldKing.shop_evilmagic; {is evil mage shop open}
  NewKing.shop_bobs     :=OldKing.shop_bobs; {is bobs beer open}
  NewKing.shop_whores   :=OldKing.shop_whores; {is whore house open}
  NewKing.shop_gigolos  :=OldKing.shop_gigolos; {is gigolos place open}

  {$I-}write(NewKingFile,NewKing);{$I+}
  If IOResult<>0 then unable_to_write(KingFileTemp);

  {$I-}close(OldKingFile);{$I+}
  if IOResult<>0 then unable_to_close(kingfile);

  {$I-}close(NewKingFile);{$I+}
  if IOResult<>0 then unable_to_close(KingFileTemp);

  {$I-}erase(OldKingFile);{$I+}
  if IOresult<>0 then unable_to_delete(KingFile);

  {$I-}rename(NewKingFile,KingFile);{$I+}
  if IOResult<>0 then unable_to_rename(KingFileTemp,KingFile);

  d(15,' DONE.');
  {--KING.DAT END---}
 end;

 ok:=false;
 {converting MAIL.DAT}
 if not file_exist(mailfile) then begin
  sd(filecolor,mailfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,mailfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewMailFile,mailfiletemp);
  assign(OldMailFile,mailfile);

  {$I-}reset(OldMailFile);{$I+}
  if IOResult<>0 then unable_to_access(mailfile);

  {$I-}rewrite(NewMailFile);{$I+}
  if IOResult<>0 then unable_to_create(mailfiletemp);

  {$I-}close(NewMailFile);{$I+}
  if IOResult<>0 then unable_to_close(mailfiletemp);

  {$I-}reset(NewMailFile);{$I+}
  if IOResult<>0 then unable_to_access(mailfiletemp);

  {$I-}seek(NewMailFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(mailfiletemp,1);

  {$I-}x:=filesize(OldMailFile);{$I+}
  if IOResult<>0 then unable_to_filesize(mailfile);

  for i:=1 to x do begin

   {$I-}read(OldMailFile,OldMail);{$I+}
   if IOResult<>0 then unable_to_read(mailfile);

   NewMail.receiver := OldMail.receiver; {destination <player.name2>}
   NewMail.recgod   := false; {new for 0.18}
   NewMail.date     := update_sixdate(OldMail.date); {mail was created this date MONTH,DAY,YEAR 00-00-00}
   NewMail.readflag := OldMail.readflag; {has this mail record been read/processed}
   NewMail.sender   := OldMail.sender; {who sent this mail <player.name2>}
   NewMail.sendgod  := false; {new for 0.18}
   NewMail.special  := OldMail.Special; {special request, see mailrequest_nothingXX constants}

   for j:=1 to global_maxmaillines do begin
    NewMail.Mess[j]:=OldMail.Mess[j]; {message text}
   end; {for j:= .end.}

   {$I-}write(NewMailFile,NewMail);{$I+}
   If IOResult<>0 then unable_to_write(mailfiletemp);

  end; {for i:= .end.}

  {$I-}close(OldMailFile);{$I+}
  if IOResult<>0 then unable_to_close(mailfile);

  {$I-}close(NewMailFile);{$I+}
  if IOResult<>0 then unable_to_close(mailfiletemp);

  {$I-}erase(OldMailFile);{$I+}
  if IOresult<>0 then unable_to_delete(mailfile);

  {$I-}rename(NewMailFile,mailfile);{$I+}
  if IOResult<>0 then unable_to_rename(mailfiletemp,mailfile);

  d(15,' DONE.');
  {--MAIL.DAT END---}
 end;


 ok:=false;
 {converting RQUESTS.DAT}
 if not file_exist(questfile) then begin
  sd(filecolor,questfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,questfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewQuestFile,questfiletemp);
  assign(OldQuestFile,questfile);

  {$I-}reset(OldQuestFile);{$I+}
  if IOResult<>0 then unable_to_access(questfile);

  {$I-}rewrite(NewQuestFile);{$I+}
  if IOResult<>0 then unable_to_create(questfiletemp);

  {$I-}close(NewQuestFile);{$I+}
  if IOResult<>0 then unable_to_close(questfiletemp);

  {$I-}reset(NewQuestFile);{$I+}
  if IOResult<>0 then unable_to_access(questfiletemp);

  {$I-}seek(NewQuestFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(questfiletemp,1);

  {$I-}x:=filesize(OldQuestFile);{$I+}
  if IOResult<>0 then unable_to_filesize(questfile);

  for i:=1 to x do begin

   {$I-}read(OldQuestFile,OldQuest);{$I+}
   if IOResult<>0 then unable_to_read(questfile);

   NewQuest.id         := OldQuest.id;
   NewQuest.initiator  := OldQuest.initiator;
   NewQuest.date       := update_sixdate(OldQuest.date);
   NewQuest.QuestType  := OldQuest.QuestType;
   NewQuest.QuestTarget:= OldQuest.QuestTarget;
   NewQuest.difficulty := OldQuest.difficulty;
   NewQuest.deleted    := OldQuest.deleted;
   NewQuest.comment    := OldQuest.comment;
   NewQuest.occupier   := OldQuest.occupier;
   NewQuest.occrace    := OldQuest.occrace;
   NewQuest.occsex     := OldQuest.occsex;
   NewQuest.occdays    := OldQuest.occdays;
   NewQuest.daystocomple:= OldQuest.daystocomple;
   NewQuest.offerto     := OldQuest.offerto;
   NewQuest.offerrefused:= OldQuest.offerrefused;
   NewQuest.forced      := OldQuest.forced;
   NewQuest.minlevel    := OldQuest.minlevel;
   NewQuest.maxlevel    := OldQuest.maxlevel;
   NewQuest.reward      := OldQuest.reward;
   NewQuest.rewardtype  := OldQuest.rewardtype;
   NewQuest.penalty     := OldQuest.penalty;
   NewQuest.penaltytype := OldQuest.penaltytype;
   for j:=1 to global_maxmon do begin
    NewQuest.monsters[j,1]:= OldQuest.monsters[j,1];
    NewQuest.monsters[j,2]:= OldQuest.monsters[j,2];
   end; {for j:= .end.}

   {$I-}write(NewQuestFile,NewQuest);{$I+}
   If IOResult<>0 then unable_to_write(questfiletemp);

  end; {for i:= .end.}

  {$I-}close(OldQuestFile);{$I+}
  if IOResult<>0 then unable_to_close(questfile);

  {$I-}close(NewQuestFile);{$I+}
  if IOResult<>0 then unable_to_close(questfiletemp);

  {$I-}erase(OldQuestFile);{$I+}
  if IOresult<>0 then unable_to_delete(questfile);

  {$I-}rename(NewQuestFile,questfile);{$I+}
  if IOResult<>0 then unable_to_rename(questfiletemp,questfile);

  d(15,' DONE.');
  {--RQUESTS.DAT END---}
 end;


 ok:=false;
 {converting DRINKS.DAT}
 if not file_exist(drinkfile) then begin
  sd(filecolor,drinkfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,drinkfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewDrinkFile,drinkfiletemp);
  assign(OldDrinkFile,drinkfile);

  {$I-}reset(OldDrinkFile);{$I+}
  if IOResult<>0 then unable_to_access(drinkfile);

  {$I-}rewrite(NewDrinkFile);{$I+}
  if IOResult<>0 then unable_to_create(drinkfiletemp);

  {$I-}close(NewDrinkFile);{$I+}
  if IOResult<>0 then unable_to_close(drinkfiletemp);

  {$I-}reset(NewDrinkFile);{$I+}
  if IOResult<>0 then unable_to_access(drinkfiletemp);

  {$I-}seek(NewDrinkFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(drinkfiletemp,1);

  {$I-}x:=filesize(OldDrinkFile);{$I+}
  if IOResult<>0 then unable_to_filesize(drinkfile);

  for i:=1 to x do begin

   {$I-}read(OldDrinkFile,OldDrink);{$I+}
   if IOResult<>0 then unable_to_read(drinkfile);

   NewDrink.name   := OldDrink.name;
   NewDrink.creator:= OldDrink.creator;
   NewDrink.date   := update_sixdate(olddrink.date);
   NewDrink.comment:= OldDrink.comment; {comment by creator}
   NewDrink.ordered:= OldDrink.ordered; {how many times have the drink been used/drank}
   NewDrink.lasthad:= OldDrink.lasthad; {last customer that had this drink}
   NewDrink.lastrac:= OldDrink.lastrac; {last customers race}
   NewDrink.lastdat:= todays_date; {drink was last had this date}
   NewDrink.deleted:= OldDrink.deleted; {deleted?}
   NewDrink.secret := OldDrink.secret; {secret recipe? creators choice}
   for j:=1 to 17 do begin
    NewDrink.amount[j]:=OldDrink.amount[j];
   end;

   {$I-}write(NewDrinkFile,NewDrink);{$I+}
   If IOResult<>0 then unable_to_write(drinkfiletemp);

  end; {for i:= .end.}

  {$I-}close(OldDrinkFile);{$I+}
  if IOResult<>0 then unable_to_close(drinkfile);

  {$I-}close(NewDrinkFile);{$I+}
  if IOResult<>0 then unable_to_close(drinkfiletemp);

  {$I-}erase(OldDrinkFile);{$I+}
  if IOresult<>0 then unable_to_delete(drinkfile);

  {$I-}rename(NewDrinkFile,drinkfile);{$I+}
  if IOResult<>0 then unable_to_rename(drinkfiletemp,drinkfile);

  d(15,' DONE.');
  {--DRINKS.DAT END---}
 end;


 ok:=false;
 {converting PLMARKET.DAT}
 if not file_exist(marketfile) then begin
  sd(filecolor,marketfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,marketfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewMarketFile,Marketfiletemp);
  assign(OldMarketFile,Marketfile);

  {$I-}reset(OldMarketFile);{$I+}
  if IOResult<>0 then unable_to_access(marketfile);

  {$I-}rewrite(NewMarketFile);{$I+}
  if IOResult<>0 then unable_to_create(marketfiletemp);

  {$I-}close(NewMarketFile);{$I+}
  if IOResult<>0 then unable_to_close(marketfiletemp);

  {$I-}reset(NewMarketFile);{$I+}
  if IOResult<>0 then unable_to_access(marketfiletemp);

  {$I-}seek(NewMarketFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(MarketFileTemp,1);

  {$I-}x:=filesize(OldMarketFile);{$I+}
  if IOResult<>0 then unable_to_filesize(Marketfile);

  for i:=1 to x do begin

   {$I-}read(OldMarketFile,OldMarket);{$I+}
   if IOResult<>0 then unable_to_read(marketfile);

   NewMarket.pekare := OldMarket.pekare;
   NewMarket.ityp   := OldMarket.ityp;
   NewMarket.seller := OldMarket.seller;
   NewMarket.date   := update_sixdate(OldMarket.date);
   NewMarket.price  := OldMarket.price;
   NewMarket.target := OldMarket.target;
   NewMarket.team   := OldMarket.team;
   NewMarket.comment:= OldMarket.comment;
   NewMarket.sold   := OldMarket.sold;

   {$I-}write(NewMarketFile,NewMarket);{$I+}
   If IOResult<>0 then unable_to_write(MarketFiletemp);

  end; {for i:= .end.}

  {$I-}close(OldMarketFile);{$I+}
  if IOResult<>0 then unable_to_close(marketfile);

  {$I-}close(NewMarketFile);{$I+}
  if IOResult<>0 then unable_to_close(MarketFileTemp);

  {$I-}erase(OldMarketFile);{$I+}
  if IOresult<>0 then unable_to_delete(MarketFile);

  {$I-}rename(NewMarketFile,MarketFile);{$I+}
  if IOResult<>0 then unable_to_rename(MarketFileTemp,MarketFile);

  d(15,' DONE.');
  {--PLMARKET.DAT END---}
 end;


 ok:=false;
 {converting WANTED.DAT}
 if not file_exist(wantedfile) then begin
  sd(filecolor,wantedfile);
  d(12,' not found. Skipped.');
 end
 else if ok then begin
  sd(2,'Converting ');
  sd(filecolor,wantedfile);
  sd(2,' to ');
  sd(NewVersionColor,NewVersion);
  sd(2,' format...');

  assign(NewWantedFile,WantedFileTemp);
  assign(OldWantedFile,WantedFile);

  {$I-}reset(OldWantedFile);{$I+}
  if IOResult<>0 then unable_to_access(WantedFile);

  {$I-}rewrite(NewWantedFile);{$I+}
  if IOResult<>0 then unable_to_create(WantedFileTemp);

  {$I-}close(NewWantedFile);{$I+}
  if IOResult<>0 then unable_to_close(WantedFileTemp);

  {$I-}reset(NewWantedFile);{$I+}
  if IOResult<>0 then unable_to_access(WantedFileTemp);

  {$I-}seek(NewWantedFile,0);{$I+}
  if IOResult<>0 then unable_to_seek(WantedFileTemp,1);

  {$I-}x:=filesize(OldWantedFile);{$I+}
  if IOResult<>0 then unable_to_filesize(WantedFile);

  for i:=1 to x do begin

   {$I-}read(OldWantedFile,OldWanted);{$I+}
   if IOResult<>0 then unable_to_read(WantedFile);

   NewWanted.name  :=OldWanted.name;       {who is wanted?}
   NewWanted.level :=OldWanted.level;      {the wanteds level}
   NewWanted.date  := update_sixdate(OldWanted.date);
   NewWanted.mad   :=OldWanted.mad;       {person who created the poster}
   NewWanted.gold  :=OldWanted.gold;   {gold reward}
   NewWanted.collected:=OldWanted.collected;   {has the reward been collected?}
   NewWanted.elig     :=OldWanted.elig;      {vem kan collecta rewarden? A=all,C=npcs,H=players}
   NewWanted.ai1      :=OldWanted.ai1;      {posters creator AI npC / Human}
   NewWanted.ai2      :=OldWanted.ai2;      {wanted persons  AI npC / Human}
   NewWanted.anonym   :=OldWanted.anonym;   {is the creator of the poster anonymous?}

   {$I-}write(NewWantedFile,NewWanted);{$I+}
   If IOResult<>0 then unable_to_write(WantedFileTemp);

  end; {for i:= .end.}

  {$I-}close(OldWantedFile);{$I+}
  if IOResult<>0 then unable_to_close(WantedFile);

  {$I-}close(NewWantedFile);{$I+}
  if IOResult<>0 then unable_to_close(WantedFileTemp);

  {$I-}erase(OldWantedFile);{$I+}
  if IOresult<>0 then unable_to_delete(WantedFile);

  {$I-}rename(NewWantedFile,WantedFile);{$I+}
  if IOResult<>0 then unable_to_rename(WantedFileTemp,WantedFile);

  d(15,' DONE.');
  {--WANTED.DAT END---}
 end;

 {convert_children}
 {skit!}
{ ok:=true;
 convert_children;

 {convert gods}
 {skit!}
{ ok:=false;
 convert_gods;

 {Updating USURPER.CFG (ufg) with new config options}
 ask_all_the_questions;

 if wrong then begin

  crlf;
  crlf;
  d(15,'Something went wrong! Replace your backup and repeat the process.');
  d(15,'Read the update docs carefully before attempting to run this program.');
  d(15,'You might be trying to upgrade an too old version of Usurper.');
  crlf;

 end
 else begin
  crlf;
  crlf;
  d(15,'***************************************************');
  d(14,'DONE!');
  sd(2,'You should view the file ');
  sd(filecolor,'README!');
  d(2,', before doing anything else.');
  crlf;
  crlf;
  d(15,'If you plan to allow the NPCs to marry and have kids then you');
  d(15,'should reset the NPC data file through the editor.exe program.');
  d(15,'You should do this because otherwise there will be a shortage of female');
  d(15,'NPC''s (Unless you create the females manually).');
  crlf;
  crlf;
 end;

 pause;

end. {Convert .end.}
ÿ