{$I DEFINES.INC}
{

Copyright 2013 Usurper Dev Team

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

unit Upgrade;

interface

procedure UpgradeIfNecessary;

implementation

uses
  Crt, File_IO, Init;

const
  { Constants to use in version detection }
  VERSION_ERROR        = 'ERROR';
  VERSION_UNKNOWN      = 'UNKNOWN';
  VERSION_001_OR_001e  = '0.01 or 0.01e';
  VERSION_001f         = '0.01f';
  VERSION_002_OR_004c_OR_005b = '0.02 or 0.04c or 0.05b';
  VERSION_008          = '0.08';
  VERSION_013c         = '0.13c';
  VERSION_017          = '0.17';
  VERSION_014_OR_016   = '0.14 or 0.16';
  VERSION_018_OR_019b6 = '0.18 or 0.19b6';
  VERSION_020d         = '0.20d';
  VERSION_020e_OR_022_OR_023_OR_023a_OR_023b = '0.20e or 0.22 or 0.23 or 0.23a or 0.23b';
  VERSION_021DOS_OR_021aDOS = '0.21 (DOS) or 0.21a (DOS)';
  VERSION_021W32_OR_021aW32 = '0.21 (W32) or 0.21a (W32)';
  VERSION_023c_OR_023d_OR_023e_OR_023f = '0.23c or 0.23d or 0.23e or 0.23f';

function CloseAndRenameFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean; forward;
function GetDataFileSize(InFileName: string): longint; forward;
function GetOldVersion: string; forward;
function GetVersionDatVersion: string; forward;
function GuessVersionByData: string; forward;
function OpenFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean; forward;
function PerformUpgrade(OldVersion: string): boolean; forward;
function PerformUpgradeTo023c: boolean; forward;
function PerformUpgradeTo023d: boolean; forward;
function UpdateVersionDat: boolean; forward;

function CloseAndRenameFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean;
var
  Result: boolean;
begin
  Result := False;

  WriteLn('DONE');

  Close(InFile);
  Close(OutFile);

  Write('     - Erasing ' + InFileName + '...');

  {$I-}Erase(InFile);{$I+}
  if (IOResult = 0) then
  begin
    WriteLn('SUCCESS');
    Write('     - Renaming ' + OutFileName + ' to ' + InFileName + '...');

    {$I-}Rename(OutFile, InFileName);{$I+}
    if (IOResult = 0) then
    begin
      WriteLn('SUCCESS');
      Result := True;
    end else
    begin
      WriteLn('FAILED');
    end;
  end else
  begin
    WriteLn('FAILED');
  end;

  CloseAndRenameFiles := Result;
end;

function GetDataFileSize(InFileName: string): longint;
var
  InFile:      file of byte;
  Result:      longint;
  TryFileName: string;
begin
  Result := -1;

  { First try in DATA directory }
  TryFileName := 'DATA' + DIRECTORY_SEPARATOR + InFileName;
  Write('   - Looking for ' + TryFileName + '...');
  if not (F_Exists(TryFileName)) then
  begin
    { Not in DATA directory, so setup for base directory lookup }
    WriteLn('NOT FOUND');
    TryFileName := InFileName;
    Write('   - Looking for ' + TryFileName + '...');
  end;

  { Look for the filename created above }
  if (F_Exists(TryFileName)) then
  begin
    WriteLn('FOUND');
    Write('   - Determining size of file...');

    Assign(InFile, TryFileName);
    {$I-}Reset(InFile);{$I+}
    if (IOResult = 0) then
    begin
      {$I-}Result := FileSize(InFile);{$I+}
      if (IOResult = 0) then
      begin
        WriteLn(Result, ' bytes');
      end else
      begin
        WriteLn('ERROR');
      end;

      Close(InFile);
    end else
    begin
      WriteLn('ERROR');
    end;
  end;

  GetDataFileSize := Result;
end;

function GetOldVersion: string;
var
  Result: string;
begin
  WriteLn(' - Trying to determine your installed version...');

  Result := GetVersionDatVersion;
  if (Result = VERSION_UNKNOWN) then Result := GuessVersionByData;
  WriteLn;

  GetOldVersion := Result;
end;

function GetVersionDatVersion: string;
var
  Ch:     char;
  InFile: Text;
  Result: string;
begin
  Result := VERSION_UNKNOWN;

  Write('   - Looking for ' + VersionF + '...');
  if (F_Exists(VersionF)) then
  begin
    WriteLn('FOUND');

    repeat
      Write('   - Trying to open file...');
      if (Open_TxtFile(TReset, InFile, VersionF)) then
      begin
        WriteLn('SUCCESS');
        ReadLn_From_Text(InFile, Result);
        Close_Text(InFile);
        Ch := 'N'; { Causes repeat loop to terminate, since we got the verrsion we need }
        WriteLn('   - Version from file: ' + Result);
      end else
      begin
        WriteLn('FAILED');
        Result := VERSION_ERROR;

        WriteLn;
        WriteLn(VersionF + ' exists, but I was unable to open it for input.  Try again?');
        WriteLn;
        WriteLn('  (Y)es, try reading the file again');
        WriteLn('  (N)o, don''t bother I''m going to reset the game anyway');
        WriteLn;
        Write('  Your choice [y/n]: ');
        repeat
          Ch := UpCase(ReadKey);
        until (Ch in ['Y', 'N']);
        WriteLn;
        WriteLn;
      end;
    until (Ch = 'N');
  end else
  begin
    WriteLn('NOT FOUND');
  end;

  GetVersionDatVersion := Result;
end;

function GuessVersionByData: string;
var
  NpcsDatSize, MonsterDatSize: longint;
  Result: string;
begin
  Result := VERSION_UNKNOWN;

  { Try to get filesize for NPCS.DAT and MONSTER.DAT to use in version guessing }
  NpcsDatSize := GetDataFileSize('NPCS.DAT');
  MonsterDatSize := GetDataFileSize('MONSTER.DAT');
  if (NpcsDatSize > 0) and (MonsterDatSize > 0) then
  begin
    { BP can't use a LongInt in a case statement?  Makes for ugly repetetive IFs... }
    if (NpcsDatSize = 37800) then
    begin
      Result := VERSION_001_OR_001e;
    end else if (NpcsDatSize = 49770) then
    begin
      Result := VERSION_001f;
    end else if (NpcsDatSize = 173880) then
    begin
      Result := VERSION_002_OR_004c_OR_005b;
    end else if (NpcsDatSize = 89320) then
    begin
      Result := VERSION_008;
    end else if (NpcsDatSize = 90370) then
    begin
      Result := VERSION_013c;
    end else if (NpcsDatSize = 91420) then
    begin
      Result := VERSION_014_OR_016;
    end else if (NpcsDatSize = 91910) then
    begin
      Result := VERSION_017;
    end else if (NpcsDatSize = 100270) then
    begin
      Result := VERSION_018_OR_019b6;
    end else if (NpcsDatSize = 100418) then
    begin
      Result := VERSION_020d;
    end else if (NpcsDatSize = 100566) then
    begin
      if (MonsterDatSize = 237237) then
      begin
        if (F_Exists('DATA' + DIRECTORY_SEPARATOR + 'DOSORWIN.DAT')) then
        begin
          Result := VERSION_021DOS_OR_021aDOS;
        end else
        begin
          Result := VERSION_020e_OR_022_OR_023_OR_023a_OR_023b;
        end;
      end else if (MonsterDatSize = 239239) then
      begin
        Result := VERSION_023c_OR_023d_OR_023e_OR_023f;
      end;
    end else if (NpcsDatSize = 113590) then
    begin
      Result := VERSION_021W32_OR_021aW32;
    end else
    begin
      Result := VERSION_UNKNOWN;
    end;

    WriteLn('   - Size indicates version: ' + Result);
  end;

  GuessVersionByData := Result;
end;

function OpenFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean;
var
  Result: boolean;
begin
  Result := False;

  Write('     - Opening ' + InFileName + ' for input...');

  Assign(InFile, InFileName);
  {$I-}Reset(InFile, 1);{$I+}
  if (IOResult = 0) then
  begin
    WriteLn('SUCCESS');
    Write('     - Opening ' + OutFileName + ' for output...');

    Assign(OutFile, OutFileName);
    {$I-}ReWrite(OutFile, 1);{$I+}
    if (IOResult = 0) then
    begin
      WriteLn('SUCCESS');
      Write('     - Converting ' + InFileName + ' to ' + OutFileName + '...');
      Result := True;
    end else
    begin
      Close(InFile);
      WriteLn('FAILED');
    end;
  end else
  begin
    WriteLn('FAILED');
  end;

  OpenFiles := Result;
end;

function PerformUpgrade(OldVersion: string): boolean;
var
  Result: boolean;
begin
  { Assume failure }
  Result := False;

  WriteLn(' - Performing automatic upgrade');

  { Check which version we're upgrading from to see what needs to be done }
  if (OldVersion = VERSION_020e_OR_022_OR_023_OR_023a_OR_023b) or (OldVersion = VERSION_021DOS_OR_021aDOS) then
  begin
    Result := PerformUpgradeTo023c;
    if (Result) then Result := PerformUpgradeTo023d;
  end else if (OldVersion = VERSION_023c_OR_023d_OR_023e_OR_023f) then
  begin
    Result := PerformUpgradeTo023d;
  end else
  begin
    WriteLn('   - On second thought, maybe not!  Your version of Usurper is not supported');
    WriteLn('     by the auto upgrader');
  end;

  { If we succeeded above, update the VERSION.DAT file }
  if (Result) then Result := UpdateVersionDat;

  PerformUpgrade := Result;
end;

function PerformUpgradeTo023c: boolean;
var
  Buf:    array[1..121] of byte;
  InFile, OutFile: file;
  OldMonsterDat, TempMonsterDat: string;
  Result: boolean;
  StrengthLongInt: longint;
  StrengthSmallInt: smallint;
begin
  Result := False;

  WriteLn('   - Upgrading to 0.23c');

  OldMonsterDat := 'DATA' + DIRECTORY_SEPARATOR + 'MONSTER.DAT';
  TempMonsterDat := 'DATA' + DIRECTORY_SEPARATOR + 'MONSTER.$$$';

  if (OpenFiles(InFile, OldMonsterDat, OutFile, TempMonsterDat)) then
  begin
    while not (EOF(InFile)) do
    begin
      { Read/write everything from beginning of record to Strength }
      BlockRead(InFile, Buf, 114);
      BlockWrite(OutFile, Buf, 114);

      { Read/write Strength, converting from SmallInt to LongInt }
      BlockRead(InFile, StrengthSmallInt, 2);
      StrengthLongInt := StrengthSmallInt;
      BlockWrite(OutFile, StrengthLongInt, 4);

      { Read/write everything past Strength to the end of the record }
      BlockRead(InFile, Buf, 121);
      BlockWrite(OutFile, Buf, 121);
    end;

    Result := CloseAndRenameFiles(InFile, OldMonsterDat, OutFile, TempMonsterDat);
  end;

  PerformUpgradeTo023c := Result;
end;

function PerformUpgradeTo023d: boolean;
var
  Buf:      array[1..114] of byte;
  Defense:  smallint;
  Hps:      longint;
  InFile, OutFile: file;
  OldMonsterDat, TempMonsterDat: string;
  Result:   boolean;
  Strength: longint;
begin
  Result := False;
  Defense := 0;

  { TODO Is it worth it to prompt users before applying this update?
         Probably only a small number of people customized their monsters, and even if they did,
         it's likely they'll want the Hps and Defense to match the way the game used to play anyway }
  WriteLn('   - Upgrading to 0.23d');

  OldMonsterDat := 'DATA' + DIRECTORY_SEPARATOR + 'MONSTER.DAT';
  TempMonsterDat := 'DATA' + DIRECTORY_SEPARATOR + 'MONSTER.$$$';

  if (OpenFiles(InFile, OldMonsterDat, OutFile, TempMonsterDat)) then
  begin
    while not (EOF(InFile)) do
    begin
      { Read/write everything from beginning of record to Strength }
      BlockRead(InFile, Buf, 114);
      BlockWrite(OutFile, Buf, 114);

      { Read/write Strength for use later }
      BlockRead(InFile, Strength, 4);
      BlockWrite(OutFile, Strength, 4);

      { Zero out defense }
      BlockRead(InFile, Buf, 2);
      BlockWrite(OutFile, Defense, 2);

      { Read/write everything between defense and hps }
      BlockRead(InFile, Buf, 2);
      BlockWrite(OutFile, Buf, 2);

      { Write Hps as Strength * 3 }
      Hps := Strength * 3;
      BlockRead(InFile, Buf, 4);
      BlockWrite(OutFile, Hps, 4);

      { Read/write everything past Hps to the end of the record }
      BlockRead(InFile, Buf, 113);
      BlockWrite(OutFile, Buf, 113);
    end;

    Result := CloseAndRenameFiles(InFile, OldMonsterDat, OutFile, TempMonsterDat);
  end;

  PerformUpgradeTo023d := Result;
end;

function UpdateVersionDat: boolean;
var
  OutFile: Text;
  Result:  boolean;
begin
  Result := False;

  WriteLn('   - Updating ' + VersionF + ' with current version');
  Write('     - Opening ' + VersionF + ' for output...');

  Assign(OutFile, VersionF);
  {$I-}ReWrite(OutFile);{$I+}
  if (IOResult = 0) then
  begin
    WriteLn('SUCCESS');
    Write('     - Writing new version to file...');

    WriteLn(OutFile, uver);
    Close(OutFile);

    WriteLn('SUCCESS');
    Result := True;
  end else
  begin
    WriteLn('FAILED');
  end;

  UpdateVersionDat := Result;
end;

procedure UpgradeIfNecessary;
var
  Ch: char;
  NewVersion, OldVersion: string;
begin
  ClrScr;
  WriteLn;
  WriteLn('USURPER AUTO UPGRADER');
  WriteLn;

  { Get EDITOR.EXE and VERSION.DAT (or best guess) versions }
  NewVersion := uver;
  OldVersion := GetOldVersion;

  { Check if we were able to retrieve the VERSION.DAT version }
  if (OldVersion = VERSION_ERROR) then
  begin
    { Ignore, error message would have been presented to user earlier }
  end else if (OldVersion = VERSION_UNKNOWN) then
  begin
    WriteLn('Unable to determine which version of Usurper you have installed!');
    WriteLn(' - If you will be resetting the game, then you can safely ignore this message');
    WriteLn(' - If you want to upgrade your game, please see UPGRADE.TXT for instructions');
    WriteLn;
    WriteLn('Hit any key to continue');
    ReadKey;
  end else if (NewVersion <> OldVersion) then
  begin
    WriteLn('It looks like your copy of Usurper needs to be upgraded!');
    WriteLn;
    WriteLn('       Existing version: ' + OldVersion);
    WriteLn('  Version to upgrade to: ' + NewVersion);
    WriteLn;
    WriteLn('Would you like to attempt an automatic upgrade now?');
    WriteLn('(I *STRONGLY* recommend you take a backup first!)');
    WriteLn;
    WriteLn('  (Y)es, upgrade now');
    WriteLn('  (N)o, I''ll upgrade later or plan on resetting the game');
    WriteLn('  (A)bort, I want to go take a backup or something');
    WriteLn;
    Write('  Your choice [y/n/a]: ');
    repeat
      Ch := UpCase(ReadKey);
    until (Ch in ['Y', 'N', 'A']);
    WriteLn;
    WriteLn;

    if (Ch = 'Y') then
    begin
      ClrScr;
      WriteLn;
      WriteLn('USURPER AUTO UPGRADER');
      WriteLn;

      if (PerformUpgrade(OldVersion)) then
      begin
        WriteLn;
        WriteLn('Upgrade complete.  Hit any key to continue');
        ReadKey;
      end else
      begin
        WriteLn;
        WriteLn('I wasn''t able to upgrade your game.  Please either reset the game, or be');
        WriteLn('careful with this program as some of the editors may expect data files with');
        WriteLn('a different structure, so you could cause damage using them before upgrading.');
        WriteLn;
        WriteLn('If you want to retry the upgrade, just quit and run this program again.');
        WriteLn;
        WriteLn('Hit any key to continue');
        ReadKey;
      end;
    end else if (Ch = 'N') then
    begin
      WriteLn('OK, I won''t upgrade your game now.  Please either reset the game, or be');
      WriteLn('careful with this program as some of the editors may expect data files with');
      WriteLn('a different structure, so you could cause damage using them before upgrading.');
      WriteLn;
      WriteLn('If you want to perform the upgrade, just quit and run this program again.');
      WriteLn;
      WriteLn('Hit any key to continue');
      ReadKey;
    end else if (Ch = 'A') then
    begin
      Halt;
    end;
  end;
end;

end.
