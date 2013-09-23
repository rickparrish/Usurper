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



unit InnC; {Usurper - The Inn}

interface

procedure The_Inn;

implementation

uses
  DDplus, Init, Cms,
  Jakob, Statusc, Plvsplc,
  Plvsmon, Recruite, Tcorner,
  News, Mail, Npc_Chec,
  Various, Various2, Various3,
  Post_To, Relation, Online,
  File_Io;

var
  sicken:  integer;
  refresh: boolean;

procedure New_Guest_News; {text put in the news when player hires a room at the inn}
var s:   s90;
  guard: GuardRec;
begin

  s := '';
  if player.bguardnr > 0 then
  begin
    {get name of door guard}
    load_guard(fload, guard, player.bguard);
    if player.bguardnr > 1 then
    begin
      s := uplc + player.name2 + config.textcol1 + ' hired some ' + uguardc + guard.Name + 's' +
        config.textcol1 + ' for protection.';
    end else
    begin
      s := uplc + player.name2 + config.textcol1 + ' hired a ' + uguardc + guard.Name + config.textcol1 + ' for protection.';
    end;
  end;

  {news-paper}
  newsy(True,
    'Guest at the Inn',
    ' ' + uplc + player.name2 + config.textcol1 + ' is staying in a room at the Inn.',
    ' ' + s,
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {New_Guest_News *end*}

procedure Meny;
const offset = 15;
var s: s90;
begin

  s := 'The Empty Barrel, run by ' + config.innkeeper;

  clearscreen;
  crlf;
  d(5, s);
  d(5, mkstring(length(s), underscore));
  crlf;
  d(config.textcolor, 'You enter the pub which is filled with a strange mix of creatures.');
  d(config.textcolor, 'Screaming trolls and grim-looking orcs are spread out at small tables');
  d(config.textcolor, 'in the center of the room. Elves and humans are mostly concentrated at');
  d(config.textcolor, 'the bar, involved in deep conversations about the latest events.');
  d(config.textcolor, 'You really don''t know what to do...');
  crlf;

  menu2(ljust('(L)edger', offset));
  menu2(ljust('(C)hat rooms', offset + 7));
  menu('(V)iew statements');

  menu2(ljust('(M)essage', offset));
  menu2(ljust('(G)et a Room', offset + 7));
  menu('(N)ew Mail Check');

  menu2(ljust('(T)eam corner', offset));
  menu('(H)all of recruitment');

  menu2(ljust('(S)tatus', offset));
  menu('(A)ttack Guest');

  menu(ljust('(R)eturn', offset));

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

      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'The Inn (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin

      if player.ear = 1 then
      begin
        who_is_here;
      end;

      crlf;
      sd(config.textcolor, 'Inn (R,C,V,M,G,L,T,N,S,A,H,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force) then
    begin
      meny;
    end;
  end;

end; {display_menu *end*}

procedure The_Inn;
const never: boolean = False;
const maxlin         = 5; {max lines to add to Inn chat file}
var
  k, cc, size, Count, dgsize: integer;
  roomcost:    array[1..4] of integer;

  c:           byte;

  ch, cho:     char;

  s:           string;
  e:           s70;
  mess:        array[1..5] of s70;

  xx, i, x, j: longint;

  finito, search, teamkill: boolean;

  Guard:       ^GuardRec;
  Pl0:         ^UserRec;
  Pl:          array [1..4] of ^Userrec;

const len = 70;            {max length of text lines}

  procedure Attack_Player; {attack a character}
  var i, j, x: longint;
  begin

    if player.pfights < 1 then
    begin
      crlf;
      d(12, 'Sorry, but you have run out of player fights.');
      pause;
    end else
    begin
      crlf;
      crlf;
      d(config.textcolor, 'Who must die?');
      sd(config.textcolor, ':');

      s := get_string(20);
      search := False;

      {searching among the humans and NPCs}
      finito := False;
      for i := 1 to 2 do
      begin

        case i of
          1: size := fs(FsPlayer);
          2: size := fs(FsNpc);
        end; {case .end.}

        for j := 1 to size do
        begin

          if load_character(pl0^, i, j) = True then
          begin

            if (findsub(s, pl0^.name2)) and
              (pl0^.hps > 0) and
              (pl0^.king = False) and
              (pl0^.deleted = False) and
              (pl0^.name1 <> global_delname1) and
              (pl0^.name2 <> global_delname2) and
              (pl0^.location in [offloc_innroom1..offloc_innroom4]) then
            begin

              if confirm(uplc + pl0^.name2 + config.textcol1, 'N') = True then
              begin

                if (player.team = pl0^.team) and (player.team <> '') and (teamkill = False) then
                begin
                  crlf;
                  d(5, 'You are not allowed to attack your own teammates!');
                  break;
                end;
                x := player.level - pl0^.level;

                if Is_Player_Married(player.name2, player.id) = pl0^.name2 then
                begin
                  cannot_attack_husband(player, pl0^);
                end else
                if (x > config.leveldiff) and (config.leveldiff <> 0) then
                begin
                  crlf;
                  d(12, 'That would be too easy!');
                end else
                begin
                  {we have found our target}
                  search := True;
                end;
              end else
              begin
                if confirm('Continue search', 'Y') = False then
                begin
                  finito := True;
                end;
              end;
            end;

            if (search) or (finito) then
              break;
          end;
        end; {for j:= .end.}
        if (search) or (finito) then
          break;
      end; {for i:= .end.}

      if (search = False) and (finito = False) then
      begin
        Could_Not_Locate_Challengable_Character;

      end;

      {target found}
      if search then
      begin

        xx := 1500;

        case pl0^.location of
          offloc_innroom1: xx := 2500;
          offloc_innroom2: xx := 2500 * 2;
          offloc_innroom3: xx := 2500 * 3;
          offloc_innroom4: xx := 2500 * 5;
        end;

        crlf;
        sd(config.textcolor, 'It will take ');
        sd(14, commastr(xx));
        d(config.textcolor, ' ' + many_money(xx) + ' in bribes to get you near the room.');
        if confirm('Pay', 'n') = True then
        begin

          if player.gold >= xx then
          begin

            {add offline player}
            if add_shadow(SAdd, pl0^, player.name2, 'fighting ' + uplc + player.name2 + config.textcol1, 0) = False then
            begin
              {unable to add pl0}
              crlf;
              d(global_plycol, pl0^.name2 + config.textcol1 + ' has left ' + sex3[pl0^.sex] + ' room!');
              pause;
            end else
            begin

              {Update player location & doing}
              onliner.location := onloc_innfight;
              onliner.doing := location_desc(onliner.location);
              add_onliner(OUpdateLocation, onliner);

              {pay bribes}
              decplayermoney(player, xx);

              d(15, 'You pay.');

              if pl0^.bguardnr > 0 then
              begin
                crlf;

                if pl0^.bguard > fs(FsGuard) then
                begin
                  pl0^.bguard := 1;
                end;

                load_guard(fload, guard^, pl0^.bguard);

                if pl0^.bguardnr = 1 then
                begin
                  sd(config.textcolor, 'An angry ');
                  sd(12, guard^.Name);
                  d(config.textcolor, ' guards the door!');
                end else
                begin
                  sd(11, commastr(pl0^.bguardnr) + ' ');
                  sd(12, guard^.Name + 's');
                  d(config.textcolor, ' guard the door!');
                end;

                if confirm('Attack ', 'N') = True then
                begin
                  crlf;
                  d(config.textcolor, 'Charging!');
                  {dec player fights}
                  Dec(player.pfights);

                  {reset monsters}
                  reset_monsters;

                  for i := 1 to pl0^.bguardnr do
                  begin
                    create_monster(i,              {#}
                      guard^.Name,        {name}
                      guard^.hps,         {hps}
                      guard^.battack,     {strength}
                      {player.level} 0,   {defence}
                      'Grrrr..',          {phrase}
                      False,              {grabweap}
                      False,              {grabarm}
                      '',                 {weapon-string}
                      '',                 {armor-string}
                      False,              {poisoned-should be false}
                      False,              {disease -should be false}
                      guard^.battack,     {punch}
                      0,                  {armpow}
                      0);                 {weappow}
                  end; {for i:= .end.}

                  {setting some variables before the fight}
                  global_begged := False;
                  global_escape := False;
                  global_nobeg := True;

                  pl[1]^.name2 := '';
                  pl[2]^.name2 := '';
                  pl[3]^.name2 := '';
                  pl[4]^.name2 := '';

                  {fight against door guards}
                  player_vs_monsters(pl_vs_doorguards, pl[1]^, pl[2]^, pl[3]^, pl[4]^);

                  if not global_killed then
                  begin

                    if pl0^.bguardnr > 1 then
                      s := 's'
                    else s := '';

                    {put the event in the news}
                    Newsy(True, 'Intruder at the Inn',
                      ' ' + uplc + player.name2 + config.textcol1 + ' massacred ' + uwhite +
                      commastr(pl0^.bguardnr) + config.textcol1 + ' ' + uguardc + guard^.Name + s + config.textcol1 + '.',
                      ' ' + uplc + player.name2 + config.textcol1 + ' then walked into ' + uplc +
                      pl0^.name2 + 's' + config.textcol1 + ' room...',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');


                    {opponent checks his inventory}
                    check_inventory(pl0^, 0, weapon, False, 0);

                    {worsen pl0:s attitude to player}
                    Update_Relation(Relation_Worsen, 2, pl0^, player, False, False);

                    {dispose of door guards}
                    pl0^.bguardnr := 0;
                    user_save(pl0^);

                    {the fight}
                    player_vs_player(pl0^);

                  end else
                  begin {died against doorguards}

                        {set player flags}
                    player.hps := 0;
                        {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);

                    crlf;
                    pause;

                    if pl0^.bguardnr > 1 then
                    begin
                      s := ' ' + uplc + player.name2 + config.textcol1 + ' fought ' + uwhite +
                        commastr(pl0^.bguardnr) + ' ' + uguardc + guard^.Name + 's' + config.textcol1 + ' at the Inn!';
                    end else
                    begin
                      s := ' ' + uplc + player.name2 + config.textcol1 + ' fought ' + uwhite +
                        commastr(pl0^.bguardnr) + ' ' + uguardc + guard^.Name + config.textcol1 + ' at the Inn!';
                    end;

                    {News-Paper}
                    Newsy(True,
                      player.name2 + ' fights DoorGuards!',
                      s,
                      ' ' + uplc + player.name2 + config.textcol1 + ' wasn''t up to it! Death collected ' +
                      uplc + player.name2 + config.textcol1 + '.',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                    {remove dead doorguards from opponent}
                    c := 0;
                    if pl0^.bguardnr > 0 then
                    begin
                      for x := 1 to global_maxmon do
                      begin
                        if monster_active(x) then
                          Inc(c);
                      end;

                      if c < pl0^.bguardnr then
                      begin
                        x := pl0^.bguardnr - c;

                        pl0^.bguardnr := c;

                        user_save(pl0^);
                        c := x;

                      end;

                    end;

                    s := uplc + player.name2 + config.textcol1 + ' attacked your Doorguards!';
                    if c > 0 then
                    begin
                      s := uplc + player.name2 + config.textcol1 + ' managed to kill ' + ulcyan +
                        commastr(c) + config.textcol1 + ' of your guards!';
                    end;

                    {mail player}
                    s := 'Failed Attack!';
                    post(MailSend,
                      player.name2,
                      player.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      ulred + s + config.textcol1,
                      mkstring(length(s), underscore),
                      'You were slain by ' + uplc + pl0^.name2 + 's' + config.textcol1 + ' door-guards!',
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

                    {mail the assaulted player}
                    s := 'Assaulted!';
                    post(MailSend,
                      pl0^.name2,
                      pl0^.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      umailheadc + s + config.textcol1,
                      mkstring(length(s), underscore),
                      s,
                      uplc + player.name2 + config.textcol1 + ' was killed in the attempt!',
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

                  {exit}
                  normal_exit;

                end;
              end else
              begin

                {dec player fights}
                Dec(player.pfights);

                {save user}
                user_save(player);

                {worsen pl0:s attitude to player}
                Update_Relation(Relation_Worsen, 2, pl0^, player, False, False);

                {fight}
                player_vs_player(pl0^);

              end;

              {remove shadow player PL0}
              add_shadow(SRemove, pl0^, '', '', 0);

            end;

          end else
          begin
            {generic message}
            you_cant_afford_it;
          end;
        end;

      end;
    end;

  end; {attack player *end*}

var pause_check: boolean;
begin {MAIN-PROCEDURE}

      {cost to hire rooms}
  roomcost[1] := 200;
  roomcost[2] := 900;
  roomcost[3] := 3200;
  roomcost[4] := 7500;

  {init pointer variables}
  new(pl0);
  new(guard);
  new(pl[1]);
  new(pl[2]);
  new(pl[3]);
  new(pl[4]);

  {fetching "kill teammates?" option from .CFG}
  teamkill := False;
  s := cfg_string(35);
  if s = '' then
    teamkill := False;
  if upcasestr(s) = 'YES' then
    teamkill := True;

  {display_menu(false,false);}

  crlf;
  repeat

    {update online location, if necessary}
    if onliner.location <> onloc_theinn then
    begin
      refresh := True;
      onliner.location := onloc_theinn;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    case global_auto_probe of
      NoWhere: begin
        display_menu(True, True);
        cho := upcase(getchar);
      end;
      Inn: begin
        global_auto_probe := NoWhere;
        crlf;
        d(config.textcolor, 'You wake up and get dressed. The Inn is providing some');
        d(config.textcolor, 'very nice rooms here. You might consider returning');
        d(config.textcolor, 'here when you have finished your daily doings.');
        crlf;
        pause;
        cho := '?';
      end;
    end; {case .end.}

    case cho of
      '?': begin
        if player.expert = True then
          display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        status(player);
        crlf;
      end;
      'N': begin {new mail, scan for}
        crlf;
        crlf;
        crlf;
        d(10, 'Let''s see if you have mail waiting ...');

        read_my_mail(player);

      end;
      'H': begin {"recruit new team members" room}
        crlf;
        recruite_npc;
      end;
      'A': begin {attack player/npc sleeping here}
        attack_player;
      end;
      'T': begin {Enter *Team Corner*}
        team_corner;
        crlf;
      end;
      'L': begin {Examine Ledger}
        crlf;
        crlf;

        s := 'When ' + config.innkeeper + ' is not around, you quickly examine the Inn ledger';

        d(config.textcolor, 'When ' + uplc + config.innkeeper + config.textcol1 +
          ' is not around, you quickly examine the Inn ledger');
        d(3, mkstring(length(s), underscore));

        k := 2;

        finito := False;
        pause_check := True;
        for i := 1 to 2 do
        begin
          case i of
            1: size := fs(FsPlayer);
            2: size := fs(FsNpc);
          end;

          for j := 1 to Size do
          begin

            if finito then
              break;

            {load character}
            if load_character(pl0^, i, j) = True then
            begin

              if (pl0^.hps > 0) and
                (pl0^.king = False) and
                (pl0^.name2 <> player.name2) and
                (pl0^.deleted = False) and
                (pl0^.location in [offloc_innroom1..offloc_innroom4]) then
              begin

                sd(global_plycol, pl0^.name2);
                sd(config.textcolor, ', the level ' + commastr(pl0^.level) + ' ' + race_display(2, pl0^.race, 0) +
                  ', is staying');

                case pl0^.location of
                  offloc_innroom1: d(config.textcolor, ' at a room downstairs.');
                  offloc_innroom2: d(config.textcolor, ' on the first floor.');
                  offloc_innroom3: d(config.textcolor, ' on the second floor.');
                  offloc_innroom4: d(config.textcolor, ' on the third floor.');
                end; {case .end.}

                if pl0^.bguard > 0 then
                begin
                  if pl0^.bguard > fs(FsGuard) then
                  begin
                    pl0^.bguard := 1;
                  end;

                  {load door-guard}
                  load_guard(Fload, guard^, pl0^.bguard);
                  if pl0^.bguardnr = 1 then
                  begin
                    sd(11, ' 1');
                    sd(config.textcolor, ' angry ');
                    sd(12, guard^.Name);
                    d(config.textcolor, ' guards the door!');
                  end else
                  begin
                    sd(11, ' ' + commastr(pl0^.bguardnr) + ' ');
                    sd(12, guard^.Name + 's');
                    d(config.textcolor, ' guard the door!');
                  end;
                  Inc(k);

                end;

          { d(8,mkstring(17,' ')+mkstring(3,'*'));
          }
                if pause_check = True then
                begin
                  Inc(k);
                  if k > global_screenlines - 2 then
                  begin
                    k := 0;

                    sd(config.textcolor, 'Continue (' + config.textcol2 + 'a' + config.textcol1 + ')ttack ? ([Y]/N/=)');

                    {get user-input}
                    repeat
                      cho := upcase(getchar);
                    until cho in [ReturnKey, 'Y', 'N', '=', 'A'];

                    crlf;
                    {evaluate user-input}
                    case cho of
                      'N': begin
                        finito := True;
                        break;
                      end;
                      '=': begin
                        pause_check := False;
                      end;
                      'A': begin
                        attack_player;
                      end;
                    end; {case .end.}

                  end;
                end;
              end;
            end;
          end; {for j:= .end.}
        end;   {for i:= .end.}

        crlf;
        pause;
        crlf;
      end;
      'G': begin {Get a room for the night.}
        crlf;
        d(config.textcolor, 'You approach ' + uplc + config.innkeeper + config.textcol1 +
          ' and ask him if there are any available rooms.');
        d(config.textcolor, '"Well, of course you can have a room if you can pay.');
        d(config.textcolor, 'What floor do you wanna stay on? Downstairs is cheaper, but');
        d(config.textcolor, 'more risky. Besides, the doors are more robust upstairs."');
        crlf;
        menu('(D)ownstairs   - ' + uyellow + commastr(roomcost[1]) + config.textcol1 + ' ' + many_money(2));
        menu('(F)irst floor  - ' + uyellow + commastr(roomcost[2]) + config.textcol1);
        menu('(S)econd floor - ' + uyellow + commastr(roomcost[3]) + config.textcol1);
        menu('(T)hird floor  - ' + uyellow + commastr(roomcost[4]) + config.textcol1);
        menu('(A)bort');
        sd(config.textcolor, 'Room:');

        repeat
          ch := upcase(getchar);
        until ch in ['D', 'F', 'S', 'T', 'A'];

        case ch of
          'D': xx := 1;
          'F': xx := 2;
          'S': xx := 3;
          'T': xx := 4;
          'A': d(config.textcolor, 'Maybe later...');
        end; {case .end.}

        if ch <> 'A' then
        begin
          if player.gold < roomcost[xx] then
          begin
            d(global_talkcol, 'Come back when you have the ' + config.moneytype + ', BUM!');
            ch := 'A';
          end;
        end;

        if ch <> 'A' then
        begin
          if confirm('Are you sure that you want the room', 'n') = True then
          begin
            if player.gold >= roomcost[xx] then
            begin

              {first pay for the room}
              decplayermoney(player, roomcost[xx]);

              if confirm('Hire a Doorguard', 'n') = True then
              begin
                cho := '?';

                repeat

                  if cho = '?' then
                  begin
                    clearscreen;
                    crlf;
                    d(5, '-*- Doorguards -*-');
                    crlf;

                    {lets get the doorguards!}
                    x := 1;
                    dgsize := fs(FsGuard);

                    for i := 1 to dgsize do
                    begin
                      load_guard(fload, guard^, i);
                      if i < 10 then
                      begin
                        menu2(ljust('(' + commastr(i) + ') ' + guard^.Name, 20));
                      end else
                      begin
                        menu5(ljust('(' + commastr(i) + ') ' + guard^.Name, 20), 2);
                      end;

                      sd(14, commastr(guard^.cost));
                      d(config.textcolor, ' ' + many_money(guard^.cost));

                      x := x + 1;
                      if x > 15 then
                      begin
                        pause;
                        x := 1;
                      end;
                    end;

                    crlf;
                    sd(config.textcolor, '[');
                    sd(5, Config.ReturnEnter);
                    d(config.textcolor, '] to Abort');
                  end;

                  crlf;
                  sd(config.textcolor, 'Choice :');

                  x := get_number(0, dgsize);

                  if (x < 1) or (x > dgsize) then
                    x := 0;

                  if x <> 0 then
                  begin
                    load_guard(fload, guard^, x);
                    sicken := x;
                    if (guard^.descp[1] + guard^.descp[2] + guard^.descp[3] +
                      guard^.descp[4] + guard^.descp[5] <> '') then
                    begin
                      crlf;
                      for cc := 1 to 5 do
                      begin
                        if guard^.descp[cc] <> '' then
                        begin
                          d(15, guard^.descp[cc]);
                        end;
                      end; {cc:= .end.}
                    end;

                    if confirm('Hire a ' + guard^.Name + ' ', 'N') = True then
                    begin
                      if player.gold < guard^.cost then
                      begin
                        you_cant_afford_it;
                        pause;
                        x := 0;
                        cho := '?';
                      end else
                      begin
                        if (guard^.multiple = True) and (confirm('Hire more than one guard ', 'N') = True) then
                        begin
                          repeat
                            crlf;
                            sd(config.textcolor, 'How many ');
                            sd(5, guard^.Name + 's');
                            d(config.textcolor, ' would you like to hire [1-10] ?');
                            sd(config.textcolor, ':');

                            x := get_number(0, 10);

                            if (x < 1) or (x > 10) then
                            begin
                              x := 0;
                            end else
                            begin
                              j := guard^.cost * x;
                              if j > player.gold then
                              begin
                                you_cant_afford_it;
                                x := 0;
                              end else
                              begin
                                sd(config.textcolor, 'This will cost ');
                                sd(14, commastr(j));
                                if confirm(' ' + many_money(j) + '. Pay ', 'N') = True then
                                begin
                                  crlf;
                                  sd(global_talkcol, 'Give me ' + commastr(x) + ' ' + guard^.Name + 's!');
                                  d(config.textcolor, ' you declare in a loud voice!');
                                  sd(config.textcolor, 'A moment later ');
                                  sd(global_plycol, config.innkeeper);
                                  d(config.textcolor, ' appears with your requested guards.');
                                  d(config.textcolor,
                                    'This might be just what you need... You receive the room key and lock');
                                  d(config.textcolor, 'the door behind you. You fall asleep listening to strange sounds');
                                  d(config.textcolor, 'outside...');
                                  crlf;

                                  {pay}
                                  decplayermoney(player, j);

                                  {set player offline location}
                                  case xx of
                                    1: player.location := offloc_innroom1;
                                    2: player.location := offloc_innroom2;
                                    3: player.location := offloc_innroom3;
                                    4: player.location := offloc_innroom4;
                                  end; {case xx of}

                                       {set player guard flags}
                                  player.bguard := sicken;
                                  player.bguardnr := x;

                                  {news-paper}
                                  new_guest_news;

                                  {exit game}
                                  pause;
                                  normal_exit;

                                end else
                                begin
                                  x := 0;
                                end;
                              end;
                            end;
                          until x > 0;
                        end else
                        begin
                          crlf;
                          sd(global_talkcol, 'Give me a ' + umonc + guard^.Name + utalkc + '!');
                          d(config.textcolor, ' you declare in a loud voice!');
                          sd(config.textcolor, 'A moment later ');
                          sd(global_plycol, config.innkeeper);
                          d(config.textcolor, ' appears with your requested guard.');
                          d(config.textcolor, 'that might be what you need... You receive the room key and lock');
                          d(config.textcolor, 'the door behind you. You fall asleep listening to strange sounds');
                          d(config.textcolor, 'outside the door...');
                          crlf;

                          {pay for guard}
                          decplayermoney(player, guard^.cost);

                          case xx of
                            1: player.location := offloc_innroom1;
                            2: player.location := offloc_innroom2;
                            3: player.location := offloc_innroom3;
                            4: player.location := offloc_innroom4;
                          end;
                          player.bguard := sicken;
                          player.bguardnr := 1;

                          new_guest_news;
                          pause;
                          normal_exit;
                        end;
                      end;
                    end else
                    begin
                      x := 0;
                    end;
                  end else
                  begin
                    if confirm('Abort', 'N') = True then
                    begin
                      {refund the player for the room}
                      incplayermoney(player, roomcost[xx]);

                      cho := 'Q';
                      break;
                    end else
                    begin
                      cho := '?';
                    end;
                  end;
                until (x <> 0) or (cho = 'Q');

              end else
              begin {player didn't want a doorguard}
                crlf;
                sd(config.textcolor, 'You give ');
                sd(global_plycol, config.innkeeper);
                d(config.textcolor, ' the ' + config.moneytype + ' and receive a room key.');
                d(config.textcolor, 'You lock the door behind you, and then fall into a');
                d(config.textcolor, 'deep and dreamless sleep...');
                crlf;

                {pay for room}
                decplayermoney(player, roomcost[xx]);
                case xx of
                  1: player.location := offloc_innroom1;
                  2: player.location := offloc_innroom2;
                  3: player.location := offloc_innroom3;
                  4: player.location := offloc_innroom4;
                end;
                pause;

                {news-paper}
                new_guest_news;

                {exit}
                normal_exit;

              end;
            end else
            begin
              crlf;
              d(config.textcolor, 'But you don''t have the ' + config.moneytype + ' stupid!');
              sd(config.textcolor, 'You have ');
              sd(14, commastr(player.gold));
              sd(config.textcolor, ' ' + many_money(player.gold) + ', but the room costs ');
              sd(14, commastr(x));
              d(config.textcolor, '!');
              crlf;
              pause;
            end;
          end;
        end;
      end;
      'M': begin {Send a Message}
        send_a_letter(False);
      end;
      'R': begin {Return to Main Street}

        crlf;
        dispose(guard);
        dispose(pl0);
        dispose(pl[1]);
        dispose(pl[2]);
        dispose(pl[3]);
        dispose(pl[4]);
        exit;

      end;
      'C': begin {Multinode Chat}

                 {Writing an IPC file}
        Init_Ipc(player);

        {Chat Menu}
        Multi_Chat;

      end;
      'V': begin {View/add to Chatfile}

        crlf;
        if global_ansi then
          display_file(global_innfile1)
        else display_file(global_innfile2);

        crlf;
        set_foreground(2);
        menu2('(A)dd to conversation, ');
        sd(config.textcolor, '[');
        sd(5, Config.ReturnEnter);
        sd(config.textcolor, '] to Continue :');

        {Get User Input}
        repeat
          ch := upcase(getchar);
        until ch in [ReturnKey, 'A'];

        {Evaluate User Input}
        if ch = 'A' then
        begin
          crlf;
          crlf;
          d(10, 'Enter your message  (max ' + commastr(maxlin) + ' lines, BLANK line to end) ');
          d(config.textcolor, '   I' + mkstring(68, underscore) + 'I');

          x := 1;
          for i := 1 to maxlin do
          begin
            mess[i] := '';
          end;

          repeat
            sd(config.textcolor, '[' + commastr(x) + ']:');
            s := mess[x];
            get_stringw(s, 70);

            mess[x] := s;

            {humbug start}
            j := length(mess[x]);
            if (j = len) and (mess[x][j] <> ' ') and (x < maxlin) then
            begin

              {m†ste vi ta med oss sista ordet fr†n f”reg†ende rad?}
              {order f†r inte vara f”r l†ngt (60 tecken). inte hela f”reg†ende rad tex}
              e := '';
              Count := 0;

              {count word length in mtext[line]}
              i := j;
              repeat
                if mess[x][i] <> ' ' then
                begin
                  Inc(Count);
                end else
                begin
                  break;
                end;
                Dec(i);
              until i = 0;

              if Count <= 60 then
              begin
                Count := 0;
                repeat
                  Inc(Count);
                  if mess[x][j] <> ' ' then
                  begin
                    e := mess[x][j] + e;
                  end else
                  begin
                    break;
                  end;
                  Dec(j);
                until j = 0;

                {delete word that is moved down to next line}
                {and remove the string from the current line}

                for j := 1 to length(e) do
                begin
                  sswrite(chr(8));
                  sswrite(' ');
                  sswrite(#8);
                end;

                j := length(mess[x]) - length(e);
                Delete(mess[x], j, length(e) + 1);
                mess[x + 1] := e;
              end;

            end;
            {humbug end}

            if mess[x] <> '' then
            begin
              Inc(x);
            end;
            crlf;
          until (s = '') or (x > maxlin);

          if mess[1] <> '' then
          begin
            crlf;
            if confirm('Say this', 'Y') = True then
            begin
              if confirm('Anonymously', 'N') = True then
              begin
                s := 'Unknown';
              end else
              begin
                s := player.name2;
                if player.king then
                begin
                  if player.sex = 1 then
                    e := ' (the King)'
                  else e := ' (the Queen)';
                  s := s + e;
                end;
              end;

              {writing the player message to the inn chat-file}
              write_to_inn_file(s,
                mess[1],
                mess[2],
                mess[3],
                mess[4],
                mess[5]);

              crlf;
              d(3, 'Message written...');
              crlf;

            end;
          end;
        end;
        crlf;
      end;

    end; {case .end.}

  until never;

end; {The_Inn *end*}

end. {Unit InnC .end.}
