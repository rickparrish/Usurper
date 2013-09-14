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
Unit EXtra; {Usurper Editor - Misc}

Interface

Uses Init, Xboxes, Objects;

Procedure FirstMenu; {MAIN MENU}
Procedure Config_Editor; {Usurper Configuration Dialog}

Procedure Load_Config;
Procedure Save_Config(announce:boolean);
Procedure Create_Default_Config(announce:boolean);
Procedure Edit_Config_Option(nr : integer);
Procedure Global_Monster_Commands;

Procedure Item_Info(item : objektrec);
Procedure Item_Type_Selector;
Procedure Manage_Inventory(var gubbe : userrec);
Procedure Equipment_Dialog(var gubbe : userrec);
Procedure Equipment_Dialog_Classic(var gubbe : userrec);

Procedure View_As_Text(const FileName: string); {snatched from TVFDEMO}

Procedure Reset_Game(game,killgods : boolean); {game=true reset game}
Procedure Reset_DataFiles;
Procedure Set_Classic_Weapon(vapen:boolean); {choose Classic Weapon for PLAYER}
Procedure Pick_Monster_Item(typ : objtype); {pick equipment for Monster}
Procedure Pick_Item(typ : objtype; which : boolean); {pick equipment for PLAYER}
Procedure Gimme_Item(typ : objtype;invnr:byte); {general ITEM selector}
Procedure ViewTextsMenu;
Procedure Options_Menu;
Procedure More_Editors_Menu;

Procedure About; {about box - who made the program + version etc. etc.}
Function YesNoBox(const toptext:string; const text:string) : boolean;
Function Save_Request : boolean;

{config dialog functions}
Function Get_a_value_box(text:s70;min,max:longint) : integer;
Function Search_in_Config(text:s70;templist : pstringcollection) : integer;
function WaitDialog(const top:string; const Msg: String) : XDialogP;

Function Bash_Name(nr:integer) : string;
Function Bash_Rank(nr:integer) : string;
Function Race_Display( race : races ) : string;

Implementation

Uses Dos, Cms, Jakobe,
     Addit, Helpfile, ClasDis2,
     cfghelp, cfgval, cfgdef,
     File_Io,

     App, MsgBox, Dialogs,
     Drivers, Views,
     Menus, ViewText;

Procedure Config_Editor; {Usurper Configuration Dialog}
Const
      dialogtitle = 'Usurper Configuration'; {dialog title}

      x1 : byte = 2; {x/y coords}
      y1 : byte = 1;
      x2 : byte = 73;
      y2 : byte = 20;

Var
  R    : TRect;
  PBor : ^TScrollBar;   {scroll bar}
  Dia  : ConfigDialogP; {dialog box}

Begin

  {Process Config Data}
  Plist^.Process;

  {Assign Dialog}
  R.Assign(x1,y1,x2,y2); {x/y start for dialog box}

  {Init Dialog}
  Dia := New(ConfigDialogP, Init(R, DialogTitle));

  {Options}
  Dia^.Options := Dia^.Options or ofCentered;

  {Buttons}
  Dia^.OkButton(x1,y2-4);
  Dia^.MakeButton(13,16,14,'~N~ew Config', cmNewConf, bfNormal+bfgrabfocus,hcConfigNew);
  Dia^.MakeButton(28,16,10,'~G~oto',       cmCGoto,   bfNormal+bfgrabfocus,hcConfigGoto);
  Dia^.MakeButton(39,16,10,'~S~earch',     cmCSearch, bfNormal+bfgrabfocus,hcConfigSearch);

  {Assign & Init Scrollbar}
  R.Assign(x2-5, y1, x2-4, y2-5);
  PBor:= New(Pscrollbar, Init(R));

  {Assign & Init Listbox}
  R.Assign(x1, y1, x2-5, y2-5);
  Plist:=New(ListboxP, Init(R,1,PBor));

  {Insert List}
  Plist^.Newlist(Namelist);

  {Insert Scrollbar}
  Dia^.Insert(PBor);

  {Insert List}
  Dia^.Insert(PList);

  {Execute Dialog}
  MyApp.ExecuteDialog(Dia,Nil);

End; {config_editor *end*}

Function Save_Request : boolean;
var r : integer;
    b : boolean;
begin

 b:=true;

 if ur_change then begin

  r:=MessageBox(
     #13 +
     ^C'Save Changes Before Exit?'#13 +
     #13 +
     ^C' '#13 +
     #13 +
     ^C' ',nil,mfYesNoCancel+mfConfirmation);

  case r of
   cmYes   :begin
             save_config(true);
             cfgchang:=false;
            end;
   cmNo    :begin
            cfgchang:=false;
            {fetch backup config}
            for r:=1 to global_maxcdef do begin
             cfgvalue[r]:=cfgback[r];
            end; {for r:= .end.}
           end;
   cmCancel:begin
             b:=false;
            end;
  end; {case .end.}
 end;

 {return result}
 save_request:=b;

end; {save_request *end*}

function WaitDialog(const top:string;const Msg: String) : XDialogP;
var
  R: TRect;
  D: XDialogP;
  Width: Integer;
  XPos: Integer;
begin
  if Length(Msg) > 40 then Width := Length(Msg) + 4
  else Width := 40;
  XPos := (Width div 2) - (Length(Msg) div 2) - 1;

  R.Assign(0, 0, Width, 7);
  D := New(XDialogP, Init(R, top));
  with D^ do
  begin
    Options := Options or ofCentered;
    Flags := Flags and (not wfClose) and (not wfMove);
    R.Assign(XPos, 3, XPos+Length(Msg)+1, 4);
    Insert(New(PStaticText,Init(R, Msg)));
  end;
  WaitDialog := D;
end; {waitdialog *end*}

Procedure ViewTextsMenu; {View doc files, menu}
Var
  R   : TRect;
  Dia : ViewTextDialogP;
  x1,y1,w : byte;

Begin

 {Assign Dialog}
 R.Assign(2,1,26,18); {x/y start for config box}
 Dia := New(ViewTextDialogP, Init(R, 'View Textfiles'));

 Dia^.Options := Dia^.Options + ofCentered;

 {offset}
 x1:=3;
 y1:=0;
 w:=18;

 {column 1}
 inc(y1,2);

 Dia^.MakeButton(x1,y1+0,w,'~R~eadme',      cmReadMe,     bfGrabFocus,hcReadMe);
 Dia^.MakeButton(x1,y1+2,w,'~W~hats New',   cmWhatsNew,   bfGrabFocus,hcWhatsNew);
 Dia^.MakeButton(x1,y1+4,w,'~S~ysop Doc',   cmSysopDoc,   bfGrabFocus,hcSysopDoc);
 Dia^.MakeButton(x1,y1+6,w,'~U~surper Doc', cmUsurperDoc, bfGrabFocus,hcUsurperDoc);
 Dia^.MakeButton(x1,y1+8,w,'Su~p~port Doc', cmSupportDoc, bfGrabFocus,hcSupportDoc);
 Dia^.MakeButton(x1,y1+10,w,'~F~uture',     cmFutureDoc,  bfGrabFocus,hcFutureDoc);

 {Dia^.MakeButton(x1,y1+8,w,'O~t~her ..',    cmViewFile,   bfGrabFocus,hcViewFile);  }
 Dia^.MakeButton(x1,y1+12,w,'~O~k', cmOk, bfGrabFocus,hcGenOk);

 {set default button}
 Dia^.SelectNext(false);

 {Excecute Dialog}
 MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Global_Monster_Commands;
Var
  R   : TRect;
  Dia : GlobalMonsterDialogP;
  x1,y1,w : byte;

Begin

 {Assign Dialog}
 R.Assign(2,1,26,12); {x/y start for config box}
 Dia := New(GlobalMonsterDialogP, Init(R, 'Global'));

 {Options}
 Dia^.Options := Dia^.Options + ofCentered;
 Dia^.GrowMode := gfGrowAll;

 {init vars}
 x1:=3;
 y1:=0;
 w:=18;

 {kolumn 1}
 inc(y1,2);

 {buttons}
 Dia^.MakeButton(x1,y1+0,w,'~R~emove Spells',cmMGrmvSpells, bfGrabFocus,hcMeditGrmvSpells);
 Dia^.MakeButton(x1,y1+2,w,'~O~k',           cmOk, bfGrabFocus,hcGenOk);

 {set default button}
 Dia^.SelectNext(false);

 {Execute Dialog}
 MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Options_Menu;
Var
  R   : TRect;
  Dia : OptionsDialogP;
  x1,y1,w : byte;

Begin

 {Assign Dialog}
 R.Assign(2,1,26,12); {x/y start for config box}
 Dia := New(OptionsDialogP, Init(R, 'Options'));

 {Options}
 Dia^.Options := Dia^.Options + ofCentered;
 Dia^.GrowMode := gfGrowAll;

 {init vars}
 x1:=3;
 y1:=0;
 w:=18;

 {kolumn 1}
 inc(y1,2);

 {buttons}
 Dia^.MakeButton(x1,y1+0,w,'~V~iew Docs',cmDocFiles, bfGrabFocus,hcDocFiles);
 Dia^.MakeButton(x1,y1+2,w,'V~i~deo',    cmOptionsToggle, bfGrabFocus,hcOptionsToggle);
 Dia^.MakeButton(x1,y1+4,w,'~D~os Shell',cmODosShell, bfGrabFocus,hcODosShell);
 Dia^.MakeButton(x1,y1+6,w,'~O~k',       cmOk, bfGrabFocus,hcGenOk);

 {set default button}
 Dia^.SelectNext(false);

 {Execute Dialog}
 MyApp.ExecuteDialog(Dia,Nil);

End;


Procedure More_Editors_Menu;
Var
  R   : TRect;
  Dia : MoreEditorsDialogP;
  x1,y1,w : byte;

Begin

 {Assign Dialog}
 R.Assign(2,1,26,16); {x/y start for config box}
 Dia := New(MoreEditorsDialogP, Init(R, 'Editors'));

 {Options}
 Dia^.Options := Dia^.Options + ofCentered;
 Dia^.GrowMode := gfGrowAll;

 {init vars}
 x1:=3;
 y1:=0;
 w:=18;

 {column 1}
 inc(y1,2);

 {buttons}
 Dia^.MakeButton(x1,y1+0,w,'~D~rinks',cmDrinkEditor, bfGrabFocus, hcDrinkEditor);
 Dia^.MakeButton(x1,y1+2,w,'~M~oat guards',cmMoatEditor, bfGrabFocus, hcMoatEditor);
 Dia^.MakeButton(x1,y1+4,w,'~L~evels',cmLevelEditor, bfGrabFocus, hcLevelEditor);
 Dia^.MakeButton(x1,y1+6,w,'~G~ods',cmGodEditor, bfGrabFocus, hcGodEditor);
 Dia^.MakeButton(x1,y1+8,w,'~C~hildren',cmChildEditor, bfGrabFocus, hcChildEditor);
 Dia^.MakeButton(x1,y1+10,w,'~O~k',cmOk, bfGrabFocus,hcGenOk);

 {set default button}
 Dia^.SelectNext(false);

 {Execute Dialog}
 MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure FirstMenu;
Var
  R   : TRect;
  Dia : TopDialogP;
  x1,y1,w : byte;

Begin

 R.Assign(2,1,45,16); {x/y start for config box}
 Dia := New(TopDialogP, Init(R, 'Usurper Editor'));

 Dia^.Options := Dia^.Options + ofCentered;
 Dia^.GrowMode := gfGrowAll;

 x1:=3;
 y1:=0;
 w:=18;

 {kolumn 1}
 inc(y1,2);

 Dia^.MakeButton(x1,y1+0,w,'~C~onfiguration', cmConfig, bfGrabFocus,hcConfig);
 Dia^.MakeButton(x1,y1+2,w,'~R~eset Game',cmResetGame,bfGrabFocus,hcResetGame);
 Dia^.MakeButton(x1,y1+4,w,'Re~s~et Data',cmResetData,bfGrabFocus,hcResetData);
 Dia^.MakeButton(x1,y1+6,w,'~O~ptions',cmOptions,bfGrabFocus,hcOptions);
 Dia^.MakeButton(x1,y1+8,w,'~A~bout',cmAbout,bfGrabFocus,hcAbout);
 Dia^.MakeButton(x1,y1+10,w,'~Q~uit',cmQuit,bfGrabFocus,hcadios);

 {kolumn 2}
 Dia^.MakeButton(x1+w,y1+0,w,'~P~layer Editor', cmPEditor, bfGrabFocus,hcPlayerEditor);
 Dia^.MakeButton(x1+w,y1+2,w,'~N~pcs',cmNpcEditor,bfGrabFocus,hcPlayerEditor);
 Dia^.MakeButton(x1+w,y1+4,w,'~I~tems',cmItemEditor,bfGrabFocus,hcItemEditor);
 Dia^.MakeButton(x1+w,y1+6,w,'Mons~t~ers',cmMonEditor,bfGrabFocus,hcMonsterEditor);
 Dia^.MakeButton(x1+w,y1+8,w,'~D~oor guards',cmDoorEditor,bfGrabFocus,hcDoorGuardEditor);
 Dia^.MakeButton(x1+w,y1+10,w,'~M~ore',cmMoreEditors,bfGrabFocus,hcMoreEditors);

 {Dia^.MakeButton(x1+w,y1+10,w,'~L~evels',cmLevEditor,bfGrabFocus,hcLevelEditor);
 }

 Dia^.SelectNext(false);

 {DeskTop^.ExecView(Dia);
 Dispose(Dia, Done);}

 Myapp.ExeCuteDialog(Dia,Nil);


End;

Procedure View_As_Text(const FileName: string); {snatched from TVFDEMO}
var
  T: PTextWindow;
  R: TRect;
begin

  R.Assign(0,0,80,22);
  T := New(PTextWindow, Init(R, FileName));
  T^.Options := T^.Options or ofCentered;

  Desktop^.ExecView(T);
  Dispose(T,Done);

end; {view_as_text *end*}

Procedure Edit_Config_Option(nr : integer); { edit config option NR }
Var
   Dia       : XDialogP;
   C,rad,
   minl      : Word;
   R         : TRect;
   S         : ^String;

   yesno_option : boolean;
   display_again : boolean;
   x1,y1,x2,y2 : integer;

Begin

 repeat
 display_again:=false;

 new(s);
 s^:='';

 {is the option a Yes/No question ?}
 yesno_option:=false;
 if nr=1111 then begin
  yesno_option:=true;
 end;

 {first we calculate how many rows the helptext consists of.}
 rad:=0;
 minl:=35;

 for c:=1 to maxhelprows do begin
  s^:=configuration_help(nr,c);
  if s^<>'' then begin
   inc(rad);

   if (length(s^)+10)>=minl then begin
    minl:=length(s^)+10;
   end;
  end;
 end; {for c:= .end.}

 {Assign Dialog}
 R.Assign(7,4,minl+2,rad+12);

 {Setup Dialog}
 str(nr,s^);
 Dia := New(XDialogP, Init(R, 'Option #'+s^));
 With Dia^ Do Begin
  Options := Options or ofCentered;

  x1:=02;
  y1:=02;
  x2:=minl-7;
  y2:=03;

  {help text rows}
  for c:=1 to rad do begin
   R.Assign(x1,y1,x2,y2);
   Insert(New(PStaticText, Init(R,configuration_help(nr,c))));
   inc(y1);
   inc(y2);
  end;

  inc(y1); inc(y2);

  {Static text or Inputline}
  if yesno_option then begin
   {if user has edited the cfg file with a texteditor, any shit could
    be in the cfgvalue..we must check this first}
   if (upcasestr(cfgvalue[nr])='YES') or (upcasestr(cfgvalue[nr])='NO') then begin
    {everything is fine}
   end
   else begin
    {neither Yes or No has been entered. we grab the default value!}
    cfgvalue[nr]:=cfg_value(nr);
    s^:=cfgvalue[nr];
    cfgchang:=true;

    NameList^.FreeItem(NameList^.At(nr-1));
    NameList^.ATPut(nr-1,NewStr(Cfg_Default(nr)+s^));
   end;

   Static(2,y1,'Current : '+cfgvalue[nr]);

  end
  else begin
   {inputline}
   TxtEntry(1,y1,'',70,minl-10,hcGenString);
  end;

  {default value}
  s^:=cfgvalue[nr];

  inc(y1,2);
  inc(y2,3);

  {Buttons}
  Dia^.OkButton(02,y1);

  {toggle}
  x1:=15;
  if yesno_option then begin
   Dia^.MakeButton(13,y1,14,'~T~oggle', cmCToggle, bfNormal+bfgrabfocus,hcConfigToggle);
   inc(x1,13);
  end;

  Dia^.CancelButton(x1,y1);

  {Position Selected Item}
  Dia^.SelectNext(true);
  Dia^.SelectNext(true);

 end;

 {Execute Dialog}
 C:=MyApp.ExecuteDialog(Dia,S);

 {Evaluate User Input}
 if C <> cmCancel then Begin

  if yesno_option then begin

   case c of
    CmCToggle:begin
               if cfgvalue[nr]='YES' then s^:='NO'
               else if cfgvalue[nr]='NO' then s^:='YES';

               cfgvalue[nr]:=s^;

               display_again:=true;
              end;
    CmOk     :begin

              end;
   end; {case .end.}
  end; {if yesno_option .end.}

  if not display_again then begin
   {Update With New Data from editline}
   if CfgValue[nr]<>s^ then begin
    CfgChang:=true;

    if s^=' ' then s^:='';

    CfgValue[nr]:=s^;

    NameList^.FreeItem(NameList^.At(nr-1));
    NameList^.ATPut(nr-1,NewStr(Cfg_Default(nr)+S^));
   end;
  end;

 End; {if c<>cmcancel .end.}

 {Dispose Temporary Pointers}
 Dispose(S);

 until not display_again;

End; {edit_config_option *end*}

Procedure Create_Default_Config;
var i : integer;
begin

 for i:=1 to global_maxcdef do begin
  cfgvalue[i]:=cfg_value(i);
 end;
 save_config(false);

 if announce then begin
  messagebox(#3'Configuration File Created!',nil,mfOkbutton+mfInformation);
 end;

end; {create_default_config *end*}

Procedure Load_Config;
var i : Integer;
    txt : text;
    temp : string;
begin

 if open_txtfile(treset,txt,ucfg) then begin
  for i:=1 to global_maxcdef do begin
   readln_from_text(txt,temp);
   cfgvalue[i]:=temp;

   case i of
    101..115:begin
              if upcasestr(cfgvalue[i])='NO' then begin
               cfgvalue[i]:='NO';
               allowitem[i-100]:=false;
              end
              else begin
               cfgvalue[i]:='YES';
               allowitem[i-100]:=true;
              end;
             end;
   end; {case .end.}

  end;
  close_text(txt);
 end
 else begin
  {error}
  unable_To_access(ucfg);
 end;

end; {load_config *end*}

Procedure Save_Config; {Saves Usurper.cfg to disk}
var
    i : Integer;
    txt : text;

Procedure PutIn(const s:string);
begin
 writeln_to_text(txt,s);
end;

begin

 if open_txtfile(trewrite,txt,ucfg) then begin

  {write the configuration values}
  for i:=1 to global_maxcdef do begin
   writeln_to_text(txt,cfgvalue[i]);
  end;

  putin(' ');
  putin('* Line 1  => Sysops name');
  putin('* Line 2  => BBS name');
  putin('* Line 3  => Number of days to keep items in Player Market (default is 20)');
  putin('* Line 4  => Number of days to keep Player Mail (default is 8)');
  putin('* Line 5  => Registration Number (0 if unregistered)');
  putin('* Line 6  => Daily Number of Dungeonfights (5-99)');
  putin('* Line 7  => Days of inactivity before deletion (15-999)');
  putin('* Line 8  => NonPlayerCharacters vicious tendencies :');
  putin('	        0=Passive, 1=Random, 2=Annoying, 3=Persecution');
  putin('* Line 9  => Name of Town (max 40 characters)');
  putin('* Line 10 => Dungeon difficulty (1-10)  10 is the toughest');
  putin('* Line 11 => Display INTRO-menu? (Yes/No)');
  putin('* Line 12 => Name of Challenges place (Anchor road)');
  putin('* Line 13 => Daily Number of Teamfights per player (1-99)');
  putin('* Line 14 => Amount of money for new players (100-1,000,000)');
  putin('* Line 15 => Name of Weaponshop owner (Tully)    [max 20 characters]');
  putin('* Line 16 => Name of Armorshop owner (Reese)     [max 20 characters]');
  putin('* Line 17 => Name of Combat Trainer (Liu Zei)    [max 20 characters]');
  putin('* Line 18 => Name of Magicshop owner (Ravanella) [max 20 characters]');
  putin('* Line 19 => Name of Bank manager (Lobba)        [max 20 characters]');
  putin('* Line 20 => Name of Inn owner (Garth)           [max 20 characters]');
  putin('* Line 21 => Name of Mad & Evil Mage (Groggo)    [max 20 characters]');
  putin('* Line 22 => Quaffing Healing Potions in the Dungeons :');
  putin('              1 : Player quaffs potions and then autoattacks monster.');
  putin('              2 : Player quaffs potions, and then the monster gets a');
  putin('                  free attack round.');
  putin('              3 : Player quaffs potions and can then choose another option.');
  putin('* Line 23 => Display monster comments (YES/NO)');
  putin('* Line 24-33 => How many % of his experience shall a player lose when dying');
  putin('               in the dungeons (0-90). Example :');
  putin(' Line [24] : 0        (Players at level 1 -10 lose 0% of their xp)');
  putin(' Line [25] : 2        (Players at level 11-20 lose 2% of their xp)');
  putin(' Line [26] : 2        (Players at level 21-30 lose 2% of their xp)');
  putin(' Line [27] : 2        (Players at level 31-40 lose 2% of their xp)');
  putin(' Line [28] : 3        (Players at level 41-50 lose 3% of their xp)');
  putin(' Line [29] : 3        (Players at level 51-60 lose 3% of their xp)');
  putin(' Line [30] : 3        (Players at level 61-70 lose 3% of their xp)');
  putin(' Line [31] : 4        (Players at level 71-80 lose 4% of their xp)');
  putin(' Line [32] : 4        (Players at level 81-90 lose 4% of their xp)');
  putin(' Line [33] : 4        (Players at level 91-100 lose 4% of their xp)');
  putin(' ');
  putin('* Line 34 => Allow players in who have been killed offline (Yes/No)');
  putin('* Line 35 => Allow players to attack their teammates (Yes/No)');
  putin('* Line 36 => Allow players to resurrect teammates (Yes/No)');
  putin('* Line 37 => Maximum level difference for players to attack each other. (0-25)');
  putin('             (Example : a value of 5 would mean that a level 10 character');
  putin('              only can attack players with a level of 5 and up...');
  putin('              a value of 0 means that there are NO LIMITS!)');
  putin('* Line 38 => The armor basevalue can now be set freely ( 0-60 % ). A value of');
  putin('             10 means that all armors absorb 10% of their armorvalues as base');
  putin('             value. The higher you set this figure, the more effective the');
  putin('             armors get  (default is 25%).');
  putin('* Line 39 => Make NPC characters available in the Dormitory (thus increasing');
  putin('             the number of opponents available to players) (Yes/No).');
  putin('* Line 40 => Number of Player Fights allowed (1-99).');
  putin('* Line 41 => Bank interest (1-15 %)');
  putin('* Line 42 => Allow NPC:s to create their own teams (Yes/No)');
  putin('* Line 43 => Name of Dungeon Complex 	(Moria, Disney Land....it'+chr(39)+'s up to you)');
  putin('* Line 44 => Include NPC:s level raises in the Daily news? (Yes/No)');
  putin('* Line 45 => Allow NPC:s to buy new Weapons/Armors for themselves? (Yes/No)');
  putin('* Line 46 => Include NPC weapon/armor purchases in the daily news (Yes/No)');
  putin('* Line 47 => Allow Teams to fight in the Dungeons (Yes/No)');
  putin('* Line 48 => Difficulty for Teams fighting in the dungeons (1-20) 1=easy');
  putin('* Line 49 => Maximum number of Healing potions a player can carry (1-9999)');
  putin('* Line 50 => Maximum number of players allowed in the game (1-400)');
  putin('* Line 51 => Allow player to be on more than 1 node simultaneously ? (YES/no)');
  putin('* Line 52 => Cost for identification of an Item in Magic Shop (1-9999999)');
  putin('* Line 53 => Allow Victor to take defeated players In Hand Eq.    (0,1,2,3,4)');
  putin('* Line 54 => Allow Victor to take defeated players Head Eq.       (yes/No)');
  putin('* Line 55 => Allow Victor to take defeated players Body Eq.       (yes/No)');
  putin('* Line 56 => Allow Victor to take defeated players Arm Eq.        (yes/No)');
  putin('* Line 57 => Allow Victor to take defeated players Fingers Eq.    (yes/No)');
  putin('* Line 58 => Allow Victor to take defeated players Legs Eq.       (yes/No)');
  putin('* Line 59 => Allow Victor to take defeated players Feet Eq.       (yes/No)');
  putin('* Line 60 => Allow Victor to take defeated players Waist Eq.      (yes/No)');
  putin('* Line 61 => Allow Victor to take defeated players Neck Eq.       (yes/No)');
  putin('* Line 62 => Allow Victor to take defeated players Face Eq.       (yes/No)');
  putin('* Line 63 => Allow Victor to take defeated players Shield         (yes/No)');
  putin('* Line 64 => Allow Victor to take defeated players On Hands Eq.   (yes/No)');
  putin('* Line 65 => Allow Victor to take defeated players Around Body Eq (yes/No)');
  putin('* Line 66 => Allow Victor to take defeated players Inventory Eq.  (yes/No)');
  putin('* Line 67 => Automatic Maintenance? (YES/no)');
  putin('* Line 68 => Resurrect Dead Players at maintenance? (yes/NO)');
  putin('* Line 69 => Credits to user(s) helping out registering Usurper');
  putin('* Line 70 => Path and name of ANSI  score file (none is created if left blank)');
  putin('* Line 71 => Path and name of ASCII score file (none is created if left blank)');
  putin('* Line 72 => Path and name of ANSI  Team score file');
  putin('* Line 73 => Path and name of ASCII Team score file');
  putin('* Line 74 => Path and name of ANSI  Weapon score file');
  putin('* Line 75 => Path and name of ASCII Weapon score file');
  putin('* Line 76 => Path and name of ANSI  Armor score file');
  putin('* Line 77 => Path and name of ASCII Armor score file');
  putin('* Line 78 => Path and name of ANSI  Equipment score file');
  putin('* Line 79 => Path and name of ASCII Equipment score file');
  putin('* Line 80 => Path and name of ANSI  "Player Killers" score file');
  putin('* Line 81 => Path and name of ASCII "Player Killers" score file');
  putin('* Line 82 => Path and name of ANSI  "Monster Killers" score file');
  putin('* Line 83 => Path and name of ASCII "Monster Killers" score file');
  putin('* Line 84 => Create defined score files upon exit of Usurper (YES/no)');
  putin('* Line 85 => Allow losers from Beer Drinking Competition to play again (YES/no)');
  putin('* Line 86 => Allow losers from Brawls to play again (YES/no)');
  putin('* Line 87 => Time Limit for players every day (1-9999, 0=time is read from dropfile)');
  putin('* Line 88 => NPC players buying strategy. 1-5 (1=sloppy...5=very carefully).');
  putin('             A higher value gives you longer maintenance sessions.');
  putin('             (The Non Player Characters are buying new equipment)');
  putin('* Line 89 => Town Reward. The sum of money a gang gets for controlling');
  putin('             the town. Default value is 5,000.');
  putin('             Example :');
  putin('             Bill (level 10 warrior) and Bull (level 3 cleric) holds');
  putin('             the town. With the default value of 5,000 gold coins the');
  putin('             sum to share would be :');
  putin('             (10 * 5,000) + (3 * 5,000) = 65,000');
  putin('             ------------------------------------');
  putin('             The sum is then split equally between the two members.');
  putin('             Giving them 32,500 gold coins each.');
  putin('* Line 90 => Shall players lose experience points (XP) after losing a');
  putin('             player versus player fight? :');
  putin('              0 = No  (default)');
  putin('              1 = Yes (both offline and online players)');
  putin('              2 = Yes (but only online players)');
  putin('              3 = Yes (but only offline players)');
  putin('            If you set this option to 1,2 or 3 then the same values are used');
  putin('            as in the dying in the dungeons options (line 24-33).');
  putin('* Line 91 => Game mode : CLASSIC or NEW');
  putin('             CLASSIC gives the player only one weapon and one armor.');
  putin('             NEW gives the player the choice of different kinds of armor');
  putin('             (leg, head, feet, body...etc etc).');
  putin('             This switch can be toggled in the middle of a game. But it is');
  putin('             not recommended.');
  putin('* Line 92 => Allow players killed in online battles to play more that day?');
  putin('             (YES/no)');
  putin('* Line 93 => Include NonPlayerCharacters (NPCs) in external score files?');
  putin('             (YES/no)');
  putin('* Line 94 => Allow Computer Controlled teams to attack other gangs?');
  putin('             (YES/no)');
  putin('* Line 95 => Maximum level superiority for attacking gang. (1-5000)');
  putin('* Line 96 => Allow players attacked in the Dorm to be rescued by teammates?');
  putin('             Only occurs at random occasions (YES/no)');
  putin('* Line 97 => # of Drinks player is allowed to order? (1-15, default is 3)');
  putin('* Line 98 => Check other node interaction how often? (every x second) :');
  putin('             (enter a value between 4..25, default is 5)');
  putin('* Line 99 => Semaphore path. Important for multiline BBS.');
  putin('             This field specifies the directory where temporary and');
  putin('             static files used for multi-node operations are stored.  A');
  putin('             RAM disk is highly recommended.');
  putin('             The directory specified here should be the drive and path to');
  putin('	        a directory on a disk (preferably a RAM disk).');
  putin('             If you leave this field blank the semaphore files will be');
  putin('             created in the Usurper '+global_datadir+'directory.');
  putin('* Line 100 => Allow "one man teams" to attack other teams (default YES)');
  putin('* Line 101 => Allow Hand Equipment in game (YES/no)');
  putin('* Line 102 => Allow Head Equipment in game (YES/no)');
  putin('* Line 103 => Allow Body Equipment in game (YES/no)');
  putin('* Line 104 => Allow Arm Equipment in game (YES/no)');
  putin('* Line 105 => Allow Left Finger Equipment in game (YES/no)');
  putin('* Line 106 => Allow Right Finger Equipment in game (YES/no)');
  putin('* Line 107 => Allow Leg Equipment in game (YES/no)');
  putin('* Line 108 => Allow Feet Equipment in game (YES/no)');
  putin('* Line 109 => Allow Waist Equipment in game (YES/no)');
  putin('* Line 110 => Allow 1 Neck Equipment in game (YES/no)');
  putin('* Line 111 => Allow 2 Neck Equipment in game (YES/no)');
  putin('* Line 112 => Allow Face Equipment in game (YES/no)');
  putin('* Line 113 => Allow Shield in game (YES/no)');
  putin('* Line 114 => Allow Around Body Equipment in game (YES/no)');
  putin('* Line 115 => Allow Secondary Weapon in game (YES/no)');
  putin('* Line 116 => Number of days to keep Wanted Posters (default is 30)');
  putin('* Line 117 => Daily News file (ASCII)');
  putin('* Line 118 => Daily News file (ANSI)');
  putin('* Line 119 => Yesterdays News (ASCII)');
  putin('* Line 120 => Yesterdays News (ANSI)');
  putin('* Line 121 => Player level needed to usurp the throne (default=25)');
  putin('* Line 122 => Player soul needed to usurp the throne (good,evil,ANY)');
  putin('* Line 123 => Should NPCs be marked with a ''*'' in the lists? (default=YES)');
  putin('* Line 124 => Should error messages be displayed in detail? (default=NO)');
  putin('* Line 125 => Days to keep NOT ORDERED cocktails at Orbs bar (0-9999, 0=indefinitely)');
  putin('* Line 126 => Max Cocktails allowed in Orbs bar (0-9999, 0=no limit)');
  putin('* Line 127 => Allow Pick-Pockets to enter game after failed attempt (YES/no)');
  putin('* Line 128 => Allow Trouble-makers in the Dorm to enter game again (YES/no)');
  putin('* Line 129 => Allow the King to setup Quests (YES/no)');
  putin('* Line 130 => Max number of quests allowed in database (1-65000, default is 100)');
  putin('* Line 131 => Number of quests a player can claim simultaneously (1-500, default is 3)');
  putin('* Line 132 => Number of Quests a player can complete/day (0-9999, default is 5)');
  putin('* Line 133 => Number of new quests the King can issue every day (1-500, default is 3)');
  putin('* Line 134 => Allow the King to force quests upon players (YES/no)');
  putin('* Line 135 => Allow players who die on quests to enter again the same day (yes/NO)');
  putin('* Line 136 => Allow players who are killed in rescue attempts/prison to enter again (yes/NO)');
  putin('* Line 137 => Npc characters willingness to write comments to the Inn chatfile (0-3).');
  putin('* Line 138 => Allow the King to imprison players for how long? (0-15 days, default is 1)');
  putin('* Line 139 => Use File-locking(1) or Record-locking(2)? (default is 1)');
  putin('* Line 140 => Delay (in milliseconds) between file-locking attempts. (0-1500, [50])');
  putin('* Line 141 => Game text color (default is green)');
  putin('* Line 142 => Player color (default is lightgreen)');
  putin('* Line 143 => Team color (default is cyan)');
  putin('* Line 144 => Monster color (default is lightred)');
  putin('* Line 145 => Item color (default is lightcyan)');
  putin('* Line 146 => Speech color (default is lightmagenta)');
  putin('* Line 147 => Menu bracket color (default is green)');
  putin('* Line 148 => Menu key color (default is magenta)');
  putin('* Line 149 => Resurrect King when Castle is infiltrated (YES/no)');
  putin('* Line 150 => Number of Wrestling matches a player can go / day (1-15, default is 5)');
  putin('* Line 151 => Allow the King to close shops (YES/no)');
  putin('* Line 152 => Punish Players who drop carrier during fight (0-1)');
  putin('* Line 153 => Allow NPCs to marry and have kids (YES/no)');
  putin('* Line 154 => Allow players to visit Steroid shop (YES/no)');
  putin('* Line 155 => Allow players to visit Whore house (YES/no)');
  putin('* Line 156 => Allow players to visit Drug Palace (YES/no)');
  putin('* Line 157 => Allow players to murder Innocent People (YES/no)');
  putin('* Line 158 => Put player opinions of the King the news (YES/no)');
  putin('* Line 159 => Allow fake players to enter (0-110)');
  putin('* Line 160 => Type of money used in game (gold)');
  putin('* Line 161 => corresponding value to #160 (coin)');
  putin('* Line 162 => corresponding value to #161 (coins)');
  putin('* Line 163 => Number of songs available to Bards/day');
  putin('* Line 164 => Log immortals entering game in the News (YES/no)');
  putin('* Line 165 => Name of Bartender at Orbs Bar (default is Sly)');
  putin('* Line 166 => Minimum Age to Marry (default is 18)');
  putin('* Line 167 => Bobs Beer Hut (default is Bobs Beer Hut)');
  putin('* Line 168 => Shop-keeper at Bobs (default is Bob)');
  putin('* Line 169 => Bishop (default is Jakobinus)');
  putin('* Line 170 => Gossip-Monger (default is Lydia)');
  putin('* Line 171 => Bartender at Bobs Beer (default is Ted)');
  putin('* Line 172 => Name of Gym-Masseur (default is Hazzan)');
  putin('* Line 173 => Put Relation Changes in the News (YES/no)');
  putin('* Line 174 => How many Children a player can have (0-300)');
  putin('* Line 175 => How many Children a NPC can have (0-300)');
  putin('* Line 176 => How many prison escape attempts / day (0-250)');
  putin('* Line 177 => Allow players to view game settings (YES/no)');
  putin('* Line 178 => Minutes before disconnected for inactivity (0-900)');
  putin('* Line 179 => Steroid Shop-Keeper (Rand the Human)');
  putin('* Line 180 => Drug Shop-Keeper (Ordlof)');
  putin('* Line 181 => Bear Taming attempts / day (0-128)');
  putin('* Line 182 => Allow NPCs to usurp the Royal Throne (YES/no)');
  putin('* Line 183 => Toss how many kids to the Wolves every day (0-5)');
  putin('* Line 184 => How many marriages can the King ban/dissolve (0-15)');
  putin('* Line 185 => Put how many kids in the Royal Orphanage/day (0-5)');
  putin('* Line 186 => Allow NPCs to interact with Gods (YES/no)');
  putin('* Line 187 => Color of Gods (LightGreen)');
  putin('* Line 188 => Allow Fake players to be chatty (YES/no)');
  putin('* Line 189 => Intimacy Acts per day (0-60000)');
  putin('* Line 190 => Allow Homo/Bi marriages (yes/NO)');
  putin('* Line 191 => How many Resurrections should a player have per day (0-60000)');
  putin('* Line 192 => Allow a player to have both Immortal & Mortal characters (YES/no)');
  putin('* Line 193 => How many days should females be pregnant (0-300)');
  putin('* Line 194 => Allow Adult Options (YES/no)');
  putin('* Line 195 => Pick-Pocket Attempts / day (0-6000)');
  putin('* Line 196 => Name of Quest-Master (Ulgmog)');
  putin('* Line 197 => Max Items That can be Stored at Home (default 10)');
  putin('* Line 198 => Bank Robbery Attempts / day (0-6000)');

  close_text(txt);

  if announce then begin
   messagebox(#3'Config Saved.',nil,mfOkbutton+mfInformation);
  end;

 end
 else begin
  {unable to create UCFG file}
  unable_To_create(ucfg);
 end;

end; {save_config *end*}

Procedure Item_Info;
const maxinfo = 20;
var
   R: TRect;
   D: XDialogP;
   i,j,c : byte;
   needy : byte;
   sinfo : array[1..maxinfo] of s90;
   first : boolean;
begin

 for i:=1 to maxinfo do begin
  sinfo[i]:='';
 end;

 {g”r iordning info arrays}
 i:=1;
 if item.attack  <>0 then begin
  sinfo[i]:='Attack value : '+commastrp(item.attack);
  inc(i);
 end;
 if item.armor   <>0 then begin
  sinfo[i]:='Armor value  : '+commastrp(item.armor);
  inc(i);
 end;
 if item.hps <>0 then begin
  sinfo[i]:='Hitpoints    : '+commastrp(item.hps);
  inc(i);
 end;
 if item.stamina <>0 then begin
  sinfo[i]:='Stamina      : '+commastrp(item.stamina);
  inc(i);
 end;
 if item.agility <>0 then begin
  sinfo[i]:='Agility      : '+commastrp(item.agility);
  inc(i);
 end;
 if item.charisma<>0 then begin
  sinfo[i]:='Charisma     : '+commastrp(item.charisma);
  inc(i);
 end;
 if item.dex     <>0 then begin
  sinfo[i]:='Dexterity    : '+commastrp(item.dex);
  inc(i);
 end;
 if item.wisdom  <>0 then begin
  sinfo[i]:='Wisdom       : '+commastrp(item.wisdom);
  inc(i);
 end;
 if item.mana    <>0 then begin
  sinfo[i]:='Mana         : '+commastrp(item.mana);
  inc(i);
 end;
 if item.strength<>0 then begin
  sinfo[i]:='Strength     : '+commastrp(item.strength);
  inc(i);
 end;
 if item.defence <>0 then begin
  sinfo[i]:='Defence      : '+commastrp(item.defence);
  inc(i);
 end;

 case item.cure of
  All      : sinfo[i]:='Cures all Diseases!';
  Blindness: sinfo[i]:='Cures Blindness';
  Plague   : sinfo[i]:='Cures the Plague';
  Smallpox : sinfo[i]:='Cures Smallpox';
  Measles  : sinfo[i]:='Cures Measles';
  Leprosy  : sinfo[i]:='Cures Leprosy';
 end;
 if item.cure<>Nothing then inc(i);

 if item.evil then begin
  sinfo[i]:='Can only be used by EVIL characters';
  inc(i);
 end
 else if item.good then begin
  sinfo[i]:='Can only be used by GOOD characters';
  inc(i);
 end;

 if item.cursed then begin
  sinfo[i]:='This item is CURSED.';
  inc(i);
 end;

 first:=true;
 c:=0;
 for j:=1 to maxclasses do begin
  if item.restrict[j]=true then begin
   inc(c);
   if c>4 then begin
    inc(i);
    c:=0;
   end;

   if first then begin
    sinfo[i]:='Item can''t be used by :';
    inc(i);
    first:=false;
   end;
   sinfo[i]:=sinfo[i]+class_display2(j)+'s, ';
  end;
 end;
 needy:=i+5;

 for i:=1 to maxinfo do begin
  if sinfo[i]<>'' then sinfo[i]:=' '+sinfo[i];
 end;

 R.Assign(0, 0, 53, needy);
 D := New(XDialogP, Init(R,item.name));
 With D^ do begin
  Options := Options or ofCentered;

 { R.Grow(-1, -1);
  Dec(R.B.Y, 3);
 }
  c:=2;
  for i:=1 to maxinfo do begin
   if sinfo[i]<>'' then begin
    Static(2,c,sinfo[i]);
    inc(c);
   end;
  end;

  OkButton(15,needy-3);

 end;

 MyApp.ExecuteDialog(D,Nil);

end; {item_info *end*}

Procedure Equipment_Dialog;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  Dia : EqDialogP;
  bx : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(dia^.ps[nr]^.Text);
 dia^.ps[nr]^.Text := NewStr(s);
 dia^.ps[nr]^.Draw;
end;

Begin

 {Dialog Coordinates}
 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;


 {Assign Dialog}
 R.Assign(x1,y1,x2,y2); {x/y start for config boxen}

 {Init Dialog}
 Dia:=New(EqDialogP, Init(R,gubbe.name2+'s Equipment'));

 {Options}
 Dia^.Options := Dia^.Options or ofCentered;

 if gubbe.lhand>0 then begin
  load_objekt(Fload,objekt,weapon,gubbe.lhand);
  replace(1,objekt.name);
 end;

 if gubbe.rhand>0 then begin
  load_objekt(Fload,objekt,weapon,gubbe.rhand);
  replace(2,objekt.name);
 end;

 if gubbe.head>0 then begin
  load_objekt(Fload,objekt,head,gubbe.head);
  replace(3,objekt.name);
 end;

 if gubbe.body>0 then begin
  load_objekt(Fload,objekt,body,gubbe.body);
  replace(4,objekt.name);
 end;

 if gubbe.arms>0 then begin
  load_objekt(Fload,objekt,arms,gubbe.arms);
  replace(5,objekt.name);
 end;

 if gubbe.lfinger>0 then begin
  load_objekt(Fload,objekt,fingers,gubbe.lfinger);
  replace(6,objekt.name);
 end;

 if gubbe.rfinger>0 then begin
  load_objekt(Fload,objekt,fingers,gubbe.rfinger);
  replace(7,objekt.name);
 end;

 if gubbe.legs>0 then begin
  load_objekt(Fload,objekt,legs,gubbe.legs);
  replace(8,objekt.name);
 end;

 if gubbe.feet>0 then begin
  load_objekt(Fload,objekt,feet,gubbe.feet);
  replace(9,objekt.name);
 end;

 if gubbe.waist>0 then begin
  load_objekt(Fload,objekt,waist,gubbe.waist);
  replace(10,objekt.name);
 end;

 if gubbe.neck>0 then begin
  load_objekt(Fload,objekt,neck,gubbe.neck);
  replace(11,objekt.name);
 end;

 if gubbe.neck2>0 then begin
  load_objekt(Fload,objekt,neck,gubbe.neck2);
  replace(12,objekt.name);
 end;

 if gubbe.face>0 then begin
  load_objekt(Fload,objekt,face,gubbe.face);
  replace(13,objekt.name);
 end;

 if gubbe.shield>0 then begin
  load_objekt(Fload,objekt,shield,gubbe.shield);
  replace(14,objekt.name);
 end;

 if gubbe.hands>0 then begin
  load_objekt(Fload,objekt,hands,gubbe.hands);
  replace(15,objekt.name);
 end;

 if gubbe.abody>0 then begin
  load_objekt(Fload,objekt,abody,gubbe.abody);
  replace(16,objekt.name);
 end;


 {LEFT HAND}
 if allowitem[15] then begin
  dia^.MakeButton(2,2,14,'~L~eft Hand',cmPELHAND,bfNormal+bfgrabfocus,hcEquipLeftHand);
 end;

 {RIGHT HAND}
 dia^.MakeButton(2,4,14,'~R~ight Hand',cmPERHAND,bfNormal+bfgrabfocus,hcEquipRightHand);

 {HEAD}
 if allowitem[2] then begin
  dia^.MakeButton(2,6,14,'~H~ead',cmPEHEAD,bfNormal+bfgrabfocus,hcEquipHead);
 end;

 {BODY}
 if allowitem[3] then begin
  dia^.MakeButton(2,8,14,'~B~ody',cmPEBODY,bfNormal+bfgrabfocus,hcEquipBody);
 end;

 {Arms}
 if allowitem[4] then begin
  dia^.MakeButton(2,10,14,'~A~rms',cmPEARMS,bfNormal+bfgrabfocus,hcEquipArms);
 end;

 {Lfinger}
 if allowitem[5] then begin
  dia^.MakeButton(2,12,14,'~1~ Finger',cmPELFING,bfNormal+bfgrabfocus,hcEquipFinger1);
 end;

 {Rfinger}
 if allowitem[6] then begin
  dia^.MakeButton(2,14,14,'~2~ Finger',cmPERFING,bfNormal+bfgrabfocus,hcEquipFinger2);
 end;

 {Legs}
 if allowitem[7] then begin
  dia^.MakeButton(2,16,14,'L~e~gs',cmPELEGS,bfNormal+bfgrabfocus,hcEquipLegs);
 end;

 bx:=41;
 {Feet}
 if allowitem[8] then begin
  dia^.MakeButton(bx,2,14,'Fee~t~',cmPEFEET,bfNormal+bfgrabfocus,hcEquipFeet);
 end;

 {Waist}
 if allowitem[9] then begin
  dia^.MakeButton(bx,4,14,'~W~aist',cmPEWAIST,bfNormal+bfgrabfocus,hcEquipWaist);
 end;

 {Neck}
 if allowitem[10] then begin
  dia^.MakeButton(bx,6,14,'~N~eck',cmPELNECK,bfNormal+bfgrabfocus,hcEquipNeck1);
 end;

 {Neck2}
 if allowitem[11] then begin
  dia^.MakeButton(bx,8,14,'Nec~k~',cmPERNECK,bfNormal+bfgrabfocus,hcEquipNeck2);
 end;

 {Face}
 if allowitem[12] then begin
  dia^.MakeButton(bx,10,14,'~F~ace',cmPEFACE,bfNormal+bfgrabfocus,hcEquipFace);
 end;

 {Shield}
 if allowitem[13] then begin
  dia^.MakeButton(bx,12,14,'~S~hield',cmPESHIELD,bfNormal+bfgrabfocus,hcEquipShield);
 end;

 {Hands}
 if allowitem[1] then begin
  dia^.MakeButton(bx,14,14,'Han~d~s',cmPEHANDS,bfNormal+bfgrabfocus,hcEquipHands);
 end;

 {Around body}
 if allowitem[14] then begin
  dia^.MakeButton(bx,16,14,'ABod~y~',cmPEABODY,bfNormal+bfgrabfocus,hcEquipAbody);
 end;

 {BUTTONS}
 dia^.MakeButton(02,y2-3,10,'~O~k',        cmOk,      bfNormal+bfgrabfocus,hcGenOk);
 dia^.MakeButton(13,y2-3,12,'~C~ancel',    cmCancel,  bfNormal+bfgrabfocus,hcGenCancel);
 dia^.MakeButton(26,y2-3,15,'~I~nventory', cmEqInventory,  bfNormal+bfgrabfocus,hcInventory);
 dia^.MakeButton(42,y2-3,16,'A~u~to Equip',cmEqAutoEquip,  bfNormal+bfgrabfocus,hcAutoEquip);
 dia^.MakeButton(59,y2-3,16,'Re~m~ove All',cmEqRemoveAll,  bfNormal+bfgrabfocus,hcRemoveAll);

 {Position Selected Item}
 Dia^.SelectNext(true);
 Dia^.SelectNext(true);
 Dia^.SelectNext(true);
 Dia^.SelectNext(true);


 {load_player('L',player,currp);}
 {Transfer(EdGuy,Player,false);

 {Dialog Setdata with Record Structure}
 dia^.SetData(EdGuy);

 {Execute Dialog}
 MyApp.ExecuteDialog(DIA,Nil);

End;

Procedure Equipment_Dialog_Classic;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  Dia : EqClDialogP;
  bx : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(dia^.ps[nr]^.Text);
 dia^.ps[nr]^.Text := NewStr(s);
 dia^.ps[nr]^.Draw;
end;
var cweapon : weaprec;
    carmor  : armrec;
Begin

 x1:=0;
 y1:=0;
 x2:=50;
 y2:=12;


 R.Assign(x1,y1,x2,y2);
 Dia:=New(EqClDialogP, Init(R,gubbe.name2+'s Weapon and Armor'));

 Dia^.Options := Dia^.Options or ofCentered;

 if gubbe.weapon>0 then begin
  load_weapon(gubbe.weapon,cweapon);
  replace(1,cweapon.name);
 end;

 if gubbe.armor>0 then begin
  load_armor(gubbe.armor,carmor);
  replace(2,carmor.name);
 end;

 {WEAPON}
 Dia^.MakeButton(2,2,12,'~W~eapon',cmPWeapOld,bfNormal+bfgrabfocus,hcClassicWeapon);

 {ARMOR}
 Dia^.MakeButton(2,4,12,'~A~rmor',cmPArmOld,bfNormal+bfgrabfocus,hcClassicArmor);


 {BUTTONS}
 Dia^.MakeButton(02,y2-3,10,'~O~k',    cmOk,     bfNormal+bfgrabfocus,hcGenOk);
 Dia^.MakeButton(13,y2-3,12,'~C~ancel',cmCancel, bfNormal+bfgrabfocus,hcGenCancel);

 MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Manage_Inventory;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  i : word;
  Dia : InvDialogP;
  bx,bw : byte;

Procedure Replace(nr:integer;s:string);
begin
 DisposeStr(Dia^.ps[nr]^.Text);
 Dia^.ps[nr]^.Text := NewStr(s);
 Dia^.ps[nr]^.Draw;
end;

Begin

 x1:=0;
 y1:=0;
 x2:=80;
 y2:=23;

 R.Assign(x1,y1,x2,y2); {x/y start for config box}
 Dia:=New(InvDialogP, Init(R,gubbe.name2+'s Inventory'));

 Dia^.Options := Dia^.Options + ofCentered;

 for i:=1 to maxitem do begin
  if gubbe.item[i]>0 then begin
   load_objekt(Fload,objekt,gubbe.itemtype[i],gubbe.item[i]);
   replace(i,objekt.name);
  end;
 end;

 bw:=6; {button width}

 Dia^.MakeButton(2,02,bw,'~1~',cmInv01,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,04,bw,'~2~',cmInv02,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,06,bw,'~3~',cmInv03,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,08,bw,'~4~',cmInv04,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,10,bw,'~5~',cmInv05,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,12,bw,'~6~',cmInv06,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,14,bw,'~7~',cmInv07,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(2,16,bw,'~8~',cmInv08,bfNormal+bfgrabfocus,hcInventoryItem);

 bx:=41;
 Dia^.MakeButton(bx,02,bw,'~9~',cmInv09,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,04,bw,'~0~',cmInv10,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,06,bw,'~A~',cmInv11,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,08,bw,'~B~',cmInv12,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,10,bw,'~D~',cmInv13,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,12,bw,'~E~',cmInv14,bfNormal+bfgrabfocus,hcInventoryItem);
 Dia^.MakeButton(bx,14,bw,'~F~',cmInv15,bfNormal+bfgrabfocus,hcInventoryItem);

 {BUTTONS}
 Dia^.MakeButton(02,y2-3,10,'~O~k',        cmOk,     bfNormal+bfgrabfocus,hcGenOk);
 Dia^.MakeButton(13,y2-3,12,'~C~ancel',    cmCancel, bfNormal+bfgrabfocus,hcGenCancel);
 Dia^.MakeButton(26,y2-3,16,'~R~emove All',cmInvRemoveAll, bfNormal+bfgrabfocus,hcInventoryRemove);

 {Set Default Button}
 Dia^.SelectNext(true);
 Dia^.SelectNext(true);

 {Execute Dialog}
 Myapp.ExecuteDialog(Dia,Nil);

End;

Procedure Item_Type_Selector;
Var
  R     : TRect;
  x1,y1,x2,y2 : byte;
  Dia : TypSelDialogP;
  sofar,cy,bx,bw : byte;

Procedure Check;
begin
 if sofar>=8 then begin
  bx:=17;
  cy:=2;
  sofar:=0;
 end;
end;
Begin

 x1:=0;
 y1:=0;
 x2:=34;
 y2:=19;

 R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
 Dia:=New(TypSelDialogP, Init(R,'Type of Item'));
 Dia^.Options := Dia^.Options or ofCentered;

 bx:=2;
 bw:=14; {button width}
 sofar:=0;

 cy:=2;

 {Weapon}
 check;
 Dia^.MakeButton(bx,cy,bw,'~W~eapon',cmSWeap,  bfNormal+bfgrabfocus,hcEquipWeapon);
 inc(cy,2); inc(sofar);

 {Shield}
 check;
 Dia^.MakeButton(bx,cy,bw,'~S~hield',cmShield, bfNormal+bfgrabfocus,hcEquipShield);
 inc(cy,2); inc(sofar);

 {Head}
 check;
 Dia^.MakeButton(bx,cy,bw,'H~e~ad',  cmSHead,  bfNormal+bfgrabfocus,hcEquipHead);
 inc(cy,2); inc(sofar);

 {Body}
 check;
 Dia^.MakeButton(bx,cy,bw,'~B~ody',  cmSBody,  bfNormal+bfgrabfocus,hcEquipBody);
 inc(cy,2); inc(sofar);

 {Arms}
 check;
 Dia^.MakeButton(bx,cy,bw,'~A~rms',  cmSArms,  bfNormal+bfgrabfocus,hcEquipArms);
 inc(cy,2); inc(sofar);

 {Hands}
 check;
 Dia^.MakeButton(bx,cy,bw,'~H~ands', cmSHands, bfNormal+bfgrabfocus,hcEquipHands);
 inc(cy,2); inc(sofar);

 {Fingers}
 check;
 Dia^.MakeButton(bx,cy,bw,'F~i~nger',cmSFing,  bfNormal+bfgrabfocus,hcEquipFingers);
 inc(cy,2); inc(sofar);

 {Legs}
 check;
 Dia^.MakeButton(bx,cy,bw,'~L~egs',  cmSLegs,  bfNormal+bfgrabfocus,hcEquipLegs);
 inc(cy,2); inc(sofar);

 {Feet}
 check;
 Dia^.MakeButton(bx,cy,bw,'~F~eet', cmSFeet,  bfNormal+bfgrabfocus,hcEquipFeet);
 inc(cy,2); inc(sofar);

 {Waist}
 check;
 Dia^.MakeButton(bx,cy,bw,'Wais~t~',cmSWaist, bfNormal+bfgrabfocus,hcEquipWaist);
 inc(cy,2); inc(sofar);

 {Neck}
 check;
 Dia^.MakeButton(bx,cy,bw,'~N~eck', cmSNeck,  bfNormal+bfgrabfocus,hcEquipNecks);
 inc(cy,2); inc(sofar);

 {Face}
 check;
 Dia^.MakeButton(bx,cy,bw,'~F~ace', cmSFace,  bfNormal+bfgrabfocus,hcEquipFace);
 inc(cy,2); inc(sofar);

 {Around Body}
 check;
 Dia^.MakeButton(bx,cy,bw,'A~r~ound Body',cmSAbody,bfNormal+bfgrabfocus,hcEquipAbody);
 inc(cy,2); inc(sofar);

 {Food}
 check;
 Dia^.MakeButton(bx,cy,bw,'F~o~od', cmSFood,  bfNormal+bfgrabfocus,hcEquipFood);
 inc(cy,2); inc(sofar);

 {Drink}
 check;
 Dia^.MakeButton(bx,cy,bw,'~D~rink',cmSDrink, bfNormal+bfgrabfocus,hcEquipDrink);
 inc(cy,2); inc(sofar);

 {Execute Dialog}
 Myapp.ExecuteDialog(Dia,Nil);

End;

Function Search_in_Config;  {search configuration file for keyword}
const maxlett = 30;
      lastsearch : string[maxlett] = '';
type DataRec = record
      nam : string[maxlett];
     end;

var
  R: TRect;
  Dia: XDialogP;
  Data : ^DataRec;
  found : boolean;
  i,res,go : integer;
  ss,s,s2 : string[100];
  kill,c : byte;
  minlength, rows : byte;
  match : boolean;
begin

 new(data);
 data^.nam:=lastsearch;

 R.Assign(0, 0, 45, 8);
 Dia := New(XDialogP, Init(R, 'Search'));
 With Dia^ do begin
  Options := Options or ofCentered;

  {Config search string}
  TxtEntry(1,2,'Search For',maxlett,maxlett,hcGenString);

  OkButton    (02,5);
  CancelButton(14,5);

  FocusNext(false);

 end;
 go:=MyApp.ExecuteDialog(Dia,Data);

 lastsearch:=data^.nam;

 if (go=CmOk) and (data^.nam<>'') then begin
  found:=false;
  res:=0;

  {leta efter data.nam}
  s:=upcasestr(data^.nam);
  kill:=4;

  for i:=1 to templist^.count do begin
   ss:=PString(templist^.At(i-1))^;
   delete(ss,1,kill);

   {
   MessageBox(#3'Is "'+s+'" somewhere in "'+ss+'"', nil,mfinformation or mfokbutton);
   }

   match:=false;
   if findsub(s,ss) then begin
    match:=true;
   end;
   if not match then begin
    {serch in long help text}
    for c:=1 to maxhelprows do begin
     s2:=configuration_help(i,c);
     if findsub(s,s2) then begin
      match:=true;
      break;
     end;
    end; {for c:= .end.}
   end;

   if match then begin
    {we have found a match in the collection (cfg file)}
    rows:=0;
    minlength:=50;
    for c:=1 to maxhelprows do begin
     s2:=configuration_help(i,c);
     if s2<>'' then begin
      inc(rows);
      if (length(s2)+10)>=minlength then begin
       minlength:=length(s2)+10;
      end;
     end;
    end; {for c:= .end.}

    {Setup FOUND MATCH Dialog}
    R.Assign(0, 0, minlength, rows+6);
    Dia := New(XDialogP, Init(R, 'Found match in Option #'+commastr(i)));
    With Dia^ do begin
     Options := Options or ofCentered;

     {.cfg helptext}
     for c:=1 to rows do begin
      if configuration_help(i,c)<>'' then begin
       Static(2,c+1,configuration_help(i,c));
      end;
     end;

     MakeButton  (01,rows+3,10,'~G~oto',CmOk,bfNormal+bfgrabfocus,hcGenGoto);
     MakeButton  (12,rows+3,10,'~N~ext',CmYes,bfNormal+bfgrabfocus,hcGenNext);
     CancelButton(23,rows+3);

     FocusNext(false);
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
   {NO MATCH}
   MessageBox(#3'No Match', nil,mfinformation or mfokbutton);
  end;

 end
 else begin
  {user pressed CANCEL}
  res:=-1;
 end;

 {return result}
 Search_In_Config:=res;

 dispose(data);

end; {Search_in_Config *end*}

Function Get_a_value_Box;
const lastsearch : string='';
Var
   Dia : XDialogP;
   R   : TRect;
   err : integer;
   c,result : longint;
   s : ^string;

Begin

 new(s);

 s^:=text;

 R.Assign(7,4,34,12);

 Dia := New(XDialogP, Init(R, s^));
 With Dia^ Do Begin
  Options := Options or ofCentered;

  {help text row}
  R.Assign(2,1,length(s^)+2,2);
  Static(2,2,s^);

  {inputline}
  TxtEntry(1,3,'',8,8,hcGenString);

  {default value}
  s^:=lastsearch;

  {Buttons}
  OkButton(2,5);
  CancelButton(14,5);

  Dia^.SelectNext(true);
  Dia^.SelectNext(true);

 end;

 result:=0;

 C:=MyApp.ExecuteDialog(Dia,S);

 if C <> cmCancel then Begin
  val(s^,c,err);
  if err=0 then begin
   if (c>=min) and (c<=max) then begin
    result:=c;
    lastsearch:=s^;

   end;
  end;

 End;

 {return result}
 Get_A_Value_Box:=Result;
 dispose(s);

End; {get_a_value_box *end*}

Procedure Reset_Game(game,killgods : boolean); {game=true resets whole game}
Var

  R : TRect;

  x1, y1, x2, y2 : byte;

  s : string[35];

Begin

 x1:=2;
 y1:=1;
 x2:=70;
 y2:=21;

 {kill the gods}
 if killgods then begin
  if f_exists(godsf) then delete_file(godsf);

   {logs of comings and goings of the gods}
   if f_exists(GodsANSI)  then delete_file(GodsANSI);
   if f_exists(GodsASCI)  then delete_file(GodsASCI);

 end;


 if NOT game then begin
  {beh”ver inte s† stor box n„r bara n†gra datafiler ska resettas}
  if not resf1 then dec(y2,2);
  if not resf2 then dec(y2,2);
  if not resf3 then dec(y2,2);
  if not resf4 then dec(y2,2);
  if not resf5 then dec(y2,2);
  if not resf6 then dec(y2,2);
  if not resf7 then dec(y2,2);
  if not resf8 then dec(y2,2);
  if not resf9 then dec(y2,2);
 end;

 if (resf4=true) and (game=false) then begin
  inc(y2,4); {monster file needs extended space}
 end
 else if (game=false) then begin
  inc(y2,2);
 end;

 if game then s:='Resetting Usurper'
         else s:='Resetting Usurper Data files';

 R.Assign(x1,y1,x2,y2); {x/y start for config box}
 Pupp := New(ResDialogP, Init(R, s,game));
 {dialogue box must not be moveable or closeable}
 Pupp^.Flags := Pupp^.Flags and not wfClose;
 Pupp^.Options := Pupp^.Options or ofCentered;

 MyApp.ExecuteDialog(Pupp,Nil);

 {don't forget to edit the options..if ya wanna do that!}
 if game then begin

  {moving the usintro files (included to fix older Usurper versions)}
  {legacy stuff}
  s:='USINTRO1.ANS';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  s:='USINTRO1.ASC';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  s:='USINTRO2.ANS';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);
  s:='USINTRO2.ASC';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  s:='USINTRO3.ANS';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);
  s:='USINTRO3.ASC';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  s:='USINTRO4.ANS';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);
  s:='USINTRO4.ASC';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  s:='USINTRO5.ANS';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);
  s:='USINTRO5.ASC';
  if (f_exists(s)) and (f_exists(global_datadir+s)=false) then move_file(s,global_datadir);

  {messagebox(#3'Usurper has been RESET!', nil,mfinformation or mfokbutton);}

 end
 else begin
  {messagebox(#3'I''m DONE!', nil,mfinformation or mfokbutton);}
 end;

End;

Procedure Reset_DataFiles;
Var

  R : TRect;
  dia : XDialogP;
  boxes : PCheckboxes;
  result : word;

  x1,y1,
  x2,y2 : byte;

Begin

  x1:=2;
  y1:=1;
  x2:=43;
  y2:=18;

  R.Assign(x1,y1,x2,y2); {x/y coords for config box}
  dia := New(XDialogP, Init(R, 'Reset Data files'));

  dia^.Static(2,2,'Choose Data files to Reset :');

  R.Assign(3, 4, 35, 13); {Size of the radio button box}

  boxes:=New(PCheckBoxes, Init(R,
         NewsItem('Level limits',
         NewSItem('Door Guards',
         NewSItem('Items',
         NewSItem('Monsters',
         NewsItem('Armor file  (CLASSIC mode)',
         NewsItem('Weapon file (CLASSIC mode)',
         NewsItem('Computer Players (NPCs)',
         NewsItem('TeamName File',
         NewsItem('Moat Creatures', nil)))))))))));

  if resf1 then boxes^.press(0);
  if resf2 then boxes^.press(1);
  if resf3 then boxes^.press(2);
  if resf4 then boxes^.press(3);
  if resf5 then boxes^.press(4);
  if resf6 then boxes^.press(5);
  if resf7 then boxes^.press(6);
  if resf8 then boxes^.press(7);
  if resf9 then boxes^.press(8);

  boxes^.helpctx:=hcLevelfile; {help text from HcLevelfile ... HcTEam.}

  dia^.Insert(boxes);

  {ok button}
  dia^.OkButton(2,14);

  {cancel button}
  dia^.CancelButton(13,14);

  {help button}
  dia^.MakeButton(24,14,10,'~H~elp', cmHelp,bfGrabFocus+bfDefault,hcResetData);

  {dia^.Flags:=0;}
  dia^.Options := dia^.Options or ofCentered;
  dia^.SelectNext(false);

  result:=DeskTop^.ExecView(dia);

  if result = cmOk then begin
   {reset selected files}
   resf1:=boxes^.Mark(0);
   resf2:=boxes^.Mark(1);
   resf3:=boxes^.Mark(2);
   resf4:=boxes^.Mark(3);
   resf5:=boxes^.Mark(4);
   resf6:=boxes^.Mark(5);
   resf7:=boxes^.Mark(6);
   resf8:=boxes^.Mark(7);
   resf9:=boxes^.Mark(8);

   {***RESET SELECTED FILES START***}
   if (resf1) or (resf2) or (resf3) or (resf4) or (resf5) or (resf6) or
      (resf7) or (resf8) or (resf9) then begin

    if YesNoBox('Warning','Are You SURE?')=true then begin
     {reset game procedure}
     reset_game(false,false);
    end;

   end;
  end;

  Dispose(Dia, Done);

End;

Procedure Set_Classic_Weapon(vapen:boolean); {choose Classic Weapon for PLAYER}
Var
  R    : TRect;
  pBor : ^TScrollBar;
  Dia  : ClassicPickDialogP;
  x1,y1,x2,y2 : byte;
  s:string[90];
Begin

  x1:=2;
  y1:=1;
  x2:=60;
  y2:=20;

  if vapen then s:='Classic Weapons'
           else s:='Classic Armors';

  CLlist^.Process(vapen); {process data list}
  R.Assign(x1,y1,x2,y2); {x/y start for config box}
  Dia := New(ClassicPickDialogP, Init(R,s,vapen));
  Dia^.Options := Dia^.Options or ofCentered;

  Dia^.MakeButton(03,16,10,'~O~k',     cmEqCatchMe,     bfNormal+bfgrabfocus,hcGenOk);
  Dia^.MakeButton(14,16,10,'~C~ancel', cmCancel   ,     bfNormal+bfgrabfocus,hcGenCancel);
  Dia^.MakeButton(25,16,10,'~N~one',   cmRemoveCurrent, bfNormal+bfgrabfocus,hcClassicNone);
  Dia^.MakeButton(36,16,12,'~S~earch', cmEqSearch ,     bfNormal+bfgrabfocus,hcGenSearch);

  R.Assign(55, 1, 56, 15);
  PBor:= New(Pscrollbar, Init(R));

  R.Assign(1, 1, 55, 15);
  CLlist:=New(ClassicListboxP, Init(R,1,PBor));

  CLlist^.Newlist(Namelist);

  if vapen then begin
   if player.weapon>0 then CLlist^.FocusItem(player.weapon-1);
  end
  else begin
   if player.armor>0 then cLlist^.focusitem(player.armor-1);
  end;

  Dia^.Insert(PBor);
  Dia^.Insert(CLList);

  MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Pick_Monster_Item(typ : objtype); {v„ljer equipment †t PLAYER}
Var
  R    : TRect;
  pBor : ^TScrollBar;
  Dia  : ItemPickMDialogP;  {v„lja item †t player}
  x1,y1,x2,y2 : byte;

Begin

  x1:=2;
  y1:=1;
  x2:=70;
  y2:=20;

  R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
  Dia := New(ItemPickMDialogP, Init(R, item_disp(typ),typ));

  dia^.Options := dia^.Options or ofCentered;

  Dia^.MakeButton(03,16,10,'~O~k',     cmEqCatchMe, bfNormal+bfgrabfocus,hcGenOk);
  Dia^.MakeButton(14,16,10,'~C~ancel', cmCancel,    bfNormal+bfgrabfocus,hcGenCancel);
  Dia^.MakeButton(25,16,10,'~N~one',   cmEqNone,    bfNormal+bfgrabfocus,hcItemRemove);
  Dia^.MakeButton(36,16,10,'~I~nfo',   cmItemInfo,  bfNormal+bfgrabfocus,hcItemInfo);
  Dia^.MakeButton(47,16,12,'~S~earch', cmEqSearch,  bfNormal+bfgrabfocus,hcItemSearch);

  R.Assign(65, 1, 66, 15);
  PBor:= New(Pscrollbar, Init(R));

  Eqlist^.Process(typ);

  R.Assign(1, 1, 65, 15);
  Eqlist:=New(EqListboxP, Init(R,1,PBor));

  Eqlist^.Newlist(Namelist);

  Dia^.Insert(PBor);
  Dia^.Insert(EqList);

  MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Pick_Item(typ : objtype; which : boolean); {v„ljer equipment †t PLAYER}
Var
  R    : TRect;
  pBor : ^TScrollBar;
  Dia  : ItemPickDialogP;  {v„lja item †t player}
  x1,y1,x2,y2 : byte;
Begin

  x1:=2;
  y1:=1;
  x2:=70;
  y2:=20;

  R.Assign(x1,y1,x2,y2); {x/y start f”r config boxen}
  Dia := New(ItemPickDialogP, Init(R, item_disp(typ),typ,which));
  dia^.Options := dia^.Options or ofCentered;


  Dia^.MakeButton(03,16,10,'~O~k',     cmEqCatchMe, bfNormal+bfgrabfocus,hcGenOk);
  Dia^.MakeButton(14,16,10,'~C~ancel', cmCancel,    bfNormal+bfgrabfocus,hcGenCancel);
  Dia^.MakeButton(25,16,10,'~N~one',   cmEqNone,    bfNormal+bfgrabfocus,hcItemRemove);
  Dia^.MakeButton(36,16,10,'~I~nfo',   cmItemInfo,    bfNormal+bfgrabfocus,hcItemInfo);
  Dia^.MakeButton(47,16,12,'~S~earch', cmEqSearch,  bfNormal+bfgrabfocus,hcItemSearch);

  R.Assign(65, 1, 66, 15);
  PBor:= New(Pscrollbar, Init(R));

  Eqlist^.Process(typ);

  R.Assign(1, 1, 65, 15);
  Eqlist:=New(EqListboxP, Init(R,1,PBor));

  Eqlist^.Newlist(Namelist);

  Dia^.Insert(PBor);
  Dia^.Insert(EqList);

  MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure Gimme_Item(typ : objtype;invnr:byte); {general ITEM selector}
Var
  R    : TRect;
  pBor : ^TScrollBar;
  Dia  : ItemPickDialog2P;
  x1,y1,x2,y2 : byte;
Begin

  x1:=2;
  y1:=1;
  x2:=70;
  y2:=20;

  Eqlist^.Process(typ);
  R.Assign(x1,y1,x2,y2);
  Dia := New(ItemPickDialog2P, Init(R, item_disp(typ),typ,invnr));

  Dia^.Options := Dia^.Options or ofCentered;

  Dia^.MakeButton(02,16,10,'~O~k',     cmEqCatchMe, bfNormal+bfgrabfocus,hcGenOk);
  Dia^.MakeButton(13,16,10,'~C~ancel', cmCancel, bfNormal+bfgrabfocus,hcGenCancel);
  Dia^.MakeButton(24,16,18,'~R~emove Current', cmRemoveCurrent,bfNormal+bfgrabfocus,hcItemRemove);

  Dia^.MakeButton(43,16,10,'~I~nfo',   cmItemInfo,     bfNormal+bfgrabfocus,hcItemInfo);
  Dia^.MakeButton(54,16,12,'~S~earch', cmEqSearch,     bfNormal+bfgrabfocus,hcItemSearch);

  R.Assign(65, 1, 66, 15);
  PBor:= New(Pscrollbar, Init(R));

  R.Assign(1, 1, 65, 15);
  Eqlist:=New(EqListboxP, Init(R,1,PBor));

  Eqlist^.Newlist(Namelist);

  Dia^.Insert(PBor);
  Dia^.Insert(EqList);

  MyApp.ExecuteDialog(Dia,Nil);

End;

Procedure About;
var
  Dia: XDialogP;
  R  : TRect;
  s  : string[55];

begin

 {s:=' '+commastr(memavail);
 }
 s:='';

 { no longer needed in GPL license
 if registered=1 then s:=' (Registered)'+s;
 }

 R.Assign(0, 0, 35, 17);
 Dia := New(XDialogP, Init(R, 'About'));
 With Dia^ do begin
  Options := Options or ofCentered;

  R.Grow(-1, -1);
  Dec(R.B.Y, 3);

  {Text}
  Insert(New(PStaticText, Init(R,
   #13 +
   ^C'Usurper Editor'+s + #13 +
   #13 + ^C+'Version '+ uver + #13 +
   #13 +
   ^C'GPL License 2007' + #13 +
   ^C'original game by ' + #13 +
   ^C'Jakob Dangarden' + #13 +
   #13 + ^C+'Ported to Win32 by' + #13 +
   ^C'Rick Parrish')));
  {1993,98}

  {Button}
  Okbutton(12,14);

 end; {with Dia do .end.}

 {Execute Dialog}
 MyApp.ExecuteDialog(Dia,Nil);

end;

Function YesNoBox(const toptext:string; const text:string) : boolean;
var
  R: TRect;
  D: XDialogP;
  Result : Word;
  x1,y1,x2,y2, i,cc:byte;
  maxy : integer;
  rows : byte;

begin

 maxy:=0;
 rows:=8;

 x1:=0;
 y1:=0;
 x2:=30;
 y2:=9;

 {checking max text length}
 cc:=1;
 for i:=1 to length(text) do begin
  if text[i]=#13 then begin
   if cc>maxy then begin
    maxy:=cc;
    inc(rows);
    cc:=0;
   end;
  end;
  inc(cc);
 end;

 if maxy=0 then begin
  if length(text) > (x2-4) then begin
   x2:=length(text)+4;
  end;
 end
 else begin
  if maxy > (x2-4) then begin
   x2:=maxy+4;
  end;
 end;

 if rows>y2 then begin
  y2:=rows;
 end;

 R.Assign(x1, y1, x2, y2);
 D := New(XDialogP, Init(R, toptext));
 With D^ do begin
  Options := Options or ofCentered;

  R.Grow(-1, -1);
  Dec(R.B.Y, 3);
  Insert(New(PStaticText, Init(R,
  #13 + ^C +text )));

  MakeButton(x1+4,y2-3,10,'~Y~es',cmYes,bfGrabFocus,hcGenYes);
  MakeButton(x1+16,y2-3,10,'~N~o' ,cmNo,bfGrabFocus,hcGenNo);
  SelectNext(false);

 end;

 result:=MyApp.ExecuteDialog(D,Nil);

 if result=CmYes then yesnobox:=true
                 else yesnobox:=false;

end; {YesNoBox *end*}

Function Bash_Name;
begin

 bash_name:='';
 case nr of
  1:bash_name:='Tackle';
  2:bash_name:='Drop-Kick';
  3:bash_name:='Uppercut';
  4:bash_name:='Bite';
  5:bash_name:='Leg-Sweep';
  6:bash_name:='JointBreak';
  7:bash_name:='Knifehand';
  8:bash_name:='Nerve Punch';
  9:bash_name:='Chokehold';
 10:bash_name:='Headbash';
 11:bash_name:='Pull Hair';
 12:bash_name:='Kick';
 13:bash_name:='Straight Punch';
 14:bash_name:='Ram';
 end; {case .end.}

end; {bash_name *end*}

Function Bash_Rank;
begin
 bash_rank:='';
 case nr of
  0:bash_rank:='Rotten';
  1:bash_rank:='Awful';
  2:bash_rank:='Lousy';
  3:bash_rank:='Pathetic';
  4:bash_rank:='Bad';
  5:bash_rank:='Poor';
  6:bash_rank:='Incompetent';
  7:bash_rank:='Below average';
  8:bash_rank:='Average';
  9:bash_rank:='Above Average';
 10:bash_rank:='Pretty good';
 11:bash_rank:='Competent';
 12:bash_rank:='Good';
 13:bash_rank:='Very good';
 14:bash_rank:='Extraordinary';
 15:bash_rank:='Excellent';
 16:bash_rank:='Superb';
 17:bash_rank:='*COMPLETE*';
 end; {case .end.}

end; {bash_rank *end*}

Function Race_Display;
begin

 case race of
  Human   : race_display:='Human';
  Hobbit  : race_display:='Hobbit';
  Elf     : race_display:='Elf';
  HalfElf : race_display:='Half-Elf';
  Dwarf   : race_display:='Dwarf';
  Troll   : race_display:='Troll';
  Orc     : race_display:='Orc';
  Gnome   : race_display:='Gnome';
  Gnoll   : race_display:='Gnoll';
  Mutant  : race_display:='Mutant';
 end; {case .end.}

end; {race_display *end*}

end. {UNIT *END*}
