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



unit KMaint; {Usurper - NPC King Maintenance}

interface

uses
  Init;

procedure King_Maintenance(var ply: userrec; var king: kingrec);

implementation

uses
  Cms, Jakob, Mail,
  News, Various, Various2,
  Various3, File_Io;

var
  not_used: boolean;


procedure King_Maintenance;
var
  x, old_tax: integer;
  s:          s90;

  i, j, k:    word;

  quest:      questrec;

  done, found, no_more: boolean;

  counter, monsters, minrange, maxrange: word;

begin

  {init pointer variables}

  {jakob..what the NPC King or Queen should do}

  {economy first. let us check the taxes}
  {0 - 5 % is the limit, see => castle.pas}

  {rule 1. we never let the tax be 0% }
  old_tax := king.tax;
  if king.tax = 0 then
  begin
    x := random(6) + 1;
  end else
  begin
    {change the tax..mabye}
    if random(3) = 0 then
    begin
      x := random(6) + 1;
    end;
  end;

  {did we decide to change the tax?}
  if x <> old_tax then
  begin

    {set new tax}
    king.tax := x;

    {announce the new tax}

    s := KingString(ply.sex);

    if king.tax > old_tax then
    begin

      {news-paper}
      newsy(True, 'Royal Tax',
        ' ' + s + ukingc + ' ' + ply.name2 + ugreen + ulred + ' raised' + ugreen + ' the ' + ulgreen + 'Royal Tax' + ugreen +
        ' to ' + commastr(king.tax) + '% !',
        ' The people despair.',
        '',
        '',
        '',
        '',
        '',
        '',
        '');
    end else
    begin

      {news-paper}
      newsy(True, 'Royal Tax',
        ' ' + s + ukingc + ' ' + ply.name2 + uwhite + ' lowered' + ugreen + ' the ' + ulgreen +
        'Royal Tax to ' + ugreen + commastr(king.tax) + '% !',
        ' People praise the wisdom of their beloved ' + KingString(ply.sex) + '!',
        '',
        '',
        '',
        '',
        '',
        '',
        '');
    end;

  end;

  {check if tax alignment is correctly set}
  {we make it easy for ourselves and let everybody pay}
  king.taxalignment := 0;

 {After the Tax decisions we turn our attention to the
  Royal Orphanage}


  {quests, NOTE that some code/thinking is duplicatd in Rquests.pas}
  no_more := False;
  if king.questsleft > 0 then
  begin

    for i := 1 to king.questsleft do
    begin

      {chance of adding a quest}
      if random(2) = 0 then
      begin

        if (fs(fsquest) >= 65000) or
          (fs(fsquest) >= Config.MaxQuestsAllowed) then
        begin

          {oopps...no more quests allowed}

          no_more := True;
          {check for deleted/completed quests in the database}
          for j := 1 to fs(fsquest) do
          begin
            {load quest}
            load_quest(fload, quest, j);

            if quest.deleted then
            begin
              no_more := False;
              break;
            end;

          end; {for j:= .end.}

        end;

        if no_more = False then
        begin

          {id # number}
          new_quest(quest);
          quest.id := crypt(20); {unique identification # number}

          {initiator}
          quest.initiator := ply.name2;

          {date}
          quest.date := todays_date;

          {quest-type}
          quest.questtype := SingleQuest;

          {quest-target}
          quest.questtarget := qMonster;

          {quest-difficulty}
          quest.difficulty := random(10) + 1;

     {set how many monsters player will encounter, depending on
      difficulty.
      also set file ranges, where to get monsters from; the higher
      the more dangerous}

          case quest.difficulty of
            1: begin

              {# of monsters}
              monsters := 1;

              {min and maxrange, where in monster file to fetch monsters}
              minrange := 1;
              maxrange := 100;

            end;
            2: begin
              monsters := 3;
              minrange := 101;
              maxrange := 200;

            end;
            3: begin
              monsters := 4;
              minrange := 201;
              maxrange := 300;

            end;
            4: begin
              monsters := 6;
              minrange := 301;
              maxrange := 400;

            end;
            5: begin
              monsters := 7;
              minrange := 401;
              maxrange := 500;

            end;
            6: begin
              monsters := 9;
              minrange := 501;
              maxrange := 600;

            end;
            7: begin
              monsters := 10;
              minrange := 601;
              maxrange := 700;

            end;
            8: begin
              monsters := 12;
              minrange := 701;
              maxrange := 800;

            end;
            9: begin
              monsters := 14;
              minrange := 801;
              maxrange := 900;

            end;
            10: begin
              monsters := 17;
              minrange := 901;
              maxrange := 999;
            end;
          end; {case .end.}

               {safety catch}
          if monsters > global_maxmon then
            monsters := global_maxmon;

          {collect some monsters}
          done := False;
          counter := 0;
          repeat

            {pick random monster}
            x := random(maxrange - minrange + 1) + minrange;

            {lets see if we already have this type of monster}
            found := False;
            for k := 1 to global_maxmon do
            begin
              if quest.monsters[k, 1] = x then
              begin
                Inc(quest.monsters[k, 2]);
                Inc(counter);
                found := True;
                break;
              end;
            end; {for k:= .end.}

            if found = False then
            begin
              {find an empty slot to put new monster in}
              for k := 1 to global_maxmon do
              begin
                if quest.monsters[k, 1] = 0 then
                begin
                  quest.monsters[k, 1] := x;
                  Inc(quest.monsters[k, 2]);
                  Inc(counter);
                  found := True;
                  break;
                end;
              end; {for k:= .end.}
            end;

            if found = False then
            begin
              {no empty slot found! we just increase the number of monsters}
              Inc(quest.monsters[1, 2]);
              Inc(counter);
            end;

            {are we done?}
            if counter = monsters then
            begin
              done := True;
            end;

          until done;

          {deleted}
          quest.deleted := False;


          {comment}
          s := emptystr;
          case random(6) of
            0: s := 'Do not fail me!';
            1: s := 'Complete this quest and be rewarded!';
            2: s := 'Help the Royal Family and complete this Quest';
            3: s := 'Go for it!';
            4: s := 'Don''t be afraid. Claim me!';
            5: s := 'You will be rewarded!';
          end; {.end. case}
          quest.comment := s;

          {name of player occupying quest}
          quest.occupier := emptystr;

          {# of days player has occupied quest}
          quest.occdays := 0;

          {# of days player has to complete the quest, 1-15}
          x := random(16) + 1;

          quest.daystocomple := x;

          {has offer been refused 1=delete,2=add to list}
          quest.offerrefused := 0;


          {min level required to take quest}
          quest.minlevel := 1;

          {max level required to take quest}
          quest.maxlevel := 100;

          {reward size, 1-3}

          x := random(3) + 1;
          quest.reward := x; {low,medium,high}


          {reward type}
          case random(5) of
            0: quest.rewardtype := qExp;
            1: quest.rewardtype := qMoney;
            2: quest.rewardtype := qPotions;
            3: quest.rewardtype := qDarkness;
            4: quest.rewardtype := qChivalry;
          end;


          {penalty}
          case random(4) of
            0: quest.penalty := 0; {nothing,low,medium,high}
            1: quest.penalty := 1;
            2: quest.penalty := 2;
            3: quest.penalty := 3;
          end;

          {penalty type}
          case random(6) of
            0: quest.penaltyType := qExp;
            1: quest.penaltytype := qMoney;
            2: quest.penaltytype := qPotions;
            3: quest.penaltytype := qDarkness;
            4: quest.penaltytype := qChivalry;
            5: quest.penaltytype := qNothing;
          end;

          {is this quest forced upon occupier}
          quest.forced := False;

          {offer this quest to a certain player}
          quest.offerto := emptystr;


          {save quest}
          add_quest(quest);

          {update king record}
          load_king(fload, king);
          Dec(king.QuestsLeft);
          load_king(fsave, king);

          {news-paper}
          newsy(True, 'A Quest has been Issued',
            ' Quest-Master ' + uplc + config.QuestMaster + config.textcol1 + ' has issued a ' +
            uquestc + 'Quest' + config.textcol1 + '!',
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
    end; {for i .end.}

  end;   {Quests .end.}

         {abdicate?}

         {save king}
  load_king(fsave, king);

end; {King_Maintenance *end*}

end. {Unit KMaint .end.}
