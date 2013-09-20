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



unit Various2; {Usurper - Various Routines II}

interface

uses
  Init;

 {Crap}
procedure Draw_Picture(const pic: string);
procedure MemInfo; {only used when developing the program}
function The_Bad: s30; {returns random "the ill-mannered ", "the ugly "}

 {Rewards}
procedure Reward_Check(speak: boolean; var winner, loser: UserRec);

{Drinks, Orbs}
procedure Drink_Maintenance;
function Random_Drink: s30;

{Quests - quest_rankings is the only proc located elsewhere, in various.pas}
procedure New_Quest(var quest: QuestRec); {init a Quest-Record}
procedure List_Quests(IncludeClaimed: boolean);
procedure Display_Quest(const quest: questrec; questnr: word);
procedure Quest_Maintenance;
function Grab_Quest(const ply: userrec; nr: word): boolean;
function Quest_DiffString(diff: byte; recstr: boolean): s90;
function Quest_Target(Target: QuestTargets): s90;
function Claimed_Quests(const Name: s30): word;

{King}
procedure King_Popularity(var ply: userrec);
procedure Healing_Royal_Angel;
procedure Hurting_Royal_Avenger;
procedure Inform_King(const line1, line2, line3, line4, line5, line6, line7, line8, line9, line10,
  line11, line12, line13, line14, line15: s100);

{Armor & Weapon Shops}
procedure Bad_News(shop: char);

{Moat Creatures}
procedure Load_MoatId(var temp: MoatRec; IDTAG: s15);
function Find_MoatId(IDTAG: s15): boolean;

{Player Levels}
procedure Raise_Player(var happy: userrec; paper, mailman, realtime, mailteam: boolean; helper: s70);
procedure Post_NightMare(var pl0: userrec);
function Level_Raise(levelst: word; inn: longint): longint;
function How_Many_XP_Left(desired_level: integer; my_exp: longint): longint;

{Player}
procedure Sleep_dormitory(const sleeper: userrec); {called from the dormitory}
procedure Deactivate_Player(var ply: userrec);
procedure Kill_Comment(var killer: userrec; const victim: s70);
procedure Battle_Comment(mode: integer; const player: s70);
procedure Chances_Eval(var ply: userrec);
function Bash_Damage(instamina: integer): integer; {called from the dormitory}

 {Wanted}
procedure Remove_Wanted_Posters(const ply: userrec); {remove plys wanted posters}

 {Npc}
function Get_NpcInnComment: s90;

{Registration}
procedure Muffis; {registration CHECK}
procedure Only_In_Registered_Version;

{money stuff}
function Many_Money(const inval: longint): s30;

{generic messages}
procedure You_Cant_Afford_It;
procedure Could_Not_Locate_Character;
procedure Could_Not_Locate_Challengable_Character;

procedure Cannot_Attack_Husband(const pl1, pl2: UserRec);
procedure No_Homo_Relations;
procedure No_Intimate_Acts;
procedure No_Dark_Deeds;
procedure No_Good_Deeds;
procedure No_Gym_Sessions;

{Help Routines, executed when "Usurper ?" is typed at the command prompt}
procedure Command_Help;
procedure Numeric_Input_Help; {describes Usurpers numeric input system}

implementation

uses
  Crt, Jakob, Various,
  Various3, Mail, CMS,
  Invent, PlMarket, Spellsu,
  Orb, Relation, News,
  Children, Online, File_io;

procedure Inform_King(const line1, line2, line3, line4, line5, line6, line7, line8, line9, line10,
  line11, line12, line13, line14, line15: s100);

var king: kingRec;
  {mail the Monarch with message}
begin

  if f_exists(global_kingf) = True then
  begin

    {load king data}
    load_king(fload, king);

    if (king.Name <> '') and (king.ai = 'H') then
    begin

      post(MailSend,
        king.Name,
        king.ai,
        False,
        mailrequest_nothing,
        '',
        line1,
        line2,
        line3,
        line4,
        line5,
        line6,
        line7,
        line8,
        line9,
        line10,
        line11,
        line12,
        line13,
        line14,
        line15);
    end;
  end;

end; {inform_king *end*}

procedure King_Popularity(var ply: userrec);
var
  done, allowed: boolean;

  king:       KingRec;

  s:          s70;
  s1, s2, s3: s90;

  vote:       byte;

  ch:         char;

begin

  {what does ply think of the current ruler}

  {init}
  allowed := True;

  {does a ruler exist?}
  if f_exists(global_kingf) = False then
  begin
    allowed := False;
  end else
  begin
    king.Name := emptystr;
    load_king(fload, king);
    if king.Name = '' then
      allowed := False;
  end;

  {current ruler is not allowed to vote on himself [obvious]}
  if ply.king = True then
    allowed := False;

  {is player entitled to vote? [20 days between polls]}
  if ply.KingVotePoll < 20 then
  begin
    allowed := False;
  end;

  {exit if not allowed to vote}
  if allowed = False then
    exit;

  done := False;
  vote := 0;
  repeat

    {Vote!}
    crlf;
    pause;
    show_usurper_data(picture_crown, False);
    s := 'Royal Referendum';
    d(15, s);
    d(5, mkstring(length(s), underscore));
    sd(config.textcolor, 'What do you think of the current ruler, ' + kingstring(king.sexy) + ' ');
    d(global_plycol, king.Name + config.textcol1 + ' ?');
    crlf;

    {(f)ine job}
    menu('(F)ine job.');

    {(b)est king ever}
    menu('(B)est ' + kingstring(king.sexy) + ' ever!');

    {(p)oor excuse}
    menu('(P)oor excuse for a ' + kingstring(king.sexy) + '.');

    {(o)verthrow}
    menu('(O)verthrow this dictator!');
    d(8, mkstring(20, '-'));

    {(N)o opinion}
    menu('(N)othing to say.');
    sd(config.textcolor, ':');

    {get user-input}
    ch := upcase(getchar);

    if ch in ['F', 'B', 'P', 'O', 'N'] then
    begin
      done := True;
    end;

  until done;

  {init message variables}
  s1 := '';
  s2 := '';
  s3 := '';

  {evaluate user-input and create message to the King}
  case ch of
    'F': begin {doing a fine job...}
      vote := 1;
      d(15, sex2[king.sexy] + '''s doing a fine job.');
      s1 := uplc + ply.name2 + config.textcol1 + ' thinks you are doing a ' + uyellow + 'fine' +
        config.textcol1 + ' job as ' + kingstring(king.sexy);

      {news-paper}
      if config.print_kingpolls = True then
      begin
        newsy(True,
          'The Royal Family is supported',
          ' ' + uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] +
          ' supports ' + kingstring(king.sexy) + ' ' + ukingc + king.Name + config.textcol1 + '.',
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
    'B': begin {best we've ever had...}
      vote := 2;
      d(15, 'I just love this ' + kingstring(king.sexy) + '!');
      s1 := uplc + ply.name2 + config.textcol1 + ' thinks you are the ' + uyellow + 'FINEST ' +
        config.textcol1 + kingstring(king.sexy) + ' ever in office!';
      {news-paper}
      if config.print_kingpolls = True then
      begin
        newsy(True,
          'The Royal Family is loved',
          ' ' + uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] +
          ' pleads loyalty to ' + kingstring(king.sexy) + ' ' + ukingc + king.Name + config.textcol1 + '.',
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
    'P': begin {poor excuse...}
      vote := 3;
      d(15, sex2[king.sexy] + '''s plain bad.');
      case random(4) of
        0: s1 := uplc + ply.name2 + config.textcol1 + ' doesn''t think too highly of your effort as ' +
            kingstring(king.sexy) + '!';
        1: s1 := uplc + ply.name2 + config.textcol1 + ' thinks you are doing a ' + ulred + 'poor' +
            config.textcol1 + ' job as ' + kingstring(king.sexy) + '!';
        2: s1 := uplc + ply.name2 + config.textcol1 + ' would like to see ' + sex4[ply.sex] +
            ' on the throne, instead of you.';
        3: begin
          s1 := uplc + ply.name2 + config.textcol1 + ' is not impressed.';
          s2 := 'Improve your ruling or face the consequences...';
        end;
      end; {case .end.}

           {news-paper}
      if config.print_kingpolls = True then
      begin
        newsy(True,
          'The Royal Family is disliked!',
          ' ' + uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] +
          ' would like to see another ' + kingstring(king.sexy) + ' in office!',
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
    'O': begin {overthrow dictator...}
      vote := 4;
      d(15, 'We deserve better than this! REBEL NOW!');
      case random(5) of
        0: s1 := uplc + ply.name2 + config.textcol1 + ' ' + ulred + 'hates' + config.textcol1 + ' your Royal governing!!';
        1: s1 := uplc + ply.name2 + config.textcol1 + ' ' + ulred + 'detests' + config.textcol1 +
            ' your delusions of grandeur!';
        2: s1 := uplc + ply.name2 + config.textcol1 + ' will sing and dance when you are removed from the Throne!';
        3: s1 := uplc + ply.name2 + config.textcol1 + ' wishes to remove you from the throne!';
        4: begin
          s1 := uplc + ply.name2 + config.textcol1 + ' wants you to ' + ulred + 'ABDICATE' + config.textcol1 + ' now.';
          s2 := 'If you don''t comply, ' + uplc + ply.name2 + config.textcol1 + ' promises to come after you!';
        end;
      end; {case .end.}

           {news-paper}
      if config.print_kingpolls = True then
      begin
        case random(3) of
          0: begin
            newsy(True,
              'Royal Family challenged!',
              ' ' + uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] +
              ' hates ' + kingstring(king.sexy) + ukingc + ' ' + king.Name + config.textcol1 + '!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');
          end;
          1: begin
            newsy(True,
              'Royal Family challenged!',
              ' ' + uplc + player.name2 + config.textcol1 + ' the ' + classnames[player.class] +
              ' spits on the Royal Family!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');
          end;
          2: begin
            newsy(True,
              'Royal Family challenged!',
              ' ' + uplc + player.name2 + config.textcol1 + ' is sick and tired of the worthless Royal Family!',
              '',
              '',
              '',
              '',
              '',
              '',
              '',
              '');
          end;
        end; {case .end.}
      end;

    end;
  end; {case .end.}

       {mail the result to current ruler}
  if ch = 'N' then
  begin
    d(15, 'Wimp!');
    vote := 0;
  end else
  if king.ai = 'H' then
  begin
    s := 'Popularity';
    post(MailSend,
      king.Name,
      king.ai,
      False,
      mailrequest_nothing,
      '',
      umailheadc + s + config.textcol1,
      mkstring(length(s), underscore),
      s1,
      s2,
      s3,
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

  {update player record}
  ply.KingVotePoll := 0;
  ply.KingLastVote := vote;

  user_save(ply);

end; {king_popularity **END**}

procedure Healing_Royal_Angel;
var x: longint;
begin

  {the king/queen has sent a healing Angel to aid player}
  {this proc is called from online.pas and mail.pas}

  crlf;
  d(14, 'Divine Intervention');
  d(14, mkstring(19, underscore));
  d(15, 'An Angel has landed beside you!');
  d(15, 'It puts its hand on your forehead. You feel a healing power');
  d(15, 'flood through your veins.');

  {cure the player}
  if player.hps < player.maxhps then
  begin
    d(15, 'Your hitpoints are maxed out!');
    player.hps := player.maxhps;
  end;

  if player.blind then
  begin
    d(14, 'Your Blindness has been cured!');
  end;
  if player.plague then
  begin
    d(14, 'You no longer suffer from the Plague!');
  end;
  if player.smallpox then
  begin
    d(14, 'You are cured of the Smallpox!');
  end;
  if player.measles then
  begin
    d(14, 'You are cured of the Measles');
  end;
  if player.leprosy then
  begin
    d(14, 'You no longer suffer from Leprosy');
  end;

  {experience}
  x := player.level * 125;
  d(config.textcolor, 'Your encounter with the Angel was a real experience!');
  d(config.textcolor, 'You receive ' + uwhite + commastr(x) + config.textcol1 + ' experience points!');

  Inc(player.exp, x);

  {goodness points}
  x := player.level * 25;
  d(config.textcolor, 'Your soul lightens! (' + commastr(x) + ' points)');
  give_chivalry(player, x);

  {News-Paper}
  Newsy(True,
    'Divine Intervention',
    ' ' + uplc + player.name2 + config.textcol1 + ' met with an ' + uwhite + 'Angel' + config.textcol1 + '.',
    ' ' + uplc + player.name2 + config.textcol1 + ' was healed and restored in ' + sex3[player.sex] + ' soul.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {Healing_Royal_Angel *end*}

procedure Hurting_Royal_Avenger;
var x: longint;
begin

  {the king/queen has sent a Dark Avenger to hurt player}
  {this proc is called from online.pas and mail.pas}

  crlf;
  d(15, 'Doom has arrived!');
  d(14, mkstring(17, underscore));
  d(15, 'A Dark Avenger has landed beside you!');
  d(15, 'It puts its hand on your shoulder. You feel your body ache!');
  d(15, 'Your veins are filled with black poison.');

  {hurt the player}
  d(12, 'Your hitpoints are depleted!');
  player.hps := 1;

  if (player.blind = False) and (random(10) = 0) then
  begin
    d(12, 'You are BLIND!');
  end;
  if (player.plague = False) and (random(10) = 0) then
  begin
    d(12, 'You suffer from the Plague!');
  end;
  if (player.smallpox = False) and (random(10) = 0) then
  begin
    d(12, 'You have the the Smallpox!');
  end;
  if (player.measles = False) and (random(10) = 0) then
  begin
    d(12, 'You suffer from Measles!');
  end;
  if (player.leprosy = False) and (random(10) = 0) then
  begin
    d(12, 'You suffer from Leprosy!');
  end;

  {darkness points}
  x := player.level * 25;
  d(config.textcolor, 'Your soul darkens from the ' + ulgray + 'Dark Avengers' + config.textcol1 +
    ' poison! (' + commastr(x) + ' points)');
  give_darkness(player, x);

  {News-Paper}
  Newsy(True,
    'Doom from the Sky',
    ' ' + uplc + player.name2 + config.textcol1 + ' met with a ' + ulred + 'Dark Avenger' + config.textcol1 + '.',
    ' ' + uplc + player.name2 + config.textcol1 + ' was hurt in both ' + sex3[player.sex] + ' body and soul.',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {Hurting_Royal_Avenger *end*}

function Bash_Damage(instamina: integer): integer;
var Result: integer;
begin

  {Used by the dormitory}

  Result := random(instamina) + 1;

  {return result}
  bash_damage := Result;

end; {bash_damage *end*}

procedure Sleep_dormitory(const sleeper: userrec);
 {called from the dormitory..when player examines sleeping
  character in the dormitory}
var
  i:      byte;
  p_description: boolean;

  inweap: weaprec;
  inarm:  armrec;
  objekt: ^orec;

begin

  crlf;
  sd(config.textcolor, 'You approach ');
  sd(global_plycol, sleeper.name2 + 's');
  d(config.textcolor, ' bed and examine ' + sex[sleeper.sex] + '.');

  p_description := False;
  for i := 1 to 4 do
  begin
    if sleeper.desc[i] <> '' then
    begin
      d(config.textcolor, sleeper.desc[i]);
      p_description := True;
    end;
  end; {for i:= .end.}

  if p_description = False then
  begin
    {no player description available...we make one ourselves here}
    d(global_plycol, sleeper.name2 + config.textcol1 + ' is a ' + vicious_string(sleeper) + ' ' +
      race_display(2, sleeper.race, 0));
    d(config.textcolor, 'In battle ' + uplc + sleeper.name2 + config.textcol1 + ' is ranked ' + battlemaster_string(sleeper));
  end;

  crlf;

  if config.classic then
  begin
    {classic weapon}
    if sleeper.weapon = 0 then
    begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' has no weapon! (hehe).');
    end else
    begin
      load_weapon(sleeper.weapon, inweap);

      sd(global_plycol, sleeper.name2 + 's');
      sd(config.textcolor, ' weapon is ');
      sd(global_itemcol, inweap.Name);
      d(config.textcolor, '.');

    end;

    {classic armor}
    if sleeper.armor = 0 then
    begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' has no armor! (hehe).');
    end else
    begin
      load_armor(sleeper.armor, inarm);

      sd(global_plycol, sleeper.name2 + 's');
      sd(config.textcolor, ' armor is ');
      sd(global_itemcol, inarm.Name);
      d(config.textcolor, '.');
    end;

  end else
  begin {NEW game mode}

        {init pointer variable}
    new(objekt);

    if sleeper.rhand > 0 then
    begin
      load_objekt(objekt^, weapon, sleeper.rhand);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' in ' + sex3[sleeper.sex] + ' right hand.');
    end;

    if sleeper.lhand > 0 then
    begin
      load_objekt(objekt^, weapon, sleeper.lhand);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' in ' + sex3[sleeper.sex] + ' left hand.');
    end;

    if sleeper.head > 0 then
    begin
      load_objekt(objekt^, head, sleeper.head);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' head.');
    end;

    if sleeper.body > 0 then
    begin
      load_objekt(objekt^, body, sleeper.body);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' body.');
    end;

    if sleeper.arms > 0 then
    begin
      load_objekt(objekt^, arms, sleeper.arms);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' arms.');
    end;

    if sleeper.lfinger > 0 then
    begin
      load_objekt(objekt^, fingers, sleeper.lfinger);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' left finger.');
    end;

    if sleeper.rfinger > 0 then
    begin
      load_objekt(objekt^, fingers, sleeper.rfinger);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' right finger.');
    end;

    if sleeper.legs > 0 then
    begin
      load_objekt(objekt^, legs, sleeper.legs);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a pair of ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' legs.');
    end;

    if sleeper.feet > 0 then
    begin
      load_objekt(objekt^, feet, sleeper.feet);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a pair of ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' feet.');
    end;

    if sleeper.waist > 0 then
    begin
      load_objekt(objekt^, waist, sleeper.waist);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' around ' + sex3[sleeper.sex] + ' waist.');
    end;

    if sleeper.neck > 0 then
    begin
      load_objekt(objekt^, neck, sleeper.neck);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' around ' + sex3[sleeper.sex] + ' neck.');
    end;

    if sleeper.neck2 > 0 then
    begin
      load_objekt(objekt^, neck, sleeper.neck2);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' around ' + sex3[sleeper.sex] + ' neck.');
    end;

    if sleeper.face > 0 then
    begin
      load_objekt(objekt^, face, sleeper.face);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' face.');
    end;

    if sleeper.shield > 0 then
    begin
      load_objekt(objekt^, shield, sleeper.shield);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' also carries a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, '.');
    end;

    if sleeper.hands > 0 then
    begin
      load_objekt(objekt^, hands, sleeper.hands);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' on ' + sex3[sleeper.sex] + ' hands.');
    end;

    if sleeper.abody > 0 then
    begin
      load_objekt(objekt^, abody, sleeper.abody);
      sd(global_plycol, sleeper.name2);
      sd(config.textcolor, ' has a ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      d(config.textcolor, ' around ' + sex3[sleeper.sex] + ' body.');
    end;

    {remove pointer variable}
    dispose(objekt);

  end;

  pause;

 {display thieving objects, player might be interested in stuff they
  can attempt to steal}

  {healing potions}
  if sleeper.healing > 0 then
  begin
    crlf;
    sd(config.textcolor, 'You notice a belt with ' + ucyan + 'healing potions' + config.textcol1 + ' stuck under ');
    sd(global_plycol, sleeper.name2 + 's');
    d(config.textcolor, ' pillow.');
  end;

  {purse with gold}
  if sleeper.gold > 0 then
  begin
    d(config.textcolor, 'You also notice ' + uplc + sleeper.name2 + config.textcol1 + ' holding a ' +
      ucyan + 'purse' + config.textcol1 + ' in ' + sex3[sleeper.sex] + ' right hand.');
    d(config.textcolor, '(it might just be possible for you to snatch it!)');
  end;

  {married}
  if sleeper.married = True then
  begin
    d(global_plycol, sleeper.name2 + config.textcol1 + ' is wearing a ' + uyellow + 'wedding ring' +
      config.textcol1 + ', and it''s made of solid gold.');
  end;

  crlf;
  case random(4) of
    0: begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' is snoring...');
    end;
    1: begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' is sleeping very deep..');
    end;
    2: begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' is sleeping like a baby..');
    end;
    3: begin
      sd(global_plycol, sleeper.name2);
      d(config.textcolor, ' is breathing heavily..');
    end;
  end; {case .end.}

       {could player beat sleeper?}
  crlf;
  pause;

end; {sleep_dormitory *end*}

procedure Chances_Eval(var ply: userrec);
var s: s70;
begin
  {can player kill this guy, used from the DORMITORY!}
  if ply.sex = 1 then
    s := 'guy'
  else s := 'gal';

  if player.maxhps > ply.maxhps then
  begin
    d(9, ' - you can beat this ' + s + '!');
  end else
  if player.maxhps < ply.maxhps then
  begin
    d(12, ' -  don''t even try...');
  end else
  begin
    d(9, ' - should be an even match');
  end;
end;


procedure Battle_Comment;
const mean1 = 'Are you trying to kill me? ';
var
  slask: s70;

begin

    {* produces fit random comments during player_vs_player battle *}
  case mode of
    {player uttalar bara generella elakheter}
    1: begin
      case random(9) of
        0: begin
          sd(global_talkcol, mean1);
          sd(global_plycol, player);
          d(config.textcolor, ' says.');
        end;
        1: begin
          sd(global_talkcol, 'You''re dead meat buddy!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams');
        end;
        2: begin
          sd(global_talkcol, 'You''re good for nothing!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams');
        end;
        3: begin
          sd(global_talkcol, 'You are one murderous bastard!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams');
        end;
        4: begin
          sd(global_talkcol, 'I have never hurt You!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' cries');
        end;
        5: begin
          sd(global_talkcol, 'Hey...take it easy friend!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' says');
        end;
        6: begin
          sd(global_talkcol, 'You''re a JOKE!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' taunts');
        end;
        7: begin
          sd(global_talkcol, 'Hehehe!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' grins at you');
        end;
        8: begin
          sd(global_talkcol, 'Have you said your prayers?');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' asks not so kindly');
        end;
      end;
    end;
    2: begin
      {player har blivit tr„ffad...}
      case random(13) of
        0: begin
          sd(global_talkcol, 'Arghhh!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams in agony!');
        end;
        1: begin
          sd(global_talkcol, 'You''re killing me!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' complains');
        end;
        2: begin
          sd(global_talkcol, 'Haha! I''m not afraid to die!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' says.');
        end;
        3: begin
          sd(global_talkcol, 'Gosh! I''m really bleeding!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' moans.');
        end;
        4: begin
          sd(global_talkcol, 'Ahh..! Where did all this blood come from?');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        5: begin
          sd(global_talkcol, ' Oh No... I''m hit!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        6: begin
          sd(global_talkcol, 'I''m too good to die!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' cries.');
        end;
        7: begin
          sd(global_talkcol, 'You were lucky with that punch!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        8: begin
          sd(global_talkcol, 'I''m bleeding for crying out loud!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' cries');
        end;
        9: begin
          sd(global_talkcol, 'Nice move chicken brain! You got me!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams');
        end;
        10: begin
          sd(global_talkcol, 'You got some moves, I can tell..');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' whispers.');
        end;
        11: begin
          sd(global_talkcol, 'Bloody Murderer! I''m hurt!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        12: begin
          sd(global_talkcol, 'You got me you RAT!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' cries.');
        end;
      end; {case .end.}
    end;
    3: begin
      {player tr„ffar i sin motst†ndare!}
      case random(12) of
        0: begin
          sd(global_talkcol, 'Haha! Gotcha!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        1: begin
          sd(global_talkcol, 'You''re DEAD MEAT buddy!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        2: begin
          sd(global_talkcol, 'Bah! You are no match for me!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' brags.');
        end;
        3: begin
          sd(global_talkcol, 'Look at You! You''re bleeding! Haha!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' laughs.');
        end;
        4: begin
          sd(global_talkcol, 'Beg for Mercy and I might spare you!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' says.');
        end;
        5: begin
          sd(global_talkcol, 'Your defence STINKS!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        6: begin
          sd(global_talkcol, 'I''m sending you to HELL!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        7: begin
          sd(global_talkcol, 'Good Heavens! You ARE worthless!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' says.');
        end;
        8: begin
          sd(global_talkcol, 'That blow felt Hu? Haha!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' laughs.');
        end;
        9: begin
          sd(global_talkcol, 'I''m not finished with you!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' screams.');
        end;
        10: begin
          sd(global_talkcol, 'I kill you in the next round!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' brags.');
        end;
        11: begin
          sd(global_talkcol, 'You are in for a TREAT friend!');
          sd(config.textcolor, ', ');
          sd(global_plycol, player);
          d(config.textcolor, ' says.');
        end;
      end; {case .end.}
    end;
  end;     {case .end.}

end;

procedure Kill_Comment(var killer: userrec; const victim: s70);
begin

  case random(10) of
    0: begin
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' laughs madly as the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' dies!');
    end;
    1: begin
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' grins evilly as ' + sex2[killer.sex] + ' watches the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' die.');
    end;
    2: begin
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' performs a little wardance when the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' dies!');
    end;
    3: begin
      sd(global_talkcol, 'EASY KILL!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' screams when the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' dies!');
    end;
    4: begin
      sd(global_talkcol, 'AM I GOOD OR WHAT!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' screams as the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' bleeds to death!');
    end;
    5: begin
      sd(global_talkcol, 'I am THE Warrior!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' brags when the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' dies!');
    end;
    6: begin
      sd(global_talkcol, 'Haha!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' laughs when the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' dies!');
    end;
    7: begin
      sd(global_talkcol, 'One Monster Less!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' screams as the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' bleeds to death!');
    end;
    8: begin
      sd(global_plycol, killer.name2);
      sd(config.textcolor, ' struts ' + sex3[killer.sex] + ' stuff when the ');
      sd(global_moncol, victim);
      d(config.textcolor, ' falls!');
    end;
    9: begin
      sd(global_talkcol, 'I WAS BORN FOR THIS!');
      sd(config.textcolor, ', ');
      sd(global_plycol, killer.name2);
      d(config.textcolor, ' screams!');
    end;
    10: begin
      sd(global_plycol, killer.name2);
      d(config.textcolor, ' points at ' + sex4[killer.sex] + ', as if ' + sex2[killer.sex] + ' was something special!');
    end;
  end; {case .end.}

end;   {kill_comment}


procedure Load_MoatId(var temp: MoatRec; IDTAG: s15);
var i:    word;
  Result: boolean;
begin
  {load the Moat Guard with the unique Id-tag IDTAG}

  Result := False;

  for i := 1 to fs(fsMoat) do
  begin
    load_moat(fload, temp, i);
    if (temp.Id = IDTAG) and
      (temp.deleted = False) and
      (temp.Name <> '') then
    begin
      Result := True;
      break;
    end;
  end; {for i:= .end.}

end;   {load_moatid *end*}

function Find_MoatId(IDTAG: s15): boolean;
var i:    word;
  Result: boolean;
  temp:   MoatRec;
begin
  {looks for a MoatGuard with ID-tag IDTAG }

  Result := False;

  for i := 1 to fs(fsMoat) do
  begin
    load_moat(fload, temp, i);
    if (temp.Id = IDTAG) and
      (temp.deleted = False) and
      (temp.Name <> '') then
    begin
      Result := True;
      break;
    end;
  end; {for i:= .end.}

       {return result}
  find_moatid := Result;

end; {find_moatid *end*}

procedure Deactivate_Player(var ply: userrec);
begin

 {called by INACTIVITY procedure in MAINT.pas
  also called by Suicide.pas and Supreme.pas proc}

  if ply.king = True then
  begin
    {king stuff}
    king_is_gone;
  end;

  ply.deleted := True;     {deleted}
  ply.king := False;    {king}
  ply.cturf := False;    {town control}
  ply.team := emptystr; {teamname} {the team vars are also reseted in tcorner.pas and npcmaint.pas}
  ply.teampw := emptystr; {team password}
  ply.gym_owner := 0; {gym owner}
  ply.gym_card := 0; {gym member card}

  {remove player RELATIONS (RELATION.DAT)}
  remove_relations(ply);

  {make player kids orphants}
  remove_parent(ply);

  {set kids by player free}
  free_kidnapped_children(ply);

  {remove WANTEd posters from/on player}
  remove_wanted_posters(ply);

  {remove player market items}
  remove_PlayerMarketItems(ply);

end; {deactivate_player *end*}


procedure Post_NightMare;
var s: s70;
begin

 {post nightmare, used by Groggo.pas and NpcMaint.pas when people are
  summoning demons against this player, he will get visions and nightmares}

  s := 'Nightmares';
  post(MailSend,
    pl0.name2,
    pl0.ai,
    False,
    mailrequest_nothing,
    '',
    umailheadc + s + config.textcol1,
    mkstring(length(s), underscore),
    'You have been plagued by bad dreams the last nights!',
    'You have all reasons to be afraid...something is',
    'out there waiting for you...',
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

end; {post_nightmare *end*}

function How_Many_XP_Left(desired_level: integer; my_exp: longint): longint;
var x:   longint;
  level: levelrec;
begin
  {how many xp left before I reach DESIRED_LEVEL}
  load_level(desired_level, level);

  x := level.xpneed - my_exp;
  if x < 0 then
    x := 0;

  {return result}
  how_many_xp_left := x;

end; {how_many_xp_left}

function Level_Raise(levelst: word; inn: longint): longint;
var
  exp:   longint;
  level: levelrec;

begin

  load_level(levelst, level);

  exp := level.xpneed;

  if inn < exp then
    level_raise := exp - inn
  else level_raise := 0;


  if levelst >= 100 then
    level_raise := 999999999;

end; {level_raise *end*}

procedure Raise_Player; {a player or offline character raises one or several
                         levels.}
var

  a, s:           s90;

  memex, fakexp, x, cp, i, j, rand, z, q, zz, yy, xx: longint;

  right, fakelev: integer;

  nec, tries:     byte;

  found:          boolean;

begin

 {raise player "happy"s level, or levels...
  if paper=true then put the story in the paper
  if mailman=true then post a letter to the player
  if realtime=true then player has requested level raise online
  if mailteam=true then inform team mates of raise}

  if level_raise(happy.level, happy.exp) <> 0 then
  begin
    {we jump out if no level raise is going to take place}
    exit;
  end;

  fakexp := happy.exp;
  fakelev := happy.level;
  right := 1;

  {calculate number of levels player can raise}
  repeat
    Inc(fakelev);
    x := level_raise(fakelev, fakexp);
    if x = 0 then
    begin
      Inc(right);
    end;
  until (fakelev > 98) or (x <> 0);

  if realtime then
  begin
    d(global_talkcol, 'and you fully deserve a raise.');

    if right > 1 then
    begin
      sd(11, 'You have earned ');
      sd(14, commastr(right));
      d(11, ' levels!');
      if confirm('Raise all levels at once', 'Y') = False then
      begin
        right := 1;
      end;
    end;

    sd(global_talkcol, 'You are now a level ');
    d(15, commastr(happy.level + right));
    d(global_talkcol, classnames[happy.class] + '!');

    if right = 1 then
    begin
      sd(config.textcolor, 'You raised ');
      sd(15, commastr(right));
      d(config.textcolor, ' level.');

      {broadcast level raise}
      online_send_to_all(uplc + onliner.Name + config.textcol1 + ' raised a level!', onliner.Name, '');

    end else
    begin
      sd(config.textcolor, 'You raised ');
      sd(15, commastr(right));
      d(config.textcolor, ' levels.');

      {broadcast level raise}
      online_send_to_all(uplc + onliner.Name + config.textcol1 + ' raised ' + commastr(right) + ' levels!', onliner.Name, '');
    end;

    crlf;
    pause;
  end;

  {choose what abilities to improve in a future version?}

  {** increase of abilities depending on class **}
  Inc(happy.level, right);
  cp := 0;
  case happy.class of
    Alchemist: begin
      i := 2;
      j := 2;
      x := 2;
      rand := 1;
      z := 1;
      q := 3;
      zz := 1;
      yy := 5;
      cp := 0;
    end;
    Assassin: begin
      i := 3;
      j := 3;
      x := 4;
      rand := 3;
      z := 4;
      q := 1;
      zz := 3;
      yy := 1;
      cp := 0;
    end;
    Barbarian: begin
      i := 7;
      j := 5;
      x := 5;
      rand := 5;
      z := 2;
      q := 1;
      zz := 1;
      yy := 1;
      cp := 0;
    end;
    Bard: begin
      i := 5;
      j := 3;
      x := 3;
      rand := 2;
      z := 3;
      q := 3;
      zz := 3;
      yy := 3;
      cp := 0;
    end;
    Cleric: begin
      i := 6;
      j := 3;
      x := 3;
      rand := 3;
      z := 2;
      q := 5;
      zz := 2;
      yy := 3;
      cp := 10;
    end;
    Jester: begin
      i := 4;
      j := 3;
      x := 5;
      rand := 1;
      z := 5;
      q := 5;
      zz := 1;
      yy := 0;
      cp := 0;
    end;
    Magician: begin
      i := 4;
      j := 1;
      x := 2;
      rand := 1;
      z := 2;
      q := 2;
      zz := 2;
      yy := 5;
      cp := 20;
    end;
    Paladin: begin
      i := 6;
      j := 4;
      x := 4;
      rand := 4;
      z := 2;
      q := 3;
      zz := 1;
      yy := 1;
      cp := 0;
    end;
    Ranger: begin
      i := 6;
      j := 3;
      x := 4;
      rand := 4;
      z := 3;
      q := 3;
      zz := 2;
      yy := 5;
      cp := 0;
    end;
    Sage: begin
      i := 4;
      j := 2;
      x := 2;
      rand := 1;
      z := 2;
      q := 2;
      zz := 2;
      yy := 5;
      cp := 25;
    end;
    Warrior: begin
      i := 6;
      j := 4;
      x := 4;
      rand := 4;
      z := 4;
      q := 1;
      zz := 3;
      yy := 1;
      cp := 0;
    end;
  end; {case .end.}

 {change the above given values, depending on choosen Level Master,
  Akrappa is the default master}

  i := i * right;
  j := j * right;
  x := x * right;
  rand := rand * right;
  z := z * right;
  q := q * right;
  zz := zz * right;
  yy := yy * right;
  cp := cp * right;

 {hps=i
  commastr=j
  def=x
  stamina=rand
  agility=z
  charisma=q
  dexterity=zz
  wisdom=yy
  mana=cp}

  {happy.master = '0' {Akrappa, default}
  case happy.master of
    '0': begin {Akrappa}
        {Akrappa is the default Master. The values change
        in reference to him.}
    end;
    '1': begin {Singuman}
      for nec := 1 to right do
      begin
        Inc(i);
        Inc(j);
        Inc(x);
        q := 0;
        if cp > 0 then
          Dec(cp, 5);
      end;
    end;
    '2': begin {Ishana}
      for nec := 1 to right do
      begin
        Dec(i, 2);
        Dec(j);
        Dec(x);
        Inc(rand, 2);
        Inc(z);
        Inc(q);
        Inc(yy, 2);
        if cp > 0 then
          Inc(cp, 5);
      end;
    end;
    '3': begin {Dzarrgo}
      for nec := 1 to right do
      begin
        Inc(i, 2);
        Inc(j);
        Dec(x, 2);
        Inc(rand);
        Inc(zz);
        Dec(z);
        yy := 0;
        if cp > 0 then
          Inc(cp, 8);
      end;
    end;
    '4': begin {Agni}
      for nec := 1 to right do
      begin
        Dec(i);
        Dec(j);
        Dec(x, 2);
        Inc(rand, 3);
        Inc(z, 2);
        Inc(yy, 3);
      end;
    end;
    '5': begin {Apollonia}
      for nec := 1 to right do
      begin
        Inc(i, 2);
        Inc(j);
        Inc(x, 2);
        rand := 1;
        z := 1;
        yy := 1;
        if cp > 0 then
          Inc(cp, 7);
      end;
    end;
    '6': begin {Sachmez}
      for nec := 1 to right do
      begin
        i := 1;
        j := 1;
        x := 1;
        q := 0;
        Inc(z, 3);
        Inc(yy, 3);
        Inc(zz, 3);
        if cp > 0 then
          Inc(cp, 12);
      end;
    end;
    '7': begin {Umilak}
      for nec := 1 to right do
      begin
        i := 1;
        Inc(j, 2);
        Inc(x);
        z := 1;
        Inc(yy);
        zz := 0;
        q := 0;
        if cp > 0 then
          Inc(cp, 14);
      end;
    end;
    '8': begin {Asanga}
      for nec := 1 to right do
      begin
        Dec(i);
        Dec(j);
        Inc(q);
        if cp > 0 then
          Inc(cp, 11);
      end;
    end;
    '9': begin {Gregorius}
      for nec := 1 to right do
      begin
        Inc(i, 2);
        Inc(x, 2);
        Inc(z, 2);
        yy := 0;
        Inc(q, 3);
      end;
    end;

  end; {case .end.}

       {Drug Users and Body Builders are punished!}
  if happy.mental < 70 then
  begin
    for nec := 1 to right do
    begin
      Dec(i);
      Dec(j);
      Dec(x);
      Dec(rand);
      Dec(z);
      Dec(q);
      Dec(zz);
      Dec(yy);
      Dec(cp);
    end; {for nec:= .end.}
  end;

  if happy.addict > 50 then
  begin
    for nec := 1 to right do
    begin
      Dec(i);
      Dec(j);
      Dec(x);
      Dec(rand);
      Dec(z);
      Dec(q);
      Dec(zz);
      Dec(yy);
      Dec(cp);
    end;
  end;

  {limits!}
  if happy.hps > 5000 then
    i := 0;
  if happy.strength > 5000 then
    j := 0;
  if happy.defence > 5000 then
    x := 0;
  if happy.stamina > 5000 then
    rand := 0;
  if happy.agility > 5000 then
    z := 0;
  if happy.charisma > 5000 then
    q := 0;
  if happy.dex > 5000 then
    zz := 0;
  if happy.wisdom > 5000 then
    yy := 0;
  if happy.maxmana > 5000 then
    cp := 0;

  if realtime then
  begin
    crlf;
    d(10, 'Congratulations!');

  end;

  if i > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your hps increased by ' + commastr(i) + '!');
    Inc(happy.maxhps, i);
    happy.hps := happy.maxhps;
  end;

  if j > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your strength increased by ' + commastr(j) + '!');
    Inc(happy.strength, j);
  end;

  if x > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your defence increased by ' + commastr(x) + ' !');
    Inc(happy.defence, x);
  end;

  if rand > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your stamina increased by ' + commastr(rand) + ' !');
    Inc(happy.stamina, rand);
  end;

  if z > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your agility increased by ' + commastr(z) + ' !');
    Inc(happy.agility, z);
  end;

  if q > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your charisma increased by ' + commastr(q) + ' !');
    Inc(happy.charisma, q);
  end;

  if zz > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your dexterity increased by ' + commastr(zz) + ' !');
    Inc(happy.dex, zz);
  end;

  if yy > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your wisdom increased by ' + commastr(yy) + ' !');
    Inc(happy.wisdom, yy);
  end;

  if happy.addict > 0 then
  begin
    for nec := 1 to right do
    begin
      happy.addict := happy.addict - (random(5) + 1);
      if happy.addict < 0 then
        happy.addict := 0;
    end;
    if realtime then
      d(config.textcolor, 'Your Drug Addiction decreased!');
  end;

  if happy.mental < 100 then
  begin
    for nec := 1 to right do
    begin
      happy.mental := happy.mental + (random(5) + 1);
      if happy.mental > 100 then
        happy.mental := 100;
    end;
    if realtime then
      d(config.textcolor, 'Your Mental Stability increased!');
  end;

  if cp > 0 then
  begin
    if realtime then
      d(config.textcolor, 'Your mana increased by ' + commastr(cp) + ' !');
    Inc(happy.maxmana, cp);
    happy.mana := happy.maxmana;
  end;

  memex := 0;
  for nec := 1 to right do
  begin
    xx := happy.level * 5000 + random(10000);
    if happy.race = gnoll then
      xx := xx + random(22000);
    incplayermoney(happy, xx);
    Inc(memex, xx);
  end;

  if realtime then
  begin
    sd(config.textcolor, 'You also receive ');
    sd(14, commastr(memex));
    d(config.textcolor, ' ' + many_money(memex) + '.');
    crlf;
    pause;
  end;

  {spell training?}
  if happy.class in [Cleric, Magician, Sage] then
  begin
    q := 0;
    for nec := 1 to global_maxspells do
    begin
      if happy.level >= level_needed(happy.class, nec) then
      begin
        if happy.spell[nec, 1] = False then
        begin
          happy.spell[nec, 1] := True;
          if realtime then
          begin
            sd(14, 'You have learned a new spell - ');
            d(11, spell_name(happy.class, nec));
          end;
        end;
      end;
    end; {for nec:= .end.}

  end;

  {2 close-combat lessons}
  for nec := 1 to right do
  begin
    Inc(happy.trains, 2);
  end;

  {lets auto-train if its a NPC}
  if (happy.ai = 'C') and (happy.trains > 0) then
  begin

    {d(15,happy.name2+' trains close-combat moves!');}

    {is this guy full trained?}
    found := False;
    for i := 1 to global_maxcombat do
    begin
      if happy.skill[i] < 16 then
      begin
        found := True;
        break;
      end;
    end;

    {this guy needs training}
    if found then
    begin
      {what move should we train}
      found := False;
      x := 0;
      tries := 0;
      repeat
        z := random(global_maxcombat) + 1;
        Inc(tries);

        if happy.skill[z] < 16 then
        begin
          found := True;
          x := z;
        end;

      until (found) or (tries > 100);

      if x > 0 then
      begin
        repeat
          Dec(happy.trains);
          Inc(happy.skill[x]);
        until (happy.trains < 1) or (happy.skill[x] > 16);
      end;

    end;

  end;

  if realtime then
  begin
    d(14, 'You have earned some Hand-to-Hand combat lessons!');
    d(config.textcolor, '(Train with the Masters at the Marketplace!)');
    crlf;
    pause;
  end;

  if paper then
  begin {put the raise in the NEWS}
    str(happy.level, a);
    if happy.chiv > happy.dark then
    begin
      if right = 1 then
      begin
        s := ' The famous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
          config.textcol1 + ' went up a level!';
      end else
      begin
        s := ' The famous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
          config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
      end;
    end else
    begin
      if happy.chiv > happy.dark then
      begin
        x := random(6);
        case x of
          0: begin
            if right = 1 then
            begin
              s := ' The glorious ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The glorious ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          1: begin
            if right = 1 then
            begin
              s := ' The warm-hearted ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The warm-hearted ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          2: begin
            if right = 1 then
            begin
              s := ' The kind ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
                config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The kind ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
                config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          3: begin
            if right = 1 then
            begin
              s := ' The good ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
                config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The good ' + urac + race_display(2, happy.race, 0) + ' ' + uplc + happy.name2 +
                config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          4: begin {alternatives..}
            if right = 1 then
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] + ' went up a level!';
            end else
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] +
                ' went up ' + uwhite + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          5: begin
            if right = 1 then
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] + ' raised a level!';
            end else
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] +
                ' raised ' + uwhite + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;

        end; {case .end.}

      end else
      begin
        x := random(6);
        case x of
          0: begin
            if right = 1 then
            begin
              s := ' The infamous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The infamous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          1: begin
            if right = 1 then
            begin
              s := ' The notorious ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The notorious ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          2: begin
            if right = 1 then
            begin
              s := ' The self-absorbed ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The self-absorbed ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          3: begin
            if right = 1 then
            begin
              s := ' The self-righteous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' went up a level!';
            end else
            begin
              s := ' The self-righteous ' + urac + race_display(2, happy.race, 0) + ' ' + uplc +
                happy.name2 + config.textcol1 + ' raised ' + uyellow + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          4: begin {alternatives..}
            if right = 1 then
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] + ' went up a level!';
            end else
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] +
                ' went up ' + uwhite + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;
          5: begin
            if right = 1 then
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] + ' raised a level!';
            end else
            begin
              s := ' ' + uplc + happy.name2 + config.textcol1 + ' the ' + classnames[happy.class] +
                ' raised ' + uwhite + commastr(right) + config.textcol1 + ' levels!';
            end;
          end;

        end; {case .end.}

      end;

    end;

    if helper <> '' then
    begin
      a := ' ' + uplc + helper + config.textcol1 + ' arranged the summoning.';
    end else
    begin
      {make a phrase to put in the news}
      a := '';
      case random(20) of
        0: a := ' ' + utalkc + 'Look at me! Look at me! I''m bad to the bone! ' + uplc + happy.name2 +
            config.textcol1 + ' boasts.';
        1: a := ' ' + utalkc + 'I''m finally getting somewhere! ' + uplc + happy.name2 + config.textcol1 + ' mumbles.';
        2: a := ' ' + utalkc + 'I''m finally getting somewhere! ' + uplc + happy.name2 + config.textcol1 + ' mutters.';
        3: a := ' ' + utalkc + 'I''m calling the shots around here now! ' + uplc + happy.name2 + config.textcol1 + ' brags.';
        4: a := ' ' + utalkc + 'Oh Boy! Finally level ' + commastr(happy.level) + '! ' + uplc +
            happy.name2 + config.textcol1 + ' sighs.';
        5: a := ' ' + utalkc + 'Boy! I earned this! ' + uplc + happy.name2 + config.textcol1 + ' shouts with joy.';
        6: a := ' ' + utalkc + 'I deserved this. ' + uplc + happy.name2 + config.textcol1 + ' concludes.';
        7: a := ' ' + utalkc + 'You can''t push me around anymore. ' + uplc + happy.name2 + config.textcol1 + ' says.';
        8: a := ' ' + utalkc + 'I am destined for Greatness! ' + uplc + happy.name2 + config.textcol1 + ' boasts.';
        9: a := ' ' + utalkc + 'There is no telling how far I can go! ' + uplc + happy.name2 + config.textcol1 + ' boasts.';
        10: a := ' ' + utalkc + 'There is no stopping me now! ' + uplc + happy.name2 + config.textcol1 + ' proclaims.';
        else a := '';

      end; {case .end.}

    end;

    {news-paper}
    newsy(True,
      config.textcol1 + 'Level Raise!',
      s,
      a, {automated comment}
      '',
      '',
      '',
      '',
      '',
      '',
      '');
  end;

  if (mailteam = True) and (happy.team <> '') then
  begin
    {inform player "Happys" team mates of his level raise}
    Team_Report_All(
      happy.team,          {team to send message to}
      happy.name2,         {exclude player name}
      'Team Success!',     {letter head}
      mailrequest_nothing, {mailrequest_constant}
      uplc + happy.name2 + config.textcol1 + ' raised a level!', {line1}
      '',                  {line2}
      '',                  {line3}
      '');                 {line4}

  end;

  if mailman then
  begin
    if helper <> '' then
      s := uplc + helper + config.textcol1 + ' took you to your Level Master!'
    else s := '';

    a := 'level';
    if right > 1 then
      a := a + 's';

    {post a letter to player}
    post(MailSend,
      happy.name2,
      happy.ai,
      False,
      mailrequest_nothing,
      '',
      umailheadc + 'Level Raise!' + config.textcol1,
      mkstring(12, underscore),
      'You raised ' + uwhite + commastr(right) + config.textcol1 + ' ' + a + '!',
      s,
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

  {Save The Character}
  user_save(happy);

  {let fake players congratulate or scorn "happy"}
  if realtime then
  begin
    fakeplayers_congratulate_levelraiser(happy);
  end;

end; {Raise_Player *end*}

function Quest_DiffString(diff: byte; recstr: boolean): s90;
var s: s90;
begin

  case diff of
    1: begin
      s := 'very easy';
    end;
    2: begin
      s := 'easy';
      if recstr then
        s := s + '  (recommended to level +5 characters)';
    end;
    3: begin
      s := 'fairly easy';
      if recstr then
        s := s + '  (recommended to level +15 characters)';
    end;
    4: begin
      s := 'moderate';
      if recstr then
        s := s + '  (recommended to level +25 characters)';
    end;
    5: begin
      s := 'challenging';
      if recstr then
        s := s + '  (recommended to level +35 characters)';
    end;
    6: begin
      s := 'complicated';
      if recstr then
        s := s + '  (recommended to level +45 characters)';
    end;
    7: begin
      s := 'serious';
      if recstr then
        s := s + '  (recommended to level +55 characters)';
    end;
    8: begin
      s := 'dangerous';
      if recstr then
        s := s + '  (recommended to level +65 characters)';
    end;
    9: begin
      s := 'hard';
      if recstr then
        s := s + '  (recommended to level +75 characters)';
    end;
    10: begin
      s := 'very hard';
      if recstr then
        s := s + '  (recommended to level +85 characters)';
    end;
  end; {case .end.}

       {return result}
  quest_diffstring := s;

end; {quest_diffstring *end*}

function Quest_Target(Target: QuestTargets): s90;
var s: s90;
begin

  {init}
  s := '{UNKNOWN}';

  case Target of
    qMonster: s := 'Kill Monsters.';
    qAssassin: s := 'Assassination.';
  end;

  {return result}
  quest_target := s;

end; {quest_target *end*}

function Claimed_Quests(const Name: s30): word;
var
  i, Result: word;
  quest:     QuestRec;
begin

  {this function returns the number of quests player NAME has claimed}

  {init vars}
  Result := 0;

  for i := 1 to fs(fsquest) do
  begin
    load_quest(fload, quest, i);

    if (quest.deleted = False) and (quest.occupier = Name) then
    begin
      Inc(Result);
    end;

  end; {for i:= .end}

       {return result}
  claimed_quests := Result;

end; {claimed_quests *end*}

procedure Display_Quest(const quest: questrec; questnr: word);
var s: s90;
begin

  {quest}
  sd(15, commastr(questnr) + '. ');

  {mission}
  s := Quest_Target(quest.questtarget);

  d(12, 'Mission    ' + config.textcol1 + ': ' + ulcyan + s + config.textcol1);

  {comment}
  if quest.comment <> '' then
  begin
    d(config.textcolor, '   Comment    : ' + utalkc + quest.comment + config.textcol1);
  end;

  {difficulty}
  s := quest_diffstring(quest.difficulty, True);

  d(config.textcolor, '   Difficulty : ' + uwhite + s + config.textcol1);

  {claimed by}
  if quest.occupier = '' then
    s := '{nobody}'
  else s := quest.occupier + config.textcol1 + ', the ' + race_display(2, quest.occrace, 0) + '.';

  d(config.textcolor, '   Claimed by : ' + uplc + s + config.textcol1);

  {end crlf}
  crlf;

end; {display_quest *end*}

function Grab_Quest(const ply: userrec; nr: word): boolean;
var
  ok:    boolean;
  quest: questrec;
begin

  {init varas}
  ok := False;

  {lock quest-file}
  if Lock_QuestFile(FLock) = False then
  begin
    unable_to_access(global_rquestf, 5);
  end else
  begin

    {load quest}
    load_QuestFile(fload, quest, nr);

    {is quest available}
    if (quest.occupier = '') and
      (quest.deleted = False) then
    begin
      ok := True;
    end;

    if ok then
    begin
      {set quest to busy}
      quest.occupier := ply.name2;
      quest.occrace := ply.race;
      quest.occsex := ply.sex;

      {save quest}
      load_QuestFile(fsave, quest, nr);
    end;

    {unlock quest-file}
    Lock_QuestFile(FUnLock);

  end;

  {return result}
  grab_quest := ok;

end; {grab_quest *end*}

procedure List_Quests(IncludeClaimed: boolean);
{both the king and the ordinary players use this procedure}
var counter, counter2: word;
  pause_counter: byte;
  i, j:    word;
  memsize: word;
  quest:   QuestRec;
  x:       longint;
  r:       byte;
  s:       s90;
  king:    kingrec;

  function mini_menu: byte;
  var ch:   char;
    Result: byte;
  begin

    {init}
    Result := 0;

    repeat
      {options}

      menu2('(M)ore  ');
      if player.king then
      begin
        menu2('(D)elete  ');
      end else
      begin
        menu2('(C)laim  ');
      end;
      menu2('(A)bort :');

      {get user-input}
      ch := upcase(getchar);

      if (ch = 'D') and (player.king = False) then
      begin
        ch := ' ';
      end else
      if (ch = 'C') and (player.king = True) then
      begin
        ch := ' ';
      end;

    until ch in [ReturnKey, 'M', 'C', 'D', 'A'];

    crlf;
    {evaluate user-input}
    case ch of
      'A': begin {abort}
        Result := 2;
      end;
      'C': begin {claim}
        Result := 1;
      end;
      'D': begin {delete}
        Result := 3;
      end;

    end; {case .end.}

         {return result}
    mini_menu := Result;

  end; {mini_menu *end*}

var go_on: boolean;
begin {LIST_QUESTS **START**}

  crlf;
  crlf;
  d(5, 'Royal Quests');
  d(5, mkstring(12, underscore));

  {init}
  counter := 0;
  pause_counter := 2;
  memsize := fs(fsquest);

  for i := 1 to fs(fsquest) do
  begin

    {load quest}
    load_quest(fload, quest, i);

    go_on := True;
    if (IncludeClaimed = False) and (quest.occupier <> '') then
    begin
      go_on := False;
    end;

    if (quest.deleted = False) and (go_on) then
    begin

      {headline}
      if counter = 0 then
      begin

      end;

      {counter}
      Inc(counter);

      Inc(pause_counter, 6);

      {display quest}
      display_quest(quest, counter);

    end;

    if (pause_counter > global_screenlines - 2) or
      (i = memsize) then
    begin

      if (i = memsize) and (counter = 0) then
      begin
        d(12, 'No Quests available!');
      end else
      begin

        {himmler}
        pause_counter := 0;

        r := mini_menu;

        if r = 1 then
        begin
          {claim quest}

    {we need to check if player already have claimed more than
     Config.MaxClaimedQuests}
          if claimed_quests(player.name2) >= Config.MaxClaimedQuests then
          begin
            crlf;
            d(12, 'Sorry, You may only be active on ' + uwhite + commastr(Config.MaxClaimedQuests) +
              ulred + ' Quests at the same time.');
            pause;
          end else
          begin
            crlf;
            sd(3, 'Claim #:');
            x := get_number(0, 65500);

            if x > 0 then
            begin

              counter2 := 0;
              for j := 1 to fs(fsquest) do
              begin

                {load quest}
                load_quest(fload, quest, j);

                go_on := True;
                if (IncludeClaimed = False) and (quest.occupier <> '') then
                begin
                  go_on := False;
                end;

                if (quest.deleted = False) and (go_on) then
                begin

                  Inc(counter2);

                  if counter2 = x then
                  begin
                    crlf;
                    s := '+CLAIM QUEST+';
                    d(14, s);
                    d(14, mkstring(length(s), underscore));
                    display_quest(quest, counter2);

                    if player.king = True then
                    begin
                      d(12, 'The Royals are forbidden by law to undertake Quests!');
                      crlf;
                      pause;
                    end else
                    if quest.initiator = player.name2 then
                    begin
                      d(12, 'You can''t undertake your own Quests!');
                      crlf;
                      pause;
                    end else
                    if quest.occupier = player.name2 then
                    begin
                      d(global_plycol, 'You' + ulred + ' have already claimed this Quest!');
                      crlf;
                      pause;
                    end else
                    if quest.occupier <> '' then
                    begin
                      d(global_plycol, quest.occupier + ulred + ' has claimed this Quest!');
                      crlf;
                      pause;
                    end else
                    if player.level < quest.minlevel then
                    begin
                      d(12, 'Sorry, this Quest requires a character of at least level ' + commastr(quest.minlevel) + '.');
                      pause;
                    end else
                    if player.level > quest.maxlevel then
                    begin
                      d(12, 'Sorry, this Quest requires a character of max level ' + commastr(quest.maxlevel) + '.');
                      pause;
                    end else
                    if confirm('Claim this', 'N') = True then
                    begin
                      if quest.daystocomple = 1 then
                        s := 'day'
                      else s := 'days';


                      if grab_quest(player, j) then
                      begin
                        {quest undertaken}
                        d(15, 'Ok.');
                        d(15, 'You have ' + commastr(quest.daystocomple) + ' ' + s + ' to complete this Quest.');

                        {tell other nodes}
                        online_send_to_all(uplc + player.name2 + config.textcol1 + ' accepted a ' +
                          uquestc + 'QUEST' + config.textcol1 + '!',
                          player.name2, '');

                        {mail the king, if he's online}
                        load_king(fload, king);

                        if (king.Name <> '') and
                          (king.ai = 'H') then
                        begin

                          if is_online(king.Name, online_player) = False then
                          begin

                            {mail}
                            s := 'QUEST Accepted';

                            post(MailSend,
                              king.Name,
                              king.ai,
                              False,
                              mailrequest_nothing,
                              '',
                              uquestc + 'QUEST' + umailheadc + ' Accepted' + config.textcol1,
                              mkstring(length(s), underscore),
                              uplc + player.name2 + config.textcol1 + ' accepted a ' + uquestc +
                              'QUEST' + config.textcol1 + '!',
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
                      end else
                      begin
           {unable to lock this quest, perhaps somebody else beat the
            player to it. The king might have deleted/removed the quest}
                        d(12, 'Unable to claim this Quest!');
                      end;

                      {news-paper}
                      Newsy(True,
                        'Quest Accepted',
                        ' ' + uplc + player.name2 + config.textcol1 + ' has undertaken a ' +
                        uquestc + 'Quest' + config.textcol1 + '!',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '');

                      {end pause}
                      pause;

                    end;
                  end;

                end;

              end; {for j:= .end.}

            end;
          end;

        end else
        if r = 3 then
        begin
          {delete quest}
          crlf;
          sd(3, 'Delete #:');
          x := get_number(0, 65500);

          if x > 0 then
          begin

            counter2 := 0;
            for j := 1 to fs(fsquest) do
            begin

              {load quest}
              load_quest(fload, quest, j);

              if quest.deleted = False then
              begin
                Inc(counter2);

                if counter2 = x then
                begin
                  crlf;
                  s := '-REVOKE QUEST-';
                  d(12, s);
                  d(12, mkstring(length(s), underscore));
                  display_quest(quest, counter2);
                  crlf;

                  if confirm('Remove Quest', 'N') = True then
                  begin

                    {inform occupier of removal of his quest}
                    if quest.occupier <> '' then
                    begin
                      crlf;
                      d(global_plycol, quest.occupier + config.textcol1 + ' has been informed of your decision.');

                      if is_online(quest.occupier, online_player) then
                      begin
                        online_send_to_player(quest.occupier, online_player, uplc + player.name2 +
                          config.textcol1 + ' revoked your ' + uquestc + 'QUEST' + config.textcol1 + '!');
                      end else
                      begin
                        {mail quest occupier}
                        post(MailSend,
                          quest.occupier,
                          'H',
                          False,
                          mailrequest_nothing,
                          '',
                          ulred + 'QUEST gone' + config.textcol1,
                          mkstring(10, underscore),
                          uplc + player.name2 + config.textcol1 + ' revoked your ' + uquestc +
                          'Quest' + config.textcol1 + '!',
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

                    {save quest}
                    quest.deleted := True;
                    load_quest(fsave, quest, j);

                    break;

                  end;

                end;
              end;

            end; {for j:= .end.}
          end;

        end else
        if r = 2 then
        begin
          {abort list}
          break;
        end;
      end;
    end;

  end; {for i:= .end.}

end;   {list_quests *end*}


procedure New_Quest(var quest: QuestRec); {init a Quest-Record}
var i, j: word;
begin

  quest.id := crypt(20);     {unique identification # number}
  quest.Initiator := emptystr; {name of (KING/QUEEN) who set this quest}
  quest.date := todays_date; {init date}
  quest.QuestType := SingleQuest; {single or team effort}
  quest.QuestTarget := qMonster; {monsters,assassinatio,seduce,claim town,gang war}
  quest.difficulty := 0;     {difficulty, especially when encountering monsters}
  quest.deleted := True;     {is this quest deleted}
  quest.comment := emptystr; {comment by initiator}
  quest.occupier := emptystr; {is quest taken at this moment/name of the person}
  quest.occrace := Human;    {occupying players race}
  quest.occsex := 1;         {occupying players sex 1=male,2=female}
  quest.occdays := 0;        {quest has been occupied for X days}
  quest.daystocomple := 0;   {days given to complete quest before failed}

  quest.offerto := emptystr; {is this quest an offer a player}
  quest.offerrefused := 0;   {if offer is refused (1=delete,2=add to list}
  quest.forced := False;     {is quest forced upon OCCUPIER}
  quest.minlevel := 0;       {min level required to take on quest}
  quest.maxlevel := 0;       {max level required to take on quest}

  quest.reward := 1;         {low,medium,high}
  quest.rewardtype := qNothing; {qRewardTypes}

  quest.penalty := 1;        {low,medium,high}
  quest.penaltytype := qNothing; {qRewardTypes}

  for i := 1 to global_maxmon do
  begin
    for j := 1 to 2 do
    begin
      quest.monsters[i, j] := 0; {1=monster file position,2=number of monsters}
    end; {for j:= .end.}
  end; {for i:= .end.}

end; {new quest *end*}

procedure Quest_Maintenance;
var i:   word;
  quest: QuestRec;
  king:  KingRec;
begin

  {run every day. updates the quests. see if players has failed quests}

  for i := 1 to fs(FsQuest) do
  begin

    {load}
    load_quest(fload, quest, i);

    if (quest.deleted = False) and (quest.occupier <> '') then
    begin

      {increase the days the quest has been in action}
      quest.occdays := quest.occdays + 1;

      if quest.occdays > quest.daystocomple then
      begin
        {failure!}

        {mail character who failed}
        post(MailSend,
          quest.occupier,
          'H',
          False,
          mailrequest_nothing,
          '',
          ulred + 'Failed QUEST' + config.textcol1,
          mkstring(12, underscore),
          'You failed your ' + uquestc + 'Quest' + config.textcol1 + '!',
          'You didn''t finish it in time!',
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

        {mail the king}
        if (king.Name <> '') and (king.ai = 'H') then
        begin
          post(MailSend,
            king.Name,
            king.ai,
            False,
            mailrequest_nothing,
            '',
            ulred + 'Failed QUEST' + config.textcol1,
            mkstring(12, underscore),
            uplc + quest.occupier + config.textcol1 + ' failed ' + sex3[quest.occsex] + uquestc +
            ' Quest' + config.textcol1 + '!',
            uplc + quest.occupier + config.textcol1 + ' was unable to finish it in time!',
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

        {news-paper}
        Newsy(True,
          'Quest Failure',
          ' ' + uplc + quest.occupier + config.textcol1 + ' was unable to finish ' + sex3[quest.occsex] +
          uquestc + ' Quest' + config.textcol1 + 'in time.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

    {set quest options, note that the quest is not deleted, just reset and
     ready for a new occupier}
        quest.occupier := '';
        quest.occdays := 0;

      end;

      {save}
      load_quest(fsave, quest, i);

    end;

  end; {for i:= .end.}

end;   {quest_maintenance *end*}

function Random_Drink: s30;
var s:   s30;
  x:     word;
  drink: drinkrec;
begin

  {returns a random drink name, from the user-made cocktails at Orbs}
  {if no user-drinks exist, then we return a random fake name}
 {this function is used when sending poison to other players, in the
 disguise of a free drink.}

  {init}
  s := '';

  if (f_exists(global_drinkfile)) and (fs(fsDrink) > 1) then
  begin

    x := random(fs(fsdrink));

    if x = 0 then
      x := 1;

    load_drink(fload, drink, x);

    s := drink.Name;

  end;

  if s = '' then
  begin

    {no user-created cocktails exist. lets make up a name.}
    case random(22) of
      0: s := 'Impala';
      1: s := 'Slime Bucket';
      2: s := 'Love Potion from Hellbender';
      3: s := 'Neon Dawn';
      4: s := 'Stamina Pusher';
      5: s := 'Hitpoints RAISER!';
      6: s := 'Kicking Mule';
      7: s := 'Die Prinzessin auf der Erbse';
      8: s := 'Mustard Hotdog';
      9: s := 'Raving Lunetic';
      10: s := 'Bobs Bomber *elite*';
      11: s := 'Slash Bomber';
      12: s := 'Demonlord & Heaven';
      13: s := 'Tragic Drug';
      14: s := 'Cocktail Deluxe';
      15: s := 'Smeagols favourite';
      16: s := 'Ramapant Evil';
      17: s := 'Trolls Revenge';
      18: s := 'Gnoll Killer';
      19: s := 'Paladin Nightmare';
      20: s := 'Freak comeback';
      21: s := 'Muffis Drink';
    end; {case .end.}

  end;

  {return result}
  random_drink := s;

end; {random_drink *end*}

procedure Drink_Maintenance;
var i:   word;
  drink: DrinkRec;
begin

  {run every day. updates the drinkfile. delete old drinks}

  for i := 1 to fs(FsDrink) do
  begin

    {load}
    load_drink(fload, drink, i);

    {checking if drink is old and can be discarded}
    if drink.deleted = False then
    begin

      if old_drink(drink) = True then
      begin
        drink.deleted := True;
      end;

      load_drink(fsave, drink, i);

    end;

  end; {for i:= .end.}

end;   {drink_maintenance **end**}

procedure Remove_Wanted_Posters(const ply: userrec);
{remove plys wanted posters (on him)}
var
  i:      word;
  wanted: WantedRec;

begin

  {remove ALL of ply:s wanted posters}

  if f_exists(global_wwfile) = True then
  begin

    for i := 1 to fs(FsWanted) do
    begin

      {load wanted poster}
      load_wanted(fload, wanted, i);

      if (wanted.collected = False) and
        (wanted.Name = ply.name2) then
      begin

        {deactivate wanted poster}
        wanted.collected := True;

        {save wanted poster}
        load_wanted(fsave, wanted, i);

      end;

    end; {for i:= .end.}

  end;

end;

procedure Bad_News(shop: char);
var s: s70;
begin

  case shop of
    'A': s := 'Armor Store';
    'W': s := 'Weapon Store';
  end;

  {player has haggled too much and is now thrown out of the store}

  {News-Paper}
  Newsy(True,
    'Banned from the ' + s,
    ' ' + uplc + player.name2 + config.textcol1 + ' acted like a shameless dog in the ' + s + '.',
    ' Finally some strong clerks kicked ' + sex[player.sex] + ' out!',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

end; {bad_news *end*}

function The_Bad; {The not so gentle descriptions...}
var s: s30;
begin

  s := 'The ill-mannered ';
  case random(21) of
    0: s := 'The ill-mannered ';
    1: s := 'The ill-behaved ';
    2: s := 'The ill-bred ';
    3: s := 'The ill-willed ';
    4: s := 'The ill-natured ';
    5: s := 'The ugly ';
    6: s := 'The mentally dwarfed ';
    7: s := 'The vicious ';
    8: s := 'The hot-tempered ';
    9: s := 'The short-tempered ';
    10: s := 'The touchy ';
    11: s := 'The blunt ';
    12: s := 'The bluff ';
    13: s := 'The untamed ';
    14: s := 'The savage ';
    15: s := 'The uncivilized ';
    16: s := 'The brutal ';
    17: s := 'The notorious ';
    18: s := 'The rock-hearted ';
    19: s := 'The rebellious ';
    20: s := 'The shameless ';
  end; {case .end.}

       {return result}
  the_bad := s;
end; {the_bad *end*}


function Get_NpcInnComment; {get random Npc comment, chatting at the Inn}
const maxcomment = 200;
  npcchatfile    = global_datadir + 'NPCCHAT.DAT';
  {npc chat comments, when chatting at the Inn}

var r:  word;
  i, x: integer;
  s:    string;
  txt:  Text;
begin

  {A maximum of MAXCOMMENTS comments will be used}

  x := 0;
  s := '';

  if f_exists(npcchatfile) = False then
  begin
    {lets create a npc comments file}
    if open_txtfile(trewrite, txt, npcchatfile) then
    begin

      writeln_to_text(txt, 'Hello everybody!');
      writeln_to_text(txt, 'Don''t do that again!');
      writeln_to_text(txt, 'Who stole my equipment!?');
      writeln_to_text(txt, 'Welcome to hell.');
      writeln_to_text(txt, 'I''m for hire today!');
      writeln_to_text(txt, 'You never can guess what I saw today...');
      writeln_to_text(txt, 'Buy some Steroids!');
      writeln_to_text(txt, 'Has anybody visited the new gym yet?');
      writeln_to_text(txt, 'I don''t like this..');
      writeln_to_text(txt, 'I''m the one!');
      writeln_to_text(txt, 'Tell me now!');
      writeln_to_text(txt, 'What are you babbling about!');
      writeln_to_text(txt, 'See ya later dude.');
      writeln_to_text(txt, 'I think I deserve a level raise now.');
      writeln_to_text(txt, 'My Master is not you!');
      writeln_to_text(txt, 'Patience is a virtue.');
      writeln_to_text(txt, 'Dorks!');
      writeln_to_text(txt, 'Haha!');
      writeln_to_text(txt, 'Worthless worms.');
      writeln_to_text(txt, 'I will consume your mother today!');
      writeln_to_text(txt, 'Ho ho ho!');
      writeln_to_text(txt, 'Hi!');
      writeln_to_text(txt, 'Are there any uglies here?');
      writeln_to_text(txt, 'Are you for real?');
      writeln_to_text(txt, 'I''m going to get all of you dirty scumballs!');

      close_text(txt);

    end else
    begin
      unable_to_create(npcchatfile, access_error);
    end;

  end;

  if f_exists(npcchatfile) = True then
  begin

    {checking how many lines .DAT files contains}
    open_txtfile(treset, txt, npcchatfile);
    while not EOF(txt) do
    begin
      Readln_from_text(txt, s);
      Inc(x);
    end;
    close_text(txt);

    {reading random selected line number}
    if x > maxcomment then
      x := maxcomment;
    open_txtfile(treset, txt, npcchatfile);
    r := random(x) + 1;
    for i := 1 to r do
    begin
      readln_from_text(txt, s);
    end;
    close_text(txt);

  end;

  {return result}
  Get_NpcInnComment := s;

end;


procedure Muffis; {Checks if program is registered}
label
  9044,
  9040,
  9039,
  9046,
  8088,
  9045,
  9041;

var
  yy, j, x, y: longint;
  a, bbs, sysop: s70;
  regnr: longint;
  i: integer;

begin

  global_registered := False;

  sysop := cfg_string(1);
  bbs := cfg_string(2);
  a := cfg_string(5);

  regnr := str_to_nr(a);

  {bbs, sysop, regnr}
  global_registered := False;
  if (length(bbs) > 2) and (length(sysop) > 3) then
  begin
    a := bbs + sysop + ' ';
    j := length(a);
    yy := 0;
    x := 0;
    y := 0;
    for i := 1 to length(a) do
    begin
      x := x + (Ord(a[i]) * i);
      yy := yy + (Ord(a[i]) * j);
      j := j - 1;
    end;
    for i := 1 to length(sysop) do
    begin
      x := x + Ord(sysop[i]);
    end;
    goto 9046;
    9044: x := x + Ord(bbs[1]);
    x := x + Ord(sysop[2]);
    x := x * 13;
    Inc(yy, 2);
    x := x div 4;
    x := x * 523;
    9046: x := x + Ord(bbs[1]);
    x := x + Ord(sysop[2]);

    if global_ubeta = False then
    begin
      x := x * 4;
      x := x div 3;
      x := x * 213;
    end else
    begin
      x := x * 123;
    end;

    goto 8088;
    8088: x := x + yy + 1;

  {writeln(x);
  readln(a2);}

    if (x = regnr) and (x <> 0) then
      global_registered := True;
  end;
  if global_registered = True then
    goto 9045;
  9045: global_registered := True;

end; {muffis *end*}

procedure Only_In_Registered_Version;
begin {displayed when players are trying to get to functions only
       available in registered games}
  d(15, 'Sorry, only available in the registered version.');
end; {only_in_registered_version *end*}


{Money stuff}
function Many_Money(const inval: longint): s30;
var Result: s30;
begin

 {depending on inval this function either returns config.moneytype2
  or config.moneytype3}
  if inval <> 1 then
    Result := config.moneytype + ' ' + config.moneytype3
  else Result := config.moneytype + ' ' + config.moneytype2;

  {return result}
  many_money := Result;

end; {many_money *end*}

     {Generic Message Routines}
procedure No_Dark_Deeds;
begin
  {no dark deeds left}
  d(12, 'You have used up all of your Dark Deeds.');
end;

procedure No_Good_Deeds;
begin
  {no good deeds left}
  d(12, 'You have done enough good today. You are exhausted.');
end;

procedure No_Gym_Sessions;
begin
  {no gym sessions left}
  d(12, 'You have used up all of your Gym Sessions.');
end;

procedure No_Intimate_Acts;
begin
  {no intimate acts left today}
  d(12, 'Sorry, you have no intimate sessions left!');
end;

procedure No_Homo_Relations;
begin
  {displayed when homo relations are toggled OFF}
  d(12, 'Homo-sexual relations are not allowed in this realm.');
end;

procedure Cannot_Attack_Husband;
{displayed when spouses try to attack each other}
begin

  {it is presumed that pl1 is player online}

  if pl1.sex <> pl2.sex then
  begin
    case pl1.sex of
      1: d(12, 'You can''t attack your ' + uwhite + 'WIFE' + ulred + '!');
      2: d(12, 'You can''t attack your ' + uwhite + 'HUSBAND' + ulred + '!');
    end; {case .end.}
  end else
  begin
    {gay couple}
    d(12, 'You can''t attack your companion in life!');
  end;

end;


procedure You_Cant_Afford_It;
begin
  {displayed when player can't afford something}
  d(12, 'You can''t afford it!');
end;

procedure Could_Not_Locate_Challengable_Character;
begin
  {displayed when 'search for persons' functions didn't find anything at the dorm}
  d(15, 'Couldn''t locate any challengeable characters!');

end;

procedure Could_Not_Locate_Character;
begin
  {displayed when 'search for persons' functions didn't find anything}
  d(15, 'Couldn''t locate that character!');
end;

procedure Reward_Check;

var
  i:      word;

  Wanted: WantedRec; {Wanted persons are stored in this record}

begin {winner has defeated loser. This proc checks if there are any
       rewards on loser. if so Winner collects the money}

  for i := 1 to fs(FsWanted) do
  begin

    {load wanted record}
    load_wanted(fload, wanted, i);

    if (wanted.Name = loser.name2) and
      (wanted.collected = False) and
      (wanted.mad <> winner.name2) then
    begin

      if (speak) and (winner.name2 = player.name2) then
      begin
        d(9, 'Reward collected!');
        sd(14, commastr(wanted.gold));
        sd(config.textcolor, ' ' + many_money(wanted.gold) + ' has been sent to you from ');
        if wanted.anonym = True then
        begin
          d(10, '*Anonymous*');
        end else
        begin
          sd(global_plycol, wanted.mad);
          d(config.textcolor, '.');
        end;
      end else
      begin
        if winner.ai = 'H' then
        begin

          {Winner is offline and should be informed of collected money!}
          post(MailSend,
            winner.name2,
            winner.ai,
            False,
            mailrequest_nothing,
            '',
            uyellow + 'Reward collected' + ugreen,
            mkstring(16, underscore),
            'You were attacked by ' + uplc + loser.name2 + ugreen + '!',
            'You killed ' + sex[loser.sex] + ' and collected ' + uyellow + commastr(wanted.gold) +
            ugreen + ' ' + many_money(wanted.gold) + ' in ' + ulblue + 'reward' + config.textcol1 + '!',
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

      {Winner gets reward money}
      incplayermoney(winner, wanted.gold);

      wanted.collected := True;
      load_wanted(Fsave, wanted, i);

      {news-paper}
      newsy(True,
        'Reward',
        ' ' + uplc + winner.name2 + ugreen + ' collected the ' + ulblue + 'Reward' + config.textcol1 +
        ' for ' + ulred + loser.name2 + ugreen + '.',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');

      if wanted.ai1 = 'H' then
      begin
        {if the guy who put the reward is online we can put a message out to him}

        if is_online(wanted.mad, online_player) then
        begin
          online_send_to_player(wanted.mad, online_player, uplc + player.name2 + config.textcol1 +
            ' collected your ' + ulblue + 'Reward' + config.textcol1 + ' for ' + uplc + wanted.Name + config.textcol1);
        end;

        {mail the guy who posted the reward}
        post(MailSend,
          wanted.mad,
          wanted.ai1,
          False,
          mailrequest_nothing,
          '',
          uyellow + 'Reward Collected' + ugreen,
          mkstring(16, underscore),
          uplc + winner.name2 + ugreen + ' attacked and killed ' + ulred + loser.name2 + ugreen + '!',
          uplc + winner.name2 + ugreen + ' collected the reward set by You for ' + uyellow +
          commastr(wanted.gold) + ugreen + '.',
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
  end; {for i:= .end.}

end;   {Reward_Check *end*}

procedure Draw_Picture;
begin
  if pic = 'TREASURE-CHEST' then
  begin
    d(14, '        /--------------\ ');
    d(14, '        |___   /\ ___  | ');
    d(14, '        |  ___ ||    __| ');
    d(14, '        |______________| ');
  end;

end;

procedure Numeric_Input_Help; {describes Usurpers numeric input system}
var s: s30;
begin
  {usurpers numeric input systems. current hotkeys are '>', 'K' and 'M'}
  s := 'Numeric Input Help';
  d(7, s);
  d(7, mkstring(length(s), underscore));
  d(config.textcolor, 'Press ' + config.textcol2 + '>' + config.textcol1 + ' for maximum input.');
  d(config.textcolor, 'Press ' + config.textcol2 + 'K' + config.textcol1 + ' for thousand');
  d(config.textcolor, 'Press ' + config.textcol2 + 'M' + config.textcol1 + ' for million');
end;

procedure MemInfo; {good when developing the program}
begin
  {d(14,'Overlay buffer : '+commastr(ovrgetbuf));}
  d(14, 'Mem available  : ' + commastr(memavail));
  d(14, 'Heap available : ' + commastr(maxavail));
end;

procedure Command_Help; {executed when : 'usurper ?' is typed}
const tc = 2;           {help text color}
  hc     = 11;          {keyword color}

  procedure my_pause;
  begin
    wr(7, '[Press a key]');
    readkey;
  end;

begin
  clrscr;
  wrl(2, '');
  wrl(6, 'Usurper, Command Line Parameters');
  wrl(6, mkstring(32, underscore));
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/Bxxxxx');
  wrl(tc, '" This tells Usurper to lock its baud rate at');
  wrl(tc, '  xxxxx.  In order to get the most efficiency out of a high speed');
  wrl(tc, '  error correcting modem (9600 baud or above), you may lock the baud');
  wrl(tc, '  rate to a speed higher than what the caller is actually using.');
  wrl(tc, '  By locking the baud to say 38,400, the modem can compress text data');
  wrl(tc, '  that is being sent and achieve a baud rate much higher than the');
  wrl(tc, '  actual transmission rate.');
  wrl(tc, '  This will lock the baud rate at the same value for all nodes that');
  wrl(tc, '  use this command line.  If you perfer a more selective way to lock');
  wrl(tc, '  baud use ''LOCKBAUD'' command in the USURP.CTL file.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/Cx');
  wrl(tc, '" (where x is 1..4) This specifies a comport number.');
  wrl(tc, '  Some bbs software does not create door information files (dropfiles)');
  wrl(tc, '  that contain the comport number.  If your bbs does have a comport');
  wrl(tc, '  listed in the dropfile then there is no need for this parameter.');
  wrl(tc, '  The default is comport 0, local mode.');

  my_pause;

  wrl(tc, '');
  wr(tc, '"'); wr(hc, '/E');
  wrl(tc, '" Expanded Memory Specification If your machine has over one');
  wrl(tc, '  megabyte of memory, then you may have some available. Usurper can');
  wrl(tc, '  utilize EMS to improve game performance and reduce conventional');
  wrl(tc, '  memory requirements.');
  wrl(tc, '  This command will tell Usurper to use EMS memory to hold its');
  wrl(tc, '  overlay buffer.  Otherwise disc area may be used to hold this buffer.');
  wrl(tc, '  This needs a memory manager and when enabled and is compatible with');
  wrl(tc, '  DESQview.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/X');
  wrl(tc, '" Expanded Memory Specification If your machine has over one');
  wrl(tc, '  megabyte of memory, then you may have some available. Usurper can');
  wrl(tc, '  utilize XMS to improve game performance and reduce conventional');
  wrl(tc, '  memory requirements.');
  wrl(tc, '  This command will tell Usurper to use XMS memory to hold its');
  wrl(tc, '  overlay buffer.  Otherwise disc area may be used to hold this buffer.');
  wrl(tc, '  This needs a memory manager and when enabled and is compatible with');
  wrl(tc, '  DESQview. (XMS memory is faster than EMS memory).');
  wrl(tc, '  You can''t use both /E and /X together.');

  my_pause;

  wrl(tc, '');
  wr(tc, '"'); wr(hc, '/L');
  wrl(tc, '" This tells Usurper to load up in LOCAL mode.');
  wrl(tc, '  This is good for testing or when a sysop just wants to "try out" the');
  wrl(tc, '  door without messing with his BBS setup.  The "/L" mode will ask the');
  wrl(tc, '  user for his name and run the door in local mode.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/Nx');
  wrl(tc, '" (where x is 1..255) This specifies a "node number".');
  wrl(tc, '  Some bbs software support multinode environments in which you must');
  wrl(tc, '  know the node number of the drop file to use. For example, RBBS-PC');
  wrl(tc, '  uses DORINFOx.DEF. If you specified "/N2" then Usurper would use');
  wrl(tc, '  DORINFO2.DEF.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/Mx');
  wrl(tc, '" (where x is up to 2 filename acceptable characters)');
  wrl(tc, '  Used to specify one of Multiple control files.  If you have created');
  wrl(tc, '  more than one GAME.CTL file (GAME1.CTL, GAME2.CTL, etc.) for each');
  wrl(tc, '  node or network PC then you can select the one you want by using');
  wrl(tc, '  the /M parm.');
  wrl(tc, '  Example:  "/M2" will force Usurper to use USURP2.CTL.');
  my_pause;

  wrl(tc, '');
  wr(tc, '"'); wr(hc, '/Pyyy');
  wrl(tc, '" This specifies the path to the drop files.');
  wrl(tc, '  For example, "/PC:\WILDCAT\WCWORK\NODE1" would tell Usurper to');
  wrl(tc, '  look for the drop file in C:\WILDCAT\WCWORK\NODE1. If this is left');
  wrl(tc, '  out the program assumes the drop file is local.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/V');
  wrl(tc, '" This command will tell Usurper not to show any display');
  wrl(tc, '  on the local screen.  Only a colored screen and a message will be');
  wrl(tc, '  displayed.  The cursor will not move as it will be turned off.');
  wrl(tc, '  Saves a little processing on multi-tasking systems.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/W');
  wrl(tc, '" This flags the program that a network is present even');
  wrl(tc, '  though no multitaskers are detected.  This is useful if the door is');
  wrl(tc, '  run on a network such as Novell that doesn''t use multitaskers.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/FMAINT');
  wrl(tc, '" This command is only useful if you have disabled the');
  wrl(tc, '  automatic maintenance. /FMAINT will only start maintenance');
  wrl(tc, '  if it is necessary. It will not run maintenance more than');
  wrl(tc, '  once a day.');
  my_pause;

  wrl(tc, '');
  wr(tc, '"'); wr(hc, '/HMAINT');
  wrl(tc, '" This command will unconditionally force Usurper to perform');
  wrl(tc, '  maintenance.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/SCORES');
  wrl(tc, '" This command will create all external score files.');
  wrl(tc, '  paths and filenames defined using the Editor.EXE program.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_PACKUSERS');
  wrl(tc, '" this command will pack the userfile, removing');
  wrl(tc, '  all deleted and empty records. Don''t execute this');
  wrl(tc, '  command when somebody is playing.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_PACKNPCS');
  wrl(tc, '" this command will pack the npcfile, removing');
  wrl(tc, '  all deleted and empty records. Don''t execute this');
  wrl(tc, '  command when somebody is playing.');
  my_pause;

  wrl(tc, '');
  wr(tc, '"'); wr(hc, '/DO_PACKMOAT');
  wrl(tc, '" this command will pack the moat-file, removing');
  wrl(tc, '  all deleted moat creatures.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_PACKRELATIONS');
  wrl(tc, '" this command will pack the social relations');
  wrl(tc, '  file. All inactive and old records will be removed.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_PACKCHILDREN');
  wrl(tc, '" this command will pack the children data-file');
  wrl(tc, '  file. All inactive and deleted children will be removed.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_PACKMAIL');
  wrl(tc, '" this command will pack the mail file, deleting all');
  wrl(tc, '  old mail and pack the file. This command should not');
  wrl(tc, '  be necessary to carry out, since Usurper keeps the mail');
  wrl(tc, '  file updated. But it can be used if you think that');
  wrl(tc, '  the \DATA\MAIL.DAT file has grown to big.');
  wrl(tc, '');

  wr(tc, '"'); wr(hc, '/DO_SENDMAIL');
  wrl(tc, '" this command will allow you to send a letter to any');
  wrl(tc, '  user in the game. It saves you the trouble having to enter the');
  wrl(tc, '  game.');
  wrl(tc, '');

end; {command_help *end*}

end. {UNIT *END*}
