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

Unit Upgrade;

interface

function UpgradeIfNecessary: Boolean;

implementation

uses
  File_IO, Init;

function UpgradeIfNecessary: Boolean;
var
  Txt: Text;
  VersionDatVersion: String;
begin
  { Assume failure }
  UpgradeIfNecessary := false;
  
  { Get installed version from VERSION.DAT }
  WriteLn;
  WriteLn('Checking if Usurper needs to be upgraded...');
  WriteLn('          EXE version: ' + uver);
  if (F_Exists(VersionF)) then
  begin
    if (Open_TxtFile(TReset, Txt, VersionF)) then
    begin
      ReadLn_From_Text(Txt, VersionDatVersion);
      Close_Text(Txt);
      WriteLn('  VERSION.DAT version: ' + VersionDatVersion);
    end else
    begin
      Unable_To_Access(VersionF);
      Exit;
    end;
  end else
  begin
    WriteLn('  VERSION.DAT version: File not found');
    WriteLn('Unknown version found, nothing to do');
    UpgradeIfNecessary := true;
    Exit;
    { TODO Could check for existence of files in DATA subdirectory.  If they exist, we could probably detect the installed
      version by looking at the sizes of certain data files, and upgrade as necessary.  If they don't exist, it's a new
      install, so no need to do anything }
  end;
  
  { If we get here we have a version from VERSION.DAT (or a guessed version from DATA file sizes) }
  if (uver = VersionDatVersion) then
  begin
    { Versions match, no need to do anything }
    WriteLn('Versions match, nothing to do');
    UpgradeIfNecessary := true;
    Exit;
  end else
  begin
    WriteLn('TODO Upgrade is necessary');
  end;
end;

end.