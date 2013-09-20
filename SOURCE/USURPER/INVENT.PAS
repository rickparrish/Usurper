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



unit Invent;
{Usurper - Player Inventory Routines}
             {also see npc_chec.pas, comp_use.pas and swapeq.pas for NPC
              inventory routines}
interface

uses
  Init;

{Inventory & Item manipulation Routines}

procedure Inventory_Display(var player0: UserRec);
function Is_Inventory_Empty(var player0: Userrec): boolean;
function Inventory_Empty(const player0: UserRec): byte;
procedure Inventory_Sort(var player0: UserRec);
procedure Use_Item(predefined: longint);
procedure Drop_Item(var temp: UserRec);
procedure Remove_Item;
procedure Check_Valid_Equipment(var man: UserRec);
procedure Objekt_Affect(use: byte; nr: longint; otyp: objtype; var player0: UserRec; loud: boolean);
function Allowed_To_Use(typ: objtype): boolean;
function Item_Select(var player0: UserRec): longint;
function Item_Search(item: longint; var player0: UserRec): boolean;
function Item_Power_Display(const item: orec): s70;

procedure Chest_with_Items; {where players can store items, located at home}

implementation

uses
  Jakob, Various, Various3,
  News, StatusC, File_Io;

procedure Inventory_Sort;
var
  gap, k:      integer;
  xx, x, i, j: longint;
  topp:        objtype;

begin

  x := global_maxitem;
  gap := x div 2;
  while gap > 0 do
  begin
    for i := (gap + 1) to x do
    begin
      j := i - gap;
      while (j > 0) do
      begin
        k := j + gap;
        if player0.item[j] >= player0.item[k] then
        begin
          j := 0;
        end else
        begin

          xx := player0.item[j];
          player0.item[j] := player0.item[k];
          player0.item[k] := xx;

          topp := player0.itemtype[j];
          player0.itemtype[j] := player0.itemtype[k];
          player0.itemtype[k] := topp;

          j := j - gap;
        end;
      end;
    end; {for i:= .end.}
    gap := gap div 2;
  end;

end; {Inventory_Sort *end*}

function Is_Inventory_Empty(var player0: Userrec): boolean;
var
  i:      byte;

  Result: boolean;

begin {returns true if player0's inventory is empty}

  Result := True;
  for i := 1 to global_maxitem do
  begin
    if player0.item[i] <> 0 then
    begin
      Result := False;
      break;
    end;
  end; {for i:= .end.}

  {return result}
  Is_Inventory_Empty := Result;

end; {Is_Inventory_Empty .end.}

function Inventory_Empty; {returns a empty inventory location,
                           if there's no empty then result=0}
var
  i, Result: byte;

begin

  {init}
  Result := 0;

  for i := 1 to global_maxitem do
  begin
    if player0.item[i] = 0 then
    begin
      Result := i;
      break;
    end;
  end; {for i:= .end.}

  {return result}
  inventory_empty := Result;

end; {inventory_empty *end*}

procedure Inventory_Display; {displays a characters inventory}
var
  nr, k, justval, cc: integer;

  showed:      array [1..global_maxitem] of boolean;

  empty, last: boolean;
  objekt:      ^orec;

begin

  {init pointer variables}
  new(objekt);

  {sort inventory}
  inventory_sort(player0);

  crlf;
  crlf;

  {space allowed for the rows}
  justval := 39;
  cc := 0;

  for k := 1 to global_maxitem do
  begin
    showed[k] := False;
    if player0.item[k] > 0 then
    begin
      Inc(cc);
    end;
  end; {for k:= .end.}

  if cc >= 2 then
  begin
    cc := cc div 2;
  end;

  nr := cc;
  Inc(cc);

  for k := 1 to (nr + 1) do
  begin

    last := True;

    if k <= global_maxitem then
    begin
      if (player0.item[k] > 0) and (showed[k] = False) then
      begin
        {load item}
        load_objekt(objekt^, player0.itemtype[k], player0.item[k]);
        {#}
        sd(3, '#' + commastr(k));
        {item name & power}
        sd(global_itemcol, ljust(' ' + objekt^.Name + ' ' + item_power_display(objekt^), justval));
        showed[k] := True;
        last := False;
      end;
    end;

    if (cc <= global_maxitem) and (cc > 0) then
    begin
      if (player0.item[cc] > 0) and (showed[cc] = False) then
      begin

        {load item}
        load_objekt(objekt^, player0.itemtype[cc], player0.item[cc]);

        if last = True then
        begin
          sd(3, mkstring(justval - 7, ' '));
        end;

        {#}
        sd(3, '#' + commastr(cc));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));

        showed[cc] := True;
        Inc(cc);
      end;
    end;

  end; {for k:= .end.}

  empty := True;
  for k := 1 to global_maxitem do
  begin
    if player0.item[k] > 0 then
    begin
      empty := False;
      break;
    end;
  end; {for k:= .end.}

  if empty = True then
  begin
    d(14, 'Empty!');
  end;

  crlf;
  dispose(objekt);

end; {inventory_display *end*}

function Item_Select;
var s:       s70;
  i, Result: longint;
begin

  Result := 0;

  repeat
    d(config.textcolor, 'Select # Item (' + config.textcol2 + '?' + config.textcol1 + '=list, Enter=abort)');
    sd(config.textcolor, ':');

    s := get_string(5);

    if s = '?' then
    begin
      inventory_display(player0);
    end else if s <> '' then
    begin

      i := str_to_nr(s);

      if (i < 1) or (i > global_maxitem) then i := 0;

      if (i > 0) and (player0.item[i] > 0) then
      begin
        Result := i;
        break;
      end;
    end;

  until s = '';

  {return result}
  item_select := Result;

end; {item_select *end*}

function Item_Search;
var i:    integer;
  Result: boolean;
begin

  Result := False;
  for i := 1 to global_maxitem do
  begin
    if player0.item[i] = item then
    begin
      Result := True;
      break;
    end;
  end; {for i:= .end.}

  {return result}
  item_search := Result;

end; {item_search *end*}

procedure Drop_Item;

var
  i:      integer;
  objekt: ^orec;

begin

  new(objekt);

  repeat
    inventory_sort(player);

    crlf;
    i := item_select(player);
    if i > 0 then
    begin

      {load item}
      load_objekt(objekt^, temp.itemtype[i], temp.item[i]);

      crlf;
      sd(config.textcolor, 'Drop ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        if objekt^.cursed = True then
        begin
          sd(12, 'You can''t drop ');
          sd(global_itemcol, objekt^.Name);
          sd(12, '!');
          d(12, ' It must be cursed!');
        end else
        begin
          sd(config.textcolor, 'You dump ');
          d(global_itemcol, objekt^.Name);
          temp.item[i] := 0;
        end;
      end;
    end;
  until i = 0;

  dispose(objekt);

end; {drop_item *end*}

procedure Remove_Item;
var
  yy, i:  longint;

  ch:     char;

  s:      s70;

  objekt: ^orec;

  righthand, rightfinger, neck1: boolean;

begin

  new(objekt);

  repeat
    inventory_sort(player);
    crlf;
    d(config.textcolor, 'Item # to Remove (' + config.textcol2 + '?' + config.textcol1 + '=list, Enter=abort)');
    sd(config.textcolor, ':');

    s := get_string(5);

    if s = '?' then
    begin
      yy := 1;

      if player.rhand > 0 then
      begin
        load_objekt(objekt^, weapon, player.rhand);
        sd(3, '#' + commastr(yy));
        sd(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        d(config.textcolor, ' (held in right hand)');
        Inc(yy);
      end;

      if player.lhand > 0 then
      begin
        load_objekt(objekt^, weapon, player.lhand);

        sd(3, '#' + commastr(yy));
        sd(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        d(config.textcolor, ' (held in left hand)');
        Inc(yy);
      end;

      if player.head > 0 then
      begin
        load_objekt(objekt^, head, player.head);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.face > 0 then
      begin
        load_objekt(objekt^, face, player.face);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.neck > 0 then
      begin
        load_objekt(objekt^, neck, player.neck);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.neck2 > 0 then
      begin
        load_objekt(objekt^, neck, player.neck2);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.body > 0 then
      begin
        load_objekt(objekt^, body, player.body);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.arms > 0 then
      begin
        load_objekt(objekt^, arms, player.arms);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.rfinger > 0 then
      begin
        load_objekt(objekt^, fingers, player.rfinger);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.lfinger > 0 then
      begin
        load_objekt(objekt^, fingers, player.lfinger);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.waist > 0 then
      begin
        load_objekt(objekt^, waist, player.waist);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.legs > 0 then
      begin
        load_objekt(objekt^, legs, player.legs);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.feet > 0 then
      begin
        load_objekt(objekt^, feet, player.feet);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.abody > 0 then
      begin
        load_objekt(objekt^, abody, player.abody);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.shield > 0 then
      begin
        load_objekt(objekt^, shield, player.shield);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;

      if player.hands > 0 then
      begin
        load_objekt(objekt^, hands, player.hands);
        sd(3, '#' + commastr(yy));
        d(global_itemcol, ' ' + objekt^.Name + ' ' + item_power_display(objekt^));
        Inc(yy);
      end;
    end;

    i := str_to_nr(s);

    if (i < 1) or (i >= yy) then
    begin
      i := 0;
    end;

    if i > 0 then
    begin
      yy := 1;
      righthand := True;

      if player.rhand > 0 then
      begin
        if yy = i then
        begin
          load_objekt(objekt^, weapon, player.rhand);
        end;
        Inc(yy);
      end;

      if player.lhand > 0 then
      begin
        if yy = i then
        begin
          load_objekt(objekt^, weapon, player.lhand);
          righthand := False;
        end;
        Inc(yy);
      end;

      if player.head > 0 then
      begin
        if yy = i then load_objekt(objekt^, head, player.head);
        Inc(yy);
      end;

      if player.face > 0 then
      begin
        if yy = i then load_objekt(objekt^, face, player.face);
        Inc(yy);
      end;
      neck1 := True;
      if player.neck > 0 then
      begin
        if yy = i then load_objekt(objekt^, neck, player.neck);
        Inc(yy);
      end;

      if player.neck2 > 0 then
      begin
        if yy = i then
        begin
          load_objekt(objekt^, neck, player.neck2);
          neck1 := False;
        end;
        Inc(yy);
      end;

      if player.body > 0 then
      begin
        if yy = i then load_objekt(objekt^, body, player.body);
        Inc(yy);
      end;

      if player.arms > 0 then
      begin
        if yy = i then load_objekt(objekt^, arms, player.arms);
        Inc(yy);
      end;

      rightfinger := True;
      if player.rfinger > 0 then
      begin
        if yy = i then load_objekt(objekt^, fingers, player.rfinger);
        Inc(yy);
      end;

      if player.lfinger > 0 then
      begin
        if yy = i then
        begin
          load_objekt(objekt^, fingers, player.lfinger);
          rightfinger := False;
        end;
        Inc(yy);
      end;

      if player.waist > 0 then
      begin
        if yy = i then load_objekt(objekt^, waist, player.waist);
        Inc(yy);
      end;

      if player.legs > 0 then
      begin
        if yy = i then load_objekt(objekt^, legs, player.legs);
        Inc(yy);
      end;

      if player.feet > 0 then
      begin
        if yy = i then load_objekt(objekt^, feet, player.feet);
        Inc(yy);
      end;

      if player.abody > 0 then
      begin
        if yy = i then load_objekt(objekt^, abody, player.abody);
        Inc(yy);
      end;

      if player.shield > 0 then
      begin
        if yy = i then load_objekt(objekt^, shield, player.shield);
        Inc(yy);
      end;

      if player.hands > 0 then
      begin
        if yy = i then load_objekt(objekt^, hands, player.hands);
        Inc(yy);
      end;


      {player is using some item}
      if objekt^.Name <> '' then
      begin

        if inventory_empty(player) = 0 then
        begin
          d(12, 'Inventory is full!');
        end else
        begin

          i := inventory_empty(player);

          case objekt^.ttype of
            Abody: begin
              if player.abody = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything around your body!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.abody;
                player.itemtype[i] := abody;
                player.abody := 0;
                objekt_affect(2, player.item[i], abody, player, True);
              end;
            end;
            Weapon: begin
              if (player.rhand = 0) and (player.lhand = 0) then
              begin
                d(config.textcolor, 'You are not holding anything in your hands!');
              end else
              begin
                if (player.lhand > 0) and (righthand = False) then
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.lhand;
                  player.itemtype[i] := Weapon;
                  player.lhand := 0;
                  objekt_affect(2, player.item[i], Weapon, player, True);
                end else
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.rhand;
                  player.itemtype[i] := Weapon;
                  player.rhand := 0;
                  objekt_affect(2, player.item[i], Weapon, player, True);
                end;
              end;
            end;
            Head: begin
              if player.head = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your head!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.head;
                player.itemtype[i] := Head;
                player.head := 0;
                objekt_affect(2, player.item[i], head, player, True);
              end;
            end;
            Body: begin
              if player.body = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your body!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.body;
                player.itemtype[i] := Body;
                player.body := 0;
                objekt_affect(2, player.item[i], body, player, True);
              end;
            end;
            Arms: begin
              if player.arms = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your arms!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.arms;
                player.itemtype[i] := arms;
                player.arms := 0;
                objekt_affect(2, player.item[i], arms, player, True);
              end;
            end;
            Hands: begin
              if player.hands = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your hands!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.hands;
                player.itemtype[i] := hands;
                player.hands := 0;
                objekt_affect(2, player.item[i], hands, player, True);
              end;
            end;
            Fingers: begin
              if (player.lfinger = 0) and (player.rfinger = 0) then
              begin
                d(config.textcolor, 'You are not wearing anything on your fingers!');
              end else
              begin
                if (player.lfinger > 0) and (rightfinger = False) then
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.lfinger;
                  player.itemtype[i] := fingers;
                  player.lfinger := 0;
                  objekt_affect(2, player.item[i], fingers, player, True);
                end else
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.rfinger;
                  player.itemtype[i] := fingers;
                  player.rfinger := 0;
                  objekt_affect(2, player.item[i], fingers, player, True);
                end;
              end;
            end;
            Legs: begin
              if player.legs = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your legs!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.legs;
                player.itemtype[i] := legs;
                player.legs := 0;
                objekt_affect(2, player.item[i], legs, player, True);
              end;
            end;
            Feet: begin
              if player.feet = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your feet!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.feet;
                player.itemtype[i] := feet;
                player.feet := 0;
                objekt_affect(2, player.item[i], feet, player, True);
              end;
            end;
            Waist: begin
              if player.waist = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything around your waist!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.waist;
                player.itemtype[i] := waist;
                player.waist := 0;
                objekt_affect(2, player.item[i], waist, player, True);
              end;
            end;
            Neck: begin
              if (player.neck = 0) and (player.neck2 = 0) then
              begin
                d(config.textcolor, 'You are not wearing anything around your neck!');
              end else
              begin
                if (player.neck > 0) and (neck1) then
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.neck;
                  player.itemtype[i] := neck;
                  player.neck := 0;
                  objekt_affect(2, player.item[i], neck, player, True);
                end else
                begin
                  sd(config.textcolor, 'You remove the ');
                  d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                  player.item[i] := player.neck2;
                  player.itemtype[i] := neck;
                  player.neck2 := 0;
                  objekt_affect(2, player.item[i], neck, player, True);
                end;
              end;
            end;
            Face: begin
              if player.face = 0 then
              begin
                d(config.textcolor, 'You are not wearing anything on your face!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.face;
                player.itemtype[i] := face;
                player.face := 0;
                objekt_affect(2, player.item[i], face, player, True);
              end;
            end;
            Shield: begin
              if player.shield = 0 then
              begin
                d(config.textcolor, 'You are not wearing a shield!');
              end else
              begin
                sd(config.textcolor, 'You remove the ');
                d(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
                player.item[i] := player.shield;
                player.itemtype[i] := shield;
                player.shield := 0;
                objekt_affect(2, player.item[i], shield, player, True);
              end;
            end;
            Food: begin
            end;
            Drink: begin
            end;
          end;
        end;
      end;
    end;
  until s = '';

  {dispose pointer var}
  dispose(objekt);

end; {remove_item *end*}

procedure Use_Item; {Used only by players online}
var
  yy, i: longint;
  y, j:  integer;

  ch:    char;
  s:     s70;

  force_right, force_left: boolean;

  objekt, objekt2: ^orec;

begin

  {init}
  new(objekt);
  new(objekt2);

  if predefined = 0 then
  begin
    player.used_item := False;
  end;

  repeat
    crlf;

    if predefined = 0 then
    begin
      inventory_sort(player);
      i := item_select(player);
    end else
    begin
      i := predefined;
    end;

    if (i < 1) or (i > global_maxitem) then
    begin
      i := 0;
    end;

    if (i > 0) and (player.item[i] > 0) then
    begin

      player.used_item := True;

      load_objekt(objekt^, player.itemtype[i], player.item[i]);

      if class_restricted(player.class, objekt^, 0) = True then
      begin
        d(12, 'Impossible! This item is class restricted!');
        pause;
      end else if objekt^.str_need > player.strength then
      begin
        d(12, 'Impossible! It''s too heavy!');
        pause;
      end else if (objekt^.good = True) and (player.chiv < 1) and (player.dark > 0) then
      begin
        d(12, 'You are zapped by the ' + uitemc + objekt^.Name + ulred + '!');
        d(12, 'You can''t use this item!');
        d(config.textcolor, 'It can only be used by Good characters.');
        pause;
      end else if (objekt^.evil = True) and (player.chiv > 0) and (player.dark < 1) then
      begin
        d(12, 'You are zapped by the ' + uitemc + objekt^.Name + ulred + '!');
        d(12, 'You can''t use this item!');
        d(config.textcolor, 'It can only be used by Evil characters.');
        pause;
      end else
      begin
        case objekt^.ttype of

          Abody: begin
            if config.allowitem[14] = True then
            begin
              if player.abody > 0 then
              begin
                load_objekt(objekt2^, abody, player.abody);

                sd(config.textcolor, 'You are already wearing a ');
                sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
                d(config.textcolor, ' around your body!');
                sd(config.textcolor, 'Put on the ');
                sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

                if confirm(' instead', 'N') = True then
                begin
                  sd(config.textcolor, 'You are now wearing the ');
                  d(global_itemcol, objekt^.Name);
                  y := player.item[i];
                  player.item[i] := player.abody;
                  player.itemtype[i] := abody;
                  objekt_affect(2, player.abody, abody, player, True);
                  player.abody := y;
                  objekt_affect(1, player.abody, abody, player, True);
                end;
              end else
              begin
                sd(config.textcolor, 'You start to wear the ');
                sd(global_itemcol, objekt^.Name);
                d(config.textcolor, ' around your body ...');
                player.abody := player.item[i];
                player.item[i] := 0;
                objekt_affect(1, player.abody, abody, player, True);
              end;
            end else
            begin
              d(12, 'You can''t use this kind of item!');
            end;
          end;
          Weapon: begin

            if config.allowitem[15] = True then
            begin
              if player.rhand > 0 then
              begin
                d(config.textcolor, '(Your right hand is occupied)');
              end else
              begin
                d(config.textcolor, '(Your right hand is FREE)');
              end;

              if player.lhand > 0 then
              begin
                d(config.textcolor, '(Your left hand  is occupied)');
              end else
              begin
                d(config.textcolor, '(Your left hand  is FREE)');
              end;

              sd(config.textcolor, 'Grab the ');
              sd(global_itemcol, objekt^.Name);
              sd(config.textcolor, ' with your ');

              if (player.rhand = 0) and (player.lhand = 0) then
              begin
                menu2('[R]ight or');
                menu2(' [L]eft hand ? :');
              end else if player.rhand = 0 then
              begin
                menu2('[R]ight or');
                menu2(' Left hand ? :');
              end else
              begin
                menu2(' Right or ');
                menu2('[L]eft hand ? :');
              end;

              repeat
                ch := upcase(getchar);
              until ch in ['R', 'L', ReturnKey];

            end else
            begin
              ch := 'R';
            end;

            crlf;
            if ch = ReturnKey then
            begin
              ch := 'R';
              if (player.rhand > 0) and (player.lhand = 0) then
              begin
                ch := 'L';
              end;
            end;

            if (ch = 'R') and (player.rhand = 0) then
            begin
              sd(config.textcolor, 'You grab the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' with your right hand...');
              player.rhand := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.rhand, weapon, player, True);
            end else if (ch = 'R') and (player.rhand > 0) then
            begin
              d(config.textcolor, 'Your right hand is occupied!');
            end
            else if (ch = 'L') and (player.lhand = 0) then
            begin
              sd(config.textcolor, 'You grab the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' with your left hand...');
              player.lhand := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.lhand, weapon, player, True);
            end else if (ch = 'L') and (player.lhand > 0) then
            begin
              d(config.textcolor, 'Your left hand is occupied!');
            end;

          end;
          Head: begin
            if player.head > 0 then
            begin
              load_objekt(objekt2^, head, player.head);

              sd(config.textcolor, 'You are already wearing a ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your head!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.head;
                player.itemtype[i] := head;
                objekt_affect(2, player.head, head, player, True);
                player.head := y;
                objekt_affect(1, player.head, head, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You put the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' on your head ...');
              player.head := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.head, head, player, True);
            end;
          end;
          Body: begin
            if player.body > 0 then
            begin
              load_objekt(objekt2^, body, player.body);

              sd(config.textcolor, 'You are already wearing a ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your body!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.body;
                player.itemtype[i] := body;
                objekt_affect(2, player.body, body, player, True);
                player.body := y;
                objekt_affect(1, player.body, body, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to wear the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.body := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.body, body, player, True);
            end;
          end;
          Arms: begin
            if player.arms > 0 then
            begin
              load_objekt(objekt2^, arms, player.arms);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your arms!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.arms;
                player.itemtype[i] := arms;
                objekt_affect(2, player.arms, arms, player, True);
                player.arms := y;
                objekt_affect(1, player.arms, arms, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You put the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' on your arms ...');
              player.arms := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.arms, arms, player, True);
            end;
          end;
          Hands: begin
            if player.hands > 0 then
            begin
              load_objekt(objekt2^, hands, player.hands);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your hands!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.hands;
                player.itemtype[i] := hands;
                objekt_affect(2, player.hands, hands, player, True);
                player.hands := y;
                objekt_affect(1, player.hands, hands, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to wear the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.hands := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.hands, hands, player, True);
            end;
          end;
          Fingers: begin
            if config.allowitem[6] = True then
            begin
              if player.rfinger > 0 then
              begin
                d(config.textcolor, '(Your right finger is occupied)');
              end else
              begin
                d(config.textcolor, '(Your right finger is FREE)');
              end;
            end;

            if config.allowitem[5] = True then
            begin
              if player.lfinger > 0 then
              begin
                d(config.textcolor, '(Your left finger is occupied)');
              end else
              begin
                d(config.textcolor, '(Your left finger is FREE)');
              end;
            end;

            force_right := False;
            force_left := False;
            if config.allowitem[6] = True then
            begin
              if (config.allowitem[5] = False) or ((player.lfinger <> 0) and (player.rfinger = 0)) then
              begin
                force_right := True;
              end else
              begin
                sd(config.textcolor, 'Put the ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' on your ');

                menu2('[R]ight or');
                menu2(' [L]eft finger ? :');
              end;
            end else if config.allowitem[5] = True then
            begin
              if (config.allowitem[6] = False) or ((player.rfinger <> 0) and (player.lfinger = 0)) then
              begin
                force_left := True;
              end else
              begin
                sd(config.textcolor, 'Put the ');
                sd(global_itemcol, objekt^.Name);
                sd(config.textcolor, ' on your ');

                menu2('[L]eft or');
                menu2(' [R]ight finger ? :');
              end;
            end;

            if force_right then
            begin
              ch := 'R';
            end else if force_left then
            begin
              ch := 'L';
            end else
            begin
              repeat
                ch := upcase(getchar);
                if (ch = 'R') and (config.allowitem[6] = False) then ch := ' ';
                if (ch = 'L') and (config.allowitem[5] = False) then ch := ' ';
              until ch in ['R', 'L', ReturnKey];
            end;

            crlf;
            if ch = ReturnKey then
            begin
              ch := 'R';
              if (player.rfinger > 0) and (player.lfinger = 0) and (config.allowitem[5]) then
              begin
                ch := 'L';
              end;
            end;

            if (ch = 'R') and (player.rfinger > 0) then
            begin
              load_objekt(objekt2^, fingers, player.rfinger);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your right finger!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.rfinger;
                player.itemtype[i] := fingers;
                objekt_affect(2, player.rfinger, fingers, player, True);
                player.rfinger := y;
                objekt_affect(1, player.rfinger, fingers, player, True);
              end;
            end else if (ch = 'L') and (player.lfinger > 0) then
            begin
              load_objekt(objekt2^, fingers, player.lfinger);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your left finger!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.lfinger;
                player.itemtype[i] := fingers;
                objekt_affect(2, player.lfinger, fingers, player, True);
                player.lfinger := y;
                objekt_affect(1, player.lfinger, fingers, player, True);
              end;
            end else if (ch = 'R') and (player.rfinger = 0) then
            begin
              sd(config.textcolor, 'You put the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' on your right finger ...');
              player.rfinger := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.rfinger, fingers, player, True);
            end else if (ch = 'L') and (player.lfinger = 0) then
            begin
              sd(config.textcolor, 'You put the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' on your left finger ...');
              player.lfinger := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.lfinger, fingers, player, True);
            end else
            begin
              {---}
            end;
          end;
          Legs: begin
            if player.legs > 0 then
            begin
              load_objekt(objekt2^, legs, player.legs);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your legs!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.legs;
                player.itemtype[i] := legs;
                objekt_affect(2, player.legs, legs, player, True);
                player.legs := y;
                objekt_affect(1, player.legs, legs, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to use the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.legs := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.legs, legs, player, True);
            end;
          end;
          Feet: begin
            if player.feet > 0 then
            begin
              load_objekt(objekt2^, feet, player.feet);

              sd(config.textcolor, 'You are already wearing ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your feet!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.feet;
                player.itemtype[i] := feet;
                objekt_affect(2, player.feet, feet, player, True);
                player.feet := y;
                objekt_affect(1, player.feet, feet, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to use the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.feet := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.feet, feet, player, True);
            end;
          end;
          Waist: begin
            if player.waist > 0 then
            begin
              load_objekt(objekt2^, waist, player.waist);

              sd(config.textcolor, 'You are already wearing the ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' around your waist!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.waist;
                player.itemtype[i] := waist;
                objekt_affect(2, player.waist, waist, player, True);
                player.waist := y;
                objekt_affect(1, player.waist, waist, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You strap the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' around your waist ...');
              player.waist := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.waist, waist, player, True);
            end;
          end;
          Neck: begin
            if (player.neck > 0) and (player.neck2 > 0) and
              (config.allowitem[10] = True) and (config.allowitem[11] = True) then
            begin
              load_objekt(objekt2^, neck, player.neck);

              sd(config.textcolor, 'You are already wearing the ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' around your neck!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.neck;
                player.itemtype[i] := neck;
                objekt_affect(2, player.neck, neck, player, True);
                player.neck := y;
                objekt_affect(1, player.neck, neck, player, True);
              end;
            end else
            begin
              if (player.neck = 0) and (config.allowitem[10] = True) then
              begin
                sd(config.textcolor, 'You start to wear ');
                sd(global_itemcol, objekt^.Name);
                d(config.textcolor, ' around your neck ...');
                player.neck := player.item[i];
                player.item[i] := 0;
                objekt_affect(1, player.neck, neck, player, True);
              end else if (player.neck2 = 0) and (config.allowitem[11] = True) then
              begin
                sd(config.textcolor, 'You start to wear ');
                sd(global_itemcol, objekt^.Name);
                d(config.textcolor, ' around your neck ...');
                player.neck2 := player.item[i];
                player.item[i] := 0;
                objekt_affect(1, player.neck2, neck, player, True);
              end else if (player.neck > 0) and (config.allowitem[10] = True) then
              begin
                load_objekt(objekt2^, neck, player.neck);

                sd(config.textcolor, 'You are already wearing the ');
                sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
                d(config.textcolor, ' around your neck!');
                sd(config.textcolor, 'Put on the ');
                sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

                if confirm(' instead', 'N') = True then
                begin
                  sd(config.textcolor, 'You are now wearing the ');
                  d(global_itemcol, objekt^.Name);
                  y := player.item[i];
                  player.item[i] := player.neck;
                  player.itemtype[i] := neck;
                  objekt_affect(2, player.neck, neck, player, True);
                  player.neck := y;
                  objekt_affect(1, player.neck, neck, player, True);
                end;

              end else if (player.neck2 > 0) and (config.allowitem[11] = True) then
              begin
                load_objekt(objekt2^, neck, player.neck2);

                sd(config.textcolor, 'You are already wearing the ');
                sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
                d(config.textcolor, ' around your neck!');
                sd(config.textcolor, 'Put on the ');
                sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

                if confirm(' instead', 'N') = True then
                begin
                  sd(config.textcolor, 'You are now wearing the ');
                  d(global_itemcol, objekt^.Name);
                  y := player.item[i];
                  player.item[i] := player.neck2;
                  player.itemtype[i] := neck;
                  objekt_affect(2, player.neck2, neck, player, True);
                  player.neck2 := y;
                  objekt_affect(1, player.neck2, neck, player, True);
                end;

              end;
            end;
          end;
          Face: begin
            if player.face > 0 then
            begin
              load_objekt(objekt2^, face, player.face);

              sd(config.textcolor, 'You are already wearing the ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, ' on your face!');
              sd(config.textcolor, 'Put on the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.face;
                player.itemtype[i] := face;
                objekt_affect(2, player.face, face, player, True);
                player.face := y;
                objekt_affect(1, player.face, face, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to use the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.face := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.face, face, player, True);
            end;
          end;
          Shield: begin
            if player.shield > 0 then
            begin
              load_objekt(objekt2^, shield, player.shield);

              sd(config.textcolor, 'You are already using the ');
              sd(global_itemcol, objekt2^.Name + ' ' + item_power_display(objekt2^));
              d(config.textcolor, '. ');
              sd(config.textcolor, 'Use the ');
              sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

              if confirm(' instead', 'N') = True then
              begin
                sd(config.textcolor, 'You are now wearing the ');
                d(global_itemcol, objekt^.Name);
                y := player.item[i];
                player.item[i] := player.shield;
                player.itemtype[i] := shield;
                objekt_affect(2, player.shield, shield, player, True);
                player.shield := y;
                objekt_affect(1, player.shield, shield, player, True);
              end;
            end else
            begin
              sd(config.textcolor, 'You start to use the ');
              sd(global_itemcol, objekt^.Name);
              d(config.textcolor, ' ...');
              player.shield := player.item[i];
              player.item[i] := 0;
              objekt_affect(1, player.shield, shield, player, True);
            end;
          end;
          Food: begin
            crlf;
            sd(config.textcolor, 'The ');
            sd(global_itemcol, objekt^.Name);
            d(config.textcolor, ' has a delicious taste to it.');
            d(config.textcolor, 'That was good!');

            objekt_affect(1, player.item[i], food, player, True);
            player.item[i] := 0;
          end;
          Drink: begin
            crlf;
            for j := 1 to 6 do
            begin
              sd(config.textcolor, 'Klunk...');
              delay2(800);
            end;
            d(15, 'Ahhh...!');

            objekt_affect(1, player.item[i], drink, player, True);
            player.item[i] := 0;

            crlf;
            sd(config.textcolor, 'The ');
            sd(global_itemcol, objekt^.Name);
            d(config.textcolor, ' is empty.');
          end;

        end; {case .end.}

      end;

    end;

    if predefined > 0 then
    begin
      dispose(objekt);
      dispose(objekt2);
      exit;
    end;

  until i = 0;

  {dispose pointer vars}
  dispose(objekt);
  dispose(objekt2);

end; {Use_Item *end*}

procedure Objekt_Affect;
const txtcol = 13;   {these two must refer to the same color}
  txtcol2    = ulmag; {see above}
var
  obj: orec;

  procedure cured(illness: cures); {player has been cured}
  var who: s70;
  begin

    if loud = True then
    begin
      if (player0.name2 = player.name2) and (player0.id = player.id) then
      begin
        who := 'You have been cured from';
      end else
      begin
        who := uplc + player0.name2 + txtcol2 + ' has been cured from';
      end;

      case illness of
        Blindness: d(txtcol, who + ' blindness!');
        Plague: d(txtcol, who + ' plague!');
        Smallpox: d(txtcol, who + ' smallpox!');
        Measles: d(txtcol, who + ' measles!');
        Leprosy: d(txtcol, who + ' leprosy!');
      end; {case .end.}

    end;

  end; {cured *end*}

  procedure stopped_using(txtval: string; Value: longint);
  {speak out changes when stop using an item?}
  var who: s40;
  begin

    if loud = True then
    begin
      if (player0.name2 = player.name2) and (player0.id = player.id) then
      begin
        who := 'Your';
      end else
      begin
        who := uplc + player0.name2 + 's' + txtcol2;
      end;

      if Value < 0 then
      begin
        d(txtcol, who + ' ' + txtval + ' ' + uyellow + 'increase' + txtcol2 + ' by ' + uwhite + '+' + commastr(abs(Value)) + txtcol2 + '!');
      end else if Value > 0 then
      begin
        d(txtcol, who + ' ' + txtval + ' ' + ulred + 'decrease' + txtcol2 + ' by ' + ulred + commastr(Value) + txtcol2 + '!');
      end;
    end;

  end; {stopped_using *end*}

  procedure report_changes(txtval: string; Value: longint);
  {report changes by item loud!}
  var who: s40;
  begin

    if loud then
    begin

      if (player0.name2 = player.name2) and (player0.id = player.id) then
      begin
        who := 'Your';
      end else
      begin
        who := uplc + player0.name2 + 's' + txtcol2;
      end;

      if Value > 0 then
      begin
        d(txtcol, who + ' ' + txtval + ' ' + uyellow + 'increase' + txtcol2 + ' by ' + uwhite + '+' + commastr(Value) + txtcol2 + '!');
      end else if Value < 0 then
      begin
        d(txtcol, who + ' ' + txtval + ' ' + ulred + 'decrease' + txtcol2 + ' by ' + ulred + commastr(abs(Value)) + txtcol2 + '!');
      end;

    end;

  end; {report_changes *end*}

begin {objekt_affect, start}

  { => ** Don't forget to change corresponding OBJ AFFECT now! ** <= }
  {in the editor routines...}

  {load object in question}
  load_objekt(obj, otyp, nr);

  case use of
    1: begin { Item has BEGUN to be used by player0 }

      if obj.ttype in [food, drink] then
      begin
        player0.hps := player0.hps + obj.hps;
        if player0.hps > player0.maxhps then
        begin
          player0.hps := player0.maxhps;
        end;

        if loud = True then
        begin
          if player0.hps >= player0.maxhps then
          begin
            d(txtcol, 'Your HITPOINTS maxed out!');
          end else
          begin
            d(txtcol, 'You regained some hitpoints!');
          end;
        end;

      end else
      begin
        player0.maxhps := player0.maxhps + obj.hps;
        report_changes('hitpoints', obj.hps);
      end;

      report_changes('stamina', obj.stamina);
      player0.stamina := player0.stamina + obj.stamina;

      report_changes('agility', obj.agility);
      player0.agility := player0.agility + obj.agility;

      report_changes('charisma', obj.charisma);
      player0.charisma := player0.charisma + obj.charisma;

      report_changes('dexterity', obj.dex);
      player0.dex := player0.dex + obj.dex;

      report_changes('wisdom', obj.wisdom);
      player0.wisdom := player0.wisdom + obj.wisdom;

      report_changes('mana', obj.mana);
      player0.maxmana := player0.maxmana + obj.mana;

      report_changes('armor power', obj.armor);
      player0.armpow := player0.armpow + obj.armor;

      report_changes('weapon power', obj.attack);
      player0.weappow := player0.weappow + obj.attack;

      report_changes('strength', obj.strength);
      player0.strength := player0.strength + obj.strength;

      report_changes('defence', obj.defence);
      player0.defence := player0.defence + obj.defence;

      case obj.cure of
        All: begin
          if player0.blind = True then cured(blindness);
          player0.blind := False;

          if player0.plague = True then cured(plague);
          player0.plague := False;

          if player0.smallpox = True then cured(smallpox);
          player0.smallpox := False;

          if player0.measles = True then cured(measles);
          player0.measles := False;

          if player0.leprosy = True then cured(leprosy);
          player0.leprosy := False;
        end;
        Blindness: begin
          if player0.blind = True then cured(blindness);
          player0.blind := False;
        end;
        Plague: begin
          if player0.plague = True then cured(plague);
          player0.plague := False;
        end;
        Smallpox: begin
          if player0.smallpox = True then cured(smallpox);
          player0.smallpox := False;
        end;
        Measles: begin
          if player0.measles = True then cured(measles);
          player0.measles := False;
        end;
        Leprosy: begin
          if player0.leprosy = True then cured(leprosy);
          player0.leprosy := False;
        end;

      end; {case .end.}

    end;
    2: begin { Item has STOPPED being used by player0 }

      {Hitpoints}
      stopped_using('maximum hitpoints', obj.hps);
      player0.maxhps := player0.maxhps - obj.hps;

      {Stamina}
      stopped_using('stamina', obj.stamina);
      player0.stamina := player0.stamina - obj.stamina;

      {Agility}
      stopped_using('agility', obj.agility);
      player0.agility := player0.agility - obj.agility;

      {Charisma}
      stopped_using('charisma', obj.charisma);
      player0.charisma := player0.charisma - obj.charisma;

      {Dexterity}
      stopped_using('dexterity', obj.dex);
      player0.dex := player0.dex - obj.dex;

      {Wisdom}
      stopped_using('wisdom', obj.wisdom);
      player0.wisdom := player0.wisdom - obj.wisdom;

      {Armor power}
      stopped_using('armor power', obj.armor);
      player0.armpow := player0.armpow - obj.armor;

      {Weapon power}
      stopped_using('weapon power', obj.attack);
      player0.weappow := player0.weappow - obj.attack;

      {Strength}
      stopped_using('strength', obj.strength);
      player0.strength := player0.strength - obj.strength;

      {Defence}
      stopped_using('defence', obj.defence);
      player0.defence := player0.defence - obj.defence;

      {Max mana}
      stopped_using('mana', obj.mana);
      player0.maxmana := player0.maxmana - obj.mana;

      if player0.mana > player0.maxmana then
      begin
        player0.mana := player0.maxmana;
      end;

    end;

  end; {case .end.}

end; {objekt_affekt *end*}

procedure Check_Valid_Equipment;
var
  loud: boolean;
  i:    integer;
begin

{1 : s:='Allow Hand Equipment';
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

  {remove items from inventory that no longer are allowed}
  for i := 1 to global_maxitem do
  begin
    if man.item[i] > 0 then
    begin

   {debug info
   if (global_maintrunning=true) and (global_ubeta=true) then begin
    d(15,'Jakob! man.item[i]='+commastr(man.item[i]));
   end;}

      if allowed_to_use(man.itemtype[i]) = False then
      begin
        man.item[i] := 0;
      end;
    end;
  end; {for i:= .end.}

  loud := False;
  if (config.allowitem[1] = False) and (man.hands > 0) then
  begin
    objekt_affect(2, man.hands, hands, man, loud);
    man.hands := 0;
  end;

  if (config.allowitem[2] = False) and (man.head > 0) then
  begin
    objekt_affect(2, man.head, head, man, loud);
    man.head := 0;
  end;

  if (config.allowitem[3] = False) and (man.body > 0) then
  begin
    objekt_affect(2, man.body, body, man, loud);
    man.body := 0;
  end;

  if (config.allowitem[4] = False) and (man.arms > 0) then
  begin
    objekt_affect(2, man.arms, arms, man, loud);
    man.arms := 0;
  end;

  if (config.allowitem[5] = False) and (man.lfinger > 0) then
  begin
    objekt_affect(2, man.lfinger, fingers, man, loud);
    man.lfinger := 0;
  end;

  if (config.allowitem[6] = False) and (man.rfinger > 0) then
  begin
    objekt_affect(2, man.rfinger, fingers, man, loud);
    man.rfinger := 0;
  end;

  if (config.allowitem[7] = False) and (man.legs > 0) then
  begin
    objekt_affect(2, man.legs, legs, man, loud);
    man.legs := 0;
  end;

  if (config.allowitem[8] = False) and (man.feet > 0) then
  begin
    objekt_affect(2, man.feet, feet, man, loud);
    man.feet := 0;
  end;

  if (config.allowitem[9] = False) and (man.waist > 0) then
  begin
    objekt_affect(2, man.waist, waist, man, loud);
    man.waist := 0;
  end;

  if (config.allowitem[10] = False) and (man.neck > 0) then
  begin
    objekt_affect(2, man.neck, neck, man, loud);
    man.neck := 0;
  end;

  if (config.allowitem[11] = False) and (man.neck2 > 0) then
  begin
    objekt_affect(2, man.neck2, neck, man, loud);
    man.neck2 := 0;
  end;

  if (config.allowitem[12] = False) and (man.face > 0) then
  begin
    objekt_affect(2, man.face, face, man, loud);
    man.face := 0;
  end;

  if (config.allowitem[13] = False) and (man.shield > 0) then
  begin
    objekt_affect(2, man.shield, shield, man, loud);
    man.shield := 0;
  end;

  if (config.allowitem[14] = False) and (man.abody > 0) then
  begin
    objekt_affect(2, man.abody, abody, man, loud);
    man.abody := 0;
  end;

  if (config.allowitem[15] = False) and (man.lhand > 0) then
  begin
    objekt_affect(2, man.lhand, weapon, man, loud);
    man.lhand := 0;
  end;

end; {Check_Valid_Equipment *end*}

function Allowed_To_Use;
var i: byte;
  a:   boolean;

begin

  {is it allowed to use this type of item? Decided by the values in .CFG}

  a := True;

  case typ of
    Hands: if config.allowitem[1] = False then a := False;
    Head: if config.allowitem[2] = False then a := False;
    Body: if config.allowitem[3] = False then a := False;
    Arms: if config.allowitem[4] = False then a := False;
    Fingers: if (config.allowitem[5] = False) and (config.allowitem[6] = False) then a := False;
    Legs: if config.allowitem[7] = False then a := False;
    Feet: if config.allowitem[8] = False then a := False;
    Waist: if config.allowitem[9] = False then a := False;
    Neck: if (config.allowitem[10] = False) and (config.allowitem[11] = False) then a := False;
    Face: if config.allowitem[12] = False then a := False;
    Shield: if config.allowitem[13] = False then a := False;
    Abody: if config.allowitem[14] = False then a := False;
  end; {case .end.}

  {return result}
  allowed_to_use := a;

end; {Allowed_To_Use *end*}

function Item_Power_Display(const item: orec): s70;
var Result: s70;
  sign:     string[1];
begin

 {displays item power
  used in status screen (statusc.pas)}

  Result := '';

  case item.ttype of
    Head,
    Body,
    Arms,
    Hands,
    Fingers,
    Legs,
    Feet,
    Waist,
    Neck,
    Face,
    Shield,
    Abody: begin
      if item.armor > 0 then sign := '+'
      else sign := '';
      Result := config.textcol1 + '(' + uwhite + sign + commastr(item.armor) + config.textcol1 + ')';
    end;
    Weapon: begin
      if item.attack > 0 then sign := '+'
      else sign := '';
      Result := config.textcol1 + '(' + uwhite + sign + commastr(item.attack) + config.textcol1 + ')';
    end;
  end; {case .end.}

  {return result}
  item_power_display := Result;

end; {item_power_display *end*}


function Empty_Chest_Slot: longint;
var q:    longint;
  kuvert: ChestItemRec;
  grepp:  boolean;
begin

  {find deleted post in playermarket file}

  grepp := False;
  empty_chest_slot := 1;

  for q := 1 to fs(FsChestItem) do
  begin
    Load_ChestItem(Fload, kuvert, q);

    {checking if item is no longer in use}
    if kuvert.PlyID = '' then
    begin
      empty_chest_slot := q;
      grepp := True;
      break;
    end;

  end;

  if not grepp then
  begin
    empty_chest_slot := fs(FsChestItem) + 1;
  end;

end; {empty_slot *end*}


procedure Chest_with_Items; {manage home Chest with items}
var
  go_ahead, done: boolean;

  ch:        char;

  i, cc, check, posmem, counter: integer;

  ChestItem: ChestItemRec;

  objekt:    ^orec;

  s:         s70;

begin {called from Home.pas}

  {init pointer variables}
  new(objekt);

  clearscreen;
  crlf;
  crlf;
  d(config.textcolor, 'You unlock the door to the room with your valuables ..');
  d(config.textcolor, 'Ahh, the door opens.');
  crlf;
  pause;

  done := False;
  ch := '?';
  repeat

    crlf;
    if ch = '?' then
    begin
      crlf;
      settings_header('Chest Room');
      d(config.textcolor, 'You examine the oak ' + ulcyan + 'Chest' + config.textcol1 + ' which holds your precious belongings.');
      d(config.textcolor, 'Now, what to do?');
      crlf;
      menu('(L)ist content');
      menu('(A)dd item');
      menu('(G)et item');
      menu('(S)tatus');
      menu('(R)eturn');
      crlf;
    end;
    sd(config.textcolor, 'Chest Room (' + config.textcol2 + '?' + config.textcol1 + ' for menu):');

    {get input from user}
    ch := upcase(getchar);

    {evaluate user input}
    case ch of


      {deactivate player items.. jakob}

      'S': begin {status}
        status(player);
        crlf;
      end;

      'G': begin {get item}
        crlf;

        d(config.textcolor, 'You open the chest and look at your belongings.');
        d(config.textcolor, 'Which item do you want?');
        sd(config.textcolor, '# :');

        cc := Get_Number(0, config.homeitems);

        if cc > 0 then
        begin
          {check if item exists}
          counter := 0;

          for i := 1 to fs(FsChestItem) do
          begin

            posmem := i;

            {load chest item data}
            load_chestitem(Fload, ChestItem, i);

            {does this this item belong to player?}
            if chestItem.PlyID = player.ID then
            begin

              Inc(counter);
              if counter = cc then
              begin
                {d(15,'Ding');}
                break;
              end;
            end;

          end; {for i:= .end.}

          if cc > 0 then
          begin
            {is there room in the inventory?}
            check := inventory_empty(player);
            if check = 0 then
            begin
              d(12, 'Inventory is full!');
              pause;
            end else
            begin
              {load item}
              if load_objekt(objekt^, ChestItem.ityp, ChestItem.pekare) = False then
              begin
                d(12, 'Unable to load item. #File I/O Error#');
                pause;
              end else
              begin

                if confirm('Get the ' + uitemc + objekt^.Name + config.textcol1, 'N') = True then
                begin
                  d(15, 'Ok.');
                  d(config.textcolor, 'You take the ' + uitemc + objekt^.Name + config.textcol1 + ' and put it in Your inventory.');

                  {add item to inventory}
                  player.item[check] := ChestItem.pekare;
                  player.itemtype[check] := ChestItem.Ityp;

                  {remove item from chest}
                  ChestItem.PlyID := emptystr;
                  ChestItem.pekare := 0;
                  load_chestitem(FSave, ChestItem, posmem);

                  {update user record, just in case.. not really necessary}
                  user_save(player);

                  {news-paper}
                  newsy(True,
                    'Home Storage',
                    ' ' + uplc + player.name2 + config.textcol1 + ' removed a ' + uitemc + objekt^.Name + config.textcol1 + ' from ' + sex3[player.sex] + ' impressive oak ' + ulcyan + 'Chest' + config.textcol1 + '.',
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

      end; {get item .end.}

      'A': begin {add item}

        go_ahead := True;

        {is the player allowed to store items}
        if config.homeitems < 1 then
        begin
          go_ahead := False;
          crlf;
          crlf;
          d(12, 'You are not allowed to store any items here.');
          pause;
        end else
        begin

          {count how many items player have stored}
          counter := 0;

          for i := 1 to fs(FsChestItem) do
          begin

            {load chest item data}
            load_chestitem(Fload, ChestItem, i);

            {does this this item belong to player?}
            if chestItem.PlyID = player.ID then
            begin
              Inc(counter);
            end;
          end; {for i:= .end.}

          if counter >= config.homeitems then
          begin
            go_ahead := False;
            crlf;
            crlf;
            d(12, 'The Chest is full! Make room. Go and sell some items.');
            d(12, 'Or you could visit the Market Place and put your items for sale.');
            pause;

          end else
          begin
            {set remaining # of items which can be added}
            counter := config.homeitems - counter;
          end;

        end;

        if go_ahead = True then
        begin

          crlf;
          repeat

            cc := item_select(player);
            if cc > 0 then
            begin

              if load_objekt(objekt^, player.itemtype[cc], player.item[cc]) = False then
              begin
                d(12, 'Unable to load item. #File I/O Error#');
                pause;
              end else
              begin

                crlf;

                sd(global_itemcol, objekt^.Name);

                if counter < 1 then
                begin
                  crlf;
                  d(12, 'The Chest is full!');
                  pause;
                end else
                begin
                  if confirm(' ', 'Y') = True then
                  begin
                    if objekt^.cursed = True then
                    begin
                      sd(12, 'You can''t get rid of ');
                      sd(global_itemcol, objekt^.Name);
                      sd(12, ' !');
                      d(12, ' It must be cursed!');
                    end else
                    begin

                      {setup item}
                      ChestItem.pekare := player.item[cc];
                      ChestItem.ityp := player.itemtype[cc];
                      ChestItem.PlyID := player.ID;

                      {save item}
                      Load_ChestItem(Fsave, ChestItem, Empty_Chest_Slot);

                      {remove item from player iventory}
                      player.item[cc] := 0;

                      {set remaining}
                      Dec(counter);

                      {update user record..just in case}
                      User_Save(player);

                      crlf;
                      sd(config.textcolor, 'You gently put the ');
                      sd(global_itemcol, objekt^.Name);
                      d(config.textcolor, ' in your ' + ulcyan + 'Chest' + config.textcol1 + '.');

                      {news-paper}
                      newsy(True,
                        'Home Storage',
                        ' ' + uplc + player.name2 + config.textcol1 + ' put a ' + uitemc + objekt^.Name + config.textcol1 + ' into ' + sex3[player.sex] + ' massive oak ' + ulcyan + 'Chest' + config.textcol1 + '.',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '');

                      pause;

                    end;
                  end;
                end;
              end;
            end;


          until cc = 0;
        end;

      end; {add item .end.}


      'L': begin {list items}

        crlf;
        crlf;
        settings_header('Chest Items');

        cc := 0;
        counter := 0;
        for i := 1 to fs(FsChestItem) do
        begin

          go_ahead := True;

          {load chest item data}
          load_chestitem(Fload, ChestItem, i);

          {does this this item belong to player?}
          if chestItem.PlyID <> player.ID then
          begin
            go_ahead := False;
          end;


          if go_ahead then
          begin
            {load corresponding object from database}
            if load_objekt(objekt^, ChestItem.ityp, ChestItem.pekare) = False then
            begin
              go_ahead := False;
            end;
          end;

          if go_ahead then
          begin

            {display item}
            Inc(counter);
            Inc(cc);
            sd(7, commastr(counter) + '. ');
            d(global_itemcol, objekt^.Name);

            if cc > 12 then
            begin
              cc := 0;
              if confirm('Continue List ', 'Y') = False then
              begin
                break;
              end;
            end;

          end;

        end; {for i .end.}

        {did we found any items}
        if counter = 0 then
        begin
          d(12, 'Bah! its empty.');
          pause;
        end;

      end; {list items .end.}


      'R': begin {return => to the living room}
        done := True;
        crlf;
        crlf;
        d(config.textcolor, 'You lock the chest and walk back to the living room.');
        crlf;
      end;

    end; {case .end.}

  until done;


  {dispose pointer variables}
  dispose(objekt);

end; {chest_with_items .end.}


end. {Unit Invent .end.}
