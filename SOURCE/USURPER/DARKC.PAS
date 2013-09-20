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


unit DarkC; {Usurper - Dark Deeds}

interface

procedure Dark_deeds;

implementation

uses
  Init, Cms, Jakob,
  Statusc, Gigoloc, Beerst,
  ChestLo, Whores, Murder,
  Various, Various2, Various3,
  News, Children, Relation,
  File_Io, Online;

var
  refresh: boolean;

procedure Kidnap_Child;
var child: childrec;
  x:       longint;

begin

  crlf;
  crlf;
  if player.darknr < 1 then
  begin
    {no dark deeds left}
    no_dark_deeds;
    pause;
    crlf;
    exit;
  end;

  d(7, '-*Evil Deed*-');
  d(config.textcolor, 'Who shall we kidnap, oh evil one ?');

  if select_a_child(player, child, anychild, excludeown, False) then
  begin

    if confirm('Kidnap ' + ukidc + child.Name + config.textcol1, 'N') = True then
    begin

      if add_child(SAddChild, child, player.name2, 'being stalked!', 0) = False then
      begin
        d(12, child.Name + ' is busy. try again soon!');
      end else
      begin
        {can't kidnap own children!}
        if my_child(player, child) then
        begin
          d(12, 'You can''t kidnap your own children! (you twisted creature!)');
        end {alredy poisoned?}
        else if child.health = childhealth_poisoned then
        begin
          d(12, child.Name + ' is suffering from poison! It''s impossible to get through.');
        end else if child.location <> childlocation_home then
        begin
          d(12, child.Name + ' is not home!');
        end else
        begin
          {chance of success}

          x := random(3);
     {fusk!
     x:=1;}

          if x = 0 then
          begin
            {successful kidnapping}

            {evil text}
            show_usurper_data('DEATH_HEAD', False);
            d(7, 'Kidnap attempt successful!');
            d(config.textcolor, 'You run away with ' + ukidc + child.Name + config.textcol1 + ' in a sack.');
            d(config.textcolor, ukidc + child.Name + 's' + config.textcol1 + ' destiny is in your hands!');
            d(config.textcolor, '(go ' + ulgray + 'Home' + config.textcol1 + ' for "kidnappers options")');
            crlf;
            d(7, 'Good work evil one!');

            {update child}
            child.location := ChildLocation_Kidnapped;
            child.kidnapper := player.name2;
            child.ransom_demanded := 100;
            child.kidnapperid := player.id;

            load_child(fsave, child, child.recnr);

            {update player variables}
            Dec(player.darknr);

            {darkness}
            x := player.level * 25;
            d(config.textcolor, 'Your soul darkens for ' + uwhite + commastr(x) + config.textcol1 + ' points!');
            Give_Darkness(player, x);

            {experience}
            x := player.level * 1050;
            d(config.textcolor, 'You receive ' + uwhite + commastr(x) + config.textcol1 + ' experience points!');
            incplayerexp(player, x);

            {inform parents}
            inform_parents_online(child, ukidc + child.Name + config.textcol1 + ' has been ' + ulred + 'kidnapped' + config.textcol1 + '!');

            inform_parents(child,
              mailrequest_nothing,
              ulred + 'Child harmed!' + config.textcol1,
              mkstring(13, underscore),
              'Your ' + sex7[child.sex] + ukidc + ' ' + child.Name + config.textcol1 + ' has been kidnapped by ' + uplc + player.name2 + config.textcol1 + ' the ' + race_display(2, player.race, 0) + '!',
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

            {news-paper}
            newsy(True,
              'Child Kidnapped!',
              ' ' + ukidc + child.Name + config.textcol1 + ', the ' + sex7[child.sex] + ' of ' + uplc + child.mother + config.textcol1 + ' and ' + uplc + child.father + config.textcol1 + ' was',
              ' ' + ulred + 'kidnapped' + config.textcol1 + ' by a evil ' + race_display(2, player.race, 0) + '!',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

          end else
          begin
            {failed kidnapping}
      {failure render in 1. jail
                         2. got away}
            x := random(2);

      {cheat , useful to enable this when testing jakob!
      x:=0;}

            if x = 0 then
            begin
              {jailed!}

              Dec(player.darknr);
              {update location}
              player.location := offloc_prison;
              player.daysinprison := 1; {days to spend in prison}

              crlf;
              d(12, '***failure***   THEY WERE WAITING FOR YOU!   ***failure***');
              d(config.textcolor, 'You are chained and led off to the Royal Prison.');
              d(config.textcolor, 'The crowd outside would like to see you lynched, but');
              d(config.textcolor, 'the guards manage to protect you.');
              crlf;
              {update player variables}
              Dec(player.darknr);
              player.hps := 0;
              {player.allowed:=false;}
              Reduce_Player_Resurrections(player, True);

              pause;
              crlf;

              d(config.textcolor, 'You are thrown in a damp prison dungeon...');
              d(config.textcolor, 'Your only company will be the rats and cockroaches.');
              d(config.textcolor, 'Return tomorrow and you might be set free.');
              d(config.textcolor, '(or attempt a daring escape)');
              crlf;

              {news-paper}
              newsy(True,
                'Kidnapper caught!',
                ' ' + the_bad + lowercase(classnames[player.class]) + ' ' + uplc + player.name2 + config.textcol1 + ' was caught attempting',
                ' to run off with ' + ukidc + child.Name + config.textcol1 + ', the ' + sex7[child.sex] + ' of ' + uplc + child.mother + config.textcol1 + ' and ' + uplc + child.father + config.textcol1 + '.',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              {inform parents}
              inform_parents_online(child, ukidc + child.Name + config.textcol1 + ' was almost kidnapped' + config.textcol1 + '!');

              inform_parents(child,
                mailrequest_nothing,
                umailheadc + 'Child in danger!' + config.textcol1,
                mkstring(16, underscore),
                uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] + ' made an attempt to kidnap your ' + sex7[child.sex] + ukidc + ' ' + child.Name + config.textcol1 + '!',
                'Fortunately the attempt failed and ' + uplc + player.name2 + config.textcol1 + ' was jailed!',
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

              {inform king}
              inform_king(
                umailheadc + 'Kidnapper Jailed!' + config.textcol1,
                mkstring(17, underscore),
                uplc + player.name2 + config.textcol1 + ' made an attempt to kidnap ' + ukidc + child.Name + config.textcol1 + '!',
                'Fortunately the attempt failed and ' + uplc + player.name2 + config.textcol1 + ' was jailed!',
                'It''s up to your royal highness to deal with this bandit.',
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


              pause;
              normal_exit;

            end else
            begin
              crlf;
              d(12, 'Failure! You never got close to the darn kid!');
              d(12, 'You must devise a better plan to get your hands on that stinking kid!');

              {news-paper}
              newsy(True,
                umailheadc + 'Kidnap attempt' + config.textcol1,
                ' An attempt to kidnap ' + ukidc + child.Name + config.textcol1 + ', ' + sex7[child.sex] + ' of ' + uplc + child.mother + config.textcol1 + ' and ' + uplc + child.father + config.textcol1 + ', failed!',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              {update player variables}
              Dec(player.darknr);

              {inform parents}
              inform_parents_online(child, ukidc + child.Name + config.textcol1 + ' was almost kidnapped' + config.textcol1 + '!');

              inform_parents(child,
                mailrequest_nothing,
                umailheadc + 'Evil near!' + config.textcol1,
                mkstring(10, underscore),
                'Somebody tried to kidnap your ' + sex7[child.sex] + ukidc + ' ' + child.Name + config.textcol1 + '!',
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
        end;

        {remove shadow kid}
        add_child(SRemoveChild, child, '', '', 0);

      end;
    end;
  end;

end; {kidnap_child *end*}

procedure Poison_Child; {poison a child!}
var child: childrec;
  x:       longint;
begin

  {this is a dark deed alright...hehe.}

  if player.darknr < 1 then
  begin
    crlf;
    {no dark deeds left}
    no_dark_deeds;
    pause;
    crlf;
    exit;
  end;

  crlf;
  crlf;
  d(7, '-*Evil Deed*-');
  d(12, 'Children are just trouble...let''s get rid of one!');

  if select_a_child(player, child, anychild, excludeown, False) then
  begin

    if confirm('Send a poisoned cookie to ' + ukidc + child.Name + config.textcol1, 'N') = True then
    begin

      if add_child(SAddChild, child, player.name2, 'talking to stranger', 0) = False then
      begin
        d(12, child.Name + ' is busy. try again soon!');
      end else
      begin
        {can't poison own children!}
        if my_child(player, child) then
        begin
          d(12, 'You can''t poison your own children! (you cruel bastard!)');
        end {alredy poisoned?}
        else if child.health = childhealth_poisoned then
        begin
          d(12, child.Name + ' is already laying in bed, suffering!');
        end else
        begin
          {chance of success}

          if random(3) = 0 then
          begin
            {successful poisoning}

            {evil text}
            show_usurper_data('DEATH_HEAD', False);
            d(7, 'Right on!');
            d(2, ukidc + child.Name + config.textcol1 + ' ate the poisoned Cookie!');
            d(config.textcolor, ukidc + child.Name + config.textcol1 + ' is suffering from stomach ache!');
            d(7, 'Good work evil one!');

            {update child}
            child.health := ChildHealth_Poisoned;
            load_child(fsave, child, child.recnr);

            {update player variables}
            Dec(player.darknr);

            {darkness}
            x := player.level * 15;
            d(config.textcolor, 'Your soul darkens for ' + uwhite + commastr(x) + config.textcol1 + ' points!');
            Give_Darkness(player, x);

            {experience}
            x := player.level * 950;
            d(config.textcolor, 'You receive ' + uwhite + commastr(x) + config.textcol1 + ' experience points!');
            incplayerexp(player, x);

            {inform parents}
            inform_parents_online(child, ukidc + child.Name + config.textcol1 + ' has been ' + ulred + 'poisoned' + config.textcol1 + '!');

            inform_parents(child,
              mailrequest_nothing,
              ulred + 'Child harmed!' + config.textcol1,
              mkstring(13, underscore),
              'Your ' + sex7[child.sex] + ukidc + ' ' + child.Name + config.textcol1 + ' ate a poisoned cookie sent by ' + uplc + player.name2 + config.textcol1 + '!',
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

            {news-paper}
            newsy(True,
              'Child Poisoned!',
              ' ' + ukidc + child.Name + config.textcol1 + ', the ' + sex7[child.sex] + ' of ' + uplc + child.mother + config.textcol1 + ' and ' + uplc + child.father + config.textcol1 + ' was',
              ' ' + ulred + 'poisoned' + config.textcol1 + ' by a wicked ' + race_display(2, player.race, 0) + '!',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

          end else
          begin
            {failed poisoning}

            crlf;
            d(12, 'Failure! The damn kid never ate the poisoned cookie you sent ' + sex[child.sex] + '!');
            d(12, 'You must devise a better plan to rid yourself of that kid!');

            {news-paper}
            newsy(True,
              umailheadc + 'Poisoning attempt' + config.textcol1,
              ' An attempt to poison ' + ukidc + child.Name + config.textcol1 + ', the ' + sex7[child.sex] + ' of ' + uplc + child.mother + config.textcol1 + ' and ' + uplc + child.father + config.textcol1 + ' failed!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

            {update player variables}
            Dec(player.darknr);

            {inform parents}
            inform_parents_online(child, ukidc + child.Name + config.textcol1 + ' was almost poisoned' + config.textcol1 + '!');

            inform_parents(child,
              mailrequest_nothing,
              umailheadc + 'Evil lurking!' + config.textcol1,
              mkstring(13, underscore),
              'Somebody tried to trick your ' + sex7[child.sex] + ukidc + ' ' + child.Name + config.textcol1 + ' to eat a poisoned cookie!',
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

        {remove shadow kid}
        add_child(SRemoveChild, child, '', '', 0);

      end;
    end;
  end;

end; {poison_child *end*}

procedure Meny;
begin
  clearscreen;
  crlf;
  d(5, '-*- Dark Deeds -*-');
  crlf;
  d(config.textcolor, 'Your mind is filled with dark thoughts...');
  d(config.textcolor, 'Who wants to be good when there are faster ways');
  d(config.textcolor, 'to success through evil acts.');
  d(config.textcolor, 'You walk to Clamson street...');
  crlf;

  {is this game configured for SOFT modes?}
  if config.allow_whores = True then
  begin
    menu('(V)isit Whorehouse');
  end;
  if config.allow_murder = True then
  begin
    menu('(M)urder innocent people');
  end;
  if config.allow_whores = True then
  begin
    menu('(H)all of Dreams  (women only)');
  end;

  menu('(B)eer stealing');
  menu('(G)rab loot from others bounty Chests');
  menu('(P)oison children');
  menu('(K)idnap children');
  menu('(S)tatus');
  menu('(R)eturn to street');

end;

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['V',
                       'M',
                       'H',
                       'B',
                       'G',
                       'S',
                       'R',
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

      crlf;
      sd(config.textcolor, 'Dark Deeds (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, 'Dark Deeds (R,M,H,B,G,P,K,S,V,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Dark_Deeds;
var cho:       char;
  king:        kingrec;
  leave_place: boolean;
begin

  leave_place := False;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_darkness then
    begin
      refresh := True;
      onliner.location := onloc_darkness;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, Onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    cho := upcase(getchar);

    {filter out disabled options}
    if (config.allow_whores = False) and (cho in ['V', 'H']) then
    begin
      crlf;
      d(12, 'The Whore House is closed in this game.');
      pause;
      cho := ' ';
    end else if (config.allow_murder = False) and (cho = 'M') then
    begin
      crlf;
      d(12, 'Murdering innocent people is forbidden in this game.');
      pause;
      cho := ' ';
    end;

    {evaluate user-input}
    case cho of
      '?': begin {display menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;
      'R': begin {return}
        leave_place := True;
      end;
      'K': begin {kidnap child}
        kidnap_child;
      end;
      'P': begin {poison child}
        poison_child;
      end;
      'B': begin {beer stealing}
        if player.darknr <= 0 then
        begin
          crlf;
          {no dark deeds left}
          no_dark_deeds;
          pause;
          crlf;
        end else
        begin
          crlf;
          crlf;
          d(config.textcolor, 'You decide to make some easy ' + config.moneytype + ' using your skill as a thief.');
          d(config.textcolor, 'When you approach the Inn you can hear the watch-dogs barking.');
          crlf;
          beer_stealing;
          crlf;
        end;
      end;
      'G': begin {steal from Chests, at peoples homes *start*}
        if config.classic then
        begin
          crlf;
          d(15, 'This option is not available in Usurper Classic mode.');
        end else
        begin
          chest_looting;
          crlf;
        end;
      end; {steal from Chests, at peoples homes *end*}
      'M': begin {murder innocent people}
        if player.darknr <= 0 then
        begin
          crlf;
          no_dark_deeds;
          d(12, 'You are too tired for any more murders.');
          d(12, 'Go and get some sleep, you bloodthirsty bastard.');
          pause;
          crlf;
        end else
        begin

          if config.allow_murder = True then
          begin
            murdering;
          end else
          begin
            crlf;
            d(12, 'Murdering is not allowed in this game.');
            pause;
          end;

        end;
      end;
      'H': begin {hall of dreams, for women only}
        if player.sex <> 2 then
        begin
          crlf;
          d(5, 'Only women can get satisfaction from this place!');
        end else
        begin

          if (player.sex = 2) and (config.allow_whores = True) then
          begin

            load_king(fload, king);

            if (king.shop_gigolos = False) and (player.king = False) then
            begin
              crlf;
              d(12, 'The Gigolos Nest is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
            end else
            begin
              gigolos;
            end;
          end;
        end;
      end;
      'V': begin {visit whore house}
        if player.sex <> 1 then
        begin
          crlf;
          d(5, 'Only men can get something from this place!');
        end else
        begin
          if (player.sex = 1) and (config.allow_whores = True) then
          begin
            load_king(fload, king);

            if (king.shop_whores = False) and (player.king = False) then
            begin
              crlf;
              d(12, 'The Whore House is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
            end else
            begin
              whore_house;
            end;
          end;
        end;
      end;
    end; {case .end.}

  until leave_place;

  crlf;

end; {dark_deeds *end*}

end. {Unit DarkC .end.}
