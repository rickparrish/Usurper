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



Procedure Save_Config;
var i : Integer;
    txt : text;
begin

 assign(txt,ucfg);
 rewrite(txt);

 for i:=1 to maxcdef do begin
  writeln(txt,cfgvalue[i]);
 end;

 writeln(txt,' ');
 writeln(txt,'* Line 1  => Sysops name');
 writeln(txt,'* Line 2  => BBS name');
 writeln(txt,'* Line 3  => Path to Dropfile');
 writeln(txt,'* Line 4  => Name of Dropfile (DORINFO1.DEF or DOOR.SYS)');
 writeln(txt,'* Line 5  => Registration Number (0 if unregistered)');
 writeln(txt,'* Line 6  => Daily Number of Dungeonfights (5-99)');
 writeln(txt,'* Line 7  => Days of inactivity before deletion (15-999)');
 writeln(txt,'* Line 8  => NonPlayerCharacters vicious tendencies :');
 writeln(txt,'	        0=Passive, 1=Random, 2=Annoying, 3=Persecution');
 writeln(txt,'* Line 9  => Name of Town (max 40 characters)');
 writeln(txt,'* Line 10 => Dungeon difficulty (1-10)  10 is the toughest');
 writeln(txt,'* Line 11 => Display INTRO-menu? (Yes/No)');
 writeln(txt,'* Line 12 => Game-mode (Normal/Soft)  "Soft" replaces whorehouse,');
 writeln(txt,'             drugs and steriods with more conventional options.');
 writeln(txt,'* Line 13 => Daily Number of Teamfights per player (1-99)');
 writeln(txt,'* Line 14 => Amount of money for new players (100-150000)');
 writeln(txt,'* Line 15 => Name of Weaponshop owner (Tully)    [max 20 characters]');
 writeln(txt,'* Line 16 => Name of Armorshop owner (Reese)     [max 20 characters]');
 writeln(txt,'* Line 17 => Name of Combat Trainer (Liu Zei)    [max 20 characters]');
 writeln(txt,'* Line 18 => Name of Magicshop owner (Ravanella) [max 20 characters]');
 writeln(txt,'* Line 19 => Name of Bank manager (Lobba)        [max 20 characters]');
 writeln(txt,'* Line 20 => Name of Inn owner (Garth)           [max 20 characters]');
 writeln(txt,'* Line 21 => Name of Mad & Evil Mage (Groggo)    [max 20 characters]');
 writeln(txt,'* Line 22 => Quaffing Healing Potions in the Dungeons :');
 writeln(txt,'              1 : Player quaffs potions and then autoattacks monster.');
 writeln(txt,'              2 : Player quaffs potions, and then the monster gets a');
 writeln(txt,'                  free attack round.');
 writeln(txt,'              3 : Player quaffs potions and can then choose another option.');
 writeln(txt,'* Line 23 => Display monster comments (Y/N)');
 writeln(txt,'* Line 24-33 => How many % of his experience shall a player lose when dying');
 writeln(txt,'               in the dungeons (0-25). Example :');
 writeln(txt,' Line [24] : 0        (Players at level 1 -10 lose 0% of their xp)');
 writeln(txt,' Line [25] : 2        (Players at level 11-20 lose 2% of their xp)');
 writeln(txt,' Line [26] : 2        (Players at level 21-30 lose 2% of their xp)');
 writeln(txt,' Line [27] : 2        (Players at level 31-40 lose 2% of their xp)');
 writeln(txt,' Line [28] : 3        (Players at level 41-50 lose 3% of their xp)');
 writeln(txt,' Line [29] : 3        (Players at level 51-60 lose 3% of their xp)');
 writeln(txt,' Line [30] : 3        (Players at level 61-70 lose 3% of their xp)');
 writeln(txt,' Line [31] : 4        (Players at level 71-80 lose 4% of their xp)');
 writeln(txt,' Line [32] : 4        (Players at level 81-90 lose 4% of their xp)');
 writeln(txt,' Line [33] : 4        (Players at level 91-100 lose 4% of their xp)');
 writeln(txt,' ');
 writeln(txt,'* Line 34 => Allow players in who have been killed offline (Yes/No)');
 writeln(txt,'* Line 35 => Allow players to attack their teammates (Yes/No)');
 writeln(txt,'* Line 36 => Allow players to resurrect teammates (Yes/No)');
 writeln(txt,'* Line 37 => Maximum level difference for players to attack each other. (0-25)');
 writeln(txt,'             (Example : a value of 5 would mean that a level 10 character');
 writeln(txt,'              only can attack players with a level of 5 and up...');
 writeln(txt,'              a value of 0 means that there are NO LIMITS!)');
 writeln(txt,'* Line 38 => The armor basevalue can now be set freely ( 0-60 % ). A value of');
 writeln(txt,'             10 means that all armors absorb 10% of their armorvalues as base');
 writeln(txt,'             value. The higher you set this figure, the more effective the');
 writeln(txt,'             armors get  (default is 25%).');
 writeln(txt,'* Line 39 => Make NPC characters available in the Dormitory (thus increasing');
 writeln(txt,'             the number of opponents available to players) (Yes/No).');
 writeln(txt,'* Line 40 => Number of Player Fights allowed (1-99).');
 writeln(txt,'* Line 41 => Bank interest (1-15 %)');
 writeln(txt,'* Line 42 => Allow NPC:s to create their own teams (Yes/No)');
 writeln(txt,'* Line 43 => Name of Dungeon Complex 	(Moria, Disney Land....it'+chr(39)+'s up to you)');
 writeln(txt,'* Line 44 => Include NPC:s level raises in the Daily news? (Yes/No)');
 writeln(txt,'* Line 45 => Allow NPC:s to buy new Weapons/Armors for themselves? (Yes/No)');
 writeln(txt,'* Line 46 => Include NPC weapon/armor purchases in the daily news (Yes/No)');
 writeln(txt,'* Line 47 => Allow Teams to fight in the Dungeons (Yes/No)');
 writeln(txt,'* Line 48 => Difficulty for Teams fighting in the dungeons (1-20) 1=easy');
 writeln(txt,'* Line 49 => Maximum numbers of Healing potions a player can carry (1-9999)');
 writeln(txt,'* Line 50 => Maximum number of players allowed in the game (1-255)');
 writeln(txt,'* Line 51 => Allow player to be on more than 1 node simultaneously ? ([Yes]/No)');
 writeln(txt,'* Line 52 => Cost for identification of an Item in Magic Shop (1-9999999)');
 writeln(txt,'* Line 53 => Allow Victor to take defeated players In Hand Eq.    (Yes/No)');
 writeln(txt,'* Line 54 => Allow Victor to take defeated players Head Eq.       (yes/No)');
 writeln(txt,'* Line 55 => Allow Victor to take defeated players Body Eq.       (yes/No)');
 writeln(txt,'* Line 56 => Allow Victor to take defeated players Arm Eq.        (yes/No)');
 writeln(txt,'* Line 57 => Allow Victor to take defeated players Fingers Eq.    (yes/No)');
 writeln(txt,'* Line 58 => Allow Victor to take defeated players Legs Eq.       (yes/No)');
 writeln(txt,'* Line 59 => Allow Victor to take defeated players Feet Eq.       (yes/No)');
 writeln(txt,'* Line 60 => Allow Victor to take defeated players Waist Eq.      (yes/No)');
 writeln(txt,'* Line 61 => Allow Victor to take defeated players Neck Eq.       (yes/No)');
 writeln(txt,'* Line 62 => Allow Victor to take defeated players Face Eq.       (yes/No)');
 writeln(txt,'* Line 63 => Allow Victor to take defeated players Shield         (yes/No)');
 writeln(txt,'* Line 64 => Allow Victor to take defeated players On Hands Eq.   (yes/No)');
 writeln(txt,'* Line 65 => Allow Victor to take defeated players Around Body Eq (yes/No)');
 writeln(txt,'* Line 66 => Allow Victor to take defeated players Inventory Eq.  (yes/No)');
 writeln(txt,'* Line 67 => Automatic Maintenance? (YES/no)');
 writeln(txt,'* Line 68 => Resurrect Dead Players at maintenance? (yes/NO)');
 writeln(txt,'* Line 69 => Credits to user(s) helping out registering Usurper');
 writeln(txt,'* Line 70 => Path and name of ANSI  score file (none is created if left blank)');
 writeln(txt,'* Line 71 => Path and name of ASCII score file (none is created if left blank)');
 writeln(txt,'* Line 72 => Path and name of ANSI  Team score file');
 writeln(txt,'* Line 73 => Path and name of ASCII Team score file');
 writeln(txt,'* Line 74 => Path and name of ANSI  Weapon score file');
 writeln(txt,'* Line 75 => Path and name of ASCII Weapon score file');
 writeln(txt,'* Line 76 => Path and name of ANSI  Armor score file');
 writeln(txt,'* Line 77 => Path and name of ASCII Armor score file');
 writeln(txt,'* Line 78 => Path and name of ANSI  Equipment score file');
 writeln(txt,'* Line 79 => Path and name of ASCII Equipment score file');
 writeln(txt,'* Line 80 => Path and name of ANSI  "Player Killers" score file');
 writeln(txt,'* Line 81 => Path and name of ASCII "Player Killers" score file');
 writeln(txt,'* Line 82 => Path and name of ANSI  "Monster Killers" score file');
 writeln(txt,'* Line 83 => Path and name of ASCII "Monster Killers" score file');
 writeln(txt,'* Line 84 => Create defined score files upon exit of Usurper (YES/no)');
 writeln(txt,'* Line 85 => Allow losers from Beer Drinking Competition to play again (YES/no)');
 writeln(txt,'* Line 86 => Allow losers from Brawls to play again (YES/no)');
 writeln(txt,'* Line 87 => Time Limit for players every day (1-9999, 0=time is read from dropfile)');
 writeln(txt,'* Line 88 => NPC players buying strategy. 1-5 (1=sloppy...5=very carefully).');
 writeln(txt,'             A higher value gives you longer maintenance sessions.');
 writeln(txt,'             (The Non Player Characters are buying new equipment)');
 writeln(txt,'* Line 89 => City Reward. The sum of money a gang gets for controlling');
 writeln(txt,'             the town. Default value is 5,000.');
 writeln(txt,'             Example :');
 writeln(txt,'             Bill (level 10 warrior) and Bull (level 3 cleric) holds');
 writeln(txt,'             the city. With the default value of 5,000 gold coins the');
 writeln(txt,'             sum to share would be :');
 writeln(txt,'             (10 * 5,000) + (3 * 5,000) = 65,000');
 writeln(txt,'             ------------------------------------');
 writeln(txt,'             The sum is then split equally between the two members.');
 writeln(txt,'             Giving them 32,500 gold coins each.');
 writeln(txt,'* Line 90 => Shall players lose experience points (XP) after losing a');
 writeln(txt,'             player versus player fight? :');
 writeln(txt,'              0 = No  (default)');
 writeln(txt,'              1 = Yes (both offline and online players)');
 writeln(txt,'              2 = Yes (but only online players)');
 writeln(txt,'              3 = Yes (but only offline players)');
 writeln(txt,'            If you set this option to 1,2 or 3 then the same values are used');
 writeln(txt,'            as in the dying in the dungeons options (line 24-33).');
 writeln(txt,'* Line 91 => Game mode : OLD or NEW');
 writeln(txt,'             OLD gives the player only one weapon and one armor.');
 writeln(txt,'             NEW gives the player the choice of different kinds of armor');
 writeln(txt,'             (leg, head, feet, body...etc etc).');
 writeln(txt,'             This switch can be toggled in the middle of a game. But it is');
 writeln(txt,'             not recommended.');
 writeln(txt,'* Line 92 => Allow players killed in online battles to play more that day?');
 writeln(txt,'             ([Yes]/No)');
 writeln(txt,'* Line 93 => Include NonPlayerCharacters (NPCs) in external score files?');
 writeln(txt,'             ([Yes]/No)');
 writeln(txt,'* Line 94 => Allow Computer Controlled teams to attack other gangs?');
 writeln(txt,'             ([Yes]/No)');
 writeln(txt,'* Line 95 => Maximum level superiority for attacking gang. (1-5000)');
 writeln(txt,'* Line 96 => Allow fake players to enter game (YES/no)');
 writeln(txt,'* Line 97 => Use Filelocking? ([Yes]/No)');
 writeln(txt,'* Line 98 => Check other node interaction how often? (every x second) :');
 writeln(txt,'             (enter a value between 4..25, default is 5)');
 writeln(txt,'* Line 99 => Semaphore path. Important for multiline BBS.');
 writeln(txt,'             This field specifies the directory where temporary and');
 writeln(txt,'             static files used for multi-node operations are stored.  A');
 writeln(txt,'             RAM disk is highly recommended.');
 writeln(txt,'             The directory specified here should be the drive and path to');
 writeln(txt,'	        a directory on a disk (preferably a RAM disk).');
 writeln(txt,'             If you leave this field blank the semaphore files will be');
 writeln(txt,'             created in the Usurper directory.');
 writeln(txt,'* Line 100 => Allow "one man teams" to attack other teams (default YES)');

 close(txt);

 if announce then begin
  messagebox(#3'Config Saved.',nil,mfOkbutton+mfInformation);
 end;

end;

Procedure Load_Player(   action : char;
                      var gubbe : userrec;
                             gr : longint);
var
    memmy : integer;
    i : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;

  {case allmodd of
   1: assign(playerfile,pfile);
   2: assign(playerfile,npfile);
  end;}

  case action of
   'L': FileMode:=fmReadOnly+fmDenyNone;
   'S': FileMode:=fmReadWrite+fmDenyAll;
  end;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(playerfile);{$I+}

  if IOResult<>0 then begin
   delay(lockdelay);
   ok:=false;
   inc(i);
  end;

 until (Ok) or (i>20);

 seek(playerfile,gr-1);
 case action of
  'L': Read (playerfile,gubbe);
  'S': Write(playerfile,gubbe);
 end;
 close(playerfile);
 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Load_Guard(    action : char;
                      var grd   : guardrec;
                             gr : longint);
var
    memmy : integer;
    i : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;

  case action of
   'L': FileMode:=fmReadOnly+fmDenyNone;
   'S': FileMode:=fmReadWrite+fmDenyAll;
  end;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(guardfile);{$I+}

  if IOResult<>0 then begin
   delay(lockdelay);
   ok:=false;
   inc(i);
  end;

 until (Ok) or (i>20);

 seek(guardfile,gr-1);
 case action of
  'L': Read (guardfile,grd);
  'S': Write(guardfile,grd);
 end;
 close(guardfile);
 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Load_Level(  action : char;
                      var lev : levelrec;
                           gr : longint);
var
    memmy : integer;
    i : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;

  case action of
   'L': FileMode:=fmReadOnly+fmDenyNone;
   'S': FileMode:=fmReadWrite+fmDenyAll;
  end;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(levelfile);{$I+}

  if IOResult<>0 then begin
   delay(lockdelay);
   ok:=false;
   inc(i);
  end;

 until (Ok) or (i>20);

 seek(levelfile,gr-1);
 case action of
  'L': Read (levelfile,lev);
  'S': Write(levelfile,lev);
 end;
 close(levelfile);
 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Load_Monster(  action : char;
                      var mony  : monsterrec;
                           gr   : longint);
var
    memmy : integer;
    i : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;

  case action of
   'L': FileMode:=fmReadOnly+fmDenyNone;
   'S': FileMode:=fmReadWrite+fmDenyAll;
  end;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(monsterfile);{$I+}

  if IOResult<>0 then begin
   delay(lockdelay);
   ok:=false;
   inc(i);
  end;

 until (Ok) or (i>20);

 seek(monsterfile,gr-1);
 case action of
  'L': Read (monsterfile,mony);
  'S': Write(monsterfile,mony);
 end;
 close(monsterfile);
 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Load_Weapon( nr        : word;
                      var inweap : weaprec );

var i,
    memmy : integer;
    ok : boolean;
begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;
  assign(weapfile,weapofile);

  FileMode:=fmReadOnly+fmDenyNone;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(weapfile);{$I+}

  if IOResult<>0 then begin
   delay2(lockdelay);
   ok:=false;
   inc(i);
  end;
 until (Ok) or (i>locknrs);

 Seek(weapfile,nr-1);
 Read(weapfile,inweap);
 close(weapfile);

 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Load_Armor( nr        : word;
                      var inarm : armrec );

var i,
    memmy : integer;
    ok : boolean;

begin

 i:=0;
 memmy:=filemode;

 repeat
  ok:=true;
  assign(armfile,armofile);
  FileMode:=fmReadOnly+fmDenyNone;
{$IFDEF WINDOWS}
  FileModeReadWrite := FileMode;
{$ENDIF}
  {$I-}reset(armfile);{$I+}

  if IOResult<>0 then begin
   delay2(lockdelay);
   ok:=false;
   inc(i);
  end;
 until (Ok) or (i>locknrs);

 Seek(armfile,nr-1);
 Read(armfile,inarm);
 close(armfile);

 filemode:=memmy;
{$IFDEF WINDOWS}
 FileModeReadWrite := FileMode;
{$ENDIF}
end;

Procedure Item_Info(item : objektrec);
begin
 messagebox(item.name,nil,mfOkbutton+mfinformation);
end;

Procedure Equipment_Dialog(var gubbe : userrec);
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  pe : EqDialogP;
  bx : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(pe^.ps[nr]^.Text);
 pe^.ps[nr]^.Text := NewStr(s);
 pe^.ps[nr]^.Draw;
end;

Begin

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;


 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 pe:=New(EqDialogP, Init(R,gubbe.name2+'s Equipment'));


 if gubbe.lhand>0 then begin
  objekt_load(objekt,weapon,gubbe.lhand);
  replace(1,objekt.name);
 end;

 if gubbe.rhand>0 then begin
  objekt_load(objekt,weapon,gubbe.rhand);
  replace(2,objekt.name);
 end;

 if gubbe.head>0 then begin
  objekt_load(objekt,head,gubbe.head);
  replace(3,objekt.name);
 end;

 if gubbe.body>0 then begin
  objekt_load(objekt,body,gubbe.body);
  replace(4,objekt.name);
 end;

 if gubbe.arms>0 then begin
  objekt_load(objekt,arms,gubbe.arms);
  replace(5,objekt.name);
 end;

 if gubbe.lfinger>0 then begin
  objekt_load(objekt,fingers,gubbe.lfinger);
  replace(6,objekt.name);
 end;

 if gubbe.rfinger>0 then begin
  objekt_load(objekt,fingers,gubbe.rfinger);
  replace(7,objekt.name);
 end;

 if gubbe.legs>0 then begin
  objekt_load(objekt,legs,gubbe.legs);
  replace(8,objekt.name);
 end;

 if gubbe.feet>0 then begin
  objekt_load(objekt,feet,gubbe.feet);
  replace(9,objekt.name);
 end;

 if gubbe.waist>0 then begin
  objekt_load(objekt,waist,gubbe.waist);
  replace(10,objekt.name);
 end;

 if gubbe.neck>0 then begin
  objekt_load(objekt,neck,gubbe.neck);
  replace(11,objekt.name);
 end;

 if gubbe.neck2>0 then begin
  objekt_load(objekt,neck,gubbe.neck2);
  replace(12,objekt.name);
 end;

 if gubbe.face>0 then begin
  objekt_load(objekt,face,gubbe.face);
  replace(13,objekt.name);
 end;

 if gubbe.shield>0 then begin
  objekt_load(objekt,shield,gubbe.shield);
  replace(14,objekt.name);
 end;

 if gubbe.hands>0 then begin
  objekt_load(objekt,hands,gubbe.hands);
  replace(15,objekt.name);
 end;

 if gubbe.body>0 then begin
  objekt_load(objekt,body,gubbe.body);
  replace(16,objekt.name);
 end;


 {LEFT HAND}
 pe^.MakeButton(2,2,14,'~L~eft Hand',cmPELHAND,bfNormal+bfgrabfocus);

 {RIGHT HAND}
 pe^.MakeButton(2,4,14,'~R~ight Hand',cmPERHAND,bfNormal+bfgrabfocus);

 {HEAD}
 pe^.MakeButton(2,6,14,'~H~ead',cmPEHEAD,bfNormal+bfgrabfocus);

 {BODY}
 pe^.MakeButton(2,8,14,'~B~ody',cmPEBODY,bfNormal+bfgrabfocus);

 {Arms}
 pe^.MakeButton(2,10,14,'~A~rms',cmPEARMS,bfNormal+bfgrabfocus);

 {Lfinger}
 pe^.MakeButton(2,12,14,'~1~ Finger',cmPELFING,bfNormal+bfgrabfocus);

 {Rfinger}
 pe^.MakeButton(2,14,14,'~2~ Finger',cmPERFING,bfNormal+bfgrabfocus);

 {Legs}
 pe^.MakeButton(2,16,14,'L~e~gs',cmPELEGS,bfNormal+bfgrabfocus);


 bx:=41;
 {Feet}
 pe^.MakeButton(bx,2,14,'Fee~t~',cmPEFEET,bfNormal+bfgrabfocus);

 {Waist}
 pe^.MakeButton(bx,4,14,'~W~aist',cmPEWAIST,bfNormal+bfgrabfocus);

 {Neck}
 pe^.MakeButton(bx,6,14,'~N~eck',cmPELNECK,bfNormal+bfgrabfocus);

 {Neck2}
 pe^.MakeButton(bx,8,14,'Nec~k~',cmPERNECK,bfNormal+bfgrabfocus);

 {Face}
 pe^.MakeButton(bx,10,14,'~F~ace',cmPEFACE,bfNormal+bfgrabfocus);

 {Shield}
 pe^.MakeButton(bx,12,14,'~S~hield',cmPESHIELD,bfNormal+bfgrabfocus);

 {Hands}
 pe^.MakeButton(bx,14,14,'Han~d~s',cmPEHANDS,bfNormal+bfgrabfocus);

 {Around body}
 pe^.MakeButton(bx,16,14,'Bod~y~',cmPEABODY,bfNormal+bfgrabfocus);


 {BUTTONS}
 pe^.MakeButton(02,y2-3,10,'~O~k',        cmOk,      bfNormal+bfgrabfocus);
 pe^.MakeButton(13,y2-3,12,'~C~ancel',    cmCancel,  bfNormal+bfgrabfocus);
 pe^.MakeButton(26,y2-3,15,'~I~nventory', cmEqInventory,  bfNormal+bfgrabfocus);
 pe^.MakeButton(42,y2-3,16,'A~u~to Equip',cmEqAutoEquip,  bfNormal+bfgrabfocus);
 pe^.MakeButton(59,y2-3,16,'Re~m~ove All',cmEqRemoveAll,  bfNormal+bfgrabfocus);

 {load_player('L',player,currp);}
 {Transfer(EdGuy,Player,false);

 pe^.SetData(EdGuy);        {Dialog Setdata with Record Structure}
 DeskTop^.ExecView(PE);

End;

Procedure Equipment_Dialog_Classic(var gubbe : userrec);
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  pe : EqClDialogP;
  bx : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(pe^.ps[nr]^.Text);
 pe^.ps[nr]^.Text := NewStr(s);
 pe^.ps[nr]^.Draw;
end;
var cweapon : weaprec;
    carmor  : armrec;
Begin

 x1:=0;
 y1:=0;
 x2:=50;
 y2:=12;


 R.Assign(x1,y1,x2,y2);
 pe:=New(EqClDialogP, Init(R,gubbe.name2+'s Weapon and Armor'));

 pe^.Options := pe^.Options or ofCentered;

 if gubbe.weapon>0 then begin
  load_weapon(gubbe.weapon,cweapon);
  replace(1,cweapon.name);
 end;

 if gubbe.armor>0 then begin
  load_armor(gubbe.armor,carmor);
  replace(2,carmor.name);
 end;

 {WEAPON}
 pe^.MakeButton(2,2,12,'~W~eapon',cmPWeapOld,bfNormal+bfgrabfocus);

 {ARMOR}
 pe^.MakeButton(2,4,12,'~A~rmor',cmPArmOld,bfNormal+bfgrabfocus);


 {BUTTONS}
 pe^.MakeButton(02,y2-3,10,'~O~k',    cmOk,     bfNormal+bfgrabfocus);
 pe^.MakeButton(13,y2-3,12,'~C~ancel',cmCancel, bfNormal+bfgrabfocus);

 DeskTop^.ExecView(PE);

End;

Procedure Manage_Inventory(var gubbe : userrec);
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  i : word;
  pe : InvDialogP;
  bx,bw : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(pe^.ps[nr]^.Text);
 pe^.ps[nr]^.Text := NewStr(s);
 pe^.ps[nr]^.Draw;
end;

Begin

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;


 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 pe:=New(InvDialogP, Init(R,gubbe.name2+'s Inventory'));

 for i:=1 to maxitem do begin
  if gubbe.item[i]>0 then begin
   objekt_load(objekt,gubbe.itemtype[i],gubbe.item[i]);
   replace(i,objekt.name);
  end;
 end;

 bw:=6; {bredd p† knapparna}

 pe^.MakeButton(2,02,bw,'~1~',cmInv01,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,04,bw,'~2~',cmInv02,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,06,bw,'~3~',cmInv03,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,08,bw,'~4~',cmInv04,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,10,bw,'~5~',cmInv05,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,12,bw,'~6~',cmInv06,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,14,bw,'~7~',cmInv07,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,16,bw,'~8~',cmInv08,bfNormal+bfgrabfocus);

 bx:=41;
 pe^.MakeButton(bx,02,bw,'~9~',cmInv09,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,04,bw,'~0~',cmInv10,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,06,bw,'~A~',cmInv11,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,08,bw,'~B~',cmInv12,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,10,bw,'~D~',cmInv13,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,12,bw,'~E~',cmInv14,bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,14,bw,'~F~',cmInv15,bfNormal+bfgrabfocus);


 {BUTTONS}
 pe^.MakeButton(02,y2-3,10,'~O~k',        cmOk,     bfNormal+bfgrabfocus);
 pe^.MakeButton(13,y2-3,12,'~C~ancel',    cmCancel, bfNormal+bfgrabfocus);
 pe^.MakeButton(26,y2-3,16,'~R~emove All',cmInvRemoveAll, bfNormal+bfgrabfocus);

 DeskTop^.ExecView(PE);

End;

Procedure Item_Type_Selector;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  pe : TypSelDialogP;
  bx,bw : byte;
Begin

 x1:=0;
 y1:=0;
 x2:=45;
 y2:=23;

 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 pe:=New(TypSelDialogP, Init(R,'Type of Item'));
 pe^.Options := pe^.Options or ofCentered;


 bw:=14; {bredd p† knapparna}

 pe^.MakeButton(2,02,bw,'~W~eapon',cmSWeap,  bfNormal+bfgrabfocus);
 pe^.MakeButton(2,04,bw,'~S~hield',cmShield,bfNormal+bfgrabfocus);
 pe^.MakeButton(2,06,bw,'~H~ead',  cmSHead,  bfNormal+bfgrabfocus);
 pe^.MakeButton(2,08,bw,'~B~ody',  cmSBody,  bfNormal+bfgrabfocus);
 pe^.MakeButton(2,10,bw,'~A~rms',  cmSArms,  bfNormal+bfgrabfocus);
 pe^.MakeButton(2,12,bw,'~H~ands', cmSHands, bfNormal+bfgrabfocus);
 pe^.MakeButton(2,14,bw,'~F~inger',cmSFing,  bfNormal+bfgrabfocus);
 pe^.MakeButton(2,16,bw,'~L~egs',  cmSLegs,  bfNormal+bfgrabfocus);

 bx:=21;
 pe^.MakeButton(bx,02,bw,'~F~eet', cmSFeet,  bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,04,bw,'~W~aist',cmSWaist, bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,06,bw,'~N~eck', cmSNeck,  bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,08,bw,'~F~ace', cmSFace,  bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,10,bw,'~F~ood', cmSFood,  bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,12,bw,'~D~rink',cmSDrink, bfNormal+bfgrabfocus);
 pe^.MakeButton(bx,14,bw,'~A~round Body',cmSAbody,bfNormal+bfgrabfocus);


 DeskTop^.ExecView(PE);


End;
