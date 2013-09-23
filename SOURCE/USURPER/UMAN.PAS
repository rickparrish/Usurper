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

unit Uman; {Usurper - The Uman Cave}

interface

procedure Uman_Cave;

implementation

uses
  Init, Cms, Jakob,
  Statusc, News, Mail,
  Online, Various, Various2,
  Various3, File_Io;

const maxlist = 250;
var refresh: boolean;

var
  list:      array [1..maxlist] of ^s70;
  list2:     array [1..maxlist] of ^longint;

procedure Meny; {uman caves - main menu}
begin

  clearscreen;
  crlf;
  d(11, '** Cave of Uman **');
  crlf;
  d(config.textcolor, 'Hidden deep in the mountain, Uman is the oasis for many');
  d(config.textcolor, 'travellers seeking a place of refuge.');
  crlf;
  menu('(H)igh and Low');
  menu('(T)ame the Bear');
  menu('(I)ndian Wrestling');
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
      sd(config.textcolor, 'Uman Cave (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, 'Uman Cave (H,T,I,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

function Easy_Target(x: longint): s30;
var s: s30;
begin

  case x of -32000.. -300: s := 'Impossible'; -299.. -100: s := 'Very Tough'; -99.. -50: s := 'Tough';
    -49.. -20: s := 'Difficult'; -19..5: s := 'Interesting';
    6..10: s := 'Pretty Easy';
    11..75: s := 'Easy';
    76..150: s := 'Very Easy';
    else s := 'You can''t lose';
  end; {case .end.}

       {return result}
  easy_target := s;

end; {easy_target *end*}

procedure Init_List; {get mem}
var i: integer;
begin

  for i := 1 to maxlist do
  begin
    new(list[i]);
    new(list2[i]);

    list[i]^ := '';
    list2[i]^ := 0;
  end; {for i:= .end.}

end;   {init_list *end*}

procedure Remove_List; {dispose pointer variables}
var i: integer;
begin

  for i := 1 to maxlist do
  begin
    dispose(list[i]);
    dispose(list2[i]);
  end; {for i:= .end.}

end;   {remove_list *end*}

procedure Sort_List(antal: integer); {sort routine}
var gap:      integer;
  x, i, j, k: integer;
  xx:         s70;
  yy:         longint;
begin

  x := antal;
  gap := x div 2;

  while gap > 0 do
  begin
    for i := (gap + 1) to x do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if list2[j]^ < list2[k]^ then
        begin
          j := 0;
        end else
        begin
          xx := list[j]^;
          yy := list2[j]^;
          list[j]^ := list[k]^;
          list2[j]^ := list2[k]^;
          list[k]^ := xx;
          list2[k]^ := yy;
          j := j - gap;
        end;
      end; {while .end.}
    end;
    gap := gap div 2;
  end; {while .end.}

end;   {sort_list *end*}

procedure Uman_Cave;
const wwtries = 15; {wrestlings memory#}
var

  ch, cho:     char;

  s:           string;
  a, sl:   s70;

  y:           integer;

  x, xx, size: longint;

  noway, win, go, search: boolean;

  txt:         Text;

  k:           byte;
  i, j, price, xpprice: longint;
  bearmood:    byte;
  fruits:      byte;
  z, insats:   integer;
  rounds:      byte;
  risk:        byte;

  p1str, p2str: longint;   {indian wrestling; players power}
  p1orig, p2orig: longint; {original strength}

  xpreward:    longint;

  lose1, lose2, rest1, rest2, newgame, leave_uman: boolean;

  alfought:    array[1..wwtries] of ^s30; {"already fought" memory}

  pl0:         userrec; {User Record}

begin

  {init & reset "already fought" memory}
  for i := 1 to wwtries do
  begin
    new(alfought[i]);
    alfought[i]^ := '';
  end;

  {enter main loop}
  leave_uman := False;
  repeat

    {update player location, if necessary}
    if onliner.location <> onloc_umanrest then
    begin
      refresh := True;
      onliner.location := onloc_umanrest;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    if player.ear = 1 then
    begin
      who_is_here;
    end;

    case global_auto_probe of
      NoWhere: begin
        display_menu(True, True);
        cho := upcase(getchar);
      end;
      UmanCave: begin
        crlf;
        d(config.textcolor, 'You have arrived to the hot gambling club!');
        global_auto_probe := Nowhere;
        cho := '?';
      end;
    end; {case .end.}

         {evaluate user-input}
    case cho of
      '?': begin {display menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;
      'R': begin {return}
        crlf;
        crlf;
        d(10, 'You head back.');
        leave_uman := True;
      end;
      'I': begin {indian wrestling}
                 {the cia planted some grass on me!}
        s := '';

        crlf;
        crlf;
        d(12, '* Indian Wrestling *');
        d(11, ' last games');

        sd(15, '');
        display_file(global_indianfile);

        repeat
          newgame := False;
          go := False;
          repeat
            z := 0;
            d(4, 'Who would you like to meet?');
            d(4, '(enter ? to see recommended opponents)');
            sd(config.textcolor, ':');

            s := get_string(20);
            a := upcasestr(s);
            s := upcasestr(player.name2);

            if a = '?' then
            begin
              {START list recommended opponents START}
              init_list;
              x := 0;

              for i := 1 to 2 do
              begin

                case i of
                  1: size := fs(FsPlayer);
                  2: size := fs(FsNpc);
                end;

                for j := 1 to size do
                begin
                  if x < maxlist then
                  begin

                    if load_character(pl0, i, j) = True then
                    begin

                      if (pl0.name2 <> global_delname2) and
                        (pl0.deleted = False) and
                        (pl0.name2 <> player.name2) and
                        (pl0.king = False) and
                        (pl0.name2 <> '') and
                        (is_online(pl0.name2, online_player) = False) then
                      begin

                        Inc(x);
                        list[x]^ := pl0.name2;
                        list2[x]^ := pl0.strength;
                      end;
                    end;
                  end;
                end; {for j:= .end.}
              end;   {for i:= .end.}

                     {sort list}
              sort_list(x);

              j := 0;
              for i := 1 to x do
              begin
                s := commastr(i) + ' ' + list[i]^;
                s := ljust(s, 15);
                sd(11, s + ' - ');

                s := easy_target(player.strength - list2[i]^);
                sd(15, ljust(s, 15));

                for y := 1 to wwtries do
                begin
                  if alfought[y]^ = list[i]^ then
                  begin
                    sd(14, '*You have fought ' + list[i]^ + '*');
                    break;
                  end;
                end; {for y:= .end.}
                crlf;

                Inc(j);
                if j > global_screenlines - 2 then
                begin
                  j := 0;
                  if confirm('Continue list', 'Y') = False then
                  begin
                    break;
                  end;
                end;
              end;

              remove_list;
              {END list recommended opponents END}
            end else
            begin
              search := False;

              for i := 1 to 2 do
              begin
                case i of
                  1: size := fs(FsPlayer);
                  2: size := fs(FsNpc);
                end;

                for j := 1 to size do
                begin

                  if load_character(pl0, i, j) = True then
                  begin

                    if (findsub(a, pl0.name2)) and
                      (pl0.name2 <> global_delname2) and
                      (pl0.name2 <> player.name2) and
                      (pl0.deleted = False) then
                    begin

                      if confirm(uplc + pl0.name2 + config.textcol1, 'N') = True then
                      begin
                        if pl0.king = True then
                        begin
                          if pl0.sex = 1 then
                            sl := 'KING'
                          else sl := 'QUEEN';
                          d(12, 'YOU MAY NOT CHALLENGE THE ' + sl);
                        end else
                        if is_online(pl0.name2, online_player) = True then
                        begin
                          d(global_plycol, pl0.name2 + ulred + ' is busy right now!');
                        end else
                        begin
                          noway := False;
                          for k := 1 to wwtries do
                          begin
                            if alfought[k]^ = pl0.name2 then
                            begin
                              d(12, 'You have already wrestled ' + uplc + pl0.name2 + ulred + '!');
                              noway := True;
                              break;
                            end;
                          end; {for k:= .end.}

                          if noway = False then
                          begin
                            z := i;
                            search := True;
                            break;
                          end;

                        end;
                      end else
                      begin
                        if confirm('Continue search ', 'Y') = False then
                        begin
                          z := -1;
                          break;
                        end;
                      end;
                    end;
                  end;
                end; {for j= .end.}

                if (z = -1) or (search) then
                  break;

              end; {for i= .end.}
            end;

            if z <> 0 then
              go := True;

          until go = True;

          if (z > 0) and (player.wrestlings < 1) then
          begin
            crlf;
            d(12, 'Sorry, You have used up your luck in this game!');
            pause;
          end else
          if z > 0 then
          begin

            if add_shadow(SAdd, pl0, player.name2, 'wrestling ' + uplc + player.name2 + config.textcol1, 0) = False then
            begin
              {unable to add pl0}
              crlf;
              d(global_plycol, pl0.name2 + config.textcol1 + ' is busy right now!');
              pause;
            end else
            begin

              for j := 1 to wwtries do
              begin
                if alfought[j]^ = '' then
                begin
                  alfought[j]^ := pl0.name2;
                  break;
                end;
              end; {for j:= .end.}

              Dec(player.wrestlings);

              {update onliner location}
              onliner.location := onloc_umanwrest;
              onliner.doing := 'wrestling ' + uplc + pl0.name2 + config.textcol1;
              add_onliner(OUpdateLocation, onliner);

              sd(15, 'TELEPORTING ');
              sd(global_plycol, pl0.name2);
              sd(15, ' ... ');
              delay2(500);
              sd(global_plycol, pl0.name2);
              sd(15, ' has arrived!');

              crlf;
              if (player.team <> '') and (player.team = pl0.team) then
              begin
                sd(global_talkcol, 'WE ARE IN THE SAME TEAM STUPID!' + config.textcol1 + ', ');
                sd(global_plycol, pl0.name2);
                d(config.textcolor, ' complains.');
              end;

              x := player.strength - pl0.strength;
              if x > 32000 then
                x := 32000;
              if x < -32000 then
                x := -32000;

              case x of -32000.. -300: begin
                  sd(config.textcolor, 'Compared to you, ');
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, ' is a GIANT! You will certainly lose.');
                  xpreward := player.level * 90;
                end; -299.. -100: begin
                  sd(global_plycol, pl0.name2 + 's');
                  sd(config.textcolor, ' muscles are much bigger than yours!');
                  xpreward := player.level * 60;
                end; -99..0: begin
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, ' is a pretty strong ');
                  if pl0.sex = 1 then
                    d(config.textcolor, 'guy!')
                  else d(config.textcolor, 'girl!');
                  d(config.textcolor, 'This will be a close fight!');
                  xpreward := player.level * 35;
                end;
                1..25: begin
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, ' and you have pretty much the same strength.');
                  xpreward := player.level * 25;
                end;
                26..75: begin
                  sd(config.textcolor, 'You should beat ');
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, '.');
                  xpreward := player.level * 15;
                end;
                76..150: begin
                  sd(config.textcolor, 'You should overcome ');
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, ' easy!');
                  xpreward := player.level * 12;
                end else begin
                  sd(global_plycol, pl0.name2);
                  sd(config.textcolor, ' is a wimp! And you should break ' + sex[pl0.sex] + ' down');
                  sd(config.textcolor, ' in seconds.');
                  xpreward := player.level * 10;
                end;
              end; {case .end.}

              if xpreward < 50 then
                xpreward := 50;
              if xpreward > 35000 then
                xpreward := 35000;

              crlf;
              crlf;
              case random(3) of
                0: begin
                  sd(11, pl0.name2);
                  d(config.textcolor, ' shows you ' + sex3[pl0.sex] + ' muscles.');
                  sd(global_talkcol, 'PRETTY NICE HUH?' + config.textcol1 + ', ');
                  sd(global_plycol, pl0.name2);
                  d(config.textcolor, ' boasts.');
                  d(global_talkcol, 'YOU ARE A LOSER ' + player.name2 + ' AND ALWAYS WILL BE! HA HA!' +
                    config.textcol1 + ',');
                end;
                1: begin
                  sd(global_plycol, pl0.name2);
                  d(config.textcolor, ' laughs when ' + sex2[pl0.sex] + ' sees your forearms.');
                  sd(global_talkcol, 'My GrandMother can beat You!' + config.textcol1 + ', ');
                  sd(global_plycol, pl0.name2);
                  d(config.textcolor, ' screams!');
                end;
                2: begin
                  sd(global_talkcol, 'Oh! I''m soooo scared!' + config.textcol1 + ', ');
                  sd(global_plycol, pl0.name2);
                  d(config.textcolor, ' says in a ridiculing voice.');
                end;
              end; {case .end.}

              pause;
              crlf;

              p1str := player.strength;
              p2str := pl0.strength;

              if (p1str > 10000) and (p2str > 10000) then
                x := 10000
              else
              if (p1str > 1000) and (p2str > 1000) then
                x := 1000
              else
              if (p1str > 100) and (p2str > 100) then
                x := 100
              else
              if (p1str > 10) and (p2str > 10) then
                x := 10
              else x := 0;

              if x > 0 then
              begin
                p1str := p1str div x;
                p2str := p2str div x;
              end;
              if p1str < 2 then
                p1str := 2;
              if p2str < 2 then
                p2str := 2;
              p1orig := p1str;
              p2orig := p2str;


              repeat
                lose1 := False;
                lose2 := False;
                rest1 := False;
                rest2 := False;

                ch := '?';
                repeat
                  if ch = '?' then
                  begin
                    crlf;
                    d(4, mkstring(20, '*'));
                    sd(12, 'Your power : ');
                    d(4, commastr(p1str) + '/' + commastr(p1orig));

                    sd(global_plycol, pl0.name2 + 's' + ulred + ' power : ');
                    d(4, commastr(p2str) + '/' + commastr(p2orig));

                    menu('(1) press firmly');
                    menu('(2) power move');
                    menu('(3) rest');
                    sd(config.textcolor, 'Your move :');

                  end;

                  {get user-input}
                  ch := upcase(getchar);

                  if (ch = '3') and (p1str >= p1orig) then
                  begin
                    crlf;
                    d(15, 'YOU NEED NO REST!');
                    ch := '?';
                  end;

                until ch in ['1', '2', '3'];
                crlf;
                crlf;

                {evaluate user-input}
                case ch of
                  '1': begin {press firmly}
                    d(11, 'You put pressure on ' + uplc + pl0.name2 + 's' + ulcyan + ' arm!');
                    lose2 := True;
                  end;
                  '2': begin {power move}
                    d(11, 'POWER MOVE!');
                    if random(5) = 0 then
                    begin
                      d(global_plycol, pl0.name2 + uwhite + ' FELL FOR IT!');
                      Dec(p2str, 6);
                    end else
                    begin
                      d(12, 'YOU FAILED!');
                      Dec(p1str, 2);
                    end;
                  end;
                  '3': begin {rest}
                    d(11, 'You rest.');
                    rest1 := True;
                  end;
                end; {case .end.}


                {other players move}
                case random(3) of
                  0: begin {press firmly}
                    d(global_plycol, pl0.name2 + ulcyan + ' puts pressure on Your arm!');
                    lose1 := True;
                  end;
                  1: begin {power move}
                    d(global_plycol, pl0.name2 + ulcyan + ' tried a POWER MOVE!');
                    if random(5) = 0 then
                    begin
                      d(15, 'YOU FELL FOR IT!');
                      Dec(p1str, 6);
                    end else
                    begin
                      d(12, 'IT FAILED!');
                      Dec(p2str, 2);
                    end;
                  end;
                  2: begin {rest}
                    if p2str < p2orig then
                    begin
                      d(global_plycol, pl0.name2 + ulcyan + ' rests.');
                      rest2 := True;
                    end else
                    begin
                      d(global_plycol, pl0.name2 + ulcyan + ' puts pressure on Your arm!');
                      lose1 := True;
                    end;
                  end;
                end; {case .end.}

                     {losses}
                if lose1 then
                  Dec(p1str, 2);
                if lose2 then
                  Dec(p2str, 2);

                {rests}
                if rest1 then
                  Inc(p1str, 1);
                if rest2 then
                  Inc(p2str, 1);

              until (p1str < 1) or (p2str < 1);

              crlf;
              s := '';
              if (p1str < 1) and (p2str < 1) then
              begin
                crlf;
                d(14, 'A DRAW!');
                sd(config.textcolor, 'You and ');
                sd(global_plycol, pl0.name2);
                d(config.textcolor, ' shake hands after this close competition.');
                s := player.name2 + ' and ' + pl0.name2 + ' had a draw';

                {inform opponent}
                post(MailSend,
                  pl0.name2,
                  pl0.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  umailheadc + 'Indian Wrestling' + config.textcol1,
                  mkstring(16, underscore),
                  uplc + player.name2 + config.textcol1 + ' dared you in a Wrestling match.',
                  'It was a ' + uwhite + 'DRAW' + config.textcol1 + '!',
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
                  'Indian Wrestling',
                  ' ' + uplc + player.name2 + config.textcol1 + ' and ' + uplc + pl0.name2 + config.textcol1 + ' had a draw.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

              end else
              if p1str < 1 then
              begin
                d(config.textcolor, 'You are exhausted! No strength is left in your arm...');
                sd(config.textcolor, 'With a grin on ' + sex3[pl0.sex] + ' face ');
                sd(global_plycol, pl0.name2);
                d(config.textcolor, ' breaks your arm down on the table.');

                crlf;
                d(12, 'YOU LOST! GO AND TRAIN SOME MORE YOU WEAKLING!');

                Inc(pl0.exp, xpreward);
                user_save(pl0);

                {mail offline opponent}
                post(MailSend,
                  pl0.name2,
                  pl0.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  umailheadc + 'Indian Wrestling' + config.textcol1,
                  mkstring(16, underscore),
                  uplc + player.name2 + config.textcol1 + ' dared you in a Wrestling match.',
                  'You WON and gained ' + uwhite + commastr(xpreward) + config.textcol1 + ' experience points.',
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
                  'Indian Wrestling',
                  ' ' + uplc + player.name2 + config.textcol1 + ' lost to ' + uplc + pl0.name2 + config.textcol1 + '.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                s := pl0.name2 + ' beat ' + player.name2;

              end else
              if p2str < 1 then
              begin
                sd(global_plycol, pl0.name2);
                d(config.textcolor, ' is exhausted! With sweat pouring down ' + sex3[pl0.sex] + ' forehead');
                d(config.textcolor, sex2[pl0.sex] + ' tries a last desperate comeback!');
                d(config.textcolor, 'But you have it all under control.');

                crlf;
                d(15, 'YOU WON! GOOD MUSCLE-WORK!');
                Inc(player.exp, xpreward);
                sd(config.textcolor, 'You gain ');
                sd(15, commastr(xpreward));
                d(config.textcolor, ' experience points.');

                {news-paper}
                newsy(True,
                  'Indian Wrestling',
                  ' ' + uplc + player.name2 + config.textcol1 + ' beat ' + uplc + pl0.name2 + config.textcol1 + '.',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                {mail offline opponent}
                post(MailSend,
                  pl0.name2,
                  pl0.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  umailheadc + 'Indian Wrestling' + config.textcol1,
                  mkstring(16, underscore),
                  uplc + player.name2 + config.textcol1 + ' dared you in a Wrestling match.',
                  ulred + 'You LOST!' + config.textcol1,
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

                s := player.name2 + ' beat ' + pl0.name2;
              end;

              if s <> '' then
              begin
                {don't forget to write result in the indian.dat file}
                s := s + ' [' + give_me_time + ', ' + fix_date(todays_date) + ']';

                if f_exists(global_indianfile) = False then
                begin
                  if open_txtfile(trewrite, txt, global_indianfile) then
                  begin
                    writeln_to_text(txt, s);
                    close_text(txt);
                  end else
                  begin
                    unable_to_create(global_indianfile, access_error);
                  end;
                end else
                begin
                  if open_txtfile(tappend, txt, global_indianfile) then
                  begin
                    writeln_to_text(txt, s);
                    close_text(txt);
                  end else
                  begin
                    unable_to_access(global_indianfile, access_error);
                  end;
                end;
              end;

              {remove offline opponent}
              add_shadow(SRemove, pl0, player.name2, '', 0);
              onliner.location := onloc_umanwrest;
              if player.wrestlings = 0 then
                pause;
              if (player.wrestlings > 0) and
                (confirm('Another Match', 'Y') = True) then
              begin
                newgame := True;
              end;

            end;
          end;

        until newgame = False;

      end;
      'T': begin {bear taming}

        if player.umanbeartries >= config.beartametries then
        begin
          crlf;
          crlf;
          d(15, 'You have had your chances with the Bear today!');
          d(15, 'Return tomorrow for more fun.');
          crlf;
          pause;
        end else
        begin
          rounds := 7;
          insats := 2500;

          price := player.level * (random(7) + 2);
          price := price * 25;

          xpprice := player.level * 150;

          if price <= insats then
            price := insats * 2;

          crlf;
          crlf;
          d(14, 'Tame the BEAR');
          sd(config.textcolor, 'You must make the Bear to sit in ');
          sd(5, commastr(rounds));
          d(config.textcolor, ' rounds.');
          d(config.textcolor, 'You will have a whip and some fruits which you');
          d(config.textcolor, 'can use to achieve your goal.');
          d(config.textcolor, 'The Bear will respond in different ways to your actions.');
          d(config.textcolor, 'Depending on its mood it might attack or obey you.');
          d(config.textcolor, '(the trick is to know when to use what)');

          crlf;
          sd(config.textcolor, 'If you succeed you will collect ');
          sd(14, commastr(price));
          d(config.textcolor, ' ' + many_money(price) + '.');

          sd(config.textcolor, 'The Entrance Fee is ');
          sd(14, commastr(insats));
          d(config.textcolor, ' ' + many_money(insats) + '.');

          crlf;
          if player.gold < insats then
          begin
            d(11, 'You can''t afford to participate!');
            crlf;
            pause;
          end else
          if confirm('Go ahead ', 'N') = True then
          begin

            if onliner.location <> onloc_umantame then
            begin
              refresh := True;
              onliner.location := onloc_umantame;
              onliner.doing := location_desc(onliner.location);
              add_onliner(OUpdateLocation, onliner);
            end;

            Inc(player.umanbeartries);
            decplayermoney(player, insats);

            crlf;
            bearmood := 5; {0=t„mjd .. 5=indifferent ..10=galen av ilska}
            fruits := 15;

            repeat
              case bearmood of
                0: s := 'The Bear is sitting down! YOU''VE DONE IT!';
                1: s := 'The Bear loves you!';
                2: s := 'The Bear licks your feet.';
                3: s := 'The Bear is very Happy.';
                4: s := 'The Bear is happy.';
                5: s := 'The Bear looks indifferent.';
                6: s := 'The Bear looks nervous.';
                7: s := 'The Bear growls.';
                8: s := 'The Bear looks upset.';
                9: s := 'The Bear is angry!';
                10: s := 'The Bear hates your guts!';
              end;
              d(15, s);

              if (bearmood > 8) and (random(2) = 0) then
              begin
                x := 8 + random(4);
                sd(config.textcolor, 'The Bear claws you for ');
                sd(15, commastr(x));
                d(config.textcolor, ' points.');
                Dec(player.hps, x);
              end;

              if bearmood <> 0 then
              begin
                crlf;
                d(8, commastr(rounds) + ' rounds left');
                menu('(F)ruit');
                menu('(W)hip');
                sd(config.textcolor, ':');
                repeat
                  ch := upcase(getchar);
                until ch in ['F', 'W'];

                Dec(rounds);

                case ch of
                  'F': begin {FRUIT}
                    d(config.textcolor, 'You throw a fruit to the Bear...');
                    case bearmood of
                      1: risk := 10;
                      2: risk := 9;
                      3: risk := 8;
                      4: risk := 7;
                      5: risk := 6;
                      6: risk := 5;
                      7: risk := 4;
                      8: risk := 3;
                      9: risk := 2;
                      10: risk := 2;
                    end;

                    if random(risk) = 0 then
                    begin
                      Inc(bearmood);
                      d(12, 'BAD MOVE!');
                    end else
                    begin
                      Dec(bearmood);
                      d(15, 'GOOD MOVE!');
                    end;

                  end;
                  'W': begin {WHIP}
                    d(15, 'KLATSCH!');
                    case bearmood of
                      1: risk := 2;
                      2: risk := 2;
                      3: risk := 3;
                      4: risk := 4;
                      5: risk := 5;
                      6: risk := 6;
                      7: risk := 7;
                      8: risk := 8;
                      9: risk := 9;
                      10: risk := 10;
                    end;

                    if random(risk) = 0 then
                    begin
                      Inc(bearmood);
                      d(12, 'BAD MOVE!');
                    end else
                    begin
                      Dec(bearmood);
                      d(15, 'GOOD MOVE!');
                    end;
                  end;
                end; {case .end.}
              end;

              if bearmood > 10 then
                bearmood := 10;

              if bearmood < 1 then
                d(15, 'The Bear is sitting down! YOU''VE DONE IT!');

            until (player.hps < 1) or (bearmood < 1) or (rounds < 1);

            if player.hps <= 0 then
            begin
              d(config.textcolor, 'YOU ARE DEAD!');

              {player.allowed:=false;}
              Reduce_Player_Resurrections(player, True);

              {news-paper}
              newsy(True,
                'Death at the Casino!',
                ' ' + uplc + player.name2 + config.textcol1 + ' died trying to tame a bear!',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              normal_exit;

            end else
            if (rounds >= 0) and (bearmood = 0) then
            begin
              crlf;
              d(5, 'YOU WON!');
              sd(14, commastr(price));
              d(config.textcolor, ' ' + many_money(price) + ' in your pocket.');

              sd(config.textcolor, 'You gain ');
              sd(14, commastr(xpprice));
              d(config.textcolor, ' experience points.');

              Inc(player.exp, xpprice);
              incplayermoney(player, price);

              {news-paper}
              newsy(True,
                'Impressive',
                ' ' + uplc + player.name2 + config.textcol1 + ' tamed a wild Bear.',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              pause;
            end else
            begin
              crlf;
              d(12, 'Sorry! You didn''t make it in time!');
              d(12, 'You lose!');
              pause;
            end;
          end;

        end;

      end;       {tame the bear .end.}

      'H': begin {high & low}

        crlf;
        crlf;

        d(config.textcolor, 'You take a seat at one of the gambling tables.');
        ch := 'H';

        case ch of
          'H': begin {high or low}
            repeat
              crlf;
              sd(config.textcolor, 'You have ');
              sd(14, commastr(player.gold));
              d(config.textcolor, ' ' + many_money(player.gold) + '.');
              sd(config.textcolor, 'Enter your bet (max 15,000) : ');

              xx := get_number(0, 15000);

              if (xx > player.gold) or (xx = 0) then
              begin
                d(15, 'Get lost!');
                break;
              end;

              crlf;
              menu2('(H)igh or ');
              menu2('(L)ow card :');
              sd(config.textcolor, ':');
              repeat
                ch := upcase(getchar);
              until ch in ['H', 'L'];

              crlf;
              crlf;

              x := random(10) + 1;
              win := False;
              if (ch = 'H') and (x > 5) then
                win := True;
              if (ch = 'L') and (x < 6) then
                win := True;

              sd(config.textcolor, 'The croupier picked :');
              d(14, commastr(x));

              if win then
              begin
                d(15, 'YOU WIN!');
                incplayermoney(player, xx);
              end else
              begin
                d(12, 'YOU LOSE!');
                decplayermoney(player, xx);
              end;

              crlf;
              if confirm('Play again', 'Y') = False then
              begin
                break;
              end;

            until ch = 'X';
          end;
        end;

      end; {high or low .end.}

    end;   {case .end.}

  until leave_uman = True;
  crlf;

  {dispose pointer vars}
  for i := 1 to wwtries do
  begin
    dispose(alfought[i]);
  end;

end; {Uman_Cave *end*}

end. {Unit Uman .end.}
