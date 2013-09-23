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



unit GoodC; {Usurper - good deeds}

interface

procedure Good_Deeds;

implementation

uses
  Init, Cms, Jakob,
  News, Various, Various2,
  Online;

var refresh: boolean;

procedure Meny;
begin
  clearscreen;
  crlf;
  d(5, '-*- Good Deeds -*-');
  crlf;
  d(config.textcolor, 'You feel that your soul is in need of salvation.');
  d(config.textcolor, 'Doing good is a virtue.');
  crlf;
  menu('(G)ive to the poor');
  menu('(C)hurch collect');
  menu('(B)lessing');
  menu('(R)eturn to street');
end;

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['G',
                       'C',
                       'B',
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
      sd(config.textcolor, 'Good Deeds (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, 'Good Deeds (G,C,B,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;
end;

procedure Good_Deeds;
const never: boolean = False;
var
  cho: char;
  xx:  longint;

begin

  repeat

    {update player location, if necessary}
    if onliner.location <> onloc_church then
    begin
      refresh := True;
      onliner.location := onloc_church;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, Onliner);
    end;

    display_menu(True, True);

    cho := upcase(getchar);

    case cho of
      '?': begin {menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'G': begin {give to the poor .start.}
        crlf;
        crlf;
        d(config.textcolor, 'You have ' + uyellow + commastr(player.gold) + config.textcol1 + ' ' + many_money(player.gold));
        d(config.textcolor, 'How much can you spare to the poor');
        sd(config.textcolor, ':');

        xx := get_number(0, player.gold);

        if (xx <= player.gold) and (xx > 0) then
        begin
          crlf;
          d(config.textcolor, 'Your contribution of ' + uyellow + commastr(xx) + config.textcol1 +
            ' ' + many_money(xx) + ' is appreciated.');
          d(config.textcolor, 'You feel a bit better inside now.');
          decplayermoney(player, xx);
          xx := xx div 10;
          if xx < 1 then
            xx := 1;
          Give_Chivalry(player, xx);
          Dec(player.chivnr);

          {news-paper}
          newsy(True,
            'Good-Doer',
            ' ' + uplc + player.name2 + config.textcol1 + ' gave money to the poor.',
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
      'C': begin {church collect .start.}
        crlf;
        crlf;
        d(config.textcolor, 'You have ' + uyellow + commastr(player.gold) + config.textcol1 + ' ' + many_money(player.gold));
        d(config.textcolor, 'How much do you want to give to the Church');
        sd(config.textcolor, ':');
        xx := get_number(0, player.gold);

        if xx > player.gold then
        begin
          d(12, 'Scoundrel! You don''t have that much!');
        end else
        if (xx <= player.gold) and (xx > 0) then
        begin

          crlf;
          d(config.textcolor, 'Your contribution of ' + uyellow + commastr(xx) + config.textcol1 +
            ' ' + many_money(xx) + ' is appreciated.');
          d(config.textcolor, 'Your virtue and support from the Church increase.');
          crlf;
          d(config.textcolor, 'You are blessed by Bishop ' + uplc + config.bishop + config.textcol1 + '.');

          decplayermoney(player, xx);
          xx := xx div 11;
          if xx < 1 then
            xx := 1;

          Give_Chivalry(player, xx);
          Dec(player.chivnr);

          {news-paper}
          newsy(True,
            'Good-Doer',
            ' ' + uplc + player.name2 + config.textcol1 + ' donated money to the Church.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

        end;

      end;       {church collect .end.}

      'B': begin {blessing .start.}
        if player.dark < 1 then
        begin
          crlf;
          d(14, 'Your soul is in no need of salvation (lucky you).');
        end else
        begin
          crlf;
          d(config.textcolor, 'You have ' + uyellow + commastr(player.gold) + config.textcol1 +
            ' ' + many_money(player.gold));
          d(config.textcolor, 'How much do you want to give for a blessing');
          sd(config.textcolor, ':');
          xx := get_number(0, player.gold);

          if (xx <= player.gold) and (xx > 0) then
          begin
            crlf;
            d(config.textcolor, 'Your contribution of ' + uyellow + commastr(xx) + config.textcol1 +
              ' ' + many_money(xx) + ' give you salvation.');
            d(config.textcolor, 'Your dark soul lightens.');

            decplayermoney(player, xx);

            xx := xx div 15;
            if xx < 1 then
              xx := 1;

            Give_Chivalry(player, xx);

            Dec(player.chivnr);

            {news-paper}
            newsy(True,
              'Blessed',
              ' ' + uplc + player.name2 + config.textcol1 + ' purchased a blessing.',
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
      end;       {blessing .end.}
      'R': begin {return}
        break;
      end;

    end;       {case .end.}

  until never; {never leave this loop}

  crlf;

end; {Good_Deeds *end*}

end. {Unit GoodC .end.}
