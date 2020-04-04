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


unit File_IO; {Usurper - File I/O routines
               see also file_io2.pas}

interface

uses
  Init, InitGods, Gym {$IFDEF FPC}, RPPort{$ENDIF};

var  {Global_Textbuffer:
      4095 should it read if you are looking for speed. I got low on
      memory and had to reduce this value, I hate the 64kb limit!}

  Global_TextBuffer:        array[1..1024] of char; {speeds up textfile handling}
  global_lockdelay:         word; {how long should filelocking procs pause/milliseconds}
  global_online_poll_delay: word; {how long should online polls pause (in milliseconds) before next poll}
                             {see various.pas for init value}

const global_locknrs: byte = 75; {how many times should filelocking be attempted}
  access_error = 5;          {unable_to_access(filename). generic error mess}

const global_bardlines = 12; {change text in create_bardsongfile also}
type bardtype = array [1..global_bardlines] of s70;

{FilSize: used by the fs(xx) function}
type FilSize = (FsPlayer, FsNPC, FsLevel, FsGuard, FsMonster,
    FsArmorclassic, FsWeaponclassic, FsMail, FsMarket,
    FsBrawl, FsOnline, FsWanted, FsDrink, FsQuest,
    FsMoat, FsRelation, FsChildren, FsGod, FsBarrel, FsChestItem);

{used by the pack routines, when called from the command line}
type PackAction = (PUsers, PNpcs);

type {used to instruct the open_txtfile function - textfile sharing routines}
  TShare = (TRewrite, TAppend, TDelete, TReset);

var Global_Onlinefile:     file of OnlineRec; {used to lock the onliners.dat}
var Global_OnlinefileSize: longint; {global_onlinefile filesize}

var Global_RelationFile:     file of RelationRec; {social relations file}
var Global_RelationFileSize: longint; {global_relationfile filesize}

var Global_MailFile:     file of MailRec; {mail file}
var Global_MailFileSize: longint; {global_mailfile filesize}

var Global_OnDuelfile: file of ComRec; {used to lock online duels com file}
var Global_QuestFile:  file of QuestRec; {royal quest-file}

 {File I/O Error Messages}
function Error_Message(const code: integer): s70; {Borland Pascal Error Messages}
procedure Unable_to_Access(const s: s70; const error: integer);
procedure Unable_to_Write(const s: s70; const error: integer);
procedure Unable_to_Read(const s: s70; const error: integer);
procedure Unable_to_Seek(const s: s70; const recnr: word);

procedure Unable_to_LockFile(const s: s70);
procedure Unable_to_Close(const s: s70; const error: integer);
procedure Unable_to_Create(const s: s70; const error: integer);
procedure Unable_to_CreateDir(const s: s70; const error: integer);
procedure Unable_to_Find(const s: s70);
procedure Unable_to_Delete(const s: s70; const error: integer);
procedure Unable_to_Append(const s: s70);
procedure Fatal(const missing: s70);

{Multi Node Chat routines}
var MyIpc:  IpcType; {players ipc record}
  Scanning: boolean;

procedure Init_Ipc(const ply: UserRec); {preparing a IPC record for use}
procedure Multi_Chat; {Chat with user(s) in a conference}
procedure IPCHook; {called upon from DDplus.pas to check for pending messages}

 {Lock Record Procs}
function Lock_OnlineRecord(action: filaction; filnr: longint): boolean;
function Lock_UserRecord(var fil; const infil: s70; action: filaction; filnr: longint): boolean;
function Lock_MailRecord(var fil; action: filaction; filnr: longint): boolean;

{Lock File Procs}
function Lock_OnlineFile(action: filaction): boolean;
function Load_OnlineFile(action: filaction; var slask: onlinerec; filnr: longint): boolean;

function Lock_QuestFile(action: filaction): boolean;
procedure Load_QuestFile(action: filaction; var slask: QuestRec; filnr: longint);

function Lock_RelationFile(action: filaction): boolean;
procedure Load_RelationFile(action: filaction; var slask: RelationRec; filnr: longint);

function Lock_MailFile(action: filaction): boolean;
procedure Load_MailFile(action: filaction; var slask: MailRec; filnr: longint);

function Lock_OnDuelFile(action: filaction): boolean;
procedure Load_OnDuelFile(action: filaction; var slask: comrec; filnr: longint);

{Load/save procedures}
procedure Append_OnlineGuy(var Person: OnlineRec);
procedure Load_Wanted(action: filaction; var slask: WantedRec; filnr: word);
procedure Load_Guard(action: filaction; var slask: GuardRec; filnr: word);
procedure Load_Moat(action: filaction; var slask: MoatRec; filnr: word);
procedure Load_Market(action: filaction; var slask: MarketItemRec; filnr: word);
procedure Load_ChestItem(action: filaction; var slask: ChestItemRec; filnr: word);
function Load_BardSong(var bardsong: bardtype; const nr: word): boolean;
function Load_Drink(action: filaction; var slask: DrinkRec; filnr: word): boolean;
function Load_Relation(action: filaction; var slask: RelationRec; filnr: word): boolean;
function Load_Child(action: filaction; var slask: ChildRec; filnr: word): boolean;
procedure Load_Barrel(action: filaction; var slask: BarrelRec; filnr: word);
function Load_God(action: filaction; var slask: GodRec; filnr: word): boolean;
function Load_Onliner(action: filaction; var slask: OnlineRec; filnr: longint): boolean;
procedure Load_Mail(action: filaction; var slask: MailRec; filnr: word);
procedure Load_Quest(action: filaction; var slask: QuestRec; filnr: word);
function Load_Objekt(var Objektt: orec; otyp: objtype; filnr: word): boolean;
function Load_Character(var slask: userrec; filtyp: byte; recnr: word): boolean;
procedure Load_King(action: filaction; var king: KingRec);
procedure Load_Weapon(filnr: word; var inweap: weaprec);
procedure Load_Armor(filnr: word; var inarm: armrec);
procedure Load_Monster(filnr, monnr: word);
procedure Load_Level(filnr: word; var lev: LevelRec);
procedure User_Save(var Save_Me: UserRec);
procedure Save_New_Guy(slot: word);

 {Filesize functions}
function Fs(filtyp: filsize): word; {file size of particular record file}
function FsOb(otyp: objtype): word; {file size of particular item file}

 {Bank Safe}
procedure Safe_Reset; {reset the bank safe, after a robbery...}
procedure Load_Safe(action: filaction; var slask: saferec);

 {Pack Record files}
procedure Pack_Gods; {pack gods data-file with /DO_PACKGODS command line parameter}
procedure Pack_Children; {pack children data-file file with /DO_PACKCHILDREN command line parameter}
procedure Pack_Relations; {pack relations file with /DO_PACKRELATIONS command line parameter}
procedure Pack_Mail; {pack mailfile with /DO_PACKMAIL command line parameter}
procedure Pack_Moat; {pack moat file with /DO_PACKMOAT command line parameter}
procedure Pack_Users(action: packaction); {pack userfile with /DO_PACKUSERS command line parameter}

 {Inter-Comm procs, node to node}
procedure LoadSave_Com(action: filaction; var commy: comrec; filnr: byte; save_mess: s70);

{Misc}
function F_Exists(const fn: string): boolean;
function Make_Dir(const s: string): boolean;
function DirExist(const st_Dir: string): boolean;
function Rename_File(const s1: string; const s2: string): boolean;
procedure Move_File(const filen: string; dest: string);
function Delete_File(const fn: string): boolean;
procedure Display_File(const s: string);
function File_Stamp_Info2(const fname: string; inclusions: byte): s70;

{Create Data Files}
procedure Create_OnlineFile;
function Create_FakePlayerFile: boolean;
function Create_TeamNameFile: boolean;
function Create_BardsongFile: boolean;

{Textfile related}
function Open_Txtfile(action: tshare; var f; const fname: string): boolean;
function Get_Random_Line_From_Textfile(const fname: string): string;
procedure Pack_Txtfile(const fname: s70; max_lines: word);
procedure Write_To_Inn_File(const Sender, m1, m2, m3, m4, m5: s70);
procedure Check_TruthFile(inmaint: boolean);
procedure Write_To_Truth_File(const Sender: string; const mess: string);
procedure Readln_from_Text(var f: Text; var s: string);
procedure Write_To_Text(var f: Text; const s: string);
procedure Writeln_To_Text(var f: Text; const s: string);
procedure Close_Text(var f: Text);


implementation

uses
  Crt, Dos, CMS, Elog,
  DDplus, DDScott, Jakob,
  Various, {$IFDEF MSDOS}TxtShare,{$ENDIF} AnsiColr,
  Mail, Invent, Relatio2,
  JakeLock, Online {$IFNDEF MSDOS}, Strings{$ENDIF};

const
 {item data files, the reason for not declaring these constants in INIT.PAS
  is that they are only referenced here! (we save memory!)}
  objf1  = global_datadir + 'OBJDAT01.DAT'; {Head}
  objf2  = global_datadir + 'OBJDAT02.DAT'; {Body}
  objf3  = global_datadir + 'OBJDAT03.DAT'; {Arms}
  objf4  = global_datadir + 'OBJDAT04.DAT'; {Hands}
  objf5  = global_datadir + 'OBJDAT05.DAT'; {Fingers}
  objf6  = global_datadir + 'OBJDAT06.DAT'; {Legs}
  objf7  = global_datadir + 'OBJDAT07.DAT'; {Feet}
  objf8  = global_datadir + 'OBJDAT08.DAT'; {Waist}
  objf9  = global_datadir + 'OBJDAT09.DAT'; {Neck}
  objf10 = global_datadir + 'OBJDAT10.DAT'; {Face}
  objf11 = global_datadir + 'OBJDAT11.DAT'; {Shield}
  objf12 = global_datadir + 'OBJDAT12.DAT'; {Food}
  objf13 = global_datadir + 'OBJDAT13.DAT'; {Drink}
  objf14 = global_datadir + 'OBJDAT14.DAT'; {Weapon}
  objf15 = global_datadir + 'OBJDAT15.DAT'; {Abody}

const {coming from FILSHAR.PAS, SWAG}
  fmReadOnly  = $00;  (* *)
  fmWriteOnly = $01;  (* Only one of these should be used *)
  fmReadWrite = $02;  (* *)

  fmDenyAll   = $10;  (* together With only one of these  *)
  fmDenyWrite = $20;  (* *)
  fmDenyRead  = $30;  (* *)
  fmDenyNone  = $40;  (* *)

  fmNoInherit = $70;  (* Set For "No inheritance"         *)
      {coming from FILSHAR.PAS, SWAG .. END}

const error_col = 12; {display color of i/o errors}
  error_mes     = 'File-Alert! '; {displayed before actual error message}

function Error_Message(const code: integer): s70;
      {return message text for a given runtime error code
       this proc was taken from the elog.pas (DDplus doordriver}
var
  class: s70;
  Msg:       s70;
begin

  case code of
    1.. 99: class := 'DOS ERROR #' + long2str(code) + ' :';
    100..149: class := 'I/O ERROR #' + long2str(code) + ' :';
    150..199: class := 'CRITICAL ERROR #' + long2str(code) + ' :';
    200..249: class := 'FATAL ERROR #' + long2str(code) + ' :';
    else class := 'UNKNOWN ERROR #' + long2str(code) + ' :';
  end; {case .end.}

  case Code of
    2: Msg := 'File not found';
    3: Msg := 'Path not found';
    4: Msg := 'Too many open files';
    5: Msg := 'File access denied';
    6: Msg := 'Bad file handle';
    12: Msg := 'Bad file access code';
    15: Msg := 'Bad drive number';
    16: Msg := 'Can''t remove current dir';
    17: Msg := 'Can''t rename across drives';

    100: Msg := 'Disk read error, read past eof on Typed File';
    101: Msg := 'Disk write error';
    102: Msg := 'File not assigned';
    103: Msg := 'File not open';
    104: Msg := 'File not open for input';
    105: Msg := 'File not open for output';
    106: Msg := 'Bad numeric format';

    150: Msg := 'Disk is write-protected';
    151: Msg := 'Unknown diskette unit';
    152: Msg := 'Drive not ready';
    153: Msg := 'Unknown command';
    154: Msg := 'CRC error in data';
    155: Msg := 'Bad drive request structure length';
    156: Msg := 'Disk seek error';
    157: Msg := 'Unknown diskette type';
    158: Msg := 'Sector not found';
    159: Msg := 'Printer out of paper';
    160: Msg := 'Device write fault';
    161: Msg := 'Device read fault';
    162: Msg := 'Hardware failure';

    200: Msg := 'Division by zero';
    201: Msg := 'Range check';
    202: Msg := 'Stack overflow';
    203: Msg := 'Heap overflow' + ' (Not enough memory to run)';
    204: Msg := 'Bad pointer operation';
    205: Msg := 'Floating point overflow';
    206: Msg := 'Floating point underflow';
    207: Msg := 'Bad floating point operation';

    else str(Code, Msg);
  end; {case .end.}

       {return result}
  Error_message := class + Msg;

end; {error_message **END**}

procedure Fatal(const missing: s70);
begin {displayed when (data) file is missing}
  clearscreen;
  crlf;
  d(12, 'ERROR!');
  sd(config.textcolor, ' Could not find vital DATA file :');
  d(15, missing);
  d(config.textcolor, ' Make sure that you are in the right Directory.');
  d(config.textcolor, ' You can also reset the .DAT files with the EDITOR.EXE program.');
  d(config.textcolor, ' Inform Sysop!');
  crlf;
  pause;
  halt;
end; {fatal *end*}

procedure Unable_to_Read_Character(const s: s70; const recnr: word);
begin
  {displayed when file access is denied}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to READ Record #' + commastr(recnr) + ' from ' + s);
  end;
end;

procedure Unable_to_Access(const s: s70; const error: integer);
begin
  {displayed when file access is denied}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Denied ACCESS : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

procedure Unable_to_Move(const f1, d1: s70);
begin
  {displayed when unable to move file F to directory D}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to move file:' + f1 + ' to dir:' + d1);
  end;
end;

procedure Unable_to_Rename(const s1, s2: s70);
begin
  {displayed when RENAME procedure fails}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to RENAME "' + s1 + '" to "' + s2 + '"');
  end;
end;

procedure Unable_to_FileSize(const s: s70);
begin
  {displayed when filesize function fails}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to get FILESIZE of : ' + s);
  end;
end;

procedure Unable_to_Delete(const s: s70; const error: integer);
begin
  {displayed when file can't be deleted}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to DELETE : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

procedure Unable_to_Find(const s: s70);
begin
  {displayed when file not found}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'File not Found : ' + s);
  end;
end;

procedure Unable_to_Seek(const s: s70; const recnr: word);
begin
  {displayed when unable to seek in file, record RECNR}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to SEEK RECORD:' + commastr(recnr) + ' in : ' + s);
  end;
end;

procedure Unable_to_Lock(const s: s70; recnr: word);
begin
  {displayed when unable to lock record, record RECNR}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to LOCK RECORD:' + commastr(recnr) + ' in : ' + s);
  end;
end;

procedure Unable_to_LockFile(const s: s70);
begin
  {displayed when unable to lock file S}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to LOCK file:' + s);
  end;
end;

procedure Unable_to_UnLock(const s: s70; recnr: word);
begin
  {displayed when unable to Unlock record, record RECNR}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to UNLOCK RECORD:' + commastr(recnr) + ' in : ' + s);
  end;
end;

procedure Unable_to_Write(const s: s70; const error: integer);
begin

  {displayed when unable to write to file}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to WRITE : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;

end;

procedure Unable_to_Read(const s: s70; const error: integer);
begin
  {displayed when unable to read from file}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to READ : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

procedure Unable_to_Close(const s: s70; const error: integer);
begin
  {displayed when unable to close file}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to CLOSE : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

procedure Unable_to_Append(const s: s70);
begin
  {displayed when unable to append to file}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to APPEND : ' + s);
  end;
end;

procedure Unable_to_Create(const s: s70; const error: integer);
begin
  {displayed when unable to create file}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to CREATE : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

procedure Unable_to_CreateDir(const s: s70; const error: integer);
begin
  {displayed when unable to create directory}
  if (config.errors) then
  begin
    d(error_col, error_mes + 'Unable to CREATE DIRECTORY : ' + s);
    d(error_col, '(' + error_message(error) + ')');
  end;
end;

function Create_FakePlayerFile: boolean;
var txt:  Text;
  Result: boolean;

begin {creates textfile with fakeplayer data, names and stuff}

  if open_txtfile(trewrite, txt, global_fakefile) = True then
  begin
    writeln_to_text(txt, '; These are the names of the fake players that will enter Usurper.');
    writeln_to_text(txt, '; Feel free to edit this file. To recreate the default file just');
    writeln_to_text(txt, '; delete the current one, and a new file will be created.');
    writeln_to_text(txt, ';');
    writeln_to_text(txt, ';format: name,sex,race,class');
    writeln_to_text(txt, ';');
    writeln_to_text(txt, 'Gwibbli,male,dwarf,warrior');
    writeln_to_text(txt, 'Sandra,female,human,ranger');
    writeln_to_text(txt, 'Sam,male,hobbit,sage');
    writeln_to_text(txt, 'Inga,female,orc,cleric');
    writeln_to_text(txt, 'Deathbringer,male,troll,barbarian');
    writeln_to_text(txt, 'Sol,male,elf,bard');
    writeln_to_text(txt, 'Thor Brownskull,male,dwarf,warrior');
    writeln_to_text(txt, 'Bulgor,male,human,jester');
    writeln_to_text(txt, 'Mynnia,female,gnoll,magician');
    writeln_to_text(txt, 'Walgur,male,halfelf,paladin');
    writeln_to_text(txt, 'Gnarf!,male,mutant,assassin');
    writeln_to_text(txt, 'Melkor,male,human,alchemist');
    writeln_to_text(txt, 'Bragger,male,hobbit,assassin');
    writeln_to_text(txt, 'Ma,female,elf,warrior');
    writeln_to_text(txt, 'Rugwash,male,troll,barbarian');

    close_text(txt);
    Result := True;
  end else
  begin
    unable_to_create(global_fakefile, 5);
    Result := False;
  end;

  {return result}
  create_fakeplayerfile := Result;

end; {create_fakeplayerfile *end*}

function Create_TeamNameFile: boolean;
var
  txt:    Text;
  Result: boolean;

begin {creates textfile with team names, this file is free to edit for
       the sysop/gamer}

  if open_txtfile(trewrite, txt, global_tnames) = True then
  begin

    writeln_to_text(txt, '; These are the names NPC teams will choose when they create');
    writeln_to_text(txt, '; their teams. Feel free to edit this file. To recreate this file just');
    writeln_to_text(txt, '; delete the current one, and a new one will be created.');
    writeln_to_text(txt, ';');
    writeln_to_text(txt, ';format: team-name');
    writeln_to_text(txt, ';');
    writeln_to_text(txt, 'Legions of Terror');
    writeln_to_text(txt, 'Army of Muscles');
    writeln_to_text(txt, 'Black Wolves');
    writeln_to_text(txt, 'Doomed Gang');
    writeln_to_text(txt, 'Blood Swords');
    writeln_to_text(txt, 'Wizards Creation');
    writeln_to_text(txt, 'Skull Crackers');
    writeln_to_text(txt, 'Guild of Purity');
    writeln_to_text(txt, 'Lurking Terror');
    writeln_to_text(txt, 'Overlords');
    writeln_to_text(txt, 'Jakes Guild');
    writeln_to_text(txt, 'Lacking Concious');
    writeln_to_text(txt, 'Freak Show');
    writeln_to_text(txt, 'Golden Youth');
    writeln_to_text(txt, 'Diamond Diabolos');
    writeln_to_text(txt, 'Watsamatta');
    writeln_to_text(txt, 'Messing Up Inc.');
    writeln_to_text(txt, 'Dog and Bark');
    writeln_to_text(txt, 'Red Army');
    writeln_to_text(txt, 'Swedish Iron');
    writeln_to_text(txt, 'Rhinos Holy Defence');
    writeln_to_text(txt, 'White Robes');
    writeln_to_text(txt, 'Urban Lords');
    writeln_to_text(txt, 'Sword Masters');
    writeln_to_text(txt, 'Pond Scum');
    writeln_to_text(txt, 'Hollow Cube');
    writeln_to_text(txt, 'Gnarfs Decapitation Crew');
    writeln_to_text(txt, 'No Brains');
    writeln_to_text(txt, 'Decapitation Crew');
    writeln_to_text(txt, 'Grifters');
    writeln_to_text(txt, 'Serious Trouble');
    writeln_to_text(txt, 'Crying Fools');
    writeln_to_text(txt, 'Nippes Turbo Crew');
    writeln_to_text(txt, 'LSD Surfers');
    writeln_to_text(txt, 'Cassidys Revenge');
    writeln_to_text(txt, 'Tools of Destruction');
    writeln_to_text(txt, 'Spears of Tears');
    writeln_to_text(txt, 'Enfant Terribles');
    writeln_to_text(txt, 'StormAxe');
    writeln_to_text(txt, 'Serious Attitude');
    writeln_to_text(txt, 'Violence Us!');
    writeln_to_text(txt, 'Looters');
    writeln_to_text(txt, 'Grave Pushers');
    writeln_to_text(txt, 'Selwyns Servants');
    writeln_to_text(txt, 'Roughabouts');
    writeln_to_text(txt, 'Spear Scum');
    writeln_to_text(txt, 'Infinte Infidels');
    writeln_to_text(txt, 'Exit Life');
    writeln_to_text(txt, 'Riff Raff');
    writeln_to_text(txt, 'King Reginalds Troops');
    writeln_to_text(txt, 'Sons of Targash');

    close_text(txt);
    Result := True;
  end else
  begin
    {we were unable to create the file}
    unable_to_create(global_tnames, 5);
    Result := False;
  end;

  {return result}
  create_teamnamefile := Result;

end; {create_teamnamefile *end*}

function Create_BardSongFile: boolean;
var
  txt:    Text;
  Result: boolean;

  procedure Ox(const s: s100); {shorter to write ox('blaha') than writeln_....}
  begin
    writeln_to_text(txt, s);
  end;

begin {creates bard_song datafile}

  if open_txtfile(trewrite, txt, global_bardsongf) = True then
  begin

    ox('; These are the songs the BARDS in the game will be able to use');
    ox('; in combat and other situations. Feel free to edit this file.');
    ox('; To recreate this file: delete the current one, and a new one');
    ox('; will be created when game is run.');
    ox(';');
    ox(';format: #Level ?? (at what level this song will be available 1..100)');
    ox(';      : #Comment  (comments about the song, not available in game)');
    ox(';      : #Title ?? (max 40 chars)');
    ox(';      : #Text...  (70 chars, max 12 lines)');
    ox(';');

    {Megadeath, Youthanasia, "Blood of heroes"}
    ox('#Level 1');
    ox('#Comment This is a War-Song, Jakob Dangarden');
    ox('#Title "Blood of heroes"');
    ox('Ladies and gents, we''re still alive');
    ox('by the skin of our teeth, now it''s killing time');
    ox('angel in our pocket, devil by our side');
    ox('we ain''t going nowhere cuz'' heroes never die');
    ox('it''s time to be immortal, ''cuz heroes never die');

  {source :http://www.crosswinds.net/russia/~kasumov/Partlyr.htm
   artist : LUGBURGZ}
    ox('#Level 2');
    ox('#Comment This is a War-Song, Jakob Dangarden');
    ox('#Title "Lesser God"');
    ox('damned to a ghostly substance');
    ox('   created by a lesser god');
    ox('damned to carry this burden');
    ox('   forever in your sour souls');
    ox('damned to dig on rotten roots');
    ox('   you are doomed and none shall live');
    ox('the essence that keeps you alive');
    ox('   nothing but venom injected by wrath');

    {unknown source}
    ox('#Level 3');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Dragon of Time"');
    ox('on cold landscapes of ghostly substance');
    ox('the dragon spreads its wings');
    ox('the only dragon, creator of time');
    ox('on paths where');
    ox('once surrounded by night');
    ox('throned the dragon of time now dwells');
    ox('the swords dipped in blood');
    ox('stone cold, washed away by time');
    ox('none shall live and all shall die');
    ox('immortal we stand');
    ox('on the hills where the dragon flies');
    ox('on the hills where dragon flies');

    {Entombed, Wolverine Blues, Blood Song}
    ox('#Level 4');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Blood Song"');
    ox('Drinking blood');
    ox('a red delightful bloody power');
    ox('my fatal bite');
    ox('the art of the blackest hour');
    ox('I suck your blood');
    ox('an immense evlasting lust');
    ox('morning grows');
    ox('the sun burns me to dust');

    ox('#Level 5');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Burial Song of Th‚oden"');
    ox('Out of doubt, out of dark, to the day''s rising');
    ox('he rode singing in the sun, sword unsheathing.');
    ox('Hope he rekindled, and in hope ended;');
    ox('over death, over dread, over doom lifted');
    ox('out of loss, out of life, unto long glory.');

    ox('#Level 6');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Athelas"');
    ox('When the black breath blows');
    ox('and death''s shadow grows');
    ox('and all lights pass,');
    ox('come athelas! come athelas!');
    ox('Life to the dying');
    ox('In the king''s hand lying!');

    ox('#Level 7');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Song of Lebennin"');
    ox('Silver flow the streams from Celos to Erui');
    ox('In the green fields of Lebennin!');
    ox('Tall grows the grass there. In the wind from the Sea');
    ox('The white lilies sway,');
    ox('And the golden bells are shaken of mallos and alfirin');
    ox('In the green fields of Lebennin,');
    ox('In the wind from the Sea!');

    {extract from Tom Bombadil's song}
    ox('#Level 8');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "River Daughter"');
    ox('O slender as the willow-wand! O clearer than clear water!');
    ox('O reed by the living pool! Fair River-daughter!');
    ox('O spring-time and summer-time, and spring again after!');
    ox('O wind on the waterfall, and the leaves'' laughter!');

    {part 1/2 from Sam's song}
    ox('#Level 9');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Song in the tower"');
    ox('In western lands beneath the Sun');
    ox('the flowers may rise in Spring,');
    ox('the trees may bud, the waters run,');
    ox('the merry finches sing.');
    ox('Or there maybe ''tis cloudless night');
    ox('and swaying beeches bear');
    ox('the Elven-stars as jewels white');
    ox('amid their branching hair.');

    {part 2/2 from Sam's song}
    ox('#Level 10');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Star Tower"');
    ox('Though here at journey''s end I lie');
    ox('in darkness buried deep,');
    ox('beyond all towers strong and high,');
    ox('beyond all mountains steep,');
    ox('above all shadows rides the Sun');
    ox('and Stars for ever dwell:');
    ox('I will not say the Day is done,');
    ox('nor bid the Stars farewell.');

    {Gollum's Song}
    ox('#Level 11');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Wishful"');
    ox('The cold hard lands');
    ox('they bites our hands,');
    ox('they gnaws our feet.');
    ox('The rocks and stones');
    ox('are like old bones');
    ox('all bare of meat.');
    ox('But stream and pool');
    ox('is wet and cool:');
    ox('so nice to feet!');
    ox('And now we wish-');

    {A Rhyme of Lore}
    ox('#Level 12');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "A Rhyme of Lore"');
    ox('Tall ships and tall kings');
    ox('Three times three,');
    ox('What brought they from the foundered land');
    ox('Over the flowing sea?');
    ox('Seven stars and seven stones');
    ox('And one white tree.');

    ox('#Level 13');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Gandalf''s Riddle of the Ents');
    ox('Ere iron was found or tree was hewn,');
    ox('When young was mountain under moon;');
    ox('Ere ring was made, or wrought was woe,');
    ox('It walked the forests long ago.');

    {1st part from "The Ent and the Ent-wife"}
    ox('#Level 14');
    ox('#Comment This is a War-Song Song, Jakob Dangarden');
    ox('#Title "Beechen Leaf"');
    ox('When Spring unfolds the beechen leaf, and sap is in the bough;');
    ox('When light is on the wild-wood stream, and wind is on the brow;');
    ox('When stride is long, and breath is deep, and keen the mountain-air,');
    ox('Come back to me! Come back to me, and say my land is fair!');

    {close textfile}
    close_text(txt);

    {set result}
    Result := True;

  end else
  begin

    {we were unable to create the file!}
    unable_to_create(global_bardsongf, 5);

    {set result}
    Result := False;

  end;

  {return result}
  create_bardsongfile := Result;

end; {create_bardsongfile *end*}


procedure Create_Onlinefile;
var
  error:      integer;

  OnlineFile: file of OnlineRec;     {** Online Players **}

begin

  {assign}
  Assign(onlinefile, global_onfile);

 {$I-}rewrite(onlinefile);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_create(global_onfile, error);

 {$I-}Close(onlinefile);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_close(global_onfile, error);

end; {create_onlinefile *end*}

procedure Pack_Mail;
var
  tempf:    s90;
  mail:     mailrec;
  tempfile: file of mailrec;
  ypos:     byte;
  i, c:     word;
  rr:       real;
  maxsize, sizebefore, x: longint;
  error:    integer;

begin

  if f_exists(global_mafile) = False then
  begin
    unable_to_find(global_mafile);
    wrl(10, '');
    exit;
  end;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  wrl(10, 'Usurper');
  wrl(10, 'Packing Mailfile : ' + global_mafile);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  c := 0;
  maxsize := fs(FsMail);
  if (maxsize > 0) then
  begin
    {keep in memory, for statistics display}
    sizebefore := maxsize;

    ypos := wherey;
    for i := 1 to MaxSize do
    begin
      GotoXy(1, ypos);
      wrl(10, 'Processing       : ' + commastr(i) + '/' + commastr(maxsize));
      load_mail(Fload, mail, i);
      if (old_mail(mail)) or (mail.readflag) then
      begin
        Inc(c);
      end else
      begin
        {save records that are kept}

     {$I-}Write(tempfile, mail);{$I+}
        error := IoResult;

        if error <> 0 then
        begin
          unable_to_write(tempf, error);
          exit;
        end;
      end;
    end; {for i:= .end.}

   {$I-}Close(tempfile);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      unable_to_close(tempf, error);
      exit;
    end;

    delete_file(global_mafile);
    rename_file(tempf, global_mafile);

    {display statistics}

    maxsize := c;

    rr := sizebefore - maxsize;
    rr := rr / sizebefore;
    rr := rr * 100;
    x := 100 - round(rr);

    wrl(10, '');
    wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
    wrl(10, 'Space saved: ' + commastr(sizeof(mailrec) * maxsize) + ' bytes, ' + commastr(x) + '%');
  end else
  begin
    { 0 byte mail file, so delete it }
    delete_file(global_mafile);
    wrl(10, '');
    wrl(10, 'Done. (0 byte file deleted)');
  end;

end; {packmail .end.}

procedure Pack_Moat; {pack the moat creature file, removing deleted creatures}
var
  tempf:    s90;
  moat:     MoatRec;
  tempfile: file of MoatRec;
  ypos:     byte;
  i, c:     word;
  rr:       real;
  error:    integer;
  maxsize, sizebefore, x: longint;

begin

  {init}
  error := 0;

  if f_exists(global_moatfile) = False then
  begin
    unable_to_find(global_moatfile);
    wrl(10, '');
    exit;
  end;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  wrl(10, 'Usurper');
  wrl(10, 'Packing Moatfile : ' + global_moatfile);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  c := 0;
  maxsize := fs(FsMoat);

  {keep in memory, for statistics display}
  sizebefore := maxsize;

  ypos := wherey;
  for i := 1 to MaxSize do
  begin
    GotoXy(1, ypos);
    wrl(10, 'Processing       : ' + commastr(i) + '/' + commastr(maxsize));
    load_moat(Fload, moat, i);
    if (moat.deleted) then
    begin
      Inc(c);
    end else
    begin
      {save records that are kept}
   {$I-}Write(tempfile, moat);{$I+}
      error := IoResult;
      if error <> 0 then
      begin
        unable_to_write(tempf, error);
        exit;
      end;
    end;
  end; {for i:= .end.}

 {$I-}Close(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(tempf, error);
    exit;
  end;

  delete_file(global_moatfile);
  rename_file(tempf, global_moatfile);

  {display statistics}

  maxsize := c;

  rr := sizebefore - maxsize;
  rr := rr / sizebefore;
  rr := rr * 100;
  x := 100 - round(rr);

  wrl(10, '');
  wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
  wrl(10, 'Space saved: ' + commastr(sizeof(mailrec) * maxsize) + ' bytes, ' + commastr(x) + '%');

end; {Pack_Moat **END**}

procedure Pack_Relations; {pack the relations file, removes deleted relation records}
var
  tempf: s90;
  relation: RelationRec;
  tempfile: file of RelationRec;

  save:  boolean;
  ypos:  byte;
  i, c, current: word;
  rr:    real;
  error: integer;
  maxsize, sizebefore, x: longint;

begin

  {init}
  error := 0;
  current := 0;

  {first we validate relations, killing all with non-active players}
  wr(10, 'Verifying all Relations..');
  validate_all_relations(False);
  wrl(10, '..DONE!');

  if f_exists(global_relationf) = False then
  begin
    unable_to_find(global_relationf);
    wrl(10, '');
    exit;
  end;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  wrl(10, 'Usurper');
  wrl(10, 'Packing Relation file : ' + global_relationf);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  c := 0;

  {set filesize}
  maxsize := fs(FsRelation);

  {keep in memory, for statistics display}
  sizebefore := maxsize;

  ypos := wherey;
  for i := 1 to MaxSize do
  begin
    GotoXy(1, ypos);
    wrl(10, 'Processing            : ' + commastr(i) + '/' + commastr(maxsize));
    load_relation(Fload, relation, i);
    save := True;

    if (relation.deleted) then
    begin
      Inc(c);
      save := False;
    end else
    begin
      {check that both relation persons are active/exists}

    end;

    if save then
    begin
      {save records that are kept}

      {set new filerec position}
      Inc(current);
      relation.recnr := current;

   {$I-}Write(tempfile, relation);{$I+}
      error := IoResult;
      if error <> 0 then
      begin
        unable_to_write(tempf, error);
        exit;
      end;
    end;

  end; {for i:= .end.}

 {$I-}Close(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(tempf, error);
    exit;
  end;

  delete_file(global_relationf);
  rename_file(tempf, global_relationf);

  {display statistics}

  maxsize := c;

  rr := sizebefore - maxsize;
  rr := rr / sizebefore;
  rr := rr * 100;
  x := 100 - round(rr);

  wrl(10, '');
  wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
  wrl(10, 'Space saved: ' + commastr(sizeof(RelationRec) * maxsize) + ' bytes, ' + commastr(x) + '%');

end; {Pack_Relation **END**}

procedure Pack_Children; {pack the children data-file, removes deleted children records}
var
  tempf:    s90;
  child:    ChildRec;
  tempfile: file of ChildRec;
  ypos:     byte;
  i, c:     word;
  rr:       real;
  error:    integer;
  maxsize, sizebefore, x: longint;

begin

  {init}
  error := 0;

  if f_exists(global_childrenf) = False then
  begin
    unable_to_find(global_childrenf);
    wrl(10, '');
    exit;
  end;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  wrl(10, 'Usurper');
  wrl(10, 'Packing Children : ' + global_childrenf);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  c := 0;

  {set filesize}
  maxsize := fs(FsChildren);

  {keep in memory, for statistics display}
  sizebefore := maxsize;

  ypos := wherey;
  for i := 1 to MaxSize do
  begin
    GotoXy(1, ypos);
    wrl(10, 'Processing       : ' + commastr(i) + '/' + commastr(maxsize));
    if load_child(Fload, child, i) = True then
    begin
      if child.deleted = True then
      begin
        Inc(c);
      end else
      begin
        {save records that are kept}
    {$I-}Write(tempfile, child);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          unable_to_write(tempf, error);
          exit;
        end;
      end;
    end;
  end; {for i:= .end.}

 {$I-}Close(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(tempf, error);
    exit;
  end;

  delete_file(global_childrenf);
  rename_file(tempf, global_childrenf);

  {display statistics}

  maxsize := c;

  rr := sizebefore - maxsize;
  rr := rr / sizebefore;
  rr := rr * 100;
  x := 100 - round(rr);

  wrl(10, '');
  wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
  wrl(10, 'Space saved: ' + commastr(sizeof(RelationRec) * maxsize) + ' bytes, ' + commastr(x) + '%');

end; {Pack_Children **END**}

procedure Pack_Gods; {pack the gods data-file, removes deleted god records}
var
  tempf:    s90;
  god0:     GodRec;
  tempfile: file of GodRec;
  ypos:     byte;
  i, c:     word;
  rr:       real;
  error:    integer;
  maxsize, sizebefore, x: longint;

begin

  {init}
  error := 0;

  if f_exists(global_godfil) = False then
  begin
    unable_to_find(global_godfil);
    wrl(10, '');
    exit;
  end;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  wrl(10, 'Usurper');
  wrl(10, 'Packing Gods : ' + global_godfil);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  c := 0;

  {set filesize}
  maxsize := fs(FsGod);

  {keep in memory, for statistics display}
  sizebefore := maxsize;

  ypos := wherey;
  for i := 1 to MaxSize do
  begin
    GotoXy(1, ypos);
    wrl(10, 'Processing       : ' + commastr(i) + '/' + commastr(maxsize));
    if load_god(Fload, god0, i) = True then
    begin
      if god.deleted = True then
      begin
        Inc(c);
      end else
      begin
        {save records that are kept}
    {$I-}Write(tempfile, god0);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          unable_to_write(tempf, error);
          exit;
        end;
      end;
    end;
  end; {for i:= .end.}

 {$I-}Close(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(tempf, error);
    exit;
  end;

  delete_file(global_godfil);
  rename_file(tempf, global_godfil);

  {display statistics}

  maxsize := c;

  rr := sizebefore - maxsize;
  rr := rr / sizebefore;
  rr := rr * 100;
  x := 100 - round(rr);

  wrl(10, '');
  wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
  wrl(10, 'Space saved: ' + commastr(sizeof(RelationRec) * maxsize) + ' bytes, ' + commastr(x) + '%');

end; {Pack_Gods **END**}

procedure Pack_Users; {Pack User/Npc file}
var
  tempf:    s90;
  ply:      userrec;
  tempfile: file of userrec;
  error:    integer;
  ypos:     byte;
  i, c:     word;
  s:        s90;
  who:      byte;
  maxsize, sizebefore, x: longint;
  rr:       real;

begin

  {init}
  error := 0;

  {construct a temporary filename}
  tempf := global_datadir + crypt(8) + '.TMP';

  case action of
    PUsers: begin
      if f_exists(global_pfile) = False then
      begin
        unable_to_find(global_pfile);
        exit;
      end;
      s := global_pfile;
      maxsize := fs(FsPlayer);
      who := 1;
    end;
    PNpcs: begin
      if f_exists(global_npfile) = False then
      begin
        unable_to_find(global_npfile);
        exit;
      end;
      s := global_npfile;
      maxsize := fs(FsNpc);
      who := 2;
    end;
  end; {case .end.}

  wrl(10, 'Usurper');
  wrl(10, 'Packing    : ' + s);

  {open temp file}
  Assign(tempfile, tempf);
 {$I-}rewrite(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_create(tempf, error);
    exit;
  end;

  {keep in memory, for statistics display}
  sizebefore := maxsize;

  c := 0;
  ypos := wherey;
  for i := 1 to MaxSize do
  begin
    GotoXy(1, ypos);
    wrl(10, 'Processing : ' + commastr(i) + '/' + commastr(maxsize));

    load_character(ply, who, i);

    if (ply.deleted) or (upcasestr(ply.name1) + upcasestr(ply.name2) = global_delname1 + global_delname2) then
    begin
      Inc(c);
    end else
    begin

      {set new filerec}

      {save active records}
   {$I-}Write(tempfile, ply);{$I+}
      error := IoResult;
      if error <> 0 then
      begin
        unable_to_write(tempf, error);
        exit;
      end;
    end;
  end; {for i:= .end.}

 {$I-}Close(tempfile);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_close(tempf, error);
    exit;
  end;

  delete_file(s);
  rename_file(tempf, s);

  {display statistics}

  maxsize := c;

  rr := sizebefore - maxsize;
  rr := rr / sizebefore;
  rr := rr * 100;
  x := 100 - round(rr);

  wrl(10, '');
  wrl(10, 'Done. (' + commastr(c) + ' records deleted)');
  wrl(10, 'Space saved: ' + commastr(sizeof(userrec) * maxsize) + ' bytes, ' + commastr(x) + '%');

end; {Pack_Users **END**}

procedure Pack_TxtFile;
const dummy = 'DUMMY.TXT'; {temporary work file}

var
  txt, txtfile: Text;

  i, skip: word; {skip=how many lines in the beginning should we skip}
  s: string;

begin

 {this proc examines the file FNAME and allows a maximum of
  "max_lines" lines in the file. if the file contains more than
  max_lines then the file is stripped of its top lines
  pack_txtfile('apa.txt',3) will out of
   1. hello
   2. mylord
   3. jesus
   4. don't
   5. destroy
  make
   1. jesus
   2. don't
   3. destroy}

  if f_exists(fname) = False then
  begin
    open_txtfile(trewrite, txtfile, fname);
    close_text(txtfile);
  end;

  i := 0;
  skip := 0;
  open_txtfile(treset, txtfile, fname);
  while not EOF(txtfile) do
  begin
    readln_from_text(txtfile, s);
    Inc(i);
  end;

  close_text(txtfile);

  {do we need to pack this textfile?}
  if i > max_lines then
  begin
    skip := i - max_lines;

    {creating dummy file}
    open_txtfile(trewrite, txt, dummy);
    close_text(txt);

    open_txtfile(tappend, txt, dummy);
    open_txtfile(treset, txtfile, fname);

    i := 0;
    while not EOF(txtfile) do
    begin

      readln_from_text(txtfile, s);
      Inc(i);

      if i >= skip then
      begin
        writeln_to_text(txt, s);
      end;

    end;

    close_text(txtfile);
    close_text(txt);

    delete_file(fname);
    rename_file(dummy, fname);
    Assign(txtfile, fname);
  end;

end; {pack_txtfile *end*}

     {The Inn Chatfile - procs - START}
procedure Write_To_Inn_File;
var
  txt: Text;
  i:   byte;
  ok:  boolean;

begin

  if f_exists(global_innfile1) = False then
  begin
    if open_txtfile(trewrite, txt, global_innfile1) then
    begin
      close_text(txt);
    end else
    begin
      unable_to_create(global_innfile1, access_error);
    end;
  end;

  if f_exists(global_innfile2) = False then
  begin
    if open_txtfile(trewrite, txt, global_innfile2) then
    begin
      close_text(txt);
    end else
    begin
      unable_to_create(global_innfile2, access_error);
    end;
  end;

  for i := 1 to 2 do
  begin
    ok := False;
    case i of
      1: begin
        if open_txtfile(tappend, txt, global_innfile1) then
          ok := True
        else ok := False;
      end;
      2: begin
        if open_txtfile(tappend, txt, global_innfile2) then
          ok := True
        else ok := False;
      end;
    end; {case .end.}

    if ok then
    begin

      writeln_to_text(txt, '');
      case i of
        1: writeln_to_text(txt, aLtGreenOnBlack + Sender + ':'); {ansi}
        2: writeln_to_text(txt, Sender + ':'); {ascii}
      end;

      if i = 1 then
      begin
        write_to_text(txt, aGreenOnBlack);
      end;

      if m1 <> '' then
        writeln_to_text(txt, m1);
      if m2 <> '' then
        writeln_to_text(txt, m2);
      if m3 <> '' then
        writeln_to_text(txt, m3);
      if m4 <> '' then
        writeln_to_text(txt, m4);
      if m5 <> '' then
        writeln_to_text(txt, m5);

      close_text(txt);
    end else
    begin
         {Unable to Write File}
      unable_to_access(global_innfile1 + '/' + global_innfile2, access_error);
    end; {if ok .end.}
  end;

end;

 {The Inn Chatfile - procs - END}

 {The Daily TRUTHs files - procs - START}



procedure Check_TruthFile(inmaint: boolean); {creates the "street-talk" files if non-existant}
const maxo = 15;
var txt: Text;

  function Cool_Line: string;
  var i, j: byte;
    s:      string;
  begin

    s := '';
    j := 1;
    for i := 1 to maxo do
    begin

      case j of
        1: begin
          s := s + aDkGrayOnBlack + underscore;
          j := 2;
        end;
        2: begin
          s := s + aLtGrayOnBlack + underscore;
          j := 1;
        end;
      end; {case .end.}

    end;   {for i:= .end.}

           {return result}
    cool_line := s;

  end;

  {cool_line *end*}
begin

  if f_exists(global_truthfile1) = False then
  begin

    {remove ascii file if it exists}
    if f_exists(global_truthfile2) then
      delete_file(global_truthfile2);

    if not inmaint then
    begin
      d(12, 'Could not find the ' + ulcyan + 'Street-talk' + ulred + ' files.');
      d(config.textcolor, 'Creating new ones...');
    end;
    if open_txtfile(trewrite, txt, global_truthfile1) then
    begin
      writeln_to_text(txt, cool_line);
      writeln_to_text(txt, '  Street Talk');
      writeln_to_text(txt, cool_line);
      close_text(txt);
    end else
    begin
      {Unable to Write File}
      unable_to_write(global_truthfile1, access_error);
    end;
  end;

  if f_exists(global_truthfile2) = False then
  begin
    if open_txtfile(trewrite, txt, global_truthfile2) then
    begin
      writeln_to_text(txt, mkstring(maxo, underscore));
      writeln_to_text(txt, '  Street Talk');
      writeln_to_text(txt, mkstring(maxo, underscore));
      close_text(txt);
    end else
    begin
      {Unable to Write File}
      unable_to_write(global_truthfile2, access_error);
    end;
  end;

end; {check_truthfile *end*}

procedure Write_To_Truth_file;
var txt: Text;
  i:  byte;
  ok:    boolean;

begin {write_to_truth_file}

      {create files if non-existant}
  check_truthfile(False);

  for i := 1 to 2 do
  begin
    ok := False;
    case i of
      1: begin
        if open_txtfile(tappend, txt, global_truthfile1) then
        begin
          ok := True;
        end else
        begin
          ok := False;
        end;
      end;
      2: begin
        if open_txtfile(tappend, txt, global_truthfile2) then
        begin
          ok := True;
        end else
        begin
          ok := False;
        end;
      end;
    end; {case .end.}

    if ok then
    begin

      if i = 1 then
      begin
        write_to_text(txt, ALtGreenOnBlack);
      end;
      writeln_to_text(txt, '');
      writeln_to_text(txt, Sender);

      if i = 1 then
      begin
        write_to_text(txt, AGreenOnBlack);
      end;

      if i = 1 then
      begin
        {ansi}
        writeln_to_text(txt, uconv(mess));
      end else
      begin
        {ascii}
        writeln_to_text(txt, strip(mess));
      end;

      close_text(txt);

    end else
    begin
      {Unable to Write File}
      unable_to_write(global_truthfile1 + '/' + global_truthfile2, access_error);
    end;
  end;

end; {The Daily TRUTHs files - procs - END}

procedure Save_New_Guy(slot: word);
var
  i, memmy, error: integer;

  ok:         boolean;

  PlayerFile: file of UserRec;    {** Userfile            **}

begin {save new user at position SLOT}

      {init}
  i := 0;
  error := 0;
  memmy := filemode;

  repeat
    ok := True;
    Assign(playerfile, global_pfile);

    {set filemode}
    if global_ushare then
    begin
      FileMode := fmReadWrite + fmDenyAll;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(playerfile);{$I+}
    error := IoResult;

    if error <> 0 then
    begin
      unable_to_access(global_pfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > 100);

  {seek}
 {$I-}Seek(playerfile, slot - 1);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_seek(global_pfile, slot - 1);

  {write}
 {$I-}Write(playerfile, player);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_write(global_pfile, error);

  {close}
 {$I-}Close(playerfile);{$I+}
  error := IoResult;
  if error <> 0 then
    unable_to_close(global_pfile, error);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {save_new_guy *end*}

function Delete_File(const fn: string): boolean;
const maxtries = 15;
var
  f:     file;
  i:     byte;
  ok:    boolean;
  error: integer;

begin; {well, this routine deletes file FN, what a surprise huh!}

       {init vars}
  i := 0;
  ok := False;
  error := 0;

  repeat
    Assign(f, fn);
  {$I-}erase(f);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      unable_to_delete(fn, error);
      Inc(i);
      delay2(global_lockdelay);
    end else
    begin
      ok := True;
    end;
  until (ok) or (i > maxtries);

  {return result}
  Delete_File := ok;

end; {delete_file *end*}

function F_Exists(const fn: string): boolean;
  { Checks for the existence of a file, allows wildcards }
var dirinfo: searchrec;
begin
  FindFirst(Fn, Anyfile - directory - volumeid, DirInfo);
  F_Exists := DosError = 0;
{$IFNDEF MSDOS}
  FindClose(dirinfo);
{$ENDIF}
end; {f_exists *end*}

function Get_Random_Line_From_Textfile(const fname: string): string;
var      {pretty self explanatory what this proc does, huh!}

  counter, goal_line: integer;

  s, Result: string;

  txt: Text;

begin

  {init}
  s := '';
  Result := '';

 {count the number of lines with names. ";" is a REM statement and
  therefore ignored}
  counter := 0;
  if open_txtfile(treset, txt, fname) = True then
  begin
    while not EOF(txt) do
    begin

      readln_from_text(txt, s);
      if s[1] <> ';' then
      begin
        Inc(counter);
      end;

      {safety measure}
      if counter > 10000 then
        break;

    end; {while .end.}
    close_text(txt);

    {pick a number}
    if counter > 0 then
    begin
      goal_line := random(counter) + 1;
      counter := 0;
      {read the line we picked}
      if open_txtfile(treset, txt, fname) = True then
      begin
        while not EOF(txt) do
        begin
          readln_from_text(txt, s);
          if s[1] <> ';' then
          begin
            Inc(counter);
          end;

          {we found it!}
          if goal_line = counter then
          begin
            Result := s;
            break;
          end;

        end; {while .end.}
        close_text(txt);
      end else
      begin
        {error}
        unable_to_access(fname, access_error);
      end;
    end;

  end else
  begin
    {error}
    unable_to_access(fname, access_error);
  end;

  {return result}
  get_random_line_from_textfile := Result;

end; {get_random_line_from_textfile *end*}

function Open_TxtFile(action: tshare; var f; const fname: string): boolean;
const max_tries = 80;
var
  i:          word;


  mem:        boolean;

  error, memmy: integer;
{$IFNDEF MSDOS}
  memmy_r:    integer;
  memmy_rw:   integer;
  lockmde_r:  byte;
  lockmde_rw: byte;
{$ENDIF}

  txt:        Text;

begin {this routine deals with all textfile related stuff.
       this code is originally taken from the SWAG archive}

  {init}
  error := 0;
  memmy := filemode;
{$IFNDEF MSDOS}
  memmy_r := TextModeRead;
  memmy_rw := TextModeReadWrite;
{$ENDIF}

  if (f_exists(fname) = False) and (action <> Trewrite) then
  begin
    Assign(txt, fname);
  {$I-}rewrite(txt);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      open_txtfile := False;
      unable_to_create(fname, error);
      exit;
    end;
  {$I-}Close(txt);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(fname, error);
  end;

  global_lockmode := filemode;
{$IFNDEF MSDOS}
  lockmde_r := TextModeRead;
  lockmde_rw := TextModeReadWrite;
{$ENDIF}
  mem := global_multi;
  global_multi := False;
  i := 0;

{$IFDEF MSDOS}
  AssignText(Text(f), Fname);  (* From TxtShare unit *)
{$ENDIF}
{$IFNDEF MSDOS}
  Assign(Text(f), Fname);  (* From TxtShare unit *)
{$ENDIF}
 {This code was not reentrant.
 For now, I'm commenting it out.
 It causes problems when displaying news,
 and then a fake player causes a read
 from fake.dat.
 The real fix is to assign separate buffers to files.
 SetTextBuf(text(f),Global_TextBuffer);}

  if global_ushare then
  begin
    case Action of
      Treset: FileMode := fmReadOnly + fmDenyNone;
      Tappend: FileMode := fmWriteOnly + fmDenyWrite;
      TDelete: FileMode := fmWriteOnly + fmDenyAll;
      TRewrite: FileMode := fmWriteOnly + fmDenyAll;
    end; {case .end.}
  end;
{$IFNDEF MSDOS}
  TextModeRead := FileMode;
  TextModeReadWrite := FileMode;
{$ENDIF}

  repeat (* Only repeat if denied access *)

    case action of

      TRewrite: {$I-}Rewrite(Text(f)){$I+}
      else      {$I-}Reset(Text(f));{$I+}

    end; {case .end.}

    error := IoResult;
    if error <> 0 then
    begin
      unable_to_access(fname, error);
      delay2(global_lockdelay);
      Inc(i);
    end 
  until (error = 0) or (i >= max_tries); (* Quit if not a sharing deny *)

  (* Set FileMode to default *)
  FileMode := global_lockmode;
{$IFNDEF MSDOS}
  TextModeRead := lockmde_r;
  TextModeReadWrite := lockmde_rw;
{$ENDIF}

  if error = 0 then
  begin
    case action of
      TRewrite: begin
        {rewrite(text(f));}
      end;
      Tappend: begin
             {$I-}append(Text(f));{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_append(fname);
      end;
      TDelete: begin
             {$I-}Close(Text(f));{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(fname, error);
        delete_file(fname);
      end;
      TReset: begin
        {reset(text(f));}
      end;

    end; {case .end.}
  end;

  {reset filemode}
  global_multi := mem;
  filemode := memmy;
{$IFNDEF MSDOS}
  TextModeRead := memmy_r;
  TextModeReadWrite := memmy_rw;
{$ENDIF}

  {return result}
  if error <> 0 then
    Open_TxtFile := False
  else Open_Txtfile := True;

end; {OPEN_TXTFILE **END**}

function Rename_File(const s1: string; const s2: string): boolean;
var f:   file;
  error: integer;
begin

  Assign(f, s1);
 {$I-} rename(f, s2); {$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_rename(s1, s2);
    rename_file := False;
  end else
  begin
    rename_file := True;
  end;

end; {rename_file *end*}

function Make_Dir(const s: string): boolean;
var error: integer;
begin

 {$I-}mkdir(s);{$I+}
  error := IoResult;
  if error <> 0 then
  begin
    unable_to_createdir(s, error);
    make_dir := False;
  end else
  begin
    make_dir := True;
  end;

end; {make_dir *end*}

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


{-----FILESIZE START-----}
function Fs;
var
  memmy, i:     integer;
  error:        integer;
  ok:           boolean;

  Result:       word;

  NewBarrel:    BarrelRec; {Barrel Masters, see Gym.pas}

  GuardFile:    file of GuardRec;      {** DoorGuard file      **}
  BrevFile:     file of MailRec;       {** Mail file           **}
  WantedFile:   file of WantedRec;     {** Wanted file         **}
  Monsterfile:  file of MonsterRec;    {** Monster file        **}
  Weapfile:     file of WeapRec;       {** Weapon file classIC **}
  Armfile:      file of ArmRec;        {** Armor file classIC  **}
  PMFile:       file of MarketItemRec; {** PlayerMarket file   **}
  ChestFile:    file of ChestItemRec;  {** Home Chest file     **}
  NpcFile:      file of UserRec;       {** Npc file            **}
  OnlineFile:   file of OnlineRec;     {** Online gubbar       **}
  PlayerFile:   file of UserRec;       {** Userfile            **}
  Drinkf:       file of DrinkRec;      {** Drinkfile           **}
  Moatf:        file of MoatRec;       {** Moat creature file  **}
  QuestFile:    file of QuestRec;      {** Questfile           **}
  RelationFile: file of RelationRec;   {** Relationsfile       **}
  ChildrenFile: file of ChildRec;      {** Childrenfile        **}
  BarrelFile:   file of BarrelRec;     {** Barrelfile          **}
  GodFile:      file of GodRec;        {** Godfile             **}

begin

  {init}
  error := 0;
  Result := 0;
  i := 0;

  {remember old filemode and setting new}
  memmy := filemode;

  if global_ushare then
  begin
    FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  end;

  {get filesize of requested file}
  case filtyp of
    FsPlayer: begin {size of playerfile}
      repeat
        Assign(playerfile, global_pfile);
        ok := True;
             {$I-}reset(playerfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(playerfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_pfile);

            {$I-}Close(playerfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_pfile, error);

    end;
    FsNpc: begin {size of npcfile}
      repeat
        Assign(npcfile, global_npfile);
        ok := True;
          {$I-}reset(npcfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

         {$I-}Result := filesize(npcfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_npfile);

         {$I-}Close(npcfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_npfile, error);

    end;
    FsChestItem: begin {home chest items}
      if f_exists(global_chestfile) = False then
      begin
        Assign(chestfile, global_chestfile);

                {$I-}rewrite(chestfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_chestfile, error);

                {$I-}Close(chestfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_chestfile, error);

      end;

      repeat
        Assign(chestfile, global_chestfile);
        ok := True;
                {$I-}reset(chestfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

               {$I-}Result := filesize(chestfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_chestfile);

               {$I-}Close(chestfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_chestfile, error);

    end; {home chest items .end.}
    FsMarket: begin {players market file}

      if f_exists(global_marketfile) = False then
      begin
        Assign(pmfile, global_marketfile);

             {$I-}rewrite(pmfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_marketfile, error);

             {$I-}Close(pmfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_marketfile, error);

      end;

      repeat
        Assign(pmfile, global_marketfile);
        ok := True;
             {$I-}reset(pmfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(pmfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_marketfile);

            {$I-}Close(pmfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_marketfile, error);

    end;
    FsGuard: begin {door guard file}

      repeat
        Assign(guardfile, global_gufile);
        ok := True;
            {$I-}reset(guardfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(guardfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_gufile);

           {$I-}Close(guardfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_gufile, error);

    end;
    FsQuest: begin {quest file}

      if f_exists(global_rquestf) = False then
      begin
        Assign(questfile, global_rquestf);

            {$I-}rewrite(questfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_rquestf, error);

            {$I-}Close(questfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_rquestf, error);

      end;

      repeat
        Assign(questfile, global_rquestf);
        ok := True;
            {$I-}reset(questfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(questfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_rquestf);

           {$I-}Close(questfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_rquestf, error);

    end;
    FsRelation: begin {social relations file}

      if f_exists(global_relationf) = False then
      begin
        Assign(relationfile, global_relationf);

            {$I-}rewrite(relationfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_relationf, error);

            {$I-}Close(relationfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_relationf, error);

      end;

      repeat
        Assign(relationfile, global_relationf);
        ok := True;
            {$I-}reset(relationfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(relationfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_relationf);

           {$I-}Close(relationfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_relationf, error);

    end;
    FsChildren: begin {children file}

      if f_exists(global_childrenf) = False then
      begin
        Assign(childrenfile, global_childrenf);

            {$I-}rewrite(childrenfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_childrenf, error);

            {$I-}Close(childrenfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_childrenf, error);

      end;

      repeat
        Assign(childrenfile, global_childrenf);
        ok := True;
            {$I-}reset(childrenfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(childrenfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_childrenf);

           {$I-}Close(childrenfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_childrenf, error);

    end;
    FsBarrel: begin {beer barrel lifters top list file}

      if f_exists(global_barrelf) = False then
      begin
        Assign(barrelfile, global_barrelf);

            {$I-}rewrite(barrelfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          unable_to_create(global_barrelf, error);
        end else
        begin
          {create empty barrel record}
          init_barrel_master(newbarrel);
          newbarrel.Name := 'Fingal';
          newbarrel.id := 'AMIGA_RULES!!!!';
          newbarrel.level := 15;
          newbarrel.race := Human;
          newbarrel.class := Warrior;
          newbarrel.deleted := False;
          newbarrel.datee := todays_date;
          newbarrel.barrels := 12;

             {$I-}Write(barrelfile, newbarrel);{$I+}
          error := IoResult;
          if error <> 0 then
            unable_to_write(global_barrelf, error);
        end;

            {$I-}Close(barrelfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_barrelf, error);
      end;

      repeat
        Assign(barrelfile, global_barrelf);
        ok := True;
            {$I-}reset(barrelfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(barrelfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_barrelf);

           {$I-}Close(barrelfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_barrelf, error);

    end;

    FsGod: begin {god file}

      if f_exists(global_godfil) = False then
      begin
        Assign(godfile, global_godfil);

            {$I-}rewrite(godfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_godfil, error);

            {$I-}Close(godfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_godfil, error);

      end;

      repeat
        Assign(godfile, global_godfil);
        ok := True;
            {$I-}reset(godfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

           {$I-}Result := filesize(godfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_godfil);

           {$I-}Close(godfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_godfil, error);

    end;


    FsOnline: begin {onliners.dat file}

      if f_exists(global_onfile) = False then
      begin
        create_onlinefile;
      end;

      repeat
        Assign(onlinefile, global_onfile);
        ok := True;
             {$I-}reset(onlinefile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(onlinefile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_onfile);

            {$I-}Close(onlinefile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_onfile, error);

    end;
    FsMail: begin {mailfile}

      if f_exists(global_mafile) = False then
      begin
        Assign(brevfile, global_mafile);

           {$I-}rewrite(brevfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_mafile, error);

           {$I-}Close(brevfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_mafile, error);

      end;

      repeat
        Assign(brevfile, global_mafile);
        ok := True;
           {$I-}reset(brevfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

          {$I-}Result := filesize(brevfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_mafile);

          {$I-}Close(brevfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_mafile, error);

    end;
    FsWanted: begin {wanted file}

      if not f_exists(global_wwfile) then
      begin
        Assign(wantedfile, global_wwfile);

             {$I-}rewrite(wantedfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_wwfile, error);

             {$I-}Close(wantedfile);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_wwfile, error);

      end;

      repeat
        Assign(wantedfile, global_wwfile);
        ok := True;

             {$I-}reset(wantedfile);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(wantedfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_wwfile);

            {$I-}Close(wantedfile);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_wwfile, error);

    end;
    FsDrink: begin {Drink file, orbs bar, user customized drinks}

      if not f_exists(global_drinkfile) then
      begin
        Assign(drinkf, global_drinkfile);

             {$I-}rewrite(drinkf);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_drinkfile, error);

             {$I-}Close(drinkf);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_drinkfile, error);

      end;

      repeat
        Assign(drinkf, global_drinkfile);
        ok := True;
             {$I-}reset(drinkf);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(drinkf);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_drinkfile);

            {$I-}Close(drinkf);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_close(global_drinkfile, error);

    end;

    FsMoat: begin {Moat Creature file}

      if not f_exists(global_moatfile) then
      begin
        Assign(moatf, global_moatfile);

             {$I-}rewrite(moatf);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_create(global_moatfile, error);

             {$I-}Close(moatf);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_close(global_moatfile, error);

      end;

      repeat
        Assign(moatf, global_moatfile);
        ok := True;
             {$I-}reset(moatf);{$I+}
        error := IoResult;
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

            {$I-}Result := filesize(moatf);{$I+}
      error := IoResult;
      if error <> 0 then
        unable_to_filesize(global_moatfile);

            {$I-}Close(moatf);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_moatfile, error);

    end;

    FsWeaponclassic: begin {weapon file, classic mode}
      repeat
        Assign(weapfile, global_weapofil);
        ok := True;
                     {$I-}reset(weapfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

                    {$I-}Result := filesize(weapfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_filesize(global_weapofil);

                    {$I-}Close(weapfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_weapofil, error);

    end;
    FsArmorclassic: begin {armor file, classic mode}
      repeat
        Assign(armfile, global_armofile);
        ok := True;
                   {$I-}reset(armfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

                  {$I-}Result := filesize(armfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_filesize(global_armofile);

                  {$I-}Close(armfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_armofile, error);

    end;
    FsMonster: begin {monster file}
      repeat
        Assign(monsterfile, global_monfile);
        ok := True;
              {$I-}reset(monsterfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          Inc(i);
          delay2(global_lockdelay);
          ok := False;
        end;
      until (ok) or (i > global_locknrs);

             {$I-}Result := filesize(monsterfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_filesize(global_monfile);

             {$I-}Close(monsterfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_monfile, error);

    end;

  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  fs := Result;

end; {-----FILESIZE END-----}


{-----ITEM FILESIZE START-----}
function FsOb;
var
  memmy, i: integer;
  error:    word;
  ok:       boolean;
  s:        s70;
  ofil:     file of Orec;

begin

  {init}
  error := 0;
  fsob := 0;
  i := 0;

  {remember old filemode}
  memmy := filemode;

  if global_ushare then
  begin
    FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  end;

  repeat
    case otyp of
      Head: s := objf1;
      Body: s := objf2;
      Arms: s := objf3;
      Hands: s := objf4;
      Fingers: s := objf5;
      Legs: s := objf6;
      Feet: s := objf7;
      Waist: s := objf8;
      Neck: s := objf9;
      Face: s := objf10;
      Shield: s := objf11;
      Food: s := objf12;
      Drink: s := objf13;
      Weapon: s := objf14;
      Abody: s := objf15;
    end; {case .end.}

         {assign objekt file}
    Assign(ofil, s);

    ok := True;
  {$I-}reset(ofil);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      Inc(i);
      unable_to_access(s, error);
      delay2(global_lockdelay);
      ok := False;
    end;
  until (ok) or (i > global_locknrs);

 {$I-}fsob := filesize(ofil);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_filesize(s);

 {$I-}Close(ofil);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_close(s, error);

  {reset filmode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {-----ITEM FILESIZE END-----}

     {-----LOAD OBJEKT START------}
function Load_Objekt;
var
  x, i, memmy, error: integer;

  ok, Result: boolean;

  ofil: file of Orec;

  s:    s80;

begin

  {init}
  i := 0;
  memmy := filemode;
  error := 0;
  Result := True;

  {assign default file}
  Assign(ofil, objf1);
  case otyp of
    Head: s := objf1;
    Body: s := objf2;
    Arms: s := objf3;
    Hands: s := objf4;
    Fingers: s := objf5;
    Legs: s := objf6;
    Feet: s := objf7;
    Waist: s := objf8;
    Neck: s := objf9;
    Face: s := objf10;
    Shield: s := objf11;
    Food: s := objf12;
    Drink: s := objf13;
    Weapon: s := objf14;
    Abody: s := objf15;
  end; {case .end.}

       {assign correct file}
  Assign(ofil, s);

  repeat
    ok := True;

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyNone;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(ofil);{$I+}
    error := IOResult;

    if Error <> 0 then
    begin
      unable_to_access(s, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > global_locknrs);

  if ok then
  begin
  {$I-}x := filesize(ofil);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_filesize(s);

    objektt.Name := 'Spade';

    if (filnr > x) or (filnr < 1) then
    begin
      filnr := 1;
    end;

  {$I-}seek(ofil, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      unable_to_seek(s, filnr - 1);
      Result := False;
    end;

  {$I-}Read(ofil, objektt);{$I+}
    error := IOResult;
    if error <> 0 then
    begin
      unable_to_read(s, error);
      Result := False;
    end;

  {$I-}Close(ofil);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(s, error);

  end else
  begin
    unable_to_read(s, error);
    Result := False;
  end;

  {return result}
  load_objekt := Result;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

{-----LOAD OBJEKT END------}

function Lock_MailRecord(var fil; action: filaction; filnr: longint): boolean;
var Result: boolean;
  err:      integer;
  fpos:     longint;
  i:        byte;
  x:        longint;
begin

  {we only use this function if Record locking is enabled}
  if Config.NetShareMethod <> RecordLocking then
  begin
    exit;
  end;

  {init}
  Result := False;
  i := 0;
  x := filnr - 1;

  case Action of
    Flock: begin {lock record}
      Fpos := x * SizeOf(MailRec);
      repeat
        err := File_Lock(Fil, FLock, FPos, FPos + SizeOf(MailRec));
        if err <> 0 then
        begin
          Inc(i);
          unable_to_lock(global_mafile, filnr);
          delay2(global_lockdelay);
        end;
      until (err = 0) or (i > global_locknrs);

         {debug info
         if err=0 then begin
          d(14,'Record locked!');
          result:=true;
         end;
         }

    end;
    Funlock: begin {unlock record}
      Fpos := x * SizeOf(MailRec);
      repeat
        err := File_Lock(fil, FUnLock, FPos, FPos + SizeOf(MailRec));
        if err <> 0 then
        begin
          Inc(i);
          unable_to_unlock(global_mafile, filnr);
          delay2(global_lockdelay);
        end;
      until (err = 0) or (i > global_locknrs);

           {debug info
           if err=0 then begin
            d(14,'Record unlocked!');
            result:=true;
           end;
           }
    end;
  end; {case .end.}

       {return result}
  Lock_MailRecord := Result;

end; {lock_mailrecord *end*}

     {-----LOAD MAIL START------}
procedure Load_Mail(action: filaction; var slask: mailrec; filnr: word);
var ok:  boolean;
  memmy: integer;
  error: integer;
  ii:    integer;
begin

  ok := False;
  ii := 0;
  memmy := filemode;
  error := 0;

  repeat

    Assign(global_mailfile, global_mafile);

    ok := True;

    if global_ushare then
    begin

      case action of
        Fload: begin
          FileMode := fmReadOnly + fmDenyWrite;
        end;
        Fsave: begin

          case Config.NetShareMethod of
            RecordLocking: filemode := fmReadWrite + fmDenyNone;
            FileLocking: fileMode := fmReadWrite + fmDenyAll;
          end; {case .end.}

        end;
      end; {case .end.}
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(global_mailfile);{$I+}
    error := IOResult;

    if error <> 0 then
    begin
      unable_to_access(global_mafile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(ii);
    end;

  until (Ok) or (ii > 100);

  if ok then
  begin

    {lock record}
    if config.netsharemethod = RecordLocking then
    begin
      Lock_MailRecord(global_mailfile, flock, filnr);
    end;

  {$I-}Seek(global_mailfile, filnr - 1);{$I+}
    error := IOResult;
    if error <> 0 then
      unable_to_seek(global_mafile, filnr - 1);

    case action of
      Fload: begin
          {$I-}Read(global_mailfile, slask);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_read(global_mafile, error);
      end;
      Fsave: begin
          {$I-}Write(global_mailfile, slask);{$I+}
        error := IoResult;
        if error <> 0 then
          unable_to_write(global_mafile, error);
      end;
    end; {case .end.}

         {unlock record}
    if config.netsharemethod = RecordLocking then
    begin
      Lock_MailRecord(global_mailfile, funlock, filnr);
    end;

  {$I-}Close(global_mailfile);{$I+}
    error := IOResult;
    if error <> 0 then
      unable_to_close(global_mafile, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_mafile, error);
      Fsave: unable_to_write(global_mafile, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

{-----LOAD MAIL END------}

function Lock_UserRecord(var fil; const infil: s70; action: filaction; filnr: longint): boolean;
var
  Result:  boolean;

  err:     integer;

  i:       byte;

  x, fpos: longint;

begin

  {we only use this function if Record locking is enabled}
  if Config.NetShareMethod <> RecordLocking then
  begin
    exit;
  end;

  {init}
  Result := False;
  i := 0;
  x := filnr - 1;

  case Action of
    Flock: begin {lock record}
      Fpos := x * SizeOf(UserRec);
      repeat
        err := File_Lock(Fil, FLock, FPos, FPos + SizeOf(UserRec));
        if err <> 0 then
        begin
          Inc(i);
          unable_to_lock(infil, filnr);
          delay2(global_lockdelay);
        end;
      until (err = 0) or (i > global_locknrs);

         {debug info
         if err=0 then begin
          d(14,'Record locked!');
          result:=true;
         end;
         }

    end;
    Funlock: begin {unlock record}
      Fpos := x * SizeOf(UserRec);
      repeat
        err := File_Lock(fil, FUnLock, FPos, FPos + SizeOf(UserRec));
        if err <> 0 then
        begin
          Inc(i);
          unable_to_unlock(infil, filnr);
          delay2(global_lockdelay);
        end;
      until (err = 0) or (i > global_locknrs);

           {debug info
           if err=0 then begin
            d(14,'Record unlocked!');
            result:=true;
           end;
           }
    end;

  end; {case .end.}

       {return result}
  lock_UserRecord := Result;

end; {lock_userrecord *end*}

     {-------LOAD CHARACTER START---------}
function Load_Character(var slask: userrec; filtyp: byte; recnr: word): boolean;
var
  ok, Result: boolean;

  i, memmy, error: integer;

  size:     word;
  filnr:    longint;

  WorkName: s90;

  WorkFile: file of UserRec; {** User/Npc file **}

begin

  {init}
  Result := False;
  ok := False;

  if recnr < 1 then
    recnr := 1;
  filnr := recnr - 1;

  if filnr < 0 then
  begin
    filnr := 1;
  end;

  {we bug out if filtyp is not 1 or 2}
  if (filtyp < 1) or (filtyp > 2) then
  begin
    d(15, 'We got a major situation here sir, filtyp reads:' + commastr(filtyp));
    pause;
    load_character := Result;
    exit;
  end;

  {we bug out if recnr is bigger than filesize}
  case filtyp of
    1: size := fs(FsPlayer);
    2: size := fs(FsNpc);
  end; {case .end.}

  if recnr > size then
  begin
    load_character := Result;
    exit;
  end;

  case filtyp of
    1: workname := global_pfile; {playerfile}
    2: workname := global_npfile {npcfile}
    else workname := 'something is wrong in file_io, load_character';
  end;

  i := 0;
  memmy := filemode;
  error := 0;

  repeat
    ok := True;

    {assign filename}
    Assign(workfile, workname);

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(workfile);{$I+}
    error := IoResult;

    if error <> 0 then
    begin
      unable_to_access(workname, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}seek(workfile, filnr);{$I+}
    error := IoResult;

    if error <> 0 then
    begin
      unable_to_seek(workname, filnr);
    end;

  {$I-}Read(workfile, slask);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      unable_to_read(workname, error);
    end else
    begin
      slask.filtyp := filtyp;
      slask.recnr := recnr;
      Result := True;
    end;

  {$I-}Close(workfile);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(workname, error);

  end else
  begin
    unable_to_read(workname, error);
  end;


  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  if Result = ok then
  begin

    {set correct spell levels. this isn't really necessary}
    if slask.class in [Cleric, Magician, Sage] then
    begin
      if slask.level >= 5 then
        slask.spell[2, 1] := True;
      if slask.level >= 10 then
        slask.spell[3, 1] := True;
      if slask.level >= 15 then
        slask.spell[4, 1] := True;
      if slask.level >= 20 then
        slask.spell[5, 1] := True;
      if slask.level >= 25 then
        slask.spell[6, 1] := True;
      if slask.level >= 30 then
        slask.spell[7, 1] := True;
      if slask.level >= 40 then
        slask.spell[8, 1] := True;
      if slask.level >= 50 then
        slask.spell[9, 1] := True;
      if slask.level >= 60 then
        slask.spell[10, 1] := True;
      if slask.level >= 70 then
        slask.spell[11, 1] := True;
      if slask.level >= 80 then
        slask.spell[12, 1] := True;
    end;

    {remove active spells, this shouldn't be necessary either}
    for i := 1 to global_maxspells do
    begin
      slask.spell[i, 2] := False;
    end; {for i:= .end.}

         {check if player has equipment that has been excluded from the editor.}
    check_valid_equipment(slask);

    {sex set. this should never need to be corrected}
    if (slask.sex < 1) or (slask.sex > 2) then
      slask.sex := 1;

  end else
  begin
    {we were unable to read the character}
    unable_to_read_character(workname, recnr);
  end;

  {return result}
  load_character := Result;

end; {Load_Character *end*}


{--------USER SAVE START-----------}
procedure User_Save;

  procedure Humans(var target: userrec);
  var
    found:      boolean;
    power:      longint;
    mem:        longint;
    dummy:      UserRec;
    i:          longint;
    ok:         boolean;
    error:      integer;
    memmy:      integer;
    PlayerFile: file of UserRec;    {** Userfile **}

  begin

    {init}
    found := False;
    error := 0;

    power := 1;
    mem := target.recnr;
    if mem < 1 then
    begin
      mem := 1;
    end else
    begin
      if mem > fs(FsPlayer) then
        mem := 1;
    end;

    if load_character(dummy, 1, mem) = True then
    begin
      if target.name2 = dummy.name2 then
      begin
        power := mem;
        found := True;
      end;
    end;

    if not found then
    begin
      for i := 1 to fs(FsPlayer) do
      begin
        if load_character(dummy, 1, i) = True then
        begin
          if target.name2 = dummy.name2 then
          begin
            power := i;
            found := True;
            break;
          end;
        end;
      end; {for i:= .end.}
    end;

    if found then
    begin
      if target.deleted then
      begin
        target.name1 := global_delname1;
        target.name2 := global_delname2;
      end;

      ok := False;
      i := 0;

      {remember old filemode}
      memmy := filemode;

      repeat
        ok := True;
        Assign(playerfile, global_pfile);

        {set filemode}
        if global_ushare then
        begin
          case Config.NetShareMethod of
            RecordLocking: filemode := fmReadWrite + fmDenyNone;
            FileLocking: fileMode := fmReadWrite + fmDenyAll;
          end; {case .end.}
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

   {$I-}reset(playerfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(global_pfile, error);
          delay2(global_lockdelay);
          ok := False;
          Inc(i);
        end;
      until (Ok) or (i > global_locknrs);

      if ok then
      begin

        {lock record}
        if config.netsharemethod = RecordLocking then
        begin
          Lock_UserRecord(playerfile, global_pfile, flock, power);
        end;

   {$I-}seek(playerfile, power - 1);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_seek(global_pfile, power - 1);

   {$I-}Write(playerfile, target);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_pfile, error);

        {unlock record}
        if config.netsharemethod = RecordLocking then
        begin
          Lock_UserRecord(playerfile, global_pfile, funlock, power);
        end;

   {$I-}Close(playerfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_close(global_pfile, error);

      end else
      begin
        unable_to_write(global_pfile, error);
      end;

      {reset filemode}
      filemode := memmy;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  end;

  procedure Npcs(var target: userrec);
  var
    found:   boolean;
    power:   longint;
    mem:     longint;
    dummy:   UserRec;
    i:       longint;
    ok:      boolean;
    memmy:   integer;
    error:   integer;
    NpcFile: file of Userrec;

  begin

    {init}
    error := 0;
    power := 1;
    found := False;
    mem := target.recnr;

    if mem < 1 then
    begin
      mem := 1;
    end else
    begin
      if mem > fs(FsNpc) then
        mem := 1;
    end;

    if load_character(dummy, 2, mem) = True then
    begin
      if target.name2 = dummy.name2 then
      begin
        power := mem;
        found := True;
      end;
    end;

    if not found then
    begin
      for i := 1 to fs(FsNpc) do
      begin
        if load_character(dummy, 2, i) = True then
        begin
          if target.name2 = dummy.name2 then
          begin
            power := i;
            found := True;
            break;
          end;
        end; {for i:= .end.}
      end;
    end;

    if found then
    begin
      if target.deleted then
      begin
        target.name1 := global_delname1;
        target.name2 := global_delname2;
      end;

      i := 0;
      {remember filemode}
      memmy := filemode;

      repeat
        ok := True;
        Assign(npcfile, global_npfile);

        {set filemode}
        if global_ushare then
        begin
          case Config.NetShareMethod of
            RecordLocking: filemode := fmReadWrite + fmDenyNone;
            FileLocking: fileMode := fmReadWrite + fmDenyAll;
          end; {case .end.}
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

   {$I-}reset(npcfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(global_npfile, error);
          delay2(global_lockdelay);
          ok := False;
          Inc(i);
        end;
      until (Ok) or (i > global_locknrs);

      if ok then
      begin

        {lock record}
        if config.netsharemethod = RecordLocking then
        begin
          Lock_UserRecord(npcfile, global_npfile, flock, power);
        end;

   {$I-}seek(npcfile, power - 1);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_seek(global_npfile, power - 1);

   {$I-}Write(npcfile, target);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_npfile, error);

        {unlock record}
        if config.netsharemethod = RecordLocking then
        begin
          Lock_UserRecord(npcfile, global_npfile, funlock, power);
        end;

   {$I-}Close(npcfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_close(global_npfile, error);

      end else
      begin
        unable_to_write(global_npfile, error);
      end;

      {reset filemode}
      filemode := memmy;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end else
    begin
      humans(target);
    end;

  end;

begin {User_Save *START*}

  case save_me.ai of
    'H': humans(save_me);
    'C': npcs(save_me);
  end; {case .end.}

end;

{--------USER SAVE END-----------}

procedure Append_OnlineGuy(var Person: OnlineRec);
var Memmy: NetShareMethods;
begin

  {appends PERSON at the end of ONLINERS.DAT}

  {we lock the file so that we have it for ourselves}
  memmy := config.NetShareMethod;
  Config.NetShareMethod := FileLocking;

  if Lock_OnlineFile(FLock) = True then
  begin

    {hitler}

    person.recnr := Global_OnlineFileSize + 1;

    Load_onlinefile(fsave, person, person.recnr);

    {unlock file}
    lock_onlinefile(funlock);

  end else
  begin
    {we were unable to get a lock on the file}
    unable_to_lockfile(global_onfile);
  end;

  {reset NetShareMethod}
  Config.NetShareMethod := Memmy;

end; {append_onlineguy *end*}

     {------LOAD WANTED START---------}
procedure Load_Wanted;
var
  ok:         boolean;
  i:          integer;
  error:      integer;
  memmy:      integer;
  WantedFile: file of WantedRec;  {** Wanted file         **}

begin

  {most wanted file, load & save}

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(wantedfile, global_wwfile);

    if global_ushare then
    begin
      case action of
        Fload: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(wantedfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_wwfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(wantedfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_wwfile, filnr - 1);

    case action of
      Fload: begin
          {$I-}Read(wantedfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_wwfile, error);
      end;
      Fsave: begin
          {$I-}Write(wantedfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_wwfile, error);
      end;
    end;

  {$I-}Close(wantedfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_wwfile, error);

  end else
  begin

    case action of
      Fload: unable_to_read(global_wwfile, error);
      Fsave: unable_to_write(global_wwfile, error);
    end; {case .end.}

  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {------LOAD WANTED END---------}

 {------LOAD KING START---------}
procedure Load_King;
var ok:     boolean;
  i:        integer;
  error:    integer;
  memmy:    integer;
  KingFile: file of KingRec;  {** King file **}
begin

  {king orders file}

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  {does file exist}
  if not f_exists(global_kingf) then
  begin
    {init}
    new_king(king);

    repeat
      ok := False;
      Assign(kingfile, global_kingf);
   {$I-}rewrite(kingfile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
      begin
        unable_to_create(global_kingf, error);
        delay2(global_lockdelay);
        ok := False;
        Inc(i);
      end else
      begin

    {$I-}Write(kingfile, king);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_kingf, error);

    {$I-}Close(kingfile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_close(global_kingf, error);

        ok := True;
      end;
    until (Ok) or (i > global_locknrs);
  end; {file does not exist .end.}

       {read/write}
  i := 0;
  repeat
    ok := True;
    Assign(kingfile, global_kingf);

    if global_ushare then
    begin
      case action of
        Fload: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(kingfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_kingf, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > global_locknrs);

  if ok then
  begin
  {$I-}Seek(kingfile, 0);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_kingf, 0);

    case action of
      Fload: begin
          {$I-}Read(kingfile, king);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_kingf, error);
      end;
      Fsave: begin
          {$I-}Write(kingfile, king);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_kingf, error);
      end;
    end; {case .end.}

  {$I-}Close(kingfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_kingf, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_kingf, error);
      Fsave: unable_to_write(global_kingf, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {------LOAD KING END---------}

 {------LOAD GUARD START--------}
procedure Load_Guard;
var ok:      boolean;
  i:         integer;
  error:     integer;
  memmy:     integer;
  GuardFile: file of GuardRec;   {** DoorGuard file      **}

begin

  {most wanted file, load & save}

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(guardfile, global_gufile);

    if global_ushare then
    begin
      case action of
        Fload: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmReadWrite + fmDenyAll;
      end; {case .end.}
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(guardfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_gufile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin
  {$I-}Seek(guardfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_gufile, filnr - 1);

    case action of
      Fload: begin
          {$I-}Read(guardfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_gufile, error);
      end;
      Fsave: begin
          {$I-}Write(guardfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_gufile, error);
      end;
    end; {case .end.}

  {$I-}Close(guardfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_gufile, error);
  end else
  begin
    case action of
      Fload: unable_to_read(global_gufile, error);
      Fsave: unable_to_write(global_gufile, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {------LOAD GUARD END--------}

 {------LOAD QUEST START--------}
procedure Load_Quest;
var ok:      boolean;
  i:         integer;
  error:     integer;
  memmy:     integer;
  QuestFile: file of QuestRec;   {** Quest file      **}

begin

  {Royal Quest file}

  {init}
  i := 0;
  error := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(questfile, global_rquestf);

    if global_ushare then
    begin
      case action of
        Fload: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmReadWrite + fmDenyAll;
      end; {case .end.}
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(questfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_rquestf, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(questfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_rquestf, filnr - 1);

    case action of
      Fload: begin
          {$I-}Read(questfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_rquestf, error);
      end;
      Fsave: begin
          {$I-}Write(questfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_rquestf, error);
      end;
    end; {case .end.}

  {$I-}Close(questfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_rquestf, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_rquestf, error);
      Fsave: unable_to_write(global_rquestf, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

{------LOAD QUEST END--------}


{------LOAD CHEST_ITEM START------}
procedure Load_ChestItem;
var
  ok:     boolean;
  i:      integer;
  error:  integer;
  memmy:  integer;
  PMFile: file of ChestItemRec;  {** ChestItem file   **}

begin

  {chest item file}

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(pmfile, global_chestfile);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(pmfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_chestfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(pmfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_chestfile, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(pmfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_chestfile, error);
      end;
      FSave: begin
          {$I-}Write(pmfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_chestfile, error);
      end;
    end; {case .end.}

  {$I-}Close(pmfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_chestfile, error);
  end else
  begin

    case action of
      Fload: unable_to_read(global_chestfile, error);
      Fsave: unable_to_write(global_chestfile, error);
    end; {case .end.}

  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

{------LOAD CHEST_ITEM END------}




{------LOAD MARKET START------}
procedure Load_Market;
var
  ok:     boolean;
  i:      integer;
  error:  integer;
  memmy:  integer;
  PMFile: file of MarketItemRec;  {** PlayerMarket file   **}

begin

  {player market file}

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(pmfile, global_marketfile);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(pmfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_marketfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(pmfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_marketfile, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(pmfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_marketfile, error);
      end;
      FSave: begin
          {$I-}Write(pmfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_marketfile, error);
      end;
    end; {case .end.}

  {$I-}Close(pmfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_marketfile, error);
  end else
  begin

    case action of
      Fload: unable_to_read(global_marketfile, error);
      Fsave: unable_to_write(global_marketfile, error);
    end; {case .end.}

  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {------LOAD MARKET END------}

 {------LOAD DRINK START------}
function Load_Drink;
var
  ok, Result: boolean;
  i:          integer;
  memmy:      integer;
  error:      integer;
  DRFile:     file of DrinkRec;    {** Drink file   **}

begin

  {users own drinks, created at Orbs Bar}
  Result := False;
  i := 0;
  {remember filemode}
  memmy := filemode;
  error := 0;

  repeat
    ok := True;
    Assign(drfile, global_drinkfile);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(drfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_drinkfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(drfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_drinkfile, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(drfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_drinkfile, error)
        else Result := True;
      end;
      FSave: begin
          {$I-}Write(drfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_drinkfile, error)
        else Result := True;
      end;
    end; {case .end.}

  {$I-}Close(drfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_drinkfile, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_drinkfile, error);
      Fsave: unable_to_write(global_drinkfile, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  load_drink := Result;

end;

 {------LOAD DRINK END------}

 {------LOAD MOAT CREATURE START------}
procedure Load_Moat;
var
  ok:      boolean;
  i:       integer;
  error:   integer;
  memmy:   integer;
  MotFile: file of MoatRec; {** Moat Creature file **}

begin

  {Moat Creatures, swimming in the Royla Castle Moat}

  {init}
  i := 0;
  error := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(motfile, global_moatfile);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(motfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_moatfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(motfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_moatfile, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(motfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_moatfile, error);
      end;
      FSave: begin
          {$I-}Write(motfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_moatfile, error);
      end;
    end; {case .end.}

  {$I-}Close(motfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_moatfile, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_moatfile, error);
      Fsave: unable_to_write(global_moatfile, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {------LOAD DRINK END------}

 {------LOAD RELATION START------}
function Load_Relation;
var
  ok, Result: boolean;
  i:          integer;
  error:      integer;
  memmy:      integer;
  REFile:     file of RelationRec; {** Social Relation file **}

begin

  {social relations}

  {init}
  i := 0;
  error := 0;
  Result := False;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(REfile, global_relationf);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(REfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_relationf, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(REfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_relationf, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(REfile, slask);{$I+}
        error := IoResult; {get error}
        slask.recnr := filnr;

        if error <> 0 then
          unable_to_read(global_relationf, error)
        else Result := True;
      end;
      FSave: begin
          {$I-}Write(REfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_relationf, error)
        else Result := True;
      end;
    end; {case .end.}

  {$I-}Close(REfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_relationf, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_relationf, error);
      Fsave: unable_to_write(global_relationf, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  load_relation := Result;

end;

{------LOAD RELATION END------}

function Load_BardSong(var bardsong: bardtype; const nr: word): boolean;
var Result: boolean;
  txtfile:  Text;
begin

  {init}
  Result := False;

  {open bard song datafile}
  if open_txtfile(treset, txtfile, global_bardsongf) = True then
  begin
    {let us find song #NR}
  {himmler hitler
  global_bardlines yamaha}
  end;

  {return result}
  load_bardsong := Result;

end; {load_bardsong *end*}

     {------LOAD CHILD START------}
function Load_Child;
var
  ok, Result:      boolean;

  i, error, memmy: integer;

  CHFile:          file of ChildRec; {** Children file **}

begin

  {children, load and save procedure}

  {init}
  i := 0;
  error := 0;
  Result := False;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(CHfile, global_childrenf);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(CHfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_childrenf, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(CHfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_childrenf, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(CHfile, slask);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_read(global_childrenf, error);
        end else
        begin
          slask.recnr := filnr;
          Result := True;
        end;

      end;
      FSave: begin
          {$I-}Write(CHfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          unable_to_write(global_childrenf, error);
        end else
        begin
          Result := True;
        end;
      end;
    end; {case .end.}

  {$I-}Close(CHfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_childrenf, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_childrenf, error);
      Fsave: unable_to_write(global_childrenf, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  load_child := Result;

end; {------LOAD CHILD END------}

     {------LOAD BARREL START------}
procedure Load_Barrel;
var
  ok:         boolean;
  i:          integer;
  error:      integer;
  memmy:      integer;
  BarrelFile: file of BarrelRec; {** Barrel Lifters top list file **}

begin

  {barrel lifters, see gym.pas}

  {init}
  i := 0;
  error := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(BarrelFile, global_barrelf);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(Barrelfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_barrelf, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(Barrelfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_barrelf, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(Barrelfile, slask);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
          unable_to_read(global_barrelf, error);

      end;
      FSave: begin
          {$I-}Write(Barrelfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_barrelf, error);
      end;
    end; {case .end.}

  {$I-}Close(Barrelfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_barrelf, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_barrelf, error);
      Fsave: unable_to_write(global_barrelf, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {------LOAD BARREL END------}

     {------LOAD GOD START------}
function Load_God;
var
  ok, Result:      boolean;

  i, error, memmy: integer;

  GodFile:         file of GodRec; {** God file **}

begin

  {gods in heaven}

  {init}
  i := 0;
  error := 0;
  Result := False;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(GodFile, global_godfil);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        FSave: FileMode := fmReadWrite + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(Godfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_godfil, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(Godfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_godfil, filnr - 1);

    case action of
      FLoad: begin
          {$I-}Read(Godfile, slask);{$I+}
        error := IoResult; {get error}
        slask.recnr := filnr;
        if error <> 0 then
        begin
          unable_to_read(global_godfil, error);
        end else
        begin
          Result := True;
        end;

      end;
      FSave: begin

          {$I-}Write(Godfile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          unable_to_write(global_godfil, error);
        end else
        begin
          Result := True;
        end;

      end;
    end; {case .end.}

  {$I-}Close(Godfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_godfil, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_godfil, error);
      Fsave: unable_to_write(global_godfil, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  load_god := Result;

end;

 {------LOAD GOD END------}

 {---LOAD classIC WEAPON START-----}
procedure Load_Weapon;
var i, error: integer;
  memmy:      integer;
  ok:         boolean;
  weapfile:   file of weaprec;
begin

  {init}
  error := 0;
  i := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(weapfile, global_weapofil);

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(weapfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_weapofil, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(weapfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_weapofil, filnr - 1);

  {$I-}Read(weapfile, inweap);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_read(global_weapofil, error);

  {$I-}Close(weapfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_weapofil, error);

  end else
  begin
    unable_to_read(global_weapofil, error);
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {---LOAD classIC WEAPON END-----}

 {---LOAD classIC ARMOR START----}
procedure Load_Armor;
var i, error: integer;
  memmy:      integer;
  ok:         boolean;
  armfile:    file of armrec;

begin

  {init}
  error := 0;
  i := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(armfile, global_armofile);

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(armfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_armofile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(armfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_armofile, filnr - 1);

  {$I-}Read(armfile, inarm);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_read(global_armofile, error);

  {$I-}Close(armfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_armofile, error);

  end else
  begin
    unable_to_read(global_armofile, error);
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

 {---LOAD classIC ARMOR END----}

 {---LOAD MONSTER START----}
procedure Load_Monster;
var
  i:           longint;
  error:       integer;
  memmy:       integer;
  ok:          boolean;
  objekt:      ^orec;
  Monsterfile: file of MonsterRec; {** Monster file        **}

begin
  {init}
  new(objekt);
  error := 0;
  i := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(monsterfile, global_monfile);

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(monsterfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_monfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

 {$I-}seek(monsterfile, filnr);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_seek(global_monfile, filnr);

 {$I-}Read(monsterfile, monster[monnr]^);{$I+}


  error := IoResult; {get error}
  if error <> 0 then
    unable_to_read(global_monfile, error);

 {$I-}Close(monsterfile);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_close(global_monfile, error);

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  objekt^.Name := '';
  if monster[monnr]^.weapnr > 0 then
  begin
    load_objekt(objekt^, weapon, monster[monnr]^.weapnr);
  end;
  monster[monnr]^.weapon := objekt^.Name;

  objekt^.Name := '';
  if monster[monnr]^.armnr > 0 then
  begin
    load_objekt(objekt^, abody, monster[monnr]^.armnr);
  end;
  monster[monnr]^.armor := objekt^.Name;

  {calculating monsters MANA, depending on magic level}
  if monster[monnr]^.magiclevel > 0 then
  begin
    monster[monnr]^.maxmana := monster[monnr]^.magiclevel * 60;
    monster[monnr]^.mana := monster[monnr]^.maxmana;
  end;

  {dispose pointer var}
  dispose(objekt);

end;

 {---LOAD MONSTER END----}

 {---LOAD LEVEL START-----}
procedure Load_Level;
var i, error, memmy: integer;
  ok:        boolean;
  LevelFile: file of LevelRec;   {** Level Limits        **}

begin

  {init}
  error := 0;
  i := 0;
  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(levelfile, global_lvlfile);

    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(levelfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_lvlfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}Seek(levelfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_lvlfile, filnr - 1);

  {$I-}Read(levelfile, lev);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_read(global_lvlfile, error);

  {$I-}Close(levelfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_lvlfile, error);

  end else
  begin
    unable_to_read(global_lvlfile, error);
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end;

{---LOAD LEVEL END-----}

function Lock_OnlineRecord(action: filaction; filnr: longint): boolean;
var Result: boolean;
  error:    integer;
  fpos:     longint;
  i:        byte;
  x:        longint;
begin

  {we only use this function if Record locking is enabled}
  if Config.NetShareMethod <> RecordLocking then
  begin
    exit;
  end;

  {init}
  Result := False;
  error := 0;
  i := 0;
  x := filnr - 1;

 { debug info
 d(15,'global_onlinefilesize='+commastr(global_onlinefilesize));
 d(15,'filnr='+commastr(filnr));
 d(15,'x='+commastr(x)+', onlinerec='+commastr(sizeof(onlinerec)));
 pause;
 }

  case Action of
    Flock: begin {lock record}
      Fpos := x * SizeOf(OnlineRec);
      repeat
        error := File_Lock(Global_OnlineFile, FLock, FPos, FPos + SizeOf(OnlineRec));
        if error <> 0 then
        begin
          Inc(i);
          unable_to_lock(global_onfile, filnr);
          delay2(global_lockdelay);
        end;
      until (error = 0) or (i > global_locknrs);

      { debug info}
        { if error=0 then begin
          d(14,'Record locked!');
          result:=true;
         end;
         }

    end;
    Funlock: begin {unlock record}
      Fpos := x * SizeOf(OnlineRec);
      repeat
        error := File_Lock(Global_OnlineFile, FUnLock, FPos, FPos + SizeOf(OnlineRec));
        if error <> 0 then
        begin
          Inc(i);
          unable_to_unlock(global_onfile, filnr);
          delay2(global_lockdelay);
        end;
      until (error = 0) or (i > global_locknrs);

      { debug info}
         {  if error=0 then begin
            d(14,'Record unlocked!');
            result:=true;
           end;
          }

    end;
  end; {case .end.}

       {return result}
  Lock_OnlineRecord := Result;

end;

{---LOCK_ONLINEFILE START-----}
function Lock_OnlineFile;
var
  Result: boolean;
  memmy:  integer;
  i:      integer;
  error:  integer;
begin

  {init vars}
  memmy := filemode;
  i := 0;
  error := 0;
  Result := False;

  case action of
    FUnlock: begin

           {$I-}Close(global_onlinefile);{$I-}
      error := IoResult; {get error}
      if error <> 0 then
      begin
        unable_to_close(global_onfile, error);
      end else
      begin
        Result := True;
      end;

    end;
    FLock: begin

      if f_exists(global_onfile) = False then
      begin

          {$I-}rewrite(global_onlinefile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_create(global_onfile, error);

          {$I-}Close(global_onlinefile);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_close(global_onfile, error);

      end;

      repeat

        Assign(global_onlinefile, global_onfile);

        if global_ushare then
        begin
          case Config.NetShareMethod of
            RecordLocking: filemode := fmReadWrite + fmDenyNone;
            FileLocking: fileMode := fmReadWrite + fmDenyAll;
          end;
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

          {$I-}reset(global_onlinefile);{$I+}
        error := IOResult;

        if error <> 0 then
        begin
          unable_to_access(global_onfile, error);
          delay2(global_lockdelay);
          Inc(i);
        end else
        begin

           {$I-}global_onlinefilesize := filesize(global_onlinefile);{$I+}
          error := IoResult; {get error}
          if error <> 0 then
          begin
            unable_to_filesize(global_onfile);
            global_onlinefilesize := 0;
          end else
          begin
            Result := True;
          end;

        end;

      until (Result) or (i > global_locknrs);

    end;
  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  lock_onlinefile := Result;

end;

 {---LOCK_ONLINEFILE END-----}

 {---LOAD ONLINEFILE START----}
function Load_OnlineFile;
var x:      longint;
  error:    integer;
  Result:   boolean;
  go_ahead: boolean;
begin

  {init}
  error := 0;
  x := filnr - 1;
  Result := False;
  go_ahead := True;

  {hunting the 4GB file error}
  if (x < 0) or (x > 700) then
  begin

    if x <> -1 then
    begin
      d(error_col, error_mes + 'Strange Number (' + commastr(x) + ') Given to Load_Onlinefile! Notify SYSOP');
      if action = fsave then
      begin
        d(error_col, 'This occured when trying to SAVE ' + slask.Name + '.');
      end else
      begin
        d(error_col, 'This occured when trying to LOAD ' + slask.Name + '.');
      end;
      d(12, 'The Action was denied!');
    end;
    go_ahead := False;

  end;

  if go_ahead then
  begin

 {$I-}seek(global_onlinefile, x);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      unable_to_seek(global_onfile, x);
    end else
    begin
      case action of
        Fload: begin
          {$I-}Read(global_onlinefile, slask);{$I+}
          error := IoResult; {get error}
          if error <> 0 then
          begin
            unable_to_read(global_onfile, error);
          end else
          begin
            Result := True;
          end;

        end;
        Fsave: begin
          {$I-}Write(global_onlinefile, slask);{$I+}
          error := IoResult; {get error}
          if error <> 0 then
          begin
            unable_to_write(global_onfile, error);
          end else
          begin
            Result := True;
          end;

        end;
      end; {case .end.}
    end;
  end;     {go_ahead}

           {return result}
  load_onlinefile := Result;

end;

 {---LOAD ONLINEFILE END----}

 {---LOCK_QUEST-FILE START-----}
function Lock_QuestFile;
var ok:  boolean;
  error: integer;
  memmy: integer;
  i:     integer;
begin

  {init vars}
  memmy := filemode;
  error := 0;
  i := 0;
  ok := False;

  case action of
    FUnlock: begin
           {$I-}Close(global_questfile);{$I-}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_rquestf, error)
      else ok := True;
    end;
    FLock: begin
      repeat

        Assign(global_questfile, global_rquestf);

        if global_ushare then
        begin
          FileMode := fmReadWrite + fmDenyAll;
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

          {$I-}reset(global_questfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(global_rquestf, error);
          delay2(global_lockdelay);
          Inc(i);
        end else
        begin
          ok := True;
        end;
      until (Ok) or (i > global_locknrs);
    end;
  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  lock_questfile := ok;

end;

 {---LOCK_QUEST-FILE END-----}

 {---LOAD QUEST-FILE START----}
procedure Load_QuestFile;
var error: integer;
begin

  {init}
  error := 0;

 {$I-}seek(global_questfile, filnr - 1);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_seek(global_rquestf, filnr - 1);

  case action of
    Fload: begin
         {$I-}Read(global_questfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_read(global_rquestf, error);
    end;
    Fsave: begin
         {$I-}Write(global_questfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_write(global_rquestf, error);
    end;
  end; {case .end.}

end;

 {---LOAD QUEST-FILE END----}

 {---LOCK_RELATION-FILE START-----}
function Lock_RelationFile;
var
  ok:    boolean;
  error: integer;
  memmy: integer;
  i:     integer;

begin

  {init vars}
  error := 0;
  memmy := filemode;
  i := 0;
  ok := False;

  if f_exists(global_relationf) = False then
  begin

  {$I-}rewrite(global_relationfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_create(global_relationf, error);

  {$I-}Close(global_relationfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_relationf, error);

  end;

  case action of
    FUnlock: begin
           {$I-}Close(global_relationfile);{$I-}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_relationf, error)
      else ok := True;
    end;
    FLock: begin
      repeat

        Assign(global_relationfile, global_relationf);

        if global_ushare then
        begin
          FileMode := fmReadWrite + fmDenyAll;
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

          {$I-}reset(global_relationfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(global_relationf, error);
          delay2(global_lockdelay);
          Inc(i);
        end else
        begin
           {$I-}global_RelationFileSize := filesize(global_relationfile);{$I+}
          error := IoResult; {get error}
          if error <> 0 then
            unable_to_filesize(global_relationf);

          ok := True;
        end;
      until (Ok) or (i > global_locknrs);
    end;
  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  lock_relationfile := ok;

end;

 {---LOCK_RELATION-FILE END-----}

 {---LOAD RELATION-FILE START----}
procedure Load_RelationFile;
var error: integer;
begin

  {init}
  error := 0;

 {$I-}seek(global_relationfile, filnr - 1);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_seek(global_relationf, filnr - 1);

  case action of
    Fload: begin
         {$I-}Read(global_relationfile, slask);{$I+}
      error := IoResult; {get error}
      slask.recnr := filnr;
      if error <> 0 then
        unable_to_read(global_relationf, error);
    end;
    Fsave: begin
         {$I-}Write(global_relationfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_write(global_relationf, error);
    end;
  end; {case .end.}

end;

 {---LOAD RELATION-FILE END----}

 {---LOCK MAIL-FILE START-----}
function Lock_MailFile;
var ok:     boolean;
  memmy:    integer;
  i, error: integer;
begin

  {init vars}
  memmy := filemode;
  i := 0;
  ok := False;
  error := 0;

  if f_exists(global_mafile) = False then
  begin

    Assign(global_mailfile, global_mafile);

  {$I-}rewrite(global_mailfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_create(global_mafile, error);

  {$I-}Close(global_mailfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_mafile, error);

  end;

  case action of
    FUnlock: begin
           {$I-}Close(global_mailfile);{$I-}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_mafile, error)
      else ok := True;
    end;
    FLock: begin
      repeat

        Assign(global_mailfile, global_mafile);

        if global_ushare then
        begin
          case Config.NetShareMethod of
            RecordLocking: filemode := fmReadWrite + fmDenyNone;
            FileLocking: fileMode := fmReadWrite + fmDenyAll;
          end;
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

          {$I-}reset(global_mailfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(global_mafile, error);
          delay2(global_lockdelay);
          Inc(i);
        end else
        begin
           {$I-}global_MailFileSize := filesize(global_mailfile);{$I+}
          error := IoResult; {get error}
          if error <> 0 then
            unable_to_filesize(global_mafile);
          ok := True;
        end;
      until (Ok) or (i > global_locknrs);
    end;
  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  lock_mailfile := ok;

end;

 {---LOCK MAIL-FILE END-----}

 {---LOAD MAIL-FILE START----}
procedure Load_MailFile;
var error: integer;
begin

  {init}
  error := 0;

 {$I-}seek(global_mailfile, filnr - 1);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_seek(global_mafile, filnr - 1);

  case action of
    Fload: begin
         {$I-}Read(global_mailfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_read(global_mafile, error);
    end;
    Fsave: begin
         {$I-}Write(global_mailfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_write(global_mafile, error);
    end;
  end; {case .end.}

end;

{---LOAD MAIL-FILE END----}


{---LOAD ONLINER START----}
function Load_Onliner;
var
  ok, Result:      boolean;

  x, fpos:         longint;

  i, memmy, error: integer;

  OnlineFile:      file of OnlineRec;  {** Online players **}

begin

  {init}
  error := 0;
  ok := False;
  Result := False;
  i := 0;

  {remember filemode}
  memmy := filemode;
  x := filnr - 1;

  repeat
    ok := True;
    Assign(onlinefile, global_onfile);

    if global_ushare then
    begin

      {set filemode}
      case Config.NetShareMethod of

        FileLocking: begin {file locking, slow but safe}
          case action of
            FLoad: FileMode := fmReadOnly + fmDenyWrite;
            Fsave: FileMode := fmReadWrite + fmDenyAll;
          end;
        end;
        RecordLocking: begin {record locking, fast but not compatible with all OS}
          FileMode := fmReadWrite + fmDenyNone;
        end;

      end; {case .end.}
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end; {if global_ushare .end.}

  {$I-}reset(onlinefile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_onfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;

  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}seek(onlinefile, x);{$I+}
    if IOResult <> 0 then
      unable_to_seek(global_onfile, x);

    if Config.NetShareMethod = RecordLocking then
    begin
      {lock record}

      i := 0;
      Fpos := x * SizeOf(OnlineRec);
      repeat
        error := File_Lock(OnlineFile, FLock, FPos, FPos + SizeOf(OnlineRec));
        if error <> 0 then
        begin
          Inc(i);
          unable_to_lock(global_onfile, filnr);
          delay2(global_lockdelay);
        end;
      until (error = 0) or (i > global_locknrs);

   {
   if error=0 then begin
    d(14,'Record locked!');
   end;
   }

    end; {record locking .end.}

    Result := False; {skitapa}
    case action of
      Fload: begin
          {$I-}Read(onlinefile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          unable_to_read(global_onfile, error);
        end else
        begin
          Result := True;
        end;

      end;
      Fsave: begin
          {$I-}Write(onlinefile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
        begin
          unable_to_write(global_onfile, error);
        end else
        begin
          Result := True;
        end;
      end;
    end; {case .end.}

    if Config.NetShareMethod = RecordLocking then
    begin
      {unlock record}
      i := 0;
      Fpos := x * SizeOf(OnlineRec);
      repeat
        error := File_Lock(OnlineFile, FUnLock, FPos, FPos + SizeOf(OnlineRec));
        if error <> 0 then
        begin
          Inc(i);
          unable_to_unlock(global_onfile, filnr);
          delay2(global_lockdelay);
        end;
      until (error = 0) or (i > global_locknrs);

   {
   if error=0 then begin
    d(14,'Record unlocked!');
   end;
   }

    end;

  {$I-}Close(onlinefile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_onfile, error);

  end else
  begin
    case action of
      Fload: unable_to_read(global_onfile, error);
      Fsave: unable_to_write(global_onfile, error);
    end; {case .end.}
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  load_onliner := Result;

end; {---LOAD ONLINER END----}



{---LOAD/SAVE in ONLINE Battle/Trading  START---}
procedure LoadSave_Com(action: filaction; var commy: comrec; filnr: byte; save_mess: s70);
var
  i:       integer;
  ok:      boolean;
  error:   integer;
  memmy:   integer;
  ComFile: file of ComRec;     {** Comm file for duels **}

begin

  {set correct filnr}
  Inc(filnr);

  {init}
  i := 0;
  error := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    display_bar_Status(False);

    ok := True;
    Assign(comfile, onliner.comfile);

    if global_ushare then
    begin
      case action of
        Fload: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmWriteOnly + fmDenyAll;
      end;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(comfile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(onliner.comfile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);

      if f_exists(onliner.comfile) = False then
      begin
        i := 101;
      end;

    end;

  until (Ok) or (i > 100);

  if ok then
  begin

  {$I-}seek(comfile, filnr - 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(onliner.comfile, filnr - 1);

    case action of
      Fload: begin
          {$I-}Read(comfile, commy);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(onliner.comfile, error);
      end;
      Fsave: begin
        if save_mess <> '' then
          commy.mess[1] := save_mess; {trading}
          {$I-}Write(comfile, commy);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(onliner.comfile, error);
      end;
    end; {case .end.}

  {$I-}Close(comfile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(onliner.comfile, error);
  end else
  begin
    {unable to access file}
    case action of
      Fload: unable_to_read(onliner.comfile, error);
      Fsave: unable_to_write(onliner.comfile, error);
    end;
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {---LOAD/SAVE in ONLINE Battle/Trading  END---}


procedure Load_Safe;
var
  ok:       boolean;
  i:        integer;
  error:    integer;
  memmy:    integer;
  safefile: file of saferec; {Bank Safe file}

begin

  {init}
  error := 0;
  ok := False;
  i := 0;

  {remember filemode}
  memmy := filemode;

  repeat
    ok := True;
    Assign(safefile, global_saffile);

    if global_ushare then
    begin
      case action of
        FLoad: FileMode := fmReadOnly + fmDenyWrite;
        Fsave: FileMode := fmReadWrite + fmDenyAll;
      end; {case .end.}
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(safefile);{$I+}
    error := IoResult; {get error}

    if error <> 0 then
    begin
      unable_to_access(global_saffile, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end;
  until (Ok) or (i > global_locknrs);

  if ok then
  begin

  {$I-}seek(safefile, 0);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_seek(global_saffile, 0);

    case action of
      Fload: begin
          {$I-}Read(safefile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_read(global_saffile, error);
      end;
      Fsave: begin
          {$I-}Write(safefile, slask);{$I+}
        error := IoResult; {get error}
        if error <> 0 then
          unable_to_write(global_saffile, error);
      end;
    end; {case .end.}

  {$I-}Close(safefile);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(global_saffile, error);
  end else
  begin
    case action of
      Fload: unable_to_read(global_saffile, error);
      Fsave: unable_to_write(global_saffile, error);
    end;
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {---LOAD SAFE END----}

procedure Safe_Reset; {Reset Bank Safe}
var bye:    boolean;
  i:        integer;
  error:    integer;
  safefile: file of saferec;
  safet:    saferec;
begin

  {init}
  error := 0;

  safet.Value := 0;
  Inc(safet.Value, random(32000));
  Inc(safet.Value, random(32000));
  Inc(safet.Value, random(32000));

  bye := False;
  i := 0;
  repeat
    Assign(safefile, global_saffile);
  {$I-}rewrite(safefile);{$I+}
    error := IoResult; {get error}
    if error = 0 then
    begin

   {$I-}Write(safefile, safet);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_write(global_saffile, error);

   {$I-}Close(safefile);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(global_saffile, error);

      bye := True;

    end else
    begin
      unable_to_create(global_saffile, error);
      Inc(i);
      delay2(global_lockdelay);
    end;
  until (bye) or (i > global_lockdelay);

end;

{---LOCK_ONDUEL-FILE START-----}
function Lock_OnDuelFile;
var ok:  boolean;
  memmy: integer;
  error: integer;
  i:     integer;
begin

  {init vars}
  error := 0;
  memmy := filemode;
  i := 0;
  ok := False;

  case action of
    FUnlock: begin
           {$I-}Close(global_onduelfile);{$I-}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_close(onliner.comfile, error)
      else ok := True;
    end;
    FLock: begin
      repeat

        Assign(global_onduelfile, onliner.comfile);

        if global_ushare then
        begin
          FileMode := fmReadWrite + fmDenyAll;
{$IFNDEF MSDOS}
          FileModeReadWrite := FileMode;
{$ENDIF}
        end;

          {$I-}reset(global_onduelfile);{$I+}
        error := IoResult; {get error}

        if error <> 0 then
        begin
          unable_to_access(onliner.comfile, error);
          delay2(global_lockdelay);
          Inc(i);
          if f_exists(onliner.comfile) = False then
          begin
            i := global_locknrs + 1;
          end;

        end else
        begin
          ok := True;
        end;
      until (Ok) or (i > global_locknrs);
    end;
  end; {case .end.}

       {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  lock_onduelfile := ok;

end;

 {---LOCK_ONDUEL-FILE END-----}

 {---LOAD ONDUEL-FILE START----}
procedure Load_OnDuelFile;
var error: integer;
begin

  error := 0;
  Inc(filnr);

 {$I-}seek(global_onduelfile, filnr - 1);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_seek(onliner.comfile, filnr - 1);

  case action of
    Fload: begin
         {$I-}Read(global_onduelfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_read(onliner.comfile, error);
    end;
    Fsave: begin
         {$I-}Write(global_onduelfile, slask);{$I+}
      error := IoResult; {get error}
      if error <> 0 then
        unable_to_write(onliner.comfile, error);
    end;
  end; {case .end.}

end;

{---LOAD ONDUEL-FILE END----}

function File_Stamp_Info2(const fname: string; inclusions: byte): s70;
 {inclusions = 1 (date)
             = 2 (time)
             = 3 (both)}
var
  f:      Text;     {file to be checked}
  ftime:  longint;  { For Get/SetFTime}
  dt:     DateTime; { For Pack/UnpackTime}

  ok:     boolean;

  i, memmy, error: integer;

  s, s2:  s30;
  Result: s70;

begin

  {displays date/time stamp of file FNAME}

  Result := '';
  ok := False;
  memmy := filemode;
  i := 0;
  error := 0;
  repeat
    Assign(f, fname);
    if global_ushare then
    begin
      FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
      FileModeReadWrite := FileMode;
{$ENDIF}
    end;

  {$I-}reset(f);{$I+}
    error := IoResult;
    if error <> 0 then
    begin
      unable_to_access(fname, error);
      delay2(global_lockdelay);
      ok := False;
      Inc(i);
    end else
    begin
      ok := True;
    end;
  until (ok) or (i > global_locknrs);

  if ok then
  begin
    GetFTime(f, ftime); {get creation time}

  {$I-}Close(f);{$I+}
    error := IoResult;
    if error <> 0 then
      unable_to_close(fname, error);

    {unpack date of last modification/creation}
    UnpackTime(ftime, dt);
    with dt do
    begin

      if inclusions in [1, 3] then
      begin
        {display date string}
        s := va(month);
        if length(s) = 1 then
          s := '0' + s;
        s2 := va(day);
        if length(s2) = 1 then
          s2 := '0' + s2;
        s := s + '-' + s2;
        s2 := long2str(year);
        s := s + '-' + s2;

        Result := s;
      end;

      {create time string}
      if inclusions in [2, 3] then
      begin
        if inclusions = 3 then
          Result := Result + ', ';
        Result := Result + LeadingZero(hour) + ':' +
          LeadingZero(min) + ':' +
          LeadingZero(sec);
      end;

    end;
  end;

  {reset filemode}
  filemode := memmy;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}

  {return result}
  file_stamp_info2 := Result;

end; {file_stamp_info *end*}

procedure Display_File;
begin

  if f_exists(s) = True then
  begin
    displayfile1(s); {ddplus routine}
  end else
  begin
    d(12, 'Unable to find the file : ' + uwhite + s + ulred + '.');
  end;

end; {display_file *end*}

procedure Move_File(const filen: string; dest: string);
var f:   file;
  error: integer;
begin

  {init}
  error := 0;

  sd(10, 'Moving ');
  sd(11, filen);
  sd(10, ' to ');
  sd(11, dest + filen + ' ... ');

  if f_exists(filen) then
  begin
    dest := dest + filen;
    Assign(f, filen);
  {$I-}rename(f, dest);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      unable_to_move(filen, dest);
    end else
    begin
      d(14, 'DONE!');
    end;
  end;

end; {move file .end.}

procedure Close_Text(var f: Text);
var error: integer;
begin

  {init}
  error := 0;

 {$I-}Close(f);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_close(textrec(f).Name, error);

end; {close_text *end*}

procedure Readln_from_Text(var f: Text; var s: string);
var error: integer;
begin

  {init}
  error := 0;

 {$I-}readln(f, s);{$I+}
  error := IoResult; {get error}
  if error <> 0 then
    unable_to_read(textrec(f).Name, error);
end; {readln_from_text *end*}

procedure Write_To_Text(var f: Text; const s: string);
begin
  Write(f, s);
     {if IOResult<>0 then unable_to_write(textrec(f).name);}
end; {write_to_text *end*}

procedure Writeln_To_Text(var f: Text; const s: string);
begin
  writeln(f, s);
     {if IOResult<>0 then unable_to_write(textrec(f).name);}
end; {writeln_to_text *end*}


function WriteIPC(var IPC: IPCType): boolean;
var
  error:    integer;
  tries:    byte;
  f:        file;
  om:       byte;
  filename: s90;
  ok:       boolean;

begin

  {init vars}
  ok := False;
  om := filemode;
  tries := 0;
  error := 0;

  {set filename}
  filename := IPCpath + 'IPC' + inttohex(IPC.node, 4) + '.IPC';

  {assign}
  Assign(f, filename);

  {set new filemode}
  if global_ushare then
  begin
    FileMode := fmReadWrite + fmDenyAll;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  end;

  repeat
  {$I-}Rewrite(f, 1);{$I-}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      unable_to_create(filename, error);
      delay2(global_lockdelay);
      Inc(tries);
    end else
    begin
      ok := True;
    end;
  until (ok) or (tries > global_locknrs);

  if ok = False then
  begin
    writeIPC := False;
  end else
  begin
    blockwrite(f, IPC, sizeof(IPC));
  {$I-}Close(f);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(filename, error);
    writeIPC := True;
  end;

  {reset filemode}
  filemode := om;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {WriteIpc *end*}

function DeleteIPC(var IPC: IPCType): boolean;
var
  tries:    integer;
  filename: s90;
  ok:       boolean;
begin

  {set filename}
  filename := IPCpath + 'IPC' + inttohex(IPC.node, 4) + '.IPC';

  tries := 0;
  ok := False;

  if f_exists(filename) then
  begin
    repeat
      if delete_file(filename) = False then
      begin
        Delay2(global_lockdelay);
        Inc(tries);
      end else
      begin
        ok := True;
      end;
    until (ok) or (tries > global_locknrs);
  end;

  {return result}
  deleteIPC := ok;

end; {deleteIpc *end*}

function ReadIPC(var IPC: IPCType; filename: pathstr): boolean;
var
  f:     file;
  error: integer;
  tries: byte;
  ok:    boolean;
  om:    byte;
begin

  {init}
  error := 0;
  om := filemode;
  ok := False;
  tries := 0;

  {assign}
  Assign(f, IPCpath + filename);

  {set filemode}
  if global_ushare then
  begin
    FileMode := fmReadOnly + fmDenyWrite;
{$IFNDEF MSDOS}
    FileModeReadWrite := FileMode;
{$ENDIF}
  end;

  repeat
  {$I-}reset(f, 1);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
    begin
      unable_to_access(ipcpath + filename, error);
      delay2(global_lockdelay);
      Inc(tries);
    end else
    begin
      ok := True;
    end;
  until (ok) or (tries > global_locknrs);

  if ok = False then
  begin
    readIPC := False;
  end else
  begin
    blockread(f, IPC, sizeof(IPC));
  {$I-}Close(f);{$I+}
    error := IoResult; {get error}
    if error <> 0 then
      unable_to_close(filename, error);
    readIPC := True;
  end;

  {reset filemode}
  filemode := om;
{$IFNDEF MSDOS}
  FileModeReadWrite := FileMode;
{$ENDIF}
end; {readIpc *end*}

procedure Init_Ipc(const ply: UserRec); {preparing a IPC record for use}
var i: byte;
begin

  {Init}
  with MyIpc do
  begin
    node := onliner.recnr;
    username := ply.name2;
    available := True;
    in_chat := False;
    conference := 0;
    confname := '';
    confpassw := '';
    messcolor := 2;

    for i := 1 to ipc_maxmsg do
    begin
      message_waiting[i] := False;
      message_to_user[i] := '';
      message_from[i] := '';
      message_color[i] := 2;
    end; {for i:= .end.}

  end;
  {Init .end.}

  {set color to be used when chatting with other players}
  MyIpc.MessColor := MyIpc.Node;
  if MyIpc.Node > 15 then
  begin
    MyIpc.MessColor := random(15) + 1;
  end;

  {file to harddisk or ramdrive (semaphore dir) }
  WriteIPC(MyIPC);

end; {init_ipc *end*}

function ChatArea_InUse(area: word): boolean;
var
  occupied: boolean;
  Sr:       Searchrec;
  tIPC:     IPCType;

begin

  {is chat area #AREA occupied?}

  {init vars}
  occupied := False;

  FindFirst(IPCpath + 'IPC????.IPC', Anyfile - Directory, sr);
  with tIPC do
  begin
    while (doserror = 0) and (occupied = False) do
    begin
      if not ReadIPC(tIPC, sr.Name) then
      begin
        d(12, 'Error reading IPC!');
      end else
      begin
        if Conference = AREA then
        begin

          {area is occupied!}
          occupied := True;

        end;
      end;

      {find next node file to check out}
      Findnext(sr);

    end;
  end;
{$IFNDEF MSDOS}
  FindClose(Sr);
{$ENDIF}

  {return result}
  ChatArea_InUse := occupied;

end; {ChatArea_InUse *end*}

procedure ChatSend(msg: string; Conf: word);
{ Use Conf = 0 to send to all conferences }
var
  Sr:   Searchrec;
  tIPC: IPCType;
  freemessage, i: byte;
begin

  FindFirst(IPCpath + 'IPC????.IPC', Anyfile - Directory, sr);
  with tIPC do
  begin
    while doserror = 0 do
    begin
      if not ReadIPC(tIPC, sr.Name) then
      begin
        d(12, 'Error reading IPC!');
      end else
      begin
        if ((conference = conf) or (conf = 0)) and (in_chat) and
          (Available) and (tIPC.node <> MyIPC.node) then
        begin

          {lets find an empty message spot}
          freemessage := 0;
          for i := 1 to ipc_maxmsg do
          begin
            if message_waiting[i] = False then
            begin
              freemessage := i;
              break;
            end;
          end; {for i:= .end.}

               {no empty place found!}
          if freemessage = 0 then
          begin
            freemessage := ipc_maxmsg; {put it at the back, unfortunately overwriting waiting mail!}
          end;

          {what color should be used when displaying the message}
          {we use the node # to decide to what color to use. the goal}
     {is to get unique color for every node, thus increasing readability
      when chatting}

          {send message}
          if freemessage > 0 then
          begin
            Message_waiting[freemessage] := True;
            Message_to_user[freemessage] := msg;
            Message_from[freemessage] := player.name2;
            Message_color[freemessage] := MyIpc.MessColor;
          end;

          { For debugging only: }
          {jswriteln('Sending to node #'+strfunc(tIPC.node));}

          if not writeIPC(tIPC) then
          begin
            d(12, 'Error writing to node ' + IntToStr(tIPC.node));
          end;

        end;
      end;

      {find next node file to send our message to}
      Findnext(sr);

    end;
  end;
{$IFNDEF MSDOS}
  FindClose(Sr);
{$ENDIF}

end; {chatsend *end*}

procedure Multi_Chat;  {Chat with user(s) in a conference}
const

  {Conferences}
  maxconf = 1;

  {Multi Chat Conferences}
  confs: array[1..maxconf] of s30 = ('The Round Table');

  {Forever}
  Chat_is_Finished = False;

 {max chat areas to keep in memory, although the actual confs can be max
  65550}
  maxlist          = 100;

var
  s:        string;
  one:      string[1];
  i:        word;
  ch:       char;
  x:        longint;
  conf:     word;          {conference}
  confnam:  s30;           {conderence name}
  confpassword: string[8]; {conference password}
  current:  word;
  tries:    word;
  go_ahead: boolean;
  ok:       boolean;

  memlist:  array[1..maxlist] of word;      {conf #}
  memlist2: array[1..maxlist] of s30;       {conf name}
  memlist3: array[1..maxlist] of string[8]; {conf password}

  procedure display_userconfs; {display active (user created) chat areas}
  var
    Sr:      Searchrec;
    tIPC:    IPCType;
    i:       byte;

    found:   boolean;

    counter: byte; {pause counter}

  begin

    {init memory list, keeping already displayed user conferances}
    for i := 1 to maxlist do
    begin
      memlist[i] := 0;
      memlist2[i] := '';
      memlist3[i] := '';
    end; {for i:= .end.}

         {init misc vars}
    counter := 0;

    FindFirst(IPCpath + 'IPC????.IPC', Anyfile - Directory, sr);
    with tIPC do
    begin
      while doserror = 0 do
      begin
        if not ReadIPC(tIPC, sr.Name) then
        begin
          d(12, 'Error reading IPC!');
        end else
        begin
          if (in_chat) and (Available) and (conference <> 65000) then
          begin

            {have we displayed this conference already?}
            found := False;
            for i := 1 to maxlist do
            begin
              if conference = memlist[i] then
              begin
                found := True;
                break;
              end;
            end; {for i:= .end.}

            if found = False then
            begin

              {display conf and add to memlist}
              Inc(current);

              {conf #}
              sd(14, ' ' + commastr(current));

              {conf name}
              sd(3, ' . ' + confname);

              {conf password}
              if confpassw <> '' then
              begin
                d(12, '  *password required*');
              end else
              begin
                crlf;
              end;


              {add this conf to the "already displayed list"}
              for i := 1 to maxlist do
              begin
                if memlist[i] = 0 then
                begin
                  memlist[i] := conference;
                  memlist2[i] := confname;
                  memlist3[i] := confpassw;
                  break;
                end;
              end; {for i:= .end.}

                   {should we pause the listing}
              Inc(counter);
              if counter > 15 then
              begin
                counter := 0;
                if confirm('Continue', 'Y') = False then
                begin
                  break;
                end;
              end;

            end;

          end;
        end;

        {find next node file to send our message to}
        Findnext(sr);

      end;
    end;
{$IFNDEF MSDOS}
    FindClose(Sr);
{$ENDIF}

  end; {display_userconfs *end*}

begin  {multi-chat}

       {Init}
  go_ahead := True; {set this to false, and the no conference will be entered}
  conf := 1; {default conference}
  confnam := confs[1]; {default conferance name}
  confpassword := ''; {conference password}

       {Display Hard-coded Conferences}
  crlf;
  crlf;
  d(10, 'Chat Rooms:');
  crlf;

  for i := 1 to maxconf do
  begin
    {Conf #}
    sd(14, ' ' + commastr(i));
    d(3, ' . ' + confs[i]);
  end; {for i:= .end.}

       {user created conferences}
  current := maxconf;

  display_userconfs;

  {last option is to Create a new conferance}
  sd(14, ' C');
  d(3, ' . ' + '<create your own chat room>');


  {Select Conference}
  crlf;
  sd(15, 'Select :');

  s := get_string(4);
  x := str_to_nr(s);

  if s = '' then
  begin
    go_ahead := False;
  end else
  if upcasestr(s) = 'C' then
  begin

    {Create New CHAT-ROOM}

    d(10, 'name your area:');
    sd(config.textcolor, ':');
    s := get_string(30);

    if s = '' then
    begin
      x := 0;
    end else
    begin
      confnam := s;

      x := 1;
      crlf;
      {password required}
      if confirm('set password', 'N') = True then
      begin
        d(10, 'enter password (max 8 chars)');
        sd(config.textcolor, ':');
        confpassword := get_stringsec(8, '*');

        if confpassword <> '' then
        begin
          d(config.textcolor, 'reenter for verification');
          sd(config.textcolor, ':');
          s := get_stringsec(8, '*');
          if s <> confpassword then
          begin
            d(12, 'wrong password, verification failed.');
            d(12, 'conference will not be using a password.');
            confpassword := '';
          end else
          begin
            d(14, 'CHAT-ROOM CREATED!');
            crlf;
          end;

        end;

      end;

      {now we must set a unique Conference Number}
      x := Onliner.RecNr + 1; {this is a unique number, nobody else has the same}

   {buth some nodes might have this number, if this player created a chat
    area and exited, and some others still are using the old area.
    we must check this now.}

      tries := 0;
      repeat
        Inc(tries);

        if ChatArea_InUse(x) then
        begin
          {Area already exists!}
          Inc(x);
        end;

      until (ChatArea_InUse(x) = False) or (tries > 255);

      if tries > 255 then
      begin
        d(12, 'Couldn''t find an empty Chat-area!');
        go_ahead := False;
      end;

    end;

    conf := x;

  end else
  begin

    {Select Conference, it might be a User chat area!}
    if (x < 0) or (x > current) then
    begin
      x := 0;
    end else
    if x > 1 then
    begin

      {password protected?}
      ok := True;
      if memlist3[x - 1] <> '' then
      begin
        d(config.textcolor, 'Enter password');
        sd(config.textcolor, ':');
        s := get_stringSec(8, '*');

        if s = memlist3[x - 1] then
        begin
          d(15, 'Correct!');
          crlf;
        end else
        begin
          d(12, 'Wrong Password!');
          ok := False;
          go_ahead := False;

          {Tell other IPCs that player tried to get in}
          ChatSend(ulred + ' {tried to enter the chat but failed!}' + config.textcol1, memlist[x - 1]);

        end;

      end;

      if ok then
      begin
        conf := memlist[x - 1];
        confnam := memlist2[x - 1];
        confpassword := memlist3[x - 1];
      end;

    end else
    begin
      conf := 1;
    end;

  end;

  case conf of
    0: exit; {user aborted}
    1: conf := 65000; {default hardcoded conference}
    else begin
      {?}
    end;

  end;

  if go_ahead then
  begin

  {
  debugging info
  d(15,'Unique Conference # is :'+commastr(conf));
  d(12,'Conference name is     :'+confnam);
  d(15,'Password is            :'+confpassword);
  }

    {Modify IPC record}
    with MyIpc do
    begin
      in_chat := True;
      conference := conf;
      confname := confnam;
      confpassw := confpassword;
    end;

    {Save Ipc}
    WriteIPC(MyIpc);

    {Update player location & doing}
    onliner.location := onloc_MultiChat;
    onliner.doing := location_desc(onliner.location);
    add_onliner(OUpdateLocation, onliner);

  {We turn OFF the multinode checking, not necessary but I think a chat
   shouldn't be disturbed. change it if you like.}
    Global_Multi := False;

    {Start typing!}
    d(11, 'Start typing [Esc=quit]');
    sd(10, ''); {set the text color}

    {Tell other IPCs that player entered Chat}
    ChatSend(uyellow + ' {entered the chat}' + config.textcol1, conf);

    {flag used by the ipc routine IPCHook}
    scanning := True;

    {Start Chatting}
    repeat

      s := '';
      one := '';

      {check if user has pressed ESC}
      ch := upcase(getchar);
      if ch = EscapeKey then
      begin
        crlf;
        d(11, '[Exit]');
        break;
      end else
      if ch = ReturnKey then
      begin
        crlf;
      end else
      begin
        one := ch;

        {prompt color}
        sd(10, '');

        {Get User Input}
        stacked := one;
        s := get_string(255);

        {emptyline}
        global_emptyline := True;

        {Send it to the IPC}
        if s <> '' then
        begin
          chatsend(s, conf);
        end;

      end;

    until Chat_Is_Finished;

    {Tell other IPCs that player has left}
    ChatSend(uyellow + ' {left the chat}' + config.textcol1, conf);

    {Delete Players IPC file}
    DeleteIpc(MyIpc);

    {we turn ON multinode checking again}
    Global_Multi := True;
  end;

end; {Multi_Chat *END*}

procedure IPCHook; {scanning own ipc node for incoming messages}
var
  i: byte;
begin

  global_emptyline := True;
  if (scanning) and (global_emptyline) then
  begin
    scanning := False;
    {CLine := Currline;}
    if readIPC(myIPC, 'IPC' + inttohex(myIPC.node, 4) + '.IPC') then
      with myipc do
      begin

        {Different Sorts of Pagings}
        {we must check the message buffer}
        for i := 1 to ipc_maxmsg do
        begin

          if message_waiting[i] then
          begin

            {display message}
            sd(message_color[i], '[' + message_from[i] + ']:');
            d(message_color[i], message_to_user[i]);

            {reset message flags}
            Message_waiting[i] := False;
            Message_to_user[i] := '';

            {Write Updated IPC}
            writeIPC(MyIPC);
          end;

        end;

      end; {for i=1 to maxmsg .end.}

  end;

  {let this procedure be able to be entered again}
  scanning := True;

end; {IPC-HOOK *end*}

begin

     {unit init code..}

end. {Unit File_Io .end.}
