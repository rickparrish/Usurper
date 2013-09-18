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


unit IceCaves; {Usurper - Ice Caves}

interface

uses
  Init;

procedure Ice_Caves(var pl1, pl2, pl3, pl4: Userrec); {Ice Caves}  {TEAM?}

implementation

uses
  Cms, Jakob, Statusc,
  Various, Online, File_io;

const place = 'Ice-Caves';
var
  refresh: boolean;

procedure Meny;
const offset = 22;
begin
  clearscreen;
  crlf;
  d(5, '-*- The ' + place + ' -*-');
  crlf;
  crlf;

  menu('(S)tatus');
  menu('(R)eturn to Dungeons');

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
      sd(config.textcolor, ulcyan + place + config.textcol1 + ' (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin

      crlf;
      sd(15, place + config.textcol1 + ' (S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Ice_Caves;
var
  ice_caves_done: boolean;

  ch: char;

begin

  {intro.text}
  crlf;
  crlf;
  d(config.textcolor, 'You enter the ' + ulcyan + place + config.textcol1);
  crlf;
  pause;

  ice_caves_done := False;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_icecaves then
    begin
      refresh := True;
      onliner.location := onloc_icecaves;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, Onliner);
    end;

    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user input}
    case ch of

      '?': begin {menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'R': begin {return}
        ice_caves_done := True;
      end;
      'S': begin {status}
        status(player);
      end;

    end; {case .end.}

  until ice_caves_done = True;

  crlf;
  crlf;
  d(config.textcolor, 'You leave the ' + ulcyan + place + config.textcol1 + '.');
  crlf;

end;

end. {Unit IceCaves .end.}
