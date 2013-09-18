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



unit Revival; {Usurper - Revival, called from Team Corner}

interface

procedure Resurrect;

implementation

uses
  Init, Cms, Jakob,
  Online, Mail, News,
  Various, Various2, Various3,
  File_Io, SysUtils;

procedure Resurrect;
var
  a:          s70;

  yy:         longint;

  i, j, size: word;

  done, big_done: boolean;

  pl0:        ^UserRec;

begin

  {init pointer var}
  new(pl0);

  big_done := False;
  repeat
    crlf;
    d(config.textcolor, 'Who do you wish to Resurrect? (enter ' + config.textcol2 + '?' + config.textcol1 + ' to see your team)');
    sd(config.textcolor, ':');
    a := get_string(20);
    a := UpperCase(a);

    done := False;

    if a = '?' then
    begin
      display_members(player.team, True);
    end else
    begin
      big_done := True;

      for i := 1 to 2 do
      begin

        if done then break;

        case i of
          1: size := fs(FsPlayer);
          2: size := fs(FsNpc);
        end;

        for j := 1 to SIZE do
        begin

          if done then break;

          load_character(pl0^, i, j);

          if (findsub(a, pl0^.name2)) and
            (pl0^.name2 <> player.name2) and
            (player_active(pl0^, False) = True) and
            (pl0^.team = player.team) then
          begin

            if confirm(uplc + pl0^.name2 + config.textcol1, 'N') = False then
            begin
              done := True;
            end else
            begin

              if pl0^.location = offloc_prison then
              begin
                sd(global_plycol, pl0^.name2);
                d(config.textcolor, ' is in prison and cannot be resurrected!');
              end else if pl0^.hps > 0 then
              begin
                case random(5) of
                  0: begin
                    sd(global_talkcol, 'I feel fine! I don''t need your Hocus Pocus!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, pl0^.name2);
                    d(config.textcolor, ' says.');
                  end;
                  1: begin
                    sd(global_talkcol, 'I''m alive and well!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, pl0^.name2);
                    d(config.textcolor, ' says.');
                  end;
                  2: begin
                    sd(global_talkcol, 'Don''t worry! I feel fine!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, pl0^.name2);
                    d(config.textcolor, ' says.');
                  end;
                  3: begin
                    sd(global_talkcol, 'Resurrect the DEAD! I''m not dead!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, pl0^.name2);
                    d(config.textcolor, ' explains.');
                  end;
                  4: begin
                    sd(global_talkcol, 'Nice thought, but I feel alright!');
                    sd(config.textcolor, ', ');
                    sd(global_plycol, pl0^.name2);
                    d(config.textcolor, ' mutters.');
                  end;
                end;
              end else
              begin

                yy := pl0^.level * 2500;
                crlf;
                sd(config.textcolor, 'The revival process of ');
                sd(global_plycol, pl0^.name2);
                sd(config.textcolor, ' will cost ');
                sd(14, commastr(yy));
                d(config.textcolor, ' ' + many_money(yy) + '.');

                if player.gold < yy then
                begin
                  d(config.textcolor, 'And You don''t have that kind of ' + config.moneytype + '!');
                  done := True;
                  break;
                end else
                begin
                  if confirm('Pay ', 'N') = False then break;
                end;

                decplayermoney(player, yy);

                crlf;
                sd(config.textcolor, 'Approaching ');
                sd(global_plycol, pl0^.name2 + 's ');
                d(config.textcolor, 'coffin you');
                d(config.textcolor, 'recollect all your knowledge of healing.');
                d(config.textcolor, 'The revival process takes a couple of hours');
                sd(config.textcolor, 'But then suddenly ');
                sd(global_plycol, pl0^.name2);
                d(config.textcolor, ' opens');
                d(config.textcolor, sex3[pl0^.sex] + ' eyes and speaks!');
                d(config.textcolor, 'Although looking very pale and worn out,');
                crlf;
                sd(global_plycol, pl0^.name2);
                d(config.textcolor, ' seems to be fit for fight!');
                crlf;

                if pl0^.ai = 'H' then
                begin
                  post(MailSend,
                    pl0^.name2,
                    pl0^.ai,
                    False,
                    mailrequest_nothing,
                    '',
                    umailheadc + 'Team-Report' + config.textcol1,
                    mkstring(11, underscore),
                    'You were resurrected by ' + uplc + player.name2 + config.textcol1 + '!',
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
                end; {post message .end. only necessary if resurrected is human}

                pl0^.hps := pl0^.maxhps;
                pl0^.allowed := True;
                pl0^.resurrections := config.resurrections;

                {save resurrected player}
                user_save(pl0^);

                {put the event in the news}
                case random(2) of
                  0: begin
                    newsy(True,
                      'Return from the Dead',
                      ' ' + uplc + player.name2 + config.textcol1 + ' resurrected ' + uplc + pl0^.name2 + config.textcol1 + '!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');
                  end;
                  1: begin
                    newsy(True,
                      'Revival',
                      ' ' + uplc + player.name2 + config.textcol1 + ' brought ' + uplc + pl0^.name2 + config.textcol1 + ' back from the grave!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');
                  end;
                end; {case .end}

                {tell other online players about this event}
                online_send_to_all(uplc + pl0^.name2 + config.textcol1 + ' has been resurrected!', player.name2, '');

                crlf;
                if confirm('Continue Search for dead members', 'Y') = False then
                begin
                  done := True;
                  break;
                end;

              end;
            end; {confirm .end.}
          end;
        end; {for j:= .end.}
      end; {for i:= .end.}
    end;

  until big_done;

  {dispose of pointer variables}
  dispose(pl0);

end; {Resurrect *end*}

end. {Unit Revival .end.}
