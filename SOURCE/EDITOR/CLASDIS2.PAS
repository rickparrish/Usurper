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

Unit ClasDis2;

Interface
Uses Init;

Function Class_Display ( class : classes ) : string;
Function Class_Display2(nr : byte ) : string;

Implementation

Function Class_Display;
begin

 case class of
  Alchemist : class_display:='Alchemist';
  Assassin  : class_display:='Assassin';
  Barbarian : class_display:='Barbarian';
  Bard      : class_display:='Bard';
  Cleric    : class_display:='Cleric';
  Jester    : class_display:='Jester';
  Magician  : class_display:='Magician';
  Paladin   : class_display:='Paladin';
  Ranger    : class_display:='Ranger';
  Sage      : class_display:='Sage';
  Warrior   : class_display:='Warrior';
 end;

end;

Function Class_Display2;
var s : string;
begin

 case nr of
  1  : s:=class_display(Alchemist);
  2  : s:=class_display(Assassin);
  3  : s:=class_display(Barbarian);
  4  : s:=class_display(Bard);
  5  : s:=class_display(Cleric);
  6  : s:=class_display(Jester);
  7  : s:=class_display(Magician);
  8  : s:=class_display(Paladin);
  9  : s:=class_display(Ranger);
  10 : s:=class_display(Sage);
  11 : s:=class_display(Warrior);
 end;

 class_display2:=s;

end;

end.
