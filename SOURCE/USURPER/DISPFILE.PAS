{$mode objfpc}{$H+}
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

uses
  Init;

function DisplayTextFile(const Name: String): Boolean;
function DisplayTextFile(const Name: String; APlayer: UserRec): Boolean;

implementation

uses
  Math, StrUtils, SysUtils,
  DDPlus,
  File_IO, Jakob, Various;

var
  Player: UserRec;
  TownName: String;

function ExpandAtCodes(S: String): String; forward;
procedure WriteShortString(S: String); forward;

function DisplayTextFile(const Name: String): Boolean;
{show ansi/ascii from the text directory}
begin
  // Call the other DisplayTextFile method, passing the current player
  Result := DisplayTextFile(Name, Init.Player);
end; {DisplayTextFile *end*}

function DisplayTextFile(const Name: String; APlayer: UserRec): Boolean;
var
  AnsiSave: Boolean;
  F: Text;
  Filename, S: String;
begin
  // Assume failure
  DisplayTextFile := False;

  // Store the given player variable, so @-code expansion can use it
  Player := APlayer;

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

// Partially implements the @ code formatting options supported by Synchronet
// http://wiki.synchro.net/custom:atcodes
function ExpandAtCode(AtCode, AtFormat: String): String;
var
  DoLower, DoCenter, DoLeft, DoRight, DoThousands, DoUpper, DoZero: Boolean;
  Err, I, Width: Integer;
  WidthStr: String;
begin
  case AtCode of
    'ACTIVE_POISON':
    begin
      if GetClass(player) = Alchemist then
      begin
        if player.poison > 0 then
        begin
          Result := LowerCase(alchemist_poison(player));
        end else
        begin
          Result := 'none';
        end;
      end else
      begin
        Result := 'not applicable';
      end;
    end;
    'AGILITY': Result := Long2Str(player.agility);
    'CHARISMA': Result := Long2Str(player.charisma);
    'CHIVALRY': Result := Long2Str(player.chiv);
    'DARKNESS': Result := Long2Str(player.dark);
    'DEXTERITY': Result := Long2Str(player.dex);
    'DISEASE_RESISTANCE': Result := immunity(player.disres);
    'DRUG_ADDICTION': Result := Long2Str(player.addict) + '%';
    'DUNGEON_FIGHTS': Result := Long2Str(player.fights);
    'EYES': Result := color[player.eyes];
    'HAIR': Result := color[player.hair];
    'HEIGHT': Result := Long2Str(player.height) + 'cm';
    'MENTAL_STABILITY': Result := Long2Str(player.mental) + '%';
    'MONSTER_DEFEATS': Result := Long2Str(player.m_defeats);
    'MONSTER_KILLS': Result := Long2Str(player.m_kills);
    'PLAYER_DEFEATS': Result := Long2Str(player.p_defeats);
    'PLAYER_FIGHTS': Result := Long2Str(player.pfights);
    'PLAYER_KILLS': Result := Long2Str(player.p_kills);
    'RESURRECTIONS_LEFT': Result := Long2Str(player.resurrections);
    'SKIN': Result := color[player.skin];
    'STAMINA': Result := Long2Str(player.stamina);
    'TEAM_FIGHTS': Result := Long2Str(player.tfights);
    'TIME_LEFT': Result := Long2Str(time_left);
    'TOWN_NAME': Result := TownName;
    'WEIGHT': Result := Long2Str(player.weight) + 'kg';
    'WISDOM': Result := Long2Str(player.wisdom);
    else
    begin
      // If we get here the @ code wasn't handled, so return it as is
      if (AtFormat = '') then
      begin
        Result := '@' + AtCode + '@';
      end else
      begin
        Result := '@' + AtCode + '|' + AtFormat + '@';
      end;
      Exit;
    end;
  end;

  // If we get here the @ code was expanded, so now we need to check if
  // we need to format it
  if (AtFormat <> '') then
  begin
    DoLower := False;
    DoCenter := False;
    DoLeft := False;
    DoRight := False;
    DoThousands := False;
    DoUpper := False;
    DoZero := False;
    WidthStr := '';

    for I := 1 to Length(AtFormat) do
    begin
      case AtFormat[I] of
        '0'..'9': WidthStr += AtFormat[I];
        'C': DoCenter := True;
        'L': DoLeft := True;
        'R': DoRight := True;
        'T': DoThousands := True;
        'U': DoUpper := True;
        'u': DoLower := True;
        'Z': DoZero := True;
      end;
    end;

    // Handle casing
    if (DoUpper) then
    begin
      Result := UpperCase(Result);
    end else if (DoLower) then
    begin
      Result := LowerCase(Result);
    end;

    // Handle thousands separator
    if (DoThousands) then
    begin
      Val(Result, I, Err);
      if (Err = 0) then
      begin
        Result := CommaStr(I);
      end;
    end;

    // Handle padding/truncation
    if (WidthStr <> '') then
    begin
      Val(WidthStr, Width, Err);
      if (Err = 0) then
      begin
        // Truncate to at most Width characters
        Result := LeftStr(Result, Width);

        // If there are fewer characters than Width, pad as requested
        if (Length(Result) < Width) then
        begin
          if (DoZero) then
          begin
            Result := AddChar('0', Result, Width);
          end else
          if (DoRight) then
          begin
            Result := StrUtils.PadLeft(Result, Width);
          end else
          if (DoCenter) then
          begin
            Result := StrUtils.PadCenter(Result, Width);
          end else
          if (DoLeft) then
          begin
            Result := StrUtils.PadRight(Result, Width);
          end;
        end;
      end;
    end;
  end;
end;

function ExpandAtCodes(S: String): String;
var
  At1, At2, Pipe, SLen, Tail: Integer;
  AtString, AtCode, AtFormat: String;
begin
  SLen := Length(S);
  Result := '';
  Tail := 1;

  // Don't bother if the string is too short (min @X@ = 3)
  if (SLen < 3) then
  begin
    Result := S;
    Exit;
  end;

  while (true) do
  begin
    // Get the position of the first @ symbol, and break if there are none left
    At1 := PosEx('@', S, Tail);
    if (At1 = 0) then Break;

    // Check if there is non-@ text between the tail and the next @ code
    // and if there is, add it to the output variable
    if (At1 > Tail) then
    begin
      Result += Copy(S, Tail, At1 - Tail);
    end;

    // Get the position of the second @ symbol, and break if there are none left
    At2 := PosEx('@', S, At1 + 1);
    if (At2 = 0) then Break;

    // Copy the @ string, eliminating the leading and trailing @ symbols
    AtString := Copy(S, At1 + 1, At2 - At1 - 1);

    // Split the @ string into separate code and format pieces
    // Minimum example is 'X:Y', hence the >= 3 and >= 2 checks
    Pipe := Pos('|', AtString);
    if (Length(AtString) >= 3) and (Pipe >= 2) and (Pipe < Length(AtString)) then
    begin
      AtCode := Copy(AtString, 1, Pipe - 1);
      AtFormat := Copy(AtString, Pipe + 1, Length(AtString) - Pipe);
    end else
    begin
      AtCode := AtString;
      AtFormat := '';
    end;

    // Handle the expansion
    Result += ExpandAtCode(AtCode, AtFormat);

    // Update the tail to be next character that we need to process
    Tail := At2 + 1;
  end;

  // If there was text left in the input string, copy it to the output string
  if (Tail <= SLen) then
  begin
    Result += Copy(S, Tail, SLen - Tail + 1);
  end;
end;

// Usurper is compiled with $MODE TP for maximum compatability with TP,
// whereas this unit uses $MODE objfpc and $H+ to enable huge strings
// This means when we want to write text, we need to do it in chunks of
// no more than 255 characters, otherwise some data will be lost.
// We chunk at 250 instead of 255 just in case there's a bit of #255
// expansion (for Telnet connections)
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
  I := 1;
  while (I <= SLen) do
  begin
    ToRead := Min(250, SLen - I + 1);
    SSWrite(Copy(S, I, ToRead));
    I += ToRead;
  end;
end;

begin
  // Initialize the variables that won't change as the game is played,
  // so then we don't have to constantly read the config file as screens display
  TownName := cfg_string(9);
end. {Unit DispFile .end.}
