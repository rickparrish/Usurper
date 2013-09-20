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



unit PlyQuest; {Usurper - Player Quest Room}

interface

procedure Player_Quest;

implementation

uses
  Init, Cms, Jakob,
  Statusc, PlVsMon, Various,
  Various2, Various3, SpellsU,
  News, Mail, File_io,
  Online;

const
  {name of place}
  local_place = 'Quest Hall';

var
  refresh: boolean;

procedure Meny;
const offset = 22;
  clerk      = 'Pingon';
begin

  clearscreen;
  crlf;
  d(5, '-*- ' + local_place + ' -*-');
  crlf;
  d(config.textcolor, 'The Hallroom is dimly lit with shady characters moving close to');
  d(config.textcolor, 'the walls and in the corners. Hardened veterans are leaning');
  d(config.textcolor, 'over their weapons giving you hostile glares.');
  d(config.textcolor, 'The royal clerk ' + uplc + clerk + config.textcol1 + ' is here to distribute the');
  d(config.textcolor, 'assignments.');
  crlf;

  menu2(ljust('(C)laim a Quest', offset));
  menu('(Q)uest Masters');

  menu('(F)inish your Quest');
  menu('(S)tatus');
  menu('(R)eturn');

end;

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
      sd(config.textcolor, local_place + ' (');
      sd(config.hotkeycolor, '?');
      sd(config.textcolor, ' for menu) :');
    end else
    begin

      crlf;
      sd(config.textcolor, local_place + ' (L,Q,C,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;

end;

function mini_menu: byte;
var
  ch:     char;
  Result: byte;
begin

  {init}
  Result := 0;
  repeat
    {options}
    crlf;
    menu2('(M)ore  ');
    menu2('(P)ick  ');
    menu2('(A)bort :');

    {get user-input}
    ch := upcase(getchar);

  until ch in [ReturnKey, 'M', 'P', 'A'];

  crlf;
  case ch of
    'A': begin {abort}
      Result := 2;
    end;
    'P': begin {pick}
      Result := 1;
    end;
  end; {case .end.}

       {return result}
  mini_menu := Result;

end; {mini_menu *end*}

procedure Player_Quest;
var
  ch:          char;

  counter, memsize, i, j: word;

  x:           longint;

  offset, counter2, r, k, l: byte;

  s:           s100;
  info:        s70;

  pl1, pl2, pl3, pl4: ^UserRec;

  quest:       questrec;

  king:        kingrec;

  leave_place: boolean;

begin

  {intro text}
  crlf;
  crlf;
  d(config.textcolor, 'You enter the ' + uplc + local_place + config.textcol1 + '.');
  crlf;

  {init pointer variables}
  new(pl1);
  new(pl2);
  new(pl3);
  new(pl4);

  leave_place := False;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_QuestHall then
    begin
      refresh := True;
      onliner.location := onloc_QuestHall;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, Onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user input}
    case ch of

      '?': begin {menu}
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
      end;
      'R': begin {leave quest hall}
        leave_place := True;
      end;
      'Q': begin {list of top quest masters}
        quest_rankings;
      end;
      'F': begin {complete a quest}
        clearscreen;
        crlf;
        crlf;
        {lets see if player has any quests involving monsters}
        d(5, 'Unfinished Quests');

        counter := 0;
        counter2 := 0;
        memsize := fs(fsquest);
        for i := 1 to fs(fsquest) do
        begin

          {load quest}
          load_quest(fload, quest, i);

          if (quest.deleted = False) and (quest.occupier = player.name2) then
          begin

            Inc(counter);
            Inc(counter2);

            {quest #}
            sd(15, commastr(counter) + '. ');

            {mission}
            s := Quest_Target(quest.questtarget);
            sd(12, 'Mission  : ' + ulcyan + s + config.textcol1);

            {difficulty}
            s := quest_diffstring(quest.difficulty, False);
            d(15, '  (' + s + ')');

          end;

          if (counter2 > 5) or (i = memsize) then
          begin

            if (counter = 0) and (i = memsize) then
            begin
              d(12, 'You have no unfinished Quests!');
              break;
            end;

            counter2 := 0;
            r := mini_menu;

            if r = 2 then
            begin
              {abort}
              break;
            end else
            if r = 1 then
            begin
              {pick quest to finish}
              crlf;
              sd(3, 'Pick #:');
              x := get_number(0, 65000);

              if (x > 0) and (player.RoyQuestsToday >= Config.MaxCompletedQuests) then
              begin
                crlf;
                d(12, 'You may only complete ' + uwhite + commastr(Config.MaxCompletedQuests) + ulred + ' quests per day.');
                pause;
              end else
              if x > 0 then
              begin

                counter2 := 0;
                for j := 1 to fs(fsquest) do
                begin

                  {load quest}
                  load_quest(fload, quest, j);

                  if (quest.deleted = False) and
                    (quest.occupier = player.name2) then
                  begin

                    Inc(counter2);

                    if counter2 = x then
                    begin
                      if quest.occupier = player.name2 then
                      begin

                        {kill monsters and get reward}
                        crlf;
                        if confirm('Travel and Slay the Beasts?', 'Y') = True then
                        begin

                          crlf;
                          sd(config.textcolor, 'You embark upon your journey...');

                          {Update player location}
                          onliner.location := onloc_QuestAttemp;
                          onliner.doing := location_desc(onliner.location);
                          add_onliner(OUpdateLocation, onliner);

                          {setup monsters}
                          Reset_Monsters;
                          Reset_Spells(pl1^, pl2^, pl3^, pl4^);

                          {reset teammates}
                          pl1^.name2 := '';
                          pl2^.name2 := '';
                          pl3^.name2 := '';
                          pl4^.name2 := '';

                          {load monsters}
                          x := 1;
                          for k := 1 to global_maxmon do
                          begin
                            if quest.monsters[k, 2] > 0 then
                            begin
                              for l := 1 to quest.monsters[k, 2] do
                              begin
                                load_monster(quest.monsters[k, 1], x);
                                Inc(x);
                              end; {for l:= .end.}
                            end;
                          end;     {for k:= .end.}

                          global_escape := False;
                          global_begged := False;
                          global_nobeg := True;

                          crlf;
                          crlf;
                          d(12, 'You have spotted the flock of evil creatures you have been');
                          d(12, 'assigned to kill!');
                          pause;

                          {fight}
                          player_vs_monsters(1, pl1^, pl2^, pl3^, pl4^);

                          {evaluate fight}
                          if global_killed then
                          begin

                            {PLAYER FAILED QUEST AND DIED!}

                            d(12, 'QUEST FAILED!');
                            d(5, mkstring(13, underscore));

                            {News-Paper}
                            Newsy(True,
                              'Failed Quest',
                              ' ' + uplc + player.name2 + config.textcol1 + ' died on a ' +
                              uquestc + 'Quest' + config.textcol1 + ' in the mountains.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                            {quest penalty}
                            crlf;
                            case quest.PenaltyType of
                              QNothing: begin
                                d(12, 'At least there was no Penalty for failing this Quest!');
                              end;
                              QExp: begin
                                x := 0;
                                case quest.penalty of
                                  1: x := player.level * 25;{low}
                                  2: x := player.level * 100;{medium}
                                  3: x := player.level * 300;{high}
                                end;

                                d(12, 'QUEST FAILED!');
                                d(5, mkstring(16, underscore));
                                d(config.textcolor, 'The ' + ulgray + 'PENALTY' + config.textcol1 +
                                  ' for failing the Quest is ' + uwhite + commastr(x) + config.textcol1 +
                                  ' experience points!');
                                DecPlayerExp(player, x);
                              end;
                              QMoney: begin
                                x := 0;
                                case quest.penalty of
                                  1: x := player.level * 3000;{low}
                                  2: x := player.level * 5000;{medium}
                                  3: x := player.level * 25000;{high}
                                end;

                                d(config.textcolor, 'The ' + ulgray + 'PENALTY' + config.textcol1 +
                                  ' for failing the Quest is ' + uyellow + commastr(x) + config.textcol1 + ' ' +
                                  many_money(x) + '!');
                                DecPlayerExp(player, x);
                              end;
                              QPotions: begin
                                x := 0;

                                case quest.penalty of
                                  1: x := 50;  {low}
                                  2: x := 100; {medium}
                                  3: x := 200; {high}
                                end;

                                d(config.textcolor, 'The ' + ulgray + 'PENALTY' + config.textcol1 +
                                  ' for failing the Quest is ' + uwhite + commastr(x) + config.textcol1 + ' healing potions!');
                                Dec(player.healing, x);
                                if player.healing < 0 then
                                  player.healing := 0;
                              end;
                              QDarkness: begin
                                x := 0;
                                case quest.penalty of
                                  1: x := 25;  {low}
                                  2: x := 75;  {medium}
                                  3: x := 110; {high}
                                end;
                                d(config.textcolor, 'The ' + ulgray + 'PENALTY' + config.textcol1 +
                                  ' for failing the Quest is ' + ulgray + commastr(x) + config.textcol1 + ' Darkness points!');
                                Give_Darkness(Player, x);
                              end;
                              QChivalry: begin
                                x := 0;
                                case quest.penalty of
                                  1: x := 25;  {low}
                                  2: x := 75;  {medium}
                                  3: x := 110; {high}
                                end;
                                d(config.textcolor, 'The ' + ulgray + 'PENALTY' + config.textcol1 +
                                  ' for failing the Quest is ' + uwhite + commastr(x) + config.textcol1 + ' Chivalry points!');
                                Give_Chivalry(Player, x);
                              end;
                            end; {case .end.}

                                 {set player flags}
                            if not Config.AllowFailQuestReturn then
                            begin
                              Reduce_Player_Resurrections(player, True);
                            end;

                            crlf;
                            d(config.textcolor, 'Miserable in soul and spirit you die...');
                            crlf;
                            pause;

                            {exit program}
                            normal_exit;

                          end else
                          begin
                            {PLAYER COMPLETED THE QUEST!}

                            {News-Paper}
                            Newsy(True,
                              'Successful Quest!',
                              ' ' + uplc + player.name2 + config.textcol1 + ' completed a ' +
                              uquestc + 'Quest' + config.textcol1 + ' in the mountains.',
                              ' ' + uplc + player.name2 + config.textcol1 + ' returned home and received a ' +
                              uwhite + 'reward' + config.textcol1 + '.',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '',
                              '');

                            {inc "player completed quests" counter}
                            Inc(player.royquests, 1);

                            {inc "player completed quests today" counter}
                            Inc(player.royqueststoday, 1);

                            {save user, he might want to look at the TOP QUEST MASTERS list}
                            user_save(player);

                            {quest reward}
                            info := emptystr; {info string that will be sent to king}
                            crlf;
                            crlf;

                            d(5, mkstring(16, underscore));
                            d(14, 'QUEST COMPLETED!');
                            d(5, mkstring(16, underscore));

                            case quest.RewardType of
                              QNothing: begin
                                d(12, 'There was no Reward for this Quest!');
                                d(config.textcolor, 'You feel extremely disappointed as you head home...');
                                info := ulred + '{nothing}' + config.textcol1;
                              end;
                              QExp: begin
                                x := 0;
                                case quest.reward of
                                  1: x := player.level * 100;{low}
                                  2: x := player.level * 500;{medium}
                                  3: x := player.level * 1000;{high}
                                end;
                                d(config.textcolor, 'The ' + ulgray + 'REWARD' + config.textcol1 +
                                  ' for this Quest is ' + uwhite + commastr(x) + config.textcol1 + ' experience points!');
                                d(config.textcolor, 'Congratulations! You have now completed ' +
                                  uwhite + commastr(player.royquests) + config.textcol1 + ' Quests in your career.');
                                Inc(player.exp, x);

                                info := uwhite + commastr(x) + config.textcol1 + ' experience points.';

                              end;
                              QMoney: begin

                                x := 0;
                                case quest.reward of
                                  1: x := player.level * 1100;{low}
                                  2: x := player.level * 5100;{medium}
                                  3: x := player.level * 11000;{high}
                                end;

                                d(config.textcolor, 'The ' + ulgray + 'REWARD' + config.textcol1 +
                                  ' for this Quest is ' + uyellow + commastr(x) + config.textcol1 + ' ' + many_money(x) + '!');
                                d(config.textcolor, 'Congratulations! You have now completed ' +
                                  uwhite + commastr(player.royquests) + config.textcol1 + ' Quests in your career.');
                                IncPlayerMoney(player, x);

                                info := uyellow + commastr(x) + config.textcol1 + ' ' + many_money(x) + '.';

                              end;
                              QPotions: begin
                                x := 0;

                                case quest.reward of
                                  1: x := 50;  {low}
                                  2: x := 100; {medium}
                                  3: x := 200; {high}
                                end;

                                d(config.textcolor, 'The ' + ulgray + 'REWARD' + config.textcol1 +
                                  ' for this Quest is ' + uwhite + commastr(x) + config.textcol1 + ' healing potions!');
                                d(config.textcolor, 'Congratulations! You have now completed ' +
                                  uwhite + commastr(player.royquests) + config.textcol1 + ' Quests in your career.');
                                Inc(Player.healing, x);

                                info := uwhite + commastr(x) + config.textcol1 + ' healing potions.';

                              end;
                              QDarkness: begin
                                x := 0;
                                case quest.reward of
                                  1: x := 25;  {low}
                                  2: x := 75;  {medium}
                                  3: x := 110; {high}
                                end;
                                d(config.textcolor, 'The ' + ulgray + 'REWARD' + config.textcol1 +
                                  ' for this Quest is ' + ulgray + commastr(x) + config.textcol1 + ' Darkness points!');
                                d(config.textcolor, 'Congratulations! You have now completed ' +
                                  uwhite + commastr(player.royquests) + config.textcol1 + ' Quests in your career.');
                                Inc(Player.dark, x);

                                info := uwhite + commastr(x) + config.textcol1 + ' darkness points.';

                              end;
                              QChivalry: begin
                                x := 0;
                                case quest.reward of
                                  1: x := 25;  {low}
                                  2: x := 75;  {medium}
                                  3: x := 110; {high}
                                end;
                                d(config.textcolor, 'The ' + ulgray + 'REWARD' + config.textcol1 +
                                  ' for this Quest is ' + uwhite + commastr(x) + config.textcol1 + ' Chivalry points!');
                                d(config.textcolor, 'Congratulations! You have now completed ' +
                                  uwhite + commastr(player.royquests) + config.textcol1 + ' Quests in your career.');
                                Inc(Player.chiv, x);

                                info := uwhite + commastr(x) + config.textcol1 + ' chivalry points.';

                              end;
                            end; {case .end.}

                                 {update quest-file}
                            quest.deleted := True;
                            load_quest(fsave, quest, j);

                            {tell other nodes}
                            online_send_to_all(uplc + player.name2 + config.textcol1 + ' completed a ' +
                              uquestc + 'QUEST' + config.textcol1 + '!'
                              , player.name2, '');

                            {mail the king, if he's online}
                            load_king(fload, king);

                            if (king.Name <> '') and (king.ai = 'H') then
                            begin
                              if is_online(king.Name, online_player) = False then
                              begin

                                {mail}
                                s := 'QUEST Completed';

                                post(MailSend,
                                  king.Name,
                                  king.ai,
                                  False,
                                  mailrequest_nothing,
                                  '',
                                  uquestc + 'QUEST' + umailheadc + ' Completed' + config.textcol1,
                                  mkstring(length(s), underscore),
                                  uplc + player.name2 + config.textcol1 + ' completed a ' +
                                  uquestc + 'QUEST' + config.textcol1 + ' in the Mountains!',
                                  uplc + player.name2 + config.textcol1 + ' received a Reward of ' + info,
                                  '', {this is info of reward and its size}
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
                            end;

                            pause;

                          end;

                        end;

                      end;

                    end;

                  end;
                end; {for j:= .end.}

              end;

            end; {if r=1 .end.}

          end;

        end; {for i:= .end.}

      end;
      'C': begin {list quests}

        if player.king then
        begin
          list_quests(True); {true=display claimed quests}
        end else
        begin
          list_quests(False); {false=don't display claimed quests}
        end;

      end;
    end; {case .end.}

  until leave_place = True;

  {dispose pointer variables}
  dispose(pl1);
  dispose(pl2);
  dispose(pl3);
  dispose(pl4);

  crlf;
  crlf;
  d(config.textcolor, 'You leave the ' + uplc + local_place + config.textcol1 + '..');
  crlf;

end; {Player_Quest *end*}

end. {Unit PlyQuest .end.}
