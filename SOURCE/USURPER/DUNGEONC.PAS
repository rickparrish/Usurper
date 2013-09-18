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


unit Dungeonc; {Usurper - the dungeons.. main routine}

interface

procedure Dungeons(teamdngs: boolean);

implementation

uses
  Init, Cms, Jakob, Dmaze,
  Dungevc, Statusc,
  Supremec, Plvsmon,
  Mail, News, Various,
  Uman, Npc_Chec, Various2,
  Various3, Online, File_Io;

var
  pl:       array [1..4] of ^Userrec; {team-mates are stored here}
  custtemp: ^Userrec; {temporary user record}

procedure Disposal; {remove pointer variables}
var i: byte;
begin

  for i := 1 to 4 do
  begin
    dispose(pl[i]);
  end;

  dispose(custtemp);
  {remove shadow players, created by player [teammates]}
  add_shadow(SRemoveShadows, player, '', 'going to sleep...', 0);

end; {disposal *end*}

procedure Team_Member_Instruct(var plyr: userrec);
var done: boolean;
  ch:     char;
begin
  done := False;
  repeat

    {menu}
    crlf;
    d(config.textcolor, 'What should be done with ' + uplc + plyr.name2 + config.textcol1 + '?');
    menu('(E)xamine');
    menu('(K)ick out from group');
    menu('(R)eturn');
    crlf;
    sd(config.textcolor, 'Decision :');

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      'R': done := True;
      'E': status(plyr);
      'K': begin {kick out from group}

        d(global_plycol, plyr.name2 + config.textcol1 + ' returns home.');

        {put team member offline / send him home to the town}
        add_shadow(SRemove, plyr, '', '', 0);

        {save user}
        user_save(plyr);

        {inform plyr of incident}
        post(MailSend,
          plyr.name2,
          plyr.ai,
          False,
          mailrequest_nothing,
          '',
          ulred + 'Kicked out!' + config.textcol1,
          mkstring(11, underscore),
          'You were kicked out from the group exploring the Dungeons.',
          'You were sent home by your team-leader: ' + uplc + player.name2 + config.textcol1 + '.',
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

        {empty team member record}
        plyr.name1 := '';
        plyr.name2 := '';

        {exit procedure}
        done := True;

        crlf;

      end;

    end; {case .end.}

  until done;

end; {team_member_instruct *end*}

function Team_Select: integer; {let player select team-mates to follow}
var
  i:         longint;

  y:         integer;

  gtext1, gtext2: s70;

  redisp:    boolean;

  ch:        char;

  coming:    array [1..4] of boolean;
  nice2:     array [1..4] of s90;

  pl0, pl01: ^UserRec;

begin

  {init pointer vars}
  new(pl0);
  new(pl01);

  coming[1] := False;
  coming[2] := False;
  coming[3] := False;
  coming[4] := False;

  pl[1]^.name2 := '';
  pl[2]^.name2 := '';
  pl[3]^.name2 := '';
  pl[4]^.name2 := '';

  team_select := 0;
  ch := '?';
  y := 0;

  crlf;

  d(config.textcolor, 'You hurry off to inform your friends of the coming adventure...');

  for i := 1 to fs(FsPlayer) do
  begin

    if load_character(pl0^, 1, i) = True then
    begin

      if (pl0^.name2 <> '') and
        (pl0^.name2 <> player.name2) and
        (pl0^.team = player.team) and
        (is_online(pl0^.name2, online_player) = False) and
        (pl0^.location <> offloc_prison) and
        (pl0^.hps > 0) then
      begin

        if add_shadow(SAdd, pl0^, player.name2, 'teaming up with ' + uplc + player.name2 + config.textcol1, 0) then
        begin

          Inc(y);
          coming[y] := True;
          pl[y]^ := pl0^;
        end;
      end;
      if pl[4]^.name2 <> '' then
      begin
        break;
      end;
    end;

  end; {for i:= .end.}

  for i := 1 to fs(FsNpc) do
  begin

    if load_character(pl0^, 2, i) = True then
    begin

      if (pl0^.name2 <> '') and
        (pl0^.name2 <> player.name2) and
        (pl0^.team = player.team) and
        (is_online(pl0^.name2, online_player) = False) and
        (pl0^.location <> offloc_prison) and
        (pl0^.hps > 0) then
      begin

        if add_shadow(SAdd, pl0^, player.name2, 'teaming up with ' + uplc + player.name2 + config.textcol1, 0) then
        begin

          Inc(y);
          coming[y] := True;
          pl[y]^ := pl0^;
        end;

      end;
      if pl[4]^.name2 <> '' then
      begin
        break;
      end;
    end;

  end; {for i:= .end.}

  if y = 0 then
  begin
    crlf;
    d(12, 'No teammembers found! (they might be dead or on-line)');
    crlf;
    pause;
    dispose(pl0);
    dispose(pl01);
    exit;
  end;

  crlf;
  if y > 1 then
  begin
    d(5, 'You are faced with the hard facts of life.');
    d(5, 'Shall you really bring the whole team?');
    d(5, 'The weak may get killed very easily!');
  end else
  begin
    sd(5, 'You and ');
    sd(global_plycol, pl[1]^.name2);
    d(5, ' sit down to discuss the situations that');
    d(5, 'may arise on your journey...');
  end;
  redisp := True;

  gtext1 := ' ready';
  gtext2 := ' sulking in a corner, not allowed to join';
  repeat
    if redisp = True then
    begin
      crlf;
      for i := 1 to y do
      begin
        case i of
          1: begin
            menu2('(1) ');
            sd(global_plycol, pl[1]^.name2);
            if coming[1] = True then d(3, gtext1)
            else d(12, gtext2);
          end;
          2: begin
            menu2('(2) ');
            sd(global_plycol, pl[2]^.name2);
            if coming[2] = True then d(3, gtext1)
            else d(12, gtext2);
          end;
          3: begin
            menu2('(3) ');
            sd(global_plycol, pl[3]^.name2);
            if coming[3] = True then d(3, gtext1)
            else d(12, gtext2);
          end;
          4: begin
            menu2('(4) ');
            sd(global_plycol, pl[4]^.name2);
            if coming[4] = True then d(3, gtext1)
            else d(12, gtext2);
          end;

        end; {case .end.}

      end; {for i:= .end.}

      crlf;
      sd(config.textcolor, '[');
      sd(5, Config.ReturnEnter);
      d(config.textcolor, '] to Continue');

      sd(config.textcolor, ':');
      redisp := False;
    end;

    {get user input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      '1': begin
        if y > 0 then
        begin
          if coming[1] = True then coming[1] := False
          else coming[1] := True;
          redisp := True;
        end;
      end;
      '2': begin
        if y > 1 then
        begin
          if coming[2] = True then coming[2] := False
          else coming[2] := True;
          redisp := True;
        end;
      end;
      '3': begin
        if y > 2 then
        begin
          if coming[3] = True then coming[3] := False
          else coming[3] := True;
          redisp := True;
        end;
      end;
      '4': begin
        if y > 3 then
        begin
          if coming[4] = True then coming[4] := False
          else coming[4] := True;
          redisp := True;
        end;
      end;

      char(13): begin
        if (coming[1] = False) and (coming[2] = False) and
          (coming[3] = False) and (coming[4] = False) then
        begin
          crlf;
          d(12, 'You must at least have ONE teammeber with you!');
          pause;
          redisp := True;
          ch := ' ';
        end;
      end;

    end; {case .end.}

  until ch = ReturnKey;
  team_select := 1;

  crlf;
  {what should the party-members say before the adventure begins}
  for i := 1 to 4 do
  begin
    if coming[i] = True then
    begin
      check_inventory(pl[i]^, 0, weapon, True, 0);

      pl01^ := pl[i]^;
      if pl01^.healing < config.maxheals then
      begin
        if pl01^.gold + pl01^.bankgold > 100 then
        begin

          {team mate buys healing potions}
          sd(global_talkcol, 'I need healing potions! I''ll go and buy some!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' says.');

          auto_healing(pl01^);

          pl[i]^ := pl01^;
          user_save(pl[i]^);

          d(global_plycol, pl01^.name2 + config.textcol1 + ' has returned. (bought some potions)');
          crlf;
        end else
        begin
          sd(global_plycol, 'I need healing potions, But I have no ' + config.moneytype + '!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' says.');
          crlf;
        end;
      end;
      if pl01^.classid in [Cleric, Magician, Sage] then
      begin
        if (pl01^.mana < pl01^.maxmana) and (random(2) = 0) then
        begin
          sd(global_talkcol, 'I don''t have full mana!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' complains.');
        end;
      end;

      case random(12) of
        0: begin
          sd(global_talkcol, 'I''m scared....!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' cries.');
        end;
        1: begin
          sd(global_talkcol, 'Let''s Go!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;
        2: begin
          sd(global_talkcol, 'I''m ready');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' mutters.');
        end;
        3: begin
          sd(global_talkcol, 'What are we waiting for!?');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' mutters.');
        end;
        4: begin
          sd(global_talkcol, 'Don''t have us killed ' + player.name2 + '!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' mutters.');
        end;
        5: begin
          sd(global_talkcol, 'Let''s have some fun!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;
        6: begin
          sd(global_talkcol, 'Can we fight a gang after this trip?');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' asks.');
        end;
        7: begin
          sd(global_talkcol, 'Hehehe....');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' says and kisses ' + sex3[pl01^.sex] + ' weapon.');
        end;
        8: begin
          sd(global_talkcol, 'LET''S KICK SOME BUTT!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;
        9: begin
          sd(global_talkcol, 'Lead us to Death or Glory!"');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;
        10: begin
          sd(global_talkcol, 'LET''S KICK SOME BUTT!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;
        11: begin
          sd(global_talkcol, 'LET''S BREAK SOME BONES!');
          sd(config.textcolor, ', ');
          sd(global_plycol, pl01^.name2);
          d(config.textcolor, ' screams.');
        end;

      end; {case .end.}
    end;
  end; {for i:= .end.}
  crlf;
  pause;
  crlf;

  {sending a mess to all team-mates that they joined player to the dngs.}

  nice2[1] := uplc + player.name2 + config.textcol1 + ' took you to the Dungeons.';

  if (pl[1]^.name2 <> '') and (pl[1]^.ai = 'H') then team_report(pl[1]^.name2, 1, nice2[1], nice2[2], nice2[3], nice2[4]);
  if (pl[2]^.name2 <> '') and (pl[2]^.ai = 'H') then team_report(pl[2]^.name2, 1, nice2[1], nice2[2], nice2[3], nice2[4]);
  if (pl[3]^.name2 <> '') and (pl[3]^.ai = 'H') then team_report(pl[3]^.name2, 1, nice2[1], nice2[2], nice2[3], nice2[4]);
  if (pl[4]^.name2 <> '') and (pl[4]^.ai = 'H') then team_report(pl[4]^.name2, 1, nice2[1], nice2[2], nice2[3], nice2[4]);

  for i := 1 to 4 do
  begin
    if pl[i]^.name2 <> '' then
    begin
      if coming[i] = False then
      begin
        add_shadow(SRemove, pl[i]^, '', '', 0);
        pl[i]^.name2 := '';
      end else
      begin
        update_shadow(pl[i]^.name2, 'teamed up with ' + uplc + player.name2 + config.textcol1, False);
      end;
    end;
  end; {for i:= .end.}

  dispose(pl0);
  dispose(pl01);

end; {Team_Select *end*}

procedure Dungeons; {MAIN PROC **START**}
var
  z, zz, yy, xx, i, x, j: longint;

  dungeon_difficulty, y, need: integer;

  leave_dungeons, done, demon: boolean;

  ch, cho: char;

  s, s2:   s100;
  header, dungeon_name: s70;

  nice2:   array [1..4] of s90;

begin

  {init pointer variables}
  for i := 1 to 4 do
  begin
    new(pl[i]);
  end;
  new(custtemp);

  s2 := 'solen skiner'; {only people who speak swedish will understand this}

  pl[1]^.name2 := '';
  pl[2]^.name2 := '';
  pl[3]^.name2 := '';
  pl[4]^.name2 := '';

  if (teamdngs = True) and
    (player.team <> '') and
    (global_auto_probe = Nowhere) then
  begin
    crlf;
    crlf;
    sd(config.textcolor, 'Bring Your Team (');
    sd(global_teamcol, player.team);
    if confirm(')', 'N') = True then
    begin
      cho := 'Y';
    end else
    begin
      cho := 'N';
    end;

    {evaluate user input}
    case cho of
      'Y': begin
        d(11, 'Yes, bring the team!');
        if (Team_Select <> 0) and (player.fights > 0) then
        begin
          case random(4) of
            0: s := 'brave';
            1: s := 'famous';
            2: s := 'deadly';
            3: s := 'legendary';
          end;

          {news-paper}
          newsy(True,
            'Party Leaves for Fame & Glory!',
            ' ' + uplc + player.name2 + config.textcol1 + ' took ' + sex3[player.sex] + ' ' + s + ' team to the dungeons.',
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
    end; {case .end.}
  end;

  clearscreen;

  crlf;
  d(config.textcolor, 'The Monsters are gathering...');

  {fetching dungeon name from .CFG}
  dungeon_name := cfg_string(43);
  if dungeon_name = '' then
  begin
    dungeon_name := 'Mindor';
  end;

  {Set Dungeon Level}
  global_dungeonlevel := player.level;

  crlf;
  d(5, 'The Dungeons of ' + dungeon_name);
  d(config.textcolor, 'As you descend to Dungeon Level ' + uwhite + commastr(player.level) + config.textcol1 + ' you tighten your grip to your weapon.');
  d(config.textcolor, 'You feel that evil lurk nearby... You wonder whether you ever shall');
  d(config.textcolor, 'see the sun shine again...');

  if (pl[1]^.name2 <> '') or (pl[2]^.name2 <> '') or
    (pl[3]^.name2 <> '') or (pl[4]^.name2 <> '') then
  begin
    crlf;
    d(15, '[YOUR TEAM IS WITH YOU]');
  end;

  {dungeon difficulty}
  s := cfg_string(10);
  dungeon_difficulty := str_to_nr(s);
  if (dungeon_difficulty < 1) or (dungeon_difficulty > 10) then
  begin
    dungeon_difficulty := 2;
  end;

  {*** Main loop ***}
  leave_dungeons := False;
  repeat
    demon := False;
    crlf;

    {list of online players}
    if player.ear = 1 then
    begin
      who_is_here;
    end;

    {dungeon fights left}
    sd(config.textcolor, '[');
    sd(11, commastr(player.fights));
    d(config.textcolor, ' fights left]');

    {update online location, if necessary}
    if onliner.location <> onloc_dungeons then
    begin
      onliner.location := onloc_dungeons;
      add_onliner(OUpdateLocation, Onliner);
    end;

    {level raise}
    x := level_raise(player.level, player.exp);
    if x = 0 then
    begin
      d(15, global_levelraise);
    end;

    {menu}
    sd(config.textcolor, 'Dungeon level ' + umag + commastr(global_dungeonlevel) + config.textcol1 + ' (');
    sd(config.textcolor, config.textcol2 + '?' + config.textcol1 + ' for menu) :');

    s := '';
    case global_auto_probe of
      NoWhere: begin
        ch := upcase(getchar);
      end;
      UmanCave: begin
        uman_cave;
        ch := '?';
      end;
    end; {case .end.}

    {evaluate user-input}
    case ch of

      ReturnKey: crlf;

      'S': begin {status}
        clearscreen;
        status(player);
        crlf;
      end;
      '?': begin {display menu}

        s := 'The Dungeons of ' + dungeon_name;
        clearscreen;
        crlf;
        d(5, s);
        crlf;
        menu('(L)ook for creatures');
        menu('(H)ealing');
        menu('(Q)uick heal');
        if global_icemap then
        begin
          {menu('(I)ce Caves'); jakob}
        end;

        if global_ubeta then
        begin

          {menu('(D)eath maze');}

        end;
        menu('(U)man caves');


        if (player_active(pl[1]^, True) = True) or
          (player_active(pl[2]^, True) = True) or
          (player_active(pl[3]^, True) = True) or
          (player_active(pl[4]^, True) = True) then
        begin
          menu('(T)eam orders');
        end;

        menu('(C)hange dungeon level');
        menu('(S)tatus');
        menu('(R)eturn to town');

      end;
      'R': begin {return to town}
        leave_dungeons := True;
      end;
      'U': begin {uman caves}
        crlf;
        crlf;
        d(10, 'You have entered a new area.');
        uman_cave;
      end;
      'D': begin {death maze, nothing serious. a test area for the programmer}

        if global_utest = True then
        begin
          crlf;
          crlf;
          death_maze;
        end else
        begin
          crlf;
          crlf;
          d(12, 'The Maze is not for you to explore!');
        end;

      end;
      'H': begin {healing}
        healing(player);
      end;
      'Q': begin {quick healing}
        quick_healing(player);
      end;
      'I': begin {ice-caves}

        crlf;
        crlf;
        d(15, 'Sorry, this area wasn''t ready to the release of this version.');
        d(15, 'The author had other priorities.');
        crlf;
        pause;
        {if global_icemap then begin
         clearscreen;
         crlf;
         crlf;
         d(config.textcolor,'You follow the map you have.');
         sd(config.textcolor,'After many hours of wandering you finally see light in the tunnel...');
         delay2(500);
         clearscreen;
         show_usurper_data(picture_ICE_CAVES,true);

         d(config.textcolor,'You have reached a place beyond the dungeons.');

         ice_caves(pl[1]^,pl[2]^,pl[3]^,pl[4]^);
         crlf;
         d(config.textcolor,'Back from the '+uwhite+'Ice-Caves'+config.textcol1+'..');
         crlf;

        end;}

      end; {*ICE-CAVES END*}

      'C': begin {change dungeon level}
        i := global_dungeonlevel;

        crlf;
        d(config.textcolor, 'There are a total of 100 dungeon levels. You can for the moment');
        sd(config.textcolor, 'access levels ');
        sd(5, commastr(player.level));
        sd(config.textcolor, ' - ');
        sd(5, commastr(player.level + 10));
        sd(config.textcolor, '. Pick a new level :');

        zz := get_number(0, 200);

        if (zz >= player.level) and (zz <= player.level + 10) then
        begin

          global_dungeonlevel := zz;

          if global_dungeonlevel > 101 then global_dungeonlevel := 101;

          if (global_dungeonlevel > 90) and (global_registered = False) then
          begin
            crlf;
            d(12, 'Sorry, you cannot reach further in the unregistered version');
            d(12, 'of Usurper. Encourage your Sysop to register!');
            crlf;
            pause;
            global_dungeonlevel := 89;
          end else
          begin
            if global_dungeonlevel = i then
            begin
              crlf;
              sd(3, 'You remain on level ');
              d(5, commastr(global_dungeonlevel));
            end else if global_dungeonlevel > i then
            begin
              crlf;
              sd(3, 'You descend to level ');
              d(5, commastr(global_dungeonlevel));
            end else
            begin
              crlf;
              sd(3, 'You ascend to level ');
              d(5, commastr(global_dungeonlevel));
            end;

          end;

          if (global_dungeonlevel = 101) and (global_registered = True) then
          begin
            supreme(pl[1]^, pl[2]^, pl[3]^, pl[4]^);
          end;

        end else
        begin
          crlf;
          sd(config.textcolor, 'You are on level ');
          d(5, commastr(global_dungeonlevel));
        end;
      end;
      'T': begin {team commands}

        if (player_active(pl[1]^, True) = False) and
          (player_active(pl[2]^, True) = False) and
          (player_active(pl[3]^, True) = False) and
          (player_active(pl[4]^, True) = False) then
        begin
          crlf;
          crlf;
          d(12, 'Ha! You are alone.');
          crlf;
        end else
        begin
          done := False;
          repeat
            crlf;
            crlf;
            s := 'Your Party';
            d(14, s);
            d(10, cool_string(length(s), '=', '-', 2, 10));

            {hitler}

            for i := 1 to global_maxteammembers - 1 do
            begin

              if player_active(pl[i]^, True) = True then
              begin
                menu('[' + commastr(i) + '] ' + uplc + pl[i]^.name2 + config.textcol1);
              end else
              begin
                menu('[' + commastr(i) + '] ' + ulgray + '---' + config.textcol1);
              end;

            end; {for i:= .end.}
            menu('(R)eturn');

            crlf;
            sd(config.textcolor, 'Team Command :');

            {get user-input}
            cho := upcase(getchar);

            {evaluate user-input}
            case cho of
              '1': if player_active(pl[1]^, True) then team_member_instruct(pl[1]^);
              '2': if player_active(pl[2]^, True) then team_member_instruct(pl[2]^);
              '3': if player_active(pl[3]^, True) then team_member_instruct(pl[3]^);
              '4': if player_active(pl[4]^, True) then team_member_instruct(pl[4]^);
              'R': done := True;
            end; {case .end.}

            if (player_active(pl[1]^, True) = False) and
              (player_active(pl[2]^, True) = False) and
              (player_active(pl[3]^, True) = False) and
              (player_active(pl[4]^, True) = False) then
            begin
              crlf;
              d(12, 'You are alone!');
              crlf;
              done := True;
            end;

          until done;

        end;

      end;
      'L': begin {look for monsters}
        if (player.fights <= 0) and (global_auto_probe = Nowhere) then
        begin
          crlf;
          d(12, 'Sorry, you have no fights left for today.');
        end else
        begin

          crlf;
          crlf;
          d(config.textcolor, 'looking...');
          if dungeon_event(pl[1]^, pl[2]^, pl[3]^, pl[4]^) = True then
          begin

            if global_killed then
            begin
              {save temm mates status}
              for i := 1 to 4 do
              begin
                custtemp^ := pl[i]^;
                if (custtemp^.name2 <> '') and (custtemp^.name1 <> '') then
                begin
                  user_save(custtemp^);
                end;

                player.hps := 0;
                {player.allowed:=false;}
                Reduce_Player_Resurrections(player, True);

                post(MailSend,
                  player.name2,
                  player.ai,
                  False,
                  mailrequest_nothing,
                  '',
                  ulred + 'Your Death' + config.textcol1,
                  mkstring(10, underscore),
                  'You were killed by a ' + umonc + killed_by[1] + config.textcol1 + ' in the Dungeons.',
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
              normal_exit; {EVENTEN ended with player being killed}

            end;
          end else
          begin {player did not experience an EVENT, alas we bring
          in monsters instead! mohaha!}

            if (global_dungeonlevel > 89) and (global_registered = False) then
            begin
              d(12, 'Sorry, you cannot reach further in the unregistered version');
              d(12, 'of Usurper. Encourage your Sysop to register!');
              crlf;
              pause;

              disposal;
              exit;
            end;

            Reset_Monsters;

            for i := 1 to global_maxspells do
            begin
              player.spell[i, 2] := False;
              for j := 1 to 4 do
              begin
                pl[j]^.spell[i, 2] := False;
              end;
            end; {for i:= .end.}

            {decrease dungeon fights}
            Dec(player.fights);

            xx := (global_dungeonlevel - 1) * 10;
            y := xx + random(10);

            load_monster(y, 1);

            if player.level > 99 then global_dungeonlevel := 101;

            if (global_dungeonlevel = 101) and (global_registered = True) then
            begin
           {uncomment this to make supreme being based on mon editor
           y:=fs(FsMonster);
           load_monster(y-1,1);
           monster[1]^.hps:=player.hps*4;
           pause;
           }
              supreme(pl[1]^, pl[2]^, pl[3]^, pl[4]^);
              normal_exit;
            end;

            if (global_dungeonlevel = 101) and (global_registered = False) then
            begin
              crlf;
              d(12, 'Sorry, you cannot reach further in the unregistered version');
              d(12, 'of Usurper. Encourage your Sysop to register!');
              crlf;
              pause;
              normal_exit;
            end;

            {*Demon maybe!?*}
            if player.haunt > 0 then
            begin
              newsy(True,
                'Demon Attack!',
                ' ' + uplc + player.name2 + config.textcol1 + ' was attacked by a ' + umonc + 'Demon' + config.textcol1 + '!',
                '',
                '',
                '',
                '',
                '',
                '',
                '',
                '');

              {remove one demon from the players HAUNT LIST}
              Dec(player.haunt);

              y := random(1) + 1;

              demon := True;

              case random(6) of
                0: s := 'Demon';
                1: s := 'Rage Demon';
                2: s := 'Dark Demon';
                3: s := 'Hell Demon';
                4: s := 'White Demon';
                5: s := 'Red Demon';
              end;

              case random(10) of
                0: s2 := 'I have been waiting for you!';
                1: s2 := 'Annihilation is my profession...';
                2: s2 := 'I have been summoned to DESTROY you!';
                3: s2 := 'Risen from hell I have!';
                4: s2 := 'It is here where your adventure ends!';
                5: s2 := 'Prepare to fight your last fight EVER!';
                6: s2 := 'I have come to bring you down!';
                7: s2 := 'I have been summoned to take care of YOU!';
                8: s2 := 'Kiss your life GOODBYE!';
                9: s2 := 'I have been chosen to kill you!';
              end;

           { debug info
           d(15,'demon hitpoints is '+commastr(player.maxhps*y));
           pause;
           }

              create_monster(1,                 {#}
                s,                 {name}
                global_dungeonlevel * 5 * y,   {hps}
                90,                {strength}
                0,                {defence}
                s2,                {phrase}
                False,             {grabweap}
                False,             {grabarm}
                '*Super Strength', {weapon-string}
                '',                {armor-string}
                False,             {poisoned-should be false}
                False,             {disease -should be false}
                100 + random(player.maxhps), {punch}
                100,               {armpow}
                0);                {weappow}
              crlf;
              d(config.textcolor, 'The ground starts to tremble!');
              d(config.textcolor, 'Through the shattered rocks something horrible');
              d(config.textcolor, 'rises! A Demon has been summoned upon YOU!');
              crlf;
              d(config.textcolor, 'Your grip to your weapon hardens...the Demon turns');
              d(config.textcolor, 'it''s ugly head against you...');
              crlf;
              d(global_talkcol, s2);
              crlf;
              pause;
            end else
            begin
              {no demons are active opponents!}
              {it might be time to make MORE opponents instead!}
           {if the player has taken teammates with him then we must make
            a lot of monster!! :) }

              yy := random(dungeon_difficulty) + 1;
              if dungeon_difficulty = 1 then yy := 1;

              if (pl[1]^.name2 <> '') and (pl[1]^.hps > 0) then yy := yy * 2;
              if (pl[2]^.name2 <> '') and (pl[2]^.hps > 0) then yy := yy * 2;
              if (pl[3]^.name2 <> '') and (pl[3]^.hps > 0) then yy := yy * 2;
              if (pl[4]^.name2 <> '') and (pl[4]^.hps > 0) then yy := yy * 2;

              if yy > global_maxmon then yy := global_maxmon;

              for i := 2 to yy do
              begin
                xx := (global_dungeonlevel - 4) * 10;
                if xx < 1 then xx := 1;
                x := global_dungeonlevel * 10;
                y := xx + random(x - xx);

                {load a monster}
                load_monster(y, i);

              end;
            end;

            {setting some global variables}
            global_escape := True;
            global_killed := False;
            global_nobeg := False;

            if demon = False then
            begin
              player_vs_monsters(pl_vs_monster, pl[1]^, pl[2]^, pl[3]^, pl[4]^);
            end else
            begin
              player_vs_monsters(pl_vs_demon, pl[1]^, pl[2]^, pl[3]^, pl[4]^);
            end;

            {Let Team-mates buy healing potions}
            for i := 1 to 4 do
            begin
              custtemp^ := pl[i]^;

              crlf;
              if (custtemp^.name2 <> '') and (custtemp^.hps > 0) then
              begin
                if custtemp^.healing < config.maxheals then
                begin

                  z := custtemp^.level * 5;
                  need := config.maxheals - custtemp^.healing;

                  incbankmoney(custtemp^, custtemp^.gold);

                  custtemp^.gold := 0;

                  if (need > 0) and (custtemp^.bankgold > 100) then
                  begin
                    z := custtemp^.level * 5;
                    xx := custtemp^.bankgold div z;
                    if (xx) > need then
                    begin
                      xx := need;
                    end else
                    begin
                      need := xx;
                    end;

                    if xx > 0 then
                    begin
                      xx := need * z;

                      decbankmoney(custtemp^, xx);
                      Inc(custtemp^.healing, need);

                      sd(global_plycol, custtemp^.name2);
                      sd(config.textcolor, ' bought ');
                      sd(15, commastr(need));
                      d(config.textcolor, ' potions.');
                      pause;
                    end;

                  end;

                  pl[i]^ := custtemp^;
                end;
              end;
            end; {for i:= .end.}

            {does player need to buy healing potions?}
            need := 0;

            {if player is dead then there will be no purchase...}
            if player.hps < 1 then
            begin
              need := 0;
            end else
            begin
              {does the player NEED to buy potions?}
              if player.healing < config.maxheals then
              begin
                need := 1;
              end;
            end;

            if need > 0 then
            begin

              crlf;
              d(5, '* Meeting *');
              d(config.textcolor, 'You are approached by a ' + uplc + 'monk' + config.textcol1 + '.');
              d(config.textcolor, 'He offers you to buy healing potions.');
              crlf;

              if confirm('Buy potions ', 'Y') = True then
              begin
                z := player.level * 5;

                sd(config.textcolor, 'The price is ');
                sd(14, commastr(z));
                sd(config.textcolor, ' ' + config.moneytype + '/potion.');

                sd(config.textcolor, ' ( you have ');
                sd(14, commastr(player.gold));
                sd(config.textcolor, ' ' + many_money(player.gold) + ' )');
                crlf;

                xx := player.gold div z;
                if player.healing + xx > config.maxheals then
                begin
                  xx := config.maxheals - player.healing;
                end;

                if xx < 0 then xx := 0;

                sd(config.textcolor, 'You can buy a maximum of ');
                sd(5, commastr(xx));
                sd(config.textcolor, ' potions');
                sd(config.textcolor, ' ( you have ');
                sd(5, commastr(player.healing));
                sd(config.textcolor, ' potions )');

                crlf;
                d(config.textcolor, 'How many would you like to buy');
                sd(config.textcolor, '(0-' + commastr(xx) + ') [' + umag + commastr(xx) + config.textcol1 + ']:');
                zz := get_number2(0, xx, xx);

                xx := player.gold;
                xx := zz * z;
                if xx > player.gold then
                begin
                  crlf;
                  d(global_talkcol, 'Who are you trying to fool?');
                  pause;
                end;
                if (player.gold >= xx) and (zz > 0) and
                  (zz + player.healing <= config.maxheals) then
                begin

                  Inc(player.healing, zz);
                  decplayermoney(player, xx);

                  d(global_talkcol, 'Ok, it''s a deal.');
                  d(config.textcolor, 'You buy ' + ulcyan + commastr(zz) + config.textcol1 + ' potions.');

                  sd(global_plycol, 'The ' + uplc + 'Monk' + config.textcol1 + ' ');
                  case random(9) of
                    0: d(config.textcolor, 'smiles at you.');
                    1: d(config.textcolor, 'stares at you.');
                    2: d(config.textcolor, 'waves goodbye.');
                    3: d(config.textcolor, 'smirks.');
                    4: d(config.textcolor, 'walks away.');
                    5: d(config.textcolor, 'burps.');
                    6: d(config.textcolor, 'is silent.');
                    7: d(config.textcolor, 'smiles');
                    8: d(config.textcolor, 'wishes you good luck.');
                  end; {case .end.}
                  crlf;
                end else
                begin
                  d(global_talkcol, 'No deal.');
                end;
              end;
            end;

            {saving teamates status}
            for i := 1 to 4 do
            begin
              custtemp^ := pl[i]^;
              if (custtemp^.name2 <> '') and (custtemp^.name1 <> '') then
              begin
                user_save(custtemp^);
              end;
            end; {for i:= .end.}

            if global_killed = True then
            begin
              {player has been killed in the dungeons}

              player.gold := 0;
              player.hps := 0;

              {player.allowed:=false;}
              Reduce_Player_Resurrections(player, True);

              {inform player}
              post(MailSend,
                player.name2,
                player.ai,
                False,
                mailrequest_nothing,
                '',
                ulred + 'Your Death' + config.textcol1,
                mkstring(10, underscore),
                'You were slaughtered by a ' + umonc + killed_by[1] + config.textcol1 + '.',
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

              if global_begged = True then
              begin
                s := ' ' + uplc + player.name2 + config.textcol1;
                case random(7) of
                  0: s := s + ' begged for ' + sex3[player.sex] + ' miserable life, but ';
                  1: s := s + ' tried to convince a grim monster not to kill ' + sex[player.sex] + ', but ';
                  2: s := s + ' cried and begged for ' + sex3[player.sex] + ' life, but ';
                  3: s := s + ' wept and begged for mercy, but ';
                  4: s := s + ' gave up before ' + sex3[player.sex] + ' superior foe, but ';
                  5: s := s + ' met superior forces, begged for ' + sex3[player.sex] + ' life, but ';
                  6: s := s + ' chickened out in a fight! Begged, but ';
                end;

                case random(10) of
                  0: s2 := ' was brutally mutilated by a monster!';
                  1: s2 := ' was slain by a monster foe!';
                  2: s2 := ' was slaughtered by a monster!';
                  3: s2 := ' was killed without any mercy!';
                  4: s2 := ' received what ' + sex2[player.sex] + ' deserved. Death...';
                  5: s2 := ' was eliminated by a nice monster!';
                  6: s2 := ' was killed...';
                  7: s2 := ' the monster didn''t show any mercy...';
                  8: s2 := ' was killed instantly!';
                  9: s2 := ' was mutilated and tortured!';
                end; {case .end.}

                {news-paper}
                newsy(True,
                  'Chicken in the Dungeons!',
                  s,
                  s2,
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

              end else
              begin

                s := uplc + player.name2 + config.textcol1;

                case random(4) of
                  0: s := s + ' was killed by a ' + umonc + killed_by[1] + config.textcol1 + ' in the dungeons.';
                  1: s := s + ' was slain by a ' + umonc + killed_by[1] + config.textcol1 + ' in the dungeons.';
                  2: s := s + ' was slaughtered by a ' + umonc + killed_by[1] + config.textcol1 + ' in the dungeons.';
                  3: s := s + ' was defeated by a ' + umonc + killed_by[1] + config.textcol1 + ' in the dungeons.';
                end;

                case random(6) of
                  0: header := 'Dungeon';
                  1: header := 'Tragic';
                  2: header := 'Deceased';
                  3: header := 'Slain';
                  4: header := 'Defeat';
                  5: header := 'Goner';
                end; {case .end.}

                header := config.textcol1 + header;

                {news-paper}
                newsy(False,
                  header,
                  ' ' + s,
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '',
                  '');

                {var teamet med?}
                for i := 1 to 4 do
                begin
                  custtemp^ := pl[i]^;

                  if custtemp^.name2 <> '' then
                  begin
                    if custtemp^.hps > 0 then
                    begin
                      newsy(False,
                        ' ' + uplc + custtemp^.name2 + config.textcol1 + ' made it out alive...',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '');
                    end else
                    begin
                      newsy(False,
                        ' ' + uplc + custtemp^.name2 + config.textcol1 + ' died along with ' + sex3[custtemp^.sex] + ' leader!',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '');

                      {skicka ett mess till den d”de!}

                      nice2[1] := 'You died under the command of ' + uplc + player.name2 + config.textcol1 + '!';
                      nice2[2] := 'You fought bravely, but the monsters were too strong...';
                      nice2[3] := 'A ' + umonc + killed_by[i] + config.textcol1 + ' took your life.';
                      team_report(custtemp^.name2,
                        3,
                        nice2[1], nice2[2], nice2[3], nice2[4]);

                    end;
                  end;
                end; {for i:= .end.}

                {news-paper}
                newsy(True,
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

                d(config.textcolor, 'You fall to the ground...deadly injured...!');
                d(config.textcolor, 'Your adventure ended in pain and misery!');
                d(config.textcolor, 'You close your eyes...');
                d(config.textcolor, 'Darkness...');
                crlf;
                pause;
              end;

              crlf;
              pause;
              normal_exit;
            end else
            begin

            end;
          end;
        end;
      end;
    end; {case .end.}

  until leave_dungeons;

  crlf;
  crlf;
  d(config.textcolor, 'You begin your journey home...');
  {player has made it out alive}
  {was the team with him?}
  if (pl[1]^.name2 <> '') or (pl[2]^.name2 <> '') or (pl[3]^.name2 <> '') or
    (pl[4]^.name2 <> '') then
  begin

    {news-paper}
    newsy(False,
      'Party Returns',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');

    for i := 1 to 5 do
    begin
      case i of
        1: custtemp^ := player;
        2: custtemp^ := pl[1]^;
        3: custtemp^ := pl[2]^;
        4: custtemp^ := pl[3]^;
        5: custtemp^ := pl[4]^;
      end; {case .end.}

      if custtemp^.name2 <> '' then
      begin
        if custtemp^.hps > 0 then
        begin
          {news-paper}
          newsy(False,
            ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + ' made it out alive from the Dungeons.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
        end else
        begin

          {create random "news of death"}
          case random(6) of
            0: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + ' was massacred by a ' + umonc + killed_by[i] + config.textcol1 + '!';
            1: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + ' encountered a ' + umonc + killed_by[i] + config.textcol1 + ' and was killed.';
            2: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + 's mutilated corpse was left behind.' + config.textcol1;
            3: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + ' was killed by a ' + umonc + killed_by[i] + config.textcol1 + '.';
            4: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + 's life was taken by a ' + umonc + killed_by[i] + config.textcol1 + '.';
            5: s := ' ' + uplc + custtemp^.name2 + config.textcol1 + ' the ' + classnames[custtemp^.classid] + ' was mauled by a ' + umonc + killed_by[i] + config.textcol1 + '.';
          end; {case .end.}

          {News-paper}
          newsy(False,
            s,
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

          {send a mess to the dead player!}
          nice2[1] := 'You died under the command of ' + uplc + player.name2 + config.textcol1 + '!';
          nice2[2] := 'You fought bravely in the dungeons, but the monsters got you!';
          nice2[3] := 'A ' + umonc + killed_by[i] + config.textcol1 + ' took your life.';
          team_report(custtemp^.name2,
            3,
            nice2[1],
            nice2[2],
            nice2[3],
            nice2[4]);
        end;

        {saving player}
        user_save(custtemp^);

      end;

    end; {for i:= .end.}

    {news-paper: send a ending crlf to the news file}
    newsy(True,
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

  {dispose of pointer variables}
  disposal;

end; {Dungeons *end*}

end. {Unit DungeonC .end.}
