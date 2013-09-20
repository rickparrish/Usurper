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


unit SwapEq;

 {Usurper - Swap equipment}
 {winner scans/takes defeated players equipment}
interface

uses
  Init;

procedure Swap_Objects(var victor: userrec; var loser: userrec; shout: boolean);
implementation

uses
  Jakob, Cms, Invent,
  Various, Various2, Comp_use,
  Mail, File_io;

var
  firstmess: boolean;

  x:         longint;

  objekt:    ^orec;
  inweap:    ^weaprec;
  inarm:     ^armrec;

procedure Check_Inventory(var temp: userrec);
begin

  if inventory_empty(temp) = 0 then
  begin

    d(config.textcolor, 'Your inventory is full!');

    if confirm('Drop something ', 'Y') = True then
    begin
      drop_item(temp);
    end;

  end;

end; {check_inventory *end*}

procedure First_Message(mode: byte; const Name: s30; shout: boolean);
begin

  if (firstmess = False) and (shout = True) then
  begin

    case mode of
      1: begin
        d(14, 'You have found something!');
      end;
      2: begin
        d(global_plycol, Name + uyellow + ' has found some stuff.' + config.textcol1);
      end;
    end; {case .end.}

    firstmess := True;

  end;

end; {first_message *end*}

function Stolen_Item_Value(const obj: orec): s70;
var Result: s100;
begin

 {returns value of obj in a string, to be used in messages to
  winners/losers about stolen equipment value}
  Result := ' ' + item_power_display(obj);
  Result := Result + '   -- worth ' + uyellow + commastr(obj.Value) + config.textcol1 + ' ' + many_money(obj.Value) + '.';

  {return result}
  stolen_item_value := Result;

end; {stolen_item_value *end*}

procedure Start_To_Use;
begin

  crlf;
  sd(config.textcolor, 'Start to use the ');
  sd(global_itemcol, objekt^.Name);
  sd(config.textcolor, ' immediately');
  if confirm('', 'Y') = True then
  begin
    use_item(x);
  end else
  begin
    sd(config.textcolor, 'You put the ');
    sd(global_itemcol, objekt^.Name);
    d(config.textcolor, ' in your backpack.');
    crlf;
  end;

end; {start_to_use *end*}


procedure Swap_Objects;
type Looting_HandTypes = (NoHands, BothHands, LeftHand, RightHand,
    RandomLeftRight, RandomLeftRightBoth,
    RandomLeftRightBothNone);
var looting_hands: looting_handtypes;


  procedure Set_LootHands;
  begin
{ 0=not allowed to take hand items
  1=Both        REFERENCE : various.pas - read_start_ ..
  2=Left only
  3=Right only
  4=Random  left/right
  5=Random  left/right/both}

    case config.loothands of
      0: looting_hands := NoHands;
      1: looting_hands := BothHands;
      2: looting_hands := LeftHand;
      3: looting_hands := RightHand;
      4: looting_hands := RandomLeftRight;
      5: looting_hands := RandomLeftRightBoth;
      6: looting_hands := RandomLeftRightBoth;
      else looting_hands := NoHands;
    end; {case .end.}

  end;   {set_loothands *end*}

         {Swap_Objects *start*}
const

  stolar     = global_maxitem + 16;
  loser_loud = False; {affected items...speak out loud how the item
                               affects loser}

var

  stolen:         array [1..stolar] of ^s70;

  i, stolcount:   integer;

  des, slask, s2: s70;

begin

{
 loot[1] l/r Hand
 loot[2]     Head
 loot[3]     Body
 loot[4]     Arm
 loot[5]     Fingers
 loot[6]     Legs
 loot[7]     Feet
 loot[8]     Waist
 loot[9]     Neck
 loot[10]    Face
 loot[11]    Shield
 loot[12]    On Hands
 loot[13]    Around Body
 loot[14]    Inventory
}

  {What objects can victor take from loser?}

  {init pointer variables}
  new(objekt);
  new(inweap);
  new(inarm);

  firstmess := False;

  stolcount := 1;

  {init pointer variables}
  for i := 1 to stolar do
  begin
    new(stolen[i]);
    stolen[i]^ := emptystr;
  end;

  {d(15,commastr(maxavail));}

  if config.classic then
  begin
    if (victor.name2 = player.name2) and (global_maintrunning = False) then
    begin

      if loser.weapon <> 0 then
      begin
        load_weapon(loser.weapon, inweap^);
        crlf;
        sd(config.textcolor, 'You have found : ');
        sd(global_itemcol, inweap^.Name);
        d(14, ' (power ' + commastr(inweap^.pow * 11) + ')');

        inweap^.Name := '';
        inweap^.pow := 0;
        if victor.weapon <> 0 then
          load_weapon(victor.weapon, inweap^);

        sd(config.textcolor, 'Your weapon    : ');
        sd(global_itemcol, inweap^.Name);
        d(14, ' (power ' + commastr(inweap^.pow * 11) + ')');

        crlf;
        if confirm('Swap Weapons ', 'N') = True then
        begin
          d(config.textcolor, 'You took the weapon!');
          swappy(victor.weapon, loser.weapon);
          swappy(victor.wpow, loser.wpow);

          slask := uplc + victor.name2 + config.textcol1 + ' took your weapon!';

          post(MailSend,
            loser.name2,
            loser.ai,
            False,
            mailrequest_nothing,
            '',
            slask,
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
            '',
            '',
            '');

        end;
      end; {weapon steal .end.}

      if loser.armor <> 0 then
      begin
        load_armor(loser.armor, inarm^);
        crlf;
        sd(config.textcolor, 'You have found : ');
        sd(global_itemcol, inarm^.Name);
        d(14, ' (power ' + commastr(inarm^.pow * 11) + ')');

        inarm^.Name := '';
        inarm^.pow := 0;
        if victor.armor <> 0 then
          load_armor(victor.armor, inarm^);

        sd(config.textcolor, 'Your armor     : ');
        sd(global_itemcol, inarm^.Name);
        d(14, ' (power ' + commastr(inarm^.pow * 11) + ')');

        crlf;
        if confirm('Swap Armor ', 'N') = True then
        begin

          d(config.textcolor, 'You took the armor!');
          swappy(victor.armor, loser.armor);
          swappy(victor.apow, loser.apow);

          slask := uplc + victor.name2 + config.textcol1 + ' took your armor!';

          post(MailSend,
            loser.name2,
            loser.ai,
            False,
            mailrequest_nothing,
            '',
            slask,
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
            '',
            '',
            '');
        end;
      end; {armor steal .end.}

    end else
    begin {victor is computer controlled}
      if loser.weapon <> 0 then
      begin
        if victor.wpow < loser.wpow then
        begin
          swappy(victor.weapon, loser.weapon);
          swappy(victor.wpow, loser.wpow);

          slask := uplc + victor.name2 + config.textcol1 + ' took your weapon!';

          {mail}
          post(MailSend,
            loser.name2,
            loser.ai,
            False,
            mailrequest_nothing,
            '',
            slask,
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
            '',
            '',
            '');
        end;
      end;
      if loser.armor <> 0 then
      begin
        if victor.apow < loser.apow then
        begin
          swappy(victor.armor, loser.armor);
          swappy(victor.apow, loser.apow);

          slask := uplc + victor.name2 + config.textcol1 + ' took your armor!';

          post(MailSend,
            loser.name2,
            loser.ai,
            False,
            mailrequest_nothing,
            '',
            slask,
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
            '',
            '',
            '');
        end;
      end;
    end;

    {remove pointer variables}
    for i := 1 to stolar do
    begin
      dispose(stolen[i]);
    end;

    dispose(objekt);
    dispose(inweap);
    dispose(inarm);
    exit;
  end; {Classic *END*}

       {NEW GAME MODE}

       {set looting hand items variable}
  set_loothands;

  case looting_hands of
    RandomLeftRight: begin
      case random(2) of
        0: looting_hands := LeftHand;
        1: looting_hands := RightHand;
      end; {case .end.}

    end;
    RandomLeftRightBoth: begin
      case random(3) of
        0: looting_hands := LeftHand;
        1: looting_hands := RightHand;
        2: looting_hands := BothHands;
      end; {case .end.}
    end;

    RandomLeftRightBothNone: begin
      case random(4) of
        0: looting_hands := LeftHand;
        1: looting_hands := RightHand;
        2: looting_hands := BothHands;
        3: looting_hands := NoHands;
      end; {case .end.}
    end;
  end;     {case .end.}

  {
    NoHands;
    BothHands;
    LeftHand;
    RightHand;
    RandomLeftRight;
    RandomLeftRightBoth;
    RandomLeftRightBothNone;
    }


  if (victor.name2 = player.name2) and (global_maintrunning = False) then
  begin

    {* Right Hand Swap *}
    if (loser.rhand > 0) and (looting_hands in [BothHands, RightHand]) then
    begin

      first_message(1, player.name2, shout);
      load_objekt(objekt^, weapon, loser.rhand);

      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin

        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.rhand;
          victor.itemtype[x] := weapon;
          objekt_affect(2, loser.rhand, weapon, loser, loser_loud);
          loser.rhand := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);

          start_to_use;
        end;
      end;
    end;

    {* Left Hand Swap *}
    if (loser.lhand > 0) and (looting_hands in [BothHands, LeftHand]) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, weapon, loser.lhand);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin

        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.lhand;
          victor.itemtype[x] := weapon;

          objekt_affect(2, loser.lhand, weapon, loser, loser_loud);
          loser.lhand := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Head Swap *}
    if (config.loot[2] = True) and (loser.head > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, head, loser.head);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin

        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.head;
          victor.itemtype[x] := head;

          objekt_affect(2, loser.head, head, loser, loser_loud);
          loser.head := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Body Swap *}
    if (config.loot[3] = True) and (loser.body > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, body, loser.body);
      sd(config.textcolor, 'Take');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin

        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.body;
          victor.itemtype[x] := body;
          objekt_affect(2, loser.body, body, loser, loser_loud);
          loser.body := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Arm Swap *}
    if (config.loot[4] = True) and (loser.arms > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, arms, loser.arms);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.arms;
          victor.itemtype[x] := arms;

          objekt_affect(2, loser.arms, arms, loser, loser_loud);
          loser.arms := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;

      end;
    end;

    {* Right Finger Swap *}
    if (config.loot[5] = True) and (loser.rfinger > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, fingers, loser.rfinger);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin

        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.rfinger;
          victor.itemtype[x] := fingers;

          objekt_affect(2, loser.rfinger, fingers, loser, loser_loud);
          loser.rfinger := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Left Finger Swap *}
    if (config.loot[5] = True) and (loser.lfinger > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, fingers, loser.lfinger);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.lfinger;
          victor.itemtype[x] := fingers;

          objekt_affect(2, loser.lfinger, fingers, loser, loser_loud);
          loser.lfinger := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Leg Swap *}
    if (config.loot[6] = True) and (loser.legs > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, legs, loser.legs);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.legs;
          victor.itemtype[x] := legs;

          objekt_affect(2, loser.legs, legs, loser, loser_loud);
          loser.legs := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Feet Swap *}
    if (config.loot[7] = True) and (loser.feet > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, feet, loser.feet);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.feet;
          victor.itemtype[x] := feet;

          objekt_affect(2, loser.feet, feet, loser, loser_loud);
          loser.feet := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Waist Swap *}
    if (config.loot[8] = True) and (loser.waist > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, waist, loser.waist);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);
        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.waist;
          victor.itemtype[x] := waist;

          objekt_affect(2, loser.waist, waist, loser, loser_loud);
          loser.waist := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Neck Swap *}
    if (config.loot[9] = True) and (loser.neck > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, neck, loser.neck);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.neck;
          victor.itemtype[x] := neck;

          objekt_affect(2, loser.neck, neck, loser, loser_loud);
          loser.neck := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Neck 2 Swap *}
    if (config.loot[9] = True) and (loser.neck2 > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, neck, loser.neck2);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.neck2;
          victor.itemtype[x] := neck;
          objekt_affect(2, loser.neck2, neck, loser, loser_loud);
          loser.neck2 := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Face Swap *}
    if (config.loot[10] = True) and (loser.face > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, face, loser.face);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.face;
          victor.itemtype[x] := face;
          objekt_affect(2, loser.face, face, loser, loser_loud);
          loser.face := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Shield Swap *}
    if (config.loot[11] = True) and (loser.shield > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, shield, loser.shield);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);

        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.shield;
          victor.itemtype[x] := shield;
          objekt_affect(2, loser.shield, shield, loser, loser_loud);
          loser.shield := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* On Hands Swap *}
    if (config.loot[12] = True) and (loser.hands > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, hands, loser.hands);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);
        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.hands;
          victor.itemtype[x] := hands;
          objekt_affect(2, loser.hands, hands, loser, loser_loud);
          loser.hands := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Around Body Swap *}
    if (config.loot[13] = True) and (loser.abody > 0) then
    begin
      first_message(1, player.name2, shout);
      load_objekt(objekt^, abody, loser.abody);
      sd(config.textcolor, 'Take ');
      sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));
      if confirm('', 'N') = True then
      begin
        check_inventory(victor);
        if inventory_empty(victor) > 0 then
        begin
          x := inventory_empty(victor);
          victor.item[x] := loser.abody;
          victor.itemtype[x] := abody;

          objekt_affect(2, loser.abody, abody, loser, loser_loud);
          loser.abody := 0;
          sd(config.textcolor, 'You take the ');
          d(global_itemcol, objekt^.Name + config.textcol1 + '.');
          stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
          Inc(stolcount);
          start_to_use;
        end;
      end;
    end;

    {* Inventory Swap *}
    if config.loot[14] = True then
    begin
      for i := 1 to global_maxitem do
      begin

        if loser.item[i] > 0 then
        begin
          first_message(1, player.name2, shout);
          load_objekt(objekt^, loser.itemtype[i], loser.item[i]);
          sd(config.textcolor, 'Take ');
          sd(global_itemcol, objekt^.Name + ' ' + item_power_display(objekt^));

          if confirm('', 'N') = True then
          begin
            check_inventory(victor);

            if inventory_empty(victor) > 0 then
            begin
              x := inventory_empty(victor);
              victor.item[x] := loser.item[i];
              victor.itemtype[x] := loser.itemtype[i];

              loser.item[i] := 0;
              sd(config.textcolor, 'You take the ');
              d(global_itemcol, objekt^.Name + config.textcol1 + '.');
              stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
              Inc(stolcount);
              start_to_use;
            end;
          end;

        end;
      end;
    end;

  end else
  begin

    {* VICTOR is computer controlled *}

    if loser.name2 = player.name2 then
      des := 'your '
    else des := loser.name2 + 's ';

    {* Right Hand Swap *}
    if (loser.rhand > 0) and (looting_hands in [BothHands, RightHand]) then
    begin

      first_message(2, victor.name2, shout);

      load_objekt(objekt^, weapon, loser.rhand);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.rhand, weapon, loser, loser_loud);

        computer_use(victor, objekt^, loser.rhand, shout);

        loser.rhand := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Left Hand Swap *}
    if (loser.lhand > 0) and (looting_hands in [BothHands, LeftHand]) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, weapon, loser.lhand);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.lhand, weapon, loser, loser_loud);

        computer_use(victor, objekt^, loser.lhand, shout);

        loser.lhand := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Head Swap *}
    if (config.loot[2] = True) and (loser.head > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, head, loser.head);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.head, head, loser, loser_loud);

        computer_use(victor, objekt^, loser.head, shout);

        loser.head := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Body Swap *}
    if (config.loot[3] = True) and (loser.body > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, body, loser.body);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.body, body, loser, loser_loud);

        computer_use(victor, objekt^, loser.body, shout);

        loser.body := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Arm Swap *}
    if (config.loot[4] = True) and (loser.arms > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, arms, loser.arms);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.arms, arms, loser, loser_loud);

        computer_use(victor, objekt^, loser.arms, shout);

        loser.arms := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Right Finger Swap *}
    if (config.loot[5] = True) and (loser.rfinger > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, fingers, loser.rfinger);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.rfinger, fingers, loser, loser_loud);

        computer_use(victor, objekt^, loser.rfinger, shout);

        loser.rfinger := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Left Finger Swap *}
    if (config.loot[5] = True) and (loser.lfinger > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, fingers, loser.lfinger);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.lfinger, fingers, loser, loser_loud);

        computer_use(victor, objekt^, loser.lfinger, shout);

        loser.lfinger := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Leg Swap *}
    if (config.loot[6] = True) and (loser.legs > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, legs, loser.legs);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.legs, legs, loser, loser_loud);

        computer_use(victor, objekt^, loser.legs, shout);

        loser.legs := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Feet Swap *}
    if (config.loot[7] = True) and (loser.feet > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, feet, loser.feet);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.feet, feet, loser, loser_loud);

        computer_use(victor, objekt^, loser.feet, shout);

        loser.feet := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Waist Swap *}
    if (config.loot[8] = True) and (loser.waist > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, waist, loser.waist);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.waist, waist, loser, loser_loud);

        computer_use(victor, objekt^, loser.waist, shout);

        loser.waist := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Neck Swap *}
    if (config.loot[9] = True) and (loser.neck > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, neck, loser.neck);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.neck, neck, loser, loser_loud);

        computer_use(victor, objekt^, loser.neck, shout);

        loser.neck := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Neck 2 Swap *}
    if (config.loot[9] = True) and (loser.neck2 > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, neck, loser.neck2);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.neck2, neck, loser, loser_loud);

        computer_use(victor, objekt^, loser.neck2, shout);

        loser.neck2 := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Face Swap *}
    if (config.loot[10] = True) and (loser.face > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, face, loser.face);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.face, face, loser, loser_loud);

        computer_use(victor, objekt^, loser.face, shout);

        loser.face := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Shield Swap *}
    if (config.loot[11] = True) and (loser.shield > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, shield, loser.shield);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.shield, shield, loser, loser_loud);

        computer_use(victor, objekt^, loser.shield, shout);

        loser.shield := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* On Hands Swap *}
    if (config.loot[12] = True) and (loser.hands > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, hands, loser.hands);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.hands, hands, loser, loser_loud);

        computer_use(victor, objekt^, loser.hands, shout);

        loser.hands := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Around Body Swap *}
    if (config.loot[13] = True) and (loser.abody > 0) then
    begin
      first_message(2, victor.name2, shout);
      load_objekt(objekt^, abody, loser.abody);
      if inventory_empty(victor) > 0 then
      begin
        x := inventory_empty(victor);
        objekt_affect(2, loser.abody, abody, loser, loser_loud);

        computer_use(victor, objekt^, loser.abody, shout);

        loser.abody := 0;
        stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
        Inc(stolcount);
      end;
    end;

    {* Inventory Swap *}
    if config.loot[14] = True then
    begin
      for i := 1 to global_maxitem do
      begin
        if loser.item[i] > 0 then
        begin
          first_message(2, victor.name2, shout);
          load_objekt(objekt^, loser.itemtype[i], loser.item[i]);
          if inventory_empty(victor) > 0 then
          begin
            x := inventory_empty(victor);

            computer_use(victor, objekt^, loser.item[i], shout);

            loser.item[i] := 0;
            stolen[stolcount]^ := uitemc + objekt^.Name + config.textcol1 + stolen_item_value(objekt^);
            Inc(stolcount);
          end;
        end;
      end; {for i:= .end.}
    end;

  end;

  {* message to loser about lost posessions *}
  if (stolen[1]^ <> '') and
    (loser.ai = 'H') then
  begin

    s2 := 'Items stolen by ' + victor.name2 + ' :';
    slask := 'Items stolen by ' + uplc + victor.name2 + config.textcol1 + ' :';

    post(MailSend,
      loser.name2,
      loser.ai,
      False,
      mailrequest_nothing,
      '',
      'Items Stolen by ' + uplc + victor.name2 + config.textcol1 + ' :',
      mkstring(length(s2), underscore),
      stolen[1]^,
      stolen[2]^,
      stolen[3]^,
      stolen[4]^,
      stolen[5]^,
      stolen[6]^,
      stolen[7]^,
      stolen[8]^,
      stolen[9]^,
      stolen[10]^,
      stolen[11]^,
      stolen[12]^,
      stolen[13]^);

  end;

  {* message to victor about new posessions *}
  if (stolen[1]^ <> '') and
    (victor.ai = 'H') and
    (victor.name2 <> player.name2) then
  begin

    s2 := 'You took some stuff from ' + loser.name2 + ' :';
    slask := 'You took some stuff from ' + uplc + loser.name2 + config.textcol1 + ' :';

    post(MailSend,
      victor.name2,
      victor.ai,
      False,
      mailrequest_nothing,
      '',
      'You took some stuff from ' + uplc + loser.name2 + config.textcol1 + ' :',
      mkstring(length(s2), underscore),
      stolen[1]^,
      stolen[2]^,
      stolen[3]^,
      stolen[4]^,
      stolen[5]^,
      stolen[6]^,
      stolen[7]^,
      stolen[8]^,
      stolen[9]^,
      stolen[10]^,
      stolen[11]^,
      stolen[12]^,
      stolen[13]^);
  end;

  {dispose pointer variables}
  for i := 1 to stolar do
  begin
    dispose(stolen[i]);
  end;
  dispose(inweap);
  dispose(inarm);
  dispose(objekt);

end; {swap_objects *end*}

end. {Unit SwapEq .end.}
