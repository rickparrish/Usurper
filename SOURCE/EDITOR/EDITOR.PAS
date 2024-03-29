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

program Editor;

 {Usurper - DoorGame Editor}
 {Tools:Borland Pascal 7.0 and TurboVision 2.0}

                {to change version and year: look for uver in version.pas}

                {looking for the reset game proc? look in init.pas
                 Procedure ResDialog.HandleEvent(var Event:TEvent);}




uses
 {$IFDEF MSDOS}Overlay, {$ENDIF} Init, CfgVal, JakobE, muffi2, extra, file_io
 {$IFDEF FPC}, RPPort{$ENDIF};

{$IFDEF MSDOS}
  {---$O Addit}
  {---$O CfgHelp}
  {---$O helpfile}
  {$O CfgVal}
  {$O CfgDef}
  {$O Extra}
  {$O Edweap01}
  {$O Edweap}
  {$O Edweap2}
  {$O Edweap3}
  {$O Edmonst}
  {$O edface}          {*biker game*}
  {$O eddrink}         {*grave.diggers* *vultures* *slaves* *black hawks*}
  {$O edrings}         {undertaker,}
  {$O edshield}        {zonk,septic,death,buzzard,69,ferret,stinky,}
  {$O edbody} {bad max,scrag,hooks,toad,pinball,stone,midnight,}
  {$O edhead}{vanessa,stinkfinger,ferret}
  {$O edneck}
  {$O edarms}
  {$O edhands}
  {$O edwaist}
  {$O edfeets}
  {$O edabody}
  {$O edlegs}
  {$O edfood}
  {$O guardres}
  {$O levres}
  {$O mon_arm}
  {$O Npc}
  {$O resettn}
{$ENDIF}

var
  i:    longint;

  s: string;

  txt:  Text;

begin
  filemode := 66;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
{$IFDEF MSDOS}
  {Overlay}
  OvrFilemode := 64;
  OvrInit('EDITOR.OVR');
  OvrInitEMS;
{$ENDIF}

  {Assign some files}
  Assign(monsterfile, monfile);
  Assign(guardfile, gufile);
  Assign(levelfile, lvlfile);

  {Checking if DATA, SCORES and NODE directories exist}
  if direxist(global_datadir) = False then
  begin
    wrl('Directory "' + global_datadir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_datadir, 1, length(global_datadir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_datadir);
      halt;
    end;
  end;

  if direxist(global_nodedir) = False then
  begin
    wrl('Directory "' + global_nodedir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_nodedir, 1, length(global_nodedir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_nodedir);
      halt;
    end;
  end;

  if direxist(global_scoredir) = False then
  begin
    wrl('Directory "' + global_scoredir + '" doesn''t exist!');
    wrl('Creating...');
    s := copy(global_scoredir, 1, length(global_scoredir) - 1);
    if make_dir(s) = False then
    begin
      unable_to_createdir(global_scoredir);
      halt;
    end;
  end;

  {Check if the the datafiles should be created}
  Rewrite_DatFiles(False);

  add_fake := False;
  registered := 0;
  if f_exists(ucfg) = True then
  begin
    terminate;
  end;

  {new editor stuff}
  cfgchang := False;
  if f_exists(ucfg) then
  begin
    load_config;
  end else
  begin

    for i := 1 to maxallows do
    begin
      allowitem[i] := True;
    end;

    create_default_config(False);

  end;

  {creating ORIGINAL BACKUP, which saves changes before exit of program}
  for i := 1 to global_maxcdef do
  begin
    cfgurb[i] := cfgvalue[i];
  end;

  {bad solution here, should use streams I guess.}
  currp := 1;    {pointer to current user in NPC/PLAYER Editor}
  currg := 1;    {pointer to current doorguard in doorguard editor}
  currd := 1;    {pointer to current drink in drink editor}
  currm := 1;    {pointer to current monster in monster editor}
  curri := 1;    {pointer to current item in item editor}
  currmoat := 1; {pointer to current moat creature in the moat editor}
  currgod := 1; {pointer to current god in the god editor}
  currchild := 1; {pointer to current child in the children editor}

  depend := False;

  {Reading NEW or OLD Game mode}
  if open_txtfile(treset, txt, ucfg) then
  begin
    for i := 1 to 91 do
    begin
      readln_from_text(txt, s);
    end;
    close_text(txt);
  end else
  begin
    {unable to open Usurper.cfg}
    unable_To_access(ucfg);
  end;

  if upcasestr(s) = 'CLASSIC' then
    classic := True
  else classic := False;

  {the standard pascal randomize routine}
  Randomize;

  {turbo vision is running!}
  vision_is_running := True;

  {Run the Editor Application}
  {$IFNDEF FPC}
  i := memavail;
  if i <> memavail then
  begin
    wrl('Out of Heap space! (give me some memory!)');
  end else
  begin
  {$ENDIF}
    MyApp.init;
    MyApp.run;
    MyApp.done;
  {$IFNDEF FPC}
  end;
  {$ENDIF}

end. {End Of Program}
