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


Unit Init; {Usurper Editor - Structures, Init code, procs & functs}

Interface

Uses App, Restore, ShadMenu,
     Objects, Drivers, Views,
     Dialogs, Menus, Xboxes;

const

 {set to true when Turbo Vision application is running, used by error
  msgs routines}
 vision_is_running : boolean = false;

 {Editor Version}
 uver      = '0.23f';
 uversion  = 'Usurper Editor '+uver;
 ubeta : boolean = false; {is this a BETA version?}

 {number of options in USURPER.CFG}
 {see cfgdef.pas for help regarding adding/editing/removing config options}
 global_maxcdef = 198;

 {text displayed when not registered}
 onlyin  = 'Only Available In Registered Version!';

 {Directories}
{$IFNDEF LINUX}
 DIRECTORY_SEPARATOR = '\';
{$ENDIF}
{$IFDEF LINUX}
 DIRECTORY_SEPARATOR = '/';
{$ENDIF}
 global_datadir ='DATA' + DIRECTORY_SEPARATOR;   {Path to DATA directory}
 global_docsdir ='DOCS' + DIRECTORY_SEPARATOR;   {Path to DOCS directory}
 global_nodedir ='NODE' + DIRECTORY_SEPARATOR;   {Path to NODE files}
 global_scoredir='SCORES' + DIRECTORY_SEPARATOR; {Path to SCORE and NEWS files}

 {file with all online help-texts. raw-file : edhelp.txt.
 to compile raw helpfile, type: tvhc edhelp editor edhelp
  or better: run makehelp.bat file}
{$IFDEF MSDOS}
 global_edhelp = 'EDITOR.HLP';
{$ENDIF}
{$IFNDEF MSDOS}
 global_edhelp = 'EDITOR32.HLP';
{$ENDIF}

 {Files in the Usurper directory}
 ucfg = 'USURPER.CFG';
 scfg = 'SAMPLE.CFG';

 {files in DATADIR}
 global_pfile      = global_datadir+'USERS.DAT';
 global_npfile     = global_datadir+'NPCS.DAT';
 truthfile1 = global_datadir+'TRUTH.ANS';
 truthfile2 = global_datadir+'TRUTH.ASC';
 marketfile = global_datadir+'PLMARKET.DAT';
 chestfile  = global_datadir+'CHEST.DAT';
 innfile1   = global_datadir+'COMMENTS.ANS';
 innfile2   = global_datadir+'COMMENTS.ASC';
 datefile   = global_datadir+'DATE.DAT';
 monfile    = global_datadir+'MONSTER.DAT';
 gufile     = global_datadir+'GUARDS.DAT'; {door-guards}
 motfile    = global_datadir+'MOATMON.DAT'; {moat creatures, protects the Castle}
 lvlfile    = global_datadir+'LEVELS.DAT';
 mafile     = global_datadir+'MAIL.DAT';

 wwfile     = global_datadir+'WANTED.DAT';
 armofile   = global_datadir+'ARMOR.DAT';
 weapofile  = global_datadir+'WEAPON.DAT';
 teamrecordf= global_datadir+'TEAMREC.DAT';
 teamrecfile= global_datadir+'TRECORD.DAT';
 godsf      = global_datadir+'GODS.DAT'; {immortals}
 indianfile = global_datadir+'INDIAN.DAT';
 drinkfile  = global_datadir+'DRINKS.DAT'; {the orbs bar, customers own drinks}
 tnamesf    = global_datadir+'TNAMES.DAT'; {team names used by npc gangs, ASCII}
 kingfile   = global_datadir+'KING.DAT';   {king orders, should be removed when Game is reset}
 rquestf    = global_datadir+'RQUESTS.DAT'; {royal quests}
 relationf  = global_datadir+'RELATION.DAT'; {social relations between players}
 childrenf  = global_datadir+'CHILDREN.DAT'; {children database}
 barrelf    = global_datadir+'BARRELS.DAT'; {beer barrel lifters top X list}
 childmalef  =global_datadir+'CHILDMAL.DAT'; {children, male names *used by npcs*}
 childfemalef=global_datadir+'CHILDFEM.DAT';{children, female names *used by npcs*}
 bardsongf  = global_datadir+'BARDSONG.DAT'; {bard song file *confirm deletion*}
 VersionF   = global_datadir+'VERSION.DAT'; {stores version number for data files, used by UPGRADE.PAS}

 {news files}
 nwfileans  = global_scoredir+'NEWS.ANS';
 nwfileasc  = global_scoredir+'NEWS.ASC';
 ynwfileans = global_scoredir+'YNEWS.ANS';
 ynwfileasc = global_scoredir+'YNEWS.ASC';

 {list of monarchs, comings and goings}
 MonarchsANSI = global_scoredir+'MONARCHS.ANS';
 MonarchsASCI = global_scoredir+'MONARCHS.ASC';

 {list of gods, comings and goings}
 GodsANSI = global_scoredir+'GODS.ANS';
 GodsASCI = global_scoredir+'GODS.ASC';

 {list of child-births}
 ChildBirthHistANSI = global_scoredir+'BIRTHIST.ANS';
 ChildBirthHistASCI = global_scoredir+'BIRTHIST.ASC';


 {list of marriages}
 MarrHistANSI = global_scoredir+'MARRHIST.ANS';
 MarrHistASCI = global_scoredir+'MARRHIST.ASC';


 {item files, used in NEW mode}
 objf1 = global_datadir+'OBJDAT01.DAT';
 objf2 = global_datadir+'OBJDAT02.DAT';
 objf3 = global_datadir+'OBJDAT03.DAT';
 objf4 = global_datadir+'OBJDAT04.DAT';
 objf5 = global_datadir+'OBJDAT05.DAT';
 objf6 = global_datadir+'OBJDAT06.DAT';
 objf7 = global_datadir+'OBJDAT07.DAT';
 objf8 = global_datadir+'OBJDAT08.DAT';
 objf9 = global_datadir+'OBJDAT09.DAT';
 objf10= global_datadir+'OBJDAT10.DAT';
 objf11= global_datadir+'OBJDAT11.DAT';
 objf12= global_datadir+'OBJDAT12.DAT';
 objf13= global_datadir+'OBJDAT13.DAT';
 objf14= global_datadir+'OBJDAT14.DAT';
 objf15= global_datadir+'OBJDAT15.DAT';

 {doc files}
 whatsnewfile = global_docsdir+'WHATS.NEW';
 sysopdoc     = global_docsdir+'SYSOP.DOC';
 usurperdoc   = global_docsdir+'USURPER.DOC';
 readmefile   = global_docsdir+'README!';
 futuredoc    = global_docsdir+'FUTURE.DOC';
 supportdoc   = global_docsdir+'SUPPORT.DOC';


 {to mark characters as ERASED}
 delname1='EMPTY';
 delname2='EMPTY';

 Global_Max_Drink_Ingredients = 17; {max ingredients in a drink (ORBS)}
 maxmspells    = 6; {max # of monster spells}
 maxitem       =15; {how many items in inventory}
 maxspells     =12; {number of spells for spellcasters}
 maxclasses    =11; {number of player classes}
 maxcombskills =14; {close combat skills}
 maxallows     =15; {toggles active ALLOW items.
                     Should head items be used... and so on...}
var
 allowitem : array[1..maxallows] of boolean;

{$IFDEF MSDOS}
type
  SmallInt  = System.Integer;
  SmallWord = System.Word;
{$ENDIF}

type ItemHandler = (Item_Add,Item_Remove); {useb by itemhandler in ADDIT.pas}

{Date Type, used by ALL record type DATE definitions in the game (usually defined in record structures)}
type UDate = string[8];

type {Character Classes}
 Classes = (Alchemist,
            Assassin,
            Barbarian,
            Bard,
            Cleric,
            Jester,
            Magician,
            Paladin,
            Ranger,
            Sage,
            Warrior);

type {Character Races}
 Races = (Human,
          Hobbit,
          Elf,
          HalfElf,
          Dwarf,
          Troll,
          Orc,
          Gnome,
          Gnoll,
          Mutant);

     {String types}
type s15 = string[15];
type s30 = string[30];
type s70 = string[70];
type s90 = string[90];

type {Cures for diseases}
 cures = (Nothing, All, Blindness, Plague, Smallpox, Measles, Leprosy);

type {Item types}
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


type {Classic Armor record}
 ArmRec = record
  name    : string[30];
  val  : longint;
  pow  : longint;
 end;

type {Classic Weapon}
 WeapRec = record
  name  : string[30];
  value : longint;
  pow   : longint;
 end;

type  {Orbs Bar Special Drink, made by Player => saved to drinkfile}
 DrinkRec = record
  name   : s30; {the drink}
  creator: s30; {creator}
  date   : string[8]; {when was the drink created}
  comment: s70;     {comment}
  ordered: longint; {how many times have the drink been used/drank}
  lasthad: s30; {last customer that has the drink}
  lastrac: races;  {last customers race}
  lastdat: string[8]; {when was drink last ordered}
  deleted: boolean; {deleted?}
  secret : boolean; {secret recipe? creators choice}
  amount : array[1..17] of SmallInt; {ingredients}
 end;

type {item record}
 ObjektRec = record
  name : string[70];   {objektets namn}
  ttype: objtype;      {typ av objekt}
  value : longint;     {v„rdet p† objektet}
  hps  : SmallInt;      {ska objekt ”ka hps}
  stamina : SmallInt;   {               stamina}
  agility : SmallInt;   {               agility}
  charisma : SmallInt;  {               charisma}
  dex : SmallInt; {               dexterity}
  wisdom : SmallInt;    {               wisdom}
  mana   : SmallInt;    {               mana}
  armor : SmallInt;     {ska objekt ”ka armor v„rdet}
  attack : SmallInt;    {ska objekt ”ka attack v„rdet}
  owned  : string[70]; {„gd av}
  onlyone: boolean;    {bara finnas ett objekt ?}
  cure   : cures;      {kan objektet hela?}
  shop   : boolean;    {finnas i shoppen}
  dng    : boolean;    {kunna hittas i dungeons?}
  cursed : boolean;    {cursed item?}
  minlev : SmallInt;    {min level att hittas i dngs}
  maxlev : SmallInt;    {max level att hittas i dngs}
  desc1 : array [1..5] of string[70]; {normal beskriving}
  desc2 : array [1..5] of string[70]; {detaljerad beskriving}
  strength : SmallInt;
  defence : SmallInt;
  str_need : SmallInt;
  good : boolean;
  evil : boolean;
  restrict : array[1..maxclasses] of boolean;
 end;

type {god}
 GodRec = Record {God record}
  realname : s30;  {real (user/bbs) name}
  name : s30;      {alias}
  id   : s15;      {unique ID tag, this id follows the player from the
                    user file!}
  recnr: SmallWord;      {rec # in file}
  age  : SmallWord;      {age}
  sex  : byte;      {sex, 1=male, 2=female}
  ai   : char;      {ai: 'H'uman or 'C'omputer }
  level: SmallWord;      {level}
  exp  : longint;   {experience, power}
  deedsleft : SmallWord; {deedsleft today, new ones given at maintenance}
  deleted  : boolean; {deleted}
  believers: SmallWord;    {believers, disciples, # of players who worship this god}
  darkness : longint; {good points, follows from the player time}
  goodness : longint; {dark points, follows from the player time}
 end; {godrec *end*}

 ChildRec = Record {kids produced by players/npc, not necessarily married
                    couples. remember that a divorce will split the kids}
  name    : s30;  {name}
  sex     : byte; {sex, 1=male, 2=female}
  age     : SmallWord; {age}
  birth   : udate; {date of birth}
  recnr   : SmallWord; {record #, position in file}
  ageplus : SmallWord; {how soon before getting one year older}
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

  soul     : SmallInt; {-500 .. 0 .. +500,  -500=pure evil, +500=angel heart}
  health   : byte; {see CMS.PAS for ChildHealth_XX constants}
  location : byte; {see CMS.PAS for ChildLocation_XX constants}
  kidnapper: s30; {name of kidnapper}
  kidnapperid : s15; {kidnapper id}
  ransom_demanded : longint; {gold demanded for the release of child}
  cursed_by_god  : s30; {name of god who cursed}
  cursed_by_godID: s15; {god unique id}
  royal : byte; {royal blood? 0=no, 1=half, 2=full}
  {cursed_typeof:byte; {type of curse: 1=age, 2=mental, 3=?}

 end;


 {You must change NPC.pas when something changes in UserRec}
type {Player & Npc structures}
 UserRec = record
  Name1 : string[30];
  name2 : string[30];
  ai    : char;
  race  : races;
  age   : SmallInt;
  gold : longint;
  hps   : longint;
  exp   : longint;
  level : longint;
  bankgold  : longint;
  chiv  : longint;
  dark  : longint;
  fights: SmallInt;
  strength : longint;
  defence  : longint;
  healing  : longint;
  allowed  : boolean;
  maxhps : longint;
  laston : longint; {dialog?}
  ageplus: SmallInt;
  darknr : SmallInt;
  chivnr : SmallInt;
  pfights: SmallInt;
  king   : boolean; {dialog?}
  loc : SmallInt;
  team  : string[25];
  teampw : string[20];
  teamrec : SmallWord;
  bguard : SmallInt;
  cturf : boolean;
  gnollp : SmallInt;
  mental : SmallInt;
  addict : SmallInt;
  wellwish : boolean; {dialog?}
 height : SmallInt;
 weight : SmallInt;
 eyes : SmallInt;
 hair : SmallInt;
 skin : SmallInt;
  sex  : SmallInt;
  mana : longint;
  maxmana : longint;
  stamina : longint;
  agility : longint;
  charisma : longint;
  dex : longint;
  wisdom : longint;
  weap : longint;  {weaponpower va hmm, vad?}
  arm : longint;   {hmm, vad?}
  blind       : boolean; {blindhet}
  plague      : boolean; {pesten}
  smallpox    : boolean; {smittkoppor}
  measles     : boolean; {m„ssling}
  leprosy     : boolean; {spet„lska}
  mercy       : SmallInt;
  item        : array[1..maxitem] of SmallInt;
  itemtype    : array[1..maxitem] of objtype;
  phr         : array[1..6] of string[70];
   {1. what to say when being attacked
   2. what to say when you have defeated somebody
   3. what to say when you have been defeated
   4. what to say when you are begging for mercy
   5. what to say when you spare opponents life
   6. what to say when you don't spare opponents life}
  autoheal    : boolean;
  class       : classes;
  loyalty     : SmallInt;
  haunt       : SmallInt;
  master      : char;
  tfights     : SmallInt;
  thiefs      : SmallInt;
  brawls      : SmallInt;
  assa        : SmallInt;
  desc        : array[1..4] of string[70];
  poison      : SmallInt;
  spell       : array[1..maxspells,1..2] of boolean;
  skill       : array[1..maxcombskills] of SmallInt;
  trains      : SmallInt;
  lhand       : SmallWord;
  rhand       : SmallWord;
  head        : SmallWord;
  body        : SmallWord;
  arms        : SmallWord;
  lfinger     : SmallWord;
  rfinger     : SmallWord;
  legs        : SmallWord;
  feet        : SmallWord;
  waist       : SmallWord;
  neck        : SmallWord;
  neck2       : SmallWord;
  face        : SmallWord;
  shield      : SmallWord;
  hands       : SmallWord;
  abody       : SmallWord;
  immortal    : boolean; {dialog?}
  battlecry   : string[70];
  bguardnr    : SmallInt; {antal doorguards, typ specificeras i bguard}
  casted      : boolean; {anv„nds som flagga under battles}
  punch       : longint;
  absorb      : longint;
  used_item   : boolean;
  m_kills     : longint;
  m_defeats   : longint;
  p_kills     : longint;
  p_defeats   : longint;
  interest    : longint;
  alive_bonus : longint;
  expert      : boolean;
  maxtime     : SmallInt;
  ear         : byte;
  castin      : char;
  weapon      : SmallWord; {OLD mode}
  armor       : SmallWord; {OLD mode}
  apow        : SmallWord; {OLD mode}
  wpow        : SmallWord; {OLD mode}
  disres      : byte;
  amember     : boolean;
  medal       : array[1..20] of boolean;
  bankguard   : boolean;
  bankwage    : longint;
  weaphag     : byte; {ggr en spelare har hagglat i weaponshop}
  armhag      : byte; {ggr en spelare har hagglat i armorshop}
  recnr       : SmallWord;
  auto_meny   : boolean;
  {new for 0.14}
  quests      : SmallInt; {# of comleted quests/missions}
  deleted     : boolean; {is this record deleted}
  god         : string[30];
  royquests   : longint;  {royal quests accomplished}

  {new for 0.17}
  RoyTaxPaied : longint; {royal taxes paied since player was last logged in}
  Wrestlings  : byte; {Indian Wrestlings matches left in Uman Caves, reset every maint}
  DrinksLeft  : byte; {Drinks left today, at Orbs}
  DaysInPrison: byte; {days left in prison}

  {below is new for 0.18}
  UmanBearTries : byte; {times player have tried to tame the bear}
  Massage       : byte; {times player have had massage this day}
  Gym_Sessions  : byte; {gym sessions(workout) left today}
  Gym_Owner     : byte; {controller of the gym? has to be in a team}
  Gym_Card      : byte; {free card to the gym? if not gym_owner that is}
  RoyQuestsToday: SmallWord;{how many royal quests have the player completed today}
  KingVotePoll: byte; {how many days since voted for king popularity}
  KingLastVote: byte; {last vote, to be used for polls}

  Married     : boolean; {is player married? only used in score list creation}
  Kids        : SmallWord; {how many kids this playeer is father/mother to}
  IntimacyActs: SmallWord; {how many acts of intimacy has player left today?}
  Pregnancy   : byte; {is player pregnant? 0=no, 1...X = days pregnant}
  FatherID    : s15;  {fathers id tag, set when pregnancy starts}

  AutoHate    : byte; {automatically worsen relation with a person that
                      attacks you? (0=no 1=one step worse)}
  ID          : s15; {unique ID tag, to keep players in touch with relations
                      and children. without thios new players with the same
                      name as a deceased father will inherit a the old guys
                      children. relations.id correspond to playe.id}
  Tax_Relief : boolean; {free from tax?}
  MarriedTimes : SmallWord; {counter for marriages}
  Bard_Songs_Left: SmallWord; {ehhh..quite self-explanatory huh?}
  prison_escapes : byte; {allowed prison escape attempts}
  Filtyp : byte; {type of file player resides in (1=player file, 2=npc file)}
  Resurrections: SmallWord; {# of resurrections left today}

  {below is new for 0.20}
  PickPocketAttempts : SmallWord; {allowed pick pocket attempts}

  {below is new for 0.20e}
  BankRobberyAttempts : SmallWord; {bank robbery attempts / day}


end;

type {Monster structure}
 MonsterRec = record
  name : string[30];
  weapnr : longint;
  armnr  : longint;
  grabweap : boolean;  {kan vapnet er”vras?}
  grabarm  : boolean;  {kan armor er”vras?}
  phrase : string[70]; {intro fras fr†n monstret}
  magicres : SmallInt;
  strength : longint;
  defence  : SmallInt;
  wuser : boolean;
  auser : boolean;
  hps : longint;
  punch : longint;
  poisoned : boolean;
  weapon : string[40];
  armor : string[40];
  disease : boolean;
  target : SmallInt;
  weappow : longint;
  armpow : longint;
  iq     : SmallInt;
  evil   : SmallInt;
  magiclevel : byte;
  mana    : SmallInt;
  maxmana : SmallInt;
  spell  : array[1..maxmspells] of boolean;
 end;

type {doorguard structure}
 GuardRec = record
  name  : string[50];
  cost  : longint;
  hps   : longint;
  multiple : boolean;
  barmor : longint;
  battack : longint;
  descp : array [1..5] of string[70];
 end;

type {moat creatures definition}
 MoatRec = record
  name : s30;
  id   : s15; {unique Id tag,}
  cost : longint;
  hps  : longint;
  deleted : boolean;
  barmor  : longint;
  battack : longint;
  descp : array [1..5] of s70;
 end;

type {level limits}
 LevelRec = record
  xpneed : longint;
 end;


var

 {which data files should be reset}
 resf1,resf2,resf3,resf4,resf5,resf6,resf7,resf8,resf9 : boolean;

 global_humans : boolean; {controls wheater the player-file should be assigned to npc/human file}
 Classic :boolean; {NEW or OLD gamemode}

 global_masterx, global_mastery : byte; {used by statbar/progress bar}

 registered : integer; {game registered}

 currp : word; {used by player/npc editor. points to #st player}
 currd : word; {used by drink editor. points to #st drink}
 currg : word; {used by doorguard editor. points to #st guarden}
 currm : word; {used by monster editor. points to #st monstret}
 curri : word; {used by item editor. points to #st itemet}
 currmoat:word;{used by moat editor. points to #st moat creature}
 currgod:word; {used by god editor. points to #st god}
 currchild:word; {used by child editor. points #st child}

 depend:boolean; {anv„nds av item editorn f”r att ange om players/npcs beh”ver}
                 {modifieras efter „ndring av item}

 add_fake : boolean; {when set to TRUE nothing is written to datafiles, it
                      only counts posts. Statbar uses this}
 totobj  : longint; {total number of objects, the calc is done in main}
 counter : longint;

 Player, Player0 : UserRec;
 objekt,memobj : objektrec;

 global_type : objtype;

 Monster : MonsterRec;
 Guard   : GuardRec;
 Moat    : MoatRec;
 God     : GodRec;
 Child   : Childrec;
 Level   : LevelRec;
 Global_Drink : DrinkRec;

 Playerfile         : file of UserRec;    {** User file **}
 Monsterfile        : file of MonsterRec; {** Monster file **}
 Guardfile, dummyg  : file of GuardRec;   {** DoorGuard file **}
 MoatFile           : file of MoatRec;    {** Moat Creatures **}
 GodFile            : file of GodRec;     {** Gods **}
 ChildFile          : file of ChildRec;   {** Children **}
 Levelfile          : file of LevelRec;   {** Level Limits file **}
 Cocktailfile       : file of DrinkRec;   {** User Drink file}
 Objektfil          : file of ObjektRec;  {** Object file **}

var
  cfgvalue : array[1..global_maxcdef] of string[70];
  cfgback  : array[1..global_maxcdef] of string[70]; {backup till cfgvalue}
  cfgurb   : array[1..global_maxcdef] of string[70]; {urbackup till cfgvalue}

  ofil : file of objektrec;
  cfgchang : boolean; {global setting that keeps track if .cfg has changed}

{Transfer Types, used when editor dialogs are converted to RECORD types}
{REENOTE These should not use SmallWord or SmallInt, or VP's TV clone will break
         They're only used in memory, so no binary compatibility problems}
type
 EditRec2 = Record     {RECORD used in PLAYER/NPC DIALOG}
                       {communicating with PLAYER REC, dialog page2}
  spell : array [1..maxspells] of word;
  desc : array[1..4] of s70;
  immortal : word; {never delete character}
  blind    : word; {blindhet}
  plague   : word; {plague}
  smallpox : word; {smittkoppor}
  measles  : word; {measles}
  leprosy  : word; {leprosy}

  maxtime : longint; {time left today (in minutes) }

  skill : array[1..maxcombskills] of longint;

  m_kills,
  m_defeats,
  p_kills,
  p_defeats : longint;

 end;

type
 EditRec = Record     {RECORD being used in PLAYER/NPC DIALOGUE}
  name  : string[30]; {communicating with PLAYER REC}
  alias : string[30];
  gold : longint;
  bankgold : longint;
  exp   : longint;
  healing:longint;
  fights: longint;
  pfights:longint;
  tfights:longint;
  team   : string[25];
  teampw : string[20];
  {battlecry:string[70]; moved this entry to phrases dialog box}
  mental : longint;
  addict : longint;
  thiefs : longint;
  brawls : longint;
  trains : longint;

  race  : integer;
  human : integer;
  sex   : integer;
  king  :integer; {gurka}
  allowed:integer;
  class : integer;

  level : longint;
  hps   : longint;
  maxhps: longint;
  age   : longint;
  chiv  : longint;
  dark  : longint;
  strength : longint;
  defence  : longint;
  darknr   : longint;
  chivnr   : longint;
  mana     : longint;
  maxmana  : longint;
  stamina  : longint;
  agility  : longint;
  charisma : longint;
  dex      : longint;
  wisdom   : longint;
 end;

type
 EditRecG = Record     {RECORD SOM ANVŽNDS I DOORGUARD DIALOGEN}
                       {kommunicerar med GUARD RECORD}
  name  : string[50];
  cost  : longint;
  hps   : longint;
  barmor: longint;
  battack: longint;
  descp : array [1..5] of string[70];
  multi : integer;
 end;

type
 EditRecChild = Record {RECORD used in communication between
                       Child DIALOGUE and Child RECORD}
  name : s30;
  mother  : s30;
  father  : s30;
  deleted : integer;
 end;

type
 EditRecGod = Record {RECORD used in communication between
                       GOD DIALOGUE and GOD RECORD}
  realname : s30;
  name  : s30;
  deleted : integer;
 end;

type
 EditRecMoat = Record {RECORD used in communication between
                       MOAT DIALOGUE and MOAT RECORD}
  name  : s30;
  cost  : longint;
  hps   : longint;
  barmor: longint;
  battack: longint;
  descp : array [1..5] of string[70];
  multi : integer;
 end;

type
 EditRecDrink = Record     {RECORD BEING USED IN DRINK DIALOG}
                       {communicating with GLOBAL_DRINK RECORD}
  name    : s30;
  creator : s30;
  date    : string[10];
  comment : s70;
  ordered : longint;
  lasthad : s30;
  lastdat : string[10];
  secret  : integer; {secret recipe}
  deleted : integer;
 end;

 EditRecPhrase = Record     {RECORD USED IN PHRASE EDITOR}
  battle_cry : s70;
  phrase : array[1..6] of s70;
 end;

type
 EditRecM = Record     {RECORD SOM ANVŽNDS I MONSTER EDITOR DIALOGEN}
                       {kommunicerar med MONSTER RECORD}
  name : string[30];
  hps : longint;
  phrase : string[70]; {intro fras fr†n monstret}
  magicres : longint;
  magiclevel: longint;
  strength : longint;
  defence  : longint;
 { wuser : boolean;
  auser : boolean;  n”dv„ndigt?}
 { punch : longint;
 { poisoned : boolean;}
 { weapon : string[40];
  armor  : string[40]; n”dv„ndigt?}
  {disease : boolean;}
  {target : integer;}
  {weappow : longint;
  armpow : longint; }
  iq     : longint;
  evil   : longint;
  grabweap : integer;  {kan vapnet er”vras?}
  grabarm  : integer;  {kan armor er”vras?}
  spell    : array[1..maxmspells] of integer; {spells}

 end;

type
 EditRecI = Record     {RECORD SOM ANVŽNDS I ITEM EDITOR DIALOGEN}
                       {kommunicerar med OBJEKT RECORD}
  name  : string[70];
  value : longint;
  attack: longint;
  armor : longint;
  desc1 : array[1..5] of string[70];
  desc2 : array[1..5] of string[70];

  shop  : integer;
  dng   : integer;

  minlev : longint;
  maxlev : longint;

  hps      : longint;
  stamina  : longint;
  agility  : longint;
  charisma : longint;
  dex      : longint;
  wisdom   : longint;
  mana     : longint;
  strength : longint;
  defence  : longint;
  str_need : longint;
  cure  : integer;
  good  : integer;
  evil  : integer;
  cursed: integer;

 end;

type GimDataRec = record
      nam : longint;
     end;

var EdGuy2   : EditRec2;
var EdGuy    : EditRec;
var EdGuard  : EditRecG;
var EdMoat   : EditRecMoat;
var EdGod    : EditRecGod;
var EdChild  : EditRecChild;
var EditDrink  : EditRecDrink;
var EditPhrase : EditRecPhrase;
var EdMonster: EditRecM;
var EdItem   : EditRecI;
var GimVData : GimDataRec;

Type
           {Main Object}
  TMyApp = Object(TApplication)
           constructor Init;
           procedure   HandleEvent(var Event: TEvent); virtual;
           procedure   GetEvent(var Event: TEvent); virtual;
           Function    GetPalette : ppalette; virtual;
           procedure   InitStatusLine; virtual;
           procedure OutOfMemory; virtual;
           procedure ToggleVideoMode;
  end;

var
   MyApp : TmyApp;

Type

  TMyStatusLine = object(TStatusLine)
    function Hint(AHelpCtx: Word): String; virtual;
  end;
  MyStatusLineP = ^TMyStatusLine;

  RListBox = Object(TlistBox) {Used for Configuring Usurper.cfg}
    procedure HandleEvent(var Event:TEvent); virtual;
    Procedure Process;
  End;
  ListBoxP = ^RListBox;

  EListBox = Object(TlistBox) {Used for item selections}
    procedure   HandleEvent(var Event:TEvent); virtual;
    Procedure   Process(typ : objtype);
  End;
  EQListBoxP = ^EListBox;

  CListBox = Object(TlistBox) {Used at Classic WEAPONS & ARMOR selections}
    procedure   HandleEvent(var Event:TEvent); virtual;
    Procedure   Process(vapen : boolean);
  End;
  ClassicListBoxP = ^CListBox;

  LListBox = Object(TlistBox) {Used by Level Editor}
    procedure HandleEvent(var Event:TEvent); virtual;
    Procedure Process;
  End;
  LevelListBoxP = ^LListBox;

  {---Top menu----------------------}
  TopDialog = Object(XDialog)
               Procedure HandleEvent(var Event:TEvent); virtual;
               Function  Valid(Command: Word): Boolean; virtual;

              end;
  TopDialogP = ^TopDialog;
  {--end----------------------}

  {---ViewText dialog----------------------}
  ViewTextDialog = Object(XDialog)
               Procedure   HandleEvent(var Event:TEvent); virtual;
              end;
  ViewTextDialogP = ^ViewTextDialog;
  {--end----------------------}

  {---Options dialog----------------------}
  OptionsDialog = Object(XDialog)
               Procedure   HandleEvent(var Event:TEvent); virtual;
              end;
  OptionsDialogP = ^OptionsDialog;
  {--end----------------------}

  {---More Editors dialog----------------------}
  MoreEditorsDialog = Object(XDialog)
               Procedure   HandleEvent(var Event:TEvent); virtual;
              end;
  MoreEditorsDialogP = ^MoreEditorsDialog;
  {--end----------------------}

  {---Global Monster Commands dialog----------------------}
  GlobalMonsterDialog = Object(XDialog)
               Procedure   HandleEvent(var Event:TEvent); virtual;
              end;
  GlobalMonsterDialogP = ^GlobalMonsterDialog;
  {--end----------------------}

  {---checking dependencies dialog-----------------}
  DependDialog = Object(XDialog)
               rand : word;
               pryl : objektrec;
               doneit : boolean;
               Constructor Init(var bounds:trect; MyTitle:ttitlestr;ra:word;pry:objektrec);
               Procedure   HandleEvent(var Event:TEvent); virtual;
              end;
  DependDialogP = ^DependDialog;
  {--end----------------------}

  {---Config editor-------------------}
  ConfigDialog = Object(Xdialog)
    Destructor  Done; Virtual;
    Procedure   HandleEvent(var Event: TEvent); Virtual;
  End;
  ConfigDialogP = ^ConfigDialog;
  {--end-------------------------}

  {---Level Editor editor-------------------}
  LevelDialog = Object(Xdialog)
    Destructor  Done; Virtual;
    Procedure   HandleEvent(var Event: TEvent); Virtual;
  End;
  LevelDialogP = ^LevelDialog;
  {--end-------------------------}

  {---Item File Operations dialog-------------------}
  IFODialog = Object(Xdialog)
                sniper : objtype;
                Constructor Init(var bounds:trect; MyTitle:ttitlestr;typo:objtype);
    Procedure   HandleEvent(var Event: TEvent); Virtual;
  End;
  IFODialogP = ^IFODialog;
  {--end-------------------------}

  {---Item Class Restrictions dialog-------------------}
  IREDialog = Object(Xdialog)
                Constructor Init(var bounds:trect; MyTitle:ttitlestr);
    Procedure   HandleEvent(var Event: TEvent); Virtual;
  End;
  IREDialogP = ^IREDialog;
  {--end-------------------------}


  {---Gimme Value:longint dialog-------------------}
  GimmeValDialog = Object(Xdialog)
   Function    Valid(Command: Word): Boolean; virtual;
   Procedure   HandleEvent(var Event: TEvent); Virtual;
  End;
  GimmeValDialogP = ^GimmeValDialog;
  {--end-------------------------}

  {---reset files dialog------------}
  ResDialog = Object(XDialog)
               doneit : boolean;
               game : boolean;
               Constructor Init(var bounds:trect; MyTitle:ttitlestr;gmode:boolean);
               Procedure   HandleEvent(var Event: TEvent); Virtual;
              end;
  ResDialogP = ^ResDialog;
  {--end----------------------}

  {---pick item dialog------------}
  ItemPickDialog = Object(XDialog)
                    sniper : objtype;
                    left   : boolean;
                    Destructor  Done; Virtual;
                    Constructor Init(var bounds:trect; MyTitle:ttitlestr;typo:objtype;which:boolean);
                    Procedure HandleEvent(var Event: TEvent); Virtual;
                   end;
  ItemPickDialogP = ^ItemPickDialog;
  {--end----------------------}

  {---pick item2 (general ITEM selector) dialog------------}
  ItemPickDialog2 = Object(XDialog)
                     sniper : objtype;
                     invx   : byte;
                     Destructor  Done; Virtual;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr;typo:objtype;invnr:byte);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                    end;
  ItemPickDialog2P = ^ItemPickDialog2;
  {--end----------------------}

  {---pick monster item dialog------------}
  ItemPickMDialog = Object(XDialog)
                    sniper : objtype;
                    Destructor  Done; Virtual;
                    Constructor Init(var bounds:trect; MyTitle:ttitlestr;typo:objtype);
                    Procedure HandleEvent(var Event: TEvent); Virtual;
                   end;
  ItemPickMDialogP = ^ItemPickMDialog;
  {--end----------------------}

  {---(pick Classic Weapon) dialog------------}
  ClassicPickDialog = Object(XDialog)
                      kanon : boolean;
                     Destructor  Done; Virtual;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr;vapen:boolean);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                    end;
  ClassicPickDialogP = ^ClassicPickDialog;
  {--end----------------------}

  {---search for player, dialog------------}
  TypSelDialog = Object(XDialog)
                  Procedure   HandleEvent(var Event: TEvent); Virtual;
                 end;
  TypSelDialogP = ^TypSelDialog;
  {--end----------------------}

  {---equipment for player, dialog------------}
  EqDialog = Object(XDialog)
              ps : array[1..16] of PStaticText;
              psArm, PsWeap : PstaticText;
              Constructor Init(var bounds:trect; MyTitle:ttitlestr);
              Procedure   HandleEvent(var Event: TEvent); Virtual;
             end;
  EqDialogP = ^EqDialog;
  {--end----------------------}

  {---CLASSIC equipment for player, dialog------------}
  EqClDialog = Object(XDialog)
              ps : array[1..2] of PStaticText;
              psArm, PsWeap : PstaticText;
              Constructor Init(var bounds:trect; MyTitle:ttitlestr);
              Procedure   HandleEvent(var Event: TEvent); Virtual;
             end;
  EqClDialogP = ^EqClDialog;
  {--end----------------------}


  {---inventory dialog player, dialog------------}
  InvDialog = Object(XDialog)
              ps : array[1..maxitem] of PStaticText;
              Constructor Init(var bounds:trect; MyTitle:ttitlestr);
              Procedure  HandleEvent(var Event: TEvent); Virtual;
             end;
  InvDialogP = ^InvDialog;
  {--end----------------------}

  {---player editor, page 1/2, dialog------------}
  PeditDialog = Object(XDialog)
                 ps : PStaticText;
                 delbutt : PButton;
                 hampus : byte;
                 Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                 Procedure   HandleEvent(var Event: TEvent); Virtual;
                 Function    Valid(Command: Word): Boolean; virtual;
                end;
  PeditDialogP = ^PeditDialog;
  {--end-----------------------}

  {---player editor, page2/2, dialog------------}
  Page2Dialog = Object(XDialog)
                 Procedure HandleEvent(var Event: TEvent); Virtual;
                 Function  Valid(Command: Word): Boolean; virtual;
                end;
  Page2DialogP = ^Page2Dialog;
  {--end-----------------------}

  {---doorguard editor, dialog------------}
  DoorGuardDialog = Object(XDialog)
                     ps : PStaticText;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                     Function  Valid(Command: Word): Boolean; virtual;
                    end;
  DoorGuardDialogP = ^DoorGuardDialog;
  {--end-----------------------}

 {---moat editor, dialog------------}
  MoatDialog = Object(XDialog)
                ps : PStaticText;
                Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                Procedure HandleEvent(var Event: TEvent); Virtual;
                Function  Valid(Command: Word): Boolean; virtual;
               end;
  MoatDialogP = ^MoatDialog;
  {--end-----------------------}

  {---god editor, dialog------------}
  GodDialog = Object(XDialog)
                ps : PStaticText;
                Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                Procedure HandleEvent(var Event: TEvent); Virtual;
                Function  Valid(Command: Word): Boolean; virtual;
               end;
  GodDialogP = ^GodDialog;
  {--end-----------------------}

  {---child editor, dialog------------}
  ChildDialog = Object(XDialog)
                ps : PStaticText;
                Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                Procedure HandleEvent(var Event: TEvent); Virtual;
                Function  Valid(Command: Word): Boolean; virtual;
               end;
  ChildDialogP = ^ChildDialog;
  {--end-----------------------}

  {---phrase editor, dialog------------}
  PhraseDialog = Object(XDialog)
                     ps : PStaticText;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                     Function  Valid(Command: Word): Boolean; virtual;
                    end;
  PhraseDialogP = ^PhraseDialog;
  {--end-----------------------}

  {---drink editor, dialog------------}
  DrinkDialog = Object(XDialog)
                     ps : PStaticText;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                     Function  Valid(Command: Word): Boolean; virtual;
                    end;
  DrinkDialogP = ^DrinkDialog;
  {--end-----------------------}

  {---monster editor, dialog------------}
  MonsterDialog = Object(XDialog)
                 ps : PStaticText;
                 psArm, PsWeap : PstaticText;
                 Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                 Procedure HandleEvent(var Event: TEvent); Virtual;
                 Function  Valid(Command: Word): Boolean; virtual;
                end;
  MonsterDialogP = ^MonsterDialog;
  {--end-----------------------}

  {---item editor, dialog------------}
  ItemEditDialog = Object(XDialog)
                     item : objektrec;
                     ps : PStaticText;
                     Constructor Init(var bounds:trect; MyTitle:ttitlestr);
                     Procedure HandleEvent(var Event: TEvent); Virtual;
                     Function  Valid(Command: Word): Boolean; virtual;
                    end;
  ItemEditDialogP = ^ItemEditDialog;
  {--end-----------------------}

Var {a bunch of Lists}
  NameList: PstringCollection;
  Plist   : ^Rlistbox;
  EqList  : ^Elistbox;
  ClList  : ^ClistBox;
  LevList : ^LListBox;

var
    Pupp  : ResDialogP; {must be global for STATBAR to able to call it.
                         statbar is a lousy solution :( But I haven't bothered
                         to remedy it}

Implementation

Uses Crt, Dos, Addit,
     Clasdis2, msgbox, muffi2,
     guardres, moatres, npc,
     resettn, extra, jakobe,
     file_io, helpfile, cms,
     cfgdef,

     levres, mon_arm,
     edweap01,
     edarmor,
     eweapon,
     eddrink,
     edrings,
     edshield,
     edbody,
     edhead,
     edneck,
     edarms,
     edhands,
     edwaist,
     edfeets,
     edabody,
     edlegs,
     edfood,
     edmonst,
     edface;


Function TMyStatusLine.Hint(AHelpCtx: Word): String; {Hint Texts - Displayed at bottom of Screen}
const
     c = 'Class : ';
     d = 'Disease : ';
     m = 'Combat : ';
     r = 'Race  : ';
     s = 'Spell : ';
 cancure = 'Item can cure various diseases';
begin


  case AHelpCtx of
    hcMainHelp       : Hint:= 'Usurper Editor Help';
    hcAdios          : Hint:= 'Exit';
    hcConfig         : Hint:= 'Configure Usurper';
    hcAbout          : Hint:= 'The Editor';
    hcPlayerEditor   : Hint:= 'Player Editor';
    hcItemEditor     : Hint:= 'Item Editor';
    hcMonsterEditor  : Hint:= 'Monster Editor';
    hcDoorGuardEditor: Hint:= 'Door Guard Editor';
    hcLevelEditor    : Hint:= 'Level Editor';
    hcGodEditor      : Hint:= 'God Editor';
    hcChildEditor    : hint:= 'Child Editor';
    hcResetData      : Hint:= 'Reset Data files';
    hcResetGame      : Hint:= 'Reset GAME';
    hcDocFiles       : Hint:= 'SYSOP.DOC, WHATS.NEW and other text files';
    hcMoreEditors    : Hint:= 'More Editors';

    hcViewFile       : Hint:= 'View a textfile';
    hcWhatsNew       : Hint:= whatsnewfile+' file';
    hcSysopDoc       : Hint:= sysopdoc+' file';
    hcUsurperDoc     : Hint:= usurperdoc+' file';
    hcReadMe         : Hint:= readmefile+' file';
    hcFutureDoc      : Hint:= futuredoc+' file';
    hcSupportDoc     : Hint:= supportdoc+' file';

    {moat editor related}
    hcMoatEditor      : Hint:= 'Moat Editor';
    hcMoatName        : Hint:= 'Name of Moat Creature'; {moat creature name}
    hcMoatCost        : Hint:= 'Cost to buy'; {name of user who created the drink}
    hcMoatHps         : Hint:= 'Hitpoints'; {hitpoints}
    hcMoatBaseArmor   : Hint:= 'Base Armor value'; {drink has been ordered # number of times}
    hcMoatBaseAttack  : Hint:= 'Base Attack value'; {drink was last had by this person}
    hcMoatDesc        : Hint:= 'Description of moat creature'; {description}
    hcMoatDeleted     : Hint:= 'Moat creature is deleted';
    hcMoatDeleted2    : Hint:= 'Moat creature is not deleted';
    hcMoatSearch      : Hint:= 'Search for moat creature'; {search for drink}
    hcMoatCreate      : Hint:= 'Create a New Moat Creature'; {create a new moat creature}

    {drink editor related}
    hcDrinkEditor    : Hint:= 'Drink Editor';
    hcDrinkName      : Hint:= 'Name of Drink'; {drink name}
    hcDrinkDate      : Hint:= 'When was the drink created';
    hcDrinkCreator   : Hint:= 'Who created the drink'; {name of user who created the drink}
    hcDrinkComment   : Hint:= 'Comment'; {comment to drink}
    hcDrinkOrdered   : Hint:= 'how many times the drink has been ordered';
    hcDrinkLastHad   : Hint:= 'drink was last had by this person';
    hcDrinkLastOrdered:Hint:= 'drink was last ordered this date';
    hcDrinkSecret    : Hint:= 'when a drink has a secret recipe, others can''t view it'; {secret recipe}
    hcDrinkSecret2   : Hint:= 'when a drink has a secret recipe, others can''t view it';
    hcDrinkDeleted   : Hint:= 'Drink has been deleted';
    hcDrinkDeleted2  : Hint:= 'Drink has not been deleted';
    hcDrinkSearch    : Hint:= 'Search for Drink';
    hcDrinkViewIng   : Hint:= 'View Ingredients';

    hcOptions        : Hint:= 'View docs, toggle video mode and dos shell';
    hcOptionsToggle  : Hint:= 'Toggle between 25 and 42/50 line mode (EGA or better)';
    hcODosShell      : Hint:= 'Shell to DOS';

                       {range start}
    hcLevelfile      : Hint:= 'file with level limits';
    hcDoorGuardfile  : Hint:= 'file with door guards';
    hcItemfile       : Hint:= 'file with items';
    hcMonsterfile    : Hint:= 'file with monsters';

    hcArmorfile      : Hint:= 'file with CLASSIC Armors';
    hcWeaponfile     : Hint:= 'file with CLASSIC Weapons';
    hcNpcFile        : Hint:= 'file with computer players';
    hcTeamNamefile   : Hint:= 'file with different team names (used by computer teams)';
    hcMoatFile       : Hint:= 'file with moat creatures, lurking in the Castle moat';
                       {range end}
    hcLevEdExpNeed   : Hint:= 'Experience needed to reach level';

    {doorguard related}
    hcDGname         : Hint:='Name of guard';
    hcDGcost         : Hint:='Cost to hire';
    hcDGmany         : Hint:='Should players be able to hire more than one guard?';
    hcDGmany2        : Hint:='Should players be able to hire more than one guard?';
    hcDGdesc         : Hint:='Description of guard';
    hcDGcreate       : Hint:='Create a new guard';
    hcDGHitpoints    : Hint:='Hitpoints';
    hcDGBaseArmor    : Hint:='Base Armor value';
    hcDGBaseAttack   : Hint:='Base Attack value';
    hcDGSearch       : Hint:='Search for guard';

    {player/npc editor related}
    hcPeditDelete    : Hint:='Mark character as DELETED';
    hcPeditRevive    : Hint:='Revive character';
    hcPeditEquip     : Hint:='Character equipment';
    hcPeditMore      : Hint:='More stuff to edit...';
    hcPeditSearch    : Hint:='Search for character';
    hcPeditCreate    : Hint:='Create character';
    hcPeditName      : Hint:='Players real name';
    hcPeditAlias     : Hint:='Players Alias';
    hcPeditMoney     : Hint:='Money on hand';
    hcPeditBank      : Hint:='Money in bank';
    hcPeditExperience: Hint:='Experience points';
    hcPeditHealings  : Hint:='Healing potions';
    hcPeditDngFights : Hint:='Dungeon fights left today';
    hcPeditPlyFights : Hint:='Player fights left today';
    hcPeditTeamFights: Hint:='Team fights left today';
    hcPeditTeam      : Hint:='Team name';
    hcPeditPassWord  : Hint:='Team password';
    hcPeditMental    : Hint:='Mental stability (0=insane...100=normal)';
    hcPeditDrugAddict: Hint:='Drug Addiction (0=normal...100=trippin every day)';
    hcPeditThefts    : Hint:='Thievery attempts left today';
    hcPeditBrawls    : Hint:='Brawls left today';
    hcPeditTrainings : Hint:='Close combat training sessions';
    hcPeditControl1  : Hint:='Human controlled';
    hcPeditControl2  : Hint:='Computer controlled';
    hcPeditGender1   : Hint:='Gender: Female';
    hcPeditGender2   : Hint:='Gender: Male';
    hcPeditKing1     : Hint:='Player is the King';
    hcPeditKing2     : Hint:='Player is NOT the King';
    hcPeditAllowed1  : Hint:='Allowed to play today';
    hcPeditAllowed2  : Hint:='NOT Allowed to play today';
    hcPeditLevel     : Hint:='Level';
    hcPeditHps       : Hint:='Hitpoints';
    hcPeditMaxhps    : Hint:='Max hitpoints';
    hcPeditAge       : Hint:='Age';
    hcPeditChivalry  : Hint:='Chivalry';
    hcPeditDarkness  : Hint:='Darkness';
    hcPeditStrength  : Hint:='Strength';
    hcPeditDefence   : Hint:='Defence';
    hcPeditGoodDeeds : Hint:='Good deeds left today';
    hcPeditEvilDeeds : Hint:='Evil deeds left today';
    hcPeditMana      : Hint:='Mana';
    hcPeditMaxMana   : Hint:='Max mana';
    hcPeditStamina   : Hint:='Stamina';
    hcPeditAgility   : Hint:='Agility';
    hcPeditCharisma  : Hint:='Charisma';
    hcPeditDexterity : Hint:='Dexterity';
    hcPeditWisdom    : Hint:='Wisdom';

    {classes help}
    hcPeditClass1    : Hint:=c+class_display(Alchemist);
    hcPeditClass2    : Hint:=c+class_display(Assassin);
    hcPeditClass3    : Hint:=c+class_display(Barbarian);
    hcPeditClass4    : Hint:=c+class_display(Bard);
    hcPeditClass5    : Hint:=c+class_display(Cleric);
    hcPeditClass6    : Hint:=c+class_display(Jester);
    hcPeditClass7    : Hint:=c+class_display(Magician);
    hcPeditClass8    : Hint:=c+class_display(Paladin);
    hcPeditClass9    : Hint:=c+class_display(Ranger);
    hcPeditClass10   : Hint:=c+class_display(Sage);
    hcPeditClass11   : Hint:=c+class_display(Warrior);

    {races help}
    hcPeditRace1     : Hint:=r+race_display(human);
    hcPeditRace2     : Hint:=r+race_display(hobbit);
    hcPeditRace3     : Hint:=r+race_display(elf);
    hcPeditRace4     : Hint:=r+race_display(halfelf);
    hcPeditRace5     : Hint:=r+race_display(dwarf);
    hcPeditRace6     : Hint:=r+race_display(troll);
    hcPeditRace7     : Hint:=r+race_display(orc);
    hcPeditRace8     : Hint:=r+race_display(gnome);
    hcPeditRace9     : Hint:=r+race_display(gnoll);
    hcPeditRace10    : Hint:=r+race_display(mutant);


    {PLAYER/NPC Editor Page [2/2]}
    {magician spell help}
    hcPeditSpells1   : Hint:=s+spell_name(1,Magician);
    hcPeditSpells2   : Hint:=s+spell_name(2,Magician);
    hcPeditSpells3   : Hint:=s+spell_name(3,Magician);
    hcPeditSpells4   : Hint:=s+spell_name(4,Magician);
    hcPeditSpells5   : Hint:=s+spell_name(5,Magician);
    hcPeditSpells6   : Hint:=s+spell_name(6,Magician);
    hcPeditSpells7   : Hint:=s+spell_name(7,Magician);
    hcPeditSpells8   : Hint:=s+spell_name(8,Magician);
    hcPeditSpells9   : Hint:=s+spell_name(9,Magician);
    hcPeditSpells10  : Hint:=s+spell_name(10,Magician);
    hcPeditSpells11  : Hint:=s+spell_name(11,Magician);
    hcPeditSpells12  : Hint:=s+spell_name(12,Magician);
    {cleric spell help}
    hcPeditSpells20  : Hint:=s+spell_name(1,Cleric);
    hcPeditSpells21  : Hint:=s+spell_name(2,Cleric);
    hcPeditSpells22  : Hint:=s+spell_name(3,Cleric);
    hcPeditSpells23  : Hint:=s+spell_name(4,Cleric);
    hcPeditSpells24  : Hint:=s+spell_name(5,Cleric);
    hcPeditSpells25  : Hint:=s+spell_name(6,Cleric);
    hcPeditSpells26  : Hint:=s+spell_name(7,Cleric);
    hcPeditSpells27  : Hint:=s+spell_name(8,Cleric);
    hcPeditSpells28  : Hint:=s+spell_name(9,Cleric);
    hcPeditSpells29  : Hint:=s+spell_name(10,Cleric);
    hcPeditSpells30  : Hint:=s+spell_name(11,Cleric);
    hcPeditSpells31  : Hint:=s+spell_name(12,Cleric);
    {sage spell help}
    hcPeditSpells35  : Hint:=s+spell_name(1,Sage);
    hcPeditSpells36  : Hint:=s+spell_name(2,Sage);
    hcPeditSpells37  : Hint:=s+spell_name(3,Sage);
    hcPeditSpells38  : Hint:=s+spell_name(4,Sage);
    hcPeditSpells39  : Hint:=s+spell_name(5,Sage);
    hcPeditSpells40  : Hint:=s+spell_name(6,Sage);
    hcPeditSpells41  : Hint:=s+spell_name(7,Sage);
    hcPeditSpells42  : Hint:=s+spell_name(8,Sage);
    hcPeditSpells43  : Hint:=s+spell_name(9,Sage);
    hcPeditSpells44  : Hint:=s+spell_name(10,Sage);
    hcPeditSpells45  : Hint:=s+spell_name(11,Sage);
    hcPeditSpells46  : Hint:=s+spell_name(12,Sage);

    hcPeditDesc      : Hint:='Character description';
    hcPeditNeverDel  : Hint:='Should player be deleted for inactivity?';
    hcPeditDis1      : Hint:=d+'Blindness';
    hcPeditDis2      : Hint:=d+'Plague';
    hcPeditDis3      : Hint:=d+'Smallpox';
    hcPeditDis4      : Hint:=d+'Measles';
    hcPeditDis5      : Hint:=d+'Leprosy';

    hcPeditMaxTime   : Hint:='Time left';

    hcPeditMove1     : Hint:=m+bash_name(1);
    hcPeditMove2     : Hint:=m+bash_name(2);
    hcPeditMove3     : Hint:=m+bash_name(3);
    hcPeditMove4     : Hint:=m+bash_name(4);
    hcPeditMove5     : Hint:=m+bash_name(5);
    hcPeditMove6     : Hint:=m+bash_name(6);
    hcPeditMove7     : Hint:=m+bash_name(7);
    hcPeditMove8     : Hint:=m+bash_name(8);
    hcPeditMove9     : Hint:=m+bash_name(9);
    hcPeditMove10    : Hint:=m+bash_name(10);
    hcPeditMove11    : Hint:=m+bash_name(11);
    hcPeditMove12    : Hint:=m+bash_name(12);
    hcPeditMove13    : Hint:=m+bash_name(13);
    hcPeditMove14    : Hint:=m+bash_name(14);

    hcPeditMKills    : Hint:='Monster kills';
    hcPeditMDefeats  : Hint:='Monster defeats';
    hcPeditPKills    : Hint:='Player kills';
    hcPeditPDefeats  : Hint:='Player defeats';

    {PLAYER/NPC Editor Page [2/2]}
    {phrases editor box}
    hcPeditPhrases   : Hint:='Player Phrases';
    hcPeditBattleCry : Hint:='Battle cry when attacked by other player';
    hcPeditPhrase1   : Hint:='What to say when being attacked';
    hcPeditPhrase2   : Hint:='What to say after a win';
    hcPeditPhrase3   : Hint:='What to say after a defeat';
    hcPeditPhrase4   : Hint:='What to say when begging for mercy';
    hcPeditPhrase5   : Hint:='What to say when sparing a life';
    hcPeditPhrase6   : Hint:='What to say when butchering defeated players';

    {MONSTER EDITOR related}
    hcMeditSearch    : Hint:='Search for monster';
    hcMeditGoto      : Hint:='Goto monster #';
    hcMeditMonster   : Hint:='Name of monster';
    hcMeditHitpoints : Hint:='Hitpoints';
    hcMeditPhrase    : Hint:='Phrase to utter when encountering players';
    hcMeditMagicRes  : Hint:='Magic resistance';
    hcMeditMagicLev  : Hint:='Magic level, a high level results in strong spells';
    hcMeditStrength  : Hint:='Strength';
    hcMeditDefence   : Hint:='Defence';
    hcMeditIQ        : Hint:='Monster IQ, smart monsters attack weak players in team.';
    hcMeditEvil      : Hint:='Evil, killing evil monsters reduces players darkness.';
    hcMeditWeapon    : Hint:='Pick a Weapon for the monster';
    hcMeditArmor     : Hint:='Pick a Armor for the monster';
    hcMeditGrabWeapon: Hint:='Allow player to take weapon when monster is dead';
    hcMeditGrabWeap2 : Hint:='Allow player to take weapon when monster is dead';
    hcMeditGrabArmor : Hint:='Allow player to take armor when monster is dead';
    hcMeditGrabArm2  : Hint:='Allow player to take armor when monster is dead';
    hcMeditGlobal    : Hint:='Commands affecting all monsters';
    hcMeditGrmvSpells: Hint:='Remove all monster spells (global)';
    hcMeditSpells1   : Hint:=s+monster_spell(1);
    hcMeditSpells2   : Hint:=s+monster_spell(2);
    hcMeditSpells3   : Hint:=s+monster_spell(3);
    hcMeditSpells4   : Hint:=s+monster_spell(4);
    hcMeditSpells5   : Hint:=s+monster_spell(5);
    hcMeditSpells6   : Hint:=s+monster_spell(6);

    {ITEM EDITOR related}
    hcItemName       : Hint:='Name of item';
    hcItemValue      : Hint:='Value in gold';
    hcItemAttack     : Hint:='Attack power';
    hcItemArmor      : Hint:='Armor power';
    hcItemDesc1      : Hint:='Description of item';
    hcItemDesc2      : Hint:='Hidden description of item';
    hcItemStore      : Hint:='Can item be bought in store?';
    hcItemFound      : Hint:='Can item be found in dungeons?';
    hcItemAtlevel1   : Hint:='Minimum dungeon level the item can be found on';
    hcItemAtLevel2   : Hint:='Maximum dungeon level the item can be found on';
    hcItemHps        : Hint:='Item will increase players Hitpoints with this value';
    hcItemStamina    : Hint:='Item will increase players Stamina with this value';
    hcItemAgility    : Hint:='Item will increase players Agility with this value';
    hcItemCharisma   : Hint:='Item will increase players Charisma with this value';
    hcItemDexterity  : Hint:='Item will increase players Dexterity with this value';
    hcItemWisdom     : Hint:='Item will increase players Wisdom with this value';
    hcItemMana       : Hint:='Item will increase players Mana with this value';
    hcItemStrength   : Hint:='Item will increase players Strength with this value';
    hcItemDefence    : Hint:='Item will increase players Defence with this value';
    hcItemStrNeed    : Hint:='Strength needed to use item';

    hcItemCure1      : Hint:=cancure;
    hcItemCure2      : Hint:=cancure;
    hcItemCure3      : Hint:=cancure;
    hcItemCure4      : Hint:=cancure;
    hcItemCure5      : Hint:=cancure;
    hcItemCure6      : Hint:=cancure;
    hcItemCure7      : Hint:=cancure;

    hcItemGood1      : Hint:='Item can only be used by Good characters';
    hcItemGood2      : Hint:='Item can only be used by Good characters';
    hcItemEvil1      : Hint:='Item can only be used by Evil characters';
    hcItemEvil2      : Hint:='Item can only be used by Evil characters';
    hcItemCursed1    : Hint:='If item is Cursed, then a player can''t drop it';
    hcItemCursed2    : Hint:='If item is Cursed, then a player can''t drop it';

    hcItemRestrict   : Hint:='Restrict item so it can be used only by certain Classes';

    hcItemSearch     : Hint:='Search for item';
    hcItemCreate     : Hint:='Create new item';
    hcItemType       : Hint:='Change to a different Type of item';
    hcItemOptions    : Hint:='File options: Import/Export items';
    hcItemImport     : Hint:='Import items from a file';
    hcItemExport     : Hint:='Export items from a file';
    hcItemRemove     : Hint:='Remove current item';
    hcItemInfo       : Hint:='Info on selected item';

    {CONFIG EDITOR related}
    hcConfigNew      : Hint:='Create a New configuration';
    hcConfigGoto     : Hint:='Goto config option #';
    hcConfigSearch   : Hint:='Search for keyword';
    hcConfigToggle   : Hint:='Toggle yes/no option';

    {Equipment Dialog (NEW) related}
    hcEquipLeftHand  : Hint:='Left hand';
    hcEquipRightHand : Hint:='Right hand';
    hcEquipHead      : Hint:='Head';
    hcEquipBody      : Hint:='Body';
    hcEquipArms      : Hint:='Arms';
    hcEquipFinger1   : Hint:='Left Finger';
    hcEquipFinger2   : Hint:='Right Finger';
    hcEquipLegs      : Hint:='Legs';
    hcEquipFeet      : Hint:='Feet';
    hcEquipWaist     : Hint:='Waist';
    hcEquipNeck1     : Hint:='Neck (primary)';
    hcEquipNeck2     : Hint:='Neck (secondary)';
    hcEquipFace      : Hint:='Face';
    hcEquipShield    : Hint:='Shield';
    hcEquipHands     : Hint:='Hands';
    hcEquipABody     : Hint:='Around Body';
    hcEquipWeapon    : Hint:='Weapon';
    hcEquipFingers   : Hint:='Fingers';
    hcEquipNecks     : Hint:='Neck';
    hcEquipFood      : Hint:='Food';
    hcEquipDrink     : Hint:='Drink';

    hcAutoEquip      : Hint:='Send this player to the stores NOW!';
    hcRemoveAll      : Hint:='Remove all equipment';

    {Equipment Dialog (Classic) related}
    hcClassicWeapon  : Hint:='Weapon';
    hcClassicArmor   : Hint:='Armor';
    hcClassicNone    : Hint:='None (remove current item)';

    {Inventory (NEW) related}
    hcInventory      : Hint:='Inventory';
    hcInventoryItem  : Hint:='Item in inventory';
    hcInventoryRemove: Hint:='Remove everything from inventory';

    {GENERAL BUTTONS}
    hcGenOk          : Hint:='Ok';
    hcGenCancel      : Hint:='Cancel';
    hcGenPrevious    : Hint:='Previous';
    hcGenNext        : Hint:='Next';
    hcGenNumeric     : Hint:='Enter a numeric value';
    hcGenFileName    : Hint:='Enter a filename';
    hcGenString      : Hint:='Enter a string';
    hcGenGoto        : Hint:='Goto found record';
    hcGenSearch      : Hint:='Search...';
    hcGenYes         : Hint:='Yes';
    hcGenNo          : Hint:='No';

    hcNada  : Hint:='';
  else
    Hint := '';
  end;
end; { TMyStatusLine.Hint }


{TMyApplication *** START ***}
Constructor TMyApp.Init;
var
    r : trect;
    MyBackGround : pbackground;
    Event : Tevent;
begin

 {Tapplication.Init;}
 Inherited Init;

 {fixes so that streams work with the below stated,
  or else helpfile won't work}
 {RegisterObjects;
 RegisterViews;
 RegisterMenus;
 RegisterDialogs;
 RegisterApp;}
 RegisterHelpFile;

 GetExtent(r);
 Desktop^.Delete(Desktop^.BackGround);
 MyBackGround:=New(PbackGround,init(r,chr(159))); {Setting the background}
 Desktop^.Insert(MybackGround);

 {togglevideomode;}

 With Event do begin
  What    := evCommand;
  Command := cmMain;
 end;
 PutEvent(Event);

end;

Function TMyApp.GetPalette:PPalette;
  const
  CColor =
        #$71#$70#$78#$74#$20#$28#$24#$17#$1F#$1A#$31#$31#$1E#$71#$00 +
    #$37#$3F#$3A#$13#$13#$3E#$21#$00#$70#$7F#$7A#$13#$13#$70#$7F#$00 +
    #$70#$7F#$7A#$13#$13#$70#$70#$7F#$7E#$20#$2B#$2F#$78#$2E#$70#$30 +
    #$3F#$3E#$1F#$2F#$1A#$20#$72#$31#$31#$30#$2F#$3E#$31#$13#$00#$00 +
    #$4F#$4F;  { <- these last two are the new entries }

Const
  P: Array[apColor..apMonochrome] of String[Length(CColor)] =
    (CColor, CBlackWhite, CMonochrome);
var i : byte;

begin

  p[apcolor,1] := #$31;   {background}
  p[apcolor,2] := #$1F;   {normal Text}
  p[apcolor,3] := #$3E;   {disabled Text}
  p[apcolor,4] := #$3E;   {shortcut}

  {8-15, blue window}
  p[apcolor,8] := #$3F;   {frame passive}
  p[apcolor,9] := #$3F;   {frame active,border}
  p[apcolor,10] := #$3A;  {close icon, size gadget}
  p[apcolor,11] := #$31;  {scrollbar page}
  p[apcolor,12] := #$31;  {scrollbar reserved text (pilarna)}
  p[apcolor,13] := #$30;  {scroller normal text, texten i f”nstret}
  p[apcolor,14] := #$3E;  {scroller selected text}
  p[apcolor,15] := #$31;  {reserved}


  {16-23, cyan windows}
{  p[apcolor,16] := #$3F;   {frame passive}
{  p[apcolor,17] := #$3F;   {frame active,border}
{  p[apcolor,18] := #$3A;  {close icon, size gadget}
{  p[apcolor,19] := #$31;  {scrollbar page}
{  p[apcolor,20] := #$31;  {scrollbar reserved text (pilarna)}
{  p[apcolor,21] := #$30;  {scroller normal text, texten i f”nstret}
{  p[apcolor,22] := #$3E;  {scroller selected text}
{  p[apcolor,23] := #$31;  {reserved}

  {24-31, gray windows}
{  p[apcolor,24] := #$3F;   {frame passive}
{  p[apcolor,25] := #$3F;   {frame active,border}
{  p[apcolor,26] := #$3A;  {close icon, size gadget}
{  p[apcolor,27] := #$31;  {scrollbar page}
{  p[apcolor,28] := #$31;  {scrollbar reserved text (pilarna)}
{  p[apcolor,29] := #$30;  {scroller normal text, texten i f”nstret}
{  p[apcolor,30] := #$3E;  {scroller selected text}
{  p[apcolor,31] := #$31;  {reserved}


 {nedan ska va me!}
  p[apcolor,32] := #$1F;  {tdialog frame active}
  p[apcolor,33] := #$1F;  {tdialog frame icon}
  p[apcolor,34] := #$1F;  {frame icon}
  p[apcolor,35] := #$1F;  {scrollbar page}

  p[apcolor,36] := #$1F;  {static text/back col i dialog boxes}
  p[apcolor,37] := #$1F;  {label normal i dialog boxes}
  p[apcolor,38] := #$1F;  {label igen}
  p[apcolor,39] := #$1C;  {label igen}

  p[apcolor,41] := #$3F;  {dialog/window button normal}
  p[apcolor,42] := #$3F;  {dialog/window button default}
  p[apcolor,43] := #$5F;  {dialog/window button selected}
  p[apcolor,44] := #$5F;  {dialog/window button selected}

 p[apcolor,45] := #$3E;  {dialog/window button shortcut}
 p[apcolor,46] := #$10;  {dialog/window button shadow}
 p[apcolor,47] := #$13;  {cluster normal}
 p[apcolor,48] := #$1E;  {cluster selected}
 p[apcolor,49] := #$1F;  {cluster shortcut . dialog boxes}

 p[apcolor,50] := #$3E;  {inputline normal}
 p[apcolor,51] := #$3E;  {inputline selected}
 p[apcolor,57] := #$1F;  {listviewer normal}
 p[apcolor,56] := #$4F;  {history Window scrollbar control}

 p[apcolor,62] := #$17;  {cluster object som ej „r valbara(shadowed)}

 getpalette := @p[apppalette];


end;

Procedure TMyApp.HandleEvent(var Event: TEvent);
begin

 TApplication.HandleEvent(Event);

 if Event.What = evCommand then begin
  case Event.Command of
   cmMain :begin
            FirstMenu; {auto starting the main menu.}
            ClearEvent(Event);
            EndModal(cmClose);
           end;
  end;
 end;

end;

Procedure TMyapp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
const
  HelpInUse: Boolean = False;
begin
  inherited GetEvent(Event);
  case Event.What of
    evCommand:

      if (Event.Command = cmHelp) and not HelpInUse then
      begin
        HelpInUse := True;
        HelpStrm := New(PDosStream, Init(CalcHelpName(global_EDHELP), stOpenRead));
        HFile := New(PHelpFile, Init(HelpStrm));
        if HelpStrm^.Status <> stOk then
        begin
          MessageBox('Could not open help file.', nil, mfError + mfOkButton);
          Dispose(HFile, Done);
        end
        else
        begin
          W := New(PHelpWindow,Init(HFile, GetHelpCtx));
          if ValidView(W) <> nil then
          begin
            ExecView(W);
            Dispose(W, Done);
          end;
          ClearEvent(Event);
        end;
        HelpInUse := False;
      end;
    evMouseDown:
      if Event.Buttons <> 1 then Event.What := evNothing;
  end;
end;

Procedure TMyApp.InitStatusLine;
var R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;

  StatusLine := New(MyStatusLineP, Init(R,
                     NewStatusDef(0,65000,
                      NewStatusKey('~F1~ Help', kbF1, cmHelp,nil),nil)));

{ draw nothing, allow ALT-X quit }
{  GetExtent(R);
  R.A.Y := R.B.Y + 1;   { below screen bottom }
{  New(StatusLine, Init(R, NewStatusDef(0, $EFFF,
                            StdStatusKeys(nil), nil)));
}
end;

procedure TMyapp.ToggleVideoMode;
var
  NewMode: Word;
  R: TRect;
begin

  NewMode := ScreenMode xor smFont8x8;
  if NewMode and smFont8x8 <> 0 then ShadowSize.X := 1
                                else ShadowSize.X := 2;
  SetScreenMode(NewMode);

  {Desktop^.GetExtent(R);}
  {TrashCan^.Reposition(R);
  ConfigRec.Video := ScreenMode and smFont8x8;}
end;

procedure TMyApp.OutOfMemory;
begin
  MessageBox('There is not enough memory to complete this operation.',
    nil, mfError+mfOKButton);
end;

{*** TMyApplication *** END ***}

{-------CLASSIC ITEMPICK DIALOG START--------}
Constructor ClassicPickDialog.Init(var Bounds:TRect; MyTitle: TTitleStr;vapen:boolean);
Begin
 TDialog.Init(Bounds, MyTitle);
 kanon:=vapen;
End;

Destructor ClassicPickDialog.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;


Procedure ClassicPickDialog.HandleEvent(var Event:TEvent);
var i,index : longint;
    carmor: armrec;
    cweapon : weaprec;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvBroadcast:begin
                case event.command of
                 cmEqCatchMe:begin {USER HAR VALT FOCUSED ITEM}
                               Index:=(CLlist^.Focused);
                               inc(index);

                               if kanon then begin
                                load_weapon(index,cweapon);
                                player.weapon:=index;
                                player.wpow:=cweapon.pow;
                               end
                               else begin
                                load_armor(index,carmor);
                                player.armor:=index;
                                player.apow:=carmor.pow;
                               end;

                               Message(Owner, evCommand, cmOk,Nil);
                              end;
                end;
                ClearEvent(Event);
               end;
   EvCommand:begin
              case event.command of

               CmRemoveCurrent:begin
                                if kanon then begin
                                 player.weapon:=0;
                                 player.wpow:=0;
                                end
                                else begin
                                 player.armor:=0;
                                 player.apow:=0;
                                end;
                                Message(Owner, evCommand, cmOk,Nil);
                               end;
               CmEqSearch:begin
                           index:=look_for_item(namelist);
                           if index>0 then begin
                            CLList^.FocusItem(index-1);
                           end;
                          end;
               CmEqCatchMe:begin
                            Index:=(CLlist^.Focused);
                            inc(index);
                             if kanon then begin
                                load_weapon(index,cweapon);
                                player.weapon:=index;
                                player.wpow:=cweapon.pow;
                               end
                               else begin
                                load_armor(index,carmor);
                                player.armor:=index;
                                player.apow:=carmor.pow;
                               end;

                            Message(Owner, evCommand, cmOk,Nil);
                       end;
               CmItemInfo:begin
                           Index:=(Eqlist^.Focused);
                           inc(index);
                          end;

              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------CLASSIC ITEMPICK DIALOG END--------}

{----RES DIALOG START-----}
Constructor ResDialog.Init(var Bounds:TRect; MyTitle: TTitleStr;gmode:boolean);
Begin
 TDialog.Init(Bounds, MyTitle);
 game:=gmode;
 doneit:=false;
End;

Procedure ResDialog.HandleEvent(var Event:TEvent);
var  sx,sy : byte;
     Txt: Text;
Begin

 if doneit=false then begin
  doneit:=true;
  if game then begin
   if f_exists(innfile1)      then delete_file(innfile1);
   if f_exists(innfile2)      then delete_file(innfile2);
   if f_exists(nwfileans)     then delete_file(nwfileans);
   if f_exists(nwfileasc)     then delete_file(nwfileasc);
   if f_exists(ynwfileasc)    then delete_file(ynwfileasc);
   if f_exists(ynwfileasc)    then delete_file(ynwfileasc);
   if f_exists(datefile)      then delete_file(datefile);
   if f_exists(mafile)        then delete_file(mafile);
   if f_exists(marketfile)    then delete_file(marketfile);
   if f_exists(chestfile)     then delete_file(chestfile);
   if f_exists(armofile)      then delete_file(armofile);
   if f_exists(weapofile)     then delete_file(weapofile);
   if f_exists(wwfile)        then delete_file(wwfile);
   if f_exists(truthfile1)    then delete_file(truthfile1);
   if f_exists(truthfile2)    then delete_file(truthfile2);
   if f_exists(teamrecordf)   then delete_file(teamrecordf);
   if f_exists(teamrecfile)   then delete_file(teamrecfile);
   if f_exists(indianfile)    then delete_file(indianfile);
   if f_exists(kingfile)      then delete_file(kingfile);
   if f_exists(rquestf)       then delete_file(rquestf);
   if f_exists(relationf)     then delete_file(relationf);
   if f_exists(childrenf)     then delete_file(childrenf);
   if f_exists(barrelf)       then delete_file(barrelf);

   if f_exists(drinkfile)     then delete_file(drinkfile);

   {log the royals comings and goings}
   if f_exists(MonarchsANSI)  then delete_file(MonarchsANSI);
   if f_exists(MonarchsASCI)  then delete_file(MonarchsASCI);

   {Marriage & Divorce History}
   if f_exists(MarrHistANSI)  then delete_file(MarrHistANSI);
   if f_exists(MarrHistASCI)  then delete_file(MarrHistASCI);

   {Child-Birth History}
   if f_exists(ChildBirthHistANSI) then delete_file(ChildBirthHistANSI);
   if f_exists(ChildBirthHistASCI) then delete_file(ChildBirthHistASCI);

   { Data file version }
   if (F_Exists(VersionF)) then Delete_File(VersionF);
  end;
  sx:=3;
  sy:=0;


  if resf1 or game then begin
   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Level Limits');
   global_MasterX:=sx;
   global_MasterY:=sy+1;
   Reset_Levels;
  end;

  if resf2 or game then begin
   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Door Guards (available at the Inn)');
   global_Masterx:=sx;
   global_Mastery:=sy+1;
   Reset_DoorGuards;
  end;

  if resf3 or game then begin
   inc(sy,2);

   Pupp^.Static(sx,sy,'Creating Items');

   global_Masterx:=sx;
   global_Mastery:=sy+1;

   Rewrite_Datfiles(true);
   Count_Objects;
   Reset_Monster_Weapons;
   Reset_body;
   Reset_rings;
   Reset_neck;
   Reset_shields;
   Reset_head;
   Reset_face;
   Reset_drink;
   Reset_arms;
   Reset_hands;
   Reset_waist;
   Reset_feets;
   Reset_abody;
   Reset_legs;
   Reset_food;
  end;

  if resf4 or game then begin
   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Monsters');
   global_Masterx:=sx;
   global_Mastery:=sy+1;

   Count_Monsters;
   Reset_Monsters;

   inc(sy,2);
   Pupp^.Static(sx,sy,'Arming Monsters');
   global_Masterx:=sx;
   global_Mastery:=sy+1;
   Arm_Monsters;
  end;

  if resf5 or game then begin
   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Armors (CLASSIC)');
   global_Masterx:=sx;
   global_Mastery:=sy+1;
   count_oldarmors;
   Reset_Armor;
  end;

  if resf6 or game then begin
   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Weapons (CLASSIC)');
   global_Masterx:=sx;
   global_Mastery:=sy+1;

   count_oldweapons;
   Reset_Weapon;
  end;

  if resf7 or game then begin
   {NPC file has to be created LAST! This because it reads information
    from the other files}
   delete_file(global_npfile);

   inc(sy,2);
   Pupp^.Static(sx,sy,'Creating Computer Characters');
   global_Masterx:=sx;
   global_Mastery:=sy+1;
   count_npcs;
   reset_npcs;
  end;

  if (resf8) or (game) then begin
   reset_teamnames;
  end;

  if (resf9) or (game) then begin
   reset_moatcreatures;
  end;

  if game then begin
   if f_exists(global_pfile) then delete_file(global_pfile);
   if f_exists(childrenf) then delete_file(childrenf);
   
   { Data file version }
   if (Open_TxtFile(TReWrite, Txt, VersionF)) then 
   begin
     WriteLn_To_Text(Txt, uver);
     Close_Text(Txt);
   end else
   begin
     Unable_To_Create(VersionF);
   end;
  end;

  if game then begin
   messagebox(#3'Usurper has been RESET!', nil,mfinformation or mfokbutton);
  end
  else begin
   messagebox(#3'I''m DONE!', nil,mfinformation or mfokbutton);
  end;

  With Event do begin
   What    := evCommand;
   Command := cmClose;
  end;
  PutEvent(Event);

  {pupp^.OkButton(2,2);}
 end;

 Inherited HandleEvent(Event);


End;
{-------RES DIALOG END--------}

{-------CONFIG OBJECT--------}
Destructor ConfigDialog.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;

Procedure ConfigDialog.HandleEvent(var Event:TEvent);
var index,i : integer;
    s : string;
Begin

 inherited HandleEvent(event);

  case event.what of
   evkeydown:begin
              case event.KeyCode of
               KbUp   : FocusNext(false);
               KbDown : FocusNext(true);
               KbRight: FocusNext(false);
               KbLeft : FocusNext(true);
               KbEnter: FocusNext(true);
              end;
              ClearEvent(Event);
             end;
   evbroadcast:
               case event.command of
                CatchNum:begin
                          Index:=(Plist^.Focused);
                          edit_config_option(index+1);
                          clearevent(event);
                         end;
               end;
   evcommand:
             case event.command of
              CmCGoto:begin {goto # line}
                       i:=Get_A_Value_Box('Goto Line #',1,global_maxcdef);

                       if i>0 then begin
                        PList^.FocusItem(i-1);
                       end;
                       ClearEvent(event);
                      end;
              CmCSearch:begin {search for keyword in helptext}
                         i:=search_in_config('Look for keyword',namelist);
                         if i>0 then begin
                          PList^.FocusItem(i-1);
                         end;
                         ClearEvent(event);
                        end;
              CmNewConf:begin {create new config file .start.}
                         s:=
                         'Previous settings will be lost!'#13 +
                         #13 +
                          ^C'Create a NEW Configuration file?'#13 +
                         #13 +
                         ^C+
                         ^C;

                         if YesNoBox('Warning',s)=true then begin

                          create_default_config(true);

                          for i:=1 to global_maxcdef do begin
                           s:=cfg_default(i);
                           s:=s+cfgvalue[i];
                           NameList^.ATPut(i-1,Newstr(S));
                           cfgback[i]:=cfgvalue[i]; {backup}
                          end;

                         end; {create new config file .end.}


                        end;
             end;
  end; {case .end.}

End;
{-------CONFIG OBJECT END--------}


{-------Level Dialog START--------}
Destructor LevelDialog.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;

Procedure LevelDialog.HandleEvent(var Event:TEvent);
var index : integer;
Begin

 inherited HandleEvent(event);

  case event.what of
   evkeydown:begin
              case event.KeyCode of
               KbUp   : FocusNext(false);
               KbDown : FocusNext(true);
               KbRight: FocusNext(false);
               KbLeft : FocusNext(true);
               KbEnter: FocusNext(true);
              end;
              ClearEvent(Event);
             end;
 Evbroadcast:begin
              case event.command of
               CatchNum:begin
                         Index:=(Levlist^.Focused);
                         edit_level(index+1);
                         clearevent(event);
                        end;
              end;
             end;

  end;

End;
{-------Level Dialog END--------}


{-------Item File Operations Dialog START--------}
Constructor IFODialog.Init(var Bounds:TRect; MyTitle: TTitleStr;typo:objtype);
Begin
 TDialog.Init(Bounds, MyTitle);
 sniper:=typo;
End;

Procedure IFODialog.HandleEvent(var Event:TEvent);
var s :string;
    n1,n2:longint;

Begin
 inherited HandleEvent(event);

  case event.what of
   evkeydown:begin
              case event.KeyCode of
               KbUp   : FocusNext(false);
               KbDown : FocusNext(true);
               KbRight: FocusNext(false);
               KbLeft : FocusNext(true);
               KbEnter: FocusNext(true);
              end;
              ClearEvent(Event);
             end;
 EvCommand:begin
            case event.command of
             CmImport:begin
                       s:=gimme_astring('Import Items','Filename',hcGenFileName);
                       if s<>'' then begin
                        if f_exists(s) then begin
                         import_items(s);
                        end
                        else begin
                         messagebox(#3'FILE NOT FOUND!',nil,mfOkbutton+mfWarning);
                        end;

                       end;
                      end;

             CmExport:begin
                       s:=gimme_astring('Export Items','Filename',hcGenFileName);

                       if s<>'' then begin
                        n1:=gimme_avalue('Export Items','From #',1,fso(sniper),hcGenNumeric);
                        if (n1>0) and (n1<(fso(sniper)+1)) then begin
                         n2:=gimme_avalue('Export Items','To #',n1+1,fso(sniper),hcGenNumeric);

                         if (n2>0) and (n2>n1) then begin
                          export_items(s,n1,n2,sniper);
                         end;

                        end;
                       end;

                      end;
            end;
           end;

  end;

End;
{-------Item File Operations Dialog END--------}

{-------Item Class Restrictions Dialog START--------}
Constructor IREDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
Begin
 TDialog.Init(Bounds, MyTitle);
End;

Procedure IREDialog.HandleEvent(var Event:TEvent);
var s :string;
    n1,n2:longint;

Begin
 inherited HandleEvent(event);

  case event.what of
   evkeydown:begin
              case event.KeyCode of
               KbUp   : FocusNext(false);
               KbDown : FocusNext(true);
               KbRight: FocusNext(false);
               KbLeft : FocusNext(true);
               KbEnter: FocusNext(true);
              end;
              ClearEvent(Event);
             end;
 EvCommand:begin
            case event.command of
             CmImport:begin
                      end;
            end;
           end;

  end;

End;
{-------Item Class Restrictions Dialog END--------}

{-------Gimme Value (longint) Dialog START--------}
Function GimmeValDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        GetData(GimVData);
       end;
 end;
end;

Procedure GimmeValDialog.HandleEvent(var Event:TEvent);
Begin
 inherited HandleEvent(event);

  case event.what of
   evkeydown:begin
              case event.KeyCode of
               KbUp   : FocusNext(false);
               KbDown : FocusNext(true);
               KbRight: FocusNext(false);
               KbLeft : FocusNext(true);
               KbEnter: FocusNext(true);
              end;
              ClearEvent(Event);
             end;
 EvCommand:begin
            {ClearEvent(Event);}
           end;

  end;

End;
{-------Gimme Value (longint) Dialog END--------}


{-------ITEMPICK DIALOG2 START  (GENERELL ITEM VŽLJARE)--------}
Destructor ItemPickDialog2.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;

Constructor ItemPickDialog2.Init(var Bounds:TRect; MyTitle: TTitleStr;typo:objtype;invnr:byte);
Begin
 TDialog.Init(Bounds, MyTitle);
 sniper:=typo;
 invx:=invnr;
End;

Procedure ItemPickDialog2.HandleEvent(var Event:TEvent);
var i,index : longint;
    obbe  : objektrec;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvBroadcast:begin
                case event.command of
                 cmEqCatchMe:begin {USER HAR VALT FOCUSED ITEM}
                               Index:=(Eqlist^.Focused);
                               inc(index);

                               player.item[invx]:=index;
                               player.itemtype[invx]:=sniper;

                               Message(Owner, evCommand, cmOk,Nil);
                              end;
                end;
                ClearEvent(Event);
               end;
   EvCommand:begin
              case event.command of

               CmRemoveCurrent:begin
                                player.item[invx]:=0;
                                Message(Owner, evCommand, cmOk,Nil);
                               end;
               CmEqSearch:begin
                           index:=look_for_item(namelist);

                           if index>0 then begin
                            EqList^.FocusItem(index-1);
                           end;
                          end;
               CmEqCatchMe:begin
                        Index:=(Eqlist^.Focused);
                        inc(index);
                         player.item[invx]:=index;
                         player.itemtype[invx]:=sniper;
                         Message(Owner, evCommand, cmOk,Nil);
                       end;
               CmItemInfo:begin
                           Index:=(Eqlist^.Focused);
                           inc(index);
                           load_objekt(Fload,obbe,sniper,index);
                           item_info(obbe);
                          end;

              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------ITEMPICK DIALOG2 END--------}

{-------ITEMTYPE SELECTOR START---------}
Procedure TypSelDialog.HandleEvent(var Event:TEvent);
var c : objtype;
    bye : boolean;
Begin

 bye:=false;

 inherited HandleEvent(event);

  case event.what of
   EvCommand:begin
              case Event.command of
              cmSWeap :begin
                        c:=Weapon;
                        bye:=true;
                       end;
              cmShield:begin
                        c:=Shield;
                        bye:=true;
                       end;
              cmSHead :begin
                        c:=Head;
                        bye:=true;
                       end;
              cmSBody :begin
                        c:=Body;
                        bye:=true;
                       end;
              cmSArms :begin
                        c:=Arms;
                        bye:=true;
                       end;
              cmSHands:begin
                        c:=Hands;
                        bye:=true;
                       end;
              cmSFing :begin
                        c:=Fingers;
                        bye:=true;
                       end;
              cmSLegs :begin
                        c:=Legs;
                        bye:=true;
                       end;
              cmSFeet :begin
                        c:=Feet;
                        bye:=true;
                       end;
              cmSWaist:begin
                        c:=Waist;
                        bye:=true;
                       end;
              cmSNeck :begin
                        c:=Neck;
                        bye:=true;
                       end;
              cmSFace :begin
                        c:=Face;
                        bye:=true;
                       end;
              cmSFood :begin
                        c:=Food;
                        bye:=true;
                       end;
              cmSDrink:begin
                        c:=Drink;
                        bye:=true;
                       end;
              cmSAbody:begin
                        c:=Abody;
                        bye:=true;
                       end;
              end;
                       if bye then begin
                         global_type:=c;
                         Message(Owner, evCommand, cmOk,Nil);
                       end;

              ClearEvent(Event);
             end;
  end;

End;
{-------ITEMTYPE SELECTOR END--------}



{-------ITEMPICK DIALOG START--------}
Destructor ItemPickDialog.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;

Constructor ItemPickDialog.Init(var Bounds:TRect; MyTitle: TTitleStr;typo:objtype;which:boolean);
Begin
 TDialog.Init(Bounds, MyTitle);
 left:=which;
 sniper:=typo;
End;


Procedure ItemPickDialog.HandleEvent(var Event:TEvent);
var index : integer;
    obbe : objektrec;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvBroadcast:begin
                case event.command of
                 cmEqCatchMe:begin
                             Index:=(Eqlist^.Focused);
                             inc(index);

                             Adjust_Item(Item_Add,Player,Sniper,Index,Left);

                             Message(Owner, evCommand, cmOk,Nil);
                            end;
                end;
                ClearEvent(Event);
               end;
   EvCommand:begin
              case Event.Command of
               CmEqSearch:begin
                           index:=look_for_item(namelist);
                           if index>0 then begin
                            EqList^.FocusItem(index-1);
                           end;
                          end;
               CmItemInfo:begin
                           Index:=(Eqlist^.Focused);
                           inc(index);
                           load_objekt(Fload,obbe,sniper,index);
                           item_info(obbe);
                          end;
               CmEqNone:begin {remove current item}
                         Adjust_Item(Item_Remove,Player,Sniper,0,Left);
                         Message(Owner, evCommand, cmOk,Nil);
                      end;
               CmEqCatchMe:begin
                        Index:=(Eqlist^.Focused);
                        inc(index);

                        Adjust_Item(Item_Add,Player,Sniper,Index,Left);
                        Message(Owner, evCommand, cmOk,Nil);
                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;

Procedure InvDialog.HandleEvent(var Event:TEvent);

Procedure Update_Item(nr:byte;name:string);
begin

 disposeStr(ps[nr]^.Text);
 ps[nr]^.Text:=NewStr(name);
 ps[nr]^.Draw;

end;

var
    index,
    m,mem,kick : word;

    obj : objektrec;
    nytyp : objtype;

Begin

 inherited HandleEvent(event);

  case event.what of
   EvCommand:begin
              kick:=0;
              case Event.Command of
               CmInvRemoveAll:begin {clean inventory}
                               for m:=1 to maxitem do begin
                                player.item[m]:=0;
                                update_item(m,'-');
                               end;
                              end;
               CmInv01: kick:=1;
               CmInv02: kick:=2;
               CmInv03: kick:=3;
               CmInv04: kick:=4;
               CmInv05: kick:=5;
               CmInv06: kick:=6;
               CmInv07: kick:=7;
               CmInv08: kick:=8;
               CmInv09: kick:=9;
               CmInv10: kick:=10;
               CmInv11: kick:=11;
               CmInv12: kick:=12;
               CmInv13: kick:=13;
               CmInv14: kick:=14;
               CmInv15: kick:=15;

              end;

              if kick>0 then begin
               if player.item[kick]=0 then begin
                Item_Type_Selector;
                nytyp:=global_type;
               end
               else begin
                nytyp:=player.itemtype[kick];
               end;


               mem:=player.item[kick];
               gimme_item(nytyp,kick);
               m:=(EqList^.Focused)+1;
               if m<>mem then begin
                if player.item[kick]=0 then obj.name:='-'
                 else load_objekt(Fload,obj,nytyp,m);

                 Update_Item(kick,obj.name);
               end;

              end; {case .end.}

              ClearEvent(Event);

             end;
  end; {case .end.}

End;

{-------ITEMPICK DIALOG END--------}

{-------MONSTER ITEMPICK DIALOG START--------}
Destructor ItemPickMDialog.Done;
Begin
 Dispose(NameList, Done);
 TDialog.done;
end;

Constructor ItemPickMDialog.Init(var Bounds:TRect; MyTitle: TTitleStr;typo:objtype);
Begin
 TDialog.Init(Bounds, MyTitle);
 sniper:=typo;
End;


Procedure ItemPickMDialog.HandleEvent(var Event:TEvent);
var index : integer;
    obbe : objektrec;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvBroadcast:begin
                case event.command of
                 cmEqCatchMe:begin
                             Index:=(Eqlist^.Focused);
                             inc(index);

                             if sniper=Weapon then begin
                              monster.weapnr:=index;
                             end
                             else if sniper=Abody then begin
                              monster.armnr:=index;
                             end;

                             Message(Owner, evCommand, cmOk,Nil);
                            end;
                end;
                ClearEvent(Event);
               end;
   EvCommand:begin
              case Event.Command of
               CmEqSearch:begin
                           index:=look_for_item(namelist);
                           if index>0 then begin
                            EqList^.FocusItem(index-1);
                           end;
                          end;
               CmItemInfo:begin
                           Index:=(Eqlist^.Focused);
                           inc(index);
                           load_objekt(Fload,obbe,sniper,index);
                           item_info(obbe);
                          end;
               CmEqNone:begin {remove current item}
                         if sniper=Weapon then begin
                          monster.weapnr:=0;
                         end
                         else if sniper=Abody then begin
                          monster.armnr:=0;
                         end;

                         Message(Owner, evCommand, cmOk,Nil);
                      end;
               CmEqCatchMe:begin
                        Index:=(Eqlist^.Focused);
                        inc(index);
                        if sniper=Weapon then begin
                         monster.weapnr:=index;
                        end
                        else if sniper=Abody then begin
                         monster.armnr:=index;
                        end;

                        Message(Owner, evCommand, cmOk,Nil);
                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------MONSTER ITEMPICK DIALOG END--------}


{--------EQUIPMENT DIALOG START------}
Procedure EqDialog.HandleEvent(var Event:TEvent);
Procedure Update_Item(nr:byte;name:string);
begin
 {update WEAPOn / ARMOr POWEr}

 disposeStr(ps[nr]^.Text);
 ps[nr]^.Text:=NewStr(name);
 ps[nr]^.Draw;

 disposeStr(psWEAP^.Text);
 psWEAP^.Text:=NewStr('Weapon Power : '+commastr(player.weap));
 psWEAP^.Draw;

 disposeStr(psARM^.Text);
 psARM^.Text:=NewStr('Armor Power : '+commastr(player.arm));
 psARM^.Draw;


end;

var index : integer;
    m : word;
    obbe : objektrec;
    mem : array[1..16] of word;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvCommand:begin
              case Event.Command of
               CmEqInventory:begin
                              Manage_Inventory(player);
                             end;
               CmEqAutoEquip:begin
                              mem[1]:=player.lhand;
                              mem[2]:=player.rhand;
                              mem[3]:=player.head;
                              mem[4]:=player.body;
                              mem[5]:=player.arms;
                              mem[6]:=player.lfinger;
                              mem[7]:=player.rfinger;
                              mem[8]:=player.legs;
                              mem[9]:=player.feet;
                              mem[10]:=player.waist;
                              mem[11]:=player.neck;
                              mem[12]:=player.neck2;
                              mem[13]:=player.face;
                              mem[14]:=player.shield;
                              mem[15]:=player.hands;
                              mem[16]:=player.abody;

                              Equip_Player(player);

                              if player.lhand<>mem[1] then begin
                               if player.lhand=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,weapon,player.lhand);

                               Update_Item(1,obbe.name);
                              end;

                              if player.rhand<>mem[2] then begin
                               if player.rhand=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,weapon,player.rhand);
                               Update_Item(2,obbe.name);
                              end;

                              if player.head<>mem[3] then begin
                               if player.head=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,head,player.head);
                               Update_Item(3,obbe.name);
                              end;

                              if player.body<>mem[4] then begin
                               if player.body=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,body,player.body);
                               Update_Item(4,obbe.name);
                              end;

                              if player.arms<>mem[5] then begin
                               if player.arms=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,arms,player.arms);
                               Update_Item(5,obbe.name);
                              end;

                              if player.lfinger<>mem[6] then begin
                               if player.lfinger=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,fingers,player.lfinger);
                               Update_Item(6,obbe.name);
                              end;

                              if player.rfinger<>mem[7] then begin
                               if player.rfinger=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,fingers,player.rfinger);
                               Update_Item(7,obbe.name);
                              end;

                              if player.legs<>mem[8] then begin
                               if player.legs=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,legs,player.legs);
                               Update_Item(8,obbe.name);
                              end;

                              if player.feet<>mem[9] then begin
                               if player.feet=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,feet,player.feet);
                               Update_Item(9,obbe.name);
                              end;

                              if player.waist<>mem[10] then begin
                               if player.waist=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,waist,player.waist);
                               Update_Item(10,obbe.name);
                              end;

                              if player.neck<>mem[11] then begin
                               if player.neck=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,neck,player.neck);
                               Update_Item(11,obbe.name);
                              end;

                              if player.neck2<>mem[12] then begin
                               if player.neck2=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,neck,player.neck2);
                               Update_Item(12,obbe.name);
                              end;

                              if player.face<>mem[13] then begin
                               if player.face=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,face,player.face);
                               Update_Item(13,obbe.name);
                              end;

                              if player.shield<>mem[14] then begin
                               if player.shield=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,shield,player.shield);
                               Update_Item(14,obbe.name);
                              end;

                              if player.hands<>mem[15] then begin
                               if player.hands=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,hands,player.hands);
                               Update_Item(15,obbe.name);
                              end;

                              if player.abody<>mem[16] then begin
                               if player.abody=0 then obbe.name:='-'
                               else load_objekt(Fload,obbe,abody,player.abody);
                               Update_Item(16,obbe.name);
                              end;

                             end;
               CmEqRemoveAll:begin
                              M:=(Eqlist^.Focused);
                              Inc(M);
                              Adjust_Item(Item_Remove,Player,Weapon,M,True);
                              Adjust_Item(Item_Remove,Player,Weapon,M,False);
                              Adjust_Item(Item_Remove,Player,Head,M,False);
                              Adjust_Item(Item_Remove,Player,Body,M,False);
                              Adjust_Item(Item_Remove,Player,Arms,M,False);
                              Adjust_Item(Item_Remove,Player,Fingers,M,True);
                              Adjust_Item(Item_Remove,Player,Fingers,M,False);
                              Adjust_Item(Item_Remove,Player,Legs,M,True);
                              Adjust_Item(Item_Remove,Player,Feet,M,True);
                              Adjust_Item(Item_Remove,Player,Waist,M,True);
                              Adjust_Item(Item_Remove,Player,Neck,M,True);
                              Adjust_Item(Item_Remove,Player,Neck,M,False);
                              Adjust_Item(Item_Remove,Player,Face,M,True);
                              Adjust_Item(Item_Remove,Player,Shield,M,True);
                              Adjust_Item(Item_Remove,Player,Hands,M,True);
                              Adjust_Item(Item_Remove,Player,Abody,M,True);

                              for m:=1 to 16 do begin
                               Update_Item(m,'-');
                              end; {for i:= .end.}

                             end;
               CmPELhand:begin {left hand change}
                          m:=player.lhand;
                          pick_item(weapon,true);
                          if player.lhand<>m then begin
                           if player.lhand=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,weapon,player.lhand);

                           Update_Item(1,obbe.name);
                          end;
                         end;
               CmPERhand:begin {right hand change}
                          m:=player.rhand;
                          pick_item(weapon,false);
                          if player.rhand<>m then begin
                           if player.rhand=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,weapon,player.rhand);
                           Update_Item(2,obbe.name);
                          end;
                         end;
               CmPEHead:begin {head change!}
                          m:=player.head;
                          pick_item(head,false);
                          if player.head<>m then begin
                           if player.head=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,head,player.head);
                           Update_Item(3,obbe.name);
                          end;
                        end;
               CmPEBody:begin
                          m:=player.body;
                          pick_item(body,false);
                          if player.body<>m then begin
                           if player.body=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,body,player.body);
                           Update_Item(4,obbe.name);
                          end;
                        end;
               CmPEArms:begin
                          m:=player.arms;
                          pick_item(arms,false);
                          if player.arms<>m then begin
                           if player.arms=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,arms,player.arms);
                           Update_Item(5,obbe.name);
                          end;
                        end;
               CmPELFing:begin
                          m:=player.lfinger;
                          pick_item(fingers,true);
                          if player.lfinger<>m then begin
                           if player.lfinger=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,fingers,player.lfinger);
                           Update_Item(6,obbe.name);
                          end;
                         end;
               CmPERFing:begin
                          m:=player.rfinger;
                          pick_item(fingers,false);
                          if player.rfinger<>m then begin
                           if player.rfinger=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,fingers,player.rfinger);
                           Update_Item(7,obbe.name);
                          end;
                         end;
               CmPELegs:begin
                          m:=player.legs;
                          pick_item(legs,false);
                          if player.legs<>m then begin
                           if player.legs=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,legs,player.legs);
                           Update_Item(8,obbe.name);
                          end;
                        end;
               CmPEFeet:begin
                          m:=player.feet;
                          pick_item(feet,false);
                          if player.feet<>m then begin
                           if player.feet=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,feet,player.feet);
                           Update_Item(9,obbe.name);
                          end;
                        end;
               CmPEWaist:begin
                          m:=player.waist;
                          pick_item(waist,false);
                          if player.waist<>m then begin
                           if player.waist=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,waist,player.waist);
                           Update_Item(10,obbe.name);
                          end;
                         end;
               CmPELNeck:begin
                          m:=player.neck;
                          pick_item(neck,true);
                          if player.neck<>m then begin
                           if player.neck=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,neck,player.neck);
                           Update_Item(11,obbe.name);
                          end;
                         end;
               CmPERNeck:begin
                          m:=player.neck2;
                          pick_item(neck,false);
                          if player.neck2<>m then begin
                           if player.neck2=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,neck,player.neck2);
                           Update_Item(12,obbe.name);
                          end;
                         end;
               CmPEFace:begin
                          m:=player.face;
                          pick_item(face,false);
                          if player.face<>m then begin
                           if player.face=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,face,player.face);
                           Update_Item(13,obbe.name);
                          end;
                        end;
               CmPEShield:begin
                          m:=player.shield;
                          pick_item(shield,false);
                          if player.shield<>m then begin
                           if player.shield=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,shield,player.shield);
                           Update_Item(14,obbe.name);
                          end;
                          end;
               CmPEHands:begin
                          m:=player.hands;
                          pick_item(hands,false);
                          if player.hands<>m then begin
                           if player.hands=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,hands,player.hands);
                           Update_Item(15,obbe.name);
                          end;
                         end;
               CmPEAbody:begin
                          m:=player.abody;
                          pick_item(abody,false);
                          if player.abody<>m then begin
                           if player.abody=0 then obbe.name:='-'
                            else load_objekt(Fload,obbe,abody,player.abody);
                           Update_Item(16,obbe.name);
                          end;
                         end;

              end;

              {securitycheck to make sure that armor/weapon power is broke}
               if player.lhand+
                  player.rhand+
                  player.head+
                  player.body+
                  player.arms+
                  player.lfinger+
                  player.rfinger+
                  player.legs+
                  player.feet+
                  player.waist+
                  player.neck+
                  player.neck2+
                  player.face+
                  player.shield+
                  player.hands+
                  player.abody=0 then begin

                  player.weap:=0;
                  player.arm:=0;
                end;

              ClearEvent(Event);
             end;
  end;

End;

Constructor EqDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
    i, sx : byte;
    g : byte;
    maxl : byte;
Begin
 maxl:=25;
 sx:=17;

 TDialog.Init(Bounds, MyTitle);

 g:=0;
 for i:=1 to 8 do begin
  R.Assign(sx,2+g,sx+maxl,3+g);
  new(ps[i],init(r,'-'));
  insert(ps[i]);
  inc(g,2);
 end;

 sx:=56;
 maxl:=22;
 g:=0;
 for i:=9 to 16 do begin
  R.Assign(sx,2+g,sx+maxl,3+g);
  new(ps[i],init(r,'-'));
  insert(ps[i]);
  inc(g,2);
 end;

 {weapon & armor INFO}
 R.Assign(3,2+g,28,3+g);
 new(psWEAP,init(r,'Weapon Power : '+commastr(player.weap)));
 insert(psWEAP);

 R.Assign(42,2+g,45+23,3+g);
 new(psARM,init(r,'Armor Power : '+commastr(player.arm)));
 insert(psARM);

End;
{----------EQUIPMENT DIALOG END---------------}

{-----CLASSIC EQUIPMENT DIALOG START----------}
Constructor EqClDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
    i, sx : byte;
    g : byte;
    maxl : byte;
Begin
 maxl:=25;
 sx:=15;

 TDialog.Init(Bounds, MyTitle);

 g:=0;
 for i:=1 to 2 do begin
  R.Assign(sx,2+g,sx+maxl,3+g);
  new(ps[i],init(r,'*none*'));
  insert(ps[i]);
  inc(g,2);
 end;

 {weapon & armor power}
 R.Assign(3,2+g,28,3+g);
 new(psWEAP,init(r,'Weapon Power : '+commastr(player.wpow*11)));
 insert(psWEAP);

 R.Assign(3,3+g,28,4+g);
 new(psARM,init(r,'Armor Power  : '+commastr(player.apow*11)));
 insert(psARM);

End;
Procedure EqClDialog.HandleEvent(var Event:TEvent);
Procedure Update_Item(nr:byte;name:string);
begin

 disposeStr(ps[nr]^.Text);
 ps[nr]^.Text:=NewStr(name);
 ps[nr]^.Draw;

 disposeStr(psWEAP^.Text);
 psWEAP^.Text:=NewStr('Weapon Power : '+commastr(player.wpow*11));
 psWEAP^.Draw;

 disposeStr(psARM^.Text);
 psARM^.Text:=NewStr('Armor Power  : '+commastr(player.apow*11));
 psARM^.Draw;

end;

var
    m : word;
    carmor : armrec;
    cweapon: weaprec;
Begin

 inherited HandleEvent(event);

  case event.what of
   EvCommand:begin
              case Event.Command of
               CmPWeapOld:begin
                           m:=player.weapon;
                           set_classic_weapon(true);
                           if m<>player.weapon then begin
                           if player.weapon=0 then cweapon.name:='*none*'
                            else load_weapon(player.weapon,cweapon);

                           Update_Item(1,cweapon.name);
                          end;
                          end;
               CmPArmOld:begin
                          m:=player.armor;
                          set_classic_weapon(false);
                          if m<>player.armor then begin
                           if player.armor=0 then carmor.name:='*none*'
                            else load_armor(player.armor,carmor);

                           Update_Item(2,carmor.name);
                          end;
                         end;
              end;

              ClearEvent(Event);
             end;
  end;

End;

{----------CLASSIC EQUIPMENT DIALOG END---------------}

{----------INVENTORY DIALOG START----------}
Constructor InvDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
    i, sx : byte;
    g : byte;
    maxl : byte;
Begin
 maxl:=25;
 sx:=09;

 TDialog.Init(Bounds, MyTitle);

 g:=0;
 for i:=1 to 8 do begin
  R.Assign(sx,2+g,sx+maxl,3+g);
  new(ps[i],init(r,'-'));
  insert(ps[i]);
  inc(g,2);
 end;

 sx:=48;
 maxl:=23;
 g:=0;
 for i:=9 to 15 do begin
  R.Assign(sx,2+g,sx+maxl,3+g);
  new(ps[i],init(r,'-'));
  insert(ps[i]);
  inc(g,2);
 end;

End;
{----------EQUIPMENT DIALOG END---------------}


{----PAGE2 DIALOG START-----}
Procedure Page2Dialog.HandleEvent(var Event:TEvent);
Begin

 inherited HandleEvent(event);

  case event.what of
   EvCommand:begin
              case event.command of
                CmPhrases:begin
                Phrase_Page; {phrase editor}
            end;

               CmCancel:begin
                         {}
                        end;
              end;
              ClearEvent(Event);
             end;
  end;

End;

Function Page2Dialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
   CmOk:begin
        {converts data from dialog to player.record}
        GetData(EdGuy2);                  {muhu}
        Transfer2(EdGuy2,Player,true);
       end;
 end;
end; { Page2Dialog.Valid }
{----PAGE2 DIALOG END------}


{-------PLAYER/NPC EDITOR START--------}
Constructor PeditDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
    s : string[15];
    hint : word;
Begin

 Load_Player(Fload,player,currp);

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,12,2);
 new(ps,init(r,'('+commastr(currp)+'/'+commastr(fs(fsplayer))+')'));
 insert(ps);

 if player.deleted then begin
  hampus:=1;
  s:='~R~evive';
  hint:=hcPeditRevive;
 end
 else begin
  hampus:=2;
  s:='~D~elete';
  hint:=hcPeditDelete;
 end;

 R.Assign(69,20,79,22);
 new(delbutt,init(R,s,cmpdelete,bfNormal+bfgrabfocus));

 delbutt^.helpctx:=hint;
 Insert(DelButt);

End;

Function PEditDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saves player rec}
        GetData(EdGuy);
        Transfer(EdGuy,Player,true);
        Load_Player(Fsave,player,currp);
       end;
 end;
end; { PEditDialog.Valid }


Procedure PeditDialog.HandleEvent(var Event:TEvent);
var i : longint;

Procedure Update_Current; {set current player Record Number/and total records}
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currp)+'/'+commastr(fs(fsplayer))+')');
 ps^.Draw;
end;

Procedure Update_Delbutton;
var s : string[15];
    r :trect;
    need : boolean;
    hint : word;
begin

 need:=false;
 if (player.deleted) and (hampus=2) then begin
  hampus:=1;
  need:=true;
 end
 else if (not player.deleted) and (hampus=1) then begin
  hampus:=2;
  need:=true;
 end;

 if need then begin
  DelButt^.done;
  dispose(delbutt);

  if player.deleted then begin
   s:='~R~evive';
   hint:=hcPeditRevive;
  end
  else begin
   s:='~D~elete';
   hint:=hcPeditDelete;
  end;

  R.Assign(69,20,79,22);
  new(delbutt,init(R,s,cmpdelete,bfNormal));
  delbutt^.helpctx:=hint;

  Insert(DelButt);

  delbutt^.draw;
 end;

end;

Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmPMore :begin {page 2 in Player Editor}
                         GetData(EdGuy);
                         Transfer(EdGuy,Player,true);
                         player_page2;
                        end;
               CmPEquip:begin {equipment dialog}
                         if Classic then begin
                          GetData(EdGuy); {jakob}
                          Transfer(EdGuy,Player,true); {jakob}
                          Equipment_Dialog_Classic(player);
                          Transfer(EdGuy,Player,false); {jakob}
                          SetData(EdGuy); {jakob}
                         end
                         else begin
                          GetData(EdGuy); {jakob}
                          Transfer(EdGuy,Player,true); {jakob}
                          Equipment_Dialog(player);
                          Transfer(EdGuy,Player,false); {jakob}
                          SetData(EdGuy); {jakob}
                         end;
                        end;
                CmPDelete:begin {DELETE/REVIVE}
                          if player.deleted then begin
                           if YesNoBox('Confirm','Revive this Character?')=true then begin
                            player.deleted:=false;
                            player.id     :=crypt(15); {unique ID tag}
                            player.married:=false;

                            edguy.name :='Need Name!';
                            edguy.alias:='Need Name!';
                            update_delbutton;
                            setdata(edguy);
                           end;
                          end
                          else begin
                           if YesNoBox('Confirm','Delete this Character?')=true then begin
                            player.deleted:=true;
                            player.id     :=crypt(15); {unique ID tag}
                            player.married:=false;

                            edguy.name :=delname1;
                            edguy.alias:=delname2;
                            update_delbutton;
                            setdata(edguy);
                           end;
                          end;
                         end;
               CmPCreate:begin {create new character}
                          if YesNoBox('Confirm','Create a New Character?')=true then begin

                           {saving current character first}
                           GetData(EdGuy);
                           Transfer(EdGuy,Player,true);
                           Load_Player(Fsave,player,currp);

                           player.name1:='New Player Name';
                           player.name2:='New Player Alias';
                           player.id   :=crypt(15); {unique ID tag}
                           player.KingVotePoll:=200; {how many days since voted for king popularity}
                           player.married     :=false;
                           player.Kids        :=0; {how many kids this playeer is father/mother to}
                           player.IntimacyActs:=5; {how many acts of intimacy has player left today?}
                           player.Pregnancy   :=0; {is player pregnant? 0=no, 1...X = days pregnant}
                           player.team        :='';
                           player.teampw      :='';
                           player.cturf       :=false; {town rulers}
                           player.gym_owner   :=0; {gym owner}
                           player.gym_card    :=0; {gym card}
                           player.Tax_Relief  :=false; {free from tax?}
                           player.MarriedTimes:=0; {counter for marriages}
                           player.Bard_Songs_Left:=0; {ehhh..quite self-explanatory huh?}
                           player.prison_escapes:=2; {allowed prison escape attempts}


                           currp:=fs(Fsplayer)+1;
                           load_player(Fsave,player,currp);

                           {loading new character}
                           load_player(Fload,player,currp);
                           Transfer(EdGuy,Player,false);
                           update_delbutton;
                           SetData(EdGuy);

                           update_current;

                           messagebox(#3'Edit New Characters name'
                            +#13+#3+'to activate him (her).'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPSearch:begin {look for user}
                          i:=look_for_user(player);
                          if i>0 then begin
                           {hit!}
                           {saving current character first}
                           GetData(EdGuy);
                           Transfer(EdGuy,Player,true);
                           Load_Player(Fsave,player,currp);

                           {loading found character}
                           currp:=i;
                           load_player(Fload,player,currp);
                           Transfer(EdGuy,Player,false);
                           update_delbutton;
                           SetData(EdGuy);

                           update_current;

                          end;
                         end;
               CmPNext:begin {load next character}

                        {save current character first}
                        GetData(EdGuy);
                        Transfer(EdGuy,Player,true);
                        Load_Player(Fsave,player,currp);

                        {loading next character}
                        if currp<fs(FsPlayer) then inc(currp)
                                              else currp:=1;

                        load_player(Fload,player,currp);
                        Transfer(EdGuy,Player,false);

                        SetData(EdGuy);

                        update_delbutton;

                        update_current;

                       end;
               CmPPrev:begin {load previous character}

                        {save current character first}
                        GetData(EdGuy);
                        Transfer(EdGuy,Player,true);
                        Load_Player(Fsave,player,currp);

                        {load previous character}
                        if currp>1 then dec(currp)
                                   else currp:=fs(fsplayer);

                        load_player(Fload,player,currp);
                        Transfer(EdGuy,Player,false);
                        SetData(EdGuy);

                        update_delbutton;

                        update_current;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------PLAYER/NPC EDITOR END--------}



{-------DOOR-GUARD DIALOG START--------}
Constructor DoorGuardDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,10,2);
 new(ps,init(r,'('+commastr(currg)+'/'+commastr(fs(fsGuard))+')'));
 insert(ps);

End;

Function DoorGuardDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving doorguard record}
        GetData(EdGuard);
        Transfer_Guard(EdGuard,Guard,true);
        Load_Guard(Fsave,guard,currg);
       end;
 end;
end;


Procedure DoorGuardDialog.HandleEvent(var Event:TEvent);
procedure update_status;
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currg)+'/'+commastr(fs(fsguard))+')');
 ps^.Draw;
end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmPSearch:begin {search for door guard}
                          i:=doorguard_search(guard);
                          if i>0 then begin
                           {hit!}
                           {saving old guard first}
                           GetData(EdGuard);
                           Transfer_Guard(Edguard,guard,true);
                           Load_Guard(Fsave,guard,currg);

                           {loading next guard}
                           currg:=i;
                           load_guard(Fload,guard,currg);
                           Transfer_Guard(EdGuard,guard,false);
                           SetData(EdGuard);

                           update_status;

                          end;
                         end;

               CmPCreate:begin {create new door guard}
                          if YesNoBox('Confirm','Create a New DoorGuard?')=true then begin

                           {saving current guard first}
                           GetData(EdGuard);
                           Transfer_Guard(EdGuard,Guard,true);
                           Load_Guard(Fsave,guard,currg);

                           guard.name:='New Guard';

                           currg:=fs(fsguard)+1;
                           load_guard(Fsave,guard,currg);

                           {loading new guard}
                           load_guard(Fload,guard,currg);
                           Transfer_Guard(EdGuard,Guard,false);
                           SetData(EdGuard);

                           update_status;

                           messagebox(#3'Edit New Guards Data'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPNext:begin {load NEXT guard}
                        {saving current guard first}
                        GetData(EdGuard);
                        Transfer_Guard(EdGuard,Guard,true);
                        Load_Guard(Fsave,guard,currg);

                        {loading next guard}
                        if currg<fs(fsguard) then inc(currg)
                                             else currg:=1;

                        load_guard(Fload,guard,currg);
                        Transfer_Guard(EdGuard,Guard,false);

                        SetData(EdGuard);

                        update_status;

                       end;
               CmPPrev:begin {load PREVIOUS guard}
                        {saving old guard first}
                        GetData(EdGuard);
                        Transfer_Guard(EdGuard,Guard,true);
                        Load_Guard(Fsave,guard,currg);

                        {loading previous guard}
                        if currg>1 then dec(currg)
                                   else currg:=fs(fsguard);

                        load_guard(Fload,guard,currg);
                        Transfer_Guard(EdGuard,Guard,false);
                        SetData(EdGuard);

                        update_status;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------DOORGUARD DIALOG END--------}

{-------MOAT DIALOG START--------}
Constructor MoatDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,10,2);
 new(ps,init(r,'('+commastr(currmoat)+'/'+commastr(fs(fsMoat))+')'));
 insert(ps);

End;

Function MoatDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving doorguard rec}
        GetData(EdMoat);
        Transfer_Moat(EdMoat,Moat,true);
        Load_Moat(Fsave,moat,currmoat);
       end;
 end;
end;


Procedure MoatDialog.HandleEvent(var Event:TEvent);
procedure update_status;
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currmoat)+'/'+commastr(fs(fsMoat))+')');
 ps^.Draw;
end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmPSearch:begin {search for moat creature}
                          i:=moat_search(moat);
                          if i>0 then begin
                           {hit!}
                           {saving old moat creature first}
                           GetData(EdMoat);
                           Transfer_Moat(EdMoat,moat,true);
                           Load_Moat(Fsave,moat,currmoat);

                           {loading next guard}
                           currmoat:=i;
                           load_moat(Fload,moat,currmoat);
                           Transfer_Moat(EdMoat,moat,false);
                           SetData(EdMoat);

                           update_status;

                          end;
                         end;

               CmPCreate:begin {create new moat creature}
                          if YesNoBox('Confirm','Create a New Moat Creature?')=true then begin

                           {saving current moat creature first}
                           GetData(EdMoat);
                           Transfer_Moat(EdMoat,Moat,true);
                           Load_Moat(Fsave,moat,currmoat);

                           {We give the new moat creature a temporary name
                            and most Important: a unique ID tag!}
                           moat.name:='New Moat Creature';
                           moat.id:=crypt(15);

                           currmoat:=fs(fsMoat)+1;
                           load_moat(Fsave,moat,currmoat);

                           {loading new moat creature}
                           load_moat(Fload,moat,currmoat);
                           Transfer_Moat(EdMoat,Moat,false);
                           SetData(EdMoat);

                           update_status;

                           messagebox(#3'Edit New Creatures Data'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPNext:begin {load NEXT moat creature}
                        {saving current moat creature first}
                        GetData(EdMoat);
                        Transfer_Moat(EdMoat,Moat,true);
                        Load_Moat(Fsave,moat,currmoat);

                        {loading next moat creature}
                        if currmoat<fs(fsMoat) then inc(currmoat)
                                                else currmoat:=1;

                        load_moat(Fload,moat,currmoat);
                        Transfer_Moat(EdMoat,Moat,false);

                        SetData(EdMoat);

                        update_status;

                       end;
               CmPPrev:begin {load PREVIOUS Moat creature}
                        {saving old creature first}
                        GetData(EdMoat);
                        Transfer_Moat(EdMoat,Moat,true);
                        Load_Moat(Fsave,moat,currmoat);

                        {loading previous moat creature}
                        if currmoat>1 then dec(currmoat)
                                      else currmoat:=fs(fsMoat);

                        load_moat(Fload,moat,currmoat);
                        Transfer_Moat(EdMoat,Moat,false);
                        SetData(EdMoat);

                        update_status;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------MOAT DIALOG END--------}

{-------GOD DIALOG START--------}
Constructor GodDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,10,2);
 new(ps,init(r,'('+commastr(currgod)+'/'+commastr(fs(fsGod))+')'));
 insert(ps);

End;

Function GodDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving god rec}
        GetData(EdGod);
        Transfer_God(EdGod,God,true);
        Load_God(Fsave,god,currgod);
       end;
 end;
end;


Procedure GodDialog.HandleEvent(var Event:TEvent);
procedure update_status;
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currgod)+'/'+commastr(fs(fsgod))+')');
 ps^.Draw;
end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmPSearch:begin {search for god}
                          i:=god_search(god);
                          if i>0 then begin
                           {hit!}
                           {saving old god first}
                           GetData(EdGod);
                           Transfer_God(EdGod,god,true);
                           Load_God(Fsave,god,currgod);

                           {loading next god}
                           currgod:=i;
                           load_god(Fload,god,currgod);
                           Transfer_God(EdGod,god,false);
                           SetData(EdGod);

                           update_status;

                          end;
                         end;

               CmPCreate:begin {create new god}
                          if YesNoBox('Confirm','Create a New God?')=true then begin

                           {saving current god first}
                           GetData(EdGod);
                           Transfer_God(EdGod,God,true);
                           Load_God(Fsave,god,currgod);

                           {We give the new God a temporary name
                            and most Importantly: a unique ID tag!}
                           god.name:='New God';
                           god.deleted:=false;

                           currgod:=fs(fsGod)+1;
                           load_god(Fsave,god,currgod);

                           {loading new god creature}
                           load_god(Fload,god,currgod);
                           Transfer_God(EdGod,God,false);
                           SetData(EdGod);

                           update_status;

                           messagebox(#3'Edit New God'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPNext:begin {load NEXT God}
                        {saving current god creature first}
                        GetData(EdGod);
                        Transfer_God(EdGod,God,true);
                        Load_God(Fsave,god,currgod);

                        {loading next god creature}
                        if currgod<fs(fsgod) then inc(currgod)
                                             else currgod:=1;

                        load_god(Fload,god,currgod);
                        Transfer_God(Edgod,god,false);

                        SetData(EdGod);

                        update_status;

                       end;
               CmPPrev:begin {load PREVIOUS God}
                        {saving old god first}
                        GetData(EdGod);
                        Transfer_God(EdGod,God,true);
                        Load_God(Fsave,god,currgod);

                        {loading previous god creature}
                        if currgod>1 then dec(currgod)
                                     else currgod:=fs(fsGod);

                        load_god(Fload,god,currgod);
                        Transfer_God(EdGod,God,false);
                        SetData(EdGod);

                        update_status;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------GOD DIALOG END--------}


{-------CHILD DIALOG START--------}
Constructor ChildDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,10,2);
 new(ps,init(r,'('+commastr(currchild)+'/'+commastr(fs(fsChild))+')'));
 insert(ps);

End;

Function ChildDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving child rec}
        GetData(EdChild);
        Transfer_Child(EdChild,Child,true);
        Load_Child(Fsave,child,currchild);
       end;
 end;
end;


Procedure ChildDialog.HandleEvent(var Event:TEvent);
procedure update_status;
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currchild)+'/'+commastr(fs(fschild))+')');
 ps^.Draw;
end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmPSearch:begin {search for child}
                          i:=child_search(child);
                          if i>0 then begin
                           {hit!}
                           {saving old child first}
                           GetData(EdChild);
                           Transfer_Child(EdChild,child,true);
                           Load_Child(Fsave,child,currchild);

                           {loading next god}
                           currchild:=i;
                           load_child(Fload,child,currchild);
                           Transfer_Child(EdChild,child,false);
                           SetData(EdChild);

                           update_status;

                          end;
                         end;

               CmPCreate:begin {create new child}
                          if YesNoBox('Confirm','Create a New Child?')=true then begin

                           {saving current child first}
                           GetData(EdChild);
                           Transfer_Child(EdChild,Child,true);
                           Load_Child(Fsave,child,currchild);

                           {We give the new Child a temporary name
                            and most Importantly: a unique ID tag!}
                           child.name:='New Child';
                           child.deleted:=false;

                           currchild:=fs(fsChild)+1;
                           load_child(Fsave,child,currchild);

                           {loading new child}
                           load_child(Fload,child,currchild);
                           Transfer_Child(EdChild,Child,false);
                           SetData(EdChild);

                           update_status;

                           messagebox(#3'Edit New Child'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPNext:begin {load NEXT Child}
                        {saving current child first}
                        GetData(EdChild);
                        Transfer_Child(EdChild,Child,true);
                        Load_Child(Fsave,child,currchild);

                        {loading next child}
                        if currchild<fs(fschild) then inc(currchild)
                                                 else currchild:=1;

                        load_child(Fload,child,currchild);
                        Transfer_Child(EdChild,child,false);

                        SetData(EdChild);

                        update_status;

                       end;
               CmPPrev:begin {load PREVIOUS Child}
                        {saving old child first}
                        GetData(EdChild);
                        Transfer_Child(EdChild,Child,true);
                        Load_Child(Fsave,child,currchild);

                        {loading previous god creature}
                        if currchild>1 then dec(currchild)
                                       else currchild:=fs(fsChild);

                        load_child(Fload,child,currchild);
                        Transfer_Child(EdChild,Child,false);
                        SetData(EdChild);

                        update_status;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------CHILD DIALOG END--------}


{-------DRINK DIALOG START--------}
Constructor DrinkDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,10,2);
 new(ps,init(r,'('+commastr(currd)+'/'+commastr(fs(fsDrink))+')'));
 insert(ps);

End;

Function DrinkDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving drink record}
        GetData(EditDrink);
        Transfer_Drink(EditDrink,Global_Drink,true);
        Load_Drink(Fsave,global_drink,currd);
       end;
 end;
end;


Procedure DrinkDialog.HandleEvent(var Event:TEvent);
procedure update_status;
begin
 DisposeStr(ps^.Text);
 ps^.Text:=NewStr('('+commastr(currd)+'/'+commastr(fs(fsdrink))+')');
 ps^.Draw;
end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmDrinkViewIng:begin {view drink ingredients}
                               drink_ingredients_editor(global_drink);
                              end;
               CmPSearch:begin {search for drink}
                          i:=drink_search(global_drink);
                          if i>0 then begin
                           {hit!}
                           {saving old drink first}
                           GetData(EditDrink);
                           Transfer_Drink(EditDrink,global_drink,true);
                           Load_Drink(Fsave,global_drink,currd);

                           {loading next drink}
                           currd:=i;
                           load_drink(Fload,global_drink,currd);
                           Transfer_Drink(EditDrink,global_drink,false);
                           SetData(EditDrink);

                           update_status;

                          end;
                         end;

               CmPNext:begin {load NEXT drink}
                        {saving current drink first}
                        GetData(EditDrink);
                        Transfer_Drink(EditDrink,Global_Drink,true);
                        Load_Drink(Fsave,global_drink,currd);

                        {loading next drink}
                        if currd<fs(fsdrink) then inc(currd)
                                             else currd:=1;

                        load_drink(Fload,global_drink,currd);
                        Transfer_Drink(EditDrink,Global_Drink,false);
                        SetData(EditDrink);

                        update_status;

                       end;
               CmPPrev:begin {load PREVIOUS drink}
                        {saving old drink first}
                        GetData(EditDrink);
                        Transfer_Drink(EditDrink,Global_Drink,true);
                        Load_Drink(Fsave,global_drink,currd);

                        {loading previous drink}
                        if currd>1 then dec(currd)
                                   else currd:=fs(fsdrink);

                        load_drink(Fload,global_drink,currd);
                        Transfer_Drink(EditDrink,global_Drink,false);
                        SetData(EditDrink);

                        update_status;

                       end;

              end;
              ClearEvent(Event);
             end;
  end; {case .end.}

End;
{-------DRINK DIALOG END--------}

{-------PHRASE DIALOG START--------}
Constructor PhraseDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
{ R.Assign(2,1,10,2);
 new(ps,init(r,'put text here'));
 insert(ps);
 }
End;

Function PhraseDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {life is great do what?}
        GetData(EditPhrase);
        Transfer_Phrases(EditPhrase,Player,true);
       end;
 end;
end;

Procedure PhraseDialog.HandleEvent(var Event:TEvent);
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              {case event.command of

              end;}
              ClearEvent(Event);
             end;
  end; {case .end.}

End;
{-------PHRASE DIALOG END--------}

{-------MONSTER EDITOR DIALOG START--------}
Function A_Deal:s70;
var s,s2 : s70;
begin


 case length(commastr(currm)) of
  1: s2:='      ';
  2: s2:='     ';
  3: s2:='    ';
  4: s2:='   ';
  5: s2:='  ';
  6: s2:=' ';
 end;

 s2:='('+commastr(currm)+')'+s2;

 s:=' (dungeon level ';
 case currm of
  1..100   : s:=s+'01-10)';
  101..200 : s:=s+'11-20)';
  201..300 : s:=s+'21-30)';
  301..400 : s:=s+'31-40)';
  401..500 : s:=s+'41-50)';
  501..600 : s:=s+'51-60)';
  601..700 : s:=s+'61-70)';
  701..800 : s:=s+'71-80)';
  801..900 : s:=s+'81-90)';
  901..1000: s:=s+'91-100)';
  else       s:=' *The final battle*';
 end;

 a_deal:=s2+s;
end;

Constructor MonsterDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
    s1,s2,s3 : string[90];
    obj : objektrec;
Begin

 load_monster(Fload,monster,currm);

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,50,2);

 new(ps,init(r,a_deal));
 insert(ps);

 {weapon & armor power}
 s1:='-none-';
 s2:='-none-';
 if monster.weapnr>0 then begin
  load_objekt(Fload,obj,weapon,monster.weapnr);
  s1:=obj.name+' (power '+commastr(obj.attack)+')';
 end;

 if monster.armnr>0 then begin
  load_objekt(Fload,obj,abody,monster.armnr);
  s2:=obj.name+' (power '+commastr(obj.armor)+')';
 end;

 R.Assign(13,12,50,13);
 new(psWEAP,init(r,s1));
 insert(psWEAP);

 R.Assign(13,14,50,15);
 new(psARM,init(r,s2));
 insert(psARM);



End;

Function MonsterDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {saving monster rec}
        GetData(EdMonster);
        Transfer_Monster(EdMonster,Monster,true);
        Load_Monster(Fsave,monster,currm);
       end;
 end;
end;


Procedure MonsterDialog.HandleEvent(var Event:TEvent);
Procedure Update_Info;
var s1,s2,s3 : string[90];
    obj : objektrec;
begin
 {updating WEAPOn / ARMOr POWEr}

 {weapon & armor power}
 s1:='-none-';
 s2:='-none-';
 if monster.weapnr>0 then begin
  load_objekt(Fload,obj,weapon,monster.weapnr);
  s1:=obj.name+' (power '+commastr(obj.attack)+')';
 end;

 if monster.armnr>0 then begin
  load_objekt(Fload,obj,abody,monster.armnr);
  s2:=obj.name+' (power '+commastr(obj.armor)+')';
 end;

 disposeStr(psWEAP^.Text);
 psWEAP^.Text:=NewStr(s1);
 psWEAP^.Draw;

 disposeStr(psARM^.Text);
 psARM^.Text:=NewStr(s2);
 psARM^.Draw;

 DisposeStr(ps^.Text);

 ps^.Text:=NewStr(a_deal);
 ps^.Draw;


end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
                CmMWeapSel:begin
                            pick_monster_item(weapon);
                            Update_Info;
                           end;
               CmMArmSel:begin
                          pick_monster_Item(abody);
                          update_info;
                         end;
               CmMGlobal:begin {global monster commands}
                          global_monster_commands;
                          {reload current monster, global changes may have taken place}
                          load_monster(Fload,monster,currm);
                          Transfer_Monster(EdMonster,monster,false);
                          SetData(EdMonster);

                          update_info;
                         end;
               CmMGoto  :begin {goto # monster}
                          i:=get_a_value_box('Goto Monster #',1,1001);

                          if i>0 then begin
                           {hit!}
                           {saving old monster first}
                           GetData(Edmonster);
                           Transfer_Monster(Edmonster,monster,true);
                           Load_Monster(Fsave,monster,currm);

                           {loading next monster}
                           currm:=i;
                           load_monster(Fload,monster,currm);
                           Transfer_Monster(EdMonster,monster,false);
                           SetData(EdMonster);

                           update_info;
                          end;

                         end;
               CmPSearch:begin {look for monster}
                          i:=monster_search(monster);
                          if i>0 then begin
                           {hit!}
                           {saving old monster first}
                           GetData(Edmonster);
                           Transfer_Monster(Edmonster,monster,true);
                           Load_Monster(Fsave,monster,currm);

                           {loading next monster}
                           currm:=i;
                           load_monster(Fload,monster,currm);
                           Transfer_Monster(EdMonster,monster,false);
                           SetData(EdMonster);

                           update_info;

                          end;
                         end;
               CmPCreate:begin {create new monster}
                          if YesNoBox('Confirm','Create a New Monster?')=true then begin

                           {saving old monster first}
                           GetData(EdMonster);
                           Transfer_Monster(EdMonster,Monster,true);
                           Load_Monster(Fsave,monster,currm);

                           monster.name:='New Monster';

                           currm:=fs(fsmonster)+1;
                           load_monster(Fsave,monster,currm);

                           {loading new monster}
                           load_monster(Fload,monster,currm);
                           Transfer_Monster(EdMonster,monster,false);
                           SetData(EdMonster);

                           update_info;

                           messagebox(#3'Edit New Monster Data'
                            ,nil,mfOkbutton+mfInformation);

                          end;
                         end;
               CmPNext:begin {loading NEXT monster}
                        {saving old monster first}
                         {i:=DataSize;
                         MessageBox('DIALOG DATASIZE : '+commastr(i), nil, mfError + mfOkButton);
                            i:=sizeof(edmonster);
                         MessageBox('MONSTER DATASIZE : '+commastr(i), nil, mfError + mfOkButton);
                        }
                        GetData(EdMonster);
                        Transfer_Monster(Edmonster,Monster,true);
                        Load_Monster(Fsave,monster,currm);

                        {loading next monster}
                        if currm<fs(fsmonster) then inc(currm)
                                         else currm:=1;

                        load_monster(Fload,monster,currm);
                        Transfer_Monster(EdMonster,Monster,false);

                        SetData(EdMonster);

                        update_info;

                       end;
               CmPPrev:begin {loading PREVIOUS monster}
                        {saving old monster first}
                        GetData(EdMonster);
                        Transfer_Monster(EdMonster,Monster,true);
                        Load_Monster(Fsave,monster,currm);

                        {loading previous monster}
                        if currm>1 then dec(currm)
                                   else currm:=fs(fsmonster);

                        load_monster(Fload,monster,currm);
                        Transfer_Monster(EdMonster,Monster,false);
                        SetData(EdMonster);

                        update_info;

                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------MONSTER EDITOR DIALOG END--------}


{-------CHECKING DEPENDENCIES, DIALOG START--------}
Constructor DependDialog.Init(var Bounds:TRect; MyTitle: TTitleStr;ra:word;pry:objektrec);
var r : trect;
Begin
 TDialog.Init(Bounds, MyTitle);

 doneit:=false;
 rand:=ra;
 pryl:=pry;
end;

Procedure DependDialog.HandleEvent(var Event:TEvent);
var mad : byte;
    i : word;
    suck :boolean;
    s : s70;
begin

 {Inherited HandleEvent(Event);}

 if doneit=false then begin
  doneit:=true;
  {* NPC & USER FILERNA *}
  for mad:=1 to 2 do begin
   case mad of
    1:begin
       assign(playerfile,global_pfile);
       s:=global_pfile;
      end;
    2:begin
       assign(playerfile,global_npfile);
       s:=global_npfile;
      end;
   end;

   if f_exists(s) then begin

    for i:=1 to fs(fsplayer) do begin
     load_player(Fload,player,i);
     suck:=false;

     if player.lhand=rand then begin
      objekt_affect(2,rand,weapon,player);
      suck:=true;
     end;

     if player.rhand=rand then begin
      objekt_affect(2,rand,weapon,player);
      suck:=true;
     end;

     if player.head=rand then begin
      objekt_affect(2,rand,head,player);
      suck:=true;
     end;

     if player.body=rand then begin
      objekt_affect(2,rand,body,player);
      suck:=true;
     end;

     if player.arms=rand then begin
      objekt_affect(2,rand,arms,player);
      suck:=true;
     end;

     if player.lfinger=rand then begin
      objekt_affect(2,rand,fingers,player);
      suck:=true;
     end;

     if player.rfinger=rand then begin
      objekt_affect(2,rand,fingers,player);
      suck:=true;
     end;

     if player.legs=rand then begin
      objekt_affect(2,rand,legs,player);
      suck:=true;
     end;

     if player.feet=rand then begin
      objekt_affect(2,rand,feet,player);
      suck:=true;
     end;

     if player.waist=rand then begin
      objekt_affect(2,rand,waist,player);
      suck:=true;
     end;

     if player.neck=rand then begin
      objekt_affect(2,rand,neck,player);
      suck:=true;
     end;

     if player.neck2=rand then begin
      objekt_affect(2,rand,neck,player);
      suck:=true;
     end;

     if player.face=rand then begin
      objekt_affect(2,rand,face,player);
      suck:=true;
     end;

     if player.shield=rand then begin
      objekt_affect(2,rand,shield,player);
      suck:=true;
     end;

     if player.hands=rand then begin
      objekt_affect(2,rand,hands,player);
      suck:=true;
     end;

     if player.abody=rand then begin
      objekt_affect(2,rand,abody,player);
      suck:=true;
     end;

     if suck=true then begin
      load_player(FSave,player,i);
     end;
    end;
   end;
  end;

  Load_Objekt(Fsave,pryl,pryl.ttype,rand);

   {* NPC & USER FILERNA *}
  for mad:=1 to 2 do begin
   case mad of
    1:begin
       assign(playerfile,global_pfile);
       s:=global_pfile;
      end;
    2:begin
       assign(playerfile,global_npfile);
       s:=global_npfile;
      end;
   end;

   if f_exists(s) then begin
    for i:=1 to fs(fsplayer) do begin
     load_player(Fload,player,i);
     suck:=false;

     if player.lhand=rand then begin
      objekt_affect(1,rand,weapon,player);
      suck:=true;
     end;

     if player.rhand=rand then begin
      objekt_affect(1,rand,weapon,player);
      suck:=true;
     end;

     if player.head=rand then begin
      objekt_affect(1,rand,head,player);
      suck:=true;
     end;

     if player.body=rand then begin
      objekt_affect(1,rand,body,player);
      suck:=true;
     end;

     if player.arms=rand then begin
      objekt_affect(1,rand,arms,player);
      suck:=true;
     end;

     if player.lfinger=rand then begin
      objekt_affect(1,rand,fingers,player);
      suck:=true;
     end;

     if player.rfinger=rand then begin
      objekt_affect(1,rand,fingers,player);
      suck:=true;
     end;

     if player.legs=rand then begin
      objekt_affect(1,rand,legs,player);
      suck:=true;
     end;

     if player.feet=rand then begin
      objekt_affect(1,rand,feet,player);
      suck:=true;
     end;

     if player.waist=rand then begin
      objekt_affect(1,rand,waist,player);
      suck:=true;
     end;

     if player.neck=rand then begin
      objekt_affect(1,rand,neck,player);
      suck:=true;
     end;

     if player.neck2=rand then begin
      objekt_affect(1,rand,neck,player);
      suck:=true;
     end;

     if player.face=rand then begin
      objekt_affect(1,rand,face,player);
      suck:=true;
     end;

     if player.shield=rand then begin
      objekt_affect(1,rand,shield,player);
      suck:=true;
     end;

     if player.hands=rand then begin
      objekt_affect(1,rand,hands,player);
      suck:=true;
     end;

     if player.abody=rand then begin
      objekt_affect(1,rand,abody,player);
      suck:=true;
     end;

     if suck=true then begin
      load_player(Fsave,player,i);
     end;
    end;
   end;
  end;

  endmodal(cmclose);
 { With Event do begin
   What    := evCommand;
   Command := cmClose;
  end;
  PutEvent(Event);}
 end;

 Inherited HandleEvent(Event);

end;

{-------CHECKING DEPENDENCIES, DIALOG END--------}

{-------ITEM EDITOR, DIALOG START--------}
Constructor ItemEditDialog.Init(var Bounds:TRect; MyTitle: TTitleStr);
var r : trect;
Begin

 TDialog.Init(Bounds, MyTitle);
 R.Assign(2,1,30,2);

 curri:=1;
 load_objekt(Fload,item,weapon,curri);
 memobj:=item; {setting this so the proc CHECK_ITEM can work}

 new(ps,init(r,item_disp(item.ttype)+' ('+commastr(curri)+'/'+commastr(fso(item.ttype))+')'));

 insert(ps);

End;

Function ItemEditDialog.Valid(Command: Word): Boolean;
begin
 Valid := true;
 case Command of
  CmOk:begin
        {sparar item rec}
        GetData(EdItem);
        Transfer_Item(EdItem,Item,true);
        {beh”ver item sparas?}
        check_item(item,curri);
       end;
 end;
end;


Procedure ItemEditDialog.HandleEvent(var Event:TEvent);
Procedure Update_Info;
begin
 DisposeStr(ps^.Text);

 ps^.Text:=NewStr(item_disp(item.ttype)+' ('+commastr(curri)+'/'+commastr(fso(item.ttype))+')');
 ps^.Draw;
 memobj:=item; {setting this so the proc CHECK_ITEM can work}

end;

var i : longint;
Begin

 inherited HandleEvent(event);

  case event.what of
   evcommand:begin
              case event.command of
               CmRestrict:begin {class restrict item}
                           item_class_restrictions(item);
                          end;
               CmIOptions:begin {import/export items}
                            item_file_operations(item.ttype);
                           end;
               CmPSearch:begin {s”ka efter item}
                          i:=leta_efter_item(item);
                          if i>0 then begin
                           {tr„ff!}
                           {sparar gamla itemet f”rst}
                           GetData(EdItem);
                           Transfer_Item(Editem,item,true);

                           {beh”ver item sparas?}
                           check_item(item,curri);

                           {laddar n„sta item}
                           curri:=i;
                           load_objekt(Fload,item,item.ttype,curri);

                           Transfer_Item(Editem,item,false);
                           SetData(Editem);

                           update_info;

                          end;
                         end;
               CmIType:begin {v„lja ny ITEM TYP}
                        {sparar gamla itemet f”rst}
                        GetData(EdItem);
                        Transfer_Item(EdItem,Item,true);
                        {beh”ver item sparas?}
                        check_item(item,curri);

                        Item_Type_Selector;
                        curri:=1;
                        load_objekt(Fload,item,global_type,curri);

                        Transfer_Item(EdItem,item,false);
                        SetData(EdItem);

                        update_info;
                       end;
               CmPCreate:begin {skapa nytt item}
                          if YesNoBox('Confirm','Create a New Item?')=true then begin

                           {sparar gamla itemet f”rst}
                           GetData(EdItem);
                           Transfer_Item(EdItem,Item,true);

                           {beh”ver item sparas?}
                           check_item(item,curri);

                           item.name:='New Item';

                           curri:=fso(item.ttype)+1;
                           load_objekt(Fsave,item,item.ttype,curri);

                           {laddar nya itemet}
                           load_objekt(Fload,item,item.ttype,curri);
                           Transfer_Item(EdItem,item,false);
                           SetData(EdItem);

                           messagebox(#3'Edit New Item Data'
                            ,nil,mfOkbutton+mfInformation);

                           update_info;

                          end;
                         end;
               CmPNext:begin {ladda n„sta item}
                        {sparar gamla itemet f”rst}
                        GetData(EdItem);
                        Transfer_Item(EdItem,Item,true);

                        {beh”ver item sparas?}
                        check_item(item,curri);

                        {laddar n„sta item}
                        if curri<fso(item.ttype) then inc(curri)
                                                 else curri:=1;

                        load_objekt(Fload,item,item.ttype,curri);
                        Transfer_Item(EdItem,Item,false);

                        SetData(EdItem);

                        update_info;
                       end;
               CmPPrev:begin {ladda f”reg†ende item}
                        {sparar gamla itemet f”rst}
                        GetData(EdItem);
                        Transfer_Item(EdItem,Item,true);

                        {beh”ver item sparas?}
                        check_item(item,curri);

                        {laddar f”reg†ende item}
                        if curri>1 then dec(curri)
                                   else curri:=fso(item.ttype);

                        load_objekt(Fload,item,item.ttype,curri);
                        Transfer_Item(EdItem,Item,false);
                        SetData(EdItem);

                        update_info;
                       end;
              end;
              ClearEvent(Event);
             end;
  end;

End;
{-------ITEM EDITOR, DIALOG END--------}


{-------LISTBOX OBJECT--------}
Procedure Rlistbox.Process;
var i : integer;
    s : string[120];
Begin

 {building config options to NameList}

 NameList:=New(Pstringcollection,Init(global_maxcdef,1));
 for i:=1 to global_maxcdef do begin
  s:=cfg_default(i);
  s:=s+cfgvalue[i];
  NameList^.ATInsert(i-1,Newstr(s));

  cfgback[i]:=cfgvalue[i]; {backup}
 end; {for i:= .end.}

End;

Procedure RListBox.HandleEvent(var Event:TEvent);
begin

 if (Event.What = EvMouseDown) and (Event.Double) then begin
  Message(Owner,EvBroadCast,CatchNum,list^.at(focused));
  Draw;
  ClearEvent(Event);
 end
 else if (Event.What = EvKeyDown) and (Event.KeyCode = KbEnter) then begin
  Message(Owner,evBroadCast,CatchNum,list^.at(focused));
  Draw;
  ClearEvent(event);
 end
 else if (Event.What = Evkeydown) and (Event.CharCode = ' ') then begin
  Message(Owner,evBroadCast,CatchNum,list^.at(focused));
  Draw;
  ClearEvent(Event);
 end
 else inherited HandleEvent(event);


end;
{-------LISTBOX OBJECT END--------}

{-------LISTBOX (EQUIPMENT ) OBJECT--------}
Procedure Elistbox.Process;
const xl = 30;
var i : integer;
    s : string;
    s2 : string[6];
    obj : objektrec;
    max,diff : word;
Begin

 max:=fso(typ);
 NameList:=New(Pstringcollection,Init(max,1));

 for i:=1 to max do begin
  load_objekt(Fload,obj,typ,i);
  case i of                {„ndrar du dessa mellanrum s† m†ste „ven S™K RUTINERNA „ndras lite}
                           {de radererar blanks innan s”kning}
   0..9         : s2:='  '+commastr(i);
   10..99       : s2:=' '+commastr(i);
   else s2:=commastr(i);
  end;
  s:=s2+' '+obj.name;

  if length(s)>xl then begin
   diff:=length(s)-xl;
   delete(s,xl+1,99);
  end
  else if length(s)<xl then begin
   diff:=xl-length(s);
   s:=s+mkstring(diff,' ');
  end;

  {armor & attack info}
  case typ of
   Weapon: s:=s+' (attack '+commastr(obj.attack)+')';
   else s:=s+' (armor '+commastr(obj.armor)+')';
  end;

  NameList^.ATInsert(i-1,Newstr(s));
 end;

End;

Procedure EListBox.HandleEvent(var Event:TEvent);
begin

 if (Event.What = evMouseDown) and (Event.Double) then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.KeyCode = KbEnter) then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.CharCode = ' ') then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else inherited HandleEvent(event);


end;
{-------LISTBOX (EQUIPMENT) OBJECT END--------}

{-------CLASSIC LISTBOX (WEAPON/ARMOR) START--------}
Procedure Clistbox.Process;
const xl = 30;
var i : integer;
    s : string;
    s2 : string[6];
    obj : objektrec;
    max,diff : word;
    carmor : armrec;
    cweapon : weaprec;
Begin

 max:=fsclassic(vapen);

 NameList:=New(Pstringcollection,Init(max,1));

 for i:=1 to max do begin
  if vapen then load_weapon(i,cweapon)
           else load_armor(i,carmor);

  case i of                {„ndrar du dessa mellanrum s† m†ste „ven S™K RUTINERNA „ndras lite}
                           {de radererar blanks innan s”kning}
   0..9         : s2:='  '+commastr(i);
   10..99       : s2:=' '+commastr(i);
   else s2:=commastr(i);
  end;

  if vapen then s:=s2+' '+cweapon.name
           else s:=s2+' '+carmor.name;

  if length(s)>xl then begin
   diff:=length(s)-xl;
   delete(s,xl+1,99);
  end
  else if length(s)<xl then begin
   diff:=xl-length(s);
   s:=s+mkstring(diff,' ');
  end;

  {armor & attack info}
   if vapen then s:=s+' (attack '+commastr(cweapon.pow*11)+')'
            else s:=s+' (armor '+commastr(carmor.pow*11)+')';

  NameList^.ATInsert(i-1,Newstr(s));
 end;
End;

Procedure CListBox.HandleEvent(var Event:TEvent);
begin

 if (Event.What = evMouseDown) and (Event.Double) then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.KeyCode = KbEnter) then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.CharCode = ' ') then begin
  Message(Owner,evBroadCast,cmEqCatchMe,list^.at(focused));
  draw;
  clearevent(event);
 end
 else inherited HandleEvent(event);

end;
{-------CLASSIC LISTBOX (WEAPON/ARMOR) END--------}



{-------Level Editor LISTBOX START--------}
Procedure Llistbox.Process;
var i,max : word;
    s:string;
Begin

 max:=fs(fslevel);

 NameList:=New(Pstringcollection,Init(max,1));

 for i:=1 to max do begin
  load_level(Fload,level,i);
  case i of
   0..9   :s:=commastr(i)+'  ';
   10..99 :s:=commastr(i)+' ';
   else    s:=commastr(i);
  end;

  s:='Level '+s+' : '+commastr(level.xpneed);
  NameList^.ATInsert(i-1,Newstr(s));
 end;

End;

Procedure LListBox.HandleEvent(var Event:TEvent);
begin

 if (Event.What = evMouseDown) and (Event.Double) then begin
  Message(Owner,evBroadCast,CatchNum,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.KeyCode = KbEnter) then begin
  Message(Owner,evBroadCast,CatchNum,list^.at(focused));
  draw;
  clearevent(event);
 end
 else if (event.what = evkeydown) and (event.CharCode = ' ') then begin
  Message(Owner,evBroadCast,CatchNum,list^.at(focused));
  draw;
  clearevent(event);
 end
 else inherited HandleEvent(event);

end;
{-------Level Editor LISTBOX END--------}


{-------MAIN MENU OBJECT--------}
Function TopDialog.Valid(Command: Word): Boolean;
var b : boolean;
begin
 Valid := true;
 case Command of
  CmCancel,
  CmQuit  :begin

            if YesNoBox('Warning','Quit?')=true then begin
             b:=true;
            end
            else begin
             b:=false;
            end;

            if b=true then begin
             valid:=save_request;
            end
            else begin
             valid:=false;
            end;

           end;
 end;

end; { TopDialog.Valid }

Procedure TopDialog.HandleEvent(var Event:TEvent);
var KillGods : boolean;
    CancelReset : boolean;
    result : integer;
Begin

 inherited HandleEvent(event);

 {Borland Pascal Help for CM commands look up : cmxx VIEWS}

 if Event.What=EvCommand then begin
  case event.command of
   cmQuit       :begin {Quit Editor}
                  Save_Request;
                  if YesNobox('Warning','Quit?')=True then begin
                   EndModal(cmClose);
                  end;
                 end;
   cmResetGame  :begin {Reset Game}

                  if YesNoBox('Warning','Reset Usurper?')=true then begin

                   if YesNoBox('Reset Game','Are you really sure?')=true then begin

                    KillGods:=false;
                    CancelReset:=false;

                    {the data files below can be edited by sysop/user
                    and we should therefore give the option to exclude
                    these files from deletion/reset}

                    {the immortals can live on after a reset.}
                    {personally I would save the Gods here.}
                    if f_exists(godsf) then begin
                     result:=MessageBox(
                     #13 +
                     ^C'Kill the IMMORTAL characters?'+
                     #13 +
                     #13 +
                     ^C' '#13 +
                     #13 +
                     ^C' ',nil,mfYesNoCancel+mfConfirmation);

                     case result of
                      cmYes   :begin
                                killgods:=true;
                               end;
                      cmNo    :begin
                                killgods:=false;
                               end;
                      cmCancel:begin
                                CancelReset:=true;
                               end;
                     end; {case .end.}

                    end;

                    {Did user really want to reset the game?}
                    if CancelReset=false then begin
                     {I guess he did...LET'S RESET!!}
                     Reset_Game(true,killgods);
                    end;

                   end;
                  end;
                 end;
   cmResetData  :begin {Reset Datafiles}
                  Reset_DataFiles;
                 end;
   cmPEditor    :begin {Player Editor}
                  if registered=1 then begin
                   if NOT f_exists(global_pfile) then begin
                    MessageBox(#3'No User file has been Created!',nil,mfwarning or mfokbutton);
                   end
                   else begin
                    global_humans:=true;
                    currp:=1;
                    player_editor;
                   end;
                  end
                  else begin
                   MessageBox(#3+onlyin,nil,mfinformation or mfokbutton);
                  end;
                 end;
   cmNpcEditor  :begin {NPC Editor}
                  if registered=1 then begin
                   if NOT f_exists(global_npfile) then begin
                    messagebox(#3'No NPC file has been Created!',nil,mfinformation or mfokbutton);
                   end
                   else begin
                    global_humans:=false;
                    currp:=1;
                    player_editor;
                   end;
                  end
                  else begin
                   messagebox(#3+onlyin,nil,mfinformation or mfokbutton);
                  end;
                 end;
   cmItemEditor :begin {Item Editor}
                  Item_Editor;
                 end;
   cmMonEditor  :begin {Monster Editor}
                  if registered=1 then begin
                   if NOT f_exists(monfile) then begin
                    messagebox(#3'No Monster file has been Created!',nil,mfinformation or mfokbutton);
                   end
                   else begin
                    Monster_Editor;
                   end;
                  end
                  else begin
                   messagebox(#3+onlyin,nil,mfinformation or mfokbutton);
                  end;
                 end;
   cmDoorEditor :begin {DoorGuard Editor}
                  if registered=1 then begin
                   if NOT f_exists(gufile) then begin
                    MessageBox(#3'No DoorGuard file has been Created!',nil,mfinformation or mfokbutton);
                   end
                   else begin
                    Doorguard_Editor;
                   end;
                  end
                  else begin
                   MessageBox(#3+onlyin,nil,mfinformation or mfokbutton);
                  end;
                 end;
   cmOptions    :begin {Options}
                  options_menu;
                 end;
   cmConfig     :begin  {Configuration Editor}
                  Config_editor;
                 end;
   cmMoreEditors:begin {"more editors" menu}
                  more_editors_menu;
                 end;

   cmAbout      :begin {About the Editor}
                  about;
                 end;

  end;
  ClearEvent(event);
 end;

End;


{-------MAIN MENU OBJECT END--------}

{View ViewText Dialog ***START***}
Procedure ViewTextDialog.HandleEvent(var Event:TEvent);
procedure Show_Me(s:string);
begin

 if f_exists(s) then begin
  View_As_Text(CalcHelpName(s));
 end
 else begin
  MessageBox(#3'File not Found : '+s, nil,mfWarning+mfOkButton);
 end;

end;
Begin

 inherited HandleEvent(event);

 if Event.What=EvCommand then begin
  case Event.Command of
   cmWhatsNew   : show_me(WhatsNewFile);
   cmSysopDoc   : show_me(SysopDoc);
   cmUsurperDoc : show_me(UsurperDoc);
   cmReadMe     : show_me(ReadMeFile);
   cmSupportDoc : show_me(SupportDoc);
   cmFutureDoc  : show_me(FutureDoc);
  end;
  ClearEvent(Event);
 end;

End; {View ViewText Dialog ***END***}

{Options Dialog ***START***}
Procedure OptionsDialog.HandleEvent(var Event:TEvent);
var r : trect;
Begin

 inherited HandleEvent(event);

 if Event.What=EvCommand then begin
  case Event.Command of
   cmDocFiles      : ViewTextsMenu;
   cmOptionsToggle : MyApp.ToggleVideoMode;
   cmODosShell     : myapp.Dosshell;
  end;
  ClearEvent(Event);
 end;

End; {Options Dialog ***END***}

{More_Editors Dialog ***START***}
Procedure MoreEditorsDialog.HandleEvent(var Event:TEvent);
var r : trect;
Begin

 inherited HandleEvent(event);

 if Event.What=EvCommand then begin

  case Event.Command of
   cmGodEditor    :begin {god editor}
                    if NOT f_exists(godsf) then begin
                      MessageBox(#3'No God file has been created!',nil,mfinformation or mfokbutton);
                     end
                     else begin
                      God_Editor;
                     end;
                   end;
   cmChildEditor    :begin {child editor}
                    if NOT f_exists(childrenf) then begin
                      MessageBox(#3'No Child file has been created!',nil,mfinformation or mfokbutton);
                     end
                     else begin
                      Child_Editor;
                     end;
                   end;

   cmLevelEditor  :begin {Level Editor}
                    if registered=1 then begin
                     if NOT f_exists(lvlfile) then begin
                      MessageBox(#3'No Level file has been Created!',nil,mfinformation or mfokbutton);
                     end
                     else begin
                      Level_Editor;
                     end;
                    end
                    else begin
                     MessageBox(#3+onlyin,nil,mfinformation or mfokbutton);
                    end;
                   end;
   cmDrinkEditor  :begin {Drink Editor}

                    if NOT f_exists(drinkfile) then begin

                     if YesNoBox('Warning','Could not find : '+drinkfile+
                         #13+#13+' Would you like to create it?')=true then begin

                      if init_drinkfile then begin
                       {create a new custom user drinkfile
                       this proc is residing in file_io.pas}
                       drink_editor;
                      end;

                     end
                     else begin
                      {}
                     end;

                    end
                    else begin
                     Drink_Editor;
                    end;
                   end;
   cmMoatEditor  :begin {Moat Creatures Editor}

                    if (f_exists(motfile)=false) or (fs(fsmoat)=0) then begin

                     MessageBox(#3'Could not find : '+motfile,nil,mfinformation or mfokbutton);

                    end
                    else begin
                     Moat_Editor;
                    end;

                   end;

  end; {case .end.}

  ClearEvent(Event);

 end;

End; {More_Editors Dialog ***END***}

{Global Monster Dialog ***START***}
Procedure GlobalMonsterDialog.HandleEvent(var Event:TEvent);
var r : trect;
    i,j : word;
   tempmonster:monsterrec;
  save_need : boolean;

  dia : XDialogP;
Begin

 inherited HandleEvent(event);

 if Event.What=EvCommand then begin

  case Event.Command of
   cmMGrmvSpells :begin

                   if YesNoBox('Remove Spells','Are you sure?')=true then begin

                    {Setup Wait Dialog}
                    Dia:=Waitdialog('Information','Removing Spells. Please Wait...');

                    MyApp.Insert(Dia);

                    for i:=1 to fs(FsMonster) do begin

                     load_monster(fload,tempmonster,i);

                     save_need:=false;
                     for j:=1 to maxmspells do begin
                      if tempmonster.spell[j]=true then begin
                       save_need:=true;
                      end;
                      tempmonster.spell[j]:=false;
                     end;

                     if save_need then begin
                      load_monster(fsave,tempmonster,i);
                     end;

                    end; {for i:= .end.}

                    {Remove Wait Dialog}
                    MyApp.Delete(Dia);
                    Dia^.Done;
                    Dispose(Dia);

                    MessageBox(#3'All Spells Removed.', nil,mfinformation or mfokbutton);
                   end;

                  end;
  end; {case .end.}

  ClearEvent(Event);

 end;

End; {GlobalMonster Dialog ***END***}

begin

 {no init code here, yet}

end. {Unit Init .end.}
