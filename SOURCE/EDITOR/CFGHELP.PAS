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


unit CfgHelp;
{Usurper Editor - Configuration Options Help text}
              {see cfgdef.pas for help regarding adding/editing/removing
               config options}
interface

const maxhelprows = 12; {used by dialog boxes when they set their x/y size}

function Configuration_Help(nr, line: integer): string;

implementation

uses
  Init;

function Color_Help(line: byte): string; {config color options}
var s: string;
begin

  s := '';
  case line of
    1: s := ' ';
    2: s := '[Choose from: Black, Blue, Green, Cyan, Red, Magenta,';
    3: s := ' Brown, LightGray, DarkGray, LightBlue, LightGreen,';
    4: s := ' LightCyan, LightRed, LightMagenta, Yellow, White]';
  end;

  {return result}
  color_help := s;

end; {color_help *end*}

function Configuration_Help(nr, line: integer): string;
var s: string;
begin

  {init}
  s := '';

  case nr of
    1: begin
      case line of
        1: s := 'Sysops name';
      end;
    end;
    2: begin
      case line of
        1: s := 'BBS name';
      end;
    end;
    3: begin
      case line of
        1: s := 'Days to keep items in Player Market';
        2: s := '(1-125, default is 20)';
      end;
    end;
    4: begin
      case line of
        1: s := 'Days to keep unread player mail';
        2: s := '(1-125, default is 8)';
      end;
    end;
    5: begin
      case line of
        1: s := 'Registration Code';
        2: s := '(Enter 0 if unregistered)';
      end;
    end;
    6: begin
      case line of
        1: s := 'Number of Dungeonfights players will';
        2: s := 'have every day (5-99). Default is 15.';
      end;
    end;
    7: begin
      case line of
        1: s := 'Days of Inactivity before a player';
        2: s := 'is deleted (15-999). Default is 25.';
      end;
    end;
    8: begin
      case line of
        1: s := 'NPCs tendencies toward doing evil things.';
        2: s := 'They do bad things to the human players.';
        3: s := '0=Passive, 1=Random, 2=Annoying, 3=Persecution';
      end;
    end;
    9: begin
      case line of
        1: s := 'Name of Town (max 40 chars)';
      end;
    end;
    10: begin
      case line of
        1: s := 'Dungeon difficulty (1-10) 10 is the toughest.';
        2: s := 'Increasing the value will make the monsters';
        3: s := 'hit harder. Default is 4.';
      end;
    end;
    11: begin
      case line of
        1: s := 'Display INTRO-menu (YES/No).';
        2: s := 'Setting this to NO will force the player into';
        3: s := 'the game immediately. Default is YES';
      end;
    end;
    12: begin
      case line of
        1: s := 'Name of Challenges place.';
        2: s := 'This is the point from where players go';
        3: s := 'to face different kind of challenges.';
        4: s := 'Default is: Anchor road';
      end;
    end;
    13: begin
      case line of
        1: s := 'Daily Number of Teamfights per player (1-99).';
        2: s := 'Default value is 5.';
      end;
    end;
    14: begin
      case line of
        1: s := 'Start Money for new players (100-1,000,000).';
        2: s := 'Default is 10,000 gold coins.';
      end;
    end;
    15: begin
      case line of
        1: s := 'Name of Weapon Shop owner [max 20 chars].';
        2: s := 'Default is TULLY, the stinking troll.';
      end;
    end;
    16: begin
      case line of
        1: s := 'Name of Armor Shop owner [max 20 chars].';
        2: s := 'Default is REESE.';
      end;
    end;
    17: begin
      case line of
        1: s := 'Name of Close Combat Trainer [max 20 chars].';
        2: s := 'This character can be found at the Market';
        3: s := 'Place. Default is LIU-ZEI.';
      end;
    end;
    18: begin
      case line of
        1: s := 'Name of Magic Shop owner [max 20 chars].';
        2: s := 'Default is Ravanella.';
      end;
    end;
    19: begin
      case line of
        1: s := 'Name of Bank Manager [max 20 chars].';
        2: s := 'Default is Lobba, the gnome.';
      end;
    end;
    20: begin
      case line of
        1: s := 'Name of Inn Keeper [max 20 chars].';
        2: s := 'Default is Garth.';
      end;
    end;
    21: begin
      case line of
        1: s := 'Name of Mad & Evil Mage [max 20 chars].';
        2: s := 'Default is Groggo.';
      end;
    end;
    22: begin
      case line of
        1: s := 'Quaffing Healing Potions in Dungeons (1-3).';
        2: s := '1 = Player quaffs potions and then autoattacks.';
        3: s := '2 = Player quaffs potions, and then monster attacks.';
        4: s := '3 = Player quaffs potions and can then choose option.';
        5: s := 'Default is 1.';
      end;
    end;
    23: begin
      case line of
        1: s := 'Display monster comments (YES/No).';
        2: s := 'Set this to YES if you want the Monsters';
        3: s := 'to say somehting when they encounter a';
        4: s := 'player. Default is YES.';
      end;
    end;
    24..33: begin
      case line of
        1: s := 'Losing Experience Points in the Dungeons.';
        2: begin
          case nr of
            24: s := 'Players at Level 01-10 lose X % of their xp';
            25: s := 'Players at Level 11-20 lose X % of their xp';
            26: s := 'Players at Level 21-30 lose X % of their xp';
            27: s := 'Players at level 31-40 lose X % of their xp';
            28: s := 'Players at level 41-50 lose X % of their xp';
            29: s := 'Players at level 51-60 lose X % of their xp';
            30: s := 'Players at level 61-70 lose X % of their xp';
            31: s := 'Players at level 71-80 lose X % of their xp';
            32: s := 'Players at level 81-90 lose X % of their xp';
            33: s := 'Players at level 91-100 lose X % of their xp';
          end;
        end;
        3: begin
          s := 'when they Die (0-90).';
        end;
        4: begin
          case nr of
            24: s := 'Default is 0.';
            25: s := 'Default is 2.';
            26: s := 'Default is 2.';
            27: s := 'Default is 2.';
            28: s := 'Default is 3.';
            29: s := 'Default is 3.';
            30: s := 'Default is 3.';
            31: s := 'Deafult is 4.';
            32: s := 'Default is 4.';
            33: s := 'Default is 4.';
          end;
        end;
      end;
    end;




    34: begin
      case line of
        1: s := 'Should players who are killed OFFLINE be able';
        2: s := 'to log in and play? This Only affects Player';
        3: s := 'vs Player fights (YES/No).';
        4: s := 'Default is YES.';
      end;
    end;
    35: begin
      case line of
        1: s := 'Should players be able to attack their';
        2: s := 'Team Mates? (Yes/NO).';
        3: s := 'Default is NO.';
      end;
    end;
    36: begin
      case line of
        1: s := 'Should players be able Resurrect Team Mates?';
        2: s := '(YES/No). Default is YES.';
      end;
    end;
    37: begin
      case line of
        1: s := 'Maximum level difference for players to attack';
        2: s := 'each other (0-25).';
        3: s := 'A value of 5 would mean that a level 10 character';
        4: s := 'only can attack players with a level of 5 and up.';
        5: s := '0 means that there are NO LIMITS! Default is 5.'
      end;
    end;
    38: begin
      case line of
        1: s := 'The Armor Base Value (0-60). A value of 10 means';
        2: s := 'that all armors absorb 10% of their armorvalues as';
        3: s := 'base value. The higher you set this value, the more';
        4: s := 'effective the armors get (default is 25).';
      end;
    end;
    39: begin
      case line of
        1: s := 'Make NPCs available in the Dormitory (thus';
        2: s := 'increasing the number of opponents available to';
        3: s := 'players. (YES/No).';
      end;
    end;
    40: begin
      case line of
        1: s := 'Number of Player Fights Allowed per day (0-99).';
        2: s := 'Default is 5.';
      end;
    end;
    41: begin
      case line of
        1: s := 'Bank Interest (1-15 %). Default is 5.';
      end;
    end;
    42: begin
      case line of
        1: s := 'Allow NPCs to create their Own Teams (YES/No).';
        2: s := 'Default is YES.';
      end;
    end;
    43: begin
      case line of
        1: s := 'Name of Dungeon Complex  [max 40 chars].';
        2: s := 'Default is Drunghin.';
      end;
    end;
    44: begin
      case line of
        1: s := 'Include NPCs Level Raises in the Daily news?';
        2: s := '(YES/No)';
      end;
    end;
    45: begin
      case line of
        1: s := 'Allow NPCs to buy new Weapons/Armors to';
        2: s := 'themselves. (YES/No).';
      end;
    end;
    46: begin
      case line of
        1: s := 'Include NPCs weapon/armor purchases in the news?';
        2: s := '(YES/No).';
      end;
    end;
    47: begin
      case line of
        1: s := 'Allow Teams to fight in the Dungeons (YES/No).';
      end;
    end;
    48: begin
      case line of
        1: s := 'Difficulty for Teams fighting in the dungeons';
        2: s := '(1-20, where 1 is easy). Default is 5.';
      end;
    end;
    49: begin
      case line of
        1: s := 'Maximum numbers of Healing potions a player can';
        2: s := 'carry (1-9999). Default is 35.';
      end;
    end;
    50: begin
      case line of
        1: s := 'Maximum number of players allowed in the game';
        2: s := '(1-400). Default is 400.';
      end;
    end;
    51: begin
      case line of
        1: s := 'Allow a Player to be on More than 1 Node';
        2: s := 'simultaneously (YES/No). Default is YES.';
      end;
    end;
    52: begin
      case line of
        1: s := 'Cost to Identify an Item in the Magic';
        2: s := 'Shop (1-9999999). Default is 1500 gold coins.';
      end;
    end;
    53: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Hand equipment  (2 is default).';
        3: s := ' ';
        4: s := '0 = Not allowed';
        5: s := '1 = Take both';
        6: s := '2 = Left only';
        7: s := '3 = Right only';
        8: s := '4 = Random Left/Right';
        9: s := '5 = Random Left/Right/Both';
        10: s := '6 = Random Left/Right/Both/None';
        11: s := ' ';
        12: s := 'This option only applies if game is in NEW mode.';
      end;
    end;
    54: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Head Equipment. (YES/No).';
      end;
    end;
    55: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Body Equipment. (Yes/NO).';
      end;
    end;
    56: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Arm Equipment. (Yes/NO).';
      end;
    end;
    57: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Finger Equipment. (Yes/NO).';
      end;
    end;
    58: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Leg Equipment. (Yes/NO).';
      end;
    end;
    59: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Feet Equipment. (Yes/NO).';
      end;
    end;
    60: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Waist Equipment. (Yes/NO).';
      end;
    end;
    61: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Neck Equipment. (Yes/NO).';
      end;
    end;
    62: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Face Equipment. (Yes/NO).';
      end;
    end;
    63: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Shield. (Yes/NO).';
      end;
    end;
    64: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'on Hands equipment. (Yes/NO).';
      end;
    end;
    65: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'around Body equipment. (YES/No).';
      end;
    end;
    66: begin
      case line of
        1: s := 'Allow Victor to take defeated players';
        2: s := 'Inventory equipment. (YES/No).';
      end;
    end;
    67: begin
      case line of
        1: s := 'Perform Automatic Maintenance (YES/no).';
      end;
    end;
    68: begin
      case line of
        1: s := 'Resurrect dead players at Maintenance (YES/No).';
      end;
    end;
    69: begin
      case line of
        1: s := 'Credits to user(s) helping out registering';
        2: s := 'Usurper.';
      end;
    end;
    70: begin
      case line of
        1: s := 'Path and name of Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    71: begin
      case line of
        1: s := 'Path and name of Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    72: begin
      case line of
        1: s := 'Path and name of Team Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    73: begin
      case line of
        1: s := 'Path and name of Team Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    74: begin
      case line of
        1: s := 'Path and name of Weapon Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    75: begin
      case line of
        1: s := 'Path and name of Weapon Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    76: begin
      case line of
        1: s := 'Path and name of Armor Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    77: begin
      case line of
        1: s := 'Path and name of Armor Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    78: begin
      case line of
        1: s := 'Path and name of Equipment Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    79: begin
      case line of
        1: s := 'Path and name of Equipment Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    80: begin
      case line of
        1: s := 'Path and name of Player Killers Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    81: begin
      case line of
        1: s := 'Path and name of Player Killers Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    82: begin
      case line of
        1: s := 'Path and name of Monster Killers Score file (ANSI)';
        2: s := '(none is created if left blank).';
      end;
    end;
    83: begin
      case line of
        1: s := 'Path and name of Monster Killers Score file (ASCII)';
        2: s := '(none is created if left blank).';
      end;
    end;
    84: begin
      case line of
        1: s := 'Create Score Files upon exit of Usurper (YES/no).';
        2: s := ' ';
        3: s := 'If you set this to NO you may want to update the';
        4: s := 'Score files manually by typing : Usurper /scores.';
      end;
    end;
    85: begin
      case line of
        1: s := 'Allow losers in Beer Drinking Competition';
        2: s := 'to play again (YES/no).';
      end;
    end;
    86: begin
      case line of
        1: s := 'Allow losers from Brawls in Bobs Bar to play again (YES/no).';
      end;
    end;
    87: begin
      case line of
        1: s := 'Log player entrances in the News (YES/no)';
        2: s := 'This option could be turned off if you have a lot of';
        3: s := 'players in the game, since the news-paper can become';
        4: s := 'rather lengthy when the activity is high.';
      end;
    end;
    88: begin
      case line of
        1: s := 'NPC players buying strategy (1-5).';
        2: s := '1=sloppy ... 5=very careful.';
        3: s := 'The higher value the longer maintenance sessions.';
      end;
    end;
    89: begin
      case line of
        1: s := 'Town Reward. The sum of money a gang gets for';
        2: s := 'controlling the town. Default is 5,000 gold coins.';
        3: s := 'Example :';
        4: s := 'Bill (level 10) and Bull (level 3) holds the town.';
        5: s := 'With a 5,000 coin reward the sum to share would be :';
        6: s := '(10 * 5,000) + (3 * 5,000) = 65,000';
        7: s := '------------------------------------';
        8: s := 'The sum is then split equally between the two members.';
        9: s := 'Giving them 32,500 gold coins each.';
      end;
    end;
    90: begin
      case line of
        1: s := 'Should players lose experience points after losing';
        2: s := 'a player - player fight? :';
        3: s := ' 0 = No  (default)';
        4: s := ' 1 = Yes (both offline and online players)';
        5: s := ' 2 = Yes (but only online players)';
        6: s := ' 3 = Yes (but only offline players)';
        7: s := 'If you set this option to 1,2 or 3 then the same %';
        8: s := 'are used as in the ''dying in the dungeons'' options';
        9: s := '(24-33).';
      end;
    end;
    91: begin
      case line of
        1: s := 'Game mode : CLASSIC or NEW';
        2: s := 'CLASSIC gives the player only one weapon and one armor.';
        3: s := 'NEW gives the player the choice of different kinds';
        4: s := 'of armor (leg, head, feet, body...etc etc).';
        5: s := 'This switch can be toggled in the middle of a game.';
        6: s := 'But it is not recommended.';
      end;
    end;
    92: begin
      case line of
        1: s := 'Allow players killed in online battles to';
        2: s := 'play more the same day (YES/No).';
      end;
    end;
    93: begin
      case line of
        1: s := 'Include NPCs in External Score Files (YES/No).';
      end;
    end;
    94: begin
      case line of
        1: s := 'Allow Computer Controlled teams to attack other';
        2: s := 'teams (YES/No).';
      end;
    end;
    95: begin
      case line of
        1: s := 'Maximum level superiority for attacking';
        2: s := 'team (1-5000). Raising this value means that';
        3: s := 'the high level teams can attack MORE low level';
        4: s := 'teams. See example :';
        5: s := ' Team1 : lev11 + lev5 + lev10 + lev25 = 51';
        6: s := ' Team2 : lev2  + lev1 + lev4  + lev7  = 14';
        7: s := ' -----------------------------------------';
        8: s := '       Level Superiority for Team1 is = 37';
      end;
    end;
    96: begin
      case line of
        1: s := 'Allow players attacked in the Dorm to be rescued by';
        2: s := 'team-mates. This only occurs at random occasions.';
        3: s := '(YES/No).';
      end;
    end;
    97: begin
      case line of
        1: s := 'Number of Drinks player can order per day.';
        2: s := '(1-15, default is 3)';
      end;
    end;
    98: begin
      case line of
        1: s := 'Check node interactivity every X second.';
        2: s := '0-999 (0=no checking, default is 5).';
      end;
    end;
    99: begin
      case line of
        1: s := 'Semaphore File Path. Important for multiline BBS.';
        2: s := 'This field specifies the directory where temporary';
        3: s := 'and static files used for multi-node operations are';
        4: s := 'stored. A RAM disk is highly recommended.';
        5: s := 'The directory specified here should be the drive and';
        6: s := 'path to a directory on a disk (preferably a RAM disk).';
        7: s := 'If you leave this field blank the semaphore files';
        8: s := 'will be created in the Usurper ' + global_nodedir + ' directory.';
      end;
    end;
    100: begin
      case line of
        1: s := 'Allow ONE MAN TEAMS to attack other teams';
        2: s := '(YES/No)';
      end;
    end;
    101: begin
      case line of
        1: s := 'Allow Hand armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    102: begin
      case line of
        1: s := 'Allow Head armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    103: begin
      case line of
        1: s := 'Allow Body armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    104: begin
      case line of
        1: s := 'Allow Arm armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    105: begin
      case line of
        1: s := 'Allow Left finger items to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    106: begin
      case line of
        1: s := 'Allow Right finger items to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    107: begin
      case line of
        1: s := 'Allow Leg armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    108: begin
      case line of
        1: s := 'Allow Feet armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    109: begin
      case line of
        1: s := 'Allow Waist items to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    110: begin
      case line of
        1: s := 'Allow 1 Neck items to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    111: begin
      case line of
        1: s := 'Allow 2 Neck items to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    112: begin
      case line of
        1: s := 'Allow Face armor to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    113: begin
      case line of
        1: s := 'Allow Shields to be used in game';
        2: s := '(YES/no)';
      end;
    end;
    114: begin
      case line of
        1: s := 'Allow Around body items in game';
        2: s := '(YES/no)';
      end;
    end;
    115: begin
      case line of
        1: s := 'Allow Secondary Weapon in game';
        2: s := '(YES/no)';
      end;
    end;
    116: begin
      case line of
        1: s := 'Days to keep Wanted Posters';
        2: s := '(1-125, default is 30)';
      end;
    end;
    117: begin
      case line of
        1: s := 'name and path of DAILY NEWS file (ASCII)';
        2: s := '(none is created if left blank)';
      end;
    end;
    118: begin
      case line of
        1: s := 'name and path of DAILY NEWS file (ANSI)';
        2: s := '(none is created if left blank)';
      end;
    end;
    119: begin
      case line of
        1: s := 'name and path of YESTERDAY NEWS file (ASCII)';
        2: s := '(none is created if left blank)';
      end;
    end;
    120: begin
      case line of
        1: s := 'name and path of YESTERDAY NEWS file (ANSI)';
        2: s := '(none is created if left blank)';
      end;
    end;
    121: begin
      case line of
        1: s := 'Player level needed to attempt to usurp the throne.';
        2: s := '(0-100, 0=nobody can make an attempt, default is 25)';
      end;
    end;
    122: begin
      case line of
        1: s := 'Player must be good or evil to usurp the throne';
        2: s := '(Good,Evil or Any, default is ANY)';
      end;
    end;
    123: begin
      case line of
        1: s := 'Should NPCs be marked with a ''*'' in the player listings.';
        2: s := 'If you set this to NO it will be harder to distinguish computer';
        3: s := 'characters from the humans involved. Default is YES.';
        4: s := '(YES,no)';
      end;
    end;

    124: begin
      case line of
        1: s := 'Display Error Messages On Screen. Should only be turned on';
        2: s := 'if hunting down a problem/error. Usually only used when';
        3: s := 'evaluating new versions or checking multi node functions.';
        4: s := 'Default is NO    (yes,NO)';
      end;
    end;

    125: begin
      case line of
        1: s := 'Days to keep not ordered player-made cocktails at Orbs Bar?';
        2: s := '(0-9999, 0=indefinitely) Default is 90.';
      end;
    end;

    126: begin
      case line of
        1: s := 'How many cocktail recipes do you allow to be stored at';
        2: s := 'Orbs Bar (0-9999, 0=no limit) Default is 50.';
      end;
    end;
    127: begin
      case line of
        1: s := 'Should pick-pockets who are caught or defeated in the Dormitory';
        2: s := 'be able to enter game again the same day  (YES,no).';
      end;
    end;
    128: begin
      case line of
        1: s := 'Should trouble-makers who are defeated in fist-fights in the';
        2: s := 'Dormitory be able to enter game again the same day  (YES,no).';
      end;
    end;
    129: begin
      case line of
        1: s := 'Allow the King to setup Quests (YES/no)';
      end;
    end;
    130: begin
      case line of
        1: s := 'Max number of quests allowed in database (1-65000, default is 100)';
      end;
    end;
    131: begin
      case line of
        1: s := 'Number of quests a player can claim simultaneously.';
        2: s := '(1-500, default is 3)';
      end;
    end;
    132: begin
      case line of
        1: s := 'Number of Quests a player may complete / day.';
        2: s := '(0-9999, default is 5)';
      end;
    end;
    133: begin
      case line of
        1: s := 'Number of New quests the King can issue every day.';
        2: s := '(1-500, default is 3)';
      end;
    end;
    134: begin
      case line of
        1: s := 'Allow the King to force quests upon players (YES/no).';
      end;
    end;
    135: begin
      case line of
        1: s := 'Allow players who die on quests to enter again the same day?';
        2: s := '(yes/NO).';
      end;
    end;
    136: begin
      case line of
        1: s := 'Allow players who are killed trying to rescue prisoners';
        2: s := 'to enter again the same day (yes/NO).';
      end;
    end;
    137: begin
      case line of
        1: s := 'Npc willingness to add comments to the Inn chatfile.';
        2: s := '(0=never, 1=seldom, 2=sometimes, 3=often) default is 1.';
        3: s := ' ';
        4: s := 'The Npc comments are stored in \DATA\NPCCHAT.DAT';
        5: s := 'You might want to edit the NPC comments, to add a';
        6: s := 'special atmosphere to the game.';
      end;
    end;
    138: begin
      case line of
        1: s := 'Allow the King to imprison players for how many days?';
        2: s := '(0-15, default is 1). 0=King is not allowed to imprison';
        3: s := 'players at all.';
      end;
    end;
    139: begin
      case line of
        1: s := 'Use File-locking or Record-locking?';
        2: s := 'File-locking is slower but more compatible.';
        3: s := 'Record-locking is faster but may not work on your system.';
        4: s := ' ';
        5: s := '(1=file-locking, 2=record-locking, default is 1).';
      end;
    end;
    140: begin
      case line of
        1: s := 'Delay (in milliseconds) between file-locking attempts.';
        2: s := '(0-1500, default is 50).';
      end;
    end;
    141: begin
      case line of
        1: s := 'Game text color.';
        2: s := '(default is Green).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);

      end;
    end;

    142: begin
      case line of
        1: s := 'Player names will be displayed in this color.';
        2: s := '(default is LightGreen).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;
    143: begin
      case line of
        1: s := 'Teams will be displayed in this color.';
        2: s := '(default is Cyan).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;
    144: begin
      case line of
        1: s := 'Monsters will be displayed in this color.';
        2: s := '(default is LightRed).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;
    145: begin
      case line of
        1: s := 'Items will be displayed in this color.';
        2: s := '(default is LightCyan).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;
    146: begin
      case line of
        1: s := 'Talk, speech, and comments will be displayed in this color.';
        2: s := '(default is LightMagenta).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;
    147: begin
      case line of
        1: s := 'Menu brackets will be displayed in this color.';
        2: s := '(default is Green).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end; {case .end.}
    end;
    148: begin
      case line of
        1: s := 'Menu selection keys will be displayed in this color.';
        2: s := '(default is Magenta).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end; {case .end.}
    end;
    149: begin
      case line of
        1: s := 'Resurrect the King when Castle is infiltrated? (YES/no)';
        2: s := 'Setting this to "no" will force the King to stay alive';
        3: s := 'if he wishes to defend his throne.';
      end; {case .end.}
    end;
    150: begin
      case line of
        1: s := 'Number of Wrestling matches a player can go / day.';
        2: s := '(1-15, default is 5)';
      end; {case .end.}
    end;
    151: begin
      case line of
        1: s := 'Allow the King to close shops (YES/no).';
        2: s := 'The King can easily abuse this option,';
        3: s := 'especially by closing down the Magic Shop.';
        4: s := 'If you get many complaints from your users';
        5: s := 'You should consider setting this to "no"';
      end; {case .end.}
    end;
    152: begin
      case line of
        1: s := 'Punish player who drops carrier during fights and when';
        2: s := 'taking Steroids and Drugs (0-1).';
        3: s := ' ';
        4: s := ' 0 = no punishment (default).';
        5: s := ' 1 = player is not allowed to play more that day.';
      end; {case .end.}
    end;
    153: begin
      case line of
        1: s := 'Allow NPCs to marry and have kids? (YES/no).';
        2: s := 'The downside of letting the NPCs marry is';
        3: s := 'that maintenance takes longer to finish.';
      end; {case .end.}
    end;
    154: begin
      case line of
        1: s := 'Allow players to visit the Steroid shop? (YES/no).';
      end; {case .end.}
    end;
    155: begin
      case line of
        1: s := 'Allow players to visit the Whore house? (YES/no).';
      end; {case .end.}
    end;
    156: begin
      case line of
        1: s := 'Allow players to visit the Drug Palace? (YES/no).';
      end; {case .end.}
    end;
    157: begin
      case line of
        1: s := 'Allow players to Murder Innocent People? (YES/no).';
      end; {case .end.}
    end;
    158: begin
      case line of
        1: s := 'Put player opinions of the King the news? (YES/no).';
      end; {case .end.}
    end;
    159: begin
      case line of
        1: s := 'How many fake players are allowed to enter? (0-110).';
        2: s := 'Default is 2.';
      end; {case .end.}
    end;
    160: begin
      case line of
        1: s := 'Type of money to be used in game (default is "gold").';
        2: s := 'This could be any other type of valuable item you like.';
        3: s := 'Examples: "silver", "iron", "mineral" or "peanut"';
      end; {case .end.}
    end;
    161: begin
      case line of
        1: s := 'This option depends on what you selected in #160.';
        2: s := 'Default here is "coin".';
        3: s := 'Examples: "coin", "bar", "plate" or "shell"';
      end; {case .end.}
    end;
    162: begin
      case line of
        1: s := 'This option should match the value selected in #161.';
        2: s := 'Default here is "coins".';
        3: s := 'Examples: "coins", "bars", "plates" or "shells"';
      end; {case .end.}
    end;
    163: begin
      case line of
        1: s := 'Number of songs available to the Bards every day.';
        2: s := 'Choose between 0-50. Default is 5.';
      end; {case .end.}
    end;
    164: begin
      case line of
        1: s := 'Log Immortal entrances in the News (YES/no)';
        2: s := 'This option could be turned off if you have a lot of';
        3: s := 'immortals in the game, since the news-paper can become';
        4: s := 'rather lengthy when the activity is high.';
      end;
    end;
    165: begin
      case line of
        1: s := 'Name of Bartender at Orbs Bar';
        2: s := 'Default is Sly';
      end;
    end;
    166: begin
      case line of
        1: s := 'Minimum Age for Marriage';
        2: s := '0 - 5000. Default is 18';
      end;
    end;
    167: begin
      case line of
        1: s := 'Name of Bobs Beer Hut.';
        2: s := 'Default is Bobs Beer Hut';
      end;
    end;
    168: begin
      case line of
        1: s := 'Shop-keeper at Bobs.';
        2: s := 'Default is Bob';
      end;
    end;
    169: begin
      case line of
        1: s := 'Name of Bishop.';
        2: s := 'Default is Jakobinus';
      end;
    end;
    170: begin
      case line of
        1: s := 'Name of Gossip-Monger at the Love Corner.';
        2: s := 'Default is Lydia';
      end;
    end;
    171: begin
      case line of
        1: s := 'Name of Bartender at Bobs Beer.';
        2: s := 'Default is Ted';
      end;
    end;
    172: begin
      case line of
        1: s := 'Name of Gym-Masseur.';
        2: s := 'Default is Hazzan';
      end;
    end;
    173: begin
      case line of
        1: s := 'Put Relation Changes in the News (YES/no)';
      end;
    end;
    174: begin
      case line of
        1: s := 'How many Children may a Player have';
        2: s := '0 - 300. Default is 25';
      end;
    end;
    175: begin
      case line of
        1: s := 'How many Children may a NPC have';
        2: s := '0 - 300. Default is 15';
      end;
    end;
    176: begin
      case line of
        1: s := 'How many Prison Escape attempts should';
        2: s := 'a player have every day?';
        3: s := '0 - 250. Default is 3';
      end;
    end;
    177: begin
      case line of
        1: s := 'Allow players to view game settings (YES/no)';
      end;
    end;
    178: begin
      case line of
        1: s := 'Minutes of Inactivity before a player';
        2: s := 'is disconnected?';
        3: s := '0 - 900. (0=no check is made)';
        4: s := 'Default is 15';
      end;
    end;
    179: begin
      case line of
        1: s := 'Steroid Shop-Keeper (default is: Rand the Human)';
      end;
    end;
    180: begin
      case line of
        1: s := 'Name of Drug Shop-Keeper (default is Ordlof)';
      end;
    end;
    181: begin
      case line of
        1: s := 'Bear Taming attempts per day (0 - 128)';
        2: s := 'Default is 5.';
      end;
    end;
    182: begin
      case line of
        1: s := 'Allow NPCs to usurp the Royal Throne (YES/no)';
        2: s := ' ';
        3: s := 'Note that the NPCs follow the same rules as the';
        4: s := 'regular players. This means that if only good-hearted';
        5: s := 'characters are allowed to take power then only good-';
        6: s := 'hearted NPCs can make attempts.';
      end;
    end;
    183: begin
      case line of
        1: s := 'Allow the King to toss children to the Wolves (0-5)';
        2: s := 'Default is 0.';
        3: s := ' ';
        4: s := 'Setting this to a value of 1 would mean that the King';
        5: s := 'can feed the wolves with one tasty kid per day.';
      end;
    end;
    184: begin
      case line of
        1: s := 'Allow the King to dissolve and ban marriages / day (0-15)';
        2: s := 'Default is 1.';
      end;
    end;
    185: begin
      case line of
        1: s := 'Allow the King to put children in the Royal Orphanage (0-5)';
        2: s := 'Default is 1.';
        3: s := ' ';
        4: s := 'Setting this to a value of 1 would mean that the King can';
        5: s := 'send one kid to the Royal Orphanage every day.';
      end;
    end;
    186: begin
      case line of
        1: s := 'Allow NPCs to interact with the Gods (YES/no)';
      end;
    end;
    187: begin
      case line of
        1: s := 'God color. The Immortals names are displayed in this color.';
        2: s := '(default is LightGreen).';
        3: s := color_help(1);
        4: s := color_help(2);
        5: s := color_help(3);
        6: s := color_help(4);
      end;
    end;

    188: begin
      case line of
        1: s := 'Allow Fake players (ghosts) to be chatty (YES/no)';
        2: s := 'This option only applies if fake players are allowed to enter.';
        3: s := 'Set this to NO if you feel that the fake players are spamming.';
      end;
    end;

    189: begin
      case line of
        1: s := 'How many Intimacy acts should a player have every day (0-60000)';
        2: s := 'Default is 2.';
      end;
    end;

    190: begin
      case line of
        1: s := 'Allow Homo-Sexual relations (yes/NO)';
        2: s := 'Set this to YES if you want to allow male-male or female-female relationships.';
        3: s := '(note: currently NPCs are not affected by this setting. They are straight).';
      end;
    end;

    191: begin
      case line of
        1: s := 'How many resurrections should a player have every day (0-60000)';
        2: s := 'Default is 3.';
      end;
    end;

    192: begin
      case line of
        1: s := 'Should a user be allowed to have both Immortal and Mortal characters';
        2: s := 'active at the same time (YES/no).';
      end;
    end;

    193: begin
      case line of
        1: s := 'How many days of pregnancy for females (0-300)';
        2: s := 'Default is 5.';
      end;
    end;

    194: begin
      case line of
        1: s := 'Allow Adult Options (YES/No)';
        2: s := '(intimate sessions where sex is involved)';
      end;
    end;


    195: begin
      case line of
        1: s := 'How many Pick-Pocket Attempts does a player have / day';
        2: s := '(0 - 60000, default is 5)'
      end;
    end;

    196: begin
      case line of
        1: s := 'Name of Quest-Master [max 20 chars].';
        2: s := 'Default is Ulgmog.';
      end;
    end;

    197: begin
      case line of
        1: s := 'Allow players to store items at Home.';
        2: s := 'Only available in Usurper NEW mode.';
        3: s := '(0 - 300 items, default is 10)'
      end;
    end;



    198: begin
      case line of
        1: s := 'How many Bank Robbery Attempts does a player have / day';
        2: s := '(0 - 60000, default is 3)'
      end;
    end;

  end; {case .end.}

  {return result}
  configuration_help := s;

end; {configuration_help *end*}

end. {Unit CfgHelp .end.}
