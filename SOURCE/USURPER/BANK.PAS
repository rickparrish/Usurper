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



unit Bank; {Usurper - The Bank}

interface

procedure The_Bank;

implementation

uses
  Init, Cms, Jakob,
  Statusc, Mail, PlvsMon,
  News, CompWar, PlComp,
  Npc_Chec, Various, Various2,
  Various3, Online, File_Io, SysUtils;

var

  i, zz, xx:   longint;

  rr:          real;

  j:           integer;

  sel, guards: byte;

  team, refresh: boolean;

  bankman, ss, a, s, s2: s70;

  {User Records}
  op:          array[1..5] of ^userrec;
  pl:          array[1..4] of ^userrec;
  temp:        ^userrec;


procedure Disposal; {dispose pointer vars}
var i: byte;
begin

  for i := 1 to 5 do
  begin
    dispose(op[i]);
  end;

  for i := 1 to 4 do
  begin
    dispose(pl[i]);
  end;

  dispose(temp);

end; {disposal *end*}

function Fri(target: byte): byte;
var i:   integer;
  match: byte;
begin

  fri := 1;
  match := 0;
  for i := 1 to 5 do
  begin

    if (op[i]^.name2 <> '') or (op[i]^.hps > 0) then
    begin
      Inc(match);
      if match = target then
      begin
        fri := i;
        break;
      end;
    end;

  end; {for i:= .end.}

end; {fri *end*}

procedure Withdraw_Money;
begin

  if player.bankgold <= 0 then
  begin
    crlf;
    crlf;
    d(12, 'Your account is empty!');
  end else
  begin
    crlf;
    crlf;

    d(config.textcolor, 'The ' + uplc + 'gnome' + config.textcol1 + ' looks disappointed...');
    if player.sex = 1 then d(global_talkcol, 'How much would you like to withdraw, sir?')
    else d(global_talkcol, 'How much would you like to withdraw, madam?');

    crlf;
    sd(config.textcolor, '(max ');
    rr := player.bankgold + 0.0;
    rr := rr + player.gold;
    if rr > 2000000000 then
    begin
      rr := 2000000000 - player.gold;
    end else
    begin
      rr := player.bankgold + 0.0;
    end;
    xx := round(rr);

    sd(14, commastr(xx));
    d(config.textcolor, numeric_help);
    sd(config.textcolor, ':');
    zz := get_number(0, xx);

    if zz = 0 then
    begin
      d(11, 'Dummy! Get real!');
    end else if (zz <= player.bankgold) and (zz > 0) then
    begin
      rr := zz + 0.0;
      rr := rr + player.gold;
      if rr > 2000000000 then
      begin
        rr := 2000000000 - player.gold;
        if zz >= rr then
        begin
          xx := round(rr);
          sd(config.textcolor, 'You withdrew ');
          sd(14, commastr(xx));

          sd(config.textcolor, ' ' + many_money(xx));

          crlf;
          decbankmoney(player, xx);
          incplayermoney(player, xx);
        end;
      end else
      begin
        xx := round(zz);
        crlf;
        sd(config.textcolor, 'You withdrew ');
        sd(14, commastr(xx));

        sd(config.textcolor, ' ' + many_money(xx));

        crlf;
        decbankmoney(player, xx);
        incplayermoney(player, xx);
      end;
    end;
  end;

end; {Withdraw_Money *end*}

procedure Deposit_Money;
begin

  if player.gold <= 0 then
  begin
    crlf;
    crlf;
    d(12, 'You have no ' + config.moneytype + '!');
  end else
  begin
    crlf;
    crlf;
    d(config.textcolor, 'The ' + uplc + 'gnome' + config.textcol1 + ' gets a greedy look in his eyes.');

    if player.sex = 1 then d(global_talkcol, 'How much would you like to deposit, sir?')
    else d(global_talkcol, 'How much would you like to deposit, madam?');
    crlf;

    {deposit some money}
    sd(config.textcolor, '(max ');

    rr := player.gold + 0.0;
    rr := rr + player.bankgold;
    if rr > 2000000000 then
    begin
      rr := 2000000000 - player.bankgold;
    end else
    begin
      rr := player.gold + 0.0;
    end;
    xx := round(rr);

    sd(14, commastr(xx));
    d(config.textcolor, numeric_help);
    sd(config.textcolor, ':');

    {get user-input}
    zz := get_number(0, xx);

    if zz = 0 then
    begin
      d(11, 'Squid-brain.');
    end else if (zz <= player.gold) and (zz > 0) then
    begin
      rr := zz + 0.0;
      rr := rr + player.bankgold;
      if rr > 2000000000 then
      begin
        rr := 2000000000 - player.bankgold;
        if zz >= rr then
        begin
          xx := round(rr);
          sd(config.textcolor, 'You deposited ');
          sd(14, commastr(xx));

          sd(config.textcolor, ' ' + many_money(xx));

          crlf;
          incbankmoney(player, xx);
          decplayermoney(player, xx);
        end;
      end else
      begin
        xx := round(zz);
        crlf;
        sd(config.textcolor, 'You deposited ');
        sd(14, commastr(xx));

        sd(config.textcolor, ' ' + many_money(xx));

        crlf;
        incbankmoney(player, xx);
        decplayermoney(player, xx);
      end;
    end;
  end;

end; {deposit_money *end*}

procedure Outburst(who: s70);
begin

  sd(global_plycol, who);
  d(config.textcolor, ' has arrived to protect the Bank!');

  case random(7) of
    0: d(global_talkcol, '"You won''t get away with this!"');
    1: d(global_talkcol, '"Robbers! Robbers! Robbers! GET THEM!"');
    2: d(global_talkcol, '"ATTACK!!"');
    3: d(global_talkcol, '"I''M PAID TO DEAL WITH TRASH LIKE YOU!"');
    4: d(global_talkcol, '"A VERY BIG MISTAKE TO HOLD UP THIS BANK KID!"');
    5: d(global_talkcol, '"YOU WILL BE SORRY FOR THIS!"');
    6: d(global_talkcol, '"GIVE UP OR PERISH!"');
  end; {case .end.}

end; {outburst *end*}

procedure Load_PlayerGuards;
var
  i:  longint;
  f:  integer;
  ok: boolean;

begin

  f := 1;
  for i := 1 to 5 do
  begin
    op[i]^.name2 := emptystr;
    op[i]^.hps := 0;
  end;

  for i := 1 to fs(FsPlayer) do
  begin

    load_character(temp^, 1, i);

    if (temp^.name2 <> player.name2) and
      (is_online(temp^.name2, online_player) = False) and
      (temp^.bankguard = True) and
      (temp^.hps > 0) then
    begin

      ok := True;
      if temp^.team <> '' then
      begin
        if temp^.team = player.team then
        begin
          ok := False;
        end;
      end;

      if ok then
      begin
        outburst(temp^.name2);
        add_shadow(SAdd, temp^, player.name2, 'fighting bank robbers!', 0);
        op[f]^ := temp^;
        Inc(f);
        if f = 6 then
        begin
          break;
        end;
      end;

    end;
  end; {for i:= .end.}

  {look among the NPCs}
  if f < 6 then
  begin
    for i := 1 to fs(FsNpc) do
    begin
      load_character(temp^, 2, i);
      if (temp^.name2 <> player.name2) and
        (temp^.team = player.team) and
        (is_online(temp^.name2, online_player) = False) and
        (temp^.bankguard = False) and
        (temp^.hps > 0) then
      begin

        outburst(temp^.name2);
        add_shadow(SAdd, temp^, player.name2, 'fighting bank robbers!', 0);
        op[f]^ := temp^;
        Inc(f);
        if f = 6 then
        begin
          break;
        end;

      end;
    end; {for i:= .end.}
  end;

end; {Load_PlayerGuards *end*}

procedure Meny;
const offset = 20;
var a2: s90;
begin

  a2 := 'Bank of Wealth, managed by ' + bankman + ' the Gnome';

  clearscreen;
  crlf;
  d(5, a2);
  d(5, mkstring(length(a2), underscore));
  crlf;
  d(config.textcolor, 'You enter the bank, which resides in the finer areas of');
  d(config.textcolor, 'the town. A huge safe is located at the back of the room.');
  d(config.textcolor, 'You can also see some guards posted around the place.');
  d(config.textcolor, 'An old gnome appears and asks you of your business.');
  crlf;
  d(config.textcolor, config.moneytype + ' on hand .. ' + uyellow + commastr(player.gold) + config.textcol1 + ' ' + many_money(player.gold) + '.');
  d(config.textcolor, config.moneytype + ' in bank .. ' + uyellow + commastr(player.bankgold) + config.textcol1 + ' ' + many_money(player.bankgold) + '.');
  crlf;

  menu2(ljust('(D)eposit ' + config.moneytype, offset));
  menu('(P)ut ' + config.moneytype + ' on other players account');

  menu2(ljust('(W)ithdraw', offset));
  menu('(T)his is a robbery');

  menu2(ljust('(S)tatus', offset));
  menu('(A)pply for Guard duty');

  menu2(ljust('(R)eturn', offset));
  menu('(*) resign from guard duty');

end; {meny *end*}

procedure Display_Menu(force, short: boolean);
begin

 {sethotkeys_on(NoKill,['D',
                       'W',
                       'S',
                       'R',
                       'P',
                       'A',
                       '*',
                       'T',
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
      sd(config.textcolor, 'The Bank (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');
    end else
    begin
      crlf;
      sd(config.textcolor, 'Bank (D,W,T,P,A,*,S,R,?) :');
    end;
  end else
  begin
    if (player.expert = False) or (force = True) then
    begin
      meny;
    end;
  end;
end; {display_menu *end*}

procedure The_Bank;
var

  vic1, vic2, vic3: integer;

  ch:    char;

  ledig: array[1..5] of boolean;

  adios, battle_over, no_robbery: boolean;

  safet: saferec; {BankSafe record}
  gubbe: onlinerec; {onlinerecord}

begin

  {init pointer vars}
  for i := 1 to 5 do
  begin
    new(op[i]);
    op[i]^.name1 := emptystr;
    op[i]^.name2 := emptystr;
  end;

  for i := 1 to 4 do
  begin
    new(pl[i]);
    pl[i]^.name1 := emptystr;
    pl[i]^.name2 := emptystr;
  end;

  new(temp);

  adios := False;
  {fetch Lobbas name from USURPER.CFG, #19}
  bankman := cfg_string(19);
  if bankman = '' then
  begin
    bankman := 'Lobba';
  end;

  {main-loop}
  repeat

    if onliner.location <> onloc_bank then
    begin
      refresh := True;
      onliner.location := onloc_bank;
      onliner.doing := location_desc(onliner.location);
      add_onliner(OUpdateLocation, onliner);
    end;

    {display menu}
    display_menu(True, True);

    {get user-input}
    ch := upcase(getchar);

    {evaluate user-input}
    case ch of
      '?': begin {display menu}
        if player.expert = True then display_menu(True, False)
        else display_menu(False, False);
      end;
      'S': begin {status}
        clearscreen;
        status(player);
      end;
      'R': begin {return}
        adios := True;
        crlf;
      end;
      '*': begin {resign from guard duty}
        crlf;
        crlf;
        if player.bankguard = False then
        begin
          d(config.textcolor, 'You are not employed here!');
          d(config.textcolor, 'There is nothing to resign from!');
          crlf;
          pause;
        end else
        begin
          d(5, 'Resign?');
          if confirm('Would you like to quit your bank job ', 'N') then
          begin
            {news-paper}
            newsy(True,
              'Resignation',
              ' ' + uplc + player.name2 + config.textcol1 + ' has left ' + sex3[player.sex] + ' job at the bank.',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');

            player.bankguard := False;
            crlf;
            d(15, 'OK.');
            d(config.textcolor, 'You are now free from your obligations at the bank.');
            d(config.textcolor, 'Good luck! (and don''t try to rob us).');
            crlf;
            pause;
          end else
          begin
            d(config.textcolor, 'OK. Stay alive and be prepared to fight');
            d(config.textcolor, 'the bad guys.');
            crlf;
            pause;
          end;
        end;
      end;

      'A': begin {apply for guard duty}
        if global_registered = False then
        begin
          crlf;
          only_in_registered_version;
        end else
        begin
          if player.bankguard then
          begin
            crlf;
            d(15, 'You are already signed up as guard!');
          end else
          begin
            xx := player.level * 1000;
            zz := player.strength * 9;
            Inc(xx, zz);

            crlf;
            crlf;
            d(5, 'Becoming a Bank guard');
            d(5, '*-*-*-*-*-*-*-*-*-*-*');
            d(config.textcolor, 'As guard you will get paid according to your combat status.');
            d(config.textcolor, 'The stronger and better equipped you are, the more the bank');
            d(config.textcolor, 'will pay you.');
            sd(config.textcolor, 'With your current status we would pay you : ');
            sd(14, commastr(xx));
            d(config.textcolor, ' ' + many_money(xx));

            d(config.textcolor, 'As you raise your abilities, so will your pay cheque.');

            crlf;
            pause;
            crlf;

            d(config.textcolor, 'As this is a respectable bank we can''t tolerate any');
            d(config.textcolor, 'riff raff hanging around the premises.');
            d(config.textcolor, 'We look for noble and good characters only.');

            if player.dark > 0 then
            begin
              {a suspect character! throw him out!}
              d(config.textcolor, 'And according to our records, you appear to be a');
              d(config.textcolor, 'rather suspicious character!');
              d(config.textcolor, 'We want people with clean reputations! You are not qualified!');
              d(config.textcolor, 'Get out of here!');
              crlf;
              pause;

            end else
            begin
              {at last a good person!}
              d(config.textcolor, 'And according to our records, you appear to be a');
              d(config.textcolor, 'trustworthy character.');
              crlf;
              if confirm('Would you like to come work for us ', 'N') = True then
              begin
                player.bankguard := True;
                crlf;
                d(15, 'Great!');
                d(config.textcolor, 'You will be called upon whenever the bank is in trouble.');
                d(config.textcolor, 'Your salary will be transfered to your account on a daily basis.');
                d(config.textcolor, 'Try to stay alive and keep your weapons ready!');
                d(config.textcolor, 'Good luck!');
                crlf;
                pause;

                crlf;
                d(5, 'Go public?');
                d(config.textcolor, 'The bank management is anxious to scare the');
                d(config.textcolor, 'criminal elements from robbing the bank.');
                d(config.textcolor, 'They bank would therefore appreciate if you would');
                d(config.textcolor, 'let them announce your employment.');
                crlf;

                if confirm('Go public with this ', 'Y') = True then
                begin
                  crlf;
                  d(15, 'Good!');

                  {news-paper}
                  newsy(True,
                    'Town Bank hires help',
                    ' ' + uplc + player.name2 + config.textcol1 + ' has been hired to prevent crime.',
                    ' Citizens are at any time welcome to apply for guard duty.',
                    ' Help us to keep the scum off the streets!',
                    '',
                    '',
                    '',
                    '',
                    '',
                    '');
                  d(config.textcolor, 'It was a wise decision. You won''t regret it!');
                  d(config.textcolor, 'Crime reduction is a vital step for building a');
                  d(config.textcolor, 'healthy society.');
                  d(config.textcolor, 'Good luck with your new job!');
                  crlf;
                end else
                begin
                  crlf;
                  d(15, 'Too bad!');
                  d(config.textcolor, 'The bank management would like to wish you good luck');
                  d(config.textcolor, 'on your mission to protect the citizens savings.');
                  crlf;
                  pause;
                end;
              end else
              begin
                crlf;
                d(config.textcolor, 'Too bad. Goodbye!.');
                crlf;
              end;
            end;

          end;
        end;
      end;

      'T': begin {Robbery!}

        for i := 1 to 5 do
        begin
          op[i]^.name2 := emptystr;
          op[i]^.hps := 0;
        end;

        vic1 := 0;
        vic2 := 0;
        vic3 := 0;

        if global_registered = False then
        begin
          crlf;
          Only_In_Registered_Version;
        end else
        begin

          crlf;
          {if player is a bankguard he is not allowed to rob the bank}
          if player.bankguard then
          begin
            crlf;
            sd(15, 'WARNING! ');
            d(config.textcolor, 'You are signed up as a guard in the bank.');
            if confirm('Do you dare to break your contract ', 'N') = True then
            begin
              player.bankguard := False;
            end else
            begin
              crlf;
              d(config.textcolor, 'I think that was a wise decision...');
            end;
          end;

          if player.bankguard = False then
          begin

            {bank is perhaps already being robbed?}
            no_robbery := False;
            for i := 1 to fs(FsOnline) do
            begin
              load_onliner(fload, gubbe, i);
              if gubbe.location = onloc_robbingbank then
              begin
                crlf;
                d(15, 'The bank is already being robbed!');
                no_robbery := True;
                break;
              end;
            end; {for i:= .end.}

            {not robbery attempts left?}
            if player.bankrobberyattempts < 1 then
            begin
              d(12, 'You have exhausted your robbery attempts for today!');
              pause;
              no_robbery := True;
            end;

            if no_robbery = False then
            begin
              crlf;
              crlf;
              {has to check out the safe and count the number of bankguards}
              if f_exists(global_saffile) = False then
              begin
                safe_reset;
              end;

              load_safe(Fload, Safet);

              guards := 2;
              if safet.Value > 50000 then Inc(guards, 2);
              if safet.Value > 100000 then Inc(guards, 2);
              if safet.Value > 250000 then Inc(guards, 2);
              if safet.Value > 500000 then Inc(guards, 2);
              if safet.Value > 750000 then Inc(guards, 2);
              if safet.Value > 1000000 then Inc(guards, 2);

              if guards > global_maxmon then guards := global_maxmon;

              sd(config.textcolor, 'Safe contains    : ');
              sd(14, commastr(safet.Value));

              d(config.textcolor, ' ' + many_money(safet.Value));

              sd(config.textcolor, 'Guards to fight  : ');
              sd(15, commastr(guards));
              d(config.textcolor, ' (could be some dogs too)');
              sd(config.textcolor, 'Players to fight : ');
              d(5, '*unknown*');
              crlf;
              pause;

              reset_monsters;
              for i := 1 to global_maxspells do
              begin
                player.spell[i, 2] := False;
              end;

              global_begged := False;
              global_nobeg := True;

              i := 1;
              repeat
                if i = 1 then
                begin
                  create_monster(i,             {#}
                    'Captain of the Guard', {name}
                    75,            {hps}
                    25,            {strength}
                    {15} 0,            {defence}
                    'Stop!',       {phrase}
                    False,         {grabweap}
                    False,         {grabarm}
                    'Broadsword',  {weapon-string}
                    'Chainmail',   {armor-string}
                    False,         {poisoned-should be false}
                    False,         {disease -should be false}
                    75,            {punch}
                    15,            {armpow}
                    25);           {weappow}

                end else
                begin
                  create_monster(i,             {#}
                    'Guard',       {name}
                    50,            {hps}
                    20,            {strength}
                    {10} 0,            {defence}
                    'Robbery',     {phrase}
                    False,         {grabweap}
                    False,         {grabarm}
                    'Halberd',     {weapon-string}
                    'Ringmail',    {armor-string}
                    False,         {poisoned-should be false}
                    False,         {disease -should be false}
                    50,            {punch}
                    10,            {armpow}
                    15);            {weappow}

                end;

                Inc(i);
              until i > guards;

              if (guards < global_maxmon) and (random(2) = 0) then
              begin
                {bring in a Pitbull, haha!}
                Inc(guards);

                create_monster(guards,         {#}
                  'Pitbull',     {name}
                  95,            {hps}
                  40,            {strength}
                  {20} 0,            {defence}
                  'Grrrr..',     {phrase}
                  False,         {grabweap}
                  False,         {grabarm}
                  'Jaws',        {weapon-string}
                  'skin',        {armor-string}
                  False,         {poisoned-should be false}
                  False,         {disease -should be false}
                  80,            {punch}
                  7,             {armpow}
                  45);           {weappow}

              end;

              vic1 := guards;

              ch := '?';
              repeat
                case ch of
                  'I': begin
                    crlf;
                    d(config.textcolor, 'You discretely inspect the guards...');
                    for i := 1 to guards do
                    begin
                      sd(11, monster[i]^.Name);
                      if monster[i]^.weapon <> '' then
                      begin
                        sd(5, ' (' + monster[i]^.weapon);
                      end;
                      if monster[i]^.armor <> '' then
                      begin
                        sd(5, ' - ' + monster[i]^.armor + ') ');
                      end;
                      crlf;
                    end;
                    pause;
                  end;
                  '?': begin
                    crlf;
                    crlf;
                    menu('(R)ob!  (all your chivalry will be gone!)');
                    menu('(I)nspect guards');
                    menu('(A)bort');
                  end;

                end; {case .end.}
                crlf;

                sd(config.textcolor, 'Bank robbery (' + config.textcol2 + '?' + config.textcol1 + ' for menu) :');

                {get user-input}
                ch := upcase(getchar);

                team := False;
                if ch = 'R' then
                begin
                  crlf;
                  if confirm('Rob the Bank ', 'N') = False then
                  begin
                    ch := ' ';
                  end else
                  begin
                    if player.team <> '' then
                    begin
                      if confirm('Bring the team with you ', 'Y') = True then
                      begin
                        team := True;
                      end;
                    end;
                  end;
                end;

                if ch = 'A' then
                begin
                  crlf;
                  if confirm('Chicken out', 'Y') = False then
                  begin
                    ch := ' ';
                  end;
                end;
              until ch in ['R', 'A'];

              crlf;
              crlf;
              case ch of
                'R': begin {** Robbery **}
                  for i := 1 to 4 do
                  begin
                    pl[i]^.name1 := emptystr;
                    pl[i]^.name2 := emptystr;
                  end;

                  player.chiv := 0;
                  give_darkness(player, 50);
                  Dec(player.bankrobberyattempts);

                  {update player location & doing}
                  onliner.doing := 'robbing the Bank!';
                  onliner.location := onloc_robbingbank;
                  add_onliner(OUpdateLocation, onliner);

                  {check for player team-mates, and fetch them}
                  xx := 0;
                  if team then
                  begin
                    for i := 1 to fs(FsPlayer) do
                    begin
                      load_character(temp^, 1, i);
                      if (temp^.name2 <> player.name2) and
                        (temp^.team = player.team) and
                        (is_online(temp^.name2, online_player) = False) and
                        (temp^.bankguard = False) and
                        (temp^.hps > 0) then
                      begin

                        if temp^.dark < 1000 then
                        begin

                          sd(global_plycol, temp^.name2);
                          d(config.textcolor, ' refuses to join you!');

                          post(MailSend,
                            temp^.name2,
                            temp^.ai,
                            False,
                            mailrequest_nothing,
                            '',
                            umailheadc + 'Bank Job' + config.textcol1,
                            mkstring(8, underscore),
                            'You refused to follow ' + uplc + player.name2 + config.textcol1 + ' on a bank job.',
                            'You follow your virtues. You are a good citizen.',
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
                        end else
                        begin

                          sd(global_plycol, temp^.name2);
                          d(config.textcolor, ' has arrived.');

                          post(MailSend,
                            temp^.name2,
                            temp^.ai,
                            False,
                            mailrequest_nothing,
                            '',
                            umailheadc + 'Bank Job' + config.textcol1,
                            mkstring(8, underscore),
                            uplc + player.name2 + config.textcol1 + ' brought you along for a bank robbery.',
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

                          Inc(xx);
                          pl[xx]^ := temp^;
                          add_shadow(SAdd, pl[xx]^, player.name2, 'robbing the Bank!', 0);
                        end;
                      end;
                    end;

                    {look for team-mates among the NPCs}
                    for i := 1 to fs(FsNpc) do
                    begin

                      load_character(temp^, 2, i);

                      if (temp^.name2 <> player.name2) and
                        (temp^.team = player.team) and
                        (is_online(temp^.name2, online_player) = False) and
                        (temp^.bankguard = False) and
                        (temp^.hps > 0) then
                      begin
                        sd(global_plycol, temp^.name2);
                        d(config.textcolor, ' has arrived.');
                        Inc(xx);
                        pl[xx]^ := temp^;
                        add_shadow(SAdd, pl[xx]^, player.name2, 'robbing the Bank!', 0);
                      end;
                    end;
                  end;

                  if team = True then
                  begin
                    {news-paper}
                    newsy(True,
                      'Bank Robbery!',
                      utec + ' ' + player.team + config.textcol1 + ' attempted to rob the Bank!',
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
                    {news-paper}
                    newsy(True,
                      'Bank Robbery!',
                      uplc + ' ' + player.name2 + config.textcol1 + ' attempted to rob the Bank!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');
                  end;

                  if team then d(global_talkcol, 'GIVE US THE ' + UpperCase(config.moneytype) + ' OR DIE!')
                  else d(global_talkcol, 'GIVE ME THE ' + UpperCase(config.moneytype) + ' OR DIE!');


                  crlf;
                  d(5, 'The guards rush toward you!');
                  d(5, 'Prepare to fight!');
                  pause;
                  crlf;

                  {The Fight!}
                  Player_vs_Monsters(5, pl[1]^, pl[2]^, pl[3]^, pl[4]^);

                  {send a letter to the deceased}
                  for i := 1 to 4 do
                  begin
                    if (pl[i]^.name2 <> '') and (pl[i]^.hps < 1) then
                    begin

                      post(MailSend,
                        pl[i]^.name2,
                        pl[i]^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        umailheadc + 'Your Death' + config.textcol1,
                        mkstring(10, underscore),
                        'You were killed when trying to rob the bank.',
                        'A guard killed you.',
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

                    end else if (pl[i]^.name2 <> '') and (pl[i]^.hps > 0) then
                    begin

                      post(MailSend,
                        pl[i]^.name2,
                        pl[i]^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        umailheadc + 'Escape!' + config.textcol1,
                        mkstring(7, underscore),
                        uplc + player.name2 + config.textcol1 + ' was killed in the attempt to rob the bank.',
                        'You managed to get away!',
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

                  if player.hps < 1 then
                  begin

                    a := emptystr;
                    s := emptystr;
                    ss := emptystr;
                    s2 := emptystr;

                    if pl[1]^.name2 <> '' then a := '  ' + pl[1]^.name2;
                    if pl[2]^.name2 <> '' then s := '  ' + pl[2]^.name2;
                    if pl[3]^.name2 <> '' then ss := '  ' + pl[3]^.name2;
                    if pl[4]^.name2 <> '' then s2 := '  ' + pl[4]^.name2;

                    {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);

                    {news-paper}
                    newsy(True,
                      'Killings in the Bank!',
                      ' The guards eliminated the robbers!',
                      ' Deceased robbers :',
                      uplc + '  ' + player.name2,
                      a,
                      s,
                      ss,
                      s2 + config.textcol1,
                      '',
                      '');

                    crlf;
                    d(config.textcolor, 'You LOST ' + player.name2 + '!');
                    d(config.textcolor, 'This robbery was a miserable failure!');
                    d(config.textcolor, 'May your soul burn in hell.');
                    crlf;

                    {save team-mates to disk}
                    for i := 1 to 4 do
                    begin
                      if pl[i]^.name2 <> '' then
                      begin
                        user_save(pl[i]^);
                      end;
                    end; {for i:= .end.}

                    {remove pointer variables}
                    disposal;
                    pause;
                    normal_exit;
                  end;

                  crlf;
                  sd(config.textcolor, 'Well done ');
                  sd(global_plycol, player.name2);
                  d(config.textcolor, '!');
                  crlf;
                  pause;

                 {ok, the guards are defeated...but there might be player
                  guards as well!}

                  battle_over := False;
                  repeat

                    if op[1]^.hps + op[2]^.hps + op[3]^.hps +
                    op[4]^.hps + op[5]^.hps < 1 then
                    begin
                      load_playerguards;
                    end;

                    if op[1]^.name2 = '' then
                    begin
                      {no opposition found}
                      battle_over := True;
                    end else
                    begin

                      {fighting the player guards!}

                      {player versus op1}

                      d(config.textcolor, 'Pick guard to fight :');
                      for i := 1 to 5 do
                      begin
                        if (op[i]^.name2 <> '') and (op[i]^.hps > 0) then
                        begin
                          menu('[' + commastr(i) + '] ' + op[i]^.name2 + ' (' + commastr(op[i]^.hps) + ' hps)');
                        end;
                      end;
                      sd(config.textcolor, ':');

                      repeat
                        ch := upcase(getchar);
                        case ch of
                          '1': if (op[fri(1)]^.name2 = '') or (op[fri(1)]^.hps < 1) then ch := ' ';
                          '2': if (op[fri(2)]^.name2 = '') or (op[fri(2)]^.hps < 1) then ch := ' ';
                          '3': if (op[fri(3)]^.name2 = '') or (op[fri(3)]^.hps < 1) then ch := ' ';
                          '4': if (op[fri(4)]^.name2 = '') or (op[fri(4)]^.hps < 1) then ch := ' ';
                          '5': if (op[fri(5)]^.name2 = '') or (op[fri(5)]^.hps < 1) then ch := ' ';
                        end;
                      until ch in ['1', '2', '3', '4', '5'];

                      case ch of
                        '1': sel := fri(1);
                        '2': sel := fri(2);
                        '3': sel := fri(3);
                        '4': sel := fri(4);
                        '5': sel := fri(5);
                      end;
                      d(global_plycol, op[sel]^.name2);

                      check_inventory(op[sel]^, 0, weapon, False, 0);

                      to_death := False; {must be set to false before fight}
                      repeat
                        player_computer(player, op[sel]^, False, 3);
                      until (player.hps < 1) or (op[sel]^.hps < 1);

                      if (player.hps < 1) and (op[sel]^.hps < 1) then
                      begin
                        newsy(True,
                          'Killings in the Bank!',
                          ' ' + uplc + player.name2 + config.textcol1 + ' and ' + uplc + op[sel]^.name2 + config.textcol1 + ' killed each other!',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '');
                      end else if player.hps < 1 then
                      begin
                        newsy(True,
                          'Killings in the Bank!',
                          ' ' + uplc + player.name2 + config.textcol1 + ' was killed by ' + uplc + op[sel]^.name2 + config.textcol1 + ' (guard)',
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
                        newsy(True,
                          'Killings in the Bank!',
                          uplc + ' ' + op[sel]^.name2 + config.textcol1 + ' (guard) was killed by ' + uplc + player.name2 + config.textcol1,
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '',
                          '');
                        Inc(vic2);
                      end;

                      if temp^.ai = 'H' then
                      begin
                        {robbers result}
                        if op[sel]^.hps < 1 then
                        begin
                          post(MailSend,
                            op[sel]^.name2,
                            op[sel]^.ai,
                            False,
                            mailrequest_nothing,
                            '',
                            umailheadc + 'Defending the Bank' + config.textcol1,
                            mkstring(18, underscore),
                            'You were killed by ' + uplc + player.name2 + config.textcol1 + ' the bankrobber.',
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
                        end else
                        begin
                          post(MailSend,
                            op[sel]^.name2,
                            op[sel]^.ai,
                            False,
                            mailrequest_nothing,
                            '',
                            umailheadc + 'Defending the Bank' + config.textcol1,
                            mkstring(18, underscore),
                            'You killed the gang leader : ' + uplc + player.name2 + config.textcol1 + '!',
                            'WELL DONE!',
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

                      user_save(op[sel]^);
                      add_shadow(SRemove, op[sel]^, player.name2, '', 0);

                      {team-mates engaging in combat}
                      for i := 1 to 5 do
                      begin
                        ledig[i] := True;
                      end;

                      for i := 1 to 4 do
                      begin
                        sel := 0;
                        if (pl[i]^.name2 <> '') and (pl[i]^.hps > 0) then
                        begin
                          for j := 1 to 5 do
                          begin
                            if (op[j]^.name2 <> '') and (op[j]^.hps > 0) and
                              (ledig[j]) then
                            begin
                              ledig[j] := False;
                              sel := j;
                              break;
                            end;
                          end;

                          if sel > 0 then
                          begin
                            {opponent found!}
                            sd(5, pl[i]^.name2);
                            sd(config.textcolor, ' and ');
                            sd(5, op[sel]^.name2);
                            d(config.textcolor, ' engage in combat!');

                            repeat
                              computer_computer(False, True, pl[i]^, op[sel]^);
                            until (pl[i]^.hps < 1) or (op[sel]^.hps < 1);

                            if (pl[i]^.hps < 1) and (op[sel]^.hps < 1) then
                            begin
                              newsy(True,
                                'Killings in the Bank!',
                                ' ' + uplc + pl[i]^.name2 + config.textcol1 + ' and ' + uplc + op[sel]^.name2 + config.textcol1 + ' killed each other!',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '');
                              Inc(vic2);
                              Inc(vic3);

                            end else if pl[i]^.hps < 1 then
                            begin
                              newsy(True,
                                'Killings in the Bank!',
                                uplc + ' ' + pl[i]^.name2 + config.textcol1 + ' was killed by ' + uplc + op[sel]^.name2 + config.textcol1 + ' (guard)',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '');
                              Inc(vic3);
                            end else
                            begin
                              newsy(True,
                                'Killings in the Bank!',
                                uplc + ' ' + op[sel]^.name2 + config.textcol1 + ' (guard) was killed by ' + uplc + pl[i]^.name2 + config.textcol1,
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '',
                                '');
                              Inc(vic2);
                            end;

                            if pl[i]^.ai = 'H' then
                            begin
                              {robbers result}
                              if pl[i]^.hps < 1 then
                              begin
                                post(MailSend,
                                  pl[i]^.name2,
                                  pl[i]^.ai,
                                  False,
                                  mailrequest_nothing,
                                  '',
                                  umailheadc + 'While robbing the Bank' + config.textcol1,
                                  mkstring(22, underscore),
                                  'You were killed by ' + uplc + op[sel]^.name2 + config.textcol1 + ' (bankguard)',
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
                              end else
                              begin
                                post(MailSend,
                                  pl[i]^.name2,
                                  pl[i]^.ai,
                                  False,
                                  mailrequest_nothing,
                                  '',
                                  umailheadc + 'While robbing the Bank' + config.textcol1,
                                  mkstring(22, underscore),
                                  'You killed ' + uplc + op[sel]^.name2 + config.textcol1 + ' (bankguard).',
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
                            end;

                            if op[sel]^.ai = 'H' then
                            begin
                              {robbers result}
                              if op[sel]^.hps < 1 then
                              begin
                                post(MailSend,
                                  op[sel]^.name2,
                                  op[sel]^.ai,
                                  False,
                                  mailrequest_nothing,
                                  '',
                                  umailheadc + 'While defending the Bank' + config.textcol1,
                                  mkstring(22, underscore),
                                  'You were killed by ' + uplc + pl[i]^.name2 + config.textcol1,
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
                              end else
                              begin
                                post(MailSend,
                                  op[sel]^.name2,
                                  op[sel]^.ai,
                                  False,
                                  mailrequest_nothing,
                                  '',
                                  umailheadc + 'While defending the Bank' + config.textcol1,
                                  mkstring(22, underscore),
                                  'You killed ' + uplc + pl[i]^.name2 + config.textcol1 + '!',
                                  'Well done!',
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

                            user_save(op[sel]^);
                            user_save(pl[i]^);
                            add_shadow(SRemove, op[sel]^, player.name2, '', 0);

                          end;
                        end;
                      end;

                      if player.hps < 1 then
                      begin
                        battle_over := True;
                      end;

                    end;

                  until battle_over;


                  {FAILURE!}
                  if player.hps < 1 then
                  begin

                    {player.allowed:=false;}
                    Reduce_Player_Resurrections(player, True);

                    {news-paper}
                    newsy(True,
                      'Killings in the Bank!',
                      ' Player guards eliminated the robbers!',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '');

                    crlf;
                    d(config.textcolor, 'You LOST! ' + player.name2);
                    d(config.textcolor, 'This robbery was a miserable failure!');
                    d(config.textcolor, 'May your soul burn in hell...');
                    crlf;

                    {save team-mates}
                    for i := 1 to 4 do
                    begin
                      if pl[i]^.name2 <> '' then
                      begin
                        user_save(pl[i]^);
                      end;
                    end; {for i:= .end.}

                    pause;
                    disposal;
                    normal_exit;
                  end;

                  {combat ends and attackers won!}

                  crlf;
                  d(15, 'Successful Robbery!');
                  sd(config.textcolor, 'Well done ');
                  sd(5, player.name2);
                  d(config.textcolor, '.');
                  crlf;
                  pause;

                  {lets grab the money in the safe!}
                  i := 1;
                  if (pl[1]^.name2 <> '') and (pl[1]^.hps > 0) then Inc(i);
                  if (pl[2]^.name2 <> '') and (pl[2]^.hps > 0) then Inc(i);
                  if (pl[3]^.name2 <> '') and (pl[3]^.hps > 0) then Inc(i);
                  if (pl[4]^.name2 <> '') and (pl[4]^.hps > 0) then Inc(i);

                  if safet.Value >= 5 then
                  begin
                    xx := safet.Value div i;
                  end else
                  begin
                    xx := 1;
                  end;

                  sd(config.textcolor, 'Your share is ');
                  sd(14, commastr(xx));

                  d(config.textcolor, ' ' + many_money(xx));

                  incplayermoney(player, xx);

                  for i := 1 to 4 do
                  begin

                    if (pl[i]^.name2 <> '') and (pl[i]^.hps > 0) then
                    begin

                      sd(global_plycol, pl[i]^.name2 + 's');
                      sd(config.textcolor, ' share is ');
                      sd(14, commastr(xx));

                      d(config.textcolor, ' ' + many_money(xx));

                      incplayermoney(pl[i]^, xx);
                      user_save(pl[i]^);

                      {inform offline player}
                      post(MailSend,
                        pl[i]^.name2,
                        pl[i]^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        umailheadc + 'Successful Robbery!' + config.textcol1,
                        mkstring(19, underscore),
                        'Your share of the loot was ' + uyellow + commastr(xx) + config.textcol1 + ' ' + many_money(xx) + '!',
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
                  end; {for i:= .end.}

                  {reset bank safe value}
                  safet.Value := 0;

                  load_safe(FSave, Safet);

                  {news-paper}
                  newsy(True,
                    'The Bank has been Robbed!',
                    ' ' + uplc + player.name2 + config.textcol1 + ' got away with the loot!',
                    ' ' + uplc + player.name2 + config.textcol1 + ' is wanted DEAD OR ALIVE!',
                    ' ',
                    ' Killed in action :',
                    '  Guards        : ' + ulgray + commastr(vic1) + config.textcol1,
                    '  Player guards : ' + ulgray + commastr(vic2) + config.textcol1,
                    '  Robbers       : ' + ulgray + commastr(vic3) + config.textcol1,
                    '',
                    '');

                  crlf;
                  d(config.textcolor, 'You better hide yourself tonight.');
                  d(config.textcolor, 'Mercenaries and bounty hunters may come looking');
                  d(config.textcolor, 'for you soon...');
                  crlf;
                  pause;

                  {remove offline players}
                  for i := 1 to 4 do
                  begin

                    if pl[i]^.name2 <> '' then
                    begin
                      add_shadow(SRemove, pl[i]^, player.name2, '', 0);
                    end;

                  end; {for i:= .end.}

                end;
                'A': begin
                  d(15, 'CHICKEN!');
                end;

              end; {case .end.}

              ch := ' ';

            end;
          end;
        end; {last job}

      end;
      'W': begin {withdraw money from account}

        Withdraw_Money;

      end;
      'P': begin {put money on other players account}

        crlf;
        d(config.textcolor, 'Who shall receive your ' + config.moneytype + '?');
        sd(config.textcolor, ':');

        a := get_string(20);

        for i := 1 to fs(FsPlayer) do
        begin

          load_character(pl[1]^, 1, i);

          if findsub(a, pl[1]^.name2) and
            (pl[1]^.name2 <> player.name2) and
            (pl[1]^.deleted = False) then
          begin

            if confirm(uplc + pl[1]^.name2 + config.textcol1, 'N') = True then
            begin

              xx := 2000000000 - pl[1]^.bankgold;

              if player.gold < xx then xx := player.gold;

              crlf;
              sd(config.textcolor, 'You can send a maximum of ');
              sd(14, commastr(xx));
              sd(config.textcolor, ' ' + many_money(xx));

              d(global_plycol, pl[1]^.name2);

              crlf;
              sd(config.textcolor, 'Amount to transfer (max ');

              sd(14, commastr(xx));
              d(config.textcolor, numeric_help);
              sd(config.textcolor, ':');
              zz := get_number(0, xx);

              if (zz <= xx) and (zz > 0) then
              begin

                if confirm('Send ' + uyellow + commastr(zz) + config.textcol1 + ' ' + many_money(zz), 'Y') = True then
                begin

                  {text}
                  d(config.textcolor, 'The ' + config.moneytype + ' have been sent.');
                  sd(global_plycol, pl[1]^.name2);
                  d(config.textcolor, ' has been notified of this transaction.');

                  {inc other players money}
                  incplayermoney(pl[1]^, zz);

                  {decrease player money}
                  decplayermoney(player, zz);

                  {update other player}
                  user_save(pl[1]^);

                  s := config.moneytype + ' Transfer';
                  {inform other player}
                  post(MailSend,
                    pl[1]^.name2,
                    pl[1]^.ai,
                    False,
                    mailrequest_nothing,
                    '',
                    umailheadc + s + config.textcol1,
                    mkstring(length(s), underscore),
                    uplc + player.name2 + config.textcol1 + ' has sent you ' + uyellow + commastr(zz) + config.textcol1 + ' ' + many_money(zz) + '.',
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

                  {is receiver online then wire the sum directly}
                  if is_online(pl[1]^.name2, online_player) = True then
                  begin
                    online_send_to_player(pl[1]^.name2, online_player, broadcast_sentmoney + long2str(zz));
                  end;

                end;
              end;

              break;
            end else
            begin
              if confirm('Continue search ', 'Y') = False then
              begin
                break;
              end;
            end;
          end;

        end; {for i:= .end.}

      end;
      'D': begin {deposit money into bank-account}
        deposit_money;
      end;
    end; {case .end.}

  until adios = True;

  {remove pointer variables}
  disposal;

end; {The_Bank *end*}

end. {Unit Bank .end.}
