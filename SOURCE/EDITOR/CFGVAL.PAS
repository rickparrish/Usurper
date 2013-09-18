{$I DEFINES.INC}
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


unit CfgVal;
{Usurper Editor - Config file default values}
             {see cfgdef.pas for help regarding adding/editing/removing
             config options}
interface

{Uses Init;}

function Cfg_Value(const c: integer): string;

implementation

uses
  Init;

function Cfg_Value(const c: integer): string;

const YEP = 'YES';
  NOP     = 'NO';

var s: string;

begin

  s := '';
  case c of
    1: s := 'Jakob Dangarden';
    2: s := 'Silent Service';
    3: s := '20';
    4: s := '8';
    5: s := '0';
    6: s := '25';
    7: s := '30';
    8: s := '3';
    9: s := 'Valhalla';
    10: s := '4';
    11: s := yep;
    12: s := 'Anchor road';
    13: s := '2';
    14: s := '10000';
    15: s := 'Tully';
    16: s := 'Reese';
    17: s := 'Liu Zei';
    18: s := 'Ravanella';
    19: s := 'Lobba';
    20: s := 'Garth';
    21: s := 'Groggo';
    22: s := '1';
    23: s := yep;
    24: s := '0';
    25: s := '2';
    26: s := '2';
    27: s := '2';
    28: s := '3';
    29: s := '3';
    30: s := '3';
    31: s := '4';
    32: s := '4';
    33: s := '4';
    34: s := yep;
    35: s := nop;
    36: s := yep;
    37: s := '5';
    38: s := '25';
    39: s := yep;
    40: s := '3';
    41: s := '3';
    42: s := yep;
    43: s := 'Drunghin';
    44: s := yep;
    45: s := yep;
    46: s := yep;
    47: s := yep;
    48: s := '5';
    49: s := '125';
    50: s := '400';
    51: s := yep;
    52: s := '1000';
    53: s := '2';
    54: s := yep;
    55: s := nop;
    56: s := nop;
    57: s := nop;
    58: s := nop;
    59: s := nop;
    60: s := nop;
    61: s := nop;
    62: s := nop;
    63: s := nop;
    64: s := nop;
    65: s := nop;
    66: s := nop;
    67: s := yep;
    68: s := nop;
    69: s := 'Thanks to Me who registered Usurper!';
    70: s := global_scoredir + 'USCORES.ANS';
    71: s := global_scoredir + 'USCORES.ASC';
    72: s := global_scoredir + 'TSCORES.ANS';
    73: s := global_scoredir + 'TSCORES.ASC';
    74: s := global_scoredir + 'WSCORES.ANS';
    75: s := global_scoredir + 'WSCORES.ASC';
    76: s := global_scoredir + 'ASCORES.ANS';
    77: s := global_scoredir + 'ASCORES.ASC';
    78: s := global_scoredir + 'ESCORES.ANS';
    79: s := global_scoredir + 'ESCORES.ASC';
    80: s := global_scoredir + 'PKILLER.ANS';
    81: s := global_scoredir + 'PKILLER.ASC';
    82: s := global_scoredir + 'MKILLER.ANS';
    83: s := global_scoredir + 'MKILLER.ASC';
    84: s := yep;
    85: s := yep;
    86: s := yep;
    87: s := yep;
    88: s := '3';
    89: s := '5000';
    90: s := '0';
    91: s := 'CLASSIC';
    92: s := yep;
    93: s := yep;
    94: s := yep;
    95: s := '100';
    96: s := yep;
    97: s := '3'; {drinks / day at Orbs}
    98: s := '5';
    99: s := global_nodedir;
    100: s := yep;
    101: s := nop; {allow equipment / toggle on OFF}
    102: s := yep;
    103: s := nop;
    104: s := nop;
    105: s := nop;
    106: s := nop;
    107: s := nop;
    108: s := nop;
    109: s := nop;
    110: s := yep;
    111: s := nop;
    112: s := nop;
    113: s := nop;
    114: s := nop;
    115: s := nop; {allow equipment / toggle on OFF}
    116: s := '30';
    117: s := nwfileasc;  {news file, asc}
    118: s := nwfileans;  {news file, ans}
    119: s := ynwfileasc; {yesterday -"-}
    120: s := ynwfileans; {yesterdat -"-}
    121: s := '25'; {level needed to usurp the throne}
    122: s := 'ANY'; {soul needed to usurp the throne}
    123: s := yep; {should npcs marked with a '*' in the lists}
    124: s := nop; {display error messages}
    125: s := '90'; {days to keep cocktail recipes at Orbs Bar}
    126: s := '50'; {max number of recipes allowed at Orbs Bar}
    127: s := yep; {allow caught pick-pockets at the Dorm to enter again}
    128: s := yep; {allow defeated trouble-makers in the Dorm to enter again}
    129: s := yep;
    130: s := '100';
    131: s := '3';
    132: s := '5';
    133: s := '3';
    134: s := yep;
    135: s := nop;
    136: s := nop;
    137: s := '1';
    138: s := '1';
    139: s := '1';
    140: s := '50';
    141: s := 'Green';
    142: s := 'LightGreen';
    143: s := 'Cyan';
    144: s := 'LightRed';
    145: s := 'LightCyan';
    146: s := 'LightMagenta';
    147: s := 'Green';
    148: s := 'Magenta';
    149: s := yep;
    150: s := '5';
    151: s := yep;
    152: s := '0';
    153: s := yep; {allow npcs to marry and have kids (YES/no)}
    154: s := yep; {allow players to visit Steroid shop}
    155: s := yep; {allow players to visit Whore house}
    156: s := yep; {allow players to visit Drug Palace}
    157: s := yep; {allow players to murder Innocent people}
    158: s := yep; {put player opinions of the king in the news?}
    159: s := '2'; {allow fake players to enter, per player session!}
    160: s := 'gold'; {gold}
    161: s := 'coin'; {coin}
    162: s := 'coins'; {coins}
    163: s := '5'; {Bard songs/day}
    164: s := 'YES'; {log immortals entering game in the news}
    165: s := 'Sly'; {name of Bartender at Orbs Bar}
    166: s := '18'; {minimum age to marry}
    167: s := 'Bobs Beer Hut';
    168: s := 'Bob';
    169: s := 'Jakobinus';
    170: s := 'Lydia';
    171: s := 'Ted';
    172: s := 'Hazzan'; {gym-masseur}
    173: s := 'Yes'; {put relation changes in the news}
    174: s := '25'; {max number of human children}
    175: s := '15'; {max number of npc children}
    176: s := '3'; {max number prison escape attempts / day}
    177: s := 'YES'; {allow players to view game settings}
    178: s := '15'; {minutes before disconnected for inactivty}
    179: s := 'Rand the Human'; {Steroid Shop-Keeper}
    180: s := 'Ordlof'; {Drug Shop-Keeper}
    181: s := '5'; {Bear Taming attempts / day}
    182: s := 'Yes'; {Allow NPCs to usurp the royal throne}
    183: s := '0'; {Allow King to toss kids to the wolves}
    184: s := '1'; {Allow King to ban/dissolve marriages per day}
    185: s := '1'; {Allow King to put kids in the royal orphanage}
    186: s := 'YES'; {Allow NPCs to interact with GODs}
    187: s := 'LightGreen'; {God color}
    188: s := 'YES'; {fake players be chatty?}
    189: s := '2'; {intimacy acts per day}
    190: s := 'NO'; {homo relations allowed}
    191: s := '3'; {resurrections / day}
    192: s := 'YES'; {allow a user to have both immortal and mortal characters active}
    193: s := '5'; {days of pregnancy, before the child pops out}
    194: s := 'YES'; {allow adult options}
    195: s := '5'; {pick-pocket attempts / day}
    196: s := 'Ulgmog'; {Quest-Master}
    197: s := '10'; {Store Items at Home}
    198: s := '3'; {Bank Robbery attempts / day}
  end; {case .end.}

  {return result}
  cfg_value := s;

end; {cfg_value *end*}

end. {Unit CfgVal .end.}
