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



unit PlComp; {Usurper - Player vs Computer}

interface

uses
  Init;

var to_death: boolean;

function Player_Computer(var player1, player2: UserRec; fastgame: boolean; {display actions}
  battletype: byte): boolean;


                           {battletype=1  (team fight)
                                       2  (king challenge)
                                       3  (bank fight)
                                       4  (player caught stealing in the Dormitory or home)
                                       5  (player fighting Royal Guard at the Prison)
                                       6  (player fighting Team-Mate in the Dormitory, who is protecting friend)
                                        }

{funtion returns TRUE if player begged for mercy}

implementation

uses
  Cms, Jakob, Invent,
  Various2, Statusc, SwapEq,
  Cast, Mail, Various;

var

  expert_press: boolean;
  a: s70;

procedure Shared_Menu(player1: Userrec);
begin

  if (player.expert = False) or (expert_press = True) then
  begin
    crlf;
    menu2('(A)ttack  ');
    menu2('(H)eal  ');
    menu2('(Q)uick Heal ');
    menu2('(F)ight to Death');
    crlf;
    menu2('(S)tatus  ');
    menu2('(B)eg for Mercy  ');
    menu2('(U)se Item  ');

    if player1.classid in [Cleric, Magician, Sage] then
    begin
      menu2('(C)ast Spell  ');
    end;

    if player1.classid = Paladin then menu2('(1) Soul Strike  ');
    if player1.classid = Assassin then menu2('(1) Backstab  ');
    crlf;
    sd(config.textcolor, ':');
  end else
  begin
    expert_press := False;
    sd(config.textcolor, 'Fight (A,H,Q,F,S,B,U,*');
    if player1.classid in [Cleric, Magician, Sage] then
    begin
      sd(config.textcolor, ',C');
    end;
    if player1.classid in [Paladin, Assassin] then
    begin
      sd(config.textcolor, ',1');
    end;
    sd(config.textcolor, ',?) :');
  end;

end; {shared_menu *end*}

function Player_Computer(var player1, player2: UserRec; fastgame: boolean; {display actions}
  battletype: byte): boolean;
const soulstrike: longint = 0;
var
  stab1, stab2: longint;
  cho:      char;
  zz, x:    longint;
  s:        s70;
  backstab: boolean;
  playerbegged: boolean;
  dummy:    byte;

begin

  {init important vars}
  playerbegged := False;

  {to handle "carrier-dropping" cheaters}
  global_PlayerInFight := True;

  {* Human versus Player2 *}
  case random(4) of
    0: begin
      sd(config.textcolor, 'You confront ');
      sd(global_plycol, player2.name2);
      d(config.textcolor, '!');
    end;
    1: begin
      sd(config.textcolor, 'You engage ');
      sd(global_plycol, player2.name2);
      d(config.textcolor, '!');
    end;
    2: begin
      sd(config.textcolor, 'You prepare to battle ');
      sd(global_plycol, player2.name2);
      d(config.textcolor, '!');
    end;
    3: begin
      sd(config.textcolor, 'You meet ');
      sd(global_plycol, player2.name2);
      d(config.textcolor, '!');
    end;
  end; {case .end.}

  crlf;
  {player hps}
  sd(config.textcolor, 'Your hps : ');
  sd(10, commastr(player1.hps));
  sd(config.textcolor, '/');
  d(10, commastr(player1.maxhps));

  {opponents hps}
  sd(global_plycol, player2.name2 + 's');
  sd(config.textcolor, ' hps : ');
  sd(10, commastr(player2.hps));
  sd(config.textcolor, '/');
  d(10, commastr(player2.maxhps));

  expert_press := False;

  cho := ' ';
  repeat
    shared_menu(player1);

    player1.used_item := False;
    player2.used_item := False;

    soulstrike := 0;

    {get user input}
    if not to_death then
    begin
      cho := upcase(getchar);
      if cho = '?' then
      begin
        expert_press := True;
        shared_menu(player1);
      end;
    end else
    begin
      if player1.hps + 3 < player1.maxhps then
      begin
        quick_healing(player);
      end;
      cho := 'A';
    end;

    {use item}
    if cho = 'U' then
    begin
      inventory_display(player1);
      use_item(0);
      cho := 'A';
    end;

    {fight to death}
    if cho = 'F' then
    begin
      if confirm('Fight to Death', 'n') = True then
      begin
        to_death := True;
        cho := 'A';
      end else
      begin
        shared_menu(player1);
      end;

    end;

    {beg for mercy}
    if cho = 'B' then
    begin
      case battletype of
        1: begin
          d(config.textcolor, 'No surrender in team fights!');
          cho := '?';
        end;
        2: begin
          d(14, 'Surrender to the CROWN');
          playerbegged := True;
        end;
        3: begin {bank fight}
          d(12, 'No mercy is given from the guards!');
          cho := '?';
        end;
        4: begin {fighting theives from the dormitory}
          crlf;
          crlf;
          sd(12, 'I don''t think so! ');
          sd(global_plycol, player2.name2);
          d(12, ' is not in a forgiving mood!');
          pause;
        end;
        5: begin {fighting Royal Guard at the Prison, player is attempting to free another player}
          crlf;
          crlf;
          sd(15, 'You surrender to ' + uplc + player2.name2 + config.textcol1 + '!');
          playerbegged := True;
        end;
        6: begin {fighting Team-Mate in the Dorm, after attacking another player there}
          crlf;
          crlf;
          sd(12, 'I don''t think so! ');
          sd(global_plycol, player2.name2);
          d(12, ' is not going to forgive your evil deed!');
          pause;
        end;

      end;
    end;


    if cho = 'Q' then
    begin
      quick_healing(player);
      cho := '?';
    end;

    if cho = 'H' then healing(player);

    if cho = 'S' then
    begin
      crlf;
      status(player);
      cho := 'S';
    end;

    if cho in ['Q', 'H', 'S'] then
    begin
      if random(5) = 1 then
      begin
        crlf;
        sd(global_talkcol, 'Come on you little punk! ');
        sd(global_plycol, player2.name2);
        d(config.textcolor, ' screams.');
      end;
      crlf;

      sd(global_plycol, 'Your');
      sd(config.textcolor, ' hitpoints : ');
      d(global_hpcol, commastr(player1.hps));

      sd(global_plycol, player2.name2 + 's');
      sd(config.textcolor, ' hitpoints : ');
      d(global_hpcol, commastr(player2.hps));

      shared_menu(player1);

    end;

    player1.casted := False;
    player2.casted := False;

    if cho = 'C' then
    begin
      cho := ' ';
      if player1.classid in [Cleric, Magician, Sage] then
      begin
        cast_spell(fastgame, 1, 2, player1, player2, False, dummy);

        if player1.casted = True then
        begin
          cho := 'A';
        end else
        begin
          cho := ' ';
        end;
      end;
    end;

    if cho = '1' then
    begin
      cho := ' ';
      if (player1.classid = Paladin) or (player1.classid = Assassin) then
      begin
        cho := '1';
      end;
    end;

    if (cho = '1') and (player1.classid = Paladin) and (player1.hps < 2) then
    begin
      crlf;
      d(12, 'Too few hitpoints left!');
      cho := ' ';
    end;

  until cho in ['A', '1', 'B'];

  stab1 := 0;
  stab2 := 0;
  {*Attacking player uses Backstab*}
  if (cho = '1') and (player1.classid = Assassin) then
  begin
    backstab := False;
    if config.classic then
    begin
      if player1.weapon = 0 then
      begin
        crlf;
        d(12, 'You don''t have a weapon!');
        pause;
        cho := ' ';
      end else
      begin
        backstab := True;
      end;
    end else
    begin
      if player1.rhand + player1.lhand = 0 then
      begin
        crlf;
        d(12, 'You don''t have a weapon!');
        pause;
        cho := ' ';
      end else
      begin
        backstab := True;
      end;
    end;

    if backstab = True then
    begin
      d(config.textcolor, 'You try to Backstab ' + player2.name2 + '!');
      if random(3) = 0 then
      begin
        d(config.textcolor, 'You manage to cut ' + player2.name2 + '!');
        d(global_plycol, player2.name2 + config.textcol1 + ' screams in pain!');
        stab1 := player1.maxhps div 2;
      end else
      begin
        stab1 := -1;
        d(config.textcolor, 'But you miss!');
        d(global_plycol, player2.name2 + config.textcol1 + ' laughs at your pathetic attempt.');
      end;
      cho := 'A';
    end;

  end;

  if cho = '1' then
  begin
    crlf;
    d(config.textcolor, 'How many hitpoints to use (max ' + commastr(player1.hps - 1) + ')');
    sd(config.textcolor, ':');

    zz := get_number(0, player1.hps - 1);

    if (zz > 0) and (zz <= player1.hps) then
    begin
      soulstrike := soul_effect(player, zz);
      Dec(player1.hps, zz);
      cho := 'A';
    end else
    begin
      d(config.textcolor, 'Aborted.');
      soulstrike := 0;
      cho := 'A';
    end;
  end;

  if cho = 'A' then
  begin
    crlf;

    {restoring overmaxed hps}
    if player2.hps > player2.maxhps then player2.hps := player2.maxhps;
    if player1.hps > player1.maxhps then player1.hps := player1.maxhps;

    {*should opponent quaff healing potions?*}
    computer_healing(True, player2);

    {*should npc use spells?*}
    if (player2.used_item = False) and (player2.casted = False) then
    begin
      if player2.classid in [Cleric, Magician, Sage] then
      begin
        cast_spell(fastgame, 1, 2, player2, player1, False, dummy);
      end;
    end;

    if (player1.race = Gnoll) and (player2.gnollp = 0) and (player1.used_item = False) and (player1.casted = False) then
    begin
      {x:=random(player2.level+5);}
      x := random(4) + 1;
      if x = 3 then
      begin
        crlf;
        d(config.textcolor, '**Poisonous Gnollbite!**');
        d(config.textcolor, 'You managed to poison ' + sex[player2.sex] + '!');
        player2.gnollp := 1;
      end;
    end;

    if (player2.race = Gnoll) and (player1.gnollp = 0) and (player2.used_item = False) and (player2.casted = False) then
    begin
      {x:=random(player1.level+5);}
      x := random(4) + 1;
      if x = 3 then
      begin
        crlf;
        d(config.textcolor, '**Poisonous Gnollbite!**');
        d(config.textcolor, 'The creep managed to poison you!');
        player1.gnollp := 1;
      end;
    end;
    if player1.gnollp > 0 then
    begin
      player2.punch := random(player2.level) + 1;
      d(config.textcolor, 'You suffered ' + uwhite + commastr(player2.punch) + config.textcol1 + ' points from poison!');
      Dec(player1.hps, player2.punch);
    end;
    if player2.gnollp > 0 then
    begin
      player1.punch := random(player1.level) + 1;
      d(global_plycol, player2.name2 + config.textcol1 + ' suffers ' + uwhite + commastr(player1.punch) + config.textcol1 + ' points from poison!');
      Dec(player2.hps, player1.punch);
    end;

    player1.punch := 0;
    player1.absorb := 0;
    player2.punch := 0;
    player2.absorb := 0;

    {strength in player attacks}
    if (player1.used_item = False) and (player1.casted = False) then
    begin
      player1.punch := normal_attack(False, player1);
    end;

    if (player2.used_item = False) and (player2.casted = False) then
    begin
      player2.punch := normal_attack(False, player2);
    end;
    cast_spell(fastgame, 2, 2, player2, player1, False, dummy);
    cast_spell(fastgame, 2, 2, player1, player2, False, dummy);


    {has player chosen a soulstrike?}
    if soulstrike > 0 then
    begin
      zz := soulstrike;
      player1.punch := soul_effect(player1, zz);
      soulstrike := 0;
      d(config.textcolor, 'Soulstrike hits ' + uplc + player2.name2 + config.textcol1 + ' for ' + uwhite + commastr(player1.punch) + config.textcol1 + ' points!');
    end;
    {*should computer controlled player ues Backstab?*}
    if config.classic then
    begin
      if (player2.classid = Assassin) and (random(3) = 0) and (player2.used_item = False) and
        (player2.casted = False) and (player2.weapon > 0) then
      begin

        sd(global_plycol, player2.name2);
        d(config.textcolor, ' tries to Backstab you!');
        if random(3) = 0 then
        begin
          sd(config.textcolor, 'You scream out in pain as ');
          sd(global_plycol, player2.name2);
          d(config.textcolor, ' cuts you !');
          stab2 := player2.maxhps div 2;
        end else
        begin
          stab2 := -1;
          d(config.textcolor, 'But misses!');
        end;
      end;
    end else
    begin
      if (player2.classid = Assassin) and (random(3) = 0) and (player2.used_item = False) and
        (player2.casted = False) and (player2.rhand + player2.lhand > 0) then
      begin

        sd(global_plycol, player2.name2);
        d(config.textcolor, ' tries to Backstab you!');
        if random(3) = 0 then
        begin
          sd(config.textcolor, 'You scream out in pain as ');
          sd(global_plycol, player2.name2);
          d(config.textcolor, ' cuts you !');
          stab2 := player2.maxhps div 2;
        end else
        begin
          stab2 := -1;
          d(config.textcolor, 'But misses!');
        end;
      end;

    end;


    {*should NPC use soul strike?*}
    if (player2.classid = Paladin) and (player2.hps > 100) and (random(3) = 0) and
      (player2.used_item = False) and (player2.casted = False) then
    begin
      zz := player2.hps div 3;
      soulstrike := zz;
      Dec(player2.hps, zz);
      player2.punch := soul_effect(player2, zz);
      soulstrike := 0;
      d(config.textcolor, 'Soulstrike from ' + uplc + player2.name2 + config.textcol1 + ' hits you for ' + uwhite + commastr(player2.punch) + config.textcol1 + ' points!');
    end;

    {* random messages *}
    if random(4) = 0 then
    begin
      battle_comment(1, player2.name2);
    end;

    if (player1.punch + player1.poison = 0) and (player1.used_item = False) and (player1.casted = False) and (stab1 <> -1) then
    begin
      d(config.textcolor, 'You miss your blow against ' + player2.name2 + '!');
    end;
    if (player1.punch + player1.poison > 0) and (player1.used_item = False) and (player1.casted = False) and (stab1 <> -1) then
    begin
      sd(config.textcolor, 'You hit ');
      sd(global_plycol, player2.name2);
      sd(config.textcolor, ' for ');
      sd(12, commastr(player1.punch + player1.poison));
      d(config.textcolor, ' points!');

      if random(4) = 0 then
      begin
        battle_comment(2, player2.name2);
      end;

      normal_defence(player2);

      if player2.absorb > player1.punch then player2.absorb := player1.punch;
      if player2.absorb > 0 then
      begin
        sd(global_plycol, player2.name2 + 's');
        sd(config.textcolor, ' armor absorbed ');
        sd(15, commastr(player2.absorb));
        d(config.textcolor, ' points!');
        player1.punch := player1.punch - player2.absorb;
        if player1.punch < 0 then player1.punch := 0;
      end;
    end;

    if (player2.punch + player2.poison = 0) and (player2.used_item = False) and (player2.casted = False) and (stab2 <> -1) then
    begin
      d(config.textcolor, player2.name2 + ' missed you completely!');
    end;

    if (player2.punch + player2.poison > 0) and (player2.used_item = False) and (player2.casted = False) and (stab2 <> -1) then
    begin
      sd(global_plycol, player2.name2);
      sd(config.textcolor, ' hits you for ');
      sd(12, commastr(player2.punch + player2.poison));
      d(config.textcolor, ' points!');

      if random(3) = 0 then
      begin
        battle_comment(3, player2.name2);
      end;

      normal_defence(player1);
      if player1.absorb > player2.punch then player1.absorb := player2.punch;
      if player1.absorb > 0 then
      begin
        d(config.textcolor, 'Your armor absorbed ' + commastr(player1.absorb) + ' points!');
        player2.punch := player2.punch - player1.absorb;
        if player2.punch < 0 then player2.punch := 0;
      end;
    end;

    {infections}
    infections;
    infections2(fastgame, player2);

    {backstab effect}
    if stab1 > 0 then player1.punch := player1.punch + stab1;
    if stab2 > 0 then player2.punch := player2.punch + stab2;

    if stab1 = -1 then
    begin
      player1.punch := 0;
      player2.punch := player2.punch + player1.level;
    end;

    if stab2 = -1 then
    begin
      player2.punch := 0;
      player1.punch := player1.punch + player2.level;
    end;

    {poison effect}
    if player1.poison > 0 then player1.punch := player1.punch + player1.poison;
    if player2.poison > 0 then player2.punch := player2.punch + player2.poison;

    if player1.punch < 0 then player1.punch := 0;
    if player2.punch < 0 then player2.punch := 0;

    {eternal battle?}
    if (player1.punch < 2) and (player2.punch < 2) then
    begin
      player1.punch := player1.punch + random(5) + 2;
      player2.punch := player2.punch + random(5) + 2;
    end;

    {at last the actual blows take effect}

    Dec(player1.hps, player2.punch);
    Dec(player2.hps, player1.punch);

    if player1.hps < 0 then player1.hps := 0;
    if player2.hps < 0 then player2.hps := 0;

    if player1.hps < 1 then
    begin
      show_usurper_data(picture_DEATH_HEAD, False);
      d(12, 'Defeat! You are dead!');
      crlf;

      reward_check(False, player2, player1);

      xplose(player);

      Inc(player.p_defeats);
      Inc(player2.p_kills);

      if player2.hps > 0 then
      begin
        swap_objects(player2, player1, True);
      end;

      pause;

    end;

    if player2.hps < 1 then
    begin
      crlf;
      d(14, 'Victory! You have killed ' + uplc + player2.name2 + uyellow + '!');
      Inc(player2.p_defeats);
      Inc(player.p_kills);
      xplose(player2);

      crlf;
      reward_check(True, player1, player2);
      pause;

      if player.hps > 0 then
      begin
        swap_objects(player1, player2, True);
      end;

      crlf;
      sd(config.textcolor, 'Leave a note to ' + uplc + player2.name2 + config.textcol1);
      if confirm(' ', 'n') = True then
      begin
        a := '';
        d(config.textcolor, 'Enter Message [1 line]');
        sd(config.textcolor, ':');
        a := get_string(70);
        if a <> '' then
        begin
          if player2.ai = 'H' then
          begin

            s := 'After-Fight Message';

            post(MailSend,
              player2.name2,
              player2.ai,
              False,
              mailrequest_nothing,
              '',
              umailheadc + s + config.textcol1,
              mkstring(length(s), underscore),
              'Just before you died, ' + uplc + player.name2 + config.textcol1 + ' said:',
              utalkc + a + config.textcol1,
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
        end;
      end;
    end;
  end;

  if (player1.hps <= 0) and (player2.autoheal = True) then
  begin
    auto_healing(player2);
  end;

  {return result}
  player_computer := playerbegged;

  {to handle "carrier-dropping" cheaters}
  global_PlayerInFight := False;

end; {Player_Computer *end*}

end. {Unit PlComp .end.}
