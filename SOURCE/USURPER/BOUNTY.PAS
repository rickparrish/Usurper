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



unit Bounty; {Usurper - Bounty Room}

interface

procedure Bounty_Hunters;

implementation

uses
  Init, Cms, Jakob,
  Mail, News, Statusc,
  Wantedsc, Various, Various2,
  Online, File_Io;

const max_posters = 50; {should be the same as the MAX constant in WANTEDSC.pas}
var
  refresh: boolean;

procedure Meny; {menu displayed when pressing '?'}
const clerk = 'Turgon';
begin

  clearscreen;
  crlf;
  d(5, 'Bounty Room');
  crlf;
  d(config.textcolor, 'The many posters on the wall indicates that this town');
  d(config.textcolor, 'is no longer the safe place it used to be.');
  d(config.textcolor, 'From the look of the crowd in here you can also tell that');
  d(config.textcolor, 'the distinction betweeten the fugitive and the hunter is somewhat');
  d(config.textcolor, 'hard to make. Cloks, long knives and daggers are their standard');
  d(config.textcolor, 'equipment.');
  d(config.textcolor, 'The royal Clerk ' + uplc + clerk + config.textcol1 + ' is here to assist you.');
  crlf;

  menu2('(W)anted posters  ');
  menu('(M)ost wanted (top ' + commastr(max_posters) + ')');

  menu2('(A)dd bounty      ');
  menu('(C)lear bounty');

  menu('(S)tatus');
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
      sd(config.textcolor, 'Bounties (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Bounties (W,A,C,M,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Bounty_Hunters;
var
  y, counter: integer;

  ch, cho:    char;

  i, j, x:    longint;

  a, s2:      s90;

  justval:    byte;

  leave_bounty_room, found, abort: boolean;

  pl0:        ^UserRec;
  wanted:     wantedrec;

begin

  {init pointer variables}
  new(pl0);

  leave_bounty_room := False;

  crlf;
  crlf;
  d(config.textcolor, 'You enter the ' + ulgreen + 'Bounty Room');
  repeat

    {update online location}
    if onliner.location <> onloc_bountyroom then
    begin
      refresh := True;
      onliner.location := onloc_bountyroom;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    cho := upcase(getchar);

    {evaluate user-input}
    case cho of
      '?': begin {menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'R': begin
        crlf;
        leave_bounty_room := True;
      end;
      'S': begin {status}
        status(player);
        crlf;
      end;
      'M': begin {most wanted list}
        most_wanted('M');
      end;
      'C': begin {clear bounty}

        crlf;
        crlf;
        d(config.textcolor, 'Clear bounty on whom ?');
        sd(config.textcolor, ':');
        a := get_string(30);
        a := upcasestr(a);

        found := False;

        for i := 1 to fs(FsWanted) do
        begin
          load_wanted(Fload, wanted, i);

          if (findsub(a, wanted.Name)) and (wanted.collected = False) then
          begin
            sd(global_plycol, wanted.Name);
            if confirm(' ', 'N') = True then
            begin
              if wanted.mad <> player.name2 then
              begin
                if wanted.Name = player.name2 then
                begin
                  d(5, 'That reward is set for YOU! FOOL!');
                end else
                begin
                  d(5, 'That reward was not set by you!');
                end;
                if confirm('Continue search ', 'Y') = False then
                begin
                  break;
                end;
              end else
              begin
                if wanted.collected = False then
                begin

                  sd(config.textcolor, 'Clear reward on ');
                  sd(global_plycol, wanted.Name);
                  sd(config.textcolor, ', for ');
                  sd(14, commastr(wanted.gold));
                  sd(config.textcolor, ' ' + many_money(wanted.gold));

                  if confirm(' ', 'N') = True then
                  begin
                    wanted.collected := True;
                    incplayermoney(player, wanted.gold);
                    load_wanted(Fsave, wanted, i);

                    d(15, 'OK.');
                    d(config.textcolor, 'You remove your poster from the board.');
                    sd(config.textcolor, 'You get your ');
                    sd(14, commastr(wanted.gold));
                    d(config.textcolor, ' ' + many_money(wanted.gold) + ' from the deposit.');
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
            end else
            begin
              if confirm('Continue search', 'Y') = False then
              begin
                break;
              end;
            end;
          end;
        end;

      end;
      'A': begin {add bounty}
        crlf;
        crlf;

        {must check if the bountyfile is full}
        x := fs(FsWanted);
        if x >= max_posters then
        begin
          d(5, 'Sorry, but the Reward-Board is currently full.');
          d(5, 'Try again later.');
        end else
        begin

          d(config.textcolor, 'Who are you looking for?');
          sd(config.textcolor, ':');
          a := get_string(30);
          a := upcasestr(a);

          found := False;
          abort := False;

          for i := 1 to fs(FsPlayer) do
          begin

            if load_character(pl0^, 1, i) = True then
            begin

              if (pl0^.deleted = False) and (pl0^.king = False) then
              begin
                if (findsub(a, pl0^.name2)) and (pl0^.name2 <> player.name2) then
                begin
                  sd(global_plycol, pl0^.name2);
                  if confirm(' ', 'N') = True then
                  begin
                    found := True;
                    break;
                  end else
                  begin
                    if confirm('Continue search ', 'Y') = False then
                    begin
                      abort := True;
                      break;
                    end;
                  end;
                end;
              end;
            end;
          end;

          if (found = False) and (abort = False) then
          begin
            for i := 1 to fs(FsNpc) do
            begin

              if load_character(pl0^, 2, i) = True then
              begin

                if (pl0^.name2 <> player.name2) and (pl0^.deleted = False) and
                  (pl0^.king = False) then
                begin
                  if (findsub(a, pl0^.name2)) and (pl0^.name2 <> player.name2) then
                  begin
                    sd(10, pl0^.name2);
                    if confirm(' ', 'N') = True then
                    begin
                      found := True;
                      break;
                    end else
                    begin
                      if confirm('Continue search ', 'Y') = False then
                      begin
                        abort := True;
                        break;
                      end;
                    end;
                  end;
                end;
              end;
            end;
          end;

          if found then
          begin
            crlf;
            sd(config.textcolor, 'You have ');
            sd(14, commastr(player.gold));
            d(config.textcolor, ' ' + many_money(player.gold));

            d(config.textcolor, 'Set bounty (min 1,500 ' + config.moneytype + ' ' + config.moneytype3 + ')');
            sd(config.textcolor, ':');

            {get user-input}
            x := get_number(0, 1000000000);

            if (x <= player.gold) and (x >= 1500) and (x <= 100000000) then
            begin

              if confirm('Are you sure ', 'Y') = True then
              begin

                if confirm('Should anyone be able to collect the reward ', 'Y') = False then
                begin

                  d(config.textcolor, 'Who should be able to collect the reward :');
                  menu('(A)nyone');
                  menu('(N)pcs only');
                  menu('(P)layers only');
                  sd(config.textcolor, ':');

                  {get user input}
                  repeat
                    ch := upcase(getchar);
                  until ch in ['A', 'N', 'P'];

                  {evaluate user input}
                  case ch of
                    'A': begin
                      d(15, 'Anyone');
                      wanted.elig := 'A';
                    end;
                    'N': begin
                      d(15, 'NPCs only');
                      wanted.elig := 'C';
                    end;
                    'P': begin
                      d(15, 'Players only');
                      wanted.elig := 'H';
                    end;
                  end;

                end else
                begin
                  wanted.elig := 'A';
                end;

                if confirm('Anonymously ', 'N') = True then
                begin
                  s2 := 'An enemy';
                  wanted.anonym := True;
                end else
                begin
                  s2 := player.name2;
                  wanted.anonym := False;

                  {news}
                  newsy(True,
                    'Bounty',
                    ' ' + uplc + pl0^.name2 + config.textcol1 + ' is wanted ' + ulred + 'DEAD' + config.textcol1 + ' by ' + uplc + player.name2 + config.textcol1 + '!',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');
                end;

                {set wanted record}
                wanted.mad := player.name2;
                wanted.Name := pl0^.name2;
                wanted.date := todays_date;
                wanted.level := pl0^.level;
                wanted.gold := x;
                wanted.collected := False;
                wanted.ai1 := player.ai;
                wanted.ai2 := pl0^.ai;

                decplayermoney(player, x);

                y := empty_wantedslot;
                load_wanted(Fsave, wanted, y);

                {notify victim}
                post(MailSend,
                  pl0^.name2,
                  pl0^.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  umailheadc + 'You are WANTED!' + config.textcol1,
                  mkstring(15, underscore),
                  uplc + s2 + config.textcol1 + ' has set a ' + uyellow + commastr(x) + config.textcol1 + ' ' + many_money(x) + ' reward',
                  'for your head.',
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

                d(15, 'OK.');
                d(config.textcolor, 'Let''s hope that some good citizen can get this creep!');

              end;
            end else if (y = 0) and (x > player.gold) then
            begin
              crlf;
              You_Cant_Afford_It;
            end else
            begin
              crlf;
              d(15, 'Get Real.');
            end;
          end;

        end;
      end;
      'W': begin {Display Wanted Posters}
        crlf;
        crlf;
        counter := 0;
        y := 0;

        if f_exists(global_wwfile) then
        begin
          for i := 1 to fs(FsWanted) do
          begin

            if i = 1 then
            begin
              s2 := '#   Wanted              Level      Bounty Set by          Can be claimed by';
              d(5, s2);
              d(5, mkstring(length(s2), underscore));
              Inc(y, 2);
            end;

            load_wanted(Fload, wanted, i);
            if (wanted.collected = False) and (wanted.Name <> '') then
            begin

              {#}
              Inc(counter);
              Inc(y);
              s2 := commastr(counter);

              case length(s2) of
                1: s2 := s2 + '   ';
                2: s2 := s2 + '  ';
                3: s2 := s2 + ' ';
              end;

              {name}
              sd(15, s2);
              justval := 20;
              sd(global_plycol, ljust(wanted.Name, justval));
              justval := 6;

              x := 0;
              {real player level}
              if wanted.ai2 = 'C' then
              begin
                for j := 1 to fs(FsNpc) do
                begin
                  if load_character(pl0^, 2, j) = True then
                  begin
                    if pl0^.name2 = wanted.Name then
                    begin
                      x := pl0^.level;
                      break;
                    end;
                  end;
                end; {for j:= .end.}
              end;

              if x = 0 then
              begin
                for j := 1 to fs(FsPlayer) do
                begin
                  if load_character(pl0^, 1, j) = True then
                  begin
                    if pl0^.name2 = wanted.Name then
                    begin
                      x := pl0^.level;
                      break;
                    end;
                  end;
                end;
              end;

              if x = 0 then x := wanted.level;
              sd(15, ljust(commastr(x), justval));

              s2 := commastr(wanted.gold);
              x := length(s2);
              if x < 11 then
              begin
                x := 11 - x;
                s2 := mkstring(x, ' ') + s2;
              end;
              justval := 12;
              sd(14, ljust(s2, justval));
              justval := 16;

              if wanted.anonym = True then
              begin
                sd(7, ljust('*Anonymous*', justval));
              end else
              begin
                sd(7, ljust(wanted.mad, justval));
              end;

              case wanted.elig of
                'A': d(7, 'Anyone');
                'C': d(7, 'NPCs');
                'H': d(7, 'Players');
              end; {case .end.}

              if y > global_screenlines - 2 then
              begin
                y := 0;
                if confirm('Continue ', 'Y') = False then
                begin
                  break;
                end;
              end;
            end;
          end;
          if counter = 0 then
          begin
            d(5, 'Too bad! No rewards are set.');
          end;
        end else
        begin
          d(12, 'Too bad! No rewards are set.');
        end;
      end;

    end; {case .end.}

  until leave_bounty_room = True;

  crlf;

  {remove pointer variables}
  dispose(pl0);

end; {Bounty_Hunters *end*}

end. {Unit Bounty .end.}
