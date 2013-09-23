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


unit VarGods; {Usurper - various God routines}

interface

uses
  Init, InitGods;

{God stuff}
function God_Search(const user_name: string): boolean;
function God_Title(const level: word): string;
function God_Believers(const godname: string; listem: boolean): word;
function Select_A_God(var tgod: godrec; const excludename: s70; const numbered: boolean): boolean;
function God_Active(const tgod: godrec): boolean;
function Verify_Gods_Existance(const Name: string): boolean;
function Get_Random_God(var Name: s30): boolean;
function How_Many_Believers(const god0: godrec): word;
function Load_God_By_Name(const Name: s30; var goddy: godrec): boolean;
function Player_Has_A_God(const Name: s90): boolean;

function Sacrifice_Gold_Return(const ingold: longint): longint;

procedure God_Maintenance; {run every day}
procedure Become_God(const user_name: string; insex: byte);
procedure God_Status(const goddy: godrec);
procedure List_Gods(const numbered: boolean);
procedure Inform_Disciples(const god1: godrec; const header: s40; const lin1, lin2, lin3, lin4: s100);
procedure List_Altars(const called_from_mortal_world: boolean);
procedure The_Great_Creators_Place; {the god boss!}

implementation

uses
  Crt, DDplus, CMS,
  Jakob, Various, Various3,
  News, Online, Mail,
  GenNews, File_IO;

const bossplace = 'Rurforium';

function God_Active(const tgod: godrec): boolean;
var Result: boolean;
begin

  if (tgod.deleted) or (tgod.Name = '') then
    Result := False
  else Result := True;

  {return result}
  god_active := Result;

end; {god_active *end*}

function Get_Random_God(var Name: s30): boolean;
const max_tries = 25;
var
  done, Result: boolean;

  tries:        byte;

  size, nr:     word;

  god0:         godrec;

begin {get random active God and return name of god in the NAME variable
       we also return true or false depending on the success of the
       operation}

  {init}
  Result := False;
  done := False;
  tries := 0;
  size := fs(fsgod);

  {does the god-file exist?}
  if f_exists(global_godfil) then
  begin

    repeat

      {lets get a random number from size}
      nr := random(size) + 1;

      {load character}
      if load_god(fload, god0, nr) = True then
      begin

        if god_active(god0) then
        begin

          {set vars}
          Name := god0.Name;
          done := True;
          Result := True;

        end;

      end;

      Inc(tries);

    until done or (tries > max_tries);
  end;

  {return result}
  get_random_god := Result;

end; {get_random_god *end*}

function Verify_Gods_Existance(const Name: string): boolean;
var
  Result: boolean;
  i:      word;
  tgod:   godrec;

begin {verify that a God by the name NAME exists, and is not deleted}

      {init}
  Result := False;

  for i := 1 to fs(FsGod) do
  begin

    {load god}
    if load_god(fload, tgod, i) = True then
    begin

      if (upcasestr(tgod.Name) = upcasestr(Name)) and
        (tgod.deleted = False) then
      begin
        Result := True;
        break;
      end;
    end;

  end; {for i:= .end.}

       {return result}
  Verify_Gods_Existance := Result;

end; {Verify_Gods_Existance *end*}

function Select_A_God(var tgod: godrec; const excludename: s70; const numbered: boolean): boolean;
  {returns false if no God is selected}
var
  i:      word;

  s:      s70;

  Result: boolean;
begin

 {
  let the user pick a God that is not deleted
   }

  {init}
  Result := False;

  repeat

    d(config.textcolor, 'Select Immortal (press ' + config.textcol2 + '?' + config.textcol1 + ' for list)');
    sd(config.textcolor, ':');

    s := get_string(20);

    if s = '?' then
    begin
      list_gods(numbered);
    end;

  until s <> '?';

  for i := 1 to fs(FsGod) do
  begin

    {load god}
    if load_god(fload, tgod, i) = True then
    begin

      if (findsub(s, tgod.Name)) and
        (tgod.deleted = False) and
        (tgod.Name <> excludename) then
      begin

        if confirm(ugodc + tgod.Name + config.textcol1, 'N') = True then
        begin
          Result := True;
          break;
        end else
        begin

          if confirm('Continue search', 'Y') = False then
          begin
            break;
          end;

        end;
      end;
    end;

  end; {for i:= .end.}

       {return result}
  select_a_god := Result;

end; {select_a_god *end*}

function God_Believers(const godname: string; listem: boolean): word;
var
  Result, size, i, j: word;

  pl0: ^UserRec;

  s:   s100;

begin {how many followers has deity GODNAME?, we list the followers if LISTEM is true}

      {init}
  Result := 0;
  new(pl0);

  if listem then
  begin

    s := 'Followers of ' + godname;
    d(5, cool_string(length(s), '=', '-', 5, 10));
    d(3, s);
    d(5, cool_string(length(s), '=', '-', 5, 10));

  end;

  {search player and npc file}
  for i := 1 to 2 do
  begin

    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end;

    for j := 1 to size do
    begin
      load_character(pl0^, i, j);

      if (pl0^.deleted = False) and
        (pl0^.god <> '') and
        (pl0^.god = godname) then
      begin

        Inc(Result);

        if listem then
        begin
          d(14, commastr(Result) + '. ' + uplc + pl0^.name2);
        end;

      end;

    end; {for j:= .end.}

  end;   {for i:= .end.}

         {remove pointer variables}
  dispose(pl0);
         {return result}
  god_believers := Result;

end; {god_believers *end*}

function God_Search(const user_name: string): boolean;
var
  Result:         boolean;

  i, nr, counter: word;

begin

  {does user_name have any divine characters?}
 {NOTE: if a user have several divine characters, he must then
  choose which one he would like to play}

  {init}
  Result := False;
  counter := 0;

  for i := 1 to fs(FsGod) do
  begin

    {load god}
    load_god(fload, god, i);


    if (god.deleted = False) and
      (upcasestr(god.realname) = upcasestr(user_name)) then
    begin

      Inc(counter);

      if counter = 1 then
      begin
        d(5, 'Pick your immortal');
      end;

      sd(12, commastr(counter) + '. ');
      d(global_godcol, god.Name);

    end;

  end; {for i:= .end.}

  if counter > 0 then
  begin
    d(12, '0. Abort');

    sd(config.textcolorH, ':');

    nr := get_number(0, counter);

    if nr > 0 then
    begin
      {load god #nr}
      counter := 0;
      for i := 1 to fs(FsGod) do
      begin

        load_god(fload, god, i);

        if (god.deleted = False) and
          (upcasestr(god.realname) = upcasestr(user_name)) then
        begin

          Inc(counter);

          if counter = nr then
          begin
            Result := True;
            break;
          end;

        end;
      end; {for i:= .end.}
    end;

  end;

  {return result}
  god_search := Result;

end; {god_search *end*}

procedure Become_God;
var
  slot:        word;
  alias:       s30;
  done, found: boolean;
  i:           word;

  tempgod:     godrec;

begin

  {a player enters this proc when he has completed the last dungeon monster}

  clearscreen;
  crlf;
  crlf;
  sd(config.textcolorH, 'You ascend to Heaven...');
  Make_Delay_Dots(config.textcolorH, 15, 300);
  crlf;
  sd(config.textcolorH, 'You grovel on your hands and knees before the great ');
  sd(global_godcol, global_supreme_creator);
  d(config.textcolorH, '.');
  crlf;


  {get alias}
  repeat

    d(global_talkcol, 'So, what name do you want to be known by?');
    sd(config.textcolorH, ':');
    alias := get_string(22);

    if length(alias) < 3 then
    begin
      d(config.textcolorH, 'Your divine name must have at least 3 letters.');
      continue;
    end;
    crlf;
    sd(config.textcolorH, 'Reading the ancient scrolls...');

    {*Search for dupe aliases among the Gods*}
    found := False;
    done := False;

    for i := 1 to fs(FsGod) do
    begin

      load_god(fload, god, i);

      if (upcasestr(alias) = upcasestr(god.Name)) or
        (upcasestr(alias) = 'SYSOP') or
        (upcasestr(alias) = upcasestr(global_supreme_creator)) then
      begin

        crlf;
        d(12, 'I''m sorry, but this name is already being used.');
        crlf;
        found := True;
        break;

      end;
    end; {for i:= .end.}

    if found then
      continue;

    crlf;
    sd(global_godcol, alias);
    if confirm(' is what you want', 'Y') = True then
    begin
      done := True;
    end else
    begin
      crlf;
    end;
    crlf;

  until done;

  {Setup God record}


  with God do
  begin
    realname := User_Name; {real (user/bbs) name}
    Name := alias;        {alias}
    id := player.id;      {player.id sec tag}
    recnr := 1;           {rec # in file}
    age := random(5) + 2; {age}
    sex := insex;
    ai := 'H';
    level := 1;       {level}
    exp := 1;         {experience}
    deedsleft := config.gods_deedsleft; {deeds left today}
    deleted := False; {deleted}
    believers := 0;   {believers, disciples, players who worships this god}
    darkness := player.dark; {good points}
    goodness := player.chiv; {dark points}
  end;

  {Save God}
  {trying to find an EMPTY slot to SAVE new God in}
  slot := 0;
  for i := 1 to fs(FsGod) do
  begin
    load_god(fload, tempgod, i);
    if tempgod.deleted = True then
    begin
      slot := i;
      break;
    end;
  end; {for i:= .end}

  if slot > 0 then
  begin
    d(config.textcolor, 'Empty slot found....');

    god.recnr := slot;
    load_god(fsave, god, slot);

 {debug stuff
  d(15,'RealnName: '+god.realname);
  d(15,'Alias: '+god.name);
  d(15,'Recnr: '+commastr(god.recnr));
  pause;
 }

  end else
  begin
    slot := fs(FsGod) + 1;
    god.recnr := slot;
    load_god(fsave, god, slot);
  end;

  {news-paper}
  newsy(True,
    config.textcol1 + 'Divinity!',
    ' ' + ugodc + god.Name + config.textcol1 + ' became immortal and entered the Divine Realm!',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

  {put the news in the Holy log-file}
  Generic_News(HolyNews,
    True,
    ' ' + ugodc + god.Name + config.textcol1 + ' became Immortal!',
    ' ' + ugodc + god.Name + config.textcol1 + ' defeated the Supreme Being!',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

  {send message to online players and gods}
  online_send_to_all(uwhite + '*NEW GOD*' + uplc + ' ' + god.Name + config.textcol1 + ' has become a God!', god.Name, '');

end; {become_god *end*}

function God_Level_Raise(const tempgod: godrec): word;
var Result: word;
  currexp:  longint;
begin {calculates and returns the levels tempgod should have based on
       his experience}

  {init}
  Result := 1;
  currexp := tempgod.exp;

  {check exp}
  if currexp > 5000 then
    Result := 2;
  if currexp > 15000 then
    Result := 3;
  if currexp > 50000 then
    Result := 4;
  if currexp > 70000 then
    Result := 5;
  if currexp > 90000 then
    Result := 6;
  if currexp > 110000 then
    Result := 7;
  if currexp > 550000 then
    Result := 8;
  if currexp > 1000500 then
    Result := 9;

  {return result}
  god_level_raise := Result;

end; {god_level_raise *end*}

function God_Title(const level: word): string;
var s: s20; {gives back the rank of a certain God level}
begin

  case level of
    1: s := 'Lesser Spirit';
    2: s := 'Minor Spirit';
    3: s := 'Spirit';
    4: s := 'Major Spirit';
    5: s := 'Minor Deity';
    6: s := 'Deity';
    7: s := 'Major Deity';
    8: s := 'DemiGod';
    9: s := 'God';

  end; {case of .end.}

       {return result}
  god_title := s;

end; {god_title *end*}

procedure List_Gods; {displays ranking list of gods to screen}
var
  i, nr, counter: word;

  line_counter: byte;

  s:       s70;

  abort:   boolean;

  tempgod: godrec;

begin {input parameter : numbered}

      {display god rankings to screen}

  crlf;
  s := '   Immortals                Rank                Followers  ';
  d(5, cool_string(length(s), '=', '-', 5, 10));
  d(3, s);
  d(5, cool_string(length(s), '=', '-', 5, 10));

  counter := 0;
  line_counter := 3;
  abort := False;
  for i := 1 to fs(FsGod) do
  begin

    if load_god(fload, tempgod, i) = True then
    begin

      if god_active(tempgod) = True then
      begin

        Inc(counter);

        {#}
        if numbered then
        begin
          sd(9, ljust(commastr(counter), 3));
        end;

        {name}
        sd(global_godcol, ljust(tempgod.Name, 25));

        {level}
        sd(config.textcolorH, ljust(god_title(tempgod.level) + commastr(tempgod.level), 13));

        {believers}
        nr := god_believers(tempgod.Name, False);

        if nr = 0 then
        begin
          sd(8, rjust('-', 10));
        end else
        begin
          sd(7, rjust(commastr(nr), 10));
        end;


        crlf;

        Inc(line_counter);
        if line_counter > global_screenlines - 2 then
        begin
          line_counter := 0;
          if confirm('Continue', 'Y') = False then
          begin
            abort := True;
          end;
        end;

      end;
    end;

    if abort then
      break;

  end; {for i:= .end}

end;   {list_gods *end*}

procedure God_Status;
begin

  clearscreen;
  crlf;
  crlf;

  {name}
  sd(config.textcolorH, 'You are ');
  d(global_godcol, goddy.Name);

  {level}
  sd(config.textcolorH, 'Rank .. ');
  d(7, god_title(goddy.level) + ' (level ' + commastr(goddy.level) + ')');

  {believers}
  sd(config.textcolorH, 'Believers .. ');
  d(7, commastr(goddy.believers));

  {deeds left}
  sd(config.textcolorH, 'Deeds left .. ');
  d(7, commastr(goddy.deedsleft));

  {havre}
  sd(config.textcolorH, 'Havre .. ');
  d(7, commastr(goddy.exp));

end; {god_status *end*}

procedure God_Maintenance; {runs every day}
var
  memy:     byte;

  mem:      integer;

  i:        word;

  xx:       longint;

  rr:       real;

  temp_god: godrec;

begin

  {we exit if no gods exist}
  if f_exists(global_godfil) = False then
    exit;

  xx := fs(FsNPC);
  mem := xx;

  {BIG_LOOP *start*}
  memy := wherey;
  for i := 1 to fs(FsGod) do
  begin

    xx := mem;
    rr := i;

    if xx > 0 then
    begin
      rr := rr / xx;
      xx := round(rr * 100);
    end else
    begin
      xx := 0;
    end;

    {progress indicator}
    sgoto_xy(1, memy);
    sd(global_mainttxt, 'Immortal activity (' + commastr(xx) + '%)');

    {load god}
    load_god(fload, temp_god, i);

    if god_active(temp_god) = True then
    begin

      {new deeds}
      temp_god.deedsleft := config.gods_deedsleft;

      {give believer exp}
      incgodexp(temp_god, temp_god.believers);

      {save god}
      load_god(fsave, temp_god, i);

    end;

  end; {for i:= .end.}
       {BIG_LOOP *end*}

end; {god_maintenance *end*}


function Sacrifice_Gold_Return(const ingold: longint): longint;
var Result: longint;
begin {given the ingold value this routine returns the power increase
       a god will receive from the amount. used in temple.pas}

  Result := 1;
  if ingold <= 20 then
  begin
    Result := 1;
  end else
  if (ingold >= 21) and (ingold <= 2000) then
  begin
    Result := 2;
  end else
  if (ingold >= 2001) and (ingold <= 45000) then
  begin
    Result := 3;
  end else
  if (ingold >= 45001) and (ingold <= 150000) then
  begin
    Result := 4;
  end else
  if (ingold >= 150001) and (ingold <= 900000) then
  begin
    Result := 5;
  end else
  if (ingold >= 900001) and (ingold <= 15000000) then
  begin
    Result := 6;
  end else
  if (ingold >= 15000001) and (ingold <= 110000000) then
  begin
    Result := 7;
  end else
  if ingold >= 110000001 then
  begin
    Result := 8;
  end;

{
  150001..680000:result:=5;
  681001..1500000: result:=6;
  1500001..150000000: result:=7;

 {return result}
  sacrifice_gold_return := Result;

end; {sacrifice_gold_return .end.}

function Player_Has_A_God;
var Result: boolean;
  i:        word;

  goddy:    godrec;

begin {checks is NAME has immortal characters}

      {init vars}
  Result := False;

  for i := 1 to fs(FsGod) do
  begin

    {load god}
    if load_god(fload, goddy, i) = True then
    begin

      if (upcasestr(goddy.realname) = upcasestr(Name)) and
        (goddy.deleted = False) then
      begin
        Result := True;
        break;
      end;
    end;

  end; {for i:= .end.}

       {return result}
  player_has_a_god := Result;

end; {player_has_a_god .end.}


function Load_God_By_Name(const Name: s30; var goddy: godrec): boolean;
var Result: boolean;
  i:        word;

begin {attempts to load a god by NAME}

      {init vars}
  Result := False;

  for i := 1 to fs(FsGod) do
  begin

    {load god}
    if load_god(fload, goddy, i) = True then
    begin

      if (upcasestr(goddy.Name) = upcasestr(Name)) and
        (goddy.deleted = False) then
      begin
        Result := True;
        break;
      end;
    end;

  end; {for i:= .end.}

       {return result}
  load_god_by_name := Result;

end; {load_god_by_name .end.}

function How_Many_Believers(const god0: godrec): word;
var
  i, j, size, Result: word;
begin

  {init}
  Result := 0;

  {searching among the humans and NPCs}
  for i := 1 to 2 do
  begin

    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end; {case .end.}

    for j := 1 to size do
    begin

      {load character}
      if load_character(player, i, j) = True then
      begin

        if (player_active(player, False) = True) and
          (player.god = god.Name) then
        begin

          {found a believer!}
          Inc(Result);

        end;
      end;
    end; {for j:= .end.}
  end;   {for i:= .end.}

         {return result}
  How_Many_Believers := Result;
end; {How_Many_Believers *end*}

procedure Meny;
begin

  {text}
  clearscreen;
  crlf;
  d(5, '-**- ' + bossplace + ' -**-');
  crlf;
  d(config.textcolorH, 'You are standing before ' + ugodc + global_supreme_creator + config.textcol1h + '.');
  d(config.textcolorH, 'Your presence is barely noticed.');

  crlf;

  menu('(A)sk for power');
  menu('(S)tatus');
  menu('(R)eturn');

end; {meny *end*}


procedure Display_Menu(refresh, force, short: boolean);
begin

  if short then
  begin
    if (refresh) and (player.auto_meny) then
    begin
      refresh := False;
      meny;
    end;

    crlf;
    sd(config.textcolorH, bossplace + ' (' + config.textcol2H + '?' + config.textcol1H + ' for menu) :');
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure the_great_creators_place;
var refresh: boolean;

var
  end_boss_visit: boolean;

  ch: char;

  x:  word;

begin {the boss god!}

  crlf;
  crlf;
  d(config.textcolorH, 'You enter ' + ubrown + bossplace + config.textcol1h + '.');

  {location begins here}
  end_boss_visit := False;
  repeat

    if onliner.location <> onloc_heaven_boss then
    begin
      refresh := True;
      onliner.location := onloc_heaven_boss;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(refresh, True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      '?': begin {menu}
        if player.expert = True then
          display_menu(refresh, True, False)
        else display_menu(refresh, False, False);
      end;
      'S': begin {status}
        god_status(god);
      end;
      'R': begin {return}
        end_boss_visit := True;
      end;
      'A': begin {ask for power}

        x := god_level_raise(god);

        if x = god.level then
        begin
          crlf;
          crlf;

          case random(2) of
            0: begin
              d(12, 'Puny worm! You are not worthy of the higher powers!');
              d(12, 'Prove yourself before you come here!');
            end;
            1: begin
              d(12, 'Get out of my sight lesser being!');
              d(12, 'Hmmppff!');
            end;
          end; {case .end.}
          pause;

        end else
        if x > god.level then
        begin

          {level raise}
          crlf;
          crlf;
          d(global_godcol, global_supreme_creator + config.textcol1h + ' looks at you and nods.');
          d(global_talkcol, '"Reap the rewards of your work ' + ugodc + god.Name + utalkc + '!"');

          {update god}
          Inc(god.level);
          load_god(fsave, god, god.recnr);

          {inform nodes}
          online_send_to_all(uplc + god.Name + 's' + config.textcol1 + ' powers are growing!', god.Name, '');

          {news-paper}
          newsy(True,
            config.textcol1 + 'Divine Ranks!',
            ' ' + ugodc + god.Name + config.textcol1 + ' has been granted a new rank; ' + ulgreen +
            god_title(god.level) + config.textcol1 + '!',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

          {inform disciples}
          Inform_Disciples(god, 'Your God Increased ' + sex3[god.sex] + ' Powers!',
            ugodc + god.Name + ulred + ' gained a level in heaven!',
            '',
            '',
            '');

          pause;

          crlf;
          d(15, '*Congratulations*');
          d(config.textcolorH, 'You are now ranked ' + uwhite + god_title(god.level));

        end;

      end; {ask for power .end.}

    end;   {case .end}

  until end_boss_visit;

  crlf;
  crlf;
  d(config.textcolorH, 'Your mind shifts toward other matters.');

end; {the_great_creators_place *end*}

procedure List_Altars;
var
  i, nr, counter: word;

  line_counter:   byte;

  god0:           godrec;

begin

  counter := 0;
  line_counter := 0;
  for i := 1 to fs(FsGod) do
  begin

    {load god}
    if load_god(fload, god0, i) = True then
    begin

      if god_active(god0) then
      begin
        Inc(counter);

        if counter = 1 then
        begin
          if called_from_mortal_world then
          begin
            d(5, 'You see Altars of different deitys...');
          end else
          begin
            d(5, 'You examine your fellow Gods...');
          end;
          Inc(line_counter);
        end;

        sd(7, '[' + ugodc + god0.Name + ulgray + ']');

        {#believers}
        nr := god_believers(god0.Name, False);

        if nr = 0 then
        begin
          sd(8, '  (not worshipped)');
        end else
        if nr = 1 then
        begin
          sd(7, '  (' + commastr(nr) + ' believer)');
        end else
        begin
          sd(7, '  (' + commastr(nr) + ' believers)');
        end;

        crlf;
        Inc(line_counter);
        if line_counter > global_screenlines - 2 then
        begin
          line_counter := 0;
          if confirm('Continue', 'Y') = False then
          begin
            break;
          end;
        end;

      end;
    end;

  end; {for i:= .end.}

end;   {list_altars *end*}

procedure Inform_Disciples(const god1: godrec; const header: s40; const lin1, lin2, lin3, lin4: s100);
{Sends report to all discples of god GOD1}
var
  i:   word;

  pl0: ^UserRec;

begin

  {init}
  new(pl0);

  {send message to ALL human players in team TEAM}
  for i := 1 to fs(FsPlayer) do
  begin;

    {load character}
    if load_character(pl0^, 1, i) = True then
    begin

      if (pl0^.god = god1.Name) and
        (player_active(pl0^, False) = True) then
      begin

        {mail disciple}
        post(MailSend,
          pl0^.name2,
          pl0^.ai,
          False,
          mailrequest_Nothing,
          '',
          umailheadc + header + config.textcol1,
          mkstring(length(header), underscore),
          lin1,
          lin2,
          lin3,
          lin4,
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

       {dispose pointer vars}
  dispose(pl0);

end; {Team_Report_All *end*}


end. {Unit Vargods .end.}
