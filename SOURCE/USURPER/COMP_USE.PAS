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


unit Comp_Use; {Usurper - NPC/offline player decides how to use an item}

interface

uses
  Init;

procedure Computer_Use(var player0: userrec; var objektx: ORec; objektnr: word; Text: boolean);

implementation

uses
  Jakob, invent, various,
  file_io;

procedure Back_Pack(var gubbe: userrec; var objekt: orec);
begin
  sd(global_plycol, gubbe.name2 + ugreen + ' puts the ');
  sd(global_itemcol, objekt.Name);
  d(2, ' in ' + sex3[gubbe.sex] + ' backpack.');
end;

procedure Throw_Away(var gubbe: userrec; var objekt: orec);
begin
  case random(5) of
    0: sd(global_talkcol, 'Nah! I don''t need this crap!');
    1: sd(global_talkcol, 'I can''t carry this!');
    2: sd(global_talkcol, 'Have to throw it away');
    3: sd(global_talkcol, 'My backpack is full!');
    4: sd(global_talkcol, 'Nah! I don''t need this!');
  end;
  sd(2, ', ');
  sd(global_plycol, gubbe.name2);
  sd(2, ' says, and drops the ');
  sd(global_itemcol, objekt.Name + ' ' + item_power_display(objekt));
  d(2, '.');

end; {throw away *end*}

function Objekt_Test(mode: char; {weapon, armor or general}
  var gubbe: userrec; var o1, o2: orec): boolean;
var go: boolean;
begin

  go := False;

  case mode of
    'A': begin {armor test}
      if (o2.armor > o1.armor) and
        (gubbe.strength >= o2.str_need) and
        (o2.attack >= 0) and
        (o2.hps >= 0) and
        (o2.defence >= 0) then
      begin
        {ok!}
        go := True;
      end;
    end;
    'W': begin {weapon test}
      if (o2.attack > o1.attack) and
        (gubbe.strength >= o2.str_need) and
        (o2.armor >= 0) and
        (o2.hps >= 0) and
        (o2.defence >= 0) then
      begin
        {ok!}
        go := True;
      end;
    end;

    'G': begin {general best test}
      if (o2.Value > o1.Value) and
        (o2.cursed = False) and
        (o2.armor >= 0) and
        (o2.attack >= 0) and
        (o2.hps >= 0) then
      begin
        {ok!}
        go := True;
      end;
    end;
  end; {case .end.}

  if (o2.good = True) and (gubbe.chiv < 1) and (gubbe.dark > 0) then
  begin
    {player too evil for item}
    go := False;
  end else if (o2.evil = True) and (gubbe.chiv > 0) and (gubbe.dark < 1) then
  begin
    {player too good for item}
    go := False;
  end;

  if (gubbe.class in [Magician, Cleric, Sage]) and (o2.mana < 0) then
  begin
    go := False;
  end;

  {cursed}
  if o2.cursed = True then
  begin
    go := False;
  end;

  {return result}
  objekt_test := go;

end; {objekt_test *end*}

procedure Computer_Use;
const loud_affect = False;
var
  i:       integer;
  y:       longint;
  q:       byte;
  objekt2: ^orec;
  discard: boolean;

begin

  {init pointer variables}
  new(objekt2);

  { => ** What is player0 to do with OBJEKT objektnr? ** <= }
  i := inventory_empty(player0);

  if (i = 0) and (objektx.cursed = False) then
  begin
    {can something in the inventory be discarded?}
    discard := True;
    for q := 1 to global_maxitem do
    begin
      load_objekt(objekt2^, player0.itemtype[q], player0.item[q]);
      if objekt_test('G', player0, objekt2^, objektx) = True then
      begin
        if Text then back_pack(player0, objektx);
        player0.item[q] := objektnr;
        player0.itemtype[q] := objektx.ttype;

        throw_away(player0, objekt2^);
        discard := False;
        break;
      end;

    end; {for q:= .end.}

    if (discard) and (Text) then
    begin
      throw_away(player0, objektx);
    end;
  end  {INVENTORY IS NOT FULL} else if (i > 0) and (objektx.cursed = False) then
  begin
    player0.item[i] := objektnr;

    player0.itemtype[i] := objektx.ttype;

    if Text then
    begin
      d(2, '');
      sd(global_plycol, player0.name2);
      sd(2, ' took the ');
      d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
    end;

    if objektx.str_need > player0.strength then
    begin
      {too heavy to use}
    end else if (objektx.good = True) and (player0.chiv < 1) and (player0.dark > 0) then
    begin
      {player is too evil for item}
      if Text then
      begin
        d(12, player0.name2 + ' is zapped by the ' + objektx.Name);
      end;
    end else if (objektx.evil = True) and (player0.chiv > 0) and (player0.dark < 1) then
    begin
      {spelaren f”r god f”r objektet}
      if Text then
      begin
        d(12, player0.name2 + ' is zapped by the ' + objektx.Name);
      end;
    end else if allowed_to_use(objektx.ttype) = False then
    begin
      throw_away(player0, objektx);
    end else
    begin

      case objektx.ttype of
        Head: begin
          if player0.head = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' puts the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' head ...');
            end;
            player0.head := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.head, head, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, head, player0.head);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' puts the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' head ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.head;
              player0.itemtype[i] := head;
              objekt_affect(2, player0.head, head, player0, loud_affect);
              player0.head := y;
              objekt_affect(1, player0.head, head, player0, loud_affect);
            end;
          end;
        end;
        Body: begin
          if player0.body = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' body ...');
            end;

            player0.body := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.body, body, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, body, player0.body);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' body ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.body;
              player0.itemtype[i] := body;
              objekt_affect(2, player0.body, body, player0, loud_affect);
              player0.body := y;
              objekt_affect(1, player0.body, body, player0, loud_affect);
            end;
          end;
        end;
        Arms: begin
          if player0.arms = 0 then
          begin
            if Text = True then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' arms ...');
            end;

            player0.arms := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.arms, arms, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, arms, player0.arms);
            if objektx.armor > objekt2^.armor then
            begin
              if Text = True then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' arms ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.arms;
              player0.itemtype[i] := arms;

              objekt_affect(2, player0.arms, arms, player0, loud_affect);
              player0.arms := y;
              objekt_affect(1, player0.arms, arms, player0, loud_affect);
            end;
          end;
        end;
        Hands: begin
          if player0.hands = 0 then
          begin
            if Text = True then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' hands ...');
            end;

            player0.hands := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.hands, hands, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, hands, player0.hands);
            if objektx.armor > objekt2^.armor then
            begin
              if Text = True then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' hands ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.hands;
              player0.itemtype[i] := hands;
              objekt_affect(2, player0.hands, hands, player0, loud_affect);
              player0.hands := y;
              objekt_affect(1, player0.hands, hands, player0, loud_affect);
            end;
          end;
        end;
        Fingers: begin

          if (player0.lfinger = 0) and (config.allowitem[5] = True) then
          begin
            if Text = True then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' left finger ...');
            end;

            player0.lfinger := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.lfinger, fingers, player0, loud_affect);
          end else if (player0.rfinger = 0) and (config.allowitem[6] = True) then
          begin
            if Text = True then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' right finger ...');
            end;

            player0.rfinger := player0.item[i];
            player0.item[i] := 0;

            objekt_affect(1, player0.rfinger, fingers, player0, loud_affect);
          end else if (player.lfinger > 0) and (config.allowitem[5] = True) then
          begin
            load_objekt(objekt2^, fingers, player0.lfinger);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' left finger ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.lfinger;
              player0.itemtype[i] := fingers;
              objekt_affect(2, player0.lfinger, fingers, player0, loud_affect);
              player0.lfinger := y;
              objekt_affect(1, player0.lfinger, fingers, player0, loud_affect);
            end;
          end else if (player.rfinger > 0) and (config.allowitem[6] = True) then
          begin
            load_objekt(objekt2^, fingers, player0.rfinger);
            if objektx.armor > objekt2^.armor then
            begin
              if Text = True then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' right finger ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.rfinger;
              player0.itemtype[i] := fingers;
              objekt_affect(2, player0.rfinger, fingers, player0, loud_affect);
              player0.rfinger := y;
              objekt_affect(1, player0.rfinger, fingers, player0, loud_affect);
            end;

          end;
        end;
        Legs: begin
          if player0.legs = 0 then
          begin
            if Text = True then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' legs ...');
            end;

            player0.legs := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.legs, legs, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, legs, player0.legs);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' legs ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.legs;
              player0.itemtype[i] := legs;
              objekt_affect(2, player0.legs, legs, player0, loud_affect);
              player0.legs := y;
              objekt_affect(1, player0.legs, legs, player0, loud_affect);
            end;
          end;
        end;
        Feet: begin
          if player0.feet = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' feet ...');
            end;

            player0.feet := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.feet, feet, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, feet, player0.feet);
            if objektx.armor > objekt2^.armor then
            begin
              if Text = True then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' feet ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.feet;
              player0.itemtype[i] := feet;
              objekt_affect(2, player0.feet, feet, player0, loud_affect);
              player0.feet := y;
              objekt_affect(1, player0.feet, feet, player0, loud_affect);
            end;
          end;
        end;
        Waist: begin
          if player0.waist = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' around ' + sex3[player0.sex] + ' waist ...');
            end;

            player0.waist := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.waist, waist, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, waist, player0.waist);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to wear the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' around ' + sex3[player0.sex] + ' waist ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.waist;
              player0.itemtype[i] := waist;
              objekt_affect(2, player0.waist, waist, player0, loud_affect);
              player0.waist := y;
              objekt_affect(1, player0.waist, waist, player0, loud_affect);
            end;
          end;
        end;
        Neck: begin
          if (player0.neck = 0) and (config.allowitem[11] = True) then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' around ' + sex3[player0.sex] + ' neck ...');
            end;

            player0.neck := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.neck, neck, player0, loud_affect);
          end else if (player0.neck2 = 0) and (config.allowitem[11] = True) then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to wear the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' around ' + sex3[player0.sex] + ' neck ...');
            end;

            player0.neck2 := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.neck2, neck, player0, loud_affect);
          end else
          begin
            if (player0.neck > 0) and (config.allowitem[10] = True) then
            begin
              load_objekt(objekt2^, neck, player0.neck);
              if objektx.armor > objekt2^.armor then
              begin
                if Text then
                begin
                  sd(global_plycol, player0.name2);
                  sd(2, ' starts to wear the ');
                  sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                  d(2, ' around ' + sex3[player0.sex] + ' neck ...');
                end;

                y := player0.item[i];
                player0.item[i] := player0.neck;
                player0.itemtype[i] := neck;
                objekt_affect(2, player0.neck, neck, player0, loud_affect);
                player0.neck := y;
                objekt_affect(1, player0.neck, neck, player0, loud_affect);
              end;
            end else if (player0.neck2 > 0) and (config.allowitem[11] = True) then
            begin
              load_objekt(objekt2^, neck, player0.neck2);
              if objektx.armor > objekt2^.armor then
              begin
                if Text then
                begin
                  sd(global_plycol, player0.name2);
                  sd(2, ' starts to wear the ');
                  sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                  d(2, ' around ' + sex3[player0.sex] + ' neck ...');
                end;

                y := player0.item[i];
                player0.item[i] := player0.neck2;
                player0.itemtype[i] := neck;
                objekt_affect(2, player0.neck2, neck, player0, loud_affect);
                player0.neck2 := y;
                objekt_affect(1, player0.neck2, neck, player0, loud_affect);
              end;
            end;
          end;
        end;
        Face: begin
          if player0.face = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' puts the ');
              sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              d(2, ' on ' + sex3[player0.sex] + ' face ...');
            end;

            player0.face := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.face, face, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, face, player0.face);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' puts the ');
                sd(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                d(2, ' on ' + sex3[player0.sex] + ' face ...');
              end;

              y := player0.item[i];
              player0.item[i] := player0.face;
              player0.itemtype[i] := face;

              objekt_affect(2, player0.face, face, player0, loud_affect);
              player0.face := y;
              objekt_affect(1, player0.face, face, player0, loud_affect);
            end;
          end;
        end;
        Shield: begin
          if player0.shield = 0 then
          begin
            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' starts to use the ');
              d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
            end;

            player0.shield := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.shield, shield, player0, loud_affect);
          end else
          begin
            load_objekt(objekt2^, shield, player0.shield);
            if objektx.armor > objekt2^.armor then
            begin
              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' starts to use the ');
                d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              end;

              y := player0.item[i];
              player0.item[i] := player0.shield;
              player0.itemtype[i] := shield;
              objekt_affect(2, player0.shield, shield, player0, loud_affect);
              player0.shield := y;
              objekt_affect(1, player0.shield, shield, player0, loud_affect);
            end;
          end;
        end;
        Weapon: begin
          if player0.rhand = 0 then
          begin

            if Text then
            begin
              sd(global_plycol, player0.name2);
              sd(2, ' grabs the ');
              d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
            end;

            player0.rhand := player0.item[i];
            player0.item[i] := 0;
            objekt_affect(1, player0.rhand, weapon, player0, loud_affect);
          end else if (player0.lhand = 0) and (config.allowitem[15] = True) then
          begin
            load_objekt(objekt2^, weapon, player0.rhand);
            if objektx.attack >= objekt2^.attack then
            begin

              if Text then
              begin
                sd(global_plycol, player0.name2);
                sd(2, ' grabs the ');
                d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
              end;

              player0.lhand := player0.item[i];
              player0.item[i] := 0;
              objekt_affect(1, player0.lhand, weapon, player0, loud_affect);
            end else if player0.rhand > 0 then
            begin
              load_objekt(objekt2^, weapon, player0.rhand);
              if objektx.attack > objekt2^.attack then
              begin
                if Text then
                begin
                  sd(global_plycol, player0.name2);
                  sd(2, ' grabs the ');
                  d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                end;

                y := player0.item[i];
                player0.item[i] := player0.rhand;
                player0.itemtype[i] := weapon;

                objekt_affect(2, player0.rhand, weapon, player0, loud_affect);
                player0.rhand := y;
                objekt_affect(1, player0.rhand, weapon, player0, loud_affect);
              end;
            end else if (player0.lhand > 0) and (config.allowitem[15] = True) then
            begin
              load_objekt(objekt2^, weapon, player0.lhand);
              if objektx.attack > objekt2^.attack then
              begin
                if Text then
                begin
                  sd(global_plycol, player0.name2);
                  sd(2, ' grabs the ');
                  d(global_itemcol, objektx.Name + ' ' + item_power_display(objektx));
                end;

                y := player0.item[i];
                player0.item[i] := player0.lhand;
                player0.itemtype[i] := weapon;

                objekt_affect(2, player0.lhand, weapon, player0, loud_affect);
                player0.lhand := y;
                objekt_affect(1, player0.lhand, weapon, player0, loud_affect);
              end;
            end;
          end;
        end;

      end; {case .end.}

    end;
  end;

  {dispose pointer vars}
  dispose(objekt2);

end; {Computer_Use *end*}

end. {Unit Compu_Use .end.}
