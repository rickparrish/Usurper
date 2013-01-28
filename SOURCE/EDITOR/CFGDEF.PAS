{$IFDEF WIN32}
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


Unit CfgDef; {Usurper Editor - Configuration Lines}

 {you must update these routines when you add/remove/change editor options :

  init.pas
  cfgdef.pas
  cfghelp.pas
  cfgval.pas
  extra.pas => save_config proc

  }

Interface

Function Cfg_Default(const c : integer): string;

Implementation

Uses Init;

Function Cfg_Default;
var
    s,s2: string;
    i,fill : byte;

Begin
 case c of
  1: s:='Sysop';
  2: s:='BBS';
  3: s:='Days to keep items in player market';
  4: s:='Days to keep unread player mail';
  5: s:='Registration code (0=unregistered)';
  6: s:='Dungeonfights';
  7: s:='Days of inactivity';
  8: s:='NPCs are vicious';
  9: s:='Town';
 10: s:='Dungeon difficulty';
 11: s:='INTRO-menu';
 12: s:='Challenges place';
 13: s:='Teamfights per day';
 14: s:='Start money';
 15: s:='Weaponshop owner';
 16: s:='Armorshop owner';
 17: s:='Combat Trainer';
 18: s:='Magicshop owner';
 19: s:='Bank manager';
 20: s:='Inn owner';
 21: s:='Mad & Evil Mage';
 22: s:='Quaffing potions';
 23: s:='Monster comments';
 24..33: s:='% of xp to lose in Dungeons';
 34: s:='Allow offline victims to play';
 35: s:='Allow people to attack teammates';
 36: s:='Allow resurrection of teammates';
 37: s:='Max level diff for player attacks';
 38: s:='Armor base value';
 39: s:='NPCs available in the Dormitory';
 40: s:='Player Fights allowed';
 41: s:='Bank interest';
 42: s:='Allow NPCs to create own teams';
 43: s:='Dungeon complex';
 44: s:='Include NPCs level raises in news';
 45: s:='Allow NPCs to buy equipment';
 46: s:='Include NPC purchases in news';
 47: s:='Teams in the Dungeons';
 48: s:='Team difficulty in Dungeons';
 49: s:='Max numbers of Healing potions';
 50: s:='Max number of players';
 51: s:='More than 1 node';
 52: s:='ID cost';
 53: s:='Take Hand Equipment';
 54: s:='Take Head Equipment';
 55: s:='Take Body Equipment';
 56: s:='Take Arm Equipment';
 57: s:='Take Finger Equipment';
 58: s:='Take Leg Equipment';
 59: s:='Take Feet Equipment';
 60: s:='Take Waist Equipment';
 61: s:='Take Neck Equipment';
 62: s:='Take Face Equipment';
 63: s:='Take Shield';
 64: s:='Take Hands Equipment';
 65: s:='Take Around Body Equipment';
 66: s:='Take Inventory Equipment';
 67: s:='Automatic Maintenance';
 68: s:='Resurrection';
 69: s:='Credits to users';
 70: s:='Score file (ANSI)';
 71: s:='Score file (ASCII)';
 72: s:='Team score file (ANSI)';
 73: s:='Team score file (ASCII)';
 74: s:='Weapon score file (ANSI)';
 75: s:='Weapon score file (ASCII)';
 76: s:='Armor score file (ANSI)';
 77: s:='Armor score file (ASCII)';
 78: s:='Equipment score file (ANSI)';
 79: s:='Equipment score file (ASCII)';
 80: s:='"Player Killers" score file (ANSI)';
 81: s:='"Player Killers" score file (ASCII)';
 82: s:='"Monster Killers" score file (ANSI)';
 83: s:='"Monster Killers" score file (ASCII)';
 84: s:='Create score files';
 85: s:='Losers from Beer Drinking';
 86: s:='Losers from Brawls in Bobs Bar';
 87: s:='Log Player Entrances in the News';
 88: s:='NPCs buying strategy';
 89: s:='Town Reward for teams';
 90: s:='Losing xp after player fight';
 91: s:='Game mode, CLASSIC or NEW';
 92: s:='Losers in online battles';
 93: s:='NPCs in external score files';
 94: s:='Computer team attacks';
 95: s:='Max level superiority for gangs';
 96: s:='Rescue Team-mates';
 97: s:='Drinks player can order per day';
 98: s:='Check other nodes';
 99: s:='Semaphore path';
 100:s:='"One man teams"';
 101: s:='Allow Hand Equipment';
 102: s:='Allow Head Equipment';
 103: s:='Allow Body Equipment';
 104: s:='Allow Arm Equipment';
 105: s:='Allow Left Finger Equipment';
 106: s:='Allow Right Finger Equipment';
 107: s:='Allow Leg Equipment';
 108: s:='Allow Feet Equipment';
 109: s:='Allow Waist Equipment';
 110: s:='Allow 1 Neck Equipment';
 111: s:='Allow 2 Neck Equipment';
 112: s:='Allow Face Equipment';
 113: s:='Allow Shield';
 114: s:='Allow Around Body Equipment';
 115: s:='Allow Secondary Weapon';
 116: s:='Days to keep Wanted Posters';
 117: s:='Daily News file (ASCII)';
 118: s:='Daily News file (ANSI)';
 119: s:='Yesterdays News (ASCII)';
 120: s:='Yesterdays News (ANSI)';
 121: s:='Level needed to Usurp the throne';
 122: s:='Soul needed to Usurp the throne';
 123: s:='Mark the NPCs in the lists';
 124: s:='Display error messages on screen';
 125: s:='Days to keep cocktails at Orbs Bar';
 126: s:='Max cocktails allowed at Orbs Bar';
 127: s:='Allow pick-pockets to enter again';
 128: s:='Allow trouble-makers to enter again';
 129: s:='Allow the King to setup Quests';
 130: s:='Quests allowed in database';
 131: s:='Quests a player can claim';
 132: s:='Quests a player can complete/day';
 133: s:='Quests the King can issue/day';
 134: s:='Allow Forced quests';
 135: s:='Handle players killed on quests';
 136: s:='Handle players killed in rescues';
 137: s:='Npc willingness to chat at the Inn.';
 138: s:='Allow the King to imprison players';
 139: s:='Use FILE-locking or RECORD-locking';
 140: s:='Delay between file-locking attempts';
 141: s:='Game text color';
 142: s:='Player color';
 143: s:='Team color';
 144: s:='Monster color';
 145: s:='Item color';
 146: s:='Speech color';
 147: s:='Menu bracket color';
 148: s:='Menu key color';
 149: s:='Resurrect King when Castle is attacked';
 150: s:='Wrestling matches/day';
 151: s:='Allow the King to close shops';
 152: s:='Punish player who drops carrier';
 153: s:='Allow NPCs to marry and have kids';
 154: s:='Open Steroid Shop';
 155: s:='Open Whore house';
 156: s:='Open Drug Palace';
 157: s:='Allow murders';
 158: s:='Put Royal polls in the News-paper';
 159: s:='Fake players are allowed to enter';
 160: s:='Money type used in game (gold)';
 161: s:='Money type used with #160 (coin)';
 162: s:='Money type used with #161 (coins)';
 163: s:='Bard songs available every day';
 164: s:='Log Immortals entering game in News';
 165: s:='Name of Bartender at Orbs Bar';
 166: s:='Minimum Age to Marry';
 167: s:='Bobs Beer Hut';
 168: s:='Shop-keeper at Bobs';
 169: s:='Bishop';
 170: s:='Gossip-Monger and Midwife';
 171: s:='Bartender at Bobs Beer';
 172: s:='Name of Gym-Masseur';
 173: s:='Put Relation Changes in the News';
 174: s:='Human children allowed';
 175: s:='NPC children allowed';
 176: s:='Prison Escape attempts allowed';
 177: s:='Allow players to view game settings';
 178: s:='Minutes of inactivity';
 179: s:='Steroid Shop-Keeper';
 180: s:='Drug Shop-Keeper';
 181: s:='Bear Taming attempts/day';
 182: s:='Allow NPCs to usurp the Throne';
 183: s:='Allow King to kill children';
 184: s:='Allow King to ban/dissolve marriages';
 185: s:='Allow King to put kids in Orphanage';
 186: s:='Allow NPCs to interact with Gods';
 187: s:='Color of Gods';
 188: s:='Should fake players be chatty';
 189: s:='Intimacy acts per day';
 190: s:='Homo/Bi-Sexual relations allowed';
 191: s:='Resurrections a player have/day';
 192: s:='Allow a user to have Immortal&Mortals';
 193: s:='Days of pregnancy for females';
 194: s:='Allow Adult Options (intimate)';
 195: s:='Pick Pocket Attempts/day';
 196: s:='Name of Quest-Master';
 197: s:='Store Items at Home';
 198: s:='Bank Robbery Attempts/day';
 end; {case .end.}

 if length(s)<39 then begin
  fill:=39-length(s);
  for i:=1 to fill do begin
   s:=s+'.';
  end
 end;

 str(c,s2);
 case c of
  1..9    : s:=s2+'...'+s;
  10..99  : s:=s2+'..'+s;
  100..999: s:=s2+'.'+s;
 end;

 {s:=s+cfgvalue[c]; {adderar VALUE}

 {return result}
 cfg_default:=s;

End; {Cfg_Default *end*}

End. {Unit CfgDef .end.}