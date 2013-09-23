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



unit Temple; {Usurper - Temple area}

interface

procedure Temple_of_The_Gods;

implementation

uses
  Init, Cms, InitGods,
  Jakob, StatusC, Various,
  Various2, VarGods, Invent,
  Mail, News, File_io,
  Online;

var
  refresh: boolean;

procedure Meny; {menu displayed when pressing '?'}
const offset = 14;
begin

  clearscreen;
  crlf;
  d(5, ' -*- Temple of the Gods -*-');
  crlf;
  d(config.textcolor, 'The Temple area is crowded with monks, preachers and');
  d(config.textcolor, 'processions of priests on their way to the altars.');
  d(config.textcolor, 'The doomsday prophets are trying to get your attention.');
  crlf;

  {is player a worshipper?}
  if player.god = '' then
    d(config.textcolor, 'You are not a believer.')
  else d(config.textcolor, 'You worship ' + ugodc + player.god + config.textcol1 + '.');
  crlf;

 {god ranking
 holy news
  }
  menu2(ljust('(W)orship', offset));
  menu2(ljust('(D)esecrate altar', offset + 5));
  menu('(H)oly News');

  menu2(ljust('(A)ltars', offset));
  menu('(C)ontribute');

  menu2(ljust('(S)tatus', offset));
  menu('(G)od ranking');

  menu('(R)eturn');

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
      sd(config.textcolor, 'Temple area (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Temple area (W,A,D,C,S,R,G,H,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure contribute_to_god; {give money/goods to deity}
var
  god0:   godrec;

  x, y:   longint;

  s, s2:  s90;

  done, wrong_god, go_ahead: boolean;

  ch:     char;

  objekt: ^orec;

begin

  crlf;
  if player.chivnr < 1 then
  begin
    no_good_deeds;
  end else
  begin

    d(10, '-* Who shall receive your gift *-');
    if select_a_god(god0, '', False) = True then
    begin

      go_ahead := True;
      wrong_god := False;
      if (player.god <> '') and (player.god <> god0.Name) then
      begin
        crlf;
        d(12, god0.Name + ' is not your God! Are you sure about this?');
        d(12, 'The mighty ' + player.god + ' is not going to be happy.');
        if confirm('Continue', 'N') = True then
        begin
          go_ahead := True;
          wrong_god := True;
        end else
        begin
          d(config.textcolor, 'Good for you!');
          go_ahead := False;
        end;
      end;

      if go_ahead then
      begin
        {init vars}
        done := False;
        ch := '?';
        repeat

          if ch = '?' then
          begin
            {sacrifice at gods altar  (gold/item)}
            clearscreen;
            d(10, '-* Sacrifice to the Gods *-');
            d(config.textcolor, 'Sacrifice to the mighty ' + ugodc + god0.Name + config.textcol1 + '.');
            crlf;
            menu('(G)old');
            menu('(I)tem(s)');
            {menu('(C)hild *dark*'); future option!}
            menu('(S)tatus');
            menu('(R)eturn');
          end;
          crlf;
          sd(config.textcolor, 'Sacrifice (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');

          {get user-input}
          ch := upcase(getchar);

          {evaluate user-input}
          case ch of
            'R': begin {return}
              done := True;
            end;
            'S': begin {player status}
              status(player);
              crlf;
            end;
            'I': begin {sac.rifice item}

              crlf;
              if config.classic then
              begin
                d(config.textcolor, 'Item Sacrifices are only available in Usurper Game Mode : ' + ulcyan + 'NEW');
                pause;
              end else
              if is_inventory_empty(player) then
              begin
                d(12, 'Your inventory is empty! You have nothing to sacrifice!');
                pause;
              end else
              begin

                {init pointer variables}
                new(objekt);

                repeat
                  inventory_sort(player);

                  d(config.textcolor, 'Item # to Sacrifice (' + config.textcol2 + '?' + config.textcol1 +
                    '=list, Enter=abort)');
                  sd(config.textcolor, ':');

                  s := get_String(5);
                  y := 0;

                  if s = '?' then
                  begin
                    inventory_display(player);
                  end else
                  if s = '' then
                  begin
                    d(12, 'Aborted.');
                  end else
                  if s <> '' then
                  begin
                    y := str_to_nr(s);
                    if (y < 1) or (y > global_maxitem) then
                      y := 0;
                  end;

                  if y > 0 then
                  begin
                    if player.item[y] > 0 then
                    begin
                      x := player.item[y];

                      if load_objekt(objekt^, player.itemtype[y], x) = True then
                      begin

                        crlf;
                        d(global_itemcol, objekt^.Name + config.textcol1 + ' is worth ' + uyellow +
                          commastr(objekt^.Value) + config.textcol1 + ' ' + config.moneytype + ' ' +
                          many_money(objekt^.Value) + '.');

                        if confirm('Sacrifice ' + uitemc + objekt^.Name + config.textcol1, 'N') = True then
                        begin

                          {Sacrifice!}
                          d(15, 'Sacrificing...');

                          {remove player item}
                          player.item[y] := 0;

                          {calculate deity power increase}
                          y := sacrifice_gold_return(objekt^.Value);

                          {increase deity power}
                          if is_online(god0.Name, online_god) = True then
                          begin
                            online_send_to_player(god0.Name, online_god, uplc + player.name2 +
                              config.textcol1H + ' sacrificed at your altar!');
                            online_send_to_player(god0.Name, online_god, broadcast_GodSacrificed + commastr(y));
                          end else
                          begin

                            {increase deity power}
                            IncGodExp(god0, y);

                            {save god}
                            load_god(fsave, god0, god0.recnr);

                          end;

                          {text}
                          d(2, ugodc + god0.Name + 's' + config.textcol1 + ' powers are growing!');
                          d(config.textcolor, 'You can feel it...Your reward will come.');

                          {inform deity}
                          s2 := '';
                          if wrong_god = False then
                          begin
                            s := 'Sacrifice!';
                            if player.god <> god0.Name then
                            begin
                              s2 := uplc + player.name2 + config.textcol1 + ' is ' + ulred + 'NOT' +
                                config.textcol1 + ' one of your disciples.';
                            end;
                          end else
                          begin
                            s := 'Unexepected Sacrifce!';
                            s2 := uplc + player.name2 + config.textcol1 + ' is a believer in ' +
                              ugodc + god0.Name + config.textcol1 + '.';
                          end;

                          {mail god}
                          post(MailSend,
                            god0.Name,
                            god0.ai,
                            True,
                            mailrequest_nothing,
                            '',
                            uyellow + s + config.textcol1,
                            mkstring(length(s), underscore),
                            uplc + player.name2 + config.textcol1 + ' sacrificed a ' + uitemc +
                            objekt^.Name + config.textcol1 + ' on your altar!',
                            '',
                            'Your power increased by ' + uwhite + commastr(y) + config.textcol1 + ' point(s)!',
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

                          {inform REAL god if sacrifice was made to other god}
                          if (player.god <> '') and (player.god <> god0.Name) then
                          begin

                            {mail god}
                            s := 'Treacherous Mortal';
                            post(MailSend,
                              player.god,
                              'H',
                              True,
                              mailrequest_nothing,
                              '',
                              ulred + s + config.textcol1,
                              mkstring(length(s), underscore),
                              uplc + player.name2 + config.textcol1 + ' sacrificed a ' + uitemc +
                              objekt^.Name + config.textcol1 + ' at the altar of ' + ugodc + god0.Name + config.textcol1 + '!',
                              'You should punish the disloyal ' + uplc + player.name2 + config.textcol1 + ' immediately!',
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

                          {news-paper}
                          newsy(True,
                            'Altar Sacrifice',
                            ' ' + uplc + player.name2 + config.textcol1 + ' sacrificed a ' +
                              uitemc + objekt^.Name + config.textcol1 + ' at the altar of ' + ugodc + god0.Name +
                              config.textcol1 + '.',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '',
                            '');

                          {decrease good deeds}
                          if global_utest = False then
                            Dec(player.chivnr);
                          d(config.textcolor, 'You have ' + uwhite + commastr(player.chivnr) +
                            config.textcol1 + ' Good Deeds left today.');

                          pause;
                          crlf;
                          if confirm('Sacrifice another Item', 'N') = False then
                          begin
                            s := '';
                          end else
                          begin

                            if player.chivnr < 1 then
                            begin
                              no_good_deeds;
                              pause;
                              s := '';
                            end;

                          end;

                        end;

                      end else
                      begin
                        d(12, 'Unable to load item from file!');
                      end;
                    end;
                  end;

                until s = '';

                {dispose pointer vars}
                dispose(objekt);

              end;

            end;
            'G': begin {sac.rifice gold}

              crlf;
              if player.gold < 1 then
              begin
                d(12, 'You have no ' + config.moneytype + '!');
              end else
              begin
                d(config.textcolor, 'Send ' + uyellow + config.moneytype + config.textcol1 + ' to Heaven');
                sd(14, '(0 - ' + commastr(player.gold) + '):');
                {get user-input}
                x := get_number(0, player.gold);

                if x > 0 then
                begin
                  if confirm('Sacrifice ' + uyellow + commastr(x) + config.textcol1 + ' ' +
                    many_money(x) + ' to ' + ugodc + god0.Name + config.textcol1, 'N') = True then
                  begin

                    {decrease player money}
                    decplayermoney(player, x);

                    {calculate deity power increase}
                    y := sacrifice_gold_return(x);

                    {increase deity power}
                    if is_online(god0.Name, online_god) = True then
                    begin
                      online_send_to_player(god0.Name, online_god, uplc + player.name2 + config.textcol1H +
                        ' sacrificed at your altar!');
                      online_send_to_player(god0.Name, online_god, broadcast_GodSacrificed + commastr(y));
                    end else
                    begin

                      {increase deity power}
                      IncGodExp(god0, y);

                      {save god}
                      load_god(fsave, god0, god0.recnr);

                    end;

                    {text}
                    d(2, ugodc + god0.Name + 's' + config.textcol1 + ' power is growing!');
                    d(config.textcolor, 'You can feel it...Your reward will come.');

                    {inform deity}
                    s2 := '';
                    if wrong_god = False then
                    begin
                      s := 'Sacrifice!';
                      if player.god <> god0.Name then
                      begin
                        s2 := uplc + player.name2 + config.textcol1 + ' is ' + ulred + 'NOT' +
                          config.textcol1 + ' one of your disciples.';
                      end;
                    end else
                    begin
                      s := 'Unexepected Sacrifce!';
                      s2 := uplc + player.name2 + config.textcol1 + ' is a believer in ' + ugodc +
                        god0.Name + config.textcol1 + '.';
                    end;

                    {mail god}
                    post(MailSend,
                      god0.Name,
                      god0.ai,
                      True,
                      mailrequest_nothing,
                      '',
                      uyellow + s + config.textcol1,
                      mkstring(length(s), underscore),
                      uplc + player.name2 + config.textcol1 + ' sacrificed ' + uyellow + commastr(x) +
                      config.textcol1 + ' ' + many_money(x) + ' on your altar!',
                      '',
                      'Your power increased by ' + uwhite + commastr(y) + config.textcol1 + ' point(s)!',
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

                    {inform REAL god if sacrifice was made to other god}
                    if (player.god <> '') and (player.god <> god0.Name) then
                    begin

                      {mail god}
                      s := 'Treacherous Mortal';
                      post(MailSend,
                        player.god,
                        'H',
                        True,
                        mailrequest_nothing,
                        '',
                        ulred + s + config.textcol1,
                        mkstring(length(s), underscore),
                        uplc + player.name2 + config.textcol1 + ' sacrificed ' + uyellow +
                          commastr(x) + config.textcol1 + ' ' + many_money(x) + ' at the altar of ' + ugodc + god0.Name +
                          config.textcol1 + '!',
                        'You should punish the disloyal ' + uplc + player.name2 + config.textcol1 + ' immediately!',
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

                    {news-paper}
                    newsy(True,
                      'Altar Sacrifice',
                      ' ' + uplc + player.name2 + config.textcol1 + ' sacrificed ' + config.moneytype +
                      ' at the altar of ' + ugodc + god0.Name + config.textcol1 + '.',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');


                    {decrease good deeds}
                    if global_utest = False then
                      Dec(player.chivnr);
                    d(config.textcolor, 'You have ' + uwhite + commastr(player.chivnr) + config.textcol1 +
                      ' Good Deeds left today.');

                  end;
                end else
                begin
                  d(12, 'Aborted.');
                end;
              end;

            end;
          end; {case .end.}


        until done;

      end;

    end;

  end;

end; {contribute_to_god .end.}


procedure Temple_of_The_Gods;
var
  I_Am_Done: boolean;
  go_ahead:  boolean;

  cho:       char;

  s:         s90;
  note:      s90;

  i:         word;

  x:         longint;
  y:         longint;

  god0:      GodRec;   {temporary god record}
  pl0:       ^UserRec; {temporary user record}

begin

  {init}
  I_Am_Done := False;
  new(pl0);

  crlf;
  crlf;
  d(11, 'You enter the Temple Area');

  {verify that player God exists}
  if player.god <> '' then
  begin
    if verify_gods_existance(player.god) = False then
    begin
      player.god := '';
      user_save(player);
    end;
  end;


  repeat

    {update onliner location, if necessary}
    if onliner.location <> onloc_temple then
    begin
      refresh := True;
      onliner.location := onloc_temple;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    cho := upcase(getchar);

    {evaluate user-input}
    case cho of
      '?': begin {display menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;

      'S': begin {status}
        status(player);
        crlf;
      end;

      'R': begin {return to previous area}
        I_am_done := True;
      end;

      'G': begin {god ranking}
        crlf;
        crlf;
        list_gods(True);
      end;
      'H': begin {holy news}
        clearscreen;
        if global_ansi then
          display_file(global_GodsANSI)
        else display_file(global_GodsASCI);
        crlf;
        pause;
      end;

      'D': begin {desecrate altar}
        crlf;
        crlf;
        if player.darknr < 1 then
        begin
          no_dark_deeds;
        end else
        begin

          if confirm('Do you really want to upset the gods', 'Y') = True then
          begin

            if select_a_god(god0, '', False) = True then
            begin

              if (player.god <> '') and (player.god = god0.Name) then
              begin
                crlf;
                d(12, 'You are not allowed to abuse your own God!');
                pause;
              end else
              begin

                if confirm('Desecrate ' + ugodc + god0.Name + 's' + config.textcol1 + ' altar', 'N') = True then
                begin

                  {desecrate gods altar}

                  case random(2) of
                    0: begin
                      crlf;
                      crlf;
                      d(config.textcolor, 'When nobody is around You start to');
                      d(config.textcolor, 'pound away at the altar with a pickaxe.');
                      sd(12, 'Hack');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'hack');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'hack');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'hack');
                      make_delay_dots(12, 4, 500);
                      d(12, '..!');

                    end;
                    1: begin
                      crlf;
                      crlf;
                      d(config.textcolor, 'When nobody is around You start to');
                      d(config.textcolor, 'stomp the flowers, trash the ornament');
                      d(config.textcolor, 'and pulverize the candles.');
                      sd(12, 'Stomp');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'trash');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'stomp');
                      make_delay_dots(12, 4, 500);
                      sd(12, 'trash');
                      make_delay_dots(12, 4, 500);
                      d(12, '..!');
                    end;
                  end; {case .end.}

                  crlf;
                  d(15, 'Good Work Evil One!');
                  d(15, 'The power of ' + ugodc + god0.Name + uwhite + ' is diminishing!');
                  d(15, 'But beware! You may have to pay a dear price for your folly.');
                  crlf;

                  {experience}
                  x := player.level * 600;
                  IncPlayerExp(player, x);
                  d(14, 'You receive ' + uwhite + commastr(x) + uyellow + ' experience points for this act.');

                  {darkness points}
                  Give_Darkness(player, player.level * 15);

                  {decrease dark deeds}
                  Dec(player.darknr);

                  {gods power diminishes}
                  y := random(3) + 3;

                  {news-paper}
                  Newsy(True,
                    'Altar desecrated!',
                    ' Infamous actions were taken at the altar of ' + ugodc + god0.Name + config.textcol1 + '.',
                    ' The place was desecrated by evil-doers.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform god}
                  if is_online(god0.Name, online_god) = True then
                  begin
                    online_send_to_player(god0.Name, online_god, uplc + player.name2 + config.textcol1H +
                      ' desecrated your altar!');
                    online_send_to_player(god0.Name, online_god, broadcast_GodDesecrated + commastr(y));
                  end else
                  begin

                    {remove experience from desecrated god}
                    DecGodExp(god0, y);

                    {save god}
                    load_god(fsave, god0, god0.recnr);

                    {mail god}
                    s := 'UNFORGIVABLE ACT!';
                    post(MailSend,
                      god0.Name,
                      god0.ai,
                      True,
                      mailrequest_nothing,
                      '',
                      ulred + s + config.textcol1,
                      mkstring(length(s), underscore),
                      uplc + player.name2 + config.textcol1 + ' desecrated your altar!',
                      'Your powers went down by ' + uwhite + commastr(y) + config.textcol1 + ' points.',
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

                  {inform the gods disciples}
                  for i := 1 to fs(FsPlayer) do
                  begin

                    load_character(pl0^, 1, i);

                    if (pl0^.name2 <> player.name2) and
                      (pl0^.god <> '') and
                      (pl0^.god = god0.Name) and
                      (pl0^.deleted = False) then
                    begin

                      {player}
                      if is_online(pl0^.name2, online_player) = True then
                      begin
                        online_send_to_player(pl0^.name2, online_player, uplc + player.name2 +
                          config.textcol1 + ' desecrated the altar of your ' + ugodc + 'GOD' + config.textcol1 + '!');
                      end else
                      begin

                        {regular mail}
                        s := 'ALTAR DESECRATED!';
                        post(MailSend,
                          pl0^.name2,
                          pl0^.ai,
                          False,
                          mailrequest_nothing,
                          '',
                          ulred + s + config.textcol1,
                          mkstring(length(s), underscore),
                          uplc + player.name2 + config.textcol1 + ' desecrated the altar of ' +
                          ugodc + god0.Name + config.textcol1 + ', your god!',
                          'You must protect your master!',
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

                end;
              end;

            end;

          end else
          begin
            d(config.textcolor, 'good for you!');
          end;
        end;

      end;       {desecrate altar *end*}

      'A': begin {altars [view]}

        crlf;
        crlf;
        list_altars(True);

      end;
      'C': begin {contribute to a deity}
        crlf;
        crlf;
        contribute_to_god;
      end;
      'W': begin {worship a deity}

        crlf;
        crlf;
        go_ahead := True;

        if player.god <> '' then
        begin

          d(config.textcolor, 'You currently worship ' + ugodc + player.god + config.textcol1 + '.');

          if confirm('Have you lost your faith in ' + ugodc + player.god + config.textcol1, 'N') = True then
          begin

            {text}
            crlf;
            d(config.textcolor, 'You don''t believe in ' + ugodc + player.god + config.textcol1 + ' anymore.');
            d(global_godcol, player.god + 's' + config.textcol1 + ' powers diminish...');

            note := '';
            if confirm('Send a note to ' + ugodc + player.god + config.textcol1, 'Y') = True then
            begin
              sd(14, 'Note:');
              note := get_string(70);
              d(15, 'Done!');
            end;

            if note = '' then
            begin
              case random(3) of
                0: note := 'You are not my God!';
                1: note := 'farewell..';
                2: note := 'never again will I follow you!';
              end;
            end;

            {mail the god who lost a believer}
            s := 'Lost Believer';
            post(MailSend,
              player.god,
              'H',
              True, {destination is a god}
              mailrequest_nothing,
              '',
              umailheadc + s + config.textcol1,
              mkstring(length(s), underscore),
              uplc + player.name2 + config.textcol1 + ' lost faith in you!',
              uplc + player.name2 + config.textcol1 + ' became a pagan.',
              '',
              'Goodbye note from ' + uplc + player.name2 + config.textcol1 + ':',
              '' + uwhite + note,
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

            {news-paper}
            Newsy(True,
              'Pagan',
              ' ' + uplc + player.name2 + config.textcol1 + ' lost faith in ' + ugodc + player.god + config.textcol1 + '.',
              ' ' + uplc + player.name2 + config.textcol1 + ', the ' + race_display(2, player.race, 0) + ', became a pagan.',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

            {tell other nodes}
            online_send_to_all(uplc + player.name2 + config.textcol1 + ' lost ' + sex3[player.sex] +
              ' faith', player.name2, '');

            {reset players faith}
            player.god := '';

          end else
          begin
            d(12, 'Good for you. The gods don''t take too kindly on apostates.');
            go_ahead := False;
          end;
        end;

        d(5, 'Select a God to worship');
        if go_ahead then
        begin

          if select_a_god(god0, '', False) = True then
          begin

            d(15, 'Ok.');
            d(config.textcolor, 'You raise your hands and pray to the almighty ' + ugodc + god0.Name + config.textcol1);
            sd(config.textcolor, 'for forgiveness...');

            Make_Delay_Dots(config.textcolor, 15, 300);
            crlf;

            d(config.textcolor, 'You are now a believer in ' + ugodc + god0.Name + config.textcol1 + '!');

            {mail the god who won a believer}
            s := 'New Believer';
            post(MailSend,
              god0.Name,
              'H',
              True, {destination is a god}
              mailrequest_nothing,
              '',
              uyellow + s + config.textcol1,
              mkstring(length(s), underscore),
              uplc + player.name2 + config.textcol1 + ' worships you!',
              uplc + player.name2 + config.textcol1 + ' grovels on ' + sex3[player.sex] +
              ' hands and knees before your altar.',
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
            Newsy(True,
              'Salvation',
              ' ' + uplc + player.name2 + config.textcol1 + ' found faith in ' + ugodc + god0.Name + config.textcol1 + '!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

            {tell other nodes}
            online_send_to_all(uplc + player.name2 + config.textcol1 + ' found salvation', player.name2, '');

            player.god := god0.Name;
            user_save(player);

          end;
        end;

      end;

    end; {case .end.}

  until I_am_Done;

  {dispose temporary variables before leaving}
  crlf;
  dispose(pl0);

end; {Temple_of_The_Gods *end*}

end. {Unit Temple .end.}
