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

Unit Upgrade;

interface

procedure UpgradeIfNecessary;

implementation

uses
  Crt, File_IO, Init;

const
  { Constants to use in version detection }
  VERSION_001_OR_001e                                             = '0.01 or 0.01e';
  VERSION_001f                                                    = '0.01f';
  VERSION_002_OR_004c_OR_005b                                     = '0.02 or 0.04c or 0.05b';
  VERSION_008                                                     = '0.08';
  VERSION_013c                                                    = '0.13c';
  VERSION_017                                                     = '0.17';
  VERSION_014_OR_016                                              = '0.14 or 0.16';
  VERSION_018_OR_019b6                                            = '0.18 or 0.19b6';
  VERSION_020d                                                    = '0.20d';
  VERSION_020e_OR_021DOS_OR_021aDOS_OR_022_OR_023_OR_023a_OR_023b = '0.20e or 0.21 (DOS) or 0.21a (DOS) or 0.22 or 0.23 or 0.23a or 0.23b'
  VERSION_021W32_OR_021aW32                                       = '0.21 (W32) or 0.21a (W32)';
  VERSION_023c_OR_023d_OR_023e_OR_023f                            = '0.23c or 0.23d or 0.23e or 0.23f';
  
function GetOldVersion: String; forward;
function GuessVersionByData: String; forward;
function GetVersionDatVersion: String; forward;
function PerformUpgrade(OldVersion: String): Boolean; forward;

function GetOldVersion: String;
var
  Result: String;
begin
  Result := GetVersionDatVersion;
  if (Result = '') then Result := GuessVersionByData;
  GetOldVersion := Result;
end;

function GuessVersionByData: String;
var
  NpcsDat: String;
  NpcsDatFile: File of Byte;
  NpcsDatSize: LongInt;
  Result: String;
begin
  Result := '';
  
  { Try to get filesize for DATA\NPCS.DAT (or .\NPCS.DAT for older versions) to use in version guessing }
  NpcsDat := Global_DataDir + 'NPCS.DAT';
  if Not(F_Exists(NpcsDat)) then NpcsDat := 'NPCS.DAT';
  if (F_Exists(NpcsDat)) then
  begin
    {$I-}
    Assign(NpcsDatFile, NpcsDat);
    Reset(NpcsDatFile);
    NpcsDatSize := FileSize(NpcsDatFile);
    Close(NpcsDatFile);
    {$I+}

    { BP can't use a LongInt in a case statement?  Makes for ugly repetetive IFs... }
    if (NpcsDatSize = 37800) then
    begin
      { TODO Not an exact match, further check possible? }
      Result := VERSION_001_OR_001e;
    end else
    if (NpcsDatSize = 49770) then
    begin
      Result := VERSION_001f;
    end else
    if (NpcsDatSize = 173880) then
    begin
      { TODO Not an exact match, further check possible? }
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
      { TODO Not an exact match, further check possible? }
      Result := VERSION_014_OR_016;
    end else
    if (NpcsDatSize = 91910) then
    begin
      Result := VERSION_017;
    end else
    if (NpcsDatSize = 100270) then
    begin
      { TODO Not an exact match, further check possible? }
      Result := VERSION_018_OR_019b6;
    end else
    if (NpcsDatSize = 100418) then
    begin
      Result := VERSION_020d;
    end else
    if (NpcsDatSize = 100566) then
    begin
      { TODO Not an exact match, further check possible? }
      Result := VERSION_020e_OR_021DOS_OR_021aDOS_OR_022_OR_023_OR_023a_OR_023b;
    end else
    if (NpcsDatSize = 113590) then
    begin
      { TODO Not an exact match, further check possible? }
      Result := VERSION_021W32_OR_021aW32;
    end else
    if (NpcsDatSize = 100566) then
    begin
      { TODO Not an exact match, further check possible? }
      Result := VERSION_023c_OR_023d_OR_023e_OR_023f;
    end;
  end else
  begin
    { Ignore, just means it's a new game that needs to be reset }
  end;
  
  GuessVersionByData := Result;
end;

function GetVersionDatVersion: String;
var
  Ch: Char;
  InFile: Text;
  Result: String;
begin
  Result := '';
  
  if (F_Exists(VersionF)) then
  begin
    repeat
      if (Open_TxtFile(TReset, InFile, VersionF)) then
      begin
        ReadLn_From_Text(InFile, Result);
        Close_Text(InFile);
        Ch := 'N'; { Causes repeat loop to terminate, since we got the verrsion we need }
      end else
      begin
        Result := 'ERROR';
        WriteLn('Error reading ' + VersionF + ' to determine which version of Usurper');
        WriteLn('you have installed!');
        WriteLn(' - If you will be resetting the game, then you can safely ignore this message');
        WriteLn(' - If you want to upgrade your game:');
        WriteLn('   - Hit Y to try to detect the installed version again');
        WriteLn('   - Hit any other key to skip the version check (and you can upgrade manually)');
        WriteLn('     See UPGRADE.TXT for instructions to manually upgrade your game');
        Ch := UpCase(ReadKey);
      end;
    until (Ch <> 'Y');
  end;
  
  GetVersionDatVersion := Result;
end;

function PerformUpgrade(OldVersion: String): Boolean;
var
  Ch: Char;
  Result: Boolean;
begin
  { Assume failure }
  Result := false;
  
  { Check which version we're upgrading from to see what needs to be done }
  if (OldVersion = VERSION_020e_OR_021DOS_OR_021aDOS_OR_022_OR_023_OR_023a_OR_023b) then
  begin
    WriteLn(' - If you will be resetting the game, then you can safely ignore this message');
    WriteLn(' - If you want to upgrade your game:');
    WriteLn('   - Hit Y to automatically upgrade your game (PLEASE BACKUP BEFORE DOING THIS)');
    WriteLn('   - Hit any other key to skip the upgrade (and you can upgrade manually)');
    WriteLn('     See UPGRADE.TXT for instructions to manually upgrade your game');
    Ch := UpCase(ReadKey);
    if (Ch = 'Y') then
    begin
      WriteLn('TODO Perform 0.23c upgrade');
      Result := true; { TODO Result should be set by success of upgrade }
      ReadKey;
    end else
    begin
      Result := true;
    end;
  end else
  begin
    WriteLn(' - Unfortunately your existing version is not supported by the automatic');
    WriteLn('   upgrade process, so you''ll have to perform the upgrade manually');
    WriteLn(' - See UPGRADE.TXT for instructions to manually upgrade your game');
    WriteLn;
    WriteLn('Hit any key to continue');
    ReadKey;
    Result := true;
  end;
  
  PerformUpgrade := Result;
end;

procedure UpgradeIfNecessary;
var
  NewVersion, OldVersion: String;
begin
  WriteLn;
  
  { Get EDITOR.EXE and VERSION.DAT (or best guess) versions }
  NewVersion := uver;
  OldVersion := GetOldVersion;
  
  { Check if we were able to retrieve the VERSION.DAT version }
  if (OldVersion = '') then
  begin
    WriteLn('Unable to determine which version of Usurper you have installed!');
    WriteLn(' - If you will be resetting the game, then you can safely ignore this message');
    WriteLn(' - If you want to upgrade your game, please see UPGRADE.TXT for instructions');
    WriteLn;
    WriteLn('Hit any key to continue');
    ReadKey;
  end else
  if (OldVersion = 'ERROR') then
  begin
    { Ignore, error message would have been presented to user earlier }
  end else
  if (NewVersion <> OldVersion) then
  begin
    WriteLn('It looks like your copy of Usurper needs to be updated');
    WriteLn('       Existing version: ' + OldVersion);
    WriteLn('  Version to upgrade to: ' + NewVersion);
    WriteLn;
    if Not(PerformUpgrade(OldVersion)) then
    begin
      WriteLn('An error was encountered while trying to upgrade your version of Usurper!');
      WriteLn(' - If you will be resetting the game, then you can safely ignore this message');
      WriteLn(' - If you want to upgrade your game, please see UPGRADE.TXT for instructions');
      WriteLn('   NOTE: This upgrade may have partially completed, so it would be best to');
      WriteLn('         restore the backup you made before manually upgrading (you made a');
      WriteLn('         backup like you were told to, right?!?)');
      WriteLn;
      WriteLn('Hit any key to continue');
      ReadKey;
    end;
  end;
end;

end.