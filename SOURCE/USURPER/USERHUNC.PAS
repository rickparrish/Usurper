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

Unit UserhunC; {Usurper - look for user & create new user}

Interface

Uses Init;

Function User_Search(var username:s70;enter_game_if_exists:boolean) : boolean; {returns TRUE if player exists, else new player}

Implementation

Uses DDplus, Jakob, Cms,
     Mail, News,
     Various, Various2, Online,
     File_Io, SysUtils;

Function User_Search(var username:s70;enter_game_if_exists:boolean) : boolean; {returns TRUE if player exists, else new player}
var

   s     : string;
   alias : s70;

   cho : char;

   i,
   x,
   j,
   startm,
   players_allowed : longint;

   dngfights,
   plfights : integer;

   found_user,
   maxtime,
   slot       : word;

   pl0 : UserRec;
   king : KingRec;

   no_play : boolean;


Begin

 user_search:=false;

 if enter_game_if_exists then begin
  clearscreen;
  sd(10,'Hang on...');
 end;

 startm:=0;
 found_user:=0;

 {we read starting amount of money}
 s:=cfg_string(14);
 startm:=str_to_nr(s);
 if (startm<100) or (startm>1000000) then startm:=10000;

 {we read # of dungeon fights}
 s:=cfg_string(6);
 dngfights:=str_to_nr(s);
 if (dngfights<1) or (dngfights>99) then dngfights:=10;

 {we read # of player fights}
 s:=cfg_string(40);
 plfights:=str_to_nr(s);
 if (plfights<1) or (plfights>99) then plfights:=3;

 {get MaxTime fr†n USURP.CTL}
 maxtime:=time_left;

 player.name1:=emptystr;
 player.name2:=emptystr;

 for i:=1 to fs(FsPlayer) do begin
  load_character(player,1,i);
  if (UpperCase(player.name1)=UpperCase(username)) and
     (player.deleted=false) then begin

   found_user:=i;

   if is_online(player.name2,online_player)=true then begin

    if enter_game_if_exists then begin
     crlf;
     d(15,'Your character is already online.');
     d(15,'You might have been challenged by another player or perhaps you');
     d(15,'are involved in some other activity.');
     sd(15,'Check ');
     sd(10,'(W)HO IS ON');
     sd(15,' from the main menu.');

     crlf;
     d(14,'If you want, you can send messages to online players');
     d(14,'from the main menu.');
     pause;
    end;

    player.name1:=emptystr;
    player.name2:=emptystr;

     user_search:=false;
     exit;

   end;

   if (player.interest>0) or
      (player.alive_bonus>0) or
      (player.roytaxpaied>0) or
      (player.bankwage>0) then begin

    if player.roytaxpaied>0 then begin
    {load king}
    load_king(fload,king);

     {repost Royal Taxes payed since last login}
     post(MailSend,
     player.name2,
     player.ai,
     false,
     mailrequest_nothing,
     '',
     umailheadc+'Royal Tax'+config.textcol1,
     cool_string(9,'=','-',10,2),
     'You had to pay '+uyellow+commastr(player.roytaxpaied)+config.textcol1+' coins to '+kingstring(king.sexy)+ukingc+' '
       +king.name+config.textcol1+'.',
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

     {reset player tax buffer}
     player.roytaxpaied:=0;

    end;

    {report player bank interest}
    if player.interest>0 then begin

     {inform offline player}
     post(MailSend,
          player.name2,
          player.ai,
          false,
          mailrequest_nothing,
          '',
          umailheadc+'Bank Interest'+config.textcol1,
          cool_string(13,'=','-',10,2),
          'You received '+uyellow+commastr(player.interest)+config.textcol1+' '+many_money(player.interest)
           +' in Bank Interest.',
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


     {receive bank interest money}
     IncPlayerMoney(player,player.interest);
     player.interest:=0;

    end;

    if player.bankwage>0 then begin
     post(MailSend,
          player.name2,
          player.ai,
          false,
          mailrequest_nothing,
          '',
          umailheadc+'Bank salary'+config.textcol1,
          mkstring(11,underscore),
          'You received '+uyellow+commastr(player.bankwage)+config.textcol1+' '+many_money(player.bankwage)
           +' for your bank employment.',
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

     {receive Bank Wage}
     IncPlayerMoney(player,player.bankwage);
     player.bankwage:=0;

    end;

    if player.alive_bonus>0 then begin

     post(MailSend,
          player.name2,
          player.ai,
          false,
          mailrequest_nothing,
          '',
          umailheadc+'Bonus Money'+config.textcol1,
          mkstring(11,underscore),
          'You received '+uyellow+commastr(player.alive_bonus)+config.textcol1+' '+many_money(player.alive_bonus)
            +' in Staying-Alive bonus!',
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

     {receive player staying alive bonus}
     IncPlayerMoney(player,player.alive_bonus);
     player.alive_bonus:=0;
    end;

    {save user, changes have been made above}
    user_save(player);
   end;

   if (player.maxtime<1) and (player.allowed=true) then begin
    crlf;
    d(config.textcolor,'You have used up all your time for today!');
    d(config.textcolor,'Return tomorrow for more action.');
    crlf;
    pause;
    player.name1:=emptystr;
    player.name2:=emptystr;

    normal_exit;
   end;

   if player.allowed=false then begin
        {read mail}
     read_my_mail(player);

   if (player.hps=-9000) then begin
    crlf;
    d(12,'Since your last visit ...');

    crlf;
    d(config.textcolor,'You are recovering from a drug experience.');
    d(config.textcolor,'Return tomorrow for more action.');
    pause;
    player.name1:='';
    player.name2:='';

    normal_exit;

   end;

   if (player.hps=-8000) then begin
    crlf;
    d(12,'Since your last visit ...');

    crlf;
    d(config.textcolor,'You are recovering from your intake of steroids.');
    d(config.textcolor,'Return tomorrow for more action.');

    pause;
    player.name1:='';
    player.name2:='';

    normal_exit;

   end;

    crlf;
    d(12,'Since your last visit ...');
    crlf;
    if player.location<>offloc_prison then begin
     d(config.textcolor,'You may return tomorrow and regain some of your lost pride...');
     crlf;
     pause;
     player.name1:='';
     player.name2:='';

     normal_exit;
    end;

   end

  end;
  if found_user>0 then break;
 end;

 if found_user>0 then begin

  if player.hps<1 then player.hps:=player.maxhps;

  if player.location=offloc_dormitory then begin
   global_auto_probe:=Dormy;
  end
  else if player.location=offloc_home then begin
   global_auto_probe:=AtHome;
  end


  else if player.location in [offloc_innroom1..offloc_innroom4] then begin
   global_auto_probe:=Inn;
  end
  else if player.location=offloc_Castle then begin {castle}
   global_auto_probe:=Slottet;
  end
  else if player.location=offloc_Prison then begin
   global_auto_probe:=Prison;
  end;

  if player.location<>offloc_prison then begin
   player.location:=offloc_dormitory;
  end;

  player.bguard:=0;
  player.bguardnr:=0;

  user_save(player);

  {time_left:=maxtime;}

  user_search:=true;
  exit;

 end;

 if enter_game_if_exists=false then begin
  user_search:=false;
  exit;
 end;


 {**************************}
 {******** NEW USER ********}
 {**************************}

 clearscreen;
 crlf;
 d(5,'Introducing a new user');
 d(5,'+-+-+-+-+-+-+-+-+-+-+-');
 crlf;
 sd(config.textcolor,'Hello ');
 sd(5,username);
 sd(config.textcolor,', you must be a new user.');
 crlf;
 d(config.textcolor,'Dare you enter a dark world filled with evil ?');
 crlf;
 sd(config.textcolor,'(');
 sd(5,'Y');
 sd(config.textcolor,')es, I''m brave and bold!');
 crlf;
 sd(config.textcolor,'(');
 sd(5,'N');
 sd(config.textcolor,')o, I don''t wanna die!');
 crlf;

 sd(config.textcolor,':');
 repeat
  cho:=upcase(getchar);
 until cho in ['Y','N'];

 if cho='N' then begin
  sd(global_talkcol,'I''m scared of monsters!');
  crlf;
  crlf;
  d(12,'Well, bye then coward!');
  crlf;
  pause;

  player.name2:='';
  normal_exit;
 end;

 sd(15,'Yeah, let''s go!');
 crlf;


 {Is this game full?}
 no_play:=false;

 {current number of slots in use}
 x:=fs(FsPlayer);

 {how many players are allowed to play}
 s:=cfg_string(50);
 players_allowed:=str_to_nr(s);
 if (players_allowed<1) or (players_allowed>global_maxplayers) then begin
  players_allowed:=global_maxplayers;
 end;

 if x>=players_allowed then begin

  no_play:=true;
  {check if any of the slots are empty}
  sd(config.textcolor,'Looking for an empty slot to put your character in...');
  for i:=1 to fs(fsplayer) do begin
   load_character(pl0,1,i);

   if (pl0.name1=global_delname1) and (pl0.name2=global_delname2) then begin
    no_play:=false;
    break;
   end;
  end; {for i:= .end.}

  if no_play then d(12,'Not found.')
             else d(14,'Found!');

 end;

 if no_play then begin
  clearscreen;
  crlf;
  d(config.textcolor,'Sorry! This game is full!');
  d(config.textcolor,'Please return later, when the game is reset.');
  crlf;
  d(config.textcolor,'You could also ask the Sysop to configure the game');
  d(config.textcolor,'to room more characters.');
  crlf;
  pause;

  player.name1:=emptystr;
  player.name2:=emptystr;
  normal_exit;

 end;


 {select ALIAS}
 crlf;
 repeat

  d(config.textcolor,'Please choose an alias');
  sd(config.textcolor,':');
  alias:=get_string(21);

  if alias='' then begin

   if confirm('Abort','N')=true then begin
    player.name1:=emptystr;
    player.name2:=emptystr;
    crlf;
    d(14,'Goodbye, adventurer!');
    normal_exit;
   end
   else begin
    continue;
   end;
  end;

  if length(alias)<3 then begin
   d(config.textcolor,'Your alias must have at least 3 letters.');
   continue;
  end;
  crlf;
  d(config.textcolor,'Scanning the books...');
  crlf;

  {*Search for dupe aliases among players*}
  s:=UpperCase(alias);

  x:=0;

if (s='SYSOP') then begin
    d(12,'I''m sorry, but that name is already being used.');
    crlf;
continue
end;

  for i:=1 to fs(FsPlayer) do begin
   load_character(player,1,i);
   if (s=UpperCase(player.name2)) then begin
    d(12,'I''m sorry, but that name is already being used.');
    crlf;
    x:=999;
    break;
   end;
  end; {for i:= .end.}

  if x=999 then continue;

  if x=0 then begin
   {*Search for dupe aliases among NPC:s*}

   for i:=1 to fs(FsNpc) do begin
    load_character(pl0,2,i);
    if s=UpperCase(pl0.name2) then begin
     d(config.textcolor,'I''m sorry, but that name is already being used.');
     crlf;
     x:=999;
     break;
    end;
   end; {for i:= .end.}
  end;

  if x=999 then continue;

  if x=0 then begin
   crlf;
   sd(5,alias);
   if confirm(' is what you want','Y')=true then begin
    x:=888;
   end
   else begin
    crlf;
   end;
   crlf;
  end;

 until x=888;

 repeat

  d(10,'Gender :');
  menu('(M)ale');
  menu('(F)emale');
  sd(config.textcolor,'Choice :');

  {get user-input}
  repeat
   cho:=upcase(getchar);
  until cho in ['M','F'];

  crlf;
  case cho of
   'M':begin
        if confirm('Play a Male character','n')=true then begin
         player.sex:=1;
         break;
        end;
       end;
   'F':begin
        if confirm('Play a Female character','n')=true then begin
         player.sex:=2;
         break;
        end;
       end;
  end; {case .end.}

 until s='Never';

 cho:='?';
 repeat

  if cho='?' then begin
   clearscreen;
   crlf;
   d(config.textcolor,'Choose your Race ');
   crlf;
   menu('(0) Human');
   menu('(1) Hobbit');
   menu('(2) Elf');
   menu('(3) Half-elf');
   menu('(4) Dwarf');
   menu('(5) Troll');
   menu('(6) Orc');
   menu('(7) Gnome');
   menu('(8) Gnoll '+ulcyan+'*poisonous bite');
   {Dan: 'evil immortals': I might implement this}
   menu('(9) Mutant');
   menu('(H) '+ulgreen+'Help');
   menu('(A) Abort');
   crlf;
   sd(config.textcolor,'Your choice :');
  end;

  {get user-input}
  cho:=upcase(getchar);

  if cho in ['0','1','2','3','4','5','6','7','8','9'] then begin

   crlf;
   case cho of
    '0':begin
         s:='a humble';
         player.race:=Human;
        end;
    '1':begin
         s:='a loyal';
         player.race:=Hobbit;
        end;
    '2':begin
         s:='a graceful';
         player.race:=Elf;
        end;
    '3':begin
         s:='an allround';
         player.race:=HalfElf;
        end;
    '4':begin
         s:='a stubborn';
         player.race:=Dwarf;
        end;
    '5':begin
         s:='a stinking';
         player.race:=Troll;
        end;
    '6':begin
         s:='an ill-mannered';
         player.race:=Orc;
        end;
    '7':begin
         s:='a willful';
         player.race:=Gnome;
        end;
    '8':begin
         s:='a puny';
         player.race:=Gnoll;
        end;
    '9':begin
         s:='a weird';
         player.race:=Mutant;
        end;

   end; {case .end.}

   if confirm('Be '+s+' '+uyellow+race_display(1,player.race,0)+config.textcol1,'N')=false then begin
    cho:='?';
   end;

  end;

  {help text}
  if cho='H' then begin
   clearscreen;
   display_text('RACEHELP');
   pause;
   cho:='?';
  end
  else if cho='A' then begin
   crlf;
   crlf;
   if confirm('Abort','N')=true then begin
    player.name1:=emptystr;
    player.name2:=emptystr;
    crlf;
    d(14,'Goodbye, adventurer!');
    normal_exit;
   end
   else begin
    cho:='?';
   end;
  end;

 until cho in ['0','1','2','3','4','5','6','7','8','9'];

 cho:='?';
 repeat
  if cho='?' then begin
   clearscreen;
   crlf;
   d(config.textcolor,'Choose your Profession :   (* special ability)');
   crlf;
   menu('(1) Alchemist   '+ulcyan+'*poison');
   menu('(2) Assassin    '+ulcyan+'*backstabbing');
   menu('(3) Barbarian');
   menu('(4) Bard'); {no songs}
   menu('(5) Cleric      '+ulcyan+'*spells');
   {'dodge expert': I might implement this}
   menu('(6) Jester');
   menu('(7) Magician    '+ulcyan+'*spells');
   menu('(8) Paladin     '+ulcyan+'*soulstrike');
   menu('(9) Ranger');
   menu('(0) Sage        '+ulcyan+'*spells');
   menu('(W) Warrior');
   menu('(H) '+ulgreen+'Help');
   menu('(A) Abort');
   crlf;
   sd(config.textcolor,'Your choice :');
  end;

  {get user-input}
  repeat
   cho:=upcase(getchar);
  until cho in ['1','2','3','4','5','6','7','8','9','0','A','H','W'];


  case cho of
   '1':begin
        s:='a shy';
        player.classid:=Alchemist;
       end;
   '2':begin
        s:='a hiding';
        player.classid:=Assassin;
       end;
   '3':begin
        s:='a powerful';
        player.classid:=Barbarian;
       end;
   '4':begin
        s:='an entertaining';
        player.classid:=Bard;
       end;
   '5':begin
        s:='a praying';
        player.classid:=Cleric;
       end;
   '6':begin
        s:='a foolish';
        player.classid:=Jester;
       end;
   '7':begin
        s:='a secretive';
        player.classid:=Magician;
       end;
   '8':begin
        s:='an honorable';
        player.classid:=Paladin;
       end;
   '9':begin
        s:='a fast';
        player.classid:=Ranger;
       end;
   '0':begin
        s:='a wise';
        player.classid:=Sage;
       end;
   'W':begin
        s:='a brave';
        player.classid:=Warrior;
       end;
  end; {case .end.}

  if cho in ['1','2','3','4','5','6','7','8','9','0','W'] then begin

   crlf;
   if confirm('Be '+s+' '+uyellow+classnames[player.classid]+config.textcol1,'n')=true then begin
    if (player.race in [Troll,Orc]) and (player.classid=Paladin) then begin
     crlf;
     d(config.textcolor,'Impossible combination!');
     d(config.textcolor,'You cannot be a Troll or Orc in combination with');
     d(config.textcolor,'the Paladin profession.');
     crlf;
     pause;
     cho:='?';
    end
    else begin
     break;
    end;
   end
   else begin
    cho:='?';
   end;
  end
  else if cho='H' then begin
   s:='Yes';
   clearscreen;
   display_text('CLASSHELP');
   pause;
   cho:='?';
  end
  else if cho='A' then begin
   crlf;
   crlf;
   if confirm('Abort','N')=true then begin
    player.name1:=emptystr;
    player.name2:=emptystr;
    crlf;
    d(14,'Goodbye, adventurer!');
    normal_exit;
   end;
  end;

 until cho='Never';


 {*user description*}
 for i:=1 to 4 do begin
  player.desc[i]:='';
 end;

 clearscreen;
 crlf;
 d(5,'Character Description :');
 d(5,'=-=-=-=-=-=-=-=-=-=-=-=');
 d(config.textcolor,'Would you like to enter a Character description?');
 d(config.textcolor,'You can always change it later in the configuration menu.');

 crlf;
 if confirm('Enter Description Now','n')=true then begin
  crlf;
  d(config.textcolor,'Example :');
  d(config.textcolor,'1. Before you stands a man of great dignity. His bulging muscles');
  d(config.textcolor,'2. are of enormous proportions and the many scars bear witness of');
  d(config.textcolor,'3. grim battles. His pale blue eyes are staring right at You!');
  d(config.textcolor,'4. Truly a great man to have as a friend.');

  crlf;
  d(config.textcolor,'Enter your description below, Max 4 lines');
  x:=1;
  repeat
   sd(config.textcolor,'['+commastr(x)+']:');
   s:=get_string(70);
   player.desc[x]:=s;
   if player.desc[x]<>'' then x:=x+1;
  until (s='') or (x>4);
 end;
 clearscreen;

 {** giving player his start values**}
 player.name1:=username;
 player.name2:=alias;
 player.allowed:=true;
 player.level:=1;
 player.gold:=startm;
 player.bankgold:=0;
 player.exp:=10;
 player.fights:=dngfights;
 player.healing:=125;
 player.ageplus:=0;
 player.darknr:=3;
 player.chivnr:=3;
 player.chiv:=0;
 player.dark:=0;
 player.ai:='H';
 player.pfights:=plfights;
 player.king:=false;
 player.location:=offloc_dormitory;
 player.team:=emptystr;
 player.teampw:=emptystr;
 player.bguard:=0;
 player.cturf:=false;
 player.gnollp:=0;
 player.mental:=100;
 player.addict:=0;
 player.weappow:=0;
 player.armpow:=0;
 player.blind:=false;
 player.plague:=false;
 player.smallpox:=false;
 player.measles:=false;
 player.leprosy:=false;
 player.mercy:=0;

 for i:=1 to global_maxitem do begin
  player.item[i]:=0;
 end;
 for i:=1 to 6 do begin
  player.phr[i]:=emptystr;
 end;

 player.autoheal:=false;
 player.loyalty:=50;
 player.haunt:=0;
 player.master:='1';
 player.tfights:=3;
 player.thiefs:=3;
 player.brawls:=3;
 player.assa:=3;
 player.poison:=0;

 {spells}
 for i:=1 to global_maxspells do begin
  for j:=1 to 2 do begin
   player.spell[i,j]:=false;
  end;
 end;

 {close combat skills}
 for i:=1 to global_maxcombat do begin
  player.skill[i]:=0;
 end;

 player.spell[1,1]:=true;
 player.trains:=2;

 player.rhand:=0;
 player.lhand:=0;
 player.head:=0;
 player.body:=0;
 player.arms:=0;
 player.lfinger:=0;
 player.rfinger:=0;
 player.legs:=0;
 player.feet:=0;
 player.waist:=0;
 player.neck:=0;
 player.neck2:=0;
 player.face:=0;
 player.shield:=0;
 player.hands:=0;
 player.abody:=0;

 player.immortal:=false;
 player.battlecry:=emptystr;
 player.bguardnr:=0;
 player.casted:=false;
 player.punch:=0;
 player.deleted:=false;
 player.laston:=packed_date;
 player.quests:=0;
 player.god:=emptystr;
 player.royquests:=0;
 player.resurrections:=config.resurrections;
 player.pickpocketattempts:=config.pickpocketattempts;
 player.BankRobberyAttempts:=config.BankRobberyAttempts;


 {*startvalues, based on Class*}
 case player.classid of
  Alchemist
  :begin
     player.hps:=1;
     player.strength:=2;
     player.defence:=1;
     player.stamina:=1;
     player.agility:=2;
     player.charisma:=4;
     player.dex:=3;
     player.wisdom:=5;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Assassin
  :begin
     player.hps:=3;
     player.strength:=4;
     player.defence:=3;
     player.stamina:=3;
     player.agility:=4;
     player.charisma:=2;
     player.dex:=5;
     player.wisdom:=2;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Barbarian
  :begin
     player.hps:=5;
     player.strength:=5;
     player.defence:=4;
     player.stamina:=5;
     player.agility:=4;
     player.charisma:=1;
     player.dex:=2;
     player.wisdom:=1;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Bard
  :begin
     player.hps:=3;
     player.strength:=4;
     player.defence:=3;
     player.stamina:=3;
     player.agility:=3;
     player.charisma:=4;
     player.dex:=4;
     player.wisdom:=3;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Cleric
  :begin
     player.hps:=3;
     player.strength:=3;
     player.defence:=2;
     player.stamina:=2;
     player.agility:=2;
     player.charisma:=4;
     player.dex:=2;
     player.wisdom:=4;
     player.mana:=20;
     player.maxmana:=20;
    end;
  Jester
  :begin
     player.hps:=2;
     player.strength:=3;
     player.defence:=2;
     player.stamina:=2;
     player.agility:=5;
     player.charisma:=3;
     player.dex:=5;
     player.wisdom:=1;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Magician
  :begin
     player.hps:=2;
     player.strength:=1;
     player.defence:=1;
     player.stamina:=1;
     player.agility:=2;
     player.charisma:=5;
     player.dex:=2;
     player.wisdom:=4;
     player.mana:=40;
     player.maxmana:=40;
    end;
  Paladin
  :begin
     player.hps:=4;
     player.strength:=4;
     player.defence:=3;
     player.stamina:=4;
     player.agility:=2;
     player.charisma:=2;
     player.dex:=3;
     player.wisdom:=3;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Ranger
  :begin
     player.hps:=3;
     player.strength:=3;
     player.defence:=3;
     player.stamina:=4;
     player.agility:=3;
     player.charisma:=2;
     player.dex:=4;
     player.wisdom:=3;
     player.mana:=0;
     player.maxmana:=0;
    end;
  Sage
  :begin
     player.hps:=1;
     player.strength:=1;
     player.defence:=2;
     player.stamina:=2;
     player.agility:=2;
     player.charisma:=3;
     player.dex:=3;
     player.wisdom:=5;
     player.mana:=40;
     player.maxmana:=40;
    end;
  Warrior
  :begin
     player.hps:=4;
     player.strength:=4;
     player.defence:=4;
     player.stamina:=4;
     player.agility:=3;
     player.charisma:=2;
     player.dex:=2;
     player.wisdom:=2;
     player.mana:=0;
     player.maxmana:=0;
    end;
 end; {case .end.}

 {*start values, based on Race*}
 case player.race of
  Human
  :begin
     player.age:=random(5)+15;
     player.hps:=player.hps+14;
     player.strength:=player.strength+4;
     player.defence:=player.defence+4;
     player.stamina:=player.stamina+4;
     player.height:=random(40)+180;
     player.weight:=random(45)+75;
     player.eyes:=random(5)+1;
     player.skin:=10;
     case random(4) of
      0: player.hair:=1;
      1: player.hair:=4;
      2: player.hair:=5;
      3: player.hair:=8;
     end;
    end;
  Hobbit
  :begin
     player.age:=random(15)+20;
     player.hps:=player.hps+12;
     player.strength:=player.strength+2;
     player.defence:=player.defence+3;
     player.stamina:=player.stamina+3;
     player.height:=random(37)+100;
     player.weight:=random(40)+40;
     player.eyes:=random(5)+1;
     player.skin:=10;
     case random(4) of
      0: player.hair:=1;
      1: player.hair:=4;
      2: player.hair:=5;
      3: player.hair:=8;
     end;
    end;
  Elf
  :begin
     player.age:=random(15)+20;
     player.hps:=player.hps+11;
     player.strength:=player.strength+3;
     player.defence:=player.defence+2;
     player.stamina:=player.stamina+3;
     player.height:=random(25)+160;
     player.weight:=random(30)+60;
     player.eyes:=random(5)+1;
     player.skin:=10;
     case random(4) of
      0: player.hair:=1;
      1: player.hair:=4;
      2: player.hair:=5;
      3: player.hair:=8;
     end;
    end;
  HalfElf
  :begin
    player.age:=random(10)+16;
    player.hps:=player.hps+13;
    player.strength:=player.strength+2;
    player.defence:=player.defence+3;
    player.stamina:=player.stamina+4;
    player.height:=random(25)+165;
    player.weight:=random(25)+70;
    player.eyes:=random(5)+1;
    player.skin:=10;
    case random(4) of
     0: player.hair:=1;
     1: player.hair:=4;
     2: player.hair:=5;
     3: player.hair:=8;
    end;
   end;
  Dwarf
  :begin
     player.age:=random(15)+25;
     player.hps:=player.hps+17;
     player.strength:=player.strength+5;
     player.defence:=player.defence+5;
     player.stamina:=player.stamina+4;
     player.height:=random(20)+160;
     player.weight:=random(20)+70;
     player.eyes:=random(5)+1;
     player.skin:=7;
     case random(4) of
      0: player.hair:=1;
      1: player.hair:=4;
      2: player.hair:=5;
      3: player.hair:=8;
     end;
    end;
  Troll
  :begin
     player.age:=random(15)+15;
     player.hps:=player.hps+20;
     player.strength:=player.strength+7;
     player.defence:=player.defence+7;
     player.stamina:=player.stamina+5;
     player.height:=random(35)+185;
     player.weight:=random(30)+85;
     player.eyes:=random(5)+1;
     player.skin:=5;
     case random(4) of
      0: player.hair:=5;
      1: player.hair:=4;
      2: player.hair:=4;
      3: player.hair:=5;
     end;
    end;
  Orc
  :begin
     player.age:=random(10)+15;
     player.hps:=player.hps+14;
     player.strength:=player.strength+3;
     player.defence:=player.defence+4;
     player.stamina:=player.stamina+3;
     player.height:=random(20)+170;
     player.weight:=random(20)+70;
     player.eyes:=random(5)+1;
     player.skin:=5;
     case random(4) of
      0: player.hair:=5;
      1: player.hair:=4;
      2: player.hair:=4;
      3: player.hair:=5;
     end;
    end;
  Gnome
  :begin
     player.age:=random(15)+15;
     player.hps:=player.hps+12;
     player.strength:=player.strength+2;
     player.defence:=player.defence+3;
     player.stamina:=player.stamina+3;
     player.height:=random(30)+160;
     player.weight:=random(15)+60;
     player.eyes:=random(5)+1;
     player.skin:=3;
     case random(4) of
      0: player.hair:=3;
      1: player.hair:=3;
      2: player.hair:=4;
      3: player.hair:=9;
     end;
    end;
  Gnoll
  :begin
     player.age:=random(10)+18;
     player.hps:=player.hps+9;
     player.strength:=player.strength+2;
     player.defence:=player.defence+2;
     player.stamina:=player.stamina+2;
     player.height:=random(15)+140;
     player.weight:=random(15)+50;
     player.eyes:=random(5)+1;
     player.skin:=4;
     case random(4) of
      0: player.hair:=3;
      1: player.hair:=3;
      2: player.hair:=4;
      3: player.hair:=9;
     end;
    end;
  Mutant
  :begin
     player.age:=random(15)+18;
     player.hps:=player.hps+random(10)+10;
     player.strength:=player.strength+random(8)+1;
     player.defence:=player.defence+random(8)+1;
     player.stamina:=player.stamina+random(5)+1;
     player.height:=random(50)+150;
     player.weight:=random(50)+50;
     player.eyes:=random(10)+1;
     player.skin:=random(10)+1;
     player.hair:=random(10)+1;
    end;
 end; {case .end.}

 player.maxhps:=player.hps;
 player.wellwish:=false;
 player.m_kills:=0;
 player.m_defeats:=0;
 player.p_kills:=0;
 player.p_defeats:=0;
 player.interest:=0;
 player.alive_bonus:=0;
 player.expert:=false;
 player.teamrec:=0;
 player.maxtime:=maxtime;
 player.ear:=global_ear_all;
 player.weapon:=0;
 player.armor:=0;
 player.apow:=0;
 player.wpow:=0;
 player.disres:=0;
 player.amember:=false;
 for i:=1 to 20 do begin
  player.medal[i]:=false;
 end;
 player.bankguard:=false;
 player.bankwage:=0;
 player.weaphag:=3;
 player.armhag:=3;
 player.recnr:=0;
 player.auto_meny:=true;
 player.roytaxpaied:=0;
 player.wrestlings:=Config.MaxWrestlings;
 player.drinksleft:=Config.DrinksatOrbs;
 player.daysinprison:=0;
 player.umanbeartries:=0;
 player.massage:=0;
 player.gym_sessions:=Config.GymSessions;
 player.Gym_Owner:=0; {controller of the gym? has to be in a team}
 player.Gym_Card:=0; {free card to the gym? if not gym_owner that is}
 player.royqueststoday:=0;
 player.KingVotePoll:=0; {how many days since voted for king popularity}
 player.KingLastVote:=0; {how did player vote last time}
 player.married:=false; {is player married, only used when creating scores}
 player.Kids:=0; {how many kids this playeer is father/mother to}
 player.IntimacyActs:=Config.IntimacyActs; {how many acts of intimacy has player left today?}
 player.Pregnancy:=0; {is player pregnant? 0=no, 1...X = days pregnant}
 player.FatherID:=emptystr;
 player.id:=crypt(15);
 player.autohate:=0; {automatically dislike attacking player}
 player.Tax_Relief:=false; {free from tax?}
 player.MarriedTimes:=0; {counter for marriages}
 player.Bard_Songs_Left:=5; {ehhh..quite self-explanatory huh?}
 player.prison_escapes:=config.prison_escapes; {attempts allowed to escape from prison}
 player.filtyp:=1; {1=player file, 2=npc file}

 {trying to find an EMPTY slot to put new player in}
 slot:=0;
 for i:=1 to fs(FsPlayer) do begin
  load_character(pl0,1,i);
  if (pl0.deleted) or (UpperCase(pl0.name1)+UpperCase(pl0.name2)=global_delname1+global_delname2)=true then begin
   slot:=i;
   break;
  end;
 end; {for i:= .end.}

 if slot>0 then begin
  {d(config.textcolor,'Empty slot found....');}
  player.recnr:=slot;
  save_new_guy(slot);
 end
 else begin
  {no empty slot found in user data base. we put new player at end of file}
  slot:=fs(FsPlayer)+1;
  player.recnr:=slot;
  save_new_guy(slot);
 end;

 {help on the numeric input system, with hotkeys and all}
 crlf;
 crlf;
 numeric_input_help;

 {off-line configuration}
 pause;
 crlf;
 crlf;
 d(config.textcolor,'I will now ask you a few questions on how');
 d(config.textcolor,'you would like your character to behave.');
 d(config.textcolor,'You can always change these options later on,');
 d(config.textcolor,'by pressing '+config.textcol2+'C'+config.textcol1+' from your status screen.');
 pause;
 crlf;

 {auto display menues?}
 crlf;
 if confirm('Would you like to auto-display menus','Y')=false then begin
  player.auto_meny:=false;
  d(15,'Auto-Display menus is OFF.');
 end
 else begin
  player.auto_meny:=true;
  d(15,'Auto-Display menus is ON.');
 end;

 {auto_hate setting}
 crlf;
 d(12,'Attitude when attacked');
 d(12,mkstring(22,underscore));
 crlf;
 d(config.textcolor,'When you are attacked, do you want your relation');
 sd(config.textcolor,'with the attacker to automatically deteriorate?');

 if confirm('','Y')=true then begin
  player.autohate:=1;
 end;

 {let the player define some phrases}

 {battle cry}
  crlf;
  d(config.textcolor,'What is your general '+ulred+'BATTLE-CRY'+config.textcol1+'?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='Here I come!!!';
  get_stringDefault(s,70);
  d(global_talkcol,s);
   player.battlecry:=s;
   
 {phrase #1}
  crlf;
  d(config.textcolor,'What shall you say when you are being attacked?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='You are going to regret this!';
  get_stringDefault(s,70);
  d(global_talkcol,s);
   player.phr[1]:=s;
   
 {phrase #2}
  crlf;
  d(config.textcolor,'What shall you say when you have defeated somebody?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='You lose!';
  get_stringDefault(s,70);
  d(global_talkcol,s);
  crlf;
     player.phr[2]:=s;
 
 {phrase #3}
  crlf;
  d(config.textcolor,'What shall you say when you have been defeated?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='It wasn''t a fair fight!';
  get_stringDefault(s,70);
  d(global_talkcol,s);
   player.phr[3]:=s;
 
 {phrase #4}
  crlf;
  d(config.textcolor,'What shall you say when you are begging for mercy?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='Let me go sucker!';
  Get_StringDefault(s,70);
  d(global_talkcol,s);
  crlf;
   player.phr[4]:=s;
 
 {phrase #5}
  crlf;
  d(config.textcolor,'What shall you say when you spare your opponents life?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='It''s your lucky day!';
  Get_StringDefault(s,70);
  d(global_talkcol,s);
   player.phr[5]:=s;
 
 {phrase #6}
  crlf;
  d(config.textcolor,'What shall you say when you don''t spare your opponents life?');
  d(config.textcolor,'Enter phrase (1 line)');
  sd(config.textcolor,':'+utalkc);
  s:='This is not the time for weakness! DIE!';
  get_stringDefault(s,70);
  d(global_talkcol,s);
   player.phr[6]:=s;
 
 {put the new players arrival in the news}
 case random(3) of
  0:begin {news-paper}
     newsy(true,
     config.textcol1+'New Player!',
     ' We welcome '+uplc+alias+config.textcol1+', a young brave '+urac+race_display(2,player.race,0)+config.textcol1,
     ' who seeks fortune and glory!',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
  1:begin {news-paper}
     newsy(true,
     config.textcol1+'New Player!',
     ' We welcome '+uplc+alias+config.textcol1+', a young brave '+classnames[player.classid],
     ' who seeks fortune and glory!',
     '',
     '',
     '',
     '',
     '',
     '',
     '');
    end;
  2:begin {news-paper}
     newsy(true,
     config.textcol1+'New Player!',
     ' We welcome '+uplc+alias+config.textcol1+' the '+classnames[player.classid]+' to the realm!',
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

 {send message to online players}
 online_send_to_all(uwhite+'*NEW PLAYER*'+uplc+' '+player.name2+config.textcol1+' has joined us!',player.name2,'');

 {a little welcome text}
 { male
   female

   race

   profession

 }


{ clearscreen;
 crlf;

 sd(2,'The Childhood of ');
 d(5,player.name2);
 d(2,'Before you travel along the road of destiny, there are a few matters');
 d(2,'still left to decide. Answer in line with your heart, and your life');
 d(2,'might be something for your parents to be proud of.');
 d(2,'As a child you were always');


 menu('(S)quash');
 menu('(L)et be');


{ d(2,'You were born a sunny April morning in the year of the lord 1195.');
 d(2,'Being the only child in a cole miners family, you soon leave home');
 d(2,'headed for the unknown ...');
}

 pause;

 {return result}
 user_search:=true;

end; {User_Search *end*}

end. {Unit UserHunc.end.}
