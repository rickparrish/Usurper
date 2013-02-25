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



Unit Addit; {Usurper Editor - Misc routines}

Interface

Uses Init, Objects;

Function Drink_Ingredient(nr:byte):s15; {name of drink ingredients}
Function Class_Restricted(class:classes;var o : objektrec):boolean;
Function Gimme_Astring(titel,text:string;hint:word) : string;
Function Gimme_Avalue(titel,text:string;n1,n2:longint;hint:word) : longint;
Procedure Objekt_Affect ( use ,obj : integer;otyp : objtype;var player0 : Userrec );
Function Spell_Name( spell : integer; class : classes) : string;
Function Monster_Spell(nr : integer) : string;
Function Spell_Hint(spell_nr : integer):word;
Function Spell_HintPly(spell_nr : integer;class:classes):word;
Function Race_Hint(r : races):word;
Function Class_Hint(c : classes):word;
Function Combat_Hint(move : byte):word;

Procedure Transfer2(var man : EditRec2; var Ply : UserRec; direction : boolean);
Procedure Transfer(var man : EditRec; var Ply : UserRec; direction : boolean);
Procedure Transfer_Guard(var gue : EditRecG; var Vakt: GuardRec; direction : boolean);
Procedure Transfer_Moat(var mue : EditRecMoat; var Moaty: MoatRec; direction : boolean);

Procedure Transfer_Phrases(var box : EditRecPhrase; var Ply: UserRec; direction : boolean);
Procedure Transfer_Drink(var due : EditRecDrink; var Drinky: DrinkRec; direction : boolean);
Procedure Transfer_Child(var cue : EditRecChild; var Childy: ChildRec; direction : boolean);
Procedure Transfer_God(var gue : EditRecGod; var Goddy: GodRec; direction : boolean);
Procedure Transfer_Monster(var mony : EditRecM; var Gulp: MonsterRec; direction : boolean);
Procedure Transfer_Item(var dia : EditRecI; var obj: ObjektRec; direction : boolean);
Procedure Count_Objects;
Procedure Count_Monsters;
Procedure Count_Npcs;
Procedure Count_OldArmors;
Procedure Count_OldWeapons;
Function  Ur_Change : boolean;
Function Item_Disp(otyp : objtype) : string;
Procedure Adjust_Item(action:itemhandler;var ply:userrec;otyp:objtype;index:word;left:boolean);
Procedure Equip_Player(var ply : userrec);
Procedure Check_Item(pryl: objektrec;rand:word);
Procedure Item_File_Operations(typ:objtype);
Procedure Item_Class_Restrictions(var item : objektrec);
Procedure Import_Items(s:string);
Procedure Export_Items(s:string;n1,n2:longint;typ:objtype);

Function Monster_Search(creep : monsterrec) : longint;
Function DoorGuard_Search(creep : guardrec) : longint;
Function Moat_Search(creep : moatrec) : longint;
Function Drink_Search(creep : drinkrec) : longint;
Function God_Search(creep : godrec) : longint;
Function Child_Search(creep : childrec) : longint;
Function Look_For_User(user : userrec) : integer;
Function Leta_Efter_Item(creep : objektrec) : longint;
Function Look_For_Item(templist : pstringcollection) : longint;

Procedure Player_Editor;
Procedure Player_Page2; {Player/Npc Editor page 2}
Procedure Phrase_Page; {Player/Npc Editor, phrases dialog box}

Procedure DoorGuard_Editor;
Procedure Drink_Editor; {user created drinks, at Orbs}
Procedure Drink_Ingredients_Editor(var a_drink:drinkrec); {called from drink_editor}
Procedure Moat_Editor; {moat creatures}

Procedure Item_Editor;
Procedure Monster_Editor;
Procedure Edit_Level(nr : integer);
Procedure Level_Editor;
Procedure God_Editor;
Procedure Child_Editor;

Implementation

Uses Extra, ClasDis2, CMS,
     edface,
     eddrink,
     edrings,
     edshield,
     edbody,
     edhead,
     edneck,
     edarms,
     edhands,
     edwaist,
     edfeets,
     edabody,
     edlegs,
     edfood,

     edarmor, file_io,
     eweapon, edweap01,
     edmonst, npc,

     jakobe,
     App, msgbox, dialogs,
     Drivers,Views, Xboxes;


Function Class_Restricted;
var i : byte;
begin

 case class of
  Alchemist : i:=1;
  Assassin  : i:=2;
  Barbarian : i:=3;
  Bard      : i:=4;
  Cleric    : i:=5;
  Jester    : i:=6;
  Magician  : i:=7;
  Paladin   : i:=8;
  Ranger    : i:=9;
  Sage      : i:=10;
  Warrior   : i:=11;
 end;

 if o.restrict[i] then class_restricted:=true
                  else class_restricted:=false;

end;

Function Gimme_Avalue;

var
  Dia : GimmeValDialogP;
  R : TRect;
  go : longint;
  res : longint;

begin

 R.Assign(0, 0, 37, 9);
 Dia := New(GimmeValDialogP, Init(R, titel));

 dia^.Options := dia^.Options or ofCentered;

 {NAME}
 dia^.ValEntry(1,2,text,15,n1,n2,hint);

 dia^.Static(1,3,' Range : '+commastr(n1)+' to '+commastr(n2));

 dia^.OkButton    (02,6);
 dia^.CancelButton(14,6);

 dia^.FocusNext(false);

 gimvdata.nam:=n1;
 dia^.setdata(gimvdata);

 go:=Desktop^.ExecView(Dia);
 Dispose(Dia, Done);


 res:=0;
 if go=CmOk then begin
  if (gimvdata.nam>=n1) and (gimvdata.nam<=n2) then begin
   res:=gimvdata.nam;
  end;
 end
 else begin
  res:=-1;
 end;

 Gimme_Avalue:=res;

end;

Function Gimme_Astring;
const max = 100;
type DataRec = record
      nam : string[max];
     end;

var
  Dia : XDialogP;
  R   : TRect;
  Data : DataRec;

  go : longint;
  ss : string;

begin

 R.Assign(0, 0, 43, 8);
 Dia := New(XDialogP, Init(R, titel));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,text,max,30,hint);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=Desktop^.ExecView(Dia);
 dia^.getdata(data);
 Dispose(Dia, Done);

 ss:='';
 if go=CmOk then begin
  if data.nam<>'' then begin
   ss:=data.nam;
  end;
 end;

 gimme_astring:=ss;

end;

Procedure Transfer_Guard;
var i : byte;
begin
 if Direction=true then begin
  {DIALOG -> DOORGUARD}
  vakt.name:=gue.name;
  vakt.cost:=gue.cost;
  vakt.hps:=gue.hps;
  if gue.multi=0 then vakt.multiple:=true
                 else vakt.multiple:=false;

  vakt.barmor:=gue.barmor;
  vakt.battack:=gue.battack;
  for i:=1 to 5 do begin
   vakt.descp[i]:=gue.descp[i];
  end;

 end
 else begin
  {DOORGUARD -> DIALOG}
  gue.name:=vakt.name;
  gue.cost:=vakt.cost;
  gue.hps:=vakt.hps;
  if vakt.multiple then gue.multi:=0
                   else gue.multi:=1;
  gue.barmor:=vakt.barmor;
  gue.battack:=vakt.battack;
  for i:=1 to 5 do begin
   gue.descp[i]:=vakt.descp[i];
  end;

 end;

end;

Procedure Transfer_Moat;
var i : byte;
begin

 if Direction=true then begin
  {DIALOG -> RECORD}
  moaty.name:=mue.name;
  moaty.cost:=mue.cost;
  moaty.hps:=mue.hps;
  if mue.multi=0 then moaty.deleted:=true
                 else moaty.deleted:=false;

  moaty.barmor:=mue.barmor;
  moaty.battack:=mue.battack;
  for i:=1 to 5 do begin
   moaty.descp[i]:=mue.descp[i];
  end;

 end
 else begin
  {RECORD -> DIALOG}
  mue.name:=moaty.name;
  mue.cost:=moaty.cost;
  mue.hps:=moaty.hps;
  if moaty.deleted then mue.multi:=0
                   else mue.multi:=1;
  mue.barmor:=moaty.barmor;
  mue.battack:=moaty.battack;
  for i:=1 to 5 do begin
   mue.descp[i]:=moaty.descp[i];
  end;

 end;

end;

Procedure Transfer_Phrases;
var i : byte;
begin

 if Direction=true then begin
  {DIALOG -> PLY}
  ply.battlecry:=box.battle_cry;
  for i:=1 to 6 do begin
   ply.phr[i]:=box.phrase[i];
  end;
 end
 else begin
  {PLY -> DIALOG}
  box.battle_cry:=ply.battlecry;
  for i:=1 to 6 do begin
   box.phrase[i]:=ply.phr[i];
  end;
 end;

end; {transfer_phrases .end.}

Procedure Transfer_Drink;
var i : byte;
begin

 if Direction=true then begin
  {DIALOG -> DRINK}
  drinky.name   :=due.name;
  drinky.creator:=due.creator;
  drinky.comment:=due.comment;
  drinky.ordered:=due.ordered;
  drinky.lasthad:=due.lasthad;

  if due.secret=0 then drinky.secret:=true
                  else drinky.secret:=false;

  if due.deleted=0 then drinky.deleted:=true
                   else drinky.deleted:=false;


 end
 else begin

  {DRINK -> DIALOG}
  due.name   :=drinky.name;
  due.creator:=drinky.creator;
  due.date   :=datefix(drinky.date);
  due.comment:=drinky.comment;
  due.ordered:=drinky.ordered;
  due.lasthad:=drinky.lasthad;
  due.lastdat:=datefix(drinky.lastdat);

  if drinky.secret then due.secret:=0
                   else due.secret:=1;

  if drinky.deleted then due.deleted:=0
                    else due.deleted:=1;

 end;

end; {transfer_drink .end.}

Procedure Transfer_God;
var i : byte;
begin

 if Direction=true then begin
  {DIALOG -> GOD}
  goddy.name   :=gue.name;
  goddy.realname  :=gue.realname;

  if gue.deleted=0 then goddy.deleted:=true
                   else goddy.deleted:=false;


 end
 else begin
  {GOD -> DIALOG}
  gue.name   :=goddy.name;
  gue.realname  :=goddy.realname;

  if goddy.deleted then gue.deleted:=0
                   else gue.deleted:=1;

 end;

end; {transfer_god .end.}

Procedure Transfer_Child;
var i : byte;
begin

 if Direction=true then begin
  {DIALOG -> CHILD}
  childy.name   :=cue.name;
  childy.mother :=cue.mother;
  childy.father :=cue.father;

  if cue.deleted=0 then childy.deleted:=true
                   else childy.deleted:=false;


 end
 else begin
  {CHILD -> DIALOG}
  cue.name   :=childy.name;
  cue.mother :=childy.mother;
  cue.father :=childy.father;

  if childy.deleted then cue.deleted:=0
                    else cue.deleted:=1;

 end;

end; {transfer_child .end.}

Procedure Transfer_Monster;
var i : byte;
begin
 if Direction=true then begin
  {DIALOG -> MONSTER}

  for i:=1 to maxmspells do begin
   if mony.spell[i]=1 then gulp.spell[i]:=true
                      else gulp.spell[i]:=false;
  end;

  gulp.name:=mony.name;
  if mony.grabweap=0 then gulp.grabweap:=true
                     else gulp.grabweap:=false;
  if mony.grabarm=0 then gulp.grabarm:=true
                    else gulp.grabarm:=false;

  gulp.phrase     :=mony.phrase;
  gulp.magiclevel :=mony.magiclevel;
  gulp.magicres   :=mony.magicres;
  gulp.strength   :=mony.strength;
  gulp.defence    :=mony.defence;
  gulp.hps        :=mony.hps;
  gulp.iq         :=mony.iq;
  gulp.evil       :=mony.evil;

 end
 else begin
  {MONSTER -> DIALOG}
  for i:=1 to maxmspells do begin
   if gulp.spell[i] then mony.spell[i]:=1
                    else mony.spell[i]:=0;
  end;

  mony.name:=gulp.name;
  if gulp.grabweap then mony.grabweap:=0
                   else mony.grabweap:=1;
  if gulp.grabarm then mony.grabarm:=0
                  else mony.grabarm:=1;

  mony.phrase  :=gulp.phrase;
  mony.magiclevel:=gulp.magiclevel;
  mony.magicres:=gulp.magicres;
  mony.strength:=gulp.strength;
  mony.defence :=gulp.defence;
  mony.hps     :=gulp.hps;
  mony.iq      :=gulp.iq;
  mony.evil    :=gulp.evil;


 end;

end;

Procedure Transfer_Item;
var i : byte;
begin
 if Direction=true then begin
  {DIALOG -> ITEM}
  obj.name     :=dia.name;
  obj.value    :=dia.value;
  obj.attack   :=dia.attack;
  obj.armor    :=dia.armor;
  obj.hps      :=dia.hps;
  obj.stamina  :=dia.stamina;
  obj.agility  :=dia.agility;
  obj.charisma :=dia.charisma;
  obj.dex      :=dia.dex;
  obj.wisdom   :=dia.wisdom;
  obj.mana     :=dia.mana;
  obj.strength :=dia.strength;
  obj.defence  :=dia.defence;
  obj.str_need :=dia.str_need;

  obj.maxlev:=dia.maxlev;
  obj.minlev:=dia.minlev;

  for i:=1 to 5 do begin
   obj.desc1[i]:=dia.desc1[i];
  end;
  for i:=1 to 5 do begin
   obj.desc2[i]:=dia.desc2[i];
  end;

  case dia.cure of
   0: obj.cure:=Nothing;
   1: obj.cure:=All;
   2: obj.cure:=Blindness;
   3: obj.cure:=Plague;
   4: obj.cure:=SmallPox;
   5: obj.cure:=Measles;
   6: obj.cure:=Leprosy;
  end;

  if dia.shop=0 then obj.shop:=true
                else obj.shop:=false;

  if dia.dng=0 then obj.dng:=true
               else obj.dng:=false;

  if dia.cursed=0 then obj.cursed:=true
                  else obj.cursed:=false;

  if dia.good=0 then obj.good:=true
                else obj.good:=false;

  if dia.evil=0 then obj.evil:=true
                else obj.evil:=false;

 end
 else begin
  {ITEM -> DIALOG}
  dia.name    :=obj.name;
  dia.value   :=obj.value;
  dia.attack  :=obj.attack;
  dia.armor   :=obj.armor;
  dia.hps     :=obj.hps;
  dia.stamina :=obj.stamina;
  dia.agility :=obj.agility;
  dia.charisma:=obj.charisma;
  dia.dex     :=obj.dex;
  dia.wisdom  :=obj.wisdom;
  dia.mana    :=obj.mana;
  dia.strength:=obj.strength;
  dia.defence :=obj.defence;
  dia.str_need:=obj.str_need;
  dia.maxlev  :=obj.maxlev;
  dia.minlev  :=obj.minlev;

  for i:=1 to 5 do begin
   dia.desc1[i]:=obj.desc1[i];
  end;

  for i:=1 to 5 do begin
   dia.desc2[i]:=obj.desc2[i];
  end;


  case obj.cure of
   Nothing   : dia.cure:=0;
   All       : dia.cure:=1;
   Blindness : dia.cure:=2;
   Plague    : dia.cure:=3;
   SmallPox  : dia.cure:=4;
   Measles   : dia.cure:=5;
   Leprosy   : dia.cure:=6;
  end;

  if obj.shop then dia.shop:=0
              else dia.shop:=1;

  if obj.dng then dia.dng:=0
             else dia.dng:=1;

  if obj.cursed then dia.cursed:=0
                else dia.cursed:=1;

  if obj.good then dia.good:=0
              else dia.good:=1;

  if obj.evil then dia.evil:=0
              else dia.evil:=1;

 end;

end;

Procedure Transfer; {transfer dialogue box values to player record}
begin

 if Direction=true then begin
  {EDITREC -> PLAYER}

  ply.name1:=man.name;
  ply.name2:=man.alias;
  if man.human=0 then ply.ai:='H'
                 else ply.ai:='C';
  if man.king=0 then ply.king:=true
                else ply.king:=false;

  if man.allowed=0 then ply.allowed:=true
                   else ply.allowed:=false;

  if man.sex=0 then ply.sex:=2
               else ply.sex:=1;

  case man.race of
   0: ply.race:=Human;
   1: ply.race:=Hobbit;
   2: ply.race:=Elf;
   3: ply.race:=HalfElf;
   4: ply.race:=Dwarf;
   5: ply.race:=Troll;
   6: ply.race:=Orc;
   7: ply.race:=Gnome;
   8: ply.race:=Gnoll;
   9: ply.race:=Mutant;
  end;

  case man.class of
   0:  ply.class:=Alchemist;
   1:  ply.class:=Assassin;
   2:  ply.class:=Barbarian;
   3:  ply.class:=Bard;
   4:  ply.class:=Cleric;
   5:  ply.class:=Jester;
   6:  ply.class:=Magician;
   7:  ply.class:=Paladin;
   8:  ply.class:=Ranger;
   9:  ply.class:=Sage;
   10: ply.class:=Warrior;
  end;

  {age}
  ply.age:=man.age;

  {pengar}
  ply.gold:=man.gold;
  ply.bankgold:=man.bankgold;

  {hps}
  ply.hps:=man.hps;

  {maxhps}
  ply.maxhps:=man.maxhps;

  {level}
  ply.level:=man.level;

  {exp}
  ply.exp:=man.exp;

  {chiv}
  ply.chiv:=man.chiv;

  {dark}
  ply.dark:=man.dark;

  {strength}
  ply.strength:=man.strength;

  {defence}
  ply.defence:=man.defence;

  {fights}
  ply.fights:=man.fights;

  {healings}
  ply.healing:=man.healing;

  {player fights}
  ply.pfights:=man.pfights;

  {team fights}
  ply.tfights:=man.tfights;

  {team}
  ply.team:=man.team;

  {team password}
  ply.teampw:=man.teampw;

  {mental health}
  ply.mental:=man.mental;

  {drug addiction}
  ply.addict:=man.addict;

  {# acts of chivalry}
  ply.chivnr:=man.chivnr;

  {# acts of darkness}
  ply.darknr:=man.darknr;

  {mana}
  ply.mana:=man.mana;

  {maxmana}
  ply.maxmana:=man.maxmana;

  {stamina}
  ply.stamina:=man.stamina;

  {agility}
  ply.agility:=man.agility;

  {charisma}
  ply.charisma:=man.charisma;

  {dexterity}
  ply.dex:=man.dex;

  {wisdom}
  ply.wisdom:=man.wisdom;

  {theiverys}
  ply.thiefs:=man.thiefs;

  {brawls}
  ply.brawls:=man.brawls;

  {training sessions}
  ply.trains:=man.trains;

  {battlecry}
  {ply.battlecry:=man.battlecry; moved this entry to 'phrases' dialog box}

 end

 else begin {PLAYER -> EDITREC}

  if ply.deleted then begin
   man.name :=delname1;
   man.alias:=delname2;
  end
  else begin
   man.name :=ply.name1;
   man.alias:=ply.name2;
  end;

  if ply.ai='H' then man.human:=0
                else man.human:=1;

  if ply.king then man.king:=0
              else man.king:=1;

  if ply.allowed then man.allowed:=0
                 else man.allowed:=1;


  if ply.sex=1 then man.sex:=1
               else man.sex:=0;
  {man.sex:=ply.sex;}

  case ply.race of
   Human  : man.race:=0;
   Hobbit : man.race:=1;
   Elf    : man.race:=2;
   HalfElf: man.race:=3;
   Dwarf  : man.race:=4;
   Troll  : man.race:=5;
   Orc    : man.race:=6;
   Gnome  : man.race:=7;
   Gnoll  : man.race:=8;
   Mutant : man.race:=9;
  end;

  case ply.class of
   Alchemist : man.class:=0;
   Assassin  : man.class:=1;
   Barbarian : man.class:=2;
   Bard      : man.class:=3;
   Cleric    : man.class:=4;
   Jester    : man.class:=5;
   Magician  : man.class:=6;
   Paladin   : man.class:=7;
   Ranger    : man.class:=8;
   Sage      : man.class:=9;
   Warrior   : man.class:=10;
  end;

  {age}
  man.age:=ply.age;

  {pengar}
  man.gold:=ply.gold;
  man.bankgold:=ply.bankgold;

  {hps}
  man.hps:=ply.hps;

  {maxhps}
  man.maxhps:=ply.maxhps;

  {level}
  man.level:=ply.level;

  {exp}
  man.exp:=ply.exp;

  {chiv}
  man.chiv:=ply.chiv;

  {dark}
  man.dark:=ply.dark;

  {strength}
  man.strength:=ply.strength;

  {defence}
  man.defence:=ply.defence;

  {fights}
  man.fights:=ply.fights;

  {healings}
  man.healing:=ply.healing;

  {player fights}
  man.pfights:=ply.pfights;

  {team fights}
  man.tfights:=ply.tfights;

  {team}
  man.team:=ply.team;

  {team password}
  man.teampw:=ply.teampw;

  {mental health}
  man.mental:=ply.mental;

  {drug addiction}
  man.addict:=ply.addict;

  {# acts of chivalry}
  man.chivnr:=ply.chivnr;

  {# acts of darkness}
  man.darknr:=ply.darknr;

  {mana}
  man.mana:=ply.mana;

  {maxmana}
  man.maxmana:=ply.maxmana;

  {stamina}
  man.stamina:=ply.stamina;

  {agility}
  man.agility:=ply.agility;

  {charisma}
  man.charisma:=ply.charisma;

  {dexterity}
  man.dex:=ply.dex;

  {wisdom}
  man.wisdom:=ply.wisdom;

  {theiverys}
  man.thiefs:=ply.thiefs;

  {brawls}
  man.brawls:=ply.brawls;

  {training sessions}
  man.trains:=ply.trains;

  {battlecry}
  {man.battlecry:=ply.battlecry; moved this entry to 'phrases' dialog box}

 end;

end; {Transfer .end.}

Procedure Transfer2; {transfer values from player dialogue2 to/from player
                      record}
var i : byte;

begin

 if Direction=true then begin
  {EDITREC - PLAYER}

  for i:=1 to maxspells do begin
   if man.spell[i]=1 then ply.spell[i,1]:=true
                     else ply.spell[i,1]:=false;
  end;


 { for i:=1 to maxspells do begin
   ply.spell[i,1]:=man.spell[i];
  end;
 }

 { if man.immortal then ply.immortal:=false
                  else ply.immortal:=true;
 }
  if man.immortal=1 then ply.immortal:=true
                    else ply.immortal:=false;

  if man.blind=1    then ply.blind:=true
                    else ply.blind:=false;
  if man.plague=1   then ply.plague:=true
                    else ply.plague:=false;
  if man.smallpox=1 then ply.smallpox:=true
                    else ply.smallpox:=false;
  if man.measles=1  then ply.measles:=true
                    else ply.measles:=false;
  if man.leprosy=1  then ply.leprosy:=true
                    else ply.leprosy:=false;

  {maxtime}
  ply.maxtime:=man.maxtime;

  {close combat skills}
  for i:=1 to 14 do begin
   ply.skill[i]:=man.skill[i];
  end;

  {player kills, stats}
  ply.m_kills   :=man.m_kills;
  ply.m_defeats :=man.m_defeats;
  ply.p_kills   :=man.p_kills;
  ply.p_defeats :=man.p_defeats;


  {player description}
  for i:=1 to 4 do begin
   ply.desc[i]:=man.desc[i];
  end;

 end
 else begin

  {*** PLAYER - EDITREC ***}

  for i:=1 to maxspells do begin
   if ply.spell[i,1] then man.spell[i]:=1
                      else man.spell[i]:=0;
  end;

{  for i:=1 to maxspells do begin
   man.spell[i]:=ply.spell[i,1];
  end;
}
{  if ply.immortal then man.immortal:=false
                  else man.immortal:=true;
}
  if ply.immortal then man.immortal:=1
                  else man.immortal:=0;



  if ply.blind then man.blind:=1
               else man.blind:=0;
  if ply.plague then man.plague:=1
                else man.plague:=0;
  if ply.smallpox then man.smallpox:=1
                  else man.smallpox:=0;
  if ply.measles then man.measles:=1
                 else man.measles:=0;
  if ply.leprosy then man.leprosy:=1
                 else man.leprosy:=0;

  {maxtime}
  man.maxtime:=ply.maxtime;

  {close combat skills}
  for i:=1 to 14 do begin
   man.skill[i]:=ply.skill[i];
  end;

  {player kills, stats}
  man.m_kills   :=ply.m_kills;
  man.m_defeats :=ply.m_defeats;
  man.p_kills   :=ply.p_kills;
  man.p_defeats :=ply.p_defeats;

  {player description}
  for i:=1 to 4 do begin
   man.desc[i]:=ply.desc[i];
  end;

 end;

end; {transfer2 .end.}

Procedure Count_Objects; {r„knar ut totala antalet objekt,
                         f”r att anv„ndas i statbaren}
begin

 add_fake:=true;
 totobj:=0;
 counter:=0;

 reset_monster_weapons;
 reset_body;
 reset_rings;
 reset_neck;
 reset_shields;
 reset_head;
 reset_face;
 reset_drink;
 reset_arms;
 reset_hands;
 reset_waist;
 reset_feets;
 reset_abody;
 reset_legs;
 reset_food;

 totobj:=counter;
 counter:=0;
 add_fake:=false;

end; {count_objects *end*}

Procedure Count_Monsters;  {r„knar ut totala antalet monsters,
                           f”r att anv„ndas i statbaren}
begin

 add_fake:=true;
 totobj:=0;
 counter:=0;

 reset_monsters;

 totobj:=counter;
 counter:=0;
 add_fake:=false;

end; {count_monsters *end*}

Procedure Count_NPCS;  {r„knar ut totala antalet NPCS}
begin

 add_fake:=true;
 totobj:=0;
 counter:=0;

 reset_npcs;

 totobj:=counter;
 counter:=0;
 add_fake:=false;

end;

Procedure Count_OldArmors;  {r„knar ut totala antalet classic armors}
begin

 add_fake:=true;
 totobj:=0;
 counter:=0;

 reset_armor;

 totobj:=counter;
 counter:=0;
 add_fake:=false;

end; {Count_OldArmors *end*}

Procedure Count_OldWeapons;  {r„knar ut totala antalet classic weapons
                             f”r att anv„ndas i statbaren}
begin

 add_fake:=true;
 totobj:=0;
 counter:=0;

 reset_weapon;

 totobj:=counter;
 counter:=0;
 add_fake:=false;

end; {count_oldweapons *end*}

Function Ur_Change;
var b : boolean;
    i : integer;
begin
 b:=false;
 for i:=1 to global_maxcdef do begin
  if cfgurb[i]<>cfgvalue[i] then begin
   b:=true;
   break;
  end;
 end;

 {return result}
 ur_change:=b;

end; {ur_change *end*}

Function Item_Disp;
var s : string[20];
begin

 case otyp of
  Head    : s:='Head';
  Body    : s:='Body';
  Arms    : s:='Arm';
  Hands   : s:='Hand';
  Fingers : s:='Finger';
  Legs    : s:='Leg';
  Feet    : s:='Feet';
  Waist   : s:='Waist';
  Neck    : s:='Neck';
  Face    : s:='Face';
  Shield  : s:='Shield';
  Food    : s:='Food';
  Drink   : s:='Drink';
  Weapon  : s:='Weapons';
  Abody   : s:='Around Body';
 end;

 if (otyp<>Weapon) and (otyp<>Shield) then begin
  s:=s+' Items';
 end;

 {return result}
 item_disp:=s;

end; {item_disp *end*}

Procedure Objekt_Affect;
var
    oobjekt : objektrec;

begin

 load_objekt(Fload,oobjekt,otyp,obj);

 { => ** GL™M INTE ATT ŽNDRA I MOTSVARANDE OBJ AFFECT NU! ** <= }

 case use of
  1:begin
     { Objektet har B™RJAT ANVŽNDAS av player0 }
     if oobjekt.ttype in [food,drink] then begin
      player0.hps:=player0.hps+oobjekt.hps;
      if player0.hps>player0.maxhps then begin
       player0.hps:=player0.maxhps;
      end;
     end
     else begin
      player0.maxhps:=player0.maxhps+oobjekt.hps;
     end;

     player0.stamina :=player0.stamina+oobjekt.stamina;
     player0.agility :=player0.agility+oobjekt.agility;
     player0.charisma:=player0.charisma+oobjekt.charisma;
     player0.dex     :=player0.dex+oobjekt.dex;
     player0.wisdom  :=player0.wisdom+oobjekt.wisdom;
     player0.maxmana :=player0.maxmana+oobjekt.mana;
     player0.arm     :=player0.arm+oobjekt.armor;
     player0.weap    :=player0.weap+oobjekt.attack;
     player0.strength:=player0.strength+oobjekt.strength;
     player0.defence :=player0.defence+oobjekt.defence;

     case oobjekt.cure of
      All      : begin
                  player0.blind   :=false;
                  player0.plague  :=false;
                  player0.smallpox:=false;
                  player0.measles :=false;
                  player0.leprosy :=false;
                 end;
      Blindness:begin
                 player0.blind:=false;
                end;
         Plague:begin
                 player0.plague:=false;
                end;
       Smallpox:begin
                 player0.smallpox:=false;
                end;
        Measles:begin
                 player0.measles:=false;
                end;
        Leprosy:begin
                 player0.leprosy:=false;
                end;
     end;
    end;
  2:begin
     { Objektet har SLUTAT ANVŽNDAS av player0 }
     player0.maxhps  :=player0.maxhps-oobjekt.hps;
     player0.stamina :=player0.stamina-oobjekt.stamina;
     player0.agility :=player0.agility-oobjekt.agility;
     player0.charisma:=player0.charisma-oobjekt.charisma;
     player0.dex     :=player0.dex-oobjekt.dex;
     player0.wisdom  :=player0.wisdom-oobjekt.wisdom;
     player0.maxmana :=player0.maxmana-oobjekt.mana;
     player0.arm     :=player0.arm-oobjekt.armor;
     player0.weap    :=player0.weap-oobjekt.attack;
     player0.strength:=player0.strength-oobjekt.strength;
     player0.defence :=player0.defence-oobjekt.defence;
    end;
 end;

end;

Procedure Adjust_Item;
begin

 {har ply n†got gammalt item som m†ste bort?}
 case otyp of
  Weapon:begin
          if left then begin
           if ply.lhand>0 then begin
            objekt_affect(2,ply.lhand,weapon,ply);
            ply.lhand:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.lhand:=index;
            objekt_affect(1,index,weapon,ply);
           end;
          end
          else begin
           if ply.rhand>0 then begin
            objekt_affect(2,ply.rhand,weapon,ply);
            ply.rhand:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.rhand:=index;
            objekt_affect(1,index,weapon,ply);
           end;
          end;
         end;
    Head:begin
          if ply.head>0 then begin
           objekt_affect(2,ply.head,head,ply);
           ply.head:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.head:=index;
           objekt_affect(1,index,head,ply);
          end;
         end;
    Body:begin
          if ply.body>0 then begin
           objekt_affect(2,ply.body,body,ply);
           ply.body:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.body:=index;
           objekt_affect(1,index,body,ply);
          end;
         end;
    Arms:begin
          if ply.arms>0 then begin
           objekt_affect(2,ply.arms,arms,ply);
           ply.arms:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.arms:=index;
           objekt_affect(1,index,arms,ply);
          end;
         end;
   Hands:begin
          if ply.hands>0 then begin
           objekt_affect(2,ply.hands,hands,ply);
           ply.hands:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.hands:=index;
           objekt_affect(1,index,hands,ply);
          end;
         end;
 Fingers:begin
          if left then begin
           if ply.lfinger>0 then begin
            objekt_affect(2,ply.lfinger,fingers,ply);
            ply.lfinger:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.lfinger:=index;
            objekt_affect(1,index,fingers,ply);
           end;
          end
          else begin
           if ply.rfinger>0 then begin
            objekt_affect(2,ply.rfinger,fingers,ply);
            ply.rfinger:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.rfinger:=index;
            objekt_affect(1,index,fingers,ply);
           end;
          end;
         end;
    Legs:begin
          if ply.legs>0 then begin
           objekt_affect(2,ply.legs,legs,ply);
           ply.legs:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.legs:=index;
           objekt_affect(1,index,legs,ply);
          end;
         end;
    Feet:begin
          if ply.feet>0 then begin
           objekt_affect(2,ply.feet,feet,ply);
           ply.feet:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.feet:=index;
           objekt_affect(1,index,feet,ply);
          end;
         end;
   Waist:begin
          if ply.waist>0 then begin
           objekt_affect(2,ply.waist,waist,ply);
           ply.waist:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.waist:=index;
           objekt_affect(1,index,waist,ply);
          end;
         end;
    Neck:begin
          if left then begin
           if ply.neck>0 then begin
            objekt_affect(2,ply.neck,neck,ply);
            ply.neck:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.neck:=index;
            objekt_affect(1,index,neck,ply);
           end;
          end
          else begin
           if ply.neck2>0 then begin
            objekt_affect(2,ply.neck2,neck,ply);
            ply.neck2:=0;
           end;
           if Action=Item_Add then begin
            {b”rjar anv„nda det nya itemet}
            ply.neck2:=index;
            objekt_affect(1,index,neck,ply);
           end;
          end;
         end;
    Face:begin
          if ply.face>0 then begin
           objekt_affect(2,ply.face,face,ply);
           ply.face:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.face:=index;
           objekt_affect(1,index,face,ply);
          end;
         end;
  Shield:begin
          if ply.shield>0 then begin
           objekt_affect(2,ply.shield,shield,ply);
           ply.shield:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.shield:=index;
           objekt_affect(1,index,shield,ply);
          end;
         end;
   Abody:begin
          if ply.abody>0 then begin
           objekt_affect(2,ply.abody,abody,ply);
           ply.abody:=0;
          end;
          if Action=Item_Add then begin
           {b”rjar anv„nda det nya itemet}
           ply.abody:=index;
           objekt_affect(1,index,abody,ply);
          end;
         end;

 end;

end;


Function Value_Objekt(var ply : userrec; var obj:objektrec) : boolean;
var go : boolean;
begin

 go:=true;
 if obj.cursed=true then go:=false;
 if obj.owned<>'' then go:=false;
 if (obj.good) and (ply.dark>0) then go:=false;
 if (obj.evil) and (ply.chiv>0) then go:=false;
 if obj.str_need>ply.strength then go:=false;

 if obj.ttype=Weapon then begin
  if obj.attack<1 then go:=false; {attack v„rde}
  if obj.attack<(ply.level) then go:=false;
 end;

 if obj.ttype<>Weapon then begin
  if obj.armor<0 then go:=false;  {armor v„rde}
 end;


 if (ply.class in [Magician,Cleric,Sage]) and (obj.mana<0) then go:=false;
 if obj.strength<-10 then go:=false;
 if obj.strength<-10 then go:=false;
 if obj.hps<-5       then go:=false;
 if obj.stamina<-20  then go:=false;
 if obj.charisma<-25 then go:=false;
 if obj.dex<-25      then go:=false;
 if obj.agility<-25  then go:=false;

 value_objekt:=go;

end;

Procedure Equip_Player;
var obj : objektrec;
      i : word;
begin

 if classic then begin
  {}
 end
 else begin {NEW game mode}

  {left hand weapon}
  if (ply.lhand=0) and (allowitem[15]=true) then begin

   for i:=1 to fso(WEAPON) do begin
    load_objekt(Fload,obj,weapon,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.lhand:=i;
     objekt_affect(1,ply.lhand,weapon,ply);
     break;
    end;
   end;

  end;

  {right hand weapon}
  if ply.rhand=0 then begin
   for i:=1 to fso(WEAPON) do begin
    load_objekt(Fload,obj,weapon,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.rhand:=i;
     objekt_affect(1,ply.rhand,weapon,ply);
     break;
    end;
   end;
  end;

  {head}
  if (ply.head=0) and (allowitem[2]=true) then begin
   for i:=1 to fso(HEAD) do begin
    load_objekt(Fload,obj,HEAD,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.head:=i;
     objekt_affect(1,ply.head,head,ply);
     break;
    end;
   end;
  end;

  {body}
  if (ply.body=0) and (allowitem[3]=true) then begin
   for i:=1 to fso(BODY) do begin
    load_objekt(Fload,obj,BODY,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.body:=i;
     objekt_affect(1,ply.body,body,ply);
     break;
    end;
   end;
  end;

  {arms}
  if (ply.arms=0) and (allowitem[4]=true) then begin
   for i:=1 to fso(ARMS) do begin
    load_objekt(Fload,obj,ARMS,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.arms:=i;
     objekt_affect(1,ply.arms,arms,ply);
     break;
    end;
   end;
  end;

  {lfinger}
  if (ply.lfinger=0) and (allowitem[5]=true) then begin
   for i:=1 to fso(FINGERS) do begin
    load_objekt(Fload,obj,FINGERS,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.lfinger:=i;
     objekt_affect(1,ply.lfinger,fingers,ply);
     break;
    end;
   end;
  end;

  {rfinger}
  if (ply.rfinger=0)  and (allowitem[6]=true) then begin
   for i:=1 to fso(FINGERS) do begin
    load_objekt(Fload,obj,FINGERS,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.rfinger:=i;
     objekt_affect(1,ply.rfinger,fingers,ply);
     break;
    end;
   end;
  end;

  {legs}
  if (ply.legs=0) and (allowitem[7]=true) then begin
   for i:=1 to fso(LEGS) do begin
    load_objekt(Fload,obj,LEGS,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.legs:=i;
     objekt_affect(1,ply.legs,legs,ply);
     break;
    end;
   end;
  end;

  {feet}
  if (ply.feet=0) and (allowitem[8]=true) then begin
   for i:=1 to fso(FEET) do begin
    load_objekt(Fload,obj,FEET,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.feet:=i;
     objekt_affect(1,ply.feet,feet,ply);
     break;
    end;
   end;
  end;

  {waist}
  if (ply.waist=0) and (allowitem[9]=true) then begin
   for i:=1 to fso(WAIST) do begin
    load_objekt(Fload,obj,WAIST,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.waist:=i;
     objekt_affect(1,ply.waist,waist,ply);
     break;
    end;
   end;
  end;

  {neck}
  if (ply.neck=0) and (allowitem[10]=true) then begin
   for i:=1 to fso(NECK) do begin
    load_objekt(Fload,obj,NECK,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.neck:=i;
     objekt_affect(1,ply.neck,neck,ply);
     break;
    end;
   end;
  end;

  {neck2}
  if (ply.neck2=0) and (allowitem[11]=true) then begin
   for i:=1 to fso(NECK) do begin
    load_objekt(Fload,obj,NECK,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.neck2:=i;
     objekt_affect(1,ply.neck2,neck,ply);
     break;
    end;
   end;
  end;

  {face}
  if (ply.face=0) and (allowitem[12]=true) then begin
   for i:=1 to fso(FACE) do begin
    load_objekt(Fload,obj,FACE,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.face:=i;
     objekt_affect(1,ply.face,face,ply);
     break;
    end;
   end;
  end;

  {shield}
  if (ply.shield=0) and (allowitem[13]=true) then begin
   for i:=1 to fso(SHIELD) do begin
    load_objekt(Fload,obj,SHIELD,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.shield:=i;
     objekt_affect(1,ply.shield,shield,ply);
     break;
    end;
   end;
  end;

  {hands}
  if (ply.hands=0)  and (allowitem[1]=true) then begin
   for i:=1 to fso(HANDS) do begin
    load_objekt(Fload,obj,HANDS,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.hands:=i;
     objekt_affect(1,ply.hands,hands,ply);
     break;
    end;
   end;
  end;

  {abody}
  if (ply.abody=0) and (allowitem[14]=true) then begin
   for i:=1 to fso(ABODY) do begin
    load_objekt(Fload,obj,ABODY,i);
    if (value_objekt(ply,obj)=true) and (random(2)=0) and
       (class_restricted(ply.class,obj)=false) then begin
     ply.abody:=i;
     objekt_affect(1,ply.abody,abody,ply);
     break;
    end;
   end;
  end;


 end;

end;

Function Combat_Hint(move : byte):word;
var x : word;
begin

 case move of
  1:  x:= hcPeditMove1;
  2:  x:= hcPeditMove2;
  3:  x:= hcPeditMove3;
  4:  x:= hcPeditMove4;
  5:  x:= hcPeditMove5;
  6:  x:= hcPeditMove6;
  7:  x:= hcPeditMove7;
  8:  x:= hcPeditMove8;
  9:  x:= hcPeditMove9;
  10: x:= hcPeditMove10;
  11: x:= hcPeditMove11;
  12: x:= hcPeditMove12;
  13: x:= hcPeditMove13;
  14: x:= hcPeditMove14;
  else x:=HcNada;
 end;

 combat_hint:=x;
end;

Function Class_Hint(c : classes):word;
var x : word;
begin
 case c of
  Alchemist : x:=HcPeditClass1;
  Assassin  : x:=HcPeditClass2;
  Barbarian : x:=HcPeditClass3;
  Bard      : x:=HcPeditClass4;
  Cleric    : x:=HcPeditClass5;
  Jester    : x:=HcPeditClass6;
  Magician  : x:=HcPeditClass7;
  Paladin   : x:=HcPeditClass8;
  Ranger    : x:=HcPeditClass9;
  Sage      : x:=HcPeditClass10;
  Warrior   : x:=HcPeditClass11;
  else x:=HcNada;
 end;

 class_hint:=x;

end;

Function Race_Hint(r : races):word;
var x : word;
begin
 case r of
  Human   : x:=HcPeditRace1;
  Hobbit  : x:=HcPeditRace2;
  Elf     : x:=HcPeditRace3;
  HalfElf : x:=HcPeditRace4;
  Dwarf   : x:=HcPeditRace5;
  Troll   : x:=HcPeditRace6;
  Orc     : x:=HcPeditRace7;
  Gnome   : x:=HcPeditRace8;
  Gnoll   : x:=HcPeditRace9;
  Mutant  : x:=HcPeditRace10;
  else x:=HcNada;
 end;

 race_hint:=x;

end;

Function Spell_HintPly(spell_nr : integer;class:classes):word;
var x : integer;
begin

 case class of
  Magician:begin
            case spell_nr of
             1:  x:=hcPeditSpells1;
             2:  x:=hcPeditSpells2;
             3:  x:=hcPeditSpells3;
             4:  x:=hcPeditSpells4;
             5:  x:=hcPeditSpells5;
             6:  x:=hcPeditSpells6;
             7:  x:=hcPeditSpells7;
             8:  x:=hcPeditSpells8;
             9:  x:=hcPeditSpells9;
             10: x:=hcPeditSpells10;
             11: x:=hcPeditSpells11;
             12: x:=hcPeditSpells12;

             else x:=HcNada;
            end;
           end;
  Cleric:begin
            case spell_nr of
             1:  x:=hcPeditSpells20;
             2:  x:=hcPeditSpells21;
             3:  x:=hcPeditSpells22;
             4:  x:=hcPeditSpells23;
             5:  x:=hcPeditSpells24;
             6:  x:=hcPeditSpells25;
             7:  x:=hcPeditSpells26;
             8:  x:=hcPeditSpells27;
             9:  x:=hcPeditSpells28;
             10: x:=hcPeditSpells29;
             11: x:=hcPeditSpells30;
             12: x:=hcPeditSpells31;

             else x:=HcNada;
            end;
           end;
  Sage:begin
            case spell_nr of
             1:  x:=hcPeditSpells35;
             2:  x:=hcPeditSpells36;
             3:  x:=hcPeditSpells37;
             4:  x:=hcPeditSpells38;
             5:  x:=hcPeditSpells39;
             6:  x:=hcPeditSpells40;
             7:  x:=hcPeditSpells41;
             8:  x:=hcPeditSpells42;
             9:  x:=hcPeditSpells43;
             10: x:=hcPeditSpells44;
             11: x:=hcPeditSpells45;
             12: x:=hcPeditSpells46;

             else x:=HcNada;
            end;
           end;

 end;
 spell_hintply:=x;

end;

Function Spell_Hint;
var x : integer;
begin
 case spell_nr of
  1: x:=hcMeditSpells1;
  2: x:=hcMeditSpells2;
  3: x:=hcMeditSpells3;
  4: x:=hcMeditSpells4;
  5: x:=hcMeditSpells5;
  6: x:=hcMeditSpells6;
  else x:=HcNada;
 end;

 spell_hint:=x;

end;

Function Monster_Spell;
var s : string;
begin

 case nr of
  1: s:='Cause Damage';
  2: s:='Snakes';
  3: s:='Cyclone';
  4: s:='Summon Undead';
  5: s:='Vice of Death';
  6: s:='Drain Life';
  else s:='error!';
 end;

 Monster_Spell:=s;

end;

Function Spell_Name;
var s : s70;
begin

 {The names of the Spells}
 s:='Not a Magic User';

 case spell of
  1:begin
     case class of
      Cleric   : s:='Cure Light';
      Magician : s:='Magic Missile';
      Sage     : s:='Fog of War';
     end;
    end;
  2:begin
     case class of
      Cleric   : s:='Armor';
      Magician : s:='Shield';
      Sage     : s:='Poison';
     end;
    end;
  3:begin
     case class of
      Cleric   : s:='Baptize Monster';
      Magician : s:='Sleep';
      Sage     : s:='Freeze';
     end;
    end;
  4:begin
     case class of
      Cleric   : s:='Cure Critical';
      Magician : s:='Web';
      Sage     : s:='Duplicate';
     end;
    end;
  5:begin
     case class of
      Cleric   : s:='Disease';
      Magician : s:='Power Hat';
      Sage     : s:='Roast';
     end;
    end;
  6:begin
     case class of
      Cleric   : s:='Holy Explosion';
      Magician : s:='Fireball';
      Sage     : s:='Hit Self';
     end;
    end;
  7:begin
     case class of
      Cleric   : s:='Invisibility';
      Magician : s:='Fear';
      Sage     : s:='Escape';
     end;
    end;
  8:begin
     case class of
      Cleric   : s:='Angel';
      Magician : s:='Lightning Bolt';
      Sage     : s:='Giant';
     end;
    end;
  9:begin
     case class of
      Cleric   : s:='Call Lightning';
      Magician : s:='Prismatic Cage';
      Sage     : s:='Steal';
     end;
    end;
 10:begin
     case class of
      Cleric   : s:='Heal';
      Magician : s:='Pillar of Fire';
      Sage     : s:='Energy Drain';
     end;
    end;
 11:begin
     case class of
      Cleric   : s:='Divination';
      Magician : s:='Power word KILL';
      Sage     : s:='Summon Demon';
     end;
    end;
 12:begin
     case class of
      Cleric   : s:='Gods Finger';
      Magician : s:='Summon Demon';
      Sage     : s:='Death Kiss';
     end;
    end;
 end;

 spell_name:=s;

end; {SPELL_NAME **** END ****}

Procedure Check_Item; {j„mf”r MEMOBJ med PRYL och kollar dependencies
                      {sparar om „ndringar skett.}
var save,dep : boolean;
    i : integer;
    dia : DependdialogP;

    R     : TRect;
    x1,y1,x2,y2 : byte;

begin
 save:=false;
 dep:=false;

 if pryl.name  <>memobj.name   then save:=true;
 if pryl.value <>memobj.value  then save:=true;
 if pryl.cure  <>memobj.cure   then save:=true;
 if pryl.shop  <>memobj.shop   then save:=true;
 if pryl.dng   <>memobj.dng    then save:=true;
 if pryl.cursed<>memobj.cursed then save:=true;
 if pryl.minlev<>memobj.minlev then save:=true;
 if pryl.maxlev<>memobj.maxlev then save:=true;
 if pryl.good<>memobj.good     then save:=true;
 if pryl.evil<>memobj.evil     then save:=true;
 if pryl.str_need<>memobj.str_need then save:=true;

 for i:=1 to 5 do begin
  if pryl.desc1[i]<>memobj.desc1[i] then save:=true;
  if pryl.desc2[i]<>memobj.desc2[i] then save:=true;
 end;

 for i:=1 to maxclasses do begin
  if pryl.restrict[i]<>memobj.restrict[i] then save:=true;
 end;

 if pryl.hps     <>memobj.hps      then dep:=true;
 if pryl.stamina <>memobj.stamina  then dep:=true;
 if pryl.agility <>memobj.agility  then dep:=true;
 if pryl.charisma<>memobj.charisma then dep:=true;
 if pryl.dex     <>memobj.dex      then dep:=true;
 if pryl.wisdom  <>memobj.wisdom   then dep:=true;
 if pryl.mana    <>memobj.mana     then dep:=true;
 if pryl.armor   <>memobj.armor    then dep:=true;
 if pryl.attack  <>memobj.attack   then dep:=true;
 if pryl.strength<>memobj.strength then dep:=true;
 if pryl.defence <>memobj.defence  then dep:=true;


 if dep then begin
  x1:=15;
  y1:=5;
  x2:=45;
  y2:=12;
  R.Assign(x1,y1,x2,y2);
  dia := New(DependDialogP, Init(R, 'Info',rand,pryl));
  dia^.static(2,2,'Checking dependencies..');
  dia^.Flags := dia^.Flags and (not wfClose) and (not wfMove);
  dia^.Options := dia^.Options or OfCentered;

  DeskTop^.ExecView(dia);
  Dispose(dia, Done);
 end
 else if save then begin
  Load_Objekt(FSave,pryl,pryl.ttype,rand);
 end;

end;

Procedure Item_File_Operations;
Var
  R   : TRect;
  Dia : IFODialogP;
  bw  : byte;

Begin

 R.Assign(0,0,30,10); {x/y start for config box}
 Dia:=New(IFODialogP, Init(R,'File Operations',typ));
 Dia^.Options := Dia^.Options or ofCentered;

 bw:=10; {button width}

 Dia^.MakeButton(2,02,bw,'~I~mport',cmImport, bfNormal+bfgrabfocus,hcItemImport);
 Dia^.MakeButton(2,04,bw,'~E~xport',cmExport, bfNormal+bfgrabfocus,hcItemExport);
 Dia^.MakeButton(2,06,bw,'~C~ancel',cmCancel, bfNormal+bfgrabfocus,hcGenCancel);

 DeskTop^.ExecView(Dia);
 Dispose(Dia, Done);

End;

Procedure Item_Class_Restrictions(var item : objektrec);
Const x1 : byte = 0;
      y1 : byte = 0;
      x2 : byte = 34;
      y2 : byte = 17;

const s='s';
Var
  R  : TRect;
  Dia : IREDialogP;
  bw : byte;
  items : pcheckboxes;

  t,w:byte;

  result : word;

Begin

 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 Dia:=New(IREDialogP, Init(R,'Item can be used by'));
 Dia^.Options := Dia^.Options or ofCentered;

 bw:=10; {button width}

 t:=2;
 w:=17;

 R.Assign(3, 2, 18, 13); {Size of the radio button box}

 items:=New(PCheckBoxes, Init(R,
        NewsItem(class_display(Alchemist)+s,
        NewSItem(class_display(Assassin)+s,
        NewSItem(class_display(Barbarian)+s,
        NewSItem(class_display(Bard)+s,
        NewsItem(class_display(Cleric)+s,
        NewsItem(class_display(Jester)+s,
        NewsItem(class_display(Magician)+s,
        NewsItem(class_display(Paladin)+s,
        NewsItem(class_display(Ranger)+s,
        NewsItem(class_display(Sage)+s,
        NewsItem(class_display(Warrior)+s, nil)))))))))))));

 for w:=1 to maxclasses do begin
  if item.restrict[w]=false then items^.press(w-1);
 end;
 Dia^.Insert(items);

 Dia^.OkButton(2,y2-3);
 Dia^.CancelButton(12,y2-3);
 Dia^.MakeButton(22,y2-3,10,'~H~elp',cmHelp,bfNormal+bfgrabfocus,hcItemRestrict);

 result:=DeskTop^.ExecView(Dia);

 if result = cmOk then begin
  {change user settings}
  for w:=1 to maxclasses do begin
   if NOT items^.Mark(w-1) then item.restrict[w]:=true
                           else item.restrict[w]:=false;
  end;
 end;

 dispose(Dia,Done);

End;


Procedure Import_Items;
var
   tempfile : file of objektrec;
   tmpobjekt : objektrec;
   x,i : longint;
   getout : boolean;
   fname : s90;

begin

 assign(tempfile,s);

 {$I-}reset(tempfile);{$I+}
 if IOResult<>0 then unable_to_access(s);

 {$I-}x:=filesize(tempfile);{$I+}
 if IOResult<>0 then unable_to_filesize(s);

 {$I-}read(tempfile,tmpobjekt);{$I+}
 if IOResult<>0 then unable_to_read(s);


 if IOResult=0 then begin

  getout:=false;

  if getout then begin
   messagebox(#3'WRONG TYPE OF FILE!',nil,mfOkbutton+mfWarning);
  end
  else begin
   fname:=objf1;
   case tmpobjekt.ttype of
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

   assign(ofil,fname);

   {$I-}reset(ofil);{$I+}
   if IOResult<>0 then unable_to_access(fname);

   {$I-}seek(ofil,filesize(ofil));{$I+}
   if IOResult<>0 then unable_to_seek(fname,0);

   {$I-}reset(tempfile);{$I+}
   if IOResult<>0 then unable_to_access(s);

   for i:=1 to x do begin
    {$I-}read(tempfile,tmpobjekt);{$I+}
    if Ioresult<>0 then unable_to_read(s);

    {$I-}write(ofil,tmpobjekt);{$I+}
    if Ioresult<>0 then unable_to_write(fname);

   end;

   {$I-}close(tempfile);{$I+}
   if IOresult<>0 then unable_to_close(s);

   {$I-}close(ofil);{$I+}
   if IOresult<>0 then unable_to_close(fname);

   messagebox(#3+commastr(x)+' ITEMS IMPORTED',nil,mfOkbutton+mfInformation);
  end;
 end
 else begin
  messagebox(#3'BAD FILE FORMAT!',nil,mfOkbutton+mfWarning);
 end;

end;

Procedure Export_Items;
var
   tempfile : file of objektrec;
   tmpobjekt : objektrec;
   x,i : longint;

begin

 assign(tempfile,s);
 {$I-}rewrite(tempfile);{$I+}
 if IOresult<>0 then unable_to_create(s);

 for i:=n1 to n2 do begin

  load_objekt(Fload,tmpobjekt,typ,i);

  {$I-}write(tempfile,tmpobjekt);{$I+}
  if IOResult<>0 then unable_to_write(s);
 end;

 {$I-}close(tempfile);{$I+}
 if IOresult<>0 then unable_to_close(s);

 messagebox(#3+commastr(n2-n1)+' ITEMS EXPORTED',nil,mfOkbutton+mfInformation);

end;

Function Look_For_User(user : userrec) : integer;

const maxlett = 30;
const lastsearch1 : string[maxlett] = '';
const lastsearch2 : string[maxlett] = '';

type DataRec = record
      nam : string[maxlett];
      ali : string[maxlett];
     end;

var
  Dia  : XDialogP;
  R    : TRect;
  Data : ^DataRec;

  i,res,go : integer;

  nam,
  ali,
  found,
  waitishere : boolean;

  ss,s : string;

begin

 new(data);
 data^.nam:=lastsearch1;
 data^.ali:=lastsearch2;

 R.Assign(0, 0, 40, 10);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME & ALIAS}
  TxtEntry(1,2,'Name ',maxlett,maxlett,hcGenString);
  TxtEntry(1,4,'Alias',maxlett,maxlett,hcGenString);

  OkButton    (02,7);
  CancelButton(14,7);

  FocusNext(false);
  FocusNext(false);

 end;

 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch1:=data^.nam;
 lastsearch2:=data^.ali;

 if go=CmOk then begin
  nam:=false;
  ali:=false;
  found:=false;
  res:=0;
  {looking for data.nam or data.ali}
  if (data^.nam<>'') or (data^.ali<>'') then begin
   if data^.nam<>'' then begin
    nam:=true;
    s:=data^.nam;
   end
   else begin
    ali:=true;
    s:=data^.ali;
   end;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;

   for i:=1 to fs(FsPlayer) do begin
    load_player(Fload,player0,i);
    if nam then ss:=player0.name1
           else ss:=player0.name2;

    if (findsub(s,ss)) and (player0.name2<>user.name2) then begin

     if waitishere then begin
      {Remove Wait Dialog}
      MyApp.Delete(Dia);
      Dia^.Done;
      Dispose(Dia);
      waitishere:=false;
     end;

     R.Assign(0, 0, 38, 9);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NUMBER, NAME & ALIAS}
      Static(2,2,'Record   : '+commastr(i));
      Static(2,3,'Username : '+player0.name1);
      Static(2,4,'Alias    : '+player0.name2);

      MakeButton  (02,06,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,06,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,06);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}
      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;
     end;

    end;
   end; {for i:= .end.}

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    messagebox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 look_for_user:=res;

 dispose(data);

end;

Function Monster_Search(creep : monsterrec) : longint;
type DataRec = record
      nam : string[30];
     end;
const lastsearch :string[30] = '';
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : monsterrec;
  i,res,go : integer;
  found : boolean;
  waitishere : boolean;
  ss,s : string;

begin

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {leta efter data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;

   for i:=1 to fs(FsMonster) do begin
    load_monster(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     if waitishere then begin
      {Remove Wait Dialog}
      MyApp.Delete(Dia);
      Dia^.Done;
      Dispose(Dia);
      waitishere:=false;
     end;

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}
      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;

     end;

    end;
   end; {for i:= .end.}

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 Monster_Search:=res;

 Dispose(Data);

end;

Function Drink_Search(creep : DrinkRec) : longint;
type DataRec = record
      nam : s30;
     end;
const lastsearch :s30 = '';
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : DrinkRec;
  i,res,go : integer;
  found : boolean;
  waitishere : boolean;
  ss,s : string;

begin

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;

   for i:=1 to fs(FsDrink) do begin
    load_drink(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     if waitishere then begin
      {Remove Wait Dialog}
      MyApp.Delete(Dia);
      Dia^.Done;
      Dispose(Dia);
      waitishere:=false;
     end;

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}
      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;

     end;

    end;
   end; {for i:= .end.}

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 Drink_Search:=res;

 Dispose(Data);

end; {drink_search .end.}

Function God_Search(creep : GodRec) : longint;
type DataRec = record
      nam : s30;
     end;
const lastsearch :s30 = '';
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : GodRec;
  i,res,go : integer;
  found : boolean;
  waitishere : boolean;
  ss,s : string;

begin

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;

   for i:=1 to fs(FsGod) do begin
    load_god(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     if waitishere then begin
      {Remove Wait Dialog}
      MyApp.Delete(Dia);
      Dia^.Done;
      Dispose(Dia);
      waitishere:=false;
     end;

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}
      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;

     end;

    end;
   end; {for i:= .end.}

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 God_Search:=res;

 Dispose(Data);

end; {god_search .end.}

Function Child_Search(creep : ChildRec) : longint;
type DataRec = record
      nam : s30;
     end;
const lastsearch :s30 = '';
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : ChildRec;
  i,res,go : integer;
  found : boolean;
  waitishere : boolean;
  ss,s : string;

begin

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;

   for i:=1 to fs(FsChild) do begin
    load_child(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     if waitishere then begin
      {Remove Wait Dialog}
      MyApp.Delete(Dia);
      Dia^.Done;
      Dispose(Dia);
      waitishere:=false;
     end;

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}
      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;

     end;

    end;
   end; {for i:= .end.}

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 Child_Search:=res;

 Dispose(Data);

end; {child_search .end.}


Function DoorGuard_Search(creep : GuardRec) : longint;
const lastsearch :string[30] = '';
type DataRec = record
      nam : string[30];
     end;
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : guardrec;
  i,res,go : integer;
  found : boolean;
  ss,s : string;

begin

 new(Data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   for i:=1 to fs(FsGuard) do begin
    load_guard(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end;

    end;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 DoorGuard_Search:=res;

 Dispose(Data);

end;

Function Moat_Search(creep : MoatRec) : longint;
const lastsearch :string[30] = '';
type DataRec = record
      nam : string[30];
     end;
var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : MoatRec;
  i,res,go : integer;
  found : boolean;
  ss,s : string;

begin

 new(Data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}
  if data^.nam<>'' then begin
   s:=data^.nam;

   for i:=1 to fs(FsMoat) do begin
    load_moat(Fload,temp,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     R.Assign(0, 0, 40, 8);
     Dia := New(XDialogP, Init(R, 'Found'));
     With Dia^ do begin
      Options := Options or ofCentered;

      {NAME}
      Static(2,2,'('+commastr(i)+') '+temp.name);

      {Buttons}
      MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
      MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
      CancelButton(24,05);

      FocusNext(false);
     end;

     go:=MyApp.ExecuteDialog(Dia,Nil);

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end;

    end;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 Moat_Search:=res;

 Dispose(Data);

end;


Function Leta_Efter_Item(creep : objektrec) : longint;
const lastsearch :string[30] = '';

type DataRec = record
      nam : string[30];
     end;

var
  R    : TRect;
  Dia  : XDialogP;
  Data : ^DataRec;

  temp : objektrec;
  i,res,go : longint;
  found : boolean;
  ss,s : string;
  getout,waitishere : boolean;

begin

 New(Data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 40, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {NAME}
  TxtEntry(1,2,'Name ',30,30,hcGenString);

  {Buttons}
  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if go=CmOk then begin
  found:=false;
  res:=0;
  {look for data.nam}

  if data^.nam<>'' then begin
   s:=data^.nam;

   {Setup Wait Dialog}
   Dia:=Waitdialog('Information','Searching...');
   MyApp.Insert(Dia);
   waitishere:=true;


   for i:=1 to fso(creep.ttype) do begin
    load_objekt(Fload,temp,creep.ttype,i);
    ss:=temp.name;

    if (findsub(s,ss)) and (temp.name<>creep.name) then begin

     getout:=false;
     repeat
      if waitishere then begin
       {Remove Wait Dialog}
       MyApp.Delete(Dia);
       Dia^.Done;
       Dispose(Dia);
       waitishere:=false;
      end;

      R.Assign(0, 0, 48, 8);
      Dia := New(XDialogP, Init(R, 'Found'));
      With Dia^ do begin
       Options := Options or ofCentered;

       {NAME}
       Static(2,2,'('+commastr(i)+') '+temp.name);

       MakeButton  (02,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
       MakeButton  (13,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
       MakeButton  (24,05,10,'~I~nfo',CmNo,bfNormal+bfgrabfocus,hcItemInfo);
       CancelButton(35,05);

       FocusNext(false);
      end;

      go:=MyApp.ExecuteDialog(Dia,Nil);

      if go=CmNo then begin
       item_info(temp);
       getout:=false;
      end
      else begin
       getout:=true;
      end;

     until getout;

     if go=CmOk then begin
      res:=i;
      found:=true;
      break;
     end
     else if go=CmCancel then begin
      res:=-1;
      found:=true;
      break;
     end
     else begin
      {next}

      if waitishere=false then begin
       {Setup Wait Dialog}
       Dia:=Waitdialog('Information','Searching...');
       MyApp.Insert(Dia);
       waitishere:=true;
      end;

     end;

    end;
   end;

   if waitishere then begin
    {Remove Wait Dialog}
    MyApp.Delete(Dia);
    Dia^.Done;
    Dispose(Dia);
    waitishere:=false;
   end;

   if NOT found then begin
    MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
   end;

  end;
 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 leta_efter_item:=res;

 dispose(data);

end;

Function Look_For_Item(templist : pstringcollection) : longint;
const lastsearch :string[30] = '';
type DataRec = record
      nam : string[30];
     end;

var

  R   : TRect;
  Dia : XDialogP;

  Data : ^DataRec;

  found : boolean;
  i,res,go : integer;
  ss,s,nice : string;
  kill : byte;

begin

 {Search for Item --}

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 45, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {Item search string}
  TxtEntry(1,2,'Search For',30,30,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;

 {execute dialog}
 go:=MyApp.ExecuteDialog(Dia,Data);

 {get user input}
 lastsearch:=data^.nam;


 if (go=CmOk) and (data^.nam<>'') then begin
  found:=false;
  res:=0;

  {leta efter data.nam}
  s:=upcasestr(data^.nam);
  kill:=4;

  for i:=1 to templist^.count do begin
   ss:=PString(templist^.At(i-1))^;
   nice:=ss;
   ss:=upcasestr(ss);

   delete(ss,1,kill);

   if length(ss)>length(s) then begin
    delete(ss,length(s)+1,99);
   end;

   if s=ss then begin

    delete(nice,1,kill);
    if length(nice)>=21 then begin
     delete(nice,21,99);
    end;

    R.Assign(0, 0, 50, 8);
    Dia := New(XDialogP, Init(R, 'Found'));
    With Dia^ do begin
     Options := Options or ofCentered;

     Static(2,2,' ('+commastr(i)+') '+nice);

     MakeButton  (01,05,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
     MakeButton  (12,05,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
     CancelButton(23,05);

     FocusNext(false);
    end;

    go:=MyApp.ExecuteDialog(Dia,Nil);

    if go=CmOk then begin
     res:=i;
     found:=true;
     break;
    end
    else if go=CmCancel then begin
     res:=-1;
     found:=true;
     break;
    end;

   end;
  end;

  if NOT found then begin
   MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
  end;

 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 Look_For_Item:=res;

 dispose(data);
end;

Procedure Player_Editor;
Var
  R   : TRect;
  Dia : PEditDialogP;

  x1,y1,x2,y2,t : byte;
  s : string[20];

  items : psitem;

Begin

 if global_humans then begin
  s:='Player Editor';
  assign(playerfile,global_pfile);
 end
 else begin
  s:='NPC Editor';
  assign(playerfile,global_npfile);
 end;

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start for config box}

 {Init}
 Dia:=New(PEditDialogP, Init(R,s));

 {Options}
 Dia^.Options := Dia^.Options + ofCentered;


 {Helptext}
 dia^.helpctx:=hcPlayerEditor;

 {NAME & ALIAS}
 dia^.TxtEntry(1,02,'Name ',30,20,hcPeditName);
 dia^.TxtEntry(1,03,'Alias',30,20,hcPeditAlias);

 {MONEY}
 dia^.ValEntry(1,04,'Money',12,0,2000000000,hcPeditMoney);

 {BANK}
 dia^.ValEntry(1,05,'Bank ',12,0,2000000000,hcPeditBank);

 {EXPERIENCE}
 dia^.ValEntry(1,06,'Experience',12,0,1000000000,hcPeditExperience);

 {HEALING POTIONS}
 dia^.ValEntry(1,07,'Healing Potions',7,0,32000,hcPeditHealings);

 {DUNGEON FIGHTS}
 dia^.ValEntry(1,08,'Dungeon Fights ',7,0,5000,hcPeditDngFights);

 {PLAYER FIGHTS}
 dia^.ValEntry(1,09,'Player Fights  ',7,0,5000,hcPeditPlyFights);

 {TEAM FIGHTS}
 dia^.ValEntry(1,10,'Team Fights    ',7,0,5000,hcPeditTeamFights);

 {TEAM}
 dia^.TxtEntry(1,11,'TeamName ',25,20,hcPeditTeam);

 {TEAM PASSWORD}
 dia^.TxtEntry(1,12,'Password ',20,14,hcPeditPassword);

 {BattleCry}
 {dia^.TxtEntry(1,13,'BattleCry',70,20,hcPeditBattleCry);
  I moved this entry to the 'phrases' dialog box

 {MENTAL HEALTH}
 dia^.ValEntry(1,14,'Mental Health ',7,0,100,hcPeditMental);

 {DRUG ADDICTION}
 dia^.ValEntry(1,15,'Drug Addiction',7,0,100,hcPeditDrugAddict);

 {THIEVING OPTIONS}
 dia^.ValEntry(1,16,'Thefts Left   ',7,0,100,hcPeditThefts);

 {BRAWLS}
 dia^.ValEntry(1,17,'Brawls Left   ',7,0,100,hcPeditBrawls);

 {Training Sessions}
 dia^.ValEntry(1,18,'Trainings     ',7,0,100,hcPeditTrainings);

 {RACE}
 items:=NewsItem(race_display(human),
        NewsItem(race_display(hobbit),
        NewsItem(race_display(elf),
        NewsItem(race_display(halfelf),
        NewsItem(race_display(dwarf),
        NewsItem(race_display(troll),
        NewsItem(race_display(orc),
        NewsItem(race_display(gnome),
        NewsItem(race_display(gnoll),
        NewsItem(race_display(mutant), nil))))))))));
 dia^.RadioButtons('Race',false,true,30,2,12,10,items,race_hint(Human));


 {AI}
 items:=NewsItem('Human',
        NewsItem('NPC',nil));
 dia^.RadioButtons('Control',true,false,28,15,16,2,items,hcPeditControl1);

 {SEX}
 items:=NewsItem('Female',
        NewsItem('Male',nil));
 dia^.RadioButtons('Gender',true,false,28,16,17,2,items,hcPeditGender1);

 {KING/QUEEN}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('King  ',true,false,28,17,18,2,items,hcPeditKing1);

 {ALLOWED IN}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Allowed In',true,false,28,18,19,2,items,hcPeditAllowed1);


 {PROFESSION}
 items:=NewsItem(class_display(alchemist),
        NewsItem(class_display(assassin),
        NewsItem(class_display(barbarian),
        NewsItem(class_display(bard),
        NewsItem(class_display(cleric),
        NewsItem(class_display(jester),
        NewsItem(class_display(magician),
        NewsItem(class_display(paladin),
        NewsItem(class_display(ranger),
        NewsItem(class_display(sage),
        NewsItem(class_display(warrior),nil)))))))))));

 dia^.RadioButtons('Profession',false,true,43,2,10,11,items,class_hint(Alchemist));


 {LEVEL}
 dia^.ValEntry(63,02,'Level'   ,7,1,100,hcPeditLevel);

 {HPS}
 dia^.ValEntry(65,03,'Hps'     ,7,-30000,30000,hcPeditHps);

 {MAXHPS}
 dia^.ValEntry(61,04,'Max Hps'  ,7,0,30000,hcPeditMaxHps);

 {AGE}
 dia^.ValEntry(65,05,'Age'     ,7,10,200,hcPeditAge);

 {Chivalry}
 dia^.ValEntry(60,06,'Chivalry',7,0,500000,hcPeditChivalry);

 {Darkness}
 dia^.ValEntry(60,07,'Darkness',7,0,500000,hcPeditDarkness);

 {Strength}
 dia^.ValEntry(60,08,'Strength',7,0,30000,hcPeditStrength);

 {Defence}
 dia^.ValEntry(61,09,'Defence' ,7,0,30000,hcPeditDefence);

 {Acts of Darkness}
 dia^.ValEntry(58,10,'Dark Deeds' ,7,0,1000,hcPeditGoodDeeds);

 {Acts of Chivalry}
 dia^.ValEntry(58,11,'Good Deeds' ,7,0,1000,hcPeditEvilDeeds);

 {Mana}
 dia^.ValEntry(64,12,'Mana',7,0,32000,hcPeditMana);

 {MaxMana}
 dia^.ValEntry(60,13,'Max Mana' ,7,0,32000,hcPeditMaxMana);

 {Stamina}
 dia^.ValEntry(61,14,'Stamina' ,7,-32000,32000,hcPeditStamina);

 {Agility}
 dia^.ValEntry(61,15,'Agility' ,7,-32000,32000,hcPeditAgility);

 {Charisma}
 dia^.ValEntry(60,16,'Charisma' ,7,-32000,32000,hcPeditCharisma);

 {Dexterity}
 dia^.ValEntry(59,17,'Dexterity' ,7,-32000,32000,hcPeditDexterity);

 {Wisdom}
 dia^.ValEntry(62,18,'Wisdom' ,7,-32000,32000,hcPeditWisdom);


 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,7,'~O~k',       cmOk,      bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+7,y2-3,12,'~P~revious', cmPPrev,   bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+19,y2-3,08,'~N~ext',    cmPNext,   bfNormal+bfgrabfocus,hcGENnext);

 dia^.MakeButton(t+27,y2-3,13,'~E~quipment',cmPEquip, bfNormal+bfgrabfocus,hcPEDITequip);
 dia^.MakeButton(t+40,y2-3,08,'~M~ore',     cmPMore,  bfNormal+bfgrabfocus,hcPEDITmore);

 dia^.MakeButton(t+48,y2-3,10,'~S~earch',   cmPSearch, bfNormal+bfgrabfocus,hcPEDITsearch);
 dia^.MakeButton(t+58,y2-3,10,'~C~reate',   cmPCreate, bfNormal+bfgrabfocus,hcPEDITcreate);

 {set the currently selected button to the OK button *must be a better solution*}
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);

 {Load Current Player/Npc}
 load_player(Fload,player,currp);

 {Transfer Player/npc data to Record structure}
 Transfer(EdGuy,Player,false);

 {Dialog Setdata with Record Structure}
 dia^.SetData(EdGuy);

 {Execute Dialog}
 DeskTop^.ExecView(DIA);

 {Dispose Dialog}
 Dispose(DIA, Done);

End;

Procedure DoorGuard_Editor;
Var
  R   : TRect;
  Dia : DoorGuardDialogP;

  x1,y1,x2,y2,t,ofy,i : byte;
  s : s70;
  items : psitem;

Begin

 assign(guardfile,gufile);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 {Title}
 s:='Door Guard Editor';

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start for config boxen}

 {Init}
 dia:=New(DoorGuardDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Guard',50,35,hcDGname);

 {COST}
 dia^.ValEntry(1,03,'Cost ',17,0,2000000000,hcDGcost);

 {HPS}
 dia^.ValEntry(1,05,'HitPoints  ',12,0,2000000000,hcDGHitpoints);

 {BASE ARMOR}
 dia^.ValEntry(1,06,'Base Armor ',7,0,32000,hcDGBaseArmor);

 {BASE ATTACK}
 dia^.ValEntry(1,07,'Base Attack',7,0,32000,hcDGBaseAttack);

 {DESC}
 ofy:=09;
 for i:=1 to 5 do begin
  case i of
   1:   s:='Description '+commastr(i);
   else s:='            '+commastr(i);
  end;

  dia^.TxtEntry(1,ofy,s,70,50,hcDGdesc);

  inc(ofy);
 end;

 {HIRE MANY?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Hire Many',true,false,1,15,17,1,items,hcDGmany);


 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',       cmOk,      bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious', cmPPrev,   bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',     cmPNext,   bfNormal+bfgrabfocus,hcGENNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',   cmPSearch, bfNormal+bfgrabfocus,hcDGSearch);

 dia^.MakeButton(t+40,y2-3,10,'~C~reate',   cmPCreate, bfNormal+bfgrabfocus,hcDGcreate);
 dia^.MakeButton(t+50,y2-3,10,'~H~elp',     cmHelp, bfNormal+bfgrabfocus,hcDoorGuardEditor);

 {load current guard}
 load_guard(Fload,guard,currg);

 {transfer guard record to dialog record}
 Transfer_Guard(EdGuard,Guard,false);

 {set dialog data}
 dia^.SetData(EdGuard);

 {set the currently selected button to the OK button *must be a better solution*}
 for i:=1 to 5 do begin
  dia^.SelectNext(true);
 end;

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End;

Procedure God_Editor; {The God Editor}
Var

  R   : TRect;
  Dia : GodDialogP;

  x1,
  y1,
  x2,
  y2,
  t,
  ofy,
  i : byte;

  s : s70;

  items : psitem;

Begin

 {assign god-file}
 assign(godfile,godsf);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=18;

 {Title}
 s:='God Editor';

 {Assign Dialog}
 R.Assign(x1,y1,x2,y2); {x/y start for config boxen}

 {Init Dialog Box}
 dia:=New(GodDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Name ',30,35,hcDrinkName);

 {ALIAS}
 dia^.TxtEntry(1,03,'Alias',30,35,hcDrinkCreator);

 {CREATED DATE}
 {dia^.TxtEntry(44,03,'Created',10,57,hcDrinkDate);

 {COMMENT}
 {dia^.TxtEntry(1,04,'Comment',70,65,hcDrinkComment);

 {ORDERED}
 {dia^.ValEntry(1,06,'Ordered',12,0,2000000000,hcDrinkOrdered);

 {LAST HAD BY}
 {dia^.TxtEntry(1,07,'Last had by',30,30,hcDrinkLastHad);

 {LAST TIME ORDERED}
 {dia^.TxtEntry(44,7,'Order Date',10,57,hcDrinkLastOrdered);


 {SECRET RECIPE?}
 {items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Secret Recipe',true,false,1,9,11,1,items,hcDrinkSecret);

 {DELETED?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Deleted',true,false,1,11,13,1,items,hcDrinkDeleted);

 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',               cmOk,           bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious',         cmPPrev,        bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',             cmPNext,        bfNormal+bfgrabfocus,hcGENNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',           cmPSearch,      bfNormal+bfgrabfocus,hcDrinkSearch);
 dia^.MakeButton(t+40,y2-3,10,'~H~elp',             cmHelp,         bfNormal+bfgrabfocus,hcDrinkEditor);

 {load current God}
 load_god(Fload,god,currgod);

 {transfer god record to dialog record}
 Transfer_God(EdGod,God,false);

 {set dialog data}
 dia^.SetData(EdGod);

 {set the currently selected button to the OK button.
  there *must be a better solution*}
 for i:=1 to 3 do begin
  dia^.SelectNext(true);
 end;

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End; {God Editor *end*}

Procedure Child_Editor; {The Children Editor}
Var

  R   : TRect;
  Dia : ChildDialogP;

  x1,
  y1,
  x2,
  y2,
  t,
  ofy,
  i : byte;

  s : s70;

  items : psitem;

Begin

 {assign child-file}
 assign(childfile,childrenf);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=18;

 {Title}
 s:='Child Editor';

 {Assign Dialog}
 R.Assign(x1,y1,x2,y2); {x/y start for config boxen}

 {Init Dialog Box}
 dia:=New(ChildDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Name ',30,35,hcDrinkName);

 {MOTHER}
 dia^.TxtEntry(1,03,'Mother',30,35,hcDrinkCreator);

 {FATHER}
 dia^.TxtEntry(1,04,'Father',30,35,hcDrinkComment);

 {ORDERED}
 {dia^.ValEntry(1,06,'Ordered',12,0,2000000000,hcDrinkOrdered);

 {LAST HAD BY}
 {dia^.TxtEntry(1,07,'Last had by',30,30,hcDrinkLastHad);

 {LAST TIME ORDERED}
 {dia^.TxtEntry(44,7,'Order Date',10,57,hcDrinkLastOrdered);


 {SECRET RECIPE?}
 {items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Secret Recipe',true,false,1,9,11,1,items,hcDrinkSecret);

 {DELETED?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Deleted',true,false,1,11,13,1,items,hcDrinkDeleted);

 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',               cmOk,           bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious',         cmPPrev,        bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',             cmPNext,        bfNormal+bfgrabfocus,hcGENNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',           cmPSearch,      bfNormal+bfgrabfocus,hcDrinkSearch);
 dia^.MakeButton(t+40,y2-3,10,'~H~elp',             cmHelp,         bfNormal+bfgrabfocus,hcDrinkEditor);

 {load current Child}
 load_child(Fload,child,currchild);

 {transfer god record to dialog record}
 Transfer_Child(EdChild,Child,false);

 {set dialog data}
 dia^.SetData(EdChild);

 {set the currently selected button to the OK button.
  there *must be a better solution*}
 for i:=1 to 3 do begin
  dia^.SelectNext(true);
 end;

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End; {God Editor *end*}


Procedure Moat_Editor;
Var
  R   : TRect;
  Dia : MoatDialogP;

  x1,y1,x2,y2,t,ofy,i : byte;
  s : s70;
  items : psitem;

Begin

 assign(moatfile,motfile);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 {Title}
 s:='Moat Creature Editor';

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start for config box}

 {Init}
 dia:=New(MoatDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Creature',30,30,hcMoatName);

 {COST}
 dia^.ValEntry(1,03,'Cost    ',12,0,2000000000,hcMoatCost);

 {HPS}
 dia^.ValEntry(1,05,'HitPoints  ',12,0,2000000000,hcMoatHps);

 {BASE ARMOR}
 dia^.ValEntry(1,06,'Base Armor ',7,0,32000,hcMoatBaseArmor);

 {BASE ATTACK}
 dia^.ValEntry(1,07,'Base Attack',7,0,32000,hcMoatBaseAttack);

 {DESCRIPTION}
 ofy:=09;
 for i:=1 to 5 do begin
  case i of
   1:   s:='Description '+commastr(i);
   else s:='            '+commastr(i);
  end;

  dia^.TxtEntry(1,ofy,s,70,60,hcMoatDesc);

  inc(ofy);
 end;

 {HIRE MANY?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Deleted',true,false,1,15,17,1,items,hcMoatDeleted);


 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',       cmOk,      bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious', cmPPrev,   bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',     cmPNext,   bfNormal+bfgrabfocus,hcGENNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',   cmPSearch, bfNormal+bfgrabfocus,hcMoatSearch);

 dia^.MakeButton(t+40,y2-3,10,'~C~reate',   cmPCreate, bfNormal+bfgrabfocus,hcMoatCreate);
 dia^.MakeButton(t+50,y2-3,10,'~H~elp',     cmHelp, bfNormal+bfgrabfocus,hcMoatEditor);

 {load current moat}
 load_moat(Fload,moat,currmoat);

 {transfer moat record to dialog record}
 Transfer_Moat(EdMoat,Moat,false);

 {set dialog data}
 dia^.SetData(EdMoat);

 {set the currently selected button to the OK button *must be a better solution*}
 for i:=1 to 5 do begin
  dia^.SelectNext(true);
 end;

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End; {moat_editor *end*}

Procedure Phrase_Page; {Phrase editor! (reached from player/npc editor
                       page 2}
Var

  R   : TRect;
  Dia : PhraseDialogP; {Dialog Box}

  x1,
  y1,
  x2,
  y2,
  t,
  i : byte;

  s : s70;

Begin

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=15;

 {Title}
 if upcase(player.name2[length(player.name2)])<>'S' then begin
  s:=player.name2+'s Phrases';
 end
 else begin
  s:=player.name2+' Phrases';
 end;

 {Assign Dialog}
 R.Assign(x1,y1,x2,y2); {x/y start for config box}

 {Init Dialog Box}
 dia:=New(PhraseDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {Battle Cry}
 dia^.TxtEntry(1,03,'Battle Cry   ',70,60,hcPeditBattleCry);

 {Phrase 1}
 dia^.TxtEntry(1,04,'When attacked',70,60,hcPeditPhrase1);

 {Phrase 2}
 dia^.TxtEntry(1,05,'After Win    ',70,60,hcPeditPhrase2);

 {Phrase 3}
 dia^.TxtEntry(1,06,'After Defeat ',70,60,hcPeditPhrase3);

 {Phrase 4}
 dia^.TxtEntry(1,07,'Begging      ',70,60,hcPeditPhrase4);

 {Phrase 5}
 dia^.TxtEntry(1,08,'Sparing life ',70,60,hcPeditPhrase5);

 {Phrase 6}
 dia^.TxtEntry(1,09,'No Mercy     ',70,60,hcPeditPhrase6);

 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',     cmOk,    bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~C~ancel', cmCancel,bfNormal+bfgrabfocus,hcGENCancel);

 {transfer values to dialog record}
 Transfer_Phrases(EditPhrase,Player,false);

 {set dialog data}
 dia^.SetData(EditPhrase);

 {set the currently selected button to the OK button.}
 dia^.SelectNext(true);

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End; {Phrase Editor .end.}


Procedure Drink_Ingredients_Editor(var a_drink:drinkrec); {called from drink_editor}
var
   R: TRect;
   D: XDialogP;
   i,j,c : byte;
   sinfo : array[1..global_max_drink_ingredients] of string[25];
   s : s15;
begin

 for i:=1 to global_max_drink_ingredients do begin
  sinfo[i]:='';
 end;

 {preparing info arrays}
 for i:=1 to global_max_drink_ingredients do begin

  if a_drink.amount[i]>0 then begin
   s:=' '+commastr(a_drink.amount[i])+'% ';
   while length(s)<6 do begin
    s:=' '+s;
   end;

   sinfo[i]:=s+drink_ingredient(i);

  end
  else begin
   s:='  --- ';
   sinfo[i]:=s;

  end;


 end; {for i:= .end.}

 R.Assign(0, 0, 28, global_max_drink_ingredients+6);
 D := New(XDialogP, Init(R,'Ingredients'));
 With D^ do begin
  Options := Options or ofCentered;

 { R.Grow(-1, -1);
  Dec(R.B.Y, 3);
 }
  c:=2;
  for i:=1 to global_max_drink_ingredients do begin
   if sinfo[i]<>'' then begin
    Static(2,c,sinfo[i]);
    inc(c);
   end;
  end;

  {Buttons}
  OkButton(9,global_max_drink_ingredients+3);

 end;

 MyApp.ExecuteDialog(D,Nil);

end; {drink_ingredients_editor *end*}

Procedure Drink_Editor; {The Drink Editor! (drinks created by users and
                         available at Orbs bar)}
Var

  R   : TRect;
  Dia : DrinkDialogP;

  x1,
  y1,
  x2,
  y2,
  t,
  ofy,
  i : byte;

  s : s70;

  items : psitem;

Begin

 {assign drinkfile}
 assign(cocktailfile,drinkfile);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=18;

 {Title}
 s:='Drink Editor';

 {Assign Dialog}
 R.Assign(x1,y1,x2,y2); {x/y start for config boxen}

 {Init Dialog Box}
 dia:=New(DrinkDialogP, Init(R,s));

 {Dialog Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Drink  ',30,35,hcDrinkName);

 {CREATOR}
 dia^.TxtEntry(1,03,'Creator',30,30,hcDrinkCreator);

 {CREATED DATE}
 dia^.TxtEntry(44,03,'Created',10,57,hcDrinkDate);

 {COMMENT}
 dia^.TxtEntry(1,04,'Comment',70,65,hcDrinkComment);

 {ORDERED}
 dia^.ValEntry(1,06,'Ordered',12,0,2000000000,hcDrinkOrdered);

 {LAST HAD BY}
 dia^.TxtEntry(1,07,'Last had by',30,30,hcDrinkLastHad);

 {LAST TIME ORDERED}
 dia^.TxtEntry(44,7,'Order Date',10,57,hcDrinkLastOrdered);


 {SECRET RECIPE?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Secret Recipe',true,false,1,9,11,1,items,hcDrinkSecret);

 {DELETED?}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Deleted',true,false,1,11,13,1,items,hcDrinkDeleted);

 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',               cmOk,           bfNormal+bfgrabfocus,hcGENok);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious',         cmPPrev,        bfNormal+bfgrabfocus,hcGENprevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',             cmPNext,        bfNormal+bfgrabfocus,hcGENNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',           cmPSearch,      bfNormal+bfgrabfocus,hcDrinkSearch);
 dia^.MakeButton(t+40,y2-3,10,'~H~elp',             cmHelp,         bfNormal+bfgrabfocus,hcDrinkEditor);
 dia^.MakeButton(t+50,y2-3,21,'~V~iew Ingredients', cmDrinkViewIng, bfNormal+bfgrabfocus,hcDrinkViewIng);

 {load current drink}
 load_drink(Fload,global_drink,currd);

 {transfer drink record to dialog record}
 Transfer_Drink(EditDrink,Global_Drink,false);

 {set dialog data}
 dia^.SetData(EditDrink);

 {set the currently selected button to the OK button.
  there *must be a better solution*}
 for i:=1 to 3 do begin
  dia^.SelectNext(true);
 end;

 {execute dialog}
 DeskTop^.ExecView(Dia);

 {dispose dialog}
 Dispose(Dia, Done);

End; {Drink Editor *end*}

Procedure Monster_Editor;
Var
  R  : TRect;
  Dia : MonsterDialogp;

  x1,y1,x2,y2,t,i : byte;
  s : string[20];
  items : PSitem;

  w,hint : byte;

Begin

 assign(monsterfile,monfile);

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 {Dialog Title}
 s:='Monster Editor';

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}

 {Init}
 dia:=New(MonsterDialogP, Init(R,s));

 {Options}
 dia^.Options := dia^.Options or ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Monster  ',30,30,      hcMeditMonster);

 {HPS}
 dia^.ValEntry(1,03,'Hitpoints',10,0,200000,hcMeditHitpoints);

 {PHRASE}
 dia^.TxtEntry(1,04,'Phrase   ',70,40,      hcMeditPhrase);

 {MAGICRES}
 dia^.ValEntry(1,05,'Magic Res',10,0,100,   hcMeditMagicRes);

 {MAGICLEVEL}
 dia^.ValEntry(1,06,'Magic Lev',10,0,100,   hcMeditMagicLev);

 {STRENGTH}
 dia^.ValEntry(1,07,'Strength ',10,0,32000, hcMeditStrength);

 {DEFENCE}
 dia^.ValEntry(1,08,'Defence  ',10,0,32000, hcMeditDefence);

 {IQ}
 dia^.ValEntry(1,09,'IQ       ',10,1,100,   hcMeditIQ);

 {EVIL}
 dia^.ValEntry(1,10,'Evil     ',10,0,10,    hcMeditEvil);

 {WEAPON & ARMOR}
 dia^.MakeButton(2,12,10,'~W~eapon',cmMWeapSel,bfNormal+bfgrabfocus,hcMeditWeapon);
 dia^.MakeButton(2,14,10,'~A~rmor',cmMArmSel,bfNormal+bfgrabfocus,hcMeditArmor);

 {GRAB WEAPON}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Allow Player to take Weapon',true,false,1,16,37,1,items,hcMeditGrabWeapon);

 {GRAB ARMOR}
 items:=NewsItem('Yes',
         NewsItem('No',nil));
 dia^.RadioButtons('Allow Player to take Armor',true,false,1,17,37,1,items,hcMeditGrabArmor);

 {SPELLS}
 dia^.Static(51,02,'Spells');
 t:=3;
 w:=15;

 for i:=1 to maxmspells do begin
  dia^.CheckBoxes('',50,t,w,9,NewsItem(monster_spell(i),nil),false,spell_hint(i)); {if true then shadowed spell}
  inc(t);
 end;

 {BUTTONS}
 t:=1;
 dia^.MakeButton(t+00,y2-3,10,'~O~k',       cmOk,      bfNormal+bfgrabfocus,hcGenOk);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious', cmPPrev,   bfNormal+bfgrabfocus,hcGenPrevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',     cmPNext,   bfNormal+bfgrabfocus,hcGenNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',   cmPSearch, bfNormal+bfgrabfocus,hcMeditSearch);
 dia^.MakeButton(t+40,y2-3,10,'~G~oto',     cmMGoto,   bfNormal+bfgrabfocus,hcMeditGoto);
 dia^.MakeButton(t+50,y2-3,10,'G~l~obal',   cmMGlobal, bfNormal+bfgrabfocus,hcMeditGlobal);
 dia^.MakeButton(t+60,y2-3,10,'~H~elp',     cmHelp,    bfNormal+bfgrabfocus,hcMonsterEditor);

 {set the currently selected button to the OK button
  *there must be a better solution*}
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);

 {load current monster}
 load_monster(Fload,monster,currm);

 {transfer monster record to dialog record}
 Transfer_Monster(EdMonster,Monster,false);

 {update dialog with dialog record info}
 dia^.SetData(EdMonster);

 {Execute Dialog}
 DeskTop^.ExecView(DIA);

 {Dispose Dialog}
 Dispose(DIA, Done);

End; {monster_editor *end*}

Procedure Item_Editor;
Var
  R   : TRect;
  Dia : ItemEditDialogP; {Item Editor Dialog}

  x1,y1,x2,y2,t,i : byte;
  s : string[20];
  items : psitem;

Begin

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 {Title}
 s:='Item Editor';

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}

 {Init}
 Dia:=New(ItemEditDialogP, Init(R,s));

 {Options}
 dia^.Options := dia^.Options + ofCentered;

 {NAME}
 dia^.TxtEntry(1,02,'Item  ',70,35,hcItemName);

 {GOLD VALUE}
 dia^.ValEntry(1,03,'Value ',14,0,2000000000,hcItemValue);

 {Attack Value}
 dia^.ValEntry(1,04,'Attack',9,-32000,32000,hcItemAttack);

 {Armor Value}
 dia^.ValEntry(1,05,'Armor ',9,-32000,32000,hcItemArmor);


 {DESCRIPTION}
 for i:=1 to 5 do begin
  dia^.TxtEntry(1,06+i,'Desc  ',70,30,hcItemDesc1);
 end;

 {HIDDEN DESCRIPTION}
 dia^.Static(10,13,'Hidden Description');
 for i:=1 to 5 do begin
  dia^.TxtEntry(1,13+i,'Desc  ',70,30,hcItemDesc2);
 end;

 {IN STORE}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Available in Store',true,false,41,2,14,2,items,hcItemStore);

 {FOUND IN DUNGEONS}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Found in Dungeons',true,false,42,3,14,2,items,hcItemFound);

 dia^.Static(50,4,'At level');
 dia^.Static(67,4,'to');

 {Min level}
 dia^.ValEntry(58,4,'',5,1,100,hcItemAtlevel1);

 {Max level}
 dia^.ValEntry(69,4,'',5,1,100,hcItemAtlevel2);

 t:=56;
 {HPS}
 dia^.ValEntry(t,05,'HitPoints',9,-32000,32000,hcItemHps);

 {Stamina}
 dia^.ValEntry(t+2,06,'Stamina',9,-32000,32000,hcItemStamina);

 {Agility}
 dia^.ValEntry(t+2,07,'Agility',9,-32000,32000,hcItemAgility);

 {Charisma}
 dia^.ValEntry(t+1,08,'Charisma',9,-32000,32000,hcItemCharisma);

 {Dexterity}
 dia^.ValEntry(t,09,'Dexterity',9,-32000,32000,hcItemDexterity);

 {Wisdom}
 dia^.ValEntry(t+3,10,'Wisdom',9,-32000,32000,hcItemWisdom);

 {Mana}
 dia^.ValEntry(t+5,11,'Mana',9,-32000,32000,hcItemMana);

 {Strength}
 dia^.ValEntry(t+1,12,'Strength',9,-32000,32000,hcItemStrength);

 {Defence}
 dia^.ValEntry(t+2,13,'Defence',9,-32000,32000,hcItemDefence);

 {Strength Needed}
 dia^.ValEntry(t-6,14,'Strength Needed',9,-32000,32000,hcItemStrNeed);


 {CURE}
 items:=NewsItem('Nothing',
        NewsItem('All',
        NewsItem('Blindness',
        NewsItem('Plague',
        NewsItem('SmallPox',
        NewsItem('Measles',
        NewsItem('Leprosy', nil)))))));
 dia^.RadioButtons('Can Cure',false,true,40,5,12,7,items,hcItemCure1);

 {Good}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Good',true,false,54,16,12,2,items,hcItemGood1);

 {Evil}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Evil',true,false,54,17,12,2,items,hcItemEvil1);

 {Cursed}
 items:=NewsItem('Yes',
        NewsItem('No',nil));
 dia^.RadioButtons('Cursed',true,false,52,18,12,2,items,hcItemCursed1);


 {BUTTONS}
 t:=1;

 {restrict}
 dia^.MakeButton(t+37,y2-6,12,'~R~estrict', cmRestrict, bfNormal+bfgrabfocus,hcItemRestrict);

 dia^.MakeButton(t+00,y2-3,10,'~O~k',       cmOk,      bfNormal+bfgrabfocus,hcGenOk);
 dia^.MakeButton(t+10,y2-3,12,'~P~revious', cmPPrev,   bfNormal+bfgrabfocus,hcGenPrevious);
 dia^.MakeButton(t+22,y2-3,08,'~N~ext',     cmPNext,   bfNormal+bfgrabfocus,hcGenNext);
 dia^.MakeButton(t+30,y2-3,10,'~S~earch',   cmPSearch, bfNormal+bfgrabfocus,hcItemSearch);
 dia^.MakeButton(t+40,y2-3,10,'~C~reate',   cmPCreate, bfNormal+bfgrabfocus,hcItemCreate);
 dia^.MakeButton(t+50,y2-3,13,'~I~tem Type',cmIType, bfNormal+bfgrabfocus,hcItemType);
 dia^.MakeButton(t+63,y2-3,11,'Op~t~ions',  cmIOptions, bfNormal+bfgrabfocus,hcItemOptions);

 {set the currently selected button to the OK button
  *there must be a better solution*}
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);
 dia^.SelectNext(true);

 {Transfer item}
 Transfer_Item(EdItem,dia^.item,false);

 {Set dialog data}
 dia^.SetData(EdItem);

 {Execute Dialog}
 DeskTop^.ExecView(DIA);

 {Dispose Dialog}
 Dispose(DIA, Done);

End; {item_editor *end*}

Procedure Edit_Level(nr : integer);
Var
   R   : Trect;
   Dia : XDialogP;

   C,rad, minl   : Word;

   S : ^String;

   out : longint;

   x1,y1,x2,y2,
   err : integer;
Begin

 new(s);
 s^:='';

 {rad sets number of rows of help text in dialog}
 rad:=1;
 minl:=55;

 R.Assign(7,4,minl+2,rad+12);

 str(nr,s^);
 Dia := New(XDialogP, Init(R, 'Level #'+s^));
 With Dia^ Do Begin
  {Options := Options or ofCentered;}

  x1:=02;
  y1:=02;
  x2:=minl-7;
  y2:=03;

  {Help Text Rows}
  Static(x1,y1,'Experience Needed to advance to Level '+s^);

  inc(y1,2);
  inc(y2,2);

  {inputline}
  TxtEntry(1,y1,'',70,minl-10,hcLevEdExpNeed);

  {default value}
  load_level(Fload,level,nr);
  s^:=commastr(level.xpneed);
  remove_commas(s^);

  inc(y1,2);
  inc(y2,2);

  inc(y2);

  {Buttons}
  OkButton(2,y1);
  CancelButton(15,y1);

  Dia^.SelectNext(true);
  Dia^.SelectNext(true);

 end;

 {Options}
 Dia^.Options := Dia^.Options + ofCentered;

 C:=MyApp.ExecuteDialog(Dia,S);

 if C <> cmCancel then Begin
  {update with new data}

  val(s^,out,err);
  if err=0 then begin
   if (out>0) and (out<=2000000000) then begin
    if level.xpneed<>out then begin
     level.xpneed:=out;
     load_level(Fsave,level,nr);

     case nr of
      0..9   :s^:=commastr(nr)+'  ';
      10..99 :s^:=commastr(nr)+' ';
      else    s^:=commastr(nr);
     end;
     s^:='Level '+s^+' : '+commastr(level.xpneed);

     NameList^.FreeItem(namelist^.at(nr-1));
     NameList^.ATPut(nr-1,newstr(s^));
    end;
   end;
  end;

 End;

 dispose(s);

End; {edit_level *end*}

Procedure Player_Page2; {Player/Npc Editor page 2}
Var

  R   : TRect;
  Dia : page2dialogp; {Dialog}

  x1,y1,x2,y2,w,y22,t,

  i,
  diff : byte;

  s : s70;

  items : psitem;

  shadow : boolean;

Begin

 {dialog title}
 s:='Editing '+player.name2;

 {dialog coordinates}
 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;
 y22:=y2;

 {Assign}
 R.Assign(x1,y1,x2,y2); {x/y start for config box}

 {Init}
 Dia:=New(Page2DialogP, Init(R,s) );

 {Options}
 dia^.Options := dia^.Options + ofCentered;

 {Spells}
 s:='Spells';
 case player.class of
  Magician: s:='Magician '+s;
  Sage    : s:='Sage '+s;
  Cleric  : s:='Cleric '+s;
 end;
 dia^.static(7,1,s);

 t:=2;
 w:=17;

 {we shadow the spell boxes if player is not a magic user}
 if player.class in [Sage,Cleric,Magician] then shadow:=false
                                           else shadow:=true;

 {setup checkboxes for the spells}
 for i:=1 to maxspells do begin
  Items:=NewsItem(spell_name(i,player.class),nil);
  dia^.CheckBoxes('',2,t,w,1,items,shadow,spell_hintply(i,player.class));
  inc(t);
 end;

{ Items:=NewsItem(spell_name(1,player.class),
        NewsItem(spell_name(2,player.class),
        NewsItem(spell_name(3,player.class),
        NewsItem(spell_name(4,player.class),
        NewsItem(spell_name(5,player.class),
        NewsItem(spell_name(6,player.class),
        NewsItem(spell_name(7,player.class),
        NewsItem(spell_name(8,player.class),
        NewsItem(spell_name(9,player.class),
        NewsItem(spell_name(10,player.class),
        NewsItem(spell_name(11,player.class),
        NewsItem(spell_name(12,player.class),
        nil))))))))))));

 pe^.CheckBoxes(s,2,2,w,12,items,shadow,spell_hintply(1,player.class));
}

 {Player Description}
 w:=45;
 dia^.TxtEntry(1,15,'Desc1',70,w,hcPeditDesc);
 dia^.TxtEntry(1,16,'Desc2',70,w,hcPeditDesc);
 dia^.TxtEntry(1,17,'Desc3',70,w,hcPeditDesc);
 dia^.TxtEntry(1,18,'Desc4',70,w,hcPeditDesc);

 {Never delete Character}
 items:=NewsItem('Never Delete Character',nil);
 dia^.CheckBoxes('',28,2,25,1,items,false,hcPeditNeverDel);

 {Diseases}
 t:=4;  {y start-coord}
 x1:=28;{x start-coord}
 dia^.static(x1+1,t,'Diseases');
 w:=13;
 dia^.CheckBoxes('',x1,t+1,w,1,NewsItem('Blindness',nil),false,hcPeditDis1);
 dia^.CheckBoxes('',x1,t+2,w,1,NewsItem('Plague',nil),false,   hcPeditDis2);
 dia^.CheckBoxes('',x1,t+3,w,1,NewsItem('SmallPox',nil),false, hcPeditDis3);
 dia^.CheckBoxes('',x1,t+4,w,1,NewsItem('Measles',nil),false,  hcPeditDis4);
 dia^.CheckBoxes('',x1,t+5,w,1,NewsItem('Leprosy',nil),false,  hcPeditDis5);

 {maxtime (time left today, in minutes) }
 dia^.static(x1+1,t+7,'Time Left Today');
 dia^.ValEntry(x1-1,t+8,'',7,0,999,hcPeditMaxTime);

 {Close Combat Skills}
 dia^.static(58,1,'Close Combat Skills');
 y2:=2;
 for i:=1 to maxcombskills do begin
  s:=bash_name(i);
  x1:=63;
  if length(s)>6 then begin
   diff:=length(s)-6;
   dec(x1,diff);
  end
  else if length(s)<6 then begin
   diff:=6-length(s);
   inc(x1,diff);
  end;
  dia^.ValEntry(x1,y2,s,7,0,17,combat_hint(i));
  inc(y2);
 end; {for i:= .end.}

 {insert player stats}
 inc(y2,2);
 dia^.ValEntry(54,y2,  '  Monster Kills',7,0,2000000000,hcPeditMkills);
 dia^.ValEntry(54,y2+1,'Monster Defeats',7,0,2000000000,hcPeditMDefeats);
 dia^.ValEntry(54,y2+2,'   Player Kills',7,0,2000000000,hcPeditPKills);
 dia^.ValEntry(54,y2+3,' Player Defeats',7,0,2000000000,hcPeditPDefeats);

 {Buttons}
 dia^.MakeButton(4,y22-3,10,'~O~k', cmOk, bfNormal+bfgrabfocus,hcGenOk);
 dia^.MakeButton(15,y22-3,15,'~P~hrases', cmPhrases, bfNormal+bfgrabfocus,hcPeditPhrases);

 {set the currently selected button to the OK button *must be a better solution*}
 dia^.SelectNext(true);

 {Transfer player data to dialog record}
 Transfer2(EdGuy2,Player,false);

 {set dialog with record structure}
 dia^.SetData(EdGuy2);

 {Execute Dialog}
 DeskTop^.ExecView(DIA);

 {Dispose Dialog}
 Dispose(DIA, Done);

End; {player_page2 *end*}

Procedure Level_Editor;
Var
  R    : TRect;
  pBor : ^TScrollBar;
  Dia  : LevelDialogP;
  x1,y1,x2,y2 : byte;

Begin

  x1:=2;
  y1:=1;
  x2:=40;
  y2:=20;

  R.Assign(x1,y1,x2,y2); {x/y start for config box}
  Dia := New(LevelDialogP, Init(R, 'Level Editor'));
  Dia^.Options := Dia^.Options or ofCentered;

  Dia^.OkButton(3,16);
  Dia^.CAncelButton(15,16);

  R.Assign(35, 1, 36, 15);
  PBor:= New(Pscrollbar, Init(R));

  R.Assign(2, 1, 35, 15);
  LevList:=New(LevelListboxP, Init(R,1,PBor));

  LevList^.Process;
  LevList^.Newlist(Namelist);
  LevList^.Helpctx:=hcLevEdExpNeed;

  Dia^.Insert(PBor);
  Dia^.Insert(LevList);

  MyApp.ExecuteDialog(Dia,Nil);

End; {level_editor *end*}

Function Drink_Ingredient(nr:byte) : s15;
const
 {Ingredients to use when mixing your own drinks}
 {notice that these names are also used in the main program(usurper.pas)!}
 ing : array [1..Global_Max_Drink_Ingredients] of string[15] =(
             'Bat Brain      ',
             'Honeydew       ',
             'Orange Juice   ',
             'Tabasco        ',
             'Ale            ',
             'Hedgehog Saliva',
             'Water          ',
             'Horse Blood    ',
             'Bobs Bomber    ',
             'Troll Rum      ',
             'Elf Water      ',
             'Kicking Squaw  ',
             'Milk           ',
             'Wine-vinegar   ',
             'Snake Spit     ',
             'Duck Dropping  ',
             'Chilipeppar    ');
begin

 {return result}
 drink_ingredient:=ing[nr];

end; {drink_ingredient *end*}

end. {UNIT *END*}
