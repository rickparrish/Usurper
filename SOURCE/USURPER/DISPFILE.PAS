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
unit DispFile; {Usurper - Displays a file from the TEXT subdirectory}

interface

{$H+}

function DisplayTextFile(const Name: String): Boolean;

implementation

uses
  Math, SysUtils,
  DDPlus,
  File_IO, Init, Jakob, Various;

var
  TownName: String;

function ExpandAtCodes(S: String): String; forward;
procedure WriteShortString(S: String); forward;

function DisplayTextFile(const Name: String): Boolean;
{show ansi/ascii from the text directory}
var
  AnsiSave: Boolean;
  F: Text;
  Filename, S: String;
begin
  // Assume failure
  DisplayTextFile := False;

  {keep ansi variable}
  AnsiSave := AnsiOn;
  AnsiOn := True; {process ansi locally, ddplus variable}

  // Get filename
  if global_ansi then
  begin
    Filename := global_textdir + upcasestr(Name) + '.ANS';
  end else
  begin
    Filename := global_textdir + upcasestr(Name) + '.ASC';
  end;

  // Read file line by line
  Assign(F, Filename);
  {$I-}Reset(F);{$I+}
  if (IOResult = 0) then
  begin
    while Not(EOF(F)) do
    begin
      ReadLn(F, S);

      if (Pos('@', S) > 0) then
      begin
        S := ExpandAtCodes(S);
      end;

      WriteShortString(S);
      if Not(EOF(F)) then Crlf;
    end; {while .end.}

    {close textfile}
    Close(F);

    DisplayTextFile := True;
  end else
  begin
    {error accessing resource file}
    unable_to_access(Filename, access_error);
  end;

  // Force resetting the foreground colour
  current_foreground := config.textcolor + 1;
  set_foreground(config.textcolor);

  {restore ansi variable}
  AnsiOn := AnsiSave;
end; {DisplayTextFile *end*}

function ExpandAtCodes(S: String): String;
begin
  // Just a dumb implementation as a proof-of-concept.  Eventually want to support
  // something like http://wiki.synchro.net/custom:atcodes with format modifiers
  ExpandAtCodes := StringReplace(S, '@TOWNNAME@', TownName, [rfReplaceAll]);
end;

procedure WriteShortString(S: String);
var
  I, SLen, ToRead: Integer;
begin
  SLen := Length(S);

  // If we already have a short string, just write it
  if (SLen <= 250) then
  begin
    SSWrite(S);
    Exit;
  end;

  // If we get here we have a long string, so we need to write it in chunks
  // since the rest of Usurper is in $H- mode
  I := 1;
  while (I <= SLen) do
  begin
    ToRead := Min(250, SLen - I + 1);
    SSWrite(Copy(S, I, ToRead));
    I += ToRead;
  end;
end;

begin
  TownName := cfg_string(9);
end. {Unit DispText .end.}
