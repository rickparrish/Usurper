{$IFDEF WIN32}
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

Unit Obj_Ad;

Interface

Uses Init;

Procedure Add_Object(
                     const name : s70;    {objektets namn}
                     ttype: objtype;   {typ av objekt}
                     value : longint;  {v„rdet p† objektet}
                     hps  : integer;   {ska objekt ”ka/minska hps}
                     stamina : integer; {ska objekt ”ka stamina}
                     agility : integer; {ska objekt ”ka agility}
                     charisma : integer; {ska objekt ”ka charisma}
                     dexterity : integer;{ska objekt ”ka dexterity}
                     wisdom : integer;   {ska objekt ”ka wisdom}
                     mana   : integer;   {ska objektet ”ka manan}
                     armor : integer;  {ska objekt ”ka armor v„rdet}
                     attack : integer; {ska objekt ”ka attack v„rdet}
                     const owned  : s70;  {„gd av}
                     onlyone: boolean; {bara ett s†dant objekt i hela spelet}
                     cure   : cures;   {kurerar den n†got}
                     shop   : boolean; {finnas i shoppen}
                     dng    : boolean; {kunna hittas i dungeons?}
                     cursed : boolean; {cursed?}
                     minlev : integer; {min level att hittas i dngs}
                     maxlev : integer; {max level att hittas i dngs}
                     const desc1 : s70;   {normal beskrivning}
                     const desc2 : s70;   {normal beskrivning}
                     const desc3 : s70;   {normal beskrivning}
                     const desc4 : s70;   {normal beskrivning}
                     const desc5 : s70;   {normal beskrivning}
                     const desc6 : s70;   {detaljerad beskrivning}
                     const desc7 : s70;   {detaljerad beskrivning}
                     const desc8 : s70;   {detaljerad beskrivning}
                     const desc9 : s70;   {detaljerad beskrivning}
                     const desc10 : s70;  {detaljerad beskrivning}
                     strength : integer; {strength ”kning}
                     defence : integer; {defence ”kning}
                     strength_need : integer); {hur mycket strength beh”vs f”r att anv„nda objektet}

Implementation
Uses JakobE, File_IO;

Procedure Add_Object;
var
   ofil : file of objektrec;
   i : byte;
   fname : s90;
begin

 if add_fake then begin
  inc(counter);
  exit;
 end;

 case ttype of
  Head    : fname:=objf1;
  Body    : fname:=objf2;
  Arms    : fname:=objf3;
  Hands   : fname:=objf4;
  Fingers : fname:=objf5;
  Legs    : fname:=objf6;
  Feet    : fname:=objf7;
  Waist   : fname:=objf8;
  Neck    : fname:=objf9;
  Face    : fname:=objf10;
  Shield  : fname:=objf11;
  Food    : fname:=objf12;
  Drink   : fname:=objf13;
  Weapon  : fname:=objf14;
  Abody   : fname:=objf15;
 end;

 {assign filename}
 assign(ofil,fname);

 Objekt.name    :=name;
 objekt.ttype   :=ttype;
 objekt.value   :=value;
 objekt.hps     :=hps;
 objekt.stamina :=stamina;
 objekt.agility :=agility;
 objekt.charisma:=charisma;
 objekt.dex     :=dexterity;
 objekt.wisdom  :=wisdom;
 objekt.mana    :=mana;
 objekt.armor   :=armor;
 objekt.attack  :=attack;
 objekt.owned   :=owned;
 objekt.onlyone :=onlyone;
 objekt.cure    :=cure;
 objekt.shop    :=shop;
 objekt.dng     :=dng;
 objekt.cursed  :=cursed;
 objekt.minlev  :=minlev;
 objekt.maxlev  :=maxlev;

 objekt.desc1[1]:=desc1;
 objekt.desc1[2]:=desc2;
 objekt.desc1[3]:=desc3;
 objekt.desc1[4]:=desc4;
 objekt.desc1[5]:=desc5;

 objekt.desc2[1]:=desc6;
 objekt.desc2[2]:=desc7;
 objekt.desc2[3]:=desc8;
 objekt.desc2[4]:=desc9;
 objekt.desc2[5]:=desc10;

 if objekt.owned='' then objekt.owned:=emptystr;
 for i:=1 to 5 do begin
  if objekt.desc1[i]='' then objekt.desc1[i]:=emptystr;
  if objekt.desc2[i]='' then objekt.desc2[i]:=emptystr;
 end;

 objekt.strength :=strength;
 objekt.defence  :=defence;
 objekt.str_need :=strength_need;

 objekt.good:=false;
 objekt.evil:=false;

 if random(50)=0 then begin
  case random(2) of
   0: objekt.good:=true;
   1: objekt.evil:=true;
  end;
 end;

 {class restrictions}
 for i:=1 to maxclasses do begin
  objekt.restrict[i]:=false;
 end;

 {$I-}reset(ofil);{$I+}
 if IOResult<>0 then unable_to_access(fname);

 {$I-}seek(ofil,filesize(ofil));{$I+}
 if IOResult<>0 then unable_to_seek(fname,0);

 {$I-}write(ofil,objekt);{$I+}
 if IOResult<>0 then unable_to_write(fname);

 {$I-}close(ofil);{$I+}
 if IOResult<>0 then unable_to_close(fname);

 inc(counter);   {statbaren m†ste ha exakt antal poster..}
 Statbar(counter,totobj,global_masterx,global_mastery,1,1);

end;
end.
