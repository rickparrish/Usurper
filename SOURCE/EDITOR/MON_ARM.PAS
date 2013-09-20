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

unit Mon_Arm;

interface

procedure Arm_Monsters;

implementation

uses
  Init, jakobe, file_io;

procedure Arm_Monsters;
var
  ready1, ready2: boolean;
  cc, cc2:        longint;
  i, j:           integer;

begin

  cc := 1;
  cc2 := 0;
  counter := 0;

  for i := 1 to fs(FsMonster) do
  begin

    Inc(cc2);
    if cc2 > 23 then
    begin
      cc2 := 0;
      Inc(cc);
    end;

    {load monster}
    load_monster(fload, monster, i);

    if monster.weapnr > 0 then
    begin

      {load monster weapon}
      load_objekt(fload, objekt, weapon, monster.weapnr);

      {set monster weapon power}
      monster.weappow := objekt.attack;

      {save monster}
      load_monster(fsave, monster, i);

    end;


    if (monster.wuser) and (monster.weapnr = 0) then
    begin
      ready1 := False;

      for j := 1 to fso(Weapon) do
      begin

        load_objekt(fload, objekt, weapon, j);

        if (objekt.ttype = Weapon) and
          (objekt.attack >= cc) and
          (objekt.attack < cc + 4) and (random(2) = 0) then
        begin
          monster.weapnr := j;
          monster.weappow := objekt.attack;
          ready1 := True;
        end;

        if ready1 then
        begin
          load_monster(fsave, monster, i);
          break;
        end;
      end; {for j:= .end.}
    end;


    Inc(counter);
    Statbar(Counter, totobj, global_masterx, global_mastery, 1, 1);

  end;

end;

end.
