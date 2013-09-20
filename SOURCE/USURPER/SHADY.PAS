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


unit Shady; {Usurper - Shady Shops}

interface

procedure Shady_Shops;

implementation

uses
  Init, Cms, Jakob,
  Groggo, Bobs, Alchemi,
  Statusc, Orb, News,
  Drugs, Steroids, Various,
  Various2, Online, File_Io;

var
  owner:   s70;
  refresh: boolean;

procedure Meny; {shady shops menu}
const offset = 25;
begin

  clearscreen;
  crlf;
  d(5, '-*- Shady Shops -*-');
  crlf;
  d(config.textcolor, 'You stumble in to the dark areas of the town.');
  d(config.textcolor, 'It is here where you can get what you want, without');
  d(config.textcolor, 'any questions being asked. Trouble is never far away in these');
  d(config.textcolor, 'neighbourhoods.');
  crlf;

  menu2(ljust('(D)rug Palace', offset));
  menu('(S)teroid Shop');

  menu2(ljust('(O)rbs Health Club', offset));
  menu('(G) ' + uplc + owner + config.textcol1 + ' Magic Services');

  menu2(ljust('(B)eer Hut', offset));
  menu('(A)lchemists Heaven');

  menu('(R)eturn to street');

end; {meny .end.}

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['B',
                       'A',
                       'G',
                       'O',
                       'S',
                       'D',
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
      sd(config.textcolor, 'Shady Shops (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Shady Shops (B,A,G,O,S,D,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Shady_Shops;
var
  cho:  char;
  y:    word;
  done: boolean;
  s:    s30;

  king: kingrec;

begin

  {fetching Groggos name from .CFG}
  owner := cfg_string(21);
  if owner = '' then
  begin
    owner := 'Groggo';
  end;

  done := False;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_darkalley then
    begin
      refresh := True;
      onliner.location := onloc_darkalley;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {auto-travel}
    case global_auto_probe of
      NoWhere: begin
        display_menu(True, True);
        cho := upcase(getchar);
      end;
      UmanCave: begin
        cho := 'R';
      end;
    end; {case .end.}

         {filter out disabled options}
    if (cho = 'D') and (config.allow_drugs = False) then
    begin
      crlf;
      d(12, 'Drugs are banned in this game.');
      pause;
      cho := ' ';
    end else
    if (cho = 'S') and (config.allow_steroids = False) then
    begin
      crlf;
      d(12, 'Steroids are banned in this game.');
      pause;
      cho := ' ';
    end;

    case cho of
      '?': begin
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'R': begin {return}
        done := True;
      end;
      'O': begin {orbs drink center}

        load_king(fload, king);

        if (king.shop_orbs = False) and (player.king = False) then
        begin
          crlf;
          d(12, 'Orbs Health Club is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
        end else
        begin
          crlf;
          crlf;
          d(config.textcolor, 'You decide to enter this somewhat dubious place.');
          orb_center;
        end;
      end;
      'A': begin {alchemist secret order}
        if player.class <> Alchemist then
        begin
          crlf;
          d(5, 'The guards outside the building humiliate you and block the entrance.');
          d(5, 'It seems as only Alchemists are allowed.');
        end else
        begin
          alchemisty;
        end;
      end;
      'B': begin {Bobs Beer Hut}

        muffis;
        if global_registered = True then
        begin
          load_king(fload, king);

          if (king.shop_bobs = False) and (player.king = False) then
          begin
            crlf;
            d(12, config.bobsplace + ' is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
          end else
          begin
            crlf;
            crlf;
            d(config.textcolor, 'You enter ' + ulcyan + config.bobsplace);
            bobs_inn;
          end;
        end else
        begin
          crlf;
          d(12, 'Sorry, only available in the registered version.');
          pause;
        end;

      end;
      'G': begin {Evil Magic}

        load_king(fload, king);

        if (king.shop_evilmagic = False) and (player.king = False) then
        begin
          crlf;
          d(12, owner + 's place is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
        end else
        begin
          Groggos_Magic;
        end;
      end;
      'D': begin {Drugs}
        load_king(fload, king);

        if (king.shop_drugs = False) and (player.king = False) then
        begin
          crlf;
          d(12, 'The Drug Palace is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
        end else
        begin
          Drug_Store;
        end;
      end;
      'S': begin {Steroids}
        load_king(fload, king);

        if (king.shop_steroids = False) and (player.king = False) then
        begin
          crlf;
          d(12, 'The Steroid Shop is closed! (The ' + upcasestr(kingstring(king.sexy)) + 's order!)');
        end else
        begin
          Steroid_Store;
        end;
      end;
    end; {case .end.}

  until done;
  crlf;

end; {shady_shops *end*}

end. {Unit Shady .end.}
