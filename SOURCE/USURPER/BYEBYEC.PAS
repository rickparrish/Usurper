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


unit ByeByeC; {Usurper - This is the Exit routine,
               executed right before program exit}

interface  {keyboard inactivity check takes place in DDPLUS.PAS}

procedure ByeBye;

implementation

uses
  DDplus, Elog, Init,
  Cms, InitGods, Jakob,
  SortPl, SortTeam, Rating,
  Various, Various2, Various3,
  Mail, News, Online,
  File_Io, SysUtils;

procedure ByeBye; {Executed upon exit of game}
var
  thanks, sysop, bbs: s70;

  i: byte;

begin

  {Set Exit Procedure}
  TrapExit;
  ExitProc := ExitSave;

  global_multi := False;

  {Get Sysop and BBS name}
  sysop := cfg_string(1);
  bbs := cfg_string(2);

  {registration check}
  muffis;

  {should player be punished for dropping carrier in fight/steroid shop}
  if (global_PlayerInSteroids) and (config.PunishCarrierDroppers > 0) then
  begin
    {message}
    d(15, 'Player dropped carrier in Steroid Shop and will be punished!');

    {mail player of his error}
    post(MailSend,
      player.name2,
      player.ai,
      False,
      mailrequest_nothing,
      '',
      ulred + 'CHEATER!?' + config.textcol1,
      mkstring(9, underscore),
      'You dropped carrier in the Steroid Shop! This is not allowed!',
      'You are not allowed to play more today ' + ulgray + '[' + fix_date(todays_date) + ']' + config.textcol1 + '.',
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
      'Drop Out!',
      ' ' + uplc + player.name2 + config.textcol1 + ' dropped carrier when taking Steroids!',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');


    {punishment, no more play today!}
    {player.allowed:=false;}
    Reduce_Player_Resurrections(player, True);

  end else if (global_PlayerInFight) and (config.PunishCarrierDroppers > 0) then
  begin

    {message}
    d(15, 'Player dropped carrier in a fight and will be punished!');

    {mail player of his error}
    post(MailSend,
      player.name2,
      player.ai,
      False,
      mailrequest_nothing,
      '',
      ulred + 'CHEATER!?' + config.textcol1,
      mkstring(9, underscore),
      'You dropped carrier in a fight! This is not allowed!',
      'You are not allowed to play more today ' + ulgray + '[' + fix_date(todays_date) + ']' + config.textcol1 + '.',
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
      'Drop Out!',
      ' ' + uplc + player.name2 + config.textcol1 + ' dropped carrier during a fight!',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '');


    {punishment, no more play today}
    {player.allowed:=false;}
    Reduce_Player_Resurrections(player, True);

  end;

  {** The Game Session is terminated **}
  {** Player file is written to disk **}

  if (global_godactive = True) and (onliner.usertype = online_god) then
  begin
    {save god}
    load_god(fsave, god, god.recnr);
  end;

  if player.name2 <> '' then
  begin

    {remove online comfile (trade or battle)}
    if (onliner.comfile <> '') and (f_exists(onliner.comfile)) then
    begin
      i := 1;
      repeat
        delete_file(onliner.comfile);
        Inc(i);
      until (f_exists(onliner.comfile) = False) or (i > 50);
    end;

    add_shadow(SRemoveFakess, player, '', 'going to sleep', 0);
    {remove online players}
    add_shadow(SRemoveShadows, player, '', 'going to sleep', 0);
    {remove online players}

    {broadcast player exit to the other nodes}
    if player.hps < 1 then
    begin
      online_send_to_all(broadcast_exitdead, onliner.Name, '');
    end else
    begin
      online_send_to_all(broadcast_exitalive, onliner.Name, '');
    end;

    {update player timer variables}
    player.laston := packed_date;
    player.maxtime := time_left;

    add_onliner(ORemoveMe, onliner);

    if (global_godactive = False) and (onliner.usertype = online_player) then
    begin
      {save user}
      user_save(player);
    end;

    if global_Registered then
    begin
      sd(config.textcolor, 'Registered to ');
      sd(11, sysop);
      sd(config.textcolor, ' and ');
      d(11, bbs);

      {fetching CREDITS fr†n .CFG}
      thanks := cfg_string(69);
      if thanks <> '' then
      begin
        crlf;
        d(config.textcolor, 'Credits :');
        d(14, ' ' + thanks);
        crlf;
      end else
      begin
        crlf;
      end;
    end;

    {returning to bbs}
    sd(config.textcolor, 'Returning to ');
    d(10, bbs);
    crlf;

    d(11, 'Internet');
    d(5, 'WWW :  ' + global_webaddress);
    d(5, 'Forum: http://www.usurper.dangarden.com');
  {d(5,'FTP : ftp.brake.north.de     in the directory /pub/tmh/');
  }
    d(5, 'E-mail : jakob@dangarden.com');
    crlf;


    if (global_godactive = False) and (onliner.usertype = online_player) then
    begin
      d(config.textcolor, 'Writing scores...');

      if global_utest = False then
      begin
        {Write Player Scores}
        sort_players(True);

        {Write Team Scores}
        sort_teams(True, False, False, False);
      end;

      if global_registered then
      begin
        {Write 'hall of fame' lists}
        ratings_and_scores('S');
      end;

    end;

    crlf;

  end;

  {delay non-registered users a while...}
  if not global_Registered then
  begin
    crlf;
    d(9, 'Usurper - from JAS Software');
    crlf;
    d(14, 'Unregistered Copy');
    Sleep(1000);
  end;

  {Dispose global monster array}
  dispose_monsters;

end; {ByeBye *end*}

end. {Unit ByebyeC *end*}
