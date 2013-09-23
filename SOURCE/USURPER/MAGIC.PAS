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


unit Magic; {Usurper - Magic Shoppe}

interface

procedure Magic_Shop;

implementation

uses
  Init, Cms, Jakob,
  Statusc, Invent, Various,
  Various2, Online, File_Io;

var
  a2, owner: s70;
  refresh:   boolean;
  counter:   integer;

procedure Meny;
begin

  clearscreen;
  crlf;
  a2 := 'Magic Shop, run by ' + owner + ' the gnome';
  d(5, a2);
  d(5, mkstring(length(a2), underscore));

  crlf;
  d(config.textcolor, 'You enter the dark and dusty boutique, filled with all sorts');
  d(config.textcolor, 'of strange objects. As you examine the place you notice a');
  d(config.textcolor, 'few druids and wizards searching for orbs and other mysterious items.');
  d(config.textcolor, 'When you reach the counter you try to remember what you were looking for.');
  crlf;
  sd(global_talkcol, 'What shall it be ');
  sd(15, race_display(2, player.race, 0));
  d(global_talkcol, '?');
  crlf;
  sd(config.textcolor, '(You have ');
  sd(14, commastr(player.gold));
  d(config.textcolor, ' ' + many_money(player.gold) + ')');
  crlf;

  menu2('(R)eturn to street     ');
  menu2('(L)ist Items  ');
  menu('(T)alk to ' + owner);

  menu2('(I)dentify item        ');
  menu('(B)uy Item');
  menu2('(H)ealing Potions      ');
  menu('(S)ell Item');

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'S',
                       'H',
                       'I',
                       'L',
                       'B',
                       chr(13),
                       '?']);}

  if short = True then
  begin
    if player.expert = False then
    begin
      if (refresh) and (player.auto_meny) then
      begin
        refresh := False;
        meny;
      end;

      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Magic Shop (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin

      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Magic (R,S,H,I,L,B,T,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Magic_Shop;
const
  bandit         = 'Rugwar'; {bandits name, if you change here, change in dungeon event to!}
  stranger       = 'Rodrik'; {strangers name, if you change here... (see above)}

  never: boolean = False;
var
  ch, cho:  char;
  rr:       real;
  zz, xx, z, x, i: longint;
  cc, j: integer;
  s:        s70;
  idcost:   longint;
  objekt:   ^orec;
  mys1, mys2, mys3: longint;
  soktyp:   objtype;

  souktyp:  array[1..3] of objtype;
  xi:       byte;

  First:    boolean;

  restrict: boolean;
  normcol, shadcol, col: byte;

begin

  new(objekt);

  { fetch Ravanellas name from .CFG }
  owner := cfg_string(18);
  if owner = '' then
    owner := 'Ravanella';

  {fetc ID cost from .CFG}
  idcost := 1500;
  s := cfg_string(52);
  idcost := str_to_nr(s);
  if (idcost < 1) or (idcost > 2000000000) then
    idcost := 1500;

  if owner = '' then
  begin
    owner := 'Ravanella';
  end;

  crlf;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_magicshop then
    begin
      refresh := True;
      onliner.location := onloc_magicshop;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    display_menu(True, True);

    cho := upcase(getchar);

    z := 0;
    case cho of
      '?': begin
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'R': begin
        crlf;
        dispose(objekt);
        exit;
      end;
      'T': begin {talk to Owner *start}
        crlf;
        sd(global_plycol, owner);
        d(config.textcolor, ' looks at you and says :');
        d(global_talkcol, ' So show me what you got!');
        crlf;
        pause;

        s := '';
        if DungeonQuest.magicshoppe = True then
        begin
          s := '(1). Papers converning ' + bandit + 's criminal activities.';
        end;

        ch := menu_choices(s, '(N)othing', '', '', '');


        if (ch = '1') and (DungeonQuest.magicshoppe = True) then
        begin
          crlf;
          sd(config.textcolor, 'You show the papers you were given by ');
          sd(global_plycol, stranger);
          sd(config.textcolor, ' to ');
          sd(global_plycol, owner);
          d(config.textcolor, '.');
          sd(global_plycol, owner);
          sd(config.textcolor, ' studies the papers and then puts them in a drawer.');
          pause;

          sd(global_plycol, owner);
          d(config.textcolor, ' then turns to you and speaks :');

          sd(global_talkcol, ' Good work ');
          sd(12, player.name2);
          sd(global_talkcol, ' ! You have helped us in the ');
          sd(14, 'Brother Ring');
          d(global_talkcol, ' more');
          d(global_talkcol, ' than you think. This may very well prove to be');
          d(global_talkcol, ' the edge we so very much need to bring that');
          sd(global_talkcol, ' infamous Warlord ');
          sd(15, bandit);
          d(global_talkcol, ' to his knees.');
          pause;


          {end of mission}
          crlf;
          crlf;
          Inc(player.quests);

          if player.quests = 1 then
          begin
            d(14, 'You have completed your FIRST Mission! Congratulations!');
          end else
          begin
            sd(config.textcolor, 'You completed your ');
            sd(15, commastr(player.quests));
            sd(config.textcolor, ' Mission! ');
            d(14, ' GOOD WORK!');
          end;

          d(config.textcolor, 'This will be put in our records!');

          DungeonQuest.magicshoppe := False;

          pause;
        end else
        begin
          d(config.textcolor, 'You stand there like a sheep. You have nothing to show!');
          d(config.textcolor, '(idiot!)');
          pause;
          sd(global_plycol, owner);
          d(config.textcolor, ' throws you out!');

          dispose(objekt);
          exit;

        end;

      end;  {talk to Owner *end*}
      'S': begin
        if config.classic then
        begin
          crlf;
          d(15, 'Not available in Usurper Classic mode.');
        end else
        begin
          crlf;
          if confirm('Sell every magic item in inventory ', 'N') = True then
          begin
            counter := 0;
            for i := 1 to global_maxitem do
            begin
              if player.item[i] > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);

                if objekt^.ttype in [Neck, Fingers, Waist] then
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
                    sd(config.textcolor, ' is worthless!, ' + owner + ' says.');
                  end else
                  if objekt^.cursed = True then
                  begin
                    sd(global_itemcol, objekt^.Name);
                    d(config.textcolor, ' is cursed!');
                    sd(15, '"I don' + chr(39) + 't buy cursed items!"');
                    d(config.textcolor, ', ' + owner + ' says.');
                  end else
                  begin
                    sd(config.textcolor, owner + ' bought your ');
                    sd(global_itemcol, objekt^.Name);
                    sd(config.textcolor, ' for ');
                    sd(14, commastr(xx));
                    d(config.textcolor, ' ' + many_money(xx) + '.');

                    incplayermoney(player, xx);
                    player.item[i] := 0;
                    Inc(counter);
                  end;

                end;
              end;
            end;
            if counter = 0 then
            begin
              crlf;
              d(global_talkcol, ' You have nothing of interest.');
            end;

          end else
          begin
            repeat
              crlf;
              i := item_select(player);
              if i > 0 then
              begin
                load_objekt(objekt^, player.itemtype[i], player.item[i]);
                if objekt^.ttype in [Neck, Fingers, Waist] then
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
                    d(config.textcolor, ', ' + owner + ' says.');
                  end else
                  if objekt^.cursed = True then
                  begin
                    sd(global_talkcol, 'I don''t buy cursed items!');
                    d(config.textcolor, ', ' + owner + ' says.');
                  end else
                  begin
                    sd(config.textcolor, owner + ' declares that he will give you ');
                    d(14, commastr(xx));
                    sd(config.textcolor, many_money(xx));
                    sd(config.textcolor, ' for your ');
                    d(global_itemcol, objekt^.Name + '.');

                    menu2('(A)gree  ');
                    menu2('(N)o Deal  ');
                    menu('(H)aggle');

                    sd(config.textcolor, ':');
                    repeat
                      ch := upcase(getchar);
                    until ch in ['A', 'N', 'H'];

                    crlf;
                    case ch of
                      'N': begin
                        d(15, '"I gave you a fair offer!", ' + owner + ' mutters');
                        pause;
                      end;
                      'H': begin

                        case random(5) of
                          0: begin
                            sd(global_talkcol, 'I don''t haggle with scum like you!');
                            d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' says in an angry voice...');
                          end;
                          1: begin
                            sd(global_talkcol, 'You are not worth dealing with!');
                            d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' scornes you.');
                          end;
                          2: begin
                            sd(global_talkcol, 'Hahaha...!');
                            d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' laughs mysteriously.');
                          end;
                          3: begin
                            sd(global_talkcol, 'NO HAGGLING IN MY STORE!');
                            d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' says.');
                          end;
                          4: begin
                            sd(global_talkcol, 'Pay or get lost!');
                            d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' screams.');
                          end;
                        end; {case .end.}
                        pause;

                      end;

                      'A': begin
                        d(14, 'Deal!');
                        player.item[i] := 0;
                        incplayermoney(player, xx);
                        crlf;
                      end;
                    end;
                  end;
                end else
                begin
                  sd(global_talkcol, 'I don''t buy that kind of items');
                  d(config.textcolor, ', ' + uplc + owner + config.textcol1 + ' says.');
                  crlf;
                  pause;
                end;

              end;
            until i = 0;
          end;
        end;
      end;
      'B': begin
        if config.classic then
        begin
          crlf;
          d(15, 'Not available in Classic mode.');
        end else
        if (config.allowitem[10] = False) and
          (config.allowitem[11] = False) and
          (config.allowitem[5] = False) and
          (config.allowitem[6] = False) and
          (config.allowitem[9] = False) then
        begin
          crlf;
          crlf;
          d(15, 'The store is closed! Some boring fool from the outside has');
          d(15, 'removed all items that are usually sold here.');
          crlf;
        end else
        begin
          crlf;
          d(3, 'Enter Item # to buy');
          sd(config.textcolor, ':');

          x := get_number(0, 65000);
          j := 0;
          xi := 0;

          if (config.allowitem[10]) or (config.allowitem[11]) then
          begin
            Inc(xi);
            souktyp[xi] := Neck;
          end;
          if (config.allowitem[5]) or (config.allowitem[6]) then
          begin
            Inc(xi);
            souktyp[xi] := Fingers;
          end;
          if config.allowitem[9] then
          begin
            Inc(xi);
            souktyp[xi] := Waist;
          end;

          if x > 0 then
          begin
            mys1 := 1;
            mys2 := 0;
            mys3 := 0;
            repeat
              soktyp := souktyp[mys1];

              for i := 1 to fsob(soktyp) do
              begin
                load_objekt(objekt^, soktyp, i);
                if objekt^.shop then
                begin
                  Inc(mys2);
                end;
                if mys2 = x then
                begin
                  mys3 := i;
                  break;
                end;
              end;

              Inc(mys1);
            until (mys1 > xi) or (mys3 <> 0);

            if mys3 > 0 then
            begin
              if (objekt^.good) and (player.chiv < 1) and (player.dark > 0) then
              begin
                d(12, 'This item is charmed for good characters.');
                d(12, 'You can buy it, but you not use it!');
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

              if class_restricted(player.class, objekt^, 0) then
              begin
                d(12, 'This item is class restricted and cannot be used by you!');
              end;

              sd(config.textcolor, 'Buy the ');
              sd(global_itemcol, objekt^.Name);
              sd(config.textcolor, ' for ');
              sd(14, commastr(objekt^.Value));
              sd(config.textcolor, ' ' + many_money(objekt^.Value));
              sd(config.textcolor, ' (Y/[N]) ?');
              repeat
                cho := upcase(getchar);
              until (cho = 'Y') or (cho = 'N') or (cho = chr(13));

              crlf;
              if cho = 'Y' then
              begin
                if player.gold < objekt^.Value then
                begin
                  d(config.textcolor, 'You don''t have the ' + config.moneytype + '!');
                end else
                begin
                  if inventory_empty(player) = 0 then
                  begin
                    d(config.textcolor, 'Your inventory is full!');
                  end else
                  begin
                    j := inventory_empty(player);
                    d(14, 'Done!');
                    decplayermoney(player, objekt^.Value);
                    player.item[j] := mys3;
                    player.itemtype[j] := objekt^.ttype;

                    crlf;
                    sd(config.textcolor, 'Start to use the ');
                    sd(global_itemcol, objekt^.Name);
                    sd(config.textcolor, ' immediately ');
                    if confirm(' ', 'Y') = True then
                    begin
                      use_item(j);
                    end else
                    begin
                      sd(config.textcolor, 'You put the ');
                      sd(global_itemcol, objekt^.Name);
                      d(config.textcolor, ' in your backpack');
                    end;
                  end;
                end;
              end;
            end;
          end;
        end;
      end;
      'L': begin {list magic items}
        if config.classic then
        begin
          crlf;
          d(15, 'Not available in Usurper Classic mode.');
        end else
        if (config.allowitem[10] = False) and
          (config.allowitem[11] = False) and
          (config.allowitem[5] = False) and
          (config.allowitem[6] = False) and
          (config.allowitem[9] = False) then
        begin
          crlf;
          crlf;
          d(15, 'The store is closed! Some boring fool from the outside has');
          d(15, 'removed all items that are usually sold here.');
          crlf;
        end else
        begin
          clearscreen;
          j := 0;
          cc := 3;
          d(5, '#   Item                  Cost');
          crlf;

          xi := 0;
          if (config.allowitem[10]) or (config.allowitem[11]) then
          begin
            Inc(xi);
            souktyp[xi] := Neck;
          end;
          if (config.allowitem[5]) or (config.allowitem[6]) then
          begin
            Inc(xi);
            souktyp[xi] := Fingers;
          end;
          if config.allowitem[9] then
          begin
            Inc(xi);
            souktyp[xi] := Waist;
          end;

          mys1 := 1;
          repeat
            soktyp := souktyp[mys1];

            for i := 1 to fsob(soktyp) do
            begin
              load_objekt(objekt^, soktyp, i);
              if objekt^.shop = True then
              begin
                Inc(j);
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
                while length(s) < 22 do
                begin
                  s := s + '.';
                end;

                {name}
                normcol := global_itemcol;
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
                  d(7, ' *Class Restricted*');
                end else
                begin
                  crlf;
                end;

                {continue}
                if cc > global_screenlines - 2 then
                begin
                  crlf;
                  if confirm('Continue ', 'Y') = False then
                    break;
                  crlf;
                  cc := 1;
                end;

              end;
            end;

            Inc(mys1);
          until mys1 > xi;

          crlf;
        end;
      end;
      'I': begin {identify item}
        if config.classic then
        begin
          crlf;
          d(15, 'Not available in Usurper Classic mode.');
        end else
        begin
          d(15, 'Identify item');
          crlf;

          repeat
            i := item_select(player);
            if i > 0 then
            begin
              load_objekt(objekt^, player.itemtype[i], player.item[i]);
              sd(config.textcolor, 'Identify ');
              sd(global_itemcol, objekt^.Name);
              if confirm(' ', 'N') = True then
              begin
                crlf;
                sd(5, owner);
                sd(config.textcolor, ' demands ');
                sd(14, commastr(idcost));
                d(config.textcolor, ' ' + many_money(idcost) + ' for this service.');
                if confirm('Agree ', 'N') = True then
                begin
                  if player.gold < idcost then
                  begin
                    d(config.textcolor, 'You don''t have the ' + config.moneytype + '!');
                  end else
                  begin
                    {player pays for identification}
                    decplayermoney(player, idcost);
                    crlf;
                    s := ' ' + objekt^.Name + ' ';
                    d(13, cool_string(length(s), '=', '-', 13, 13));
                    d(global_itemcol, s);
                    d(13, cool_string(length(s), '=', '-', 13, 13));
                    crlf;
                    for i := 1 to 5 do
                    begin
                      if objekt^.desc2[i] <> '' then
                      begin
                        d(15, ' ' + objekt^.desc2[i]);
                      end;
                    end; {for i:= .end.}
                    sd(config.textcolor, 'Value : ');
                    d(14, commastr(objekt^.Value));

                    if objekt^.hps <> 0 then
                    begin
                      sd(config.textcolor, 'Hitpoints : ');
                      if objekt^.hps > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.hps));
                      end else
                      begin
                        d(15, commastr(objekt^.hps));
                      end;
                    end;

                    if objekt^.stamina <> 0 then
                    begin
                      sd(config.textcolor, 'Stamina : ');
                      if objekt^.stamina > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.stamina));
                      end else
                      begin
                        d(15, commastr(objekt^.stamina));
                      end;
                    end;

                    if objekt^.agility <> 0 then
                    begin
                      sd(config.textcolor, 'Agility : ');
                      if objekt^.agility > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.agility));
                      end else
                      begin
                        d(15, commastr(objekt^.agility));
                      end;
                    end;

                    if objekt^.charisma <> 0 then
                    begin
                      sd(config.textcolor, 'Charisma : ');
                      if objekt^.charisma > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.charisma));
                      end else
                      begin
                        d(15, commastr(objekt^.charisma));
                      end;
                    end;

                    if objekt^.dex <> 0 then
                    begin
                      sd(config.textcolor, 'Dexterity : ');
                      if objekt^.dex > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.dex));
                      end else
                      begin
                        d(15, commastr(objekt^.dex));
                      end;
                    end;

                    if objekt^.wisdom <> 0 then
                    begin
                      sd(config.textcolor, 'Wisdom : ');
                      if objekt^.wisdom > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.wisdom));
                      end else
                      begin
                        d(15, commastr(objekt^.wisdom));
                      end;
                    end;

                    if objekt^.mana <> 0 then
                    begin
                      sd(config.textcolor, 'Mana : ');
                      if objekt^.mana > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.mana));
                      end else
                      begin
                        d(15, commastr(objekt^.mana));
                      end;
                    end;

                    if objekt^.armor <> 0 then
                    begin
                      sd(config.textcolor, 'Armor : ');
                      if objekt^.armor > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.armor));
                      end else
                      begin
                        d(15, commastr(objekt^.armor));
                      end;
                    end;

                    if objekt^.attack <> 0 then
                    begin
                      sd(config.textcolor, 'Attack : ');
                      if objekt^.attack > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.attack));
                      end else
                      begin
                        d(15, commastr(objekt^.attack));
                      end;
                    end;

                    if objekt^.strength <> 0 then
                    begin
                      sd(config.textcolor, 'Strength : ');
                      if objekt^.strength > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.strength));
                      end else
                      begin
                        d(15, commastr(objekt^.strength));
                      end;
                    end;

                    if objekt^.defence <> 0 then
                    begin
                      sd(config.textcolor, 'Defence : ');
                      if objekt^.defence > 0 then
                      begin
                        d(15, '+' + commastr(objekt^.defence));
                      end else
                      begin
                        d(15, commastr(objekt^.defence));
                      end;
                    end;

                    if objekt^.str_need > 0 then
                    begin
                      sd(config.textcolor, 'Strength Needed to Use Object : ');
                      d(15, commastr(objekt^.str_need));
                    end;

                    case objekt^.cure of
                      All: d(3, 'It cures Every known disease!');
                      Blindness: d(3, 'It cures Blindness!');
                      Plague: d(3, 'It cures the Plague!');
                      Smallpox: d(3, 'It cures Smallpox!');
                      Measles: d(3, 'It cures Measles!');
                      Leprosy: d(3, 'It cures Leprosy!');
                    end; {case .end.}

                    if objekt^.good = True then
                    begin
                      d(config.textcolor, 'This item can only be used by good characters.');
                    end;

                    if objekt^.evil = True then
                    begin
                      d(config.textcolor, 'This item can only be used by evil characters.');
                    end;

                    if objekt^.cursed = True then
                    begin
                      d(12, 'The ' + objekt^.Name + ' is CURSED!');
                    end;

                    First := True;
                    for i := 1 to global_maxclasses do
                    begin
                      if class_restricted(player.class, objekt^, i) then
                      begin
                        if First then
                        begin
                          d(12, 'This item is class restricted!');
                          First := False;
                        end;
                        sd(5, classnames[class_corr2(i)] + 's');
                        d(config.textcolor, ' can''t use this item!');
                      end;
                    end; {for i:= .end.}

                    crlf;
                    pause;
                  end;
                end;
              end;
            end;
          until i = 0;
        end;
      end;

      'H': begin {buy healing potions}
        crlf;
        crlf;

        {calculate price for a potion}
        z := player.level * 5;

        xx := player.gold div z;
        if (player.healing + xx) > config.maxheals then
        begin
          xx := config.maxheals - player.healing;
        end;

        if xx < 0 then
          xx := 0;

        if player.gold < z then
        begin
          d(12, 'You don''t have enough ' + config.moneytype + '!');
        end else
        if xx = 0 then
        begin
          d(12, 'You already have the maximum number of healing potions!');
        end else
        if player.gold = 0 then
        begin
          d(12, 'You don''t have any ' + config.moneytype + '!');
        end else
        if player.gold < z then
        begin
          if xx = 0 then
          begin
            d(5, 'You already have the maximum number of healing potions.');
          end else
          begin
            sd(config.textcolor, 'You need ');
            sd(5, commastr(xx));
            d(config.textcolor, ' potions.');
          end;

          d(5, 'You can''t afford anything!');
          crlf;
          pause;
        end else
        if player.healing >= config.maxheals then
        begin
          d(5, 'You already have the maximum number of healing potions.');
        end else
        if player.gold >= z then
        begin

          sd(config.textcolor, 'Current price is ');
          sd(14, commastr(z));
          sd(config.textcolor, ' ' + many_money(z) + ' per potion.');

          sd(config.textcolor, ' You have ');
          sd(14, commastr(player.gold));
          sd(config.textcolor, ' ' + many_money(player.gold) + '.');
          crlf;

          sd(config.textcolor, 'You have ');
          sd(5, commastr(player.healing));
          sd(config.textcolor, ' potions');
          crlf;

          sd(config.textcolor, 'How many? (max ');
          sd(5, commastr(xx));
          sd(config.textcolor, ' potions');
          d(config.textcolor, numeric_help);

          sd(config.textcolor, ':');

          zz := get_number(0, xx);

          xx := player.gold;
          rr := zz * z;
          xx := round(rr);
          if xx > player.gold then
          begin
            crlf;
            d(config.textcolor, owner + ' looks at you and laughs...Who are you trying to fool?');
            pause;
          end;
          if (player.gold >= xx) and (zz > 0) and (zz + player.healing <= config.maxheals) then
          begin
            Inc(player.healing, zz);
            decplayermoney(player, xx);
            sd(config.textcolor, 'Ok, it''s a deal. You buy ');
            sd(11, commastr(zz));
            d(config.textcolor, ' potions.');
            crlf;
          end else
          begin
            d(12, 'Aborted.');
          end;
          z := 0;
        end;
      end;

    end;       {case .end.}

  until never; {main loop}
  crlf;

  {dispose pointer var}
  dispose(objekt);

end; {Magic_Shop *end*}

end. {Unit Magic .end.}
