{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
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
unit Version;

interface

const
  uver            = '0.25';            {Don't forget to update CheckVersion when you update this}
  ucomp           = '2022/10/30';      {compile date, yyyy/mm/dd}
  editor_version  = 'Usurper Editor ' + uver;
  usurper_version = 'Usurper ' + uver; {prog & version}
  ubeta: boolean  = False; {is this a BETA version?}

var
  OldVersion: string;
  UpgradeFailedReason: string;

function CheckVersion: boolean;
  
implementation

uses
  File_Io, Init;

const
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

function CloseAndRenameFiles(var InFile: file; InFileName: string; var OutFile: file; 
                             BackupExtension: string): boolean; forward;
function GetDataFileSize(InFileName: string): longint; forward;
function GetOldVersion: string; forward;
function GetVersionDatVersion: string; forward;
function GuessVersionByData: string; forward;
function OpenFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean; forward;
function UpdateVersionDat(version: string): boolean; forward;
function UpgradeTo023c: boolean; forward;
function UpgradeTo023d: boolean; forward;

function CheckVersion: boolean;
var
  Result: boolean;
begin
  { Assume success }
  Result := True;

  { Check which version we're upgrading from to see what needs to be done }
  OldVersion := GetOldVersion;
  
  if (OldVersion <> uver) then
  begin
    { Upgrade needed, check if it's supported, and if so, what needs doing }
    if (OldVersion = VERSION_020e_OR_022_OR_023_OR_023a_OR_023b) or (OldVersion = VERSION_021DOS_OR_021aDOS) then
    begin
      Result := UpgradeTo023c;
    end else
    if (OldVersion = VERSION_023c_OR_023d_OR_023e_OR_023f) or (OldVersion = '0.23c') then
    begin
      Result := UpgradeTo023d;
    end else
    if (OldVersion >= '0.23d') and (OldVersion <= '0.24') then
    begin
      { Currently no upgrade needed for these versions }
      Result := UpdateVersionDat(uver);
    end else
    begin
      { Apparently it's an unsupported version }
      UpgradeFailedReason := 'Unknown/unsupported version';
      Result := False;
    end;

    { We might have multiple updates needed, so recursively call this function }
    if (Result) then
    begin
      Result := CheckVersion;
    end;
  end;

  CheckVersion := Result;
end;

function CloseAndRenameFiles(var InFile: file; InFileName: string; var OutFile: file; BackupExtension: string): boolean;
var
  Result: boolean;
begin
  Result := False;

  Close(InFile);
  Close(OutFile);

  {$I-}Rename(InFile, Copy(InFileName, 1, Pos('.', InFileName)) + BackupExtension);{$I+}
  if (IOResult = 0) then
  begin
    {$I-}Rename(OutFile, InFileName);{$I+}
    if (IOResult = 0) then
    begin
      Result := True;
    end else
    begin
      UpgradeFailedReason := 'Unable to swap data files (rename2)';
    end;
  end else
  begin
    UpgradeFailedReason := 'Unable to swap data files (rename1)';
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
  if not (F_Exists(TryFileName)) then
  begin
    { Not in DATA directory, so setup for base directory lookup }
    TryFileName := InFileName;
  end;

  { Look for the filename created above }
  if (F_Exists(TryFileName)) then
  begin
    Assign(InFile, TryFileName);
    {$I-}Reset(InFile);{$I+}
    if (IOResult = 0) then
    begin
      {$I-}Result := FileSize(InFile);{$I+}
      Close(InFile);
    end;
  end;

  GetDataFileSize := Result;
end;

function GetOldVersion: string;
var
  Result: string;
begin
  Result := GetVersionDatVersion;
  if (Result = VERSION_UNKNOWN) then
  begin
    Result := GuessVersionByData;
  end;

  GetOldVersion := Result;
end;

function GetVersionDatVersion: string;
var
  InFile: Text;
  Result: string;
begin
  Result := VERSION_UNKNOWN;

  if (F_Exists(Global_VersionF)) then
  begin
    if (Open_TxtFile(TReset, InFile, Global_VersionF)) then
    begin
      ReadLn_From_Text(InFile, Result);
      Close_Text(InFile);
    end else
    begin
      Result := VERSION_ERROR;
      UpgradeFailedReason := 'Unable to read VERSION.DAT';
    end;
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
    if (NpcsDatSize = 37800) then
    begin
      Result := VERSION_001_OR_001e;
    end else
    if (NpcsDatSize = 49770) then
    begin
      Result := VERSION_001f;
    end else
    if (NpcsDatSize = 173880) then
    begin
      Result := VERSION_002_OR_004c_OR_005b;
    end else
    if (NpcsDatSize = 89320) then
    begin
      Result := VERSION_008;
    end else
    if (NpcsDatSize = 90370) then
    begin
      Result := VERSION_013c;
    end else
    if (NpcsDatSize = 91420) then
    begin
      Result := VERSION_014_OR_016;
    end else
    if (NpcsDatSize = 91910) then
    begin
      Result := VERSION_017;
    end else
    if (NpcsDatSize = 100270) then
    begin
      Result := VERSION_018_OR_019b6;
    end else
    if (NpcsDatSize = 100418) then
    begin
      Result := VERSION_020d;
    end else
    if (NpcsDatSize = 100566) then
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
      end else
      if (MonsterDatSize = 239239) then
      begin
        Result := VERSION_023c_OR_023d_OR_023e_OR_023f;
      end;
    end else
    if (NpcsDatSize = 113590) then
    begin
      Result := VERSION_021W32_OR_021aW32;
    end;
  end else
  if (NpcsDatSize = -1) and (MonsterDatSize = -1) then
  begin
    { Neither data file exists -- probably a fresh install, so assume current version }
    Result := uver;
  end;

  GuessVersionByData := Result;
end;

function OpenFiles(var InFile: file; InFileName: string; var OutFile: file; OutFileName: string): boolean;
var
  Result: boolean;
begin
  Result := False;

  Assign(InFile, InFileName);
  {$I-}Reset(InFile, 1);{$I+}
  if (IOResult = 0) then
  begin
    Assign(OutFile, OutFileName);
    {$I-}ReWrite(OutFile, 1);{$I+}
    if (IOResult = 0) then
    begin
      Result := True;
    end else
    begin
      Close(InFile);
      UpgradeFailedReason := 'Unable to open data files (rewrite)';
    end;
  end else
  begin
    UpgradeFailedReason := 'Unable to open data files (reset)';
  end;

  OpenFiles := Result;
end;

function UpdateVersionDat(version: string): boolean;
var
  OutFile: Text;
  Result:  boolean;
begin
  { Assume failure }
  Result := False;

  Assign(OutFile, Global_VersionF);
  {$I-}ReWrite(OutFile);{$I+}
  if (IOResult = 0) then
  begin
    WriteLn(OutFile, version);
    Close(OutFile);
    Result := True;
  end else
  begin
    UpgradeFailedReason := 'Unable to update VERSION.DAT to ' + version;
  end;

  UpdateVersionDat := Result;
end;

function UpgradeTo023c: boolean;
var
  Buf:    array[1..121] of byte;
  InFile, OutFile: file;
  OldMonsterDat, TempMonsterDat: string;
  Result: boolean;
  StrengthLongInt: longint;
  StrengthSmallInt: smallint;
begin
  Result := False;

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

    Result := CloseAndRenameFiles(InFile, OldMonsterDat, OutFile, '23c');

    { Update VERSION.DAT }
    if (Result) then
    begin
      UpdateVersionDat('0.23c');
    end;
  end;

  UpgradeTo023c := Result;
end;

function UpgradeTo023d: boolean;
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

    Result := CloseAndRenameFiles(InFile, OldMonsterDat, OutFile, '23d');

    { Update VERSION.DAT }
    if (Result) then
    begin
      UpdateVersionDat('0.23d');
    end;
  end;

  UpgradeTo023d := Result;
end;

end.
