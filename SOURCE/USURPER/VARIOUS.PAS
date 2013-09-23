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


unit Various; {Usurper - Various Routines I}

interface

uses
  Init, InitGods {$IFDEF FPC}, RPPort{$ENDIF};

{Miscellaneous}
procedure Zero_Player(var target: UserRec);
procedure Make_Delay_Dots(col, dots, delayy: integer);
procedure Swappy(var nr1: SmallWord; var nr2: SmallWord);
procedure Create_Maint_Flag;
function Random_Path: s70;
function Crypt(nr: word): s70;
function Adds(const Name: s30): s3;

{Alchemist}
function Alchemist_Poison(const ply: Userrec): s30;

{Fight}
function Soul_Effect(var paladin: userrec; soul: longint): longint;
function Normal_Attack(silent: boolean; var attacker: UserRec): longint;
function Percent(now: longint; max: longint): integer;
procedure Normal_Defence(var defender: UserRec);

{Infections/Diseases}
procedure Infections;
procedure Infections2(fastgame: boolean; var player0: UserRec);
function Immunity(def: longint): s70;

{Healing}
procedure Quick_Healing(var pl: userrec);
procedure Computer_Healing(Show: boolean; var player0: UserRec);
procedure Auto_healing(var player0: UserRec);
procedure Healing(var pl: userrec);

{Configuration}
procedure Read_Start_CfgValues;
function Cfg_String(i: word): s100;

{FakePlayer routines}
procedure Get_FakePlayerData(var fake: UserRec);
procedure Fakeplayers_Congratulate_Levelraiser(const ply: userrec);
function FakePlayer_Reply: s70;
function FakePlayer_New_Message(const receiver: onlinerec): s70;

{Dungeon}
procedure Setup_DungeonItems;
function Dungeon_Reward(dungeon: integer): longint;

 {BadWords}
function Remove_BadWords(const s: string): string; {check string for bad words}

 {King}
procedure New_King(var king: kingrec); {init a kingrecord}
procedure King_Is_Gone; {when king is somehow removed/gone from office}
function Get_King(var ply: userrec): boolean;
function KingString(const sex: byte): s30; {returns either 1=KING or 2=QUEEN}

procedure Inform_King(const line1, line2, line3, line4, line5, line6, line7, line8, line9, line10,
  line11, line12, line13, line14, line15: s90);

{Quests - most quest related procedures are located in various2.pas}
procedure Quest_Rankings;

{News-Paper}
procedure Read_News_Paper;

{Close Combat}
function HitChance(var nr: smallint): integer;
function Condition(now, max: longint): s70;
function Bash_Name(nr: integer): s70;
function Bash_Rank(nr: integer): s70;

{Monsters}
procedure Dispose_Monsters;
function Monster_Active(i: integer): boolean;
function Target_Monster: byte;
function Monster_Power(mnr: integer): longint;
procedure Reset_Monsters;
procedure Create_Monster(nr: byte; const Name: s70; hps: longint; strength: longint; defence: longint;
  const phrase: s70; grabweap: boolean; grabarm: boolean; const weapon: s70; const armor: s70;
  poisoned: boolean; disease: boolean; punch: longint; armpow: longint; weappow: longint);



{Race & Class}
function Race_Display(const mode: byte; race: races; const racenr: byte): s10;
function Class_Corr2(i: byte): classes;
function Class_Corr(class: classes): byte;
function Class_Restricted(class: classes; var o: orec; instead: byte): boolean;

{Help Texts}
function Numeric_Help: s90;

{Experience}
procedure IncPlayerExp(var ply: UserRec; exp: longint);
procedure DecPlayerExp(var ply: UserRec; exp: longint);
procedure XPLose(var loser: UserRec);

procedure IncGodExp(var god0: GodRec; exp: longint);
procedure DecGodExp(var god0: GodRec; exp: longint);

{Money}
function IncPlayerMoney(var ply: UserRec; coins: longint): boolean;
procedure DecPlayerMoney(var ply: UserRec; coins: longint);
function IncBankMoney(var ply: UserRec; coins: longint): boolean;
procedure DecBankMoney(var ply: UserRec; coins: longint);

function IncInterest(var ply: UserRec; coins: longint): boolean;
function IncBankWage(var ply: UserRec; coins: longint): boolean;

{King}
function IncKingTreasury2(var king: KingRec; coins: longint): boolean;
procedure DecKingTreasury(var king: KingRec; coins: longint);
procedure Pay_Royal_Guard(var ply: UserRec; var king: kingrec);
procedure Sack_Royal_Guards;

{Experience / Chivalry / Darkness}
procedure Give_Chivalry(var pl: userrec; chiv: longint);
procedure Give_Darkness(var pl: userrec; dark: longint);
function Vicious_String(const pl: userrec): s70;

function BattleMaster_String(const pl: userrec): s70;


procedure Pre_Darkness;
procedure Pre_Chivalry;
procedure Pre_Charity;

{Profiles}
procedure Player_Profile(const caller, ply: userrec);

implementation

uses
  Crt, DDplus, Jakob,
  Cms, Mail, Resetg,
  PlvsPlc, PlComp, Various2,
  Various3, Relation, News,
  Online, File_Io2, File_Io;

procedure Pre_Darkness;
begin
  if player.chiv > 0 then
  begin
    d(15, 'Your Chivalry rating went down after this outrageous behaviour!');
  end else
  begin
    d(15, 'Your Dark soul became even darker after this outrageous behaviour!');
  end;
end;

procedure Pre_Charity;
begin
  if player.dark > 0 then
  begin
    d(15, 'Your Dark soul became lighter after this decent behaviour!');
  end else
  begin
    d(15, 'Your bright soul became even brighter after this act of charity!');
  end;
end; {pre_charity *end*}


procedure Pre_Chivalry;
begin
  if player.dark > 0 then
  begin
    d(15, 'Your Dark soul became lighter after this decent behaviour!');
  end else
  begin
    d(15, 'Your bright soul became even brighter after this act of chivalry!');
  end;
end;

procedure Give_Chivalry(var pl: userrec; chiv: longint);
begin

  if pl.dark > 0 then
  begin
    pl.dark := pl.dark - chiv;
    if pl.dark < 0 then
      pl.dark := 0;
  end else
  begin
    pl.chiv := pl.chiv + chiv;
    if pl.chiv > 30000 then
      pl.chiv := 30000;
  end;

end;

procedure Give_Darkness(var pl: userrec; dark: longint);
begin

  if pl.chiv > 0 then
  begin
    pl.chiv := pl.chiv - dark;
    if pl.chiv < 0 then
      pl.chiv := 0;
  end else
  begin
    pl.dark := pl.dark + dark;
    if pl.dark > 30000 then
      pl.dark := 30000;
  end;

end; {give_darkness *end*}

function Vicious_String(const pl: userrec): s70;
var Result: s70;
begin {used when examining sleeping players in the Dorm}

      {returns a string with info on player pls soul}
  if pl.dark > 0 then
  begin
    if (pl.dark >= 1) and (pl.dark <= 100) then
    begin
      Result := 'mean';
    end else
    if (pl.dark >= 101) and (pl.dark <= 1000) then
    begin
      Result := 'vicious';
    end else
    if (pl.dark >= 1001) and (pl.dark <= 5000) then
    begin
      Result := 'brutal';
    end else
    if (pl.dark >= 5001) and (pl.dark <= 9000) then
    begin
      Result := 'sadist';
    end else
    if (pl.dark >= 9001) and (pl.dark <= 15000) then
    begin
      Result := 'evil';
    end else
    if (pl.dark >= 15001) and (pl.dark <= 27000) then
    begin
      Result := 'black soul';
    end else
    if (pl.dark >= 27001) and (pl.dark <= 27001) then
    begin
      Result := 'extremely evil';
    end else
    if (pl.dark >= 55001) and (pl.dark <= 99999) then
    begin
      Result := 'satans child';
    end else Result := 'devils right hand';

  end else
  if pl.chiv > 0 then
  begin
    if (pl.chiv >= 1) and (pl.chiv <= 100) then
    begin
      Result := 'happy';
    end else
    if (pl.chiv >= 101) and (pl.chiv <= 1000) then
    begin
      Result := 'warm-hearted';
    end else
    if (pl.chiv >= 1001) and (pl.chiv <= 5000) then
    begin
      Result := 'kind';
    end else
    if (pl.chiv >= 5001) and (pl.chiv <= 9000) then
    begin
      Result := 'good';
    end else
    if (pl.chiv >= 9001) and (pl.chiv <= 15000) then
    begin
      Result := 'good-doer';
    end else
    if (pl.chiv >= 15001) and (pl.chiv <= 27000) then
    begin
      Result := 'extremely kind';
    end else
    if (pl.chiv >= 27001) and (pl.chiv <= 55000) then
    begin
      Result := 'extremely virtous';
    end else
    if (pl.chiv >= 55001) and (pl.chiv <= 99999) then
    begin
      Result := 'angel heart';
    end else Result := 'gods device';

  end else
  begin
    Result := 'neutral';
  end;

  {return result}
  vicious_string := '*' + Result + '*';

end; {vicious_string *end*}

function BattleMaster_String(const pl: userrec): s70;
var Result: s70;
begin {used when examining sleeping players in the Dorm}

      {returns a string with info on player experience in battle}
  case (pl.p_kills + pl.p_defeats) of
    0: Result := 'wimp!';
    1..7: Result := 'baby soldier';
    8..15: Result := 'novice';
    16..50: Result := 'amateur';
    51..90: Result := 'adept';
    91..110: Result := 'warrior';
    111..150: Result := 'soldier';
    151..250: Result := 'veteran';
    251..350: Result := 'mercenary';
    351..470: Result := 'experienced adventurer';
    471..600: Result := 'wardog';
    601..900: Result := 'battle tank';
    else Result := 'battle-god';
  end; {case .end.}

       {return result}
  battlemaster_string := '*' + Result + '*';

end; {battlemaster_string *end*}


function Numeric_Help: s90;
begin
     {used by numeric input routines, help text}
  numeric_help := ', ' + config.textcol2 + MaxInput_Key + config.textcol1 + ' for MAX' + ')';
end; {numeric_help *end*}

procedure Create_Maint_Flag; {this proc creates MAINT.FLG which
                              forbids any other node trying to enter game}
var txt: Text;
  s:     s30;
begin

  if open_txtfile(trewrite, txt, global_maintfile) then
  begin
    {set node}
    if local then
      s := 'LOCAL'
    else s := global_cnode;
    writeln_to_text(txt, 'Node ' + s);
    writeln_to_text(txt, 'This is a temporary file created when Usurper runs');
    writeln_to_text(txt, 'the daily maintenance.');
    writeln_to_text(txt, 'Created: ' + todays_date + ', ' + todays_time);
    close_text(txt);
  end else
  begin
    normal_exit;
  end;

end; {create_maint_flag *end*}

function Random_Path: s70;
const s: string[15] = '';
begin {pretty meaningless function. used in dungeon events}

  s := '*unknown*';
  case random(6) of     {to fake arrivals and some random exits}
    0: s := 'North';
    1: s := 'South';
    2: s := 'West';
    3: s := 'East';
    4: s := 'Up';
    5: s := 'Down';
  end; {case .end.}

       {return result}
  random_path := s;

end; {random_path *end*}

function Class_Corr(class: classes): byte;
var i: byte;
begin

  case class of
    Alchemist: i := 1;
    Assassin: i := 2;
    Barbarian: i := 3;
    Bard: i := 4;
    Cleric: i := 5;
    Jester: i := 6;
    Magician: i := 7;
    Paladin: i := 8;
    Ranger: i := 9;
    Sage: i := 10;
    Warrior: i := 11;
  end;

  class_corr := i;

end; {class_corr *end*}

function Class_Corr2(i: byte): classes;
var j: classes;
begin

  case i of
    1: j := Alchemist;
    2: j := Assassin;
    3: j := Barbarian;
    4: j := Bard;
    5: j := Cleric;
    6: j := Jester;
    7: j := Magician;
    8: j := Paladin;
    9: j := Ranger;
    10: j := Sage;
    11: j := Warrior;
  end;

  class_corr2 := j;

end; {class_corr2 *end*}

function Class_Restricted(class: classes; var o: orec; instead: byte): boolean;
var i: byte;
begin

  {this function sees if item X is restricted for CLASS}
  {returns true if item cannot be used by class}
  i := instead;
  if instead = 0 then
  begin
    i := class_corr(class);
  end;

  {return result}
  if o.restrict[i] then
    class_restricted := True
  else class_restricted := False;

end; {class_restricted *end*}



{*** START *** Monster related procs / functions *** START ***}
procedure Dispose_Monsters;
var i: byte;
begin {get rid of all monster, occupying memory}

  if global_monsterinit then
  begin
    for i := 1 to global_maxmon do
    begin
      dispose(monster[i]);
    end;
  end;

end;

function Monster_Power(mnr: integer): longint;
var Result: longint;
begin {calculates monster #mnr powers..depending on weappower & hps}

      {init variables}
  Result := 0;

  Result := (monster[mnr]^.hps) + (monster[mnr]^.weappow);

  {return result}
  monster_power := Result;

end; {monster_power *end*}

function Target_Monster;
var
  done:   boolean;
  k, ii, rad, temp: integer;
  cho:    char;
  s:      s70;
  x:      integer;

  Result: integer;

begin

  Result := 1;
  done := False;
  k := 0;

  for ii := 1 to global_maxmon do
  begin
    if monster[ii]^.hps > 0 then
    begin
      k := k + 1;
      temp := ii;
    end;
  end; {for ii:= .end.}

  if k = 1 then
  begin
    Result := temp;
    done := True;
  end;

  if done = False then
  begin
    crlf;
    sd(config.textcolor, 'Pick Target (?=list, [Enter]=First Monster) :');
    repeat

      s := get_string(5);

      if s = '?' then
      begin
        crlf;
        rad := 0;
        for ii := 1 to global_maxmon do
        begin
          if (monster[ii]^.hps > 0) and (monster[ii]^.Name <> '') then
          begin
            sd(3, '#' + commastr(ii) + ' ');
            d(global_moncol, monster[ii]^.Name);
            Inc(rad);
          end;
        end; {for ii:= .end.}
        sd(config.textcolor, ':');
      end else
      begin
        x := str_to_nr(s);

        if (x < 1) or (x > global_maxmon) then
          x := 0;

        if x = 0 then
        begin
          rad := 1;
          repeat
            if monster[rad]^.hps > 0 then
            begin
              Result := rad;
              cho := 'Z';
              crlf;
              done := True;
              break;
            end;
            rad := rad + 1;
          until rad > global_maxmon;
        end else
        begin
          rad := x;
          repeat
            if monster[rad]^.hps > 0 then
            begin
              Result := rad;
              cho := 'Z';
              crlf;
              done := True;
              break;
            end;
            rad := rad + 1;
          until rad > global_maxmon;
        end;
      end;

    until done;
  end;
  crlf;

  {return result}
  target_monster := Result;

end; {target_monster *end*}

function Monster_Active(i: integer): boolean;
var Result: boolean;
begin

  {Is monster I active?}

  if (monster[i]^.Name <> '') and (monster[i]^.hps > 0) then
  begin
    Result := True;
  end else
  begin
    Result := False;
  end;

  {return result}
  monster_active := Result;

end; {monster_active *end*}

procedure Reset_Monster(nr: byte);
var i: byte;
begin
  {reset monster #NR}
  monster[nr]^.hps := 0;
  monster[nr]^.phrase := emptystr;
  monster[nr]^.Name := emptystr;
  monster[nr]^.grabweap := False;
  monster[nr]^.grabarm := False;
  monster[nr]^.weapon := emptystr;
  monster[nr]^.armor := emptystr;
  monster[nr]^.poisoned := False;
  monster[nr]^.disease := False;
  monster[nr]^.punch := 0;
  monster[nr]^.magicres := 0;
  monster[nr]^.target := 0;
  monster[nr]^.strength := 0;
  monster[nr]^.armnr := 0;
  monster[nr]^.weapnr := 0;
  monster[nr]^.defence := 0;
  monster[nr]^.weappow := 0;
  monster[nr]^.armpow := 0;
  monster[nr]^.iq := 0;
  monster[nr]^.evil := 0;
  monster[nr]^.wuser := False;
  monster[nr]^.auser := False;
  monster[nr]^.magiclevel := 0;
  monster[nr]^.maxmana := 0;
  monster[nr]^.mana := 0;

  for i := 1 to global_maxmspells do
  begin
    monster[nr]^.spell[i] := False;
  end; {for i:= .end.}

end;   {reset_monster *end*}

procedure Create_Monster(nr: byte; const Name: s70; hps: longint; strength: longint; defence: longint;
  const phrase: s70; grabweap: boolean; grabarm: boolean; const weapon: s70; const armor: s70;
  poisoned: boolean; disease: boolean; punch: longint; armpow: longint; weappow: longint);

begin

  {create a new monster (nr)}

  {reset monster first}
  reset_monster(nr);

  monster[nr]^.Name := Name;
  monster[nr]^.hps := hps;
  monster[nr]^.strength := strength;
  monster[nr]^.defence := defence;
  monster[nr]^.phrase := phrase;
  monster[nr]^.grabweap := grabweap;
  monster[nr]^.grabarm := grabarm;
  monster[nr]^.weapon := weapon;
  monster[nr]^.armor := armor;
  monster[nr]^.poisoned := poisoned;
  monster[nr]^.disease := disease;
  monster[nr]^.punch := punch;
  monster[nr]^.armpow := armpow;
  monster[nr]^.weappow := weappow;

end; {create_monster **END**}

procedure Reset_Monsters; {reset ALL monsters}
var i: byte;
begin

  for i := 1 to global_maxmon do
  begin
    reset_monster(i);
  end; {for i:= .end.}

end;

{*** END *** Monster related procs / functions *** END ***}

function Normal_Attack;
var
  temp: ^longint;
begin

  new(temp);

  {calculates a normal attack from Attacker}
  if config.classic then
  begin
    temp^ := attacker.wpow;
  end else
  begin
    temp^ := attacker.weappow;
  end;

  temp^ := temp^ + random(attacker.strength);

  if temp^ < 0 then
  begin
    temp^ := 0;
  end;

  if config.classic = False then
  begin
    {fixar till eventuella left hand items}
    if (attacker.lhand > 0) and (attacker.rhand > 0) and (temp^ > 1) then
    begin
      {temp^:=temp^ div 2;}
    end;
  end;

  {l„gger till styrke bonus}
  if attacker.strength > 4 then
  begin
    Inc(temp^, (attacker.strength div 5));
  end;

  if temp^ < 0 then
  begin
    temp^ := 0;
  end;

  {fixing poisoned weapons, from Alchemists}
  if attacker.poison > 0 then
  begin
    Inc(temp^, (random(attacker.poison)));
    if random(4) = 0 then
    begin
      Dec(attacker.poison);
    end;
  end;

  normal_attack := temp^;

  if (attacker.mental < 50) and (random(3) = 0) then
  begin
    if attacker.name2 = player.name2 then
    begin
      if not silent then
      begin
        d(3, 'Your miss your blow due to lack of concentration.');
      end;
    end else
    begin
      if not silent then
      begin
        d(3, attacker.name2 + ' missed ' + sex3[attacker.sex] + ' blow due to lack of concentration.');
      end;
    end;
    normal_attack := 0;
  end;

  if (attacker.addict > 50) and (random(3) = 0) then
  begin
    if attacker.name2 = player.name2 then
    begin
      if not silent then
      begin
        d(3, 'You start to hallucinate, and miss your blow.');
      end;
    end else
    begin
      if not silent then
      begin
        d(3, attacker.name2 + ' suffers from hallucinations.');
      end;
    end;
    normal_attack := 0;
  end;

  dispose(temp);

end; {normal_attack *end*}


procedure Normal_Defence;
var
  yy:    longint;
  rr:    real;
  slask: longint;

begin

  {calculates normal armor defence from Defender}
  yy := 0;
  rr := 0;
  slask := 0;

  if config.classic then
  begin
    if defender.apow > 1 then
    begin
      rr := (config.abase * defender.apow);
      yy := round(rr);
      slask := defender.apow - yy;
    end;
  end else
  begin
    if defender.armpow > 1 then
    begin
      rr := (config.abase * defender.armpow);
      yy := round(rr);
      slask := defender.armpow - yy;
    end;
  end;

  Inc(defender.absorb, yy);

  {regenerar mana}
  if defender.class in [Cleric, Magician, Sage] then
  begin
    if defender.mana < defender.maxmana then
    begin
      Inc(defender.mana);
      if defender.mana > defender.maxmana then
      begin
        defender.mana := defender.maxmana;
      end;
    end;
  end;

  if defender.absorb < 0 then
  begin
    defender.absorb := 0;
  end;

end; {normal_defence *end*}

function Cfg_String(i: word): s100; {Reads option/line I from ucfg}
var

  j:   integer;

  s:   string;

  txt: Text;

begin

  {init}
  s := '';

  if f_exists(global_ucfg) = True then
  begin
    {returns option I from the usurper config file}
    if open_txtfile(treset, txt, global_ucfg) then
    begin
      for j := 1 to i do
      begin
        readln_from_text(txt, s);
      end; {for j:= .end.}
      close_text(txt);
    end else
    begin
      {error}
      unable_to_access(global_ucfg, access_error);
    end;
  end else
  begin
    {couldn't find the .cfg file!}
    unable_to_find(global_ucfg);
  end;

{$IFDEF UNIX}
  // translate \ to / for path related entries
  // 70..83 = score files
  // 99 = semaphore path
  // 117..120 = news
  if (i in [70..83, 99, 117..120]) then
  begin
    while (Pos('\', S) > 0) do
    begin
      Insert('/', S, Pos('\', S));
      Delete(S, Pos('\', S), 1);
    end;
  end;
{$ENDIF}

  {return result}
  cfg_string := s;

end; {cfg_string *end*}

function FakePlayer_New_Message(const receiver: onlinerec): s70;
var s: s70;
begin {fakeplayer sends nonsense first message to online human player}

  s := 'Hihi!';

  case random(48) of
    0: s := 'Hi there!';
    1: s := 'Your mother is ugly!';
    2: s := 'I hate ' + race_display(3, receiver.race, 0) + '!';
    3: s := 'I hate ' + classnames[receiver.class] + 's !';
    4: s := 'Why don''t you quit when you can!';
    5: s := 'Cheater!';
    6: s := 'Wanna kiss me?';
    7: s := 'Hug me!';
    8: s := 'Who are you?';
    9: s := 'You are ugly!';
    10: s := race_display(3, receiver.race, 0) + ' are thieves!';
    11: s := 'Wanna fight?';
    12: s := 'Wanna take a trip to the dungeons?';
    13: s := 'Go ahead, make my day!';
    14: s := 'Zzaaarpppmihhhtrhril!';
    15: s := 'Drop dead!';
    16: s := 'Your fighting skills are worthless.';
    17: s := 'I will never join you!';
    18: s := 'Lowlife!';
    19: s := 'I want to marry you!';
    20: s := 'Could I see you at the Inn tonight?';
    21: s := 'Grafgh?';
    22: s := 'How are you?';
    23: s := 'Gribhmni greppzin woghkl?';
    24: s := 'Warrfghu Imnyths Lofllar!';
    25: s := 'The kitten said: me be good!';
    26: s := 'fancy a walk in the Ice Caves?';
    27: s := 'where are you?';
    28: s := 'I have something for you!';
    29: s := 'I have a blade with your name on it!';
    30: s := 'Oh boy, I hate you so much!';
    31: s := 'You again!!';
    32: s := 'Why do you even bother?';
    33: s := 'Huoulj Margath Offnuni?';
    34: s := 'I dislike you.';
    35: s := 'I like your looks.';
    36: s := 'Gimme a hug!';
    37: s := 'you can kiss my butt!';
    38: s := 'Oh, I hate you so much!';
    39: s := 'Blah blah blah...';
    40: s := 'I would like to cut your head off!';
    41: s := 'Have a drink at Orbs!';
    42: s := 'Come have a drink with me!';
    43: s := 'Would you buy me a drink?';
    44: s := 'I need money, please!';
    45: s := 'You''re so cute!';
    46: s := 'Give us a kiss!';
    47: s := 'Hi sweetie!';
  end; {case .end.}

       {return result}
  fakeplayer_new_message := s;

end; {fakeplayer_new_message *end*}

function FakePlayer_Reply: s70;
var
  s: s70;
begin {fakeplayer response to players who send them online chatmail}

  s := 'Hihi!';
  case random(33) of
    0: s := '??';
    1: s := 'what are you saying?';
    2: s := 'idiot.';
    3: s := 'leave me alone!';
    4: s := 'hi.';
    5: s := 'go away!';
    6: s := 'wanna team up?';
    7: s := 'nope.';
    8: s := 'yes...';
    9: s := 'i don''t know.';
    10: s := 'speak english!';
    11: s := 'shut up fool.';
    12: s := 'yes?';
    13: s := 'what are you babbling about?';
    14: s := 'oh no..not you again!';
    15: s := 'you are rambling as usual.';
    16: s := 'do something useful for a change.';
    17: s := 'i''m busy!';
    18: s := 'I''m leaving, sorry.';
    19: s := 'Grabbel grobbel bnurf!?';
    20: s := 'fool!';
    21: s := 'leave me be.';
    22: s := 'leave me alone!';
    23: s := 'you are a pain in the *ss!';
    24: s := 'crawl back home';
    25: s := 'that''s enough!';
    26: s := 'balloon-head!';
    27: s := 'misfit!';
    28: s := 'bye dear!';
    29: s := 'haha!';
    30: s := 'you''re kidding right!?';
    31: s := 'meet me at Orbs!';
    32: s := 'tjack-pundare!';
  end; {case .end.}

       {return result}
  fakeplayer_reply := s;

end; {fakeplayer_reply *end*}

procedure Fakeplayers_Congratulate_Levelraiser(const ply: userrec);
var
  i:     word;

  s:     s70;

  faker: onlinerec;

begin {fakeplayers congratulate/scorn online player "ply" who just
       raised a level online. called from various2.pas=>raise_player}

  for i := 1 to fs(FsOnline) do
  begin

    {load online character}
    load_onliner(fload, faker, i);
    if (faker.fake = True) and (faker.Name <> '') then
    begin
   {we have found a fakeplayer, let us send a message to ply and
    either congratulate or scorn him.}

      {lets decide what to say}
      case random(10) of
        0: s := 'congratulations!';
        1: s := 'congratz!';
        2: s := 'way to go!';
        3: s := 'lucky you!';
        4: s := 'so you are a level ' + commastr(ply.level) + ' now...';
        5: s := 'you''re still a loser.';
        6: s := 'don''t expect me to congratulate you.';
        7: s := 'loser.';
        8: s := 'still ' + commastr(100 - ply.level) + ' levels to go.';
        9: s := 'good work!';
      end; {case .end.}

           {send the message to ply}
      if tell_onliner_compact(faker, ply.name2, s) = True then
      begin
        {message got through!}
      end;

    end;

  end; {for i:= .end.}

end;   {fakeplayers_congratulate_levelraiser *end*}

procedure Get_FakePlayerData; {Gets random data name/sex from fakes.dat file}
var

  go_ahead: boolean;
  counter:  integer;
  Result:   s30;

begin

  {init}
  Result := '';
  go_ahead := True;

  fake.name2 := '';
  fake.sex := 1;

  if f_exists(global_fakefile) = False then
  begin
    {create the fakefile}
    if create_fakeplayerfile = False then
      go_ahead := False;
  end;

  {get a random line from file}
  if go_ahead = True then
  begin
    Result := get_random_line_from_textfile(global_fakefile);
  end;

  {return result}
  if Result <> '' then
  begin
  {let us separate the data, which should be in the format:

   david,male,human,warrior
   lena,female,hobbit,assassin }

    {lets read the .sex variable}
    if findsub('male', Result) = True then
    begin
      fake.sex := 1;
    end else
    if findsub('female', Result) = True then
    begin
      fake.sex := 2;
    end else fake.sex := 1;

    {lets read the .race variable}
    fake.race := Dwarf; {default}
    if findsub(racenames[Human], Result) = True then
    begin
      fake.race := Human;
    end else
    if findsub(racenames[Hobbit], Result) = True then
    begin
      fake.race := Hobbit;
    end else
    if findsub(racenames[Elf], Result) = True then
    begin
      fake.race := Elf;
    end else
    if findsub(racenames[HalfElf], Result) = True then
    begin
      fake.race := HalfElf;
    end else
    if findsub(racenames[Dwarf], Result) = True then
    begin
      fake.race := Dwarf;
    end else
    if findsub(racenames[Troll], Result) = True then
    begin
      fake.race := Troll;
    end else
    if findsub(racenames[Orc], Result) = True then
    begin
      fake.race := Orc;
    end else
    if findsub(racenames[Gnome], Result) = True then
    begin
      fake.race := Gnome;
    end else
    if findsub(racenames[Gnoll], Result) = True then
    begin
      fake.race := Gnoll;
    end else
    if findsub(racenames[Mutant], Result) = True then
    begin
      fake.race := Mutant;
    end;

    {lets read the .class variable}
    fake.class := Warrior; {default}
    if findsub(classnames[Alchemist], Result) = True then
    begin
      fake.class := Alchemist;
    end else
    if findsub(classnames[Assassin], Result) = True then
    begin
      fake.class := Assassin;
    end else
    if findsub(classnames[Barbarian], Result) = True then
    begin
      fake.class := Barbarian;
    end else
    if findsub(classnames[Bard], Result) = True then
    begin
      fake.class := Bard;
    end else
    if findsub(classnames[Cleric], Result) = True then
    begin
      fake.class := Cleric;
    end else
    if findsub(classnames[Jester], Result) = True then
    begin
      fake.class := Jester;
    end else
    if findsub(classnames[Magician], Result) = True then
    begin
      fake.class := Magician;
    end else
    if findsub(classnames[Paladin], Result) = True then
    begin
      fake.class := Paladin;
    end else
    if findsub(classnames[Ranger], Result) = True then
    begin
      fake.class := Ranger;
    end else
    if findsub(classnames[Sage], Result) = True then
    begin
      fake.class := Sage;
    end else
    if findsub(classnames[Warrior], Result) = True then
    begin
      fake.class := Warrior;
    end;

    {lets setup the name and clense it from the rest of the data info}
    counter := 1;
    fake.name2 := '';
    repeat
      fake.name2 := fake.name2 + Result[counter];
      Inc(counter);
    until Result[counter] = ',';

  end;

end; {get_fakeplayerdata *end*}


function Percent(now: longint; max: longint): integer;
var
  rr: real;
  x:  longint;

begin

  {calculates health/condition}
  rr := now;
  rr := rr / max;
  x := round(rr * 100);

  percent := x;

end;

function Immunity; {immunity to diseases}

var
  t: s70;

begin

  t := 'very poor';

  if def > 4 then
    t := 'poor';
  if def > 10 then
    t := 'medium';
  if def > 28 then
    t := 'average';
  if def > 40 then
    t := 'above average';
  if def > 70 then
    t := 'strong';
  if def > 90 then
    t := 'very strong';
  if def > 150 then
    t := 'EXTREME';
  if def > 250 then
    t := '*IMMUNE*';

  immunity := t;

end;

function HitChance;
var y: integer;
begin
  hitchance := 8;
  case nr of
    0: y := 7;
    1: y := 6;
    2: y := 6;
    3: y := 6;
    4: y := 5;
    5: y := 5;
    6: y := 5;
    7: y := 4;
    8: y := 4;
    9: y := 4;
    10: y := 4;
    11: y := 3;
    12: y := 3;
    13: y := 3;
    14: y := 3;
    15: y := 2;
    16: y := 2;
    17: y := 2;
  end;
  hitchance := y;
end;

function Condition;
var h: s70;
  rr:  real;
  x:   longint;
begin

  {calculates health/condition}
  rr := now;
  rr := rr / max;
  x := round(rr * 100);

  h := 'is in Excellent condition';
  if x < 100 then
    h := 'has some small wounds and bruises';
  if x < 80 then
    h := 'has some wounds';
  if x < 70 then
    h := 'is pretty hurt!';
  if x < 50 then
    h := 'is in bad shape!';
  if x < 30 then
    h := 'has some BIG and NASTY wounds!';
  if x < 20 then
    h := 'is in an awful condition!';
  if x < 5 then
    h := 'is bleeding from wounds ALL over their body!';
     {return result}
  condition := h;
end; {condition *end*}

function Bash_Name;
var s: string[15];
begin

  case nr of
    1: s := 'Tackle';
    2: s := 'Drop-Kick';
    3: s := 'Uppercut';
    4: s := 'Bite';
    5: s := 'Leg-Sweep';
    6: s := 'JointBreak';
    7: s := 'Knifehand';
    8: s := 'Nerve Punch';
    9: s := 'Chokehold';
    10: s := 'Headbash';
    11: s := 'Pull Hair';
    12: s := 'Kick';
    13: s := 'Straight Punch';
    14: s := 'Ram';
    else s := '*error*';
  end; {case .end.}

       {return result}
  bash_name := s;

end; {bash_name *end*}

function Bash_Rank;
var s: string[15];
begin
  case nr of
    0: s := 'Rotten';
    1: s := 'Awful';
    2: s := 'Lousy';
    3: s := 'Pathetic';
    4: s := 'Bad';
    5: s := 'Poor';
    6: s := 'Incompetent';
    7: s := 'Below average';
    8: s := 'Average';
    9: s := 'Above Average';
    10: s := 'Pretty good';
    11: s := 'Competent';
    12: s := 'Good';
    13: s := 'Very good';
    14: s := 'Extraordinary';
    15: s := 'Excellent';
    16: s := 'Superb';
    17: s := '*COMPLETE*';
    else s := '*error*';
  end;
     {return result}
  bash_rank := s;
end; {bash_rank *end*}

procedure Computer_Healing;
var
  zz, x, z: longint;

begin

  {*should player TEMP heal himself?*}
  if (player0.hps + 5 <= player0.maxhps) and (player0.healing > 0) then
  begin
    x := player0.maxhps - player0.hps;
    zz := x div 5;
    z := zz * 5 + player0.hps;
    if z < player0.maxhps then
      zz := zz + 1;
    if zz = 0 then
      zz := 1;
    if zz > player0.healing then
      zz := player0.healing;
    player0.healing := player0.healing - zz;
    x := zz * 5;
    player0.hps := player0.hps + x;
    if player0.hps > player0.maxhps then
      player0.hps := player0.maxhps;

    if Show then
    begin
      if zz = 1 then
      begin
        sd(10, player0.name2);
        d(config.textcolor, ' quaffed ' + commastr(zz) + ' potion!');
      end else
      begin
        sd(10, player0.name2);
        d(config.textcolor, ' quaffed ' + commastr(zz) + ' potions!');
      end;
    end;
  end;
end; {computer_healing *end*}

procedure Infections2;
var
  Count: byte;

begin

  Count := 0;

  {if player0.blind}
  if player0.plague = True then
  begin
    Inc(Count);
    Dec(player0.hps, 8);
  end;
  if player0.smallpox = True then
  begin
    Inc(Count);
    Dec(player0.hps, 3);
  end;
  if player0.measles = True then
  begin
    Inc(Count);
    Dec(player0.hps);
  end;
  if player0.leprosy = True then
  begin
    Inc(Count);
    Dec(player0.hps, 5);
  end;

  if (Count = 1) and (fastgame = False) then
  begin
    d(4, player0.name2 + ' suffers from a disease!');
  end;
  if (Count = 2) and (fastgame = False) then
  begin
    d(4, player0.name2 + ' shivers from evil diseases!');
  end;
  if (Count = 3) and (fastgame = False) then
  begin
    d(4, player0.name2 + ' REALLY look uncomfortable!');
  end;
  if (Count >= 4) and (fastgame = False) then
  begin
    d(4, player0.name2 + 's face is distorted in pains from multiple diseases!');
  end;

end; {infections2 *end*}

procedure Infections;

begin

  {if cust.blind}
  if player.plague = True then
  begin
    d(4, 'You suffer 8 hps from the Plague!');
    Dec(player.hps, 8);
  end;
  if player.smallpox = True then
  begin
    d(4, 'You suffer 3 hps from Smallpox!');
    Dec(player.hps, 3);
  end;
  if player.measles = True then
  begin
    d(4, 'You suffer 1 hps from Measles!');
    Dec(player.hps);
  end;
  if player.leprosy = True then
  begin
    d(4, 'You suffer 5 hps from Leprosy!');
    Dec(player.hps, 5);
  end;

end; {infections *end*}

function Dungeon_Reward;
var x: longint;
begin

  {calculates EXPERIENCE POINTS REWARD for butchered monster in dungons}

  x := dungeon * (random(50) + 75);
  Inc(x, (random(75) * 3));

  {return result}
  dungeon_reward := x;

end; {dungeon_reward *end*}

procedure Quick_Healing;
var
  zz, x, z, i: longint;

  s:           s10;

begin

  if pl.hps = pl.maxhps then
  begin
    crlf;
    d(14, 'You don''t need healing.');
  end;
  if (pl.hps < pl.maxhps) and (pl.healing = 0) then
  begin
    crlf;
    d(12, 'You need healing, but dont have any potions!');
  end;

  if (pl.hps < pl.maxhps) and (pl.healing > 0) then
  begin
    x := pl.maxhps - pl.hps;
    zz := x div 5;
    z := zz * 5 + pl.hps;
    if z < pl.maxhps then
    begin
      Inc(zz);
    end;
    if zz = 0 then
    begin
      zz := 1;
    end;

    crlf;

    if zz > 1 then
      s := 'potions'
    else s := 'potion';

    d(config.textcolor, 'You need ' + uyellow + commastr(zz) + config.textcol1 + ' ' + s + '.');

    if zz > pl.healing then
      zz := pl.healing;

    Dec(pl.healing, zz);
    x := zz * 5;
    i := pl.maxhps - pl.hps;
    Inc(pl.hps, x);
    if pl.hps > pl.maxhps then
    begin
      x := i;
      pl.hps := pl.maxhps;
    end;
    if zz = 1 then
    begin
      d(config.textcolor, 'You quaffed ' + uwhite + commastr(zz) + config.textcol1 + ' potion and regained ' +
        uwhite + commastr(x) + config.textcol1 + ' hitpoints.');
      d(config.textcolor, 'You have ' + commastr(pl.healing) + ' potions left.');
    end else
    begin
      d(config.textcolor, 'You quaffed ' + uwhite + commastr(zz) + config.textcol1 + ' potions and regained ' +
        uwhite + commastr(x) + config.textcol1 + ' hitpoints.');
      d(config.textcolor, 'You have ' + uwhite + commastr(pl.healing) + config.textcol1 + ' potions left.');
    end;

  end;
  z := 0;

end; {quick_healing *end*}

function Soul_Effect; {effect of soulstrike from popy}
begin

  {return result}
  soul_effect := random(soul) + paladin.level;

end;


procedure Swappy;
var
  temp: longint;
begin
  temp := nr1;
  nr1 := nr2;
  nr2 := temp;
end; {swappy *end*}

procedure XPLose;
var
  s:     s70;
  zz: real;
  x:     longint;
  lost:  byte;
  lose:  ^real;
  adios: boolean;
  plose: longint;

begin

  if loser.exp < 2000 then
    exit;

  new(lose);

  s := cfg_string(90);
  lost := str_to_nr(s);

  if (lost > 3) or (lost < 0) then
  begin
    lost := 0;
  end;

  adios := False;
  case lost of
    0: begin {Nope, no loses}
      adios := True;
    end;
    1: begin {Yep, both loses}

    end;
    2: begin {Yep, only onliner loses}
      if loser.name2 <> player.name2 then
        adios := True;
    end;
    3: begin {Yep, only offliner loses}
      if loser.name2 = player.name2 then
        adios := True;
    end;
  end;

  if (adios = True) or (loser.exp < 100) then
  begin
    dispose(lose);
    exit;
  end;

  {vi l„ser in lose parametrarna}
  x := 24 + (loser.level - 1) div 10;
  s := cfg_string(x);
  zz := str_to_real(s);

  if (zz < 0) or (zz > 90) then
  begin
    zz := 1;
  end;

  lose^ := zz;
  lose^ := lose^ / 100;

  plose := round(lose^ * loser.exp);
  if loser.name2 = player.name2 then
  begin
    d(15, 'You lose ' + commastr(plose) + ' experience points.');
  end else
  if (loser.ai = 'H') and (plose > 0) then
  begin
    post(MailSend,
      loser.name2,
      loser.ai,
      False,
      mailrequest_nothing,
      '',
      umailheadc + 'Lost Experience!' + config.textcol1,
      mkstring(16, underscore),
      'In your last fight you died and lost ' + uwhite + commastr(plose) + config.textcol1 + ' experience points.',
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
  end else
  begin
    {ingen kommentar till datorgubbar}
  end;

  Dec(loser.exp, plose);
  if loser.exp < 0 then
  begin
    loser.exp := 0;
  end;

  dispose(lose);

end;

procedure Zero_Player;
begin

  {Zero all fields in Target}
  fillchar(Target, sizeof(Target), 0);
 {Now integer fields have the value 0, strings are empty,
  characters are Chr(0), booleans are FALSE,
  pointers are NIL, and reals are 0.0.}

end;

procedure Auto_healing; {player0 buys healing potions}

var

  done: boolean;

  needed_potions, cost, sum, afford, price: longint;

begin

  {init}
  needed_potions := 0;
  cost := 0;
  price := 0;
  afford := 0;
  sum := 0;

  {debug info}
{ d(15,'Money: '+commastr(player0.gold));
 d(15,'Bank : '+commastr(player0.bankgold));
 pause;

 {do we need to withdraw money from bank account}
  if (player0.gold < 25000) and (player0.bankgold > 0) then
  begin

    sum := player0.level * 5;
    done := False;
    repeat

      if player0.bankgold > sum * 2 then
      begin
        sum := sum * 2;
      end else
      begin
        done := True;
      end;

      if sum > 1000000 then
        done := True;

    until done;

    if (done) and (sum > 0) then
    begin
      incplayermoney(player0, sum);
      decbankmoney(player0, sum);
    end;

  end;

  {price for a potion}
  price := player0.level * 5;

  {potions needed by player0}
  needed_potions := config.maxheals - player0.healing;

  if (needed_potions > 0) and (player0.gold > price) then
  begin
    {how many potions can player0 afford}
    afford := player0.gold div price;
    if afford > needed_potions then
    begin
      afford := needed_potions;
    end;

    if afford > 0 then
    begin
      cost := afford * price;
      decplayermoney(player0, cost);
      Inc(player0.healing, afford);

      {debug info}
  { d(15,player0.name2+' bought '+commastr(afford)+' potions.');
   d(15,'Cost: '+commastr(cost)+' gold coins');
   d(15,'Money: '+commastr(player0.gold));
   d(15,'Bank : '+commastr(player0.bankgold));
   pause;
   }
    end;

  end;

end; {auto_healing *end*}


procedure Healing;

var
  zz, x, z: longint;

begin

  crlf;

  if pl.hps = pl.maxhps then
  begin
    d(config.textcolor, 'You don''t need healing.');
  end;

  if pl.hps < pl.maxhps then
  begin
    d(config.textcolor, 'You have ' + uwhite + commastr(pl.healing) + config.textcol1 + ' healing potions.');
    d(config.textcolor, 'Quaff how many potions');
    sd(config.textcolor, ':');

    {get user input}
    zz := get_number(0, pl.healing);

    if (zz <= pl.healing) and (zz > 0) then
    begin
      x := zz * 5;
      if x + pl.hps > pl.maxhps then
      begin
        x := pl.maxhps - pl.hps;
        zz := x div 5;
        z := zz * 5 + pl.hps;
        if z < pl.maxhps then
          zz := zz + 1;
        if zz = 0 then
          zz := 1;
        d(12, 'You only need ' + uwhite + commastr(zz) + ulred + ' potions.');

        Dec(pl.healing, zz);
        Inc(pl.hps, x);
      end else
      begin
        Dec(pl.healing, zz);
        Inc(pl.hps, x);
      end;
      d(config.textcolor, 'You quaffed ' + uwhite + commastr(zz) + config.textcol1 + ' potions');
      d(config.textcolor, 'You regained ' + uwhite + commastr(x) + config.textcol1 + ' hitpoints  (' +
        commastr(pl.hps) + '/' + commastr(pl.maxhps) + ')');
      d(config.textcolor, 'You have ' + uwhite + commastr(pl.healing) + config.textcol1 + ' potions left');
    end;

  end;

end; {Healing *end*}

function Race_Display(const mode: byte; race: races; const racenr: byte): s10;
var Result: s10;
begin

  {init variables}
  Result := '';

  if racenr <> 0 then
  begin
    case racenr of
      1: race := Human;
      2: race := Hobbit;
      3: race := Elf;
      4: race := HalfElf;
      5: race := Dwarf;
      6: race := Troll;
      7: race := Orc;
      8: race := Gnome;
      9: race := Gnoll;
      10: race := Mutant;
    end; {case .end.}
  end;

  case mode of
    1: begin
      case race of
        Human: Result := 'Human';
        Hobbit: Result := 'Hobbit';
        Elf: Result := 'Elf';
        HalfElf: Result := 'Half-Elf';
        Dwarf: Result := 'Dwarf';
        Troll: Result := 'Troll';
        Orc: Result := 'Orc';
        Gnome: Result := 'Gnome';
        Gnoll: Result := 'Gnoll';
        Mutant: Result := 'Mutant';
      end;
    end;
    2: begin
      case race of
        Human: Result := 'human';
        Hobbit: Result := 'hobbit';
        Elf: Result := 'elf';
        HalfElf: Result := 'half-elf';
        Dwarf: Result := 'dwarf';
        Troll: Result := 'troll';
        Orc: Result := 'orc';
        Gnome: Result := 'gnome';
        Gnoll: Result := 'gnoll';
        Mutant: Result := 'mutant';
      end;
    end;
    3: begin
      case race of
        Human: Result := 'humans';
        Hobbit: Result := 'hobbits';
        Elf: Result := 'elves';
        HalfElf: Result := 'half-elves';
        Dwarf: Result := 'dwarves';
        Troll: Result := 'trolls';
        Orc: Result := 'orcs';
        Gnome: Result := 'gnomes';
        Gnoll: Result := 'gnolls';
        Mutant: Result := 'mutants';
      end;
    end;

  end; {case .end.}

       {return result}
  race_display := Result;

end; {race_display *end*}

function Replace_A_String(Source, Old, New: string): string;
var p: integer;
begin

  while POS(upcasestr(Old), upcasestr(Source)) <> 0 do
  begin
    p := POS(upcasestr(Old), upcasestr(Source));
    Delete(Source, p, length(Old));
    insert(New, Source, p);
  end;
  Replace_A_String := Source;

end; {Replace_a_String *end*}

function Remove_BadWords; {check and remove bad words}
const seperator = '|';
var
  txt: Text; {textfile}

  word1, word2: s70;

  s2, l: string;

  t: char;

  x: word;

begin

  {Remove Sysop-defined (bad)words from S string}

  s2 := s;

  {Has Sysop defined a BADWORDS file?}
  if f_exists(global_badfile) then
  begin

    {Let's open the Badword file.}
    if open_txtfile(treset, txt, global_badfile) = True then
    begin
      while not EOF(txt) do
      begin
        readln_from_text(txt, l);

        {lines beginning with ; are comment lines and are skipped}
        if (l[1] = ';') or (l = '') then
        begin
          {Skipping comment or empty line}
        end else
        begin
          {pull out word1 and word2 from line L}

          word1 := '';
          word2 := '';

          x := 1;
          {Word1}
          repeat
            t := l[x];
            if t <> seperator then
              word1 := word1 + t;
            Inc(x);
          until t = seperator;

          {word2}
          repeat
            t := l[x];
            if t <> seperator then
              word2 := word2 + t;
            Inc(x);
          until x > length(l);

          if (word1 <> '') and (word2 <> '') then
          begin
            s2 := replace_a_string(s2, word1, word2);
          end;

        end; {pull out .end.}

      end;
      close_text(txt);
    end else
    begin
      {We failed to open the file!}
    end;

  end; {file exists .end.}

       {Return Result}
  remove_badwords := s2;

end; {remove_badwords *end*}

procedure Read_Start_CfgValues;
var
  s:     s100;

  i:     longint;

  error: integer;

  txt:   Text;

  RelationFile: file of RelationRec; {** Relation file **}
  ChildrenFile: file of ChildRec;    {** Children file **}

begin

  {This routine reads configuration settings from USURPER.CFG}

  if f_exists(global_ucfg) = False then
  begin
    wr(12, 'Problem! I could not find the ');
    wr(11, global_ucfg);
    wrl(12, ' file.');
    wrl(12, 'Please make sure that you have this file in');
    wrl(12, 'the Usurper main directory.');
    wr(12, 'You can create a new ');
    wr(11, global_ucfg);
    wrl(12, ' with EDITOR.EXE.');
    wrl(12, '');
    pause;
    halt;
  end;

  {Fast Play, skip first menu, #11}
  s := cfg_string(11);
  if upcasestr(s) = 'YES' then
    config.fastplay := False
  else config.fastplay := True;

  {Mark Npcs or not, #123}
  s := cfg_string(123);
  if upcasestr(s) = 'NO' then
    config.marknpcs := False
  else config.marknpcs := True;

  {Anchor road name, #12}
  s := cfg_string(12);
  if upcasestr(s) <> '' then
  begin
    config.anchor := s;
  end;

 {checking if SIMULNODE is allowed (to be on more than 1 node
  simultaneously, #51}
  config.simulnode := True;
  s := cfg_string(51);
  if upcasestr(s) = 'NO' then
  begin
    config.simulnode := False;
  end;

  {checking if Auto_Maint is off, #67}
  s := cfg_string(67);
  config.automaint := True;
  if upcasestr(s) = 'NO' then
  begin
    config.automaint := False;
  end;

  {days to keep items on the player market, #3}
  s := cfg_string(3);
  config.maxmarket := str_to_nr(s);
  if (config.maxmarket < 2) or (config.maxmarket > 127) then
  begin
    config.maxmarket := 30;
  end;

  {days to keep unread mail, #4}
  s := cfg_string(4);
  config.maxmail := str_to_nr(s);
  if (config.maxmail < 2) or (config.maxmail > 127) then
  begin
    config.maxmail := 8;
  end;

  {# of Bard Songs/day, #163}
  s := cfg_string(163);
  i := str_to_nr(s);
  if (i < 0) or (i > 50) then
    config.bardsongs := 5
  else config.bardsongs := i;


  {log immortals entries in the news, #164}
  s := cfg_string(164);
  config.log_divine_entrance := True;
  if upcasestr(s) = 'NO' then
  begin
    config.log_divine_entrance := False;
  end;

  {minimum age to marry, #166}
  s := cfg_string(166);
  i := str_to_nr(s);
  if (i < 0) or (i > 65000) then
    config.MinimumAgetoMarry := 18
  else config.MinimumAgetomarry := i;


  {name of bobs beer place}
  s := cfg_string(167);
  config.bobsplace := 'Bobs Beer';
  if upcasestr(s) <> '' then
    config.bobsplace := s;

  s := cfg_string(168);
  config.bobsname := 'Bob';
  if upcasestr(s) <> '' then
    config.bobsname := s;

  s := cfg_string(169);
  config.bishop := 'Jakobinus';
  if upcasestr(s) <> '' then
    config.bishop := s;

  s := cfg_string(170);
  config.gossip_monger := 'Lydia';
  if upcasestr(s) <> '' then
    config.gossip_monger := s;

  s := cfg_string(171);
  config.bobsbartender := 'Ted';
  if upcasestr(s) <> '' then
    config.bobsbartender := s;

  s := cfg_string(172);
  config.gymmasseur := 'Hazzan';
  if upcasestr(s) <> '' then
    config.gymmasseur := s;

  {put relation changes in the news, #173}
  s := cfg_string(173);
  config.relationChangesNews := 1;
  if upcasestr(s) = 'NO' then
  begin
    config.relationChangesNews := 0;
  end;

  {# of Children allowed, #174}
  s := cfg_string(174);
  i := str_to_nr(s);
  if (i < 0) or (i > 100) then
    config.MaxHumanChildren := 25
  else config.MaxHumanChildren := i;

  {# of NPC Children allowed, #175}
  s := cfg_string(175);
  i := str_to_nr(s);
  if (i < 0) or (i > 100) then
    config.MaxNPCChildren := 20
  else config.MaxNPCChildren := i;

  {# of Prison Escape Attempts allowed per day and player, #176}
  s := cfg_string(176);
  i := str_to_nr(s);
  if (i < 0) or (i > 250) then
    config.prison_escapes := 3
  else config.prison_escapes := i;


  {allow players to view game settings, #177}
  s := cfg_string(177);
  config.ViewGameSettings := True;
  if upcasestr(s) = 'NO' then
  begin
    config.ViewGameSettings := False;
  end;


  {# of minutes of inactivity before booted from the game, #178}
  s := cfg_string(178);
  i := str_to_nr(s);
  if (i < 0) or (i > 900) then
    config.inactivity := 15
  else config.inactivity := i;

  {Bear Taming in the Uman Caves / attempts per day, #181}
  s := cfg_string(181);
  i := str_to_nr(s);
  if (i < 0) or (i > 128) then
    config.beartametries := 5
  else config.beartametries := i;

  {Allow the NPCs to usurp the Royal Throne, #182}
  s := cfg_string(182);
  config.AllowNPCUsurping := True;
  if upcasestr(s) = 'NO' then
  begin
    config.AllowNPCUsurping := False;
  end;

  {King allowed to feed the Wolves with X kids per day, #183}
  s := cfg_string(183);
  i := str_to_nr(s);
  if (i < 0) or (i > 5) then
    config.AllowFeedingTheWolves := 5
  else config.AllowFeedingTheWolves := i;

  {Kings marry actions per day, dissolve and ban marriages, #184}
  s := cfg_string(184);
  i := str_to_nr(s);
  if (i < 0) or (i > 15) then
    config.MarryActionsPerDay := 15
  else config.MarryActionsPerDay := i;

  {King allowed to put X kids in the Royal Orphanage per day, #185}
  s := cfg_string(185);
  i := str_to_nr(s);
  if (i < 0) or (i > 5) then
    config.AllowRoyalAdoption := 5
  else config.AllowRoyalAdoption := i;

  {allow NPCs to believe in GODs}
  {#186}
  s := cfg_string(186);
  config.npcbelievers := True;
  if upcasestr(s) = 'NO' then
  begin
    config.npcbelievers := False;
  end;

  {God Color, #187}
  s := cfg_string(187);
  if valid_color(s) then
  begin
    ugodc := ConvertToUsurperAnsi(s);
    global_godcol := ConvertToUsurperAnsi2(s);
  end;

  {days to keep NOT ORDERED drinks at Orbs, #125}
  s := cfg_string(125);
  config.maxdrinkds := str_to_nr(s);
  if (config.maxdrinkds < 0) or (config.maxdrinkds > 999) then
  begin
    config.maxdrinkds := 90;
  end;

  {maxdrinks at Orbs, #126}
  s := cfg_string(126);
  config.maxdrinks := str_to_nr(s);
  if (config.maxdrinks < 1) or (config.maxdrinks > 9999) then
  begin
    config.maxdrinks := 50;
  end;

  {allow losers from pick-pocketing at the Dorm to enter again}
  {#127}
  s := cfg_string(127);
  config.dormpocketattackallow := True;
  if upcasestr(s) = 'NO' then
  begin
    config.dormpocketattackallow := False;
  end;

  {allow losers from Wake up calls in the Dormitory to enter again}
  {#128}
  s := cfg_string(128);
  config.dormwakeupcallallow := True;
  if upcasestr(s) = 'NO' then
  begin
    config.dormwakeupcallallow := False;
  end;

  {max Drinks at Orbs, #97}
  s := cfg_string(97);
  i := str_to_nr(s);
  if (i < 1) or (i > 15) then
  begin
    Config.DrinksAtOrbs := 3;
  end else
  begin
    Config.DrinksAtOrbs := i;
  end;

  {Allow king/queen to create quests, #129}
  s := cfg_string(129);
  config.AllowKingtoInitQuests := True;
  if upcasestr(s) = 'NO' then
  begin
    config.AllowKingtoInitQuests := False;
  end;

  {Max Quests allowed in database, #130}
  s := cfg_string(130);
  i := str_to_nr(s);
  if (i < 1) or (i > 65000) then
  begin
    Config.MaxQuestsAllowed := 100;
  end else
  begin
    Config.MaxQuestsAllowed := i;
  end;

  {Max Quests a player can claim, #131}
  s := cfg_string(131);
  i := str_to_nr(s);
  if (i < 1) or (i > 500) then
  begin
    Config.MaxClaimedQuests := 3;
  end else
  begin
    Config.MaxClaimedQuests := i;
  end;

  {Max Quests a player can complete/day, #132}
  s := cfg_string(132);
  i := str_to_nr(s);
  if (i < 1) or (i > 9999) then
  begin
    Config.MaxCompletedQuests := 5;
  end else
  begin
    Config.MaxCompletedQuests := i;
  end;

  {Max New Quests the King can issue/day, #133}
  s := cfg_string(133);
  i := str_to_nr(s);
  if (i < 1) or (i > 500) then
  begin
    Config.MaxNewQuestsPerDay := 3;
  end else
  begin
    Config.MaxNewQuestsPerDay := i;
  end;

  {allow the King to force Quests upon players, #134}
  s := cfg_string(134);
  config.ForceQuests := True;
  if upcasestr(s) = 'NO' then
  begin
    config.ForceQuests := False;
  end;

  {allow players who die on Quests to enter again, #135}
  s := cfg_string(135);
  config.AllowFailQuestReturn := False;
  if upcasestr(s) = 'YES' then
  begin
    config.AllowFailQuestReturn := True;
  end;

 {allow players who are killed trying to rescue mates from prison to
  enter again, from .CFG #136}
  s := cfg_string(136);
  config.AllowFailPrisonRescue := False;
  if upcasestr(s) = 'YES' then
  begin
    config.AllowFailPrisonRescue := True;
  end;

  {get NPC willingness to write to Inn Chatfile, from .CFG, #137}
  s := cfg_string(137);
  i := str_to_nr(s);
  if (i < 0) or (i > 3) then
  begin
    Config.AddNpcInnComments := 1;
  end else
  begin
    Config.AddNpcInnComments := i;
  end;

 {For how many days can the King have players in prison? 0-15,
  from .CFG, #138}
  s := cfg_string(138);
  i := str_to_nr(s);
  if (i < 0) or (i > 15) then
  begin
    Config.AllowKingtoImprison := 1;
  end else
  begin
    Config.AllowKingtoImprison := i;
  end;

  {File-locking or Record-locking?, #139}
  s := cfg_string(139);
  i := str_to_nr(s);
  if i = 2 then
  begin
    Config.NetShareMethod := RecordLocking;
  end else
  begin
    Config.NetShareMethod := FileLocking;
  end;

  {Lockdelay in millseconds between File-locking attempts, #140}
  s := cfg_string(140);
  i := str_to_nr(s);
  if (i >= 0) and (i < 1501) then
  begin
    Config.LockDelay := i;
  end;
  global_lockdelay := Config.LockDelay;
  {we set the closely related online_poll_delay....se file_io.pas for details}
  global_online_poll_delay := global_lockdelay + 400;

  {Game Text Color, #141}
  s := cfg_string(141);
  if valid_color(s) then
  begin
    config.textcol1 := ConvertToUsurperAnsi(s);
    urac := ConvertToUsurperAnsi(s);
    config.textcolor := ConvertToUsurperAnsi2(s);
  end;

  {Player names Colors, #142}
  s := cfg_string(142);
  if valid_color(s) then
  begin
    uplc := ConvertToUsurperAnsi(s);
    global_plycol := ConvertToUsurperAnsi2(s);

    {temporary solution! until you decided to let sysop edit via the editor}
    ukidc := uplc; {temporary solution, but since the editor can't change kid
                colors we copy/use the player colors}
    global_kidcol := global_plycol;
  end;

  {Team Colors, #143}
  s := cfg_string(143);
  if valid_color(s) then
  begin
    utec := ConvertToUsurperAnsi(s);
    global_teamcol := ConvertToUsurperAnsi2(s);
  end;

  {Monster Colors, #144}
  s := cfg_string(144);
  if valid_color(s) then
  begin
    umonc := ConvertToUsurperAnsi(s);
    global_moncol := ConvertToUsurperAnsi2(s);
  end;

  {Item Color, #145}
  s := cfg_string(145);
  if valid_color(s) then
  begin
    uitemc := ConvertToUsurperAnsi(s);
    global_itemcol := ConvertToUsurperAnsi2(s);
  end;

  {Item Color, #146}
  s := cfg_string(146);
  if valid_color(s) then
  begin
    utalkc := ConvertToUsurperAnsi(s);
    global_talkcol := ConvertToUsurperAnsi2(s);
  end;

  {Menu bracket Color, #147}
  s := cfg_string(147);
  if valid_color(s) then
  begin
    config.bracketcolor := ConvertToUsurperAnsi2(s);
  end;

  {Menu hotkey Color, #148}
  s := cfg_string(148);
  if valid_color(s) then
  begin
    config.hotkeycolor := ConvertToUsurperAnsi2(s);
    config.textcol2 := ConvertToUsurperAnsi(s);
  end;

  {resurrect the King when Castle is infiltrated, #149}
  s := cfg_string(149);
  config.ResurrectTheKing := True;
  if upcasestr(s) = 'NO' then
  begin
    config.ResurrectTheKing := False;
  end;

  {MaxWrestlings (in Uman Caves), #150}
  s := cfg_string(150);
  i := str_to_nr(s);
  if (i < 1) or (i > 15) then
  begin
    Config.MaxWrestlings := 5;
  end else
  begin
    Config.MaxWrestlings := i;
  end;

  {allow the King to close shops, .CFG #151}
  s := cfg_string(151);
  Config.AllowCloseShops := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.AllowCloseShops := False;
  end;

  {get PunishCarrierDroppers from .CFG, #152}
  s := cfg_string(152);
  i := str_to_nr(s);
  if (i < 0) or (i > 1) then
  begin
    Config.PunishCarrierDroppers := 0;
  end else
  begin
    Config.PunishCarrierDroppers := i;
  end;

  {allow the NPCs to marry and have kids, .CFG #153}
  s := cfg_string(153);
  Config.AllowNpcMarry := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.AllowNpcMarry := False;
  end;

  {allow players to visit Steroids shop, .CFG #154}
  s := cfg_string(154);
  Config.Allow_Steroids := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.Allow_Steroids := False;
  end;

  {allow players to visit Whore house, .CFG #155}
  s := cfg_string(155);
  Config.Allow_Whores := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.Allow_Whores := False;
  end;

  {allow players to buy Drugs, .CFG #156}
  s := cfg_string(156);
  Config.Allow_Drugs := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.Allow_Drugs := False;
  end;

  {allow players to Murder Innocent People, .CFG #157}
  s := cfg_string(157);
  Config.Allow_Murder := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.Allow_Murder := False;
  end;

  {put players opinions of the ruler in the news?, .CFG #158}
  s := cfg_string(158);
  Config.Print_KingPolls := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.Print_KingPolls := False;
  end;

  {get Fakeplayers from .CFG, #159}
  s := cfg_string(159);
  config.fakeplayers := str_to_nr(s);
  if (config.fakeplayers < 0) or (config.fakeplayers > 110) then
  begin
    config.fakeplayers := 2;
  end;

  {get fakeplayers SHUTUP setting from .CFG, #188}
  s := cfg_string(188);
  if upcasestr(s) = 'NO' then
  begin
    config.fakeschatty := False;
  end;

  {get Intimacy acts from .CFG, #189}
  s := cfg_string(189);
  config.IntimacyActs := str_to_nr(s);
  if (config.IntimacyActs < 0) or (config.IntimacyActs > 60000) then
  begin
    config.IntimacyActs := 10;
  end;


  {get homo/bi allowed from .CFG, #190}
  s := cfg_string(190);
  if upcasestr(s) = 'YES' then
  begin
    Config.AllowHomoRelations := True;
  end;

  {get Resurrections from .CFG, #191}
  s := cfg_string(191);
  config.Resurrections := str_to_nr(s);
  if (config.Resurrections < 0) or (config.Resurrections > 60000) then
  begin
    config.Resurrections := 10;
  end;


  {get homo/bi allowed from .CFG, #192}
  s := cfg_string(192);
  Config.bothImmortalsAndMortals := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.bothImmortalsAndMortals := False;
  end;

  {get Labor Days from .CFG, #193}
  s := cfg_string(193);
  config.LaborDays := str_to_nr(s);
  if (config.LaborDays < 0) or (config.LaborDays > 300) then
  begin
    config.LaborDays := 5;
  end;

  {allow adult options .CFG, #194}
  s := cfg_string(194);
  Config.AllowAdultOptions := True;
  if upcasestr(s) = 'NO' then
  begin
    Config.AllowAdultOptions := False;
  end;

  {get Allowed Pick Pocket Attempts per day CFG, #195}
  s := cfg_string(195);
  Config.PickPocketAttempts := str_to_nr(s);
  if (Config.PickPocketAttempts < 0) or (Config.PickPocketAttempts > 60000) then
  begin
    config.PickPocketAttempts := 5;
  end;

  {get Quest-Master, #196}
  s := cfg_string(196);
  if upcasestr(s) = '' then
  begin
    config.QuestMaster := 'Ulgmog';
  end else
  begin
    config.QuestMaster := s;
  end;

  {get Allowed Home Store Items, #197}
  s := cfg_string(197);
  Config.HomeItems := str_to_nr(s);
  if (Config.HomeItems < 0) or (Config.HomeItems > 300) then
  begin
    config.HomeItems := 10;
  end;


  {get Allowed bank robbery Attempts per day CFG, #198}
  s := cfg_string(198);
  Config.BankRobberyAttempts := str_to_nr(s);
  if (Config.BankRobberyAttempts < 0) or (Config.BankrobberyAttempts > 60000) then
  begin
    config.BankRobberyAttempts := 3;
  end;


  {MoneyType (gold), .CFG #160}
  s := cfg_string(160);
  if (upcasestr(s) <> config.moneytype) and (s <> '') then
  begin
    Config.MoneyType := s;
  end;

  {MoneyType2 (coin), .CFG #161}
  s := cfg_string(161);
  if (upcasestr(s) <> config.moneytype2) and (s <> '') then
  begin
    Config.MoneyType2 := s;
  end;

  {MoneyType3 (coins), .CFG #162}
  s := cfg_string(162);
  if (upcasestr(s) <> config.moneytype3) and (s <> '') then
  begin
    Config.MoneyType3 := s;
  end;

  {get maxwanted from .CFG, #116}
  s := cfg_string(116);
  config.maxwanted := str_to_nr(s);
  if (config.maxwanted < 2) or (config.maxwanted > 127) then
    config.maxwanted := 30;

  {GETTING NEWS & YESTERDAYS NEWSFILES....(if they are defined that is)}
  s := cfg_string(117);
  s := striplead(s, DIRECTORY_SEPARATOR); {removing leading /}
  global_nwfileasc := s;

  {ansi newsfile defined?}
  s := cfg_string(118);
  s := striplead(s, DIRECTORY_SEPARATOR);
  global_nwfileans := s;

  {#119, ascii yesterdays newsfile defined?}
  s := cfg_string(119);
  s := striplead(s, DIRECTORY_SEPARATOR);
  global_ynwfileasc := s;

  {#120, ansi yesterdays newsfile defined?}
  s := cfg_string(120);
  s := striplead(s, DIRECTORY_SEPARATOR);
  global_ynwfileans := s;

  {#121, min level for players req to usurp the throne}
  s := cfg_string(121);
  i := str_to_nr(s);
  if (i < 0) or (i > 100) then
    Config.MinLevelKing := 25
  else Config.MinLevelKing := i;

  {#122, soul needed to usurp the throne (1=good,2=evil,3=any)}
  s := upcasestr(cfg_string(122));
  if s = 'GOOD' then
  begin
    Config.SoulNeededKing := 1; {good}
  end else
  if s = 'EVIL' then
  begin
    Config.SoulNeededKing := 2; {evil}
  end else
  begin {ANY}
    Config.SoulNeededKing := 3; {any}
  end;

  {#37, get Leveldiff from .CFG}
  s := cfg_string(37);
  config.leveldiff := str_to_nr(s);
  if (config.leveldiff < 0) or (config.leveldiff > 25) then
    config.leveldiff := 5;

  {get ArmorBase from .CFG}
  s := cfg_string(38);
  config.abase := str_to_nr(s);
  if (config.abase < 0) or (config.abase > 60) then
    config.abase := 25;
  config.abase := config.abase / 100;

  {get Max potions allowed from .CFG}
  s := cfg_string(49);
  config.maxheals := str_to_nr(s);
  if (config.maxheals < 1) or (config.maxheals > 9999) then
    config.maxheals := 250;

  {get Quaffing healing potions sequence, in the dungeons from .CFG}
  s := cfg_string(22);
  config.quaffopt := str_to_nr(s);
  if (config.quaffopt < 1) or (config.quaffopt > 3) then
    config.quaffopt := 1;

  {get Classic game mode (or not) from .CFG}
  s := cfg_string(91);
  if upcasestr(s) = 'CLASSIC' then
    config.classic := True;

  {get 'which items can be taken from defeated player' from .CFG}
  for i := 53 to 66 do
  begin
    s := cfg_string(i);

    if i = 53 then
    begin
   {we treat HAND items special
    0=not allowed to take hand items
    1=Both
    2=Left only
    3=Right only
    4=Random  left/right
    5=Random  left/right/both
    6=Random  left/right/both/none
   }

      config.loot[i - 52] := False;
      config.loothands := str_to_nr(s);
      if config.loothands in [0, 1, 2, 3, 4, 5, 6] then
      begin
            {everything is well}
      end else
      begin {set default value}
        config.loothands := 2;
      end;

    end else
    begin
      {all other items are processed here}
      if upcasestr(s) = 'YES' then
        config.loot[i - 52] := True
      else config.loot[i - 52] := False;
    end;

  end;

  {allow team mates to help mates attacked at the Dorm?}
  s := cfg_string(96);
  if upcasestr(s) = 'YES' then
    config.TeamAssist := True
  else config.TeamAssist := False;

  {Teamdiff, this sets how much more powerful a team can be than its opponent}
  {if the team is too powerful then the fight will not be allowed}
  s := cfg_string(95);
  config.teamdiff := str_to_nr(s);
  if (config.teamdiff < 1) or (config.teamdiff > 5000) then
    config.teamdiff := 75;

  {every X second should we check node interactivity, #98}
  s := cfg_string(98);
  config.multicheck := str_to_nr(s);
  if (config.multicheck < 0) or (config.multicheck > 32000) then
  begin
    config.multicheck := 5;
  end;

  {semaphore path, #99}
  s := cfg_string(99);
  if s <> '' then
  begin
    i := length(s);
    if s[i] <> DIRECTORY_SEPARATOR then
    begin
      {append trailing backslash}
      s := s + DIRECTORY_SEPARATOR;
    end;

    {set onfile (onliners.dat) to semaphore dir}
    global_onfile := s + global_onfile;

    {set maintfile (maint.flg) to semaphore dir}
    global_maintfile := s + global_maintfile;

    {set IPC (multi node chat files) path to semaphore dir}
    IpcPath := s;

    {set path to semaphore dir}
    config.semaphore := s;

  end else
  begin
    config.semaphore := global_nodedir;
    global_onfile := global_nodedir + global_onfile;
  end;

  {display error messages on screen, #124}
  s := cfg_string(124);
  if upcasestr(s) = 'YES' then
  begin
    config.errors := True;
  end;

  {InnKeepers name, #20}
  s := cfg_string(20);
  if upcasestr(s) = '' then
  begin
    config.InnKeeper := 'Garth';
  end;

  {should the monsters speak in the dungeons, #23}
  s := cfg_string(23);
  if upcasestr(s) = 'NO' then
  begin
    config.mon_talk := False;
  end else
  begin
    config.mon_talk := True;
  end;

  {allow one man TEAM attacks?, #100}
  s := cfg_string(100);
  if upcasestr(s) = 'NO' then
  begin
    config.onemanshow := False;
  end;

  {Allow items to be used. defined by sysop in #101..115}
  for i := 101 to 115 do
  begin
    config.allowitem[i - 100] := True;
    s := cfg_string(i);
    if upcasestr(s) = 'NO' then
    begin
      config.allowitem[i - 100] := False;
    end;
  end;

  {Checking if DATA directory exists}
  if direxist(global_datadir) = False then
  begin
    d(12, 'Directory "' + ulcyan + global_datadir + ulred + '" doesn''t exist!');
    d(15, 'Creating...');
    s := copy(global_datadir, 1, length(global_datadir) - 1);
    if make_dir(s) = False then
    begin
      halt;
    end;
  end;

  {Checking if DOCS directory exists}
  if direxist(global_docsdir) = False then
  begin
    d(12, 'Directory "' + ulcyan + global_docsdir + ulred + '" doesn''t exist!');
    d(15, 'Creating...');
    s := copy(global_docsdir, 1, length(global_docsdir) - 1);
    if make_dir(s) = False then
    begin
      halt;
    end;
  end;

  {Checking if NODE directory exists}
  if direxist(global_nodedir) = False then
  begin
    d(12, 'Directory "' + ulcyan + global_nodedir + ulred + '" doesn''t exist!');
    d(15, 'Creating...');
    s := copy(global_nodedir, 1, length(global_nodedir) - 1);
    if make_dir(s) = False then
    begin
      halt;
    end;
  end;

  {Checking if SCORES directory exists}
  if direxist(global_scoredir) = False then
  begin
    d(12, 'Directory "' + ulcyan + global_scoredir + ulred + '" doesn''t exist!');
    d(15, 'Creating...');
    s := copy(global_scoredir, 1, length(global_scoredir) - 1);
    if make_dir(s) = False then
    begin
      halt;
    end;
  end;

  {Checking for necessary DATA files}
  if f_exists(global_monfile) = False then
    fatal(global_monfile);
  if f_exists(global_npfile) = False then
    fatal(global_npfile);
  if f_exists(global_gufile) = False then
    fatal(global_gufile);
  if f_exists(global_lvlfile) = False then
    fatal(global_lvlfile);

  if (config.classic) and (f_exists(global_armofile) = False) then
    fatal(global_armofile);
  if (config.classic) and (f_exists(global_weapofil) = False) then
    fatal(global_weapofil);

  if not f_exists(global_pfile) then
  begin
    d(12, 'Could not locate the UserFile.' + config.textcol1 + ' Creating a new one...');
    d(config.textcolor, 'Setting up the game...');
    Reset_Game;
    crlf;
    d(config.textcolor, 'Ok! You will be the first victim to enter... Mohaha!');
    crlf;
  end;

  {Does Inn Chat files exist?}
  if (f_exists(global_innfile1) = False) or (f_exists(global_innfile2) = False) then
  begin
    d(12, 'Could not find the ' + ulcyan + 'Inn-Chat' + ulred + ' files.');
    d(config.textcolor, 'creating new ones...');

    if open_txtfile(trewrite, txt, global_innfile1) then
    begin
      writeln_to_text(txt, '---');
      writeln_to_text(txt, 'Conversations at the Inn');
      close_text(txt);
    end else
    begin
      unable_to_create(global_innfile1, 5);
    end;

    if open_txtfile(trewrite, txt, global_innfile2) then
    begin
      writeln_to_text(txt, '---');
      writeln_to_text(txt, 'Conversations at the Inn');
      close_text(txt);
    end else
    begin
      unable_to_create(global_innfile2, 5);
    end;

  end;

  {check "street-talk" files, create if non-existant}
  Check_TruthFile(False);

  {Check if "Fame File" exists}
  if f_exists(global_famefile) = False then
  begin
    d(12, 'Could not find ' + ulcyan + 'Hall of Fame' + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');

    if open_txtfile(trewrite, txt, global_famefile) then
    begin
      writeln_to_text(txt, 'Usurper  Hall of Fame');
      writeln_to_text(txt, mkstring(21, underscore));
      close_text(txt);
    end else
    begin
      unable_to_create(global_famefile, 5);
    end;
  end; {if famefile does not exists .end.}

       {Check if "Relations File" exists}
  if f_exists(global_relationf) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_relationf + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');

    Assign(relationfile, global_relationf);
  {$I-}rewrite(relationfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_create(global_relationf, error);

  {$I-}Close(relationfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(global_relationf, error);

  end; {if relation database does not exists .end.}

       {Check if "Children File" exists}
  if f_exists(global_childrenf) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_childrenf + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');

    Assign(childrenfile, global_childrenf);

  {$I-}rewrite(childrenfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_create(global_childrenf, error);

  {$I-}Close(childrenfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(global_childrenf, error);

  end; {if children database does not exists .end.}

       {check to see that fake.dat exists}
  if f_exists(global_fakefile) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_fakefile + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');
    create_fakeplayerfile;
  end;

  {check to see that TEAM-NAME file exists}
  if f_exists(global_tnames) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_tnames + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');
    create_teamnamefile;
  end;

  {check to see that BARDSONG file exists}
  if f_exists(global_bardsongf) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_bardsongf + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');
    if create_bardsongfile = False then
    begin
      unable_to_create(global_bardsongf, 5);
    end;
  end;

  {check to see that MALE children file exists}
  if f_exists(global_childmalef) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_childmalef + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');
    create_childrenfile(1); {fileio2}
  end;

  {check to see that FEMALE children file exists}
  if f_exists(global_childfemalef) = False then
  begin
    d(12, 'Could not find ' + ulcyan + global_childfemalef + ulred + ' file.');
    d(config.textcolor, 'creating a new one...');
    create_childrenfile(2); {fileio2}
  end;

  {onliners.dat, onfile}
  if f_exists(global_onfile) = False then
  begin
    wrl(12, 'Could not find ' + ulcyan + global_onfile + ulred + ' file.');
    wrl(config.textcolor, 'creating a new one...');
    create_onlinefile;
  end;

end; {Read_Start_CfgValues *END*}


function Crypt(nr: word): s70; {returns a random array with length NR}
var s: s100;
  i:   byte;
begin

  s := '';
  for i := 1 to nr do
  begin
    case random(65) of
      0: s := s + 'A';
      1: s := s + 'B';
      2: s := s + 'C';
      3: s := s + 'D';
      4: s := s + 'E';
      5: s := s + 'F';
      6: s := s + 'G';
      7: s := s + 'H';
      8: s := s + 'I';
      9: s := s + 'J';
      10: s := s + 'K';
      11: s := s + 'L';
      12: s := s + 'M';
      13: s := s + 'N';
      14: s := s + 'O';
      15: s := s + 'P';
      16: s := s + 'Q';
      17: s := s + 'R';
      18: s := s + 'S';
      19: s := s + 'T';
      20: s := s + 'U';
      21: s := s + 'V';
      22: s := s + 'W';
      23: s := s + 'X';
      24: s := s + 'Y';
      25: s := s + 'Z';
      26: s := s + 'a';
      27: s := s + 'b';
      28: s := s + 'c';
      29: s := s + 'd';
      30: s := s + 'e';
      31: s := s + 'f';
      32: s := s + 'g';
      33: s := s + 'h';
      34: s := s + 'i';
      35: s := s + 'j';
      36: s := s + 'k';
      37: s := s + 'l';
      38: s := s + 'm';
      39: s := s + 'n';
      40: s := s + 'o';
      41: s := s + 'p';
      42: s := s + 'q';
      43: s := s + 'r';
      44: s := s + 's';
      45: s := s + 't';
      46: s := s + 'u';
      47: s := s + 'v';
      48: s := s + 'w';
      49: s := s + 'x';
      50: s := s + 'y';
      51: s := s + 'z';
      52: s := s + '#';
      53: s := s + '$';
      54: s := s + '%';
      55: s := s + '0';
      56: s := s + '1';
      57: s := s + '2';
      58: s := s + '3';
      59: s := s + '4';
      60: s := s + '5';
      61: s := s + '6';
      62: s := s + '7';
      63: s := s + '8';
      64: s := s + '9';
    end; {case .end.}
  end;   {for i:= .end.}

         {return result}
  crypt := s;

end; {Crypt **END**}

function Get_King(var ply: userrec): boolean;
var
  Result, found: boolean;

  i:    word;
begin {try to locate and load king from user/npc file}

      {init}
  Result := False;
  found := False;

  for i := 1 to fs(FsPlayer) do
  begin

    {load character}
    load_character(ply, 1, i);

    if (ply.king = True) and (player_active(ply, False) = True) then
    begin
      found := True;
      break;
    end;

  end; {for i:= .end.}

       {Search among the NPCs}
  if not found then
  begin
    for i := 1 to fs(FsNpc) do
    begin

      {load character}
      load_character(ply, 2, i);

      if (ply.king = True) and (player_active(ply, False) = True) then
      begin
        found := True;
        break;
      end;

    end; {for i:= .end.}

  end;

  Result := found;

  {return result}
  get_king := Result;

end; {get_king *end*}

procedure New_King(var king: kingrec); {init a kingrecord}
var i: byte;
begin

  king.Name := emptystr; {name}
  king.ai := 'C'; {king ai, C=computer (default), H=human}
  king.sexy := 1; {male=1,female=2}
  king.daysinpower := 0; {days in power}
  king.tax := 0; {tax rate}
  king.taxalignment := 0; {tax who? 0=all,1=only good,2=only evil}
  king.treasury := 0; {royal treasury}
  king.prisonsleft := 4; {prison sentences left today}
  king.executeleft := 3; {executions left today}
  king.questsleft := Config.MaxNewQuestsPerDay; {max # of new quests the KING can issue/day}
  king.MarryActions := Config.MarryActionsPerDay; {max # of marriages the King can interfer every day}
  king.WolfFeed := 0; {how many kids have been tossed to the wolves}

  king.moatID := emptystr; {whats in the moat? 0=goldfish 1=crocodiles or else}
  king.moatnr := 0; {number of crocodiles (or whatever) in the moat}

  {body guards}
  for i := 1 to global_KingGuards do
  begin
    king.guard[i] := emptystr; {guard name}
    king.guardpay[i] := 0;     {guard salary}
    king.guardai[i] := 'C';    {guard ai}
    king.guardsex[i] := 1;     {guardsex}
  end;

  king.shop_weapon := True;    {shop is open}
  king.shop_armor := True;     {shop is open}
  king.shop_magic := True;     {shop is open}
  king.shop_alabat := True;    {shop is open}
  king.shop_plmarket := True;  {market is open}
  king.shop_healing := True;   {healing center}
  king.shop_drugs := True;     {drug palace is open}
  king.shop_steroids := True;  {steroid shop is open}
  king.shop_orbs := True;      {club is open}
  king.shop_evilmagic := True; {evil mages shop is open}
  king.shop_bobs := True;      {bobs beer is open}
  king.shop_whores := True;    {whore house is open}
  king.shop_gigolos := True;   {gigolos place is open}

end; {new_king *end*}



procedure IncPlayerExp; {increase player experience}
begin

  if ply.exp + exp > global_maxinput then
  begin
    {error}
  end else
  begin
    Inc(ply.exp, exp);
  end;

  {prevent negative amount}
  if ply.exp < 0 then
    ply.exp := 0;

end;

procedure DecPlayerExp; {decrease player experience}
begin
  Dec(ply.exp, exp);
  {prevent negative amount}
  if ply.exp < 0 then
    ply.exp := 0;
end;

procedure IncGodExp; {increase god experience}
begin

  if god0.exp + exp > global_maxinput then
  begin
    {error}
  end else
  begin
    Inc(god0.exp, exp);
  end;

end;

procedure DecGodExp; {decrease god experience}
begin

  Dec(god0.exp, exp);
  {prevent negative amount}
  if god0.exp < 0 then
    god0.exp := 0;

end;

function IncPlayerMoney; {increase player money}
var mum1, mum2, mum3: real;
  Result: boolean;
begin

  mum1 := ply.gold;
  mum2 := coins;
  mum3 := mum1 + mum2;

  if mum3 > global_maxinput then
  begin
    {error}
    Result := False;
  end else
  begin
    Inc(ply.gold, coins);
    Result := True;
  end;

  {prevent negative amount}
  if ply.gold < 0 then
    ply.gold := 0;

  IncPlayerMoney := Result;

end; {incplayermoney *end*}

procedure DecPlayerMoney; {decrease player money}
begin

  Dec(ply.gold, coins);

  {prevent negative amount}
  if ply.gold < 0 then
    ply.gold := 0;

end; {decplayermoney *end*}

function IncBankMoney; {increase bank money}
var mum1, mum2, mum3: real;
  Result: boolean;
begin

  mum1 := ply.bankgold;
  mum2 := coins;
  mum3 := mum1 + mum2;

  if mum3 > global_maxinput then
  begin
    {error}
    Result := False;
  end else
  begin
    Inc(ply.bankgold, coins);
    Result := True;
  end;

  {prevent negative amount}
  if ply.bankgold < 0 then
    ply.bankgold := 0;

  {return result}
  IncBankMoney := Result;

end; {incbankmoney *end*}

procedure DecBankMoney; {decrease bank money}
begin

  Dec(ply.bankgold, coins);

  {prevent negative amount}
  if ply.bankgold < 0 then
    ply.bankgold := 0;

end; {decbankmoney *end*}

function IncInterest; {increase bank interest}
var mum1, mum2, mum3: real;
  Result: boolean;
begin

  mum1 := ply.interest;
  mum2 := coins;
  mum3 := mum1 + mum2;

  if mum3 > global_maxinput then
  begin
    {error}
    Result := False;
  end else
  begin
    Inc(ply.interest, coins);
    Result := True;
  end;

  {prevent negative amount}
  if ply.interest < 0 then
    ply.interest := 0;

  {return result}
  IncInterest := Result;

end; {incinterest *end*}

function IncBankWage; {increase bank guard Wage}
var mum1, mum2, mum3: real;
  Result: boolean;
begin

  mum1 := ply.bankwage;
  mum2 := coins;
  mum3 := mum1 + mum2;

  if mum3 > global_maxinput then
  begin
    {error}
    Result := False;
  end else
  begin
    Inc(ply.bankwage, coins);
    Result := True;
  end;

  {return result}
  IncBankWage := Result;

end; {incbankwage *end*}

function IncKingTreasury2; {increase royal treasury}
var
  mum1, mum2, mum3: real;
  Result:           boolean;
begin

  mum1 := king.treasury;
  mum2 := coins;
  mum3 := mum1 + mum2;

  if mum3 > global_maxinput then
  begin
    {error}
    Result := False;
  end else
  begin
    Inc(king.treasury, coins);
    Result := True;
  end;

  IncKingTreasury2 := Result;

end; {inckingtreasury *end*}

procedure DecKingTreasury; {decrease royal treasury}
begin
  Dec(king.treasury, coins);
  if king.treasury < 0 then
    king.treasury := 0;
end; {deckingtreasury *end*}


procedure Quest_Rankings; {rankings of the characters who have completed
                           the most quests}
const maxsorts = global_maxplayers; {maximum entries this routine will handle}
var
  offset, line_counter: byte;
  i, j, k: longint;
  counter: word;
  ply:     ^UserRec;

  filex:   array [1..maxsorts] of word; {used by sorting routine}
  quests:  array [1..maxsorts] of word; {used by sorting routine}

  s:       string;
  gap:     integer;
  xx, yy:  longint;

begin

  {init pointer vars}
  new(ply);

  {init standard vars}
  for i := 1 to maxsorts do
  begin
    quests[i] := 0;
    filex[i] := 0;
  end; {for i:= .end.}

  crlf;
  crlf;

  s := 'Quest Masters                                     Completed Quests';
  d(5, s);
  d(5, mkstring(length(s), underscore));

  {let's load all characters with completed quests in a temporary sort array}
  counter := 0;
  for i := 1 to fs(fsplayer) do
  begin

    if load_character(ply^, 1, i) = True then
    begin

      if (player_active(ply^, False) = True) and
        (ply^.royquests > 0) then
      begin

        {#}
        Inc(counter);

        filex[counter] := i;
        quests[counter] := ply^.royquests;

      end;

    end;

    {emergency break out}
    if counter = maxsorts then
    begin
      break;
    end;

  end; {for i:= .end.}

       {let's sort the array we collected}
  if counter > 1 then
  begin
    {Sort routine}
    gap := counter div 2;
    while gap > 0 do
    begin
      for i := (gap + 1) to counter do
      begin
        j := i - gap;
        while (j > 0) do
        begin
          k := j + gap;
          if quests[j] >= quests[k] then
          begin
            j := 0;
          end else
          begin

            xx := quests[j];
            yy := filex[j];

            quests[j] := quests[k];
            filex[j] := filex[k];

            quests[k] := xx;
            filex[k] := yy;

            j := j - gap;
          end;
        end;
      end;
      gap := gap div 2;
    end;
    {Sorting *end*}

  end;

  {lets display the sorted array of characters}
  counter := 0;
  line_counter := 2;
  for i := 1 to maxsorts do
  begin

    if filex[i] > 0 then
    begin

      {load right character}
      if load_character(ply^, 1, filex[i]) = True then
      begin

        {#}
        Inc(counter);
        s := ulgray + commastr(counter) + '. ';

        {name}
        s := s + uplc + ply^.name2 + config.textcol1 + ' the level ';

        {level}
        s := s + commastr(ply^.level) + ' ';

        {race}
        s := s + config.textcol1 + classnames[ply^.class] + config.textcol1;

        {display produced string}
        s := s + ' ';

        offset := 80;
        if length(s) < offset then
        begin
          xx := offset - length(s);
          s := s + mkstring(xx, '.');
        end else
        if length(s) > offset then
        begin
          s := copy(s, 1, offset);
        end;

        sd(config.textcolor, s);

        {quests}
        d(15, commastr(ply^.royquests));

        Inc(line_counter);
      end;
    end;

    if line_counter > global_screenlines - 2 then
    begin
      line_counter := 0;
      if confirm('Continue', 'Y') = False then
      begin
        break;
      end;
    end;

  end; {for i:= .end.}

       {dispose pointer vars}
  dispose(ply);

end; {quest_rankings *end*}


procedure Setup_DungeonItems; {reads array of items that can be found in
                               dungeons to array in memory}
var
  i, x:    integer;

  dummy:   byte; {dummy counter, spin cursor routine}

  ok:      boolean;

  gtyp:    objtype;

  objektx: ^orec;

begin

  crlf;
  if config.classic = False then
  begin
    new(objektx);

    case random(5) of
      0: sd(11, 'Preparing your fate...');
      1: sd(11, 'Welcome to perpetual pleasure...');
      2: sd(11, 'Setting up your future...');
      3: sd(11, 'Preparing your entrance...');
      4: sd(11, 'Informing your enemies...');
    end; {case .end.}

    for i := 1 to 15 do
    begin
      for x := 1 to global_maxhittas do
      begin
        hittas[i, x] := False;
      end;
    end; {for i:= .end.}

    x := 1;
    repeat
      case x of
        1: gtyp := Head;
        2: gtyp := Body;
        3: gtyp := Arms;
        4: gtyp := Hands;
        5: gtyp := Fingers;
        6: gtyp := Legs;
        7: gtyp := Feet;
        8: gtyp := Waist;
        9: gtyp := Neck;
        10: gtyp := Face;
        11: gtyp := Shield;
        12: gtyp := Food;
        13: gtyp := Drink;
        14: gtyp := Weapon;
        15: gtyp := Abody;
      end; {case .end.}

      ok := False;
  {1 : s:='Allow Hand Equipment';
   2 : s:='Allow Head Equipment';
   3 : s:='Allow Body Equipment';
   4 : s:='Allow Arm Equipment';
   5 : s:='Allow Left Finger Equipment';
   6 : s:='Allow Right Finger Equipment';
   7 : s:='Allow Leg Equipment';
   8 : s:='Allow Feet Equipment';
   9 : s:='Allow Waist Equipment';
   10: s:='Allow 1 Neck Equipment';
   11: s:='Allow 2 Neck Equipment';
   12: s:='Allow Face Equipment';
   13: s:='Allow Shield';
   14: s:='Allow Around Body Equipment';
   15: s:='Allow Secondary Weapon';
   }

      if (gtyp = Head) and (config.allowitem[2]) then
        ok := True;
      if (gtyp = Body) and (config.allowitem[3]) then
        ok := True;
      if (gtyp = Arms) and (config.allowitem[4]) then
        ok := True;
      if (gtyp = Hands) and (config.allowitem[1]) then
        ok := True;
      if gtyp = Fingers then
      begin
        if (config.allowitem[5]) or (config.allowitem[6]) then
          ok := True;
      end;
      if (gtyp = Legs) and (config.allowitem[7]) then
        ok := True;
      if (gtyp = Feet) and (config.allowitem[8]) then
        ok := True;
      if (gtyp = Waist) and (config.allowitem[9]) then
        ok := True;
      if gtyp = Neck then
      begin
        if (config.allowitem[10]) or (config.allowitem[11]) then
          ok := True;
      end;
      if (gtyp = Face) and (config.allowitem[12]) then
        ok := True;
      if (gtyp = Shield) and (config.allowitem[13]) then
        ok := True;
      if (gtyp = Abody) and (config.allowitem[15]) then
        ok := True;

      if gtyp in [Food, Drink, Weapon] then
        ok := True;

      if ok then
      begin

        dummy := 0;
        for i := 1 to fsob(gtyp) do
        begin

          load_objekt(objektx^, gtyp, i);

          if config.spincursor = True then
          begin
            Inc(dummy);
            if dummy > 20 then
            begin
              dummy := 0;
              spin_cursor(2, 11); {spinit}
            end;
          end;

          if objektx^.dng = True then
          begin
            hittas[x, i] := True;
          end;

          if i >= global_maxhittas then
          begin
            break;
          end;

        end; {for i:= .end.}

      end;

      Inc(x);
    until x > 15;

    dispose(objektx);
    crlf;

  end;
end; {setup_dungeonitems *end*}

procedure Pay_Royal_Guard(var ply: UserRec; var king: kingrec);
var i, k: byte;
begin

 {this procedure is called by the Maint routines to pay players if
  they are in the Royal Guard Force.
  Should the Royal Treasury not have the funds, then the player will
  be sacked from his/her duty.}

  {is the player a guard?}
  k := 0;
  for i := 1 to global_kingguards do
  begin
    if (ply.name2 = king.guard[i]) and
      (ply.name2 <> '') and
      (player_active(ply, False) = True) then
    begin

      k := i;
      break;
    end;
  end; {for i:= .end.}

  if k > 0 then
  begin
    if king.guardpay[k] > 0 then
    begin
      if king.guardpay[k] > king.treasury then
      begin
        {not enough money! we must sack player}

        {post sacked player}
        post(MailSend,
          king.guard[k],
          king.guardai[k],
          False,
          mailrequest_nothing,
          '',
          ulred + 'SACKED!' + config.textcol1,
          mkstring(7, underscore),
          'You were SACKED from the ' + ulcyan + 'Royal Guard' + config.textcol1 + '!',
          'The Royal Treasury is bankrupt! No wages are being payed.',
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

        {notify the king}
        post(MailSend,
          king.Name,
          king.ai,
          False,
          mailrequest_nothing,
          '',
          ulred + 'SACKED' + config.textcol1,
          mkstring(6, underscore),
          uplc + king.guard[k] + config.textcol1 + ' was SACKED from the ' + ulcyan + 'Royal Guard' + config.textcol1 + '.',
          'The Royal Treasury is bankrupt!',
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

        Newsy(True,
          'Sacked',
          ' ' + uplc + king.guard[k] + config.textcol1 + ' was SACKED from the ' + ulcyan +
          'Royal Guard' + config.textcol1 + '!',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

        king.guard[k] := emptystr;
        king.guardpay[k] := 0;

      end else
      begin

        {decrease Royal Treasury}
        DecKingTreasury(king, king.guardpay[k]);

        {pay player}
        IncPlayerMoney(ply, king.guardpay[k]);

        {inform player}
        post(MailSend,
          king.guard[k],
          king.guardai[k],
          False,
          mailrequest_nothing,
          '',
          umailheadc + 'Income' + config.textcol1,
          mkstring(6, underscore),
          'You received ' + uyellow + commastr(king.guardpay[k]) + config.textcol1 + ' ' +
          many_money(king.guardpay[k]) + ' for your',
          'service in the ' + ulcyan + 'Royal Guard' + config.textcol1 + '.',
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

        {inform the King of the expenses}
        post(MailSend,
          king.Name,
          king.ai,
          False,
          mailrequest_nothing,
          '',
          umailheadc + 'Royal Expenses' + config.textcol1,
          mkstring(14, underscore),
          ulgray + 'The Royal Treasury ' + config.textcol1 + 'reports that it has paid ' + uplc +
          king.guard[k] + config.textcol1,
          'the tidy sum of ' + uyellow + commastr(king.guardpay[k]) + config.textcol1 + ' for ' +
          sex3[king.guardsex[k]] + ' service in the ' + ulcyan + 'Royal Guard' + config.textcol1 + '.',
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
    end;
  end;

end; {pay_royal_guard *end*}


procedure Sack_Royal_Guards;
var i:  byte;
  king: kingrec;
begin

 {this proc is called by either the 'A'bdication process or when
  a new king is installed, the guard are automatically sacked}

  {load king}
  load_king(fload, king);

  for i := 1 to global_kingguards do
  begin

    if (king.guard[i] <> '') and (king.guardai[i] = 'H') then
    begin
      if is_online(king.guard[i], online_player) then
      begin
        online_send_to_player(king.guard[i], online_player, 'You were ' + ulred + 'SACKED' +
          config.textcol1 + ' from the Royal Guard!');
      end else
      begin

        {mail}
        post(MailSend,
          king.guard[i],
          king.guardai[i],
          False,
          mailrequest_nothing,
          '',
          ulred + 'SACKED' + config.textcol1,
          mkstring(6, underscore),
          'You were ' + ulred + 'sacked' + config.textcol1 + ' from the ' + ulcyan + 'Royal Guard' + config.textcol1 + '.',
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
    end;

  end; {for i:= .end.}

end;   {sack_royal_guards *end*}

procedure Inform_King(const line1, line2, line3, line4, line5, line6, line7, line8, line9, line10,
  line11, line12, line13, line14, line15: s90);

{mail king, if he exists and is a human controlled character}
var king: kingrec;
begin

  {load king data}
  load_king(fload, king);

  if (king.Name <> '') and (king.ai = 'H') then
  begin
    post(MailSend,
      king.Name,
      king.ai,
      False,
      mailrequest_nothing,
      '',
      line1,
      line2,
      line3,
      line4,
      line5,
      line6,
      line7,
      line8,
      line9,
      line10,
      line11,
      line12,
      line13,
      line14,
      line15);
  end;

end; {inform_king *end*}


procedure King_Is_Gone;
var
  s:          s70;
  i, j, size: word;

  relation:   ^RelationRec;
  ply:        ^UserRec;

begin

  {when king has commited suicide/been deposed/abdicated}

  {init}
  new(relation);
  new(ply);

  {we must not to forget current player flag}
  player.KingVotePoll := 200;
  player.KingLastVote := 0; {how did player vote last time}

  {reset all player/Npc vote for king flags}
  for i := 1 to 2 do
  begin

    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end; {case .end.}

    for j := 1 to size do
    begin

      {load character}
      if load_character(ply^, i, j) = True then
      begin

        if ply^.deleted = False then
        begin

          {is ply online or offline?}
          if (i = 1) and (is_online(ply^.name2, online_player) = True) then
          begin
            {Reset "King Vote" time}
            online_send_to_player(ply^.name2, online_player, broadcast_ResetKingVote);
            online_send_to_player(ply^.name2, online_player, broadcast_TaxReinstate);
          end else
          begin
            ply^.KingVotePoll := 200; {days since vote for king. this makes it happen at first logon}
            ply^.KingLastVote := 0;   {how did player vote last time}
            if ply^.tax_relief = True then
            begin
              ply^.Tax_Relief := False; {kill old tax relief flag}

              {inform player of reinstated royal tax}
              s := 'Revoked Tax Privilege!';
              post(MailSend,
                ply^.name2,
                ply^.ai,
                False,
                mailrequest_nothing,
                '',
                ulred + s + config.textcol1,
                mkstring(length(s), underscore),
                'You are obliged to pay Royal Taxes again!',
                'Your old privilege has been revoked!',
                'You no longer enjoy special favors with the Royal Family.',
                ' //The Royal Treasury//',
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

            user_save(ply^); {update player}

          end;
        end;

      end;

    end; {for j:= .end.}

  end;   {for i:= .end.}

         {open all shoppes}
 {hmm..this is done in file_io.pas =>
 }

  {remove all relation "bans on marriage"}
  for i := 1 to fs(FsRelation) do
  begin

    {load relation}
    load_relation(fload, relation^, i);

    if (relation^.deleted = False) and
      (relation^.BannedMarry = True) then
    begin

      {set new flags}
      Relation^.BannedMarry := False;

      {save relation}
      load_relation(fsave, relation^, i);

      {mail the happy couple}
      s := 'Forgiven!';
      {mail name1}
      s := 'Forgiven!';
      post(MailSend,
        relation^.name1,
        relation^.ai1,
        False,
        mailrequest_nothing,
        '',
        uyellow + s + config.textcol1,
        mkstring(length(s), underscore),
        'The Royal House has forgiven the immoral relationship between you',
        'and ' + uplc + relation^.name2 + config.textcol1 + '!',
        'Try to act decent in the future, or you will be banned forever!',
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

      s := 'Forgiven!';
      {mail name1}
      s := 'Forgiven!';
      post(MailSend,
        relation^.name2,
        relation^.ai2,
        False,
        mailrequest_nothing,
        '',
        uyellow + s + config.textcol1,
        mkstring(length(s), underscore),
        'The Royal House has forgiven the immoral relationship between you',
        'and ' + uplc + relation^.name1 + config.textcol1 + '!',
        'Try to act decent in the future, or you will be banned forever!',
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

  end; {for i:= .end.}

       {dispose pointer vars}
  dispose(relation);
  dispose(ply);

end; {king_is_gone *end*}

function KingString;
var s: string[5];
begin

  {set default value}
  s := 'King';

  case sex of
    1: s := 'King';
    2: s := 'Queen';
  end;

  {return result}
  KingString := s;

end;

procedure Make_Delay_Dots; {displays X dots with delay between}
var counter: integer;
begin
  counter := 0;
  repeat
    counter := counter + 1;
    sd(col, '.');
    delay2(delayy);
  until counter >= dots;
end;



procedure FeelFor_TheKing;
var kingstr: string[5];
  ch:        char;
  done:      boolean;
  king:      kingrec;
begin

  kingstr := 'King';

  {we exit if there is no king-file}
  if f_exists(global_kingf) = False then
    exit;

  {load king}
  load_king(fload, king);

  {we exit if there is no king}
  if king.Name = '' then
    exit;

  case king.sexy of
    1: kingstr := 'King';
    2: kingstr := 'Queen';
  end;


  done := False;
  ch := '?';
  repeat

    if ch = '?' then
    begin
      crlf;
      crlf;
      sd(config.textcolor, 'What are your feelings toward ' + kingstr);
      d(global_kingcol, ' ' + king.Name);
      crlf;

      menu('(1) I love ' + sex[king.sexy] + '!');
      menu('(2) this Tyrant must be removed!');
      menu('()');
    end;

    sd(config.textcolor, 'Declaration of Loyalty (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');

    {get user-input}
    ch := upcase(getchar);

  until done;

end; {feelfor_theking *end*}

procedure Read_News_Paper;
{used by both mortals and gods to read the news}
var ch: char;
begin

  crlf;
  crlf;
  menu2('(T)odays News,');
  menu2(' (Y)esterdays News or');
  menu2(' (A)bort :');

  repeat
    ch := upcase(getchar);
  until ch in ['A', 'Y', 'N', 'T', ReturnKey];

  crlf;

  case ch of
    ReturnKey, 'T', 'N': begin {todays news}
      if global_ansi then
        display_file(global_nwfileans)
      else display_file(global_nwfileasc);
    end;
    'Y': begin {yesterdays news}
      if global_ansi then
        display_file(global_ynwfileans)
      else display_file(global_ynwfileasc);
    end;
  end; {case .end.}
  pause;

end; {read_news_paper *end*}

     {Alchemist}
function Alchemist_Poison(const ply: Userrec): s30;
var s: s30;
begin

  {returns a string with info on how strong the current poison is}
  s := 'Light';
  if ply.poison > 25 then
    s := 'Medium';
  if ply.poison > 50 then
    s := 'Strong';
  if ply.poison > 80 then
    s := 'Deadly';

  {return result}
  alchemist_poison := s;

end; {alchemist_poison *end*}

procedure Player_Profile(const caller, ply: userrec);
var s:      s90;
  relation: relationrec;
begin {displays information of a character..used when dealing
       with applications for membership (team/gym) and when the
       king hires guards...but can of course be used for other kinds
       of situations. caller is the player calling this procedure.}

  d(global_plycol, ply.name2 + config.textcol1 + ' is ' + uwhite + commastr(ply.age) + config.textcol1 + ' years old.');
  d(global_plycol, ply.name2 + config.textcol1 + ' is a level ' + uwhite + commastr(ply.level) +
    config.textcol1 + ' character.');

  {soul condition (good or evil)}
  if ply.dark > ply.chiv then
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' is ' + ulred + 'EVIL' + config.textcol1 + '.');
  end else
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' is ' + uwhite + 'GOOD-HEARTED' + config.textcol1 + '.');
  end;

  {mental state}
  if ply.mental < 100 then
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' has ' + ulred + 'mental problems' + config.textcol1 + '.');
  end;
  if ply.addict > 0 then
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' has ' + ulred + 'drug problems' + config.textcol1 + '.');
  end;

  {player kills}
  crlf;
  d(global_plycol, ply.name2 + config.textcol1 + ' has defeated ' + uwhite + commastr(ply.p_kills) +
    config.textcol1 + ' players in ' + sex3[ply.sex] + ' career.');
  d(global_plycol, ply.name2 + config.textcol1 + ' has been defeated ' + uwhite + commastr(ply.p_defeats) +
    config.textcol1 + ' times.');
  {load current relation}
  social_relation(caller, ply, relation);
  {display how many times player has been attacked by applicant}
  attacked_relation_display(relation);

  {PART II, the social stuff}
  crlf;

  {married}
  if ply.married = True then
  begin
    s := is_player_married(ply.name2, ply.id);
    if s <> '' then
    begin
      if s = player.name2 then
        s := 'You';
      d(global_plycol, ply.name2 + config.textcol1 + ' is married to ' + uplc + s + config.textcol1 + '.');
    end;
  end else
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' is not married.');
  end;

  {children}
  if ply.kids > 0 then
  begin
    if ply.kids = 1 then
    begin
      s := uwhite + '1' + config.textcol1 + ' child.';
    end else
    begin
      s := uwhite + commastr(ply.kids) + config.textcol1 + ' children.';
    end;

    d(global_plycol, ply.name2 + config.textcol1 + ' is the ' + sex8[ply.sex] + ' of ' + s);

  end else
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' has no children.');
  end;

  {believer}
  if ply.god <> '' then
  begin
    d(global_plycol, ply.name2 + config.textcol1 + ' is a believer in ' + ugodc + ply.god + config.textcol1 + '.');
  end;

end; {player_profile *end*}

function Adds(const Name: s30): s3;
begin
 {this simple function is used when you are displaying a sentence like
  for example : "player.name's children". This function returns
  a "s" if players name not already ends with a s}

  {return result}
  if upcasestr(Name[length(Name)]) <> 'S' then
    adds := 's'
  else adds := '';

end; {adds *end*}

end. {UNIT VARIOUS *END*}
