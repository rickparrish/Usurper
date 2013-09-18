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


unit PrisonC; {Usurper - the prison, from the prisoners view}

interface

procedure The_Prison;

implementation

uses
  Init, Cms, Jakob,
  Statusc, Various, Various2,
  Post_To, Mail,
  News, Online, File_Io, SysUtils;

var refresh: boolean;

procedure Meny;
const offset = 20;
begin
  clearscreen;
  crlf;

  d(8, 'IIIIIIIIIIIIIIIIIIIIIIII');
  d(8, 'III The Royal Prison III');
  d(8, 'IIIIIIIIIIIIIIIIIIIIIIII');
  crlf;
  d(config.textcolor, 'You wake up cold and aching.');
  d(config.textcolor, 'Horrifying screams from the torture-chamber nearby make You');
  d(config.textcolor, 'shudder with fear.');
  d(config.textcolor, 'The Sheriff and his henchmen can be heard chatting in the');
  d(config.textcolor, 'corridor outside.');

  crlf;
  menu2(ljust('(W)ho else is here', offset));
  menu('(D)emand to be released!');

  menu2(ljust('(M)essage', offset));
  menu('(N)ew mail');

  menu2(ljust('(O)pen cell door', offset));
  menu('(E)scape!');
  menu('(S)tatus');
  menu('(Q)uit');

end; {meny .end.}

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
      sd(config.textcolor, 'Royal Prison (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, 'Royal Prison (W,M,N,D,O,S,E,Q,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu .end.}


procedure The_Prison;
var
  cho:    char;

  counter: byte;

  i, j, k, size: word;

  x:      longint;

  daystr: s4;

  abort:  boolean;

  pl0:    userrec; {user record}

begin

  global_auto_probe := NoWhere;
  repeat

    {update onliner location, if necessary}
    if (onliner.location <> onloc_prisoner) and (onliner.location <> onloc_prisonerop) then
    begin
      refresh := True;
      onliner.location := onloc_prisoner;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {list of other players here and online}
    if player.ear = global_ear_all then
    begin
      who_is_here;
    end;

    {menu}
    display_menu(True, True);

    {get user input}
    cho := upcase(getchar);

    {evaluate user input}
    case cho of
      '?': begin {display menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;
      'Q': begin {quit}
        crlf;
        crlf;
        if confirm('QUIT game', 'N') = False then
        begin
          cho := ' ';
        end;
      end;
      'M': begin {send a message}
        send_a_letter(False);
      end;
      'N': begin {new mail, scan for}
        crlf;
        crlf;
        crlf;
        d(10, 'Let''s see if you have mail waiting ...');

        {scan for mail}
        read_my_mail(player);

      end;
      'O': begin {open cell door}
        crlf;

        if onliner.location = onloc_prisonerop then
        begin

          d(13, 'You walk out of your cell.');
          d(13, 'You are free!');

          player.location := offloc_dormitory;
          player.hps := player.maxhps;
          player.DaysinPrison := 0;
          global_auto_probe := MainStreet;
          user_save(player);

          exit;
        end else
        begin
          crlf;
          d(13, 'You try to open the Iron door, but it''s impossible.');
          d(13, 'You are trapped in here! Perhaps you should try to escape.');
          pause;
        end;

      end;
      'D': begin {demand to be released}
        crlf;
        crlf;
        d(5, 'You clear your throat : ');
        sd(global_talkcol, 'Let me out of here please....!');
        Sleep(900);
        crlf;

        crlf;
        d(config.textcolor, 'After a moment you hear a dark voice cry out :');
        case random(5) of
          0: d(global_talkcol, 'Haha!');
          1: d(global_talkcol, 'Sure! Next year maybe! Haha!');
          2: d(global_talkcol, 'SHUT UP! OR WE WILL HURT YOU BAD!');
          3: d(global_talkcol, 'GIVE IT A REST IN THERE!');
          4: d(global_talkcol, 'Ho ho ho!');
        end;

        d(config.textcolor, '(You will probably be released tomorrow)');

      end;

      'E': begin {escape}

        crlf;
        if player.prison_escapes < 1 then
        begin
          crlf;
          d(12, 'You have no escape attempts left! Try again tomorrow.');
          pause;
        end else
        begin

          {perhaps you could implement 'help from God/Immortal'}

          crlf;
          if confirm(ubrown + 'Jail-Break' + config.textcol1, 'Y') = True then
          begin

            Dec(player.prison_escapes);
            user_save(player);
            crlf;

            {chances for successful jail-break}
            x := random(2);

          {cheat
          x:=1;}

            if x = 0 then
            begin
              d(12, 'You failed!');

              {news-paper}
              newsy(True,
                'Escape Attempt',
                ' ' + uplc + player.name2 + config.textcol1 + ' failed to escape from Prison!',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');


              pause;
              crlf;
            end else
            begin

              d(15, 'Success! You are FREE!');

              {news-paper}
              newsy(True,
                'Jail-Break',
                ' ' + uplc + player.name2 + config.textcol1 + ' escaped from Prison!',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              {inform king/queen}
              inform_king(uplc + player.name2 + config.textcol1 + ' escaped from prison!',
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
                '',
                '',
                '');

              {inform other nodes}
              online_send_to_all(uplc + player.name2 + ugreen + ' escaped Prison!', player.name2, '');

              crlf;
              pause;

              {set player flags}
              player.location := offloc_dormitory;
              player.hps := player.maxhps;
              player.DaysinPrison := 0;
              global_auto_probe := MainStreet;

              {enter game}
              exit;

            end;

          end;

        end;

      end; {escape .end.}

      'W': begin {list of prisoners}
        crlf;
        crlf;
        d(5, 'Prisoners');
        d(5, mkstring(9, underscore));

        k := 0;
        abort := False;
        counter := 2;
        for i := 1 to 2 do
        begin

          size := 1;
          case i of
            1: size := fs(fsplayer);
            2: size := fs(fsnpc);
          end;

          for j := 1 to size do
          begin
            load_character(pl0, i, j);
            if (pl0.name2 <> player.name2) and
              (pl0.name2 <> global_delname2) and
              (pl0.location = offloc_prison) and
              (pl0.deleted = False) and
              (pl0.name2 <> '') then
            begin

              Inc(k);

              sd(global_plycol, pl0.name2);
              sd(config.textcolor, ' the ' + race_display(2, pl0.race, 0));

              if is_online(pl0.name2, online_player) then
              begin
                sd(14, ' (awake)');
              end else if pl0.hps < 1 then
              begin
                sd(config.textcolor, ' (' + ulred + 'dead' + config.textcol1 + ')');
              end else
              begin
                sd(config.textcolor, ' (sleeping)');
              end;

              {days left in prison}
              x := pl0.daysinprison;
              if x = 0 then x := 1;
              if x = 1 then daystr := 'day'
              else daystr := 'days';

              d(config.textcolor, ' (' + uwhite + commastr(x) + config.textcol1 + ' ' + daystr + ' left)');

              {pause listing?}
              Inc(counter);
              if counter > global_screenlines - 2 then
              begin
                counter := 0;
                if confirm('Continue search', 'Y') = False then
                begin
                  abort := True;
                end;
              end;

            end;

            if abort then break;

          end; {for j:= .end.}

          if abort then break;

        end; {for i:= .end.}

        if (k = 0) and (abort = False) then
        begin
          d(6, 'You are the only prisoner here right now!');
        end;

        {display how many days player must stay in jail}
        x := player.daysinprison;
        if x = 0 then x := 1;
        if x = 1 then daystr := 'day'
        else daystr := 'days';

        d(config.textcolor, 'You have ' + uwhite + commastr(x) + config.textcol1 + ' ' + daystr + ' left in prison.');

      end;

    end; {case .end.}

  until cho = 'Q';

  crlf;
  d(5, 'You cover yourself with some hay and try to get some sleep.');
  d(5, 'It will be a long and cold night with the rats...');
  crlf;

  normal_exit;

end; {The_Prison *end*}

end. {Unit PrisonC .end.}
