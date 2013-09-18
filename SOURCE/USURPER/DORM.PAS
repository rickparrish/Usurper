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


unit Dorm; {Usurper - the Dormitory}

interface

procedure Dormitory;

implementation

uses
  Init, Cms, Jakob,
  Statusc, Mail,
  News,
  Various, Various2, Various3,
  Online, File_Io, SysUtils;

const maxboys = 5; {max people that can be in a fist-fight}

type
  FistBoyRec = record  {Offline characters when fighting trouble-maker}
    Name:      string[30]; {name}
    filnr:     byte; {1=player file, 2=npc file}
    recnr:     word; {record # in file}
    ai:        char; {'H'uman or 'C'omputer}
    sex:       byte; {1=male,2=female}
    level:     word; {character level}
    stamina:   smallint; {stamina}
    strength:  smallint; {strength}
    myexp:     longint; {experience earned during fight}
    myfate:    string[100]; {knocked out by whom? empty string means that he survived}
    me_nailed: word; {i was nailed in this round}
    skill:     array[1..global_maxcombat] of smallint; {close-combat skills}
  end;

var
  fistboys: array[1..maxboys] of ^FistBoyRec; {the fighting bunch}
  npckill:  boolean; {is players allowed to attack npcs?}
  teamkill: boolean; {is player allowed to attack teammates?}

procedure Fist_Fight; {Player engages in a fist-fight against a number
                       of opponents}
var
  ch:           char;

  move_string:  array[1..global_maxcombat] of s30;
  allow_move:   array[1..global_maxcombat] of boolean;
  allow_char:   array[1..global_maxcombat] of char;

  enemy_is_down: boolean; {set when all enemies are down}
  player_is_down: boolean; {set when player is down}
  player_fled:  boolean; {set when player flees}

  round:        word; {fight round}
  player_stamina: integer; {player stamina}
  player_exp:   longint; {player experience accumulated during fight}

  boy:          byte; {current enemy}
  max_options:  byte; {max number of different moves available to player
                         every bout}

  {used by many routines}
  ok, go_ahead: boolean;

  i, j, x, y:   longint;

  lastboy:      s30;
  roundstr:     string[6];

  s, myexp, myfate, player_fate: s100; {used when producing mail}

  knocker:      s30; {string used to keep name of who knocked player out}
  bash:         byte; {bash # used by offline kicker}

  pl0:          ^UserRec; {player record}

begin

 {programmers note: it could become a bit ridiculous if a player knocks
  out all opponents and then starts a new brawl, and encounters some
  of the guys he just took out... how should this be solved?}

  {you lift up Jenny and squeeze her!}
  {Mooney sees an opportunity and tries to escape!}
  {Maxie tries to ram you, but misses and hits Jimbo insted!}
  {surprise left}
  {shrugs it off}
  {floor him! stomp her!}
  {Oh no! He anticipated that move!}
  {From the back of the room Slim screams : "Get Slash! Get Slash!"}

  {initialize vars}
  new(pl0);
  round := 0;
  enemy_is_down := False;
  player_is_down := False;
  player_fled := False;
  player_exp := 0;

  player_stamina := player.stamina;

  {move strings}
  for i := 1 to global_maxcombat do
  begin
    move_string[i] := bash_name(i);

    insert('(', move_string[i], 1);
    insert(')', move_string[i], 3);
  end; {for i:= .end.}

  {strange comment from offline players before fight begins}
  {just to scare the player a bit}
  for i := 1 to maxboys do
  begin
    if (fistboys[i]^.Name <> '') and (fistboys[i]^.stamina > 0) then
    begin
      case random(11) of
        0: begin
          sd(global_plycol, fistboys[i]^.Name);
          d(config.textcolor, ' grins and shows ' + sex3[fistboys[i]^.sex] + ' teeth; ');
          d(global_talkcol, ' I''m gonna bite you bad ' + player.name2 + '!');
          pause;
          crlf;
          break;
        end;
        1: begin
          sd(config.textcolor, 'You notice ');
          sd(global_plycol, fistboys[i]^.Name);
          d(config.textcolor, ' gulp down a bottle of some kind of elixir.');
          d(15, ' (gulp)');
          pause;
          crlf;
          break;
        end;
      end; {case .end.}

    end;
  end; {for i:= .end.}

  {fight-loop}
  repeat
    Inc(round);

    {check if player is conscious}
    go_ahead := False;
    if player_stamina > 0 then
    begin
      go_ahead := False;
      {are there enemies left?}
      for i := 1 to maxboys do
      begin
        if fistboys[i]^.stamina > 0 then
        begin
          go_ahead := True;
          break;
        end;
      end; {for i:= .end.}
    end;

    if go_ahead then
    begin
      {who should player meet in this bout}
      ok := False;
      repeat
        boy := random(maxboys) + 1;
        if (fistboys[boy]^.Name <> '') and (fistboys[boy]^.stamina > 0) then
        begin
          ok := True;
        end;
      until ok;

      crlf;
      d(15, '(Power ' + commastr(player_stamina) + '/' + commastr(player.stamina) + ')');
      crlf;
      sd(12, 'You are facing ');
      sd(global_plycol, fistboys[boy]^.Name);
      d(12, '!');
      crlf;

      {every situation only gives a certain amount of possible (combat) moves}
      for i := 1 to global_maxcombat do
      begin
        allow_move[i] := False;
        allow_char[i] := ' ';
      end; {for i:= .end.}

      max_options := 2;
      x := 1;
      repeat
        y := random(global_maxcombat) + 1;

        if allow_move[y] = False then
        begin
          allow_move[y] := True;
          allow_char[y] := move_string[y][2];
          Inc(x);
        end;

      until x > max_options;

      {display allowed menu choices/ combat moves}
      for i := 1 to global_maxcombat do
      begin
        if allow_move[i] then
        begin
          menu2(move_string[i] + '  ');
        end;
      end; {for i:= .end.}

      menu2('(F)lee :');

      {get user-input}
      ok := False;
      repeat
        ch := upcase(getchar);
        if ch = 'F' then
        begin
          crlf;
          if confirm('Flee', 'N') = False then
          begin
            ch := ' ';
          end;
        end else
        begin
          for i := 1 to global_maxcombat do
          begin
            if (allow_move[i] = True) and (ch = allow_char[i]) then
            begin
              ok := True;
              break;
            end;
          end; {for i:= .end.}
        end;
      until (ok) or (ch = 'F'); {'f'lee}

      {evaluate user-input}
      case ch of
        'F': begin {player tries to flee}
          {chance of success}
          x := random(5);
          if x = 0 then
          begin
            d(15, 'You manage to throw yourself out through a window!');
            player_fled := True;
            pause;
          end else
          begin

            case random(2) of
              0: begin {player tries to flee, but is dragged back}
                sd(12, 'You head for the exit but...');
                make_delay_dots(12, 4, 300);
                crlf;
                ok := False;
                repeat
                  for i := 1 to maxboys do
                  begin
                    if (fistboys[i]^.Name <> '') and (fistboys[i]^.stamina > 0) and
                      (random(3) = 0) then
                    begin
                      ok := True;

                      sd(global_plycol, fistboys[i]^.Name);
                      d(12, ' comes from behind and grabs a firm hold of your hair!');
                      d(12, 'You are dragged back in the fight!');
                      d(15, '(damn!)');
                      pause;

                      break;
                    end;
                  end;
                until ok;
              end; {flee attempt 1 .end.}
              1: begin {player tries to flee, but the exits are blocked}
                crlf;
                sd(12, 'You head for the exit...');
                make_delay_dots(12, 4, 300);
                crlf;
                d(12, 'But it''s blocked!');
                d(15, '(damn!)');
                pause;
              end;

            end; {case .end.}

          end;

        end {flee *end*} else begin
          {player attack .start.}
          crlf;
          crlf;
          if (random(5) < 2) and (random(hitchance(player.skill[i])) <> 0) then
          begin
            d(12, 'You missed!');
          end else
          begin
            sd(14, 'You hit ');
            sd(global_plycol, fistboys[boy]^.Name);
            d(14, '!');

            Dec(fistboys[boy]^.stamina, bash_damage(player.strength));

            {nailed!}
            if fistboys[boy]^.stamina < 1 then
            begin
              sd(global_plycol, fistboys[boy]^.Name);
              d(14, ' stumbles to the ground! You floored ' + sex[fistboys[boy]^.sex] + '!');

              {set history}
              fistboys[boy]^.myfate := uplc + player.name2 + config.textcol1 + ' nailed you! (round ' + commastr(round) + ')';
              fistboys[boy]^.me_nailed := round;

              {give player some exp}
              Inc(player_exp, fistboys[boy]^.level * 100);

            end;

          end;
        end; {player attack .end.}
      end; {case ch .end.}

      {let the offline guys make their moves}
      for i := 1 to maxboys do
      begin
        if (fistboys[i]^.Name <> '') and (fistboys[i]^.stamina > 0) and
          (player_stamina > 0) and (player_fled = False) then
        begin

          bash := random(global_maxcombat) + 1;

          {pre opponent attack text}
          case random(2) of
            0: begin
              sd(config.textcolor, 'in the corner of your eye you see ');
              sd(global_plycol, fistboys[i]^.Name);
              sd(config.textcolor, ' attempting a ');
            end;
            1: begin
              sd(config.textcolor, 'coming in from behind you get a glimpse of ');
              sd(global_plycol, fistboys[i]^.Name);
              sd(config.textcolor, ' trying a ');
            end;
          end; {case .end.}

          {type of bash}
          sd(global_bashcol, bash_name(bash));
          d(config.textcolor, '!');

          {player is hit!}
          if random(3) = 0 then
          begin
            d(12, 'OUCH! That hurt!');

            {remove some player power}
            Dec(player_stamina, bash_damage(fistboys[i]^.strength));

            {give offline player some xp for every HIT}
            y := player.level * 50;
            Inc(fistboys[i]^.myexp, y);

            {is player down?}
            if player_stamina < 1 then
            begin
              d(12, 'You have been overpowered!');
              knocker := fistboys[i]^.Name;
            end;

          end {player evaded the attack}
          else
          begin

            case random(2) of
              0: d(14, 'That swept passed you! You managed to evade the attack!');
              1: d(14, 'You managed to dodge!');
            end; {case .end.}

            if random(4) = 0 then
            begin
              {hit friend}
              ok := False;
              boy := 0;
              x := 0;
              repeat
                for j := 1 to maxboys do
                begin
                  if (fistboys[j]^.Name <> '') and (fistboys[j]^.stamina > 0) and
                    (fistboys[j]^.Name <> fistboys[i]^.Name) and (random(3) = 0) then
                  begin
                    boy := j;
                    ok := True;
                    break;
                  end;

                  Inc(x);
                end;
              until (ok) or (x > 30);

              if boy > 0 then
              begin

                {ok, lets hit one of the friendly guys, since we missed player}
                sd(config.textcolor, 'In ' + sex3[fistboys[i]^.sex] + ' eagerness to get you, ');
                sd(config.textcolor, sex2[fistboys[i]^.sex] + ' hits ');
                sd(global_plycol, fistboys[boy]^.Name);
                d(config.textcolor, ' by mistake!');

                Dec(fistboys[boy]^.stamina, bash_damage(fistboys[i]^.strength));

                {opponent is down}
                if fistboys[boy]^.stamina < 1 then
                begin
                  sd(global_plycol, fistboys[boy]^.Name);
                  d(12, ' goes down!');

                  {set history}
                  fistboys[boy]^.myfate := uplc + fistboys[i]^.Name + config.textcol1 + ' floored you by mistake!';
                  fistboys[boy]^.me_nailed := round;

                end;

              end;

            end; {if random(4) .end.}

          end;

        end;
      end;

    end; {if go_ahead .end.}

    {check if player is knocked out}
    if player_stamina < 1 then
    begin
      player_is_down := True;
    end;

    {check if opponents are knocked out}
    enemy_is_down := True;
    for i := 1 to maxboys do
    begin
      if (fistboys[i]^.Name <> '') and (fistboys[i]^.stamina > 0) then
      begin
        enemy_is_down := False;
        break;
      end;
    end;

  until (enemy_is_down) or (player_is_down) or (player_fled);
  {FIGHT-LOOP *END*}

  {evaluate the fight}

  {set the lastboy, so we can produce nice news-paper}
  lastboy := '';
  for i := 1 to maxboys do
  begin
    if fistboys[i]^.Name <> '' then
    begin
      lastboy := fistboys[i]^.Name;
    end;
  end;

  {roundstr is used to display number of fight rounds in the news}
  roundstr := 'round';
  if round > 1 then roundstr := roundstr + 's';

  {creating news lines that are default in all news-paper events}
  s := '';
  for i := 1 to maxboys do
  begin
    if fistboys[i]^.Name <> '' then
    begin

      if s = '' then
      begin
        s := uplc + fistboys[i]^.Name + config.textcol1;
      end else if fistboys[i]^.Name = lastboy then
      begin
        s := s + ' and ' + uplc + fistboys[i]^.Name + config.textcol1;
      end else
      begin
        s := s + ', ' + uplc + fistboys[i]^.Name + config.textcol1;
      end;

    end;
  end; {for i:= .end.}

  {save offline characters}
  for i := 1 to maxboys do
  begin

    if (fistboys[i]^.Name <> '') and (fistboys[i]^.myexp > 0) then
    begin

      {load character}
      if load_character(pl0^, fistboys[i]^.filnr, fistboys[i]^.recnr) = True then
      begin

        {transfer values}
        incplayerexp(pl0^, fistboys[i]^.myexp);

        {save character}
        user_save(pl0^);
      end;

    end;

  end; {for i:= .end.}


  if player_fled then
  begin

    {news-paper}
    Newsy(True,
      'Fist Fight',
      ' ' + uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
      ' ' + s,
      ' were angered and stood up against ' + uplc + player.name2 + config.textcol1 + '.',
      ' ' + uplc + player.name2 + config.textcol1 + ' fled after ' + commastr(round) + ' ' + roundstr + '.',
      '',
      '',
      '',
      '',
      '');

    {mail offline participants}
    for i := 1 to maxboys do
    begin
      if (fistboys[i]^.Name <> '') and (fistboys[i]^.ai = 'H') then
      begin

        if fistboys[i]^.myfate = '' then
        begin
          myfate := 'You stood on your feet during the whole fight! Well done!';
        end else
        begin
          myfate := fistboys[i]^.myfate;
        end;

        if fistboys[i]^.myexp > 0 then
        begin
          myexp := 'You earned ' + uwhite + commastr(fistboys[i]^.myexp) + config.textcol1 + ' experience points.';
        end else
        begin
          myexp := '';
        end;

        {player fate}
        player_fate := uplc + player.name2 + config.textcol1 + ' fled after ' + commastr(round) + ' ' + roundstr + ' (the coward).';

        {mail}
        post(MailSend,
          fistboys[i]^.Name,
          fistboys[i]^.ai,
          False,
          mailrequest_nothing,
          '',
          ulred + 'Fist Fight' + config.textcol1,
          mkstring(10, underscore),
          uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
          'You and several others joined to throw out the trouble-maker.',
          myfate,
          player_fate,
          myexp,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
    end; {for i:= .end.}

  end {player fled *end*} else if (player_is_down) and (enemy_is_down) then
  begin
    {should never happen}
  end else if player_is_down then
  begin

    {news-paper}
    Newsy(True,
      'Fist Fight',
      ' ' + uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
      ' ' + s,
      ' were angered and stood up against ' + uplc + player.name2 + config.textcol1 + '.',
      ' ' + ulred + player.name2 + config.textcol1 + ' was floored in the ' + commastr(round) + ' round!',
      '',
      '',
      '',
      '',
      '');

    {mail offline participants}
    for i := 1 to maxboys do
    begin
      if (fistboys[i]^.Name <> '') and (fistboys[i]^.ai = 'H') then
      begin

        if fistboys[i]^.myfate = '' then
        begin
          myfate := 'You stood on your feet during the whole fight! Well done!';
        end else
        begin
          myfate := fistboys[i]^.myfate;
        end;

        if fistboys[i]^.myexp > 0 then
        begin
          myexp := 'You earned ' + uwhite + commastr(fistboys[i]^.myexp) + config.textcol1 + ' experience points.';
        end else
        begin
          myexp := '';
        end;

        {player fate}
        player_fate := uplc + player.name2 + config.textcol1 + ' was floored in the ' + commastr(round) + ' round!';

        {mail}
        post(MailSend,
          fistboys[i]^.Name,
          fistboys[i]^.ai,
          False,
          mailrequest_nothing,
          '',
          ulred + 'Fist Fight' + config.textcol1,
          mkstring(10, underscore),
          uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
          'You and several others joined to throw out the trouble-maker.',
          myfate,
          player_fate,
          myexp,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
    end; {for i:= .end.}


    {mail player to remind him of what happened to him}
    post(MailSend,
      player.name2,
      player.ai,
      False,
      mailrequest_nothing,
      '',
      ulred + 'Your Downfall' + config.textcol1,
      mkstring(13, underscore),
      'You were knocked cold by ' + uplc + knocker + config.textcol1 + ' in a fist fight.',
      'No one to blame but yourself.',
      'It was you who provoked the guys at the Dorm.',
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

    d(config.textcolor, 'You dream of the stars...');

    if config.dormwakeupcallallow = False then
    begin
      {player.allowed:=false;}
      Reduce_Player_Resurrections(player, True);
      player.hps := 0;
    end;

    pause;
    normal_exit;

  end else if enemy_is_down then
  begin

    {news-paper}
    Newsy(True,
      'Fist Fight',
      ' ' + uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
      ' ' + s,
      ' were angered and stood up against ' + uplc + player.name2 + config.textcol1 + '.',
      ' ' + uplc + player.name2 + config.textcol1 + ' floored ALL opponents in ' + commastr(round) + ' ' + roundstr + '!',
      '',
      '',
      '',
      '',
      '');

    {mail offline participants}
    for i := 1 to maxboys do
    begin
      if (fistboys[i]^.Name <> '') and (fistboys[i]^.ai = 'H') then
      begin

        if fistboys[i]^.myfate = '' then
        begin
          myfate := 'You were beat up!';
        end else
        begin
          myfate := fistboys[i]^.myfate;
        end;

        if fistboys[i]^.myexp > 0 then
        begin
          myexp := 'You earned ' + uwhite + commastr(fistboys[i]^.myexp) + config.textcol1 + ' experience points.';
        end else
        begin
          myexp := '';
        end;

        {player fate}
        player_fate := '';

        {mail}
        post(MailSend,
          fistboys[i]^.Name,
          fistboys[i]^.ai,
          False,
          mailrequest_nothing,
          '',
          ulred + 'Fist Fight' + config.textcol1,
          mkstring(10, underscore),
          uplc + player.name2 + config.textcol1 + ' provoked a fight in the Dormitory!',
          'You and several others joined to throw out the trouble-maker.',
          myfate,
          player_fate,
          myexp,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;

    end; {for i:= .end.}

    {good work text and experience reward}
    d(15, 'Good work!');
    sd(config.textcolor, 'You earned ');

    sd(15, commastr(player_exp));

    incplayerexp(player, player_exp);

    d(config.textcolor, ' experience points for this fight.');
    crlf;
    pause;

  end;

  {dispose pointer vars}
  dispose(pl0);

end; {fist_fight **END**}


procedure Examine_Sleeper(npckill: boolean);
var
  s:        s90;

  ii, size: integer;

  i, j:     longint;

  found:    boolean;

  pl0:      ^UserRec;

begin

  {init pointer variables}
  new(pl0);

  crlf;
  crlf;
  d(config.textcolor, 'Who do you want to examine?');
  sd(config.textcolor, ':');

  {get user input}
  s := get_string(25);
  s := UpperCase(s);

  found := False;

  ii := 2;
  if not npckill then Dec(ii);

  for i := 1 to ii do
  begin

    size := 1;
    case i of
      1: size := fs(FsPlayer);
      2: size := fs(FsNpc);
    end; {case .end.}

    for j := 1 to size do
    begin

      if load_character(pl0^, i, j) = True then
      begin

        if (findsub(s, pl0^.name2)) and
          (pl0^.king = False) and
          (pl0^.name2 <> player.name2) and
          (player_active(pl0^, True) = True) and
          (pl0^.location = offloc_dormitory) then
        begin

          if is_online(pl0^.name2, online_player) = False then
          begin

            if confirm(uplc + pl0^.name2 + config.textcol1, 'N') = True then
            begin
              s := pl0^.name2;
              found := True;

              {display sleeping person}
              sleep_dormitory(pl0^);
              found := True;
            end else
            begin

              if confirm('Continue search', 'Y') = False then
              begin
                found := True;
              end;

            end;
          end;
        end;
      end;

      if found then break;

    end; {for j:= .end.}
    if found then break;
  end; {for i:= .end.}

  if found = False then
  begin
    Could_Not_Locate_Character;
  end;

  {dispose pointer vars}
  dispose(pl0);

end; {examine_sleeper *end*}


procedure Meny;
var
  justval: word;
begin

  clearscreen;
  d(5, 'Dormitory of the Franciscan order');
  d(5, '+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+');
  crlf;
  d(config.textcolor, 'You enter the dormitory and watch all the sleeping');
  d(config.textcolor, 'adventurers. They are lying there like babies. Loud snores');
  d(config.textcolor, 'come from the trolls, silent breathing from the elves and short');
  d(config.textcolor, 'snivels from the gnolls, as if they were having bad dreams or something...');

  crlf;
  justval := 16;

  menu2(ljust('(A)ttack guest', justval));
  menu2(ljust('(L)ist of Souls', justval + 6));
  menu('(W)ake the guests (' + ulred + 'dangerous' + config.textcol1 + ')');

  menu2(ljust('(S)tatus', justval));
  menu('(E)xamine character');

  menu2(ljust('(R)eturn', justval));
  menu('(G)o to sleep');

end; {meny *end*}

procedure Display_Menu(force, short: boolean; var refresh: boolean);
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

      sd(config.textcolor, 'Dormitory (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');

    end else
    begin
      crlf;
      sd(config.textcolor, 'Dormitory (L,A,E,G,W,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure Dormitory; {MAIN **START**}
const never: boolean = False;
  givemeboys: byte   = 5;
var

  refresh:  boolean;

  cho, ch:  char;

  s:        s100;

  size:     word;

  x:        longint;

  k, guys:  byte;

  i, j, ii: longint;

  found, go_ahead, pause_check: boolean;

  pl0:      ^UserRec;

begin

  {init pointer vars}
  new(pl0);

  {get 'kill teammates' from .CFG}
  s := cfg_string(35);
  teamkill := False;
  if UpperCase(s) = 'YES' then teamkill := True;

  {get 'kill npcs' from .CFG}
  s := cfg_string(39);
  npckill := False;
  if UpperCase(s) = 'YES' then npckill := True;

  crlf;
  crlf;
  d(config.textcolor, 'You enter the ' + ulgreen + 'Dormitory' + config.textcol1);
  crlf;

  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_dormitory then
    begin
      refresh := True;
      onliner.location := onloc_dormitory;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {auto-probe, players is moving automatically}
    case global_auto_probe of
      NoWhere: begin
        display_menu(True, True, refresh);
        cho := upcase(getchar);
      end;

      Dormy: begin
        crlf;
        d(config.textcolor, 'You are awake. Sleeping here in the Dormitory isn''t');
        d(config.textcolor, 'too comfortable. You deserve better than this, you think');
        d(config.textcolor, 'to yourself while you get dressed.');
        crlf;
        pause;

        global_auto_probe := NoWhere;
        cho := '?';
      end;
    end; {case .end.}

    {evaluate user-input}
    case cho of
      '?': begin {display menu}
        if player.expert = True then display_menu(True, False, refresh)
        else display_menu(False, False, refresh);
      end;
      'G': begin {go to sleep in the dormitory, same as quitting from main menu}
        crlf;
        crlf;
        if confirm('Stay here for the night', 'N') = True then
        begin
          clearscreen;
          d(config.textcolor, 'You take one of the free beds in the dormitory.');
          d(config.textcolor, 'Soon you fall asleep to the heavy breathing from the');
          d(config.textcolor, 'sleeping adventurers...');
          crlf;

          {set player location}
          player.location := Offloc_Dormitory;
          pause;

          {exit}
          normal_exit;

        end else
        begin
          d(12, 'Nah, You deserve better than this.');
        end;

      end;
      'S': begin {status}
        status(player);
        crlf;
      end;
      'R': begin {return to street}
        dispose(pl0);
        crlf;
        exit;
      end;
      'E': begin {examine sleeping guest}
        examine_sleeper(npckill);
      end;
      'A': begin {attack sleeping guest}
        attack_guest(npckill, teamkill); {various3.pas}
      end;
      'W': begin {Wake everybody up at the dormitory, kind of a suicide thing}
        crlf;
        crlf;
        d(15, 'Wake up call');
        d(config.textcolor, 'Ruining people''s sleep is fun, but not advisable.');
        d(config.textcolor, 'There''s going to be trouble for sure.');
        crlf;

        {make noise!?}
        if confirm('Make a Noise in here', 'N') then
        begin

          {wake them up how}
          menu('(U)se the GONG');
          menu('(S)cream');
          menu('(A)bort');
          sd(config.textcolor, ':');

          repeat
            ch := upcase(getchar);
          until ch in ['U', 'S', 'A'];


          if ch = 'A' then
          begin
            crlf;
            d(15, 'Chicken!');
          end else if player.darknr < 1 then
          begin
            crlf;
            d(12, 'Sorry, you have no dark deeds left today.');
            crlf;
            pause;
          end else
          begin

            {give playe some dark points}
            d(15, 'Oops! Your soul turned a bit darker after this!');
            x := random(75) + 55;
            give_darkness(player, x);

            {how many enemies should wake up and confront player}
            givemeboys := random(5) + 1;
            if givemeboys < 2 then givemeboys := 2;

            {init and reset pointer vars}
            for i := 1 to maxboys do
            begin
              new(fistboys[i]);
              fistboys[i]^.Name := '';
            end; {for i:= .end.}

            {reduce dark deeds left today}
            Dec(player.darknr);

            crlf;
            case ch of
              'S': begin {scream}
                crlf;
                d(config.textcolor, 'You take a deep breath and scream for all that you''re worth;');
                sd(global_talkcol, 'Ayyyiieeeeeee!!!..');
                Make_Delay_Dots(global_talkcol, 5, 300);
                crlf;

              end;
              'U': begin {Using the GONG}
                crlf;
                d(config.textcolor, 'You go for the Dormitory GONG.');
                sd(config.textcolor, 'Here goes...');
                Make_Delay_Dots(2, 3, 400);
                sd(config.textcolor, 'DONG!');
                Make_Delay_Dots(2, 3, 400);
                sd(config.textcolor, 'DONG!');
                Make_Delay_Dots(2, 3, 400);
                sd(config.textcolor, 'DONG!');
                crlf;

              end;
            end; {case .end.}

            d(15, 'Great! You managed to wake some of the guests!');
            x := player.level * 300;

            incplayerexp(player, x);

            sd(config.textcolor, 'You earn ');
            sd(15, commastr(x));
            d(config.textcolor, ' experience points for this brave (but foolish) stunt.');

            pause;


            guys := 0;
            {wake some of the guests}
            for i := 1 to 2 do
            begin

              case i of
                1: size := fs(fsplayer);
                2: size := fs(fsnpc);
              end;

              go_ahead := True;
              if (i = 2) and (npckill = False) then
              begin
            {npcs are not available at the Dorm, thus they can't be awakened
             either}
                go_ahead := False;
              end;

              if go_ahead then
              begin
                for j := 1 to size do
                begin

                  if load_character(pl0^, i, j) = True then
                  begin

                    if (player_active(pl0^, True) = True) and
                      (pl0^.hps > 0) and
                      (pl0^.location = offloc_dormitory) and
                      (pl0^.name2 <> player.name2) and
                      (is_online(pl0^.name2, online_player) = False) then
                    begin

                      if random(8) = 0 then
                      begin

                        {add shadow player}
                        if add_shadow(SAdd, pl0^, player.name2, 'FISTFIGHT IN THE DORMITORY', 0) = True then
                        begin

                          {random text, describing angry guest wakening up to players noise}
                          case random(3) of
                            0: begin
                              sd(global_plycol, pl0^.name2);
                              d(12, ' wants to have a word with you!');
                            end;
                            1: begin
                              sd(global_plycol, pl0^.name2);
                              d(12, ' has rolled up ' + sex3[pl0^.sex] + ' sleeves!');
                            end;
                            2: begin
                              sd(global_plycol, pl0^.name2);
                              d(12, ' jumps out of ' + sex3[pl0^.sex] + ' bed!');
                            end;
                          end; {case .end.}

                          Inc(guys);

                          {setup fistboy record}
                          with fistboys[guys]^ do
                          begin
                            Name := pl0^.name2;
                            filnr := i;
                            recnr := j;
                            ai := pl0^.ai;
                            sex := pl0^.sex;
                            level := pl0^.level;
                            stamina := pl0^.stamina;
                            strength := pl0^.strength;
                            myexp := 0;
                            myfate := '';
                            me_nailed := 0;
                            for k := 1 to global_maxcombat do
                            begin
                              skill[k] := pl0^.skill[k];
                            end;
                          end; {with .end.}

                        end;
                      end;

                    end;
                  end;

                  if guys = givemeboys then break;

                end; {for j:= .end.}
              end;

              if guys = givemeboys then break;

            end; {for i:= .end.}

            {if we couldn't find any opppents then there will be no fight}
            if guys = 0 then
            begin
              d(15, 'Apparently there is no one to fight here!');
              d(15, 'Too bad really.');
              pause;
            end else
            begin

              {initalize fist-fight with infuriated guests}

              {Update player location & doing}
              onliner.location := onloc_dormfists;
              onliner.doing := location_desc(onliner.location);
              add_onliner(OUpdateLocation, onliner);

              {fist fight!}
              fist_fight;

            end;

            {remove shadow players}
            for i := 1 to maxboys do
            begin
              if fistboys[i]^.Name <> '' then
              begin
                if load_character(pl0^, fistboys[i]^.filnr, fistboys[i]^.recnr) = True then
                begin
                  add_shadow(SRemove, pl0^, '', '', 0);
                end;
              end;
            end; {for i:= .end.}

            {dispose pointer vars}
            for i := 1 to maxboys do
            begin
              dispose(fistboys[i]);
            end; {for i:= .end.}

          end;

        end else
        begin
          {player decided not to make a noise in the Dormitory}
          d(12, 'Good for you.');
        end;

      end;
      'L': begin {list sleeping adventurers}
        crlf;
        crlf;
        sd(5, 'Sleeping adventurers : ');

        sd(7, '<M>arried, <K>ing, <Q>ueen');

        if config.marknpcs then
        begin
          sd(7, ',');
          sd(14, ' *');
          sd(5, '=computer player)');
        end;

        crlf;

        d(5, mkstring(22, underscore));

        found := False;
        pause_check := True;
        ii := 2;
        for i := 1 to 2 do
        begin

          case i of
            1: size := fs(FsPlayer);
            2: size := fs(FsNpc);
          end; {case .end.}

          if (i = 2) and (npckill = False) then
          begin
            break;
          end else if found then
          begin
            break;
          end;

          for j := 1 to size do
          begin

            {load character}
            if load_character(pl0^, i, j) = True then
            begin

              if (pl0^.location = offloc_dormitory) and
                (pl0^.allowed = True) and
                (player_active(pl0^, True) = True) and
                (pl0^.hps > 0) and
                (pl0^.king = False) and
                (pl0^.name2 <> player.name2) and
                (is_online(pl0^.name2, online_player) = False) then
              begin

                {name}
                sd(global_plycol, pl0^.name2);

                {race}
                sd(config.textcolor, ', the ' + race_display(2, pl0^.race, 0));

                {class}
                sd(config.textcolor, ' (');
                sd(3, 'level ' + commastr(pl0^.level) + ' ' + classnames[pl0^.classid]);
                sd(config.textcolor, ') ');

                {married flag}
                if (config.WriteMarriedFlag = True) and
                  (pl0^.married = True) then
                begin
                  sd(7, '<M>');
                end;

                {king}
                if pl0^.king = True then
                begin
                  if pl0^.sex = 1 then sd(7, '<K>')
                  else sd(7, '<Q>');
                end;

                {how are my chances text}
                {chances_eval(pl0^);}

                crlf;

                if pause_check = True then
                begin
                  Inc(ii);
                  if ii > global_screenlines - 2 then
                  begin
                    ii := 0;

                    sd(config.textcolor, 'Continue (' + config.textcol2 + 'e' + config.textcol1 + ')xamine (' + config.textcol2 + 'a' + config.textcol1 + ')ttack ? ([Y]/N/=)');

                    {get user-input}
                    repeat
                      cho := upcase(getchar);
                    until cho in [ReturnKey, 'Y', 'N', '=', 'E', 'A'];
                    crlf;

                    {evaluate user-input}
                    case cho of
                      'N': begin
                        found := True;
                        break;
                      end;
                      '=': begin
                        pause_check := False;
                      end;
                      'E': begin
                        examine_sleeper(npckill);
                      end;
                      'A': begin
                        attack_guest(npckill, teamkill);
                      end;
                    end; {case ch of .end.}

                  end;
                end;
              end;
            end;

          end; {for j:= .end.}

        end; {for i:= .end.}

        crlf;
        pause;
        crlf;
      end;

    end; {case .end.}

  until never;

end; {Dormitory *end*}

end. {Unit Dorm .end.}
