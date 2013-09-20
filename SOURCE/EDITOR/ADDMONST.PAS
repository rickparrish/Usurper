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


unit AddMonst;

interface

uses
  Init;

procedure Add_Monster(armoruser: boolean; weaponuser: boolean; weapon: longint; armor: longint; strength: integer; const Name: s70; grabweap: boolean; grabarm: boolean; const phrase: s70);

implementation

uses
  JakobE, File_IO;

procedure Add_Monster;
var i: byte;
begin

  if add_fake then
  begin
    Inc(counter);
    exit;
  end;

  monster.Name := Name;
  monster.weapnr := weapon;
  monster.armnr := armor;
  monster.grabweap := grabweap; {kan man ta vapnet}
  monster.grabarm := grabarm;
  monster.phrase := phrase;     {vad s„ger odjuret?}
  if monster.phrase = '' then monster.phrase := emptystr;
  monster.wuser := weaponuser;
  monster.auser := armoruser;

  monster.magicres := random(50);

  monster.strength := strength + random(10);

  if weaponuser = False then monster.strength := monster.strength + random(20);


  {all of Jakob's monsters had strength*3}
  monster.hps := monster.strength * 3;
  monster.punch := 0;
  monster.poisoned := False;
  monster.weapon := emptystr;
  monster.armor := emptystr;
  monster.disease := False;
  monster.target := 0;
  monster.weappow := 0;
  monster.armpow := 0;
  monster.iq := random(100);
  monster.evil := random(11);

  if counter >= 10 then
  begin
    monster.magiclevel := counter div 10;
  end else
  begin
    monster.magiclevel := 1;
  end;
  if monster.magiclevel > 100 then monster.magiclevel := 100;

  monster.mana := 0;
  monster.maxmana := 0;

  {giving monsters random spell capability}
  for i := 1 to maxmspells do
  begin
    if random(10) = 0 then monster.spell[i] := True
    else monster.spell[i] := False;
  end;

  {write to disk}
 {$I-}Write(monsterfile, monster);{$I-}
  if IOResult <> 0 then unable_to_write(monfile);

  Inc(counter); {statbar must have the exact amount of posts..}
  Statbar(Counter, totobj, global_masterx, global_mastery, 1, 1);

end;



end.
