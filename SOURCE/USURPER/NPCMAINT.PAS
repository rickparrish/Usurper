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



unit NpcMaint; {Usurper - Non Player Character maintenance (NPC) }

interface

procedure Npc_Maint(var king_found: boolean);

implementation

uses
  Crt, DDplus, Init, Cms,
  Jakob, Invent, Autogang,
  Mail, News, TeamRec,
  Relation, relatio2, WantedSc, Compwar,
  Kmaint, Various, Various2,
  Various3, InitGods, VarGods,
  ChallKng, File_Io;

     {npcs that go after the crown must:
       not be married to monarch
       not feel strongly for monarch
       not be in the royal guard

       must swim the moat
       must fight the royal guards
       must fight the monarch
      }


const mux = 400;
  maxnr   = 60;
var
  obatt:       array [1..mux] of ^longint;
  oshop:       array [1..mux] of ^boolean;
  power:       array [1..maxnr] of longint;
  power2:      array [1..maxnr] of longint;
  team2:       array [1..maxnr] of ^s70;

  nice:        array [1..maxnr] of ^boolean;
  nice2:       array [1..maxnr] of ^s70;

  counter:     integer;
  yy, i, j, k: longint;

  afflicted, save_need, npcpurnews, bought, bother, found, skip_hunt: boolean;

  pl0, pl1:    ^UserRec;
  objekt:      ^orec;
  wanted:      wantedrec;

function Ok_To_Buy(var pl0: userrec; var o: orec; var minarmor, maxarmor: word): boolean;
begin

  if (o.shop) and (o.armor > minarmor) and
    (o.armor <= maxarmor) and (o.cursed = False) and
    (class_restricted(pl0.class, o, 0) = False) and
    (pl0.strength >= o.str_need) then
  begin
    ok_to_buy := True;
  end else
  begin
    ok_to_buy := False;
  end;

end; {ok_to_buy *end*}

procedure Remove_Gang(var badgang: s70);
begin

  d(global_mainttxt, 'Removing NPC team : ' + badgang);

  {news-paper}
  newsy(False,
    'Gang Dissolved',
    utec + ' ' + badgang + config.textcol1 + ' ceased to exist!',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '');

  for j := 1 to fs(FsNpc) do
  begin

    {load character}
    if load_character(pl0^, 2, j) then
    begin

      if (player_active(pl0^, False) = True) and (pl0^.team = badgang) then
      begin

        {news-paper}
        newsy(False,
          ' ' + uplc + pl0^.name2 + config.textcol1 + ' left the team.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

        {check for records}
        team_record(pl0^.team);

    {this code also exists in tcorner.pas and various2.pas (deactivate_player!
     these snippets should perhaps be united in one single proc/function...}
        pl0^.team := emptystr;
        pl0^.cturf := False;
        pl0^.teampw := emptystr;
        pl0^.team := emptystr;
        pl0^.gym_owner := 0;

        {save user}
        user_save(pl0^);

      end;

    end;

  end; {for j:= .end.}

 {news-paper,
 this puts a CRLF in the newsfiles}
  newsy(True,
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

end; {remove_gang *end*}

procedure NPC_Believer; {believe,lose faith, desecrate altar, sacrifce...}
var
  found_god: boolean;

  x:         longint;

  s:         s70;

  god0:      godrec;

begin

  {are the NPCS allowed to have faith in GODs?}
  if (config.npcbelievers = True) and
    (random(3) = 0) and
    (player_active(pl0^, False) = True) then
  begin

    {verify faith}
    if pl0^.god <> '' then
    begin
      if Verify_Gods_Existance(pl0^.god) = False then
      begin
        pl0^.god := '';
        save_need := True;
      end;
    end;

    {already a believer}
    if pl0^.god <> '' then
    begin
      {stop believe, sacrifice, desecrate other gods altar}
      x := random(8);
      case x of
        0: begin {stop believe}

          {mail the god who lost a believer}
          s := 'Lost Believer';
          post(MailSend,
            pl0^.god,
            'H',
            True, {destination is a god}
            mailrequest_nothing,
            '',
            umailheadc + s + config.textcol1,
            mkstring(length(s), underscore),
            uplc + pl0^.name2 + config.textcol1 + ' lost faith in you!',
            uplc + pl0^.name2 + config.textcol1 + ' became a pagan.',
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
          Newsy(True,
            'Pagan',
            ' ' + uplc + pl0^.name2 + config.textcol1 + ' lost faith in ' + ugodc + pl0^.god + config.textcol1 + '.',
            ' ' + uplc + pl0^.name2 + config.textcol1 + ', the ' + race_display(2, pl0^.race, 0) + ', became a pagan.',
            '',
            '',
            '',
            '',
            '',
            '',
            '');

          {set user flags}
          pl0^.god := '';
          save_need := True;

        end; {stop believe .end.}
        1: begin {desecrate other gods altar}

          {jakob}

        end;
      end; {case .end.}

    end else
    begin

      {npc becomes a believer}

      {find god}
      found_god := get_random_god(god0.Name);

      if found_god then
      begin

        {set user flags}
        pl0^.god := god0.Name;
        save_need := True;

        {mail the god who won a believer}
        s := 'New Believer';
        post(MailSend,
          god0.Name,
          'H',
          True, {destination is a god}
          mailrequest_nothing,
          '',
          uyellow + s + config.textcol1,
          mkstring(length(s), underscore),
          uplc + pl0^.name2 + config.textcol1 + ' worships you!',
          uplc + pl0^.name2 + config.textcol1 + ' grovels before your altar.',
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
        Newsy(True,
          'Salvation',
          ' ' + uplc + pl0^.name2 + config.textcol1 + ' found faith in ' + ugodc + god0.Name + config.textcol1 + '!',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

      end; {become believer .end.}

    end;

  end;

end; {npc_believer *end*}

procedure Npcs_On_The_Move;
var
  x, y: byte;
begin

  {init pointer vars}
  for i := 1 to maxnr do
  begin
    nice[i]^ := False;    {human influenced gang?}
    nice2[i]^ := emptystr; {gang-name}
    power[i] := 0;        {power}
    team2[i]^ := emptystr;
    power2[i] := 0;        {# of members}
  end; {for i:= .end.}

  d(global_mainttxt, 'NPC teams on the move');

  for j := 1 to fs(FsPlayer) do
  begin

    {load character}
    if load_character(player, 1, j) = True then
    begin

      x := 0;
      if (player.team <> '') and
        (player_active(player, False) = True) then
      begin

        for i := 1 to maxnr do
        begin
          if nice2[i]^ = player.team then
          begin
            x := 1;
            Inc(power2[i]);
            break;
          end;
        end; {for i:= .end.}

        if x = 0 then
        begin
          for i := 1 to maxnr do
          begin
            if nice2[i]^ = '' then
            begin
              nice2[i]^ := player.team;
              nice[i]^ := True;
              Inc(power2[i]);
              break;
            end;
          end; {for i:= .end.}
        end;
      end;
    end;

  end; {for j:= .end.}

  for j := 1 to fs(FsNpc) do
  begin
    y := 0;

    load_character(pl0^, 2, j);

    if (pl0^.team <> '') and
      (player_active(pl0^, False) = True) then
    begin

      for i := 1 to maxnr do
      begin
        yy := i;
        if pl0^.team = nice2[i]^ then
        begin
          Inc(power2[i]);
          y := 1;
          break;
        end;
      end; {for i:= .end.}
      if y = 0 then
      begin
        for i := 1 to maxnr do
        begin
          if nice2[i]^ = '' then
          begin
            nice2[i]^ := pl0^.team;
            Inc(power2[i]);
            break;
          end;
        end; {for i:= .end.}
      end;
    end;

  end; {for j:= .end.}

  {remove small NPC gangs or...}
  {should they recruite!? that is decided here!}
  for i := 1 to maxnr do
  begin

    if (nice2[i]^ <> '') and (nice[i]^ = False) and (power2[i] > global_maxteammembers) then
    begin
      {cheat gang! team has more than 5 members}
      remove_gang(nice2[i]^);
    end else if (nice2[i]^ <> '') and (nice[i]^ = False) and (power2[i] <= 3) then
    begin
      {this is a NPC only gang with *power2* members}
      if random(4) = 0 then
      begin {dissolve gang}
        remove_gang(nice2[i]^);
      end else
      begin  {recruiting more teammembers!}

        for j := 1 to fs(FsNpc) do
        begin

          if load_character(pl0^, 2, j) then
          begin

            if power2[i] > (global_maxteammembers - 1) then
            begin
              {enough people have been recruited}
              break;
            end;

            if (player_active(pl0^, False) = True) and
              (pl0^.team = '') and
              (not pl0^.king) and
              (random(3) = 0) then
            begin

              Inc(power2[i]);

              for k := 1 to fs(FsNpc) do
              begin

                if load_character(pl1^, 2, k) then
                begin

                  if (player_active(pl1^, False) = True) and
                    (pl1^.team = nice2[i]^) then
                  begin

                    pl0^.team := nice2[i]^;
                    pl0^.teampw := pl1^.teampw;
                    pl0^.cturf := pl1^.cturf;
                    pl0^.teamrec := pl1^.teamrec;
                    break;
                  end;
                end;

              end; {for k:= .end.}

              {save player}
              user_save(pl0^);

              {news-paper}
              newsy(True,
                config.textcol1 + 'Gang Recruit',
                ' ' + uplc + pl0^.name2 + config.textcol1 + ' has been recruited to ' + utec + nice2[i]^ + config.textcol1,
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

        end; {for j:= .end.}
      end;
    end;
  end; {for i:= .end.}

end; {npcs_on_the_move *end*}

procedure Npc_Scan;
begin

  if f_exists(global_wwfile) then
  begin

    for i := 1 to maxnr do
    begin
      nice2[i]^ := emptystr; {name for wanted}
      power[i] := 0;   {the wanteds level}
      team2[i]^ := emptystr;
    end; {for i:= .end.}

    bother := False;

    for i := 1 to fs(FsWanted) do
    begin
      load_wanted(Fload, wanted, i);
      if (wanted.elig in ['A', 'C']) and (wanted.collected = False) and
        (wanted.gold >= 1500) then
      begin

        bother := True;
        nice2[i]^ := wanted.Name;
        power[i] := wanted.level;
        team2[i]^ := wanted.mad;
        case wanted.ai2 of
          'H': power2[i] := 1;
          'C': power2[i] := 2;
        end;

      end;
    end; {for i:= .end.}

  end;

end; {npc_scan *end*}

procedure Dispose_Team;
begin

  for i := 1 to maxnr do
  begin
    dispose(team2[i]);
  end;

end; {dispose_team *end*}

procedure Disposal; {dispose of pointer vars}
var i: integer;
begin

  for i := 1 to maxnr do
  begin
    dispose(nice[i]);
    dispose(nice2[i]);
  end;

  for i := 1 to mux do
  begin
    dispose(obatt[i]);
    dispose(oshop[i]);
  end;

  dispose(pl0);
  dispose(pl1);
  dispose(objekt);

end; {disposal *end*}

function Npc_Buy(var pl0: UserRec; news: boolean): boolean;
var
  s: s70;
  x: longint;
  bought, save_need: boolean;

  rhand_need, lhand_need, head_need, body_need, arms_need, lfinger_need, rfinger_need, legs_need, feet_need, waist_need, neck_need, neck2_need, face_need, shield_need, hands_need, abody_need: boolean;

  minattack, minarmor, maxattack, maxarmor: word;

  g: byte;

begin

{ d(14,commastr(memavail));
 pause;
}

  rhand_need := False;
  lhand_need := False;
  head_need := False;
  body_need := False;
  arms_need := False;
  lfinger_need := False;
  rfinger_need := False;
  legs_need := False;
  feet_need := False;
  waist_need := False;
  neck_need := False;
  neck2_need := False;
  face_need := False;
  shield_need := False;
  hands_need := False;
  abody_need := False;

  minattack := pl0.level + random(70);
  minarmor := pl0.level div 3;

  maxattack := pl0.level * 30;
  maxarmor := pl0.level * 30;


  {buying items for npc:s and other computer controlled characters}
  if pl0.rhand = 0 then
  begin
    rhand_need := True;
  end;

 {
 if (pl0.lhand=0) and (allowitem[15]=true) then begin
  lhand_need:=true;
 end;
 }

  g := 3;

  if (pl0.head = 0) and (random(g) = 0) and (config.allowitem[2]) then
  begin
    head_need := True;
  end;

  if (pl0.body = 0) and (random(g) = 0) and (config.allowitem[3]) then
  begin
    body_need := True;
  end;

  if (pl0.shield = 0) and (random(g) = 0) and (config.allowitem[13]) then
  begin
    shield_need := True;
  end;

  if (pl0.legs = 0) and (random(g) = 0) and (config.allowitem[7]) then
  begin
    legs_need := True;
  end;

  if (pl0.arms = 0) and (random(g) = 0) and (config.allowitem[4]) then
  begin
    arms_need := True;
  end;

 { 1 : s:='Allow Hand Equipment';
   2 : s:='Allow Head Equipment';
   3 : s:='Allow Body Equipment';
   4 : s:='Allow Arm Equipment';
   5 : s:='Allow Left Finger Equipment';
   6 : s:='Allow Right Finger Equipment';
   7 : s:='Allow Leg Equipment';
   8 : s:='Allow Feet Equipment';
   9 : s:='Allow Waist Equipment';
   10: s:='Allow 1 Neck Equipment';
   11: s:='Allow 2 Neck Equipment';
   12: s:='Allow Face Equipment';
   13: s:='Allow Shield';
   14: s:='Allow Around Body Equipment';
   15: s:='Allow Secondary Weapon';
   }

  if (pl0.hands = 0) and (random(g) = 0) and (config.allowitem[1]) then
  begin
    hands_need := True;
  end;

 {if (pl0.lfinger=0) and (config.allowitem[5]) then begin
  lfinger_need:=true;
 end;}

  if (pl0.rfinger = 0) and (random(g) = 0) and (config.allowitem[6]) then
  begin
    rfinger_need := True;
  end;

  if (pl0.feet = 0) and (random(g) = 0) and (config.allowitem[8]) then
  begin
    feet_need := True;
  end;

  if (pl0.waist = 0) and (random(g) = 0) and (config.allowitem[9]) then
  begin
    waist_need := True;
  end;

  if (pl0.neck = 0) and (random(g) = 0) and (config.allowitem[10]) then
  begin
    neck_need := True;
  end;

 {if (pl0.neck2=0) and (config.allowitem[11]) then begin
  neck2_need:=true;
 end;}

  if (pl0.face = 0) and (random(g) = 0) and (config.allowitem[12]) then
  begin
    face_need := True;
  end;

  if (pl0.abody = 0) and (random(g) = 0) and (config.allowitem[14]) then
  begin
    abody_need := True;
  end;

  bought := False;

  if rhand_need then
  begin

    x := fsob(Weapon);
    if x > mux then
    begin
      x := mux;
    end;

    for j := 1 to x do
    begin

      if (oshop[j]^) and
        (obatt[j]^ > minattack) and
        (obatt[j]^ <= maxattack) then
      begin

        bought := True;
        rhand_need := False;
        if pl0.rhand > 0 then
        begin
          objekt_affect(2, pl0.rhand, weapon, pl0, False);
        end;
        pl0.rhand := j;
        objekt_affect(1, pl0.rhand, weapon, pl0, False);
        {d(0,14,0,'New weapon for '+pl0.name2);}
        break;
      end;

    end; {for j:= .end.}

  end;

  if body_need then
  begin

    for j := 1 to fsob(body) do
    begin
      load_objekt(objekt^, body, j);

      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        body_need := False;
        if pl0.body > 0 then
        begin
          objekt_affect(2, pl0.body, body, pl0, False);
        end;
        pl0.body := j;
        objekt_affect(1, pl0.body, body, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if head_need then
  begin

    for j := 1 to fsob(head) do
    begin
      load_objekt(objekt^, head, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        head_need := False;
        if pl0.head > 0 then
        begin
          objekt_affect(2, pl0.head, head, pl0, False);
        end;
        pl0.head := j;
        objekt_affect(1, pl0.head, head, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if shield_need then
  begin
    for j := 1 to fsob(shield) do
    begin
      load_objekt(objekt^, shield, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        shield_need := False;
        if pl0.shield > 0 then
        begin
          objekt_affect(2, pl0.shield, shield, pl0, False);
        end;
        pl0.shield := j;
        objekt_affect(1, pl0.shield, shield, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if legs_need then
  begin
    for j := 1 to fsob(legs) do
    begin
      load_objekt(objekt^, legs, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        legs_need := False;
        if pl0.legs > 0 then
        begin
          objekt_affect(2, pl0.legs, legs, pl0, False);
        end;
        pl0.legs := j;
        objekt_affect(1, pl0.legs, legs, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if arms_need then
  begin
    for j := 1 to fsob(arms) do
    begin
      load_objekt(objekt^, arms, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        arms_need := False;
        if pl0.arms > 0 then
        begin
          objekt_affect(2, pl0.arms, arms, pl0, False);
        end;
        pl0.arms := j;
        objekt_affect(1, pl0.arms, arms, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if hands_need then
  begin
    for j := 1 to fsob(hands) do
    begin
      load_objekt(objekt^, hands, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        hands_need := False;
        if pl0.hands > 0 then
        begin
          objekt_affect(2, pl0.hands, hands, pl0, False);
        end;
        pl0.hands := j;
        objekt_affect(1, pl0.hands, hands, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if rfinger_need then
  begin
    for j := 1 to fsob(fingers) do
    begin
      load_objekt(objekt^, fingers, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        rfinger_need := False;
        if pl0.rfinger > 0 then
        begin
          objekt_affect(2, pl0.rfinger, fingers, pl0, False);
        end;
        pl0.rfinger := j;
        objekt_affect(1, pl0.rfinger, fingers, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if feet_need then
  begin
    for j := 1 to fsob(feet) do
    begin
      load_objekt(objekt^, feet, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        feet_need := False;
        if pl0.feet > 0 then
        begin
          objekt_affect(2, pl0.feet, feet, pl0, False);
        end;
        pl0.feet := j;
        objekt_affect(1, pl0.feet, feet, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if waist_need then
  begin
    for j := 1 to fsob(waist) do
    begin
      load_objekt(objekt^, waist, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        waist_need := False;
        if pl0.waist > 0 then
        begin
          objekt_affect(2, pl0.waist, waist, pl0, False);
        end;
        pl0.waist := j;
        objekt_affect(1, pl0.waist, waist, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if neck_need then
  begin
    for j := 1 to fsob(neck) do
    begin
      load_objekt(objekt^, neck, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        neck_need := False;
        if pl0.neck > 0 then
        begin
          objekt_affect(2, pl0.neck, neck, pl0, False);
        end;
        pl0.neck := j;
        objekt_affect(1, pl0.neck, neck, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if face_need then
  begin
    for j := 1 to fsob(face) do
    begin
      load_objekt(objekt^, face, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        face_need := False;
        if pl0.face > 0 then
        begin
          objekt_affect(2, pl0.face, face, pl0, False);
        end;
        pl0.face := j;
        objekt_affect(1, pl0.face, face, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if abody_need then
  begin
    for j := 1 to fsob(abody) do
    begin
      load_objekt(objekt^, abody, j);
      if ok_to_buy(pl0, objekt^, minarmor, maxarmor) then
      begin
        bought := True;
        abody_need := False;
        if pl0.abody > 0 then
        begin
          objekt_affect(2, pl0.abody, abody, pl0, False);
        end;
        pl0.abody := j;
        objekt_affect(1, pl0.abody, abody, pl0, False);
        break;
      end;
    end; {for j:= .end.}
  end;

  if (bought = True) and (news = True) then
  begin

    case random(12) of
      0: s := 'Hehe...';
      1: s := 'Just what I was looking for!';
      2: s := 'This will fit in nicely in my collection';
      3: s := 'Don''t mess with me now!';
      4: s := 'I really need this!';
      5: s := 'At last, some new equipment!';
      6: s := 'Now I must go and train!';
      7: s := 'I can already smell blood!';
      8: s := 'It was a bargain!';
      9: s := 'I got the perfect stuff!';
      10: s := 'Am I looking good or what!?';
      11: s := 'Master of Equipment is Back!';
    end; {case .end.}

    case random(3) of
      0: begin
        newsy(True,
          config.textcol1 + 'Purchase',
          ' ' + uplc + pl0.name2 + config.textcol1 + ' bought new equipment.',
          ' ' + utalkc + s + config.textcol1,
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
          config.textcol1 + 'Shopping',
          ' ' + uplc + pl0.name2 + config.textcol1 + ' was seen shopping.',
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
          config.textcol1 + 'Stuff',
          ' ' + uplc + pl0.name2 + config.textcol1 + ' purchased new equipment.',
          s,
          '',
          '',
          '',
          '',
          '',
          '',
          '');
      end;
    end; {case .end.}
    save_need := True;
  end;

  {return result}
  npc_buy := save_need;

end; {npc_buy *end*}

procedure Npc_Maint;
var
  member:    array[1..5] of s70;
  done:      array [1..maxnr] of boolean;

  ok, npccharge, npcbuy, npcnews, npc_married, go_ahead, npcallow: boolean;

  vic, mem, attempts, y, interest: integer;

  yy, rep, xx, townpot, zz, x, z, q, rand: longint;

  s2, ss, s: string;

  rr:        real;

  rewcount, rewset: byte; {keeps track of # posts in REWARD file}

  failures, attacks, attack_nr, buy_strat, hunts, hunts2: byte;
  memy:      byte;

  aarmor:    armrec;
  wweapon:   weaprec;
  guard:     guardrec;
  king:      kingrec;
  relation:  relationrec;

begin

  {init pointer vars}
  for i := 1 to maxnr do
  begin
    new(team2[i]);
  end;

  for i := 1 to mux do
  begin
    new(obatt[i]);
    new(oshop[i]);

    obatt[i]^ := 0;
    oshop[i]^ := False;
  end; {for i:= .end.}

  new(pl0);
  new(pl1);
  new(objekt);

  {lets read the weapon file in to our buffer}
  x := fsob(Weapon);
  if x > mux then
  begin
    x := mux;
  end;

  for i := 1 to x do
  begin
    load_objekt(objekt^, weapon, i);
    oshop[i]^ := objekt^.shop;
    obatt[i]^ := objekt^.attack;
  end;

  for i := 1 to maxnr do
  begin
    new(nice[i]);
    new(nice2[i]);

    nice[i]^ := False;
    nice2[i]^ := emptystr;
  end; {for i=: .end.}

  rewcount := fs(FsWanted);
  rewset := 0;

  if (config.classic) and (f_exists(global_armofile) = False) then
  begin
    fatal(global_armofile);
  end;

  if (config.classic) and (f_exists(global_weapofil) = False) then
  begin
    fatal(global_weapofil);
  end;

  vic := 0;
  s := cfg_string(8);
  vic := str_to_nr(s);
  if (vic < 1) or (vic > 3) then vic := 0;

 {we read interest level from .cfg (#41) and
  are NPCs allowed to create their own teams? (#42) }
  s := cfg_string(41);
  ss := cfg_string(42);

  interest := str_to_nr(s);
  if (interest < 1) or (interest > 15) then interest := 3;
  npcallow := True;
  if upcasestr(ss) = 'NO' then npcallow := False;

  {fetching NPC ,level raises in news, in NEWS? from .CFG (#44) }
  {fetching NPC allowance to buy new armor/weapons (#45) }
  {fetching option to include npc purchases in news file? (#46) }
  npcnews := True;
  npcbuy := True;
  npcpurnews := True;

  s2 := cfg_string(44);
  s := cfg_string(45);
  ss := cfg_string(46);

  if upcasestr(s2) = 'NO' then npcnews := False;
  if upcasestr(s) = 'NO' then npcbuy := False;
  if upcasestr(ss) = 'NO' then npcpurnews := False;

  {read editor option #94, npc teams allowed to attack?}
  npccharge := True;
  s := cfg_string(94);
  if upcasestr(s) = 'NO' then npccharge := False;

  {read editor option #88, buying strategy}
  s := cfg_string(88);
  buy_strat := str_to_nr(s);
  if (buy_strat < 1) or (buy_strat > 5) then
  begin
    buy_strat := 2;
  end;

  {we have to buy items for the npcs in the users.dat}
  if config.classic = False then
  begin
    for i := 1 to fs(FsPlayer) do
    begin

      if load_character(pl0^, 1, i) = True then
      begin

        if (player_active(pl0^, False) = True) and
          (pl0^.ai = 'C') and
          (pl0^.rhand = 0) then
        begin

          save_need := False;
          save_need := npc_buy(pl0^, npcpurnews);

          if save_need then
          begin
            user_save(pl0^);
          end;

        end;

      end;

    end; {for i:= .end.}
  end;

  {Should bad/mean Npcs be activated?}
  if vic > 0 then
  begin
    x := 10;
    case vic of
      1: x := 10;
      2: x := 5;
      3: x := 2;
    end;

    if random(x) = 0 then
    begin

      afflicted := False;
      x := fs(FsPlayer);
      yy := random(x) + 1;
      load_character(pl0^, 1, yy);

      if random(2) = 0 then
      begin
        {demon}
        Inc(pl0^.haunt);
        afflicted := True;
      end else
      begin

        {disease, check resistance}
        if pl0^.disres < 50 then
        begin
          afflicted := True;
          case random(5) of
            0: pl0^.blind := True;
            1: pl0^.plague := True;
            2: pl0^.smallpox := True;
            3: pl0^.measles := True;
            4: pl0^.leprosy := True;
          end; {case .end.}

        end;

      end;

      if (afflicted) and (player_active(pl0^, False) = True) then
      begin

        {save user}
        user_save(pl0^);

        {post nightmare letter to target}
        post_nightmare(pl0^);

      end;

    end;
  end;
  {Mean Npcs *end*}

  ansion := True;
  xx := fs(FsNPC);
  mem := xx;

  {load king, so payrolls routines can be used}
  load_king(fload, king);

  {BIG-LOOP *START*}
  memy := wherey;
  for rep := 1 to fs(FsNPC) do
  begin

    xx := mem;
    rr := rep;
    if xx > 0 then
    begin
      rr := rr / xx;
      xx := round(rr * 100);
    end else
    begin
      xx := 0;
    end;

    if global_utest = False then
    begin
      sgoto_xy(1, memy);
      sd(global_mainttxt, 'NPC activity (' + commastr(xx) + '%)');
    end;

    y := 0;

    {set to true when npc variable is changed}
    save_need := False;

    {load character}
    load_character(pl0^, 2, rep);

    {pay-check for Royal Guard Duty?}
    Pay_Royal_Guard(pl0^, King);

    {bard songs}
    if pl0^.class = bard then
    begin
      pl0^.bard_songs_left := config.bardsongs;
    end;

    {set prison escape attempts}
    pl0^.prison_escapes := config.prison_escapes;

    {pick-pocket attempts}
    pl0^.pickpocketattempts := config.pickpocketattempts;

    {bank robbery attempts}
    pl0^.BankRobberyAttempts := config.BankRobberyAttempts;

    {shall NPC put himself at the Inn or go to prison?}
    if (pl0^.location = Offloc_prison) and
      (player_active(pl0^, False) = True) then
    begin

      if pl0^.daysinprison < 1 then
      begin

        {set location}
        pl0^.location := offloc_dormitory;

        {news-paper}
        newsy(True,
          config.textcol1 + 'Prisoner Released',
          ' ' + uplc + pl0^.name2 + config.textcol1 + ' was released from prison.',
          '',
          '',
          '',
          '',
          '',
          '',
          '',
          '');
        pl0^.location := offloc_dormitory;
        save_need := True;
      end else
      begin

        {player stays in prison}
        Dec(pl0^.daysinprison);

      end;

    end else if pl0^.location <> offloc_dormitory then
    begin
      pl0^.location := offloc_dormitory;
      save_need := True;
    end else
    begin

      if (random(15) = 0) and
        (pl0^.dark > 1000) and
        (player_active(pl0^, False) = True) and
        (pl0^.king = False) then
      begin

        {royal guards can't be jailed}
        ok := True;
        for i := 1 to global_kingguards do
        begin
          if king.guard[i] = pl0^.name2 then
          begin
            ok := False;
            break;
          end;
        end; {for i:= .end.}

        if ok then
        begin

          {npc placed in prison}
          pl0^.location := offloc_prison;
          pl0^.daysinprison := 1;
          save_need := True;

          {put it in the news}
          {vagrancy}
          {cheating}
          {figthing}
          case random(5) of
            0: s := 'vagrancy';
            1: s := 'theft';
            2: s := 'drunkenness';
            3: s := 'witchcraft';
            4: s := 'fraud';
          end;

          {news}
          newsy(True,
            config.textcol1 + 'Prison',
            ' ' + uplc + pl0^.name2 + config.textcol1 + ' was arrested for ' + ulred + s + config.textcol1 + '.',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '');
        end;

      end else if random(7) = 0 then
      begin
        {npc takes his rest at the Inn}

        case random(4) of
          0: pl0^.location := offloc_innroom1;
          1: pl0^.location := offloc_innroom2;
          2: pl0^.location := offloc_innroom3;
          3: pl0^.location := offloc_innroom4;
        end;

        if random(2) = 0 then
        begin
          {hire some door-guards}

          x := fs(FsGuard);
          if x > 0 then
          begin
            x := random(x) + 1;

            pl0^.bguard := x;
            {have to check of you are able to hire more than 1 guard}
            load_guard(Fload, guard, x);
            if guard.multiple then pl0^.bguardnr := random(10) + 1
            else pl0^.bguardnr := 1;
          end;
        end;
        save_need := True;
      end else if random(8) = 0 then
      begin
        {npc takes his rest at the Beggars Wall}
        pl0^.location := offloc_beggarwall;
        save_need := True;
      end;
    end;

    {god stuff}
    npc_believer;


    {should the NPC put out a reward just for the hell of it?}
    if (pl0^.level > 5) and
      (random(5) = 0) and
      (rewcount < 40) and
      (rewset < 4) and
      (player_active(pl0^, False) = True) then
    begin

      Inc(rewset);
      x := fs(FsPlayer);
      x := random(x);
      Inc(x);

      {load character}
      load_character(pl1^, 1, x);

      bother := True;
      if (pl0^.team <> '') and (pl1^.team <> '') then
      begin
        if (pl1^.name2 = pl0^.name2) or (pl0^.team = pl1^.team) then
        begin
          bother := False;
        end;
      end;

      if (pl1^.king = False) and (pl1^.level > 4) and (bother) then
      begin
        zz := random(pl1^.level) + random(pl1^.level);
        if zz < 2 then zz := 2;
        xx := 1000 * zz;

        wanted.Name := pl1^.name2;
        wanted.level := pl1^.level;
        wanted.date := todays_date;
        wanted.mad := pl0^.name2;
        wanted.gold := xx;
        wanted.collected := False;
        wanted.elig := 'A';
        wanted.ai1 := pl0^.ai;
        wanted.ai2 := pl1^.ai;
        case random(5) of
          0..3: wanted.anonym := False;
          4: wanted.anonym := True;
        end;

        y := empty_wantedslot;
        load_wanted(Fsave, wanted, y);

        if wanted.anonym = False then
        begin

          {notify victim}
          post(MailSend,
            pl1^.name2,
            pl1^.ai,
            False,
            mailrequest_nothing,
            '',
            umailheadc + 'You are WANTED!' + config.textcol1,
            mkstring(15, underscore),
            uplc + pl0^.name2 + config.textcol1 + ' has set a ' + uyellow + commastr(xx) + config.textcol1 + ' ' + many_money(xx) + ' reward',
            'for your liquidation.',
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

          {notify the victim}
          post(MailSend,
            pl1^.name2,
            pl1^.ai,
            False,
            mailrequest_nothing,
            '',
            umailheadc + 'You are WANTED!' + config.textcol1,
            mkstring(15, underscore),
            'Some rotten character has set a ' + uyellow + commastr(xx) + config.textcol1 + ' ' + many_money(xx) + ' reward',
            'for your liquidation.',
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

    {give daily resurrections}


    save_need := True; {now. save_need is truly unnecessary..since we save them all}
    pl0^.resurrections := config.resurrections;

    {controlling the town}
    if (pl0^.cturf = True) and (player_active(pl0^, False) = True) then
    begin
      Inc(pl0^.teamrec);
      save_need := True;
    end;

    {baby production}
    if (pl0^.sex = 2) and (pl0^.pregnancy > 0) then
    begin
      Inc(pl0^.pregnancy);
      give_birth(pl0^);
    end;

    {reset "quests_accomplished_today" counter}
    pl0^.RoyQuestsToday := 0;

    {heal npc from diseases ... by cheating really...}
    if pl0^.blind = True then pl0^.blind := False;
    if pl0^.plague = True then pl0^.plague := False;
    if pl0^.smallpox = True then pl0^.smallpox := False;
    if pl0^.measles = True then pl0^.measles := False;
    if pl0^.leprosy = True then pl0^.leprosy := False;

    {become a member of the Alchemist guild}
    if (pl0^.class = Alchemist) and
      (pl0^.level > 11) and
      (player_active(pl0^, False) = True) and
      (random(6) = 0) then
    begin

      pl0^.amember := True;
      save_need := True;
    end;

    {become bank-guard?}
    pl0^.bankguard := False;
    if (random(10) = 0) and
      (player_active(pl0^, False) = True) then
    begin
      pl0^.bankguard := True;
      save_need := True;
    end;

    {bank interest}
  {if (pl0^.bank>0) and (pl0^.bank<1500000000) then begin
   rr:=interest;
   rr:=rr / 100;
   rr:=1.00+rr;
   rr:=(pl0^.bank*rr);
   x:=pl0^.bank;
   pl0^.bank:=round(rr);
   yy:=pl0^.bank-x;
  end;}

    if pl0^.bankgold < 0 then
    begin
      pl0^.bankgold := 0;
      save_need := True;
    end;

    if pl0^.gold = 0 then
    begin
      incplayermoney(pl0^, (pl0^.level * 12000));
      save_need := True;
    end;

    {donate money if character is poor}
  {if (pl0^.bank<=0) and (pl0^.money<=0) then begin
   pl0^.bank:=25000+random(25000);
  end;}

    {sell items in inventory}
    if player_active(pl0^, False) = True then
    begin
      if config.classic = False then
      begin
        for i := 1 to global_maxitem do
        begin
          if pl0^.item[i] > 0 then
          begin
            pl0^.item[i] := 0;
            save_need := True;
          end;
        end; {for i:= .end.}
      end;
    end;

    if (npcbuy = True) and (player_active(pl0^, False) = True) then
    begin

      if config.classic then
      begin
        if pl0^.weapon = 0 then
        begin
          x := pl0^.level + random(5) + 3;
          if x > 100 then x := 90;

          load_weapon(x, wweapon);
          pl0^.weapon := x;
          pl0^.wpow := wweapon.pow;
          save_need := True;
        end;

        if pl0^.armor = 0 then
        begin
          x := pl0^.level + random(5) + 3;
          if x > 100 then x := 90;

          load_armor(x, aarmor);
          pl0^.armor := x;
          pl0^.apow := aarmor.pow;
          save_need := True;
        end;
      end else
      begin {heave buys if NEW mode is selected}
        x := 3;
        case buy_strat of
          1: x := 8;
          2: x := 7;
          3: x := 6;
          4: x := 5;
          5: x := 4;
        end;
        if (random(x) = 0) or (pl0^.armpow = 0) or (pl0^.weappow = 0) then
        begin
          npc_buy(pl0^, npcpurnews);
          save_need := True;
        end;
      end;
    end;

    {is it time for spell training as well?}
    if pl0^.class in [Cleric, Magician, Sage] then
    begin
      pl0^.spell[1, 1] := True;
      if pl0^.level >= 5 then pl0^.spell[2, 1] := True;
      if pl0^.level >= 10 then pl0^.spell[3, 1] := True;
      if pl0^.level >= 15 then pl0^.spell[4, 1] := True;
      if pl0^.level >= 20 then pl0^.spell[5, 1] := True;
      if pl0^.level >= 25 then pl0^.spell[6, 1] := True;
      if pl0^.level >= 30 then pl0^.spell[7, 1] := True;
      if pl0^.level >= 35 then pl0^.spell[8, 1] := True;
      if pl0^.level >= 40 then pl0^.spell[9, 1] := True;
      if pl0^.level >= 45 then pl0^.spell[10, 1] := True;
      if pl0^.level >= 50 then pl0^.spell[11, 1] := True;
      if pl0^.level >= 55 then pl0^.spell[12, 1] := True;
      y := 1;
      if pl0^.maxmana = 0 then
      begin
        pl0^.maxmana := pl0^.level * 30;
      end;
      pl0^.mana := pl0^.maxmana;
    end;

    {Is this the King/queen?}
    if (pl0^.king = True) and (king_found = True) then
    begin
      pl0^.king := False;
      save_need := True;
    end else if (pl0^.king = True) and (player_active(pl0^, False) = False) then
    begin
      pl0^.king := False;
      save_need := True;
    end else if (pl0^.king) and (player_active(pl0^, False) = True) and (king_found = False) then
    begin

      {we found the king .. or queen}
      king_found := True;

      {news-paper}
      newsy(True,
        config.textcol1 + 'The ' + kingstring(pl0^.sex),
        ' Long live ' + kingstring(pl0^.sex) + ' ' + uplc + pl0^.name2 + config.textcol1 + '! Hooray, Hooray, Hooray!',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '');

      {king maintenance!}
      king_maintenance(pl0^, king);

    end;

    {if this wasn't the King...should he/she attempt to usurp the throne?}
    go_ahead := True;

    {is the npc allowed to usurp the throne?}
    if king_found then go_ahead := False;
    if config.AllowNPCUsurping = False then go_ahead := False;
    if config.minlevelking = 0 then go_ahead := False;
    if pl0^.king = True then go_ahead := False;
    if pl0^.level < config.minlevelking then go_ahead := False;
    if (pl0^.dark > pl0^.chiv) and (config.SoulNeededKing = 1) then go_ahead := False;
    if (pl0^.chiv > pl0^.dark) and (config.SoulNeededKing = 2) then go_ahead := False;

    {ok if the dice says so, we'll make a run for the Castle}
    if go_ahead then
    begin
      if random(7) <> 0 then go_ahead := False;
    end;

    if go_ahead then
    begin

   {jakob: perhap make an alignment check also, a good-hearted NPC
     will not attack a good ruler...what do you think?}

      {must not be married/have a good relation to the current ruler!}
      if get_king(pl1^) = True then
      begin

        {load current relation}
        social_relation(pl0^, pl1^, relation);

        {correct relation}
        correct_relation(pl0^.name2, relation);

        {if we have too good a relation with the King then we call off the attack}
        if relation.relation1 in [global_RelationMarried,
          global_RelationLove,
          global_RelationPassion,
          global_RelationFriendship,
          global_RelationTrust] then
        begin
          go_ahead := False;
        end;

      end;

    end;

    {lets go for the Throne! Charge!!}
    if go_ahead then
    begin

      {save king records first}
      load_king(fsave, king);

      {attack the castle!!}
      if global_utest then d(15, pl0^.name2 + ' is attempting to usurp the Throne!');

      {worsen kings attitude to pl0}
      Update_Relation(Relation_Worsen, 2, pl1^, pl0^, True, False);

      {storm the castle}
      challenge_king(pl1^, pl0^, True);

      {load updated king record}
      load_king(fload, king);

      {I'm King! lose connection with Team}
      if (pl0^.king) and (pl0^.team <> '') then
      begin

        {news-paper}
        newsy(True,
          'Team Deserter',
          ' ' + uplc + pl0^.name2 + config.textcol1 + ' left ' + utec + pl0^.team + config.textcol1 + '!',
          ' ' + uplc + pl0^.name2 + config.textcol1 + ' became something better: ' + ukingc + kingstring(pl0^.sex) + config.textcol1 + '!',
          '',
          '',
          '',
          '',
          '',
          '',
          '');

        {mail team-mates}
        Team_Report_All(pl0^.team,  {team to send message to}
          pl0^.name2, {exclude player name}
          'Team Drop-Out!',    {letter head}
          mailrequest_nothing, {mailrequest_constant}
          uplc + pl0^.name2 + config.textcol1 + ' left your Team!', {line1}
          uplc + pl0^.name2 + config.textcol1 + ' became ' + +kingstring(pl0^.sex) + config.textcol1 + '!', {line2}
          '',  {line3}
          ''); {line4}


        {leave team}
        pl0^.team := '';
        save_need := True;
      end;

    end;

    {END OF NPC TRHONE USURPING}


    {NPC gets his daily share of experience}
    if player_active(pl0^, False) = True then
    begin

      {we give the npc his exp}
      if pl0^.exp < 2000000000 then
      begin

        xx := random(20000) + 10750;

        xx := pl0^.level * xx;

        incplayerexp(pl0^, xx);

        save_need := True;

      end;
    end;

    {set auto_hate}
    {the same proc exists in maint.pas!!!!}
    if pl0^.autohate <> 1 then
    begin
      y := 1;
      pl0^.AutoHate := 1;
      save_need := True;
    end;

    {set intimacy acts}
    if pl0^.intimacyActs < Config.IntimacyActs then
    begin
      y := 1;
      pl0^.intimacyActs := Config.IntimacyActs;
      save_need := True;
    end;

    {set max mana}
    if pl0^.maxmana > 0 then
    begin
      y := 1;
      pl0^.mana := pl0^.maxmana;
      save_need := True;
    end;

    {set max hps}
    if pl0^.hps < pl0^.maxhps then
    begin
      y := 1;
      pl0^.hps := pl0^.maxhps;
      save_need := True;
    end;

    {healing potions}
    if pl0^.healing < 5 then
    begin
      y := 1;
      pl0^.healing := config.maxheals;
      save_need := True;
    end;

    {level raise?}
    if player_active(pl0^, False) = True then
    begin
      raise_player(pl0^, npcnews, False, False, True, '');
    end;

    {social relations}
    if config.allownpcmarry then
    begin
      if global_utest then d(15, pl0^.name2 + ' entering npc_change_relations');
      npc_change_relations(pl0^);
      if global_utest then d(15, pl0^.name2 + ' exiting npc_change_relations');
    end;

    save_need := True;

    {save npc if necessary}
    if save_need = True then
    begin
      user_save(pl0^);
    end;

  end; {for rep:=1 ... BIG-LOOP *END*}

  sd(global_mainttxt, ' ... ');
  d(11, 'DONE');
  if config.allownpcmarry then
  begin
    sd(global_mainttxt, 'Checking NPC marriages...');

    npc_set_out_to_marry;
    d(11, 'DONE');

  end;


  {Should the NPC build gangs?}
 {first we check how many "clean" NPC teams there are
        (teams with only npcs,no humans) }

  if npcallow then
  begin

    {recruit/dissolve teams}
    npcs_on_the_move;

    {now lets check how many free NPC:s there are}
    y := 0;
    for i := 1 to fs(FsNPC) do
    begin

      load_character(pl0^, 2, i);

      if (pl0^.team = '') and
        (player_active(pl0^, False) = True) then
      begin

        Inc(y);
        if y > 10 then
        begin
          break;
        end;

      end;
    end; {for i:= .end.}

    if y > 10 then
    begin
      sd(2, 'þ ');
      d(10, 'Some Computer players are forming a team .. ');

      {first we pick a team-name}
      attempts := 0;
      repeat
        Inc(attempts);
        s := get_teamname;
        if s = '' then
        begin
          sd(12, global_tnames);
          d(10, ' not found!');
          break;
        end;

        d(14, '  ' + s);

        for i := 1 to fs(FsPlayer) do
        begin
          y := 0;
          load_character(player, 1, i);
          if upcasestr(player.team) = upcasestr(s) then
          begin
            y := 1;
            break;
          end;
        end; {for i:= .end.}

        if y = 0 then
        begin
          for i := 1 to fs(FsNPC) do
          begin
            load_character(pl0^, 2, i);
            if upcasestr(pl0^.team) = upcasestr(s) then
            begin
              y := 1;
              break;
            end;
          end;
        end;
        if y = 0 then
        begin
          y := 999;
        end;
      until (y = 999) or (attempts > 50);

      {pick members}
      if y = 999 then
      begin
        member[1] := emptystr;
        member[2] := emptystr;
        member[3] := emptystr;
        member[4] := emptystr;
        member[5] := emptystr;

        x := 0;
        y := fs(FsNPC);
        repeat
          xx := random(y) + 1;

          {load character}
          load_character(pl0^, 2, xx);

          if (pl0^.team = '') and
            (player_active(pl0^, False) = True) then
          begin

            pl0^.team := s;
            Inc(x);
            member[x] := pl0^.name2 + ' (lvl ' + commastr(pl0^.level) + ' ' + classnames[pl0^.class] + ')';
            user_save(pl0^);

          end;
        until x = 5;

        {announce the new team}
        case random(3) of
          0: begin
            newsy(True,
              config.textcol1 + 'A new gang has been formed!',
              ' ' + utec + s + config.textcol1 + ' has arrived to fight for power.',
              ' The members are ..',
              '           ' + uplc + member[1],
              '           ' + member[2],
              '           ' + member[3],
              '           ' + member[4],
              '           ' + member[5] + config.textcol1,
              '',
              '');
          end;
          1: begin
            newsy(True,
              config.textcol1 + 'New team!',
              ' ' + utec + s + config.textcol1 + ' has been created by some determined warriors.',
              ' Members :',
              '           ' + uplc + member[1],
              '           ' + member[2],
              '           ' + member[3],
              '           ' + member[4],
              '           ' + member[5] + config.textcol1,
              '',
              '');
          end;
          2: begin
            newsy(True,
              config.textcol1 + 'New gang!',
              ' ' + utec + s + config.textcol1 + ' has been formed by some determined warriors.',
              ' Members :',
              '           ' + uplc + member[1],
              '           ' + member[2],
              '           ' + member[3],
              '           ' + member[4],
              '           ' + member[5] + config.textcol1,
              '',
              '');
          end;

        end; {case .end.}

      end;
    end;
  end;

  {should some NPC team attack?}
  if npccharge then
  begin
    d(global_mainttxt, 'NPC teams allowed to attack.');
    d(global_mainttxt, '  Scanning combat status attackers/targets...');
    s := emptystr;

    {resetting variables needed}
    for i := 1 to maxnr do
    begin
      nice2[i]^ := emptystr;
      power[i] := 0;
      team2[i]^ := emptystr;
      power2[i] := 0;
    end;

    {counting all NPC teams}
    counter := 0;
    for i := 1 to fs(FsNPC) do
    begin
      load_character(pl0^, 2, i);
      xx := 0;
      if (pl0^.team <> '') and
        (player_active(pl0^, False) = True) then
      begin

        for j := 1 to maxnr do
        begin
          if pl0^.team = nice2[j]^ then
          begin
            if pl0^.hps > 0 then
            begin
              Inc(power[j], pl0^.level);
            end;
            xx := 1;
            break;
          end;
        end;

        if xx = 0 then
        begin
          for j := 1 to fs(FsPlayer) do
          begin
            load_character(pl1^, 1, j);
            if (pl0^.team = pl1^.team) and
              (player_active(pl0^, False) = True) then
            begin
              xx := 1;
              break;
            end;
          end; {for j:= .end.}

          if (xx = 0) and (counter < 50) then
          begin
            Inc(counter);
            if pl0^.hps > 0 then
            begin
              nice2[counter]^ := pl0^.team;
            end;
            power[counter] := pl0^.level;
          end;

        end;
      end;
    end; {for i:= .end.}

    {counting all HUMAN influenced gangs (gangs with human members) }
    counter := 0;
    for i := 1 to fs(FsPlayer) do
    begin
      xx := 0;
      load_character(pl0^, 1, i);

      if (pl0^.team <> '') and
        (player_active(pl0^, False) = True) then
      begin

        for j := 1 to maxnr do
        begin
          if pl0^.team = team2[j]^ then
          begin
            if pl0^.hps > 0 then
            begin
              Inc(power2[j], pl0^.level);
            end;
            break;
            xx := 1;
          end;
        end;

        if (xx = 0) and (counter < 50) then
        begin
          Inc(counter);
          if pl0^.hps > 0 then
          begin
            team2[counter]^ := pl0^.team;
          end;
          power2[counter] := pl0^.level;
        end;

      end;
    end; {for i:= .end.}

    for i := 1 to fs(FsNPC) do
    begin
      load_character(pl0^, 2, i);
      if (pl0^.team <> '') and
        (player_active(pl0^, False) = True) then
      begin

        for j := 1 to maxnr do
        begin
          if pl0^.team = team2[j]^ then
          begin
            if pl0^.hps > 0 then
            begin
              Inc(power2[j], pl0^.level);
            end;
            break;
          end;
        end;
      end;
    end; {for i:= .end.}

    attacks := random(4) + 2;
    attack_nr := 0;
    failures := 0;

    repeat
      {now we have all the NPC team names gathered in Nice2[1-50] }
      {                             their power is in Power[1-50] }
      s := emptystr;
      for i := 1 to maxnr do
      begin

        if (nice2[i]^ <> '') and (random(3) = 0) and (done[i] = False) then
        begin
          s := nice2[i]^;
          yy := power[i];

          done[i] := True;

          break;
        end;
      end; {for i:= .end.}

      if s <> '' then
      begin

        case random(2) of
          0: begin

            {find HUMAN opponents to S}
            s2 := emptystr;
            for i := 1 to maxnr do
            begin

              if (team2[i]^ <> '') and (yy > power2[i]) and
                (yy - power2[i] <= config.teamdiff) and (random(2) = 0) and
                (s <> s2) and (done[i] = False) then
              begin

                s2 := team2[i]^;
                xx := power2[i];
                done[i] := True;
                break;
              end;
            end; {for i:= .end.}

          end;
          1: begin
            {find NPC opponents to S}
            s2 := emptystr;
            for i := 1 to maxnr do
            begin

              if (nice2[i]^ <> '') and (yy > power[i]) and
                (yy - power[i] <= config.teamdiff) and (random(2) = 0) and
                (s <> s2) and (done[i] = False) then
              begin

                s2 := nice2[i]^;
                xx := power[i];
                done[i] := True;
                break;
              end;
            end; {for i:= .end.}
          end;

        end; {case .end.}

        if (s2 <> '') and (s <> '') and (xx > 0) and (yy > 0) then
        begin

          {opponents found}

     {don't see why this should be shown to users now.
     sd(14,'  ');
     sd(global_teamcol,s);
     sd(14,' ');
     sd(5,'against');
     sd(14,' ');
     sd(global_teamcol,s2);
     d(10,' !');
}
          {gang - gang routine}
          auto_gangwar(s, s2);
          Inc(attack_nr);

        end;
      end else
      begin
        Inc(failures);
      end;

    until (attack_nr >= attacks) or (failures > 30);

  end else
  begin
    d(global_mainttxt, 'The Computer Teams are unhappy, since they are not allowed to attack.');
  end;

  {NPCS on bountyhunting}
  {we scan WANTED.DAT first}
  {we reset the flag arrays}

  npc_scan;

  {TEAM2 array disappears here}
  dispose_team;

  if bother then
  begin

    {how many should make an attempt}
    attempts := random(8) + 1;
    y := 0;
    d(global_mainttxt, 'Bounty Hunters are on the move');

    hunts := 0;
    hunts2 := 0;

    repeat
      for i := 1 to fs(FsNPC) do
      begin

        load_character(pl0^, 2, i);

        if (random(5) = 0) and
          (pl0^.hps > 0) and
          (player_active(pl0^, False) = True) then
        begin

          for j := 1 to maxnr do
          begin
            xx := pl0^.level - power[j];
            Inc(hunts2);
            if (xx > config.leveldiff) and (config.leveldiff <> 0) then
            begin
              {this wouldn''t be a fair fight!}
            end else
            begin

              y := random(10) + random(25) + 1;
              if (nice2[j]^ <> '') and
                (pl0^.level + y >= power[j]) and
                (nice2[j]^ <> pl0^.name2) and
                (nice2[j]^ <> global_delname1) and
                (random(4) = 0) then
              begin

                {could be worth a try}
                sd(global_mainttxt, '  ');
                sd(global_plycol, pl0^.name2);
                sd(global_mainttxt, ' is looking for ');
                d(global_plycol, nice2[j]^);
                Inc(hunts);

                bother := False;

                for q := 1 to fs(FsPlayer) do
                begin

                  load_character(pl1^, 1, q);

                  if (pl1^.name2 = nice2[j]^) and
                    (player_active(pl1^, False) = True) then
                  begin

                    if pl1^.hps > 0 then
                    begin
                      bother := True;
                      break;
                    end;

                  end;

                end; {for q:= .end.}

                if bother = False then
                begin

                  for q := 1 to fs(FsNPC) do
                  begin

                    load_character(pl1^, 2, q);

                    if (pl1^.name2 = nice2[j]^) and
                      (player_active(pl1^, False) = True) then
                    begin

                      if pl1^.hps > 0 then
                      begin
                        bother := True;
                        break;
                      end;

                    end;
                  end; {for q:= .end.}
                end;

                if pl1^.hps < 1 then
                begin
                  bother := False;
                  nice2[j]^ := emptystr;
                end;

                {we found the PL1 punk! let the fight begin!}
                if bother then
                begin
                  if pl1^.team <> '' then
                  begin
                    if pl1^.team = pl0^.team then
                    begin
                      bother := False;
                    end;
                  end;
                end;

                if bother then
                begin

                  zz := 0;
                  repeat
                    Inc(zz);
                    computer_computer(True, True, pl0^, pl1^);
                  until (pl0^.hps < 1) or (pl1^.hps < 1) or (zz > 9999);

                  {update "killedby" variable in relations data file}
                  if pl0^.hps < 1 then
                  begin
                    killed_by_stats(pl1^, pl0^);
                  end;
                  if pl1^.hps < 1 then
                  begin
                    killed_by_stats(pl0^, pl1^);
                  end;

                  if pl1^.hps < 1 then
                  begin
                    nice2[j]^ := emptystr;
                    if pl0^.hps > 0 then
                    begin

                      {collect reward}
                      {toggle reward record flag to COLLECTED}
                      {observe that there may be more than one reward on the same guy}

                      for q := 1 to fs(FsWanted) do
                      begin
                        load_wanted(Fload, wanted, q);
                        if wanted.Name = pl1^.name2 then
                        begin
                          case random(2) of
                            0: incplayermoney(pl0^, wanted.gold);
                            1: incbankmoney(pl0^, wanted.gold);
                          end;
                          wanted.collected := True;
                          load_wanted(Fsave, wanted, q);

                        end;
                      end; {for q:= .end.}
                    end;
                  end;

                  user_save(pl0^);
                  user_save(pl1^);

                  s := ' ' + uplc + pl0^.name2 + config.textcol1 + ' attacked ' + uplc + pl1^.name2 + config.textcol1;

                  if (pl0^.hps < 1) and (pl1^.hps < 1) then
                  begin

                    s := s + ' : both were killed! (round ' + ulgray + commastr(zz) + config.textcol1 + ')';

                    if pl1^.ai = 'H' then
                    begin
                      if pl0^.sex = 1 then s := 'his'
                      else s := 'her';
                      post(MailSend,
                        pl1^.name2,
                        pl1^.ai,
                        False,
                        mailrequest_nothing,
                        '',
                        umailheadc + 'Fight!' + config.textcol1,
                        mkstring(6, underscore),
                        uplc + pl0^.name2 + config.textcol1 + ' attacked and killed you!',
                        'However, the poor bastard died from ' + sex3[pl0^.sex] + ' wounds...',
                        'The creep was probably after the reward.',
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
                  end else if pl0^.hps < 1 then
                  begin

                    if zz > 1 then
                    begin
                      s := s + '. ' + ulred + pl0^.name2 + config.textcol1 + ' was defeated (' + ulgray + commastr(zz) + config.textcol1 + ' rounds)';
                    end else
                    begin
                      s := s + '. ' + ulred + pl0^.name2 + config.textcol1 + ' was killed (' + ulgray + commastr(zz) + config.textcol1 + ' round)';
                    end;

                    {inform opponent}
                    case random(3) of
                      0: begin
                        post(MailSend,
                          pl1^.name2,
                          pl1^.ai,
                          False,
                          mailrequest_nothing,
                          '',
                          umailheadc + 'Fight!' + config.textcol1,
                          mkstring(6, underscore),
                          uplc + pl0^.name2 + config.textcol1 + ' attacked you but failed!',
                          'The worm died like a coward! Look out for more Bounty Hunters!',
                          'They are after your hide!',
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
                      1: begin
                        post(MailSend,
                          pl1^.name2,
                          pl1^.ai,
                          False,
                          mailrequest_nothing,
                          '',
                          umailheadc + 'Fight!' + config.textcol1,
                          mkstring(6, underscore),
                          uplc + pl0^.name2 + config.textcol1 + ' attacked you but lost!',
                          'You earned some nice experience here!',
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
                      2: begin
                        post(MailSend,
                          pl1^.name2,
                          pl1^.ai,
                          False,
                          mailrequest_nothing,
                          '',
                          umailheadc + 'Fight!' + config.textcol1,
                          mkstring(6, underscore),
                          uplc + pl0^.name2 + config.textcol1 + ' attacked you!',
                          'But you killed ' + sex[pl0^.sex] + '!',
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
                    end; {case .end.}

                  end else if pl1^.hps < 1 then
                  begin

                    if zz > 1 then
                    begin
                      s := s + '. ' + ulred + pl1^.name2 + config.textcol1 + ' was defeated.';
                    end else
                    begin
                      s := s + '. ' + ulred + pl1^.name2 + config.textcol1 + ' was overpowered.';
                    end;

                    post(MailSend,
                      pl1^.name2,
                      pl1^.ai,
                      False,
                      mailrequest_nothing,
                      '',
                      umailheadc + 'Fight!' + config.textcol1,
                      mkstring(6, underscore),
                      uplc + pl0^.name2 + config.textcol1 + ' attacked and killed you!',
                      uplc + pl0^.name2 + config.textcol1 + ' collected a nice reward for ' + sex3[pl0^.sex] + ' effort.',
                      '(Some people like to see you dead)',
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

                  if (pl1^.hps < 1) and (pl0^.hps > 1) then
                  begin
                    newsy(True,
                      config.textcol1 + 'Bounty Hunter',
                      s,
                      ' ' + uplc + pl0^.name2 + config.textcol1 + ' collected the reward for ' + uplc + pl1^.name2 + config.textcol1 + '.',
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
                      config.textcol1 + 'Player Fight!',
                      s,
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

                Inc(y);
                break;
              end;
            end;
          end;
        end;

        {checking if there any wanted characters left}
        xx := 0;
        for j := 1 to maxnr do
        begin
          if nice2[j]^ <> '' then
          begin
            xx := 1;
            break;
          end;
        end;

        if (hunts >= attempts) or (xx = 0) then
        begin
          break;
        end;

      end;

    until (hunts >= attempts) or (xx = 0) or (hunts2 > 100);

  end; {for i:= .end. BIG-LOOP}

  {save the updated king record}
  load_king(fsave, king);

  {the byebye proc will create scores if the player.name strings are set}
  {therefore we nullify them here...}
  player.name1 := emptystr;
  player.name2 := emptystr;

  {dispose of pointer vars}
  disposal;

end; {Npc_maint *end*}

end. {UNIT NpcMaint *end*}
