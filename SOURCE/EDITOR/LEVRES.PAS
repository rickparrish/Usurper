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

unit LevRes;

interface

procedure Reset_Levels;

implementation

uses
  Init, Jakobe, file_io;

var c: integer;

procedure Add_Level(xp: longint);
begin

  level.xpneed := xp;
  {write to disk}
 {$I-}Write(levelfile, level);{$I+}
  if IOResult <> 0 then unable_to_write(lvlfile);

  Inc(c);
  Statbar(C, 101, global_masterx, global_mastery, 1, 2);

end;

procedure Reset_Levels;
begin

  c := 0;

  Assign(levelfile, lvlfile);
 {$I-}rewrite(levelfile);{$I+}
  if IOResult <> 0 then unable_to_create(lvlfile);

  add_level(900);
  add_level(5000);
  add_level(10000);
  add_level(15000);
  add_level(20000);
  add_level(30000);
  add_level(40000);
  add_level(60000);
  add_level(85000);
  add_level(120000);
  add_level(140000);
  add_level(180000);
  add_level(240000);
  add_level(290000);
  add_level(340000);
  add_level(400000);
  add_level(500000);
  add_level(600000);
  add_level(850000);
  add_level(1000000);
  add_level(1200000);
  add_level(1400000);
  add_level(1600000);
  add_level(1800000);
  add_level(2200000);
  add_level(2500000);
  add_level(2700000);
  add_level(2900000);
  add_level(3200000);
  add_level(3400000);
  add_level(3600000);
  add_level(3800000);
  add_level(4200000);
  add_level(4400000);
  add_level(4600000);
  add_level(4800000);
  add_level(5000000);
  add_level(5200000);
  add_level(5400000);
  add_level(5600000);
  add_level(5800000);
  add_level(6000000);
  add_level(6200000);
  add_level(6400000);
  add_level(6600000);
  add_level(6800000);
  add_level(7000000);
  add_level(7200000);
  add_level(7400000);
  add_level(7600000);
  add_level(7800000);
  add_level(8000000);
  add_level(8200000);
  add_level(8400000);
  add_level(8600000);
  add_level(8800000);
  add_level(9000000);
  add_level(9200000);
  add_level(9400000);
  add_level(9600000);
  add_level(9800000);
  add_level(10000000);
  add_level(10200000);
  add_level(10400000);
  add_level(10600000);
  add_level(10800000);
  add_level(11000000);
  add_level(12000000);
  add_level(13000000);
  add_level(14000000);
  add_level(15000000);
  add_level(16000000);
  add_level(17000000);
  add_level(18000000);
  add_level(19000000);
  add_level(20000000);
  add_level(21000000);
  add_level(22000000);
  add_level(23000000);
  add_level(24000000);
  add_level(25000000);
  add_level(26000000);
  add_level(27000000);
  add_level(28000000);
  add_level(29000000);
  add_level(30000000);
  add_level(31000000);
  add_level(32000000);
  add_level(33000000);
  add_level(35000000);
  add_level(36000000);
  add_level(37000000);
  add_level(39000000);
  add_level(41000000);
  add_level(42000000);
  add_level(43000000);
  add_level(45000000);
  add_level(47000000);
  add_level(48000000);
  add_level(49000000);
  add_level(50000000);

 {$I-}Close(levelfile);{$I+}
  if IOResult <> 0 then unable_to_close(lvlfile);

end;

end.
