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


unit WeapShop; {Usurper - Weapon Shop}

interface

procedure Weapon_Shop;

implementation

uses
  Init, Cms, Jakob,
  News, Statusc, Invent,
  Hagglec, Various, Various2,
  Online, File_Io;

const backpack = 'back-pack';
var
  s:       s70;
  tully:   ^s70;
  refresh: boolean;
  counter: integer;

procedure Meny;
begin
  clearscreen;

  {show_usurper_data('WEAPON_SHOP',true);
  }

  crlf;
  s := 'Weaponstore, run by ' + tully^ + ' the troll';

  d(5, s);
  d(5, mkstring(length(s), underscore));
  d(config.textcolor, 'You enter the dusty old weaponstore and notice that the shelves');
  d(config.textcolor, 'are filled with all kinds of different weapons. Yet you know that the');
  d(config.textcolor, 'real powerful items dwells somewhere deeper within this mysterious');
  d(config.textcolor, 'building.');
  crlf;
  d(config.textcolor, 'A fat troll stumbles out from a room nearby and greets you.');
  sd(config.textcolor, 'You realize that this dirty old swine must be ');
  sd(global_plycol, tully^);
  d(config.textcolor, ' the owner.');
  d(config.textcolor, 'After a brief inspection of his customer he asks what you want.');
  crlf;
  sd(config.textcolor, '(You have ');
  sd(14, commastr(player.gold));
  d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + ')');
  crlf;
  menu('(R)eturn to street');
  menu('(B)uy');
  menu('(T)he best weapon for your ' + config.moneytype);
  menu('(S)ell');
  menu('(L)ist items');

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
begin

  if short = True then
  begin
    if player.expert = False then
    begin
      if (refresh) and (player.auto_meny) then
      begin
        refresh := False;
        meny;
      end;

      crlf;
      sd(config.textcolor, 'Weapons (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Weapons (R,B,S,L,T,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Note_It(const spook: s70); {put Weapon Buy in the News}
begin

  {news-paper}
  newsy(True,
    'Weapon',
    ' ' + uplc + player.name2 + config.textcol1 + ' bought a ' + uitemc + spook + config.textcol1 + '.',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {note_it *end*}

procedure Weapon_Shop;
var

  exit_shop, restrict, go_ahead: boolean;

  rr:      ^real;

  komihag, cho, ch: char;

  y, zz, justval: integer;

  mincost, maxcost, cc, j, x, i, xx: longint;

  objekt:  ^orec;
  inweap:  ^weaprec;
  wweapon: weaprec;

  col, normcol, shadcol: byte;

begin {Weapon Shop}

  new(objekt);
  new(tully);
  new(inweap);
  new(rr);

  exit_shop := False;
  {fetching Tullys name from .CFG}
  tully^ := cfg_string(15);
  if tully^ = '' then
    tully^ := 'Tully';

  crlf;
  komihag := ' ';
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_weaponshop then
    begin
      refresh := True;
      onliner.location := onloc_weaponshop;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    if player.weaphag < 1 then
    begin
      crlf;
      d(15, 'The strong desk-clerks throw you out!');
      d(15, 'You realize that you went a little bit too far in');
      d(15, 'your attempts to get a good deal.');
      cho := 'R';

      Bad_News('W');

    end else
    if komihag = ' ' then
    begin
      display_menu(True, True);
      cho := upcase(getchar);
    end else
    begin
      cho := komihag;
      komihag := ' ';
    end;

    if (cho = 'L') and (config.classic) then
    begin
      crlf;
      d(5, 'Ancient Weapons            Price');
      cc := 1;
      justval := 14;

      for i := 1 to fs(FsWeaponClassic) do
      begin
        load_weapon(i, wweapon);

        {#}
        sd(3, ljust(commastr(i), 4));

        {name}
        s := wweapon.Name + config.textcol1;
        repeat
          s := s + '.';
        until length(s) > 20;
        sd(global_itemcol, s);

        {price}
        s := uyellow + commastr(wweapon.Value);
        repeat
          s := '.' + s;
        until length(s) >= 13;

        sd(config.textcolor, rjust(s, 13));

        crlf;
        Inc(cc);
        if cc > global_screenlines - 2 then
        begin
          cc := 0;
          if confirm('Continue', 'Y') = False then
          begin
            break;
          end;
        end;
      end;
    end;

    if (cho = 'L') and (not config.classic) then
    begin
      crlf;
      mincost := 0;
      sd(config.textcolor, 'Min Cost :');

      x := get_number(0, global_maxinput);
      if (x > 0) and (x < 2000000000) then
      begin
        mincost := x;
      end;

      maxcost := 2000000000;
      sd(config.textcolor, 'Max Cost :');

      x := get_number(0, global_maxinput);
      if (x > 0) and (x >= mincost) and (x <= 2000000000) then
      begin
        maxcost := x;
      end;

      clearscreen;
      j := 0;
      cc := 3;
      justval := 14;

      sd(5, ljust('#', 4));
      sd(5, ljust('Item', 13));
      d(5, rjust('Cost', 15));
      crlf;

      for i := 1 to fsob(Weapon) do
      begin
        load_objekt(objekt^, weapon, i);
        if objekt^.shop = True then
        begin
          Inc(j);
          if (objekt^.Value >= mincost) and (objekt^.Value <= maxcost) then
          begin
            Inc(cc);

            restrict := False;
            if class_restricted(player.class, objekt^, 0) = True then
            begin
              restrict := True;
            end;

            normcol := 3;
            shadcol := 8;

            if restrict then
              col := shadcol
            else col := normcol;

            {#}
            sd(col, ljust(commastr(j), 4));

            {name}
            s := objekt^.Name;
            while length(s) < 24 do
            begin
              s := s + '.';
            end;
            normcol := 15;
            if restrict then
              col := shadcol
            else col := normcol;

            sd(col, s);

            {price}
            normcol := 14;
            if restrict then
              col := shadcol
            else col := normcol;

            s := commastr(objekt^.Value);
            sd(col, s);

            {restrictions}
            if class_restricted(player.class, objekt^, 0) = True then
            begin
              d(shadcol, ' *class restricted*');
            end else
            begin
              crlf;
            end;

            {menu}
            if cc > global_screenlines - 2 then
            begin
              cc := 1;
              crlf;
              menu2('[C]ontinue  ');
              menu2('(A)bort  ');
              menu2('(B)uy item :');

              repeat
                ch := upcase(getchar);
              until ch in ['C', 'A', 'B', ReturnKey];

              if ch = ReturnKey then
              begin
                ch := 'C';
              end;

              case ch of
                'C': begin
                  sd(config.textcolor, ' More');
                end;
                'A': begin
                  sd(config.textcolor, ' Abort');
                  break;
                end;
                'B': begin
                  sd(config.textcolor, ' Buy item');
                  cho := 'B';
                  break;
                end;
              end; {case .end.}

              crlf;
            end;
          end;
        end;
      end;
      crlf;
    end;

    case cho of
      '?': begin
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin
        if config.classic then
        begin
          crlf;
          if player.weapon = 0 then
          begin
            d(global_talkcol, 'Sell what?');
          end else
          begin
            load_weapon(player.weapon, inweap^);
            xx := inweap^.Value div 2;
            d(config.textcolor, 'The troll declares that he will pay you ');
            sd(14, commastr(xx));
            sd(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + ' for your ');
            d(global_itemcol, inweap^.Name);

            if confirm('Will you sell it ', 'N') = True then
            begin
              d(config.textcolor, 'You give the troll your weapon, and receive the ' + config.moneytype + '.');
              incplayermoney(player, xx);
              player.weapon := 0;
              player.wpow := 0;
              if player.poison > 0 then
              begin
                d(config.textcolor, 'You feel a bit sad, now when your poisoned weapon is gone.');
                pause;
              end;
              player.poison := 0;
              pause;
            end;
          end;
        end else
        begin
          crlf;
          crlf;
          if confirm('Sell ALL weapon in your inventory', 'N') = True then
          begin
            counter := 0;
            for i := 1 to global_maxitem do
            begin
              if player.item[i] > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);
                if objekt^.ttype in [Weapon] then
                begin
                  if objekt^.Value > 1 then
                  begin
                    xx := objekt^.Value div 2;
                  end else
                  begin
                    xx := objekt^.Value;
                  end;
                  {time to sell}
                  if xx <= 0 then
                  begin
                    sd(global_itemcol, objekt^.Name);
                    sd(config.textcolor, ' is worthless!, ' + tully^ + ' says.');
                  end else
                  if objekt^.cursed = True then
                  begin
                    sd(global_itemcol, objekt^.Name);
                    d(config.textcolor, ' is cursed!');
                    sd(global_talkcol, 'I don''t buy cursed items!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, tully^);
                    d(config.textcolor, ' says.');
                  end else
                  begin
                    sd(10, tully^);
                    sd(config.textcolor, ' bought the ');
                    sd(global_itemcol, objekt^.Name);
                    sd(config.textcolor, ' for ');
                    sd(14, commastr(xx));
                    d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + '.');

                    incplayermoney(player, xx);
                    player.item[i] := 0;
                    Inc(counter);
                  end;

                end;
              end;
            end;
            if counter = 0 then
            begin
              sd(global_plycol, tully^);
              d(config.textcolor, ' looks at your empty ' + backpack);
              d(global_talkcol, ' You have nothing to sell!');
            end;

          end else
          begin
            repeat
              crlf;
              i := item_select(player);
              if i > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);
                if objekt^.ttype in [Weapon] then
                begin
                  if objekt^.Value > 1 then
                  begin
                    xx := objekt^.Value div 2;
                  end else
                  begin
                    xx := objekt^.Value;
                  end;
                  if xx <= 0 then
                  begin
                    sd(global_talkcol, 'That item is worthless!');
                    d(config.textcolor, ', ' + tully^ + ' says.');
                  end else
                  if objekt^.cursed = True then
                  begin
                    sd(global_talkcol, 'I don''t buy cursed items!');
                    d(config.textcolor, ', ' + tully^ + ' says.');
                  end else
                  begin
                    sd(global_plycol, tully^ + config.textcol1 + ' declares that he will give you ');
                    sd(14, commastr(xx));
                    sd(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3);
                    sd(config.textcolor, ' for your ');
                    d(global_itemcol, objekt^.Name + '.');

                    menu2('(A)gree  ');
                    menu('(N)o deal');
                    sd(config.textcolor, ':');

                    repeat
                      ch := upcase(getchar);
                    until ch in ['A', 'N'];

                    crlf;
                    case ch of
                      'N': begin
                        sd(global_talkcol, 'You are making a mistake here!');
                        d(config.textcolor, ', ' + tully^ + ' mutters.');
                      end;
                      'A': begin
                        d(14, 'Deal!');
                        player.item[i] := 0;
                        incplayermoney(player, xx);
                      end;
                    end;
                  end;
                end else
                begin
                  sd(global_talkcol, 'I don''t buy that kind of items!');
                  d(config.textcolor, ', ' + tully^ + ' says.');
                  crlf;
                  pause;
                end;
              end;
            until i = 0;
          end;
        end;
      end;

      'T': begin {k”pa det b„sta vapnet f”r pengarna spelaren har i handen}
        crlf;
        go_ahead := True;
        if (config.classic) and (player.weapon <> 0) then
        begin
          d(global_talkcol, 'Get rid of your old weapon first!');
          go_ahead := False;
          pause;
        end;

        if go_ahead then
        begin

          if player.gold <= 0 then
          begin
            d(global_talkcol, 'Haha! Get out of my store you halfwit!');
            d(global_talkcol, 'Come back when you have enough ' + config.moneytype + '!');
            crlf;
          end else
          begin
            crlf;
            sd(config.textcolor, 'You put your ');
            sd(14, commastr(player.gold));
            d(config.textcolor, ' ' + config.moneytype + ' ' + config.moneytype3 + ' on the counter.');
            crlf;
            d(config.textcolor, 'The old troll looks at the gold and then at you.');
            d(global_talkcol, 'Alright, I''ll se what I can do...');

            x := 0;
            {leta}
            if config.CLASSIC then
            begin
              for i := 1 to fs(FsWeaponClassic) do
              begin
                load_weapon(i, wweapon);
                if player.gold >= wweapon.Value then
                begin
                  x := i;
                end else
                if player.gold < wweapon.Value then
                begin
                  break;
                end;
              end;

              if x = 0 then
              begin
                d(global_talkcol, 'Sorry friend! I don''t have any weapon You can afford.');
              end else
              begin
                d(global_talkcol, 'I have exactly what you are looking for!');
                sd(config.textcolor, ', ');
                sd(global_plycol, tully^);
                d(config.textcolor, ' says.');
                load_weapon(x, wweapon);
                sd(config.textcolor, 'Buy ');
                sd(global_itemcol, wweapon.Name);
                sd(config.textcolor, ' for ');
                sd(14, commastr(wweapon.Value));
                sd(config.textcolor, ' ' + many_money(wweapon.Value));

                if confirm(' ', 'N') = True then
                begin
                  sd(global_talkcol, 'Ok. ');
                  d(config.textcolor, 'says the troll and hands you the weapon.');
                  sd(config.textcolor, 'You give ');
                  sd(global_plycol, tully^);
                  d(config.textcolor, ' the ' + config.moneytype + '.');
                  decplayermoney(player, wweapon.Value);
                  player.weapon := x;
                  player.wpow := wweapon.pow;
                end;

              end;

            end {CLASSIC mode END} else
            begin {NEW mode START}
              x := 0;
              cc := 0;
              for i := 1 to fsob(weapon) do
              begin
                go_ahead := True;
                load_objekt(objekt^, weapon, i);

                if (player.gold < objekt^.Value) or (objekt^.shop = False) then
                begin
                  go_ahead := False;
                end;

                if objekt^.shop = True then
                begin
                  if (objekt^.good) and (player.chiv < 1) and (player.dark > 0) then
                  begin
                    go_ahead := False;
                  end else
                  if (objekt^.evil = True) and (player.chiv > 0) and (player.dark < 1) then
                  begin
                    go_ahead := False;
                  end else
                  if class_restricted(player.class, objekt^, 0) = True then
                  begin
                    go_ahead := False;
                  end;
                  if objekt^.str_need > player.strength then
                  begin
                    go_ahead := False;
                  end;
                end;

                if go_ahead then
                begin {compare with previously found}
                  xx := objekt^.Value;
                  if xx > cc then
                  begin
                    x := i;
                    cc := objekt^.Value;
                  end;
                end;

              end;

              if x > 0 then
              begin
                load_objekt(objekt^, weapon, x);

                sd(global_talkcol, 'I have exactly what you are looking for!');
                sd(config.textcolor, ', ');
                sd(global_plycol, tully^);
                d(config.textcolor, ' says.');

                sd(config.textcolor, 'Buy ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' for ');
                sd(14, commastr(objekt^.Value));
                sd(config.textcolor, ' ' + many_money(objekt^.Value));
                if confirm(' ', 'N') = True then
                begin

                  if inventory_empty(player) = 0 then
                  begin
                    d(config.textcolor, 'Your inventory is full!');
                    if confirm('Drop something ', 'Y') = True then
                    begin
                      drop_item(player);
                    end;
                  end;

                  if inventory_empty(player) > 0 then
                  begin
                    j := inventory_empty(player);
                    d(14, 'Done!');
                    decplayermoney(player, objekt^.Value);
                    player.item[j] := x;
                    player.itemtype[j] := objekt^.ttype;

                    crlf;
                    sd(config.textcolor, 'Start to use the ');
                    sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                    sd(config.textcolor, ' immediately');
                    if confirm('', 'Y') = True then
                    begin
                      use_item(j);
                    end else
                    begin
                      sd(config.textcolor, 'You put the ');
                      sd(global_itemcol, objekt^.Name);
                      d(config.textcolor, ' in your ' + backpack);
                    end;
                  end;
                end;
              end;

            end; {do not remove}

          end;
        end;

      end;
      'B': begin {buy .start.}
        if config.classic then
        begin
          crlf;
          if player.weapon <> 0 then
          begin
            d(global_talkcol, 'Get rid of your old weapon first!');
            pause;
          end else
          begin
            sd(global_talkcol, 'Which one?');
            d(config.textcolor, ', the troll mutters');
            sd(config.textcolor, ':');

            zz := get_number(0, 65000);

            x := fs(FsWeaponClassic);

            if (zz > 0) and (zz <= x) then
            begin
              load_weapon(zz, wweapon);

              sd(config.textcolor, 'So you want a ');
              d(global_itemcol, wweapon.Name);

              if player.race = troll then
              begin
                sd(global_plycol, Tully^);
                d(config.textcolor, ' blinks at you ');
                d(global_talkcol, 'Hey, we trolls gotta stick together!');
                d(global_talkcol, 'therefore i will give ya a discount!');

                rr^ := 0.1;
                rr^ := (wweapon.Value * rr^);
                Dec(wweapon.Value, round(rr^));
              end;

              crlf;
              sd(config.textcolor, 'It will cost you ');
              sd(14, commastr(wweapon.Value));
              d(config.textcolor, ' in ' + +config.moneytype + '.');

              sd(config.textcolor, 'Pay ? ');
              menu2('(Y)es, ');
              menu2('[N]o, ');
              menu('(H)aggle');
              sd(config.textcolor, ':');
              repeat
                ch := upcase(getchar);
              until ch in ['Y', 'N', 'H', ReturnKey];

              if ch = ReturnKey then
              begin
                ch := 'N';
              end;

              case ch of

                'H': begin {haggle}

                  x := haggle('W', wweapon.Value, tully^);

                  if x < wweapon.Value then
                  begin
                    if player.gold < x then
                    begin
                      sd(global_talkcol, 'No ' + config.moneytype + ', no goods!');
                      d(config.textcolor, ' the troll snores.');
                      pause;
                    end else
                    begin
                      d(config.textcolor, 'The troll gives you the weapon.');
                      d(config.textcolor, 'You give him the ' + config.moneytype + '.');

                      decplayermoney(player, x);
                      player.weapon := zz;
                      player.wpow := wweapon.pow;

                      {put it in the news}
                      note_it(wweapon.Name);

                      pause;

                    end;
                  end;
                end;

                'N': begin
                  d(15, 'No');
                end;
                'Y': begin
                  d(15, 'Yes');
                  crlf;
                  if player.gold < wweapon.Value then
                  begin
                    sd(global_talkcol, 'No ' + config.moneytype + ', no goods!');
                    d(config.textcolor, ', the troll snores.');
                    pause;
                  end else
                  begin
                    d(config.textcolor, 'Ok. says the old troll and hands you the weapon.');
                    d(config.textcolor, 'You give the greedy creature the ' + config.moneytype + '.');

                    decplayermoney(player, wweapon.Value);
                    player.weapon := zz;
                    player.wpow := wweapon.pow;

                    note_it(wweapon.Name);

                    pause;
                  end;
                end;
              end;
              ch := ' ';

            end;
          end;
        end else
        begin {classic = false}
          crlf;
          d(3, 'Enter Item # to buy');
          sd(config.textcolor, ':');

          s := get_string(10);

          if s = '?' then
          begin
            d(15, 'List of weapons:');
            komihag := 'L';
          end;
          x := str_to_nr(s);
          j := 0;
          if (x > 0) and (x <= fsob(Weapon)) then
          begin
            for i := 1 to fsob(weapon) do
            begin
              load_objekt(objekt^, weapon, i);
              if objekt^.shop = True then
              begin
                Inc(j, 1);
              end;
              if j = x then
              begin
                if (objekt^.good) and (player.chiv < 1) and (player.dark > 0) then
                begin
                  d(12, 'This item is charmed for good characters.');
                  d(12, 'You can buy it, but you can''t use it!');
                end else
                if (objekt^.evil = True) and (player.chiv > 0) and (player.dark < 1) then
                begin
                  d(12, 'This item is enchanted and can be used by evil characters only.');
                  d(12, 'You can buy it, but not use it!');
                end;

                if objekt^.str_need > player.strength then
                begin
                  d(12, 'This item is too heavy for you to use!');
                end;

                sd(config.textcolor, 'Buy the ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' for ');
                sd(14, commastr(objekt^.Value));
                sd(config.textcolor, ' ' + many_money(objekt^.Value));

                sd(config.textcolor, ' (Y/[N] or (H)aggle) ?');
                repeat
                  cho := upcase(getchar);
                until cho in ['Y', 'N', 'H', ReturnKey];

                crlf;
                if cho = 'H' then
                begin
                  x := haggle('W', objekt^.Value, tully^);
                  if x < objekt^.Value then
                  begin
                    if player.gold < x then
                    begin
                      d(12, 'You don''t have the ' + config.moneytype + '!');
                    end else
                    begin
                      if inventory_empty(player) = 0 then
                      begin
                        d(12, 'Your inventory is full!');
                        if confirm('Drop something ', 'Y') = True then
                        begin
                          drop_item(player);
                        end;
                      end;

                      if inventory_empty(player) > 0 then
                      begin
                        j := inventory_empty(player);
                        d(14, 'Done!');
                        decplayermoney(player, x);
                        player.item[j] := i;
                        player.itemtype[j] := objekt^.ttype;

                        note_it(objekt^.Name);

                        crlf;
                        sd(config.textcolor, 'Start to use the ');
                        sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                        sd(config.textcolor, ' immediately');
                        if confirm('', 'Y') = True then
                        begin
                          use_item(j);
                        end else
                        begin
                          sd(config.textcolor, 'You put the ');
                          sd(global_itemcol, objekt^.Name);
                          d(config.textcolor, ' in your ' + backpack);
                        end;
                      end;
                    end;
                  end;
                end;

                if cho = 'Y' then
                begin
                  if player.gold < objekt^.Value then
                  begin
                    d(12, 'You don''t have the ' + config.moneytype + '!');
                  end else
                  begin
                    if inventory_empty(player) = 0 then
                    begin
                      d(12, 'Your inventory is full!');
                      if confirm('Drop something ', 'Y') = True then
                      begin
                        drop_item(player);
                      end;
                    end;

                    if inventory_empty(player) > 0 then
                    begin
                      j := inventory_empty(player);
                      d(14, 'Done!');
                      decplayermoney(player, objekt^.Value);
                      player.item[j] := i;
                      player.itemtype[j] := objekt^.ttype;

                      note_it(objekt^.Name);

                      crlf;
                      sd(config.textcolor, 'Start to use the ');
                      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                      sd(config.textcolor, ' immediately');
                      if confirm('', 'Y') = True then
                      begin
                        use_item(j);
                      end else
                      begin
                        sd(config.textcolor, 'You put the ');
                        sd(global_itemcol, objekt^.Name);
                        d(config.textcolor, ' in your ' + backpack);
                      end;
                    end;
                  end;
                end;
                break;
              end;
            end;
          end;
        end;
      end; {buy .end.}


      'R': begin {return .start.}
        crlf;
        exit_shop := True;
      end; {return .end.}

    end;   {case .end.}

  until exit_shop = True;

  {dispose pointer variables}
  dispose(objekt);
  dispose(tully);
  dispose(inweap);
  dispose(rr);

end; {Weapon_Shop *end*}

end. {UNIT *END*}
