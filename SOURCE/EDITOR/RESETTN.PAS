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

Unit ResetTN; {Usurper Editor - Reset NPC Team Names}

Interface

Procedure Reset_TeamNames;

Implementation
Uses Init, file_io;

Procedure Reset_TeamNames;
const maxnr=50;
var txt : text;
    i : byte;
    names: array[1..maxnr] of string[50];
begin

 names[1]:='Legion of Terror';
 names[2]:='Army of Muscles';
 names[3]:='Black Wolves';
 names[4]:='Doomed Gang';
 names[5]:='Blood Swords';
 names[6]:='Wizards Creation';
 names[7]:='Skull Crackers';
 names[8]:='Guild of Purity';
 names[9]:='Lurking Terror';
 names[10]:='Overlords';
 names[11]:='Lennys Crew';
 names[12]:='Hammers';
 names[13]:='Freak Show';
 names[14]:='Golden Youth';
 names[15]:='Contaminated Wrestlers';
 names[16]:='Hacksaws';
 names[17]:='Messing Up Inc.';
 names[18]:='Dog and Bark';
 names[19]:='Red Army';
 names[20]:='Supreme Rulers';
 names[21]:='Rhinos Holy Defence';
 names[22]:='White Robes';
 names[23]:='Urban Lords';
 names[24]:='Sword Masters';
 names[25]:='Biohazards';
 names[26]:='Hollow Cube';
 names[27]:='Infiltrators';
 names[28]:='No Brains';
 names[29]:='Decapitation Crew';
 names[30]:='Grifters';
 names[31]:='Serious Trouble';
 names[32]:='Crying Fools';
 names[33]:='Nippes Turbo Crew';
 names[34]:='LSD Surfers';
 names[35]:='RuLEs';
 names[36]:='Tools of Destruction';
 names[37]:='Spears of Tears';
 names[38]:='Enfant Terribles';
 names[39]:='StormAxe';
 names[40]:='Serious Attitude';
 names[41]:='Violence Us!';
 names[42]:='Looters';
 names[43]:='Grave Pushers';
 names[44]:='Selwyns Servants';
 names[45]:='Roughabouts';
 names[46]:='Spear Scum';
 names[47]:='Counterstrike';
 names[48]:='Exit Life';
 names[49]:='Riff Raff';
 names[50]:='*Doom*';

 if open_txtfile(trewrite,txt,tnamesf) then begin

  for i:=1 to maxnr do begin
   writeln_to_text(txt,names[i]);
  end;

  close_text(txt);
 end
 else begin
  {error}
  unable_to_create(tnamesf);
 end;

end; {Reset_TeamNames *end*}

end. {Unit ResetTN .end.}
