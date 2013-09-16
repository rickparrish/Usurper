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


Unit Init; {Usurper Init & Structure code}

Interface  {see CMS.pas for more constants.
            see InitGods.pas for God related stuff}

{Uses}
Type
 {String types}
 s3   = string[3];
 s4   = string[4];
 s14  = string[14];
 s15  = string[15];
 s10  = string[10];
 s20  = string[20];
 s25  = string[25];
 s30  = string[30];
 s40  = string[40];
 s70  = string[70];
 s80  = string[80];
 s90  = string[90];
 s100 = string[100];
 s120 = string[120];

{Date Type, used by ALL record type DATE definitions in the game (usually defined in record structures)}
type UDate = string[8];

{Character AI Type, used by various procs to verify NPC or human controlled character}
{type CharacterAI = (Computer,Human);

{FileType, Used by file procedures/functions}
type FilAction = (FLock,FUnlock,FLoad,FSave);

{used by relation relation procedures/functions}
type RelationCommand = (Relation_Better,Relation_Worsen);

Const
 ReturnKey = #13; {just here for making the source code more ReadAble}
 EscapeKey = #27; {same thing goes for this!}
 DeleteKey = #8;  {and this...}
 MaxInput_key = '>'; {used in input routines to get max numeric value}

 global_delname1 = 'EMPTY'; {name given to deleted players}
 global_delname2 = 'EMPTY'; {alias given to deleted players}

 {Ansi stuff}
 acc     = '`'; {ansi control char. used by Usurpers own ansi code system
                 see below for more information regarding this system}

 {internal ansi control codes}
 ublack  = acc+'00';
 ublue   = acc+'01';
 ugreen  = acc+'02';
 ucyan   = acc+'03';
 ured    = acc+'04';
 umag    = acc+'05';
 ubrown  = acc+'06';
 ulgray  = acc+'07';
 udgray  = acc+'08';
 ulblue  = acc+'09';
 ulgreen = acc+'10';
 ulcyan  = acc+'11';
 ulred   = acc+'12';
 ulmag   = acc+'13';
 uyellow = acc+'14';
 uwhite  = acc+'15';

 {background colors, control codes}
 BackUBlack  = acc+'20'; {black}
 BackUBlue   = acc+'21'; {blue}
 BackUGreen  = acc+'22'; {green}
 BackUCyan   = acc+'23'; {cyan}
 BackURed    = acc+'24'; {red}
 BackUMagenta= acc+'25'; {magenta}
 BackUBrown  = acc+'26'; {brown}
 BackULGray  = acc+'27'; {light-gray}

 {news/mail colors}
 uplc  :s3 = ulgreen; {color players get in ANSI news, see also global_plycol}
 ukidc :s3 = ulgreen; {color kids get in ANSI news, see also global_kidcol}
 ugodc :s3 = ulgreen; {color gods get in ANSI news, see also global_godcol}
 ukingc:s3 = ulgreen; {color king/queen get in ANSI news, see also global_kingcol}
 utec  :s3 = ucyan;   {color teams get in ANSI news}
 urac  :s3 = ugreen;  {color races get in ANSI news}
 uestabc:s3 = ulmag; {color for establishments in news}
 uquestc:s3 = ulblue; {color for the word QUEST in quests}
 uguardc:s3 = ulred; {color for doorguards in news}
 umonc  :s3 = ulred; {color for monsters in news -see also global_moncol}
 utalkc :s3 = ulmag; {color for phrases in news, see also global_talkcol}
 uitemc :s3 = ulcyan; {color for items in news, see also global_itemcol}
 umailheadc:s3 = ucyan; {color for header in player mail}
 urelationc:s3 = ubrown; {color for social relations}
 udrinkc :s3   = ulblue; {color for the drinks and cocktails}

Const

 {Directories}
{$IFDEF UNIX}
 DIRECTORY_SEPARATOR = '/';
{$ENDIF}
{$IFNDEF UNIX}
 DIRECTORY_SEPARATOR = '\';
{$ENDIF}
 global_datadir ='DATA' + DIRECTORY_SEPARATOR;   {Path to DATA directory}
 global_docsdir ='DOCS' + DIRECTORY_SEPARATOR;   {Path to DOCS directory}
 global_nodedir ='NODE' + DIRECTORY_SEPARATOR;   {Path to NODE directory}
 global_scoredir='SCORES' + DIRECTORY_SEPARATOR; {Path to SCORE and NEWS directory}

 {Files and their Paths}
 global_ucfg     = 'USURPER.CFG'; {Usurper configuration file}
 global_textdataf= 'USUTEXT.DAT'; {all ansi/ascii pictures, located in the datadir}
 global_pfile    = global_datadir+'USERS.DAT'; {user file}
 global_npfile   = global_datadir+'NPCS.DAT';  {npc file}
 global_monfile  = global_datadir+'MONSTER.DAT'; {monster file}
 global_fakefile = global_datadir+'FAKES.DAT'; {fake player data file}
 global_lvlfile  = global_datadir+'LEVELS.DAT'; {level limits file}
 global_mafile   = global_datadir+'MAIL.DAT';   {mail file}
 global_armofile = global_datadir+'ARMOR.DAT';  {classic armor file}
 global_weapofil = global_datadir+'WEAPON.DAT'; {classic weapon file}
 global_saffile  = global_datadir+'BANKSAFE.DAT'; {bank safe file}
 global_wwfile   = global_datadir+'WANTED.DAT';   {most wanted file}
 global_gufile   = global_datadir+'GUARDS.DAT'; {door guard file}
 global_moatfile = global_datadir+'MOATMON.DAT'; {moat creatures, protects the Castle}
 global_innfile1 = global_datadir+'COMMENTS.ANS'; {inn chat file (ANSI)}
 global_innfile2 = global_datadir+'COMMENTS.ASC'; {inn chat file (ASCII)}
 global_datefile = global_datadir+'DATE.DAT'; {date file, when to run maintenance}
 global_famefile = global_datadir+'FAME.DAT'; {list of heroes who comleted the game}
 global_truthfile1 = global_datadir+'TRUTH.ANS'; {truthfile, displayed at the beginning}
 global_truthfile2 = global_datadir+'TRUTH.ASC'; {ascii truthfile}
 global_marketfile = global_datadir+'PLMARKET.DAT'; {player market file}
 global_chestfile  = global_datadir+'CHEST.DAT'; {home chest items}
 global_godfil     = global_datadir+'GODS.DAT'; {the gods}
 global_drinkfile  = global_datadir+'DRINKS.DAT'; {the orbs bar, customers own drinks}
 global_indianfile = global_datadir+'INDIAN.DAT'; {indian wrestling in the UMAN caves, event}
 global_tnames     = global_datadir+'TNAMES.DAT'; {team names used by npc gangs, ASCII}
 global_kingf      = global_datadir+'KING.DAT'; {king orders, opened shops etc etc}
 global_rquestf    = global_datadir+'RQUESTS.DAT'; {royal quests}
 global_relationf  = global_datadir+'RELATION.DAT'; {social relations between players}
 global_childrenf  = global_datadir+'CHILDREN.DAT'; {children database}
 global_childmalef =global_datadir+'CHILDMAL.DAT'; {children, male names *used by npcs*}
 global_childfemalef=global_datadir+'CHILDFEM.DAT';{children, female names *used by npcs*}
 global_bardsongf = global_datadir+'BARDSONG.DAT'; {bard song file}
 global_barrelf   = global_datadir+'BARRELS.DAT'; {beer barrel lifters top X list}
 global_badfile   = global_datadir+'BADWORDS.DAT'; {sysop can place names here if she wants
                                       to replace certain words with proper ones}
 Global_VersionF   = global_datadir+'VERSION.DAT'; {stores version number for data files, used by UPGRADE.PAS}

 global_teamrecordf= global_datadir+'TEAMREC.DAT'; {record fil with current gang record}
 global_teamrectxt = global_datadir+'TRECORD.DAT'; {txtfil, team records for holding TOWN}

 {list of monarchs, comings and goings}
 global_MonarchsANSI = global_scoredir+'MONARCHS.ANS';
 global_MonarchsASCI = global_scoredir+'MONARCHS.ASC';

 {list of gods, comings and goings}
 global_GodsANSI = global_scoredir+'GODS.ANS';
 global_GodsASCI = global_scoredir+'GODS.ASC';

 {list of marriages}
 global_MarrHistANSI = global_scoredir+'MARRHIST.ANS';
 global_MarrHistASCI = global_scoredir+'MARRHIST.ASC';

 {list of child-births}
 global_ChildBirthHistANSI = global_scoredir+'BIRTHIST.ANS';
 global_ChildBirthHistASCI = global_scoredir+'BIRTHIST.ASC';

 {temporary files, path to these files can be defined by sysop in editor.exe}
 global_onfile   : s100 ='ONLINERS.DAT';
 global_maintfile: s100 ='MAINT.FLG';

 {Global Constants}
 global_online_maxwaits = 4500; {polling other online players...wait how many ticks}
 global_online_maxwaits_bigloop = 50000; {wait how many ticks before a player has waited too long}

 global_maxplayers  = 400; {max number of players the game can handle}
 global_maxteammembers = 5; {max members in a team}
 global_maxallows   = 15;  {toggles active allow items. Should head items be used in game ..und so weiter..}
 global_maxnod      = 5;   {max rows used by online functions}
 global_maxmon      = 17;  {max number of monsters active at the same time, ALERT! WARNING! QUESTREC is dependant on this!}
 global_maxmspells  = 6;   {max number of monster spells}
 global_maxitem     = 15;  {max number of items a player can have in his inventory}
 global_maxhittas   = 450; {max number of objects that can be found in the dungeons}
 global_maxspells   = 12;  {max spells available}
 global_maxcombat   = 14;  {max close combat moves}
 global_maxclasses  = 11;  {max classes}
 global_maxraces    = 10;  {max races}
 global_maxbarrelmasters=15; {# of names in the "barrel masters" top list}

 global_maxinput    = 2000000000; {maximum numeric input allowed}
 global_maxmaillines= 15;  {max # of lines in MailRecord, it isn't enough to change just here though!}
 global_npcmark     = '*'; {marks npcs in player lists etc etc}
 global_KingGuards  = 5;   {max number of body guards the king can have}

 {in game colors}
 global_hpcol    :byte = 12; {color to display hitpoints in game (hitpoints left)}
 global_talkcol  :byte = 13; {color used in phrases, see also utalkc constant}
 global_teamcol  :byte = 3; {color used when displaying teams}
 global_plycol   :byte = 10; {color used when displaying player names - see also uplc}
 global_godcol   :byte = 10; {color used when displaying god names - see also godc}
 global_kingcol  :byte = 10; {color used when displaying king/queen - see also ukingc}
 global_kidcol   :byte = 10; {color used when displaying children - see also ukidc}
 global_moncol   :byte = 9;  {color used by monster names - see also umonc}
 global_itemcol  :byte = 11; {color used when displaying items - see also uitemc}
 global_bashcol  :byte = 3; {color used when displaying close combat moves}
 global_relationcol:byte = 6; {color for social relations, see also usocialc}

 {chat routines globals}
 global_emptyline : boolean = false; {set to true when user has a blank line}

{file related constants}
const global_ushare   :boolean=true; {is share installed}
const global_lockmode :byte=0; {keeps track of filemode}
const global_cnode    :string[3]='001'; {which BBS # node is this}
                                        {becomes "Loc" if local}
{game related constants}
const global_screenlines :byte =25; {used in the games display routines}
const global_multi  : boolean=false; {if false then no multinode operations are allowed}
const global_fakeplayers:byte = 0; {active fake players in this player session}
const global_dungeonlevel : integer=3; {dungeon level, but also decides xp when fighting elsewhere. bad programming!}


const global_PlayerInSteroids:boolean=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}
const global_PlayerInFight:boolean=false; {exitproc checks for this flag and handles CARRIER-DROPPING cheaters}
const global_begged : boolean=false; {player has begged for mercy}
const global_nobeg  : boolean=true; {if YES mercy to NOBODY, Supreme being spares no one..}
const global_escape : boolean=true; {if YES players are not allowed to escape}
const global_killed : boolean = false; {player has been killed}
const global_icemap : boolean=false; {players get the ice-map after a dungeon event}
const global_monsterinit : boolean=false; {toggled TRUE when monster array is NEW:ed}
const global_registered : boolean=false; {is game registered, see various2.pas}
const global_onemin : boolean=false; {time left warning}
const global_twomin : boolean=false; {time left warning}
const global_ansi   : boolean=false; {has user ansi or not}
const global_cfor  : byte =2; {foreground color, used together with ddplus}
const global_cback : byte =0; {background color, used together with ddplus}
const global_ubeta : boolean=false; {is this a beta version?}
const global_utest : boolean=false; {is this a Jakob test version?}
const global_maintrunning : boolean=false; {set to true when Maintenance is running}
const global_carrierdropped:boolean=false; {set to true when ddplus reports carried dropped, see ddplus.pas=proc dropmessage}
const global_checkcarrier:boolean=false; {set to false when command line options are running}
const global_mainttxt = 10 ; {color of p† maint text, when its running}
const global_webaddress = 'http://www.randm.ca/usurper.aspx';
const global_levelraise = '(you are eligible for a level raise!)'; {text displayed when player is eligible for level raise}


 {supreme being equipment}
const global_s_lantern : boolean=false;
const global_s_sword   : boolean=false;
const global_s_bstaff  : boolean=false;
const global_s_wstaff  : boolean=false;

const Global_GodActive : boolean=false; {see godworld.pas}

const sex  : array [1..2] of string[3]=('him','her');
const sex2 : array [1..2] of string[3]=('he','she');
const sex3 : array [1..2] of string[3]=('his','her');
const sex4 : array [1..2] of string[7]=('himself','herself');
const sex5 : array [1..2] of string[7]=('husband','wife');
const sex6 : array [1..2] of string[4]=('boy','girl');
const sex7 : array [1..2] of string[8]=('son','daughter');
const sex8 : array [1..2] of string[6]=('father','mother');

{this array isn't used much...could probably be replaced.}
const color : array [0..10] of string[6]=
                                         ('white',
                                          'red',
                                          'blue',
                                          'green',
                                          'brown',
                                          'black',
                                          'purple',
                                          'grey',
                                          'blue',
                                          'yellow',
                                          'white');

var {keeps track of last time multinode check was performed}
    global_lasthour,
    global_lastminute,
    global_lastsecond,
    global_lastsec100 : word;

    {keeps track of last keypress}
    global_lastkeyhour,
    global_lastkeyminute,
    global_lastkeysecond,
    global_lastkeysec100 : word;

type

 {sysop may choose one of the following methods for using shared files
  in a network environment}

 NetShareMethods = (FileLocking, RecordLocking);

 {Auto_Probe uses these constants to auto travel in the game}
 places = (NoWhere,
           MainStreet,
           Slottet,
           Inn,
           Dormy,
           Prison,
           UmanCave,
           AtHome);

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

{When AutoProbe is set to a direction the player auto travels there}
const global_auto_probe : Places = NoWhere;

Const ClassNames : array[Classes] of string[9] = ('Alchemist',
                                                  'Assassin',
                                                  'Barbarian',
                                                  'Bard',
                                                  'Cleric',
                                                  'Jester',
                                                  'Magician',
                                                  'Paladin',
                                                  'Ranger',
                                                  'Sage',
                                                  'Warrior');


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

Const RaceNames : array[Races] of string[7] = ('Human',
                                               'Hobbit',
                                               'Elf',
                                               'Half-Elf',
                                               'Dwarf',
                                               'Troll',
                                               'Orc',
                                               'Gnome',
                                               'Gnoll',
                                               'Mutant');


type {player can be haunted by one or several of these diseases}
 Cures = (Nothing,
          All,
          Blindness,
          Plague,
          Smallpox,
          Measles,
          Leprosy);


type {item types}
 ObjType = (
            Head,
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

{MULTI-NODE CHAT ROUTINES}
const ipc_maxmsg = 10; {how many chatlines every file handles}
const ipcpath : s90 = global_nodedir; {dir to .ipc files, inc RAM drive support!!}

type {the ipc routines are taken from John Stephensons Jsdoor package
      the structure has been modified to suit the needs of Usurper}
 IPCType = Record {Multi node Chat record}
  Node      : SmallWord;    {Node number for this record}
  Username  : S30;     {Users Name}
  Available : Boolean; {Is user available for chat}
  In_chat   : boolean; {Whether user is in chat}
  Conference: SmallWord;     {Conference number}
  ConfName  : s30;      {Conference name}
  ConfPassW : string[8];{Conference password}
  MessColor : byte;    {this is MY color, as displayed to other players}
  Message_waiting : array[1..ipc_maxmsg] of boolean; {Whether the message is waiting or not }
  Message_to_user : array[1..ipc_maxmsg] of String; {Message to our user? }
  Message_from    : array[1..ipc_maxmsg] of s30; {who sent the mess}
  Message_color   : array[1..ipc_maxmsg] of byte; {color of text}
 end;


type {used by Dungeon Events and other routines to keep track of
      events/missions/quests in progress}
 DungeonQuestRec = record
  magicshoppe : boolean; {see dungeon events.}
 end;

type {used by temporary com-files at online duels/trading}
 ComRec = record
  com  : char; {usually the order command sent to the other node}
  mess : array[1..2] of s70; {string messages sent between nodes}
  nr1  : longint; {used to pass info between nodes}
  nr2  : longint; {same as above}
 end;

type {used to issue King orders, open shoppes etc etc}
     {this record is reset when a new king is elected/usurps power}
     {update :
               various.pas  => new_king
               maint.pas    => update king record
               challkng.pas => update king record...search for 'kingstruct'
               }
 KingRec = record
  name          : s30; {name of ruler}
  ai            : char; {ai - (C)omputer or (H)uman}
  sexy          : byte; {1=male or 2=female}
  daysinpower   : longint; {days in power}
  tax           : byte; {tax level}
  taxalignment  : byte; {tax who? 0=all,1=only good,2=only evil}
  treasury      : longint; {money in the royal vault}
  prisonsleft   : byte; {# of people king can imprison today. new every day}
  executeleft   : byte; {# of death sentences left today. new every day}
  questsleft    : SmallWord; {# of new quests the king can issue today}
  MarryActions  : SmallWord; {# of marriages the king can interfer in today}
  WolfFeed      : byte; {# kids have can be tossed to the wolves/day, set to config.allowfeedingthewolves at maint}
  RoyalAdoptions: byte; {# kids can be placed in the Royal Orphanage/day, set to config.allowRoyalAdoption at maint}
  moatID        : s15; {unique moat creature ID}
  moatnr        : SmallInt; {how many crocodiles (or whatever) in the moat?}
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

type {see Questrec specs for connections to these QuestTypes}
 QuestTypes   = (SingleQuest,TeamQuest);
 QuestTargets = (qMonster,qAssassin,qSeduce,qClaimTown,qGangWar);
 {quest reward types}
 QRewardTypes = (qNothing,qExp,qMoney,qPotions,QDarkness,QChivalry);

type QuestRec = Record {Royal Quests, initiated by the King/Queen}
      Id          : s20; {unique identification # number, useful when offering requests via mail}
      Initiator   : s30; {name of (KING/QUEEN) who initiated this quest}
      date        : Udate; {date when quest was created}
      QuestType   : QuestTypes; {single or team effort, see QuestTypes}
      QuestTarget : QuestTargets; {monsters,assassinatio,seduce,claim town,gang war}
      difficulty  : byte; {difficulty, especially useful when encountering monsters}
      deleted     : boolean; {has this quest been deleted?}
      comment     : s90; {comment by initiator}
      occupier    : s30; {is quest taken at this moment..and in that case the name of the claimnant}
      occrace     : races; {occupiers race}
      occsex      : byte; {occupiers sex 1=male,2=female}
      occdays     : SmallWord; {quest has been occupied for X days}
      daystocomple: SmallWord; {days given to complete quest before considered "failed"}

      offerto     : s30; {is this quest an offer to player}
      offerrefused: byte; {if offer is refused (1=delete,2=add to list}
      forced      : boolean; {is quest forced upon OCCUPIER?}
      minlevel    : SmallWord; {min level required to take on quest}
      maxlevel    : SmallWord; {max level required to take on quest}

      reward      : byte; {nothing,low,medium,high}
      rewardtype  : qrewardtypes; {type of reward, see qrewardtypes}

      penalty     : byte; {nothing,low,medium,high}
      penaltytype : qrewardtypes; {type of penalty, see qrewardtypes}

      monsters    : array[1..global_maxmon,1..2] of SmallWord; {1=type of monster,2=how many}

     end; {QuestRec *end*}


type {Orbs Bar, Special Drinks, made by Players => saved to drinkfile}
 DrinkRec = record
  name   : s30; {the drink}
  creator: s30; {creator}
  date   : Udate; {when was the drink created}
  comment: s70; {comment by creator}
  ordered: longint; {how many times have the drink been used/drank}
  lasthad: s30; {last customer that had this drink}
  lastrac: races; {last customers race}
  lastdat: Udate; {date when drink was last ordered}
  deleted: boolean; {deleted?}
  secret : boolean; {secret recipe? creators choice}
  amount : array[1..17] of SmallInt; {ingredients}
 end;

{type {Bard Songs, made by game/players/sysop => saved to global_bardsongf}
{ BardSongRec = record  {bards can create their own songs!}
                       {a new place only for the Bards! guilds}
{  title  : s30; {song-title}
{  creator: s30; {creator: *game* *editor* *name of player(bard)*}
{  date   : Udate; {when was the song created}
{  level  : SmallWord; {level needed to sing}
{  available: byte; {1=always,2=training,3=quest,4=disabled}
{  deleted  : boolean; {deleted?}
{  goodbad  : byte; {1=good,2=bad,3=any alignment can sing this song}
{  songtype : byte; {1=healing,2=aggressive,3=calling deity}
{  songtext : array[1..5] of s70;
 end;}

type {home chest, store items in chest}
    ChestItemRec = record
     pekare : SmallWord; {pointer to item # in the objXX file}
     ityp  : objtype; {type of item}
     PlyID : s15; { must match userrec ID }
    end;


type {Players Market, stuff that players want to sell}
 MarketItemRec = record
  pekare : SmallWord; {points to item # in the objXX file}
  ityp   : objtype; {type of item}
  seller : s30;     {name of seller}
  date   : Udate; {when the item was put in}
  price  : longint; {price}
  target : s30;     {marked for someone special}
  team   : boolean; {marked for some special team?}
  comment: s70;     {comment by seller}
  sold   : boolean; {has item been sold?}
 end;

type {Most Wanted people}
 WantedRec = record
  name      : s30;  {who is wanted?}
  level     : byte; {the wanteds level}
  date      : Udate;{when was this poster created?}
  mad       : s30;  {person who created the poster}
  gold      : longint; {gold reward}
  collected : boolean; {has the reward been collected?}
  elig      : char;    {vem kan collecta rewarden? A=all,C=npcs,H=players}
  ai1       : char;    {posters creator AI npC / Human}
  ai2       : char;    {wanted persons  AI npC / Human}
  anonym    : boolean; {is the creator of the poster anonymous?}
 end;

type {bank vault}
 SafeRec = record
  value    : longint; {money in the vault}
 end;

type  {Weapons in CLASSIC mode}
 WeapRec = record
  name  : s30; {name of weapon}
  value : longint; {value}
  pow   : longint; {power}
 end;

type {Armors in CLASSIC mode}
 ArmRec = record
  name  : s30; {name of armor}
  value : longint; {value}
  pow   : longint; {power}
 end;

type {item definition}
 ORec = record
  name : s70;   {objects name}
  ttype: objtype;      {type of object :
                         1. head
                         2. body
                         3. arms
                         4. hands
                         5. fingers
                         6. legs
                         7. feet
                         8. waist
                         9. neck
                         10. face
                         11. shield
                         12. mat
                         13. dryck
                         14. weapon
                         15. around body}


  value : longint;     {object value}
  hps  : SmallInt;      {can object increase/decrease hps (hitpoints)}
  stamina : SmallInt;   {..stamina}
  agility : SmallInt;   {..agility}
  charisma : SmallInt;  {..charisma}
  dex : SmallInt;       {..dexterity}
  wisdom : SmallInt;    {..wisdom}
  mana   : SmallInt;    {..mana}
  armor  : SmallInt;     {..can object increase armor value}
  attack : SmallInt;    {..can object increase attack value}
  owned  : s70;        {owned by (character name)}
  onlyone: boolean;    {only one object of its kind?}
  cure   : cures;      {can the object heal?}
  shop   : boolean;    {is the object available in the shoppe}
  dng    : boolean;    {can you find the item in the dungeons?}
  cursed : boolean;    {is the item cursed?}
  minlev : SmallInt;    {min level to be found in the dungeons}
  maxlev : SmallInt;    {max level to be found in the dungoens}
  desc1 : array [1..5] of s70; {normal description}
  desc2 : array [1..5] of s70; {detailed description}
  strength : SmallInt;{can object increase/decrease strength}
  defence : SmallInt; {can object increase/decrease defence}
  str_need : SmallInt; {strength needed to wear object}
  good : boolean; {does character need to be good to use item?}
  evil : boolean; {does character need to be evil to use item?}
  restrict : array[1..global_maxclasses] of boolean;
 end;

type {level limits, experience points needed to reach a certain level.}
 LevelRec = record
  xpneed : longint;
 end;

type {doorguard definition}
 GuardRec = record
  name : string[50]; {name of creature}
  cost  : longint; {cost to hire}
  hps   : longint; {hitpoints}
  multiple : boolean; {can multiple guards of this type be hired?}
  barmor : longint; {base armor}
  battack : longint; {base attack}
  descp : array [1..5] of s70; {description}
 end;

type {moat creatures definition}
 MoatRec = record
  name : s30; {name}
  id   : s15; {unique ID tag}
  cost : longint; {cost to hire}
  hps  : longint; {hitpoints}
  deleted : boolean; {deleted?}
  barmor  : longint; {base armor}
  battack : longint; {base attack}
  descp : array [1..5] of s70; {description}
 end;

type {mail record definition}
 MailRec = record
  receiver : s30; {destination <player.name2>}
  recgod   : boolean; {is receiver a god?}
  date     : Udate; {mail was created this date DAY,MONTH,YEAR 00-00-0000}
  readflag : boolean; {has this mail record been read/processed}
  sender   : s30; {who sent this mail <player.name2>}
  sendgod  : boolean; {is sender a god}
  special  : byte; {special request, see mailrequest_nothingXX constants}
  mess : array [1..global_maxmaillines] of s100; {message text}
 end;

const global_onlocal = 'Loc'; {used by online.node:=, when local player}

type OnlineTypes = (OnLine_Player,Online_God,Online_Child,Online_Fake);

type {online character/record definition}
 OnlineRec = record
  name     : s30; {player alias}
  realname : s30; {player real name, or rather his BBS name}
  node     : s3; {node; 001, 002 ... etc}
  arrived  : UDate; {date of arrival; hour:minute:second}
  usertype : onlinetypes; {see type onlinetypes...player/god/child}
  fake     : boolean; {a fake player is acting like a real player and will
                       stay as long as the player who created him}
  recnr    : SmallWord; {rec # in ONLINERS.DAT}
  shadow   : boolean; {if true then this character is computer controlled}
  dead     : boolean; {is this being used?? check this one out jakob! i don't think its being used}
  race     : races; {race}
  class    : classes; {class}
  sex      : byte; {sex, 1=male 2=female}
  initiator: string[31]; {who created this record, could be a "GHOST"}
  doing    : string[40]; {status of player, what is he doing}
  chatline : array[1..global_maxnod] of s90;
  chatsend : array[1..global_maxnod] of s30;
  info     : array[1..global_maxnod] of s90;
  infosend : array[1..global_maxnod] of s30;
  ear      : byte; {how much info does the player want to get when online, see cms.pas and ear constants}
  bname    : s30; {online opponents name}
  comfile  : s90; {name of file in which online comm will take place}
  com      : char; {used in player<=>player online routines}
  location : SmallInt; {location in game, see onloc_?? constants}
 end;

type {Player/Npc Record}


 {when adding/removing a value for USERREC you must update these files:

   Usurper Project
   ---------------
   init.pas (both record struct. & creating new ply)
   userhunc.pas
   resetg.pas
   (not always)
   maint.pas & npcmaint.pas...if values need to be updated every day


   Editor Project
   --------------
   init.pas
   npc.pas

   Converter Project
   -----------------
   converta.pas (or whatever your converter project is called)

   }


 UserRec = record
  Name1 : s30; {bbs/real name}
  name2 : s30; {game alias}
  ai    : char; {(C)omputer or (H)uman}
  race  : races; {races}
  age   : SmallInt; {age}
  gold  : longint; {gold in hand}
  hps   : longint; {hitpoints}
  exp   : longint; {experience}
  level : longint; {level}
  bankgold : longint; {gold in bank}
  chiv  : longint; {chivalry}
  dark  : longint; {darkness}
  fights: SmallInt; {dungeon fights}
  strength : longint; {strength}
  defence  : longint; {defence}
  healing  : longint; {healing potions}
  allowed   : boolean;  {allowed to play}
  maxhps  : longint;  {max hitpoints}
  laston  : longint;  {laston, date}
  ageplus : SmallInt;  {how soon before getting one year older}
  darknr  : SmallInt;  {dark deeds left}
  chivnr  : SmallInt;  {good deeds left}
  pfights : SmallInt;  {player fights}
  king    : boolean;  {king?}
  location: SmallInt;  {offline location, se offloc_?? constants}
  team    : s25; {team name}
  teampw  : s20; {team password}
  teamrec : SmallWord;    {team record, how many days have we had the town}
  bguard  : SmallInt; {type of guard, # in door guard file}
  cturf   : boolean; {is team in control of town}
  gnollp  : SmallInt; {gnoll poison, temporary used in fights}
  mental  : SmallInt; {mental health}
  addict  : SmallInt; {drug addiction}
  wellwish : boolean; {has player visited the Wishing Well}
  height   : SmallInt; {height}
  weight   : SmallInt; {weight}
  eyes : SmallInt; {eye color}
  hair : SmallInt; {hair color}
  skin : SmallInt; {skin color}
  sex  : SmallInt; {sex, male=1 female=2}
  mana : longint; {mana, spellcasters only}
  maxmana  : longint; {maxmana}
  stamina  : longint; {stamina}
  agility  : longint; {agility}
  charisma : longint; {charisma}
  dex      : longint; {dexterity}
  wisdom   : longint; {wisdom}
  weappow  : longint; {weapon power}
  armpow   : longint; {armor power}
  blind    : boolean; {blind?}
  plague   : boolean; {plague?}
  smallpox : boolean; {smallpox? (smittkoppor in swedish)}
  measles  : boolean; {measles? (m„ssling in swedish)}
  leprosy  : boolean; {leprosy? (spet„lska in swedish)}
  mercy    : SmallInt; {mercy?? check this up!!}
  item     : array[1..global_maxitem] of SmallInt; {inventory}
  itemtype : array[1..global_maxitem] of objtype; {type of items in inventory}
  phr      : array[1..6] of s70; {phrases used in different situations}
  {1. what to say when being attacked
   2. what to say when you have defeated somebody
   3. what to say when you have been defeated
   4. what to say when you are begging for mercy
   5. what to say when you spare opponents life
   6. what to say when you don't spare opponents life}
  autoheal : boolean; {autoheal in battle?}
  class    : classes; {class}
  loyalty  : SmallInt; {loayalty% (0-100)}
  haunt    : SmallInt; {how many demons are set to haunt player}
  master   : char;    {who is the level master player uses}
  tfights  : SmallInt; {team fights left}
  thiefs   : SmallInt; {thieverys left}
  brawls   : SmallInt; {brawls left}
  assa     : SmallInt; {assainations left}
  desc     : array[1..4] of s70; {player description}
  poison   : SmallInt; {poison, adds to weapon. used by ALCHEMISTS}
  spell    : array[1..global_maxspells,1..2] of boolean; {spells}
  skill    : array[1..global_maxcombat] of SmallInt; {close combat skills}
  trains   : SmallInt; {training sessions at Close-Combat master}
  lhand    : SmallWord; {item carried in left hand}
  rhand    : SmallWord; {item in right hand}
  head     : SmallWord; {head}
  body     : SmallWord; {body}
  arms     : SmallWord; {arms}
  lfinger  : SmallWord; {left finger}
  rfinger  : SmallWord; {right fignger}
  legs     : SmallWord; {legs}
  feet     : SmallWord; {feet}
  waist    : SmallWord; {waist}
  neck     : SmallWord; {neck}
  neck2    : SmallWord; {neck2}
  face     : SmallWord; {face}
  shield   : SmallWord; {shield}
  hands    : SmallWord; {hands}
  abody    : SmallWord; {around body}
  immortal  : boolean; {if yes, never deleted for inactivity}
  battlecry : s70;     {battle cry}
  bguardnr  : SmallInt; {number of doorguards, type is specified in bguard}
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
  maxtime     : SmallInt; {maxtime (minutes) per session in game}
  ear         : byte; {how should player deal with internode messages..see cms.pas}
  castin      : char;
  weapon      : SmallWord; {OLD mode}
  armor       : SmallWord; {OLD mode}
  apow        : SmallWord; {OLD mode}
  wpow        : SmallWord; {OLD mode}
  disres      : byte; {disease resistance}
  amember     : boolean; {medlem i alchemist s„llskapet}
  medal       : array[1..20] of boolean;
  bankguard   : boolean; {bank-guard?}
  bankwage    : longint; {salary from the bank, for guard duty}
  weaphag     : byte; {ggr en spelare har hagglat i weaponshop}
  armhag      : byte; {ggr en spelare har hagglat i armorshop}
  recnr       : SmallWord; {fil pointer, what record# does the player hold}
  auto_meny   : boolean; {spelaren vill ha menyerna automatiskt utritade}

  {below is new for 0.14}
  quests      : SmallInt; {# of completed missions/quests}
  deleted     : boolean;  {is this record deleted}
  god         : string[30]; {player worships GOD with this name}
  royquests   : longint;  {# of royal quests accomplished}

  {below is new for 0.17}
  RoyTaxPaied : longint; {royal taxes paied since player was last logged in}
  Wrestlings  : byte; {Indian Wrestlings matches left in Uman Caves, reset every maint}
  DrinksLeft  : byte; {Drinks left today, at Orbs}
  DaysInPrison: byte; {days left in prison}

  {below is new for 0.18}
  UmanBearTries : byte; {times player have tried to tame the bear}
  Massage       : byte; {times player have had massage this day}
  gym_sessions  : byte; {gym sessions(workout) left today}
  Gym_Owner     : byte; {controller of the gym? has to be in a team}
  Gym_Card      : byte; {free card to the gym? if not gym_owner that is}
  RoyQuestsToday: SmallWord;{how many royal quests have the player completed today}
  KingVotePoll: byte; {how many days since voted for king popularity}
  KingLastVote: byte; {last vote, to be used for polls}

  Married     : boolean; {is player married?}
  Kids        : SmallWord; {how many kids this playeer is father/mother to}
  IntimacyActs: SmallWord; {how many acts of intimacy has player left today?}
  Pregnancy   : byte; {is player pregnant? 0=no, 1...X = days pregnant}
  FatherID    : s15;  {fathers id tag, set when pregnancy starts}
  AutoHate    : byte; {automatically worsen relation with a person that
                      attacks you? (0=no 1=one step worsened)}
  ID          : s15; {unique ID tag, to keep players in touch with relations
                     and children. without this, new players with the same
                     name as a deceased father will inherit the old guys
                     children. relations.id correspond to player.id
                     this id also follows the player to the gods.dat!}
  Tax_Relief : boolean; {free from tax?}

  MarriedTimes : SmallWord; {counter for marriages}
  Bard_Songs_Left: SmallWord; {ehhh..quite self-explanatory huh?}
  prison_escapes : byte; {allowed prison escape attempts}
  Filtyp : byte; {type of file player resides in (1=player file, 2=npc file)}
  resurrections : SmallWord; {times left allowed to play...decreases after each death}

  {below is new for 0.20}
  PickPocketAttempts : SmallWord; {pick pocket attempts}

  {below is new for 0.20e}
  BankRobberyAttempts : SmallWord; {bank robbery attempts / day}

end;

type
 { NOTE! change the following procs & funcs when adding/removing vals
    update relation.pas => create_child
    update reltio2.pas  => child_view
 }
 ChildRec = Record {kids produced by players/npc, not necessarily married
                    couples. remember that a divorce will split the kids between parents}
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

type {Social Relations, how characters relate to each other}
 RelationRec = Record
  {!! remember to change and the following procs when you modify the struct
    Correct_Relation   => relation.pas
    new_relationrecord => relation.pas
    prepare_relation   => relation.pas
   }

  name1       : s30;  {player 1 name}
  name2       : s30;  {player 2 name}
  ai1         : char; {player 1 ai}
  ai2         : char; {player 2 ai}
  race1       : races; {pl1 race}
  race2       : races; {pl2 race}
  relation1   : SmallWord; {pl1s relation to pl2 ,see:relation constants}
  relation2   : SmallWord; {pl2s relation to pl1 ,see:relation constants}
  idtag1      : s15; {holds pl1.id - necessary when identifying kids parents}
  idtag2      : s15; {holds pl2.id - necessary when identifying kids parents}
  recnr1      : SmallWord; {pl1 recnr in userfile}
  recnr2      : SmallWord; {pl2 recnr in userfile}
  filetype1   : byte; {pl1 is residing in (1)user/(2)npc file}
  filetype2   : byte; {pl1 is residing in (1)user/(2)npc file}
  deleted     : boolean; {this relation record is deleted}
  recnr       : SmallWord; {record #, file position of relation record}
  bannedmarry : boolean; {not allowed to marry, only the King can set this flag}
  marriedtimes: SmallWord; {how many times have this couple been married}
  marrieddays : longint; {how many days has the current marriage lasted}
  kids        : SmallWord; {# of children this relation has produced}
  killedby1   : SmallWord; {name2 has been killed this many times by name1}
  killedby2   : SmallWord; {name1 has been killed this many times by name2}
 end;

type {Monster definition}
 MonsterRec = record
  name     : s30; {name of creature}
  weapnr   : longint; {weapon used, # points to weapon in weapon data file}
  armnr    : longint; {armor used, # points to armor in armor data file}
  grabweap : boolean; {can weapon be taken?}
  grabarm  : boolean; {can armor be taken?}
  phrase   : s70;     {intro phrase from monster}
  magicres : SmallInt; {magic resistance}
  strength : longint; {strength}
  defence  : SmallInt; {defence}
  wuser    : boolean; {weapon user}
  auser    : boolean; {armor user}
  hps      : longint; {hitpoints}
  punch    : longint; {punch, temporary battle var}
  poisoned : boolean; {poisoned?, temporary battle var}
  weapon   : string[40]; {name of weapon}
  armor    : string[40]; {name of armor}
  disease  : boolean; {infected by a disease?}
  target   : SmallInt; {target, temporary battle var}
  weappow  : longint; {weapon power}
  armpow   : longint; {armor power}
  iq       : SmallInt; {iq}
  evil     : SmallInt; {evil (0-100%)}
  magiclevel : byte; {magiclevel, the higher the better magic performed}
  mana    : SmallInt; {mana left}
  maxmana : SmallInt; {maxmana}
  spell  : array[1..global_maxmspells] of boolean; {monster spells}
 end;

 {global array of monsters, used to create opponents}
 MonsterArray = array [1..global_maxmon] of ^MonsterRec;
var Monster : MonsterArray;

type {Config Reocrd}

 {when updating ConfigRecord you should considering updating these
  routines as well:

  Usurper Project
  ---------------
  various3.pas => Display_Game_Settings proc
  various.pas => Read_Start_CfgValues proc

  Editor Project
  --------------
  see cfgdef.pas

  Converter Project
  -----------------
  ConvertX.pas

  }

 ConfigRecord = record
  marknpcs  : boolean; {should the npcs be marked with a '*' in the lists? 123}
  leveldiff : SmallInt; {max level diff when attacking, }
  fastplay  : boolean; {skip intro menu}
  anchor    : string[25]; {name of challenges place..default is Anchor road}
  simulnode : boolean; {allow users to be on more than 1 node simultaneously}
  automaint : boolean; {should maintenance take place automatically}
  maxmail   : byte; {how many days should player mail be kept, config option}
  maxmarket : byte; {how many days should player market items stay}
  maxwanted : byte; {how many days should wanted posters stay up}
  maxdrinkds: SmallInt; {how many days should user drinks be kept}
  maxdrinks : SmallInt; {how drinks are allowed in the file}
  inactivity: SmallWord; {how many minutes of inactivity before a user is logged off}
  abase     : real; {armorbase}
  maxheals  : SmallInt; {max # of healing potions}
  classic   : boolean; {old or new game type}
  teamassist: boolean; {allow team mates to help team mates attacked in the Dorm}
  teamdiff  : SmallInt; {how many levels more can attacker have, team}
  multicheck: SmallInt;  {read onliners.dat every MULTICHECK second}
  onemanshow: boolean; {can "oneman teams" fight?}
  innkeeper : s20; {name of innkeeper}
  semaphore : string[120]; {path to semaphore directory}
  errors    : boolean; {display errors to the screen, read from .cfg file}
  mon_talk  : boolean; {should the monsters speak in the dungeons}
  quaffopt  : byte; {quaffing healing potions in the dungeons, consequences 1..3}
  dormpocketattackallow : boolean; {allow losers from pick-pocket attacks in the dorm to enter again}
  pickpocketattempts    : SmallWord; {how many pick-pocket attempts per day}
  dormwakeupcallallow   : boolean; {defeated guys from dorm wake up calls}
  BardSongs:byte; {# of bard songs/day}
  Bard_Songs_Allowed : boolean; {allow bards to use sing.NOT added to Editor!}
  DrinksAtOrbs : byte; {drinks per day at Orbs}
  MaxWrestlings:byte; {indian wrestling bouts a player can go / day}
  PunishCarrierDroppers:byte; {0=no punishment,1=no play today}
  Allow_Steroids:boolean; {#154, allow players to visit shop}
  Allow_Whores:boolean; {#155, allow players to visit whores}
  Allow_Drugs:boolean; {#156, allow players to buy drugs}
  Allow_Murder:boolean; {#157, allow players to murder innocent people}
  FakePlayers:byte; {#159, fake players per player session (0-110)}
  MaxFakePlayers:byte; {#???, max fake players per game session! (0-110)}
                       {this option has not yet been implemented in the
                        editor!!! user cant change it yet!}
  FakeSChatty:boolean; {#188, should the fake players be chatty or quiet}
  ViewGameSettings : boolean; {#177 allow players to view game settings}

  BobsPlace:s30; {#167 name of Bobs Beer Hut}
  BobsName:s30; {#168 name of shop keeper at Bobs Beer}
  Bishop:s30; {#169 name of bishop}
  Gossip_Monger:s30; {#170, gossip-monger and midwife at love corner}
  BobsBartender:s30; {#171, bartender at Bobs Beer}
  GymMasseur:s30;    {#172, Masseur at the Gym}

  {King}
  MinLevelKing          : byte; {#121, min level for players req to usurp the throne}
  SoulNeededKing        : byte; {#122, soul needed to usurp the throne (good,evil,any)}
  Print_KingPolls       : boolean; {#158, put the players opinions about the ruler in the news?}
  ResurrectTheKing      : boolean; {resurrect the King when castle is infiltrated}
  AllowKingtoInitQuests : boolean; {allow king/queen to create quests}
  MaxQuestsAllowed      : SmallWord; {max # of quests allowed in database}
  MaxClaimedQuests      : SmallWord; {max # of claimed quests a player can have simlutaneously}
  MaxCompletedQuests    : SmallWord; {max # of quests a player is allowed to complete/day}
  MaxNewQuestsPerDay    : SmallWord; {max # of new quests the KING can issue/day}
  ForceQuests           : boolean; {allow the king to force quests upon players}
  AllowFailQuestReturn  : boolean; {allow players who die on quests to enter again the same day}
  AllowFailPrisonRescue : boolean; {allow players who are killed in rescue attempts/prison to enter again}
  MarryActionsPerDay    : SmallWord;    {max # of marriages the King can interfer every day}
  AllowNPCUsurping      : boolean; {allow the npcs to usurp the throne}
  AllowCloseShops       : boolean; {allowed to close shops}
  AllowRoyalAdoption    : byte; {0-5 allow the King to put X kids per day in Royal Orphanage}
  AllowFeedingTheWolves : byte; {0-5 children a day to the wolves}
  AllowKingtoImprison   : byte; {the king is allowed to imprison players for
                                 how many days? 0-15. 0=not allowed to imprison}

  Prison_Escapes : byte; {number of escape attempts imprisoned players have}


  {Npcs & Chatfile}
  NpcBelievers      : boolean; {allow npcs to believe in GODs}
  AllowNpcMarry     : boolean; {allow npcs to marry and have kids}
  AddNpcInnComments : byte; {add Npc comments to the Inn Chat file
                             0=never, 1=seldom, 2=sometimes, 3=often}

  {File i/o stuff}
  NetShareMethod : NetShareMethods; {FileLocking, RecordLocking}
  LockDelay : SmallWord; {delay in milliseconds between file lock attempts}

  {Social}
  MinimumAgetoMarry  : SmallWord; {minimum age to marry, default is 18}
  BirthdayInterAct   : boolean; {allow other players to "congratulate" birtday subject}
  AllowHomoRelations : boolean; {allow homosexual relations}
  AllowAdultOptions  : boolean; {allow intimate sex options #194}
  IntimacyActs       : SmallWord; {acts of intimacy/day a player has}
  RelationChangesNews: byte; {put moodswings in the news? 0=no,1=yes}
  MaxHumanChildren   : SmallWord; {# of children allowed}
  MaxNPCChildren     : SmallWord; {# of children allowed}
  LaborDays          : SmallWord; {# of labor days before child pops out}

  HomeItems : SmallWord; {# of items which can be stored at home}

  {Uman Cave}
  BearTameTries : byte; {chances to go a round with the bear}

  {Gym}
  MassageVisits : byte; {times allowed to have massage / day}
  GymSessions   : byte; {workout sessions / day}

  {game custom settings}
        {NOTE! if you change moneytype string length don't forget
        to change the corresponding function "many_money" in various2.pas}
  MoneyType : string[10]; {"gold" is default here, but it can be "silver" or anything else}
  MoneyType2: string[10]; {"coin" is default here, but it can be "bar" or "cup" or ...}
  MoneyType3: string[10]; {default is "coins" ... }
  WriteMarriedFlag : boolean; {write <M> in player listings/scores}
  ReturnEnter : string[6]; {use press RETURN, or use press ENTER}
  TextColor : byte; {color to use when displaying standard text}
  TextColorH: byte; {same as above, but this is the text in Heaven}
  BracketColor : byte; {color to use when displaying menu brackets}
  BracketColorH: byte; {same as above, but this is used in heaven where the immortals reside}

  HotKeyColor : byte; {color when displaying hot keys}
  HotKeyColorH: byte; {same as above, but this is used in heaven}

  TextCol1 : string[3]; {same color as textcolor}
  TextCol2 : string[3]; {lighter alternative to textcol ex: '?' for menu}

  TextCol1H : string[3]; {same as above, but used in heaven}
  TextCol2H : string[3]; {same as above, but used in heaven}

  SpinCursor : boolean; {use spin cursor routines..may slow some routines}

  log_divine_entrance : boolean; {#164, log divine entries in the news}
  Resurrections : SmallWord; {191, how many ressurections a player have per day}

  {Quest-Master}
  QuestMaster : s20;

  {gods}
  gods_deedsleft : SmallWord; {deeds/day}

  {items}
  allowitem : array[1..global_maxallows] of boolean;
  loot      : array [1..14] of boolean; {allow players to take equpiment from opponents}
  loothands : byte; {this replaces the above setting for hand items.
                     0=not allowed to take hand items
                     1=Both        REFERENCE : various.pas and swapeq.pas
                     2=Left only
                     3=Right only
                     4=Random  left/right
                     5=Random  left/right/both
                     6=Random  left/right/both/none}

  bothImmortalsAndMortals : boolean;

  {bank}
  BankRobberyAttempts : SmallWord;

 end; {ConfigRec *END*}


var Config : ConfigRecord; {holds global settings from the usurper.cfg file}
var Hittas : array [1..15,1..global_maxhittas] of boolean;

var Player  : UserRec; {this is the record used by the player online}
var Onliner : OnlineRec; {this is the record used by the player online}
var DungeonQuest : DungeonQuestRec;

var ExitSave : pointer; {points to current exitprocedure}

var global_nwfileasc  : s70; {newsfile ASCII}
var global_nwfileans  : s70; {newsfile ANSI}
var global_ynwfileasc : s70; {yesterdays news ASCII}
var global_ynwfileans : s70; {yesterdays news ANSI... defined by sysop. default below}

Procedure Init_Usu;

Implementation

Uses Dos;

Procedure Init_Usu; {Init Global Variables}
var i : byte;
begin

 {filemode}
 global_lockmode:=filemode;

 {newsfiles}
 global_nwfileasc  := global_scoredir+'NEWS.ASC';
 global_nwfileans  := global_scoredir+'NEWS.ANS';
 global_ynwfileasc := global_scoredir+'YNEWS.ASC';
 global_ynwfileans := global_scoredir+'YNEWS.ANS';

 onliner.name:='';
 onliner.recnr:=0;

 {time}
 gettime(global_lasthour,global_lastminute,global_lastsecond,global_lastsec100);
 gettime(global_lastkeyhour,global_lastkeyminute,global_lastkeysecond,global_lastkeysec100);

 {reseting Quest record/events}
 DungeonQuest.magicshoppe:=false;


 {Set global config defaults, the Sysop defined settings are read from READ_START_CFGVALUES in VARIOUS.PAS}
 Config.inactivity:=2; {how many minutes of inactivity before a user is logged off}
 Config.MarkNpcs  :=true;
 Config.LevelDiff :=5;
 Config.FastPlay  :=false;
 Config.Anchor    :='Anchor road';
 Config.SimulNode :=true;
 Config.AutoMaint :=true;
 Config.Maxmail   :=15; {how many days should player mail be kept, config option}
 Config.Maxmarket :=30; {how many days should player market items stay}
 Config.Maxwanted :=30; {how many days should wanted posters stay up}
 Config.Abase     :=0;  {armorbase, base armor}
 Config.MaxHeals  :=75; {max # of healing potions}
 Config.Classic   :=false; {OLD or NEW game type}
 Config.TeamAssist:=true;  {allow team mates to help mates attacked at the Dorm?}
 Config.TeamDiff  :=5;  {how many levels more can attacker have, *team fights*}
 Config.MultiCheck:=5;  {read onliners.dat every MultiCheck second}
 Config.InnKeeper :='Grull'; {name of InnKeeper}
 Config.OneManShow:=true; {allow "onemane teams" to fight?}
 Config.Semaphore :=''; {path to semaphore directory}
 Config.Errors    :=false; {display file-error messages to the screen}
 Config.Mon_Talk  :=true; {should the monster speak}
 Config.QuaffOpt  :=1; {quaffing healing potions in the dungeons selection}
 Config.dormpocketattackallow:=true; {allow losing attackers from pick pocket attacks in the dorm to enter again}
 Config.dormwakeupcallallow:=true; {defeated guys from dorm wake up calls}
 Config.BardSongs:=5; {# of Bard Songs / day}
 Config.Bard_Songs_Allowed:=true; {allow bards to use sing.NOT added to Editor!}
 Config.DrinksAtOrbs:=3; {drinks per day at Orbs}
 Config.MaxWrestlings:=5; {indian wrestling bouts a player can go / day}
 Config.PunishCarrierDroppers:=0; {punish player who drop carrier during fight}
 Config.Allow_Steroids:=true; {#154, allow players to visit shop}
 Config.Allow_Whores:=true; {#155, allow players to visit whores}
 Config.Allow_Drugs:=true; {#156, allow players to buy drugs}
 Config.Allow_Murder:=true; {#157, allow players to murder innocent people}
 Config.Print_KingPolls:=true; {#158, put players opinions of the ruler in the news?}
 Config.FakePlayers:=2; {#159, fake players per player session (0-100)}
 Config.FakeSChatty:=true; {#188, fake players are chatty}
 Config.MaxFakePlayers:=10; {#160, max fake players per game session! (0-100)}

 Config.ResurrectTheKing:=true; {resurrect the King when castle is infiltrated}
 Config.AllowKingtoInitQuests:=true; {allow king/queen to create quests}
 Config.MaxQuestsAllowed:=100; {max # of quests active in database}
 Config.MaxClaimedQuests:=3; {max # of claimed quests a player can have simlutaneously}
 Config.MaxCompletedQuests:=5; {max # quests a player can complete/day}
 Config.MaxNewQuestsPerDay:=3; {max # of new quests the KING can issue/day}
 Config.MarryActionsPerDay:=5; {max # of marriages the King can interfer every day}
 Config.AllowCloseShops   :=true; {allowed to close shops}
 Config.AllowRoyalAdoption:=1; {allow the King to put X children in the royal orphanage}

 Config.ForceQuests:=false; {allow the king to force missions upon players}
 Config.AllowFailQuestReturn:=false; {allow players who die on quests to enter again the same day}

 Config.AllowKingtoImprison:=1; {allow the king to imprison players for how many days}

 Config.AllowFailPrisonRescue:=true; {allow players who are killed in rescue attempts/prison to enter again}


 Config.AllowNpcMarry    :=true; {allow npcs to marry and have kids}
 Config.AddNpcInnComments:=1; {add Npc comments to the Inn Chat file}
 Config.AllowNPCUsurping :=true; {allow the npcs to usurp the throne}
 Config.PickPocketAttempts:=5; {how many pick pocket attempts are allowed per day}

 {file /io stuff}
 Config.NetShareMethod:=FileLocking; {FileLocking, RecordLocking}
 Config.LockDelay:=50; {delay in milliseconds between file locking attempts}

 {social}
 Config.BirthdayInterAct:=true; {allow other players to "congratulate" birtday subject}
 Config.AllowHomoRelations:=false; {allow homosexual relations}
 Config.IntimacyActs:=10;

 {Uman Caves}
 Config.BearTameTries:=5; {chances to go a round with the bear}

 {Gym}
 Config.MassageVisits:=3; {times allowed to have massage / day}
 Config.GymSessions:=4; {sessions(workout) in the gym / day}

 {game custom}
 Config.MoneyType:='gold'; {"gold" is default here, but it can be "silver" or anything else}
 Config.MoneyType2:='coin'; {"coin" is default here, but it can be "bar" or "cup" or ...}
 Config.MoneyType3:=Config.MoneyType2+'s'; {same as 2 but many! default is "coins" ...}

 Config.WriteMarriedFlag:=true; {write <M> in player listings/scores. IT TAKES TIME TO CHECK IF A PLAYER IS MARRIED!}
 Config.ReturnEnter:='Return'; {use 'press Return' or 'press Enter'}
 Config.TextColor:=2; {color when displaying text in Usurper}
 Config.BracketColor:=2; {color when displaying menu brackets}
 Config.HotKeyColor:=5; {color when displaying hot keys}
 Config.TextCol1:=ugreen; {same as textcolor}
 Config.TextCol2:=umag; {alternative 'menu hotkey' color to textcol1}

 {same as above but used in heaven}
 Config.TextColorH:=2; {color when displaying text in Usurper}
 Config.BracketColorH:=2; {color when displaying menu brackets}
 Config.HotKeyColorH:=5; {color when displaying hot keys}
 Config.TextCol1H:=ugreen; {same as textcolor}
 Config.TextCol2H:=umag; {alternative 'menu hotkey' color to textcol1}
 Config.SpinCursor:=true; {spin the cursor at delaying/waiting moments}

 {gods}
 Config.gods_deedsleft:=5; {deeds / day}

 {items}
 for i:=1 to global_maxallows do begin
  Config.AllowItem[i]:=true; {allow different type of items in the game}
 end;

 for i:=1 to 14 do begin
  config.loot[i]:=false; {allow players to take equipment from defeated players}
 end; {for i:= .end.}

end;

end. {Unit Init *end*}
        {
         player.loc   = var h†ller spelaren hus offline
                        0... ligger p† dormitoryt och slaggar (default)
                        1..4 ligger i ett rum p† the Inn

                        30.. castle (kungen eller drottningen)
                        40.. f„ngelset/prison
                        50.. tigger p† marketplace, beggars wall


        „ven if cust0.hps=-9000 or cust0.hps=-8000 then Drugged

        }

        {

        IO/filer :
                   file_io.pas

                   market.pas    - some routines
                   onduel.pas    - players vs player online
                   ontrade.pas   - tradea grejor online
                   userhunc.pas  - ny user mm..
        }


        { st„llen som mygel-Jakob hittar p† i dngs
          Khartan
          Monlouth
        }

        { onliner.location
          1-100, vanliga st„llen i spelet
          100-210, dungeons
          300-..., ice caves

        }

