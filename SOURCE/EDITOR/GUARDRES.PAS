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

unit GuardRes;

interface

procedure Reset_DoorGuards;

implementation

uses
  Init, jakobe, file_io;

var  c: integer;


procedure Add_Guard(const Name: s70; cost: longint; hps: longint; multi: boolean; basearm: longint;
  baseatt: longint; const lin1: s70; const lin2: s70; const lin3: s70; const lin4: s70; const lin5: s70);
var
  i: integer;
begin

  guard.Name := Name;
  guard.cost := cost;
  guard.hps := hps;
  guard.multiple := multi;
  guard.barmor := basearm;
  guard.battack := baseatt;

  guard.descp[1] := lin1;
  guard.descp[2] := lin2;
  guard.descp[3] := lin3;
  guard.descp[4] := lin4;
  guard.descp[5] := lin5;

  for i := 1 to 5 do
  begin
    if guard.descp[i] = '' then
      guard.descp[i] := emptystr;
  end;

 {$I-}Write(guardfile, guard);{$I+}
  if IOResult <> 0 then
    unable_to_write(gufile);

  {gl”m inte att „ndra 7:an om antalet guards „ndras}
  Inc(c);
  Statbar(C, 7, global_masterx, global_mastery, 1, 1);

end;

procedure Reset_DoorGuards;
begin

  c := 0;

  Assign(guardfile, gufile);
 {$I-}rewrite(guardfile);{$I+}
  if IOResult <> 0 then
    unable_to_create(gufile);

  add_guard('Cat', 1000, 50, True, 25, 25,
    'The Innkeeper is the breeder of this animal.',
    'It''s the regular domestic type, with the',
    'exception of extended claws and increased',
    'weight.',
    '');

  add_guard('Bulldog', 2500, 90, True, 25, 25,
    'A stinking orcish breed.',
    'The animal is seldom fed, and is',
    'therefore extremely aggressive.',
    '',
    '');

  add_guard('Rattle Snake', 4000, 120, True, 25, 25,
    'Effective when they use the moment of',
    'surprise. If not treated, the injected poison can',
    'be dangerous.',
    '',
    '');

  add_guard('Gorilla', 8700, 150, True, 25, 25,
    'The gorilla has great powers when it comes',
    'down to close combat. When the gorilla grapples',
    'with an opponent, the fight is often in a moment.',
    'Dancing with this ape could prove to be a',
    'fatal mistake.');

  add_guard('Grizzly Bear', 15000, 250, True, 25, 25,
    'Large fierce grey-brown bear of the Northern',
    'parts of the land.',
    'This particular breed is equipped with extra',
    'thick fur.',
    '');

  add_guard('Stone Giant', 25000, 300, True, 52, 52,
    'The stone giant is summoned at request',
    'by Akrappa the old conjurer.',
    'With an armor of stone, the giant is',
    'guaranteed to survive longer than a gorilla',
    'for instance.');

  add_guard('Small Dragon', 75000, 500, True, 25, 25,
    'The drawback with the dragon is that it',
    'all too often sleeps on its post.',
    'Other than this, you should have no reason to',
    'be concerned with your safety.',
    '');

 {$I-}Close(guardfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(gufile);

end;

end.
