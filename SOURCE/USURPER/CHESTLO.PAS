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


unit ChestLo; {Usurper - Stealing Chest Items}

interface

uses
  Init;

function Load_Chest_Item_Owner(var owner: userrec; const ChestItem: ChestItemRec): boolean;
procedure Chest_Looting; {Stealing Chest Items}

implementation

uses
  Cms, Jakob,
  Statusc, Mail, News,
  Various, Various2, Various3, plcomp,
  Online, File_Io, Invent,
  relation;

var
  refresh: boolean;

procedure Meny;
begin

  clearscreen;
  crlf;
  d(5, '-*- The risky business of theft -*-');
  crlf;
  d(config.textcolor, 'You make your way to the wealthy and populated areas in Town');
  d(config.textcolor, 'If you can make into other peoples houses without being seen');
  d(config.textcolor, 'You might get away with some loot. That is, if you can open the chests.');
  crlf;

  menu('(L)ist targets (people with items in their chests)');
  menu('(G)rab some loot from a chest!');
  menu('(S)tatus');
  menu('(R)eturn from crime scene');

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['R',
                       'G',
                       'S',
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
      sd(config.textcolor, 'A dark alley (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin
      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'a dark alley (L,E,G,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}


procedure Chest_Looting;
var
  go_ahead, loadres, found, abort, spotted: boolean;

  ch:        char;

  cc, posmem, counter: integer;

  i, j, size, x: word;

  ChestItem: ChestItemRec;

  objekt:    ^orec;
  ply2:      userrec;

  s:         s70;

begin

  {init pointer variables}
  new(objekt);


  repeat


    if onliner.location <> onloc_chestloot then
    begin
      refresh := True;
      onliner.location := onloc_chestloot;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, Onliner);
    end;

    display_menu(True, True);

    ch := upcase(getchar);

    case ch of
      '?': begin {menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;

      'L': begin {list targets}


        crlf;
        crlf;
        settings_header('Chest Goodies');

        cc := 0;
        counter := 0;
        for i := 1 to fs(FsChestItem) do
        begin

          go_ahead := True;

          {load chest item data}
          load_chestitem(Fload, ChestItem, i);

          {don't show players own item .. or rather: dont show Player in this list}
          if chestItem.PlyID = player.ID then
          begin
            go_ahead := False;
          end;

          if chestItem.PlyID = '' then
          begin
            go_ahead := False;
          end;


          if go_ahead then
          begin
            {load corresponding object from database}
            if load_objekt(objekt^, ChestItem.ityp, ChestItem.pekare) = False then
            begin
              go_ahead := False;
            end else
            begin
              {load owner name}
              s := '*unknown*';

              loadres := load_chest_item_owner(Ply2, ChestItem);

              if loadres then
              begin
                s := ply2.name2;
              end;

            end;

          end;

          if go_ahead then
          begin

            {display item}
            Inc(counter);
            Inc(cc);
            sd(7, commastr(counter) + '. ');
            sd(global_itemcol, objekt^.Name);
            d(config.textcolor, ' - owned by ' + uplc + s);

            if cc > 12 then
            begin
              cc := 0;
              if confirm('Continue List ', 'Y') = False then
              begin
                break;
              end;
            end;

          end;

        end; {for i .end.}

             {did we found any items}
        if counter = 0 then
        begin
          d(12, 'Bah! You didn''t find any valuables!');
          pause;
        end;

      end;       {list targets *end*}

      'G': begin {grab loot from chest}

        if player.darknr < 1 then
        begin
          crlf;
          {no dark deeds left}
          no_dark_deeds;
          pause;
        end else
        if inventory_empty(player) = 0 then
        begin
          crlf;
          d(12, 'Your inventory is full!');
          pause;
        end else
        begin

          crlf;
          crlf;
          d(config.textcolor, 'Hehe, time to grab some easy loot. Who is your target?');

          sd(config.textcolor, ':');
          s := get_string(20);

          found := False;
          abort := False;

          for i := 1 to 2 do
          begin

            size := 1;
            case i of
              1: size := fs(fsplayer);
              2: size := fs(fsnpc);
            end;

            for j := 1 to size do
            begin

              {load player/npc}
              if load_character(ply2, i, j) = True then
              begin

                if (findsub(s, ply2.name2)) and
                  (ply2.name2 <> player.name2) and
                  (ply2.deleted = False) and
                  (ply2.name2 <> global_delname2) then
                begin

                  go_ahead := True;


                  if confirm(uplc + ply2.name2 + ' ' + config.textcol1, 'N') = True then
                  begin

                    if is_online(ply2.name2, online_player) then
                    begin
                      d(12, 'Sorry, but ' + uplc + ply2.name2 + ulred + ' is awake and watchinge the chest.');
                    end else
                    begin
                      found := True;
                      abort := True;
                    end;
                  end else
                  begin

                    if confirm('Continue search', 'Y') = False then
                    begin
                      abort := True;
                    end;

                  end;

                end;

              end;

              if abort then
                break;

            end; {for j:= .end.}

            if abort then
              break;

          end; {for i:= .end.}

        end;
        if (found = False) and (abort = False) then
        begin
          could_not_locate_character;
        end else
        if found then
        begin

         {found a player. check if he/she has items
         d(14,'Golden! Your sources tells you that...');
         }

          cc := 0;
          counter := 0;
          for i := 1 to fs(FsChestItem) do
          begin

            go_ahead := False;

            {load chest item data}
            load_chestitem(Fload, ChestItem, i);

            {don't show players own item .. or rather: dont show Player in this list}
            if chestItem.PlyID = ply2.ID then
            begin
              go_ahead := True;
            end;


            if go_ahead then
            begin
              {load corresponding object from database}
              if load_objekt(objekt^, ChestItem.ityp, ChestItem.pekare) = False then
              begin
                go_ahead := False;
              end;

            end;

            if go_ahead then
            begin

              {display item}
              Inc(counter);
              Inc(cc);

              if counter = 1 then
              begin
                crlf;
                d(14, 'Golden! What do you want to steal from ' + uplc + ply2.name2 + config.textcol1 + '?');
              end;

              sd(7, commastr(counter) + '. ');
              d(global_itemcol, objekt^.Name);
              {d(config.textcolor,' - owned by ' + uplc + s);}

              if cc > 12 then
              begin
                cc := 0;
                if confirm('Continue List ', 'Y') = False then
                begin
                  break;
                end;
              end;

            end;

          end; {for i .end.}

               {did we found any items}
          if counter = 0 then
          begin
            d(12, 'Bah! You didn''t find any valuables stored in ' + uplc + ply2.name2 + 's' + config.textcol1 + ' house.');
          end else
          begin

            sd(config.textcolor, '# to steal (0-' + commastr(counter) + '):');


            x := get_number(0, counter);

            go_ahead := False;
            if x = 0 then
            begin
              d(12, 'You decide to be a coward.');
            end else
            begin
              Dec(player.darknr);

              {locate item}
              counter := 0;
              go_ahead := False;
              for i := 1 to fs(FsChestItem) do
              begin

                {load chest item data}
                load_chestitem(Fload, ChestItem, i);
                posmem := i;

                if chestItem.PlyID = ply2.ID then
                begin
                  go_ahead := True;
                end;


                if go_ahead then
                begin
                  {load corresponding object from database}
                  if load_objekt(objekt^, ChestItem.ityp, ChestItem.pekare) = False then
                  begin
                    go_ahead := False;
                  end;

                end;

                if go_ahead then
                begin
                  Inc(counter);
                  if counter = x then
                  begin
                    {d(15,'Match!');}
                    break;
                  end;
                end;

              end; {for i .end.}

              if confirm('Steal the ' + uitemc + objekt^.Name + config.textcol1, 'N') = True then
              begin

                crlf;
                d(config.textcolor, 'You slowly open the window in the back...');
                pause;


                i := random(2);
                {jakob}
                if (i = 1) and (ply2.hps > 0) and (ply2.location = offloc_home) then
                begin
                  if add_shadow(SAdd, ply2, player.name2, 'fighting ' + uplc + player.name2 +
                    config.textcol1 + '!', 0) = True then
                  begin

                    spotted := True;
                    d(12, 'Oh no!');
                    d(global_plycol, ply2.name2 + config.textcol1 + ' is standing in the room. Watching you.');
                    d(config.textcolor, 'This is going to get ugly.');
                    pause;
                    to_death := False;
                    for i := 1 to global_maxspells do
                      player.spell[i, 2] := False;
                    repeat
                      player_computer(player, ply2, False, 4);
                    until (player.hps < 1) or (ply2.hps < 1);
                    if player.hps <= 0 then
                      killed_by_stats(ply2, player);
                    if ply2.hps <= 0 then
                      killed_by_stats(player, ply2);

                    if player.hps > 0 then
                      sd(config.textcolor, 'Ahh, nothing like killing someone at home!')
                    else
                    begin
                      reduce_player_resurrections(player, True);
                      pause;
                      normal_exit;
                    end;
                    add_shadow(SRemove, ply2, '', '', 0);

                  end;

                end else
                begin
                  if random(3) = 0 then
                  begin
                    d(12, 'Uh oh. They saw you stealing! You barely got away.');
                    spotted := True;
                  end else
                  begin
                    spotted := False;
                  end;
                end;

                {update player variables}

                {put item in player inventory}
                i := inventory_empty(player);
                if i > 0 then
                begin
                  player.item[i] := chestitem.pekare;
                  player.itemtype[i] := chestitem.ityp;
                end;

                {remove item from chest}
                ChestItem.PlyID := emptystr;
                ChestItem.pekare := 0;
                load_chestitem(FSave, ChestItem, posmem);



                {darkness}
                x := player.level * 20;
                d(config.textcolor, 'Your soul darkens for ' + uwhite + commastr(x) + config.textcol1 + ' points!');
                Give_Darkness(player, x);


                {save player char}
                user_save(player);


                if spotted then
                begin

                  {news-paper}
                  newsy(True,
                    'Thief! Thief!',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was spotted stealing from ' +
                    uplc + ply2.name2 + 's' + config.textcol1 + ' house.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {informing victim}
                  post(MailSend,
                    ply2.name2,
                    ply2.ai,
                    False,
                    mailrequest_nothing,
                    '',
                    ulred + 'Dirty Thieves' + config.textcol1,
                    mkstring(13, underscore),
                    uplc + player.name2 + config.textcol1 + ' stole the ' + uitemc + objekt^.Name +
                    config.textcol1 + ' from your home!',
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

                  {news-paper}
                  newsy(True,
                    'Burglars',
                    ' Thieves broke into ' + uplc + ply2.name2 + 's' + config.textcol1 + ' home and stole treasure.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {informing victim}
                  post(MailSend,
                    ply2.name2,
                    ply2.ai,
                    False,
                    mailrequest_nothing,
                    '',
                    ulred + 'Dirty Thieves' + config.textcol1,
                    mkstring(13, underscore),
                    config.textcol1 + 'Somebody broke into your home and stole the ' + uitemc +
                    objekt^.Name + config.textcol1 + '!',
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

              end else
              begin
                crlf;
                d(12, 'You decide not to.');
              end;

            end;

          {jakob
          decrease dark deeds
          mail victim
          news
          }

          end;

        end;

      end; {grab loot from chest *end*}
    end;


  until ch = 'R';

  crlf;

  {dispose pointer variables}
  dispose(objekt);

end; {Chest_Looting *end*}


function Load_Chest_Item_Owner(var owner: userrec; const ChestItem: ChestItemRec): boolean;
var

  i, j, size: word;
  found:      boolean;

begin
  {init}
  found := False;

  Load_Chest_Item_Owner := False;

  for i := 1 to 2 do
  begin

    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end; {case .end.}

    for j := 1 to size do
    begin

      if load_character(owner, i, j) = True then
      begin

        if (owner.ID = chestitem.PLYID) and
          (owner.deleted = False) and
          (owner.name1 <> global_delname1) and
          (owner.name2 <> global_delname2) then
        begin
          found := True;
          break;
        end;
      end;

    end; {for j:= .end.}
    if found then
      break;
  end; {for i:= .end.}

  Load_Chest_Item_Owner := found;

end; {Load_Chest_Item_Owner *end*}


end. {Unit ChestLo .end.}
