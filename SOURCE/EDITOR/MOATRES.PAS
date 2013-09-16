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

Unit MoatRes; {Usurper Editor - Reset MoatCreatures}

Interface

Procedure Reset_MoatCreatures;

Implementation

uses Init, jakobe, file_io;

var     c : integer;


Procedure Add_Creature( const name : s30;
                           cost    : longint;
                           hps     : longint;
                           basearm : longint;
                           baseatt : longint;
                           const desc1 : s70;
                           const desc2 : s70;
                           const desc3 : s70;
                           const desc4 : s70;
                           const desc5 : s70);


var moaty : MoatRec; {moat creature}

begin

 moaty.name    :=name;
 moaty.id      :=crypt(15); {if tag, to ease identification}
 moaty.cost    :=cost;
 moaty.hps     :=hps;
 moaty.deleted :=false;
 moaty.barmor  :=basearm;
 moaty.battack :=baseatt;

 moaty.descp[1]:=desc1;
 moaty.descp[2]:=desc2;
 moaty.descp[3]:=desc3;
 moaty.descp[4]:=desc4;
 moaty.descp[5]:=desc5;

 for c:=1 to 5 do begin
  if moaty.descp[c]='' then moaty.descp[c]:=emptystr;
 end;

 {$I-}write(moatfile,moaty);{$I+}
 if IOResult<>0 then unable_to_write(gufile);

end; {add_creature}

Procedure Reset_MoatCreatures;
begin

 c:=0;

 assign(moatfile,motfile);
 {$I-}rewrite(moatfile);{$I+}
 if IOResult<>0 then unable_to_create(motfile);

 add_creature('Eel',2500,50,15,15,
              'the black eel. using its jagged theeth the eel can',
              'prove to be disastrous to any careless swimmer.',
              '',
              '',
              '');

 add_creature('Crocodile',15000,90,25,25,
              '',
              '',
              '',
              '',
              '');

 add_creature('Giant Octopussy',50000,150,30,30,
              '',
              '',
              '',
              '',
              '');

 add_creature('Hippo',125000,300,32,32,
              'the hippo likes to squash his enemies.',
              'try to keep the Hippos in large numbers, they don''t',
              'like to be by themselves.',
              '',
              '');

 add_creature('Lake Monster',1100000,950,55,55,
              'this hideous creature lurks at the bottom of',
              'the murky lakes in the land. The Lake Monster is',
              'so big that it just fits in a Castle moat.',
              '',
              '');

 {$I-}close(moatfile);{$I+}
 if IOResult<>0 then unable_to_close(motfile);

end; {reset_moatcreatures}

end.
