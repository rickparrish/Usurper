{$IFNDEF MSDOS}
{$I DEFINES.INC}
{$ENDIF}
 {*********************************************************}
 {*                   ANSICOLR.PAS 1.0                    *}
 {*            Copyright (c) Ì ·ETATech Ì 1991.           *}
 {*                 All rights reserved.                  *}
 {*********************************************************}
 { Wed  12-18-1991 v1.0                                    }
 { This unit is patterned after the TurboPower OPCOLOR     }
 { unit.  OPCOLOR allows the programmer to specify screen  }
 { colors with easily rememberable names like "RedOnBlue". }
 { I wanted a way to specify the same type of color        }
 { definitions, but have the ANSI escape sequence for that }
 { combination to be the output.  Hopfully this unit will  }
 { accomplish this task making ANSI colors easier for the  }
 { programmer.                                             }

 { The naming conventions of ANSICOLR are similar to that  }
 { of OPCOLOR except that all names begin with a lower     }
 { case "a" (ie. aRedOnBlack).  This will return the ANSI  }
 { escape code that will enable this color combination.    }
 { All low intensity forground combinations start by       }
 { setting the previous colors off, then define the new    }
 { color set.  To get a color set with the foreground set  }
 { to blink, just preface the color combination with "ab"  }
 { (ie. abRedOnBlue).  Each low intensity color combination}
 { is 10 char., each high intensity color set is 12 char.  }
 { and each blinking color set is 14 char. long.           }

 { I retain the copyright for this unit, but release it for}
 { public use with no royalties required.  You may use it  }
 { in any program that it would be of assistance to you.   }
 { In the same regard, I offer NO WARANTEE what so ever    }
 { either express or implied.                              }

 { If you come up with enhancements or changes to this unit}
 { I would appreciate knowing about them as I would like to}
 { keep the unit up to date.  I can be reached at the      }
 { places listed below:                                    }

 { ·ETATech Computer Consulting           The Paradigm BBS }
 { P. O. Box 566742                           404/671-1581 }
 { Atlanta, GA  30356-6013                  1200-19200 HST }
 {*********************************************************}

unit AnsiColr; {Usurper - this ansi unit was taken from the SWAG archive}

interface

const

  aBlink: byte     = 16;

  aSt: string [2]  = #27'[';
  aEnd: string [1] = 'm';
  aDef: string [4] = #27'[0m';

  fgCol: array [0..31] of string [8] =
    ('0;30', '0;34', '0;32', '0;36',
    '0;31', '0;35', '0;33', '0;37',
    '0;1;30', '0;1;34', '0;1;32', '0;1;36',
    '0;1;31', '0;1;35', '0;1;33', '0;1;37',
    '0;5;30', '0;5;34', '0;5;32', '0;5;36',
    '0;5;31', '0;5;35', '0;5;33', '0;5;37',
    '0;1;5;30', '0;1;5;34', '0;1;5;32', '0;1;5;36',
    '0;1;5;31', '0;1;5;35', '0;1;5;33', '0;1;5;37');

  bgCol: array [0..7] of string [4] =
    (';40', ';44', ';42', ';46', ';41', ';45', ';43', ';47');

type
  Str14 = string [14];

{Black background}
function aBlackOnBlack: Str14;
function abBlackOnBlack: Str14;
function aBlueOnBlack: Str14;
function abBlueOnBlack: Str14;
function aGreenOnBlack: Str14;
function abGreenOnBlack: Str14;
function aCyanOnBlack: Str14;
function abCyanOnBlack: Str14;
function aRedOnBlack: Str14;
function abRedOnBlack: Str14;
function aMagentaOnBlack: Str14;
function abMagentaOnBlack: Str14;
function aBrownOnBlack: Str14;
function abBrownOnBlack: Str14;
function aLtGrayOnBlack: Str14;
function abLtGrayOnBlack: Str14;
function aDkGrayOnBlack: Str14;
function abDkGrayOnBlack: Str14;
function aLtBlueOnBlack: Str14;
function abLtBlueOnBlack: Str14;
function aLtGreenOnBlack: Str14;
function abLtGreenOnBlack: Str14;
function aLtCyanOnBlack: Str14;
function abLtCyanOnBlack: Str14;
function aLtRedOnBlack: Str14;
function abLtRedOnBlack: Str14;
function aLtMagentaOnBlack: Str14;
function abLtMagentaOnBlack: Str14;
function aYellowOnBlack: Str14;
function abYellowOnBlack: Str14;
function aWhiteOnBlack: Str14;
function abWhiteOnBlack: Str14;

{Blue background}
function aBlackOnBlue: Str14;
function abBlackOnBlue: Str14;
function aBlueOnBlue: Str14;
function abBlueOnBlue: Str14;
function aGreenOnBlue: Str14;
function abGreenOnBlue: Str14;
function aCyanOnBlue: Str14;
function abCyanOnBlue: Str14;
function aRedOnBlue: Str14;
function abRedOnBlue: Str14;
function aMagentaOnBlue: Str14;
function abMagentaOnBlue: Str14;
function aBrownOnBlue: Str14;
function abBrownOnBlue: Str14;
function aLtGrayOnBlue: Str14;
function abLtGrayOnBlue: Str14;
function aDkGrayOnBlue: Str14;
function abDkGrayOnBlue: Str14;
function aLtBlueOnBlue: Str14;
function abLtBlueOnBlue: Str14;
function aLtGreenOnBlue: Str14;
function abLtGreenOnBlue: Str14;
function aLtCyanOnBlue: Str14;
function abLtCyanOnBlue: Str14;
function aLtRedOnBlue: Str14;
function abLtRedOnBlue: Str14;
function aLtMagentaOnBlue: Str14;
function abLtMagentaOnBlue: Str14;
function aYellowOnBlue: Str14;
function abYellowOnBlue: Str14;
function aWhiteOnBlue: Str14;
function abWhiteOnBlue: Str14;

{Green background}
function aBlackOnGreen: Str14;
function abBlackOnGreen: Str14;
function aBlueOnGreen: Str14;
function abBlueOnGreen: Str14;
function aGreenOnGreen: Str14;
function abGreenOnGreen: Str14;
function aCyanOnGreen: Str14;
function abCyanOnGreen: Str14;
function aRedOnGreen: Str14;
function abRedOnGreen: Str14;
function aMagentaOnGreen: Str14;
function abMagentaOnGreen: Str14;
function aBrownOnGreen: Str14;
function abBrownOnGreen: Str14;
function aLtGrayOnGreen: Str14;
function abLtGrayOnGreen: Str14;
function aDkGrayOnGreen: Str14;
function abDkGrayOnGreen: Str14;
function aLtBlueOnGreen: Str14;
function abLtBlueOnGreen: Str14;
function aLtGreenOnGreen: Str14;
function abLtGreenOnGreen: Str14;
function aLtCyanOnGreen: Str14;
function abLtCyanOnGreen: Str14;
function aLtRedOnGreen: Str14;
function abLtRedOnGreen: Str14;
function aLtMagentaOnGreen: Str14;
function abLtMagentaOnGreen: Str14;
function aYellowOnGreen: Str14;
function abYellowOnGreen: Str14;
function aWhiteOnGreen: Str14;
function abWhiteOnGreen: Str14;

{Cyan background}
function aBlackOnCyan: Str14;
function abBlackOnCyan: Str14;
function aBlueOnCyan: Str14;
function abBlueOnCyan: Str14;
function aGreenOnCyan: Str14;
function abGreenOnCyan: Str14;
function aCyanOnCyan: Str14;
function abCyanOnCyan: Str14;
function aRedOnCyan: Str14;
function abRedOnCyan: Str14;
function aMagentaOnCyan: Str14;
function abMagentaOnCyan: Str14;
function aBrownOnCyan: Str14;
function abBrownOnCyan: Str14;
function aLtGrayOnCyan: Str14;
function abLtGrayOnCyan: Str14;
function aDkGrayOnCyan: Str14;
function abDkGrayOnCyan: Str14;
function aLtBlueOnCyan: Str14;
function abLtBlueOnCyan: Str14;
function aLtGreenOnCyan: Str14;
function abLtGreenOnCyan: Str14;
function aLtCyanOnCyan: Str14;
function abLtCyanOnCyan: Str14;
function aLtRedOnCyan: Str14;
function abLtRedOnCyan: Str14;
function aLtMagentaOnCyan: Str14;
function abLtMagentaOnCyan: Str14;
function aYellowOnCyan: Str14;
function abYellowOnCyan: Str14;
function aWhiteOnCyan: Str14;
function abWhiteOnCyan: Str14;

{Red background}
function aBlackOnRed: Str14;
function abBlackOnRed: Str14;
function aBlueOnRed: Str14;
function abBlueOnRed: Str14;
function aGreenOnRed: Str14;
function abGreenOnRed: Str14;
function aCyanOnRed: Str14;
function abCyanOnRed: Str14;
function aRedOnRed: Str14;
function abRedOnRed: Str14;
function aMagentaOnRed: Str14;
function abMagentaOnRed: Str14;
function aBrownOnRed: Str14;
function abBrownOnRed: Str14;
function aLtGrayOnRed: Str14;
function abLtGrayOnRed: Str14;
function aDkGrayOnRed: Str14;
function abDkGrayOnRed: Str14;
function aLtBlueOnRed: Str14;
function abLtBlueOnRed: Str14;
function aLtGreenOnRed: Str14;
function abLtGreenOnRed: Str14;
function aLtCyanOnRed: Str14;
function abLtCyanOnRed: Str14;
function aLtRedOnRed: Str14;
function abLtRedOnRed: Str14;
function aLtMagentaOnRed: Str14;
function abLtMagentaOnRed: Str14;
function aYellowOnRed: Str14;
function abYellowOnRed: Str14;
function aWhiteOnRed: Str14;
function abWhiteOnRed: Str14;

{Magenta background}
function aBlackOnMagenta: Str14;
function abBlackOnMagenta: Str14;
function aBlueOnMagenta: Str14;
function abBlueOnMagenta: Str14;
function aGreenOnMagenta: Str14;
function abGreenOnMagenta: Str14;
function aCyanOnMagenta: Str14;
function abCyanOnMagenta: Str14;
function aRedOnMagenta: Str14;
function abRedOnMagenta: Str14;
function aMagentaOnMagenta: Str14;
function abMagentaOnMagenta: Str14;
function aBrownOnMagenta: Str14;
function abBrownOnMagenta: Str14;
function aLtGrayOnMagenta: Str14;
function abLtGrayOnMagenta: Str14;
function aDkGrayOnMagenta: Str14;
function abDkGrayOnMagenta: Str14;
function aLtBlueOnMagenta: Str14;
function abLtBlueOnMagenta: Str14;
function aLtGreenOnMagenta: Str14;
function abLtGreenOnMagenta: Str14;
function aLtCyanOnMagenta: Str14;
function abLtCyanOnMagenta: Str14;
function aLtRedOnMagenta: Str14;
function abLtRedOnMagenta: Str14;
function aLtMagentaOnMagenta: Str14;
function abLtMagentaOnMagenta: Str14;
function aYellowOnMagenta: Str14;
function abYellowOnMagenta: Str14;
function aWhiteOnMagenta: Str14;
function abWhiteOnMagenta: Str14;

{Brown background}
function aBlackOnBrown: Str14;
function abBlackOnBrown: Str14;
function aBlueOnBrown: Str14;
function abBlueOnBrown: Str14;
function aGreenOnBrown: Str14;
function abGreenOnBrown: Str14;
function aCyanOnBrown: Str14;
function abCyanOnBrown: Str14;
function aRedOnBrown: Str14;
function abRedOnBrown: Str14;
function aMagentaOnBrown: Str14;
function abMagentaOnBrown: Str14;
function aBrownOnBrown: Str14;
function abBrownOnBrown: Str14;
function aLtGrayOnBrown: Str14;
function abLtGrayOnBrown: Str14;
function aDkGrayOnBrown: Str14;
function abDkGrayOnBrown: Str14;
function aLtBlueOnBrown: Str14;
function abLtBlueOnBrown: Str14;
function aLtGreenOnBrown: Str14;
function abLtGreenOnBrown: Str14;
function aLtCyanOnBrown: Str14;
function abLtCyanOnBrown: Str14;
function aLtRedOnBrown: Str14;
function abLtRedOnBrown: Str14;
function aLtMagentaOnBrown: Str14;
function abLtMagentaOnBrown: Str14;
function aYellowOnBrown: Str14;
function abYellowOnBrown: Str14;
function aWhiteOnBrown: Str14;
function abWhiteOnBrown: Str14;

{Light gray backgrouund}
function aBlackOnLtGray: Str14;
function abBlackOnLtGray: Str14;
function aBlueOnLtGray: Str14;
function abBlueOnLtGray: Str14;
function aGreenOnLtGray: Str14;
function abGreenOnLtGray: Str14;
function aCyanOnLtGray: Str14;
function abCyanOnLtGray: Str14;
function aRedOnLtGray: Str14;
function abRedOnLtGray: Str14;
function aMagentaOnLtGray: Str14;
function abMagentaOnLtGray: Str14;
function aBrownOnLtGray: Str14;
function abBrownOnLtGray: Str14;
function aLtGrayOnLtGray: Str14;
function abLtGrayOnLtGray: Str14;
function aDkGrayOnLtGray: Str14;
function abDkGrayOnLtGray: Str14;
function aLtBlueOnLtGray: Str14;
function abLtBlueOnLtGray: Str14;
function aLtGreenOnLtGray: Str14;
function abLtGreenOnLtGray: Str14;
function aLtCyanOnLtGray: Str14;
function abLtCyanOnLtGray: Str14;
function aLtRedOnLtGray: Str14;
function abLtRedOnLtGray: Str14;
function aLtMagentaOnLtGray: Str14;
function abLtMagentaOnLtGray: Str14;
function aYellowOnLtGray: Str14;
function abYellowOnLtGray: Str14;
function aWhiteOnLtGray: Str14;
function abWhiteOnLtGray: Str14;

{==========================================================================}

implementation

const

  { Foreground and background color constants }

  Black: byte     = 0;
  Blue: byte      = 1;
  Green: byte     = 2;
  Cyan: byte      = 3;
  Red: byte       = 4;
  Magenta: byte   = 5;
  Brown: byte     = 6;
  LightGray: byte = 7;

  { Foreground color constants }

  DarkGray: byte     = 8;
  LightBlue: byte    = 9;
  LightGreen: byte   = 10;
  LightCyan: byte    = 11;
  LightRed: byte     = 12;
  LightMagenta: byte = 13;
  Yellow: byte       = 14;
  White: byte        = 15;



function MakeAnsiString(ForeG, BackG: byte): Str14;
begin
  MakeAnsiString := aSt + fgCol[ForeG] + bgCol[BackG] + aEnd;
end;



{Black background}
function aBlackOnBlack: Str14;
begin
  aBlackOnBlack := MakeAnsiString(Black, Black);
end;


function abBlackOnBlack: Str14;
begin
  abBlackOnBlack := MakeAnsiString(Black + aBlink, Black);
end;


function aBlueOnBlack: Str14;
begin
  aBlueOnBlack := MakeAnsiString(Blue, Black);
end;


function abBlueOnBlack: Str14;
begin
  abBlueOnBlack := MakeAnsiString(Blue + aBlink, Black);
end;


function aGreenOnBlack: Str14;
begin
  aGreenOnBlack := MakeAnsiString(Green, Black);
end;


function abGreenOnBlack: Str14;
begin
  abGreenOnBlack := MakeAnsiString(Green + aBlink, Black);
end;


function aCyanOnBlack: Str14;
begin
  aCyanOnBlack := MakeAnsiString(Cyan, Black);
end;


function abCyanOnBlack: Str14;
begin
  abCyanOnBlack := MakeAnsiString(Cyan + aBlink, Black);
end;


function aRedOnBlack: Str14;
begin
  aRedOnBlack := MakeAnsiString(Red, Black);
end;


function abRedOnBlack: Str14;
begin
  abRedOnBlack := MakeAnsiString(Red + aBlink, Black);
end;


function aMagentaOnBlack: Str14;
begin
  aMagentaOnBlack := MakeAnsiString(Magenta, Black);
end;


function abMagentaOnBlack: Str14;
begin
  abMagentaOnBlack := MakeAnsiString(Magenta + aBlink, Black);
end;


function aBrownOnBlack: Str14;
begin
  aBrownOnBlack := MakeAnsiString(Brown, Black);
end;


function abBrownOnBlack: Str14;
begin
  abBrownOnBlack := MakeAnsiString(Brown + aBlink, Black);
end;


function aLtGrayOnBlack: Str14;
begin
  aLtGrayOnBlack := MakeAnsiString(LightGray, Black);
end;


function abLtGrayOnBlack: Str14;
begin
  abLtGrayOnBlack := MakeAnsiString(LightGray + aBlink, Black);
end;


function aDkGrayOnBlack: Str14;
begin
  aDkGrayOnBlack := MakeAnsiString(DarkGray, Black);
end;


function abDkGrayOnBlack: Str14;
begin
  abDkGrayOnBlack := MakeAnsiString(DarkGray + aBlink, Black);
end;


function aLtBlueOnBlack: Str14;
begin
  aLtBlueOnBlack := MakeAnsiString(LightBlue, Black);
end;


function abLtBlueOnBlack: Str14;
begin
  abLtBlueOnBlack := MakeAnsiString(LightBlue + aBlink, Black);
end;


function aLtGreenOnBlack: Str14;
begin
  aLtGreenOnBlack := MakeAnsiString(LightGreen, Black);
end;


function abLtGreenOnBlack: Str14;
begin
  abLtGreenOnBlack := MakeAnsiString(LightGreen + aBlink, Black);
end;


function aLtCyanOnBlack: Str14;
begin
  aLtCyanOnBlack := MakeAnsiString(LightCyan, Black);
end;


function abLtCyanOnBlack: Str14;
begin
  abLtCyanOnBlack := MakeAnsiString(LightCyan + aBlink, Black);
end;


function aLtRedOnBlack: Str14;
begin
  aLtRedOnBlack := MakeAnsiString(LightRed, Black);
end;


function abLtRedOnBlack: Str14;
begin
  abLtRedOnBlack := MakeAnsiString(LightRed + aBlink, Black);
end;


function aLtMagentaOnBlack: Str14;
begin
  aLtMagentaOnBlack := MakeAnsiString(LightMagenta, Black);
end;


function abLtMagentaOnBlack: Str14;
begin
  abLtMagentaOnBlack := MakeAnsiString(LightMagenta + aBlink, Black);
end;


function aYellowOnBlack: Str14;
begin
  aYellowOnBlack := MakeAnsiString(Yellow, Black);
end;


function abYellowOnBlack: Str14;
begin
  abYellowOnBlack := MakeAnsiString(Yellow + aBlink, Black);
end;


function aWhiteOnBlack: Str14;
begin
  aWhiteOnBlack := MakeAnsiString(White, Black);
end;


function abWhiteOnBlack: Str14;
begin
  abWhiteOnBlack := MakeAnsiString(White + aBlink, Black);
end;



{Blue background}
function aBlackOnBlue: Str14;
begin
  aBlackOnBlue := MakeAnsiString(Black, Blue);
end;


function abBlackOnBlue: Str14;
begin
  abBlackOnBlue := MakeAnsiString(Black + aBlink, Blue);
end;


function aBlueOnBlue: Str14;
begin
  aBlueOnBlue := MakeAnsiString(Blue, Blue);
end;


function abBlueOnBlue: Str14;
begin
  abBlueOnBlue := MakeAnsiString(Blue + aBlink, Blue);
end;


function aGreenOnBlue: Str14;
begin
  aGreenOnBlue := MakeAnsiString(Green, Blue);
end;


function abGreenOnBlue: Str14;
begin
  abGreenOnBlue := MakeAnsiString(Green + aBlink, Blue);
end;


function aCyanOnBlue: Str14;
begin
  aCyanOnBlue := MakeAnsiString(Cyan, Blue);
end;


function abCyanOnBlue: Str14;
begin
  abCyanOnBlue := MakeAnsiString(Cyan + aBlink, Blue);
end;


function aRedOnBlue: Str14;
begin
  aRedOnBlue := MakeAnsiString(Red, Blue);
end;


function abRedOnBlue: Str14;
begin
  abRedOnBlue := MakeAnsiString(Red + aBlink, Blue);
end;


function aMagentaOnBlue: Str14;
begin
  aMagentaOnBlue := MakeAnsiString(Magenta, Blue);
end;


function abMagentaOnBlue: Str14;
begin
  abMagentaOnBlue := MakeAnsiString(Magenta + aBlink, Blue);
end;


function aBrownOnBlue: Str14;
begin
  aBrownOnBlue := MakeAnsiString(Brown, Blue);
end;


function abBrownOnBlue: Str14;
begin
  abBrownOnBlue := MakeAnsiString(Brown + aBlink, Blue);
end;


function aLtGrayOnBlue: Str14;
begin
  aLtGrayOnBlue := MakeAnsiString(LightGray, Blue);
end;


function abLtGrayOnBlue: Str14;
begin
  abLtGrayOnBlue := MakeAnsiString(LightGray + aBlink, Blue);
end;


function aDkGrayOnBlue: Str14;
begin
  aDkGrayOnBlue := MakeAnsiString(DarkGray, Blue);
end;


function abDkGrayOnBlue: Str14;
begin
  abDkGrayOnBlue := MakeAnsiString(DarkGray + aBlink, Blue);
end;


function aLtBlueOnBlue: Str14;
begin
  aLtBlueOnBlue := MakeAnsiString(LightBlue, Blue);
end;


function abLtBlueOnBlue: Str14;
begin
  abLtBlueOnBlue := MakeAnsiString(LightBlue + aBlink, Blue);
end;


function aLtGreenOnBlue: Str14;
begin
  aLtGreenOnBlue := MakeAnsiString(LightGreen, Blue);
end;


function abLtGreenOnBlue: Str14;
begin
  abLtGreenOnBlue := MakeAnsiString(LightGreen + aBlink, Blue);
end;


function aLtCyanOnBlue: Str14;
begin
  aLtCyanOnBlue := MakeAnsiString(LightCyan, Blue);
end;


function abLtCyanOnBlue: Str14;
begin
  abLtCyanOnBlue := MakeAnsiString(LightCyan + aBlink, Blue);
end;


function aLtRedOnBlue: Str14;
begin
  aLtRedOnBlue := MakeAnsiString(LightRed, Blue);
end;


function abLtRedOnBlue: Str14;
begin
  abLtRedOnBlue := MakeAnsiString(LightRed + aBlink, Blue);
end;


function aLtMagentaOnBlue: Str14;
begin
  aLtMagentaOnBlue := MakeAnsiString(LightMagenta, Blue);
end;


function abLtMagentaOnBlue: Str14;
begin
  abLtMagentaOnBlue := MakeAnsiString(LightMagenta + aBlink, Blue);
end;


function aYellowOnBlue: Str14;
begin
  aYellowOnBlue := MakeAnsiString(Yellow, Blue);
end;


function abYellowOnBlue: Str14;
begin
  abYellowOnBlue := MakeAnsiString(Yellow + aBlink, Blue);
end;


function aWhiteOnBlue: Str14;
begin
  aWhiteOnBlue := MakeAnsiString(White, Blue);
end;


function abWhiteOnBlue: Str14;
begin
  abWhiteOnBlue := MakeAnsiString(White + aBlink, Blue);
end;



{Green background}
function aBlackOnGreen: Str14;
begin
  aBlackOnGreen := MakeAnsiString(Black, Green);
end;


function abBlackOnGreen: Str14;
begin
  abBlackOnGreen := MakeAnsiString(Black + aBlink, Green);
end;


function aBlueOnGreen: Str14;
begin
  aBlueOnGreen := MakeAnsiString(Blue, Green);
end;


function abBlueOnGreen: Str14;
begin
  abBlueOnGreen := MakeAnsiString(Blue + aBlink, Green);
end;


function aGreenOnGreen: Str14;
begin
  aGreenOnGreen := MakeAnsiString(Green, Green);
end;


function abGreenOnGreen: Str14;
begin
  abGreenOnGreen := MakeAnsiString(Green + aBlink, Green);
end;


function aCyanOnGreen: Str14;
begin
  aCyanOnGreen := MakeAnsiString(Cyan, Green);
end;


function abCyanOnGreen: Str14;
begin
  abCyanOnGreen := MakeAnsiString(Cyan + aBlink, Green);
end;


function aRedOnGreen: Str14;
begin
  aRedOnGreen := MakeAnsiString(Red, Green);
end;


function abRedOnGreen: Str14;
begin
  abRedOnGreen := MakeAnsiString(Red + aBlink, Green);
end;


function aMagentaOnGreen: Str14;
begin
  aMagentaOnGreen := MakeAnsiString(Magenta, Green);
end;


function abMagentaOnGreen: Str14;
begin
  abMagentaOnGreen := MakeAnsiString(Magenta + aBlink, Green);
end;


function aBrownOnGreen: Str14;
begin
  aBrownOnGreen := MakeAnsiString(Brown, Green);
end;


function abBrownOnGreen: Str14;
begin
  abBrownOnGreen := MakeAnsiString(Brown + aBlink, Green);
end;


function aLtGrayOnGreen: Str14;
begin
  aLtGrayOnGreen := MakeAnsiString(LightGray, Green);
end;


function abLtGrayOnGreen: Str14;
begin
  abLtGrayOnGreen := MakeAnsiString(LightGray + aBlink, Green);
end;


function aDkGrayOnGreen: Str14;
begin
  aDkGrayOnGreen := MakeAnsiString(DarkGray, Green);
end;


function abDkGrayOnGreen: Str14;
begin
  abDkGrayOnGreen := MakeAnsiString(DarkGray + aBlink, Green);
end;


function aLtBlueOnGreen: Str14;
begin
  aLtBlueOnGreen := MakeAnsiString(LightBlue, Green);
end;


function abLtBlueOnGreen: Str14;
begin
  abLtBlueOnGreen := MakeAnsiString(LightBlue + aBlink, Green);
end;


function aLtGreenOnGreen: Str14;
begin
  aLtGreenOnGreen := MakeAnsiString(LightGreen, Green);
end;


function abLtGreenOnGreen: Str14;
begin
  abLtGreenOnGreen := MakeAnsiString(LightGreen + aBlink, Green);
end;


function aLtCyanOnGreen: Str14;
begin
  aLtCyanOnGreen := MakeAnsiString(LightCyan, Green);
end;


function abLtCyanOnGreen: Str14;
begin
  abLtCyanOnGreen := MakeAnsiString(LightCyan + aBlink, Green);
end;


function aLtRedOnGreen: Str14;
begin
  aLtRedOnGreen := MakeAnsiString(LightRed, Green);
end;


function abLtRedOnGreen: Str14;
begin
  abLtRedOnGreen := MakeAnsiString(LightRed + aBlink, Green);
end;


function aLtMagentaOnGreen: Str14;
begin
  aLtMagentaOnGreen := MakeAnsiString(LightMagenta, Green);
end;


function abLtMagentaOnGreen: Str14;
begin
  abLtMagentaOnGreen := MakeAnsiString(LightMagenta + aBlink, Green);
end;


function aYellowOnGreen: Str14;
begin
  aYellowOnGreen := MakeAnsiString(Yellow, Green);
end;


function abYellowOnGreen: Str14;
begin
  abYellowOnGreen := MakeAnsiString(Yellow + aBlink, Green);
end;


function aWhiteOnGreen: Str14;
begin
  aWhiteOnGreen := MakeAnsiString(White, Green);
end;


function abWhiteOnGreen: Str14;
begin
  abWhiteOnGreen := MakeAnsiString(White + aBlink, Green);
end;



{Cyan background}
function aBlackOnCyan: Str14;
begin
  aBlackOnCyan := MakeAnsiString(Black, Cyan);
end;


function abBlackOnCyan: Str14;
begin
  abBlackOnCyan := MakeAnsiString(Black + aBlink, Cyan);
end;


function aBlueOnCyan: Str14;
begin
  aBlueOnCyan := MakeAnsiString(Blue, Cyan);
end;


function abBlueOnCyan: Str14;
begin
  abBlueOnCyan := MakeAnsiString(Blue + aBlink, Cyan);
end;


function aGreenOnCyan: Str14;
begin
  aGreenOnCyan := MakeAnsiString(Green, Cyan);
end;


function abGreenOnCyan: Str14;
begin
  abGreenOnCyan := MakeAnsiString(Green + aBlink, Cyan);
end;


function aCyanOnCyan: Str14;
begin
  aCyanOnCyan := MakeAnsiString(Cyan, Cyan);
end;


function abCyanOnCyan: Str14;
begin
  abCyanOnCyan := MakeAnsiString(Cyan + aBlink, Cyan);
end;


function aRedOnCyan: Str14;
begin
  aRedOnCyan := MakeAnsiString(Red, Cyan);
end;


function abRedOnCyan: Str14;
begin
  abRedOnCyan := MakeAnsiString(Red + aBlink, Cyan);
end;


function aMagentaOnCyan: Str14;
begin
  aMagentaOnCyan := MakeAnsiString(Magenta, Cyan);
end;


function abMagentaOnCyan: Str14;
begin
  abMagentaOnCyan := MakeAnsiString(Magenta + aBlink, Cyan);
end;


function aBrownOnCyan: Str14;
begin
  aBrownOnCyan := MakeAnsiString(Brown, Cyan);
end;


function abBrownOnCyan: Str14;
begin
  abBrownOnCyan := MakeAnsiString(Brown + aBlink, Cyan);
end;


function aLtGrayOnCyan: Str14;
begin
  aLtGrayOnCyan := MakeAnsiString(LightGray, Cyan);
end;


function abLtGrayOnCyan: Str14;
begin
  abLtGrayOnCyan := MakeAnsiString(LightGray + aBlink, Cyan);
end;


function aDkGrayOnCyan: Str14;
begin
  aDkGrayOnCyan := MakeAnsiString(DarkGray, Cyan);
end;


function abDkGrayOnCyan: Str14;
begin
  abDkGrayOnCyan := MakeAnsiString(DarkGray + aBlink, Cyan);
end;


function aLtBlueOnCyan: Str14;
begin
  aLtBlueOnCyan := MakeAnsiString(LightBlue, Cyan);
end;


function abLtBlueOnCyan: Str14;
begin
  abLtBlueOnCyan := MakeAnsiString(LightBlue + aBlink, Cyan);
end;


function aLtGreenOnCyan: Str14;
begin
  aLtGreenOnCyan := MakeAnsiString(LightGreen, Cyan);
end;


function abLtGreenOnCyan: Str14;
begin
  abLtGreenOnCyan := MakeAnsiString(LightGreen + aBlink, Cyan);
end;


function aLtCyanOnCyan: Str14;
begin
  aLtCyanOnCyan := MakeAnsiString(LightCyan, Cyan);
end;


function abLtCyanOnCyan: Str14;
begin
  abLtCyanOnCyan := MakeAnsiString(LightCyan + aBlink, Cyan);
end;


function aLtRedOnCyan: Str14;
begin
  aLtRedOnCyan := MakeAnsiString(LightRed, Cyan);
end;


function abLtRedOnCyan: Str14;
begin
  abLtRedOnCyan := MakeAnsiString(LightRed + aBlink, Cyan);
end;


function aLtMagentaOnCyan: Str14;
begin
  aLtMagentaOnCyan := MakeAnsiString(LightMagenta, Cyan);
end;


function abLtMagentaOnCyan: Str14;
begin
  abLtMagentaOnCyan := MakeAnsiString(LightMagenta + aBlink, Cyan);
end;


function aYellowOnCyan: Str14;
begin
  aYellowOnCyan := MakeAnsiString(Yellow, Cyan);
end;


function abYellowOnCyan: Str14;
begin
  abYellowOnCyan := MakeAnsiString(Yellow + aBlink, Cyan);
end;


function aWhiteOnCyan: Str14;
begin
  aWhiteOnCyan := MakeAnsiString(White, Cyan);
end;


function abWhiteOnCyan: Str14;
begin
  abWhiteOnCyan := MakeAnsiString(White + aBlink, Cyan);
end;



{Red background}
function aBlackOnRed: Str14;
begin
  aBlackOnRed := MakeAnsiString(Black, Red);
end;


function abBlackOnRed: Str14;
begin
  abBlackOnRed := MakeAnsiString(Black + aBlink, Red);
end;


function aBlueOnRed: Str14;
begin
  aBlueOnRed := MakeAnsiString(Blue, Red);
end;


function abBlueOnRed: Str14;
begin
  abBlueOnRed := MakeAnsiString(Blue + aBlink, Red);
end;


function aGreenOnRed: Str14;
begin
  aGreenOnRed := MakeAnsiString(Green, Red);
end;


function abGreenOnRed: Str14;
begin
  abGreenOnRed := MakeAnsiString(Green + aBlink, Red);
end;


function aCyanOnRed: Str14;
begin
  aCyanOnRed := MakeAnsiString(Cyan, Red);
end;


function abCyanOnRed: Str14;
begin
  abCyanOnRed := MakeAnsiString(Cyan + aBlink, Red);
end;


function aRedOnRed: Str14;
begin
  aRedOnRed := MakeAnsiString(Red, Red);
end;


function abRedOnRed: Str14;
begin
  abRedOnRed := MakeAnsiString(Red + aBlink, Red);
end;


function aMagentaOnRed: Str14;
begin
  aMagentaOnRed := MakeAnsiString(Magenta, Red);
end;


function abMagentaOnRed: Str14;
begin
  abMagentaOnRed := MakeAnsiString(Magenta + aBlink, Red);
end;


function aBrownOnRed: Str14;
begin
  aBrownOnRed := MakeAnsiString(Brown, Red);
end;


function abBrownOnRed: Str14;
begin
  abBrownOnRed := MakeAnsiString(Brown + aBlink, Red);
end;


function aLtGrayOnRed: Str14;
begin
  aLtGrayOnRed := MakeAnsiString(LightGray, Red);
end;


function abLtGrayOnRed: Str14;
begin
  abLtGrayOnRed := MakeAnsiString(LightGray + aBlink, Red);
end;


function aDkGrayOnRed: Str14;
begin
  aDkGrayOnRed := MakeAnsiString(DarkGray, Red);
end;


function abDkGrayOnRed: Str14;
begin
  abDkGrayOnRed := MakeAnsiString(DarkGray + aBlink, Red);
end;


function aLtBlueOnRed: Str14;
begin
  aLtBlueOnRed := MakeAnsiString(LightBlue, Red);
end;


function abLtBlueOnRed: Str14;
begin
  abLtBlueOnRed := MakeAnsiString(LightBlue + aBlink, Red);
end;


function aLtGreenOnRed: Str14;
begin
  aLtGreenOnRed := MakeAnsiString(LightGreen, Red);
end;


function abLtGreenOnRed: Str14;
begin
  abLtGreenOnRed := MakeAnsiString(LightGreen + aBlink, Red);
end;


function aLtCyanOnRed: Str14;
begin
  aLtCyanOnRed := MakeAnsiString(LightCyan, Red);
end;


function abLtCyanOnRed: Str14;
begin
  abLtCyanOnRed := MakeAnsiString(LightCyan + aBlink, Red);
end;


function aLtRedOnRed: Str14;
begin
  aLtRedOnRed := MakeAnsiString(LightRed, Red);
end;


function abLtRedOnRed: Str14;
begin
  abLtRedOnRed := MakeAnsiString(LightRed + aBlink, Red);
end;


function aLtMagentaOnRed: Str14;
begin
  aLtMagentaOnRed := MakeAnsiString(LightMagenta, Red);
end;


function abLtMagentaOnRed: Str14;
begin
  abLtMagentaOnRed := MakeAnsiString(LightMagenta + aBlink, Red);
end;


function aYellowOnRed: Str14;
begin
  aYellowOnRed := MakeAnsiString(Yellow, Red);
end;


function abYellowOnRed: Str14;
begin
  abYellowOnRed := MakeAnsiString(Yellow + aBlink, Red);
end;


function aWhiteOnRed: Str14;
begin
  aWhiteOnRed := MakeAnsiString(White, Red);
end;


function abWhiteOnRed: Str14;
begin
  abWhiteOnRed := MakeAnsiString(White + aBlink, Red);
end;



{Magenta background}
function aBlackOnMagenta: Str14;
begin
  aBlackOnMagenta := MakeAnsiString(Black, Magenta);
end;


function abBlackOnMagenta: Str14;
begin
  abBlackOnMagenta := MakeAnsiString(Black + aBlink, Magenta);
end;


function aBlueOnMagenta: Str14;
begin
  aBlueOnMagenta := MakeAnsiString(Blue, Magenta);
end;


function abBlueOnMagenta: Str14;
begin
  abBlueOnMagenta := MakeAnsiString(Blue + aBlink, Magenta);
end;


function aGreenOnMagenta: Str14;
begin
  aGreenOnMagenta := MakeAnsiString(Green, Magenta);
end;


function abGreenOnMagenta: Str14;
begin
  abGreenOnMagenta := MakeAnsiString(Green + aBlink, Magenta);
end;


function aCyanOnMagenta: Str14;
begin
  aCyanOnMagenta := MakeAnsiString(Cyan, Magenta);
end;


function abCyanOnMagenta: Str14;
begin
  abCyanOnMagenta := MakeAnsiString(Cyan + aBlink, Magenta);
end;


function aRedOnMagenta: Str14;
begin
  aRedOnMagenta := MakeAnsiString(Red, Magenta);
end;


function abRedOnMagenta: Str14;
begin
  abRedOnMagenta := MakeAnsiString(Red + aBlink, Magenta);
end;


function aMagentaOnMagenta: Str14;
begin
  aMagentaOnMagenta := MakeAnsiString(Magenta, Magenta);
end;


function abMagentaOnMagenta: Str14;
begin
  abMagentaOnMagenta := MakeAnsiString(Magenta + aBlink, Magenta);
end;


function aBrownOnMagenta: Str14;
begin
  aBrownOnMagenta := MakeAnsiString(Brown, Magenta);
end;


function abBrownOnMagenta: Str14;
begin
  abBrownOnMagenta := MakeAnsiString(Brown + aBlink, Magenta);
end;


function aLtGrayOnMagenta: Str14;
begin
  aLtGrayOnMagenta := MakeAnsiString(LightGray, Magenta);
end;


function abLtGrayOnMagenta: Str14;
begin
  abLtGrayOnMagenta := MakeAnsiString(LightGray + aBlink, Magenta);
end;


function aDkGrayOnMagenta: Str14;
begin
  aDkGrayOnMagenta := MakeAnsiString(DarkGray, Magenta);
end;


function abDkGrayOnMagenta: Str14;
begin
  abDkGrayOnMagenta := MakeAnsiString(DarkGray + aBlink, Magenta);
end;


function aLtBlueOnMagenta: Str14;
begin
  aLtBlueOnMagenta := MakeAnsiString(LightBlue, Magenta);
end;


function abLtBlueOnMagenta: Str14;
begin
  abLtBlueOnMagenta := MakeAnsiString(LightBlue + aBlink, Magenta);
end;


function aLtGreenOnMagenta: Str14;
begin
  aLtGreenOnMagenta := MakeAnsiString(LightGreen, Magenta);
end;


function abLtGreenOnMagenta: Str14;
begin
  abLtGreenOnMagenta := MakeAnsiString(LightGreen + aBlink, Magenta);
end;


function aLtCyanOnMagenta: Str14;
begin
  aLtCyanOnMagenta := MakeAnsiString(LightCyan, Magenta);
end;


function abLtCyanOnMagenta: Str14;
begin
  abLtCyanOnMagenta := MakeAnsiString(Lightcyan + aBlink, Magenta);
end;


function aLtRedOnMagenta: Str14;
begin
  aLtRedOnMagenta := MakeAnsiString(LightRed, Magenta);
end;


function abLtRedOnMagenta: Str14;
begin
  abLtRedOnMagenta := MakeAnsiString(LightRed + aBlink, Magenta);
end;


function aLtMagentaOnMagenta: Str14;
begin
  aLtMagentaOnMagenta := MakeAnsiString(LightMagenta, Magenta);
end;


function abLtMagentaOnMagenta: Str14;
begin
  abLtMagentaOnMagenta := MakeAnsiString(LightMagenta + aBlink, Magenta);
end;


function aYellowOnMagenta: Str14;
begin
  aYellowOnMagenta := MakeAnsiString(Yellow, Magenta);
end;


function abYellowOnMagenta: Str14;
begin
  abYellowOnMagenta := MakeAnsiString(Yellow + aBlink, Magenta);
end;


function aWhiteOnMagenta: Str14;
begin
  aWhiteOnMagenta := MakeAnsiString(White, Magenta);
end;


function abWhiteOnMagenta: Str14;
begin
  abWhiteOnMagenta := MakeAnsiString(White + aBlink, Magenta);
end;



{Brown background}
function aBlackOnBrown: Str14;
begin
  aBlackOnBrown := MakeAnsiString(Black, Brown);
end;


function abBlackOnBrown: Str14;
begin
  abBlackOnBrown := MakeAnsiString(Black + aBlink, Brown);
end;


function aBlueOnBrown: Str14;
begin
  aBlueOnBrown := MakeAnsiString(Blue, Brown);
end;


function abBlueOnBrown: Str14;
begin
  abBlueOnBrown := MakeAnsiString(Blue + aBlink, Brown);
end;


function aGreenOnBrown: Str14;
begin
  aGreenOnBrown := MakeAnsiString(Green, Brown);
end;


function abGreenOnBrown: Str14;
begin
  abGreenOnBrown := MakeAnsiString(Green + aBlink, Brown);
end;


function aCyanOnBrown: Str14;
begin
  aCyanOnBrown := MakeAnsiString(Cyan, Brown);
end;


function abCyanOnBrown: Str14;
begin
  abCyanOnBrown := MakeAnsiString(Cyan + aBlink, Brown);
end;


function aRedOnBrown: Str14;
begin
  aRedOnBrown := MakeAnsiString(Red, Brown);
end;


function abRedOnBrown: Str14;
begin
  abRedOnBrown := MakeAnsiString(Red + aBlink, Brown);
end;


function aMagentaOnBrown: Str14;
begin
  aMagentaOnBrown := MakeAnsiString(Magenta, Brown);
end;


function abMagentaOnBrown: Str14;
begin
  abMagentaOnBrown := MakeAnsiString(Magenta + aBlink, Brown);
end;


function aBrownOnBrown: Str14;
begin
  aBrownOnBrown := MakeAnsiString(Brown, Brown);
end;


function abBrownOnBrown: Str14;
begin
  abBrownOnBrown := MakeAnsiString(Brown + aBlink, Brown);
end;


function aLtGrayOnBrown: Str14;
begin
  aLtGrayOnBrown := MakeAnsiString(LightGray, Brown);
end;


function abLtGrayOnBrown: Str14;
begin
  abLtGrayOnBrown := MakeAnsiString(LightGray + aBlink, Brown);
end;


function aDkGrayOnBrown: Str14;
begin
  aDkGrayOnBrown := MakeAnsiString(DarkGray, Brown);
end;


function abDkGrayOnBrown: Str14;
begin
  abDkGrayOnBrown := MakeAnsiString(DarkGray + aBlink, Brown);
end;


function aLtBlueOnBrown: Str14;
begin
  aLtBlueOnBrown := MakeAnsiString(LightBlue, Brown);
end;


function abLtBlueOnBrown: Str14;
begin
  abLtBlueOnBrown := MakeAnsiString(LightBlue + aBlink, Brown);
end;


function aLtGreenOnBrown: Str14;
begin
  aLtGreenOnBrown := MakeAnsiString(LightGreen, Brown);
end;


function abLtGreenOnBrown: Str14;
begin
  abLtGreenOnBrown := MakeAnsiString(LightGreen + aBlink, Brown);
end;


function aLtCyanOnBrown: Str14;
begin
  aLtCyanOnBrown := MakeAnsiString(LightCyan, Brown);
end;


function abLtCyanOnBrown: Str14;
begin
  abLtCyanOnBrown := MakeAnsiString(LightCyan + aBlink, Brown);
end;


function aLtRedOnBrown: Str14;
begin
  aLtRedOnBrown := MakeAnsiString(LightRed, Brown);
end;


function abLtRedOnBrown: Str14;
begin
  abLtRedOnBrown := MakeAnsiString(LightRed + aBlink, Brown);
end;


function aLtMagentaOnBrown: Str14;
begin
  aLtMagentaOnBrown := MakeAnsiString(LightMagenta, Brown);
end;


function abLtMagentaOnBrown: Str14;
begin
  abLtMagentaOnBrown := MakeAnsiString(LightMagenta + aBlink, Brown);
end;


function aYellowOnBrown: Str14;
begin
  aYellowOnBrown := MakeAnsiString(Yellow, Brown);
end;


function abYellowOnBrown: Str14;
begin
  abYellowOnBrown := MakeAnsiString(Yellow + aBlink, Brown);
end;


function aWhiteOnBrown: Str14;
begin
  aWhiteOnBrown := MakeAnsiString(White, Brown);
end;


function abWhiteOnBrown: Str14;
begin
  abWhiteOnBrown := MakeAnsiString(White + aBlink, Brown);
end;



{Light gray backgrouund}
function aBlackOnLtGray: Str14;
begin
  aBlackOnLtGray := MakeAnsiString(Black, LightGray);
end;


function abBlackOnLtGray: Str14;
begin
  abBlackOnLtGray := MakeAnsiString(Black + aBlink, LightGray);
end;


function aBlueOnLtGray: Str14;
begin
  aBlueOnLtGray := MakeAnsiString(Blue, LightGray);
end;


function abBlueOnLtGray: Str14;
begin
  abBlueOnLtGray := MakeAnsiString(Blue + aBlink, LightGray);
end;


function aGreenOnLtGray: Str14;
begin
  aGreenOnLtGray := MakeAnsiString(Green, LightGray);
end;


function abGreenOnLtGray: Str14;
begin
  abGreenOnLtGray := MakeAnsiString(Green + aBlink, LightGray);
end;


function aCyanOnLtGray: Str14;
begin
  aCyanOnLtGray := MakeAnsiString(Cyan, LightGray);
end;


function abCyanOnLtGray: Str14;
begin
  abCyanOnLtGray := MakeAnsiString(Cyan + aBlink, LightGray);
end;


function aRedOnLtGray: Str14;
begin
  aRedOnLtGray := MakeAnsiString(Red, LightGray);
end;


function abRedOnLtGray: Str14;
begin
  abRedOnLtGray := MakeAnsiString(Red + aBlink, LightGray);
end;


function aMagentaOnLtGray: Str14;
begin
  aMagentaOnLtGray := MakeAnsiString(Magenta, LightGray);
end;


function abMagentaOnLtGray: Str14;
begin
  abMagentaOnLtGray := MakeAnsiString(Magenta + aBlink, LightGray);
end;


function aBrownOnLtGray: Str14;
begin
  aBrownOnLtGray := MakeAnsiString(Brown, LightGray);
end;


function abBrownOnLtGray: Str14;
begin
  abBrownOnLtGray := MakeAnsiString(Brown + aBlink, LightGray);
end;


function aLtGrayOnLtGray: Str14;
begin
  aLtGrayOnLtGray := MakeAnsiString(LightGray, LightGray);
end;


function abLtGrayOnLtGray: Str14;
begin
  abLtGrayOnLtGray := MakeAnsiString(LightGray + aBlink, LightGray);
end;


function aDkGrayOnLtGray: Str14;
begin
  aDkGrayOnLtGray := MakeAnsiString(DarkGray, LightGray);
end;


function abDkGrayOnLtGray: Str14;
begin
  abDkGrayOnLtGray := MakeAnsiString(DarkGray + aBlink, LightGray);
end;


function aLtBlueOnLtGray: Str14;
begin
  aLtBlueOnLtGray := MakeAnsiString(LightBlue, LightGray);
end;


function abLtBlueOnLtGray: Str14;
begin
  abLtBlueOnLtGray := MakeAnsiString(LightBlue + aBlink, LightGray);
end;


function aLtGreenOnLtGray: Str14;
begin
  aLtGreenOnLtGray := MakeAnsiString(LightGreen, LightGray);
end;


function abLtGreenOnLtGray: Str14;
begin
  abLtGreenOnLtGray := MakeAnsiString(LightGreen + aBlink, LightGray);
end;


function aLtCyanOnLtGray: Str14;
begin
  aLtCyanOnLtGray := MakeAnsiString(LightCyan, LightGray);
end;


function abLtCyanOnLtGray: Str14;
begin
  abLtCyanOnLtGray := MakeAnsiString(LightCyan + aBlink, LightGray);
end;


function aLtRedOnLtGray: Str14;
begin
  aLtRedOnLtGray := MakeAnsiString(LightRed, LightGray);
end;


function abLtRedOnLtGray: Str14;
begin
  abLtRedOnLtGray := MakeAnsiString(LightRed + aBlink, LightGray);
end;


function aLtMagentaOnLtGray: Str14;
begin
  aLtMagentaOnLtGray := MakeAnsiString(LightMagenta, LightGray);
end;


function abLtMagentaOnLtGray: Str14;
begin
  abLtMagentaOnLtGray := MakeAnsiString(LightMagenta + aBlink, LightGray);
end;


function aYellowOnLtGray: Str14;
begin
  aYellowOnLtGray := MakeAnsiString(Yellow, LightGray);
end;


function abYellowOnLtGray: Str14;
begin
  abYellowOnLtGray := MakeAnsiString(Yellow + aBlink, LightGray);
end;


function aWhiteOnLtGray: Str14;
begin
  aWhiteOnLtGray := MakeAnsiString(White, LightGray);
end;


function abWhiteOnLtGray: Str14;
begin
  abWhiteOnLtGray := MakeAnsiString(White + aBlink, LightGray);
end;




begin

end. {Unit AnsiColr .end.}
