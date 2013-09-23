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



unit Resetg; {Usurper - Used when no userfile is found. Reset Game
              creates the first default characters, computer controlled}

interface

procedure Reset_Game;

implementation

uses
  Init, Cms, Jakob,
  Various, News, File_Io;

procedure Reset_Game;

var
  c:          byte;

  error:      integer;

  i, j:       longint;

  ok:         boolean;

  s, CryptIt: s70;

  PlayerFile: file of UserRec;    {** Userfile **}

begin

  s := 'Usurper. Happenings of ' + fix_date(todays_date);

  {Put RESET-GAME event in the news}
  newsy(True,
    s,
    mkstring(length(s), '-'),
    ' ',
    '***************************',
    '**** Usurper was reset ****',
    '***************************',
    '',
    '',
    '',
    '');

  {delete truth.ans/.asc}
  if f_exists(global_truthfile1) then
    delete_file(global_truthfile1);
  if f_exists(global_truthfile2) then
    delete_file(global_truthfile2);

  {delete inn chatfile}
  if f_exists(global_innfile1) then
    delete_file(global_innfile1);
  if f_exists(global_innfile2) then
    delete_file(global_innfile2);

  {Delete mailfile}
  if f_exists(global_mafile) then
    delete_file(global_mafile);

  {Rewrite PlayerFile}
  ok := False;
  c := 0;
  repeat
    error := 0;
    Assign(playerfile, global_pfile);
  {$I-}rewrite(playerfile);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      unable_to_create(global_pfile, error);
      delay2(900);
    end else
    begin
      ok := True;
    end;

    Inc(c);

  until (c > 5) or (ok);

  {We exit if some error ocurred}
  if not ok then
  begin
    unable_to_create(global_pfile, error);
    crlf;
    halt;
  end;

 {$I-}reset(playerfile);{$I+}
  error := IoResult;

  if error <> 0 then
  begin
    unable_to_access(global_pfile, error);
    crlf;
    halt;
  end;

 {$I-}seek(playerfile, 0);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_To_seek(global_pfile, 0);
    crlf;
    halt;
  end;

  {Randomizing Npc team passwords}
  j := random(10) + 9;
  cryptIt := emptystr;
  for i := 1 to j do
  begin
    case random(39) of
      0: cryptIt := cryptIt + 'A';
      1: cryptIt := cryptIt + 'B';
      2: cryptIt := cryptIt + 'C';
      3: cryptIt := cryptIt + 'D';
      4: cryptIt := cryptIt + 'E';
      5: cryptIt := cryptIt + 'F';
      6: cryptIt := cryptIt + 'G';
      7: cryptIt := cryptIt + 'H';
      8: cryptIt := cryptIt + 'I';
      9: cryptIt := cryptIt + 'J';
      10: cryptIt := cryptIt + 'K';
      11: cryptIt := cryptIt + 'L';
      12: cryptIt := cryptIt + 'M';
      13: cryptIt := cryptIt + 'N';
      14: cryptIt := cryptIt + 'O';
      15: cryptIt := cryptIt + 'P';
      16: cryptIt := cryptIt + 'Q';
      17: cryptIt := cryptIt + 'R';
      18: cryptIt := cryptIt + 'S';
      19: cryptIt := cryptIt + 'T';
      20: cryptIt := cryptIt + 'U';
      21: cryptIt := cryptIt + 'V';
      22: cryptIt := cryptIt + 'W';
      23: cryptIt := cryptIt + 'X';
      24: cryptIt := cryptIt + 'Y';
      25: cryptIt := cryptIt + 'Z';
      26: cryptIt := cryptIt + '#';
      27: cryptIt := cryptIt + '$';
      28: cryptIt := cryptIt + '%';
      29: cryptIt := cryptIt + '0';
      30: cryptIt := cryptIt + '1';
      31: cryptIt := cryptIt + '2';
      32: cryptIt := cryptIt + '3';
      33: cryptIt := cryptIt + '4';
      34: cryptIt := cryptIt + '5';
      35: cryptIt := cryptIt + '6';
      36: cryptIt := cryptIt + '7';
      37: cryptIt := cryptIt + '8';
      38: cryptIt := cryptIt + '9';
    end; {case .end.}
  end;   {for i:= .end.}

         {*Adding some Npcs to the empty userfile*}
  for i := 1 to 20 do
  begin
    player.medal[i] := False;
  end;

  {common variables for all characters, we only init them here}
  player.bankguard := False;
  player.bankwage := 0;
  player.weaphag := 3;
  player.armhag := 3;
  player.recnr := 0;
  player.auto_meny := False;

  {*Computer Character nr 1*}
  player.Name1 := 'Computer1';
  player.name2 := 'Llwellyn';
  player.ai := 'C';
  player.race := Human;
  player.age := 32;
  player.gold := 75000;
  player.hps := 78;
  player.exp := 350000;
  player.level := 10;
  player.bankgold := 238000;
  player.chiv := 1500;
  player.dark := 0;
  player.fights := 5;
  player.strength := 25;
  player.defence := 45;
  player.healing := 250;
  player.allowed := True;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.maxhps := 78;
  player.laston := packed_date;
  player.ageplus := 1;
  player.darknr := 3;
  player.chivnr := 3;
  player.pfights := 3;
  player.king := True;
  player.location := Offloc_Dormitory;
  player.team := 'Close Circle';
  player.teampw := cryptIt;
  player.bguard := 0;
  player.cturf := True;
  player.gnollp := 0;
  player.mental := 100;
  player.addict := 0;
  player.wellwish := False;
  player.Height := 195;
  player.weight := 95;
  player.eyes := 1;
  player.hair := 2;
  player.skin := 3;
  player.sex := 1;
  player.mana := 0;
  player.maxmana := 0;
  player.stamina := 25;
  player.agility := 25;
  player.charisma := 47;
  player.dex := 16;
  player.wisdom := 38;
  player.weappow := 0;
  player.armpow := 0;
  player.blind := False;
  player.plague := False;
  player.smallpox := False;
  player.measles := False;
  player.leprosy := False;
  player.mercy := 0;
  for i := 1 to global_maxitem do
  begin
    player.item[i] := 0;
  end;
  for i := 1 to 6 do
  begin
    player.phr[i] := emptystr;
  end;
  player.autoheal := False;
  player.class := Paladin;
  player.loyalty := 90;
  player.haunt := 3;
  player.master := '1';
  player.tfights := 3;
  player.thiefs := 3;
  player.brawls := 3;
  player.assa := 3;
  player.desc[1] := emptystr;
  player.desc[2] := emptystr;
  player.desc[3] := emptystr;
  player.desc[4] := emptystr;
  player.poison := 0;

  for i := 1 to global_maxspells do
    for j := 1 to 2 do
      player.spell[i, j] := False;
  for i := 1 to global_maxcombat do
    player.skill[i] := 0;

  player.trains := 2;
  player.rhand := 0;
  player.lhand := 0;
  player.head := 0;
  player.body := 0;
  player.arms := 0;
  player.lfinger := 0;
  player.rfinger := 0;
  player.legs := 0;
  player.feet := 0;
  player.waist := 0;
  player.neck := 0;
  player.neck2 := 0;
  player.face := 0;
  player.shield := 0;
  player.hands := 0;
  player.abody := 0;
  player.immortal := True;
  player.battlecry := emptystr;
  player.bguardnr := 0;
  player.casted := False;
  player.punch := 0;
  player.m_kills := 0;
  player.m_defeats := 0;
  player.p_kills := 0;
  player.p_defeats := 0;
  player.interest := 0;
  player.alive_bonus := 0;
  player.teamrec := 2;
  player.expert := False;
  player.maxtime := 60;
  player.ear := 1;
  player.castin := ' ';
  player.armor := 0;
  player.weapon := 0;
  player.wpow := 0;
  player.apow := 0;
  player.disres := 0;
  player.amember := False;
  player.quests := random(5);
  player.god := emptystr;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.royquests := 0;
  player.deleted := False;
  player.roytaxpaied := 0;
  player.wrestlings := 0;
  player.drinksleft := Config.DrinksatOrbs;
  player.daysinprison := 0;
  player.umanbeartries := 0;
  player.massage := 0;
  player.gym_sessions := config.gymsessions;
  player.Gym_Owner := 0;      {controller of the gym? has to be in a team}
  player.Gym_Card := 0;       {free card to the gym? if not gym_owner that is}
  player.royqueststoday := 0;
  player.KingVotePoll := 200; {how many days since voted for king popularity}
  player.KingLastVote := 0;   {how did player vote last time}
  player.married := False;    {married?}
  player.Kids := 0;           {how many kids this playeer is father/mother to}
  player.IntimacyActs := Config.IntimacyActs; {how many acts of intimacy has player left today?}
  player.Pregnancy := 0;      {is player pregnant? 0=no, 1...X = days pregnant}
  player.FatherID := emptystr;
  player.id := crypt(15);
  player.autohate := 1;
  player.Tax_Relief := False;  {free from tax?}
  player.MarriedTimes := 0;    {counter for marriages}
  player.filtyp := 1;          {1=player file, 2=npc file}
  player.Bard_Songs_Left := 5; {ehhh..quite self-explanatory huh?}
  player.prison_escapes := config.prison_escapes; {attempts allowed to escape from prison}


 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {*Computer Character nr 2*}
  player.Name1 := 'Computer2';
  player.name2 := 'De Mandeville';
  player.ai := 'C';
  player.race := HalfElf;
  player.age := 22;
  player.gold := 15000;
  player.hps := 64;
  player.exp := 250000;
  player.level := 8;
  player.bankgold := 238000;
  player.chiv := 500;
  player.dark := 245;
  player.fights := 5;
  player.strength := 25;
  player.defence := 45;
  player.healing := 250;
  player.allowed := True;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.maxhps := 64;
  player.laston := packed_date;
  player.ageplus := 1;
  player.darknr := 3;
  player.chivnr := 3;
  player.pfights := 3;
  player.king := False;
  player.location := offloc_dormitory;
  player.team := 'Close Circle';
  player.teampw := cryptIt;
  player.bguard := 0;
  player.cturf := True;
  player.gnollp := 0;
  player.mental := 100;
  player.addict := 0;
  player.wellwish := False;
  player.Height := 180;
  player.weight := 75;
  player.eyes := 1;
  player.hair := 2;
  player.skin := 3;
  player.sex := 1;
  player.mana := 0;
  player.maxmana := 0;
  player.stamina := 45;
  player.agility := 15;
  player.charisma := 67;
  player.dex := 36;
  player.wisdom := 18;
  player.weappow := 0;
  player.armpow := 0;
  player.blind := False;
  player.plague := False;
  player.smallpox := False;
  player.measles := False;
  player.leprosy := False;
  player.mercy := 0;
  for i := 1 to global_maxitem do
  begin
    player.item[i] := 0;
  end;
  for i := 1 to 6 do
  begin
    player.phr[i] := emptystr;
  end;

  player.autoheal := False;
  player.class := Warrior;
  player.loyalty := 90;
  player.haunt := 3;
  player.master := '2';
  player.tfights := 3;
  player.thiefs := 3;
  player.brawls := 3;
  player.assa := 3;
  player.desc[1] := emptystr;
  player.desc[2] := emptystr;
  player.desc[3] := emptystr;
  player.desc[4] := emptystr;
  player.poison := 0;

  for i := 1 to global_maxspells do
  begin
    for j := 1 to 2 do
    begin
      player.spell[i, j] := False;
    end;
  end;

  for i := 1 to global_maxcombat do
    player.skill[i] := 0;

  player.trains := 2;
  player.m_kills := 0;
  player.m_defeats := 0;
  player.p_kills := 0;
  player.p_defeats := 0;
  player.interest := 0;
  player.alive_bonus := 0;
  player.teamrec := 2;
  player.expert := False;
  player.maxtime := 60;
  player.ear := 1;
  player.castin := ' ';
  player.armor := 0;
  player.weapon := 0;
  player.wpow := 0;
  player.apow := 0;
  player.disres := 0;
  player.amember := False;
  player.quests := random(5);
  player.god := emptystr;
  player.royquests := 0;
  player.deleted := False;
  player.roytaxpaied := 0;
  player.wrestlings := 0;
  player.drinksleft := Config.DrinksatOrbs;
  player.umanbeartries := 0;
  player.massage := 0;
  player.gym_sessions := config.gymsessions;
  player.Gym_Owner := 0;      {controller of the gym? has to be in a team}
  player.Gym_Card := 0;       {free card to the gym? if not gym_owner that is}
  player.royqueststoday := 0;
  player.KingVotePoll := 200; {how many days since voted for king popularity}
  player.KingLastVote := 0;   {how did player vote last time}
  player.married := False;
  player.Kids := 0;           {how many kids this playeer is father/mother to}
  player.IntimacyActs := Config.IntimacyActs; {how many acts of intimacy has player left today?}
  player.Pregnancy := 0;      {is player pregnant? 0=no, 1...X = days pregnant}
  player.FatherID := emptystr;
  player.daysinprison := 0;
  player.id := crypt(15);
  player.autohate := 1;
  player.Tax_Relief := False;  {free from tax?}
  player.MarriedTimes := 0;    {counter for marriages}
  player.Bard_Songs_Left := 5; {ehhh..quite self-explanatory huh?}

 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {****** Computer Character nr 3 **********}
  player.Name1 := 'Computer3';
  player.name2 := 'Ugluk';
  player.ai := 'C';
  player.race := Orc;
  player.age := 42;
  player.gold := 5000;
  player.hps := 45;
  player.exp := 75000;
  player.level := 6;
  player.bankgold := 49000;
  player.chiv := 0;
  player.dark := 1200;
  player.fights := 5;
  player.strength := 25;
  player.defence := 45;
  player.healing := 250;
  player.allowed := True;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.maxhps := 45;
  player.laston := packed_date;
  player.ageplus := 1;
  player.darknr := 3;
  player.chivnr := 3;
  player.pfights := 3;
  player.king := False;
  player.location := offloc_dormitory;
  player.team := emptystr;
  player.teampw := emptystr;
  player.bguard := 0;
  player.cturf := False;
  player.gnollp := 0;
  player.mental := 100;
  player.addict := 0;
  player.wellwish := False;
  player.Height := 172;
  player.weight := 70;
  player.eyes := 1;
  player.hair := 2;
  player.skin := 3;
  player.sex := 1;
  player.mana := 100;
  player.maxmana := 100;
  player.stamina := 20;
  player.agility := 35;
  player.charisma := 20;
  player.dex := 36;
  player.wisdom := 60;
  player.weappow := 0;
  player.armpow := 0;
  player.blind := False;
  player.plague := False;
  player.smallpox := False;
  player.measles := False;
  player.leprosy := False;
  player.mercy := 0;
  for i := 1 to global_maxitem do
  begin
    player.item[i] := 0;
  end;
  for i := 1 to 6 do
  begin
    player.phr[i] := emptystr;
  end;
  player.autoheal := False;
  player.class := Sage;
  player.loyalty := 90;
  player.haunt := 3;
  player.master := '3';
  player.tfights := 3;
  player.thiefs := 3;
  player.brawls := 3;
  player.assa := 3;
  player.desc[1] := emptystr;
  player.desc[2] := emptystr;
  player.desc[3] := emptystr;
  player.desc[4] := emptystr;
  player.poison := 0;

  for i := 1 to global_maxspells do
  begin
    for j := 1 to 2 do
      player.spell[i, j] := False;
  end;

  for i := 1 to global_maxcombat do
    player.skill[i] := 0;

  player.trains := 2;
  player.m_kills := 0;
  player.m_defeats := 0;
  player.p_kills := 0;
  player.p_defeats := 0;
  player.interest := 0;
  player.alive_bonus := 0;
  player.teamrec := 0;
  player.expert := False;
  player.maxtime := 60;
  player.ear := 1;
  player.castin := ' ';
  player.armor := 0;
  player.weapon := 0;
  player.wpow := 0;
  player.apow := 0;
  player.disres := 0;
  player.amember := False;
  player.quests := random(5);
  player.god := emptystr;
  player.royquests := 0;
  player.deleted := False;
  player.roytaxpaied := 0;
  player.wrestlings := 0;
  player.drinksleft := Config.DrinksatOrbs;
  player.daysinprison := 0;
  player.umanbeartries := 0;
  player.massage := 0;
  player.gym_sessions := config.gymsessions;
  player.Gym_Owner := 0;      {controller of the gym? has to be in a team}
  player.Gym_Card := 0;       {free card to the gym? if not gym_owner that is}
  player.royqueststoday := 0;
  player.KingVotePoll := 200; {how many days since voted for king popularity}
  player.KingLastVote := 0;   {how did player vote last time}
  player.married := False;
  player.Kids := 0;           {how many kids this playeer is father/mother to}
  player.IntimacyActs := Config.IntimacyActs; {how many acts of intimacy has player left today?}
  player.Pregnancy := 0;      {is player pregnant? 0=no, 1...X = days pregnant}
  player.FatherID := emptystr;
  player.id := crypt(15);
  player.autohate := 1;
  player.Tax_Relief := False;  {free from tax?}
  player.MarriedTimes := 0;    {counter for marriages}
  player.Bard_Songs_Left := 5; {ehhh..quite self-explanatory huh?}

 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {*Computer Character nr 4*}
  player.Name1 := 'Computer4';
  player.name2 := 'Zara';
  player.ai := 'C';
  player.race := Elf;
  player.age := 24;
  player.gold := 1500;
  player.hps := 45;
  player.exp := 15000;
  player.level := 4;
  player.bankgold := 2500;
  player.chiv := 150;
  player.dark := 0;
  player.fights := 5;
  player.strength := 18;
  player.defence := 24;
  player.healing := 250;
  player.allowed := True;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.maxhps := 35;
  player.laston := packed_date;
  player.ageplus := 1;
  player.darknr := 3;
  player.chivnr := 3;
  player.pfights := 3;
  player.king := False;
  player.location := offloc_dormitory;
  player.team := emptystr;
  player.teampw := emptystr;
  player.bguard := 0;
  player.cturf := False;
  player.gnollp := 0;
  player.mental := 100;
  player.addict := 0;
  player.wellwish := False;
  player.Height := 179;
  player.weight := 68;
  player.eyes := 1;
  player.hair := 2;
  player.skin := 3;
  player.sex := 2;
  player.mana := 0;
  player.maxmana := 0;
  player.stamina := 20;
  player.agility := 25;
  player.charisma := 21;
  player.dex := 16;
  player.wisdom := 25;
  player.weappow := 0;
  player.armpow := 0;
  player.blind := False;
  player.plague := False;
  player.smallpox := False;
  player.measles := False;
  player.leprosy := False;
  player.mercy := 0;

  for i := 1 to global_maxitem do
  begin
    player.item[i] := 0;
  end;

  for i := 1 to 6 do
  begin
    player.phr[i] := emptystr;
  end;

  player.autoheal := False;
  player.class := Ranger;
  player.loyalty := 10;
  player.haunt := 3;
  player.master := '4';
  player.tfights := 3;
  player.thiefs := 3;
  player.brawls := 3;
  player.assa := 3;
  player.desc[1] := 'Zara is tall and beautiful.';
  player.desc[2] := emptystr;
  player.desc[3] := emptystr;
  player.desc[4] := emptystr;
  player.poison := 0;

  for i := 1 to global_maxspells do
  begin
    for j := 1 to 2 do
      player.spell[i, j] := False;
  end;

  for i := 1 to global_maxcombat do
    player.skill[i] := 0;

  player.trains := 2;
  player.m_kills := 0;
  player.m_defeats := 0;
  player.p_kills := 0;
  player.p_defeats := 0;
  player.interest := 0;
  player.alive_bonus := 0;
  player.teamrec := 0;
  player.expert := False;
  player.maxtime := 60;
  player.ear := 1;
  player.castin := ' ';
  player.armor := 0;
  player.weapon := 0;
  player.wpow := 0;
  player.apow := 0;
  player.disres := 0;
  player.amember := False;
  player.quests := random(5);
  player.god := emptystr;
  player.royquests := 0;
  player.deleted := False;
  player.roytaxpaied := 0;
  player.wrestlings := 0;
  player.drinksleft := Config.DrinksatOrbs;
  player.daysinprison := 0;
  player.umanbeartries := 0;
  player.massage := 0;
  player.gym_sessions := config.gymsessions;
  player.Gym_Owner := 0;      {controller of the gym? has to be in a team}
  player.Gym_Card := 0;       {free card to the gym? if not gym_owner that is}
  player.royqueststoday := 0;
  player.KingVotePoll := 200; {how many days since voted for king popularity}
  player.KingLastVote := 0;   {how did player vote last time}
  player.married := False;
  player.Kids := 0;           {how many kids this playeer is father/mother to}
  player.IntimacyActs := Config.IntimacyActs; {how many acts of intimacy has player left today?}
  player.Pregnancy := 0;      {is player pregnant? 0=no, 1...X = days pregnant}
  player.FatherID := emptystr;
  player.id := crypt(15);
  player.autohate := 1;
  player.Tax_Relief := False;  {free from tax?}
  player.MarriedTimes := 0;    {counter for marriages}
  player.Bard_Songs_Left := 5; {ehhh..quite self-explanatory huh?}

 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {*Computer Character nr 5*}
  player.Name1 := 'Computer5';
  player.name2 := 'Sony';
  player.ai := 'C';
  player.race := Mutant;
  player.age := 32;
  player.gold := 1500;
  player.hps := 39;
  player.exp := 85000;
  player.level := 5;
  player.bankgold := 22000;
  player.chiv := 50;
  player.dark := 12;
  player.fights := 5;
  player.strength := 30;
  player.defence := 25;
  player.healing := 250;
  player.allowed := True;
  player.resurrections := config.resurrections;
  player.pickpocketattempts := config.pickpocketattempts;
  player.BankRobberyAttempts := config.BankRobberyAttempts;
  player.maxhps := 39;
  player.laston := packed_date;
  player.ageplus := 1;
  player.darknr := 3;
  player.chivnr := 3;
  player.pfights := 3;
  player.king := False;
  player.location := offloc_dormitory;
  player.team := emptystr;
  player.teampw := emptystr;
  player.bguard := 0;
  player.cturf := False;
  player.gnollp := 0;
  player.mental := 100;
  player.addict := 0;
  player.wellwish := False;
  player.Height := 182;
  player.weight := 80;
  player.eyes := 1;
  player.hair := 2;
  player.skin := 2;
  player.sex := 1;
  player.mana := 0;
  player.maxmana := 0;
  player.stamina := 30;
  player.agility := 20;
  player.charisma := 89;
  player.dex := 43;
  player.wisdom := 30;
  player.weappow := 0;
  player.armpow := 0;
  player.blind := False;
  player.plague := False;
  player.smallpox := False;
  player.measles := False;
  player.leprosy := False;
  player.mercy := 0;
  for i := 1 to global_maxitem do
  begin
    player.item[i] := 0;
  end;
  for i := 1 to 6 do
  begin
    player.phr[i] := emptystr;
  end;
  player.autoheal := False;
  player.class := Assassin;
  player.loyalty := 30;
  player.haunt := 3;
  player.master := '5';
  player.tfights := 3;
  player.thiefs := 3;
  player.brawls := 3;
  player.assa := 3;
  player.desc[1] := emptystr;
  player.desc[2] := emptystr;
  player.desc[3] := emptystr;
  player.desc[4] := emptystr;
  player.poison := 0;

  for i := 1 to global_maxspells do
  begin
    for j := 1 to 2 do
      player.spell[i, j] := False;
  end;

  for i := 1 to global_maxcombat do
    player.skill[i] := 0;

  player.trains := 2;
  player.m_kills := 0;
  player.m_defeats := 0;
  player.p_kills := 0;
  player.p_defeats := 0;
  player.interest := 0;
  player.alive_bonus := 0;
  player.teamrec := 0;
  player.expert := False;
  player.maxtime := 60;
  player.ear := 1;
  player.castin := ' ';
  player.armor := 0;
  player.weapon := 0;
  player.wpow := 0;
  player.apow := 0;
  player.disres := 0;
  player.amember := False;
  player.quests := random(5);
  player.god := emptystr;
  player.royquests := 0;
  player.deleted := False;
  player.roytaxpaied := 0;
  player.wrestlings := 0;
  player.drinksleft := Config.DrinksatOrbs;
  player.daysinprison := 0;
  player.umanbeartries := 0;
  player.massage := 0;
  player.gym_sessions := config.gymsessions;
  player.Gym_Owner := 0;      {controller of the gym? has to be in a team}
  player.Gym_Card := 0;       {free card to the gym? if not gym_owner that is}
  player.royqueststoday := 0;
  player.KingVotePoll := 200; {how many days since voted for king popularity}
  player.KingLastVote := 0;   {how did player vote last time}
  player.married := False;
  player.Kids := 0;           {how many kids this playeer is father/mother to}
  player.IntimacyActs := Config.IntimacyActs; {how many acts of intimacy has player left today?}
  player.Pregnancy := 0;      {is player pregnant? 0=no, 1...X = days pregnant}
  player.FatherID := emptystr;
  player.id := crypt(15);
  player.autohate := 1;
  player.Tax_Relief := False;  {free from tax?}
  player.MarriedTimes := 0;    {counter for marriages}
  player.Bard_Songs_Left := 5; {ehhh..quite self-explanatory huh?}

 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {*************************************}
 {$I-}Close(playerfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(global_pfile, error);
  end;

end; {Reset_Game *end*}

end. {Unit ResetG .end.}
