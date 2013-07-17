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
  Result: String;
begin
  Result := '';
  
  { TODO Guess version by looking at data files }
  
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
      if not(Open_TxtFile(TReset, InFile, VersionF)) then
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
  Result: Boolean;
begin
  { Assume failure }
  Result := false;
  
  { TODO Check which version we're upgrading from to see what needs to be done }
  
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