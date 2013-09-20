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


unit StatusC; {Usurper - Status of Player}

interface

uses
  Init;

procedure Status(var player0: UserRec);

{this routine displays a characters status and inventory (in the non
 classic mode). It is also used when viewing team-mates or other players.

 if player0.name2=player.name2 then this routine acts like it is the player
 watching himself}

implementation

uses
  DDplus, Cms, Jakob, invent,
  spellsu, various, various2,
  various3, online, file_io;

const nada        = '{nothing}';
  never_quit_loop = False;
var

  justval:     integer;
  force:       boolean;

  objekt:      ^orec;

  inarm:       armrec;
  inweap:      weaprec;

  scrap_entry: s70;

  {array containing items...only text: names of items.}
  itemstr:     array[1..global_maxallows, 1..2] of ^s70;

function ItemCol(const s: s70): byte;
begin

  if s = nada then itemcol := 8
  else itemcol := global_itemcol;

end; {itemcol *end*}

procedure disposal; {remove pointer variables}
var i: byte;
begin
  dispose(objekt);
  for i := 1 to global_maxallows do
  begin
    dispose(itemstr[i, 1]);
    dispose(itemstr[i, 2]);
  end; {for i:= .end.}
end;

procedure Load_Items(const player0: userrec);
var x: byte;
begin        {load info of the players used items}
  x := 0;

  if config.allowitem[15] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Left Hand  : ';

    if player0.lhand > 0 then
    begin
      load_objekt(objekt^, weapon, player0.lhand);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);
    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[2] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Head : ';

    if player0.head > 0 then
    begin
      load_objekt(objekt^, head, player0.head);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[12] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Face : ';

    if player0.face > 0 then
    begin
      load_objekt(objekt^, face, player0.face);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[10] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Neck : ';

    if player0.neck > 0 then
    begin
      load_objekt(objekt^, neck, player0.neck);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[11] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Neck : ';

    if player0.neck2 > 0 then
    begin
      load_objekt(objekt^, neck, player0.neck2);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[4] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Arms : ';

    if player0.arms > 0 then
    begin
      load_objekt(objekt^, arms, player0.arms);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[3] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Body : ';

    if player0.body > 0 then
    begin
      load_objekt(objekt^, body, player0.body);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[6] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Right Finger : ';

    if player0.rfinger > 0 then
    begin
      load_objekt(objekt^, fingers, player0.rfinger);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[5] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Left Finger : ';

    if player0.lfinger > 0 then
    begin
      load_objekt(objekt^, fingers, player0.lfinger);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[14] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Around Body : ';

    if player0.abody > 0 then
    begin
      load_objekt(objekt^, abody, player0.abody);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[7] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Legs : ';

    if player0.legs > 0 then
    begin
      load_objekt(objekt^, legs, player0.legs);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[8] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Feet : ';

    if player0.feet > 0 then
    begin
      load_objekt(objekt^, feet, player0.feet);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[1] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Hands : ';

    if player0.hands > 0 then
    begin
      load_objekt(objekt^, hands, player0.hands);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[9] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Waist : ';

    if player0.waist > 0 then
    begin
      load_objekt(objekt^, waist, player0.waist);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

  if config.allowitem[13] = True then
  begin
    Inc(x);
    itemstr[x, 1]^ := 'Shield : ';

    if player0.shield > 0 then
    begin
      load_objekt(objekt^, shield, player0.shield);
      itemstr[x, 2]^ := objekt^.Name + ' ' + item_power_display(objekt^);

    end else
    begin
      itemstr[x, 2]^ := nada;
    end;
  end;

end; {load_items *end*}

procedure Display_Menu(const player0: Userrec; force, short: boolean);
var x: longint;
  s:   s70;
begin

  if short = True then
  begin
    if player.expert = False then
    begin
      crlf;
      if config.classic then
      begin
        sd(config.textcolor, 'Status (M,H,T,S,C,L,?) :');
      end else
      begin
        sd(config.textcolor, 'Status (M,H,T,S,I,C,L,?) :');
      end;
    end else
    begin
      crlf;
      if config.classic then
      begin
        sd(config.textcolor, 'Status (M,H,S,C,L,?,[Enter] to exit) :');
      end else
      begin
        sd(config.textcolor, 'Status (M,H,S,I,C,L,?,[Enter] to exit) :');
      end;
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin

      if config.classic then
      begin
        clearscreen;

        if (player0.name1 = player.name1) and
          (player0.name2 = player.name2) then
        begin
          sd(5, 'Your status, ' + player0.name2);


          if player0.king = True then
          begin
            if player0.sex = 1 then sd(14, ' (THE KING)')
            else sd(14, ' (THE QUEEN)');
          end;

          x := level_raise(player0.level, player0.exp);
          if x = 0 then
          begin
            d(10, ' ' + global_levelraise);
          end else if player0.trains > 0 then
          begin
            d(10, ' (you should train some moves!)');
          end else
          begin
            crlf;
          end;

        end else
        begin
          d(5, player0.name2 + ' Status,');
        end;
        crlf;
        justval := 30;
        sd(config.textcolor, ljust('Race       : ' + race_display(1, player0.race, 0), justval));
        sd(config.textcolor, 'Weapon     : ');
        if player0.weapon = 0 then
        begin
          sd(itemcol(nada), 'bare hands');
        end else
        begin
          load_weapon(player0.weapon, inweap);
          sd(itemcol(inweap.Name), inweap.Name);
        end;
        crlf;
        sd(config.textcolor, ljust('Class      : ' + classnames[player0.class], justval));
        sd(config.textcolor, 'Armor      : ');
        if player0.armor = 0 then
        begin
          sd(itemcol(nada), 'skin');
        end else
        begin
          load_armor(player0.armor, inarm);
          sd(itemcol(inarm.Name), inarm.Name);
        end;
        crlf;

        sd(config.textcolor, ljust('Level      : ' + commastr(player0.level), justval));
        d(config.textcolor, ljust('Age        : ' + commastr(player0.age) + ' years', justval));

        s := ljust(config.moneytype, 11);
        sd(config.textcolor, ljust(s + ': ' + commastr(player0.gold), justval));
        d(config.textcolor, ljust('Bank Funds : ' + commastr(player0.bankgold), justval));

        sd(config.textcolor, ljust('Healings   : ' + commastr(player0.healing), justval));
        d(config.textcolor, ljust('Experience : ' + commastr(player0.exp), justval));

        sd(10, ljust('Hitpoints  : ' + commastr(player0.hps) + '/' + commastr(player0.maxhps), justval));
        d(config.textcolor, ljust('Strength   : ' + commastr(player0.strength), justval));

        sd(config.textcolor, ljust('Defence    : ' + commastr(player0.defence), justval));
        sd(config.textcolor, 'Team       : ');

        if player0.team = '' then
        begin
          d(12, '<not in a team>');
        end else
        begin
          d(config.textcolor, utec + player0.team + config.textcol1);
        end;

        sd(config.textcolor, ljust('WeaponPower: ' + commastr(player0.wpow * 11), justval));
        d(config.textcolor, ljust('ArmorPower : ' + commastr(player0.apow * 11), justval));

        sd(config.textcolor, ljust('Trainings  : ' + commastr(player0.trains), justval));
        if player0.class in [Cleric, Sage, Magician] then
        begin
          d(config.textcolor, ljust('Mana       : ' + commastr(player0.mana) + '/' + commastr(player0.maxmana), justval));
        end else
        begin
          crlf;
        end;

        sd(config.textcolor, ljust('Pick-Pocket: ' + commastr(player0.PickPocketAttempts), justval));
        crlf;

        crlf;
        if (player0.name1 = player.name1) and
          (player0.name2 = player.name2) then
        begin

          sd(config.textcolor, '(');

          sd(config.hotkeycolor, 'M');
          sd(config.textcolor, ')ore  (');

          sd(config.hotkeycolor, 'C');
          sd(config.textcolor, ')onfig  (');

          sd(config.hotkeycolor, 'S');
          sd(config.textcolor, ')kills  (');

          sd(config.hotkeycolor, 'H');
          sd(config.textcolor, ')ealing  (');

          sd(config.hotkeycolor, 'T');
          sd(config.textcolor, ')eam  (');

          sd(config.hotkeycolor, 'L');
          sd(config.textcolor, ')evel ');

          if player0.class in [Cleric, Magician, Sage] then
          begin
            menu2('(E) Spells');
          end;

    {sd(config.textcolor,'(');
    sd(config.hotkeycolor,'Enter');
    sd(config.textcolor,')');}
        end;
      end else
      begin

        {NEW mode displayen starts here}

        {load items}
        load_items(player0);

        clearscreen;

        if (player0.name1 = player.name1) and
          (player0.name2 = player.name2) then
        begin

          sd(5, 'Your status, ' + player0.name2);

          {King?}
          if player0.king then
          begin
            if player0.sex = 1 then sd(14, ' (THE KING)')
            else sd(14, ' (THE QUEEN)');
          end;

          {eligble for a level raise?}
          x := level_raise(player0.level, player0.exp);
          if x = 0 then
          begin
            d(10, ' (you are eligible for a level raise!)');
          end else if player0.trains > 0 then
          begin
            d(10, ' (you should train some moves!)');
          end else
          begin
            crlf;
          end;

        end else
        begin
          {other character is being viewed}
          d(5, player0.name2 + ' Status,');
        end;

        {race}
        crlf;
        justval := 30;
        sd(config.textcolor, ljust('Race       : ' + race_display(1, player0.race, 0), justval));

        {right hand}
        sd(config.textcolor, 'Weapon : ');
        if player0.rhand > 0 then
        begin
          load_objekt(objekt^, weapon, player0.rhand);
          sd(itemcol(objekt^.Name), objekt^.Name);
          {power}
          sd(config.textcolor, ' ' + item_power_display(objekt^));
        end else
        begin
          sd(itemcol(nada), nada);
        end;

        {class}
        crlf;
        sd(config.textcolor, ljust('Class      : ' + classnames[player0.class], justval));

        {left hand}
        sd(config.textcolor, itemstr[1, 1]^);
        d(itemcol(itemstr[1, 2]^), itemstr[1, 2]^);
        sd(config.textcolor, ljust('Level      : ' + commastr(player0.level), justval));

        {head}
        sd(config.textcolor, itemstr[2, 1]^);
        d(itemcol(itemstr[2, 2]^), itemstr[2, 2]^);
        sd(config.textcolor, ljust('Age        : ' + commastr(player0.age) + ' years', justval));

        {face}
        sd(config.textcolor, itemstr[3, 1]^);
        d(itemcol(itemstr[3, 2]^), itemstr[3, 2]^);

        s := ljust(config.moneytype, 11);
        sd(config.textcolor, ljust(s + ': ' + commastr(player0.gold), justval));

        {neck}
        sd(config.textcolor, itemstr[4, 1]^);
        d(itemcol(itemstr[4, 2]^), itemstr[4, 2]^);

        sd(config.textcolor, ljust('Bank Funds : ' + commastr(player0.bankgold), justval));

        {neck2}
        sd(config.textcolor, itemstr[5, 1]^);
        d(itemcol(itemstr[5, 2]^), itemstr[5, 2]^);
        sd(config.textcolor, ljust('Healings   : ' + commastr(player0.healing), justval));

        {arms}
        sd(config.textcolor, itemstr[6, 1]^);
        d(itemcol(itemstr[6, 2]^), itemstr[6, 2]^);
        sd(config.textcolor, ljust('Experience : ' + commastr(player0.exp), justval));

        {body}
        sd(config.textcolor, itemstr[7, 1]^);
        d(itemcol(itemstr[7, 2]^), itemstr[7, 2]^);
        sd(10, ljust('Hitpoints  : ' + commastr(player0.hps) + '/' + commastr(player0.maxhps), justval));

        {right finger}
        sd(config.textcolor, itemstr[8, 1]^);
        d(itemcol(itemstr[8, 2]^), itemstr[8, 2]^);
        sd(config.textcolor, ljust('Strength   : ' + commastr(player0.strength), justval));

        {left finger}
        sd(config.textcolor, itemstr[9, 1]^);
        d(itemcol(itemstr[9, 2]^), itemstr[9, 2]^);
        sd(config.textcolor, ljust('Defence    : ' + commastr(player0.defence), justval));

        {around body}
        sd(config.textcolor, itemstr[10, 1]^);
        d(itemcol(itemstr[10, 2]^), itemstr[10, 2]^);

        s := player0.team;
        if length(s) > 17 then
        begin
          s := copy(s, 1, 17);
        end else if length(s) < 17 then
        begin
          x := 17 - length(s);
          s := s + mkstring(x, ' ');
        end;

        sd(config.textcolor, 'Team       : ');
        sd(global_teamcol, s);

        {legs}
        sd(config.textcolor, itemstr[11, 1]^);
        d(itemcol(itemstr[11, 2]^), itemstr[11, 2]^);
        sd(config.textcolor, ljust('WeaponPower: ' + commastr(player0.weappow), justval));

        {feet}
        sd(config.textcolor, itemstr[12, 1]^);
        d(itemcol(itemstr[12, 2]^), itemstr[12, 2]^);
        sd(config.textcolor, ljust('ArmorPower : ' + commastr(player0.armpow), justval));

        {hands}
        sd(config.textcolor, itemstr[13, 1]^);
        d(itemcol(itemstr[13, 2]^), itemstr[13, 2]^);
        sd(config.textcolor, ljust('Trainings  : ' + commastr(player0.trains), justval));

        {waist}
        sd(config.textcolor, itemstr[14, 1]^);
        d(itemcol(itemstr[14, 2]^), itemstr[14, 2]^);

        if player0.class in [Cleric, Sage, Magician] then
        begin
          sd(config.textcolor, ljust('Mana       : ' + commastr(player0.mana) + '/' + commastr(player0.maxmana), justval));
        end else
        begin
          sd(config.textcolor, ljust('             ' + '      ', justval));
        end;

        {shield}
        sd(config.textcolor, itemstr[15, 1]^);
        d(itemcol(itemstr[15, 2]^), itemstr[15, 2]^);
        sd(config.textcolor, ljust('Pick-Pocket: ' + commastr(player0.PickPocketAttempts), justval));

        crlf;
        crlf;

        if (player0.name1 = player.name1) and
          (player0.name2 = player.name2) then
        begin
          sd(config.textcolor, '(');

          sd(config.hotkeycolor, 'M');
          sd(config.textcolor, ')ore  (');

          sd(config.hotkeycolor, 'I');
          sd(config.textcolor, ')nventory  (');

          sd(config.hotkeycolor, 'C');
          sd(config.textcolor, ')onfig  (');

          sd(config.hotkeycolor, 'S');
          sd(config.textcolor, ')kills  (');

          sd(config.hotkeycolor, 'H');
          sd(config.textcolor, ')ealing  (');

          sd(config.hotkeycolor, 'T');
          sd(config.textcolor, ')eam  (');

          sd(config.hotkeycolor, 'L');
          sd(config.textcolor, ')evel ');

          if player0.class in [Cleric, Magician, Sage] then
          begin
            menu('(E) Spells');
          end;

     {sd(config.textcolor,'(');
     sd(config.hotkeycolor,'Enter');
     sd(config.textcolor,')');}
        end;

      end;
    end;
  end;

end; {display_menu *end*}

procedure Status;
var

  tempin, s, a, a2: s70;

  ch:      char;

  i, y, x: longint;

  infect:  boolean;

begin

  {init pointer variables}
  new(objekt);
  for i := 1 to global_maxallows do
  begin
    new(itemstr[i, 1]);
    new(itemstr[i, 2]);
    itemstr[i, 1]^ := '';
    itemstr[i, 2]^ := '';
  end; {for i:= .end.}

  {game registration check}
  muffis;

  for i := 1 to global_maxallows do
  begin
    itemstr[i, 1]^ := emptystr;
    itemstr[i, 2]^ := emptystr;
  end;


  if not config.Classic then
  begin
    {Loading items so they can be displayed in STATUS screen}
    load_items(player0);
  end;

  if player0.name2 <> player.name2 then
  begin
    display_menu(player0, True, False);
    crlf;
    pause;
    disposal;
    exit;
  end;

  display_menu(player0, False, False);

  repeat

    {display menu}
    display_menu(player0, True, True);

    repeat

      {get user-input}
      ch := upcase(getchar);

      {evaluate user-input}
      if (ch = 'I') and (config.classic = True) then
      begin
        ch := '-';
      end else if (ch = 'E') then
      begin
        ch := '-';
        if (player0.class in [Cleric, Magician, Sage]) then
        begin
          ch := 'E';
        end;
      end;

    until ch in [ReturnKey, 'Q', 'M', 'I', 'T', 'H', 'L', 'C', 'S', '?', 'E'];

    {evaluate user-input}
    case ch of
      ReturnKey: begin
        disposal;
        exit;
      end;
      'Q': begin
        disposal;
        exit;
      end;
      'E': begin {spells}
        crlf;
        spell_list(player0);
      end;
      '?': begin {expert menues}
        if player.expert = True then display_menu(player0, True, False)
        else display_menu(player0, False, False);
      end;

      'T': begin {team}
        if player.team <> '' then
        begin

          display_member(player, True);

          display_members(player.team, False);

          crlf;
        end else
        begin
          crlf;
          crlf;
          d(5, 'You don''t belong to a team.');
        end;
      end;
      'L': begin {xp left to level raise info *start*}
        clearscreen;
        crlf;
        d(11, 'Level Info');
       {sd(config.textcolor,', you are level ');
       sd(15,commastr(player0.level));
       d(config.textcolor,' character');}
        d(10, mkstring(10, underscore));
        x := level_raise(player0.level, player0.exp);

        d(config.textcolor, 'You are a level ' + uyellow + commastr(player0.level) + config.textcol1 + ' ' + race_display(2, player0.race, 0) + '.');
        if x <> 0 then
        begin
          sd(config.textcolor, 'You need ');
          sd(15, commastr(x));
          d(config.textcolor, ' experience points to advance a level.');
        end else
        begin
          d(15, 'You have enough points to make a level!');
        end;
        crlf;
        pause;

      end; {xp left to level raise info *end*}

      'H': begin {healing}
        repeat

          clearscreen;
          crlf;
          crlf;

          sd(3, 'Hitpoints : ');
          sd(5, commastr(player0.hps));
          sd(3, '/');
          d(5, commastr(player0.maxhps));

          if player0.hps < player0.maxhps then
          begin
            d(12, 'You NEED healing.');
          end else
          begin
            d(12, 'You don''t need healing.');
          end;

          infect := False;
          if (player0.blind) or (player0.plague) or (player0.smallpox) or
            (player0.measles) or (player0.leprosy) then
          begin
            d(12, 'You have a disease!');
            infect := True;
          end;

          menu2('(Q)uick heal ');
          menu2('(H)eal ');

          if infect then
          begin
            menu2('(D)iseases');
          end;
          d(config.textcolor, ' or [' + Config.ReturnEnter + ']');

          sd(config.textcolor, ':');

          {get user-input}
          repeat
            ch := upcase(getchar);
          until ch in ['Q', 'H', 'D', ReturnKey];

          case ch of
            'Q': begin
              quick_healing(player0);
              pause;
            end;
            'H': begin
              healing(player0);
              pause;
            end;
            'D': begin
              crlf;
              d(5, 'Affecting Diseases:');
              d(5, '=-=-=-=-=-=-=-=-=-=');
              if player0.blind then d(4, '*Blindness*');
              if player0.plague then d(4, '*Plague*');
              if player0.smallpox then d(4, '*Smallpox*');
              if player0.measles then d(4, '*Measles*');
              if player0.leprosy then d(4, '*Leprosy*');

              if (player0.blind = False) and (player0.plague = False) and
                (player0.smallpox = False) and (player0.measles = False) and
                (player0.leprosy = False) then
              begin
                crlf;
                d(14, 'You are not infected!');
                d(14, 'Stay healthy!');
              end;
              crlf;
              crlf;
              pause;
            end;

          end; {case .end.}

        until ch = ReturnKey;
        ch := ' ';
      end;

      'S': begin
        clearscreen;
        crlf;
        d(15, 'Your Close-Combat Skills :');
        d(5, '+-+-+-+-+-+-+-+-+-+-+-+-+-');
        crlf;

        for i := 1 to global_maxcombat do
        begin
          sd(global_bashcol, ljust(bash_name(i), 15));

          y := 11;
          case player0.skill[i] of
            0..2: y := 11;
            3..8: y := 3;
            9..14: y := 12;
            15..16: y := 14;
            17: y := 15;
          end; {case .end.}

          d(y, '- ' + bash_rank(player0.skill[i]));
        end;
        crlf;
        if player.trains > 0 then
        begin
          d(15, 'You should seek your training master right now!');
          d(15, 'You are able to improve your skills!');
        end;
        pause;
      end;

      'C': begin
        repeat

          repeat
            clearscreen;
            d(15, 'Your Setup & Off-line Behaviour :');
            d(5, '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+');

            if (player.expert = False) or (force = True) then
            begin

              force := False;
              clearscreen;
              d(15, 'Your Setup & Off-line Behaviour :');
              d(5, '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+');

              menu2('(0) Ansi Graphics is currently : ');

              if global_ansi then sd(15, 'On')
              else sd(15, 'Off');
              crlf;

              menu2('(1) Buy new healing potions when needed : ');

              if player0.autoheal = True then sd(15, 'Yes')
              else sd(15, 'No');
              crlf;

              menu('(2) Phrase when you are being attacked :');
              d(global_talkcol, '     ' + player0.phr[1]);

              menu('(3) Phrase when you have defeated an opponent :');
              d(global_talkcol, '     ' + player0.phr[2]);

              menu('(4) Phrase when you have been defeated :');
              d(global_talkcol, '     ' + player0.phr[3]);

              menu('(5) Phrase when you are begging for mercy :');
              d(global_talkcol, '     ' + player0.phr[4]);

              menu('(6) Character Description');
              menu('(7) Battlecry :');
              d(global_talkcol, '     ' + player0.battlecry);

              menu('(8) Phrase when you spare your opponent :');
              d(global_talkcol, '     ' + player0.phr[5]);

              menu('(9) Phrase when you don''t spare your opponent :');
              d(global_talkcol, '     ' + player0.phr[6]);
              {phrases end}

              menu2('(A) Expert Menus : ');
              if player0.expert = True then d(15, 'On')
              else d(15, 'Off');
              menu2('(B) Online Ear   : ');
              case player0.ear of
                global_ear_all: d(11, '*All* (all information available)');
                global_ear_personal: d(11, '*Personal* (only personal information)');
                global_ear_quiet: d(11, '*Quiet* (no information)');
              end; {case .end.}

              {auto display menus}
              menu2('(C) Auto-Display menus   : ');
              if player0.auto_meny then d(15, 'Yes')
              else d(15, 'No');

              {auto hate}
              menu2('(D) Auto Hate : ');
              if player0.autohate = 0 then sd(15, 'Off')
              else sd(15, 'On');

            end;

            {player has expert menues activated}
            if player.expert = True then
            begin
              crlf;
              sd(config.textcolor, '(0..9,A..D,?, [' + config.ReturnEnter + '] to continue) :');
            end else
            begin
              crlf;
              sd(config.textcolor, '(');
              sd(config.hotkeycolor, config.ReturnEnter);
              sd(config.textcolor, '), ? :');
            end;

            {get user-input}
            ch := upcase(getchar);

          until ch in [ReturnKey, '1', '2', '3', '4', '5', '6', '7', '8', '0', '9',
              'A', 'B', 'C', 'D', '?'];

          for i := 1 to 6 do
          begin
            if player0.phr[i] = '' then player0.phr[i] := emptystr;
          end;

          {evaluate user-input}
          case ch of
            ReturnKey: break;

            '?': begin {display config menu}
              if player.expert = True then
              begin
                force := True;
              end;
            end;
            '0': begin {ansi}

              if global_ansi then
              begin
                global_ansi := False;
                Graphics := 2; {ddplus var}
              end else
              begin
                global_ansi := True;
                Graphics := 3; {ddplus var}
              end;

            end;
            '1': begin {autoheal}
              if player0.autoheal = True then player0.autoheal := False
              else player0.autoheal := True;
            end;
            '2': begin {attack phrase}

              crlf;
              d(config.textcolor, 'What shall you say when you are being attacked ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[1] := a2;
              end;

            end;
            '3': begin

              crlf;
              d(config.textcolor, 'What shall you say when you have defeated somebody ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              crlf;
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[2] := a2;
              end;

            end;
            '4': begin
              crlf;
              d(config.textcolor, 'What shall you say when you have been defeated ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[3] := a2;
              end;
            end;
            '5': begin
              crlf;
              d(config.textcolor, 'What shall you say when you are begging for mercy ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              crlf;
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[4] := a2;
              end;
            end;
            '6': begin
              clearscreen;
              d(config.textcolor, 'Description :');

              for i := 1 to 4 do
              begin
                d(10, '[' + commastr(i) + '] ' + player0.desc[i]);
              end;

              crlf;
              if confirm('Would You like to change this', 'Y') = True then
              begin
                d(config.textcolor, 'Enter your description below, Max 4 lines');
                x := 1;
                scrap_entry := emptystr;
                repeat
                  sd(config.textcolor, '[' + commastr(x) + ']:');
                  a2 := get_string(70);
                  player0.desc[x] := a2;
                  if player0.desc[x] <> '' then x := x + 1
                  else player0.desc[x] := emptystr;

                until (a2 = '') or (x > 4);

              end;
            end;
            '7': begin
              crlf;
              d(config.textcolor, 'What shall your general Battlecry be ?');
              d(config.textcolor, 'This is displayed when you are fighting with your team,');
              d(config.textcolor, 'in the Dungeons and in Team fights.');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              crlf;
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.battlecry := a2;
              end;
              if player0.battlecry = '' then player0.battlecry := emptystr;
            end;
            '8': begin
              crlf;
              d(config.textcolor, 'What shall you say when you spare your opponents life ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[5] := a2;
              end;

            end;
            '9': begin
              crlf;
              d(config.textcolor, 'What shall you say when you don''t spare your opponents life ?');
              d(config.textcolor, 'Enter phrase (1 line)');
              sd(config.textcolor, ':');
              a2 := get_string(70);
              d(global_talkcol, a2);
              if confirm('Is this alright', 'Y') = True then
              begin
                player0.phr[6] := a2;
              end;
            end;
            'A': begin {expert on/off}
              if player0.expert = True then player0.expert := False
              else player0.expert := True;
            end;
            'B': begin
              crlf;
              d(15, 'Set "Outside" MODE variable :');
              d(15, '(A)ll information available.');
              d(15, '   All vital information about other players');
              d(15, '   will be displayed.');
              crlf;

              d(15, '(P)ersonal information only.');
              d(15, '   You will only get information concerning');
              d(15, '   yourself.');
              crlf;
              d(15, '(Q)uiet mode. No information about other');
              d(15, '   players will be displayed. You will refuse');
              d(15, '   to accept any messages or challenges.');
              sd(15, ':');

              {get user-input}
              repeat
                ch := upcase(getchar);
              until ch in ['A', 'P', 'Q'];

              {evaluate user-input}
              case ch of
                'A': player0.ear := global_ear_all;
                'P': player0.ear := global_ear_personal;
                'Q': player0.ear := global_ear_quiet;
              end; {case .end.}

              onliner.ear := player0.ear;
              add_onliner(OUpdateAll, onliner);
            end;

            'C': begin {auto display menus}
              if player0.auto_meny then
              begin
                player0.auto_meny := False;
                d(15, 'Auto-Display menus is OFF.');
              end else
              begin
                player0.auto_meny := True;
                d(15, 'Auto-Display menus is ON.');
              end;
            end;
            'D': begin {auto hate, deteriorate relations when attacked offline}
              if player0.autohate = 1 then
              begin
                player0.autohate := 0;
                d(15, 'Auto-Hate is OFF.');
                d(config.textcolor, 'When you are attacked off-line, your relation with');
                d(config.textcolor, 'the attacking player will not be affected.');
                pause;
              end else
              begin
                player0.autohate := 1;
                d(15, 'Auto-Hate is ON.');
                d(config.textcolor, 'When you are attacked off-line, your relation with');
                d(config.textcolor, 'the attacking player will ' + ulred + 'deteriorate' + config.textcol1 + '.');
                pause;
              end;
            end;
          end; {case .end.}

          if player.expert then
          begin
            pause;
          end;

        until ch = ReturnKey;

      end;

      'I': begin {Inventory display}

        repeat

          {display current inventory}
          inventory_display(player);

          {menu}
          if (player0.expert = False) or (ch = '?') then
          begin

            menu2('(E)xamine item ');
            menu2('(D)rop ');
            menu2('(U)se ');
            menu2('(S)top using ');
            menu2('(*) Drop All ');

            sd(config.textcolor, '[');
            sd(config.hotkeycolor, config.returnenter);
            sd(config.textcolor, '] to Continue :');
          end else
          begin
            sd(config.textcolor, 'Inventory (E,D,U,S,*,?) :');
          end;

          {get user-input}
          repeat
            ch := upcase(getchar);
          until ch in [ReturnKey, 'D', 'U', 'E', 'S', '*', '?'];

          {evaluate user-input}
          case ch of
            ReturnKey: begin {continue}
              tempin := 'fasa';
            end;

            '*': begin {drop everything}
              crlf;
              crlf;
              if confirm('Drop everything in Your inventory', 'N') = True then
              begin

                for i := 1 to global_maxitem do
                begin

                  if player.item[i] > 0 then
                  begin
                    load_objekt(objekt^, player0.itemtype[i], player.item[i]);
                    if objekt^.cursed = False then
                    begin
                      sd(config.textcolor, 'You drop ');
                      d(global_itemcol, objekt^.Name);
                      player.item[i] := 0;
                    end else
                    begin
                      sd(config.textcolor, 'You can''t drop the ');
                      sd(global_itemcol, objekt^.Name);
                      d(config.textcolor, '! It seems to be cursed!');
                    end;
                  end;

                end; {for i:= .end.}

                crlf;
                pause;
              end;
              inventory_sort(player);
            end;

            'S': begin {stop using item}
              remove_item;
            end;

            'E': begin {examine item}
              repeat
                crlf;
                i := item_select(player);
                if i > 0 then
                begin
                  load_objekt(objekt^, player0.itemtype[i], player0.item[i]);
                  crlf;
                  sd(config.textcolor, 'You examine the ');
                  sd(global_itemcol, objekt^.Name);
                  d(config.textcolor, ' ...');
                  crlf;
                  for i := 1 to 5 do
                  begin
                    if objekt^.desc1[i] <> '' then
                    begin
                      d(config.textcolor, ' ' + objekt^.desc1[i]);
                    end;
                  end; {for i:= .end.}
                  crlf;
                  pause;
                end;
              until i = 0;
            end;

            'U': begin {use item}
              use_item(0);
              crlf;
            end;

            'D': begin {drop specific item}
              drop_item(player);
            end;

          end; {case .end.}

        until tempin = 'fasa';

      end;

      'M': begin {more status...}

        clearscreen;
        crlf;
        crlf;

        sd(config.textcolor, ljust('Wisdom     : ' + commastr(player0.wisdom), justval));
        sd(config.textcolor, ljust('Darkness   : ' + commastr(player0.dark), justval));
        crlf;

        sd(config.textcolor, ljust('Charisma   : ' + commastr(player0.charisma), justval));
        sd(config.textcolor, ljust('Dungeon fights     : ' + commastr(player0.fights), justval));
        crlf;

        sd(config.textcolor, ljust('Agility    : ' + commastr(player0.agility), justval));
        sd(config.textcolor, ljust('Teamfights : ' + commastr(player0.tfights), justval));
        crlf;

        sd(config.textcolor, ljust('Dexterity  : ' + commastr(player0.dex), justval));
        sd(config.textcolor, ljust('Player fights     : ' + commastr(player0.pfights), justval));

        crlf;
        sd(config.textcolor, ljust('Stamina    : ' + commastr(player0.stamina), justval));
        sd(config.textcolor, ljust('Chivalry   : ' + commastr(player0.chiv), justval));

        crlf;

        crlf;
        sd(config.textcolor, 'Disease resistance  : ');
        sd(config.textcolor, immunity(player0.disres));
        crlf;

        sd(config.textcolor, 'Drug addiction      : ' + commastr(player0.addict) + ' %');
        crlf;
        d(config.textcolor, 'Mental stability    : ' + commastr(player0.mental) + ' %');

        crlf;

        sd(config.textcolor, 'Height : ');
        sd(config.textcolor, commastr(player0.Height));
        sd(config.textcolor, ' cm, Hair is ');
        sd(config.textcolor, color[player0.hair]);
        crlf;

        sd(config.textcolor, 'Weight : ');
        sd(config.textcolor, commastr(player0.weight));
        sd(config.textcolor, ' kilos, Eyes are ');
        sd(config.textcolor, color[player0.eyes]);
        crlf;

        sd(config.textcolor, 'Skin : ');
        sd(config.textcolor, color[player0.skin]);

        {Alchemist Poison}
        if player0.class = Alchemist then
        begin
          crlf;
          crlf;
          sd(config.textcolor, 'Active Poison : ');
          if player0.poison > 0 then
          begin

            a2 := alchemist_poison(player0);
            sd(15, a2);

          end else
          begin
            sd(15, 'None');
          end;
        end;

        crlf;
        crlf;
        sd(config.textcolor, 'Monster Kills : ');
        d(15, commastr(player.m_kills));

        sd(config.textcolor, '      Defeats : ');
        d(15, commastr(player.m_defeats));

        sd(config.textcolor, 'Player  Kills : ');
        d(15, commastr(player.p_kills));

        sd(config.textcolor, '      Defeats : ');
        d(15, commastr(player.p_defeats));

        sd(config.textcolor, '                 ..');
        sd(10, commastr(time_left));
        sd(config.textcolor, ' min left..');

        sd(config.textcolor, '  Resurrections left..');
        sd(10, commastr(player.resurrections));


        crlf;
        pause;
      end;

    end; {case .end.}

  until never_quit_loop;

end; {Status *end*}

end. {Unit StatusC .end.}
