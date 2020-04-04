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



unit PlvsMon; {Usurper - Generic Player versus Monsters routine}

interface

uses
  Init;

var killed_by: array[1..5] of string[30];

 {the monster who took the players and teammates lives killed_by[1] is
  player}

procedure Player_vs_Monsters(monster_mode: byte; var pl1, pl2, pl3, pl4: Userrec);
                            {see cms.pas for constants
                             1 = pl vs dungeon monsters
                             2 = pl vs door guards
                             3 = pl vs supreme being
                             4 = pl vs demon
                             5 = pl vs alchemist opponent
                             6 = pl vs prison guards (attempting to free a friend}

implementation

uses
  Jakob, Statusc, Invent,
  Cms, Cast, Npc_Chec, News,
  Spellsu, Various, Various2,
  Various3, Online, File_Io;

var
  dispat, norm_att, found, done, First: boolean;

  tempman: userrec;

  healed:  boolean;

  {start, spell related variables, start}
  monster_magic: boolean;
  monster_spell: byte;
  damage:  longint;
  ms, ms2: byte;

{start, spell related variables, end}

function Retreat: boolean;
var s: s100;
  xx:  longint;
begin

  case random(2) of
    0: begin
      crlf;
      d(config.textcolor, 'You have escaped battle!');
      retreat := True;
    end;
    1: begin
      crlf;
      d(config.textcolor, 'The monster won''t let you escape!');
      xx := random(global_dungeonlevel * 10) + 3;

      d(config.textcolor, 'As you cowardly turn and run, you feel pain when something');
      d(config.textcolor, 'hits you in the back for ' + commastr(xx) + ' points');
      crlf;

      Dec(player.hps, xx);
      if player.hps <= 0 then
      begin
        crlf;
        d(12, 'You have been slain!');
        crlf;
        player.hps := 0;
        {player.allowed:=false;}

        s := uplc + player.name2 + config.textcol1;

        case random(3) of
          0: s := s + ' was killed by a ';
          1: s := s + ' was slain by a ';
          2: s := s + ' was slaughtered by a ';
          3: s := s + ' was defeated by a ';
        end;

        s := s + 'monster, when trying to escape battle!';


        {news-paper}
        newsy(True,
          'Coward!',
          ' ' + s,
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

        Reduce_Player_Resurrections(player, True);

        d(config.textcolor, 'Darkness...');
        crlf;

        {set killed flags}
        global_killed := True;
        retreat := False;
        global_PlayerInFight := False;

        {exit program}
        normal_exit;

      end;
    end;
  end; {case .end.}

end;   {retreat **end**}

procedure Monster_Charge(mode: integer);
var i: longint;
  xx:  longint;
begin

  case mode of
    1: begin
      for i := 1 to global_maxmon do
      begin
        xx := 3;
        if monster[i]^.strength < 10 then
          monster[i]^.strength := 10;
        monster[i]^.punch := 0;
        if monster[i]^.weappow > 32000 then
          monster[i]^.weappow := 32000;
        monster[i]^.punch := monster[i]^.weappow + (random(monster[i]^.weappow));
        monster[i]^.punch := monster[i]^.punch + (monster[i]^.strength div xx);

        {lucky freak attack}
        if random(3) = 0 then
        begin
          monster[i]^.punch := monster[i]^.punch + random(5) + 1;
        end;

      end;   {for i:= .end.}
    end;
    2: begin {player versus doorguard(s)}
      for i := 1 to global_maxmon do
      begin
        xx := monster[i]^.strength * 2;
        monster[i]^.punch := random(xx);
      end; {for i:= .end.}
    end;
    3: begin
      dispat := False;
      for i := 1 to global_maxmon do
      begin
        monster[i]^.punch := random(player.maxhps) + 3;

        if (global_s_sword = True) and (dispat = False) then
        begin
          d(15, 'The Black Sword attacks the Supreme Being!');
          Dec(monster[i]^.hps, 75);
          dispat := True;
        end;
        if (global_s_lantern = True) and (dispat = False) then
        begin
          d(15, 'The Lantern starts to glow before you!');
          monster[i]^.punch := monster[i]^.punch div 2;
          dispat := True;
        end;
        if (global_s_wstaff = True) and (dispat = False) then
        begin
          d(15, 'The White Staff starts to glow before you!');
          Dec(monster[i]^.punch, 50);
          if monster[i]^.punch < 0 then
            monster[i]^.punch := 0;
          dispat := True;
        end;
        if (global_s_bstaff = True) and (dispat = False) then
        begin
          d(15, 'The Black Staff increases your strength!');
          dispat := True;
        end;

        monster[i]^.magicres := 100;
      end; {for i:= .end.}
    end;
    4: begin

      {demon}
      monster[1]^.punch := 100 + (random(player.maxhps));
      monster[1]^.armpow := 100;
      monster[1]^.magicres := 100;

    end;
    5..6: begin
      for i := 1 to global_maxmon do
      begin
        xx := 3;
        if monster[i]^.strength < 10 then
          monster[i]^.strength := 10;
        monster[i]^.punch := 0;

        if monster[i]^.weappow > 32000 then
          monster[i]^.weappow := 32000;

        monster[i]^.punch := monster[i]^.weappow + (random(monster[i]^.weappow));
        monster[i]^.punch := monster[i]^.punch + (monster[i]^.strength div xx);
      end; {for i:= .end.}
    end;
  end;     {case .end.}

end; {monster_charge **end**}


function Hit_Output(const inval: longint): s70;
var
  s: string[8];

begin

  s := 'MAX';
  case inval of
    1..5: s := 'Light';
    6..20: s := 'Medium';
    21..100: s := 'Hard';
    101..200: s := 'Heavy';
    201..2000: s := 'Extreme';
    2001..9999: s := 'ULTRA';
  end;

  {return result}
  hit_output := s;

end;

procedure Monster_Magic_Attack(const i: integer);
var s, s2: s70;
  j:       byte;
begin         {monster #i casts monster_spell against tempman}

  sd(global_moncol, monster[i]^.Name);

  if spell_multi_monster(monster_spell) then
  begin
    sd(15, ' casts a SPELL!');
  end else
  begin
    sd(15, ' casts a SPELL on ');
    if tempman.name2 = player.name2 then
      sd(15, 'You!')
    else sd(global_plycol, tempman.name2);
  end;

  d(config.textcolor, ' (' + spell_name_monster(monster_spell) + ')');

  {should the spell fail?}
  if random(2) = 0 then
  begin
    d(5, 'But it failed.');
  end else
  begin

    {spell affects target(s)}
    case monster_spell of
      1: begin {Spell : CAUSE DAMAGE}
        damage := monster[i]^.magiclevel * 3; {damage}
        if tempman.name2 = player.name2 then
          s := 'You are'
        else s := tempman.name2 + ' is';

        d(11, s + ' hurt for ' + commastr(damage) + ' damage!');
        Dec(tempman.hps, damage);
      end;
      2: begin {Spell : Snakes}
        d(12, 'Silver Snakes appear in a puff of smoke!');
        damage := monster[i]^.magiclevel * 2; {damage}
        if tempman.name2 = player.name2 then
          s := 'You are'
        else s := tempman.name2 + ' is';

        d(11, s + ' bitten for ' + commastr(damage) + ' damage!');

        Dec(tempman.hps, damage);
      end;
      3: begin  {Spell : Cyclone}
        d(12, 'They have summoned a CYCLONE!');
        damage := monster[i]^.magiclevel * 2; {damage}
        if tempman.name2 = player.name2 then
          s := 'You are'
        else s := tempman.name2 + ' is';

        d(11, s + ' swept away and hurt for ' + commastr(damage) + ' damage!');

        Dec(tempman.hps, damage);
      end;
      4: begin {Spell : Summon Undead}

               {decide undead type}
        case random(2) of
          0: begin
            s := 'Zombie';
            s2 := 'Sabre';
          end;
          1: begin
            s := 'Corpse';
            s2 := 'Rotten arms';
          end;
        end; {case .end.}

        d(12, 'From the ground, a ' + s + ' suddenly rises!');

        {check in any empty monster spots are available}
        for j := 1 to global_maxmon do
        begin
          if monster_active(j) = False then
          begin
            create_monster(j,             {#}
              s,             {name}
              50,            {hps}
              15,            {strength}
              15,            {defence}
              'Kill.Kill.',  {phrase}
              False,         {grabweap}
              False,         {grabarm}
              s2,            {weapon-string}
              '',            {armor-string}
              False,         {poisoned-should be false}
              False,         {disease -should be false}
              25,            {punch}
              7,             {armpow}
              7);            {weappow}
            monster[j]^.target := 1;
            break;
          end;
        end;

      end;

      5: begin {Spell : Vice of Death}
        d(12, tempman.name2 + ' has been seized by cramps!');
        d(12, tempman.name2 + ' is incapacitated!');

        damage := monster[i]^.magiclevel * 2; {damage}
        if tempman.name2 = player.name2 then
          s := 'You are'
        else s := tempman.name2 + ' is';

        d(11, s + ' hurt for ' + commastr(damage) + ' damage!');
        Dec(tempman.hps, damage);

      end;
      6: begin {Spell : Drain Life}
        d(12, 'A bright spark of red energy hits ' + tempman.name2 + '!');

        damage := monster[i]^.magiclevel * 1; {damage}
        if tempman.name2 = player.name2 then
          s := 'You are'
        else s := tempman.name2 + ' is';

        d(11, s + ' zapped for ' + commastr(damage) + ' damage!');
        Dec(tempman.hps, damage);
      end;
    end; {case .end.}

  end;

 { USED WHEN TESTING Monster spell functions
 d(config.textcolor,'Monster knows the following spells :');
 for j:=1 to maxmspells do begin
  if monster[i]^.spell[j] then begin
   d(4,spell_name_monster(j));
  end;
 end;
 }

  {monsters mana is reduced}
  Dec(monster[i]^.mana, spell_cost_monster(monster_spell));

end; {monster_magic_attack **end**}

procedure Player_vs_Monsters; {Main START}
const soulstrike: longint = 0;

var

  cho:        char;

  to_death, expert_press: boolean;

  s: s70;

  i, j, x, zz, yy, xx: longint;

  y, stab1: integer;

  k, mon, attack_order, dummy: byte;

  mtemp1:     array [1..global_maxmon] of s70;
  mtemp2:     array [1..global_maxmon] of integer;

  procedure Has_Monster_Died;
  var Result, plynr: byte;
  begin

    {has monster died?}
    if (monster[mon]^.Name <> '') and (monster[mon]^.hps < 1) then
    begin
      if random(5) = 0 then
      begin
        d(config.textcolor, 'The ' + monster[mon]^.Name + ' looks surprised when your final blow');
        d(config.textcolor, 'causes its instant death!');
      end;
      d(14, 'You have killed the ' + monster[mon]^.Name + '!');
      pause;
      Inc(player.m_kills);
      monster[mon]^.Name := '';
      xx := dungeon_reward(global_dungeonlevel);

      {does XP haves to be split with teammates?}
      yy := 1;
      if player_active(pl1, True) then
        Inc(yy);
      if player_active(pl2, True) then
        Inc(yy);
      if player_active(pl3, True) then
        Inc(yy);
      if player_active(pl4, True) then
        Inc(yy);

      if yy > 1 then
        d(3, 'The experience and ' + config.moneytype + ' are split equally...');

      xx := xx div yy;
      incplayerexp(player, xx);

      if yy > 1 then
        sd(config.textcolor, 'You receive your share of ')
      else sd(config.textcolor, 'You receive ');

      sd(14, commastr(xx));
      d(config.textcolor, ' experience points!');

      if player_active(pl1, True) then
        incplayerexp(pl1, xx);
      if player_active(pl2, True) then
        incplayerexp(pl2, xx);
      if player_active(pl3, True) then
        incplayerexp(pl3, xx);
      if player_active(pl4, True) then
        incplayerexp(pl4, xx);

      xx := random(300) * global_dungeonlevel;
      Inc(xx, random(500));
      sd(config.textcolor, 'You search the corpse and find ');
      sd(14, commastr(xx));
      d(config.textcolor, ' ' + many_money(xx) + '!');

      xx := xx div yy;
      incplayermoney(player, xx);

      if yy > 1 then
      begin
        sd(config.textcolor, 'Your share is ');
        sd(14, commastr(xx));
        d(config.textcolor, ' ' + many_money(xx) + '!');
      end;
      if player_active(pl1, True) then
        incplayermoney(pl1, xx);
      if player_active(pl2, True) then
        incplayermoney(pl2, xx);
      if player_active(pl3, True) then
        incplayermoney(pl3, xx);
      if player_active(pl4, True) then
        incplayermoney(pl4, xx);

      {should player take monster weapon/armor?}
      if (random(5) = 0) and (monster[mon]^.weapon <> '') and
        (monster[mon]^.grabweap = True) and (config.classic = False) then
      begin
        crlf;
        sd(14, 'You have found something : ');
        d(global_itemcol, monster[mon]^.weapon);

        if confirm('Take it ', 'Y') = True then
        begin

          xx := inventory_empty(player);
          if xx = 0 then
          begin
            d(15, 'Your inventory is full!');
            if confirm('Drop something ', 'Y') = True then
            begin
              drop_item(player);
            end;
          end;

          xx := inventory_empty(player);
          if xx > 0 then
          begin
            player.item[xx] := monster[mon]^.weapnr;
            player.itemtype[xx] := weapon;
            sd(config.textcolor, 'You place the ');
            sd(global_itemcol, monster[mon]^.weapon);
            d(config.textcolor, ' in your backpack');
            pause;
          end;

        end else
        begin
    {player decided not to take the weapon...teammembers can have
     their go at it now.}

          for plynr := 1 to 4 do
          begin
            case plynr of
              1: tempman := pl1;
              2: tempman := pl2;
              3: tempman := pl3;
              4: tempman := pl4;
            end; {case .end.}

            if (tempman.name2 <> '') and (tempman.hps > 0) then
            begin

              crlf;
              sd(global_plycol, tempman.name2);
              sd(config.textcolor, ' picks up the ');
              d(global_itemcol, monster[mon]^.weapon + config.textcol1 + '.');

              Result := check_inventory(tempman, monster[mon]^.weapnr, weapon, True, 4);

              {tempman took the item}
              if Result > 0 then
              begin
                case plynr of
                  1: pl1 := tempman;
                  2: pl2 := tempman;
                  3: pl3 := tempman;
                  4: pl4 := tempman;
                end; {case .end.}
                break;
              end;

            end;

          end; {for plynr:= .end.}

        end;
      end;

      if (random(5) = 0) and (monster[mon]^.armor <> '') and
        (monster[mon]^.grabarm = True) and
        (config.classic = False) then
      begin

        crlf;
        sd(14, 'You have found something : ');
        d(global_itemcol, monster[mon]^.armor);
        if confirm('Take it ', 'Y') = True then
        begin
          xx := inventory_empty(player);

          if xx = 0 then
          begin
            d(15, 'Your inventory is full!');
            if confirm('Drop something ', 'Y') = True then
            begin
              drop_item(player);
            end;
          end;
          xx := inventory_empty(player);

          if xx > 0 then
          begin
            player.item[xx] := monster[mon]^.armnr;
            player.itemtype[xx] := abody;
            sd(config.textcolor, 'You place the ');
            sd(global_itemcol, monster[mon]^.armor);
            d(config.textcolor, ' in your backpack');
            pause;
          end;

        end else
        begin
    {player decided not to take the armor...teammembers can have
     their go at it now.}

          for plynr := 1 to 4 do
          begin
            case plynr of
              1: tempman := pl1;
              2: tempman := pl2;
              3: tempman := pl3;
              4: tempman := pl4;
            end; {case .end.}

            if (tempman.name2 <> '') and (tempman.hps > 0) then
            begin

              crlf;
              sd(global_plycol, tempman.name2);
              sd(config.textcolor, ' picks up the ');
              d(global_itemcol, monster[mon]^.armor + config.textcol1 + '.');

              Result := check_inventory(tempman, monster[mon]^.armnr, abody, True, 4);

              {tempman took the item}
              if Result > 0 then
              begin
                case plynr of
                  1: pl1 := tempman;
                  2: pl2 := tempman;
                  3: pl3 := tempman;
                  4: pl4 := tempman;
                end; {case .end.}
                break;
              end;

            end;

          end; {for plynr:= .end.}
        end;
      end;
    end;

  end; {has_monster_died **end**}

begin  {MAIN PROC **START**}

       {init}
  attack_order := 1;
  healed := False;
  to_death := False;
  done := False;

  {to handle "carrier-dropping" cheaters}
  global_PlayerInFight := True;

  mon := 0;

 {code here used to set hps to strength*3.
  This made setting hitpoints in the monster editor completely
  pointless.}

  repeat
    player.casted := False;
    pl1.casted := False;
    pl2.casted := False;
    pl3.casted := False;
    pl4.casted := False;

    healed := False;

    crlf;
    d(7, 'You are fighting :');
    crlf;

    for i := 1 to global_maxmon do
    begin
      mtemp1[i] := '';
      mtemp2[i] := 0;
    end;

    for i := 1 to global_maxmon do
    begin
      found := False;
      if monster[i]^.hps > 0 then
      begin
        for j := 1 to global_maxmon do
        begin
          if mtemp1[j] = monster[i]^.Name then
          begin
            Inc(mtemp2[j], 1);
            found := True;
            break;
          end;
        end;
        if found = False then
        begin
          for j := 1 to global_maxmon do
          begin
            if mtemp1[j] = '' then
            begin
              mtemp1[j] := monster[i]^.Name;
              Inc(mtemp2[j], 1);
              break;
            end;
          end;
        end;
      end;
    end; {for i:= .end.}

    x := 0;
    y := 0;
    for i := 1 to global_maxmon do
    begin
      if mtemp1[i] <> '' then
      begin
        Inc(y);
        if y <> 1 then
        begin
          sd(global_moncol, ', ');
        end;

        Inc(x);
        if x > 3 then
        begin
          x := 0;
          crlf;
        end;

        if mtemp2[i] = 1 then
          sd(global_moncol, mtemp1[i])
        else sd(global_moncol, commastr(mtemp2[i]) + ' ' + mtemp1[i]);
        if mtemp2[i] > 1 then
        begin
          sd(global_moncol, 's');
        end;

      end;
    end;
    crlf;

    sd(global_plycol, 'Your ');
    sd(config.textcolor, 'hitpoints : ');
    sd(global_hpcol, commastr(player.hps));
    sd(config.textcolor, '/');
    d(global_hpcol, commastr(player.maxhps));

    for i := 1 to 4 do
    begin
      case i of
        1: tempman := pl1;
        2: tempman := pl2;
        3: tempman := pl3;
        4: tempman := pl4;
      end; {case .end.}

      if tempman.name2 <> '' then
      begin
        if tempman.hps > 0 then
        begin
          sd(global_plycol, tempman.name2 + ' ');
          d(3, condition(tempman.hps, tempman.maxhps));
        end else
        begin
          d(12, tempman.name2 + 's corpse, laying in a pool of blood...');
        end;
      end;
    end;

    expert_press := False;
    if to_death = False then
      cho := '?'
    else cho := 'A';

    repeat

      if cho = '?' then
      begin
        if (player.expert = False) or (expert_press = True) then
        begin
          expert_press := False;
          crlf;
          menu2('(A)ttack  ');
          menu2('(R)un  ');
          menu2('(H)eal  ');
          menu2('(Q)uick Heal ');
          menu2('(D)etailed Monster list');
          crlf;
          menu2('(S)tatus  ');
          menu2('(F)ight to Death ');
          menu2('(B)eg for Mercy  ');
          menu2('(*) Team command ');

          if player.class in [Cleric, Magician, Sage] then
          begin
            menu2('(C)ast Spell  ');
          end;

          if player.class = Paladin then
            menu2('(1) Soul Strike  ');
          if player.class = Assassin then
            menu2('(1) Backstab  ');
          crlf;
          sd(6, ':');
        end else
        begin
          crlf;
          sd(config.textcolor, 'Dng Fight (A,R,H,Q,D,S,F,B,*');
          if player.class in [Cleric, Magician, Sage] then
          begin
            sd(config.textcolor, ',C');
          end;
          if player.class in [Paladin, Assassin] then
          begin
            sd(config.textcolor, ',1');
          end;
          sd(config.textcolor, ',?) :');
        end;
      end;

      cho := ' ';

      if to_death = False then
      begin

        cho := upcase(getchar);

        if cho = chr(13) then
          cho := 'A';


        if cho = '?' then
        begin
          expert_press := True;
        end;

      end else
      begin
        if player.hps + 3 < player.maxhps then
        begin
          quick_healing(player);
        end;
        cho := 'A';
      end;

      case cho of
        'U': begin {use item - -only in NEW game mode}

          if config.classic = False then
          begin
            inventory_display(player);
            use_item(0);
            crlf;
            cho := 'A';
          end else
          begin
            cho := '?';
          end;

        end;
        'S': begin
          status(player);
          crlf;
          cho := '?';
        end;
        'F': begin {fight to the death}
          crlf;
          if confirm('Fight to Death ', 'Y') = True then
          begin
            d(4, 'IT''S YOU OR THEM!!');
            to_death := True;
            cho := 'A';
          end else
          begin
            cho := '?';
          end;
        end;

        '*': begin {team commands / options}
          crlf;
          if player.team = '' then
          begin
            d(5, 'You are not a member of a team!');
          end;
          if (pl1.name2 = '') and (pl2.name2 = '') and
            (pl3.name2 = '') and (pl4.name2 = '') then
          begin
            d(5, 'You have no teammembers with you!');
            pause;
          end else
          begin
            repeat
              d(14, 'Command :');
              menu('(A)ttack order');
              menu('(B)rief Status report');
              menu('(D)etailed report');

              sd(config.textcolor, '[');
              sd(5, 'Enter');
              d(config.textcolor, '] to continue');
              sd(config.textcolor, ':');
              cho := upcase(getchar);

              case cho of
                'A': begin {attack order}
                  crlf;
                  sd(config.textcolor, 'Current order : ');

                  case attack_order of
                    1: d(global_talkcol, 'Pick your own targets');
                    2: d(global_talkcol, 'Follow MY example');
                    3: d(global_talkcol, 'Attack the strongest opponent');
                    4: d(global_talkcol, 'Attack the weakest opponent');
                  end;

                  menu('(P)ick your own targets.');
                  menu('(F)ollow my example!');
                  menu('(S) attack strongest opponent');
                  menu('(W) attack weakest opponent');

                  sd(config.textcolor, ':');
                  repeat
                    cho := upcase(getchar);
                  until cho in ['P', 'F', 'S', 'W'];
                  crlf;

                  case cho of
                    'P': begin
                      attack_order := 1;
                      d(global_talkcol, 'Pick your own targets!');
                    end;
                    'F': begin
                      attack_order := 2;
                      d(global_talkcol, 'Follow my example!');
                    end;
                    'S': begin
                      attack_order := 3;
                      d(global_talkcol, 'Attack the strongest opponent!');
                    end;
                    'W': begin
                      attack_order := 4;
                      d(global_talkcol, 'Attack the weakest!');
                    end;
                  end; {case .end.}

                end;
                'D': begin
                  crlf;
                  if player_active(pl1, True) then
                    menu('[1] ' + pl1.name2)
                  else menu('[1] ---');
                  if player_active(pl2, True) then
                    menu('[2] ' + pl2.name2)
                  else menu('[2] ---');
                  if player_active(pl3, True) then
                    menu('[3] ' + pl3.name2)
                  else menu('[3] ---');
                  if player_active(pl4, True) then
                    menu('[4] ' + pl4.name2)
                  else menu('[4] ---');
                  sd(config.textcolor, ':');
                  cho := upcase(getchar);

                  case cho of
                    '1': if player_active(pl1, True) then
                        status(pl1);
                    '2': if player_active(pl2, True) then
                        status(pl2);
                    '3': if player_active(pl3, True) then
                        status(pl3);
                    '4': if player_active(pl4, True) then
                        status(pl4);
                  end;
                  cho := ' ';

                end;
                'B': begin
                  crlf;

                  for i := 1 to 4 do
                  begin
                    case i of
                      1: tempman := pl1;
                      2: tempman := pl2;
                      3: tempman := pl3;
                      4: tempman := pl4;
                    end; {case .end.}
                    if tempman.name2 <> '' then
                    begin
                      if tempman.hps < 1 then
                      begin
                        d(12, tempman.name2 + ', dead');
                      end else
                      begin
                        sd(global_plycol, tempman.name2);
                        sd(config.textcolor, ' has ');
                        sd(5, commastr(tempman.healing));
                        d(config.textcolor, ' healing potions');
                      end;
                    end;
                  end;

                  crlf;
                end;
              end;
            until cho = ReturnKey;
          end;
          cho := '?';
        end;

        'D': begin {display monsters}
          crlf;
          for i := 1 to global_maxmon do
          begin
            if monster_active(i) = True then
            begin
              sd(global_moncol, monster[i]^.Name + ' (' + commastr(monster[i]^.hps) + ' hps)');

              if monster[i]^.weapon <> '' then
              begin
                sd(7, '  Weapon : ' + monster[i]^.weapon);
              end;
              if monster[i]^.armor <> '' then
              begin
                sd(7, '  Armor : ' + monster[i]^.armor);
              end;

              crlf;

              if (First = False) and (config.mon_talk = True) then
              begin
                d(global_talkcol, '  ' + monster[1]^.phrase);
                First := True;
              end;
            end;
          end;
          pause;
          cho := '?';
        end;
        'C': begin {can spells be used?}

          cho := ' ';
          if player.class in [Cleric, Magician, Sage] then
          begin
            player.casted := False;

            cast_spell(False, 1, 1, player, player, False, mon);

            if player.casted = True then
            begin
              has_monster_died;
              cho := 'A';
            end else
            begin
              cho := '?';
            end;

          end;
        end;
        '1': begin {Backstab, poison option available?}
          if (player.race = Gnoll) or (player.class in [Paladin, Assassin]) then
          begin

          end else
          begin
            cho := '?';
          end;
        end;
        'Q': begin {check if healing is necessary}
          if player.hps >= player.maxhps then
          begin
            d(7, 'You are in no need of healing!');
            cho := '?';
          end;
        end;
      end;
    until cho in ['A', 'R', 'H', 'Q', 'B', '1'];

    stab1 := 0;
    case cho of

      'Q': begin {* Player uses Quick heal *}
        quick_healing(player);
        case config.quaffopt of
          1: begin {player Quaffs potion and then autoattacks}
                   {healed:=true;}
            cho := 'A';
          end;
          2: begin {player Quaffs potion and then monster attack}
            healed := True;
            cho := 'A';
          end;
          3: begin {player Quaffs potion and then chooses another option}
                   {healed:=true;}
            cho := '?';
          end;
        end;
      end;
      'H': begin {* Player heals himself *}
        healing(player);
        case config.quaffopt of
          1: begin
            {healed:=true;}
            cho := 'A';
          end;
          2: begin
            healed := True;
            cho := 'A';
          end;
          3: begin
            {healed:=true;}
            cho := '?';
          end;
        end;
      end;

      'B': begin {* Player begs for Mercy *}
        if monster_mode = pl_vs_prisonguards then
        begin
          {give up to the prison guards! immediately imprisoned!}
          crlf;
          d(15, 'You surrender to the guards!');
          crlf;
          pause;
          Inc(player.m_defeats);
          global_begged := True;
          global_PlayerInFight := False;
          exit;
        end else
        if (global_nobeg) or (monster_mode <> pl_vs_monster) then
        begin
          d(15, 'No Mercy is given here!');
          cho := 'A';
        end else
        if monster_mode = pl_vs_monster then
        begin
          crlf;
          if confirm('Beg for Mercy', 'N') = True then
          begin
            if (random(3) = 0) or (global_nobeg = True) then
            begin
              crlf;
              d(config.textcolor, 'You throw yourself to the ground and plead for mercy!');
              d(config.textcolor, 'But the monster doesn' + chr(39) + 't seem to care');
              d(config.textcolor, 'about your pathetic whining!');
              crlf;
              d(config.textcolor, 'You soon realize that your life has come to an end...');
              d(4, 'Splatt! Splatt! Your limbs are torn apart...');
              crlf;
              d(config.textcolor, 'Darkness...');
              crlf;

              Inc(player.m_defeats);
              global_begged := True;
              global_killed := True;
              global_PlayerInFight := False;
              crlf;

              exit;
            end else
            begin
              crlf;
              d(config.textcolor, 'You throw yourself to the ground and plead for mercy!');
              d(config.textcolor, 'Your foe doesn''t seem to care');
              d(config.textcolor, 'about whether you live or die.');
              crlf;
              d(config.textcolor, 'You soon realize that you will make it out of this situation!');
              d(config.textcolor, 'You watch how your foe slowly lurks away...');
              cho := 'R';
              X := 99;
              break;
            end;
          end;
        end;
      end;

      '1': begin {*Attacking player uses Backstab*}
        if player.class = Assassin then
        begin
          stab1 := 0;
          if config.classic then
          begin
            if player.weapon = 0 then
            begin
              crlf;
              d(config.textcolor, 'You don''t have a weapon!');
              crlf;
              pause;
              cho := ' ';
            end;
          end else
          begin
            if player.rhand + player.lhand = 0 then
            begin
              crlf;
              d(config.textcolor, 'You don''t have a weapon!');
              crlf;
              pause;
              cho := ' ';
            end;
          end;

          { Make sure we still can backstab }
          if (cho = '1') then
          begin
            mon := target_monster;
            crlf;
            d(config.textcolor, 'You try to Backstab the ' + monster[mon]^.Name + '!');
            if random(3) = 0 then
            begin
              d(config.textcolor, 'You manage to cut the ' + monster[mon]^.Name + '!');
              d(config.textcolor, 'The ' + monster[mon]^.Name + ' screams in pain!');
              stab1 := player.maxhps div 2;
            end else
            begin
              d(config.textcolor, 'You missed!');
              stab1 := -1;
            end;
            cho := 'A';
          end;
        end;

        if player.class = Paladin then
        begin
          crlf;
          if player.hps < 2 then
          begin
            d(config.textcolor, 'Sorry, too few hitpoints left!');
          end else
          begin
            mon := target_monster;
            sd(6, 'How many hitpoints to use (max ' + commastr(player.hps - 1) + ') :');
            zz := get_number(0, player.hps - 1);
            if (zz > 0) and (zz <= player.hps) then
            begin
              soulstrike := zz;
              Dec(player.hps, zz);
              if (player.mental < 50) and (random(3) = 0) then
              begin
                if random(player.mental) < random(player.mental) then
                begin
                  d(config.textcolor, 'Soulstrike failed due to weak concentration.');
                  soulstrike := 0;
                end;
              end;
              if (player.addict > 50) and (soulstrike > 0) and (random(3) = 0) then
              begin
                if random(player.addict) > random(player.addict) then
                begin
                  d(config.textcolor, 'Soulstrike failed due to your weakness.');
                  soulstrike := 0;
                end;
              end;
              cho := 'A';
            end else
            begin
              d(config.textcolor, 'Aborted.');
              cho := ' ';
            end;
          end;
        end;
      end;
    end;

    if cho = 'A' then
    begin {attack option has been activated}

      crlf;
      if mon < 1 then
      begin
        x := 0;
        for i := 1 to global_maxmon do
        begin
          if monster[i]^.hps > 0 then
          begin
            if x < 1 then
              mon := i;
            Inc(x);
          end;
        end; {for i:= .end.}
        if x > 1 then
        begin
          mon := target_monster;
        end;
      end;

      {strength in monster attacks, depending on the MODE variable}
      monster_charge(monster_mode);

      {monster picks target, if there are more than 1}
      for i := 1 to global_maxmon do
      begin
        monster[i]^.target := 1;

        if monster_mode <> pl_vs_demon then
        begin
          if (player_active(pl1, True)) and (random(3) = 0) then
          begin
            monster[i]^.target := 2;
          end;
          if (player_active(pl2, True)) and (random(3) = 0) then
          begin
            monster[i]^.target := 3;
          end;
          if (player_active(pl3, True)) and (random(3) = 0) then
          begin
            monster[i]^.target := 4;
          end;
          if (player_active(pl4, True)) and (random(3) = 0) then
          begin
            monster[i]^.target := 5;
          end;
        end;

      end;

      {styrkan i spelarnas attacker}
      player.punch := normal_attack(False, player);

      if healed = True then
      begin
        player.punch := 0;
      end;

      if soulstrike > 0 then
      begin
        zz := soul_effect(player, soulstrike);

        Inc(player.punch, zz);
        soulstrike := 0;
        d(config.textcolor, 'Soulstrike hits ' + monster[mon]^.Name + ' for ' + commastr(zz) + ' points!');
      end;

      {*Gnoll poison?*}
      if (player.race = Gnoll) and (monster[mon]^.poisoned = False) then
      begin
        {x:=random(global_dungeonlevel+5);}
        x := random(4) + 1;
        if x = 3 then
        begin
          d(config.textcolor, '**Poisonous Gnollbite!**');
          monster[mon]^.poisoned := True;
        end;
      end;

      {restoring overmaxed hps}
      if player.hps > player.maxhps then
        player.hps := player.maxhps;

      {backstab effect}
      if stab1 > 0 then
        player.punch := player.punch + stab1;

      if stab1 = -1 then
      begin
        monster[mon]^.punch := monster[mon]^.punch + player.level + 3;
        player.punch := 0;
      end;

      {poison effect}
      if player.poison > 0 then
      begin
        player.punch := player.punch + player.poison;
      end;

      if (stab1 <> -1) and (player.punch = 0) and (healed = False) and (player.casted = False) then
      begin
        d(config.textcolor, 'You missed your blow!');
      end;

      if (player.punch > 0) and (healed = False) and (player.casted = False) then
      begin

        if player.punch > 0 then
        begin
          if monster[mon]^.Name = '' then
          begin
            mon := target_monster;
          end;
          d(12, 'You hit the ' + monster[mon]^.Name + ' for ' + commastr(player.punch) + ' damage!');

          x := 0;
          {monster armor/defence}


          zz := 0;
          zz := monster[mon]^.defence + random(monster[mon]^.defence div 8);

          if monster[mon]^.armnr > 0 then
          begin
            zz := zz + random(monster[mon]^.armpow);
          end;

          if zz > 0 then
          begin
            Inc(x, zz);
          end;

          if x > 0 then
          begin

            {kludge, the programmer (jakob) is sloppy, he admits!}
            if x > player.punch then
              x := player.punch;
            Dec(player.punch, x);
            d(3, monster[mon]^.Name + 's armor absorbed ' + commastr(x) + ' points!');

          end;

          Dec(monster[mon]^.hps, player.punch);

          has_monster_died;

        end;
      end;

      {TeamMates attacks monster(s)}
      for i := 1 to 4 do
      begin
        case i of
          1: tempman := pl1;
          2: tempman := pl2;
          3: tempman := pl3;
          4: tempman := pl4;
        end;

        if (tempman.name2 <> '') and (tempman.hps > 0) then
        begin

          x := tempman.healing;
          {need to heal?}
          computer_healing(True, tempman);
          if (x <> tempman.healing) and (config.quaffopt = 2) then
            x := -1;

          if x <> -1 then
          begin {quaff=2 inneb„r n„mligen att spelaren binds en runda}

                {picks monster dependending on attack_order [1..4] }
            j := 0;
            case attack_order of
              1: begin {pick the first monster available}

                for k := 1 to global_maxmon do
                begin
                  if monster_active(k) = True then
                  begin
                    j := k;
                    break;
                  end;
                end; {for k:= .end.}

              end;
              2: begin {follow PLAYERS example}

                if mon > 0 then
                begin
                  if monster_active(mon) = True then
                  begin
                    j := mon;
                  end;
                end;

                if j = 0 then
                begin
                  for k := 1 to global_maxmon do
                  begin
                    if monster_active(k) = True then
                    begin
                      j := k;
                      break;
                    end;
                  end; {for k:= .end.}
                end;

              end;
              3: begin {pick the strongest opponent}

                xx := 0;
                for k := 1 to global_maxmon do
                begin
                  if monster_active(k) = True then
                  begin
                    if monster_power(k) > xx then
                    begin
                      xx := monster_power(k);
                      j := k;
                    end;
                  end;
                end; {for k:= .end.}

                if j = 0 then
                begin
                  for k := 1 to global_maxmon do
                  begin
                    if monster_active(k) = True then
                    begin
                      j := k;
                      break;
                    end;
                  end; {for k:= .end.}
                end;

              end;
              4: begin {pick the weakest opponent}

                xx := 0;
                for k := 1 to global_maxmon do
                begin
                  if monster_active(k) = True then
                  begin
                    xx := monster_power(k);
                    break;
                  end;
                end; {for k:= .end.}

                for k := 1 to global_maxmon do
                begin
                  if monster_active(k) = True then
                  begin
                    if monster_power(k) < xx then
                    begin
                      xx := monster_power(k);
                      j := k;
                    end;
                  end;
                end; {for k:= .end.}

                if j = 0 then
                begin
                  for k := 1 to global_maxmon do
                  begin
                    if monster_active(k) = True then
                    begin
                      j := k;
                      break;
                    end;
                  end; {for k:= .end.}
                end;

              end;
            end;


            if j > 0 then
            begin

              {suitable monster found, now deciding type of attack}

              norm_att := True;
              {*soul strike?*}
              if (tempman.class = Paladin) and (tempman.hps > 100) and
                (random(3) = 0) and (tempman.casted = False) then
              begin

                zz := tempman.hps div 3;
                Dec(tempman.hps, zz);

                zz := soul_effect(tempman, zz);
                Dec(monster[j]^.hps, zz);
                s := hit_output(zz);
                sd(config.textcolor, 'Soulstrike from ');
                sd(global_plycol, tempman.name2);
                sd(config.textcolor, ' hits ');
                sd(global_moncol, monster[j]^.Name);
                d(config.textcolor, ' for ' + s + ' damage!');
                norm_att := False;
              end else
              if (tempman.class = Assassin) and (random(3) = 0) and
                (tempman.rhand + tempman.lhand > 0) then
              begin
                {*Backstab?*}
                sd(global_plycol, tempman.name2);
                d(3, ' tries to Backstab the ' + monster[j]^.Name + '!');
                if random(3) = 0 then
                begin
                  d(3, 'SUCCESS! The ' + monster[j]^.Name + ' is covered with blood!');
                  zz := tempman.maxhps div 2;
                  Dec(monster[j]^.hps, zz);
                end else
                begin
                  d(3, 'But misses!');
                end;
                norm_att := False;
              end else
              if tempman.class in [Cleric, Magician, Sage] then
              begin
                if (tempman.mana > 15) and (random(3) = 0) then
                begin
                  {spell casting?}
                  tempman.absorb := 0;
                  cast_spell(False, 1, 1, tempman, tempman, False, dummy);
                  cast_spell(False, j + 9999, 1, tempman, tempman, False, dummy);
                  norm_att := False;
                end;
              end;

              if norm_att = True then
              begin
                {*Normal attack}
                zz := normal_attack(False, pl1);
                s := hit_output(zz);
                x := monster[j]^.defence + random(monster[j]^.defence div 8);
                if monster[j]^.armnr > 0 then
                begin
                  x := x + random(monster[j]^.armpow);
                end;

                if x > 0 then
                begin
                  if x > zz then
                    x := zz;

                  Dec(zz, x);
                end;
                Dec(monster[j]^.hps, zz);

                if (random(6) = 0) and (tempman.battlecry <> '') then
                begin
                  sd(global_talkcol, tempman.battlecry);
                  sd(config.textcolor, ', ');
                  sd(global_plycol, tempman.name2);
                  d(config.textcolor, ' screams!');
                end;

                if zz > 0 then
                begin
                  sd(global_plycol, tempman.name2);
                  sd(3, ' slashes ');
                  sd(global_moncol, monster[j]^.Name);
                  d(3, ' for ' + s + ' damage!');
                  if x > 0 then
                  begin
                    sd(global_moncol, monster[j]^.Name + 's ');
                    d(3, 'armor absorbed ' + uwhite + commastr(x) + ucyan + ' points!');
                  end;
                end else
                begin
                  sd(global_plycol, tempman.name2);
                  sd(3, ' attacks ');
                  sd(global_moncol, monster[j]^.Name);
                  d(config.textcolor, ' but misses!');
                end;
              end;

              if monster[j]^.hps < 1 then
              begin
                Inc(tempman.m_kills);

                kill_comment(tempman, monster[j]^.Name);
                monster[j]^.Name := '';
                if j = mon then
                  mon := 0;

                xx := dungeon_reward(global_dungeonlevel);
                {does the XP have to be split with teammates?}
                yy := 1;
                if player_active(pl1, True) then
                  Inc(yy);
                if player_active(pl2, True) then
                  Inc(yy);
                if player_active(pl3, True) then
                  Inc(yy);
                if player_active(pl4, True) then
                  Inc(yy);

                if yy > 1 then
                  d(3, 'The Experience and ' + config.moneytype + ' are split equally...');

                xx := xx div yy;
                incplayerexp(player, xx);

                sd(config.textcolor, 'You receive your share of ');
                sd(14, commastr(xx));
                d(config.textcolor, ' experience points!');

                if player_active(pl1, True) then
                  incplayerexp(pl1, xx);
                if player_active(pl2, True) then
                  incplayerexp(pl2, xx);
                if player_active(pl3, True) then
                  incplayerexp(pl3, xx);
                if player_active(pl4, True) then
                  incplayerexp(pl4, xx);

                {search monster corpse for gold}
                xx := random(300) * global_dungeonlevel;
                Inc(xx, random(500));
                sd(global_plycol, tempman.name2);
                sd(config.textcolor, ' search the corpse and finds ');
                sd(14, commastr(xx));
                d(config.textcolor, ' ' + many_money(xx) + '!');

                xx := xx div yy;
                incplayermoney(player, xx);

                sd(config.textcolor, 'Your share is ');
                sd(14, commastr(xx));
                d(config.textcolor, ' ' + many_money(xx) + '!');

                if player_active(pl1, True) then
                  incplayermoney(pl1, xx);
                if player_active(pl2, True) then
                  incplayermoney(pl2, xx);
                if player_active(pl3, True) then
                  incplayermoney(pl3, xx);
                if player_active(pl4, True) then
                  incplayermoney(pl4, xx);

                {should the player take monster weapon/armor?}
                if (monster[j]^.weapon <> '') and (monster[j]^.grabweap = True) and
                  (config.classic = False) then
                begin
                  crlf;
                  sd(global_plycol, tempman.name2);
                  d(config.textcolor, ' has found : ');
                  d(global_itemcol, ' ' + monster[j]^.weapon);

                  check_inventory(tempman, monster[j]^.weapnr, weapon, True, 3);

                end;

                if (monster[j]^.armor <> '') and (monster[j]^.grabarm = True) and
                  (config.classic = False) then
                begin
                  crlf;
                  sd(global_plycol, tempman.name2);
                  d(config.textcolor, ' has found : ');
                  d(global_itemcol, ' ' + monster[j]^.armor);

                  check_inventory(tempman, monster[j]^.armnr, abody, True, 3);

                end;
              end;
            end;
          end;
        end;

        case i of
          1: pl1 := tempman;
          2: pl2 := tempman;
          3: pl3 := tempman;
          4: pl4 := tempman;
        end;

      end;

      for i := 1 to global_maxmon do
      begin
        if (monster_active(i) = True) and (monster[i]^.poisoned = True) then
        begin
          x := random(5) + 1;
          sd(global_moncol, monster[i]^.Name);
          d(config.textcolor, ' suffers from poison!');
          Dec(monster[i]^.hps, x);
        end;

        if (monster_active(i) = True) and (monster[i]^.disease = True) then
        begin
          x := random(14) + 1;
          sd(global_moncol, monster[i]^.Name);
          d(config.textcolor, ' suffers from a disease!');
          Dec(monster[i]^.hps, x);
        end;
      end;

      {take into account long lasting spells}

      cast_spell(False, mon + 9999, 1, player, player, False, dummy);


      {monster attacks}
      xx := 0;
      y := 0;
      for i := 1 to global_maxmon do
      begin

        case monster[i]^.target of
          1: tempman := player;
          2: tempman := pl1;
          3: tempman := pl2;
          4: tempman := pl3;
          5: tempman := pl4;
        end;

        tempman.absorb := 0;

        if tempman.hps > 0 then
        begin

          Inc(y);
          if (y > 8) and (to_death = False) then
          begin
            y := 0;
            pause;
          end;

          {**START** monster decides if it should cast a spell **START**}

          {fusk! ger monster alla spells!}
     {for j:=1 to global_maxmspells do begin
      monster[i]^.spell[j]:=true;
     end;}

          monster_magic := False;
          monster_spell := 0;
          ms := 0;

          if monster_active(i) then
          begin
            for j := 1 to global_maxmspells do
            begin
              if monster[i]^.spell[j] then
              begin
                if monster[i]^.mana >= spell_cost_monster(j) then
                begin
                  Inc(ms);
                end;
              end;
            end; {for j:= .end.}

            if (ms > 0) and (random(2) = 0) then
            begin
              ms := random(ms) + 1;
              ms2 := 0;
              for j := 1 to global_maxmspells do
              begin
                if (monster[i]^.spell[j]) and (monster[i]^.mana >= spell_cost_monster(j)) then
                begin
                  Inc(ms2);
                  if ms2 = ms then
                  begin
                    ms := j;
                    monster_spell := ms;
                    monster_magic := True;
                    break;
                  end;
                end;
              end;
            end;
          end;

          {**END** monster cast spell decision **END**}




          if (monster[i]^.punch < 1) and (monster[i]^.Name <> '') and
            (not monster_magic) then
          begin
            if tempman.name2 = player.name2 then
            begin
              sd(global_moncol, monster[i]^.Name);
              d(13, ' missed you completely!');
            end else
            begin
              sd(global_moncol, monster[i]^.Name);
              sd(13, ' missed ');
              d(global_plycol, tempman.name2 + '!');
            end;
            Inc(xx);
          end;

          if (monster_active(i)) then
          begin

            if (monster[i]^.punch > 0) or (monster_magic) then
            begin

              if not monster_magic then
              begin
                s := hit_output(monster[i]^.punch);

                if tempman.name2 = player.name2 then
                begin
                  sd(global_moncol, monster[i]^.Name);
                  sd(12, ' hits You for ' + s + ' damage!');
                end else
                begin
                  sd(global_moncol, monster[i]^.Name);
                  sd(12, ' hits ');
                  sd(global_plycol, tempman.name2);
                  d(12, ' for ' + s + ' damage!');
                end;

                Inc(xx);

                {cast_spell(2,1,tempman,tempman);}
                normal_defence(tempman);

                if tempman.absorb > monster[i]^.punch then
                begin
                  tempman.absorb := monster[i]^.punch;
                end;
                if tempman.absorb < 0 then
                begin
                  tempman.absorb := 0;
                end;

                if (tempman.absorb > 0) and (tempman.name2 = player.name2) then
                begin
                  d(3, '  (armor absorbed ' + commastr(percent(tempman.absorb, monster[i]^.punch)) + '%)');
                  monster[i]^.punch := monster[i]^.punch - tempman.absorb;
                  if monster[i]^.punch < 0 then
                  begin
                    monster[i]^.punch := 0;
                  end;
                end else
                begin
                  crlf;
                end;

                if monster[i]^.punch > 0 then
                begin
                  tempman.hps := tempman.hps - monster[i]^.punch;
                end;
              end else
              begin {Monster_magic=true}

                monster_magic_attack(i);;
                {MONSTER Decided to CAST a Spell}

              end;

              if tempman.hps < 1 then
              begin

                if tempman.name2 = player.name2 then
                begin
                  show_usurper_data(picture_death_head, False);
                  d(4, 'You are DEAD!');

                  {the monster who took players life}
                  killed_by[1] := monster[i]^.Name;

                  {announce it node-wide}
                  online_send_to_all(uplc + player.name2 + config.textcol1 + ' has been killed by a ' +
                    umonc + monster[i]^.Name + config.textcol1, player.name2, '');

                  xplose(tempman);
                  Inc(tempman.m_defeats);
                  pause;

                end else
                begin

                  {teammates last words}
                  case random(4) of
                    0: begin
                      d(15, 'A horrifying scream is heard!!');
                    end;
                    1: begin
                      sd(global_plycol, tempman.name2);
                      d(12, ' goes down!');
                    end;
                    2: begin
                      sd(global_talkcol, 'Jesus! They got me!');
                      sd(15, ', ');
                      sd(global_plycol, tempman.name2);
                      d(15, ' whispers.');
                    end;
                    3: begin
                      d(global_talkcol, 'Gosh, I''m really BLEEDING guys...!');
                    end;
                  end;

                  show_usurper_data(picture_death_head, False);
                  d(4, '** ' + tempman.name2 + ' is DEAD! **');

                  {the monster who took players life}
                  killed_by[monster[i]^.target] := monster[i]^.Name;

                  {announce it node-wide}
                  online_send_to_all(uplc + tempman.name2 + config.textcol1 + ' has been killed by a ' +
                    umonc + monster[i]^.Name +
                    config.textcol1, player.name2, player.name2);

                  if tempman.name2 <> player.name2 then
                  begin
                    update_shadow(tempman.name2, '', True);
                  end;
                  xplose(tempman);
                  Inc(tempman.m_defeats);
                  pause;

                  s := '';
                  if random(4) = 0 then
                  begin
                    if (pl1.name2 <> '') and (pl1.name2 <> tempman.name2) and
                      (pl1.hps > 0) then
                    begin
                      s := pl1.name2;
                    end else
                    if (pl2.name2 <> '') and (pl2.name2 <> tempman.name2) and
                      (pl2.hps > 0) then
                    begin
                      s := pl2.name2;
                    end else
                    if (pl3.name2 <> '') and (pl3.name2 <> tempman.name2) and
                      (pl3.hps > 0) then
                    begin
                      s := pl3.name2;
                    end else
                    if (pl4.name2 <> '') and (pl4.name2 <> tempman.name2) and
                      (pl4.hps > 0) then
                    begin
                      s := pl4.name2;
                    end;

                    if s <> '' then
                    begin
                      case random(3) of
                        0: begin
                          sd(global_talkcol, 'We must avenge ' + tempman.name2 + '!');
                          sd(config.textcolor, ', ');
                          sd(global_plycol, s);
                          d(config.textcolor, ' screams!');
                        end;
                        1: begin
                          sd(global_talkcol, 'Poor ' + tempman.name2 + '! Too weak to follow!');
                          sd(config.textcolor, ', ');
                          sd(global_plycol, s);
                          d(config.textcolor, ' remarks.');
                        end;
                        2: begin
                          sd(global_talkcol, 'REVENGE! REVENGE FOR ' + tempman.name2 + 's DEATH!');
                          sd(config.textcolor, ', ');
                          sd(global_plycol, s);
                          d(config.textcolor, ' screams!');
                        end;
                      end;
                    end;
                  end;
                end;

              end;
            end;
          end;
        end;

        case monster[i]^.target of
          1: player := tempman;
          2: pl1 := tempman;
          3: pl2 := tempman;
          4: pl3 := tempman;
          5: pl4 := tempman;
        end;

      end;

      done := True;
      for i := 1 to global_maxmon do
      begin
        if monster[i]^.hps > 0 then
        begin
          done := False;
          break;
        end;
      end;

      if player.hps <= 0 then
      begin
        global_killed := True;
        global_PlayerInFight := False;
        exit;
      end;
      {infections?}
      infections;

    end;
    {** end of 'A' <attack> **}


    {RUN AWAY}
    if cho = 'R' then
    begin
      if (global_escape = False) or (monster_mode <> pl_vs_monster) then
      begin
        d(12, 'YOU CAN''T ESCAPE!');
        cho := 'A';
      end else
      if monster_mode = pl_vs_monster then
      begin
        if Retreat = True then
        begin
          d(15, 'You managed to escape!');
          global_PlayerInFight := False;
          exit;
        end else
        begin
          d(12, 'You failed to escape!');
          crlf;
          cho := 'A';
        end;
      end;
    end; {if cho='R'}

  until done;

  {player has left fight}
  global_PlayerInFight := False;

end;

end.
