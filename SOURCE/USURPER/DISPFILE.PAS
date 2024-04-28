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
  File_IO, Jakob, Various, Various2, Version;

var
  BankMan: String;
  Player: UserRec;
  TownName: String;

function ExpandAtCode(AtString: String): String; forward;
function ExpandAtCodes(S: String): String; forward;
function ExpandTernary(AtString: String): String; forward;
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
function ExpandAtCode(AtString: String): String;
var
  DoLower, DoCenter, DoLeft, DoParentheses, DoRight, DoThousands, DoUpper, DoZero: Boolean;
  Err, I, Pipe, Width: Integer;
  AtCode, AtFormat, WidthStr: String;

  inarm: armrec;
  inweap: weaprec;
begin
  Result := '';

  // Split the @ string into separate code and format pieces
  // Minimum example is 'X|Y', hence the >= 3 and >= 2 checks
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

  case AtCode of
    'ACTIVE_POISON':
    begin
      if GetClass(player) = Alchemist then
      begin
        if player.poison > 0 then
        begin
          Result := alchemist_poison(player);
        end else
        begin
          Result := 'None';
        end;
      end else
      begin
        Result := 'Not Applicable';
      end;
    end;
    'AGE': Result := Long2Str(player.age) + ' years';
    'AGILITY': Result := Long2Str(player.agility);
    'ARMOUR_NAME':
    begin
      if (player.armor = 0) then
      begin
        Result := 'skin';
      end else
      begin
        load_armor(player.armor, inarm);
        Result := inarm.name;
      end;
    end;
    'ARMOUR_POWER': Result := Long2Str(player.apow * 11);
    'BANK': Result := Long2Str(player.bankgold);
    'BANKMAN': Result := BankMan;
    'CHARISMA': Result := Long2Str(player.charisma);
    'CHIVALRY': Result := Long2Str(player.chiv);
    'CLASS': Result := classnames[GetClass(player)];
    'COMPILED_DATE': Result := ucomp;
    'DARKNESS': Result := Long2Str(player.dark);
    'DEFENCE': Result := Long2Str(player.defence);
    'DEXTERITY': Result := Long2Str(player.dex);
    'DISEASE_RESISTANCE': Result := immunity(player.disres);
    'DRUG_ADDICTION': Result := Long2Str(player.addict) + '%';
    'DUNGEON_FIGHTS': Result := Long2Str(player.fights);
    'EXP': Result := Long2Str(player.exp);
    'EYES': Result := color[player.eyes];
    'GOLD': Result := Long2Str(player.gold);
    'HAIR': Result := color[player.hair];
    'HEALINGS': Result := Long2Str(player.healing);
    'HEIGHT': Result := Long2Str(player.height) + 'cm';
    'HP_FRACTION': Result := Long2Str(player.hps) + '/' + Long2Str(player.maxhps);
    'LEVEL': Result := Long2Str(player.level);
    'MENTAL_STABILITY': Result := Long2Str(player.mental) + '%';
    'MONEY_TYPE':
    begin
      Result := config.moneytype;
      Result[1] := UpCase(Result[1]);
    end;
    'MONSTER_DEFEATS': Result := Long2Str(player.m_defeats);
    'MONSTER_KILLS': Result := Long2Str(player.m_kills);
    'NAME': Result := player.name2;
    'PICKPOCKETS': Result := Long2Str(player.pickpocketattempts);
    'PLAYER_DEFEATS': Result := Long2Str(player.p_defeats);
    'PLAYER_FIGHTS': Result := Long2Str(player.pfights);
    'PLAYER_KILLS': Result := Long2Str(player.p_kills);
    'RACE': Result := race_display(1, player.race, 0);
    'RESURRECTIONS': Result := Long2Str(player.resurrections);
    'SKIN': Result := color[player.skin];
    'STAMINA': Result := Long2Str(player.stamina);
    'STRENGTH': Result := Long2Str(player.strength);
    'TEAM_FIGHTS': Result := Long2Str(player.tfights);
    'TEAM_NAME':
    begin
      if (player.team = '') then
      begin
        Result := '<not on a team>';
      end else
      begin
        Result := player.team;
      end;
    end;
    'TIME_LEFT': Result := Long2Str(time_left);
    'TOWN_NAME': Result := TownName;
    'TRAININGS': Result := Long2Str(player.trains);
    'VERSION': Result := uver;
    'WEAPON_NAME':
    begin
      if (player.weapon = 0) then
      begin
        Result := 'bare hands';
      end else
      begin
        load_weapon(player.weapon, inweap);
        Result := inweap.name;
      end;
    end;
    'WEAPON_POWER': Result := Long2Str(player.wpow * 11);
    'WEIGHT': Result := Long2Str(player.weight) + 'kg';
    'WISDOM': Result := Long2Str(player.wisdom);
    else
    begin
      // If we get here the @ code wasn't handled, so return it as is
      Result := '@' + AtString + '@';
      Exit;
    end;
  end;

  // If we get here, that means Result now contains the text we want to display

  // Check if a format has been requested
  if (AtFormat <> '') then
  begin
    DoLower := False;
    DoCenter := False;
    DoLeft := False;
    DoParentheses := False;
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
        'P': DoParentheses := True;
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

    // Handle parentheses
    if (DoParentheses) and (Trim(Result) <> '') then
    begin
      Result := '(' + Result + ')';
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
  At1, At2, SLen, Tail: Integer;
  AtString: String;
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

    // Check if this is a standard @ code, or a ternary conditional
    if (LeftStr(AtString, 4) = 'CAN_') or (LeftStr(AtString, 4) = 'HAS_') or (LeftStr(AtString, 3) = 'IS_') then
    begin
      // It's a conditional
      Result += ExpandTernary(AtString);
    end else
    begin
      // It's a standard code
      Result += ExpandAtCode(AtString);
    end;

    // Update the tail to be next character that we need to process
    Tail := At2 + 1;
  end;

  // If there was text left in the input string, copy it to the output string
  if (Tail <= SLen) then
  begin
    Result += Copy(S, Tail, SLen - Tail + 1);
  end;
end;

function ExpandTernary(AtString: String): String;
var
  AtCode, IfTrue, IfFalse: String;
  Colon, QuestionMark: Integer;
  IsTrue: Boolean;
begin
  Result := '';
  IsTrue := False;

  // Split the @ string into separate code, true, and false pieces
  // Example: IS_ME?It's me:It's not me
  QuestionMark := Pos('?', AtString);
  Colon := Pos(':', AtString);
  AtCode := Copy(AtString, 1, QuestionMark - 1);
  IfTrue := Copy(AtString, QuestionMark + 1, Colon - QuestionMark - 1);
  IfFalse := Copy(AtString, Colon + 1, Length(AtString) - Colon);

  case AtCode of
    'CAN_LEVEL_UP': IsTrue := (level_raise(player.level, player.exp) = 0);
    'HAS_MANA': IsTrue := (GetClass(player) in [Cleric, Sage, Magician]);
    'HAS_TEAM': IsTrue := (player.team <> '');
    'HAS_TRAININGS': IsTrue := (player.trains > 0);
    'IS_ALCHEMIST': IsTrue := (GetClass(player) = Alchemist);
    'IS_KING': IsTrue := (player.king and (player.sex = 1));
    'IS_ME': IsTrue := (player.name1 = Init.player.name1);
    'IS_QUEEN': IsTrue := (player.king and (player.sex <> 1));
    else
    begin
      // If we get here the @ code wasn't handled, so return it as is
      Result := '@' + AtString + '@';
      Exit;
    end;
  end;

  // If we get here, we need to update Result with either the true or false
  // branch based on the result of the conditional variable
  if (IsTrue) then Result := IfTrue else Result := IfFalse;

  // Ternary @ codes use # instead, so check if we have any in our Result, and if
  // so, pass them to ExpandAtCodes so they can be expanded
  if (Pos('#', AtString) > 0) then
  begin
    Result := StringReplace(Result, '#', '@', [rfReplaceAll]);
    Result := ExpandAtCodes(Result);
  end;

  // Handle any special chars that can be used in a ternary
  if (Pos('\', Result) > 0) then
  begin
    Result := StringReplace(Result, '\a', '@', [rfReplaceAll]);
    Result := StringReplace(Result, '\c', ':', [rfReplaceAll]);
    Result := StringReplace(Result, '\h', '#', [rfReplaceAll]);
    Result := StringReplace(Result, '\r', #13, [rfReplaceAll]);
    Result := StringReplace(Result, '\n', #10, [rfReplaceAll]);
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
  BankMan := cfg_string(19);
  TownName := cfg_string(9);
end. {Unit DispFile .end.}
