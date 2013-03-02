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


Procedure Count_Objects; {caluclates total object to be used in status bat}
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

end;

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

end;

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

end;

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

end;

Procedure Rewrite_Datfiles( force : boolean );
begin
 if (NOT exist(objf1)) or (force) then begin
  assign(ofil,objf1);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf2) or (force) then begin
  assign(ofil,objf2);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf3) or (force) then begin
  assign(ofil,objf3);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf4) or (force) then begin
  assign(ofil,objf4);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf5) or (force) then begin
  assign(ofil,objf5);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf6) or (force) then begin
  assign(ofil,objf6);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf7) or (force) then begin
  assign(ofil,objf7);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf8) or (force) then begin
  assign(ofil,objf8);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf9) or (force) then begin
  assign(ofil,objf9);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf10) or (force) then begin
  assign(ofil,objf10);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf11) or (force) then begin
  assign(ofil,objf11);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf12) or (force) then begin
  assign(ofil,objf12);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf13) or (force) then begin
  assign(ofil,objf13);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf14) or (force) then begin
  assign(ofil,objf14);
  rewrite(ofil);
  close(ofil);
 end;
 if NOT exist(objf15) or (force) then begin
  assign(ofil,objf15);
  rewrite(ofil);
  close(ofil);
 end;

end;

Function Ur_Change : boolean;
var b : boolean;
    i : integer;
begin
 b:=false;
 for i:=1 to maxcdef do begin
  if cfgurb[i]<>cfgvalue[i] then begin
   b:=true;
   break;
  end;
 end;
 ur_change:=b;
end;

Function Save_Request : boolean;
var r : integer;
    b : boolean;
begin

 b:=true;

 if ur_change then begin

  r:=messagebox(
     #13 +
     ^C'Save Changes Before Exit?'#13 +
     #13 +
     ^C' '#13 +
     #13 +
     ^C' ',nil,mfYesButton+mfNoButton+mfCancelButton);

     case r of
      cmYes   :begin
                save_config(true);
                cfgchang:=false;
               end;
      cmNo    :begin
                cfgchang:=false;
                {h„mta backup konfiggen}
                for r:=1 to maxcdef do begin
                 cfgvalue[r]:=cfgback[r];
                end;
              end;
      cmCancel:begin
                b:=false;
               end;
    end;
 end;

 save_request:=b;

end;

Procedure TopDialog.Reset_DataFiles;
Var
  R     : TRect;
  Pupp  : ResetDialogP;
  x1,y1,x2,y2 : byte;

  x:integer;

  skit : psitem;

Begin

  x1:=2;
  y1:=1;
  x2:=43;
  y2:=16;

  R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
  Pupp := New(ResetDialogP, Init(R, 'Reset DataFiles'));

  Pupp^.Static(2,2,'Choose DataFiles to Reset :');

  skit:=NewSItem('Door Guards',
        NewSItem('Items',
        NewsItem('Computer Players',
        NewSItem('Monsters',
        NewsItem('Level limits',
        NewsItem('Armor file  (OLD mode Armors)',
        NewsItem('Weapon file (OLD mode Weapons)', nil)))))));

  pupp^.CheckBoxes(3,4,31,7,skit);

  Pupp^.OkButton(2,12);
  Pupp^.CancelButton(13,12);

  {Pupp^.Flags:=0;}
  pupp^.Options := Options or ofCentered;

  DeskTop^.ExecView(Pupp);

  {Pupp^.Static(3,2,'Creating Horrible Monsters');
  for x:=1 to 50 do begin
   Statbar(pupp,x,50,3,3,5,6);
   delay(50);
  end;

  Pupp^.Static(3,5,'Creating Computer Players');
  for x:=1 to 50 do begin
   Statbar(pupp,x,50,3,6,0,0);
   delay(50);
  end; }

  DeskTop^.Delete(Pupp);
  Dispose(Pupp, Done);

End;

Procedure TopDialog.Reset_The_Game;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  sx,sy : byte;

Begin

 x1:=2;
 y1:=1;
 x2:=70;
 y2:=20;

 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 Pupp := New(ResetDialogP, Init(R, 'Reset Usurper'));

 {dialogen skall ej kunna st„ngas eller flyttas}
 Pupp^.Flags:=0;

 DeskTop^.Insert(Pupp);

 {Pupp^.Static(3,2,'Creating Horrible Monsters');
 for x:=1 to 50 do begin
  Masterx:=3; Mastery:=3;

  Statbar(x,50,masterx,mastery,1,1);
  delay(50);
 end;}

 if exist(innfile)       then delete_file(innfile);
 if exist(nwfileans)     then delete_file(nwfileans);
 if exist(nwfileasc)     then delete_file(nwfileasc);
 if exist(ynwfileasc)    then delete_file(ynwfileasc);
 if exist(ynwfileasc)    then delete_file(ynwfileasc);
 if exist(datefile)      then delete_file(datefile);
 if exist(mafile)        then delete_file(mafile);
 if exist(marketfile)    then delete_file(marketfile);
 if exist(armofile)      then delete_file(armofile);
 if exist(weapofile)     then delete_file(weapofile);
 if exist(wwfile)        then delete_file(wwfile);
 if exist(truthfile)     then delete_file(truthfile);
 if exist('teamrec.dat') then delete_file('teamrec.dat');
 if exist('trecord.dat') then delete_file('trecord.dat');

 sx:=3;
 sy:=2;

 Pupp^.Static(sx,sy,'Creating Level Limits');
 MasterX:=sx; MasterY:=sy+1;
 Reset_Levels;

 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Door Guards (available at the Inn)');
 Masterx:=sx; Mastery:=sy+1;
 Reset_DoorGuards;

 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Items');
 Masterx:=sx; Mastery:=sy+1;

 Rewrite_Datfiles(true);
 Count_Objects;
 Reset_Monster_Weapons;
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

 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Monsters');
 Masterx:=sx; Mastery:=sy+1;

 Count_Monsters;
 Reset_Monsters;

 inc(sy,2);
 Pupp^.Static(sx,sy,'Arming Monsters');
 Masterx:=sx; Mastery:=sy+1;
 Arm_Monsters;


 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Armors (OLD mode)');
 Masterx:=sx; Mastery:=sy+1;
 count_oldarmors;
 Reset_Armor;

 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Weapons (OLD mode)');
 Masterx:=sx; Mastery:=sy+1;
 count_oldweapons;
 Reset_Weapon;

 {NPC m†ste skapas SIST eftersom den l„ser fr†n de tidigare}
 assign(playerfile,npfile);
 rewrite(playerfile);
 close(playerfile);

 inc(sy,2);
 Pupp^.Static(sx,sy,'Creating Computer Characters');
 Masterx:=sx; Mastery:=sy+1;
 count_npcs;
 reset_npcs;

 if exist(pfile) then delete_file(pfile);

 {don''t forget to edit the options..if ya wanna do that!}
 messagebox(#3'Usurper is ready to Go!', nil,mfinformation or mfokbutton);

 DeskTop^.Delete(Pupp);
End;

Procedure Config;
Var
  R     : TRect;
  pBor  : ^TScrollBar;
  Pupp  : PConfigDialog;
  x1,y1,x2,y2,t : byte;
Begin

  x1:=2;
  y1:=1;
  x2:=70;
  y2:=20;

  Plist^.Process; {tdialog}
  R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
  Pupp := New(PConfigDialog, Init(R, 'Usurper Configuration'));

  t:=5;
  Pupp^.OkButton(t+00,16);
  Pupp^.MakeButton(t+12,16,14,'~N~ew Config', cmNewConf, bfNormal+bfgrabfocus);
  Pupp^.MakeButton(t+28,16,10,'~G~oto', cmCGoto, bfNormal+bfgrabfocus);

  R.Assign(65, 1, 66, 15);
  PBor:= New(Pscrollbar, Init(R));

  R.Assign(2, 1, 65, 15);
  Plist:=New(PListbox, Init(R,1,PBor));

  Plist^.Newlist(Namelist);

  Pupp^.Insert(PBor);
  Pupp^.Insert(PList);
  DeskTop^.ExecView(Pupp);
  Dispose(Pupp, Done);

End;

Procedure About;
var
  D: PDialog;
  R: TRect;
begin

 R.Assign(0, 0, 40, 11);
 D := New(PDialog, Init(R, 'About'));
 With D^ do begin
  Options := Options or ofCentered;

  R.Grow(-1, -1);
  Dec(R.B.Y, 3);
  Insert(New(PStaticText, Init(R,
   #13 +
   ^C'Usurper Editor'#13 +
   #13 +
   ^C'Copyright (c) 1995'#13 +
   #13 +
   ^C'JAS Software')));

  R.Assign(15, 8, 25, 10);
  Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));
 end;
 Desktop^.ExecView(D);
 Dispose(D, Done);
end;


Procedure Edit_Config_Option(nr:integer);
Var
   Dbox      : PDialog;
   C,rad,
   minl      : Word;
   A         : PView;
   R         : TRect;
   S         : String;

   x1,y1,x2,y2 : integer;

Begin

 {f”rst r„knar vi hur m†nga RADER hj„lptexten best†r av.}
 rad:=0;
 minl:=35;

 for c:=1 to 10 do begin
  s:=help_cfg(nr,c);
  if s<>'' then begin
   inc(rad);
   if (length(s)+10)>=minl then begin
    minl:=length(s)+10;
   end;
  end;
 end;

 R.Assign(7,4,minl+2,rad+12);

 str(nr,s);
 Dbox := New(PDialog, Init(R, 'Option #'+s));
 With Dbox^ Do Begin
  {Options := Options or ofCentered;}

  x1:=02;
  y1:=02;
  x2:=minl-7;
  y2:=03;

  {help text RADER}
  for c:=1 to rad do begin
   R.Assign(x1,y1,x2,y2);
   Insert(New(PStaticText, Init(R,help_cfg(nr,c))));
   inc(y1);
   inc(y2);
  end;

  inc(y1); inc(y2);

  {inputline}
  R.Assign(02,y1,minl-10,y2);
  A:=New(PInputLine, Init(R,70));
  Insert(A);

  {default value}
  s:=cfgvalue[nr];
  A^.SetData(S);


  inc(y1,2);
  inc(y2,2);

  inc(y2);

  {Buttons}
  R.Assign(02, y1, 12, y2);
  Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));

  R.Assign(15, y1, 25, y2);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

  DBox^.SelectNext(true);
  DBox^.SelectNext(true);

 end;

 C:=Desktop^.ExecView(Dbox);
 if C <> cmCancel then Begin
  {uppdatera med ny data!}
  A^.GetData(S);

  if upcasestr(cfgvalue[nr])<>upcasestr(s) then begin
   cfgchang:=true;
   cfgvalue[nr]:=s;
   NameList^.ATPut(nr-1,Newstr(default_cfg(nr)+S));
  end;

 End;

 Dispose(Dbox, Done);

End;



Function Goto_Config_Option : integer;
Var
   Dbox      : PDialog;
   A         : PView;
   R         : TRect;
   err : integer;
   c,result : word;
   s : string;

Begin

 R.Assign(7,4,40,11);

 Dbox := New(PDialog, Init(R, 'Goto Option #'));
 With Dbox^ Do Begin
  {Options := Options or ofCentered;}

  s:='Goto Line #';
  {help text RADER}
  R.Assign(2,1,length(s)+2,2);
  Insert(New(PStaticText, Init(R,s)));

  {inputline}
  R.Assign(2,2,8,3);
  A:=New(PInputLine, Init(R,8));
  Insert(A);

  {default value}
  s:='';
  A^.SetData(S);

  {Buttons}
  R.Assign(02, 04, 12, 06);
  Insert(New(PButton, Init(R, 'O~K', cmOk, bfDefault)));

  R.Assign(15, 04, 25, 06);
  Insert(New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal)));

  DBox^.SelectNext(true);
  DBox^.SelectNext(true);

 end;

 result:=0;

 C:=Desktop^.ExecView(Dbox);
 if C <> cmCancel then Begin
  {goto ny line}
  A^.GetData(S);

  val(s,c,err);
  if err=0 then begin
   if (c>0) and (c<=maxcdef) then begin
    result:=c;
   end;
  end;

 End;

 Dispose(Dbox, Done);

 goto_config_option:=result;

End;


