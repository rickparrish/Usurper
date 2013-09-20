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


unit PrisonF; {Usurper, outside the royal prison}

interface

procedure Free_Prisoner; {free a prisoner!}

implementation

uses
  Init, Cms, Jakob,
  Statusc, Various, Various3,
  News, PlvsMon, Plcomp,
  Mail, Online, File_Io;

const captain = 'Ronald'; {captain of the guard *same as in prisonc1.pas}

var refresh: boolean;

procedure Meny;
const offset = 20;
begin
  clearscreen;
  crlf;

  d(5, 'Outside the Royal Prison');
  crlf;
  d(config.textcolor, 'You walk along side the long stretch of cells.');
  d(config.textcolor, 'From the dark pits You can hear the screams from the tortured souls');
  d(config.textcolor, 'deep in the dungeons. The torture masters must be having a great time.');

  crlf;
  menu('(P)risoners');
  menu('(F)ree a prisoner');
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
      sd(config.textcolor, 'Prison walk (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, 'Prison walk (P,F,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Free_Prisoner;
var
  cho:       char;
  i, j, size, y: word;
  attempts:  byte;

  prisoner, guard: UserRec;

  s:         s90;

  finito, found, done: boolean;

  king:      kingrec;

  player_guard: boolean;
  surrender: boolean;

  foes:      byte;
  x:         longint;

  weapon, armor: s30;
  hps:       word;

  pl:        array[1..4] of ^userrec;

  line_counter: byte;
  abort:     boolean;

begin

  global_auto_probe := NoWhere;
  repeat

    {update onliner location, if necessary}
    if (onliner.location <> onloc_prisonwalk) then
    begin
      refresh := True;
      onliner.location := onloc_prisonwalk;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

 { if player.ear=1 then begin
   who_is_here;
  end;
 }
    display_menu(True, True);
    cho := upcase(getchar);

    case cho of
      '?': begin {menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;
      'F': begin {free a prisoner}

                 {only one player at a time may attempt to break into jail}
                 {we must check if any other node is doing this}
        if anybody_on_location(onloc_prisonbreak, player.name2) then
        begin
          crlf;
          crlf;
          d(12, 'Sorry, the Prison is being infiltrated right now!');
          d(12, 'There would be too big a risk to break in!');
          pause;
          crlf;
        end else
        begin

          crlf;
          crlf;
          d(12, 'You prepare to break in!');
          d(config.textcolor, 'Don''t get caught! You will be jailed instantly if the guards');
          d(config.textcolor, 'get you!');
          crlf;

          {Update player location & doing}
          onliner.location := onloc_prisonbreak;
          onliner.doing := location_desc(onliner.location);
          add_onliner(OUpdateLocation, onliner);

          d(config.textcolor, 'Who do you wanna set free?');
          sd(config.textcolor, ':');

          s := get_string(30);

          finito := False;
          found := False;

          {searching among the humans and NPCs}
          for i := 1 to 2 do
          begin

            case i of
              1: size := fs(FsPlayer);
              2: size := fs(FsNpc);
            end;

            for j := 1 to size do
            begin
              load_character(prisoner, i, j);

              if (findsub(s, prisoner.name2)) and
                (prisoner.name2 <> player.name2) and
                (prisoner.name2 <> global_delname2) and
                (prisoner.location = offloc_prison) and
                (prisoner.hps > 0) and
                (prisoner.deleted = False) then
              begin

                if confirm(uplc + prisoner.name2 + config.textcol1, 'n') = True then
                begin
                  found := True;
                  break;

                end else
                begin
                  if confirm('Continue search ', 'Y') = False then
                  begin
                    finito := True;
                    break;
                  end;
                end;
              end;

              if (finito) or (found) then
                break;

            end; {for j:= .end.}

            if (finito) or (found) then
              break;

          end; {for i:= .end.}

               {the King and Royal Guards may not attempt this!}
          if found then
          begin
            if player.king then
            begin
              case player.sex of
                1: s := 'King';
                2: s := 'Queen';
              end;
              d(12, 'Hey! You are the ' + s + '! Why would you bother with this!');
              d(12, 'It''s your Castle!');
              pause;
              crlf;
            end else
            begin

              {is player a royal guard, guards may not free prisoners}
              load_king(fload, king);

              finito := False;
              for i := 1 to global_kingguards do
              begin
                if king.guard[i] = player.name2 then
                begin
                  finito := True;
                end;
              end; {for i:= .end.}

              if finito then
              begin
                d(12, 'You are a member of the Royal Guard! You cannot betray the Royal Family!');
                crlf;
                pause;
                found := False;
              end;

            end;
          end;

          {free prisoner}
          if found then
          begin

            crlf;
            crlf;
            d(config.textcolor, 'You approach the gate...');
            d(config.textcolor, 'You must get pass the guards, and not only that!');
            d(config.textcolor, 'You must also get the cell-keys from the guard-captain.');
            pause;
            crlf;

            {is any of the royal guards ready to guard the gate}
            done := False;
            attempts := 0;
            load_king(fload, king);
            repeat

              for i := 1 to global_kingguards do
              begin
                Inc(attempts);
                if king.guard[i] <> '' then
                begin
                  if random(3) = 0 then
                  begin

                    if is_online(king.guard[i], online_player) = False then
                    begin

                      {find and load guard from user/npc database}
                      y := look_for_alias(king.guard[i], king.guardai[i]);

                      if y > 0 then
                      begin

                        guard.name2 := '';

                        if y <= fs(fsplayer) then
                        begin
                          {load from player file}
                          load_character(guard, 1, y);
                        end;

                        if guard.name2 <> king.guard[i] then
                        begin

                          if y <= fs(fsnpc) then
                          begin
                            {lets try load from npc file}
                            load_character(guard, 2, y);
                          end;
                        end;

                        if guard.name2 <> king.guard[i] then
                        begin
                          {damn! guard does not exist in the player/npc files}
                          y := 0;
                        end else
                        if (is_online(king.guard[i], online_player) = False) and
                          (guard.location <> offloc_prison) and
                          (guard.deleted = False) and
                          (guard.name2 <> player.name2) and
                          (guard.allowed = True) and
                          (guard.name2 <> global_delname2) and
                          (guard.hps > 0) then
                        begin
                          {add offline player, if he's offline and not in jail himself}
                          Add_Shadow(SAdd, guard, player.name2, 'guarding the prison', 0);
                          done := True;
                          break;
                        end;

                      end;
                    end;

                  end;
                end;
              end; {for i:= .end.}

            until (done) or (attempts > 25);

            {get the keys from the guard}
            if done then
            begin
              {player guard found}
              s := guard.name2;
              player_guard := True;
            end else
            begin
              {no player guard found! we create a guard}
              s := captain;
              guard.name1 := captain;
              guard.name2 := captain;
              guard.sex := 1;
              player_guard := False;
            end;

            {guard found}
            d(config.textcolor, 'You sneak up behind ' + uplc + s + config.textcol1 + ' the Royal guard.');
            d(config.textcolor, uplc + s + config.textcol1 + ' is sleeping on ' + sex3[guard.sex] + ' post.');
            sd(config.textcolor, 'You cautiously loosen the bunch of keys tied to ' + uplc + s +
              's' + config.textcol1 + ' belt...');
            make_delay_dots(2, 5, 600);
            crlf;

            done := False;
            case random(20) of
              0: begin
                d(15, 'Yes! You did it!');
                done := True; {passed guard}
                {remove offline guard}
                if player_guard then
                begin
                  {remove guard}
                  Add_Shadow(SRemove, guard, '', '', 0);
                end;
              end else begin
                d(12, 'Oh No! ' + uplc + s + ulred + ' woke up!');
              end;
            end; {case .end.}

                 {fight guard}
            if done = False then
            begin

              if player_guard = False then
              begin
                {reset monsters}
                reset_monsters;

                {create guards}
                foes := random(3) + 1;
                for i := 1 to foes do
                begin
                  case random(3) of
                    0: s := 'Prison-Guard';
                    1: s := 'Guard';
                    2: s := 'Torture-Master';
                  end;

                  case random(3) of
                    0: begin
                      weapon := 'Sword';
                      armor := 'Chain-mail';
                    end;
                    1: begin
                      weapon := 'Club';
                      armor := 'Chain-mail';
                    end;
                    2: begin
                      weapon := 'Axe';
                      armor := 'Leather';
                    end;
                  end; {case .end.}

                  hps := player.level * 4;

                  if i = 1 then
                  begin
                    s := captain; {the guard captain}
                    hps := hps * 2;
                  end;

            {d(15,'hps :'+commastr(hps));
            }

                  create_monster(i,              {#}
                    s,                     {name}
                    hps,                   {hps}
                    player.strength * 2,   {strength}
                    player.defence * 2,    {defence}
                    'seize the intruder!', {phrase}
                    False,                 {gragweap}
                    False,                 {grabarm}
                    weapon,                {weapon-string}
                    armor,                 {armor-string}
                    False,                 {poisoned-should be false}
                    False,                 {disease -should be false}
                    player.level,          {punch}
                    player.level + 1,      {armpow}
                    player.level + 1);     {weappow}

                end; {for i:= .end.}

                {global battle flags}
                global_escape := False;
                global_begged := False;
                global_nobeg := False;

                {init pointer vars}
                for i := 1 to 4 do
                begin
                  new(pl[i]);
                end;

                {set team flags}
                for i := 1 to 4 do
                begin
                  pl[i]^.name1 := '';
                  pl[i]^.name2 := '';
                end;

                {fight!}
                player_vs_monsters(pl_vs_prisonguards, pl[1]^, pl[2]^, pl[3]^, pl[4]^);

                {init pointer vars}
                for i := 1 to 4 do
                begin
                  dispose(pl[i]);
                end;

                {evaluate fight}
                if global_begged then
                begin
                  {player begged for mercy and is put in a cell}
                  d(15, 'YOU COWARD!');
                  d(15, 'You are dragged to a Cell where you await your sentence.');

                  player.location := Offloc_Prison;
                  player.daysinprison := 1;

                  {news-paper}
                  Newsy(True,
                    'Prison',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was seized after an attempt to free ' +
                    uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                    ' ' + ulred + player.name2 + config.textcol1 + ' surrendered to the Guards and was jailed.',
                    ' The Royal Justice will deal with this outlaw.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform other nodes}
                  online_send_to_all(uplc + player.name2 + config.textcol1 + ' has been imprisoned!', player.name2, '');

                  {inform the prisoner}
                  if prisoner.ai = 'H' then
                  begin
                    post(MailSend,
                      prisoner.name2,
                      prisoner.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Helping Hand' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was seized after an attempt to get you out of prison.',
                      ulred + player.name2 + config.textcol1 + ' surrendered to the Guards and was put in chains.',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Infiltration' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was seized after an attempt to free ' +
                      uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                      ulred + player.name2 + config.textcol1 + ' surrendered to the Guards and was put in chains.',
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

                  pause;
                  halt;
                end else
                if global_killed then
                begin
                  {player was killed by prison-guards}
                  d(12, 'YOU FAILED!');
                  d(config.textcolor, 'You see the Dark Angel descending...');


                  {news-paper}
                  Newsy(True,
                    'Prison',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                    uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform the prisoner}
                  if prisoner.ai = 'H' then
                  begin
                    post(MailSend,
                      prisoner.name2,
                      prisoner.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Helping Hand' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was killed in an attempt to free You from prison.',
                      'The prison guards killed ' + ulred + player.name2 + config.textcol1 + '!',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and
                    (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Infiltration' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                      uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                      'The prison guards took care of the intruder!',
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

                  {is player allowed to enter more this day?}
                  if Config.AllowFailPrisonRescue = False then
                  begin
                    {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);
                  end;

                  pause;
                  halt;

                end else
                begin
                  {player survived}
                  crlf;
                  d(15, 'You take the Keys to the Prison Cells!');
                end;

              end else
              begin

                {player must fight a member of the Kings Royal Guard!}
                d(15, 'Fight!');

                repeat
                  surrender := player_computer(player, guard, False, 5);
                until (player.hps < 1) or (guard.hps < 1) or (surrender = True);

                if surrender then
                begin
                  {player gave up}

                  crlf;
                  d(12, 'YOU COWARD!');
                  d(15, 'You are dragged to a Cell where you await your sentence.');
                  player.location := offloc_prison;
                  player.daysinprison := 1;

                  {news-paper}
                  Newsy(True,
                    'New Prisoner',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was seized after an attempt to free ' +
                    uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                    ' ' + ulred + player.name2 + config.textcol1 + ' surrendered to the royal guard ' +
                    uplc + guard.name2 + config.textcol1 + '!',
                    ' The Royal Justice will deal with this outlaw.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform other nodes}
                  online_send_to_all(uplc + player.name2 + config.textcol1 + ' has been imprisoned!', player.name2, '');

                  {inform the guard}
                  if guard.ai = 'H' then
                  begin
                    post(MailSend,
                      guard.name2,
                      guard.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Prison Duty' + config.textcol1,
                      mkstring(11, underscore),
                      uplc + player.name2 + config.textcol1 + ' attacked you on when you guarded the Prison Dungeons.',
                      ulred + player.name2 + config.textcol1 + ' surrendered to you!',
                      'You sent ' + uplc + player.name2 + config.textcol1 + ' to a Cell.',
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

                  {inform the prisoner}
                  if prisoner.ai = 'H' then
                  begin
                    post(MailSend,
                      prisoner.name2,
                      prisoner.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Helping Hand' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was seized after an attempt to get you out of prison.',
                      ulred + player.name2 + config.textcol1 + ' surrendered to the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + ' and was put in chains.',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and
                    (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Infiltration' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' was seized after an attempt to free ' +
                      uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                      ulred + player.name2 + config.textcol1 + ' surrendered to the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + '.',
                      ulred + player.name2 + config.textcol1 + ' was put in chains.',
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

                  pause;
                  halt;
                end else
                if (player.hps < 1) and (guard.hps < 1) then
                begin

                  {both guard and player were killed}
                  crlf;
                  d(12, 'YOU FAILED!');
                  d(config.textcolor, 'You can see the Death Angel descending...');

                  {news-paper}
                  Newsy(True,
                    'Prison Trouble',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                    uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                    ' ' + ulred + player.name2 + config.textcol1 + ' was eliminated by the royal guard ' +
                    uplc + guard.name2 + config.textcol1 + '!',
                    ' ' + ulred + guard.name2 + config.textcol1 + ' was badly wounded and died soon after the fight.',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform the guard}
                  if guard.ai = 'H' then
                  begin
                    post(MailSend,
                      guard.name2,
                      guard.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Prison Duty' + config.textcol1,
                      mkstring(11, underscore),
                      uplc + player.name2 + config.textcol1 + ' attacked you on when you guarded the Prison Dungeons.',
                      'You killed ' + ulred + player.name2 + config.textcol1 + '!',
                      ulred + 'You were badly wounded and died short after the fight!' + config.textcol1,
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

                  {inform the prisoner}
                  if prisoner.ai = 'H' then
                  begin
                    post(MailSend,
                      prisoner.name2,
                      prisoner.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Helping Hand' + config.textcol1,
                      mkstring(12, underscore),
                      ulred + player.name2 + config.textcol1 + ' was killed in an attempt to get you out of prison!',
                      ulred + player.name2 + config.textcol1 + ' was killed by the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + '!',
                      ulred + guard.name2 + config.textcol1 + ' died on ' + sex3[guard.sex] + ' way to hospital.',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and
                    (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Infiltration' + config.textcol1,
                      mkstring(12, underscore),
                      ulred + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                      uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                      ulred + player.name2 + config.textcol1 + ' was killed by the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + '.',
                      ulred + guard.name2 + config.textcol1 + ' died on ' + sex3[guard.sex] + ' way to hospital.',
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

                  {save guard}
                  user_save(guard);

                  {is player allowed to enter more this day?}
                  if Config.AllowFailPrisonRescue = False then
                  begin
                    {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);
                  end;

                  pause;
                  halt;

                end else
                if guard.hps < 1 then
                begin
                  {guard was killed}
                  d(15, 'You take the Keys to the Prison Cells!');

                  {news-paper}
                  Newsy(True,
                    'Prison',
                    ' ' + ulred + guard.name2 + config.textcol1 + ', the royal guard, was killed by ' +
                    uplc + player.name2 + config.textcol1 + '!',
                    ' ' + uplc + player.name2 + config.textcol1 + ' stole the keys to the Prison cells!',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform the guard}
                  if guard.ai = 'H' then
                  begin
                    post(MailSend,
                      guard.name2,
                      guard.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Incompetence' + config.textcol1,
                      mkstring(12, underscore),
                      uplc + player.name2 + config.textcol1 + ' attacked you on when you guarded the Prison Dungeons.',
                      'You were killed by ' + uplc + player.name2 + config.textcol1 + '!',
                      uplc + player.name2 + config.textcol1 + ' stole the keys to the Prison cells!',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and
                    (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Prison Infiltrated!' + config.textcol1,
                      mkstring(19, underscore),
                      uplc + player.name2 + config.textcol1 + ' killed the royal guard ' + ulred +
                      guard.name2 + config.textcol1 + '!',
                      uplc + player.name2 + config.textcol1 + ' stole the keys to the Prison cells!',
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

                  {save guard}
                  user_save(guard);

                end else
                if player.hps < 1 then
                begin
                  {player was killed}

                  crlf;
                  d(12, 'YOU FAILED!');
                  d(config.textcolor, 'You can see the Death Angel descending...');

                  {news-paper}
                  Newsy(True,
                    'Prison',
                    ' ' + uplc + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                    uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                    ' ' + ulred + player.name2 + config.textcol1 + ' was killed by the royal guard ' +
                    uplc + guard.name2 + config.textcol1 + '!',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');

                  {inform the guard}
                  if guard.ai = 'H' then
                  begin
                    post(MailSend,
                      guard.name2,
                      guard.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Prison Duty' + config.textcol1,
                      mkstring(11, underscore),
                      uplc + player.name2 + config.textcol1 + ' attacked you on when you guarded the Prison Dungeons.',
                      'You killed ' + ulred + player.name2 + config.textcol1 + '!',
                      uwhite + 'GOOD WORK!',
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

                  {inform the prisoner}
                  if prisoner.ai = 'H' then
                  begin
                    post(MailSend,
                      prisoner.name2,
                      prisoner.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Helping Hand' + config.textcol1,
                      mkstring(12, underscore),
                      ulred + player.name2 + config.textcol1 + ' was killed in an attempt to get you out of prison!',
                      ulred + player.name2 + config.textcol1 + ' was killed by the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + '!',
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

                  {inform the king}
                  if (is_online(king.Name, online_player) = False) and
                    (king.ai = 'H') then
                  begin
                    post(MailSend,
                      king.Name,
                      king.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + 'Infiltration' + config.textcol1,
                      mkstring(12, underscore),
                      ulred + player.name2 + config.textcol1 + ' was killed in an attempt to free ' +
                      uplc + prisoner.name2 + config.textcol1 + ' from prison.',
                      ulred + player.name2 + config.textcol1 + ' was killed by the royal guard ' +
                      uplc + guard.name2 + config.textcol1 + '.',
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

                  {is player allowed to enter more this day?}
                  if Config.AllowFailPrisonRescue = False then
                  begin
                    {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);
                  end;

                  pause;
                  halt;

                end;

              end;

            end;

            {remove offline guard}
            if player_guard then
            begin
              Add_Shadow(SRemove, guard, '', '', 0);
            end;

            {player managed to get pass the guard! now lets set prisoner free}

            {send a little message to all nodes}
            online_send_to_all(uplc + player.name2 + config.textcol1 + ' stole the KEYS to the Prison Dungeons!',
              player.name2, '');

            {intro text!}
            d(15, 'You did it! You passed the guards.');
            crlf;

            if is_online(prisoner.name2, online_player) then
            begin
              {hitler}

              {we send the news of the opened cell door to prisoner}
              {it is now up to him to exit jail or stay}
              online_send_to_player(prisoner.name2, online_player, broadcast_CellDoorOpens);

              {text}
              crlf;
              d(config.textcolor, 'You open the door to ' + uplc + prisoner.name2 + 's' + config.textcol1 + ' cell.');
              d(config.textcolor, uplc + prisoner.name2 + config.textcol1 + ' sits in a corner wearing rags.');
              sd(config.textcolor, 'You wait for ' + uplc + prisoner.name2 + config.textcol1 + ' to get up...');

              crlf;
              pause;

            end else
            begin

              {text}
              crlf;
              d(config.textcolor, 'You open the door to ' + uplc + prisoner.name2 + 's' + config.textcol1 + ' cell.');
              d(config.textcolor, uplc + prisoner.name2 + config.textcol1 + ' sits in a corner wearing rags.');
              d(config.textcolor, 'You take ' + sex3[prisoner.sex] + ' hand and lead ' +
                sex[prisoner.sex] + ' out to freedom!');
              crlf;

              {add offline player}
              Add_Shadow(SAdd, prisoner, player.name2, 'escaping from prison!', 0);

              {news-paper}
              Newsy(True,
                'Escape from Prison',
                ' ' + uplc + prisoner.name2 + config.textcol1 + ' escaped from Prison!',
                ' ' + uplc + prisoner.name2 + config.textcol1 + ' had help from the outside.',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              {inform the King}
              if (is_online(king.Name, online_player) = False) and
                (king.ai = 'H') then
              begin
                post(MailSend,
                  king.Name,
                  king.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  ulred + 'Jail-Break!' + config.textcol1,
                  mkstring(11, underscore),
                  uplc + prisoner.name2 + config.textcol1 + ' escaped from Prison!',
                  uplc + prisoner.name2 + config.textcol1 + ' had help from the outside.',
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

              {inform the Prisoner}
              if prisoner.ai = 'H' then
              begin
                post(MailSend,
                  prisoner.name2,
                  prisoner.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  uwhite + 'Helping Hand' + config.textcol1,
                  mkstring(12, underscore),
                  uplc + player.name2 + config.textcol1 + ' helped you escape from Jail!',
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

              {inform all nodes}
              online_send_to_all(uplc + prisoner.name2 + config.textcol1 + ' escaped from Prison!', player.name2, '');

              {update prisoner}
              prisoner.location := offloc_dormitory;

              {save prisoner}
              user_save(prisoner);

              {remove offline prisoner}
              Add_Shadow(SRemove, prisoner, '', '', 0);

              pause;

            end;
          end;
        end;

      end;
      'P': begin {list of prisoners}
        crlf;
        crlf;
        d(config.textcolor, 'You examine the Dungeons.');
        crlf;

        list_of_prisoners;

      end;
    end; {case .end.}

  until cho = 'R';

  crlf;
  crlf;
  d(config.textcolor, 'You leave the depressing prison grounds.');
  crlf;

end; {Free_Prisoner *end*}

end. {UNIT PrisonF .end.}
