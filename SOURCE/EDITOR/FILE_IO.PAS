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

unit File_Io; {Usurper Editor - File I/O Routines}

 {NOTE that all textfile related I/O is handled in OPENTXT.PAS}

interface

uses
  Init;

{used by file procedures/functions}
type FilAction = (FLoad, FSave, FLock, FUnlock);
  FilSize      = (FSPlayer,
    FSLevel,
    FSGuard,
    FSMonster,
    FSGod,
    FSChild,
    FSDrink,
    FSMoat); {Used by file procedures/functions}

 {used by opentxt.pas - textfile sharing routines, originally from SWAG}
type TShare = (Twhat,   {not used - free!}
    TRewrite,
    TAppend,
    TDelete,
    TReset);

{File I/O Error Displays}
procedure Unable_to_Access(const s: s70);
procedure Unable_to_Read(const s: s70);
procedure Unable_to_Write(const s: s70);
procedure Unable_to_Seek(const s: s70; recnr: word);
procedure Unable_to_Create(const s: s70);
procedure Unable_to_Close(const s: s70);
procedure Unable_to_FileSize(const s: s70);
procedure Unable_to_CreateDir(const s: s70);

{FileSize}
function FsClassic(weapon: boolean): word;
function Fs(filtyp: filsize): word;
function FsO(otyp: objtype): word;

{Load/Save}
procedure Load_Objekt(action: filaction; var Objektt: objektrec; otyp: objtype; filnr: word);
procedure Load_Player(action: filaction; var ply: userrec; gr: word);
procedure Load_Guard(action: filaction; var grd: guardrec; gr: word);
procedure Load_Moat(action: filaction; var mot: moatrec; gr: word);
procedure Load_God(action: filaction; var goddy: godrec; gr: word);
procedure Load_Child(action: filaction; var childy: childrec; gr: word);

procedure Load_Drink(action: filaction; var drnk: drinkrec; gr: word);
procedure Load_Level(action: filaction; var lev: levelrec; gr: word);
procedure Load_Weapon(nr: word; var inweap: weaprec);
procedure Load_Armor(nr: word; var inarm: armrec);
procedure Load_Monster(action: filaction; var mony: monsterrec; gr: word);

{Special}
function Init_DrinkFile: boolean;

{Misc}
procedure Rewrite_Datfiles(force: boolean);
function F_Exists(const s: string): boolean;
function Make_Dir(const s: string): boolean;
function DirExist(const st_dir: string): boolean;
procedure Delete_File(const fn: string);
procedure Move_File(const filen: string; dest: string);

{Textfiles}
function Open_TxtFile(action: tshare; var f; const fname: string): boolean;
procedure Readln_from_Text(var f: Text; var s: string);
procedure Write_To_Text(var f: Text; const s: string);
procedure Writeln_To_Text(var f: Text; const s: string);
procedure Close_Text(var f: Text);
function CalcHelpName(const wanted: string): string;

implementation

uses
  Dos, MsgBox, {$IFDEF MSDOS}TxtShare,{$ENDIF} Jakobe
  {$IFNDEF MSDOS}, Strings{$ENDIF} {$IFDEF FPC}, RPPort{$ENDIF};

const
  locknrs   = 100; {how many attempts to access a file?}
  lockdelay = 50; {time used by delay2 function in filelocking routines}

const {FILSHAR.PAS}
  fmReadOnly  = $00;  (* *)
  fmWriteOnly = $01;  (* Only one of these should be used *)
  fmReadWrite = $02;  (* *)

  fmDenyAll   = $10;  (* together With only one of these  *)
  fmDenyWrite = $20;  (* *)
  fmDenyRead  = $30;  (* *)
  fmDenyNone  = $40;  (* *)

  fmNoInherit = $70;  (* Set For "No inheritance"         *)


procedure Unable_to_Move(const f1, d1: s70);
begin

  {displayed when unable to move file f1 to directory d1}
  if vision_is_running then
  begin
    messagebox(#3'Unable to MOVE :' + f1 + ' to dir:' + d1, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Error! Unable to MOVE :' + f1 + ' to dir:' + d1);
  end;

end;

procedure Unable_to_Access(const s: s70);
begin
  {displayed when file access is denied}
  if vision_is_running then
  begin
    messagebox(#3'Unable to ACCESS : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to ACCESS : ' + s);
  end;
end;

procedure Unable_to_Create(const s: s70);
begin
  {displayed when unable to create file}
  if vision_is_running then
  begin
    messagebox(#3'Unable to CREATE : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to CREATE : ' + s);
  end;
end;

procedure Unable_to_Seek(const s: s70; recnr: word);
begin
  {displayed when unable to seek in file, record RECNR}
  if vision_is_running then
  begin
    messagebox(#3'Unable to SEEK RECORD : ' + commastr(recnr) + ' in:' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to SEEK RECORD : ' + commastr(recnr) + ' in:' + s);
  end;
end;

procedure Unable_to_Write(const s: s70);
begin
  {displayed when unable to write to file}
  if vision_is_running then
  begin
    messagebox(#3'Unable to WRITE to : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to WRITE to : ' + s);
  end;
end;

procedure Unable_to_Read(const s: s70);
begin
  {displayed when unable to read from file}
  if vision_is_running then
  begin
    messagebox(#3'Unable to READ from : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to READ from : ' + s);
  end;
end;

procedure Unable_to_Close(const s: s70);
begin
  {displayed when unable to close file}
  if vision_is_running then
  begin
    messagebox(#3'Unable to CLOSE : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to CLOSE : ' + s);
  end;
end;

procedure Unable_to_CreateDir(const s: s70);
begin
  {displayed when unable to Create a Directory}
  if vision_is_running then
  begin
    messagebox(#3'Unable to CREATE DIRECTORY : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to CREATE DIRECTORY : ' + s);
  end;
end;

procedure Unable_to_FileSize(const s: s70);
begin
  {displayed when filesize function fails}
  {displayed when unable to Create a Directory}
  if vision_is_running then
  begin
    messagebox(#3'Unable to get FILESIZE of : ' + s, nil, mfError + mfokbutton);
  end else
  begin
    wrl('Unable to get FILESIZE of : ' + s);
  end;

end;



function CalcHelpName(const wanted: string): string;
var
  EXEName: PathStr;
  Dir:     DirStr;
  Name:    NameStr;
  Ext:     ExtStr;
begin
  if Lo(DosVersion) >= 3 then
    EXEName := ParamStr(0)
  else EXEName := FSearch(Wanted, GetEnv('PATH'));
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = DIRECTORY_SEPARATOR then
    Dec(Dir[0]);

  CalcHelpName := FSearch(wanted, Dir);
end;

procedure Delete_File;
var
  f: file;
begin;
  Assign(f, fn);
 {$I-}erase(f);{$I+}
  if ioresult <> 0 then
  begin
    {error}
  end;
end;

function F_Exists;
var Inf: SearchRec;
begin
  findfirst(s, AnyFile, Inf);
  f_exists := (DOSError = 0);
{$IFNDEF MSDOS}
  FindClose(Inf);
{$ENDIF}
end;

function Make_Dir(const s: string): boolean;
begin
 {$I-}mkdir(s);{$I+}
  if IOResult <> 0 then
    make_dir := False
  else make_dir := True;
end;

procedure Move_File(const filen: string; dest: string);
var f: file;
begin

  if f_exists(filen) = False then
  begin
    {FILE NOT FOUND}
  end else
  begin
    dest := dest + filen;
    Assign(f, filen);
  {$I-} rename(f, dest); {$I+}
    if IOResult <> 0 then
    begin
      {error}
      unable_to_move(filen, dest);
    end else
    begin
      {OK}
    end;
  end;

end;

function DirExist(const st_Dir: string): boolean;
var
  wo_Fattr: word;
  fi_Temp:  file;
begin
  Assign(fi_Temp, (st_Dir + '.'));
  getfattr(fi_Temp, wo_Fattr);
  if (Doserror <> 0) then
    DirExist := False
  else
    DirExist := ((wo_Fattr and directory) <> 0);
end; { DirExist END, from SWAG }

function FsO;
var
  memmy, i: integer;
  ok:       boolean;
  ofil:     file of objektrec;

  fname:    s70;
begin

  Assign(ofil, objf1);

  case otyp of
    Head: fname := objf1;
    Body: fname := objf2;
    Arms: fname := objf3;
    Hands: fname := objf4;
    Fingers: fname := objf5;
    Legs: fname := objf6;
    Feet: fname := objf7;
    Waist: fname := objf8;
    Neck: fname := objf9;
    Face: fname := objf10;
    Shield: fname := objf11;
    Food: fname := objf12;
    Drink: fname := objf13;
    Weapon: fname := objf14;
    Abody: fname := objf15;
  end;

  {assign file}
  Assign(ofil, fname);

  fso := 0;
  i := 0;

  memmy := filemode;
  FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  repeat
    ok := True;
  {$I-}reset(ofil);{$I+}
    if IoResult <> 0 then
    begin
      Inc(i);
      delay2(lockdelay);
      ok := False;
    end;
  until (ok) or (i > locknrs);

 {$I-}fso := filesize(ofil);{$I+}
  if IOResult <> 0 then
    unable_to_filesize(fname);

 {$I-}Close(ofil);{$I+}
  if IOResult <> 0 then
    unable_to_close(fname);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

function FsClassic(weapon: boolean): word;
var
  memmy, i: integer;
  ok:       boolean;

var {Classic Weapon and Armor files}
  WeapFile: file of WeapRec;
  ArmFile:  file of ArmRec;

begin

  if weapon then
    Assign(weapfile, weapofile)
  else Assign(armfile, armofile);

  fsclassic := 0;
  i := 0;

  memmy := filemode;
  FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  repeat
    ok := True;
    if weapon then
    begin
   {$I-}reset(weapfile);{$I+}
    end else
    begin
   {$I-}reset(armfile);{$I+}
    end;
    if IoResult <> 0 then
    begin
      Inc(i);
      delay2(lockdelay);
      ok := False;
    end;
  until (ok) or (i > locknrs);

  if weapon then
  begin
  {$I-}fsclassic := filesize(weapfile);{$I+}
    if IOResult <> 0 then
      unable_to_filesize(weapofile);

  {$I-}Close(weapfile);{$I+}
    if IOResult <> 0 then
      unable_to_close(weapofile);
  end else
  begin
  {$I-}fsclassic := filesize(armfile);{$I+}
    if IOResult <> 0 then
      unable_to_filesize(armofile);

  {$I-}Close(armfile);{$I+}
    if IOResult <> 0 then
      unable_to_close(armofile);
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

function Fs(filtyp: filsize): word;
var
  memmy, i: integer;
  ok:       boolean;

begin

  fs := 0;
  i := 0;

  memmy := filemode;
  FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  case filtyp of
    FsPlayer: begin {player/npc file}
      repeat
        ok := True;
        {$I-}reset(playerfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(playerfile);{$I+}
      if IOresult <> 0 then
        unable_to_filesize(global_pfile + ' / ' + global_npfile);

       {$I-}Close(playerfile);{$I+}
      if IOresult <> 0 then
        unable_to_close(global_pfile + ' / ' + global_npfile);

    end;
    FsLevel: begin {Level limits}
      repeat
        ok := True;
        {$I-}reset(levelfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(levelfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(lvlfile);

       {$I-}Close(levelfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(lvlfile);

    end;
    FsGuard: begin {DoorGuards}
      repeat
        ok := True;
        {$I-}reset(guardfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(guardfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(gufile);

       {$I-}Close(guardfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(gufile);

    end;
    FsMonster: begin {Monsters}
      repeat
        ok := True;
        {$I-}reset(monsterfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(monsterfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(Monfile);

       {$I-}Close(monsterfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(Monfile);

    end;
    FsDrink: begin {Drinks}

      Assign(cocktailfile, drinkfile);
      repeat
        ok := True;
        {$I-}reset(cocktailfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(cocktailfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(drinkfile);

       {$I-}Close(cocktailfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(drinkfile);

    end;

    FsMoat: begin {Moat Creature file}

      Assign(moatfile, motfile);
      repeat
        ok := True;
        {$I-}reset(moatfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(moatfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(motfile);

       {$I-}Close(moatfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(motfile);

    end;         {moat *end*}
    FsGod: begin {God file}

      Assign(godfile, godsf);
      repeat
        ok := True;
        {$I-}reset(godfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(godfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(godsf);

       {$I-}Close(godfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(godsf);

    end;           {god *end*}

    FsChild: begin {Child file}

      Assign(childfile, childrenf);
      repeat
        ok := True;
        {$I-}reset(childfile);{$I+}
        if IoResult <> 0 then
        begin
          Inc(i);
          delay2(lockdelay);
          ok := False;
        end;
      until (ok) or (i > locknrs);

       {$I-}fs := filesize(childfile);{$I+}
      if IOResult <> 0 then
        unable_to_filesize(childrenf);

       {$I-}Close(childfile);{$I+}
      if IOResult <> 0 then
        unable_to_close(childrenf);

    end; {child *end*}

  end;   {case .end.}

         {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Objekt;
var
  i:  word;
  ofil:  file of ObjektRec;
  memmy: integer;
  ok:    boolean;
  fname: s90;

begin

  fname := objf1;

  case otyp of
    Head: fname := objf1;
    Body: fname := objf2;
    Arms: fname := objf3;
    Hands: fname := objf4;
    Fingers: fname := objf5;
    Legs: fname := objf6;
    Feet: fname := objf7;
    Waist: fname := objf8;
    Neck: fname := objf9;
    Face: fname := objf10;
    Shield: fname := objf11;
    Food: fname := objf12;
    Drink: fname := objf13;
    Weapon: fname := objf14;
    Abody: fname := objf15;
  end;


  {assign filename}
  Assign(ofil, fname);

  i := 0;
  memmy := filemode;

  repeat
    ok := True;
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      FSave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  {$I-}reset(ofil);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > locknrs);

 {$I-}seek(ofil, filnr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_seek(fname, filnr - 1);

  case action of
    Fload: begin
         {$I-}Read(ofil, objektt);{$I+}
      if IOResult <> 0 then
        unable_to_read(fname);
    end;
    FSave: begin
         {$I-}Write(ofil, objektt);{$I+}
      if IOResult <> 0 then
        unable_to_write(fname);
    end;
  end;

 {$I-}Close(ofil);{$I+}
  if IOResult <> 0 then
    unable_to_close(fname);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Player;
const fname = 'PLAYER/NPC FILE';
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

  {case allmodd of
   1: assign(playerfile,pfile);
   2: assign(playerfile,npfile);
  end;}

    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(playerfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(playerfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_seek(fname, gr - 1);
  case action of
    Fload: begin
         {$I-}Read(playerfile, ply);{$I+}
      if IOResult <> 0 then
        unable_to_read(fname)
      else ply.recnr := gr;
    end;
    Fsave: begin
         {$I-}Write(playerfile, ply);{$I+}
      if IOResult <> 0 then
        unable_to_write(fname);
    end;
  end;

 {$I-}Close(playerfile);{$I+}
  if IOResult <> 0 then
  begin
    unable_to_close(fname);
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {load_player *end*}

procedure Load_Guard;
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(guardfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(guardfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_To_seek(gufile, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(guardfile, grd);{$I+}
      if IOResult <> 0 then
        unable_to_read(gufile);
    end;
    Fsave: begin
         {$I-}Write(guardfile, grd);{$I+}
      if IOResult <> 0 then
        unable_to_write(gufile);
    end;
  end;

 {$I-}Close(guardfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(gufile);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Moat;
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(moatfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(moatfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_To_seek(motfile, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(moatfile, mot);{$I+}
      if IOResult <> 0 then
        unable_to_read(motfile);
    end;
    Fsave: begin
         {$I-}Write(moatfile, mot);{$I+}
      if IOResult <> 0 then
        unable_to_write(motfile);
    end;
  end;

 {$I-}Close(moatfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(motfile);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {load_moat .end.}

procedure Load_God; {load/save immortal}
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(godfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(godfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_To_seek(godsf, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(godfile, goddy);{$I+}
      if IOResult <> 0 then
        unable_to_read(godsf);
    end;
    Fsave: begin
         {$I-}Write(godfile, goddy);{$I+}
      if IOResult <> 0 then
        unable_to_write(godsf);
    end;
  end;

 {$I-}Close(godfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(godsf);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {load_god .end.}

procedure Load_Child; {load/save child}
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(childfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(childfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_To_seek(childrenf, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(childfile, childy);{$I+}
      if IOResult <> 0 then
        unable_to_read(childrenf);
    end;
    Fsave: begin
         {$I-}Write(childfile, childy);{$I+}
      if IOResult <> 0 then
        unable_to_write(childrenf);
    end;
  end;

 {$I-}Close(childfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(childrenf);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {load_child .end.}


function Init_DrinkFile: boolean; {user drinks created at Orbs Bar}
var
  Result: boolean;
  i:      byte;
  drink:  drinkrec;

begin

  {init vars}
  Result := False;
  i := 0;

  {assign drinkfile}
  Assign(cocktailfile, drinkfile);

  {rewrite drinkfile}
  repeat
  {$I-}rewrite(cocktailfile);{$I+}
    if IOResult <> 0 then
    begin
      unable_to_create(drinkfile);
    end else
    begin
      Result := True;
    end;
    Inc(i);
  until (Result = True) or (i > 7);

  if Result then
  begin

    {setup defult drink}
    drink.Name := 'Dads Nightmare'; {name of drink}
    drink.creator := 'Big Boss'; {creator}
    drink.date := todays_date; {string[8]}
    drink.comment := 'this is good for you!';     {comment}
    drink.ordered := 1; {how many times have the drink been used/drank}
    drink.lasthad := 'Big Boss'; {last customer that has the drink}
    drink.lastrac := troll;  {last customers race}
    drink.deleted := False; {deleted?}
    drink.secret := False; {secret recipe? creators choice}
    for i := 1 to 17 do
    begin
      drink.amount[i] := 0; {ingredients}
    end;
    drink.amount[1] := 50;
    drink.amount[2] := 25;
    drink.amount[3] := 10;
    drink.amount[4] := 10;
    drink.amount[6] := 5;

  {$I-}Write(cocktailfile, drink);{$I+}
    if IOResult <> 0 then
    begin
      unable_to_write(drinkfile);
      Result := False;
    end;

  {$I-}Close(cocktailfile);{$I+}
    if IOResult <> 0 then
    begin
      unable_to_close(drinkfile);
      Result := False;
    end;

  end;

  {return result}
  init_drinkfile := Result;

end; {init_drinkfile *end*}

procedure Load_Drink; {load Drink}
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  Assign(cocktailfile, drinkfile);
  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(cocktailfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(cocktailfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_To_seek(drinkfile, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(cocktailfile, drnk);{$I+}
      if IOResult <> 0 then
        unable_to_read(drinkfile);
    end;
    Fsave: begin
         {$I-}Write(cocktailfile, drnk);{$I+}
      if IOResult <> 0 then
        unable_to_write(drinkfile);
    end;
  end;

 {$I-}Close(cocktailfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(drinkfile);

  {restore filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {load_drink *end*}

procedure Load_Level;
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      Fsave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(levelfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(levelfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_seek(lvlfile, gr - 1);

  case action of
    Fload: begin
         {$I-}Read(levelfile, lev);{$I+}
      if IOresult <> 0 then
        unable_to_read(lvlfile);
    end;
    Fsave: begin
         {$I-}Write(levelfile, lev);{$I+}
      if IOResult <> 0 then
        unable_to_write(lvlfile);
    end;
  end;
 {$I-}Close(levelfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(lvlfile);
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Monster;
var
  memmy: integer;
  i:     integer;
  ok:    boolean;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;

    {set filemode}
    case action of
      Fload: FileMode := fmReadOnly + fmDenyNone;
      FSave: FileMode := fmReadWrite + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(monsterfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > 20);

 {$I-}seek(monsterfile, gr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_Seek(monfile, gr - 1);

  case action of
    Fload: begin
        {$I-}Read(monsterfile, mony);{$I+}
      if IOResult <> 0 then
        unable_to_read(monfile);
    end;
    FSave: begin
         {$I-}Write(monsterfile, mony);{$I+}
      if IOResult <> 0 then
        unable_to_write(monfile);
    end;
  end;

 {$I-}Close(monsterfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(monfile);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Weapon;
var i, memmy: integer;
  ok:         boolean;
  WeapFile:   file of WeapRec;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;
    Assign(weapfile, weapofile);

    FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}

  {$I-}reset(weapfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > locknrs);

 {$I-}Seek(weapfile, nr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_seek(weapofile, nr - 1);

 {$I-}Read(weapfile, inweap);{$I+}
  if IOResult <> 0 then
    unable_to_read(weapofile);

 {$I-}Close(weapfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(weapofile);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Load_Armor;
var i, memmy: integer;
  ok:         boolean;
  ArmFile:    file of ArmRec;

begin

  i := 0;
  memmy := filemode;

  repeat
    ok := True;
    Assign(armfile, armofile);
    FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  {$I-}reset(armfile);{$I+}

    if IOResult <> 0 then
    begin
      delay2(lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > locknrs);

 {$I-}Seek(armfile, nr - 1);{$I+}
  if IOResult <> 0 then
    unable_to_seek(armofile, nr - 1);

 {$I-}Read(armfile, inarm);{$I+}
  if IOResult <> 0 then
    unable_to_read(armofile);

 {$I-}Close(armfile);{$I+}
  if IOResult <> 0 then
    unable_to_close(armofile);

  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

procedure Rewrite_Datfiles(force: boolean);
begin

  if (not f_exists(objf1)) or (force) then
  begin
    Assign(ofil, objf1);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf1);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf1);

  end;
  if not f_exists(objf2) or (force) then
  begin
    Assign(ofil, objf2);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf2);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf2);

  end;
  if not f_exists(objf3) or (force) then
  begin
    Assign(ofil, objf3);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf3);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf3);

  end;
  if not f_exists(objf4) or (force) then
  begin
    Assign(ofil, objf4);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf4);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf4);

  end;
  if not f_exists(objf5) or (force) then
  begin
    Assign(ofil, objf5);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf5);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf5);

  end;
  if not f_exists(objf6) or (force) then
  begin
    Assign(ofil, objf6);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf6);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf6);

  end;
  if not f_exists(objf7) or (force) then
  begin
    Assign(ofil, objf7);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf7);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf7);

  end;
  if not f_exists(objf8) or (force) then
  begin
    Assign(ofil, objf8);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf8);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf8);

  end;
  if not f_exists(objf9) or (force) then
  begin
    Assign(ofil, objf9);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf9);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf9);

  end;
  if not f_exists(objf10) or (force) then
  begin
    Assign(ofil, objf10);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf10);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf10);

  end;
  if not f_exists(objf11) or (force) then
  begin
    Assign(ofil, objf11);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf11);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf11);

  end;
  if not f_exists(objf12) or (force) then
  begin
    Assign(ofil, objf12);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf12);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf12);

  end;
  if not f_exists(objf13) or (force) then
  begin
    Assign(ofil, objf13);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf13);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf13);

  end;
  if not f_exists(objf14) or (force) then
  begin
    Assign(ofil, objf14);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf14);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf14);

  end;
  if not f_exists(objf15) or (force) then
  begin
    Assign(ofil, objf15);
  {$I-}rewrite(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_create(objf15);

  {$I-}Close(ofil);{$I+}
    if IOResult <> 0 then
      unable_to_close(objf15);

  end;

end;

function Open_TxtFile;

var
  i:          word;
  IORes:      integer;
  tries:      byte;
  txt:        Text;
  memmy:      integer;
  lockmde:    byte;
{$IFNDEF MSDOS}
  memmy_r:    integer;
  memmy_rw:   integer;
  lockmde_r:  byte;
  lockmde_rw: byte;
{$ENDIF}
begin

  memmy := filemode;
{$IFNDEF MSDOS}
  memmy_r := TextModeRead;
  memmy_rw := TextModeReadWrite;
{$ENDIF}

  if f_exists(fname) = False then
  begin
    Assign(txt, fname);
    rewrite(txt);
    Close(txt);
  end;

  lockmde := filemode;
{$IFNDEF MSDOS}
  lockmde_r := TextModeRead;
  lockmde_rw := TextModeReadWrite;
{$ENDIF}

  i := 0;
  tries := 50;


{ if action=Treset then begin
  FileMode:=fmReadOnly+fmDenyNone;
 end
 else begin
  FileMode:=fmReadWrite+fmDenyAll;
 end;
 }

  repeat
{$IFDEF MSDOS}
    AssignText(Text(f), Fname);  (* From TxtShare unit *)
{$ENDIF}
{$IFNDEF MSDOS}
    Assign(Text(f), FName);
{$ENDIF}

    case action of
      Treset: FileMode := fmReadOnly + fmDenyNone;
      Tappend: FileMode := fmWriteOnly + fmDenyWrite;
      TDelete: FileMode := fmWriteOnly + fmDenyAll;
      TRewrite: FileMode := fmWriteOnly + fmDenyAll;
    end;
{$IFNDEF MSDOS}
    TextModeRead := FileMode;
    TextModeReadWrite := FileMode;
{$ENDIF}

  {$I-}Reset(Text(f));{$I+}
    IORes := IoResult;
    if IORes <> 0 then
    begin         (* Only repeat if denied access *)
      if (ubeta) then
      begin
    {d(2,'* Waiting for file access (text) *');
    {case action of
     2: display(0,14,0,' REWRITE '+fname);
     3: display(0,14,0,' APPEND '+fname);
     4: display(0,14,0,' CLOSE '+fname);
     5: display(0,14,0,' RESET '+fname);
    end;}
      end;
      delay2(lockdelay);    (* Wait 1/10 second before retry *)
      Inc(i);               (* Use your own delay routine here *)
    end else
    begin
      i := tries;        (* Quit if not a sharing deny *)
    end;
  until (IORes = 0) or (i >= tries);

  FileMode := lockmde;    (* Set FileMode to default *)
{$IFNDEF MSDOS}
  TextModeRead := lockmde_r;
  TextModeReadWrite := lockmde_rw;
{$ENDIF}

  if IORes = 0 then
  begin
    case action of
      TRewrite: begin
        rewrite(Text(f));
      end;
      Tappend: begin
        append(Text(f));
      end;
      TDelete: begin
             {$I-}
        Close(Text(f));
             {$I+}
        if ioresult <> 0 then
        begin

        end;
        delete_file(fname);
      end;
      TReset: begin
        {reset(text(f));}
      end;

    end;
  end;

  {Reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  TextModeRead := memmy_r;
  TextModeReadWrite := memmy_rw;
{$ENDIF}

  if IOREs <> 0 then
    Open_TxtFile := False
  else open_txtfile := True;

end;

procedure Close_Text(var f: Text);
begin

 {$I-}Close(f);{$I+}
{$IFDEF MSDOS}
  if IOResult <> 0 then
    unable_to_close(textrec(f).Name);
{$ENDIF}
{$IFNDEF MSDOS}
  if IOResult <> 0 then
    unable_to_close(StrPas(textrec(f).Name));
{$ENDIF}
end;

procedure Readln_from_Text(var f: Text; var s: string);
begin
 {$I-}readln(f, s);{$I+}
{$IFDEF MSDOS}
  if IOResult <> 0 then
    unable_to_read(textrec(f).Name);
{$ENDIF}
{$IFNDEF MSDOS}
  if IOResult <> 0 then
    unable_to_read(StrPas(textrec(f).Name));
{$ENDIF}
end;

procedure Write_To_Text(var f: Text; const s: string);
begin
 {$I-}Write(f, s);{$I+}
{$IFDEF MSDOS}
  if IOResult <> 0 then
    unable_to_write(textrec(f).Name);
{$ENDIF}
{$IFNDEF MSDOS}
  if IOResult <> 0 then
    unable_to_write(StrPas(textrec(f).Name));
{$ENDIF}
end;

procedure Writeln_To_Text(var f: Text; const s: string);
begin
 {$I-}writeln(f, s);{$I+}
{$IFDEF MSDOS}
  if IOResult <> 0 then
    unable_to_write(textrec(f).Name);
{$ENDIF}
{$IFNDEF MSDOS}
  if IOResult <> 0 then
    unable_to_write(StrPas(textrec(f).Name));
{$ENDIF}
end;

end. {Unit File_Io .end.}
